USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[getLinkedServer]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[getLinkedServer] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[getLinkedServer] ( @lsName varchar(128) = '', @RetentionDays INT = 30, @DryRun TINYINT = 1 )
AS
BEGIN
	--  EXEC [info].[getLinkedServer] @dryRun = 0
	--  EXEC [info].[getLinkedServer] @lsName = 'UTPROD_RO', @dryRun = 0

	--creating a temporary table
	IF OBJECT_ID('tempdb..#output') IS NOT NULL
		DROP TABLE #ls;
	CREATE TABLE #ls (
		[Name] [sysname] NOT NULL,
		[Product] [sysname] NOT NULL,
		[Provider] [sysname] NOT NULL,
		[Data_source] [nvarchar](4000) NULL,
		[Provider_string] [nvarchar](4000) NULL,
		[Catalog] [sysname] NULL,
		[Uses_self_credential] [bit] NULL,
		[Remote_name] [sysname] NULL,
		[Modify_date] [datetime] NULL,
		[Status] [nvarchar](4000) NULL,
		--[Comments] [nvarchar](128) NULL,
		[HarvestDate] DateTime
	) WITH (DATA_COMPRESSION = PAGE);
    
	--inserting info in temporary table
	IF( @lsName = '' )
		BEGIN
			INSERT INTO #ls
			SELECT  a.[name], [product], [provider], [data_source], 
				[provider_string], [catalog], [uses_self_credential], [remote_name], b.[Modify_date], '' AS [Status], GetDate() as [HarvestDate]
			FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
			LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
			WHERE is_linked = 1;
		END
	ELSE
		BEGIN
			INSERT INTO #ls
			SELECT  a.[name], [product], [provider], [data_source], 
				[provider_string], [catalog], [uses_self_credential], [remote_name], b.[Modify_date], '' AS [Status], GetDate() as [HarvestDate]
			FROM sys.Servers a
			LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
			LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
			WHERE is_linked = 1 AND a.[name] = @lsName;
		END;
    
    /** TEST each linkedServer  **/
    DECLARE @CurrentName sysname;
    WHILE exists (SELECT [name] FROM  #ls where status = '')
    BEGIN
	    begin try 
		    SELECT @CurrentName = [name] FROM  #ls where status = ''
		    EXEC sp_testlinkedserver @CurrentName;
		    UPDATE #ls SET [STATUS] = 'Valid' WHERE [name] = @CurrentName
	    end try 
	    begin catch 
		    UPDATE #ls SET [STATUS] = replace(error_Message(),'''','') WHERE [name] = @CurrentName
	    end catch;
    END;


	IF( @dryRun = 0 )
		BEGIN
			MERGE info.LinkedServer AS old
			USING ( SELECT [name], [product], [provider], [data_source], 
							[provider_string], [catalog], [uses_self_credential], 
							[remote_name], [Modify_date], [Status], [HarvestDate]
					FROM #ls ) AS new( name,
										product,
										provider,
										data_source,
										provider_string,
										catalog,
										uses_self_credential,
										remote_name,
										Modify_date,
										Status,
										--Comments,
										HarvestDate )
			ON new.name = old.name AND old.uses_self_credential = new.uses_self_credential
			WHEN MATCHED AND ( old.product <> new.product OR old.provider <> new.provider OR old.data_source <> new.data_source OR 
							   old.provider_string <> new.provider_string OR old.catalog <> new.catalog OR
							   old.remote_name <> new.remote_name  OR 
							   old.Modify_date <> new.Modify_date OR old.Status <> new.Status OR old.HarvestDate <> new.HarvestDate
							 ) THEN
				UPDATE SET 
					old.product = new.product, old.provider = new.provider, old.data_source = new.data_source, 
					old.provider_string = new.provider_string, old.catalog = new.catalog,
					old.remote_name = new.remote_name, 
					old.Modify_date = new.Modify_date, old.Status = new.Status, old.HarvestDate = new.HarvestDate
			WHEN NOT MATCHED BY TARGET THEN
				INSERT( name,
						product,
						provider,
						data_source,
						provider_string,
						catalog,
						uses_self_credential,
						remote_name,
						Modify_date,
						Status,
						--Comments,
						HarvestDate )
				VALUES( new.name,
						new.product,
						new.provider,
						new.data_source,
						new.provider_string,
						new.catalog,
						new.uses_self_credential,
						new.remote_name,
						new.Modify_date,
						new.Status,
						--new.Comments,
						new.HarvestDate )
			WHEN NOT MATCHED by SOURCE THEN 
				DELETE;

		END;
	ELSE
		BEGIN
		  	SELECT [name], [product], [provider], [data_source], 
					[provider_string], [catalog], [uses_self_credential], 
					[remote_name], [Modify_date], [Status], [HarvestDate] as [DryRunDate]
			FROM #ls
		END;
END;