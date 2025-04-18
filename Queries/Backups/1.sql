USE [UiPath]
GO
/****** Object:  Table [dbo].[QueueItems]    Script Date: 7/8/2021 8:22:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QueueItems](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Priority] [int] NOT NULL,
	[QueueDefinitionId] [bigint] NOT NULL,
	[Key] [uniqueidentifier] NOT NULL,
	[Status] [int] NOT NULL,
	[ReviewStatus] [int] NOT NULL,
	[RobotId] [bigint] NULL,
	[StartProcessing] [datetime] NULL,
	[EndProcessing] [datetime] NULL,
	[SecondsInPreviousAttempts] [int] NOT NULL,
	[AncestorId] [bigint] NULL,
	[RetryNumber] [int] NOT NULL,
	[SpecificData] [nvarchar](max) NULL,
	[TenantId] [int] NOT NULL,
	[LastModificationTime] [datetime] NULL,
	[LastModifierUserId] [bigint] NULL,
	[CreationTime] [datetime] NOT NULL,
	[CreatorUserId] [bigint] NULL,
	[DeferDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[Progress] [nvarchar](max) NULL,
	[Output] [nvarchar](max) NULL,
	[OrganizationUnitId] [bigint] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[ProcessingExceptionType] [int] NULL,
	[HasDueDate] [bit] NOT NULL,
	[Reference] [nvarchar](128) NULL,
	[ReviewerUserId] [bigint] NULL,
	[ProcessingExceptionReason] [nvarchar](max) NULL,
	[ProcessingExceptionDetails] [nvarchar](max) NULL,
	[ProcessingExceptionAssociatedImageFilePath] [nvarchar](max) NULL,
	[ProcessingExceptionCreationTime] [datetime] NULL,
	[CreatorJobId] [bigint] NULL,
	[ExecutorJobId] [bigint] NULL,
	[AnalyticsData] [nvarchar](max) NULL,
	[RiskSlaDate] [datetime] NULL,
	[HasRiskSlaDate]  AS (CONVERT([bit],case when [RiskSlaDate] IS NULL then (0) else (1) end)),
 CONSTRAINT [PK_dbo.QueueItems] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[QueueItems] ADD  DEFAULT ((0)) FOR [OrganizationUnitId]
GO
ALTER TABLE [dbo].[QueueItems] ADD  DEFAULT ((0)) FOR [HasDueDate]
GO
ALTER TABLE [dbo].[QueueItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QueueItems_dbo.QueueDefinitions_QueueDefinitionId] FOREIGN KEY([QueueDefinitionId])
REFERENCES [dbo].[QueueDefinitions] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QueueItems] CHECK CONSTRAINT [FK_dbo.QueueItems_dbo.QueueDefinitions_QueueDefinitionId]
GO
ALTER TABLE [dbo].[QueueItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QueueItems_dbo.Robots_RobotId] FOREIGN KEY([RobotId])
REFERENCES [dbo].[Robots] ([Id])
GO
ALTER TABLE [dbo].[QueueItems] CHECK CONSTRAINT [FK_dbo.QueueItems_dbo.Robots_RobotId]
GO
ALTER TABLE [dbo].[QueueItems]  WITH CHECK ADD  CONSTRAINT [FK_dbo.QueueItems_dbo.Users_ReviewerUserId] FOREIGN KEY([ReviewerUserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[QueueItems] CHECK CONSTRAINT [FK_dbo.QueueItems_dbo.Users_ReviewerUserId]
GO
