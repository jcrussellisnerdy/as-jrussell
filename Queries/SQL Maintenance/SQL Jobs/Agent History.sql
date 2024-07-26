USE msdb;
GO

SELECT 
  j.name AS Job_Name,
  jh.run_date AS Run_Date,
  jh.run_time AS Run_Time,
  jh.step_name AS Step_Name,
  jh.message AS Message,
  CASE jh.step_id 
    WHEN -1 THEN 'Job Level'  -- Job level message
    ELSE 'Step Level' 
  END AS Message_Level,
  CASE jh.run_status
    WHEN 0 THEN 'Failed'
    WHEN 1 THEN 'Succeeded'
    WHEN 2 THEN 'Retry - step only'
    WHEN 3 THEN 'Cancelled'
    WHEN 4 THEN 'In Progress'
    ELSE 'Unknown'
  END AS Run_Status
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
where jh.run_status not in  (1,2,3,4) 
and run_date >= '20240625' 
and   jh.step_name <> '(Job outcome)'
AND   j.name NOT LIKE 'dba%'
AND   j.name NOT LIKE 'pERFMON%'
AND   j.name NOT LIKE 'OLA%'
AND   j.name NOT LIKE 'HDTStorag%'
ORDER BY j.name, jh.run_date DESC;
GO
