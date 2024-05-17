USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[databaseConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[databaseConfig](
	[databaseName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[confkey] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[confvalue] [varchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_databaseconfig] PRIMARY KEY CLUSTERED 
(
	[databaseName] ASC,
	[confkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
