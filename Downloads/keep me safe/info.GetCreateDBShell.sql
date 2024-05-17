USE DBA
GO
/****** Object:  StoredProcedure [info].[GetCreateDBShell]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[GetCreateDBShell]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetCreateDBShell] AS RETURN 0;';
END
GO

ALTER PROCEDURE info.GetCreateDBShell ( @TargetDB varchar(100) = 'DBA', @dryRun int = 0 )
AS
BEGIN
	-- EXEC [info].[GetCreateDBShell] @TargetDB = 'unitrac', @DryRun = 1
	-- EXEC [info].[GetCreateDBShell] @DryRun = 0

    -- This might be a bad name for this stored procedure.  
	SET NOCOUNT ON

	IF OBJECT_ID('tempdb..#FileInfo', 'U') IS NOT NULL
		DROP TABLE #FileInfo
	/* List required fields of target DB */
	CREATE TABLE #FileInfo
	(
		file_ID int,
		Type INT,
		NAME varchar(MAX),
		PHYSICAL_NAME varchar(MAX),
		SIZE INT,
		MAX_SIZE INT,
		GROWTH INT,
		is_percent_growth int
	)
	WITH (DATA_COMPRESSION = PAGE);

	IF OBJECT_ID('tempdb..#CreateShell', 'U') IS NOT NULL
		DROP TABLE #CreateShell
	/* Create statements */
	CREATE TABLE #CreateShell
	(
		ExpectedID int,
		CommandType varchar(max),
		CommandStatement varchar(MAX)
	)
	WITH (DATA_COMPRESSION = PAGE);

	IF OBJECT_ID('tempdb..#DropTempFiles', 'U') IS NOT NULL
		DROP TABLE #DropTempFiles
	/* Drop place holder files */
	CREATE TABLE #DropTempFiles
	(
		ExpectedID int,
		CommandType varchar(max),
		CommandStatement varchar(MAX)
	)
	WITH (DATA_COMPRESSION = PAGE);

	DECLARE @myCounter int = 1, @firstLogFile int = 0, @lastFileID int = 0, @maxFileID int = 0, @sqlCMD varchar(max)

	SELECT @TargetDB = name FROM sys.Databases where name = @TargetDB
	SELECT @sqlCMD = 'select file_ID, Type, NAME, PHYSICAL_NAME, SIZE, MAX_SIZE, GROWTH, is_percent_growth FROM '+ @TargetDB +'.Sys.database_files'
	INSERT INTO #FileInfo (file_ID, Type, NAME,	PHYSICAL_NAME, SIZE, MAX_SIZE, GROWTH, is_percent_growth) 
		EXEC( @sqlCMD )
		--select file_ID,	Type, NAME,	PHYSICAL_NAME, SIZE, MAX_SIZE, GROWTH, is_percent_growth FROM Sys.database_files

	IF( @dryRun = 1 ) SELECT * FROM  #FileInfo

	SELECT @firstLogFile = MIN(File_ID) from #FileInfo WHERE Type = 1
	SELECT @maxFileID = max(file_id) from #FileInfo

	WHILE( @myCounter <= @maxFileID )
	BEGIN
		INSERT INTO #CreateShell ( ExpectedID ) VALUES ( @mycounter );
		SET @myCounter = @myCounter + 1
	END;

	UPDATE Commands
	SET  CommandType = 'CREATE',
		 CommandStatement = --( SELECT 
	'( Name = N'''+ [name] +''', FileName = N'''+ physical_name +''', Size = '+ convert(varchar(100), (Size/1024)*8) +'MB, MaxSize = '+ CASE WHEN Max_Size = -1 THEN 'UNLIMITED' ELSE convert(varchar(100), (Max_Size/1024)*8) +'MB' END +', FileGrowth = '+ convert(varchar(100), (growth/1024)*8) +'MB )'
	FROM  #CreateShell as Commands
	Inner Join #FileInfo as DF on (Commands.ExpectedID = DF.File_ID) 
	WHERE File_ID <= @firstLogFile

	UPDATE Commands
	SET  CommandType = CASE WHEN Type= 0 THEN 'ALTER' ELSE 'ADD LOG' END,
		 CommandStatement = --( SELECT 
	'( Name = N'''+ [name] +''', FileName = N'''+ physical_name +''', Size = '+ convert(varchar(100), (Size/1024)*8) +'MB, MaxSize = '+ CASE WHEN Max_Size = -1 THEN 'UNLIMITED' ELSE convert(varchar(100), (Max_Size/1024)*8) +'MB' END +', FileGrowth = '+ convert(varchar(100), (growth/1024)*8) +'MB )'
	FROM  #CreateShell as Commands
	Inner Join #FileInfo as DF on (Commands.ExpectedID = DF.File_ID) 
	WHERE File_ID >  @firstLogFile

	INSERT INTO #DropTempFiles ( ExpectedID )  SELECT ExpectedID FROM #CreateShell WHERE ExpectedID NOT IN ( SELECT ExpectedID FROM #DropTempFiles ) AND CommandType is NULL

	UPDATE #CreateShell
	SET CommandType = CASE WHEN ExpectedID > (SELECT MIN(File_ID) from Sys.database_files WHERE Type = 1) THEN 'ALTER' ELSE 'CREATE' END,
		CommandStatement = '( Name = N'''+ @TargetDB +'_TempFile'+ convert(varchar(100), ExpectedID) +''', FileName = N''C:\SQL\HKB1\SQLData\'+ @TargetDB +'_TempFile'+ convert(varchar(100), ExpectedID) +'.ndf'', Size = 1MB, MaxSize = UNLIMITED, FileGrowth = 1MB )'
	WHERE CommandType is null
	IF( @dryRun = 1 ) SELECT * FROM  #CreateShell

	UPDATE #DropTempFiles
	SET CommandType = 'REMOVE',
		CommandStatement = 'ALTER DATABASE ['+ @TargetDB +'] REMOVE FILE ['+ @TargetDB +'_TempFile'+ convert(varchar(100), ExpectedID) +'];'
	WHERE CommandType is null
	IF( @dryRun = 1 ) SELECT * FROM  #DropTempFiles

	DECLARE @CreateStatement varchar(max) 
	SET @myCounter = 1
	While( @myCounter <= @maxFileID )
	BEGIN
		IF( @myCounter = 1)
		BEGIN
			SELECT @CreateStatement= '
				USE [MASTER]
				GO
			/* Create Original Database */
				Create Database ['+ @TargetDB +'] 
				  Containment = None 
				  on Primary '
			SELECT @CreateStatement = @CreateStatement +'
				'+ coalesce(CommandStatement, ', ', '')
				FROM  #CreateShell
				WHERE ExpectedID = @mycounter
				Order by ExpectedID
		END
		ELSE IF( @firstLogFile = @myCounter)
		BEGIN
			SELECT @CreateStatement = @CreateStatement +'
				LOG ON
				'+ coalesce(CommandStatement, ', ', '')
				FROM  #CreateShell
				WHERE ExpectedID = @mycounter
				Order by ExpectedID
		END
		ELSE IF( (SELECT CommandType FROM #CreateShell WHERE ExpectedID = @mycounter) = 'CREATE' )
		BEGIN
			SELECT @CreateStatement = @CreateStatement +',
				'+ coalesce(CommandStatement, ', ', '')
				FROM  #CreateShell
				WHERE ExpectedID = @mycounter
				Order by ExpectedID
		END	
		ELSE 
		BEGIN
			IF( (SELECT CommandType FROM #CreateShell WHERE ExpectedID = @mycounter - 1 ) = 'CREATE' )
			BEGIN
				SELECT @CreateStatement = @CreateStatement +'
				GO

			/* Additional files after DB create */'
			END
				SELECT @CreateStatement = @CreateStatement +'
				ALTER Database ['+ @TargetDB +'] ADD '+ CASE WHEN CommandType = 'ALTER' THEN 'FILE ' ELSE 'LOG FILE ' END + CommandStatement +';'
				FROM  #CreateShell
				WHERE ExpectedID = @myCounter
		END;

		SET @myCounter = @myCounter + 1
	END;
		SELECT @CreateStatement = @CreateStatement +'
				GO
			
				USE ['+ @TargetDB +']
				GO
				ALTER AUTHORIZATION ON DATABASE::['+ @TargetDB +'] TO [sa];
				GO
	'

	IF( (SELECT Count(*) FROM #DropTempFiles) > 0 )
	BEGIN
		SELECT @CreateStatement = @CreateStatement +'
			/* Remove TEMP files created to keep file SID same */'

		SELECT @CreateStatement = @CreateStatement +'
				'+ coalesce(CommandStatement, '; ', '')
			FROM  #DropTempFiles
			Order by ExpectedID
	END

	PRINT @CreateStatement 


	/*
	shell game rough instructions...

	Create new DB
	Create new table
	DETACH new DB
	Move new files to safety
	Create empty DB - same everything
	Set empty DB in recovery....
		BACKUP DATABASE [UniTrac] TO  DISK = N'nul' WITH NOFORMAT, NOINIT,  NAME = N'Empty-UniTrac-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
		BACKUP LOG [UniTrac] TO  DISK = N'nul' WITH  NO_TRUNCATE , NOFORMAT, NOINIT,  NAME = N'Empty-UniTrac-Log Database Backup', SKIP, NOREWIND, NOUNLOAD,  NORECOVERY ,  STATS = 10
		GO
	Take SQL Instance offline
	Remove empty DB files
	Place real DB files in correct location
	Bring SQL Instance online

 

	Open database into standby check LSN
	RESTORE LOG UniTrac
	WITH STANDBY = N'C:\SQL\HKB1\Backups\ROLLBACK_UNDO_UniTrac.tuf', CONTINUE_AFTER_ERROR;
	Put it back
	Restore database unitrac with norecovery
	GO

	*/
END;
