USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_DeleteODPatches]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_DeleteODPatches] ;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_DeleteODPatches]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_DeleteODPatches] AS RETURN 0;';
END;
GO

 
ALTER  PROCEDURE [dbo].[xtr_DeleteODPatches] (	@BATCHID Int)
AS
BEGIN
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_DeleteODPatches'
DECLARE @SQL nvarchar(max)

BEGIN TRY


SET @SQL = 'DELETE xtrCurrentPatchStatus FROM xtrCurrentPatchStatus C
			INNER JOIN 
			(SELECT MACHINEID, MAX(SCANDATE) AS SCANDATE FROM xtrCurrentPatchStatus
			GROUP BY MACHINEID) M
			ON M.MACHINEID = C.MACHINEID
			AND C.SCANDATE < DATEADD(dd,-90, M.SCANDATE)
			WHERE C.INSTALLSTATEID = 4'

			EXEC sp_executesql @SQL

			RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH


END
