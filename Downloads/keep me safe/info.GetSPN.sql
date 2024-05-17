USE [DBA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[info].[GetSPN]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetSPN] AS RETURN 0;' 
END
GO
ALTER PROCEDURE [info].[GetSPN] (@failOnError int =0) 
AS
-- EXEC [info].[GetSPN] @FailOnError = 1
set nocount on
DECLARE @ServiceaccountName varchar(250)  
DECLARE @InstanceName nvarchar(50)
DECLARE @value VARCHAR(100), @port varchar(15)
declare @server varchar(128), @sqlstring varchar(5000)
declare @output as table (x varchar(250))

SET @InstanceName=CONVERT(nVARCHAR,isnull(SERVERPROPERTY('INSTANCENAME'),'MSSQLSERVER'))

SELECT @port = local_tcp_port   
 FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
 
--print @port
EXECUTE master.dbo.xp_instance_regread  
N'HKEY_LOCAL_MACHINE', N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',  
N'ObjectName',@ServiceAccountName OUTPUT, N'no_output'  
--SELECT @ServiceAccountName  

if @serviceAccountName is null
	select @serviceAccountName = 'Missing'
if @port is null
	select @port = 'xxxxx'
if @instanceName is null
	select @instanceName = 'Ix'
	
insert @output 
select 'Instance running as '+@serviceAccountName

if @@serverName like '%\%'
	select @server = substring(@@serverName,1,charindex('\',@@serverName)-1)
else 
	select @server = @@serverName
 
select @sqlstring = 'setspn -L '+@serviceAccountName+ ' | find /i "'+@server+'." | sort'

--print @sqlString

insert @output
exec xp_cmdshell @sqlstring--info.verifySPN - run setspn for account

delete from @output where x is null

exec dba.info.setSystemConfig 'Instance.InstanceName',@instanceName


update @output
set x = 'OK--'+ x where x like '%'+@port 
		or x like '%ldap error%' or x like '%failed to bind%'
if @@rowcount = 0
	insert @output select 'Error--Port ('+@port+') SPN missing for account '+@serviceAccountName

-- in case it isn't set
if @port <> 'xxxxx'
begin
	-- in case it isn't set
	exec dba.info.setSystemConfig 'Instance.port',@port
	update @output
	set x = 'OK--'+ x where x like '%'+@instanceName
			or x like '%ldap error%' or x like '%failed to bind%'

	if @@rowcount = 0
		insert @output select 'Error--Instance ('+@instanceName+') SPN missing for account '+@serviceAccountName
end

select x messages from @output
if @failonError = 1
begin
	if exists (select * from @output where x like '%error--%')
		raiserror('Issue verifying SPN', 16, 1)
end

return
GO