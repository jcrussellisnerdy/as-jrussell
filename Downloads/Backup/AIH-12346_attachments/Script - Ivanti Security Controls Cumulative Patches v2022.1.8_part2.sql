USE [SHAVLIK]
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'AIH_12346';
DECLARE @RowsToInsert bigint = 0;

/* Step 1 - Calculate rows to be Inserted */
SET @RowsToInsert = 36; /*If the rows are not contained in an existing table*/

/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM HDTStorage.sys.tables  
               WHERE name like  @Ticket+'_xtrCumulativePatches' AND type IN (N'U') )
	BEGIN
    		/* Step 2 - Create EMPTY Storage Table  */
		EXEC('SELECT [ID], [PATCHCODE], [ACTIVE]  /*Specify columns to avoid identity columns*/
          		INTO HDTStorage..'+ @Ticket+'_xtrCumulativePatches
          		FROM DBO.xtrCumulativePatches
          		WHERE 1=0');  /*WHERE 1=0 creates table without moving data*/
    
		/* populate new Storage table from Sources */
		INSERT INTO HDTStorage..AIH_12346_xtrCumulativePatches ( PATCHCODE, ACTIVE ) /*Specify columns to avoid identity columns*/
		VALUES
			( 'MSNS%-MRNET-%',1),
			( '%-MRNET-%',1),
			( '%SSU%',1),
			( 'VMWT%',1),
			( '%CHROME%',1),
			( '%MSFT%',1),
			( 'MEDGE%',1),
			( 'NPPP%',1),
			( '%-IE-%',1),
			( '%-SO81-%',1),
			( '%-SQL-%',1),
			( '%-AFP%',1),
			( 'SQL%',1),
			( '%-O365-%',1),
			( '%-365-%',1),
			( '%VS2015%',1),
			( '%DNETC21%',1),
			( '%MSVC14%',1),
			( 'MSRT%',1),
			( '%-SONET-%',1),
			( '%-MR81-%',1),
			( 'MS2%-W10-%',1),
			( 'APSB%',1),
			( '%-OFF-%',1),
			( 'MSNS%-W10-%',1),
			( 'NOJSC%',1),
			( 'SQL2019-%',1),
			( 'OROO-%',1),
			( '%-W10-%',1),
			( '%-QP81-%',1),
			( 'SSMS%',1),
			( '%DNETC%',1),
			( 'MS19%-IE-%',2),
			( 'MS18%-IE-%',2),
			( 'MS20-01-IE-%',2),
			( 'MS20-02-IE-%',2);
  
    		/* Does Storage Table meet expectations */
		IF( @@RowCount = @RowsToInsert )
			BEGIN
				PRINT 'Storage table meets expections - continue'

				/* Step 3 - Perform table INSERT */
				INSERT INTO xtrCumulativePatches 
				SELECT PATCHCODE, ACTIVE
				FROM HDTStorage..AIH_12346_xtrCumulativePatches
				

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
