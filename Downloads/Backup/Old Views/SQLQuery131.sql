USE [SHAVLIK]
GO

/****** Object:  View [Reporting2].[PatchType]    Script Date: 5/10/2022 12:28:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [Reporting2].[PatchType]
AS
SELECT [Id],
       [Value],
       [Description]
FROM   [dbo].[PatchType]
GO


