USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[getAgentjob]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getAgentjob] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[getAgentjob] ( @JobName VARCHAR(128) = '', @RetentionDays int = 30, @DryRun TINYINT = 1 )
AS
BEGIN
	--  EXEC [info].[getAgentJob] @JobName = 'DBA-HarvestDaily', @dryRun = 0
		--  EXEC [info].[getAgentJob]  @dryRun = 0
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    CREATE TABLE #aj
    (
        [JobName] NVARCHAR(128) NOT NULL,
        [JobDescription] NVARCHAR(MAX) NULL,
		[JobCategory] NVARCHAR(32) NULL,
		[JobEnabled] INT null,
		[JobStatus] INT null,
        [StatusDesc] NVARCHAR(32) NULL,
        [JobDurationSec] INT NULL,
        [RunDateTime] DateTime,
        [EndDateTime] DateTime,
        [CreateDate] DateTime,
        [ModifiedDate] DateTime,
		[HarvestDate] DateTime
    )
    WITH (DATA_COMPRESSION = PAGE);

    BEGIN TRY
		DECLARE @SQL NVARCHAR(2000);

		if( @JobName = '' )
			BEGIN
				INSERT INTO #aj ( [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], [RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate] ) 
				SELECT
					JobName = J.name, J.description as JobDescription, S.[name] as JobCategory, J.enabled as JobEnabled,
					H.*, HarvestDate = GetDATE() 
				FROM
					msdb.dbo.sysjobs AS J LEFT JOIN msdb.dbo.syscategories as S ON (J.category_id = S.category_id)
					OUTER APPLY (
						SELECT TOP 1
							--JobName = J.name,
							--JobDescription = j.description,  select * from msdb.dbo.syscategories
							--JobEnabled = j.enabled,
							--StepNumber = T.step_id,
							--StepName = T.step_name,
							JobStatus = T.run_status, 
							StatusDesc = CASE T.run_status
								WHEN 0 THEN 'Failed'
								WHEN 1 THEN 'Succeeded'
								WHEN 2 THEN 'Retry'
								WHEN 3 THEN 'Canceled'
								ELSE 'Running' END,
							JobDurationSec = T.run_duration/10000 * 3600+T.run_duration/100%100 * 60+T.run_duration%100,
							RunDateTime = DATEADD(ss, T.run_time/10000 * 3600+T.run_time/100%100 * 60+T.run_time%100, CONVERT(DATETIME, CAST(T.run_date AS VARCHAR(10)))),
							EndDateTime = DATEADD(ss, (T.run_duration/10000 * 3600+T.run_duration/100%100 * 60+T.run_duration%100), DATEADD(ss, T.run_time/10000 * 3600+T.run_time/100%100 * 60+T.run_time%100, CONVERT(DATETIME, CAST(T.run_date AS VARCHAR(10))))),
							CreateDate = Date_created,
							ModifiedDate = Date_Modified
						FROM
							msdb.dbo.sysjobhistory AS T
						WHERE
							T.job_id = J.job_id
						ORDER BY
							T.instance_id DESC) AS H
				--ORDER BY J.name

				/* find missing Jobs */
				INSERT INTO #aj ( [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], [RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate] )  
				SELECT JobName, 'Required job' AS  [JobDescription], JobCategory AS [JobCategory], IsEnabled [JobEnabled], IsRequired [JobStatus], 'Missing' [StatusDesc], 0 [JobDurationSec], '' [RunDateTime], '' [EndDateTime], '' [CreateDate], '' [ModifiedDate], GetDATE() [HarvestDate] 
				FROM info.AgentJobConfig where IsRequired = 1 AND JobName not in ( SELECT JobName from #AJ )
    
			END
		ELSE
			BEGIN
				INSERT INTO #aj ( [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], [RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate] ) 
				SELECT
					JobName = J.name, J.description as JobDescription, S.[name] as JobCategory, J.enabled as JobEnabled,
					H.*, HarvestDate = GetDATE() 
				FROM
					msdb.dbo.sysjobs AS J LEFT JOIN msdb.dbo.syscategories as S ON (J.category_id = S.category_id)
					OUTER APPLY (
						SELECT TOP 1
							--JobName = J.name,
							--JobDescription = j.description,
							--JobEnabled = j.enabled,
							--StepNumber = T.step_id,
							--StepName = T.step_name,
							JobStatus = T.run_status,
							StatusDesc = CASE T.run_status
								WHEN 0 THEN 'Failed'
								WHEN 1 THEN 'Succeeded'
								WHEN 2 THEN 'Retry'
								WHEN 3 THEN 'Canceled'
								ELSE 'Running' END,
							JobDurationSec = T.run_duration/10000 * 3600+T.run_duration/100%100 * 60+T.run_duration%100,
							RunDateTime = DATEADD(ss, T.run_time/10000 * 3600+T.run_time/100%100 * 60+T.run_time%100, CONVERT(DATETIME, CAST(T.run_date AS VARCHAR(10)))),
							EndDateTime = DATEADD(ss, (T.run_duration/10000 * 3600+T.run_duration/100%100 * 60+T.run_duration%100), DATEADD(ss, T.run_time/10000 * 3600+T.run_time/100%100 * 60+T.run_time%100, CONVERT(DATETIME, CAST(T.run_date AS VARCHAR(10))))),
							CreateDate = Date_created,
							ModifiedDate = Date_Modified
						FROM
							msdb.dbo.sysjobhistory AS T
						WHERE
							T.job_id = J.job_id AND J.name = @JobName
						ORDER BY
							T.instance_id DESC) AS H
				--ORDER BY J.name
			END;


		IF( @dryRun = 0 )
			BEGIN
				MERGE [info].[AgentJob] AS old
					USING ( SELECT [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], 
								   [RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate]
							FROM #AJ ) AS new ( [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], 
												[RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate] )
					ON new.[JobName] = old.[JobName]
					WHEN MATCHED AND (  old.[JobDescription] <> new.[JobDescription] OR old.[JobCategory] <> new.[JobCategory] OR 
										old.[JobEnabled] <> new.[JobEnabled] OR old.[JobStatus] <> new.[JobStatus] OR
										old.[StatusDesc] <> new.[StatusDesc] OR old.[JobDurationSec] <> new.[JobDurationSec] OR
										IsNull(old.[RunDateTime],'') <> new.[RunDateTime] OR IsNull(old.[EndDateTime],'') <> new.[EndDateTime] OR
										IsNull(old.[CreateDate],'') <> new.[CreateDate] OR IsNull(old.[ModifiedDate],'') <> new.[ModifiedDate] OR isNull(old.[HarvestDate], '') <> new.[HarvestDate]
									 ) THEN
						UPDATE SET 
							old.[JobDescription] = new.[JobDescription], old.[JobCategory] = new.[JobCategory], 
							old.[JobEnabled] = new.[JobEnabled], old.[JobStatus] = new.[JobStatus],
							old.[StatusDesc] = new.[StatusDesc], old.[JobDurationSec] = new.[JobDurationSec],
							old.[RunDateTime] = new.[RunDateTime], old.[EndDateTime] = new.[EndDateTime],
							old.[CreateDate] = new.[CreateDate], old.[ModifiedDate] = new.[ModifiedDate], old.[HarvestDate] = new.[HarvestDate]
							
					/* Inserts records into the target table that do not exist, but exist in the source table */
					WHEN NOT MATCHED THEN
						INSERT( [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], 
								[RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], [HarvestDate] )
						VALUES( new.[JobName], new.[JobDescription], new.[JobCategory], new.[JobEnabled], new.[JobStatus], new.[StatusDesc], new.[JobDurationSec], 
								new.[RunDateTime], new.[EndDateTime], new.[CreateDate], new.[ModifiedDate], new.[HarvestDate] )

					/* Remove old entries */
					WHEN NOT MATCHED BY SOURCE AND @JobName = '' THEN
						DELETE;

		END;
	ELSE
		BEGIN
		  	SELECT  [JobName], [JobDescription], [JobCategory], [JobEnabled], [JobStatus], [StatusDesc], [JobDurationSec], 
					[RunDateTime], [EndDateTime], [CreateDate], [ModifiedDate], ISnULL([HarvestDate] , GETDATE()) as [DryRunDate]
			FROM #AJ;
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