USE [Unitrac]


DECLARE @db_id SMALLINT= Db_id((SELECT Db_name()));;
DECLARE @object_id INT = Object_id(N'dbo.INTERACTION_HISTORY');
DECLARE @index_name VARCHAR(100)= ''
DECLARE @MIN INT ='5';
DECLARE @MAX INT = '35';
DECLARE @mode VARCHAR(10) ='LIMITED';--modes are (LIMITED/SAMPLED/DETAILED)


IF @object_id IS NULL
  BEGIN
      PRINT N'Invalid object';
  END
ELSE
  BEGIN
      SELECT Object_name(IPS.object_id) AS [TableName],
             SI.name                    AS [IndexName],
             IPS.Index_type_desc,
             IPS.avg_fragmentation_in_percent,
                 ISNULL(IPS.fragment_count,0) AS fragment_count, 
            ISNULL(IPS.avg_fragment_size_in_pages,0) AS avg_fragment_size_in_pages, 
             CASE
               WHEN IPS.Index_type_desc IN ('NONCLUSTERED INDEX', 'CLUSTERED INDEX')
                    AND IPS.avg_fragmentation_in_percent BETWEEN @MIN AND @MAX THEN Concat('BEGIN TRY   ALTER INDEX [', SI.name, '] ON [', Object_name(IPS.object_id), '] REORGANIZE 	  END TRY  
    BEGIN CATCH  PRINT ''WARNING:  [', SI.name, '] ON [', Object_name(IPS.object_id), '] was not added either not in the correct database or index itself failed.'' RETURN  END CATCH  ')
               WHEN IPS.Index_type_desc IN ('NONCLUSTERED INDEX', 'CLUSTERED INDEX')
                    AND IPS.avg_fragmentation_in_percent > @MAX THEN Concat('BEGIN TRY ALTER INDEX [', SI.name, '] ON [', Object_name(IPS.object_id), '] REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = ON, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  END TRY  
    BEGIN CATCH  PRINT ''WARNING:  [', SI.name, '] ON [', Object_name(IPS.object_id), '] was not added either not in the correct database or index itself failed.'' RETURN  END CATCH  ')
        
		WHEN IPS.Index_type_desc = 'HEAP' THEN Concat('CANNOT REORGANIZE HEAPS on ', Object_name(IPS.object_id), '!!!')
                           ELSE Concat('[', si.NAME, '] DOES NOT CURRENTLY NEED TO BE REORGANIZED!!!')
             END AS [Script to use], 
			  CASE
			 WHEN IPS.Index_type_desc = 'CLUSTERED INDEX' AND IPS.avg_fragmentation_in_percent >= @MIN THEN Concat('DO WE REALLY NEED TO REORG A CLUSTERED INDEX ON ', Object_name(IPS.object_id),'---' ,'ALTER INDEX [', SI.name, '] ON [',Object_name(IPS.object_id), '] REORGANIZE')
			 WHEN IPS.Index_type_desc = 'HEAP' THEN Concat('CANNOT REORGANIZE HEAPS on ', Object_name(IPS.object_id), '!!!')
			 ELSE 
			 CASE WHEN IPS.avg_fragmentation_in_percent >= @MIN  THEN 
			 'Good Luck with your rebuild or REORG on '+ Object_name(IPS.object_id)+'' 	
			 ELSE Concat('[', si.NAME, '] DOES NOT CURRENTLY NEED TO BE REORGANIZED!!!')
				END	 END AS [Suggestion]
      FROM   sys.Dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL, @mode) AS IPS
             JOIN sys.tables ST WITH (nolock)
               ON IPS.object_id = ST.object_id
             JOIN sys.indexes SI WITH (nolock)
               ON IPS.object_id = SI.object_id
                  AND IPS.index_id = SI.index_id
      WHERE  ST.is_ms_shipped = 0
	  AND SI.name LIKE '%'+ @index_name +'%'
      ORDER  BY 1,
                5
  END

GO 
