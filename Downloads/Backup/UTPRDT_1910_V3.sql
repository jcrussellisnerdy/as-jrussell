USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'UTPRDT_1919_V3';
DECLARE @BackoutCheckFT INT;
DECLARE @UpdateCheckFT INT;
DECLARE @BackoutCheckFTD INT;
DECLARE @UpdateCheckFTD INT;
DECLARE @BackoutCheckCA INT;
DECLARE @UpdateCheckCA INT;
DECLARE @BackoutCheckCD INT;
DECLARE @UpdateCheckCD INT;
DECLARE @BackoutCheckIH INT;
DECLARE @UpdateCheckIH INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
DECLARE @RowsToChangeFT INT = (SELECT COUNT(*) from FINANCIAL_TXN where ID IN (33828022,33828020,33828019,33828018));
DECLARE @RowsToChangeFTD INT = (SELECT COUNT(*) from FINANCIAL_TXN_DETAIL where FINANCIAL_TXN_ID IN (33828022,33828020,33828019,33828018));
DECLARE @RowsToChangeCA INT = (SELECT COUNT(*) from CPI_ACTIVITY where ID IN (63431826));
DECLARE @RowsToChangeCD INT = (SELECT COUNT(*) from CERTIFICATE_DETAIL where CPI_ACTIVITY_ID IN (63431826));
DECLARE @RowsToChangeIH INT = (SELECT COUNT(*) from INTERACTION_HISTORY where ID IN (703651332)) ;

/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM HDTStorage.sys.tables  
               WHERE name like  @Ticket+'%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT * into HDTStorage..UTPRDT_1919_V3_FT
		from FINANCIAL_TXN where ID IN (33828022,33828020,33828019,33828018)
		Set @BackoutCheckFT = @@ROWCOUNT

		SELECT * into HDTStorage..UTPRDT_1919_V3_FTD
		from FINANCIAL_TXN_DETAIL where FINANCIAL_TXN_ID IN (33828022,33828020,33828019,33828018)
		Set @BackoutCheckFTD = @@ROWCOUNT

		SELECT * into HDTStorage..UTPRDT_1919_V3_CA
		from CPI_ACTIVITY where ID IN (63431826)
		Set @BackoutCheckCA = @@ROWCOUNT

		SELECT * into HDTStorage..UTPRDT_1919_V3_CD
		from CERTIFICATE_DETAIL where CPI_ACTIVITY_ID IN (63431826)
		Set @BackoutCheckCD = @@ROWCOUNT

		SELECT * into HDTStorage..UTPRDT_1919_V3_IH
		from INTERACTION_HISTORY where ID IN (703651332)
		Set @BackoutCheckIH = @@ROWCOUNT

  
    	/* Does Storage Table meet expectations */
	IF( @BackoutCheckFT = @RowsToChangeFT AND @BackoutCheckFTD = @RowsToChangeFTD AND @BackoutCheckCA = @RowsToChangeCA AND @BackoutCheckCD = @RowsToChangeCD AND @BackoutCheckIH = @RowsToChangeIH )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
			Update FINANCIAL_TXN
			set PURGE_DT = GETDATE(),
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where ID IN (33828022,33828020,33828019,33828018)
			Set @UpdateCheckFT = @@ROWCOUNT

			UPDATE FINANCIAL_TXN_DETAIL
			set PURGE_DT = GETDATE(),
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where FINANCIAL_TXN_ID IN (33828022,33828020,33828019,33828018)
			Set @UpdateCheckFTD = @@ROWCOUNT

			UPDATE CPI_ACTIVITY
			set TOTAL_PREMIUM_NO = '-1490.66',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where ID IN (63431826)
			Set @UpdateCheckCA = @@ROWCOUNT

			UPDATE CERTIFICATE_DETAIL
			set AMOUNT_NO = '-1490.66',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where CPI_ACTIVITY_ID IN (63431826)
			Set @UpdateCheckCD = @@ROWCOUNT

			update ih 
			set 	 
			SPECIAL_HANDLING_XML.modify('replace value of (/SH/Premium/text())[1] with "149.34"'),
			UPDATE_DT = GETDATE(),
			UPDATE_USER_TX = @Ticket,
			LOCK_ID = ih.LOCK_ID % 255 + 1
			from INTERACTION_HISTORY ih
			where ID = 703651332
			Set @UpdateCheckIH = @@ROWCOUNT


        		/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @UpdateCheckFT = @RowsToChangeFT AND @UpdateCheckFTD = @RowsToChangeFTD AND @UpdateCheckCA = @RowsToChangeCA AND @UpdateCheckCD = @RowsToChangeCD AND @UpdateCheckIH = @RowsToChangeIH )
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