USE [DBA];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[info].[GetInstance]')
          AND type IN ( N'P', N'PC' )
)
BEGIN
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [info].[GetInstance] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [info].[GetInstance] ( @DryRun int = 1, @Debug int = 0 )
AS 
BEGIN
	-- EXEC info.GetInstance @DryRun = 0
	-- EXEC info.GetInstance @Debug = 1
SET NOCOUNT ON
DECLARE @DAC NVARCHAR(100), @TCP NVARCHAR(100), @TCPDynamic NVARCHAR(100), @IP NVARCHAR(100)
DECLARE @InstanceName NVARCHAR(100), @registryPath NVARCHAR(MAX), @sqlVersion varchar(10), @ProductVersion int
DECLARE @ServerName NVARCHAR(100), @xpCMD nvarchar(100), @sqlCMD nvarchar(max)

SET @ServerName = ( select isnull(convert(varchar(max),serverproperty('ServerName')),'MSSQLSERVER')  ) -- SELECT @@Servername
SET @InstanceName = ( select isnull(convert(varchar(max),serverproperty('InstanceName')),'MSSQLSERVER') ) -- select serverproperty('instancename')
SET @ProductVersion = ( select  LEFT( convert(varchar(max),SERVERPROPERTY('ProductVersion')), CharIndex('.', convert(varchar(max),SERVERPROPERTY('ProductVersion')))- 1) )

IF( charindex ('\', @servername) > 0 ) 
BEGIN
	SET @Servername = left(@Servername, charindex ('\', @servername)-1 )
END

SELECT @xpCMD = 'nslookup '+ REPLACE(REPLACE(@ServerName ,'NEWTIMMAY','TIMMAY'), 'SITECOREBUILD01', 'SITECORE-BUILD' ) -- instance name DNS mismatches 

IF(@ProductVersion < 11)
	begin
		SET @sqlVersion = (select convert(varchar(max),@ProductVersion) +'_'+ LEFT( REPLACE(convert(varchar(max),SERVERPROPERTY('ProductVersion')), convert(varchar(max),@ProductVersion) +'.' ,'' ), CharIndex('.', REPLACE(convert(varchar(max),SERVERPROPERTY('ProductVersion')), convert(varchar(max),@ProductVersion) +'.' ,'' ))- 1))
	
        IF( @sqlVersion = '10_0' ) SET @sqlVersion= '10'
    END
ELSE
	BEGIN
		SET @sqlVersion = (select  LEFT( convert(varchar(max),SERVERPROPERTY('ProductVersion')), CharIndex('.', convert(varchar(max),SERVERPROPERTY('ProductVersion')))- 1))
        IF( @Servername IN ('OCR-SQLPRD-01', 'OCR-SQLPRD-04') ) SET @sqlVersion = 13
	END

SET @registryPath = (SELECT 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL'+ @sqlVersion +'.'+ @InstanceName +'\MSSQLServer\SuperSocketNetLib\AdminConnection\Tcp' )
IF( (select @@version) like '%AZURE%' )
    BEGIN
        SET @DAC = '0';
    END
ELSE
    BEGIN
		EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @registryPath, N'TcpDynamicPorts', @DAC OUTPUT
	END;

SET @registryPath = (SELECT 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL'+ @sqlVersion +'.'+ @InstanceName +'\MSSQLServer\SuperSocketNetLib\Tcp\IPAll' )
IF( (select @@version) NOT like '%AZURE%' )
    BEGIN
        EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @registryPath, N'TcpPort', @TCP OUTPUT
    END;


SET @registryPath = (SELECT 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL'+ @sqlVersion +'.'+ @InstanceName +'\MSSQLServer\SuperSocketNetLib\Tcp\IPAll' )
IF( (select @@version) like '%AZURE%' )
    BEGIN
        SET @TCPDynamic = '';
    END
ELSE
    BEGIN
		EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @registryPath, N'TcpDynamicPorts', @TCPDynamic OUTPUT
	END;

SET @registryPath = (SELECT 'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL'+ @sqlVersion +'.'+ @InstanceName +'\MSSQLServer\SuperSocketNetLib\Tcp\IP2' )
IF( (select @@version) like '%AZURE%' )
    BEGIN
		select distinct @IP = local_net_address, @TCP = local_tcp_port from sys.dm_exec_connections where local_net_address is not null
    END
ELSE
    BEGIN
		EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', @registryPath, N'IPAddress', @IP OUTPUT
	END;

IF( (select @@version) like '%AZURE%' )
    BEGIN
        select distinct @IP = local_net_address, @TCP = local_tcp_port from sys.dm_exec_connections where local_net_address is not null
    END
ELSE
    BEGIN
		IF OBJECT_ID('tempdb..#results') IS NOT NULL
			DROP TABLE #results
		CREATE TABLE #results(
			RowNumber int identity (1,1),
			output varchar(max) )

		INSERT INTO #results
		 EXEC xp_cmdshell @xpCMD --DailyHarvest;

		DELETE FROM #results where output is null

		SELECT @IP = lTrim(REPLACE(output,'Address: ','')) FROM  #results where RowNumber = ( SELECT Max(RowNumber) FROM  #results)
		--SELECT IsNull(@TCP, @TCPDynamic), @DAC, @IP
	END;

DECLARE @Domain NVARCHAR(100)
IF( (select @@version) like '%AZURE%' )
    BEGIN
        SET @Domain = REPLACE( convert(varchar(100), SERVERPROPERTY('ServerName')), LEFT(convert(varchar(100), SERVERPROPERTY('ServerName')),charIndex('.',convert(varchar(100), SERVERPROPERTY('ServerName')))),'');
    END
ELSE
    BEGIN
        EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain', @Domain OUTPUT
    END;

SELECT @sqlCMD = '       
	SELECT  
        convert(varchar(100), SERVERPROPERTY(''ServerName'')) AS [SQLServerName],  
        UPPER(IsNull(convert(varchar(100), SERVERPROPERTY(''MachineName'')), LEFT(convert(varchar(100), SERVERPROPERTY(''ServerName'')),charIndex(''.'',convert(varchar(100), SERVERPROPERTY(''ServerName'')))-1) )) AS [MachineName], 
		--(SELECT SERVERPROPERTY(''computerNamePhysicalNetBIOS'')) AS [ServerName],
        '''+ @InstanceName +''' AS [InstanceName],
        '''+ @Domain +''' AS [DomainName],
        '''+ @IP +''' AS [Local_Net_Address],  -- sELECT * FROM SYS.DM_EXEC_CONNECTIONS 
        '+ IsNull(@TCP, @TCPDynamic) +' as Port,      
        '+ @DAC +' as DACport,
        SUBSTRING ( (SELECT convert(varchar(100), @@VERSION)),1, CHARINDEX(''('',(SELECT REPLACE(convert(varchar(100), @@VERSION),''-'',''('')))-1 ) as [ProductName],
        convert(varchar(100), SERVERPROPERTY(''ProductVersion'')) AS [ProductVersion],  
        convert(varchar(100), SERVERPROPERTY(''ProductLevel'')) AS [ProductLevel],
        convert(varchar(10), SERVERPROPERTY(''ProductUpdateLevel'')) as [ProductUpdateLevel],
        --SERVERPROPERTY(''ProductMajorVersion'') AS [ProductMajorVersion],
        --SERVERPROPERTY(''ProductMinorVersion'') AS [ProductMinorVersion],
        --SERVERPROPERTY(''ProductBuild'') AS [ProductBuild],
        convert(varchar(100), SERVERPROPERTY(''Edition'')) AS [Edition],
        CASE convert(int, SERVERPROPERTY(''EngineEdition''))
            WHEN 1 THEN ''PERSONAL''
            WHEN 2 THEN ''STANDARD''
            WHEN 3 THEN ''ENTERPRISE''
            WHEN 4 THEN ''EXPRESS''
            WHEN 5 THEN ''SQL DATABASE''
            WHEN 6 THEN ''SQL DATAWAREHOUSE''
            WHEN 8 THEN ''Azure SQL Managed Instance''
        END AS [EngineEdition], 
        ( SELECT value FROM sys.configurations WHERE name like ''min server memory%'' ) AS [MIN_SIZE_SERVER_MEMORY_MB],  --select * from sys.configurations
        ( SELECT value FROM sys.configurations WHERE name like ''max server memory%'' ) AS [MAX_SIZE_SERVER_MEMORY_MB],
        ( SELECT convert(int, value) FROM sys.configurations WHERE name like ''cost threshold for parallelism%'' ) AS [CTFP],
        ( SELECT convert(int, value) FROM sys.configurations WHERE name like ''max degree of parallelism%'' ) AS [MDOP],
        ( SELECT convert(int, value) FROM sys.configurations WHERE name like ''Ad Hoc Distributed Queries%'' ) as [IsAdHocEnabled],
        ( SELECT convert(int, value) FROM sys.configurations WHERE name like ''Database Mail XPs%'' ) as [IsDBMailEnabled],
        ( SELECT convert(int, value) FROM sys.configurations WHERE name like ''Agent XPs%'' ) as [IsAgentXPsEnabled],
        CASE convert(int, SERVERPROPERTY(''IsHadrEnabled'')) WHEN 0 THEN 0 WHEN 1 THEN 1 ELSE 0 END AS IsHadrEnabled,
        CASE convert(int, SERVERPROPERTY(''HadrManagerStatus''))
            WHEN 0 THEN ''Not started, pending communication''
            WHEN 1 THEN ''Started and running''
            WHEN 2 THEN ''Not started and failed''
            ELSE ''Not applicable''
        END AS HadrManagerStatus,
        CASE convert(int, SERVERPROPERTY(''IsSingleUser'')) WHEN 0 THEN 0 ELSE 1 END AS InSingleUser,
        CASE convert(int, SERVERPROPERTY(''IsClustered'')) WHEN 1 THEN 1 WHEN 0 THEN 0 ELSE 0 END AS IsClustered,
        ( SELECT UPPER(info.GetSystemConfig(''Server.Environment'', ''ENV - Missing'')) ) as ServerEnvironment,
        '''' as ServerStatus,
        '''+ CASE WHEN @DryRun = 0 THEN 'DESC' ELSE 'DryRun' END +''' as Comments;'


 IF( @DryRun = 0 ) 
	 BEGIN
		truncate table info.Instance --should be merge

         /* Create TEMP Table */
		INSERT INTO info.Instance
			EXEC(@sqlCMD)
        /* Merge */

	END
ELSE
	BEGIN
		if @Debug = 1 print @sqlCMD

		EXEC(@sqlCMD)
	END

END;