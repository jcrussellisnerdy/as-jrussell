USE DBA
GO
/****** Object:  StoredProcedure [info].[getObjectUsage]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[GetDatabaseUsage]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetDatabaseUsage] AS RETURN 0;';
END
GO

ALTER PROCEDURE info.GetDatabaseUsage ( @TargetDB varchar(100) = 'TempDB', @dryRun int = 1 )
AS
BEGIN
	-- EXEC [info].[getDatabaseUsage] @TargetDB = 'DBA'
	-- EXEC [info].[getDatabaseUsage] @DryRun = 0

    -- This might be a bad name for this stored procedure.  DatabaseUsage might indicate table sizes and stuff..
    SELECT tst.[session_id],
        s.[login_name] AS [Login Name],
        DB_NAME (tdt.database_id) AS [Database],
        tdt.[database_transaction_begin_time] AS [Begin Time],
        tdt.[database_transaction_log_record_count] AS [Log Records],
        tdt.[database_transaction_log_bytes_used] AS [Log Bytes Used],
        tdt.[database_transaction_log_bytes_reserved] AS [Log Bytes Rsvd],
        SUBSTRING(st.text, (r.statement_start_offset/2)+1,
        ((CASE r.statement_end_offset
                WHEN -1 THEN DATALENGTH(st.text)
                ELSE r.statement_end_offset
        END - r.statement_start_offset)/2) + 1) AS statement_text,
        st.[text] AS [Last T-SQL Text],
        qp.[query_plan] AS [Last Plan]
    FROM    sys.dm_tran_database_transactions tdt
            JOIN sys.dm_tran_session_transactions tst
                ON tst.[transaction_id] = tdt.[transaction_id]
            JOIN sys.[dm_exec_sessions] s
                ON s.[session_id] = tst.[session_id]
            JOIN sys.dm_exec_connections c
                ON c.[session_id] = tst.[session_id]
            LEFT OUTER JOIN sys.dm_exec_requests r
                ON r.[session_id] = tst.[session_id]
            CROSS APPLY sys.dm_exec_sql_text (c.[most_recent_sql_handle]) AS st
            OUTER APPLY sys.dm_exec_query_plan (r.[plan_handle]) AS qp
    WHERE   DB_NAME (tdt.database_id) = @TargetDB
    ORDER BY [Log Bytes Used] DESC

END;
