use tempdb 

DECLARE @BASEPATH NVARCHAR(300)
DECLARE @CORES INT
DECLARE @FILECOUNT INT
DECLARE @SIZE INT
DECLARE @GROWTH INT
DECLARE @ISPERCENT INT
DECLARE @LogFile NVARCHAR(10) 
DECLARE @Percentage DECIMAL(5,2) = 0.20;
DECLARE @ServerLocation NVARCHAR(10) = 'AWS-EC2'

SELECT @LogFile = CASE WHEN ServerLocation = @ServerLocation AND ServerEnvironment NOT IN ('PRD','PROD', 'ADMIN' ,'ADM') THEN '1' 
WHEN ServerLocation = @ServerLocation AND ServerEnvironment  IN ('PRD','PROD', 'ADMIN' ,'ADM') THEN '10' 
ELSE 0 END
from dba.info.Instance


-- TempDB mdf count equal logical cpu count
SELECT @CORES = cpu_count FROM sys.dm_os_sys_info
  
IF @CORES BETWEEN 9 AND 31 SET @CORES = @CORES / 2
IF @CORES >= 32 SET @CORES = @CORES / 4
 
--Check and set tempdb files count are multiples of 4
IF @CORES > 8 SET @CORES = @CORES - (@CORES % 4)
 
SET @BASEPATH = (
    SELECT CASE 
        WHEN CHARINDEX(N'tempdb.mdf', LOWER(physical_name)) > 0 
        THEN SUBSTRING(physical_name, 1, CHARINDEX(N'tempdb.mdf', LOWER(physical_name)) - 1) 
        ELSE physical_name 
    END 
    FROM master.sys.master_files
    WHERE database_id = 2 AND FILE_ID = 1
);

SET @FILECOUNT = (SELECT COUNT(*)
FROM master.sys.master_files
WHERE database_id = 2 AND TYPE_DESC = N'ROWS')
 
SELECT @SIZE = size FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SET @SIZE = @SIZE / 128
 
SELECT @GROWTH = growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SELECT @ISPERCENT = is_percent_growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
 
IF @ISPERCENT = 0 SET @GROWTH = @GROWTH * 8
 

SELECT 
    (m.size * 8) / 1024 AS [Starting size (MB)],
    (d.size * 8) / 1024 AS [Current size (MB)], 
	I.SQlServername,
	ServerLocation,
	ServerEnvironment, 
	CASE WHEN CAST(@CORES AS NVARCHAR(100)) > CAST(@FILECOUNT AS NVARCHAR(100)) THEN 
	'Server '+ I.SQlServername +' needs ' + CAST(@CORES AS NVARCHAR(100)) + ' TempDB data files, now there is ' + CAST(@FILECOUNT AS NVARCHAR(100)) + CHAR(10) + CHAR(13)
	ELSE 'No datafile growth needed' END
	[Data File Needed],
ROUND(CONVERT(DECIMAL(18,2), vs.total_bytes/1073741824.0),0) AS [Total Size (GB)],
ROUND(
    (CONVERT(DECIMAL(18,2), vs.total_bytes / 1073741824.0)  
     - CONVERT(DECIMAL(18,2), (vs.total_bytes / 1073741824.0) * @Percentage) 
     - CONVERT(DECIMAL(18,2), @LogFile)
    ), 0) [Usable space for drive],

ROUND(
    CONVERT(DECIMAL(18,2), 
        ( 
            (CONVERT(DECIMAL(18,2), vs.total_bytes / 1073741824.0)  
             - CONVERT(DECIMAL(18,2), (vs.total_bytes / 1073741824.0) * @Percentage) 
             - CONVERT(DECIMAL(18,2), @LogFile)
            ) 
        / CAST(@CORES AS DECIMAL(18,2))  
    ), 0),0) 
[Amount per datafile]
,CASE WHEN ServerLocation = 'AWS-EC2' AND ServerEnvironment NOT IN ('PRD','PROD', 'ADMIN' ,'ADM') THEN @LogFile+' GB' 
WHEN ServerLocation = 'AWS-EC2' AND ServerEnvironment  IN ('PRD','PROD', 'ADMIN' ,'ADM') THEN @LogFile+' GB'
WHEN ServerLocation = 'AWS-RDS' THEN 'N/A'
ELSE 'Research'
END [Log File]

FROM sys.master_files AS m
JOIN tempdb.sys.database_files AS d ON m.file_id = d.file_id
CROSS APPLY sys.dm_os_volume_stats(m.database_id, m.[file_id]) AS vs 
cross join DBA.INFO.INSTANCE i
WHERE DB_NAME(m.database_id) = 'tempdb'
AND  m.type_desc = 'LOG'
AND  (  (d.size * 8) / 1024 ) <= (@LogFile * 1024)
AND ServerLocation = @ServerLocation

