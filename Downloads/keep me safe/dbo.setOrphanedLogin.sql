USE DBA
GO
/****** Object:  StoredProcedure [dbo].[setOrphanedLogin]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[setOrphanedLogin]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[setOrphanedLogin] AS RETURN 0;';
END
GO

ALTER PROCEDURE dbo.setOrphanedLogin ( @TargetDB varchar(100) = '', @TargetUser varchar(100) = '', @dryRun int = 1 )
AS
BEGIN
-- EXEC [dbo].[setOrphanedLogin] @TargetDB = 'PRL_HUNTINGTON_5392_STG', @dryRun = 0
-- EXEC [dbo].[setOrphanedLogin] @dryRun = 0

	DECLARE @DynamicSQL nvarchar(max), @DropCommand nvarchar(max), @CreateCommand nvarchar(max)

	IF OBJECT_ID('tempdb..#DatabaseInfo ') IS NOT NULL
		DROP TABLE #DatabaseInfo ;
	CREATE TABLE #DatabaseInfo 
	(
		DatabaseName VARCHAR(128), 
		ProcessDatabase bit
	) WITH (DATA_COMPRESSION=PAGE);

	IF OBJECT_ID('tempdb..#DatabaseUserInfo ') IS NOT NULL
		DROP TABLE #DatabaseUserInfo ;
	CREATE TABLE #DatabaseUserInfo 
	(
		DatabaseName VARCHAR(128),
		UserName VARCHAR(128),
		DBUserSID uniqueidentifier,
		ServerLogonSID uniqueidentifier,
		DropCommand VARCHAR(128),
		CreateCommand VARCHAR(MAX),
		ProcessUser bit
	) WITH (DATA_COMPRESSION=PAGE);

	IF ( @TargetDB = '' ) -- Get all Database info
		BEGIN
			INSERT INTO #DatabaseInfo ( DatabaseName, ProcessDatabase )
				select [name], 0
				from sys.databases (nolock)
				where [name] not in ('tempdb')
				order by database_id
		END
	ELSE
		BEGIN
			INSERT INTO #DatabaseInfo ( DatabaseName, ProcessDatabase )
				select [name], 0
				from sys.databases (nolock)
				where [name] not in ('tempdb') AND [name] = @TargetDB
		END
	IF( @dryRun = 1 ) 
	BEGIN
		SELECT * from  #DatabaseInfo
	END


	WHILE EXISTS (SELECT * FROM #DatabaseInfo WHERE ProcessDatabase = 0)
		BEGIN
			SELECT TOP 1 @TargetDB = DatabaseName FROM #DatabaseInfo WHERE ProcessDatabase = 0

			SELECT @DynamicSQL = '
			insert into #DatabaseUserInfo
			SELECT ''['+ @TargetDB +']'',DB.name, DB.sid, SL.sid, ''DROP LOGIN [''+ DB.name +'']'' as DropCMD, 
			''CREATE LOGIN [''+ DB.[name] +''] WITH PASSWORD=0x''+ CONVERT(nvarchar(max), SL.password_hash, 2)+N'' HASHED, CHECK_POLICY=OFF, ''+  N''SID=0x''+CONVERT(nvarchar(max), DB.[sid], 2)+N'';'' as CreateCMD,
			0 as ProcessBit
			--,* 
			FROM ['+ @TargetDB +']..sysusers  as DB
			LEFT Join MASTER.sys.sql_logins as SL on (SL.name collate SQL_Latin1_General_CP1_CI_AS = DB.name )
			--LEFT JOIN master.sys.server_principals AS SP ON ( SP.[sid] = SL.[sid] )
			where DB.sid != SL.sid'
			
			IF( @dryRun = 1 ) 
			BEGIN
				PRINT '/** '+ @TargetDB +' **/'
				PRINT @DynamicSQL
			END

			EXEC(@DynamicSQL)

			UPDATE #DatabaseInfo SET  ProcessDatabase = 1 WHERE DatabaseName = @TargetDB; 

			--Execute the drop and create commands as we get them to shorten the list for other databases.
			WHILE EXISTS (SELECT * FROM #DatabaseUserInfo WHERE ProcessUser = 0)
				BEGIN
					SELECT TOP 1 @TargetUser = UserName,  @DropCommand = DropCommand, @CreateCommand = CreateCommand FROM #DatabaseUserInfo WHERE ProcessUser = 0

					IF( @dryRun = 1 ) 
						BEGIN
							PRINT @DropCommand
						END
					ELSE
						BEGIN
							EXEC(@DropCommand)
						END


					IF( @dryRun = 1 ) 
						BEGIN
							PRINT @CreateCommand
						END
					ELSE
						BEGIN
							EXEC(@CreateCommand)
						END

					UPDATE #DatabaseUserInfo SET ProcessUser = 1 WHERE UserName = @TargetUser;

				END;

		END

	IF( @dryRun = 1 ) 
	BEGIN
		select * from  #DatabaseUserInfo
	END

/*

DROP LOGIN [RFPLdbDurga]

CREATE LOGIN [RFPLdbDurga] WITH PASSWORD=0x0200F1101D097243E51D4CEA9A462B3F81978BAAA1F7358451BC9D0BFE3276027923C8318BC8EEC1A1682CC6EE9F0388777C96FE2366703AC46DD38910D59879C74D2EC3667E HASHED, CHECK_POLICY=OFF, SID=0x4FED9BB279591F49BFB1F335CFDA9C79;

*/

END;

/* Drop older version */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[setOrphanedSID]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'DROP PROCEDURE [dbo].[setOrphanedSID];';
END