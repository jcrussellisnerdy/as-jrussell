USE DBA
GO
/****** Object:  StoredProcedure [info].[getObjectUsage]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[getObjectUsage]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getObjectUsage] AS RETURN 0;';
END
GO

ALTER PROCEDURE info.getObjectUsage ( @TargetDB varchar(100) = '', @dryRun int = 1 )
AS
BEGIN
	-- EXEC [info].[getObjectUsage] @TargetDB = 'DBA'
	-- EXEC [info].[getObjectUsage] @DryRun = 0
	DECLARE @selectSQL varchar(max)

	IF OBJECT_ID('tempdb..#Databases') IS NOT NULL
		DROP TABLE #Databases;
	CREATE TABLE #Databases (dbName varchar(150), processTables bit, ProcessProcedures bit) WITH(DATA_COMPRESSION=PAGE);

	INSERT INTO #Databases
		select [name], 0, 0
		from sys.databases (nolock)
		where [name] not in ('tempdb') and State_desc not in ('RESTORING')
		order by database_id

	IF( @dryRun = 1 ) select * from #Databases

	WHILE EXISTS (SELECT * FROM #Databases WHERE processTables = 0 and ProcessProcedures = 0)
		BEGIN
			SELECT TOP 1 @TargetDB = dbName FROM #Databases WHERE ProcessTables = 0 and ProcessProcedures = 0

			IF OBJECT_ID('tempdb..#Tables') IS NOT NULL
				DROP TABLE #Tables;
			CREATE TABLE #Tables (	
				DatabaseName varchar(150), 
				SchemaName varchar(100),
				TableName varchar(100),
				CreateDate DateTime,
				ModifyDate DateTime,
				maxUserSeek DateTime,
				maxUserScan DateTime,
				maxUserLookup DateTime,
				maxUserUpdate DateTime,
				DiscoverDate DateTime,
				HarvestDate DateTime
			) WITH(DATA_COMPRESSION=PAGE);

			print 'Process Tables '+ @targetDB
				SET @selectSQL = 'USE ['+ @TargetDB +'];
				SELECT '''+ @TargetDB +''',	SCHEMA_NAME(schema_ID),	T.name, T.create_date, T.modify_date,  
					max(last_user_seek), max(last_user_scan), max(last_user_lookup), Max(last_user_update), getDate(), getDate()
				FROM sys.tables as T 
				LEFT JOIN sys.dm_db_index_usage_stats AS IUS 
					ON (T.object_id = IUS.object_id)
				GROUP BY SCHEMA_NAME(schema_ID), T.Name, T.Create_date, T.modify_date'

			INSERT INTO #Tables
				EXEC(@selectSQL)

			 IF( @dryRun = 0 )
				 BEGIN
					MERGE info.TableUsage AS old
					USING ( SELECT DatabaseName, SchemaName, TableName,	CreateDate,	ModifyDate,
								maxUserSeek, maxUserScan, maxUserLookup, maxUserUpdate, DiscoverDate, HarvestDate
							FROM #Tables ) AS new ( DatabaseName, SchemaName, TableName,	CreateDate,	ModifyDate,
													maxUserSeek, maxUserScan, maxUserLookup, maxUserUpdate, DiscoverDate, HarvestDate  )
					ON new.DatabaseName = old.DatabaseName AND new.SchemaName = old.SchemaName AND new.TableName = old.TableName
					WHEN MATCHED AND ( old.CreateDate <> new.CreateDate OR old.ModifyDate <> new.ModifyDate OR old.maxUserSeek <> new.maxUserSeek OR
										old.maxUserScan <> new.maxUserScan OR old.maxUserLookup <> new.maxUserLookup OR 
										old.maxUserUpdate <> new.maxUserUpdate OR IsNull(old.HarvestDate,'') <> new.HarvestDate
									 ) THEN
						UPDATE SET 
							old.CreateDate = new.CreateDate, old.ModifyDate = new.ModifyDate, old.maxUserSeek = new.maxUserSeek,
							old.maxUserScan = new.maxUserScan, old.maxUserLookup = new.maxUserLookup, 
							old.maxUserUpdate = new.maxUserUpdate, old.HarvestDate = new.HarvestDate,
							old.DiscoverDate = CASE WHEN old.DiscoverDate IS NULL THEN new.DiscoverDate ELSE old.DiscoverDate END
					WHEN NOT MATCHED THEN
						INSERT( DatabaseName, SchemaName, TableName, CreateDate, ModifyDate, 
								maxUserSeek, maxUserScan, maxUserLookup, maxUserUpdate, DiscoverDate, HarvestDate )
						VALUES( new.DatabaseName, new.SchemaName, new.TableName, new.CreateDate, new.ModifyDate, 
								new.maxUserSeek, new.maxUserScan, new.maxUserLookup, new.maxUserUpdate, DiscoverDate, HarvestDate );
					-- WHEN NOT MATCHED by SOURCE THEN 
					--	DELETE;
				END
			ELSE
				BEGIN
					PRINT @selectSQL
					SELECT * FROM #Tables
				END

			Update #Databases SET ProcessTables = 1  WHERE dbName = @TargetDB 

			IF OBJECT_ID('tempdb..#Procedures') IS NOT NULL
				DROP TABLE #Procedures;
			CREATE TABLE #Procedures ( 
				DatabaseName varchar(150), 
				SchemaName varchar(100),
				ProcedureName varchar(100),
				CreateDate DateTime,
				ModifyDate DateTime,
				lastExecDate DateTime,
				DiscoverDate DateTime,
				HarvestDate DateTime
			) WITH(DATA_COMPRESSION=PAGE);

			-- DECLARE @selectSQL varchar(max), @targetDB varchar(100) ='DBA'
			print 'Process Stored Procedures'
			SET @selectSQL = 'USE ['+ @TargetDB +'];
				SELECT '''+ @TargetDB +''', schema_name(Schema_ID),
					P.name, P.create_date, P.modify_date, MAX(EPS.last_execution_time), getDate(), getDate()
				FROM ['+ @TargetDB +'].sys.objects AS P LEFT JOIN sys.dm_exec_procedure_stats AS EPS ON (P.object_id = EPS.object_id)
				WHERE P.type in (N''P'', N''PC'')
				group by SCHEMA_NAME(schema_ID), P.name, P.create_date, P.modify_date
				order by P.name'

			INSERT INTO #Procedures
				EXEC(@selectSQL)

			IF( @dryRun = 0 )
				BEGIN

		  			MERGE info.ProcedureUsage AS old
					USING ( SELECT DatabaseName, SchemaName, ProcedureName,
									CreateDate,	ModifyDate,	LastExecDate, DiscoverDate, HarvestDate
							FROM #Procedures
							) AS new( DatabaseName,	SchemaName,	ProcedureName,	
										CreateDate,	ModifyDate,	LastExecDate, DiscoverDate, HarvestDate )
					ON new.DatabaseName = old.DatabaseName AND new.SchemaName = old.SchemaName AND new.ProcedureName = old.ProcedureName
					WHEN MATCHED AND ( old.CreateDate <> new.CreateDate OR old.ModifyDate <> new.ModifyDate OR 
									   old.LastExecDate <> new.LastExecDate OR IsNull(old.HarvestDate,'') <> new.HarvestDate
									 ) THEN
						UPDATE SET 
							old.CreateDate = new.CreateDate, old.ModifyDate = new.ModifyDate, 
							old.LastExecDate = new.LastExecDate, old.HarvestDate = new.HarvestDate,
							old.DiscoverDate = CASE WHEN old.DiscoverDate IS NULL THEN new.DiscoverDate ELSE old.DiscoverDate END
					WHEN NOT MATCHED THEN
						INSERT( DatabaseName, SchemaName, ProcedureName,
								CreateDate,	ModifyDate,	LastExecDate, DiscoverDate, HarvestDate )
						VALUES( new.DatabaseName, new.SchemaName, new.ProcedureName,
								new.CreateDate,	new.ModifyDate,	new.LastExecDate, new.DiscoverDate, new.HarvestDate );
					-- WHEN NOT MATCHED by SOURCE THEN 
					--	DELETE;
				END
			ELSE
				BEGIN
					PRINT @selectSQL
					SELECT * FROM #Procedures
				END
			Update #Databases SET ProcessProcedures = 1  WHERE dbName = @TargetDB 

		END
END;
