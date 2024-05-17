
IF NOT EXISTS (SELECT * from sys.tables st inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name ='ContainerPath' and sc.name ='TI')
CREATE TABLE TI.ContainerPath
(
    ContainerPathId BIGINT IDENTITY(1,1) NOT NULL,
    ContainerPath NVARCHAR(MAX) NOT NULL,
    [ContainerPathHashValue] AS (CONVERT([int],hashbytes('MD5',[ContainerPath])))
)
IF NOT EXISTS (SELECT * FROM sys.key_constraints kc INNER JOIN sys.tables st ON kc.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerPath' and sc.name ='TI')
ALTER TABLE TI.ContainerPath
ADD CONSTRAINT PK_ContainerPath PRIMARY KEY CLUSTERED (ContainerPathId);

IF NOT EXISTS (SELECT * from sys.tables st inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name ='ContainerScan' and sc.name ='TI')
CREATE TABLE TI.ContainerScan
(
ContainerScanId BIGINT IDENTITY(1,1) NOT NULL,
FK_ScanId INT NOT NULL,
FK_ContainerTypeId TINYINT NOT NULL,
FK_ContainerPathId BIGINT NOT NULL,
FK_PermissionSetId INT NULL,
FK_ParentContainerScanId BIGINT NULL,
Title NVARCHAR(255) NULL,
FileCount INT NOT NULL DEFAULT(0)
);
IF NOT EXISTS (SELECT * FROM sys.key_constraints kc INNER JOIN sys.tables st ON kc.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT PK_ContainerScan PRIMARY KEY CLUSTERED (ContainerScanId);

IF EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_Scan' and delete_referential_action_desc <> 'CASCADE')
ALTER TABLE TI.ContainerScan
DROP CONSTRAINT FK_ContainerScan_Scan;

IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_Scan')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT FK_ContainerScan_Scan FOREIGN KEY (FK_ScanId) REFERENCES TI.Scan(ScanId) ON DELETE CASCADE;


IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_ContainerType')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT FK_ContainerScan_ContainerType FOREIGN KEY (FK_ContainerTypeId) REFERENCES TI.ContainerType(ContainerTypeId);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_ContainerPath')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT FK_ContainerScan_ContainerPath FOREIGN KEY (FK_ContainerPathId) REFERENCES TI.ContainerPath(ContainerPathId);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_PermissionSet')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT FK_ContainerScan_PermissionSet FOREIGN KEY (FK_PermissionSetId) REFERENCES TI.PermissionSet(PermissionSetId);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'ContainerScan' and sc.name ='TI'
and fk.name ='FK_ContainerScan_ParentContainerScan')
ALTER TABLE TI.ContainerScan
ADD CONSTRAINT FK_ContainerScan_ParentContainerScan FOREIGN KEY (FK_ParentContainerScanId) REFERENCES TI.ContainerScan(ContainerScanId);

IF NOT EXISTS (SELECT * FROM sys.columns c inner join sys.tables st on c.object_ID = st.Object_ID   inner join sys.schemas sc on st.schema_id = sc.schema_id 
where st.name ='InventoryScan' and sc.name = 'TI' and c.name ='FK_ContainerScanId')
ALTER TABLE TI.InventoryScan
ADD FK_ContainerScanId BIGINT NULL;

IF NOT EXISTS (SELECT * FROM sys.foreign_keys fk INNER JOIN sys.tables st ON fk.parent_object_id = st.object_id inner join sys.schemas sc on st.schema_id = sc.schema_id where st.name = 'InventoryScan' and sc.name ='TI'
and fk.name ='FK_InventoryScan_ContainerScan')
ALTER TABLE TI.InventoryScan
ADD CONSTRAINT FK_InventoryScan_ContainerScan FOREIGN KEY (FK_ContainerScanId) REFERENCES TI.ContainerScan(ContainerScanId);

IF EXISTS (SELECT * FROM sys.columns c inner join sys.tables st on c.object_ID = st.Object_ID   inner join sys.schemas sc on st.schema_id = sc.schema_id 
WHERE st.name ='ContainerScan' and sc.name = 'TI' and c.name ='FK_PermissionSetId')
ALTER TABLE ti.ContainerScan ALTER COLUMN FK_PermissionSetId INT NULL

IF NOT EXISTS (SELECT * FROM sys.columns c inner join sys.tables st on c.object_ID = st.Object_ID   inner join sys.schemas sc on st.schema_id = sc.schema_id 
WHERE st.name ='ContainerScan' and sc.name = 'TI' and c.name ='FileCount')
ALTER TABLE ti.ContainerScan ADD FileCount INT NOT NULL DEFAULT(0)

IF NOT EXISTS (SELECT * FROM sys.columns c inner join sys.tables st on c.object_ID = st.Object_ID   inner join sys.schemas sc on st.schema_id = sc.schema_id 
WHERE st.name ='ContainerScan' and sc.name = 'TI' and c.name ='Title')
ALTER TABLE ti.ContainerScan ADD Title NVARCHAR(255) NULL

IF NOT EXISTS (SELECT * FROM sys.columns c inner join sys.tables st on c.object_ID = st.Object_ID   inner join sys.schemas sc on st.schema_id = sc.schema_id 
WHERE st.name ='ContainerPath' and sc.name = 'TI' and c.name ='ContainerPathHashValue')
ALTER TABLE ti.ContainerPath ADD [ContainerPathHashValue] AS (CONVERT([int],hashbytes('MD5',[ContainerPath])))



Update [TI].[Scan] set IsDiscovery = 0 Where IsDiscovery is null
