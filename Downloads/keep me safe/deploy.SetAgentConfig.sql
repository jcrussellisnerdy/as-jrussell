USE [DBA]
GO

IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[deploy].[SetAgentConfig]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetAgentConfig] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [deploy].[SetAgentConfig] ( @dryRun int = 1)
AS
BEGIN
	-- EXEC [deploy].[SetAgentConfig] @dryRun = 1
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @i int = 1;
	DECLARE @sqlVersion nvarchar(max);
	DECLARE @MyTableVar table(
		idx smallint Primary Key IDENTITY(1,1),
		config nvarchar(MAX) NOT NULL);

	IF OBJECT_ID('tempdb..#AgentInfo') IS NOT NULL
		DROP TABLE #AgentInfo

	CREATE table #AgentInfo(
		Auto_start int,
		msx_server_name nvarchar(max),
		sqlagent_type int,
		Startup_account nvarchar(max),
		sqlserver_restart int,
		jobhistory_max_rows bigint,
		jobhistory_max_rows_per_job bigint,
		errorlog_file nvarchar(max),
		errorlogging_level int,
		error_recipient nvarchar(max),
		monitor_autostart int,
		local_host_server nvarchar(max),
		job_shutdown_timeout int,
		cmdexec_account nvarchar(max),
		regular_connections int,
		host_login_name nvarchar(max),
		host_login_password nvarchar(max),
		login_timeout int,
		idle_cpu_percent int,
		idle_cpu_duration int,
		oem_errorlog int,
		sysadmin_only int,
		email_profile nvarchar(max),
		email_save_in_sent_folder int,
		cpu_poller_enabled int,
		alert_replace_runtime_tokens int
	);

	INSERT INTO #AgentInfo
		EXEC msdb.dbo.sp_get_sqlagent_properties

    BEGIN TRY

		IF OBJECT_ID('tempdb..#configs') IS NOT NULL
			DROP TABLE #configs

		Create table #configs ( confkey varchar(max), confValue varchar(max) )

		INSERT INTO #configs (ConfKey )
			Select NAME 
			From tempdb.sys.columns
			Where object_id=OBJECT_ID('tempdb.dbo.#agentInfo') AND 
				name in (select replace(confkey,'Agent.','') from DBA.info.SystemConfig WHERE confkey like 'Agent.%');

		DECLARE @searchConf varchar(100), @ProductVersion INT
		SELECT @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ))

		WHILE EXISTS (Select top 1 * From #configs WHERE confValue is null)
		BEGIN
			SET @searchConf = (SELECT top 1 confKey From #configs WHERE confValue is null)

			UPDATE #configs 
			SET confValue = ( select confvalue from DBA.info.SystemConfig WHERE confkey = 'Agent.'+ @searchConf )
			WHERE confKey = @searchConf
		END;

		INSERT INTO @MyTableVar
			SELECT 'EXEC msdb.dbo.sp_set_sqlagent_properties @'+ confKey +' = '+ confValue +';'
			FROM #configs

		INSERT INTO @MyTableVar
			SELECT 'EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N''DBAlert'', @notificationmethod=1;'
		/* Set SQL Agent email to default account */
		IF EXISTS ( SELECT p.name
					FROM msdb.dbo.sysmail_profile p 
						JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1 )
			BEGIN
				IF( @ProductVersion in (10) ) -- 10 = SQL2012
					BEGIN
						INSERT INTO @MyTableVar
						SELECT 'EXEC master.dbo.xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent'', N''DatabaseMailProfile'', N''REG_SZ'', N'''+ p.name +''';'
						FROM msdb.dbo.sysmail_profile p 
							JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1
					END
				ELSE
					BEGIN
						INSERT INTO @MyTableVar
						SELECT 'EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, @databasemail_profile=N'''+ p.name +''', @use_databasemail=1;'
						FROM msdb.dbo.sysmail_profile p 
							JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1
					END
			END
		ELSE
			BEGIN
				PRINT 'No Default profile defined';
			END;

		IF( (SELECT COUNT(*) FROM @MyTableVar)>0 )
		BEGIN
 			SELECT @SQL =''
			WHILE (@i <= (SELECT MAX(idx) FROM @MyTableVar))
			BEGIN
				select @SQL = @SQL +'
			'+ config from @MyTableVar WHERE IDX = @i;

				SET @i = @i + 1;
			END;
		END;


	IF( (SELECT COUNT(*) FROM @MyTableVar)>0 )
		BEGIN
			IF(@dryRun=0)
				BEGIN
					PRINT 'RUNNING SQL TO SET sys.configurations';
					EXEC (@SQL);
				END;
			ELSE
				BEGIN
					PRINT 'PRINTING SQL TO SET sys.configurations.....';
					PRINT @SQL;
				END
		END
	ELSE
		BEGIN
			PRINT 'No Changes needed.'
		END;

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
                @ErrorProcedure NVARCHAR(200);

        /*Assign variables to error-handling functions that capture information for RAISERROR.*/
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        /*Return Resultset for Digestion*/
        -- Insert error into local alert table?

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