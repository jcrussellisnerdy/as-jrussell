USE UniTrac
GO

BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'UTPRDT_1919';
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
DECLARE @RowsToChangeFT INT =  (Select COUNT(*) from FINANCIAL_TXN where ID IN (33827967));
DECLARE @RowsToChangeFTD INT = (Select COUNT(*) from FINANCIAL_TXN_DETAIL where FINANCIAL_TXN_ID IN (33827967));
DECLARE @RowsToChangeCA INT = (Select COUNT(*) from CPI_ACTIVITY where ID IN (63370329,63370154));
DECLARE @RowsToChangeCD INT = (Select COUNT(*) from  CERTIFICATE_DETAIL where ID IN (63370329,63370154));
DECLARE @RowsToChangeIH INT = (Select COUNT(*) from INTERACTION_HISTORY where ID IN (700341118));

/* Existence check for Storage tables - Exit if they exist */
/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like  @Ticket+'_V2%' AND type IN (N'U') )
	BEGIN
    	/* populate new Storage table from Sources */
    	SELECT * into UnitracHDStorage..UTPRDT_1919_V2_FT
		from FINANCIAL_TXN where ID IN (33827967)
		Set @BackoutCheckFT = @@ROWCOUNT

		SELECT * into UnitracHDStorage..UTPRDT_1919_V2_FTD
		from FINANCIAL_TXN_DETAIL where FINANCIAL_TXN_ID IN (33827967)
		Set @BackoutCheckFTD = @@ROWCOUNT

		SELECT * into UnitracHDStorage..UTPRDT_1919_V2_CA
		from CPI_ACTIVITY where ID IN (63370329,63370154)
		Set @BackoutCheckCA = @@ROWCOUNT

		SELECT * into UnitracHDStorage..UTPRDT_1919_V2_CD
		from CERTIFICATE_DETAIL where CPI_ACTIVITY_ID IN (63370329,63370154)
		Set @BackoutCheckCD = @@ROWCOUNT

		SELECT * into UnitracHDStorage..UTPRDT_1919_V2_IH
		from INTERACTION_HISTORY where ID IN (700341118)
		Set @BackoutCheckIH = @@ROWCOUNT

  
    	/* Does Storage Table meet expectations */
	IF( @BackoutCheckFT = @RowsToChangeFT AND @BackoutCheckFTD = @RowsToChangeFTD AND @BackoutCheckCA = @RowsToChangeCA AND @BackoutCheckCD = @RowsToChangeCD AND @BackoutCheckIH = @RowsToChangeIH )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
			Update FINANCIAL_TXN
			set amount_no = '-34.37',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where ID IN (33827967)
			Set @UpdateCheckFT = @@ROWCOUNT

			UPDATE FINANCIAL_TXN_DETAIL
			set amount_no = '-34.37',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where FINANCIAL_TXN_ID IN (33827967)
			Set @UpdateCheckFTD = @@ROWCOUNT

			UPDATE CPI_ACTIVITY
			set TOTAL_PREMIUM_NO = '-412.44',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where ID IN (63370329)
			Set @UpdateCheckCA = @@ROWCOUNT

			UPDATE CPI_ACTIVITY
			set TOTAL_PREMIUM_NO = '-481.18',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where ID IN (63370154)
			Set @UpdateCheckCA = @@ROWCOUNT + @UpdateCheckCA

			UPDATE CERTIFICATE_DETAIL
			set AMOUNT_NO = '-412.44',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where CPI_ACTIVITY_ID IN (63370329)
			Set @UpdateCheckCD = @@ROWCOUNT

			UPDATE CERTIFICATE_DETAIL
			set AMOUNT_NO = '-481.18',
			UPDATE_USER_TX = @Ticket,
			UPDATE_DT = GETDATE(),
			LOCK_ID = LOCK_ID % 255 + 1
			where CPI_ACTIVITY_ID IN (63370154)
			Set @UpdateCheckCD = @@ROWCOUNT + @UpdateCheckCD

			update ih 
			set 	 
			SPECIAL_HANDLING_XML.modify('replace value of (/SH/Premium/text())[1] with "34.38"'),
			UPDATE_DT = GETDATE(),
			UPDATE_USER_TX = @Ticket,
			LOCK_ID = ih.LOCK_ID % 255 + 1
			from INTERACTION_HISTORY ih
			where ID = 700341118
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