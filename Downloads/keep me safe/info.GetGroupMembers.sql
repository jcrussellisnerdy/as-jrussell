USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[GetGroupMembers]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetGroupMembers] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[GetGroupMembers] ( @myApplication VARCHAR(max), @DryRun TINYINT = 1 )
AS
BEGIN
	-- exec [info].[GetGroupMembers] 'CenterPoint'
	SET NOCOUNT ON;

DECLARE @tSQL varchar(max),@myRecipient NVARCHAR(MAX),@myRecipients NVARCHAR(MAX),@myDatabase2 VARCHAR(max)
DECLARE @mySubRecipient NVARCHAR(MAX),@mySubRecipients NVARCHAR(MAX),@myAccountStatus nvarchar(max)
DECLARE @TargetLDAP varchar(10) = 'AS.LOCAL', @TargetBranch varchar(100) = 'OU=SQL Customer Groups,OU=Carmel,DC=AS,DC=LOCAL'
CREATE TABLE #people 
(		parentAdGroup varchar(MAX),
		childAdGroup varchar(MAX),
        name VARCHAR(max),
        email VARCHAR(max),
		accountStatus VARCHAR(max)
)
-- DEVELOPER GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name, mail, userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myApplication+'_Development_Team,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication +'_Development_Team', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
-- READ/WRITE GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myApplication+'_ReadWrite,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_ReadWrite', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 		
-- READ ONLY GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myApplication+'_ReadOnly,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_ReadOnly', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 	
--Looking for SUB GROUPS in READ ONLY GROUP 		
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT ''GROUP'',name FROM OpenQuery(ADSI, ''SELECT  name  FROM '''''+ @TargetLDAP +'''''  where  objectClass = ''''group'''' and memberOf=''''CN=SQL_'+@myApplication+'_ReadOnly,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients
		while @@FETCH_STATUS=0
		BEGIN
			 IF @myRecipient IS NOT NULL
			 BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					--INSERT INTO #people ( parentAdGroup, name, email )	VALUES  ( 'SQL_'+@myApplication+'_RO', @myRecipients, @myRecipient, @myAccountStatus )
					SET @tSQL='DECLARE  arraySubRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl  FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN='+@myRecipients+','+ @TargetBranch +''''' '')'
					--SET @tSQL='DECLARE  arrayRecipients cursor for SELECT ''GROUP'',* FROM OpenQuery(ADSI, ''SELECT  name  FROM '''''+ @TargetLDAP +'''''  where  objectClass = ''''group'''' and memberOf=''''CN=SQL_'+@@myApplication+'_RO,'+ @TargetBranch +''''' '')'
					EXEC(@tSQL)

							open arraySubRecipients
							FETCH next from arraySubRecipients into @mySubRecipient, @mySubRecipients, @myAccountStatus
							while @@FETCH_STATUS=0
							BEGIN
								 IF @mySubRecipient IS NOT NULL
								 BEGIN
										PRINT @myRecipients  +' '+ @mySubRecipients  +' '+ @mySubRecipient
										INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_ReadOnly', @myRecipients, @mySubRecipient, @mySubRecipients, @myAccountStatus )
								 END
								FETCH next from arraySubRecipients into @mySubRecipient, @mySubRecipients, @myAccountStatus
							END
							DEALLOCATE arraySubRecipients 
			 END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients--, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 	
-- SSIS GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myApplication+'_SSIS,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people (parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_SSIS', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
-- SSRS GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myApplication+'_SSRS,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_SSRS', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
-- IT Development GROUP																																																														CN=HQ DBA SSIS,'+ @TargetBranch +'
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=IT Development,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'IT Development', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
------------------
--  If there is an "_" remove it but preserve it in the group name.
------------------

SET @myDatabase2 = (select REPLACE(@myApplication,'_','') )

-- DEVELOPER GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myDatabase2+'_Development_Team,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication +'_Development_Team', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
-- READ/WRITE GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myDatabase2+'_ReadWrite,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people ( parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_ReadWrite', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 		
-- READ ONLY GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myDatabase2+'_ReadOnly,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people (parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_ReadOnly', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 		
-- SSIS GROUP
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myDatabase2+'_SSIS,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people (parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_SSIS', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 
-- SSRS GROUP 
SET @tSQL='DECLARE  arrayRecipients cursor for SELECT name,mail,userAccountControl FROM OpenQuery(ADSI, ''SELECT name, mail, userAccountControl FROM '''''+ @TargetLDAP +'''''  where objectClass = ''''User'''' and objectClass=''''Person'''' and memberOf=''''CN=SQL_'+@myDatabase2+'_SSRS,'+ @TargetBranch +''''' '')'
EXEC(@tSQL)

		open arrayRecipients
		FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		while @@FETCH_STATUS=0
		BEGIN
			IF @myRecipient IS NOT NULL
				BEGIN
					PRINT @myRecipients  +' '+ @myRecipient
					INSERT INTO #people (parentAdGroup, childAdGroup, name, email, accountStatus )	VALUES  ( 'SQL_'+@myApplication+'_SSRS', '', @myRecipient, @myRecipients, @myAccountStatus )
				END
			FETCH next from arrayRecipients into @myRecipient, @myRecipients, @myAccountStatus
		END
		DEALLOCATE arrayRecipients 



		SELECT distinct * FROM #people where childADgroup not in ( 'SQL_'+@myApplication +'_Development_Team','SQL_'+@myApplication+'_ReadWrite','SQL_'+@myApplication+'_ReadOnly','SQL_'+@myApplication+'_SSRS','SQL_'+@myApplication+'_SSIS')

END