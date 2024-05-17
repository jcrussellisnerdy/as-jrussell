USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[getAuditLogin]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getAuditLogin] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[getAuditLogin] ( @TargetEvent VARCHAR(128) = 'AuditLogin', @DryRun TINYINT = 1 )
AS
BEGIN
	--  EXEC [info].[getAuditLogin] @dryRun = 0, @dbName = 'DBA'
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	BEGIN TRY
		DECLARE @ExtendedEventsSessionName sysname = N'AuditLogin';
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
		
		IF OBJECT_ID('tempdb..#LoginResults') IS NOT NULL
			DROP TABLE #LoginResults
		CREATE TABLE #LoginResults
		(
			  TimeStamp datetime NOT NULL,
			  userName varchar(100),
			  NTUserName varchar(100),
			  ServerPrincipalName varchar(100),
			  IsSystem varchar(10),
			  ClientHostName varchar(100),
			  ClientAppName varchar(max),
			  DatabaseName varchar(max)
		);

		INSERT INTO #LoginResults
		SELECT  --top 1 --xr.xeXML,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('TimeStamp="',convert(nvarchar(max),xr.xeXML))+LEN('TimeStamp="'),  
						CharIndex('">',convert(nvarchar(max),xr.xeXML)) - (CharIndex('TimeStamp="',convert(nvarchar(max),xr.xeXML))+LEN('TimeStamp="')+1) ) AS TimeStamp,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),  
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS UserName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS NTUserName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('server_principal_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),  
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('server_principal_name',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('server_principal_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as ServerPrincipalName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('is_system',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as IsSystem,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_hostname',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) AS ClientHostName,
			Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('client_app_name',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) as ClientAppName,
			DB_name(Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('database_id',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'), 
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('database_id',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('database_id',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) )as DatabaseName
		FROM #xmlResults xr
		WHERE (SELECT Substring(convert(nvarchar(max),xr.xeXML), CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>'),
						CharIndex('</value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) ) 
						- (CharIndex('<value>', convert(nvarchar(max),xr.xeXML), CharIndex('nt_username',convert(nvarchar(max),xr.xeXML)) )+LEN('<value>')) ) ) not like 'NT SERVICE%'

		IF OBJECT_ID('tempdb..#AuditLogin') IS NOT NULL
			DROP TABLE #AuditLogin
		CREATE TABLE #AuditLogin
		(
			  TimeStamp datetime NOT NULL,
			  userName varchar(100),
			  NTUserName varchar(100),
			  ServerPrincipalName varchar(100),
			  IsSystem varchar(10),
			  ClientHostName varchar(100),
			  ClientAppName varchar(max),
			  DatabaseName varchar(max)
		);

		INSERT INTO #AuditLogin
		SELECT MAX(TimeStamp), UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName FROM #LoginResults
		Group BY UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName


		IF( @dryRun = 0 )
			BEGIN
				MERGE [info].[AuditLogin] AS old
					USING ( SELECT  TimeStamp, UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName 
							FROM #AuditLogin ) AS new ( TimeStamp, UserName, NTUserName, ServerPrincipalName, IsSystem,
													ClientHostName,	ClientAppName, DatabaseName )
					ON new.UserName = old.UserName AND new.NTUserName = old.NTUserName AND new.ServerPrincipalName = old.ServerPrincipalName AND 
								new.IsSystem = old.IsSystem AND new.ClientHostName = old.ClientHostName AND new.ClientAppName = old.ClientAppName AND
								new.DatabaseName = old.DatabaseName
					WHEN MATCHED AND ( old.TimeStampUTC <> new.TimeStamp
							) THEN
						UPDATE SET 
							old.TimeStampUTC = new.TimeStamp
					WHEN NOT MATCHED THEN
						INSERT( TimeStampUTC, UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName)
						VALUES( new.TimeStamp, new.UserName, new.NTUserName, new.ServerPrincipalName, 
								new.IsSystem, new.ClientHostName, new.ClientAppName, new.DatabaseName );
					/* Remove old entries */
					--DELETE * FROM info.AuditLogin WHERE TimeStamp > 90 days?

		END;
	ELSE
		BEGIN
		  	SELECT MAX(TimeStamp), UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName FROM #LoginResults
			Group BY UserName, NTUserName, ServerPrincipalName, IsSystem, ClientHostName, ClientAppName, DatabaseName
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