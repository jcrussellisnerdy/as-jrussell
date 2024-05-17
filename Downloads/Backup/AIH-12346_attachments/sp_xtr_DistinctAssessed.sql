USE SHAVLIK



IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_DistinctAssessed]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_DistinctAssessed] ;
GO





IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_DistinctAssessed]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_DistinctAssessed] AS RETURN 0;';
END;
GO

ALTER PROCEDURE [dbo].[xtr_DistinctAssessed](@BATCHID INT)


AS
BEGIN 
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_DistinctAssessed'

BEGIN TRY
TRUNCATE TABLE xtrDistinctAssessed

INSERT INTO xtrDistinctAssessed

SELECT machineid, MONTH([AssessedOn]) M, year([AssessedOn]) y, max([AssessedOn]) Assessedon
  FROM [Reporting2].[AssessedMachineState]
  WHERE AssessedOn IS NOT NULL 
  group by machineid, MONTH([AssessedOn]) , year([AssessedOn]) 

RETURN CAST(@@rowcount AS INT)

END TRY

BEGIN CATCH
	EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
	
END CATCH

END
