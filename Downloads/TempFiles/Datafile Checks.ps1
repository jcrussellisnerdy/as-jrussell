set-location C:\Downloads\TempFiles

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\Prod.txt"
$outputfile="\logs\tempfiles_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile


$filePath = ""

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=master;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "

DECLARE @check BIT
 
SET @check = 0 --For information set 0, for change 1
 
DECLARE @BASEPATH NVARCHAR(300)
DECLARE @SQL_SCRIPT NVARCHAR(1000)
DECLARE @CORES INT
DECLARE @FILECOUNT INT
DECLARE @SIZE INT
DECLARE @GROWTH INT
DECLARE @ISPERCENT INT
 
-- TempDB mdf count equal logical cpu count
SELECT @CORES = cpu_count FROM sys.dm_os_sys_info
 
--PRINT 'Logical CPU count ' + CAST(@CORES AS NVARCHAR(100))
 
IF @CORES BETWEEN 9 AND 31 SET @CORES = @CORES / 2
IF @CORES >= 32 SET @CORES = @CORES / 4
 
--Check and set tempdb files count are multiples of 4
IF @CORES > 8 SET @CORES = @CORES - (@CORES % 4)
 
SET @BASEPATH = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'tempdb.mdf', LOWER(physical_name)) - 1) DataFileLocation
FROM master.sys.master_files
WHERE database_id = 2 AND FILE_ID = 1)
 
SET @FILECOUNT = (SELECT COUNT(*)
FROM master.sys.master_files
WHERE database_id = 2 AND TYPE_DESC = N'ROWS')
 
SELECT @SIZE = size FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SET @SIZE = @SIZE / 128
 
SELECT @GROWTH = growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
SELECT @ISPERCENT = is_percent_growth FROM master.sys.master_files WHERE database_id = 2 AND FILE_ID = 1
 
IF @ISPERCENT = 0 SET @GROWTH = @GROWTH * 8
 
IF  @CORES > @FILECOUNT
BEGIN
--Current situation
CREATE TABLE #TMP ([LINE] nvarchar(max))

INSERT INTO #TMP
SElect 'Needed ' + CAST(@CORES AS NVARCHAR(100)) + ' TempDB data files, now there is ' + CAST(@FILECOUNT AS NVARCHAR(100)) + CHAR(10) + CHAR(13)
 
SELECT @@SERVERNAME [Server], * FROM #TMP
END 
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray| ConvertTo-Html -head $reportstyle -body "SQL Server Database Sizes" | Set-Content $outputfilefull  

$filepath = $outputfilefull  


