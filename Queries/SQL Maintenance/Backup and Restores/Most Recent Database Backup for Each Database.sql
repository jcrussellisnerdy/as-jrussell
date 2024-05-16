------------------------------------------------------------------------------------------- 
--Most Recent Database Backup for Each Database 
------------------------------------------------------------------------------------------- 
/*

https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql?view=sql-server-ver15
Backup type. Can be:

D = Database

I = Differential database

L = Log

F = File or filegroup

G =Differential file

P = Partial

Q = Differential partial
*/

DECLARE @sqlcmd VARCHAR(max),
        @StartDate   VARCHAR(20) = '',
		@EndDate   VARCHAR(20) ,
		@Type varchar(1) = 'L',		
		@DBNAME varchar(50) = 'Unitrac',
        @Verbose INT = 1,
		@WhatIF INT = 1


IF @StartDate is null or @StartDate = ''
set @StartDate = GETDATE()-7


IF @EndDate is null or @EndDate = ''
set @EndDate = GETDATE() 


SELECT @sqlcmd = '	
SELECT  
   CONVERT(CHAR(100), SERVERPROPERTY(''Servername'')) AS Server, msdb..backupset.type,
   msdb.dbo.backupset.database_name,  
   MAX(msdb.dbo.backupset.backup_finish_date) AS last_db_backup_date , physical_device_name
      ,   LEFT(
        SUBSTRING(
            physical_device_name,
            LEN(physical_device_name) - CHARINDEX(''\'', REVERSE(physical_device_name)) + 2,
            LEN(physical_device_name)
        ),
        LEN(physical_device_name) - CHARINDEX(''.'', REVERSE(physical_device_name)) + 1
    ) AS filename
   --select  top 5*
FROM   msdb.dbo.backupmediafamily  
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id  
WHERE msdb..backupset.type = '''+@Type+''' 
AND  msdb.dbo.backupset.database_name = '''+ @DBNAME + '''
AND  msdb.dbo.backupset.backup_finish_date BETWEEN  '''+ @StartDate  + ''' AND '''+ @EndDate  + '''
GROUP BY 
   msdb.dbo.backupset.database_name  , msdb.dbo.backupset.type, msdb.dbo.backupmediafamily.physical_device_name,  LEFT(
        SUBSTRING(
            physical_device_name,
            LEN(physical_device_name) - CHARINDEX(''\'', REVERSE(physical_device_name)) + 2,
            LEN(physical_device_name)
        ),
        LEN(physical_device_name) - CHARINDEX(''.'', REVERSE(physical_device_name)) + 1
    )
ORDER BY  
  MAX(msdb.dbo.backupset.backup_finish_date) DESC' 

IF @DBNAME  ='?'
 BEGIN 
IF @WhatIF = 0
  BEGIN
  IF Object_id(N'tempdb..#LastBackup') IS NOT NULL
              DROP TABLE #LastBackup

            CREATE TABLE #LastBackup
              (
                 [Server]  VARCHAR(100),
                 [type]     VARCHAR(100),
                 [DatabaseName]    VARCHAR(100),
                 [last_db_backup_date]     DATE,
                 [physical_device_name] VARCHAR(1000),
				 [filename] VARCHAR(1000)
              );

            INSERT INTO #LastBackup
            EXEC Sp_msforeachdb
              @SQLcmd

IF @Verbose = 1
BEGIN
            SELECT DISTINCT [Server], type, DatabaseName, max(last_db_backup_date) [Last backup Date],   [physical_device_name],  [filename] 
            FROM   #LastBackup
			GROUP BY [Server], type, DatabaseName, [physical_device_name],  [filename] 
			ORDER BY max(last_db_backup_date) DESC
END

ELSE
BEGIN 

            SELECT DISTINCT [Server], type, DatabaseName, max(last_db_backup_date) [Last backup Date]
            FROM   #LastBackup
			GROUP BY [Server], type, DatabaseName, [physical_device_name],  [filename] 
			ORDER BY max(last_db_backup_date) DESC

END 
	
  END
ELSE
  BEGIN
      PRINT ( @SQLcmd + ' 
	  
	  exec @sqlcmd')
  END

  END
  ELSE 
  BEGIN 
IF @WhatIF = 0
  BEGIN

  EXEC ( @SQLcmd )
    END
ELSE
  BEGIN
      PRINT ( @SQLcmd )
  END 
  END