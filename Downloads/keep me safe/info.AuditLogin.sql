USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[AuditLogin]') AND type in (N'U'))
BEGIN
CREATE TABLE [info].[AuditLogin](
	TimeStampUTC datetime NOT NULL,
	UserName varchar(100),
	NTUserName varchar(100),
	ServerPrincipalName varchar(100),
	IsSystem varchar(10),
	ClientHostName varchar(100),
	ClientAppName varchar(max),
	DatabaseName varchar(max)
)
END
GO
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[info].[AuditLogin]') 
         AND name = 'DatabaseName'
)
BEGIN
	ALTER TABLE [info].[AuditLogin] ADD [DatabaseName] varchar(max)
END
GO
