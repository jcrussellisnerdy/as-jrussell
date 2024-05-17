USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[TableUsage]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[TableUsage](
	[DatabaseName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaName] [varchar](255) NOT NULL,
	[TableName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreateDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[maxUserSeek] [datetime] NULL,
	[maxUserScan] [datetime] NULL,
	[maxUserLookup] [datetime] NULL,
	[maxUserUpdate] [datetime] NULL,
	[DiscoverDate] [datetime] null,
	[HarvestDate] [datetime] null
 CONSTRAINT [PK_TableUsage] PRIMARY KEY CLUSTERED 
	(
		[databaseName] ASC,
		[SchemaName] ASC,
		[TableName] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/* Alters to be reviewed and removed later */
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[info].[TableUsage]') 
         AND name = 'HarvestDate'
)
BEGIN
	ALTER TABLE [info].[TableUsage] ADD HarvestDate DateTime
END
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[info].[TableUsage]') 
         AND name = 'DiscoverDate'
)
BEGIN
	ALTER TABLE [info].[TableUsage] ADD DiscoverDate DateTime
END
GO