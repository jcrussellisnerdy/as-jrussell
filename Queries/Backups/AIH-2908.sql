USE [master]
GO

IF EXISTS (SELECT *
               FROM sys.databases  
               WHERE name = 'UniTrac_DW')
	BEGIN


ALTER DATABASE [UniTrac_DW] MODIFY FILE ( NAME = N'UniTrac_DW', MAXSIZE = 492134400KB )



END 
ELSE 

PRINT 'No Database with that Name'



