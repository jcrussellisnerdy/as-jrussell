	DECLARE @retVal INT,
			@Time   INT ='900';

	IF Object_id(N'tempdb..#AGCheck') IS NOT NULL
	  DROP TABLE #AGCheck
	CREATE TABLE #AGCheck

	  (
		 [seconds behind]                   INT,
		 [DatabaseName - secondary_replica] VARCHAR(250),
		 [ServerName]                       VARCHAR(250),
		 [group_name]                       VARCHAR(100)
	  );

	;
	WITH AG_Stats
		 AS (SELECT AR.replica_server_name,
					AG.name                  AS AGName,
					HARS.role_desc,
					Db_name(DRS.database_id) [DBName],
					DRS.last_commit_time
			 FROM   sys.dm_hadr_database_replica_states DRS
					INNER JOIN sys.availability_replicas AR
							ON DRS.replica_id = AR.replica_id
					INNER JOIN sys.dm_hadr_availability_replica_states HARS
							ON AR.group_id = HARS.group_id
							   AND AR.replica_id = HARS.replica_id
					INNER JOIN [sys].[availability_groups] AG
							ON AG.group_id = AR.group_id),
		 Pri_CommitTime
		 AS (SELECT replica_server_name,
					AGNAME,
					DBName,
					last_commit_time
			 FROM   AG_Stats
			 WHERE  role_desc = 'PRIMARY'),
		 Sec_CommitTime
		 AS (SELECT replica_server_name,
					AGNAME,
					DBName,
					last_commit_time
			 FROM   AG_Stats
			 WHERE  role_desc = 'SECONDARY')
	INSERT INTO #AGCheck
	SELECT Datediff(ss, s.last_commit_time, p.last_commit_time) AS [Seconds Behind],
		   @@SERVERNAME,
		   p.[DBName] + ' - ' + s.replica_server_name           AS [DatabaseName - secondary_replica],
		   p.AGNAME
	FROM   Pri_CommitTime p
		   LEFT JOIN Sec_CommitTime s
				  ON [s].[DBName] = [p].[DBName]
					 AND s.AGNAME = p.AGNAME
	WHERE  Datediff(ss, s.last_commit_time, p.last_commit_time) >= @Time

	IF Object_id(N'tempdb..#SpaceDrive') IS NOT NULL
	  DROP TABLE #SpaceDrive

	CREATE TABLE #SpaceDrive
	  (
		 volume_mount_point   NVARCHAR(1000),
		 file_system_type     VARCHAR(10),
		 logical_volume_name  VARCHAR(100),
		 [Total Size (GB)]    NVARCHAR(1000),
		 [Available Size (GB)]NVARCHAR(1000),
		 [Free Space %]       INT
	  );

	INSERT INTO #SpaceDrive
	SELECT DISTINCT vs.volume_mount_point,
					vs.file_system_type,
					vs.logical_volume_name,
					CONVERT(DECIMAL(18, 2), vs.total_bytes / 1073741824.0)                   AS [Total Size (GB)],
					CONVERT(DECIMAL(18, 2), vs.available_bytes / 1073741824.0)               AS [Available Size (GB)],
					CONVERT(DECIMAL(18, 2), vs.available_bytes * 1. / vs.total_bytes * 100.) AS [Space Free %]
	FROM   sys.master_files AS f WITH (NOLOCK)
		   CROSS APPLY sys.Dm_os_volume_stats(f.database_id, f.[file_id]) AS vs
	WHERE  CONVERT(DECIMAL(18, 2), vs.available_bytes * 1. / vs.total_bytes * 100.) < '15'
	ORDER  BY vs.volume_mount_point
	OPTION (RECOMPILE);

	DECLARE @SQLcmd VARCHAR(MAX)
	DECLARE @size VARCHAR(3) = '15'

	SELECT @SQLcmd = '
	 USE [?]
	SELECT @@servername as ServerName,[DatabaseName] = DB_NAME()
			 ,[Logical_Name] = name
			 ,[Path] = physical_name 
			,[TYPE] = A.TYPE_DESC
			  ,  [FileGrowth]    = CASE growth / 128
								  WHEN 0 THEN ''By %''
								  ELSE ''By '' + Cast(growth/128 AS VARCHAR(10))
									   + '' MB''
								END
		 
	,[AutoGrowth]  =CASE WHEN growth = 0 THEN ''Autogrowth is off'' ELSE CASE WHEN (max_size = -1  OR growth >0) THEN ''Enabled'' ELSE ''Disabled'' END END
	,[Max Grow MB] =CASE WHEN growth = 0 THEN ''Autogrowth is off'' ELSE CASE WHEN max_size = -1 THEN ''Unlimited'' WHEN growth= 0 THEN ''Unlimited'' WHEN max_size = 268435456 THEN ''2 TB''  ELSE CAST(max_size/128 AS VARCHAR(10))    + '' MB'' END END 
			, [CurrentSizeMB ] =  size/128.0
			,  [SpaceUsedMB] =CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0
			,[FreeSpaceMB] =  CASE WHEN (max_size = -1  OR growth >0) THEN size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 ELSE max_size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 END
			, [Free Space %] = CASE WHEN (max_size = -1  OR growth >0) THEN CONVERT(INT,ABS(CONVERT(DECIMAL (10,2), CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/ CONVERT(DECIMAL (10,2), size/128.0)*100 -100)) ELSE CONVERT(INT,ABS(CONVERT(DECIMAL (10,2), CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)/ CONVERT(DECIMAL (10,2), max_size/128.0)*100 -100)) END
			FROM sys.database_files A 
		  order by [SpaceUsedMB] desc'

		  
	IF Object_id(N'tempdb..#DatafileSize') IS NOT NULL
	  DROP TABLE #DatafileSize

	CREATE TABLE #DatafileSize
	  (
		 [ServerName]    NVARCHAR(100),
		 [DatabaseName]  NVARCHAR(250),
		 [Logical_Name]  VARCHAR(250),
		 [File_Path]     VARCHAR(250),
		 [TYPE]          NVARCHAR(10),
		 [FileGrowth]    NVARCHAR(1000),
		 [Max]           VARCHAR(100),
		 [MAX Growth MB] VARCHAR(100),
		 [CurrentSizeMB] VARCHAR(15),
		 [SpaceUsedMB]   VARCHAR(15),
		 [FreeSpaceMB]   VARCHAR(15),
		 [Free Space %]  INT
	  );

	INSERT INTO #DatafileSize
	EXEC Sp_msforeachdb
	  @SQLcmd


	IF Object_id(N'tempdb..#LRT') IS NOT NULL
	  DROP TABLE #LRT

	CREATE TABLE #LRT
	  (
		 [ServerName]         NVARCHAR(100),
		 [DatabaseName]       NVARCHAR(100),
		 session_id           INT,
		 start_time           TIME,
		 TotalElapsedTime_min NVARCHAR(100),
		 status               NVARCHAR(100),
		 command              NVARCHAR(100)
	  )

	INSERT INTO #LRT
	SELECT [ServerName]         =@@SERVERNAME,
		   DatabaseName         = Db_name(r.database_id),
		   r.session_id,
		   r.start_time,
		   TotalElapsedTime_min = r.total_elapsed_time / 1000 / 60,
		   r.[status],
		   r.command
	FROM   sys.dm_exec_requests r
		   CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS t
		   CROSS APPLY sys.Dm_exec_query_plan(r.plan_handle) AS p
	WHERE  wait_type != 'XE_LIVE_TARGET_TVF'
	ORDER  BY r.total_elapsed_time DESC

	SELECT ServerEnvironment, *
	FROM   [DBA].[info].[AgentJob] A
	cross apply [DBA].[info].[Instance] I 
	WHERE JobCategory not in ('Data Collector',
	'Database Collector',
	'Database Maintenance',
	'PerfStats') AND  
	JobEnabled = 1
		   AND JobStatus = 0
		   AND RunDateTime >= Dateadd(HOUR, -4, Getdate())
		   AND ServerEnvironment ='PRD' 
	  
	  


	  
	select * 
	  FROM [DBA].[info].[Database]
	  where state NOT IN ( 'ONLINE', 'MISSING', 'RESTORING')
	  
	SELECT *
	FROM   #AGCheck

	SELECT *
	FROM   #SpaceDrive
	where [Free Space %] <= 5



	  SELECT  * 
	FROM   #DatafileSize
	WHERE [MAX Growth MB]  NOT IN ('Unlimited', '2 TB','Autogrowth is off')
	AND CASE WHEN TYPE NOT IN ('LOG', 'ROWS') THEN (CAST (REPLACE([MAX Growth MB], 'MB','') AS INT)+1) ELSE CAST (REPLACE([MAX Growth MB], 'MB','') AS INT) END<= CONVERT(INT,ABS([CurrentSizeMB])) 
	AND DatabaseName <> 'tempdb'
	UNION
	SELECT * 
	FROM   #DatafileSize
	WHERE [MAX Growth MB]  NOT IN('Unlimited', '2 TB','Autogrowth is off')
	AND CASE WHEN TYPE NOT IN ('LOG', 'ROWS') THEN (CAST (REPLACE([MAX Growth MB], 'MB','') AS INT)+1) ELSE CAST (REPLACE([MAX Growth MB], 'MB','') AS INT) END<= CONVERT(INT,ABS([CurrentSizeMB]))
	AND  [Free Space %] <= 5
	ORDER  BY [MAX Growth MB] ASC,
			  [Free Space %] ASC 


			  
	select L.* from #LRT L
	join [DBA].[info].[Instance] I on I.SQLServerName=L.ServerName
	where TotalElapsedTime_min > 120  AND ServerEnvironment IN ('PROD','PRD')



	
	--EXEC [DBA].[Backup].[BackupReport] @BackupType = 'FULL', @DryRun = 1
	--EXEC [DBA].[Backup].[BackupReport] @BackupType = 'LOG', @DryRun = 1
