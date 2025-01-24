DECLARE @sqlcmd       VARCHAR(max),
        @DatabaseName SYSNAME,
        @StartDate    VARCHAR(20) = '',
        @EndDate      VARCHAR(20),
        @Type         VARCHAR(1) = 'D',
        @DBNAME       VARCHAR(125) = '',
        @NotBackedup  VARCHAR(125),
        @Max          INT = 1,
        @Verbose      INT = 1,
        @WhatIF       INT = 0

IF Object_id(N'tempdb..#LastBackup') IS NOT NULL
  DROP TABLE #LastBackup

CREATE TABLE #LastBackup
  (
     [Server]               VARCHAR(100),
     [type]                 VARCHAR(100),
     [DatabaseName]         VARCHAR(100),
     [last_db_backup_date]  DATE,
     [physical_device_name] VARCHAR(1000),
     [filename]             VARCHAR(1000),
     IsProcessed            BIT
  );

/* 
-- In a world the DBA maintenance tables doesn't exist this can be used. 
INSERT INTO #TempDatabases (DatabaseName, IsProcessed)
SELECT name, 0 -- SELECT *
FROM   sys.databases
ORDER  BY database_id
*/
IF @StartDate IS NULL
    OR @StartDate = ''
  SET @StartDate = Getdate() - 7

IF @EndDate IS NULL
    OR @EndDate = ''
  SET @EndDate = Getdate()

IF Object_id(N'tempdb..#TempDatabases') IS NOT NULL
  DROP TABLE #TempDatabases

CREATE TABLE #TempDatabases
  (
     DatabaseName SYSNAME,
     IsProcessed  BIT
  )

-- Insert the databases to exclude into the temporary table
INSERT INTO #TempDatabases
            (DatabaseName,
             IsProcessed)
SELECT DatabaseName,
       0 -- SELECT *
FROM   [DBA].[backup].[Schedule] S
       JOIN sys.databases D
         ON S.DatabaseName = D.name

-- Loop through the remaining databases
WHILE EXISTS(SELECT *
             FROM   #TempDatabases
             WHERE  IsProcessed = 0)
  BEGIN
      -- Fetch 1 DatabaseName where IsProcessed = 0
      SELECT TOP 1 @DatabaseName = DatabaseName
      FROM   #TempDatabases
      WHERE  IsProcessed = 0

      -- Prepare SQL Statement
      SELECT @sqlcmd = '	
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY(''Servername'')) AS Server, msdb..backupset.type,
   msdb.dbo.backupset.database_name,  
   MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date , physical_device_name
      ,   LEFT(
        SUBSTRING(
            physical_device_name,
            LEN(physical_device_name) - CHARINDEX(''\'', REVERSE(physical_device_name)) + 2,
            LEN(physical_device_name)
        ),
        LEN(physical_device_name) - CHARINDEX(''.'', REVERSE(physical_device_name)) + 1
    ) AS filename,0 
   --select  top 5*
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
WHERE msdb..backupset.type = ''' + @Type
                       + ''' 
AND  msdb.dbo.backupset.database_name = '''
                       + @DatabaseName
                       + '''
AND  msdb.dbo.backupset.backup_finish_date BETWEEN  '''
                       + @StartDate + ''' AND ''' + @EndDate
                       + '''
GROUP BY 
   msdb.dbo.backupset.database_name  , msdb.dbo.backupset.type, msdb.dbo.backupmediafamily.physical_device_name,  LEFT(
        SUBSTRING(
            physical_device_name,
            LEN(physical_device_name) - CHARINDEX(''\'', REVERSE(physical_device_name)) + 2,
            LEN(physical_device_name)
        ),
        LEN(physical_device_name) - CHARINDEX(''.'', REVERSE(physical_device_name)) + 1
    )
ORDER BY  
  MAX(msdb.dbo.backupset.backup_finish_date) DESC'

      IF @WhatIF = 1
        BEGIN
            PRINT ( @SQLCMD )
        END

      INSERT INTO #LastBackup
      EXEC (@SQLcmd)

      -- Update table
      UPDATE #LastBackup
      SET    IsProcessed = 1
      WHERE  DatabaseName = @databaseName

      -- Update table
      UPDATE #TempDatabases
      SET    IsProcessed = 1
      WHERE  DatabaseName = @databaseName
  END

-- Check for databases not backed up within the time frame
DECLARE @NotBackedUpCount INT;

SELECT @NotBackedUpCount = Count(*)
FROM   sys.databases D
       LEFT JOIN #LastBackup LB
              ON D.name = LB.DatabaseName
WHERE  D.database_id > 4 -- Exclude system databases
       AND ( LB.last_db_backup_date IS NULL
              OR LB.last_db_backup_date < @StartDate );

SELECT @NotBackedup = D.name
FROM   sys.databases D
       LEFT JOIN #LastBackup LB
              ON D.name = LB.DatabaseName
WHERE  D.database_id > 4
       AND ( LB.last_db_backup_date IS NULL
              OR LB.last_db_backup_date < @StartDate );

IF @Type = 'D'
BEGIN
IF @NotBackedUpCount > 0  
  BEGIN
      PRINT 'Databases not backed up within the specified time frame: '
            + @NotBackedup;
  END
ELSE
  BEGIN
      PRINT 'All databases backed up in a good time frame.';
  END;
END 

IF @Max = 0
   AND @WhatIF = 0
  BEGIN
      SELECT DatabaseName,
             Max([last_db_backup_date]) [Last backup Date]
      FROM   #LastBackup
      WHERE  DatabaseName LIKE '%' + @DBNAME + '%'
      GROUP  BY DatabaseName
      ORDER  BY [Last backup Date] DESC
  END
ELSE IF @Max = 0
   AND @WhatIF = 1
  BEGIN
      PRINT ( ' SELECT DatabaseName,
             Max([last_db_backup_date]) [Last backup Date]
      FROM   #LastBackup
	  WHERE  DatabaseName LIKE ''%' + @DBNAME
              + '%''
      GROUP  BY DatabaseName
      ORDER  BY [Last backup Date] DESC' )
  END
ELSE
  BEGIN
      IF @WhatIF = 0
        BEGIN
            IF ( @DBNAME = '?'
                  OR @DBNAME = '' )
              IF @Verbose = 1
                BEGIN
                    SELECT DISTINCT [Server],
                                    type,
                                    DatabaseName,
                                    Max(last_db_backup_date) [Last backup Date],
                                    [physical_device_name],
                                    [filename]
                    FROM   #LastBackup
                    GROUP  BY [Server],
                              type,
                              DatabaseName,
                              [physical_device_name],
                              [filename]
                    ORDER  BY Max(last_db_backup_date) DESC
                END
              ELSE
                BEGIN
                    SELECT DISTINCT [Server],
                                    type,
                                    DatabaseName,
                                    Max(last_db_backup_date) [Last backup Date]
                    FROM   #LastBackup
                    GROUP  BY [Server],
                              type,
                              DatabaseName,
                              [physical_device_name],
                              [filename]
                    ORDER  BY Max(last_db_backup_date) DESC
                END
            ELSE IF @Verbose = 1
              BEGIN
                  SELECT DISTINCT [Server],
                                  type,
                                  DatabaseName,
                                  Max(last_db_backup_date) [Last backup Date],
                                  [physical_device_name],
                                  [filename]
                  FROM   #LastBackup
                  WHERE  DatabaseName = @DBNAME
                  GROUP  BY [Server],
                            type,
                            DatabaseName,
                            [physical_device_name],
                            [filename]
                  ORDER  BY Max(last_db_backup_date) DESC
              END
            ELSE
              BEGIN
                  SELECT DISTINCT [Server],
                                  type,
                                  DatabaseName,
                                  Max(last_db_backup_date) [Last backup Date]
                  FROM   #LastBackup
                  WHERE  DatabaseName = @DBNAME
                  GROUP  BY [Server],
                            type,
                            DatabaseName,
                            [physical_device_name],
                            [filename]
                  ORDER  BY Max(last_db_backup_date) DESC
              END
        END
  END 
