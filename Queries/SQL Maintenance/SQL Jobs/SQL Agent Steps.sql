USE msdb;
GO

SELECT 
  j.name AS Job_Name,
  s.step_name AS Step_Name,
  s.step_id,
  CASE s.subsystem  -- Identify step type (optional)
    WHEN N'SQL' THEN 'T-SQL Script'
    WHEN N'CmdExec' THEN 'Operating System Command'
    ELSE s.subsystem
  END AS Step_Type,
  s.command AS Step_Command
FROM msdb.dbo.sysjobs j
INNER JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
where j.name = 'DBA-BackupDatabases-LOG'
ORDER BY j.name, s.step_id;
GO
