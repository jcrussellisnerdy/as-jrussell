USE [DBA]
GO
/****** Object:  StoredProcedure [backup].[RemoveBackup]    Script Date: 9/13/2019 12:23:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[backup].[RemoveBackup]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [backup].[RemoveBackup] AS RETURN 0;' 
END
GO

ALTER PROCEDURE [backup].[RemoveBackup]
	@DDHost						varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_HOST - Data Domain Host Name
	@DDBoostUser				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_USER - DD Boost User
	@DDStorageUnit				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DEVICE_PATH - Storage Unit Name
	@ClientHost					varchar (50)	= NULL,	
	@SQLInstanceName 			varchar (50)  	= NULL,
	@SaveSet					varchar (100)	= NULL,					-- -a specifies a filter on the save set name for display and deletes both.
	@StartTime					varchar (30)	= NULL,					-- -b specifies the lower boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@EndTime	 				varchar (30)	= NULL,					-- -e specifies the upper boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@AppType		 			varchar (10)  	= 'mssql',				-- -n specifies the application type
	--@ConfigFile					varchar (255)	= NULL,				-- -z specifies the configuration file path
	@BackupSoftware				varchar	(100)	= NULL,
	@Clean						bit				= 1,					-- -c cleans up the corrupted or invalid catalogue information
	@DelExpired					bit				= 0,					-- -r deletes the expired savesets disregarding retention
	@Verbose					bit				= 0,					-- -v prints the verbose output on the console
	@DryRun						bit				= 1
AS
BEGIN
	-- EXEC [backup].[RemoveBackup] @backupSoftware = 'EMC', @Clean = 0, @DelExpired = 0, @verbose = 0, @DryRun = 0
	-- EXEC [backup].[RemoveBackup] @backupSoftware = 'EMC', @Clean = 0, @DelExpired = 0, @DryRun = 0
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Check required parameters
	if @AppType is null raiserror('Null values not allowed for AppType', 16, 1)
	--if @ConfigFile is null raiserror('Null values not allowed for ConfigFile', 16, 1)
		
	-- Set Default values 
	IF( @DDHost is null ) SELECT @DDHost = UPPER(info.GetDatabaseConfig('DataDomain','Host', ''));
	IF( @DDBoostUser is null ) SELECT @DDBoostUser = info.GetDatabaseConfig('DataDomain','User', '');
	IF( @SaveSet is null ) SELECT @SaveSet = UPPER(info.GetDatabaseConfig('DataDomain','SetName', ''));
	IF( @DDStorageUnit is null ) SELECT @DDStorageUnit = UPPER(info.GetDatabaseConfig('DataDomain','DevicePath', ''));
	--IF( @DDLockBoxPath is null ) SELECT @DDLockBoxPath = info.GetDatabaseConfig('DataDomain','LockBoxPath', '');
	-- convert(varchar(25),Format(dateadd(day,-90,getdate()), 'MM/dd/yyyy hh:mm:ss'))
	IF( @EndTime is null ) SELECT @EndTime = convert(varchar(10),GETDATE(), 101) +' '+ LTRIM(RIGHT(CONVERT(CHAR(20), getdate(), 22), 11));
	--IF( @NumberOfStripes = 0 ) SELECT @NumberOfStripes = info.GetDatabaseConfig('DataDomain','NumberOfFiles', '');
	--IF( @BackupSetDescription is null ) SET @BackupSetDescription = @BackupLevel +' Backup'
	IF( @ClientHost is null ) SET @ClientHost = ( SELECT UPPER( convert(varchar(100), SERVERPROPERTY('MachineName')) )+'.'+(SELECT DomainName FROM DBA.info.Instance) )
	IF( @BackupSoftware is null ) SET @BackupSoftware = info.GetDatabaseConfig('Backup','Software', '');
	
	-- sanity check ??
	IF NOT EXISTS(select * from master.sys.objects where type_desc = 'CLR_STORED_PROCEDURE' and name = @BackupSoftware+'_Run_delete') and @BackupSoftware = 'EMC'
		BEGIN
			--PRINT 'USE XP_cmdShell'
			SET @BackupSoftware = 'ddboost'
		END
	ELSE
		BEGIN
			--PRINT 'USE EMC native'
			SET @BackupSoftware = 'EMC'
		END

	IF( @BackupSoftware = 'ddboost' )
		BEGIN
			Exec [ddbma].[ExpireImage] 
				 @DDHost = @DDHost
				,@DDBoostUser = @DDBoostUser
				,@DDStorageUnit = @DDStorageUnit
				,@ClientHost = @ClientHost
				,@SQLInstanceName = @SQLInstanceName
				,@SaveSet = @SaveSet
				,@StartTime = @StartTime
				,@EndTime = @EndTime
				,@AppType = @AppType
				,@ConfigFile = ''
				,@Clean = @Clean
				,@DelExpired = @DelExpired
				,@Verbose = @Verbose
				,@DryRun = @DryRun
		END
	ELSE IF( @BackupSoftware = 'EMC' )
		BEGIN
			DECLARE @returnCode int, @EMCcmd nvarchar(100), @retention int
			SELECT @retention = [info].[GetDatabaseConfig] ('DataDomain', 'Retention', 14)
			
			IF( @verbose = 1 )
				BEGIN
					SET @EMCcmd = '-k -v '
				END
			ELSE
				BEGIN
					SET @EMCcmd = '-k '
				END
			SET @EMCcmd = @EMCcmd +'-n mssql -a "DDBOOST_USER='+ @DDBoostUser +'" -a "DEVICE_PATH='+ @DDStorageUnit +'" -a "DEVICE_HOST='+ @DDHost +'" -a "CLIENT='+ @ClientHost +'" -e "'+ convert(varchar(10), @retention )+' days ago"'
			
			IF( @DryRun = 0 )
				BEGIN
					EXEC @returnCode = master.dbo.emc_run_delete @EMCcmd
				END
			ELSE
				BEGIN
					PRINT '[DryRun]'
					PRINT @EMCcmd
					SET @returnCode = 0
				END

			/* only alert if the full backups are running */
			IF ((@returnCode <> 0) AND ((SELECT enabled FROM msdb..sysjobs where name = 'DBA-BackupDatabases-FULL') <> 0))
			BEGIN
				PRINT @returnCode
				RAISERROR ('Fail!', 16, 1)
			END
		END
	ELSE
		BEGIN
			PRINT 'Backup Software undefined'
			raiserror('Backup Software undefined',16,1)	
		END
		
END;
GO

/* Remove old versions */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[RemoveBackup]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'DROP PROCEDURE [dba].[RemoveBackup];' 
END
