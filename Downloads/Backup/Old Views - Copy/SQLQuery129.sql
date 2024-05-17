USE [SHAVLIK]
GO

/****** Object:  View [Reporting].[DetectedPatchState]    Script Date: 5/10/2022 12:25:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW  [Reporting].[DetectedPatchState]
WITH

 SCHEMABINDING

AS
SELECT scanItem.[itemID] AS Id,
       scanMachine.[smachID] AS AssessedMachineStateId,
       patch.[patchID] AS PatchId,
       lpp.[pspplspplID] AS ProductId,
       scanItem.[installedOn] AS InstalledOn,
       scanItem.[installState] AS InstallStateId
FROM   [dbo].[ScanMachines] AS scanMachine
       INNER JOIN
       [dbo].[ScanItems] AS scanItem
       ON scanMachine.[smachID] = scanItem.[itemMachineID]
       INNER JOIN
       [dbo].[LinkPatchProduct] AS lpp
       ON lpp.[pspplID] = scanItem.[itempspplID]
       INNER JOIN
       [dbo].[Patches] AS patch
       ON patch.[patchID] = lpp.[pspplpatchID]
WHERE  scanItem.[installState] IS NOT NULL
UNION
SELECT scanItem.[itemID] AS Id,
       scanMachine.[smachID] AS AssessedMachineStateId,
       patch.[patchID] AS PatchId,
       lpp.[pspplspplID] AS ProductId,
       scanItem.[installedOn] AS InstalledOn,
       CONVERT (SMALLINT, (CASE WHEN (scanItem.[itemType] IS NULL) THEN -1 WHEN (scanItem.[itemType] = 0
                                                                                 AND patch.[patchLevel] = 1) THEN 6 WHEN (scanItem.[itemType] = 3
                                                                                                                          OR scanItem.[itemType] = 5) THEN 3 ELSE scanItem.[itemType] END)) AS InstallStateId
FROM   [dbo].[ScanMachines] AS scanMachine
       INNER JOIN
       [dbo].[ScanItems] AS scanItem
       ON scanMachine.[smachID] = scanItem.[itemMachineID]
       INNER JOIN
       [dbo].[LinkPatchProduct] AS lpp
       ON lpp.[pspplID] = scanItem.[itempspplID]
       INNER JOIN
       [dbo].[Patches] AS patch
       ON patch.[patchID] = lpp.[pspplpatchID]
WHERE  scanItem.[installState] IS NULL
GO


CREATE INDEX [IX_ScanItems_installState] ON [SHAVLIK].[dbo].[ScanItems] ([installState]) INCLUDE ([itempspplID], [itemType], [itemMachineID], [installedOn])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
