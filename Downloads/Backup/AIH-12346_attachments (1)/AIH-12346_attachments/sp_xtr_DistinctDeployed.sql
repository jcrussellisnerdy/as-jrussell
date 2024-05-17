USE SHAVLIK




IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_DistinctDeployed]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_DistinctDeployed] ;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_DistinctDeployed]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_DistinctDeployed] AS RETURN 0;';
END;
GO


ALTER  PROCEDURE [dbo].[xtr_DistinctDeployed](@BATCHID INT)


AS

BEGIN

DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_DistinctDeployed'

BEGIN TRY
TRUNCATE TABLE xtrDistinctDeployed

INSERT INTO xtrDistinctDeployed

SELECT AMS.machineid, MONTH(PD.DeployStartedOn) M, year(PD.DeployStartedOn) y, max(PD.DeployStartedOn) DeployedOn
  FROM [Reporting2].[AssessedMachineState] AMS join [Reporting2].[DetectedPatchState] DPS on AMS.Id = DPS.AssessedMachineStateId
  join [Reporting2].[PatchDeployment] PD on DPS.Id = PD.DetectedPatchStateId
  WHERE PD.DeployStartedOn IS NOT NULL 
  group by AMS.machineid, MONTH(PD.DeployStartedOn) , year(PD.DeployStartedOn)

RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH

END

