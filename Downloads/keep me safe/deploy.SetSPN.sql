USE [DBA];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[deploy].[SetSPNs]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetSPNs] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [deploy].[SetSPNs]
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @StartDateTime DATETIME,
            @Active_Start_Date VARCHAR(10),
            @Active_Start_Time VARCHAR(10),
            @ServiceAccountName VARCHAR(256),
            @InstanceName VARCHAR(256),
            @MachineName VARCHAR(256),
            @Command VARCHAR(4000),
            @StepName VARCHAR(256),
            @Domain VARCHAR(20),
            @Port VARCHAR(15),
            @ProductVersion TINYINT,
            @MaxID INT,
            @StepID INT = 1,
            @SuccessAction TINYINT = 3,
            @FailureAction TINYINT = 3;

    CREATE TABLE #Commands
    (
        ID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
        Command VARCHAR(MAX),
        StepName VARCHAR(100)
    )
    WITH (DATA_COMPRESSION = PAGE);

    SELECT @StartDateTime = DATEADD(MINUTE, 5, GETDATE()),
           @InstanceName = CONVERT(VARCHAR(128), SERVERPROPERTY('InstanceName')),
           @ProductVersion = CONVERT(TINYINT, SERVERPROPERTY('ProductMajorVersion')),
           @MachineName = CONVERT(VARCHAR(128), SERVERPROPERTY('MachineName')),
           @Port = local_tcp_port
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID;

    /*Check if the port is null*/
    IF (@Port IS NULL OR @Port = '')
    BEGIN
        SELECT @Port = Utility.dbo.GetConfig('Instance.port', '');
    END;

    /*Get the Active Start Date and Time*/
    SELECT @Active_Start_Date
        = CONVERT(VARCHAR(10), DATEPART(yyyy, @StartDateTime))
          + RIGHT('0' + CONVERT(VARCHAR(10), DATEPART(mm, @StartDateTime)), 2)
          + RIGHT('0' + CONVERT(VARCHAR(10), DATEPART(dd, @StartDateTime)), 2),
           @Active_Start_Time
               = CONVERT(VARCHAR(10), DATEPART(hh, @StartDateTime))
                 + RIGHT('0' + CONVERT(VARCHAR(10), DATEPART(mi, @StartDateTime)), 2)
                 + RIGHT('0' + CONVERT(VARCHAR(10), DATEPART(ss, @StartDateTime)), 2);


    /*Get Domain Name*/
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters',
                                           N'Domain',
                                           @Domain OUTPUT,
                                           N'no_output';

    /*Check if the domain is null*/
    IF (@Domain IS NULL OR @Domain = '')
    BEGIN
        SELECT @Domain = DBA.info.GetSystemConfig('Instance.domainName', '');
    END;

    /*Get Service Account Name*/
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
                                           N'ObjectName',
                                           @ServiceAccountName OUTPUT,
                                           N'no_output';

    /*Set the command to be ran*/
    SET IDENTITY_INSERT #Commands ON;
    INSERT INTO #Commands
    ( ID, Command, StepName )
    VALUES
    (1, 'SETSPN -S MSSQLSvc/' + @MachineName + '.' + @Domain + ':' + @Port + ' ' + @ServiceAccountName, 'Port'),
    (2, 'SETSPN -S MSSQLSvc/' + @MachineName + '.' + @Domain + IsNull( ':' + @InstanceName, '' ) +' '+ @ServiceAccountName,'InstanceName');
    SET IDENTITY_INSERT #Commands OFF;

    /*Check If there are any AGs - Validate the Version of SQL*/
    IF (@ProductVersion >= 11)
    BEGIN
        INSERT INTO #Commands
        SELECT 'SETSPN -S MSSQLSvc/' + [AG].[name] + '.' + @Domain + ':' + CAST([AGL].[port] AS VARCHAR(15)) + ' '
               + @ServiceAccountName,
               'AG'
        FROM master.sys.availability_groups AS AG
            INNER JOIN master.sys.availability_group_listeners AS AGL
                ON AG.group_id = AGL.group_id;
    END;

    /*Get MaxID*/
    SELECT @MaxID = MAX(ID)
    FROM #Commands;

    /*Delete the Job If it somehow exists already*/
    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE [name] = 'DBA-AddMissingSPNs')
    BEGIN
        EXEC msdb.dbo.sp_delete_job @job_name = 'DBA-AddMissingSPNs';
    END;

    /*Add DB Maintenance Catergory if it does not exists*/
    IF NOT EXISTS
    (
        SELECT 1
        FROM msdb.dbo.syscategories
        WHERE [name] = 'DB Maintenance'
    )
    BEGIN
        EXEC msdb.dbo.sp_add_category @class = 'JOB',
                                      @type = 'LOCAL',
                                      @name = 'DB Maintenance';
    END;

    /*Create the Job*/
    EXEC msdb.dbo.sp_add_job 
        @job_name = 'DBA-AddMissingSPNs',
        @enabled = 1,
        @description = N'Adds the Missing SPNs on Startup
Job is deleted after successful execution',
        @start_step_id = 1,
        @category_name = 'DB Maintenance',
        @owner_login_name = 'sa',
        @notify_level_email = 2,
        @notify_level_page = 2,
        @delete_level = 1;

    /*Loop through and create steps*/
    WHILE (@MaxID >= @StepID)
    BEGIN
        SELECT @Command = Command,
               @StepName = 'Set the SPNs ' + ISNULL(StepName, 'AG') + '_' + CAST(@StepID AS VARCHAR(10))
        FROM #Commands
        WHERE ID = @StepID;

        IF (@MaxID = @StepID)
        BEGIN
            SELECT @SuccessAction = 1,
                   @FailureAction = 2;
        END;

        /*Add Job Steps for each Missing SPN*/
        EXEC msdb.dbo.sp_add_jobstep 
            @job_name = 'DBA-AddMissingSPNs',
            @step_id = @StepID,
            @step_name = @StepName,
            @subsystem = N'CMDEXEC',
            @command = @Command,
            @cmdexec_success_code = 0,
            @on_success_action = @SuccessAction,
            @on_success_step_id = 0,
            @on_fail_action = @FailureAction,
            @on_fail_step_id = 0,
            @server = NULL,
            @database_name = NULL,
            @flags = 0;

        SELECT @StepID += 1;
    END;

    /*Add Job Schedule*/
    EXEC msdb.dbo.sp_add_jobschedule 
        @job_name = 'DBA-AddMissingSPNs',
        @name = 'AddMissingSPNs_Schedule',
        @enabled = 1,
        @freq_type = 1,
        @freq_interval = 0,
        @freq_subday_type = 0,
        @freq_subday_interval = 0,
        @freq_relative_interval = 0,
        @freq_recurrence_factor = 0,
        @active_start_date = @Active_Start_Date,
        @active_end_date = 99991231,
        @active_start_time = @Active_Start_Time,
        @active_end_time = 235959;


    /*Add Job to run on the local server*/
    EXEC msdb.dbo.sp_add_jobserver 
        @job_name = 'DBA-AddMissingSPNs',
        @server_name = N'(local)';
END;

GO
