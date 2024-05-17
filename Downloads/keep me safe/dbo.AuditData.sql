USE [DBA]
GO
/****** Object:  Table [dbo].[AuditData]
DROP TABLE [dbo].[AuditData]
******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AuditData]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[AuditData](
		[event_time] [datetime2](7) NOT NULL,
		[sequence_number] [int] NOT NULL,
		[action_id] [varchar](4) NULL,
		[succeeded] [bit] NOT NULL,
		[permission_bitmask] [varbinary](16) NOT NULL,
		[is_column_permission] [bit] NOT NULL,
		[session_id] [smallint] NOT NULL,
		[server_principal_id] [int] NOT NULL,
		[database_principal_id] [int] NOT NULL,
		[target_server_principal_id] [int] NOT NULL,
		[target_database_principal_id] [int] NOT NULL,
		[object_id] [int] NOT NULL,
		[class_type] [varchar](2) NULL,
		[session_server_principal_name] [nvarchar](128) NULL,
		[server_principal_name] [nvarchar](128) NULL,
		[server_principal_sid] [varbinary](85) NULL,
		[database_principal_name] [nvarchar](128) NULL,
		[target_server_principal_name] [nvarchar](128) NULL,
		[target_server_principal_sid] [varbinary](85) NULL,
		[target_database_principal_name] [nvarchar](128) NULL,
		[server_instance_name] [nvarchar](128) NULL,
		[database_name] [nvarchar](128) NULL,
		[schema_name] [nvarchar](128) NULL,
		[object_name] [nvarchar](128) NULL,
		[statement] [nvarchar](4000) NULL,
		[additional_information] [nvarchar](4000) NULL,
		[file_name] [nvarchar](260) NOT NULL,
		[audit_file_offset] [bigint] NOT NULL,
		[user_defined_event_id] [smallint] NULL,
		[user_defined_information] [nvarchar](4000) NULL,
		[audit_schema_version] [int] NULL,
		[sequence_group_id] [varbinary](85) NULL
	) ON [PRIMARY]
END;

/* Does it exist */
IF EXISTS (SELECT * FROM sys.indexes AS I WHERE I.object_id = OBJECT_ID('[dbo].[AuditData]') AND I.name = 'IX_AuditData')
BEGIN	
	/* Does it match expected values */
	IF NOT EXISTS (
			SELECT i.name AS index_name  
				,COL_NAME(ic.object_id,ic.column_id) AS column_name  
				,ic.index_column_id  
				,ic.key_ordinal  
				,ic.is_included_column  
			FROM sys.indexes AS i  
			INNER JOIN sys.index_columns AS ic
				ON i.object_id = ic.object_id AND i.index_id = ic.index_id  
			WHERE i.object_id = OBJECT_ID('[dbo].[AuditData]') 
				AND i.name = 'IX_AuditData'
				AND COL_NAME(ic.object_id,ic.column_id) = 'event_time'
				AND ic.index_column_id= 1
				AND ic.key_ordinal = 1
				AND ic.is_included_column = 0
		)
		BEGIN
			DROP INDEX IX_AuditData ON [dbo].[AuditData];
		END
	ELSE
		BEGIN
			PRINT 'Definition is correct';
		END
END;

IF NOT EXISTS (SELECT * FROM sys.indexes AS I WHERE I.object_id = OBJECT_ID('[dbo].[AuditData]') AND I.name = 'IX_AuditData')
BEGIN	
	CREATE INDEX IX_AuditData ON [dbo].[AuditData] ([event_time]);
END;
