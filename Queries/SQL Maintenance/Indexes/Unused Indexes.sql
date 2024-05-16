DECLARE @DatabaseName VARCHAR(100) ='',
        @TableName    VARCHAR(255) ='',
        @sqlcmd       VARCHAR(max),
        @DryRun       INT = 0

SELECT @sqlcmd = ' USE [' + @DatabaseName
                 + ']
				
DECLARE @now DATETIME
SET @now = GETDATE()

SELECT top 20
''$(ClientName)'', @@ServerName,
DB_NAME(),
o.name AS ObjectName
, i.name AS IndexName
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, ''DROP INDEX '' + QUOTENAME(i.name)
+ '' ON '' + QUOTENAME(s.name) + ''.'' + QUOTENAME(OBJECT_NAME(dm_ius.object_id)) as ''drop statement''
, @now
FROM sys.dm_db_index_usage_stats dm_ius
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.object_id = i.object_id
INNER JOIN sys.objects o on dm_ius.object_id = o.object_id
INNER JOIN sys.schemas s on o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.object_id
FROM sys.partitions p GROUP BY p.index_id, p.object_id) p
ON p.index_id = dm_ius.index_id AND dm_ius.object_id = p.object_id
WHERE OBJECTPROPERTY(dm_ius.object_id,''IsUserTable'') = 1
AND dm_ius.database_id = DB_ID()
AND i.type_desc = ''nonclustered''
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
AND dm_ius.user_seeks = 0
AND dm_ius.user_scans = 0
AND dm_ius.user_lookups = 0
AND o.name NOT LIKE ''MS%''
--AND o.name IN ('''                 + @TableName + ''')
ORDER BY p.TableRows DESC
'

IF @DatabaseName  ='?'
BEGIN 
IF @DryRun = 0
  BEGIN
  
		exec sp_MSforeachdb @sqlcmd 
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
      PRINT ( @SQLcmd + '
	  
	  exec @sqlcmd')
  END

  END