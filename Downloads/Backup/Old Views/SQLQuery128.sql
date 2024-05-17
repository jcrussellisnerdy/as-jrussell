USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[Machine]    Script Date: 5/11/2022 10:40:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [Reporting2].[Machine]

AS
SELECT machine.[mmKey] AS [Id],
       machine.[dnsName] AS [DnsName],
       machine.[domain] AS [Domain],
       machine.[language] AS [Language],
       machine.[name] AS [Name],
       platformArchitecture.[OSType] AS [OperatingSystemFamilyId],
       platformArchitecture.[Architecture] AS [ArchitectureId],
       platformArchitecture.[Distribution] AS [Distribution],
       linuxPlatform.[Id] AS [LinuxPlatformId],
       machine.[mmOSID] AS [ProductId],
    --   [dbo].[IPAddressToString](machine.[lastKnownIPAddress]) AS [LastKnownIP],
       lastPatchAssessment.[smachScanDate] AS [LastPatchAssessedOn],
       lastPatchAssessment.[smachID] AS [LastAssessedMachineStateId],
       lastPatchAssessment.[groupName] AS [LastPatchMachineGroupName],
       machine.[assignedGroup] AS [AssignedGroup],
       virtualMachine.[path] AS [VirtualInventoryPath],
       virtualServer.[name] AS [VirtualServerName]
FROM   [dbo].[ManagedMachines] AS machine
       INNER JOIN
       [dbo].[Platform] AS platformArchitecture
       ON platformArchitecture.[Id] = machine.[platformId]
       LEFT OUTER JOIN
       [dbo].[Scans] AS scan
       ON scan.[ScanID] = machine.[lastPatchScanId]
       LEFT OUTER JOIN
       [dbo].[ScanMachines] AS lastPatchAssessment
       ON lastPatchAssessment.[smachmmKey] = machine.[mmKey]
          AND lastPatchAssessment.smachScanID = scan.[ScanID]
       LEFT OUTER JOIN
       [Nix].[Platform] AS linuxPlatform
       ON linuxPlatform.[PlatformId] = machine.[nixOSId]
       LEFT OUTER JOIN
       [dbo].[VirtualMachine] AS virtualMachine
       ON virtualMachine.[id] = machine.[virtualMachineId]
       LEFT OUTER JOIN
       [dbo].[VirtualServer] AS virtualServer
       ON virtualMachine.[virtualServerId] = virtualServer.[id]
GO


