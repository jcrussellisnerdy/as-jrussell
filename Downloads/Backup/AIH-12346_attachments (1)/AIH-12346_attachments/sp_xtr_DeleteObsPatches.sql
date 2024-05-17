USE SHAVLIK

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_DeleteObsPatches]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_DeleteObsPatches] ;
GO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_DeleteObsPatches]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_DeleteObsPatches] AS RETURN 0;';
END;
GO

 
ALTER PROCEDURE [dbo].[xtr_DeleteObsPatches] (
	@PATCHCODE nvarchar(256), @BATCHID Int

)
AS

BEGIN
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_DeleteObsPatches'
DECLARE @SQL nvarchar(max)

BEGIN TRY


SET @SQL = 'DELETE xtrCurrentPatchStatus FROM xtrCurrentPatchStatus C
			INNER JOIN
			(SELECT MACHINEID, PATCHID, PRODUCTID,   ASSESSEDMACHINESTATEID, 
			SCANDATE, INSTALLSTATEID
			FROM xtrCurrentPatchStatus 
			WHERE (BULLETIN LIKE ''' + @PATCHCODE + ''')
			AND INSTALLSTATEID = 4) DP
			ON C.MACHINEID = DP.MACHINEID
			AND C.PATCHID = DP.PATCHID
			AND C.PRODUCTID = DP.PRODUCTID
			AND C.ASSESSEDMACHINESTATEID = DP.ASSESSEDMACHINESTATEID'

			EXEC sp_executesql @SQL

			RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH


END

