/*
Missing Index Details from SQLQuery7.sql - trapperkeeper.SHAVLIK (ELDREDGE_A\jpieples (72))
The Query Processor estimates that implementing the following index could improve the query cost by 11.7849%.
*/

/*


USE [SHAVLIK]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ScanItems') AND name = N'IX_ScanItems_installState')
BEGIN 
		CREATE NONCLUSTERED INDEX [IX_ScanItems_installState] ON [dbo].[ScanItems] ([installState])
		PRINT 'SUCCESS: [IX_ScanItems_installState] ON [dbo].[ScanItems] successfully added'
END
	ELSE
BEGIN
		PRINT 'WARNING: [IX_ScanItems_installState] ON [dbo].[ScanItems] was not added'
END

*/
