USE DBA;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[deploy].[SetSQLAuthLogin]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [deploy].[SetSQLAuthLogin] AS' 
END
GO
ALTER PROCEDURE [deploy].[SetSQLAuthLogin] ( @notify int = 0, @SQLLogin varchar(100) = '', @dryRun int = 1, @ForceReset int = 0, @verbose int = 0 )
as
BEGIN
	-- EXEC [deploy].[SetSQLAuthLogin] @dryRun =0
	-- EXEC [deploy].[SetSQLAuthLogin] @verbose = 1
	set nocount on

	-- DECLARE @dryRun int = 1, @verbose int = 0
	DECLARE @sqlCMD nvarchar(max), @ProductVersion INT
	SELECT @ProductVersion = convert(int, LEFT(convert(varchar(100),SERVERPROPERTY('ProductVersion')),charindex('.',convert(varchar(100),SERVERPROPERTY('ProductVersion')))-1 ))

	IF OBJECT_ID('tempdb..#SQLAuthLogin') IS NOT NULL
		DROP TABLE #SQLAuthLogin

	CREATE table #SQLAuthLogin(
		SQLAuthLogin nvarchar(max),
		HashedPassword nvarchar(max),
		loginSID varbinary(85),
		LoginProcessed int
		)

	INSERT INTO #SQLAuthLogin (SQLAuthLogin,HashedPassword, loginSID, LoginProcessed )
	VALUES
		--('SQLAuthLogin', 'HashedPassword', 'LoginSID' )
		('SSRS-DBA-Reports', '0x02009E6A3F8EBC0F1FE02414B6CAB805D1F0AB1B86A0D59DA786D27B13A4B6959FB8CE741ED7DFE41A6118564DA7717EB29BFD8784754D66B5FBF1011B0FAA9A5021868CD912', 0x7FDA514F92CF6A499BAF68AFD169BB61, 0 ),
		('dbDirectorySvc', '0x0200040BB27E639CEA2EA7DDCF480603209BFD9D34E6C49D97AB525043B6942A229613AC995C17D018D0F2ED3CB8FC4CD128F4DDD75021FD11B0AA0E0CD207B9A3F4E648B441', 0x2370097A8EE55747A448609D66F6BC67, 0); --- This account is used for linked serves from DBA-SQLPRD-01

	IF OBJECT_ID('tempdb..#SQLAuthPermission') IS NOT NULL
		DROP TABLE #SQLAuthPermission

	CREATE table #SQLAuthPermission(
		SQLAuthLogin nvarchar(max),
		DatabaseName nvarchar(max),
		DatabasePermission nvarchar(max),
		PermissionProcessed int
		)
		
	INSERT INTO #SQLAuthPermission (SQLAuthLogin, DatabaseName, DatabasePermission, PermissionProcessed )
	VALUES
		--('SQLAuthLogin', 'DatabaseName', 'DatabasePermission' )
		('SSRS-DBA-Reports', 'InventoryDWH', 'db_datareader', 0),
		('SSRS-DBA-Reports', 'MASTER', 'db_datareader', 0),
		('SSRS-DBA-Reports', 'MSDB', 'db_datareader', 0),
		('SSRS-DBA-Reports', 'DBA', 'db_datareader', 0),
		('dbDirectorySvc', 'DBA', 'db_datareader', 0);

	DECLARE @CurrentLogin varchar(max), @CurrentHashed varchar(max), @CurrentSID varbinary(max)
	DECLARE @DatabaseName varchar(max), @DatabasePermission varchar(max)
	WHILE EXISTS ( SELECT TOP 1 SQLAuthLogin FROM #SQLAuthLogin WHERE LoginProcessed = 0  )
		BEGIN
			-- Leaving SID login for histarical purposes....
			SELECT TOP 1 @CurrentLogin = SQLAuthLogin, @CurrentHashed = HashedPassword, @CurrentSID = loginSID FROM #SQLAuthLogin WHERE LoginProcessed = 0
			IF EXISTS (SELECT * FROM master.sys.sql_logins WHERE name = @CurrentLogin and SID = @CurrentSID )
				BEGIN
					PRINT 'SQL Auth Account: ['+ @CurrentLogin +'] exists with the correct SID'
					SELECT @sqlCMD = '' --placeholder for nothing 
				END
			ELSE IF EXISTS ( SELECT * FROM master.sys.sql_logins WHERE name != @CurrentLogin and SID = @CurrentSID )
				BEGIN
					PRINT 'The SID is in use for SQL Auth Account: ['+ @CurrentLogin +']'
					SELECT @sqlCMD = 'SELECT * FROM master.sys.sql_logins WHERE name != '''+ @CurrentLogin +''' and SID = '+ CONVERT(NVARCHAR(MAX),@CurrentSID, 1) +';'
				END
			ELSE IF EXISTS ( SELECT * FROM master.sys.sql_logins WHERE name = @CurrentLogin and SID != @CurrentSID )
				BEGIN
					PRINT 'SQL Auth Account: ['+ @CurrentLogin +'] exists with the wrong SID'
						--SELECT @CurrentSID,* FROM master.sys.sql_logins WHERE name = @CurrentLogin
					PRINT 'DROP & Recreate SQL Auth Account: '
					SELECT @sqlCMD = '
						DROP LOGIN ['+ @CurrentLogin +'];
						CREATE LOGIN ['+ @CurrentLogin +'] 
						WITH PASSWORD='+ @CurrentHashed +' HASHED, 
						CHECK_POLICY=OFF, SID='+ CONVERT(NVARCHAR(MAX),@CurrentSID, 1) +';'
				END
			ELSE
				BEGIN
					PRINT 'SQL Auth Account: ['+ @CurrentLogin +'] does not exist and the SID is available'
					SELECT @sqlCMD ='
					CREATE LOGIN ['+ @CurrentLogin +'] 
					WITH PASSWORD='+ @CurrentHashed +' HASHED, 
					CHECK_POLICY=OFF, SID='+ CONVERT(NVARCHAR(MAX),@CurrentSID, 1) +';'
				END

			IF( @dryRun = 1 )
				BEGIN
					PRINT '[DryRun]'
					PRINT @sqlCMD
				END
			ELSE
				BEGIN
					IF( @verbose = 1 ) PRINT @sqlCMD;
					EXEC( @sqlCMD); 
				END

			WHILE EXISTS ( SELECT TOP 1 SQLAuthLogin FROM #SQLAuthPermission WHERE PermissionProcessed = 0  AND SQLAuthLogin = @CurrentLogin )
				BEGIN
				
					SELECT TOP 1 @DatabaseName = DatabaseName, @DatabasePermission = DatabasePermission FROM #SQLAuthPermission WHERE PermissionProcessed = 0 AND SQLAuthLogin = @CurrentLogin 
					--Does TargetDB exist on this instance
					IF EXISTS ( SELECT name FROM sys.databases where name = @DatabaseName )
						BEGIN
							SELECT @sqlCMD =  '
							/* Does the account exist in targetDB */
								USE ['+ @DatabaseName +']
								IF NOT EXISTS ( SELECT * FROM sys.database_permissions
												WHERE grantee_principal_id = USER_ID('''+ @CurrentLogin +''') AND permission_name = ''CONNECT'')
									BEGIN
										PRINT ''['+ @DatabaseName +'] Account Missing ''
										IF( '+ convert(char(1),@DryRun) +' = 1 ) -- DryRun
											BEGIN
												PRINT ''[DryRun] CREATE USER ['+ @CurrentLogin +'] FOR LOGIN ['+ @CurrentLogin +'];''
											END
										ELSE
											BEGIN
												CREATE USER ['+ @CurrentLogin +'] FOR LOGIN ['+ @CurrentLogin +'];
											END	
									END
								ELSE IF NOT EXISTS( SELECT * FROM sysusers WHERE [name] = '''+ @CurrentLogin +''' AND SID = '+ convert(nvarchar(90), @CurrentSID, 1) +' )
									BEGIN
										PRINT ''['+ @DatabaseName +'] SID MISMATCH ''
										IF( '+ convert(char(1),@DryRun) +' = 1 ) -- DryRun
											BEGIN
												PRINT ''[DryRun] DROP USER ['+ @CurrentLogin +']'';
												PRINT ''[DryRun] CREATE USER ['+ @CurrentLogin +'] FOR LOGIN ['+ @CurrentLogin +'];''
											END
										ELSE
											BEGIN
												DROP USER ['+ @CurrentLogin +'];
												CREATE USER ['+ @CurrentLogin +'] FOR LOGIN ['+ @CurrentLogin +'];
											END
									END';
							IF( @verbose = 1 ) PRINT @sqlCMD;

							EXEC( @sqlCMD); 

							SELECT @sqlCMD = '
							/* Does the account have permission */
								USE ['+ @DatabaseName +']
								IF NOT EXISTS ( SELECT * FROM sys.database_role_members
												WHERE role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = '''+ @DatabasePermission +'''
												AND member_principal_id = USER_ID('''+ @CurrentLogin +''')) )
									BEGIN
										PRINT ''['+ @DatabaseName +'] Permission Missing ''
										IF( '+ convert(char(1),@DryRun) +' = 1 ) -- DryRun
											BEGIN
												'+ CASE WHEN @ProductVersion < 10 THEN 
												'PRINT ''[Dryrun] ALTER ROLE ['+ @DatabasePermission +'] ADD MEMBER ['+ @CurrentLogin +'];''' 
												ELSE 
												'PRINT ''[DryRun] EXEC sp_addrolemember '''''+ @DatabasePermission +''''', '''''+ @CurrentLogin +''''';'''
												 END +'
											END
										ELSE
											BEGIN
												'+ CASE WHEN @ProductVersion < 10 THEN 
												'ALTER ROLE ['+ @DatabasePermission +'] ADD MEMBER ['+ @CurrentLogin +'];' 
												ELSE
												'EXEC sp_addrolemember '''+ @DatabasePermission +''', '''+ @CurrentLogin +''';'
												END +'
											END
									END';

							IF( @verbose = 1 ) PRINT @sqlCMD;

							EXEC( @sqlCMD); 
						END
					ELSE
						BEGIN
							IF( @verbose = 1 ) PRINT 'Database ['+ @DatabaseName +'] does not exist on this instance.' 	
						END

					UPDATE #SQLAuthPermission SET PermissionProcessed = 1 WHERE SQLAuthLogin = @CurrentLogin AND DatabaseName = @DatabaseName AND DatabasePermission = @DatabasePermission
				END-- process permissions

			UPDATE #SQLAuthLogin SET LoginProcessed = 1 WHERE SQLAuthLogin = @CurrentLogin
		END; -- Process Logins

	/* Disable SA account */
		SELECT @sqlCMD = '
		/* Disable SA account */
			USE [MASTER]
			IF EXISTS ( select * from sys.server_principals where name = ''sa'' and Is_Disabled = 0  )
				BEGIN
					PRINT ''SQL Auth Account: [SA] exists and is not Disabled''
					IF( '+ convert(char(1), @DryRun) +' = 1 ) -- DryRun
						BEGIN
							'+ CASE WHEN @ProductVersion < 10 THEN 
							'PRINT ''[Dryrun] ALTER LOGIN [SA] DISABLE;''' 
							ELSE 
							'PRINT ''[Dryrun] ALTER LOGIN [SA] DISABLE;'''
								END +'
						END
					ELSEIF( '+ convert(char(1), @ForceReset) +' = 1) -- ForceReset
						BEGIN 
							'+ CASE WHEN @ProductVersion < 10 THEN 
							'ALTER LOGIN [SA] DISABLE;' 
							ELSE
							'ALTER LOGIN [SA] DISABLE;'
							END +'
						END
				END
			ELSE
				BEGIN
					PRINT ''SQL Auth Account: [SA] is disabled.''
				END';

		IF( @verbose = 1 ) PRINT @sqlCMD;

		EXEC( @sqlCMD);

END;