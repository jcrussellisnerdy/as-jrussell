/* DECLARE ALL variables at the top */
DECLARE @sqlcmd VARCHAR(1000)
DECLARE @DatabaseName SYSNAME ='' --Database Name
DECLARE @SchemaName VARCHAR(1000) ='dbo'--Schema Name by default it is DBO but in some cases it might be different
DECLARE @TableName VARCHAR(1000) =''--Table Name
DECLARE @DryRun INT = 0 --1 to Preview / 0 to Execute 

SELECT @SQLCMD = '
USE [' + @DatabaseName
                 + ']

IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '''
                 + @DatabaseName
                 + ''')
BEGIN 
IF EXISTS (SELECT 1 FROM SYS.objects WHERE NAME =  '''
                 + @TableName
                 + ''')
	BEGIN 
	IF EXISTS (SELECT 1 FROM  sys.tables t INNER JOIN sys.partitions p ON t.object_id = p.OBJECT_ID WHERE p.rows != 0 and   t.[name] =  '''+ @TableName + ''')
		BEGIN
		TRUNCATE TABLE [' + @SchemaName
						 + '].[' + @TableName
						 + ']
		PRINT ''SUCCESSFUL: TABLE WAS TRUNCATED ''
		END 
	ELSE 
		BEGIN 
		PRINT ''WARNING: PLEASE CHECK YOUR TABLE''
		END 
	END
END '

-- You know what we do here if it's 1 then it'll give us code and 0 executes it
IF @DryRun = 0
  BEGIN
      EXEC ( @SQLcmd)
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd )
  END 
