USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_LinuxDeleteCPatches]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_LinuxDeleteCPatches] ;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_LinuxDeleteCPatches]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_LinuxDeleteCPatches] AS RETURN 0;';
END;
GO

 
ALTER  PROCEDURE [dbo].[xtr_LinuxDeleteCPatches] (@PATCHCODE nvarchar(256), @BATCHID Int)
AS
BEGIN
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_LinuxDeleteCPatches'
DECLARE @SQL nvarchar(max)

BEGIN TRY

SET @SQL = 'DELETE  xtrLinuxCurrentPatchStatus FROM xtrLinuxCurrentPatchStatus C
			INNER JOIN
			(SELECT A.ID,  A.MACHINEID, PATCHID,   MAX(ASSESSEDMACHINESTATEID) AS MAXAMS , 
			SCANDATE, INSTALLSTATEID
			FROM xtrLinuxCurrentPatchStatus A
			INNER JOIN 
			(SELECT DISTINCT MACHINEID, MAX(ASSESSEDMACHINESTATEID) AS MAXID
			FROM xtrLinuxCurrentPatchStatus
			WHERE PATCH LIKE ''' + @PATCHCODE + ''' AND INSTALLSTATEID = 3
			GROUP BY MACHINEID ) B
			ON A.MACHINEID = B.MACHINEID AND A.ASSESSEDMACHINESTATEID < B.MAXID
			WHERE PATCH LIKE ''' + @PATCHCODE + ''' AND INSTALLSTATEID = 4
			GROUP BY  A.MACHINEID,PATCHID,   SCANDATE,  ID, INSTALLSTATEID) D
			ON C.PATCHID = d.PATCHID  AND C.ASSESSEDMACHINESTATEID = D.MAXAMS'

			
			EXEC sp_executesql @SQL

			RETURN CAST(@@rowcount AS INT)

	

			
END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH



END
