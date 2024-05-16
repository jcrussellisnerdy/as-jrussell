DECLARE @DatabaseName VARCHAR(100) ='UnitracArchive',
        @TableName    VARCHAR(255) ='PROPERTY_CHANGE_UPDATE',
        @sqlcmd       VARCHAR(max),
        @DryRun       INT = 0

SELECT @sqlcmd = '
use [' + @DatabaseName + ']

SELECT
	DB_NAME() AS DatabaseName,
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
	    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    SUM(a.total_pages) * 8 / 1024 / 1024. AS TotalSpaceGB, 
    SUM(a.used_pages) * 8 / 1024 / 1024. AS UsedSpaceGB, 
    (SUM(a.total_pages) - SUM(a.used_pages))* 8 / 1024 / 1024.  AS UnusedSpaceGB,
	CONCAT(''select TOP 5 * from [''+DB_NAME()+''].[dbo].['',t.NAME,'']'') AS [Example Query]
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE ''dt%'' 
	AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
	AND t.[name] like ''%'
                 + @TableName
                 + '%''

		--		 	AND t.[name] ='''
                 + @TableName+'''
                
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
     SUM(a.used_pages) * 8 / 1024 / 1024. DESC'



  
IF @DatabaseName  ='?'
BEGIN 
IF @DryRun = 0
  BEGIN
  
		  IF Object_id(N'tempdb..#TableFileSize') IS NOT NULL
              DROP TABLE #TableFileSize

            CREATE TABLE #TableFileSize
              (
                 [DatabaseName]  VARCHAR(100),
                 [TableName]     VARCHAR(100),
                 [SchemaName]    VARCHAR(100),
                 [RowCounts]     BIGINT,
                 [TotalSpaceKB]  INT,
                 [UsedSpaceKB] INT,
                 [UnusedSpaceKB]INT,
                 [TotalSpaceGB]  NVARCHAR(100),
                 [UsedSpaceGB]   NVARCHAR(100),
                 [UnusedSpaceGB] NVARCHAR(100),
                 [Example Query] VARCHAR(1000)
              );

            INSERT INTO #TableFileSize
            EXEC Sp_msforeachdb
              @SQLcmd

            SELECT *
            FROM   #TableFileSize
			ORDER BY     [TotalSpaceKB] DESC
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd + '
	  
	  exec sp_MSforeachdb @sqlcmd' )
  END
  END 
  ELSE 
  BEGIN 
IF @DryRun = 0
  BEGIN
      EXEC ( @SQLcmd)
		
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd + 'in
	  
	  exec @sqlcmd')
  END

  END


