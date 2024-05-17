USE [DBA];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shrinkLogs]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[shrinkLogs] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [dbo].[shrinkLogs] (@maxRunTime int = 120, @oneDB varchar(128) = NULL, @dryRun int = 1) --null = all
-- will finish file it's on if the time expires, but does keep it from running endlessly.
AS

SET NOCOUNT ON;
-- [dbo].[shrinkLogs] @oneDB = 'DBA', @dryRun = 0;
-- [dbo].[shrinkLogs] @dryRun = 0;
DECLARE @sql AS VARCHAR(7999);
DECLARE @version INT;

--Checks for existing global temp table. Exits if already exists. Replace this later
IF OBJECT_ID('tempdb..##vlfs') IS NOT NULL
    BEGIN
		PRINT 'Table ##vlfs already exists. Exit any other instances of this procedure that is running and try again.';
		RETURN;
	END;

--Checks for version.  2012 and after a new column named recoveryunitid
SELECT @version = CONVERT(INT, SERVERPROPERTY('ProductMajorVersion'))

IF @version >=11
	BEGIN
		SELECT @sql = 'CREATE TABLE ##vlfs
		(recoveryunitid tinyint, fileId tinyint, fileSize bigint, startOffset bigint, fseqNo int, status tinyint, paritity tinyint, createLSN numeric(25,0))';
	END
ELSE
	BEGIN
		SELECT @sql = 'CREATE TABLE ##vlfs
		(fileId tinyint, fileSize bigint, startOffset bigint, fseqNo int, status tinyint, paritity tinyint, createLSN numeric(25,0))';
	END;

EXEC(@sql);

CREATE TABLE #LogSpace (DBName VARCHAR(128), LogSize BIGINT, LogPctUsed BIGINT, [Status] INT) WITH (DATA_COMPRESSION=PAGE);
CREATE TABLE #DBs (Name VARCHAR(128), LogSize BIGINT, MaxLogSize BIGINT) WITH (DATA_COMPRESSION=PAGE);
DECLARE @dbName varchar(128), @dbLogSize bigint, @maxDBLogSize int;
DECLARE @VLFsize int, @newdbLogSize bigint, @logfileid int, @logfilename varchar(128), @newlogfilesize bigint;
DECLARE @stop int;
DECLARE @endTime datetime;

SELECT @endTime = DATEADD(mi, @maxRunTime, GETDATE());

INSERT INTO #DBs
	SELECT d.name, sum(size)/1024.0*8, DBA.info.getDatabaseConfig(d.name,'maxLogSizeMB',
														case
														when d.name like 'ReportServer%' then 132096
														else (SELECT DBA.info.getDatabaseConfig( 'ALL','maxLogSizeMB',10240)) end)
	FROM master.sys.master_files f (NOLOCK)
	JOIN sys.databases d (NOLOCK)
	  ON f.database_id = d.database_id
	INNER JOIN DBA.Info.getAGDatabaseRole('') agRole
	  ON d.name = agRole.DatabaseName and agRole.AGDatabaseRole IN (0,1)
	WHERE data_space_id = 0 --and dbid > 4 
	  AND d.state_desc = 'ONLINE' AND d.is_read_only = 0
	GROUP BY d.name
	HAVING SUM(size)/1024.0*8 > DBA.info.getDatabaseConfig(d.name,'maxLogSizeMB',
														case
														when d.name like 'ReportServer%' then 132096
														else (SELECT DBA.info.getDatabaseConfig( 'ALL','maxLogSizeMB',10240)) end)

IF @oneDB IS NOT NULL
BEGIN
	DELETE FROM #DBs WHERE name <> @oneDB;
END;
	
WHILE EXISTS (SELECT * FROM #DBs) AND GETDATE() < @endTime
BEGIN
	SELECT @stop = 0
	SELECT TOP 1 @dbName = name, @dbLogSize = logsize, @newdblogsize = logsize, @maxDBLogsize=maxlogsize
		 FROM #DBs ORDER BY LogSize DESC, Name;
	PRINT '---------------- ' + @dbName + ' ---------------';
	WHILE GETDATE() < @endTime AND @stop = 0 AND @newdbLogSize > @maxDBLogSize
	BEGIN
		SELECT @vlfsize = 0;

		IF EXISTS (SELECT * FROM DBA.info.InstanceLoadQuery (NOLOCK)
		WHERE CurrentStatement LIKE '%backup%' + @dbName + '%')
		BEGIN
			SELECT @stop = 1;
			PRINT 'Full or log backup running.';
			BREAK;
		END;

		DELETE FROM #LogSpace;
		INSERT INTO #LogSpace
		EXEC ('DBCC SQLPERF (LogSpace) WITH NO_INFOMSGS');
			
		IF EXISTS (SELECT * FROM #LogSpace WHERE DBName = @dbName AND LogPctUsed > 70)
		BEGIN
			SELECT @stop = 1;
			PRINT 'Log pct > 70, unable to continue shrink';
			BREAK;
		END;
			
		DELETE FROM ##vlfs;
		SELECT @sql = 'USE [' + @dbName + ']
			DBCC LOGINFO WITH NO_INFOMSGS';
				
		INSERT INTO ##vlfs
		EXEC (@sql);

		-- if the very last vlf is not the 'first' log file, and the size is the minimum, we need to 
		-- backup a vlf and check the one before so that we can shrink the 'first' file.

		DELETE FROM ##vlfs
		WHERE fileid <> 2 AND startoffset = 8192;
						
		SELECT TOP 1 @vlfSize = CASE WHEN Status <> 0 THEN -1 -- can only shrink the log if the very last vlf is empty
								ELSE FileSize/1024.0/1024.0 END,
					@logFileid = fileid
					FROM ##vlfs
					ORDER BY FileID DESC, StartOffset DESC;
		IF @vlfsize = 0 -- fraction was dropped
		BEGIN
			SELECT @vlfsize = 1;
		END;
						
		IF @vlfSize < 0
		BEGIN
			SELECT @stop = 1;
			PRINT 'Last VLF is not empty';
			BREAK;
		END;

		-- get the actual filename and current size for the file to be shrunk
		SELECT @logFileName = name, @newlogfilesize = size/1024.0*8 
			FROM master.sys.master_files (NOLOCK) 
			WHERE database_id = DB_ID(@dbName) AND file_id = @logfileid;
		SELECT @newdblogsize = @newdblogsize - @vlfsize - 1,-- size must be smaller than last vlf
				@newlogfilesize = @newlogfilesize - @vlfsize - 1; -- in case there is more than one log, get the exact size for the file we are shrinking

		IF @newdblogsize < 1 OR @newlogfilesize < 1
		BEGIN
			SELECT @stop = 1;
			PRINT 'Error calculating size';
			BREAK;
		END;

		IF @logFileName = ''
		BEGIN
			SELECT @stop = 1;
			PRINT 'Invalid filename';
			BREAK;
		END;

		PRINT @dbname + ' SHRINKING '+ CAST(@dblogsize AS VARCHAR(50))+' --- > ' + CAST(@newdblogSize AS VARCHAR(50)); 
		SELECT @sql = 'USE [' + @dbname + ']
			DBCC SHRINKFILE (''' + @LogFileName + ''', ' + CAST(@newlogfileSize AS VARCHAR(50));
		SELECT @sql = @sql + ') WITH NO_INFOMSGS';
			
		BEGIN TRY
			IF( @dryRun = 1 )
				BEGIN
					PRINT @sql;
				END
			ELSE
				BEGIN
					EXEC (@sql);
				END
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE();
			SELECT @stop = 1;
			BREAK;
		END CATCH

		SELECT @newdblogsize = SUM(size)/1024.0*8
			FROM master.sys.master_files (NOLOCK) 
			WHERE type = 1 AND database_id = DB_ID(@dbname); 

		IF @newdblogsize >= @dblogsize
		BEGIN
			SELECT @stop = 1;
			PRINT 'Log did not shrink';
			BREAK;
		END;
	END;
	DELETE FROM #DBs WHERE name = @dbname;
END;

DROP TABLE ##vlfs;

GO