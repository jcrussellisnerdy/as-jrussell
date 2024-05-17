USE [DBA];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'[deploy].[SetServerLogin]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetServerLogin] AS RETURN 0;';
END;
GO
ALTER PROCEDURE [deploy].[SetServerLogin] (@TargetLogin nvarchar(100) = '', @DryRun TINYINT = 1, @Notify TINYINT=0)
AS
BEGIN
	-- EXEC [DBA].[deploy].[SetServerLogin] @DryRun = 0
	-- EXEC [DBA].[deploy].[SetServerLogin] @Notify = 1 -- doesnot alert
	-- EXEC [DBA].[deploy].[SetServerLogin] @TargetLogin = 'ELDREDGE_A\SQL Server Maint Group' , @DryRun = 0
	-- EXEC [DBA].[deploy].[SetServerLogin] @TargetLogin = 'ELDREDGE_A\Database Administrators', @DryRun = 0
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @SQLEnv VARCHAR(100), @CurrentLogin nvarchar(max), @CurrentAction nvarchar(max), @ProductVersion INT, @sqlCMD nvarchar(4000);
	
	SELECT @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ))

	IF OBJECT_ID('tempdb..#LOGINS') IS NOT NULL
		DROP TABLE #LOGINS
	CREATE TABLE #LOGINS
	(
		LOGINNAME VARCHAR(100),
		LOGINSID VARBINARY(100),
		LOGINTYPE CHAR(1),
		POLICYCHECK BIT,
		EXPIRATIONCHECK BIT

	);

	CREATE TABLE #MissingLogins
	(
		LOGINNAME VARCHAR(100),
		LOGINTYPE CHAR(1),
		Action varchar(500),
		IsProcessed bit
	);

	CREATE TABLE #PERMISSION
	(
		LOGINNAME VARCHAR(100),
		PERMISSIONNAME VARCHAR(100),
		PERMISSIONSTATE VARCHAR(10),
		OBJECTNAME VARCHAR(100)
	);

	CREATE TABLE #MissingPermission
	(
		LOGINNAME VARCHAR(100),
		ActionType VARCHAR(100),
		Action varchar(300),
		IsProcessed bit

	);

	CREATE TABLE #ROLEMEMBERSHIP
	(
		LOGINNAME VARCHAR(100),
		ROLENAME VARCHAR(100)
	);

	CREATE TABLE #MissingROLEMEMBERSHIP
	(
		LOGINNAME VARCHAR(100),
		ActionType VARCHAR(100),
		Action varchar(300),
		IsProcessed bit
	);

	CREATE TABLE #results (id int identity, resultrows varchar(2000))
	INSERT #results (resultrows) exec master..xp_cmdshell 'osql -E -w2000 -Q "exec sp_helplogins"'

	--Parse out the Login, DbName, Username and UserOrAlias columns from second result set and store in #helpusers
	SELECT Rtrim(substring(resultrows,2,header1)) LoginName,
		   Rtrim(substring(resultrows,header1 + 3,header2)) DBName,
		   Rtrim(substring(resultrows,header1 + header2 + 4,header3)) UserName,
		   Rtrim(substring(resultrows,header1 + header2 + header3 + 5,header4)) UserOrAlias
	INTO #helpusers
	FROM (
		select  len(parsename(replace(ltrim(rtrim(resultrows)),' ','.'),4)) header1, 
			len(parsename(replace(ltrim(rtrim(resultrows)),' ','.'),3)) header2,
			len(parsename(replace(ltrim(rtrim(resultrows)),' ','.'),2)) header3,
			len(parsename(replace(ltrim(rtrim(resultrows)),' ','.'),1)) header4
		from #results
		where id = (select id + 1 from #results where resultrows like '%LoginName%DBName%UserName%UserOrAlias%')
		 ) headers,
	#results
	where id > (select id + 2 from #results where resultrows like '%LoginName%DBName%UserName%UserOrAlias%')
	and resultrows is not null and resultrows not like '%rows a%'

	DELETE FROM #helpusers WHERE LoginName like '##MS_%' 
	DELETE FROM #helpusers WHERE LoginName = 'SA'

	-- select * from #helpusers

	SELECT @SQLEnv = [info].[GetSystemConfig]('Server.Environment','')
	
	IF( @DryRun = 1 )
	BEGIN
		PRINT '[DryRun]'
	END

		IF( (@SQLEnv != 'PROD') and (@SQLEnv != 'ADMIN') ) --GRANT non production permissions
			BEGIN
				PRINT 'SET NONPROD permissions '+ @SQLEnv +' SQL version: '+ convert(varchar(10), @ProductVersion)
			-- LOGIN  SELECT * FROM #LOGINS
				--INSERT INTO #LOGINS (LOGINNAME,LOGINSID,LOGINTYPE,POLICYCHECK,EXPIRATIONCHECK) VALUES ('ELDREDGE_A\SQL Administrators',NULL,'W',NULL,NULL);
				INSERT INTO #LOGINS (LOGINNAME,LOGINSID,LOGINTYPE,POLICYCHECK,EXPIRATIONCHECK) VALUES ('ELDREDGE_A\SQL Server Maint Group',NULL,'W',NULL,NULL);
				INSERT INTO #LOGINS (LOGINNAME,LOGINSID,LOGINTYPE,POLICYCHECK,EXPIRATIONCHECK) VALUES ('ELDREDGE_A\Database Administrators',NULL,'W',NULL,NULL);


			-- PERMISSION  SELECT * FROM #PERMISSION
				--INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Administrators','VIEW SERVER STATE','GRANT','server');
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW ANY DEFINITION','GRANT','server');
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW ANY DATABASE','GRANT','server');
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW SERVER STATE','GRANT','server');

			IF( @ProductVersion > 11 )
				BEGIN
					INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','SELECT ALL USER SECURABLES','GRANT','server');
					INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','CONNECT ANY DATABASE','GRANT','server');
				END
			ELSE
				BEGIN 			-- sp_helplogins 'loginname'	
					INSERT INTO #PERMISSION 
						SELECT 'ELDREDGE_A\SQL Server Maint Group','db_datareader','GRANT', name 
						FROM Sys.databases
						WHERE name not in ('TempDB');
					--INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','CONNECT ANY DATABASE','GRANT','dba');
				END

			-- ROLE MEMBERSHIP SELECT * FROM #ROLEMEMBERSHIP
				-- NO!!! INSERT INTO #ROLEMEMBERSHIP (LOGINNAME,ROLENAME) VALUES ('ELDREDGE_A\SQL Administrators','sysadmin');
				INSERT INTO #ROLEMEMBERSHIP (LOGINNAME,ROLENAME) VALUES ('ELDREDGE_A\Database Administrators','sysadmin');
			END;
		ELSE
			BEGIN
				PRINT 'SET PROD permissions'
			-- LOGIN  SELECT * FROM #LOGINS
				INSERT INTO #LOGINS (LOGINNAME,LOGINSID,LOGINTYPE,POLICYCHECK,EXPIRATIONCHECK) VALUES ('ELDREDGE_A\SQL Server Maint Group',NULL,'W',NULL,NULL);
				INSERT INTO #LOGINS (LOGINNAME,LOGINSID,LOGINTYPE,POLICYCHECK,EXPIRATIONCHECK) VALUES ('ELDREDGE_A\Database Administrators',NULL,'W',NULL,NULL);

			-- PERMISSION  SELECT * FROM #PERMISSION
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW ANY DEFINITION','GRANT','server');
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW ANY DATABASE','GRANT','server');
				INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','VIEW SERVER STATE','GRANT','server');

			IF( @ProductVersion > 11 )
				BEGIN
					INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','SELECT ALL USER SECURABLES','GRANT','server');
					INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','CONNECT ANY DATABASE','GRANT','server');
				END
			ELSE
				BEGIN 			-- sp_helplogins 'loginname'	
					INSERT INTO #PERMISSION 
						SELECT 'ELDREDGE_A\SQL Server Maint Group','db_datareader','GRANT', name 
						FROM Sys.databases
						WHERE name not in ('TempDB');
					--INSERT INTO #PERMISSION (LOGINNAME,PERMISSIONNAME,PERMISSIONSTATE,OBJECTNAME) VALUES ('ELDREDGE_A\SQL Server Maint Group','CONNECT ANY DATABASE','GRANT','dba');
				END
			-- ROLE MEMBERSHIP SELECT * FROM #ROLEMEMBERSHIP
				INSERT INTO #ROLEMEMBERSHIP (LOGINNAME,ROLENAME) VALUES ('ELDREDGE_A\Database Administrators','sysadmin');

			END;

		IF( @TargetLogin != '') 
		BEGIN
			DELETE FROM #LOGINS WHERE LoginName != @TargetLogin;
			DELETE FROM #PERMISSION WHERE LoginName != @TargetLogin;
		END

	IF( @DryRun = 1 ) PRINT '[] Do all required Logins exist?'
-- VALIDATE LOGIN exist
/* 
	SQL LOGINS are being handeled by SetSQLAuthLogin
*/
		INSERT INTO #MissingLogins 
		SELECT L.LoginName, LoginType, 'CREATE LOGIN ['+ L.LoginName +'] FROM WINDOWS WITH DEFAULT_DATABASE=[TempDB];' AS [Action], 0
		FROM #LOGINS L --select * from syslogins
		LEFT JOIN MASTER..SYSLOGINS S ON L.LOGINNAME=S.NAME 
		WHERE L.LOGINTYPE='W' AND S.NAME IS NULL;

		IF( @@RowCount = 0 )  
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] All Required Logins are present'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more required Logins are missing'
			END

	IF( @DryRun = 1 ) PRINT '[] Do required logins have required Instance Permissions?'
-- VALIDATE SERVER PERMISSIONS -ADD
		INSERT INTO #MissingPermission  
		SELECT L.LoginName, 'ADD-Instance' AS ActionType, 'USE MASTER; '+ L.PERMISSIONSTATE +' '+ L.PERMISSIONNAME +' TO ['+ L.LoginName +']' AS Action, 0
		FROM #PERMISSION L
		LEFT JOIN (
		SELECT  pr.name AS LOGINNAME,pe.state_desc AS PERMISSIONSTATE, pe.permission_name AS PERMISSIONNAME
		FROM sys.server_principals AS pr   
			JOIN sys.server_permissions AS pe   
				ON pe.grantee_principal_id = pr.principal_id
		WHERE PERMISSION_NAME <> 'CONNECT SQL'	
		)A ON L.LOGINNAME=A.LOGINNAME COLLATE DATABASE_DEFAULT AND L.PERMISSIONSTATE=A.PERMISSIONSTATE COLLATE DATABASE_DEFAULT  AND L.PERMISSIONNAME=A.PERMISSIONNAME COLLATE DATABASE_DEFAULT
		WHERE L.OBJECTNAME='SERVER' AND A.LOGINNAME IS NULL;

		IF( @@RowCount = 0 )
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] All Required Logins have required Instance permissions'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more required Logins are missing required Instance permissions'
			END

	IF( @DryRun = 1 ) PRINT '[] Do required logins have required Server roles?'
-- Validate Server Roles -ADD
		INSERT INTO #MissingPermission 
		SELECT DISTINCT trm.LoginName, 'ADD-Server' AS ActionType,
			CASE WHEN @ProductVersion < 10 THEN 
				'ALTER SERVER ROLE ['+ trm.roleNAME +'] ADD MEMBER ['+ trm.LoginName +'];' 
				ELSE
				'EXEC sp_addsrvrolemember @loginame = N'''+ trm.LoginName +''', @rolename = N'''+ trm.roleNAME +''';'
			END as [Action], 0
		FROM SYS.server_principals L
			LEFT JOIN SYS.server_role_members RM ON L.principal_id=RM.member_principal_id
			LEFT JOIN SYS.SERVER_PRINCIPALS R ON R.principal_id=RM.role_principal_id
			LEFT JOIN ( SELECT LOGINNAME, ROLENAME FROM #ROLEMEMBERSHIP) AS tRM ON tRM.LOGINNAME=L.NAME 
		WHERE L.is_disabled = 0 AND L.NAME not like 'NT %' AND
			( (L.Name in ( SELECT LoginName from #ROLEMEMBERSHIP )) AND
				(R.Name NOT in ( SELECT ROLENAME from #ROLEMEMBERSHIP WHERE LoginName = L.Name ))) AND -- select * FROM #ROLEMEMBERSHIP
			( L.Name = CASE WHEN @TargetLogin != '' THEN @TargetLogin ELSE L.Name END )

		IF( @@RowCount = 0 )
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] All Required Logins have required Server roles'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more required Logins are missing required Server roles'
			END

	IF( @DryRun = 1 ) PRINT '[] Do required users exist?'
-- Validate database membership. 
		INSERT INTO #MissingLogins  
		SELECT P.LOGINNAME,'W','USE ['+ OBjectName +']; CREATE USER ['+ P.LOGINNAME +'] FOR LOGIN ['+ P.LOGINNAME +'];' AS [Action], 0
		FROM #PERMISSION AS P LEFT JOIN #helpusers AS HU ON (P.LOGINNAME = HU.LoginName AND P.OBJECTNAME=HU.DBName)
		WHERE P.ObjectName != 'SERVER' AND IsNull(HU.UserOrAlias, 'User') = 'User' AND P.ObjectName != IsNull(HU.DBName, '')

		IF( @@RowCount = 0 )
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] All Required users exist'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more required users are missing'
			END

	IF( @DryRun = 1 ) PRINT '[] Do required users have required Database Role?'
-- Validate database role membership.  -- select * FROM #helpusers  select * from #Permission
		INSERT INTO #MissingPermission  
		SELECT  P.LOGINNAME,'ADD-Database','USE ['+ OBjectName +']; ALTER ROLE ['+ P.PermissionName +'] '+ CASE WHEN P.PermissionState = 'GRANT' THEN 'ADD' ELSE 'REMOVE' END +' MEMBER ['+ P.LoginName +'];' AS [Action], 0
		FROM #PERMISSION AS P LEFT JOIN #helpusers AS HU ON (P.LOGINNAME = HU.LoginName AND P.OBJECTNAME=HU.DBName)
		WHERE P.ObjectName != 'SERVER' AND IsNull(HU.UserOrAlias, 'MemberOf') = 'MemberOf' AND P.ObjectName != IsNull(HU.DBName, '')

		IF( @@RowCount = 0 )
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] All Required users have required db roles'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more required users are missing required db roles'
			END
/*
	incomplete
*/


/* Creating AUDIT LOGIN SToredprocedure for removal and enforcement.
	IF( @DryRun = 1 ) PRINT '[] Do ServerRoles that have incorrect members?'
	-- VALIDATE SERVER ROLE MEMBERSHIP -REMOVE
		INSERT INTO #MissingPermission 
		SELECT L.NAME AS LOGINNAME, 'REMOVE' AS ActionType, 
			CASE WHEN @ProductVersion < 10 THEN 
				'ALTER SERVER ROLE ['+ R.NAME +'] DROP MEMBER ['+ L.NAME +'];' 
				ELSE
				'EXEC sp_dropsrvrolemember @loginame = N'''+ L.NAME +''', @rolename = N'''+ R.NAME +''';'
			END as [Action], 0
			--CASE WHEN L.Name IN ('sa') THEN 'ALTER LOGIN ['+ L.NAME +'] DISABLE' ELSE IsNull('ALTER SERVER ROLE ['+ R.NAME +'] DROP MEMBER ['+ L.NAME +']', 'Drop login ['+ L.NAME  +'];') END as [Action]
		FROM SYS.server_role_members RM
		JOIN SYS.SERVER_PRINCIPALS R ON R.principal_id=RM.role_principal_id
		JOIN SYS.server_principals L ON RM.member_principal_id=L.principal_id
		LEFT JOIN ( SELECT LOGINNAME, ROLENAME FROM #ROLEMEMBERSHIP) AS tRM ON tRM.LOGINNAME=L.NAME 
		WHERE L.is_disabled = 0 AND L.NAME not like 'NT %' AND
			( (L.Name Not in ( SELECT LoginName from #ROLEMEMBERSHIP )) OR
				(R.Name not in (SELECT ROLENAME from #ROLEMEMBERSHIP WHERE LoginName = L.Name ))) AND
			( L.Name = CASE WHEN @TargetLogin != '' THEN @TargetLogin ELSE L.Name END )

		IF( @@RowCount = 0 )
			BEGIN
				IF( @DryRun = 1 ) PRINT '[OK] Server Roles do not have extra members'
			END
		ELSE
			BEGIN
				IF( @DryRun = 1 ) PRINT '[ALERT] One or more Server roles has a typical member'
			END
*/

-- Process missing Logins DECLARE @DryRun int = 1, @currentLogin varchar(100), @CurrentAction varchar(100)
			IF( (SELECT COUNT(*) FROM #MissingLogins) > 0)
				BEGIN
					WHILE EXISTS ( SELECT TOP 1 * FROM #MissingLogins WHERE IsProcessed = 0 )
					BEGIN
						SELECT TOP 1 @CurrentLogin = LOGINNAME, @CurrentAction = Action FROM #MissingLogins WHERE IsProcessed = 0
						IF( @DryRun = 1 )
							BEGIN
								PRINT '/* ADD */ '+ @CurrentAction
							END
						ELSE
							BEGIN
								EXEC(@CurrentAction);
							END
						UPDATE #MissingLogins SET IsProcessed = 1 WHERE IsProcessed = 0 AND LOGINNAME = @CurrentLogin AND Action = @CurrentAction
					END
				END

--Removing extra logins will be handled by 90 audit that have been locked or have no permisions.

--process missing instance permissions  DECLARE @DryRun int = 1, @currentLogin varchar(100), @CurrentAction varchar(100)
--ADD
			IF( (SELECT COUNT(*) FROM #MissingPermission WHERE ActionType = 'ADD-Server' AND IsProcessed = 0) > 0 )
				BEGIN
					WHILE EXISTS ( SELECT TOP 1 * FROM #MissingPermission WHERE ActionType = 'ADD-Server' AND IsProcessed = 0 )
					BEGIN
						SELECT TOP 1 @CurrentLogin = LOGINNAME, @CurrentAction = Action FROM #MissingPermission WHERE ActionType = 'ADD-Server' AND IsProcessed = 0
						IF( @DryRun = 1 )
							BEGIN
								PRINT '/* ADD-Server */ '+ @CurrentAction
							END
						ELSE
							BEGIN
								EXEC(@CurrentAction);
							END
						UPDATE #MissingPermission SET IsProcessed = 1 WHERE ActionType = 'ADD-Server' AND IsProcessed = 0 AND LOGINNAME = @CurrentLogin AND Action = @CurrentAction
					END
				END

--process missing instance permissions  DECLARE @DryRun int = 1, @currentLogin varchar(100), @CurrentAction varchar(100)
--ADD
			IF( (SELECT COUNT(*) FROM #MissingPermission WHERE ActionType = 'ADD-Instance' AND IsProcessed = 0) > 0 )
				BEGIN
					WHILE EXISTS ( SELECT TOP 1 * FROM #MissingPermission WHERE ActionType = 'ADD-Instance' AND IsProcessed = 0 )
					BEGIN
						SELECT TOP 1 @CurrentLogin = LOGINNAME, @CurrentAction = Action FROM #MissingPermission WHERE ActionType = 'ADD-Instance' AND IsProcessed = 0
						IF( @DryRun = 1 )
							BEGIN
								PRINT '/* ADD-Instance */ '+ @CurrentAction
							END
						ELSE
							BEGIN
								EXEC(@CurrentAction);
							END
						UPDATE #MissingPermission SET IsProcessed = 1 WHERE ActionType = 'ADD-Instance' AND IsProcessed = 0 AND LOGINNAME = @CurrentLogin AND Action = @CurrentAction
					END
				END
--process missing instance permissions  DECLARE @DryRun int = 1, @currentLogin varchar(100), @CurrentAction varchar(100)
--ADD
			IF( (SELECT COUNT(*) FROM #MissingPermission WHERE ActionType = 'ADD-Database' AND IsProcessed = 0) > 0 )
				BEGIN
					WHILE EXISTS ( SELECT TOP 1 * FROM #MissingPermission WHERE ActionType = 'ADD-Database' AND IsProcessed = 0 )
					BEGIN
						SELECT TOP 1 @CurrentLogin = LOGINNAME, @CurrentAction = Action FROM #MissingPermission WHERE ActionType = 'ADD-Database' AND IsProcessed = 0
						IF( @DryRun = 1 )
							BEGIN
								PRINT '/* ADD-Database */ '+ @CurrentAction
							END
						ELSE
							BEGIN
								EXEC(@CurrentAction);
							END
						UPDATE #MissingPermission SET IsProcessed = 1 WHERE ActionType = 'ADD-Database' AND IsProcessed = 0 AND LOGINNAME = @CurrentLogin AND Action = @CurrentAction
					END
				END
/* REMOVE
			IF( (SELECT COUNT(*) FROM #MissingPermission WHERE ActionType = 'REMOVE') > 0)
				BEGIN
					WHILE EXISTS ( SELECT TOP 1 * FROM #MissingPermission WHERE ActionType = 'REMOVE' AND IsProcessed = 0 )
					BEGIN
						SELECT TOP 1 @CurrentLogin = LOGINNAME, @CurrentAction = Action FROM #MissingPermission WHERE ActionType = 'REMOVE' AND IsProcessed = 0
						IF( @DryRun = 1 )
							BEGIN
								PRINT '/* DEL */ '+ @CurrentAction
							END
						ELSE
							BEGIN
								EXEC(@CurrentAction);
							END
						UPDATE #MissingPermission SET IsProcessed = 1 WHERE ActionType = 'REMOVE' AND IsProcessed = 0 AND LOGINNAME = @CurrentLogin AND Action = @CurrentAction
					END
				END
 
 */

END;
