SELECT 'Customer Usage', [ServerName]         =@@SERVERNAME,
       DatabaseName         = Db_name(r.database_id),
       r.session_id,
       r.start_time,
       TotalElapsedTime_min = r.total_elapsed_time / 1000 / 60,
       r.[status],
       r.command, wait_type, t.[text]--, p.query_plan
FROM   sys.dm_exec_requests r
       CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS t
       CROSS APPLY sys.Dm_exec_query_plan(r.plan_handle) AS p
	   WHERE Db_name(r.database_id) IN (select DatabaseName from DBA.info.[database] where DatabaseType = 'User')
UNION
SELECT 'System Usage',[ServerName]         =@@SERVERNAME,
       DatabaseName         = Db_name(r.database_id),
       r.session_id,
       r.start_time,
       TotalElapsedTime_min = r.total_elapsed_time / 1000 / 60,
       r.[status],
       r.command, wait_type, t.[text]--, p.query_plan
FROM   sys.dm_exec_requests r
       CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS t
       CROSS APPLY sys.Dm_exec_query_plan(r.plan_handle) AS p
	   WHERE Db_name(r.database_id) IN (select DatabaseName from DBA.info.[database] where DatabaseType != 'User')