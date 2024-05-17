USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[Patch]    Script Date: 5/10/2022 12:27:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[Patch]
AS
WITH   PatchProductVendorSeverity (PatchId, VendorSeverityId)
AS     (SELECT   lpp.[pspplpatchID] AS [PatchId],
                 MIN(lpp.[pspplMSSeverity]) AS [VendorSeverityId]
        FROM     [dbo].[Patches] AS patch
                 INNER JOIN
                 [dbo].[LinkPatchProduct] AS lpp
                 ON patch.[patchID] = lpp.[pspplpatchID]
        GROUP BY lpp.[pspplpatchID])
SELECT patch.[patchID] AS Id,
       patch.[patchBulletinID] AS Bulletin,
       patch.[patchQNumbers] AS QNumber,
       patch.[patchBulletinTitle] AS BulletinTitle,
       pvs.[VendorSeverityId] AS VendorSeverityId,
       patch.[patchIsCustom] AS IsCustomPatch,
       patch.[patchType] AS PatchTypeId,
       patch.[patchBulletinDate] AS ReleasedOn,
       patch.[iavaId] AS IavaId
FROM   [dbo].[Patches] AS patch
       INNER JOIN
       PatchProductVendorSeverity AS pvs
       ON pvs.[PatchId] = patch.[patchID]
GO


