USE tempdb

DECLARE @BASEPATH NVARCHAR(300)
DECLARE @SQL_SCRIPT NVARCHAR(1000)
DECLARE @CORES INT
DECLARE @FILECOUNT INT
DECLARE @SIZE INT
DECLARE @GROWTH INT
DECLARE @ISPERCENT INT
DECLARE @LogFile NVARCHAR(10)
DECLARE @Percentage DECIMAL(5, 2) = 0.20;
DECLARE @ServerLocation NVARCHAR(10)
DECLARE @Dryrun BIT = 1

SELECT @LogFile = CASE
                    WHEN ServerLocation = @ServerLocation
                         AND ServerEnvironment NOT IN ( 'PRD', 'PROD', 'ADMIN', 'ADM' ) THEN '1'
                    WHEN ServerLocation = @ServerLocation
                         AND ServerEnvironment IN ( 'PRD', 'PROD', 'ADMIN', 'ADM' ) THEN '10'
                    ELSE 1
                  END
--select *
FROM   dba.info.Instance

IF @ServerLocation IS NULL
    OR @ServerLocation = ''
  BEGIN
      SELECT @ServerLocation = CASE
                                 WHEN ServerLocation IS NOT NULL THEN ServerLocation
                                 ELSE ''
                               END
      --select *
      FROM   dba.info.Instance
  END

-- TempDB mdf count equal logical cpu count
SELECT @CORES = cpu_count
FROM   sys.dm_os_sys_info

IF @CORES BETWEEN 9 AND 31
  SET @CORES = @CORES / 2

IF @CORES >= 32
  SET @CORES = @CORES / 4

--Check and set tempdb files count are multiples of 4
IF @CORES > 8
  SET @CORES = @CORES - ( @CORES % 4 )

SET @BASEPATH = (SELECT CASE
                          WHEN Charindex(N'tempdb.mdf', Lower(physical_name)) > 0 THEN Substring(physical_name, 1, Charindex(N'tempdb.mdf', Lower(physical_name)) - 1)
                          ELSE physical_name
                        END
                 FROM   master.sys.master_files
                 WHERE  database_id = 2
                        AND FILE_ID = 1);
SET @FILECOUNT = (SELECT Count(*)
                  FROM   master.sys.master_files
                  WHERE  database_id = 2
                         AND TYPE_DESC = N'ROWS')

SELECT @SIZE = size
FROM   master.sys.master_files
WHERE  database_id = 2
       AND FILE_ID = 1

SET @SIZE = @SIZE / 128

SELECT @GROWTH = growth
FROM   master.sys.master_files
WHERE  database_id = 2
       AND FILE_ID = 1

SELECT @ISPERCENT = is_percent_growth
FROM   master.sys.master_files
WHERE  database_id = 2
       AND FILE_ID = 1

IF @ISPERCENT = 0
  SET @GROWTH = @GROWTH * 8

---force this to only show for either just dryrun or just verbose if dryrun is 0 this isn't needed
SELECT Isnull(I.SQlServername, @@SERVERNAME)                                                                                                                                                                                                                             [InstanceName],
       Isnull(ServerLocation, 'Research')                                                                                                                                                                                                                                [InstanceLocation],
       Isnull(ServerEnvironment, 'Research')                                                                                                                                                                                                                             [InstanceEnvironment],
       (SELECT size * 8 / 1024
        FROM   sys.master_files
        WHERE  database_id = 2
               AND type = 1)                                                                                                                                                                                                                                             AS CurrentLogFileSizeMB,
       (SELECT growth * 8 / 1024
        FROM   sys.master_files
        WHERE  database_id = 2
               AND type = 1)                                                                                                                                                                                                                                             AS StartingLogFileSizeMB,
       (SELECT Avg(size * 8 / 1024)
        FROM   sys.master_files
        WHERE  database_id = 2
               AND type = 0)                                                                                                                                                                                                                                             AS AvgStartingTempDataSizeMB,
       (SELECT Avg(growth * 8 / 1024)
        FROM   sys.master_files
        WHERE  database_id = 2
               AND type = 0)                                                                                                                                                                                                                                             AS AvgCurrentTempDataSizeMB,
       Isnull(Round(CONVERT(DECIMAL(18, 2), vs.total_bytes / 1073741824.0), 0), '0')                                                                                                                                                                                     AS [Total Size (GB)],
       CASE
         WHEN Cast(@CORES AS NVARCHAR(100)) > Cast(@FILECOUNT AS NVARCHAR(100)) THEN 'Server ' + I.SQlServername + ' needs '
                                                                                     + Cast(@CORES AS NVARCHAR(100))
                                                                                     + ' TempDB data files, now there is '
                                                                                     + Cast(@FILECOUNT AS NVARCHAR(100))
                                                                                     + Char(10) + Char(13)
         ELSE 'No datafile growth needed'
       END                                                                                                                                                                                                                                                               [Data File Needed],
       Isnull(Round(( CONVERT(DECIMAL(18, 2), vs.total_bytes / 1073741824.0) - CONVERT(DECIMAL(18, 2), ( vs.total_bytes / 1073741824.0 ) * @Percentage) - CONVERT(DECIMAL(18, 2), @LogFile) ), 0), '0')                                                                  [Usable space for drive  (GB)],
       Isnull(Round(CONVERT(DECIMAL(18, 2), ( ( CONVERT(DECIMAL(18, 2), vs.total_bytes / 1073741824.0) - CONVERT(DECIMAL(18, 2), ( vs.total_bytes / 1073741824.0 ) * @Percentage) - CONVERT(DECIMAL(18, 2), @LogFile) ) / Cast(@CORES AS DECIMAL(18, 2)) ), 0), 0), '0') [Amount per datafile  (GB)],
       CASE
         WHEN ServerLocation = 'AWS-EC2'
              AND ServerEnvironment NOT IN ( 'PRD', 'PROD', 'ADMIN', 'ADM' ) THEN @LogFile + ' GB'
         WHEN ServerLocation = 'AWS-EC2'
              AND ServerEnvironment IN ( 'PRD', 'PROD', 'ADMIN', 'ADM' ) THEN @LogFile + ' GB'
         WHEN ServerLocation = 'AWS-RDS' THEN 'N/A'
         WHEN ServerLocation = '' THEN @LogFile + ' GB'
         ELSE 'Research'
       END                                                                                                                                                                                                                                                               [Log File  (GB)]
--SELECT *
FROM   sys.master_files AS m
       JOIN tempdb.sys.database_files AS d
         ON m.file_id = d.file_id
       CROSS APPLY sys.Dm_os_volume_stats(m.database_id, m.[file_id]) AS vs
       OUTER APPLY DBA.INFO.INSTANCE i
WHERE  Db_name(m.database_id) = 'tempdb'
       AND m.type_desc = 'LOG'
       AND ( ( d.size * 8 ) / 1024 ) <= ( @LogFile * 1024 )
       AND ServerLocation = @ServerLocation

IF @CORES > @FILECOUNT
  BEGIN
      WHILE @CORES > @FILECOUNT
        BEGIN
            SET @SQL_SCRIPT = N'ALTER DATABASE tempdb
                ADD FILE (
                               FILENAME = '''
                              + @BASEPATH + 'tempdb'
                              + Rtrim(Cast(@CORES AS NCHAR))
                              + '.ndf'',
                               NAME = tempdev'
                              + Rtrim(Cast(@CORES AS NCHAR))
                              + ',
                               SIZE = '
                              + Rtrim(Cast(@SIZE AS NCHAR))  ---need to populate the amount from query above
                              + 'MB,
                               FILEGROWTH = '
                              + Rtrim(Cast(@GROWTH AS NCHAR))

            IF @ISPERCENT = 1
              SET @SQL_SCRIPT = @SQL_SCRIPT + '%'
            ELSE
              SET @SQL_SCRIPT = @SQL_SCRIPT + 'KB'

            SET @SQL_SCRIPT = @SQL_SCRIPT + ')'
            SET @CORES = @CORES - 1

            IF @DryRun = 0
              BEGIN
                  EXEC (@SQL_SCRIPT)
              END
            ELSE
              BEGIN
                  PRINT ( @SQL_SCRIPT )
/*


	      PRINT 'InstanceName: ' + @InstanceName;
    PRINT 'InstanceLocation: ' + @InstanceLocation;
    PRINT 'InstanceEnvironment: ' + @InstanceEnvironment;
    PRINT 'CurrentLogFileSizeMB: ' + @CurrentLogFileSizeMB;
    PRINT 'StartingLogFileSizeMB: ' + @StartingLogFileSizeMB;
    PRINT 'AvgStartingTempDataSizeMB: ' + @AvgStartingTempDataSizeMB;
    PRINT 'AvgCurrentTempDataSizeMB: ' + @AvgCurrentTempDataSizeMB;
    PRINT 'Total Size (GB): ' + @TotalSizeGB;
    PRINT 'Usable space for drive (GB): ' + @UsableSpaceGB;
    PRINT 'Amount per datafile (GB): ' + @AmountPerDataFileGB;
    PRINT 'Data File Needed: ' + @DataFileNeeded;
    PRINT 'LogFile Allocation: ' + @LogFileAllocation;

	*/

			
              END
        END
  END 
