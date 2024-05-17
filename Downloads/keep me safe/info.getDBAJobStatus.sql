USE DBA
GO
/****** Object:  StoredProcedure [info].[getDBAJobStatus] @dryRun = 0   Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[getDBAJobStatus]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getDBAJobStatus] AS RETURN 0;';
END
GO

ALTER procedure info.getDBAJobStatus
as
begin
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT dj.JobPrefix as [jobName],
			CASE WHEN SJ.enabled = 1 THEN 'Exists and enabled'
			  WHEN SJ.enabled = 0 AND DJ.isRequired = 0 THEN '[WARNING] Exists but disabled'
			  WHEN SJ.enabled = 0 AND DJ.isRequired = 1 THEN '[ALERT] Exists but disabled'
			  WHEN isnull(SJ.enabled,'') = '' AND DJ.isRequired = 0 THEN '[WARNING] Missing'
			  WHEN isnull(SJ.enabled,'') = '' AND DJ.isRequired = 1 THEN '[ALERT] Missing'
			end as [JobStatus],
		SS.name as ScheduleName, 
			CASE WHEN ss.name = SJ.Name +'_Schedule' THEN SS.name
				ELSE 'Non standard Name'
			END as ScheduleNameStatus,
			CASE WHEN SS.enabled = 1 THEN 'Exists and enabled'
			  WHEN SS.enabled = 0 AND DJ.isRequired = 0 THEN '[WARNING] Exists but disabled'
			  WHEN SS.enabled = 0 AND DJ.isRequired = 1 THEN '[ALERT] Exists but disabled'
			  WHEN isnull(SS.enabled,'') = '' AND DJ.isRequired = 0 THEN '[WARNING] Missing'
			  WHEN isnull(SS.enabled,'') = '' AND DJ.isRequired = 1 THEN '[ALERT] Missing'
			end AS [ScheduleStatus]
FROM [DBA].[info].[DBAJobs] as DJ 
  LEFT JOIN msdb..sysjobs as SJ ON (dj.JobPrefix = SJ.name)
  LEFT JOIN msdb..sysjobschedules AS SJS ON ( SJ.job_id = SJS.job_id )
  LEFT JOIN MSDB..sysschedules AS SS ON ( SS.schedule_id = SJS.schedule_id )
ORDER BY dj.JobPrefix

END;