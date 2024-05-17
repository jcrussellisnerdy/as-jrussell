USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[getDatabase]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getDatabase] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[getDatabase] ( @DBName VARCHAR(128) = '', @DryRun TINYINT = 1 )
AS
BEGIN
	--  EXEC [info].[getDatabase] @dbName = 'DBA', @dryRun = 0
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    CREATE TABLE #db
    (
        [DBID] INT NULL,
        [Name] NVARCHAR(128) NULL,
		[owner] NVARCHAR(128) null,
        [State] NVARCHAR(128) NULL,
		[CompatibilityLevel] INT null,
		[RecoveryModel] NVARCHAR(128) null,
        [CanAcceptConnections] BIT NULL,
        [DataConsumedSizeMB] BIGINT NULL,
        [DataFreeSpaceMB] BIGINT NULL,
        [LogConsumedSizeMB] BIGINT NULL,
        [LogFreeSpaceMB] BIGINT NULL,
        [ServerType] NVARCHAR(32) NULL,
        [ReplicationStatus] NVARCHAR(32) NULL,
        [IsEncrypted] BIT NULL,
        [EncryptionType] NVARCHAR(32) NULL,
		CreateDate dateTime,
		LastFullBackup dateTime,
		LastTranBackup dateTime,
		LastCheckDB dateTime
    )
    WITH (DATA_COMPRESSION = PAGE);

    CREATE TABLE #logspace
    (
        [ID] INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED NOT NULL,
        dbName VARCHAR(MAX) NULL,
        [dbID] INT NULL,
        logSizeMB VARCHAR(100) NULL,
        logFreeSpaceMB VARCHAR(100) NULL,
        dataSizeMB VARCHAR(100) NULL,
        DataFreeSpaceMB VARCHAR(100) NULL
    )
    WITH (DATA_COMPRESSION = PAGE);

	CREATE TABLE #DBInfo_LastKnownGoodCheckDB
    (
     ParentObject VARCHAR(1000) NULL,
     [Object] VARCHAR(1000) NULL,
     Field VARCHAR(1000) NULL,
     Value VARCHAR(1000) NULL,
     DatabaseName VARCHAR(1000) NULL
    )

    BEGIN TRY
		DECLARE @SQL NVARCHAR(2000);

		if( @dbname = '' )
			BEGIN
				INSERT INTO #db ( [Name], [Owner], [CompatibilityLevel], [RecoveryModel], [State], [CreateDate] ) SELECT name, suser_sname( owner_sid ), compatibility_level, recovery_model_desc, state_desc, create_date from sys.databases; --select suser_sname( owner_sid ),* from sys.databases
			END
		ELSE
			BEGIN
				INSERT INTO #db ( [Name], [Owner], [CompatibilityLevel], [RecoveryModel], [State], [CreateDate] ) SELECT name, suser_sname( owner_sid ), compatibility_level, recovery_model_desc, state_desc, create_date from sys.databases where name = @DBName;
			END;
		
		WHILE EXISTS(SELECT * FROM #DB WHERE isNull([DBID],'') = '')
			BEGIN
				
				SELECT top 1 @DBName = name FROM #DB WHERE IsNull([DBID],'') = ''
				print 'update Can accept Connections '+ @DBName
				UPDATE #db -- SELECT CASE COALESCE( DATABASEPROPERTYEX('LoopFlow', 'Collation'), 'CollationIsNULL')  WHEN 'CollationIsNULL' THEN  0 ELSE 1 end
				SET [CanAcceptConnections] = CASE COALESCE(DATABASEPROPERTYEX('' + @DBName + '', 'Collation'), 'CollationIsNULL' )
												 WHEN 'CollationIsNULL' THEN 0
												 ELSE 1
											 END
				WHERE name = @DBName;

				DECLARE @ProductVersion int, @CurrentInstance nvarchar(100), @serverType varchar(100), @replicaStatus varchar(100)
				SELECT @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ))
				SELECT @CurrentInstance = @@Servername

				PRINT 'IS Instance HADR ready'
				IF( @ProductVersion > 10 AND (select SERVERPROPERTY('IsHadrEnabled')) = 1 )
					BEGIN
						SET @SQL = 'SELECT @is_Primary_Replica =
							CASE 
								WHEN MAX(convert(int, is_primary_replica)) = 1 THEN ''PRIMARY''
								WHEN MAX(convert(int, is_primary_replica)) = 0 THEN ''SECONDARY''
								ELSE ''''
							END 
						FROM sys.databases as sd
						LEFT OUTER JOIN sys.dm_hadr_database_replica_states hdrs on hdrs.database_id = sd.database_id
						LEFT OUTER JOIN sys.dm_hadr_name_id_map grp on grp.ag_id = hdrs.group_id
						INNER JOIN sys.dm_hadr_availability_replica_cluster_states acs on acs.replica_id = hdrs.replica_id
						WHERE sd.name = '''+ @DBName +''' AND replica_server_name =(@@Servername)'
						EXEC sp_executesql @SQL, N'@is_Primary_Replica Nvarchar(100) OUT', @is_Primary_Replica=@ServerType OUTPUT;


						SET @SQL = 'SELECT @synchronization_state_desc = synchronization_state_desc
						FROM sys.databases as sd
						LEFT OUTER JOIN sys.dm_hadr_database_replica_states hdrs on hdrs.database_id = sd.database_id
						LEFT OUTER JOIN sys.dm_hadr_name_id_map grp on grp.ag_id = hdrs.group_id
						INNER JOIN sys.dm_hadr_availability_replica_cluster_states acs on acs.replica_id = hdrs.replica_id
						WHERE sd.name = '''+ @DBName +''' AND replica_server_name =(@@Servername)'
						EXEC sp_executesql @SQL, N'@synchronization_state_desc Nvarchar(100) OUT', @synchronization_state_desc=@replicaStatus OUTPUT;
					END
				ELSE					
					BEGIN
						SET @ServerType = null
					END

				UPDATE d
				SET d.[DBID] = s.database_id,
					--d.[State] = s.state_desc,
					d.ServerType = @serverType,
					d.ReplicationStatus = @replicaStatus,
					d.IsEncrypted = CASE
										WHEN ek.Database_ID IS NOT NULL THEN
											1
										ELSE
											0
									END,
					d.EncryptionType = CASE
										   WHEN c.name IS NOT NULL THEN
											   'CERTIFICATE'
										   WHEN ak.name IS NOT NULL THEN
											   'HSM'
										   ELSE
											   'NONE'
									   END,
					LastFullBackup = ISNULL(LastFullBackup.BackupDate, ''),
					LastTranBackup = ISNULL(LastTranBAckup.BackupDate, '')
				FROM #db d
					JOIN sys.databases s
						ON d.[Name] = s.[name]
					LEFT JOIN sys.dm_database_encryption_keys ek
						ON ek.Database_id = s.Database_ID
					LEFT JOIN master.sys.certificates c
						ON ek.encryptor_thumbprint = c.thumbprint
					LEFT JOIN master.sys.asymmetric_keys ak
						ON ek.encryptor_thumbprint = ak.thumbprint
					LEFT JOIN (SELECT
								bs.database_name,
								MAX(bs.backup_finish_date) AS BackupDate
								FROM
								msdb..backupset bs
								WHERE
								bs.TYPE = 'D'
								GROUP BY
								bs.database_name) AS LastFullBackup
									ON d.name = LastFullBackup.database_name
					LEFT JOIN (SELECT
								bs.database_name,
								MAX(bs.backup_finish_date) AS BackupDate
								FROM
								msdb..backupset bs
								WHERE
								bs.TYPE = 'L'
								GROUP BY
								bs.database_name) AS LastTranBackup
						ON d.name = LastTranBackup.database_name
				WHERE d.name = @DBName;

				IF EXISTS (SELECT 1 FROM #db WHERE ([State] = 'ONLINE' and name = @DBName) AND (IsNull(DataConsumedSizeMB,'') = '') )
				BEGIN
					/*get select for logspace data */
					SELECT @SQL
						= '
					use [' + @DBName + '];
					select ''' + @DBName + ''' AS dbName  
					, DB_ID()
					, SUM(CASE WHEN [type] = 1 THEN space_used END) as logSizeMB
					, SUM(CASE WHEN [type] = 1 THEN space_free END) as logFreeSpaceMB
					, SUM(CASE WHEN [type] = 0 THEN space_used END) as dataSizeMB
					, SUM(CASE WHEN [type] = 0 THEN space_free END) as DataFreeSpaceMB
				FROM (
					SELECT S.[type], space_used = SUM(CAST(FILEPROPERTY(S.name, ''SpaceUsed'') AS BIGINT) / 128),
										space_free = (SUM(CAST(size AS BIGINT))/128) - (sum(CAST(FILEPROPERTY(S.name,''SpaceUsed'') AS BIGINT))/128)
					FROM [' + @DBName + '].sys.database_files AS S
					GROUP BY S.[type]
				) t;';

					INSERT INTO #logspace
						EXEC (@SQL);

					/*updating information now*/
					UPDATE d
					SET d.DataConsumedSizeMB = l.dataSizeMB,
						d.DataFreeSpaceMB = l.DataFreeSpaceMB,
						d.LogConsumedSizeMB = l.logSizeMB,
						d.LogFreeSpaceMB = l.logFreeSpaceMB
					FROM #db d
						JOIN #logspace l ON d.[Name] = l.dbName
					WHERE d.name = @DBName;

					--Create dynamic SQL to be inserted into temp table DBCC DBINFO ('DBA') WITH TABLERESULTS
                    SET @SQL = 'DBCC DBINFO (' + CHAR(39) + @DBName + CHAR(39) + ') WITH TABLERESULTS'
	
					--Insert the results of the DBCC DBINFO command into the temp table
                    INSERT  INTO #DBInfo_LastKnownGoodCheckDB ( ParentObject, [Object], Field, Value )
                        EXEC ( @SQL )

					--Set the database name where it has yet to be set
                    UPDATE #DBInfo_LastKnownGoodCheckDB
                    SET DatabaseName = @DBName
                    WHERE DatabaseName IS NULL

					UPDATE d
					SET d.LastCheckDB = isNull(LKGC.Value, '')
					FROM #db d
						JOIN #DBInfo_LastKnownGoodCheckDB AS LKGC ON (d.[name] = LKGC.DatabaseName)
					WHERE d.name = @DBName and LKGC.Field = 'dbi_dbccLastKnownGood';
				END;
			END;

		/*Zero out offline DBs*/
		UPDATE d
		SET d.DataConsumedSizeMB = 0,
			d.DataFreeSpaceMB = 0,
			d.LogConsumedSizeMB = 0,
			d.LogFreeSpaceMB = 0
		FROM #db d
		WHERE [State] != 'ONLINE';


		IF( @dryRun = 0 )
			BEGIN
				MERGE [info].[Database] AS old
					USING ( SELECT DBID, [Name], [Owner], [State], [CompatibilityLevel], [RecoveryModel], 
								[CanAcceptConnections], [DataConsumedSizeMB], [DataFreeSpaceMB], [LogConsumedSizeMB],
								[LogFreeSpaceMB], [ServerType], [ReplicationStatus], [IsEncrypted], [EncryptionType], [CreateDate],
								[LastFullBackup], [LastTranBackup], [LastCheckDB], getDAte()
							FROM #DB ) AS new ( DBID, DatabaseName, Owner, State, CompatibilityLevel, RecoveryModel,
													CanAcceptConnections,	DataConsumedSizeMB,	DataFreeSpaceMB, LogConsumedSizeMB,
													LogFreeSpaceMB, ServerType, ReplicationStatus, IsEncrypted, EncryptionType, CreateDate,
													LastFullBackup, LastTranBackup, LastCheckDB, HarvestDate )
					ON new.DatabaseName = old.DatabaseName 
					WHEN MATCHED AND ( old.State <> new.State OR old.Owner <> new.Owner OR old.CompatibilityLevel <> new.CompatibilityLevel OR old.RecoveryModel <> new.RecoveryModel OR
										old.CanAcceptConnections <> new.CanAcceptConnections OR old.DataConsumedSizeMB <> new.DataConsumedSizeMB OR
										old.DataFreeSpaceMB <> new.DataFreeSpaceMB OR old.LogConsumedSizeMB <> new.LogConsumedSizeMB OR old.LogFreeSpaceMB <> new.LogFreeSpaceMB OR
										old.ServerType <> new.ServerType OR old.ReplicationStatus <> new.ReplicationStatus OR old.IsEncrypted <> new.IsEncrypted OR
										old.EncryptionType <> new.EncryptionType OR old.CreateDate <> new.CreateDate OR old.LastFullBackup <> new.LastFullBackup OR
										old.LastTranBackup <> new.LastTranBackup OR old.LastCheckDB <> new.LastCheckDB OR old.HarvestDate <> new.HarvestDate
									 ) THEN
						UPDATE SET 
							old.State = new.State,  old.Owner = new.Owner, old.CompatibilityLevel = new.CompatibilityLevel, old.RecoveryModel = new.RecoveryModel,
							old.CanAcceptConnections = new.CanAcceptConnections, old.DataConsumedSizeMB = new.DataConsumedSizeMB,
							old.DataFreeSpaceMB = new.DataFreeSpaceMB, old.LogConsumedSizeMB = new.LogConsumedSizeMB, old.LogFreeSpaceMB = new.LogFreeSpaceMB,
							old.ServerType = new.ServerType, old.ReplicationStatus = new.ReplicationStatus, old.IsEncrypted = new.IsEncrypted,
							old.EncryptionType = new.EncryptionType,  old.CreateDate = new.CreateDate, old.LastFullBackup = new.LastFullBackup,
							old.LastTranBackup = new.LastTranBackup, old.LastCheckDB = new.LastCheckDB, old.HarvestDate = new.HarvestDate
					WHEN NOT MATCHED THEN
						INSERT( DBID, DatabaseName, Owner, State, CompatibilityLevel, RecoveryModel,
								CanAcceptConnections, DataConsumedSizeMB, DataFreeSpaceMB, LogConsumedSizeMB, LogFreeSpaceMB,
								ServerType, ReplicationStatus, IsEncrypted, EncryptionType, CreateDate,
								LastFullBackup, LastTranBackup, LastCheckDB, HarvestDate)
						VALUES( new.DBID, new.DatabaseName, new.Owner, new.State, new.CompatibilityLevel, new.RecoveryModel,
								new.CanAcceptConnections, new.DataConsumedSizeMB, new.DataFreeSpaceMB, new.LogConsumedSizeMB, new.LogFreeSpaceMB, 
								new.ServerType, new.ReplicationStatus, new.IsEncrypted, new.EncryptionType, new.CreateDate,
								new.LastFullBackup, new.LastTranBackup, new.LastCheckDB, new.HarvestDate )

					/* Remove old entries */
					WHEN NOT MATCHED by SOURCE THEN 
						DELETE;

		END;
	ELSE
		BEGIN
		  	SELECT DBID, 
				[Name],
				[Owner],
				[State],
				[CompatibilityLevel],
				[RecoveryModel],
				[CanAcceptConnections],
				[DataConsumedSizeMB],
				[DataFreeSpaceMB],
				[LogConsumedSizeMB],
				[LogFreeSpaceMB],
				[ServerType],
				[ReplicationStatus],
				[IsEncrypted],
				[EncryptionType],
				[CreateDate],
				[LastFullBackup],
				[LastTranBackup],
				[LastCheckDB],
				getDate() as [DryRunDate]
			FROM #DB;
		  END;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorNumber INT,
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorProcedure NVARCHAR(200)

        /*Assign variables to error-handling functions that capture information for RAISERROR.*/
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        /*Build the message string that will contain original error information.*/
        SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 'Message: ' + ERROR_MESSAGE();

        /*Return Resultset for Digestion*/
        -- SELECT [DatabaseName]
		  -- ,[State]
		  -- ,[CanAcceptConnections]
		  -- ,[DataConsumedSizeMB]
		  -- ,[DataFreeSpaceMB]
		  -- ,[LogConsumedSizeMB]
		  -- ,[LogFreeSpaceMB]
		  -- ,[ServerType]
		  -- ,[ReplicationStatus]
		  -- ,[IsEncrypted]
		  -- ,[EncryptionType]
	    -- FROM [DBA].[inv].[Database];

        /*Raise an error: msg_str parameter of RAISERROR will contain the original error information.*/
        RAISERROR(
                     @ErrorMessage,
                     @ErrorSeverity,
                     1,
                     @ErrorNumber,
                     @ErrorSeverity,
                     @ErrorState,
                     @ErrorProcedure,
                     @ErrorLine
                 );

    END CATCH;
END;