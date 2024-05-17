USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_LogErrorInfo]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_LogErrorInfo] ;
GO




IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_LogErrorInfo]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_LogErrorInfo] AS RETURN 0;';
END;
GO

 
ALTER PROCEDURE [dbo].[xtr_LogErrorInfo] (@BATCHID int, @ENTITYNAME nvarchar(100))
AS
BEGIN

INSERT INTO [dbo].[xtrEntityProcessErrorLog]
           ([BATCHID]
           ,[LOGDATE]
           ,[ENTITYNAME]
           ,[ERRORNUMBER]
           ,[ERRORSEVERITY]
           ,[ERRORSTATE]
           ,[ERRORPROCEDURE]
           ,[ERRORLINE]
           ,[ERRORMESSAGE])
SELECT
	@BATCHID
	, GETDATE()
	, @ENTITYNAME
	, ERROR_NUMBER() AS ERRORNUMBER
    , ERROR_SEVERITY() AS ERRORSEVERITY
    , ERROR_STATE() AS ERRORSTATE
    , ERROR_PROCEDURE() AS ERRORPROCEDURE
    , ERROR_LINE() AS ERRORLINE
    , ERROR_MESSAGE() AS ERRORMESSAGE;
 

 INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
	VALUES (@BATCHID, GETUTCDATE(),  ERROR_PROCEDURE(), 'Error(s) encountered. See more details in table dbo.EntityProcessErrorLog')

END



