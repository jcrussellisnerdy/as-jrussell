USE LetterGen
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'CSH_31346_LG';
DECLARE @RowsToChange INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChange = count(distinct cbd.ID) from LETTER_RULE lr
join CONTENT_BLOCK_DEFINITION cbd on cbd.ID = lr.RELATE_ID and lr.RELATE_CLASS_TX = 'Allied.UniTrac.ContentBlockDefinition'
where DESCRIPTION_TX IN ('(SMP) Lapse In Coverage IL-MO-WV',
'(SMP) IL-MO-WV Cover Letter') and cbd.PURGE_DT is null

/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT cbd.* into UnitracHDStorage..CSH_31346_LG
		from LETTER_RULE lr
		join CONTENT_BLOCK_DEFINITION cbd on cbd.ID = lr.RELATE_ID and lr.RELATE_CLASS_TX = 'Allied.UniTrac.ContentBlockDefinition'
		where DESCRIPTION_TX IN ('(SMP) Lapse In Coverage IL-MO-WV',
		'(SMP) IL-MO-WV Cover Letter') and cbd.PURGE_DT is null

  
    	/* Does Storage Table meet expectations */
	IF( @@RowCount = @RowsToChange )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
		UPDATE cbd
		set STYLE_NAME_TX = 'ArialNarrow10pt',
		UPDATE_DT = GETDATE(),
		UPDATE_USER_TX = @ticket,
		LOCK_ID = cbd.LOCK_ID % 255 + 1
			from CONTENT_BLOCK_DEFINITION cbd
			join UnitracHDStorage..CSH_31346_LG t on t.ID = cbd.ID


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