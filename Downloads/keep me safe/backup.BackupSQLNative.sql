USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[backup].[BackupSQLNative]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [backup].[BackupSQLNative] AS RETURN 0;';
END
GO

ALTER PROCEDURE [backup].[BackupSQLNative]
	@DatabaseName sysname,
	@DatabaseType varchar(50) = 'USER',
	@BackupType varchar(10) = 'FULL',
	@BackupPath varchar(max),
	@FilesPerPath int = 1,
	@RetainDays int,
	@UseMirror smallint = 0,
	@EncryptionKey varchar(255) = null,
	@KeySize int = 128,
	@CompressionLevel int = 2,
	@Description varchar(255) = '',
	@Password varchar(255) = null,
	@CheckSum int = 0,
	@CopyOnly bit = 1,
	@BackupPathDelimiter char(1) = ',',
	@IncludeDBNameInPath int = null, -- default (null) will force check of global config
	@IncludeDayOfWeekInPath int = null, -- default (null) will force check of global config
	@dryrun int = 0,
	@EncryptionAlgorithm varchar(50),
	@WithEncryption bit,
    @MaxTransferSize varchar(20) = '1048576' --default 1MB, used for TDE Compressed databases. Using a variable initially so we can experiment easily
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BackupStatement varchar(max);
	DECLARE @StrFileList varchar(max),
			@StrMirrorFileList varchar(max);
	DECLARE @exitcode int,
			@sqlerrorcode int;
	DECLARE @DiskStringType varchar(25);
	DECLARE @sqlVersion int;
	DECLARE @IsTDEEncrypted BIT;
	DECLARE @BackupDate varchar(100);
	
	-- figure out our sql version (9=2005, 10=2008, etc.)
	SET @sqlVersion = cast( substring(cast(SERVERPROPERTY('productversion') as varchar(100)), 0, charindex('.', cast(SERVERPROPERTY('productversion') as varchar(100)))) as int )
	SELECT @IsTDEEncrypted=is_encrypted FROM SYS.DATABASES WHERE NAME=@DatabaseName;

	-- only option we support with standard backups, for now
	-- SET @UseMirror = 0;

	SET @DiskStringType = 'DISK';
	SET @DiskStringType = CASE WHEN @UseMirror = 1 THEN 'DISKMIRROR' ELSE 'DISK' END;
	SET @BackupDate = CONVERT(nchar(8), getdate(), 112) + '_' + REPLACE(CONVERT(nchar(8), getdate(), 108), N':', N'');
	Set @StrFileList = @DiskStringType +' = N'''+ @BackupPath +'\'+ @DatabaseName +'_'+ @BackupType +'_'+ 
		(CASE WHEN @CopyOnly = 1 THEN '_COPYONLY'	ELSE ''	END) +
		@BackupDate +'.' + (
							CASE @BackupType -- file extension details here
								WHEN 'FULL' THEN 'bak'
								WHEN 'LOG' THEN 'trn'
								WHEN 'DIFF' THEN 'dif'
								ELSE 'bak'
							END
					) + '''';

	/* Future Feature
	-- see the function "dbabackup.GetDiskListString" for all the complex stuff involved in figuring out pathing:
	SET @StrFileList = dbabackup.GetDiskListString(
						@DatabaseName, @DatabaseType, @BackupType,
						@BackupPath, @FilesPerPath, @BackupPathDelimiter,
						@DiskStringType, @IncludeDBNameInPath, @IncludeDayOfWeekInPath
					);

	if( @UseMirror = 1 )
	begin
		-- raiserror('Mirrored backups are not yet supported for native backups.', 16, 1, 1);
		-- return ;
		SET @StrMirrorFileList = dbabackup.GetDiskListString(
						@DatabaseName, @DatabaseType, @BackupType,
						@BackupPath, @FilesPerPath, @BackupPathDelimiter,
						'SQLMIRROR', default, default );
	end */

	SET @BackupStatement = 'BACKUP ' +
							(CASE UPPER(@BackupType)
								WHEN 'FULL' THEN 'DATABASE'
								WHEN 'DIFF' THEN 'DATABASE'
								WHEN 'LOG' THEN 'LOG'
								ELSE 'ERROR'
							 END)
							+ ' [' + @DatabaseName + '] TO '
							+ char(13) + @StrFileList
							+ (CASE WHEN @UseMirror = 1 and len(@StrMirrorFileList) > 0 THEN ' MIRROR TO  ' + @StrMirrorFileList ELSE '' END)
							+ char(13) + 'WITH STATS = 5, INIT '
							-- FUTURE FEATURE+ (CASE WHEN ((select AGROLE from DBA.[Info].[fnInstanceAGRole](@DatabaseName))=2 AND @BackupType != 'log')  THEN ', COPY_ONLY 'ELSE '' END)
							-- not suppported in 2005
							+ CASE WHEN @sqlVersion >= 10 THEN 
								CASE WHEN coalesce(@CompressionLevel, 0) > 0 THEN ' , COMPRESSION ' ELSE ' , NO_COMPRESSION ' END
							  ELSE ''
							  END
							-- disable mirroring for now -- much more complex with native backups
							+ (CASE WHEN @BackupType = 'DIFF' THEN ' , DIFFERENTIAL ' ELSE '' END)
							+ (CASE WHEN @CheckSum = 1 THEN ' , CHECKSUM ' ELSE '' END)
							+ ' , DESCRIPTION = ''' + @Description + ''''
							+ ' , FORMAT' -- we always use format with native backups.
							-- not *really* supported in 2005 (or 2008).  Old "password" is depricated
							 + (CASE WHEN @WithEncryption = 1 AND @IsTDEEncrypted=0 THEN ', 
									ENCRYPTION
									(
										ALGORITHM='+@EncryptionAlgorithm+',
										SERVER ASYMMETRIC KEY = '+@EncryptionKey+'
									)' ELSE '' END) 
							+ (CASE WHEN @RetainDays > 0 THEN ', RETAINDAYS = '+ CONVERT(nchar(8), @RetainDays ) +', SKIP, NOREWIND, NOUNLOAD '
								ELSE ''	END)
							+ (CASE WHEN @CopyOnly = 1 THEN ', COPY_ONLY '
								ELSE ''	END)
                            -- If Encrypted with TDE and SQL 2016 onwards, compressed log backups need max transfersize set in order to compress.
                             + (CASE WHEN @IsTDEEncrypted = 1 AND @sqlVersion >= 13 AND UPPER(@BackupType) = 'LOG'
									THEN ' , MAXTRANSFERSIZE = '+@MaxTransferSize+''
									ELSE ''
								END);

	IF( @dryrun = 0 )
		BEGIN
			EXEC( @BackupStatement );
		END
	ELSE
		BEGIN
			print @BackupStatement;
		END
END;
GO
