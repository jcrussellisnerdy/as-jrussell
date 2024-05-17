USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_LinuxDistinctDeployed]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_LinuxDistinctDeployed] ;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_LinuxDistinctDeployed]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_LinuxDistinctDeployed] AS RETURN 0;';
END;
GO


ALTER  PROCEDURE [dbo].[xtr_LinuxDistinctDeployed](@BATCHID INT)


AS
BEGIN 
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_LinuxDistinctDeployed'

BEGIN TRY
TRUNCATE TABLE xtrLinuxDistinctDeployed

INSERT INTO xtrLinuxDistinctDeployed

SELECT AMS.machineid, MONTH(PD.InstallStartedOn) M, year(PD.InstallStartedOn) y, max(PD.InstallStartedOn) DeployedOn
  FROM [Reporting2].[AssessedMachineState] AMS join [Reporting2].[LinuxDetectedPatchState] DPS on AMS.Id = DPS.AssessedMachineStateId
  join [Reporting2].[LINUXPatchDeployment] PD on DPS.Id = PD.LinuxDetectedPatchStateId
  WHERE PD.InstallStartedOn IS NOT NULL 
  group by AMS.machineid, MONTH(PD.InstallStartedOn) , year(PD.InstallStartedOn)

RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH


END

