USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'CSH_30763';
DECLARE @RowsToChange INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChange = count(distinct cbd.ID) from LETTER_RULE lr
join CONTENT_BLOCK_DEFINITION cbd on cbd.ID = lr.RELATE_ID and lr.RELATE_CLASS_TX = 'Allied.UniTrac.ContentBlockDefinition'
where DESCRIPTION_TX IN (
'Mortgagee - Townhome (blank)',
'No Walls In - Townhome',
'Cancel - Townhome',
'Expire - Townhome',
'In-Force - Townhome',
'No Policy - Townhome',
'HOA Expired w/good Unit pol - Townhome',
'HOA Infrc w/ExpCxl Unit pol - Twonhome',
'No HOA w/Expired HO6 - Townhome',
'No HOA w/Inforce Unit pol - Townhome',
'HO6 Inforce w/Expr HOA - Townhome',
'Inad Cvg - HO6 - Townhome',
'Expired - Townhome')

/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT cbd.* into UnitracHDStorage..CSH_30763
		from LETTER_RULE lr
		join CONTENT_BLOCK_DEFINITION cbd on cbd.ID = lr.RELATE_ID and lr.RELATE_CLASS_TX = 'Allied.UniTrac.ContentBlockDefinition'
		where DESCRIPTION_TX IN (
		'Mortgagee - Townhome (blank)',
		'No Walls In - Townhome',
		'Cancel - Townhome',
		'Expire - Townhome',
		'In-Force - Townhome',
		'No Policy - Townhome',
		'HOA Expired w/good Unit pol - Townhome',
		'HOA Infrc w/ExpCxl Unit pol - Twonhome',
		'No HOA w/Expired HO6 - Townhome',
		'No HOA w/Inforce Unit pol - Townhome',
		'HO6 Inforce w/Expr HOA - Townhome',
		'Inad Cvg - HO6 - Townhome',
		'Expired - Townhome')

  
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
			join UnitracHDStorage..CSH_30763 t on t.ID = cbd.ID


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