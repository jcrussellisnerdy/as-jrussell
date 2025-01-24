DECLARE @sqlcmd VARCHAR(MAX);
DECLARE @TableName VARCHAR(255) = '';
DECLARE @definition VARCHAR(150) = '';
DECLARE @type_desc VARCHAR(150) = '';
DECLARE @DatabaseName VARCHAR(100) = '';
DECLARE @DryRun INT = 1;

-- Construct the SQL command 
SELECT @sqlcmd = '
USE [' + @DatabaseName + ']

SELECT DISTINCT
    DB_NAME() AS DatabaseName,
    OBJECT_NAME(o.object_id),
    OBJECT_NAME(m.object_id),
    o.name AS Object_Name,
    o.type_desc
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE m.definition LIKE ''%' + @definition + '%'' 
  AND o.type_desc LIKE ''%' + @type_desc + '%''
';

-- Check if the script should be executed against all databases
IF @DatabaseName = '?'
BEGIN
    -- Create a temporary table to store the results
    IF OBJECT_ID(N'tempdb..#TableFileSize') IS NOT NULL
        DROP TABLE #TableFileSize;

    CREATE TABLE #TableFileSize (
        [DatabaseName] VARCHAR(100),
        [O_Name] VARCHAR(100),
        [Module_Name] VARCHAR(100),
        [Object_Name] VARCHAR(100),
        [type_desc] VARCHAR(100)
    );

    -- Use a WHILE loop to iterate through databases
    DECLARE @DbName SYSNAME;
    DECLARE @Counter INT = 1;

    -- Get the total number of databases
    SELECT @Counter = COUNT(*) FROM sys.databases; -- You can filter this if needed

    WHILE @Counter > 0
    BEGIN
        -- Get the next database name
        SELECT TOP 1 @DbName = name 
        FROM sys.databases  -- Add filtering here if needed
        WHERE name NOT IN (SELECT TOP (@Counter - 1) name FROM sys.databases); -- ORDER BY name); 

        -- Construct the dynamic SQL for the current database
        DECLARE @CurrentSQL VARCHAR(MAX);
        SET @CurrentSQL = REPLACE(@sqlcmd, '[' + @DatabaseName + ']', '[' + @DbName + ']');

        -- Execute the dynamic SQL and insert the results into the temporary table
        INSERT INTO #TableFileSize
        EXEC (@CurrentSQL);

        SET @Counter = @Counter - 1;
    END

    -- Display the results from the temporary table
    IF @DryRun = 0
    BEGIN
        SELECT * FROM #TableFileSize;
    END
    ELSE
    BEGIN
        PRINT @sqlcmd;
        PRINT '--- Results will be inserted into #TableFileSize ---';
    END
END
ELSE  -- Execute the script against a specific database
BEGIN
    IF @DryRun = 0
    BEGIN
        EXEC (@sqlcmd);
    END
    ELSE
    BEGIN
        PRINT @sqlcmd;
    END
END