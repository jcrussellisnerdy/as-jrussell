USE SHAVLIK



IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_DistinctPatched]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_DistinctPatched] ;
GO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_DistinctPatched]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_DistinctPatched] AS RETURN 0;';
END;
GO

 
ALTER  PROCEDURE [dbo].[xtr_DistinctPatched](
@BATCHID INT)


AS
BEGIN
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_DistinctPatched'

BEGIN TRY
TRUNCATE TABLE xtrDistinctPatched

INSERT INTO xtrDistinctPatched

SELECT AMS.machineid, MONTH(DPS.InstalledOn) M, year(DPS.InstalledOn) y, max(DPS.InstalledOn) PatchedOn
  FROM [Reporting2].[AssessedMachineState] AMS join [Reporting2].[DetectedPatchState] DPS on AMS.Id = DPS.AssessedMachineStateId
  WHERE DPS.InstalledOn IS NOT NULL 
  group by AMS.machineid, MONTH(DPS.InstalledOn) , year(DPS.InstalledOn)

RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH

END
