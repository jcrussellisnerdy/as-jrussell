USE [DBA]
GO

/****** Object:  Table [ddbma].[SQLSchedule]    Script Date: 3/17/2020 1:53:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[backup].[Schedule]') AND type in (N'U'))
BEGIN
CREATE TABLE [Backup].[Schedule](
	[DatabaseName] [varchar](50) NULL,
	[DatabaseType] [varchar](50) NULL,
	[BackupMethod] [varchar](50) NULL, --- SQLNative/DDBOOST/....
	[ExpectedRecoveryModel] [varchar](50) NULL,
	[Sunday] [varchar](100) NULL,
	[Monday] [varchar](100) NULL,
	[Tuesday] [varchar](100) NULL,
	[Wednesday] [varchar](100) NULL,
	[Thursday] [varchar](100) NULL,
	[Friday] [varchar](100) NULL,
	[Saturday] [varchar](100) NULL,
	[NumberOfFiles] [int] NULL,
	[WithCompression] [int] NULL,
	[CompressionLevel] [int] NULL,
	[WithEncryption] [int] NULL, 
	[Exclude] [int] NULL
) ON [PRIMARY]
END

/* Alters to be reviewed and removed later */
--ALTER TABLE [ddbma].[SQLSchedule] Alter Column BackupMethod varchar(50)
--ALTER TABLE [ddbma].[SQLSchedule] Alter Column ExpectedRecoveryModel varchar(50)

GO

/* Drop old version */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ddbma].[SQLSchedule]') AND type in (N'U'))
BEGIN
	DROP TABLE [ddbma].[SQLSchedule]
END