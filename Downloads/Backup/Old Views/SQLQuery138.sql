USE [SHAVLIK]
GO

/****** Object:  View [Reporting].[DeployState]    Script Date: 5/10/2022 12:39:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting].[DeployState]
AS
SELECT [Id],
       [Value],
       [Description]
FROM   [dbo].[DeployState]
GO


