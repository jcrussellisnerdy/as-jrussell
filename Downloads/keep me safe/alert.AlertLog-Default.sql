USE [DBA]
GO

/****** Object:  StoredProcedure [alert].[AlertLog]    Script Date: 3/17/2020 1:45:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[alert].[AlertLog]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [alert].[AlertLog] AS RETURN 0;' 
END
GO
ALTER PROCEDURE [alert].[AlertLog]
	@DBName nvarchar(200) = 'DBA',
	@SrvName nvarchar(200),
	@Date int,
	@Time int,
	@Severity int,
	@Error int,
	@Message nvarchar(3000)

AS
BEGIN

	DECLARE @msg nvarchar(4000)
	DECLARE @From nvarchar(128)
	DECLARE @DL_Total int
	Declare @MailRecipients as nvarchar(3000)
	Declare @subject nvarchar(256)		
	Declare @FilterStatus bit
	Declare @FilterCount int
	Declare @FilterWhereClause as nvarchar(3000)
	Declare @FilterResults int
	Declare @str as nvarchar(4000)
	DECLARE @DBMailProfile nvarchar(256)


	Set @Message = Replace(@Message, Char(39), '')

	Select @DBMailProfile = [PL_ParamValue] from [alert].[Parameters] where [PL_ParamName] = 'MailProfile' and [PL_Scope] = 'All'

	Set @FilterStatus = 0

	IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'alert' 
                 AND  TABLE_NAME = 'Log'))
		Begin
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
		End

	Insert Into [alert].[Log]
	([Database], [Server], [Date], [Time], [Severity], [Error], [Message])
	Select 
		@DBName
		, @SrvName
		, @Date
		, @Time
		, @Severity
		, @Error
		, @Message

	If (Select Count(*) from [alert].[Filters] where AF_Error = @Error and AF_Severity = @Severity and AF_MSG_Contains is Null and AF_Enabled = 1 and AF_ExpirationDate > GetDate()) >= 1
		Begin
			--Print 'Enter Phase 1 - Level 1'
			Set @FilterStatus = 1
		End
	Else 
		Begin
			Print 'Enter Phase 2 - Level 1'
			Print 'Error = ' + Cast(@Error as varchar(10))
			Print 'Severity = ' + Cast(@Severity as char(2))
			Print 'Message = ' + Cast(@message as varchar(500))
			Print 'Time = ' + Cast(@time as varchar(6))

			--Select * from [dbo].[ALRT_Filters] where AF_Error = @Error and AF_Severity = @Severity and AF_MSG_Contains is Not Null and AF_Enabled = 1 and AF_ExpirationDate > GetDate()

			Select @FilterCount = Count(*) from [alert].[Filters] where AF_Error = @Error and AF_Severity = @Severity and AF_MSG_Contains is Not Null and AF_Enabled = 1 and AF_ExpirationDate > GetDate()

			--Print 'FilterCount'
			--Print @FilterCount
			

			if @FilterCount = 1
				Begin
					Select @FilterWhereClause = AF_MSG_Contains From [alert].[Filters] where AF_Error = @Error and AF_Severity = @Severity and AF_MSG_Contains is Not Null and AF_Enabled = 1 and AF_ExpirationDate > GetDate()

					Set @str = '
						Declare @message nvarchar(3000)
						Declare @time int

						Set @message = ' + Char(39) + @message + Char(39) + '
						Set @time = ' + Cast(@time as nvarchar(6)) + '
						Select 1 as [FilterStatus] into ##Temp1 where ' + @FilterWhereClause
							
					--Print @str

					Exec sp_executesql @str

					Select @FilterStatus = [FilterStatus] from ##Temp1

					Drop Table ##Temp1

					If @FilterResults = 1
						Begin
							Set @FilterStatus = 1
						End
				End
			Else If @FilterCount > 1
				Begin
					--Print 'Enter Phase 2 - Level 2'
					Declare AF_Cursor Cursor for
					Select AF_MSG_Contains from [alert].[Filters] where AF_Error = @Error and AF_Severity = @Severity and AF_MSG_Contains is Not Null and AF_Enabled = 1 and AF_ExpirationDate > GetDate()

					Open AF_Cursor

					Fetch Next from AF_Cursor into @FilterWhereClause

					While @@FETCH_STATUS = 0
						Begin
							Set @str = '
							Declare @message nvarchar(3000)
							Declare @time int

							Set @message = ' + Char(39) + Replace(@message, Char(39), Char(39) + Char(39)) + Char(39) + '
							Set @time = ' + Cast(@time as nvarchar(6)) + '
							Select 1 as [FilterStatus] into ##Temp1 where ' + @FilterWhereClause
							
							--Print @str

							Exec sp_executesql @str

							Select @FilterStatus = [FilterStatus] from ##Temp1

							Drop Table ##Temp1

							If @FilterResults = 1
								Begin
									Set @FilterStatus = 1
								End

							Fetch Next from AF_Cursor into @FilterWhereClause
						End

					Close AF_Cursor
					Deallocate AF_Cursor
				End
		End

	--Print 'Filter Status'
	--Print @FilterStatus

	If @FilterStatus = 0
		Begin
			If @Severity >= 19 OR @Error = 825
				Begin
					Select @MailRecipients = [PL_ParamValue] from [alert].[parameters] where [PL_ParamName] = 'DBA Alerts' and [PL_Scope] = 'All'		

					Select @MailRecipients = @MailRecipients + ';' + [PL_ParamValue] from [alert].[parameters] where [PL_ParamName] = 'DBA Alerts Text' and [PL_Scope] = 'All'	
				End
			Else
				Begin
					Select @MailRecipients = [PL_ParamValue] from [alert].[parameters] where [PL_ParamName] = 'DBA Alerts' and [PL_Scope] = 'All'			
				End

			Set @msg = '
				Error: ' + Cast(@Error as nvarchar(300)) + '
				Severity: ' + Cast(@Severity as nvarchar(300)) + '
				Date: ' + Cast(@Date as nvarchar(300))+ '
				Time: ' + Cast(@Time as nvarchar(300)) + '
				Server: ' + @SrvName + '
				Database: ' + @DBName + '
				Message: ' + @Message

			If @Error = 15457
				Begin
				    Set @Subject =  Host_Name() + ' SQL Configuration Has Changed'
				End
			Else If @Error = 18456
				Begin
				    Set @Subject =  Host_Name() + ' SQL Failed Login Attempt'
				End
			Else
				Begin
					Set @Subject = 'SQL Server Sev: ' + Cast(@Severity as nvarchar(10)) + ' - Error: ' + Cast(@Error as nvarchar(20)) + ' - Alert Notification'
				End

			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = @DBMailProfile,
				@recipients = @MailRecipients,
				@importance = 'high',
				@subject = @Subject,
				@body = @msg
		
	End



End


GO


