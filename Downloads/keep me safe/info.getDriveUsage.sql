USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[getDriveUsage]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getDriveUsage] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[getDriveUsage] ( @units varchar(10) = 'GB', @RetentionDays INT = 30, @DryRun TINYINT = 1 )
AS
BEGIN
--  EXEC [info].[getDriveUsage] @dryRun = 0
/* Needs to be updated to handle ZAURE instances */


	DECLARE @HostName varchar(255)
	DECLARE @sql varchar(4000)
	--by default it will take the current server name, we can the set the server name as well
	-- Need to swap this to an if contains take the left of charIndex('\') and then use @HostName
	Select @HostName = convert(varchar(255), SERVERPROPERTY('MachineName') )

	set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@HostName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,label,capacity,freespace | foreach{$_.name+$_.label+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'
	--creating a temporary table
	IF OBJECT_ID('tempdb..#output') IS NOT NULL
		DROP TABLE #output;
	CREATE TABLE #output
	(line varchar(255))
	--inserting disk name, total space and free space value in to temporary table
	insert #output
	EXEC xp_cmdshell @sql --necesary evil

	If( @units = 'MB')
		BEGIN
			--script to retrieve the values in MB from PS Script output
			set @sql = 'select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX(''|'',line) -1))) as drivename
							,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''|'',line)+1,
							(CHARINDEX(''%'',line) -1)-CHARINDEX(''|'',line)) )) as Float),0) as ''capacity(MB)''
							,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''%'',line)+1,
							(CHARINDEX(''*'',line) -1)-CHARINDEX(''%'',line)) )) as Float),0) as ''freespace(MB)''
							,round(round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''%'',line)+1,
							(CHARINDEX(''*'',line) -1)-CHARINDEX(''%'',line)) )) as Float),0)/
							round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''|'',line)+1,
							(CHARINDEX(''%'',line) -1)-CHARINDEX(''|'',line)) )) as Float),0),2)*100 as ''percentFree'',
							getdate() as HarvestDate
						from #output
						where line like ''[A-Z][:]%''
						order by drivename'
		END
	ELSE
		BEGIN
			--script to retrieve the values in GB from PS Script output
			set @sql = 'select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX(''|'',line) -1))) as drivename
						   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''|'',line)+1,
						   (CHARINDEX(''%'',line) -1)-CHARINDEX(''|'',line)) )) as Float)/1024,0) as [capacity(GB)]
						   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''%'',line)+1,
						   (CHARINDEX(''*'',line) -1)-CHARINDEX(''%'',line)) )) as Float) /1024 ,0)as [freespace(GB)]
						   ,round(round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''%'',line)+1,
						   (CHARINDEX(''*'',line) -1)-CHARINDEX(''%'',line)) )) as Float) /1024 ,0)/round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX(''|'',line)+1,
						   (CHARINDEX(''%'',line) -1)-CHARINDEX(''|'',line)) )) as Float)/1024,0),2)*100 as [percentFree],
							getdate() as HarvestDate
						from #output
						where line like ''[A-Z][:]%''
						order by drivename'
		END

	IF OBJECT_ID('tempdb..#DriveUsage') IS NOT NULL
		DROP TABLE #DriveUsage;
	CREATE TABLE #DriveUsage(
		[Path] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TotalGB] [bigint] NULL,
		[FreeGB] [bigint] NULL,
		[FreePct] [float] NULL,
		[HarvestDate] DateTime
	) WITH (DATA_COMPRESSION = PAGE);

	INSERT INTO #DriveUsage
		EXEC(@sql)

	IF( @dryRun = 0 )
		BEGIN
			MERGE [info].[DriveUsage] AS old
				USING ( SELECT [Path], [TotalGB], [FreeGB], [FreePct], [HarvestDate]
						FROM #DriveUsage ) AS new ( [Path], [TotalGB], [FreeGB], [FreePct], [HarvestDate] )
				ON new.[Path] = old.[Path] 
				WHEN MATCHED AND (  old.[TotalGB] <> new.[TotalGB] OR old.[FreeGB] <> new.[FreeGB] OR 
									old.[FreePct] <> new.[FreePct] OR old.HarvestDate <> new.HarvestDate
								 ) THEN
					UPDATE SET 
						old.[TotalGB] = new.[TotalGB], old.[FreeGB] = new.[FreeGB], 
						old.[FreePct] = new.[FreePct], old.HarvestDate = new.HarvestDate
				WHEN NOT MATCHED THEN
					INSERT( [Path], [TotalGB], [FreeGB], [FreePct], [HarvestDate] )
					VALUES( new.[Path], new.[TotalGB], new.[FreeGB], new.[FreePct], new.[HarvestDate] )
				WHEN NOT MATCHED by SOURCE THEN 
					DELETE;

		END;
	ELSE
		BEGIN
		  	SELECT [Path], [TotalGB], [FreeGB], [FreePct], [HarvestDate] as [DryRunDate]
			FROM #DriveUsage;
		  END;
END;