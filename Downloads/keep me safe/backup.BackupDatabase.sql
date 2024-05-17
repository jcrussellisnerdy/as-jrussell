USE [DBA]
GO
/****** Object:  StoredProcedure [backup].[BackupDatabase]    Script Date: 12/28/2020 10:44:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [backup].[BackupDatabase] 
	@ClientHost					varchar (50)	= NULL,					-- -c Client/Host SQL Server Backup Source
	@BackupLevel				varchar (10),							-- -l Backup Level <full,incr,diff>
	@BackupSetName 				varchar (100)	= NULL, 				-- -N Backup Set Name
	@BackupSetDescription 		varchar (255)	= NULL,					-- -b Backup Set Description
	@BackupSoftware				varchar	(100)	= NULL,
	@RetentionDays				int 		  	= 0,					-- -y Default to 30 days if not supplied - Generates 
	@DDHost						varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_HOST - Data Domain Host Name
	@DDBoostUser				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_USER - DD Boost User
	@DDStorageUnit				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DEVICE_PATH - Storage Unit Name
	@DDLockBoxPath				varchar (100)	= NULL,					--
	@SkipBadState				varchar (10)    = "TRUE",				--
	@SQLDatabaseName			varchar (100),							-- SQL Database Name
	@SQLInstanceName 			varchar (50)  	= NULL,					-- SQL Instance Name - Defaults to MSSQL
	@SQLBackupPath 				varchar (100)  	= NULL,					-- Defaults to Instance default paths
	@NumberOfStripes			int				= 0,					-- -S Number of Stripes
	@NoTruncate					bit				= NULL,					-- -R Uses the NO_TRUNCATE option when backing up transaction logs.
	@TruncateOnly				bit				= NULL,					-- -T Performs a TRUNCATE_ONLY transaction log backup before backing up the database. This option is valid only for full backups on SQL Server 2005.
	@NoLogTRN					bit				= NULL,					-- -G Specifies a NO_LOG transaction log backup before backing up the database. This option is valid only for full backups on SQL Server 2005.
	@TailLog					bit				= NULL,					-- -H Performs a tail-log backup of the database and leave it in the restoring state.
	@CCheck						bit				= NULL,					-- -j Performs a database consistency check before starting the backup.
	@CreateChecksum				bit				= 1,					-- -k Performs checksum before backing up the data to the device.
	@ContinueOnChecksumErr		bit				= NULL,					-- -u Performs checksum and continues the operation even in case of errors.
	@DDFCHostName				varchar (50)	= NULL,					-- -a NSR_FC_HOSTNAME - Data Domain FC Hostname
	@Quiet						bit				= NULL,					-- -q Displays ddbmsqlsv messages in the quiet mode, that is, the option displays summary information and error messages only.
	@Verbose					bit				= NULL,					-- -v Displays ddbmsqlsv messages in the verbose mode, that is, the option provides detailed information about the progress of the backup operation.
	@DebugLevel					char(1)			= 1,					-- -D Generates detailed logs that you can use to troubleshoot the backup issues. <0-9>
--	@BackupTarget				varchar (50)	= 'DBA'					-- USER_Databases / SYSTEM_Databases / DB_NAME
--	@VirtualServer				varchar (50)  	= NULL					-- -A Note: This appears to be intended for use with virtual cluster nodes, but is not documented well in the administration guide - Do not have environment to test this functionality, so have not implemented
	@DryRun						bit				= 1,
	@Force						bit				= 0						-- Disregard schedule table
AS
BEGIN
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'System_Databases', @DryRun = 0
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'USER_Databases', @DryRun = 0
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'DBA', @DryRun = 0

	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'System_Databases', @backupSoftware = 'SQLNative', @DryRun = 0
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'USER_Databases', @backupSoftware = 'SQLNative', @DryRun = 0
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'DBA', @backupSoftware = 'SQLNative', @force = 1, @DryRun = 0
	-- EXEC [backup].[BackupDatabase] @BackupLevel = 'FULL', @SQLDatabaseName = 'DBA', @backupSoftware = 'SQLNative', @SQLBackupPath = 'C:\SQL\HKB1\Backups\Escrow', @force = 1, @DryRun = 0

	-- Set Default values 
	IF( @BackupSetName is null ) SELECT @BackupSetName = UPPER(info.GetDatabaseConfig('DataDomain','SetName', ''));
	IF( @RetentionDays = 0 ) SELECT @RetentionDays = info.GetDatabaseConfig('DataDomain','Retention', '');
	IF( @NumberOfStripes = 0 ) SELECT @NumberOfStripes = info.GetDatabaseConfig('DataDomain','NumberOfFiles', '');
	IF( @BackupSetDescription is null ) SET @BackupSetDescription = @BackupLevel +' Backup'
	IF( @ClientHost is null ) SET @ClientHost = ( SELECT UPPER( convert(varchar(100), SERVERPROPERTY('MachineName')) ) )
	IF( @SQLInstanceName is null ) SET @SQLInstanceName = (select isnull('MSSQL$'+ convert(varchar(max),serverproperty('instancename')),'MSSQL') )
	IF( @BackupSoftware is null ) SET @BackupSoftware = info.GetDatabaseConfig('Backup','Software', '');

	-- Set DDBoost Values
	IF( @DDHost is null ) SELECT @DDHost = UPPER(info.GetDatabaseConfig('DataDomain','Host', ''));
	IF( @DDBoostUser is null ) SELECT @DDBoostUser = info.GetDatabaseConfig('DataDomain','User', '');
	IF( @DDStorageUnit is null ) SELECT @DDStorageUnit = UPPER(info.GetDatabaseConfig('DataDomain','DevicePath', ''));
	IF( @DDLockBoxPath is null ) SELECT @DDLockBoxPath = info.GetDatabaseConfig('DataDomain','LockBoxPath', '');

	-- Set SQL Native Values
	DECLARE @path NVARCHAR(4000) 

	If( @SQLBackupPath is null )
	BEGIN
		EXEC master.dbo.xp_instance_regread 
				N'HKEY_LOCAL_MACHINE', 
				N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory', 
				@path OUTPUT,  
				'no_output' 
		SET @SQLBackupPath = @path --Make this an INIT value ? + CASE WHEN @IncludeDBNameInPath = 1 THEN @DatabaseName ELSE '' END
	END

	-- Check Default parameters
	if @ClientHost is null raiserror('Null values not allowed for ClientHost', 16, 1)
	if @BackupLevel is null raiserror('Null values not allowed for BackupLevel', 16, 1)
	if @BackupSetName is null raiserror('Null values not allowed for BackupSetName', 16, 1)
	if @BackupSetDescription is null raiserror('Null values not allowed for BackupSetDescription', 16, 1)	
	if @DDHost is null raiserror('Null values not allowed for DDHost', 16, 1)
	if @DDBoostUser is null raiserror('Null values not allowed for DDBoostUser', 16, 1)
	if @DDStorageUnit is null raiserror('Null values not allowed for DDStorageUnit', 16, 1)
	if @SQLInstanceName is null raiserror('Null values not allowed for SQLInstanceName', 16, 1)
	if @SQLDatabaseName is null raiserror('Null values not allowed for SQLDatabaseName', 16, 1)


	--Sanity check for backup type in 'FULL'/'LOG'/'DIFF' ???

	-- should we be coding exception logic for all clusters/AG groups?
	IF( @ClientHost like 'ON-SQLCLSTPRD%') SET @ClientHost = 'PRDSQLCLST'
	-- 

	DECLARE @cur cursor, @CreateDIR nvarchar(100);
	DECLARE @dbname nvarchar(100), @NumOfFiles int, @DatabaseType nvarchar(100);
	DECLARE @bsetname nvarchar(255);
	DECLARE @bsetdescription nvarchar(255);
	DECLARE @t TABLE (DBNAME NVARCHAR(100), NumOfFiles int, DBTYPE nvarchar(100))
	DECLARE @ValidStatus int, @ProductVersion INT
	SELECT @ValidStatus = 0, @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ))


	INSERT INTO @t
	SELECT DatabaseName, NumberOfFiles, DatabaseType -- SELECT * 
	FROM [DBA].[backup].[Schedule]
	WHERE ( DatabaseType = CASE WHEN @SQLDatabaseName= 'user_databases' THEN 'USER'
							    WHEN @SQLDatabaseName= 'system_databases' THEN 'SYSTEM'
						   END AND BackupMethod = @DDBoostUser 
			OR DatabaseName = @SQLDatabaseName )  AND 
		 ( @BackupLevel = CASE DATEPART(weekday, getdate())
								WHEN 1 THEN Sunday
								WHEN 2 THEN Monday
								WHEN 3 THEN Tuesday
								WHEN 4 THEN Wednesday
								WHEN 5 THEN Thursday
								WHEN 6 THEN Friday
								WHEN 7 THEN Saturday
							END
			OR ExpectedRecoveryModel = CASE WHEN @backupLevel = 'LOG' THEN 'FULL'
											ELSE 'DIFF'
										END 
			OR @Force = 1 )
	ORDER BY DatabaseName

	IF( @BackupLevel = 'LOG' ) SET @BackupLevel = 'incr'

	SET @cur = Cursor FOR
	SELECT DBNAME, NumOfFiles, DBTYPE FROM @t
	open @cur
	fetch next FROM @cur INTO @dbname, @NumOfFiles, @DatabaseType
	while @@fetch_status = 0
	BEGIN

		IF( (SELECT IsNull(SERVERPROPERTY ('IsHadrEnabled'), 0)) <> 1 ) -- 10 = SQL2008
			BEGIN
				SET @ValidStatus = 1
			END
		ELSE
			BEGIN
				If( sys.fn_hadr_is_primary_replica ( @dbname ) <> 1 )
					BEGIN  
						SET @ValidStatus = 0
					END 
				ELSE
					BEGIN
						SET @ValidStatus = 1
					END
			END

		IF( @ValidStatus = 1 )
			BEGIN
				print '--------------------------------------------------------------'
				print 'Backing up: ' + @dbname +' using: '+  @BackupSoftware
				print '--------------------------------------------------------------'

				--Set @bsetname = UPPER(@dbname + '_'+ @BackupLevel);
				Set @bsetdescription = UPPER(@dbname +' '+ @BackupLevel +' Backup');
				Set @BackupLevel = UPPER(@BackupLevel);

				IF( @BackupSoftware = 'ddboost' )
					BEGIN
						IF( (@DryRun = 1) AND (@SQLDatabaseName NOT IN ('user_databases', 'system_databases')) )
						BEGIN
							PRINT '
							Exec DDBMA.BackupImage 
								@ClientHost = '+ @ClientHost +',
								@SQLInstanceName = '+ @SQLInstanceName +',
								@BackupLevel = '+ @BackupLevel +',
								@BackupSetName = '+ @BackupSetName +',
								@BackupSetDescription = '+ @bsetdescription +',
								@RetentionDays = '+ CONVERT(VARCHAR(100), @RetentionDays ) +',
								@DDHost = '+ @DDHost +',
								@DDBoostUser = '+ @DDBoostUser +',
								@DDStorageUnit = '+ @DDStorageUnit +',
								@DDLockBoxPath = '+ @DDLockBoxPath +',
								@SQLDatabaseName = '+ @dbname +',
								@NumberOfStripes = '+ CONVERT(VARCHAR(100), @NumOfFiles ) +',
								@DryRun = '+ CONVERT(VARCHAR(100), @DryRun )	
							print '--------------------------------------------------------------'
						END

						Exec DDBMA.BackupImage 
							@ClientHost = @ClientHost,
							@SQLInstanceName = @SQLInstanceName,
							@BackupLevel = @BackupLevel,
							@BackupSetName = @BackupSetName,
							@BackupSetDescription = @bsetdescription,
							@RetentionDays = @RetentionDays,
							@DDHost = @DDHost,
							@DDBoostUser = @DDBoostUser,
							@DDStorageUnit = @DDStorageUnit,
							@DDLockBoxPath = @DDLockBoxPath,
							@SQLDatabaseName = @dbname,
							@NumberOfStripes = @NumOfFiles,
							@DryRun = @DryRun

					END
				ELSE IF( @BackupSoftware = 'SQLNative' )
					BEGIN
						IF( (@DryRun = 1) AND (@SQLDatabaseName NOT IN ('user_databases', 'system_databases')) )
						BEGIN
							PRINT '
							Exec [backup].BackupSQLNative 
								@DatabaseName = '''+ @dbname +''',
								@DatabaseType = '''+ @DatabaseType +''',
								@BackupType = '''+ @BackupLevel +''',
								@BackupPath = '''+ @SQLBackupPath +''',
								@FilesPerPath = '+ CONVERT(VARCHAR(100), @NumOfFiles ) +',
								@RetainDays = '+ CONVERT(VARCHAR(100), @RetentionDays ) +',
								@UseMirror = 0,
								@EncryptionKey  = null,
								@KeySize = 128,
								@CompressionLevel = 2,
								@Description =  '''+ @bsetdescription +''',
								@Password = null,
								@CheckSum = '+ CONVERT(VARCHAR(100), @CreateChecksum ) +',
								@IncludeDBNameInPath = null, -- default (null) will force check of global config
								@IncludeDayOfWeekInPath = null, -- default (null) will force check of global config
								@EncryptionAlgorithm = '''',
								@WithEncryption = 0,
								@DryRun = '+ CONVERT(VARCHAR(100), @DryRun )
							print '--------------------------------------------------------------'
						END
						
						SET @CreateDIR = 'mkdir ' + @SQLBackupPath;
						PRINT 'Force Create: '+ @CreateDIR
						PRINT '--------------------------------------------------------------'

						IF( @DryRun = 0 )
						BEGIN
							exec master.dbo.xp_cmdshell @CreateDIR, no_output;  --dbabackup.GetDiskListString - create backup directory
						END;

						Exec [backup].BackupSQLNative 
								@DatabaseName = @dbname,
								@DatabaseType = @DatabaseType,
								@BackupType = @BackupLevel,
								@BackupPath = @SQLBackupPath,
								@FilesPerPath = @NumberOfStripes,
								@RetainDays = @RetentionDays,
								@UseMirror = 0,
								@EncryptionKey  = null,
								@KeySize = 128,
								@CompressionLevel = 2,
								@Description =  @bsetdescription,
								@Password = null,
								@CheckSum = @CreateChecksum,
								@IncludeDBNameInPath = null, -- default (null) will force check of global config
								@IncludeDayOfWeekInPath = null, -- default (null) will force check of global config
								@EncryptionAlgorithm = '',
								@WithEncryption = 0,
								@DryRun = @DryRun
					END
				ELSE
					BEGIN
						PRINT 'Backup Software undefined'
						raiserror('Backup Software undefined',16,1)	
					END
			END
		ELSE
			BEGIN
				print '--------------------------------------------------------------'
				print 'Invalid Status: ' + @dbname
				print '--------------------------------------------------------------'
			END
	
		fetch next FROM @cur INTO @dbname, @NumOfFiles, @DatabaseType
	end
	close @cur;
	Deallocate @cur;
END;
