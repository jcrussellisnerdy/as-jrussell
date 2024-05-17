set-location C:\Downloads\Datafiles

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\Prod.txt"
$outputfile="\logs\sql_server_db_sizes_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile


$filePath = ""

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
DECLARE @SQLcmd varchar(MAX)
DECLARE @size varchar(2) = '5'

select @SQLcmd ='
USE [?]
SELECT 


		 @@servername as ServerName
		 ,[Database_Name] = name
		,[TYPE] = A.TYPE_DESC
		,[AutoGrow] = ''By '' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + '' MB -'' 
			WHEN 1 THEN CAST(growth AS VARCHAR(10)) + ''% -'' ELSE '''' END 
			+ CASE max_size WHEN 0 THEN ''DISABLED'' WHEN -1 THEN '' Unrestricted'' 
				ELSE '' Restricted to '' + CAST(max_size/(128*1024) AS VARCHAR(10)) + '' GB'' END 
			+ CASE is_percent_growth WHEN 1 THEN '' [autogrowth by percent, BAD setting!]'' ELSE '''' END
		, [CurrentSizeMB ] =  size/128.0
		,[FreeSpaceMB] =  size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0
	, [Remaining Data File %] = convert(decimal(12,2),CAST(max_size/(128*1024) AS INT)*100 / convert(decimal(12,2),round(size/128.000,2)) * 100)
	, [Free Space %] =CONVERT(INT, CONVERT(DECIMAL (10,2), size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)  / (CONVERT(DECIMAL(10,2),SIZE/128.0))*100)	
	FROM sys.database_files A 
	WHERE max_size != ''-1''
	AND convert(decimal(12,2),CAST(max_size/(128*1024) AS INT)*100 / convert(decimal(12,2),round(size/128.000,2)) * 100) ='''+ @size + '''
		order by CONVERT(INT, CONVERT(DECIMAL (10,2), size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)  / (CONVERT(DECIMAL(10,2),SIZE/128.0))*100)'



		IF OBJECT_ID(N'tempdb..#DatafileSize') IS NOT NULL
DROP TABLE #DatafileSize

CREATE TABLE #DatafileSize ([ServerName] nvarchar(100), [Database_Name] varchar(250),[TYPE] nvarchar(10),  [AutoGrow] nvarchar(max),[Space MB ] nvarchar(1000), [FreeSpaceMB] nvarchar(1000)  ,[Remaining Data File %] INT,[Free Space %] INT);

INSERT INTO #DatafileSize
exec sp_MSforeachdb @SQLcmd

SELECT * FROM #DatafileSize
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Database Sizes" | Set-Content $outputfilefull  

$filepath = $outputfilefull  



set-location C:\Downloads\Datafiles

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath= 'C:\Downloads\Datafiles'


$instancepath=$basepath + "\NonProd.txt"
$outputfile="\logs\sql_server_db_sizes_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile


$filePath = ""

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
DECLARE @SQLcmd varchar(MAX)
DECLARE @size varchar(2) = '5'

select @SQLcmd ='
USE [?]
SELECT 


		 @@servername as ServerName
		 ,[Database_Name] = name
		,[TYPE] = A.TYPE_DESC
		,[AutoGrow] = ''By '' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + '' MB -'' 
			WHEN 1 THEN CAST(growth AS VARCHAR(10)) + ''% -'' ELSE '''' END 
			+ CASE max_size WHEN 0 THEN ''DISABLED'' WHEN -1 THEN '' Unrestricted'' 
				ELSE '' Restricted to '' + CAST(max_size/(128*1024) AS VARCHAR(10)) + '' GB'' END 
			+ CASE is_percent_growth WHEN 1 THEN '' [autogrowth by percent, BAD setting!]'' ELSE '''' END
		, [CurrentSizeMB ] =  size/128.0
		,[FreeSpaceMB] =  size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0
	, [Remaining Data File %] = convert(decimal(12,2),CAST(max_size/(128*1024) AS INT)*100 / convert(decimal(12,2),round(size/128.000,2)) * 100)
	, [Free Space %] =CONVERT(INT, CONVERT(DECIMAL (10,2), size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)  / (CONVERT(DECIMAL(10,2),SIZE/128.0))*100)	
	FROM sys.database_files A 
	WHERE max_size != ''-1''
	AND convert(decimal(12,2),CAST(max_size/(128*1024) AS INT)*100 / convert(decimal(12,2),round(size/128.000,2)) * 100) ='''+ @size + '''
		order by CONVERT(INT, CONVERT(DECIMAL (10,2), size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0)  / (CONVERT(DECIMAL(10,2),SIZE/128.0))*100)'



		IF OBJECT_ID(N'tempdb..#DatafileSize') IS NOT NULL
DROP TABLE #DatafileSize

CREATE TABLE #DatafileSize ([ServerName] nvarchar(100), [Database_Name] varchar(250),[TYPE] nvarchar(10),  [AutoGrow] nvarchar(max),[Space MB ] nvarchar(1000), [FreeSpaceMB] nvarchar(1000)  ,[Remaining Data File %] INT,[Free Space %] INT);

INSERT INTO #DatafileSize
exec sp_MSforeachdb @SQLcmd

SELECT * FROM #DatafileSize
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Database Sizes" | Set-Content $outputfilefull  

$filepath = $outputfilefull  



nslookup solarwinds.alliedsolutions.net