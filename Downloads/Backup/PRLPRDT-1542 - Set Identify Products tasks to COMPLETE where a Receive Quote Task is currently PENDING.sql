/*
rfpl-sql-prod.bc4aa900af54.database.windows.net
*/

USE PRL_ALLIEDSYS_PROD
GO

BEGIN TRAN;

/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'PRLPRDT1542'
	, @RowsToChange BIGINT = 0
	, @RowsBackedUp	BIGINT = 0
	, @RowsUpdated	BIGINT = 0;


IF OBJECT_ID ('tempdb..#tempIDProductTable') IS NOT NULL
	DROP TABLE #tempIDProductTable;

CREATE table #tempIDProductTable (
	ID	bigint identity
	, witID	bigint)

INSERT INTO #tempIDProductTable (witID)
SELECT	ID
FROM	alliedworkitemtasktable 
WHERE	name_tx = 'IdentifyProducts' 
	AND	status_cd = 'PEND'
	AND	purge_dt IS NULL

IF OBJECT_ID ('tempdb..#tempWITTable') IS NOT NULL
	DROP TABLE #tempWITTable;

CREATE table #tempWITTable (
	ID	bigint identity
	, witID	bigint
	, wiID bigint
	, idpID	bigint)


INSERT INTO #tempWITTable (witID, wiID, idpID)
SELECT	wit.ID
		, wit.work_item_id
		, tidp.witID
FROM	alliedworkitemtasktable wit 
INNER JOIN #tempIDProductTable tidp ON wit.parent_work_item_task_id = tidp.witid
WHERE	wit.name_tx = 'CompleteRequiredFields' 
	AND	wit.purge_dt IS NULL

IF OBJECT_ID ('tempdb..#tempRQTable') IS NOT NULL
	DROP TABLE #tempRQTable;

CREATE table #tempRQTable (
	ID	bigint identity
	, witID	bigint
	, idpID bigint)

INSERT INTO #tempRQTable (witID, idpID)
SELECT	wit.ID
		, twit.idpID
FROM	alliedworkitemtasktable wit
INNER JOIN #tempWITTable twit ON wit.work_item_id = twit.wiID
WHERE	wit.name_tx = 'ReceiveQuote'
	AND	wit.status_cd = 'PEND'
	AND	wit.purge_dt IS NULL


/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT	@RowsToChange = count(witID)
FROM	#tempRQTable

PRINT	cast(@RowsToChange as nvarchar(5)) + ' row(s) to change';

/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM HDTStorage.sys.tables   
               WHERE name like  @Ticket+'_%' AND type IN (N'U') )
	BEGIN

    	/* populate new Storage table from Sources */
    	EXEC('SELECT wit.id, wit.name_tx, wit.work_item_id, wit.status_cd, wit.COMPLETE_DT, wit.update_dt, wit.update_user_tx, wit.lock_id
		INTO HDTStorage..'+@Ticket+'_WORK_ITEM_TASK
  		FROM AlliedWorkItemTaskTable wit
		INNER JOIN #tempRQTable trq ON wit.id = trq.idpID')

		SET @RowsBackedUp = @@ROWCOUNT;

		PRINT	cast(@rowsBackedUp as nvarchar(5)) + ' row(s) backed up';
  
    	/* Does Storage Table meet expectations */
	IF( @RowsBackedUp = @RowsToChange )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
			UPDATE	wit /*with(rowlock) DO NOT USE ROWLOCK let SQL handle locking*/
			SET		STATUS_CD = 'COMP'
					, COMPLETE_DT = GETUTCDATE()
					, update_dt = GETUTCDATE()
					, update_user_tx = @ticket
					, [LOCK_ID] = (LOCK_ID+1)%255
			FROM	AlliedWorkItemTaskTable wit
			INNER JOIN #tempRQTable trq ON wit.id = trq.idpID

			SET		@RowsUpdated = @@ROWCOUNT;

			PRINT	cast(@RowsUpdated as nvarchar(5)) + ' row(s) updated';

        		/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @RowsUpdated = @RowsToChange )
		  		BEGIN
		    			PRINT 'SUCCESS - Performing Commit'
		    			COMMIT;
		  		END
			ELSE
		  		BEGIN
		    			PRINT 'FAILED TO UPDATE - Performing Rollback'
		    			ROLLBACK;
		  		END
		END
	ELSE
      		BEGIN
        		PRINT 'Storage does not meet expectations - rollback'
			ROLLBACK;
		END
	END
ELSE
	BEGIN
		PRINT 'HD TABLE EXISTS - Stop work'
		ROLLBACK;
	END


IF OBJECT_ID ('tempdb..#tempIDProductTable') IS NOT NULL
	DROP TABLE #tempIDProductTable;

IF OBJECT_ID ('tempdb..#tempWITTable') IS NOT NULL
	DROP TABLE #tempWITTable;

IF OBJECT_ID ('tempdb..#tempRQTable') IS NOT NULL
	DROP TABLE #tempRQTable;