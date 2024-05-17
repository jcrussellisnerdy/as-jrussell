USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'UTPRDT_1986_c';
DECLARE @RowsToChange INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChange = count(*)
from CONTROL_NUMBER_MESSAGE where ID = 6154

/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'_C%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT * into UnitracHDStorage..UTPRDT_1986_c
		from CONTROL_NUMBER_MESSAGE where ID = 6420
  
    	/* Does Storage Table meet expectations */
	IF( @@RowCount = @RowsToChange )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
			Update CONTROL_NUMBER_MESSAGE
			set PURGE_DT = NULL,
			LOCK_ID = LOCK_ID % 255 + 1,
			UPDATE_DT = GETDATE(),
			UPDATE_USER_TX = 'UTPRDT_1986'
			where ID = 6154


        		/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @@ROWCOUNT = @RowsToChange )
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