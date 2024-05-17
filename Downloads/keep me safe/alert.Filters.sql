USE [DBA]
GO

/****** Object:  Table [alert].[Filters]    Script Date: 3/17/2020 1:54:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Alert' AND  TABLE_NAME = 'Filters'))
BEGIN

	CREATE TABLE [alert].[Filters](
		[AF_ID] [int] IDENTITY(1,1) NOT NULL,
		[AF_Error] [int] NOT NULL,
		[AF_Severity] [int] NOT NULL,
		[AF_MSG_Contains] [varchar](4000) NULL,
		[AF_Enabled] [bit] NULL,
		[AF_DateCreated] [datetime] NULL,
		[AF_CreatedBy] [varchar](256) NOT NULL,
		[AF_Description] [varchar](4000) NOT NULL,
		[AF_ExpirationDate] [datetime] NULL
	) ON [PRIMARY]
	

	ALTER TABLE [alert].[Filters] ADD  DEFAULT ((1)) FOR [AF_Enabled]

	ALTER TABLE [alert].[Filters] ADD  DEFAULT (getdate()) FOR [AF_DateCreated]

	ALTER TABLE [alert].[Filters] ADD  DEFAULT ('12/31/2029') FOR [AF_ExpirationDate]
END
