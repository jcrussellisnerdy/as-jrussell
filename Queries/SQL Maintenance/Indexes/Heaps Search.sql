

 declare @cmd3 varchar(max)



 set @cmd3 ='USE ?   SELECT DB_NAME(),  TBL.name AS TableName,
 user_seeks, user_scans, user_lookups,  IDX.type_desc,
 SUM(sPTN.Rows) AS [RowCount]
  from sys.indexes IDX
  INNER JOIN sys.tables AS TBL ON TBL.object_id = IDX.object_id 
  INNER JOIN sys.schemas AS SCH ON TBL.schema_id = SCH.schema_id 
  INNER JOIN sys.dm_db_index_usage_stats ST on OBJECT_NAME(st.object_id) =tbl.name
  INNER JOIN sys.partitions AS sPTN     ON tbl.object_id = sPTN.object_id
  WHERE IDX.index_id = 0 AND
  user_seeks <> ''0''OR user_scans <> ''0''OR user_lookups  <> ''0''
GROUP BY 
      TBL.name,user_seeks, user_scans, user_lookups,  IDX.type_desc
'


IF Object_id(N'tempdb..#HEAPs') IS NOT NULL
  DROP TABLE #HEAPs
CREATE TABLE #HEAPs (DatabaseName nvarchar(100), TableName nvarchar(max)
, user_seeks INT, user_scans INT, user_lookups INT, IndexType nvarchar(max)
, Row_Counts nvarchar(max))

INSERT INTO #HEAPs
  exec sp_MSforeachdb @cmd3

  select * from #HEAPs
  where DatabaseName not in ('Perfstats', 'DBA', 'master', 'tempdb', 'msdb','HDTStorage')
  AND DatabaseName not  like '%HDStorage'
   and IndexType = 'HEAP' 
   order by user_seeks desc


