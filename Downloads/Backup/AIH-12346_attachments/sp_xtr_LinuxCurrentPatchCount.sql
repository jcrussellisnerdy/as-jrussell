USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_LinuxCurrentPatchCount]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_LinuxCurrentPatchCount] ;



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_LinuxCurrentPatchCount]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_LinuxCurrentPatchCount] AS RETURN 0;';
END;
GO

 
ALTER  PROCEDURE [dbo].[xtr_LinuxCurrentPatchCount](@BATCHID Int)


AS
BEGIN
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_LinuxCurrentPatchCount'

BEGIN TRY
TRUNCATE TABLE xtrLinuxCurrentPatchCount

INSERT INTO xtrLinuxCurrentPatchCount

SELECT AMS.MACHINEID AS MACHINE, VS.VALUE AS SEVERITY,
SUM(CASE WHEN INSTALLSTATEID = 3 THEN 1 ELSE 0 END) AS INSTALLED,
SUM(CASE WHEN INSTALLSTATEID = 4 THEN 1 ELSE 0 END) AS NOTINSTALLED,
SUM(CASE WHEN INSTALLSTATEID = 6 THEN 1 ELSE 0 END) AS MISSINGSERVICEPACK,
SUM(CASE WHEN INSTALLSTATEID = 2 THEN 1 ELSE 0 END) AS INFORMATIONAL

FROM xtrLinuxCurrentPatchStatus LCPS
LEFT OUTER JOIN 
Reporting2.AssessedMachineState AMS ON AMS.ID = LCPS.ASSESSEDMACHINESTATEID
LEFT OUTER JOIN
Reporting2.LinuxPatch LP ON LCPS.PATCHID = LP.ID
LEFT OUTER JOIN
Reporting2.VendorSeverity VS ON VS.ID = LP.VENDORSEVERITYID
GROUP BY AMS.MACHINEID,  VS.VALUE

RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH

END
