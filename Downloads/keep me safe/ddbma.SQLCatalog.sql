USE [DBA]
GO

/****** Object:  Table [alert].[Parameters]    Script Date: 3/17/2020 1:53:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DDBMA].[SQLCatalog]') AND type in (N'U'))
BEGIN
CREATE TABLE [ddbma].[SQLCatalog](
	[ClientHostName] [varchar](50) NULL,
	[BackupLevel] [varchar](10) NULL,
	[BackupSetName] [varchar](100) NULL,
	[BackupSetDescription] [varchar](255) NULL,
	[BackupDate] [datetime] NULL,
	[ExpDate] [datetime] NULL,
	[DDHost] [varchar](50) NULL,
	[DDStorageUnit] [varchar](50) NULL,
	[DatabaseName] [varchar](100) NULL,
	[SQLInstance] [varchar](50) NULL
) ON [PRIMARY]
END


