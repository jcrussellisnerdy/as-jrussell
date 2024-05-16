IF Object_id(N'tempdb..#IOWarningResults') IS NOT NULL
  DROP TABLE #IOWarningResults

CREATE TABLE #IOWarningResults
  (
     LogDate     DATETIME,
     ProcessInfo SYSNAME,
     LogText     NVARCHAR(max)
  );

IF EXISTS (SELECT *
           FROM   sys.databases
           WHERE  name = 'rdsadmin')
  BEGIN
      INSERT INTO #IOWarningResults
      EXEC rdsadmin.dbo.Rds_read_error_log
        @index = 0,
        @type = 1;

      INSERT INTO #IOWarningResults
      EXEC rdsadmin.dbo.Rds_read_error_log
        @index = 1,
        @type = 1;

      INSERT INTO #IOWarningResults
      EXEC rdsadmin.dbo.Rds_read_error_log
        @index = 2,
        @type = 1;

      INSERT INTO #IOWarningResults
      EXEC rdsadmin.dbo.Rds_read_error_log
        @index = 0,
        @type = 2;
  END
ELSE IF EXISTS (select * from sys.database_files  where physical_name like 'https%')
  BEGIN
      INSERT INTO #IOWarningResults
        EXEC Xp_readerrorlog
        0,
        1,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        1,
        1,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        0,
        2,
        N'';
 END
ELSE
  BEGIN
      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        0,
        1,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        1,
        1,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        0,
        2,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        1,
        2,
        N'';
  END

SELECT *
FROM   #IOWarningResults
order by logdate desc 



/*
SELECT *
FROM #IOWarningResults

ORDER BY LogDate DESC 

select GETDATE()

SELECT MIN(LogDate)
FROM #IOWarningResults
ORDER BY LogDate DESC 

*/










