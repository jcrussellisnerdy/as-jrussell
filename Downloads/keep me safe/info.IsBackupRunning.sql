USE [DBA];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[Info].[IsBackupRunning]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [Info].[IsBackupRunning] AS';
END;
GO
ALTER PROCEDURE [Info].[IsBackupRunning] (@Debug TINYINT = 0)
--WITH EXECUTE AS OWNER
AS
BEGIN
	-- EXEC [Info].[IsBackupRunning] @Debug = 1
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE --@PVJ AS ParameterValueToJSON,
            @ProcedureName NVARCHAR(128),
            /*Set the defualt to 0: OK state*/
            @RunningBackups TINYINT = 0;

    --INSERT INTO @PVJ
    --(
    --    ParameterName,
    --    ParameterValue
    --)
    --VALUES
    --('Debug', CAST(@Debug AS NVARCHAR(MAX)));

    SELECT @ProcedureName
        = QUOTENAME(DB_NAME()) + '.' + QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID, DB_ID())) + '.'
          + QUOTENAME(OBJECT_NAME(@@PROCID, DB_ID()));

    DECLARE @PolpLogID BIGINT;
    --EXEC DBA.dbo.PoLPLogIns @ProcedureName = @ProcedureName,
    --                            @ParameterValue = @PVJ,
    --                            @PoLPLogID = @PolpLogID OUTPUT;

    BEGIN TRY
        /*Check if any backups are currently running*/
        CREATE TABLE #RunningBackups
        (
            ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
            SessionID INT,
            HostName NVARCHAR(128),
            UserLogin NVARCHAR(128),
            DatabaseName NVARCHAR(256),
            CommandStatus NVARCHAR(128),
            PercentComplete DECIMAL(18, 3),
            StartTime DATETIME,
            EstimatedMinutesLeft INT,
            EstimatedFinishTime DATETIME,
            CommandStatement NVARCHAR(128),
            CurrentStatement NVARCHAR(MAX)
        )
        WITH (DATA_COMPRESSION = PAGE);
 
		INSERT INTO #RunningBackups
        SELECT [session_id],
               [host_name],
               [login_name],
               [Database],
               [status],
               [%],
               [start_time],
               [MinLeft],
               DATEADD(mi, [MinLeft], GETDATE()) AS [EstimatedFinishTime],
               [command],
               [CurrentStatement]
        FROM DBA.info.instanceLoadQuery
        WHERE [command] = 'BACKUP DATABASE'
              OR [command] = 'BACKUP LOG';

        /*Check to see IF ONLY a log backup is running and update state*/
        IF EXISTS
        (
            SELECT 1
            FROM #RunningBackups
            WHERE [CommandStatement] = 'BACKUP LOG'
        )
        BEGIN
            /*Set value to 1: Warning State*/
            SELECT @RunningBackups = 1;
            IF (@Debug > 0)
            BEGIN
                PRINT 'Log Backup is currently running';
            END;
        END;

        /*Check to see IF ONLY a database full/diff backup is running and update state*/
        IF EXISTS
        (
            SELECT 1
            FROM #RunningBackups
            WHERE [CommandStatement] = 'BACKUP DATABASE'
        )
        BEGIN
            /*Set value to 2: Critical State*/
            SELECT @RunningBackups = 2;
            IF (@Debug > 0)
            BEGIN
                PRINT 'Full/Diff Backup is currently running';
            END;
        END;

        /*Present result set if the state is not OK*/
        IF (@RunningBackups > 0)
        BEGIN
            SELECT [SessionID],
                   [HostName],
                   [UserLogin],
                   [DatabaseName],
                   [CommandStatus],
                   [PercentComplete],
                   [StartTime],
                   [EstimatedMinutesLeft],
                   [EstimatedFinishTime],
                   [CommandStatement],
                   [CurrentStatement]
            FROM #RunningBackups;
        END;

		/*Print state vlaue if in debug mode*/
        IF (@Debug > 0)
        BEGIN
            PRINT 'The state value to be returned is: ' + CAST(@RunningBackups AS VARCHAR(3));
        END;

        /*Update Complete date in the log*/
        --EXEC DBA.dbo.PoLPLogUpd @PoLPLogID = @PolpLogID;

        /*Return the state value*/
        RETURN @RunningBackups;

    END TRY
    BEGIN CATCH
        /*If anything is open - we need to rollback*/
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorNumber INT,
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorProcedure NVARCHAR(200),
                @PoLPErrorMessage NVARCHAR(4000);

        /*Assign variables to error-handling functions that capture information for RAISERROR.*/
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        /*Build the message string that will contain original error information.*/
        SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 'Message: ' + ERROR_MESSAGE();

        SELECT @PoLPErrorMessage = @ErrorMessage;
        SELECT @PoLPErrorMessage = STUFF(@PoLPErrorMessage, CHARINDEX('%d', @PoLPErrorMessage), 2, @ErrorNumber);
        SELECT @PoLPErrorMessage = STUFF(@PoLPErrorMessage, CHARINDEX('%d', @PoLPErrorMessage), 2, @ErrorSeverity);
        SELECT @PoLPErrorMessage = STUFF(@PoLPErrorMessage, CHARINDEX('%d', @PoLPErrorMessage), 2, @ErrorState);
        SELECT @PoLPErrorMessage = STUFF(@PoLPErrorMessage, CHARINDEX('%s', @PoLPErrorMessage), 2, @ErrorProcedure);
        SELECT @PoLPErrorMessage = STUFF(@PoLPErrorMessage, CHARINDEX('%d', @PoLPErrorMessage), 2, @ErrorLine);

        /*Return Resultset for Digestion*/
        SELECT @Debug AS DebugValue;

        /*Update the Polp log with complete time and error message*/
        --EXEC DBA.dbo.PoLPLogUpd @PoLPLogID = @PolpLogID, @Error = @PoLPErrorMessage;

        /*Raise an error: msg_str parameter of RAISERROR will contain
         the original error information.*/
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

        /*a return of 3 designates an UNKNOWN if the severity does not stop execution*/
        RETURN 3;

    END CATCH;
END;

