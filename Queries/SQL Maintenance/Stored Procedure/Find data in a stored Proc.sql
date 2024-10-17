DECLARE @sqlcmd       VARCHAR(max),
        @TableName    VARCHAR(255) ='',
		@definition        VARCHAR(150) = 'execute as ',
		@type_desc        VARCHAR(150) = '',
        @DatabaseName VARCHAR(100) ='unitrac',

        @DryRun       INT = 0

SELECT @sqlcmd = '
use [' + @DatabaseName + ']



SELECT DISTINCT
	DB_NAME() AS DatabaseName,
	    OBJECT_NAME(o.object_id),
	    OBJECT_NAME(m.object_id),
       o.name AS Object_Name,
       o.type_desc
  FROM sys.sql_modules m
       INNER JOIN
       sys.objects o
         ON m.object_id = o.object_id
 WHERE m.definition  like ''%' + @definition + '%'' 
  AND  o.type_desc  like ''%' + @type_desc + '%'' 
 '

IF @DatabaseName  ='?'
BEGIN 
IF @DryRun = 0
  BEGIN
  
		  IF Object_id(N'tempdb..#TableFileSize') IS NOT NULL
              DROP TABLE #TableFileSize

            CREATE TABLE #TableFileSize
              (
                 [DatabaseName]  VARCHAR(100),
                 [O_Name]     VARCHAR(100),
                 [Module_Name]     VARCHAR(100),
                 [Object_Name]     VARCHAR(100),
                 [type_desc]    VARCHAR(100)
				 )

            INSERT INTO #TableFileSize
            EXEC Sp_msforeachdb
              @SQLcmd

            SELECT *
            FROM   #TableFileSize
			
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd + '
	  
	  exec sp_MSforeachdb @sqlcmd' )
  END
  END 
  ELSE 
  BEGIN 
IF @DryRun = 0
  BEGIN
      EXEC ( @SQLcmd)
		
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd + 'in
	  
	  exec @sqlcmd')
  END

  END


