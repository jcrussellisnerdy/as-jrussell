DECLARE @SQL VARCHAR(max)
DECLARE @username NVARCHAR(200)
DECLARE @DatabaseName SYSNAME
DECLARE @definition VARCHAR(150) = '';
DECLARE @type_desc VARCHAR(150) = '';
DECLARE @DryRun INT = 0 --1 preview / 0 executes it 
DECLARE @Verbose INT =0 --1 preview / 0 executes it 


IF OBJECT_ID(N'tempdb..#TableFileSize') IS NOT NULL
        DROP TABLE #TableFileSize;

    CREATE TABLE #TableFileSize (
   --content
    );


      IF Object_id(N'tempdb..#TempDatabases') IS NOT NULL
        DROP TABLE #TempDatabases

      CREATE TABLE #TempDatabases
        (
           DatabaseName SYSNAME,
           IsProcessed  BIT
        )

      -- Insert the databases to exclude into the temporary table
      INSERT INTO #TempDatabases
                  (DatabaseName,
                   IsProcessed)
SELECT name, 0 -- SELECT *
FROM   sys.databases
ORDER  BY database_id

      -- Loop through the remaining databases
      WHILE EXISTS(SELECT *
                   FROM   #TempDatabases
                   WHERE  IsProcessed = 0)
        BEGIN
            -- Fetch 1 DatabaseName where IsProcessed = 0
            SELECT TOP 1 @DatabaseName = DatabaseName
            FROM   #TempDatabases
            WHERE  IsProcessed = 0

            -- Prepare SQL Statement
            SELECT @SQL = '
USE [' + @DatabaseName
                          + ']

'



            -- You know what we do here if it's 1 then it'll give us code and 0 executes it
            IF @DryRun = 0
              BEGIN
                  PRINT ( @DatabaseName )

                  EXEC ( @SQL)
              END
            ELSE
              BEGIN
                  PRINT ( @SQL )
              END

            -- Update table
            UPDATE #TempDatabases
            SET    IsProcessed = 1
            WHERE  DatabaseName = @databaseName
        END




IF @Verbose = 0
BEGIN 
  select * From #TableFileSize
END