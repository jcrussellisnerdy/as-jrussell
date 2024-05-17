USE [SHAVLIK]
GO

/****** Object:  View [Reporting].[AssessedMachineState]    Script Date: 5/10/2022 12:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting].[AssessedMachineState]
AS
SELECT scanMachine.[smachID] AS Id,
       scanMachine.[smachmmKey] AS MachineId,
       patchScan.[Id] AS PatchScanId,
       [dbo].[IPAddressToString]([scanMachine].[ipAddress]) AS IPAddress,
       patchScan.[AssessedOn] AS AssessedOn
FROM   [dbo].[ScanMachines] AS scanMachine
       LEFT OUTER JOIN
       (SELECT scan.[ScanID] AS Id,
               scan.[ScanDate] AS AssessedOn
        FROM   [dbo].[Scans] AS scan
        WHERE  scan.[scanType] = 1) AS patchScan
       ON patchScan.[Id] = scanMachine.[smachScanID]
WHERE  scanMachine.[smachmmKey] IS NOT NULL
GO


