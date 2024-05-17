USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[GetBackupStatus]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetBackupStatus] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[GetBackupStatus] ( @TargetDB varchar(100) = 'DBA', @BackupType varchar(100) = 'FULL', @DryRun TINYINT = 1 )
AS
BEGIN
--  EXEC [info].[GetBackupStatus] @dryRun = 0
	DECLARE @HostName varchar(255)
	DECLARE @sql varchar(4000)
	--by default it will take the current server name, we can the set the server name as well
	-- Need to swap this to an if contains take the left of charIndex('\') and then use @HostName
	Select @HostName = convert(varchar(255), SERVERPROPERTY('MachineName') )


	SELECT getdate() as [Current Time], r.session_id as SPID, CONVERT(NUMERIC(6,2),r.percent_complete) AS [Percent Complete],
		CONVERT(VARCHAR(20),DATEADD(ms,r.estimated_completion_time,GetDate()),20) AS [ETA Completion Time],
		CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0) AS [ETA Min],
		CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0/60.0) AS [ETA Hours],
		CONVERT(VARCHAR(1000),(SELECT SUBSTRING(text,r.statement_start_offset/2,	
								CASE WHEN r.statement_end_offset = -1 THEN 1000 
								ELSE (r.statement_end_offset-r.statement_start_offset)/2 END) 
						FROM sys.dm_exec_sql_text(sql_handle)
						)
				) as [sqltxt], command
	FROM sys.dm_exec_requests r  
	WHERE command IN (@BackupType) 

	/*
		Incomplete work.  This should be able to receive all the same parameters as the backupDatabase stored procedure.
	*/
END;