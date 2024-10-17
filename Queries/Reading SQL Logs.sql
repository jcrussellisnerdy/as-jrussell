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
        2,
        1,
        N'';

      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        3,
        1,
        N'';

		      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        4,
        1,
        N'';

		      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        5,
        1,
        N'';
		      INSERT INTO #IOWarningResults
      EXEC Xp_readerrorlog
        6,
        1,
        N'';		       





  END

SELECT  
  FORMAT(LogDate, 'dddd, MMMM dd, yyyy hh:mm tt'),

 ProcessInfo, LogText
FROM   #IOWarningResults
WHERE ProcessInfo not in ('Logon','Backup')
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










--DECLARE @auth_mode INT;

--EXEC xp_instance_regread 
--    N'HKEY_LOCAL_MACHINE', 
--    N'Software\Microsoft\MSSQLServer\MSSQLServer', 
--    N'LoginMode', 
--    @auth_mode OUTPUT;

--SELECT 
--    CASE @auth_mode 
--        WHEN 1 THEN 'Windows Authentication'
--        WHEN 2 THEN 'SQL Server and Windows Authentication'
--        ELSE 'Unknown Authentication Mode'
--    END AS AuthenticationMode;
