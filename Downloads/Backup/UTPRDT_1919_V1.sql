Use UniTrac
GO

BEGIN TRAN

Declare @Ticket nvarchar(20) = 'UTPRDT_1919'
Declare @Date datetime = GETDATE()

CREATE TABLE #Values
(CA_ID bigint,NEW_AMOUNT decimal(18,2),CURRENT_AMOUNT decimal(18,2),FT_ID bigint,FPC_ID bigint,PURGED_AMOUNT decimal(18,2),IH_ID bigint,NEW_PREMIUM decimal(18,2))

--CORRECTED REFUND VALUES TABLE--
--MUST ENTER CA_ID(CPI ACTIVITY ID) and NEW AMOUNT--
Insert into #Values
Values
(63317982,'-107.68',NULL,NULL,NULL,NULL,NULL,NULL),
(63319798,'0.00',NULL,NULL,NULL,NULL,NULL,NULL),
(63364666,'-861.64',NULL,NULL,NULL,NULL,NULL,NULL),
(63385717,'-114.04',NULL,NULL,NULL,NULL,NULL,NULL),
(63385225,'-697.86',NULL,NULL,NULL,NULL,NULL,NULL),
(63430851,'-7595.58',NULL,NULL,NULL,NULL,NULL,NULL)


Update val
set FPC_ID = FPC.ID,
Current_Amount = ca.TOTAL_PREMIUM_NO
from #Values val
join CPI_ACTIVITY ca on ca.ID = val.CA_ID
join FORCE_PLACED_CERTIFICATE fpc on fpc.CPI_QUOTE_ID = ca.CPI_QUOTE_ID

Update val
set FPC_ID = FPC.ID,
Current_Amount = ca.TOTAL_PREMIUM_NO
from #Values val
join CPI_ACTIVITY ca on ca.ID = val.CA_ID
join FORCE_PLACED_CERTIFICATE fpc on fpc.CPI_QUOTE_ID = ca.CPI_QUOTE_ID


Update val
Set FT_ID = ft.ID,
PURGED_AMOUNT = ft.AMOUNT_NO
from #Values val
join FINANCIAL_TXN ft on ft.FPC_ID = val.FPC_ID
where ft.TXN_TYPE_CD = 'C' and AMOUNT_NO > 0 and PURGE_DT is null and AMOUNT_NO = (Current_Amount - NEW_Amount)

Update val
Set NEW_PREMIUM = (SPECIAL_HANDLING_XML.value('(/SH/Premium)[1]', 'nvarchar(max)')-val.PURGED_AMOUNT),
IH_ID = ih.ID
from INTERACTION_HISTORY ih
join
#Values val
on val.FPC_ID	= IH.RELATE_ID 
and ih.RELATE_CLASS_TX = 'Allied.UniTrac.ForcePlacedCertificate'
and ih.TYPE_CD = 'CPI'

Update #Values
set IH_ID = NULL
where FT_ID is null and PURGED_AMOUNT is null and NEW_PREMIUM is null


DECLARE @RowsToChangeCA INT;
DECLARE @RowsToChangeIH INT;
DECLARE @RowsToChangeCD INT;
DECLARE @RowsToChangeFT INT;
DECLARE @RowsChangedIH INT;
DECLARE @RowsChangedCD INT;
DECLARE @RowsChangedCA INT;
DECLARE @RowsChangedFT INT;

IF NOT EXISTS (SELECT *
               FROM UnitracHDStorage.sys.tables  
               WHERE name like '%UTPRDT_1919_V1%' AND type IN (N'U') )
	BEGIN


/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChangeCA = count(*)
FROM #Values where CA_ID is not null

SELECT @RowsToChangeCD = count(*)
FROM #Values where CA_ID is not null

SELECT @RowsToChangeIH = count(*)
FROM #Values where IH_ID is not null

SELECT @RowsToChangeFT = count(*)
FROM #Values where FT_ID is not null
/* Existence check for Storage tables - Exit if they exist */
	BEGIN

    	/* populate new Storage table from Sources */
    	Select ih.ID[IH_ID],SPECIAL_HANDLING_XML[IH_SH],cd.ID[CD_ID],cd.AMOUNT_NO,ca.ID[CA_ID],ca.TOTAL_PREMIUM_NO,FT.ID[FT_ID],FT.PURGE_DT[FT_PURGE_DT] 
		into UnitracHDStorage..UTPRDT_1919_V1
		from #Values val
		join CPI_ACTIVITY ca on ca.ID = val.CA_ID
		join CERTIFICATE_DETAIL cd on cd.CPI_ACTIVITY_ID = val.CA_ID
		left Join INTERACTION_HISTORY ih on ih.ID = val.IH_ID
		left join FINANCIAL_TXN FT on FT.ID = val.FT_ID
  
    	/* Does Storage Table meet expectations */
	IF( @@RowCount = @RowsToChangeCA )
		BEGIN
			PRINT 'Storage table meets expections - continue'

			/* Step 3 - Perform table update */
			--UPDATE REFUND VALUES--
				Update ca
				set TOTAL_PREMIUM_NO = val.NEW_AMOUNT,
				UPDATE_DT = @Date,
				UPDATE_USER_TX = @Ticket,
				LOCK_ID = LOCK_ID % 255 + 1
				--Select *
				from CPI_ACTIVITY ca
				join #Values val on val.CA_ID = ca.ID
				Set @RowsChangedCA  = @@ROWCOUNT


				--UPDATE DETAILS TO MATCH NEW REFUND VALUES--
				Update cd
				set AMOUNT_NO = ca.TOTAL_PREMIUM_NO,
				UPDATE_DT = @Date,
				UPDATE_USER_TX = @Ticket,
				LOCK_ID = cd.LOCK_ID % 255 + 1
				--select ca.TOTAL_PREMIUM_NO,cd.*
				from CPI_ACTIVITY ca
				join CERTIFICATE_DETAIL cd on cd.CPI_ACTIVITY_ID = ca.ID and cd.TYPE_CD = 'PRM'
				join #Values val on val.CA_ID = ca.ID
				Set @RowsChangedCD  = @@ROWCOUNT


				update ih 
				set 	 
				SPECIAL_HANDLING_XML.modify('replace value of (/SH/Premium/text())[1] with sql:column("val.NEW_PREMIUM")'),
				UPDATE_DT = @Date,
				UPDATE_USER_TX = @Ticket,
				LOCK_ID = ih.LOCK_ID % 255 + 1
				--Select *
				from INTERACTION_HISTORY ih
				join #Values val on val.IH_ID = ih.ID
				Set @RowsChangedIH  = @@ROWCOUNT

				Update FT
				Set PURGE_DT = @Date,
				UPDATE_DT = @Date,
				UPDATE_USER_TX = @Ticket,
				LOCK_ID = FT.LOCK_ID % 255 + 1
				--Select *
				from FINANCIAL_TXN FT
				join #Values val on val.FT_ID = FT.ID
				Set @RowsChangedFT  = @@ROWCOUNT

        		/* Step 4 - Inspect results - Commit/Rollback */
			IF ( @RowsChangedCA = @RowsToChangeCA and @RowsChangedCD = @RowsToChangeCD and @RowsChangedFT = @RowsToChangeFT and @RowsChangedIH = @RowsToChangeIH)
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
END