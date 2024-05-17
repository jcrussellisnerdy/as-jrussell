USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[backup].[DiscoverDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [backup].[DiscoverDatabase] AS RETURN 0;' 
END
GO

ALTER PROCEDURE [backup].[DiscoverDatabase] ( @dryRun int = 1 )
AS
BEGIN
	set nocount on;
	-- EXEC [backup].[DiscoverDatabase] @DryRun = 0

	DECLARE @dbname sysname,
			@state	int, 
			@dbtype varchar(25),
			@NumOfFiles int = 8,
			@recovery_model varchar(25);
	
	-- Marking absent datqabases as "Excluded"
	PRINT 'Attempting to remove any missing databases from our configuration (SET @Exclude = 1)';
		
	-- delete, for output
	IF EXISTS( SELECT * FROM [backup].[Schedule] WHERE [DatabaseName] NOT IN (select name from sys.databases) )
		begin
			print 'Found missing databases:';
			SELECT * FROM [backup].[Schedule] WHERE [DatabaseName] NOT IN (select name from sys.databases)
			
			IF( @DryRun = 0 )
			BEGIN
				UPDATE [backup].[Schedule]
				SET Exclude = 1
				WHERE [DatabaseName] NOT IN (select name from sys.databases)
			END
		end
	ELSE
		begin
			print '... No databases to prune';
		end

	--creating a temporary table
	IF OBJECT_ID('tempdb..#Schedule') IS NOT NULL
		DROP TABLE #Schedule;		
	CREATE TABLE #Schedule(
		[DatabaseName] varchar(100),
		[DatabaseType] varchar(100),
		[BackupMethod] varchar(100),
		[ExpectedRecoveryModel] varchar(100), 
		Sunday varchar(100), 
		Monday varchar(100), 
		Tuesday varchar(100), 
		Wednesday varchar(100),	
		Thursday varchar(100), 
		Friday varchar(100), 
		Saturday varchar(100),
		NumberOfFiles int, 
		WithCompression int,
		CompressionLevel int,
		WithEncryption int,
		Exclude int
	) WITH (DATA_COMPRESSION = PAGE);

	-- Default values should come from DBA.Backup.ScheduleConfig
	INSERT INTO #Schedule
	SELECT [name] as DatabaseName, case when name in ('master', 'model', 'msdb', 'DBA', 'ReportServer', 'ReportServerTempDB') then 'SYSTEM' 
										WHEN name like '%Storage' THEN 'SYSTEM' 
										else 'USER' 
									end as DatabaseType, 
		'ddboost' as BackupMethod, recovery_model_desc as ExpectedRecoveryModel, 
		'FULL' AS Sunday, 'FULL' AS Monday, 'FULL' AS Tuesday, 'FULL' AS Wednesday,	'FULL' AS Thursday, 'FULL' AS Friday, 'FULL' AS Saturday,
		8 AS NumberOfFiles, 0 AS WithCompression, 0 AS CompressionLevel, 0 AS WithEncryption, CASE WHEN state = 0 then 0 else 1 END AS Exclude
	from sys.databases (nolock)
	where [name] not in ('tempdb') AND databasePropertyEx([name], 'Updateability') = 'READ_WRITE'
	order by [name];

	-- These values should be in DBA.BAckup.ScheduleConfig
	update #Schedule -- UniTrac - should be a size determiniation
	SET Monday = 'DIFF', Tuesday = 'DIFF', Wednesday = 'DIFF', Thursday = 'DIFF', Friday = 'DIFF', Saturday = 'DIFF', NumberOfFiles = 32
	WHERE DatabaseName ='unitrac'

	update #Schedule
	SET Monday = 'DIFF', Tuesday = 'DIFF', Wednesday = 'DIFF', Thursday = 'DIFF', Friday = 'DIFF', Saturday = 'DIFF', NumberOfFiles = 16
	WHERE DatabaseName ='InventoryDWH'

	update #Schedule -- ReportServer
	SET Monday = 'DIFF', Tuesday = 'DIFF', Wednesday = 'DIFF', Thursday = 'DIFF', Friday = 'DIFF', Saturday = 'DIFF', NumberOfFiles = 2
	WHERE DatabaseName IN ('ReportServer', 'ReportServerTempDB', 'DBA')

	IF( @DryRun = 0 )
		BEGIN
			-- MERGE!!!!!
			MERGE [DBA].[backup].[Schedule] AS TARGET
			USING #Schedule AS SOURCE
			ON (
					TARGET.DatabaseName = SOURCE.DatabaseName
				)
			WHEN MATCHED THEN UPDATE
				SET TARGET.DatabaseType = SOURCE.DatabaseType, TARGET.BAckupMethod = SOURCE.BAckupMethod, 
					TARGET.[ExpectedRecoveryModel] = SOURCE.[ExpectedRecoveryModel], TARGET.Sunday = SOURCE.Sunday, 
					TARGET.Monday = SOURCE.Monday, TARGET.Tuesday = SOURCE.Tuesday, 
					TARGET.Wednesday = SOURCE.Wednesday, TARGET.Thursday = SOURCE.Thursday, 
					TARGET.Friday = SOURCE.Friday, TARGET.Saturday = SOURCE.Saturday, 
					TARGET.NumberOfFiles = SOURCE.NumberOfFiles, TARGET.[WithCompression] = SOURCE.[WithCompression], 
					TARGET.[CompressionLevel] = SOURCE.[CompressionLevel], TARGET.[WithEncryption] = SOURCE.[WithEncryption],
					TARGET.Exclude = SOURCE.Exclude
			/* Inserts records into the target table */
			WHEN NOT MATCHED BY TARGET THEN
				INSERT
				( [DatabaseName], [DatabaseType], [BackupMethod], [ExpectedRecoveryModel],  
					[Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday],
					[NumberOfFiles], [WithCompression], [CompressionLevel], [WithEncryption], [Exclude] )
				VALUES
				( SOURCE.[DatabaseName], SOURCE.[DatabaseType], SOURCE.[BackupMethod], SOURCE.[ExpectedRecoveryModel], 
					SOURCE.[Sunday], SOURCE.[Monday], SOURCE.[Tuesday], SOURCE.[Wednesday], SOURCE.[Thursday], SOURCE.[Friday], SOURCE.[Saturday],
					SOURCE.[NumberOfFiles], SOURCE.[WithCompression], SOURCE.[CompressionLevel], SOURCE.[WithEncryption], SOURCE.[Exclude]  );

			/* Delete records that exist in the target table, but not in the source table */
			-- Currently we just mark to be excluded
			--	WHEN NOT MATCHED BY SOURCE THEN
			--	DELETE;
		END
	ELSE
		BEGIN
			SELECT * FROM #Schedule ORDER BY DatabaseName;
		END
END;

/* Remove old versions */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ddbma].[DiscoverDatabases]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'DROP PROCEDURE [ddbma].[DiscoverDatabases];' 
END
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[deploy].[setDatabaseBackup]') AND type in (N'P', N'PC'))
--BEGIN
--	EXEC dbo.sp_executesql @statement = N'DROP PROCEDURE [deploy].[setDatabaseBackup];' 
--END
