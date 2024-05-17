USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[GetAuditCmdShell]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetAuditCmdShell] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[GetAuditCmdShell] ( @TargetEvent VARCHAR(128) = 'AuditCmdShell', @DryRun TINYINT = 1 )
AS
BEGIN
	--  EXEC [info].[getAuditCmdShell] @dryRun = 0
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	BEGIN TRY
		DECLARE @ExtendedEventsSessionName sysname = N'AuditCmdShell';
		DECLARE @StartTime datetimeoffset;
		DECLARE @EndTime datetimeoffset;
		DECLARE @Offset int;
 
		IF OBJECT_ID('tempdb..#xmlResults') IS NOT NULL
			DROP TABLE #xmlResults
		CREATE TABLE #xmlResults
		(
			  xeTimeStamp datetimeoffset NOT NULL
			, xeXML XML NOT NULL
		);
 
		SET @StartTime = DATEADD(HOUR, -4, GETDATE()); --modify this to suit your needs
		SET @EndTime = GETDATE();
		SET @Offset = DATEDIFF(MINUTE, GETDATE(), GETUTCDATE());
		SET @StartTime = DATEADD(MINUTE, @Offset, @StartTime);
		SET @EndTime = DATEADD(MINUTE, @Offset, @EndTime);
 
		SELECT StartTimeUTC = CONVERT(varchar(30), @StartTime, 127)
			, StartTimeLocal = CONVERT(varchar(30), DATEADD(MINUTE, 0 - @Offset, @StartTime), 120)
			, EndTimeUTC = CONVERT(varchar(30), @EndTime, 127)
			, EndTimeLocal = CONVERT(varchar(30), DATEADD(MINUTE, 0 - @Offset, @EndTime), 120);
 
		DECLARE @target_data xml;
		SELECT @target_data = CONVERT(xml, target_data)
		FROM sys.dm_xe_sessions AS s 
		JOIN sys.dm_xe_session_targets AS t 
			ON t.event_session_address = s.address
		WHERE s.name = @ExtendedEventsSessionName
			AND t.target_name = N'ring_buffer';
 
		;WITH src AS 
		(
			SELECT xeXML = xm.s.query('.')
			FROM @target_data.nodes('/RingBufferTarget/event') AS xm(s)
		)
		INSERT INTO #xmlResults (xeXML, xeTimeStamp)
		SELECT src.xeXML
			, [xeTimeStamp] = src.xeXML.value('(/event/@timestamp)[1]', 'datetimeoffset(7)')
		FROM src;

		UPDATE #xmlResults SET xeXML = cast (replace (cast(xeXML as nvarchar(max)), '<value/>','<value>NA</value>') as xml) where convert(nvarchar(max),xeXML) like '%<value/>%'
 
		IF OBJECT_ID('tempdb..#CmdShellResults') IS NOT NULL
			DROP TABLE #CmdShellResults
		CREATE TABLE #CmdShellResults
		(
			  TimeStamp datetime NOT NULL,
			  userName varchar(100),
			  NTUserName varchar(100),
			  SQL_Text varchar(MAX),
			  IsSystem varchar(10),
			  ClientHostName varchar(100),
			  ClientAppName varchar(max),
			  DatabaseName varchar(max),
			  ObjectName varchar(max),
			  SQL_Statement varchar(max)
		);

		INSERT INTO #CmdShellResults
		SELECT  -- SELECT top 1 xr.xeXML FROM #xmlResults xr
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('TimeStamp="',convert(nvarchar(max),xr.xeXML))+LEN('TimeStamp="'),  
						CharIndex('">',convert(nvarchar(max),xr.xeXML)) - (CharIndex('TimeStamp="',convert(nvarchar(max),xr.xeXML))+LEN('TimeStamp="')+1) ) AS TimeStamp,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),  
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('"username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS UserName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS NTUserName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"sql_text',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),  
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('"sql_text',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"sql_text',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as SQL_Text,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as IsSystem,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS ClientHostName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as ClientAppName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"database_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('"database_name',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"database_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as DatabaseName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"object_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('"object_name',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"object_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as ObjectName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"Statement"',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('"Statement"',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('"Statement"',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as SQL_Statement
		FROM #xmlResults xr
		WHERE (SELECT Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) ) not like 'NT SERVICE%'

		IF OBJECT_ID('tempdb..#AuditCmdShell') IS NOT NULL
			DROP TABLE #AuditCmdShell
		CREATE TABLE #AuditCmdShell
		(
			TimeStamp datetime NOT NULL,
			userName varchar(100),
			NTUserName varchar(100),
			SQL_Text varchar(MAX),
			IsSystem varchar(10),
			ClientHostName varchar(100),
			ClientAppName varchar(max),
			DatabaseName varchar(max),
			ObjectName varchar(max),
			SQL_Statement varchar(max)
		);

		INSERT INTO #AuditCmdShell
		SELECT TimeStamp, UserName, NTUserName, LTRIM(REPLACE(SQL_Text, CHAR(9), '')), IsSystem, 
			ClientHostName, ClientAppName, DatabaseName, ObjectName, SQL_Statement 
		FROM #CmdShellResults
		--Group BY UserName, NTUserName, SQL_Text, IsSystem, ClientHostName, ClientAppName, DatabaseName


		IF( @dryRun = 0 )
			BEGIN
				MERGE [info].[AuditCmdShell] AS old
					USING ( SELECT  TimeStamp, UserName, NTUserName, SQL_Text, IsSystem, ClientHostName, ClientAppName, DatabaseName, ObjectName, SQL_Statement  
							FROM #AuditCmdShell ) AS new ( TimeStamp, UserName, NTUserName, SQL_Text, IsSystem,
														   ClientHostName, ClientAppName, DatabaseName, ObjectName, SQL_Statement )
					ON old.TimeStampUTC = new.TimeStamp AND new.UserName = old.UserName AND new.NTUserName = old.NTUserName AND new.SQL_Text = old.SQL_Text AND 
								new.IsSystem = old.IsSystem AND new.ClientHostName = old.ClientHostName AND new.ClientAppName = old.ClientAppName AND
								new.DatabaseName = old.DatabaseName AND new.ObjectName = old.ObjectName AND new.SQL_Statement = old.SQL_Statement 
					--WHEN MATCHED AND ( old.TimeStampUTC <> new.TimeStamp
					--		) THEN
					--	UPDATE SET 
					--		old.TimeStampUTC = new.TimeStamp
					WHEN NOT MATCHED THEN
						INSERT( TimeStampUTC, UserName, NTUserName, SQL_Text, IsSystem, ClientHostName, ClientAppName, DatabaseName, ObjectName, SQL_Statement )
						VALUES( new.TimeStamp, new.UserName, new.NTUserName, new.SQL_Text, 
								new.IsSystem, new.ClientHostName, new.ClientAppName, new.DatabaseName, new.ObjectName, new.SQL_Statement );
					/* Remove old entries */
					DELETE FROM info.AuditCmdShell WHERE TimeStampUTC < GetDate() - 90

		END;
	ELSE
		BEGIN
		  	SELECT TimeStamp, UserName, NTUserName, SQL_Text, IsSystem, ClientHostName, ClientAppName, DatabaseName FROM #CmdShellResults
			--Group BY UserName, NTUserName, SQL_Text, IsSystem, ClientHostName, ClientAppName, DatabaseName
		END;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorNumber INT,
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorProcedure NVARCHAR(200)

        /*Assign variables to error-handling functions that capture information for RAISERROR.*/
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        /*Build the message string that will contain original error information.*/
        SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 'Message: ' + ERROR_MESSAGE();

        /*Return Resultset for Digestion*/
        -- SELECT [DatabaseName]
		  -- ,[State]
		  -- ,[CanAcceptConnections]
		  -- ,[DataConsumedSizeMB]
		  -- ,[DataFreeSpaceMB]
		  -- ,[LogConsumedSizeMB]
		  -- ,[LogFreeSpaceMB]
		  -- ,[ServerType]
		  -- ,[ReplicationStatus]
		  -- ,[IsEncrypted]
		  -- ,[EncryptionType]
	    -- FROM [DBA].[inv].[Database];

        /*Raise an error: msg_str parameter of RAISERROR will contain the original error information.*/
        RAISERROR(
                     @ErrorMessage,
                     @ErrorSeverity,
                     1,
                     @ErrorNumber,
                     @ErrorSeverity,
                     @ErrorState,
                     @ErrorProcedure,
                     @ErrorLine
                 );

    END CATCH;
END;
GO


