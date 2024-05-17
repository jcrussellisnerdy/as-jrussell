USE UniTrac
GO
create table #BATCHES (batch varchar(100))
Insert Into #BATCHES values
('NTC_110082302_4937818'),('NTC_110082302_4937819'),('NTC_110082302_4937820')


BEGIN TRAN;
/* Declare variables */
DECLARE @Ticket NVARCHAR(15) =N'CSH31318';
DECLARE @RowsToChange INT;

/* Step 1 - Calculate rows to be changed - same query as populate Storage table */
SELECT @RowsToChange = count(pl.ID) --1909
from PROCESS_LOG pl
inner join process_log_item pli on pli.PROCESS_LOG_ID = pl.id and (pli.relate_type_cd = 'allied.unitrac.notice')
inner join output_batch ob on ob.process_log_id = pl.ID
left outer join document_container dc on dc.relate_id = pli.RELATE_ID and (dc.relate_class_name_tx = 'allied.unitrac.notice')
where ob.external_ID IN (SELECT * FROM #BATCHES);

/* Existence check for Storage tables - Exit if they exist */
IF NOT EXISTS (SELECT *
               FROM UNITRACHDSTORAGE.sys.tables  -- Someday this will be the standard 
               WHERE name like  @Ticket+'_%' AND type IN (N'U') )
    BEGIN

        /* populate new Storage table from Sources */
        EXEC('SELECT PL.* into UNITRACHDSTORAGE..'+@Ticket+'_PROCESS_LOG
        from PROCESS_LOG pl
        inner join process_log_item pli on pli.PROCESS_LOG_ID = pl.id and (pli.relate_type_cd = ''allied.unitrac.notice'')
        inner join output_batch ob on ob.process_log_id = pl.ID
        left outer join document_container dc on dc.relate_id = pli.RELATE_ID and (dc.relate_class_name_tx = ''allied.unitrac.notice'')
        where ob.external_ID IN (SELECT * FROM #BATCHES)')
  
        /* Does Storage Table meet expectations */
    IF( @@RowCount = @RowsToChange )
        BEGIN
            PRINT 'Storage table meets expections - continue'

            /* Step 3 - Perform table update */
            update pl
            set 
                pl.PURGE_DT = GETDATE(),
                pl.UPDATE_DT = GETDATE(),
                pl.UPDATE_USER_TX = @ticket,
                pl.LOCK_ID = pl.LOCK_ID % 255 + 1
                --SELECT *
            FROM PROCESS_LOG pl
                inner join process_log_item pli on pli.PROCESS_LOG_ID = pl.id and (pli.relate_type_cd = 'allied.unitrac.notice')
                inner join output_batch ob on ob.process_log_id = pl.ID
                left outer join document_container dc on dc.relate_id = pli.RELATE_ID and (dc.relate_class_name_tx = 'allied.unitrac.notice')
            where ob.external_ID IN (SELECT * FROM #BATCHES)

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
ELSE
    BEGIN
        PRINT 'HD TABLE EXISTS - Stop work'
        COMMIT;
    END