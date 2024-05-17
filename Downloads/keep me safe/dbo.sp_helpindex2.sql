USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[sp_helpindex2]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_helpindex2]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_helpindex2] AS RETURN 0;';
END
GO

ALTER PROCEDURE [dbo].[sp_helpindex2]
	@tableName SYSNAME    -- the table to check for indexes
AS
	-- 04/13/2012 - sng - converted from MS sp_helpindex
	
	DECLARE @objectId           INT = OBJECT_ID(@tableName),    -- the object id of the table
			@indexId            SMALLINT,	-- the index id of an index
			@groupid            INT,  		-- the filegroup id of an index
			@indexName          SYSNAME,
			@groupname          SYSNAME,
			@status             INT,
			@keys               NVARCHAR(2126),	--Length (16*max_identifierLength)+(15*2)+(16*3)
			@dbname	            SYSNAME = PARSENAME(@tableName, 3),
			@ignore_dup_key	    BIT,
			@is_unique		    BIT,
			@is_hypothetical	BIT,
			@is_primary_key	    BIT,
			@is_unique_key 	    BIT,
			@auto_created	    BIT,
			@no_recompute	    BIT,
			@i                  INT, 
			@thiskey            NVARCHAR(131), -- 128+3
			@includedColumns    NVARCHAR(2126),
			@filter             NVARCHAR(2126),
			@userSeeks			INT, 
			@userLookups		INT, 
			@userScans			INT, 
			@userUpdates		INT

	SET NOCOUNT ON

	CREATE TABLE #spindtab
	(
		index_name			SYSNAME	COLLATE database_default NOT NULL,
		index_id			INT,
		ignore_dup_key		BIT,
		is_unique			BIT,
		is_hypothetical		BIT,
		is_primary_key		BIT,
		is_unique_key		BIT,
		auto_created		BIT,
		no_recompute		BIT,
		groupname			SYSNAME COLLATE database_default NULL,
		index_keys			NVARCHAR(2126)	COLLATE database_default NOT NULL,
		included_columns    NVARCHAR(2126)	COLLATE database_default NULL,
		filter_definition   NVARCHAR(2126)	COLLATE database_default NULL,
		userSeeks			INT,
		userLookups			INT, 
		userScans			INT, 
		userUpdates			INT
	)

	-- Check to see that the object names are local to the current database.
	IF @dbname IS NULL
		SELECT @dbname = DB_NAME()
	ELSE IF @dbname <> DB_NAME()
    BEGIN
	    RAISERROR(15250,-1,-1)
		RETURN (1)
    END

	-- Check to see the the table exists 
	IF @objectId IS NULL
	BEGIN
		RAISERROR(15009,-1,-1,@tableName,@dbname)
		RETURN (1)
	END

	-- OPEN CURSOR OVER INDEXES (skip stats: bug shiloh_51196)
	DECLARE ms_crs_ind CURSOR LOCAL STATIC FOR
    SELECT  i.index_id, i.data_space_id, i.name, i.ignore_dup_key, i.is_unique, 
            i.is_hypothetical, i.is_primary_key, i.is_unique_constraint, 
            s.auto_created, s.no_recompute, i.filter_definition,
            us.user_seeks, us.user_lookups, us.user_scans, us.user_updates
    FROM    sys.indexes i 
            INNER JOIN sys.stats s
			ON i.object_id = s.object_id AND 
			   i.index_id = s.stats_id
			LEFT OUTER JOIN sys.dm_db_index_usage_stats us
			ON us.object_id = s.object_id and
			   us.index_id = i.index_id AND
			   us.database_id = DB_ID()
    WHERE   i.object_id = @objectId
    
	OPEN ms_crs_ind
	
	FETCH ms_crs_ind INTO @indexId, @groupid, @indexName, @ignore_dup_key, @is_unique, @is_hypothetical,
			@is_primary_key, @is_unique_key, @auto_created, @no_recompute, @filter, 
			@userSeeks, @userLookups, @userScans, @userUpdates

	-- IF NO INDEX, QUIT
	IF @@FETCH_STATUS < 0
	BEGIN
		DEALLOCATE ms_crs_ind
		RAISERROR(15472, -1, -1, @tableName) -- Object does not have any indexes.
		RETURN (0)
	END

	-- Now check out each index, figure out its type and keys and
	--	save the info in a temporary table that we'll print out at the end.
	WHILE @@FETCH_STATUS >= 0
	BEGIN

		-- First we'll figure out what the keys are.
		SELECT @keys = INDEX_COL(@tableName, @indexId, 1), @i = 2
			
		IF (INDEXKEY_PROPERTY(@objectId, @indexId, 1, 'isdescending') = 1)
			SELECT @keys = @keys  + '(-)'

		SELECT @thiskey = index_col(@tableName, @indexId, @i)
		
		IF ((@thiskey IS NOT NULL) AND (INDEXKEY_PROPERTY(@objectId, @indexId, @i, 'isdescending') = 1))
			SELECT @thiskey = @thiskey + '(-)'

		WHILE (@thiskey IS NOT NULL )
		BEGIN
			SELECT @keys = @keys + ', ' + @thiskey, @i = @i + 1
		
			SELECT @thiskey = INDEX_COL(@tableName, @indexId, @i)
		
			IF ((@thiskey IS NOT NULL) and (INDEXKEY_PROPERTY(@objectId, @indexId, @i, 'isdescending') = 1))
				SELECT @thiskey = @thiskey + '(-)'
		END

        SELECT  @includedColumns = NULL

        SELECT  @includedColumns = ISNULL(@includedColumns + ', ', '') + c.name
        FROM    sys.index_columns ic
                INNER JOIN sys.columns c
                ON c.object_id = ic.object_id AND
                   c.column_id = ic.column_id
        WHERE   ic.object_id = @objectId AND
                ic.index_id = @indexId AND
                ic.is_included_column = 1
        ORDER BY ic.key_ordinal

		SELECT  @groupname = NULL
		
		SELECT  @groupname = name 
		FROM    sys.data_spaces 
		WHERE   data_space_id = @groupid

		-- INSERT ROW FOR INDEX
		INSERT INTO #spindtab 
		VALUES 
		( @indexName, @indexId, @ignore_dup_key, @is_unique, @is_hypothetical,
		  @is_primary_key, @is_unique_key, @auto_created, @no_recompute, @groupname, @keys, @includedColumns, @filter,
		  @userSeeks, @userLookups, @userScans, @userUpdates )

		-- Next index
		FETCH ms_crs_ind INTO @indexId, @groupid, @indexName, @ignore_dup_key, @is_unique, @is_hypothetical,
			@is_primary_key, @is_unique_key, @auto_created, @no_recompute, @filter,
			@userSeeks, @userLookups, @userScans, @userUpdates

	END
	
	DEALLOCATE ms_crs_ind

	-- DISPLAY THE RESULTS
	SELECT  'index_name' = index_name,
		    'index_description' = convert(varchar(210), --bits 16 off, 1, 2, 16777216 on, located on group
				case when index_id = 1 then 'clustered' else 'nonclustered' end
				+ case when ignore_dup_key <>0 then ', ignore duplicate keys' else '' end
				+ case when is_unique <>0 then ', unique' else '' end
				+ case when is_hypothetical <>0 then ', hypothetical' else '' end
				+ case when is_primary_key <>0 then ', primary key' else '' end
				+ case when is_unique_key <>0 then ', unique key' else '' end
				+ case when auto_created <>0 then ', auto create' else '' end
				+ case when no_recompute <>0 then ', stats no recompute' else '' end
				+ ' located on ' + groupname),
		    'index_keys' = index_keys,
		    included_columns, filter_definition, userSeeks, userLookups, userScans, userUpdates
	FROM    #spindtab
	ORDER BY index_name

	RETURN (0)
GO


/* Remove old versions */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[sp_helpindex2]') AND type in (N'P', N'PC'))
BEGIN
	EXEC dbo.sp_executesql @statement = N'DROP PROCEDURE [info].[sp_helpindex2];' 
END

/*   */
IF( (select @@version) like '%AZURE%' )
	BEGIN
		RETURN;
	END
ELSE
	BEGIN
		exec sys.sp_MS_marksystemobject 'dbo.sp_helpindex2';
	END
go

