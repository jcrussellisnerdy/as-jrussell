USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrCurrentPatchStatus]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrCurrentPatchStatus] ;
GO


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrCurrentPatchCount]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrCurrentPatchCount] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrDistinctAssessed]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrDistinctAssessed] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrDistinctPatched]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrDistinctPatched] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrDistinctDeployed]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrDistinctDeployed] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrEntityProcessLog]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrEntityProcessLog] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrEntityProcessErrorLog]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrEntityProcessErrorLog] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrLinuxCumulativePatches]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrLinuxCumulativePatches] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrLinuxCurrentPatchStatus]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrLinuxCurrentPatchStatus] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrLinuxCurrentPatchCount]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrLinuxCurrentPatchCount] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrCumulativePatches]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrCumulativePatches] ;
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrLinuxCumulativePatches]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrLinuxCumulativePatches] ;
GO




IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtrLinuxDistinctDeployed]')
                    AND type IN (N'U') ) 
    DROP TABLE [dbo].[xtrLinuxDistinctDeployed] ;
GO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrCurrentPatchCount]') AND type in (N'U'))
BEGIN
  CREATE TABLE [dbo].[xtrCurrentPatchCount](
	[MACHINEID] [int] NULL,
	[SEVERITY] [varchar](50) NULL,
	[INSTALLEDCNT] [int] NULL,
	[NOTINSTALLEDCNT] [int] NULL,
	[MISSINGSPCNT] [int] NULL,
	[INFORMATIONALCNT] [int] NULL)
    ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrLinuxCumulativePatches]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrLinuxCumulativePatches](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PATCHCODE] [varchar](100) NULL,
	[ACTIVE] [int] NULL
) ON [PRIMARY]

END




IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrCurrentPatchStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrCurrentPatchStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MACHINEID] [int] NULL,
	[BULLETIN] [varchar](256) NULL,
	[PATCHID] [int] NULL,
	[PRODUCTID] [int] NULL,
	[ASSESSEDMACHINESTATEID] [int] NULL,
	[SCANDATE] [datetime] NULL,
	[INSTALLSTATEID] [int] NULL,
	[OSID] [int]

) ON [PRIMARY]

END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrDistinctAssessed]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrDistinctAssessed](
	[MACHINEID] [int] NULL,
	[M] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	[ASSESSEDON] [datetime] NULL
) ON [PRIMARY]
END



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrDistinctPatched]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrDistinctPatched](
	[MACHINEID] [int] NULL,
	[M] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	[PATCHEDON] [datetime] NULL
) ON [PRIMARY]
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrDistinctDeployed]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrDistinctDeployed](
	[MACHINEID] [int] NULL,
	[M] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	[DEPLOYEDON] [datetime] NULL
) ON [PRIMARY]

END



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrEntityProcessLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrEntityProcessLog](
	[ENTITYPROCESSLOGID] [int] IDENTITY(1,1) NOT NULL,
	[BATCHID] [int] NULL,
	[LOGDATE] [datetime] NULL,
	[PROCEDURENAME] [nvarchar](100) NULL,
	[DESCRIPTION] [nvarchar](1000) NULL
) ON [PRIMARY]
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtrEntityProcessErrorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrEntityProcessErrorLog](
	[ENTITYPROCESSERRORLOGID] [int] IDENTITY(1,1) NOT NULL,
	[BATCHID] [int] NULL,
	[LOGDATE] [datetime] NULL,
	[ENTITYNAME] [nvarchar](100) NULL,
	[ERRORNUMBER] [int] NULL,
	[ERRORSEVERITY] [int] NULL,
	[ERRORSTATE] [int] NULL,
	[ERRORPROCEDURE] [nvarchar](128) NULL,
	[ERRORLINE] [int] NULL,
	[ERRORMESSAGE] [nvarchar](4000) NULL
) ON [PRIMARY]
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N' [dbo].[xtrCumulativePatches]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrCumulativePatches](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PATCHCODE] [varchar](100) NULL,
	[ACTIVE] [int] NULL
) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N' [dbo].[xtrLinuxCurrentPatchStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrLinuxCurrentPatchStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MACHINEID] [int] NULL,
	[PATCH] [varchar](256) NULL,
	[PATCHID] [int] NULL,
	[ASSESSEDMACHINESTATEID] [int] NULL,
	[SCANDATE] [datetime] NULL,
	[INSTALLSTATEID] [int] NULL,
	[OSID] [int] NULL
) ON [PRIMARY]

END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N' [dbo].[xtrLinuxDistinctDeployed]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[xtrLinuxDistinctDeployed](
	[MACHINEID] [int] NULL,
	[M] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	[DEPLOYEDON] [datetime] NULL
) ON [PRIMARY]
END


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_MACHINEID')
BEGIN
	CREATE INDEX IDX_MACHINEID ON xtrCurrentPatchStatus (MACHINEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_BULLETIN')
BEGIN
	CREATE INDEX IDX_BULLETIN ON xtrCurrentPatchStatus (BULLETIN)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_PATCHID')
BEGIN
	CREATE INDEX IDX_PATCHID ON xtrCurrentPatchStatus (PATCHID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_PRODUCTID')
BEGIN
	CREATE INDEX IDX_PRODUCTID ON xtrCurrentPatchStatus (PRODUCTID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_ASSESSEDMACHINESTATEID')
BEGIN
	CREATE INDEX IDX_ASSESSEDMACHINESTATEID ON xtrCurrentPatchStatus (ASSESSEDMACHINESTATEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_INSTALLSTATEID')
BEGIN
	CREATE INDEX IDX_INSTALLSTATEID ON xtrCurrentPatchStatus (INSTALLSTATEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrCumulativePatches') AND name = N'IDX_OSID')
BEGIN
	CREATE INDEX IDX_OSID ON xtrCurrentPatchStatus (OSID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrLinuxCurrentPatchStatus') AND name = N'IDX_LINUXMACHINEID')
BEGIN
	CREATE INDEX IDX_LINUXMACHINEID ON xtrLinuxCurrentPatchStatus (MACHINEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrLinuxCurrentPatchStatus') AND name = N'IDX_LINUXPATCHID')
BEGIN
	CREATE INDEX IDX_LINUXPATCHID ON xtrLinuxCurrentPatchStatus (PATCHID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrLinuxCurrentPatchStatus') AND name = N'IDX_LINUXPATCH')
BEGIN
	CREATE INDEX IDX_LINUXPATCH ON xtrLinuxCurrentPatchStatus (Patch)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrLinuxCurrentPatchStatus') AND name = N'IDX_LINUXASSESSEDMACHINESTATEID')
BEGIN
	CREATE INDEX IDX_LINUXASSESSEDMACHINESTATEID ON xtrLinuxCurrentPatchStatus (ASSESSEDMACHINESTATEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.xtrLinuxCurrentPatchStatus') AND name = N'IDX_LINUXINSTALLSTATEID')
BEGIN
	CREATE INDEX IDX_LINUXINSTALLSTATEID ON xtrLinuxCurrentPatchStatus (INSTALLSTATEID)
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END



PRINT 'THANK YOU FOR YOUR PATIENCE.... ALL DONE'