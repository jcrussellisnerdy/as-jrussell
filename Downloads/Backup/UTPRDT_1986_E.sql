USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'UTPRDT_1986';
DECLARE @RowsToChange INT;
DECLARE @RowsChanged INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChange = count(*) from escrow e
join process_log_item pli on pli.RELATE_ID = e.ID and pli.RELATE_TYPE_CD = 'Allied.UniTrac.Escrow'
where pli.PROCESS_LOG_ID IN (111996140) and TRAN_STATUS_CD = 'SENT'


/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'_E%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT e.* into UnitracHDStorage..UTPRDT_1986_E
		from escrow e
		join process_log_item pli on pli.RELATE_ID = e.ID and pli.RELATE_TYPE_CD = 'Allied.UniTrac.Escrow'
		where pli.PROCESS_LOG_ID IN (111996140) and TRAN_STATUS_CD = 'SENT'
		Set @RowsChanged = @@ROWCOUNT

  
    	/* Does Storage Table meet expectations */
	IF( @RowsChanged = @RowsToChange )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			Set @RowsChanged = 0

			/* Step 3 - Perform table update */
			Update E
			set TRAN_STATUS_CD = 'PEND'
			from escrow e
			join process_log_item pli on pli.RELATE_ID = e.ID and pli.RELATE_TYPE_CD = 'Allied.UniTrac.Escrow'
			where pli.PROCESS_LOG_ID IN (111996140) and TRAN_STATUS_CD = 'SENT'
			Set @RowsChanged = @@ROWCOUNT


        		/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @RowsChanged = @RowsToChange )
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
			PRINT 'Storage table already exists'
			ROLLBACK;
END

GO
