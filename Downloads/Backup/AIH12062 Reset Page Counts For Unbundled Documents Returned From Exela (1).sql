BEGIN TRAN;
/* Declare variables */
DECLARE 
	@Ticket NVARCHAR(15) = 'AIH12062',
	@RowsToChange INT,
	@StartDate DATETIME = '3/18/22',
	@EndDate DATETIME = '4/12/22'

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT 
	@RowsToChange = count(1)
FROM
	VUT.dbo.ScanBatch AS SB
	INNER JOIN LIMC.dbo.ExelaReturnStaging AS ERS ON SB.BatchID = ERS.originalBatchId
WHERE
	SB.BatchDate BETWEEN @StartDate AND @EndDate
	AND SB.DeletedDate IS NULL
	AND SB.BatchedDate IS NULL

/* Existence check for Storage tables - Exit if they exist */
	IF NOT EXISTS (SELECT *
				   FROM HDTStorage.sys.tables  
				   WHERE [Name] LIKE  @Ticket + '_%' AND [TYPE] IN (N'U'))
		BEGIN
			/* Backup ScanBatch Table */
			SELECT	
				ERS.*
			INTO	
				HDTStorage..AIH12062
			FROM
				VUT.dbo.ScanBatch AS SB
				INNER JOIN LIMC.dbo.ExelaReturnStaging AS ERS ON SB.BatchID = ERS.originalBatchId
			WHERE
				SB.BatchDate BETWEEN @StartDate AND @EndDate
				AND SB.DeletedDate IS NULL
				AND SB.BatchedDate IS NULL
				
			/* Does Storage Table meet expectations */
			IF( @@RowCount = @RowsToChange )
				BEGIN
					PRINT 'Storage table meets expections - continue'

					/* Step 3 - Perform table update */
					UPDATE
						ERS
					SET
						documentPageCount = NULL
					FROM
						VUT.dbo.ScanBatch AS SB
						INNER JOIN LIMC.dbo.ExelaReturnStaging AS ERS ON SB.BatchID = ERS.originalBatchId
					WHERE
						SB.BatchDate BETWEEN @StartDate AND @EndDate
						AND SB.DeletedDate IS NULL
						AND SB.BatchedDate IS NULL

					/* Step 4 - Inspect results - Commit/Rollback */
					IF ( @@ROWCOUNT = @RowsToChange )
						BEGIN
							PRINT 'SUCCESS - Performing Commit'
							COMMIT TRAN;
						END
					ELSE
						BEGIN
							PRINT 'FAILED TO UPDATE - Performing Rollback'
							ROLLBACK TRAN;
						END
					END
			ELSE
				BEGIN
					PRINT 'Storage does not meet expectations - rollback'
					ROLLBACK TRAN;
				END
		END
	ELSE
		BEGIN
			PRINT 'HD TABLE EXISTS - Stop work'
			ROLLBACK TRAN;
		END
