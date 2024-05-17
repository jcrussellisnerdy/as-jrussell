USE [DBA];
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[CheckFailoverReadiness]') AND type IN (N'P', N'PC'))
BEGIN
  EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[CheckFailoverReadiness] AS RETURN 0;'; 
END;
GO
ALTER PROCEDURE [info].[CheckFailoverReadiness]
( @ErrorOnFail bit=0 )
AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Red int, @Yellow int, @RecID int, @PrintAuditStmt int = 0;
DECLARE @status int = 0;
SELECT @Red = 0, @Yellow = 0, @RecID = 0;

--DECLARE @status as table (recid int, status varchar(10), message varchar(250))
CREATE TABLE #Status (RecID int, [Status] varchar(10), [Message] varchar(250));
--declare @LogSpace as table (dbName varchar(128), logSizeMB bigint, logSpaceUsedMB float, status int)
CREATE TABLE #LogSpace (DbName varchar(128), LogSizeMB bigint, LogSpaceUsedMB float, [Status] int);

INSERT INTO #LogSpace
EXEC ('DBCC SQLPERF(LOGSPACE)');

SELECT @RecID = @RecID + 1;
EXECUTE @status = DBA.info.[IsBackupRunning];
IF (@status = 2)
BEGIN
  SELECT @Red = 1;
		
  INSERT #Status (RecID, [Status], [Message])
  SELECT @RecID, 'RED', 'Full Backup Running - ' + LEFT(CurrentStatement, 50) -- select * 
  FROM DBA.Info.InstanceLoadQuery WHERE CurrentStatement LIKE '%backup%database%';
END;

SELECT @RecID = @RecID + 1;
IF (@status = 1)
BEGIN
  SELECT @Yellow = 1;
  
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT @RecID, 'YELLOW', 'Log Backup Running - ' + LEFT(CurrentStatement, 50)
  FROM DBA.Info.InstanceLoadQuery WHERE CurrentStatement LIKE '%backup%log%' AND Command LIKE '%backup%';
END;

/*  Check to validate SQL 2008 R2 Audits Starts */
IF CAST(@@Version AS varchar(50)) LIKE '%SQL Server 2008 R2%'
BEGIN
  SELECT @RecID = @RecID + 1;
		
  IF EXISTS (SELECT 'x' FROM sys.server_audits WHERE is_state_enabled = 1 AND Name IN ('Audit_Cmdshell','Members_CreateDate'))
  BEGIN
    SELECT @Red = 1;
    SELECT @PrintAuditStmt = 1;
    
    INSERT INTO #Status (RecID, [Status], [Message])
    SELECT @RecID, 'RED', 'SQL Server Audit is running or enabled';
				
  END;
END; /*  Check to validate SQL 2008 R2 Audits Ends */
	
SELECT @Recid = @RecID + 1;	
IF EXISTS (SELECT * FROM #LogSpace WHERE (LogSizeMB * LogSpaceUsedMB / 100.0) > 65000)
BEGIN
  SELECT @Yellow = 1;
  
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT @RecID, 'YELLOW', 'Log Size - ' + DbName + ' ' + CAST(LogSizeMB * LogSpaceUsedMB / 100.0 AS varchar(20))
  FROM #LogSpace WHERE (LogSizeMB * LogSpaceUsedMB / 100.0) > 65000;
END;

SELECT @RecID = @RecID + 1;
IF EXISTS (SELECT * FROM DBA.Info.InstanceLoadQuery WHERE Command LIKE '%roll%')
BEGIN
  SELECT @Red = 1;
  
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT @RecID, 'RED', 'SPID rolling back - ' + ISNULL([Database], '') + ' - SPID ' 
    + CAST(Session_id AS varchar(8)) + ' - ' + LEFT(CurrentStatement, 50)
  FROM DBA.Info.InstanceLoadQuery WHERE Command LIKE '%roll%';
END;

SELECT @RecID = @RecID + 1;
IF EXISTS (SELECT * FROM DBA.Info.InstanceLoadQuery WHERE start_time < DATEADD(mi, -5, GetDate())  AND CurrentStatement != 'sp_server_diagnostics')
BEGIN 
  SELECT @Yellow = 1;
  
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT @RecID, 'YELLOW', 'Long Running SPID - ' + ISNULL([Database], '') + ' - SPID ' 
    + CAST(Session_id AS varchar(8)) + ' - ' 
    + CAST(DATEDIFF(mi, Start_Time, GetDate()) AS varchar(10)) + ' min - ' + LEFT(CurrentStatement, 50)
  FROM DBA.Info.InstanceLoadQuery 
  WHERE Start_Time < DATEADD(mi, -5, GetDate()) AND CurrentStatement != 'sp_server_diagnostics';
END;

IF @Red = 1
BEGIN
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT 0, 'RED', 'Instance Status - Do NOT failover';
END;
ELSE IF @Yellow = 1
BEGIN
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT 0, 'YELLOW', 'Instance Status - proceed with caution, resolve issues before failover';
END;
ELSE
BEGIN
  INSERT INTO #Status (RecID, [Status], [Message])
  SELECT 0, 'GREEN', 'Instance Status - safe to failover';
END;

SELECT [Status], [Message] 
FROM #Status
ORDER BY RecID;

IF EXISTS (SELECT * FROM #Status WHERE [Status] != 'GREEN') AND @ErrorOnFail = 1
BEGIN
  RAISERROR('Instance is not ready to be failed over!', 16, 1)
END;

/*  Print Audits Statements Starts - */
IF @PrintAuditStmt = 1
BEGIN
  SELECT 'USE [MASTER];ALTER SERVER AUDIT [' + [name] + '] WITH (STATE = OFF);' AS 'Before Failover - Disable Audit by running Below Stmts' 
  FROM sys.server_audits WHERE is_state_enabled = 1 AND name IN ('Audit_Cmdshell','Members_CreateDate');

  SELECT 'USE [MASTER];ALTER SERVER AUDIT [' + [name] + '] WITH (STATE = ON);' AS 'After Failover - Enable Audit by running Below Stmts' 
  FROM sys.server_audits WHERE is_state_enabled = 1 AND name IN ('Audit_Cmdshell','Members_CreateDate');
END;
/*  Print SQL 2008 R2 Audits Statements Ends */


/*####################################################################
Purpose:  
     This procedure checks to ensure that an instance is able to 
     be failed over with minimal risk of issue.
History:  
     YYYYMMDD USERID W-000000000 Created

######################################################################*/
GO

