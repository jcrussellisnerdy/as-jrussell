USE [DBA]
GO
/****** Object:  StoredProcedure [ddbma].[Expire]    Script Date: 9/13/2019 12:23:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ddbma].[ExpireImage]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ddbma].[ExpireImage] AS RETURN 0;' 
END
GO

ALTER PROCEDURE [ddbma].[ExpireImage]
	@DDHost						varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_HOST - Data Domain Host Name
	@DDBoostUser				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DD_USER - DD Boost User
	@DDStorageUnit				varchar (50)	= NULL,					-- -a NSR_DFA_SI_DEVICE_PATH - Storage Unit Name
	@ClientHost					varchar (50)	= NULL,	
	@SQLInstanceName 			varchar (50)  	= NULL,
	@SaveSet					varchar (100)	= NULL,					-- -a specifies a filter on the save set name for display and deletes both.
	@StartTime					varchar (30)	= NULL,					-- -b specifies the lower boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@EndTime	 				varchar (30)	= NULL,					-- -e specifies the upper boundary of the expiry time of the save set - Hr(24 hour format):Min:Sec Month DD, YYYY
	@AppType		 			varchar (10)  	= 'mssql',				-- -n specifies the application type
	@ConfigFile					varchar (255)	= NULL,					-- -z specifies the configuration file path
	@Clean						bit				= NULL,					-- -c cleans up the corrupted or invalid catalogue information
	@DelExpired					bit				= NULL,					-- -r deletes the expired savesets 
	@Verbose					bit				= 1,					-- -v prints the verbose output on the console
	@DryRun						bit				= 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Check required parameters
	if @AppType is null raiserror('Null values not allowed for AppType', 16, 1)
	--if @ConfigFile is null raiserror('Null values not allowed for ConfigFile', 16, 1)

		
	declare @ddbmacmd nvarchar(4000);
	declare @cur cursor;
	declare @line nvarchar(4000);
	declare @rcode bit;
	declare @rreturned bit;
	
	-- Set return code to no errors and records returned to 0
	SET @rcode = 0;
	SET @rreturned = 0;
	
	-- Base DD Boost Command
	SET @ddbmacmd = 'echo Y | ddbmexptool.exe'
	if @DelExpired = 1
		BEGIN
			Set @ddbmacmd = @ddbmacmd + ' -d'
		END
	ELSE 
		BEGIN
			Set @ddbmacmd = @ddbmacmd + ' -k'
		END

	if @Verbose is not null 
	Begin 
		if @Verbose = 1 Set @ddbmacmd = @ddbmacmd + ' -v'
	End 

	Set @ddbmacmd = @ddbmacmd + ' -n ' + @AppType + 
	--' -z "' + @ConfigFile + '"'
	' -a "DDBOOST_USER=' + @DDBoostUser + '"' +
	' -a "DEVICE_PATH=' + @DDStorageUnit + '"' + 
	' -a "DEVICE_HOST=' + @DDHost + '"' +
	' -a "CLIENT='+ @ClientHost +'"'

	-- Optional DD Boost command switches
	if @SaveSet is not null Set @ddbmacmd = @ddbmacmd + ' -a ' + @SaveSet
	if @StartTime is not null Set @ddbmacmd = @ddbmacmd + ' -b "' + @StartTime + '"'
	if @EndTime is not null Set @ddbmacmd = @ddbmacmd + ' -e "' + @EndTime + '"' 

	/* Deprecated */
	--if @Clean is not null
	--Begin 
	--	if @Clean = 1 Set @ddbmacmd = @ddbmacmd + ' -c '
	--End
	--if @DelExpired is not null 
	--Begin 
	--	if @DelExpired = 1 Set @ddbmacmd = @ddbmacmd + ' -r '
	--End

	
	IF( @DryRun = 0 )
		BEGIN
			-- Setup temprorary in memory table to loop through DDB executable output
			DECLARE @t TABLE (LINE NVARCHAR(4000))
			INSERT INTO @t
			exec xp_cmdshell @ddbmacmd --DBA DDBoost expire backup
			SET @cur = Cursor FOR
			SELECT LINE FROM @t
			open @cur
			fetch next FROM @cur INTO @line
			while @@fetch_status = 0
			begin
				-- Check if option to delete expire images was passed
				IF @DelExpired is not null
				BEGIN
		
					-- Check if expired imaged were returned for for deletion
					IF @line LIKE 'Deleting saveset name%'
					BEGIN
						SET @rreturned = 1
					END
			
					-- Check for error messages
					IF @line LIKE 'Failed to delete item%'
					BEGIN
						SET @rcode = 1
					END
			
				END
		
				-- Expired images were requested only for listing
				IF @DelExpired is null
				BEGIN
					-- Check if expired images were returned
					IF @line LIKE 'client%size%retent%'
					BEGIN
						SET @rreturned = 1
					END
						
					-- Check for error messages
					IF @line LIKE '%error%failed%'
					BEGIN
						SET @rcode = 1
					END
				END
		
				-- Print output and process next line
				print @line
				fetch next FROM @cur INTO @line
			end
			close @cur;
			Deallocate @cur;
	
			-- Report if no expired images were returned
			IF @rreturned = 0
				print 'No expired images found';
	
			-- Report if errors were returned
			IF @rcode = 1
				raiserror('An error occured with the backup',16,1)	
		END
	ELSE
		BEGIN
			PRINT '[DryRun]'
			PRINT @ddbmacmd 
		END
END
