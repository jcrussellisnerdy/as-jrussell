USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[AgentJobConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[AgentJobConfig](
	[JobName] [varchar](200) NOT NULL,
	[JobCategory] [varchar](200),
	[IsRequired] [bit] NULL,
	[IsEnabled] [bit] NULL,
	[Comments] [varchar](100) NULL,
	PRIMARY KEY CLUSTERED 
	(
		[JobName] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
