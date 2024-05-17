USE [DBA]
GO

/****** Object:  Table [alert].[Log]    Script Date: 3/17/2020 1:54:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'alert' AND  TABLE_NAME = 'Log'))
BEGIN
	CREATE TABLE [alert].[Log](
		[AL_ID] [int] IDENTITY(1,1) NOT NULL,
		[Database] [nvarchar](200) NOT NULL,
		[Server] [nvarchar](200) NOT NULL,
		[Date] [int] NOT NULL,
		[Time] [int] NOT NULL,
		[Severity] [int] NOT NULL,
		[Error] [int] NOT NULL,
		[Message] [nvarchar](3000) NOT NULL
	) ON [PRIMARY]
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'AlertTime' AND TABLE_NAME = 'Log')
ALTER TABLE [alert].[Log] ADD AlertTime datetime
GO
ALTER TABLE [alert].[Log] ALTER COLUMN Time int NULL
GO
ALTER TABLE [alert].[Log] ALTER COLUMN Date int NULL
GO

update [alert].[Log]
SET AlertTime = convert(datetime, convert(char(8), Date)+' '+ convert(varchar, dateadd(hour, (Time/10000) % 100, dateadd(minute, (Time/100) % 100, dateadd(second, (Time/1) % 100 , cast('00:00:00' as time(2)))))))
GO