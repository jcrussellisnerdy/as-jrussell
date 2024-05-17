USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CheckpointTempdb]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[CheckpointTempdb] AS RETURN 0;' 
END
GO
ALTER PROCEDURE [dbo].[CheckpointTempdb] (@to varchar(256) = 'hbrotherton@AlliedSolutions.net', @maxPct float = 30)
AS

SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

   -- DECLARE @to varchar(256) = 'hbrotherton@AlliedSolutions.net', @maxPct float = 30
   DECLARE @msg    varchar(150)
   DECLARE @subject varchar(256)
   DECLARE @body varchar(max), @string varchar(max), @starttime datetime, @endTime datetime

	declare @priorPct float, @afterPct float 

   select @body = ''
	
	CREATE TABLE #LogSpace (DBName sysname, LogSize float, SpaceUsed float, Status int) ;
	
	INSERT INTO #LogSpace(DBName, LogSize, SpaceUsed, Status)
	EXEC ('dbcc sqlperf(logspace)')  
	
	select @priorPct = spaceUsed from #logspace where dbName = 'tempdb'
	
-- ==============================================================
-- Check for logsize Exceeded;
-- ===============================================================	


if @priorPct <= @maxpct
	return

	select @startTime = getdate()
	
	begin try
		exec ('use tempdb	checkpoint')
	end try
	begin catch
		print ''
	end catch
	
	select @endtime = getdate()
	
	truncate table #logSpace
	
	INSERT INTO #LogSpace(DBName, LogSize, SpaceUsed, Status)
	EXEC ('dbcc sqlperf(logspace)')  
	
	select @afterPct = spaceUsed from #logspace where dbName = 'tempdb'
	----------insert DBA.dbo.CheckPointTempDBLog (checkPointDate, priorPercent, afterPercent, runMinutes)
	----------select getdate(), @priorPct, @afterPct,datediff(mi, @startTime, @endtime)


select @body = 'Tempdb log space used before checkpoint:  '+cast(cast(@priorPct as int) as char(3)) + '%.'+char(13)+
'Tempdb log space used after  checkpoint:  '+cast(cast(@afterPct  as int) as char(3)) + '%.'+char(13)+
'Checkpoint time in minutes: '+cast(datediff(mi, @startTime, @endtime) as char(5))

IF @body <> ''
	BEGIN    
	     SET @subject = 'ALERT - TempDB Checkpoint executed -- '+ DBA.info.getConfig('Instance.description','')

	  ------------   if @to is null or @to = ''
			------------select @To = DBA.dbo.getSystemConfig('Email.Notification','dbinformation@exacttarget.com')

/*
         EXEC  master.dbo.sp_SEND_SMTPMail
                 @sTo = @To,
                 @sSubject = @subject,
                 @sBody = @body, 
				 @sRunSQL 	= 'exec DBA.dba.allOpenTransInfo;'   -- added for additional details
*/
	END                    

	print @body


GO