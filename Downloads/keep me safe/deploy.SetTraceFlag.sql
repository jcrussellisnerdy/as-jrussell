USE [DBA]
GO
/****** Object:  StoredProcedure [deploy].[SetTraceFlag]    Script Date: 5/5/2020 5:27:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[deploy].[SetTraceFlag]') AND type IN ( N'P', N'PC' ) )
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetTraceFlag] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [deploy].[SetTraceFlag] (@Debug BIT = 0, @DryRun BIT=0, @Force BIT=0)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE 
            @ProcedureName NVARCHAR(128),
            /*Set the defualt to 0: OK state*/
            @SetTraceFlag TINYINT = 0;


	DECLARE @ProductVersion INT,
			@InstanceName NVARCHAR(2000),
			@SubKey NVARCHAR(2000),
			@TraceFlag NVARCHAR(20),
			@i INT,
			@ValueName NVARCHAR(4000),
			@Value NVARCHAR(4000),
			@Cmd VARCHAR(7999),
			@SQL NVARCHAR(MAX)='';

	IF OBJECT_ID('tempdb..#Trace') IS NOT NULL
		DROP TABLE #Trace;
	IF OBJECT_ID('tempdb..#EnumValues') IS NOT NULL
		DROP TABLE #EnumValues;
	CREATE TABLE #Trace (Traceflag varchar(50), TraceStatus bit, IsGlobal bit, IsSession bit) WITH(DATA_COMPRESSION=PAGE);
	CREATE TABLE #EnumValues (ValueName varchar(256), Value varchar(256)) WITH(DATA_COMPRESSION=PAGE);

    SELECT @ProcedureName
        = QUOTENAME(DB_NAME()) + '.' + QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID, DB_ID())) + '.'
          + QUOTENAME(OBJECT_NAME(@@PROCID, DB_ID()));

    BEGIN TRY
		
		IF NOT EXISTS (SELECT * FROM sys.objects where name = 'TraceFlag' AND TYPE='U')
			BEGIN
				IF (@DEBUG=1)
					PRINT 'Table TraceFlag does not exist in database DBA';
					SELECT @SetTraceFlag=2;
			END;
		ELSE
			BEGIN
				SELECT @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ));

				INSERT INTO #Trace
				EXEC sp_executesql N'DBCC TraceStatus(-1) WITH NO_INFOMSGS';


				WHILE EXISTS (SELECT * FROM DBA.info.TraceFlag tf WHERE tf.TraceFlag NOT IN (SELECT TraceFlag FROM #Trace))
				BEGIN
				  SELECT TOP 1 @TraceFlag = TraceFlag FROM DBA.info.TraceFlag tf
					WHERE
					TraceFlag NOT IN (SELECT TraceFlag FROM #Trace);

				  IF NOT EXISTS ( SELECT * FROM #Trace WHERE TraceFlag = @TraceFlag)
				  BEGIN
					IF( @productVersion in (13) and @TraceFlag = '1117' )
						BEGIN
							PRINT '2016 override';
						END
					ELSE
						BEGIN
							SELECT @SQL += '
										DBCC TRACEON( '+ @TraceFlag +' , -1) WITH NO_INFOMSGS;
										';
						END;
				  END;
  
				  INSERT INTO #Trace (TraceFlag) SELECT @TraceFlag ;
				END;

				IF(@DEBUG=1)
				BEGIN
					PRINT 'PARAMETER DEBUG SET TO '+ convert(varchar,@debug); 
				END;

				IF(@DryRun=0)
					BEGIN
						IF(@DEBUG=1)
							BEGIN
								IF(LEN(@SQL)>1)
									BEGIN
										PRINT 'RUNNING SQL TO SET Trace Flags on the Instance';
										PRINT @SQL;
									END;
								ELSE
									BEGIN
										PRINT 'Traces flags already set on the instance. Nothing to do.....';
									END;
							END;
						EXEC (@SQL);
					END
				ELSE
					BEGIN
						IF(@DEBUG=1)
							BEGIN
								IF(LEN(@SQL)>1)
									BEGIN
										PRINT 'PRINTING SQL TO SET Trace Flags on the Instance';
										PRINT @SQL;
									END;
								ELSE
									BEGIN
										PRINT 'Traces flags already set on the instance. Nothing to do.....';
									END;
							END;
						END;
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
                @ErrorProcedure NVARCHAR(200),
                @PoLPErrorMessage NVARCHAR(4000);

        /*Assign variables to error-handling functions that capture information for RAISERROR.*/
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

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