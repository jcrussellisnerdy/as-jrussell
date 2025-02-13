USE [PerfStats]

GO

IF NOT EXISTS (SELECT *
               FROM   sys.objects
               WHERE  object_id = Object_id(N'[dbo].[GetFillFactor]')
                      AND type IN ( N'P', N'PC' ))
  BEGIN
      /* Create Empty Stored Procedure */
      EXEC dbo.Sp_executesql
        @statement = N'CREATE PROCEDURE [dbo].[GetFillFactor] AS RETURN 0;';
  END;

GO

/* Alter Stored Procedure */
ALTER PROCEDURE [GetFillFactor] (@FillFactor   NVARCHAR(100) = 80,
                                 @DatabaseName VARCHAR(100)='',
                                 @TableName    VARCHAR(255) ='',
                                 @IndexName    VARCHAR(255) ='',
                                 @SchemaName   VARCHAR(255) ='',
                                 @DryRun       BIT = 1-- If 0, applies changes
)
AS
  BEGIN
      SET NOCOUNT ON;

      DECLARE @DbName SYSNAME,
              @SQL    NVARCHAR(MAX);

      -- Temp table to store index details
      CREATE TABLE #FillFactorCheck
        (
           DatabaseName      SYSNAME,
           SchemaName        SYSNAME,
           TableName         SYSNAME,
           IndexName         SYSNAME,
           CurrentFillFactor INT
        );

      -- Temp table to store databases
      CREATE TABLE #Databases
        (
           DatabaseName SYSNAME,
           IsProcessed  BIT
        );

      INSERT INTO #Databases
                  (DatabaseName,
                   IsProcessed)
      SELECT name,
             0
      FROM   sys.databases
      WHERE  state_desc = 'ONLINE'
             AND database_id > 4; -- Excludes system DBs

      -- Loop through databases
      -- Loop through the remaining databases
      WHILE EXISTS(SELECT *
                   FROM   #Databases
                   WHERE  IsProcessed = 0)
        BEGIN
            -- Fetch 1 DatabaseName where IsProcessed = 0
            SELECT TOP 1 @DbName = DatabaseName
            FROM   #Databases
            WHERE  IsProcessed = 0

            SELECT @SQL = '
            USE ' + Quotename(@DbName)
                          + '

            INSERT INTO #FillFactorCheck
            SELECT 
                DB_NAME() AS DatabaseName,
                SCHEMA_NAME(o.schema_id) AS SchemaName,
                OBJECT_NAME(i.object_id) AS TableName,
                   ISNULL(i.name, ''NoIndexName'') AS IndexName,
                i.fill_factor
            FROM sys.indexes i
            JOIN sys.objects o ON i.object_id = o.object_id
            WHERE o.type IN (''U'', ''V'');';

            -- You know what we do here if it's 1 then it'll give us code and 0 executes it
            IF @DryRun = 0
              BEGIN
                  EXEC ( @SQL)
              END
            ELSE
              BEGIN
                  PRINT ( @SQL )
              END

            UPDATE #Databases
            SET    IsProcessed = 1
            WHERE  DatabaseName = @DbName
        END;

      IF @DryRun = 0
        BEGIN
            BEGIN
                -- Rest of the code for filtering and displaying data from #FillFactorCheck (same as before)
                IF @TableName <> ''
                  BEGIN
                      SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [TableName] = @TableName
                             AND DatabaseName LIKE '%' + @DatabaseName + '%'
                             AND [IndexName] LIKE '%' + @IndexName + '%'
                             AND [SchemaName] LIKE '%' + @SchemaName + '%'
                  END
                ELSE IF @DatabaseName <> ''
                  BEGIN
                      SELECT *
                      FROM   #FillFactorCheck
                      WHERE  DatabaseName = @DatabaseName
                             AND [TableName] LIKE '%' + @TableName + '%'
                             AND [IndexName] LIKE '%' + @IndexName + '%'
                             AND [SchemaName] LIKE '%' + @SchemaName + '%'
                  END
                ELSE IF @SchemaName <> ''
                  BEGIN
                      SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [SchemaName] = @SchemaName
                             AND [TableName] LIKE '%' + @TableName + '%'
                             AND [IndexName] LIKE '%' + @IndexName + '%'
                             AND DatabaseName LIKE '%' + @DatabaseName + '%'
                  END
                ELSE IF @IndexName <> ''
                  BEGIN
                      SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [IndexName] = @IndexName
                             AND DatabaseName LIKE '%' + @DatabaseName + '%'
                             AND [TableName] LIKE '%' + @TableName + '%'
                             AND [SchemaName] LIKE '%' + @SchemaName + '%'
                  END
                ELSE
                  BEGIN
                      SELECT *
                      FROM   #FillFactorCheck
                  END
            END
        END
      ELSE
        BEGIN
            PRINT ( '      IF Object_id(N''tempdb..#FillFactorCheck'') IS NOT NULL
        DROP TABLE #FillFactorCheck;
      CREATE TABLE #FillFactorCheck
        (
           DatabaseName      SYSNAME,
           SchemaName        SYSNAME,
           TableName         SYSNAME,
           IndexName         SYSNAME,
           CurrentFillFactor INT
        )
     INSERT INTO #FillFactorCheck' )

            PRINT ( @SQL );

                           IF @TableName <> ''
                  BEGIN
                    PRINT ('  SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [TableName] = '''+@TableName+'''
                             AND DatabaseName LIKE ''%' + @DatabaseName + '%''
                             AND [IndexName] LIKE ''%' + @IndexName + '%''
                             AND [SchemaName] LIKE ''%' + @SchemaName + '%''')
                  END
                ELSE IF @DatabaseName <> ''
                  BEGIN
                    PRINT ('  SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [TDatabaseName] = '''+@DatabaseName+'''
							 AND [TableName] LIKE ''%' + @TableName + '%''
                             AND [IndexName] LIKE ''%' + @IndexName + '%''
                             AND [SchemaName] LIKE ''%' + @SchemaName + '%''')

           
                  END
                ELSE IF @SchemaName <> ''
                  BEGIN
                    PRINT ('  SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [SchemaName] = '''+@SchemaName+'''
                             AND DatabaseName LIKE ''%' + @DatabaseName + '%''
                             AND [IndexName] LIKE ''%' + @IndexName + '%''
                             AND [TableName] LIKE ''%' + @TableName + '%''')
                  END
                ELSE IF @IndexName <> ''
                  BEGIN
                    PRINT ('  SELECT *
                      FROM   #FillFactorCheck
                      WHERE  [IndexName] = '''+@IndexName+'''
                             AND DatabaseName LIKE ''%' + @DatabaseName + '%''
                             AND [TableName] LIKE ''%' + @TableName + '%''
                             AND [SchemaName] LIKE ''%' + @SchemaName + '%''')
                  END
                ELSE
                  BEGIN
                   PRINT ('   SELECT *
                      FROM   #FillFactorCheck ')
                  END
        END


		---Put Merge here


  END; 
