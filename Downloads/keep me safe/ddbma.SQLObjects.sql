USE [DBA]
GO

/****** Object:  Table [DDBMA].[SQLObjects]    Script Date: 3/17/2020 1:53:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- used to hold other bits of info for backups like files
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DDBMA].[SQLObjects]') AND type in (N'U'))
BEGIN
CREATE TABLE [ddbma].[SQLObjects](
	[BackupSetName] [varchar](100) NULL,
	[BackupDate] [datetime] NULL,
	[DatabaseName] [varchar](100) NULL,
	[SQLInstance] [varchar](50) NULL,
	[file1] [varchar](50) NULL
) ON [PRIMARY]
END
-- edit file - comit
-- merge? 
-- delete branch - unsafe
