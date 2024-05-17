USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[AuditCmdShell]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[AuditCmdShell](
	TimeStampUTC datetime NOT NULL,
	UserName varchar(100),
	NTUserName varchar(100),
	SQL_Text varchar(max),
	IsSystem varchar(10),
	ClientHostName varchar(100),
	ClientAppName varchar(max),
	DatabaseName varchar(max),
	ObjectName varchar(max),
	SQL_Statement varchar(max)
)
END
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[info].[AuditCmdShell]') 
         AND name = 'ObjectName'
)
BEGIN
	ALTER TABLE [info].AuditCmdShell ADD [ObjectName] varchar(max)
END
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[info].[AuditCmdShell]') 
         AND name = 'SQL_Statement'
)
BEGIN
	ALTER TABLE [info].AuditCmdShell ADD [SQL_Statement] varchar(max)
END
GO