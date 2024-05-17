USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[SetSystemConfig]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[SetSystemConfig] AS RETURN 0;' 
END
GO

ALTER PROCEDURE [info].[SetSystemConfig] 
	@key varchar(255),
	@val varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;     

	update info.systemconfig
	set confvalue = @val
	where confkey = @key;

	if( @@rowcount = 0 )
	begin
		insert into info.systemconfig
		(confkey, confvalue)
			values
		(@key, @val);
	end
END
GO

