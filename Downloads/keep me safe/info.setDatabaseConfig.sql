USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[SetDatabaseConfig]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[SetDatabaseConfig] AS RETURN 0;' 
END
GO

ALTER PROCEDURE [info].[SetDatabaseConfig] 
	@dbName varchar(100),
	@key varchar(255),
	@val varchar(1024),
	@dryRun int = 1
AS
BEGIN
	SET NOCOUNT ON;     
	IF(@dryRun = 0)
	BEGIN
		update info.databaseconfig
		set confvalue = @val
		where confkey = @key and databaseName = @dbname;

		if( @@rowcount = 0 )
		begin
			insert into info.databaseconfig
			(databasename, confkey, confvalue)
				values
			(@dbname, @key, @val);
		end
	END
	ELSE
	BEGIN
		PRINT '[DryRun] - No values modified';
	END
END
;
GO
