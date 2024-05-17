USE [DBA];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[backup].[BackupReport]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [backup].[BackupReport] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [backup].[BackupReport] (@BackupType NVARCHAR(10), @email_id_to NVARCHAR(512) = '', @DryRun TINYINT = 1)
AS
BEGIN
	-- EXEC [Backup].[BackupReport] @BackupType = 'FULL', @DryRun = 0
	-- EXEC [Backup].[BackupReport] @BackupType = 'LOG', @DryRun = 0
	-- EXEC [Backup].[BackupReport] @BackupType = 'LOGS', @DryRun = 0
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	/* VARIABLE DECLARATIONS */ 
	--DECLARE @email_copy_to NVARCHAR(512) = 'harold.brotherton@alliedsolutions.net'
	DECLARE @email_reply_to NVARCHAR(512) = 'hd-it-dba@alliedsolutions.net' 
	DECLARE @email_from_address NVARCHAR(512) = 'no-reply-gp@alliedsolutions.net' 
	DECLARE @email_profile_name NVARCHAR(64) = 'UT-StagingSQL' --'GP-Prod' 
	DECLARE @email_subject NVARCHAR(64)
	DECLARE @email_head NVARCHAR(2048) 
	DECLARE @email_head_title NVARCHAR(500)
	DECLARE @email_body NVARCHAR(MAX) 
	DECLARE @email_body_format NVARCHAR(64) = 'HTML'
	DECLARE @email_tail NVARCHAR(500) 
	DECLARE @email_html NVARCHAR(MAX) 
	DECLARE @databaseName NVARCHAR(128)
	DECLARE @databaseLastBackup DATETIME
	DECLARE @newLineChar AS CHAR(2) = CHAR(13) + CHAR(10)

	/* Set variables based on @backupType */
	DECLARE @bType NVARCHAR(1) 
	DECLARE @alertThreshold INT -- hours
	IF( @BackupType = 'FULL' )
		BEGIN
			SET @bType = 'D'
			SET @alertThreshold = 25 -- hours
		END
	ELSE IF( @BackupType = 'LOG' )
		BEGIN
			SET @bType = 'L'
			SET @alertThreshold = 30 -- hours
		END
	ELSE
		BEGIN
			PRINT 'Unknown Backup type: '+ @BackupType
			RAISERROR('Unknown Backup type', 1, 1)-- with LOG
		END

	/* Get Default email profile info */
	SELECT @email_from_address = a.name,  @email_profile_name = p.name --, SELECT  * 
	FROM msdb.dbo.sysmail_profileaccount pa
		join msdb.dbo.sysmail_profile p	on pa.profile_id = p.profile_id
		join msdb.dbo.sysmail_account a	on pa.account_id = a.account_id
	WHERE pa.profile_ID IN ( SELECT profile_id FROM msdb.dbo.sysmail_principalprofile WHERE is_default = 1 )

	/* Get DBAlert email recipients */
	IF( @email_ID_to = '' )
		BEGIN
			SET @email_id_to = ( SELECT email_address FROM msdb.dbo.sysoperators WHERE name = 'DBAlert' )
		END

	IF OBJECT_ID('tempdb..#databases') IS NOT NULL
	BEGIN
		DROP TABLE #databases
	END;

	CREATE TABLE #databases (ID INT NOT NULL IDENTITY(1,1), DBName VARCHAR(100), LastBackupDate DATETIME);

	WITH LastFullBackup
	AS (SELECT [BS].[database_name],
				MAX([BS].[backup_finish_date]) AS BackupDate
		FROM [msdb].[dbo].[backupset] AS BS
		WHERE [BS].[type] = @bType
		GROUP BY [BS].[database_name])

	INSERT INTO #databases (DBName,LastBackupDate)
	SELECT [name],
			CONVERT(VARCHAR(50), ISNULL(llb.BackupDate, '1/1/1900'), 120)
	FROM sys.databases AS sd
		LEFT JOIN LastFullBackup llb
			ON sd.[name] = llb.[database_name]
	WHERE sd.[recovery_model] IN ( 1, 2, 3 )
			AND sd.is_read_only = 0
			AND sd.[state] = 0
			AND sd.[name] NOT IN ('tempdb')
			AND databasePropertyEx(sd.[name], 'Updateability') = 'READ_WRITE';

	IF (SELECT COUNT(*) FROM #databases WHERE DATEDIFF(HOUR,LastBackupDate,GETDATE()) >= @alertThreshold) > 0
	BEGIN
		/* SET EMAIL SUBJECT */
		SET @email_subject = @@SERVERNAME + ' '+ @backupType +' are not backing up';
		SET @email_head_title = 'The following databases on ' + @@SERVERNAME + ' Do not have a '+ @backupType +' backup in: '+ convert(varchar(10), @alertThreshold) + 'hours.'

		/* SET EMAIL HTML FORMATTING */
		SET @email_head = '<html><head><style>' +
			'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;} ' +
			'</style></head><body>' +
			'<div style="margin-top:20px; margin-left:5px; margin-bottom:15px; font-weight:bold; font-size:1.3em; font-family:calibri; width:800px">' +
			@email_head_title + '</div>' +
			'<div style="margin-left:50px; font-family:Calibri;"><table cellpadding=0 cellspacing=0 border=0 width=460px>' +
			'<col width="60"><col width="160"><col width="240">' + 
			'<tr bgcolor=#4b6c9e>' +
			'<td align=center><font face="calibri" color=White><b>#</b></font></td>' + 
			'<td align=center><font face="calibri" color=White><b>Database Name</b></font></td>' + 
			'<td align=center><font face="calibri" color=White><b>Database Last Backup</b></font></td></tr>' 
		SET @email_tail = '</table></div></body></html>' ;

		/* SET EMAIL BODY SEPARATELY FROM sp_send_dbmail. DO *NOT* USE DYNAMIC SQL */ 
		SET @email_body = 
		(
			SELECT 
				CASE WHEN dateDiff(hour, lastbackupDate, getdate()) > @alertThreshold THEN 3
				ELSE ROW_NUMBER() OVER(ORDER BY db.ID) % 2 END AS TRRow
				, td = db.ID
				, td = db.DBName
				, td = CONVERT(NVARCHAR(64), db.LastBackupDate, 100) 
			FROM #databases db
			ORDER BY db.ID
			FOR XML RAW('tr'), ELEMENTS
		)

		SET @email_body = REPLACE(@email_body, '<td>', '<td align=center><font face="calibri">')
		SET @email_body = REPLACE(@email_body, '</td>', '</font></td>')
		SET @email_body = REPLACE(@email_body, '_x0020_', space(1))
		SET @email_body = Replace(@email_body, '_x003D_', '=')
		SET @email_body = Replace(@email_body, '<tr><TRRow>0</TRRow>', '<tr bgcolor=#F8F8FD>')
		SET @email_body = Replace(@email_body, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#EEEEF4>')
		SET @email_body = Replace(@email_body, '<tr><TRRow>3</TRRow>', '<tr bgcolor=#ffff00>')
		SET @email_body = Replace(@email_body, '<TRRow>0</TRRow>', '')
	
		SET @email_html = @email_head + @email_body + @email_tail;
		SET @email_html = '<div style="color:Black; font-size:11pt; font-family:Calibri; width:100px;">' + @email_html + '</div>'

		IF( @DryRun = 1 )
			BEGIN
				PRINT 'DryRun is on'
				SELECT   @BackupType, @alertThreshold,
						@email_profile_name, @email_from_address,
						@email_reply_to , @email_id_to,
						--, @copy_recipients = @email_copy_to
						@email_subject, @email_html, @email_body_format

				SELECT *, CASE WHEN dateDiff(hour, lastbackupDate, getdate()) > @alertThreshold THEN '3 - Warning'
									ELSE convert(char(1), ROW_NUMBER() OVER(ORDER BY db.ID) % 2) END AS TRRow
				FROM #databases db
				ORDER BY db.ID
			END
		ELSE
			BEGIN
				PRINT 'Alert Sent'
				/* EXECUTE DB MAIL. USE VARIABLES FOR ALL AS BEST PRACTICE */ 
				EXEC      [MSDB].[dbo].[sp_send_dbmail] 
							@profile_name = @email_profile_name 
						, @from_address = @email_from_address 
						, @reply_to = @email_reply_to 
						, @recipients = @email_id_to 
						--, @copy_recipients = @email_copy_to
						, @subject = @email_subject 
						, @body = @email_html 
						, @body_format = @email_body_format
			END
	END
END