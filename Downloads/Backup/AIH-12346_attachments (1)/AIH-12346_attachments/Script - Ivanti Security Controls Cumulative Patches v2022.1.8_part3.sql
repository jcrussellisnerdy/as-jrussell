USE [SHAVLIK]
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'AIH_12346';
DECLARE @RowsToInsert bigint = 0;

/* Step 1 - Calculate rows to be Inserted */
SET @RowsToInsert = 2; /*If the rows are not contained in an existing table*/

/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM HDTStorage.sys.tables  
               WHERE name like  @Ticket+'_xtrLinuxCumulativePatches' AND type IN (N'U') )
	BEGIN
    		/* Step 2 - Create EMPTY Storage Table  */
		EXEC('SELECT [ID], [PATCHCODE], [ACTIVE]  /*Specify columns to avoid identity columns*/
          		INTO HDTStorage..'+ @Ticket+'_xtrLinuxCumulativePatches
          		FROM DBO.xtrLinuxCumulativePatches
          		WHERE 1=0');  /*WHERE 1=0 creates table without moving data*/
    
		/* populate new Storage table from Sources */
		INSERT INTO HDTStorage..AIH_12346_xtrLinuxCumulativePatches ( PATCHCODE, ACTIVE ) /*Specify columns to avoid identity columns*/
		VALUES
		( '%Firefox%',1),
		( '%Chrome%',1);
  
    		/* Does Storage Table meet expectations */
		IF( @@RowCount = @RowsToInsert )
			BEGIN
				PRINT 'Storage table meets expections - continue'

				/* Step 3 - Perform table INSERT */
				INSERT INTO xtrLinuxCumulativePatches 
				SELECT PATCHCODE, ACTIVE
				FROM HDTStorage..AIH_12346_xtrLinuxCumulativePatches
				

				/* Step 4 - Inspect results - Commit/Rollback */
				IF ( @@ROWCOUNT = @RowsToInsert )
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
		COMMIT;
	END
