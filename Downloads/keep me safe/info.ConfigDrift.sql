USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[ConfigDrift]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[ConfigDrift](
	[ConfigurationDrift] [varchar](MAX) NOT NULL,
	[FirstDiscovered] [datetime] NULL,
	[LastDiscovered] [datetime] NULL
)
END
GO
