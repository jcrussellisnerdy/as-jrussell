USE [DBA]
GO

IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[deploy].[SetInstanceConfig]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetInstanceConfig] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [deploy].[SetInstanceConfig] ( @DryRun INT = 1, @ForceReset INT = 0 )
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- EXEC [deploy].[SetInstanceConfig] @dryRun = 0, @ForceReset = 1
	-- EXEC [deploy].[SetInstanceConfig] @ForceReset = 1
	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @i int = 1;
	DECLARE @MyTableVar table(
		idx smallint Primary Key IDENTITY(1,1),
		config nvarchar(200) NOT NULL);

    BEGIN TRY

        IF( @ForceReset = 1 )
            BEGIN
		        INSERT into @MyTableVar
		        SELECT 'EXEC sp_configure '''+ REPLACE(sc.[confkey] ,'Instance.','') +''', '+ [confvalue] +'; RECONFIGURE WITH OVERRIDE;' AS command
		        FROM [DBA].[Info].[systemconfig] as sc
		        left join sys.configurations as c ON (REPLACE(sc.[confkey] ,'Instance.','') = c.name)
		        WHERE sc.[confkey] like 'Instance.%';
            END
        ELSE
            BEGIN
		        INSERT into @MyTableVar
		        SELECT 'EXEC sp_configure '''+ REPLACE(sc.[confkey] ,'Instance.','') +''', '+ [confvalue] +'; RECONFIGURE WITH OVERRIDE;' AS command
		        FROM [DBA].[Info].[systemconfig] as sc
		        left join sys.configurations as c ON (REPLACE(sc.[confkey] ,'Instance.','') = c.name)
		        WHERE sc.[confkey] like 'Instance.%' AND convert(bigint,[confvalue]) > isNull(c.value, 0); 
            END

		IF( (SELECT COUNT(*) FROM @MyTableVar)>0 )
		BEGIN
 			SELECT @SQL ='
			EXEC sp_configure ''show advanced options'', 1;	RECONFIGURE WITH OVERRIDE;
			'
			WHILE (@i <= (SELECT MAX(idx) FROM @MyTableVar))
			BEGIN
				select @SQL = @SQL +'
			'+ config from @MyTableVar WHERE IDX = @i;

				SET @i = @i + 1;
			END;
		END;
	-- Registry fun!
	DECLARE @AuthenticationMode INT  
	EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', @AuthenticationMode OUTPUT  
	
	IF( (@AuthenticationMode != 2) OR (@ForceReset = 1) )
	BEGIN
		INSERT into @MyTableVar
		SELECT 'EXEC xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 2'
	END

	DECLARE @AuditLevel int
	exec master..xp_instance_regread @rootkey='HKEY_LOCAL_MACHINE', @key='SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', @value_name='AuditLevel',@value=@AuditLevel output
/*
	None = 0
	Successful Logins Only = 1
	Failed Logins Only = 2
	Both Failed and Successful Logins = 3
*/
	IF( (@AuditLevel != 2) OR (@ForceReset = 1) )
	BEGIN
		INSERT into @MyTableVar
		SELECT 'EXEC xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''AuditLevel'', REG_DWORD, 2'
	END

	IF( (SELECT COUNT(*) FROM @MyTableVar)>0 )
		BEGIN
 			SELECT @SQL = @SQL +'
			-- Setting registry 
			'
			WHILE (@i <= (SELECT MAX(idx) FROM @MyTableVar))
			BEGIN
				select @SQL = @SQL +'
			'+ config from @MyTableVar WHERE IDX = @i;

				SET @i = @i + 1;
			END;
		END;

	IF( (SELECT COUNT(*) FROM @MyTableVar)>0 )
		BEGIN
			IF(@DryRun=0)
				BEGIN
					PRINT 'RUNNING SQL TO SET sys.configurations';
					EXEC (@SQL);
				END;
			ELSE
				BEGIN
                    --IF( @RecordDrift = 0 )
                    --    BEGIN
					        PRINT 'PRINTING SQL TO SET sys.configurations.....';
					        PRINT @SQL;
                    --    END
                    --ELSE
                    --    BEGIN
                    --        PRINT 'Record Config Drift'
                    --        --SELECT email_address FROM msdb.dbo.sysoperators WHERE name = N'dbAlert'

                    --        MERGE [DBA].[info].[ConfigDrift] AS TARGET
                    --        USING @MyTableVar AS SOURCE
                    --        ON (
                    --               TARGET.[ConfigurationDrift] = SOURCE.config
                    --           )
                    --        /* Update existing records */
                    --        WHEN MATCHED THEN UPDATE
                    --            SET TARGET.[LastDiscovered] = getDate()
                    --        /* Inserts records into the target table that do not exist, but exist in the source table */
                    --        WHEN NOT MATCHED BY TARGET THEN
                    --            INSERT
                    --            ( [ConfigurationDrift], [FirstDiscovered] )
                    --            VALUES
                    --            ( SOURCE.[config], getDate() )
                    --        /* Delete records that exist in the target table, but not in the source table */
                    --        WHEN NOT MATCHED BY SOURCE THEN
                    --            DELETE;
                    --    END
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