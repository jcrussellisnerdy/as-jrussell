USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[Cve]    Script Date: 5/10/2022 12:38:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[Cve]
AS
SELECT [id] AS Id,
       [cveId] AS Name,
       [cvssV2] AS CVSSv2,
       [cvssV3] AS CVSSv3
FROM   [dbo].[Cve]
GO


