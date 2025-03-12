DECLARE @EmailSubject AS VARCHAR(100)
DECLARE @Profile AS VARCHAR(200)
declare @Email AS  VARCHAR(200)
DECLARE @body NVARCHAR(MAX)


		 

 
		 EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile,
						@recipients = @Email,
						@subject = @EmailSubject,
						@body = @body





/*

BEGIN
            EXEC msdb.dbo.sp_send_dbmail 
			@Subject= 'EDI Error Report',
			@profile_name = 'Unitrac-prod',
			@body = 'Attached are all EDI errors from the past 72 hours.',
			@recipients = 'mike.breitsch@alliedsolutions.net;rene.cannon@alliedsolutions.net;kevin.flaherty@alliedsolutions.net;joseph.russell@alliedsolutions.net;benjamin.helmuth@alliedsolutions.net',
			 @file_attachments= 'C:\Reports\EDIErrorReport.csv';
            RETURN
        END


		
EXEC msdb.dbo.sysmail_help_profile_sp;


		*/