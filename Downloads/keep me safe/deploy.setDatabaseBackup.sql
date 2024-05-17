USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[deploy].[setDatabaseBackup]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[setDatabaseBackup] AS' 
END
GO

ALTER PROCEDURE [deploy].[setDatabaseBackup]
	@dryrun int = 1
AS
BEGIN
	set nocount on;  -- [deploy].[setDatabaseBackup] @dryRun = 0

	DECLARE @dbname sysname,
			@dbid	int,
			@dbtype varchar(25),
			@recovery_model varchar(25);

	IF EXISTS( SELECT * FROM [inv].[DatabaseBackup] WHERE IncludeInBackup = 1 AND [DatabaseName] NOT IN (select name from sys.databases) )
		BEGIN
			If( @dryRun = 1 )
				BEGIN
					SELECT * FROM [inv].[DatabaseBackup] WHERE IncludeInBackup = 1 AND [DatabaseName] NOT IN (select name from sys.databases)
				END
			ELSE
				BEGIN
					UPDATE [inv].[DatabaseBackup] SET IncludeInBackup = 0 WHERE [DatabaseName] NOT IN (select name from sys.databases)
				END
		END
			
	declare c_dblist cursor read_only static local
	for
		select [name], database_id, recovery_model_desc, 
			case WHEN name in ('master', 'model', 'msdb', 'DBA', 'ReportServer', 'ReportServerTempDB') then 'SYSTEM' 
				 WHEN name like '%storage' THEN 'SYSTEM' 
				 ELSE 'USER' 
			end
		from sys.databases (nolock)
		where [name] not in ('tempdb')
		order by database_id;

	open c_dblist
	fetch next from c_dblist into @dbname, @dbid, @recovery_model, @dbType

	while( @@fetch_status = 0 )
	begin
		--set @dbtype = (case when @dbname in ('master', 'model', 'msdb', 'DBA', 'ReportServer', 'ReportServerTempDB') then 'SYSTEM' else 'USER' end);

		-- do we already have a record for it?
		if not exists (select * from [inv].[DatabaseBackup] where [DatabaseName] = @dbname)
		begin
			-- auto-insert with default values
			IF( @dryrun = 0)
				BEGIN
					INSERT INTO [inv].[DatabaseBackup]
						( [DatabaseName] ,[DatabaseType] ,[BackupMethod] ,[ExpectedRecoveryModel], [IncludeInBackup],
							[FullBackupPathSetID], [LogBackupPathSetID] ,[DiffBackupPathSetID],
				
						BackupTypeForMonday, BackupTypeForTuesday, BackupTypeForWednesday,
						BackupTypeForThursday, BackupTypeForFriday, BackupTypeForSaturday,
						BackupTypeForSunday

						,[WithCompression] ,[CompressionLevel] ,[WithEncryption]
						,[EncryptionKey] ,[WithChecksum] , [NumFullsToRetain], [PreferredBackupLocation] )  
					select @dbname, @dbtype , 'SQL' , @recovery_model, '1',
							(CASE
								WHEN @dbtype = 'SYSTEM'
								--THEN COALESCE( (select BackupPathSetID from BackupPathSet where [Name] = 'DefaultSystem'), [FullBackupPathSetID] )
								THEN 1
								ELSE 2 --[FullBackupPathSetID]
							END)
						, 3 --[LogBackupPathSetID] 
						, 4 --[DiffBackupPathSetID]
						, 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 1, 2, 0, null, 1, 2,
						CASE WHEN @dbname in ('master', 'model', 'msdb', 'DBA', 'ReportServer', 'ReportServerTempDB')  THEN 'PRIMARY' ELSE 'AG Pref' END

					if( @@ROWCOUNT = 0 )
					begin
						RAISERROR('Unable to insert default values for database.  Please make sure your default settings are set', 16, 1, 1);
						return;
					end
				END
			ELSE
				BEGIN
					select @dbname, @dbtype , 'SQL' , @recovery_model, '1',
							(CASE
								WHEN @dbtype = 'SYSTEM'
								--THEN COALESCE( (select BackupPathSetID from BackupPathSet where [Name] = 'DefaultSystem'), [FullBackupPathSetID] )
								THEN 1
								ELSE 2 --[FullBackupPathSetID]
							END)
						, 3 --[LogBackupPathSetID] 
						, 4 --[DiffBackupPathSetID]
						, 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 'FULL', 1, 2, 0, null, 1, 2,
						CASE WHEN @dbname in ('master', 'model', 'msdb', 'DBA', 'ReportServer', 'ReportServerTempDB')  THEN 'PRIMARY' ELSE 'AG Preference' END

				END
		end

		fetch next from c_dblist into @dbname, @dbid, @recovery_model, @dbType
	end

	close c_dblist
	deallocate c_dblist
END
;
GO