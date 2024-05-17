USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[VendorSeverity]    Script Date: 5/10/2022 12:38:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[VendorSeverity]
AS
SELECT [Id],
       [Value],
       [Description]
FROM   [dbo].[VendorSeverity]
GO


