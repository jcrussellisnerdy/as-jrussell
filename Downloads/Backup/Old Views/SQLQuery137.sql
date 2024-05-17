USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[PatchDeployment]    Script Date: 5/10/2022 12:39:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[PatchDeployment]
AS
SELECT [dsilpdID] AS DeployId,
       [dsilitemID] AS DetectedPatchStateId,
       [dsilScheduledTime] AS DeployScheduledOn,
       [installStart] AS DeployStartedOn,
       [installEnd] AS DeployEndOn,
       [dsilDeployStatus] AS DeployStateId,
       [nativeCode] AS ResultCode
FROM   [dbo].[LinkDeploymentScanItems]
GO


