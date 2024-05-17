USE [DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'alert' AND  TABLE_NAME = 'Trigger')
BEGIN
	CREATE TABLE [alert].[Trigger](
	AlertTriggerId int identity,
	ErrorNumber varchar(25) NOT NULL,
	FrequencyMinutes int NOT NULL,
	LastRunTime datetime NOT NULL, 
	NextRunTime datetime NOT NULL
	)

	ALTER TABLE [alert].[Trigger] ADD  DEFAULT (getdate()) FOR [LastRunTime]

	ALTER TABLE [alert].[Trigger] ADD  DEFAULT (getdate()) FOR [NextRunTime]


	CREATE CLUSTERED INDEX IX_AlertTrigger_NextRunTime ON AlertTrigger(NextRunTime)

END
GO
