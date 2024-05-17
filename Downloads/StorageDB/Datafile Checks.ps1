set-location C:\Downloads\StorageDB

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\Prod.txt"
$outputfile="\logs\StorageDB_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile


$filePath = ""

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
    TRY {
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=master;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "


DECLARE @retVal int

SELECT @retVal = COUNT(*)
FROM SYS.DATABASES
where name = 'HDTStorage'


IF (@retVal =0)
BEGIN
CREATE TABLE #TMP ([Information] nvarchar(255))
INSERT INTO #TMP
SELECT @@SERVERNAME + ' needs to have HDTStorage added to it'  
END
ELSE	
BEGIN 
	PRINT 'DO NOTHING'
END

SELECT * FROM #TMP
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
    } 
    CATCH{ Write-Host 'We do not want this'}
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors,  Table, ItemArray| ConvertTo-Html -head $reportstyle -body "SQL Server Storage Databases" | Set-Content $outputfilefull  

$filepath = $outputfilefull  


