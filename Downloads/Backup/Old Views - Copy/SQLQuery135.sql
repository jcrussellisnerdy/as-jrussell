USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[InstallState]    Script Date: 5/10/2022 12:39:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[InstallState]
WITH

 SCHEMABINDING

AS
SELECT [Id],
       [Value],
       [Description]
FROM   [dbo].[InstallState]
GO


