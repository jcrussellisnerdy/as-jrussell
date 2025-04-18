USE [RPA]
GO
/****** Object:  StoredProcedure [UIPath].[TableMaintenance]    Script Date: 7/13/2022 2:56:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [UIPath].[TableMaintenance] ( @JobName varchar(100), @DatabaseName varchar(100), @SchemaName varchar(100), @TableName varchar(100), @DateColumnName varchar(100))
AS 
BEGIN
	-- EXEC RPA.UIPath.TableMaintenance @JobName = 'UIPath-TableHistoryCleanup', @DatabaseName = 'RPA', @SchemaName ='UIPath', @TableName = 'TableCleanupHistory', @DateColumnName = 'RunDate'

	DECLARE @NumberOfDaysToKeep INT, @RetainRows INT
	DECLARE @BatchSize INT, @Enabled INT, @RemoveRows INT
	DECLARE @SQLStatement nvarchar(200)

	-- SELECT * FROM [RPA].[UIPath].[AgentJobTableRetention]
	SELECT  @NumberOfDaysToKeep = TableRetention,
		@BatchSize = BatchSize,
		@Enabled = Enabled
	FROM [RPA].[UIPath].[AgentJobTableRetention] 
	WHERE JobName = @JobName and TableName = @TableName;

	-- Record Beginning counts
	SELECT @SQLStatement = 'SELECT @RemoveCount = count(*) FROM ['+ @DatabaseName +'].['+ @SchemaName +'].['+  @TableName +'] WHERE DateDiff(day, '+ @DateColumnName +', GetDate()) > '+ convert(varchar(10), @NumberOfDaysToKeep)
	exec sp_executesql @SQLStatement, N'@RemoveCount int out', @RemoveRows out

	SELECT @SQLStatement = 'SELECT @RetainCount = count(*) FROM ['+ @DatabaseName +'].['+ @SchemaName +'].['+  @TableName +'] WHERE DateDiff(day, '+ @DateColumnName +', GetDate()) < '+ convert(varchar(10), @NumberOfDaysToKeep)
	exec sp_executesql @SQLStatement, N'@RetainCount int out', @RetainRows out

	PRINT 'JobName: '+ @jobName 
	PRINT 'TableName: '+ @TableName
	PRINT 'Keeping: '+ convert(varchar(10), @NumberOfDaysToKeep) +' Days'
	PRINT 'BatchSize: '+ convert(varchar(10), @BatchSize) +' rows'
	PRINT 'Enabled: '+ convert(varchar(10), @Enabled) +' '
	PRINT 'Rows to be deleted: '+ convert(varchar(10), @RemoveRows)
	PRINT 'Rows to remain: '+ convert(varchar(10), @RetainRows)

	IF( (@Enabled = 1) AND (@RemoveRows > 0) )
		BEGIN
			INSERT INTO [RPA].[UIPath].[TableCleanupHistory]
				([JobName],[StepName],[TableName],[RemoveCount],[RetainCount],[RunDate])
			VALUES
				( @jobName, @TableName, @TableName, @RemoveRows, @RetainRows, GetDate() )
			/* Insert statement will return @@RowCount = 1 */
			WHILE ( @@Rowcount > 0 )
				BEGIN
					-- Ledger table cleanup
					SELECT @SQLStatement = 'DELETE TOP('+ convert(varchar(10), @BatchSize) +') FROM ['+ @DatabaseName +'].['+ @SchemaName +'].['+  @TableName +'] WHERE DateDiff(day, '+ @DateColumnName +', GetDate()) > '+  convert(varchar(10), @NumberOfDaysToKeep)
					-- PRINT @SQLStatement
					EXEC(@SQLStatement)
				END
			-- SELECT * FROM [RPA].[UIPath].[TableCleanupHistory]
		END
	ELSE
		BEGIN
			IF( @Enabled = 0 )
				BEGIN
					PRINT 'Nothing Processed - Table Disabled.'
				END
			ELSE
				BEGIN
					PRINT 'No rows to delete.'
				END
		END
END
