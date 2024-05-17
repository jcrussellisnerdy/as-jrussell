USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[deploy].[SetDBMail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetDBMail] AS' 
END
GO
ALTER procedure [deploy].[SetDBMail] ( @notify int = 0, @recipient varchar(100) = '', @dryRun int = 1 )
as

set nocount on

/*
-- to review the dbmail setup on this instance, run:

select p.name [profile], a.name [account], a.email_address, a.replyto_address, s.servertype, s.servername, s.port
from msdb.dbo.sysmail_profile p
left join msdb.dbo.sysmail_profileaccount ap on p.profile_id = ap.profile_id
left join msdb.dbo.sysmail_account a on ap.account_id = a.account_id
left join msdb.dbo.sysmail_server s on a.account_id = s.account_id

SELECT *
FROM msdb.dbo.sysmail_profile p 
JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1
JOIN msdb.dbo.sysmail_profileaccount pa ON p.profile_id = pa.profile_id 
JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id 
JOIN msdb.dbo.sysmail_server s ON a.account_id = s.account_id;

SELECT sent_status, * FROM MSDB..sysmail_allitems 
where subject = 'Email Test from '+ @@servername AND body like 'Email Test from '+ @@servername +'%'
order by mailitem_id DESC

----MSDB..sysmail_help_queue_sp @queue_type = 'Mail' ;
--SELECT * FROM msdb..sysmail_event_log 
--SELECT * FROM msdb..sysmail_allitems Where subject like 'Test From no-reply%' order by mailitem_id desc

*/

/*
######################################################################
					Get the paramaters
######################################################################
*/
DECLARE @profileName varchar(100)
DECLARE @SMTPServer VARCHAR(100)
DECLARE @emailAccount VARCHAR(100) 
DECLARE @replyToEmail VARCHAR(100)
DECLARE @DomainName VARCHAR(100)
DECLARE @x int
DECLARE @msgSubject varchar(100)
DECLARE @msgBody varchar(500)
DECLARE  @key varchar(100), @ServerName varchar(100)

SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\'
EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', @key=@key,@value_name='Domain',@value=@DomainName OUTPUT 
--SELECT 'Server Name: '+@@servername + ' Domain Name:'+convert(varchar(100),@DomainName)
SELECT @ServerName = @@Servername

If( @ServerName = 'UTSTAGE01' ) SET @Servername = 'UT-STAGE-01'
If( @ServerName = 'UTSTAGE-UTL1' ) SET @Servername = 'UT-STAGEUTL-01'
If( @ServerName = 'UTSTAGE-SQL-01' ) SET @Servername = 'UT-STAGINGSQL-01'
If( @ServerName = 'UTSTAGE-SQL-02' ) SET @Servername = 'UT-STAGINGSQL-02'
If( @ServerName = 'POS-SQLSTAGING1' ) SET @Servername = 'POS-SQLSTAGING-01'

If( @ServerName = 'UTQA-UTL1' ) SET @Servername = 'UT-QAUTL-01'
If( @ServerName = 'UTQA-SQL-14' ) SET @Servername = 'UT-QASQL-14'

If( @ServerName = 'IGNITE-SQL14' ) SET @Servername = 'IGNITE-SQL-14'
If( @ServerName = 'IVOS-SQL-02' ) SET @Servername = 'IVOS-SQLPRD-02'
If( @ServerName = 'IVOS-DB01' ) SET @Servername = 'IVOS-DBPRD-01'
If( @ServerName = 'TRAPPERKEEPER' ) SET @Servername = 'SHAVLIK-SQLPRD-01'

IF( (SELECT LEFT(@ServerName, LEN(@ServerName) - charindex('-',REVERSE(@ServerName)))) = (SELECT LEFT(@ServerName, charindex('-',@ServerName)-1)))
	BEGIN
		SET @profileName = replace(@ServerName,'1','')
	END
Else
	BEGIN
		SET @profileName = LEFT(@ServerName, LEN(@ServerName) - charindex('-',REVERSE(@ServerName)))
	END
				
SET @SMTPServer = 'mailrelay.alliedsolutions.net'
SET @emailAccount = 'no-reply-'+ LEFT(@ServerName, CharIndex('-', @ServerName)-1) +'@alliedsolutions.net'
SET @replyToEmail = 'No-reply@alliedsolutions.net'

if @SMTPServer is null
	begin
		if @DomainName <>  'rd.as.local' 
			begin
				print 'Set Production values'
			end
		else
			begin
				print 'Set nonproduction values'
			end
	end

SET @msgSubject = 'EMAIL Test from ' + @@servername
set @msgBody = 'EMAIL Test from ' + @@servername +'
This is a test of the SEND DBmail settings for this instance.
If you received this message you are lucky.'

/*
######################################################################
*/
IF( @dryrun = 1 )
BEGIN
	PRINT @domainname
	PRINT @smtpserver
	PRINT @emailaccount
	PRINT @replytoemail
	PRINT @profilename
	PRINT @recipient
END;

/*
######################################################################
					Drop nonstandard Operators
######################################################################
*/

/*
######################################################################
					Setting Up Operators
######################################################################
*/
If( @dryrun = 0 )
BEGIN

    /*Source Table*/
    CREATE TABLE #OperatorEmail
    (
        [OperatorName] VARCHAR(128) NOT NULL,
        [OperatorEmail] VARCHAR(128) NOT NULL,
        [OperatorPager] VARCHAR(128) NULL, 
        [OperatorCategory] VARCHAR(128) NULL,
		[processed] bit
    )
    WITH (DATA_COMPRESSION = PAGE);

	INSERT INTO #OperatorEmail  ( [OperatorName], [OperatorEmail], [OperatorPager], [OperatorCategory], [processed] )
	SELECT [OperatorName], [OperatorEmail], [OperatorPager], [OperatorCategory], 0 FROM [dba].[info].[OperatorEmail]
	-- select * from #OperatorEmail
	DECLARE @OperatorName VARCHAR(128), @OperatorEmail VARCHAR(128), @OperatorPager VARCHAR(128), @OperatorCategory VARCHAR(128)

	WHILE EXISTS (SELECT top 1 [OperatorEmail] FROM #OperatorEmail WHERE processed != 1 )
	BEGIN
		SELECT top 1  
			@OperatorName = [OperatorName], 
			@OperatorEmail = [OperatorEmail],
			@OperatorPager = [OperatorPager],
			@OperatorCategory = [OperatorCategory]
		FROM #OperatorEmail WHERE processed != 1

		IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = @OperatorName)
			BEGIN
				PRINT 'Creating account: '+ @OperatorName
				EXEC msdb.dbo.sp_add_operator @name=@OperatorName,
					@enabled=1,
					@weekday_pager_start_time=90000,
					@weekday_pager_end_time=180000,
					@saturday_pager_start_time=90000,
					@saturday_pager_end_time=180000,
					@sunday_pager_start_time=90000,
					@sunday_pager_end_time=180000,
					@pager_days=0,
					@email_address=@OperatorEmail,
					@category_name=@OperatorCategory
			END
		ELSE
			BEGIN
				PRINT 'Account: '+ @OperatorName +' already exists.'
				EXEC msdb.dbo.sp_update_operator @name=@OperatorName,
					@enabled=1,
					@weekday_pager_start_time=90000,
					@weekday_pager_end_time=180000,
					@saturday_pager_start_time=90000,
					@saturday_pager_end_time=180000,
					@sunday_pager_start_time=90000,
					@sunday_pager_end_time=180000,
					@pager_days=0,
					@email_address=@OperatorEmail,
					@category_name=@OperatorCategory
			END

		UPDATE #OperatorEmail SET processed = 1 WHERE [OperatorName] = @OperatorName;
	END; 
	--IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'MoserIT')
	--	BEGIN
	--		EXEC msdb.dbo.sp_add_operator @name=N'MoserIT',
	--			@enabled=1,
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0,
	--			@email_address=N'MoserConsultants@AlliedSolutions.net',
	--			@category_name=N'[Uncategorized]'
	--	END
	--ELSE
	--	BEGIN
	--		EXEC msdb.dbo.sp_update_operator @name=N'MoserIT',
	--			@enabled=1,
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0,
	--			@email_address=N'MoserConsultants@AlliedSoltutions.net',
	--			@category_name=N'[Uncategorized]'
	--	END

	--IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'dbAlert')
	--	BEGIN

	--		--NonProductionAlerts 92e4edd6.alliedsolutions.net@amer.teams.ms
	--		--ProductionAlerts 79059233.alliedsolutions.net@amer.teams.ms
	--		EXEC msdb.dbo.sp_add_operator @name=N'dbAlert',
	--			@enabled=1,
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0,
	--			@email_address=N'HD-IT-DBA@AlliedSolutions.net;MoserConsultants@AlliedSoltutions.net',
	--			@category_name=N'[Uncategorized]'
	--	END;
	--ELSE
	--	BEGIN
	--		EXEC msdb.dbo.sp_update_operator @name=N'dbAlert', 
	--			@enabled=1, 
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0, 
	--			@email_address=N'HD-IT-DBA@AlliedSolutions.net;MoserConsultants@AlliedSoltutions.net', 
	--			@pager_address=N''
	--	END

	--IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'NOCAlert')
	--	BEGIN
	--		EXEC msdb.dbo.sp_add_operator @name=N'NOCAlert',
	--			@enabled=1,
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0,
	--			@email_address=N'HD-IT-DBA@AlliedSolutions.net;noc@alliedsolutions.net',
	--			@category_name=N'[Uncategorized]'
	--	END;
	--ELSE
	--	BEGIN
	--		EXEC msdb.dbo.sp_update_operator @name=N'NOCAlert', 
	--			@enabled=1, 
	--			@weekday_pager_start_time=90000,
	--			@weekday_pager_end_time=180000,
	--			@saturday_pager_start_time=90000,
	--			@saturday_pager_end_time=180000,
	--			@sunday_pager_start_time=90000,
	--			@sunday_pager_end_time=180000,
	--			@pager_days=0, 
	--			@email_address=N'HD-IT-DBA@AlliedSolutions.net;noc@alliedsolutions.net', 
	--			@pager_address=N''
	--	END
END

/*
######################################################################
					Setting Up Database Mail Defaults
######################################################################
*/
IF EXISTS(SELECT * from msdb.dbo.sysmail_profile where name = @profileName)
	PRINT 'DB mail already configured for ' + @profileName
ELSE
	BEGIN
		--Create global mail profile.
		If(@dryRun = 0)
			BEGIN
				exec msdb.dbo.sysmail_add_profile_sp @profile_name = @profileName , @description = ''
			END
		ELSE
			BEGIN
				PRINT '
		EXEC msdb.dbo.sysmail_add_profile_sp @profile_name = '+ @profileName +' , @description = ''''';
			END
	END

IF EXISTS(SELECT * from msdb.dbo.sysmail_profile where name not IN (@profileName, 'Unitrac-PROD', 'UniTrac-Monitor', 'iQQ-Monitor' ))
	PRINT '[WARNING] Nonstandard Email Profile'


IF EXISTS(SELECT * from msdb.dbo.sysmail_account where name = @emailAccount)
	PRINT 'DB mail account already configured for ' + @emailAccount
ELSE
	BEGIN
		--Create database mail account.
		If(@dryRun = 0)
			BEGIN
				EXEC msdb.dbo.sysmail_add_account_sp
						@Account_name = @emailAccount
						, @description = ''
						, @email_address = @emailAccount
						, @replyto_address = @replyToEmail
						, @display_name = ''
						, @mailserver_name = @SMTPServer
			END
		ELSE
			BEGIN
				PRINT '
		EXEC msdb.dbo.sysmail_add_account_sp
			@Account_name = '+ @emailAccount +'
			, @description = ''''
			, @email_address = '+ @emailAccount +'
			, @replyto_address = '+ @replyToEmail +'
			, @display_name = ''''
			, @mailserver_name = '+ @SMTPServer
			END
	END


IF EXISTS(select * from msdb.dbo.sysmail_profileaccount pa
		join msdb.dbo.sysmail_profile p
		on pa.profile_id = p.profile_id
		join msdb.dbo.sysmail_account a
		on pa.account_id = a.account_id
		where p.name = @profileName and a.name = @emailAccount
		)
	PRINT 'DB mail profile / account already configured.'
ELSE
	BEGIN
	--Add the account to the profile.
		If(@dryRun = 0)
			BEGIN
				EXEC msdb.dbo.sysmail_add_profileaccount_sp
						@profile_name = @profileName
						, @Account_name = @emailAccount
						, @sequence_number=1
			END
		ELSE
			BEGIN
				PRINT '
		EXEC msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = '+ @profileName +',
			@Account_name = '+ @emailAccount +',
			@sequence_number=1'
			END
	END

--grant access to the profile to all users in the msdb database
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_principalprofile where is_default = 1)
	PRINT 'DB mail principal profile already configured.'
ELSE
	BEGIN
		IF(@dryRun = 0)
			BEGIN
				EXEC msdb.dbo.sysmail_add_principalprofile_sp
						 @profile_name = @profileName
						, @principal_name = 'public'
						, @is_default = 1
			END
		ELSE
			BEGIN
				PRINT '
		EXEC msdb.dbo.sysmail_add_principalprofile_sp @profile_name = '+ @profileName +', @principal_name = ''public'', @is_default = 1'
			end
	end

DECLARE @oper_email nvarchar(100)
IF( IsNull(@recipient,'') = '')
	BEGIN
		set @oper_email = (select email_address from msdb.dbo.sysoperators where name ='dbAdmins' and enabled = 1)
	END
ELSE
	BEGIN
		set @oper_email = @recipient
	END

If( @notify = 1 ) 
	BEGIN
		--send a test message.
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @profileName, 
			@recipients = @oper_email,
			@reply_to = @replyToEmail,
			@importance = 'LOW',
			@subject = @msgSubject,
			@body = @msgBody

		-- send a test alert
		EXEC msdb.dbo.sp_notify_operator  
		   --@profile_name = N'AdventureWorks Administrator',  
		   @name = N'dbAlert',  
		   @subject = N'[ALERT] - Test Notification',  
		   @body = N'
			This is a test of notification via e-mail.
		
			If you recieved this you are kinda lucky.' ;  
	END
ELSE IF( @notify = 0 AND @dryRun = 1 ) 
	BEGIN
		--display information
		print '
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = '''+ @profileName +''', 
			@recipients = '''+ @oper_email +''',
			@reply_to = '''+ @replyToEmail +''',
			@importance = ''LOW'',
			@subject = '''+ @msgSubject +''',
			@body = '''+ @msgBody +''''

		-- display a test alert
		PRINT'
		EXEC msdb.dbo.sp_notify_operator  
		   --@profile_name = N''AdventureWorks Administrator'',  
		   @name = N''dbAlert'',  
		   @subject = N''[ALERT] - Test Notification'',  
		   @body = N''
			This is a test of notification via e-mail.
		
			If you recieved this you are kinda lucky.'' ;'  
	END

GO

