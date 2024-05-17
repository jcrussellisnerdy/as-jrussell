USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[PatchAppliesTo]    Script Date: 5/10/2022 12:38:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[PatchAppliesTo]
WITH

 SCHEMABINDING

AS
SELECT lpp.[pspplpatchID] AS PatchId,
       lpp.[pspplspplID] AS ProductId,
       patchProductCve.[cveId] AS CveId
FROM   [dbo].[LinkPatchProduct] AS lpp
       LEFT OUTER JOIN
       [dbo].[PatchCve] AS patchProductCve
       ON patchProductCve.[patchUid] = lpp.[patchUid]
GO


