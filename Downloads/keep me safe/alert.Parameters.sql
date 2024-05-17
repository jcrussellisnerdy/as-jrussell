USE [DBA]
GO

/****** Object:  Table [alert].[Parameters]    Script Date: 3/17/2020 1:53:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[alert].[Parameters]') AND type in (N'U'))
BEGIN
	CREATE TABLE [alert].[Parameters](
		[PL_ID] [int] IDENTITY(1,1) NOT NULL,
		[PL_Scope] [varchar](256) NULL,
		[PL_ParamName] [varchar](256) NULL,
		[PL_ParamValue] [varchar](1024) NULL,
		[PL_LastModified] [datetime] NULL,
		[PL_LastModifiedBy] [varchar](256) NULL,
		[PL_Description] [varchar](2048) NULL
	) ON [PRIMARY]
	
END


