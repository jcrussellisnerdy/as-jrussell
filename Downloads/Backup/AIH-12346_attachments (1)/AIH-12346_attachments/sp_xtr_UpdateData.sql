USE SHAVLIK


IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_ID = OBJECT_ID(N'[dbo].[xtr_UpdateData]')
                    AND type IN (N'P') ) 
    DROP PROCEDURE [dbo].[xtr_UpdateData] ;
GO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[xtr_UpdateData]') AND type in (N'P', N'PC'))
BEGIN
	/* Create Empty Stored Procedure */
	EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[xtr_UpdateData] AS RETURN 0;';
END;
GO

 
ALTER PROCEDURE [dbo].[xtr_UpdateData]

AS
BEGIN
BEGIN TRY

DECLARE @CumulativePatches TABLE (
ID INT,
PATCHCODE VARCHAR(256),
ACTIVE INT
)
DECLARE @ENTITYNAME VARCHAR(100) = 'xtr_UpdateData'
DECLARE @STAGEDRECORDCOUNT INT = 0
DECLARE @ID INT, @PATCHCODE VARCHAR(256)
DECLARE @BATCHID INT = (SELECT ISNULL(max(BATCHID),0) + 1 FROM dbo.xtrEntityProcessLog)
DECLARE @DELETEDRECORDS INT = 0
DECLARE @DELETEDOBSRECORDS INT = 0
DECLARE @DELETEDODRECORDS INT = 0
DECLARE @RETURNVALUE INT = 0

-- Calls the procedure xtr_CurrentPatchStatus which gets a list of all patches,
-- the install state of each patch the last time it was detected and the datetime of that detection

BEGIN
EXEC xtr_CurrentPatchStatus @BATCHID, @RECORDSSTAGED = @STAGEDRECORDCOUNT OUTPUT
END

-- Calls the procedure xtr_DeleteCPatches and removes any patch that is in the cumulative list that has a
-- later version of that patch installed

INSERT INTO @CumulativePatches
SELECT 
	ID,
	PATCHCODE,
	ACTIVE
FROM dbo.xtrCumulativePatches
WHERE ACTIVE = 1

WHILE (SELECT COUNT(0) FROM @CumulativePatches) > 0
BEGIN
	BEGIN TRY
	
		SELECT TOP 1 
			@ID = ID,
			@PATCHCODE = PATCHCODE
 		FROM @CumulativePatches
		
		EXEC @RETURNVALUE = xtr_DeleteCPatches @PATCHCODE, @BATCHID
		SET @DELETEDRECORDS = @DELETEDRECORDS + @RETURNVALUE
		DELETE FROM @CumulativePatches WHERE PATCHCODE = @PATCHCODE

	END TRY

		BEGIN CATCH
		DELETE FROM @CumulativePatches WHERE PATCHCODE = @PATCHCODE
		END CATCH
END
			INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
			VALUES (@BATCHID, GETUTCDATE(), 'xtr_DeleteCPatches', 'Deleted ' + CAST(@DELETEDRECORDS AS NVARCHAR(100)) + ' records')
END TRY
	
BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH

-- Calls the procedure xtr_DeleteObsPatches and removes any obsolete patch that is in the cumulative list

BEGIN TRY
INSERT INTO @CumulativePatches
SELECT 
	ID,
	PATCHCODE,
	ACTIVE
FROM dbo.xtrCumulativePatches
WHERE ACTIVE = 2

WHILE (SELECT COUNT(0) FROM @CumulativePatches) > 0
BEGIN
	BEGIN TRY
	
		SELECT TOP 1 
			@ID = ID,
			@PATCHCODE = PATCHCODE
 		FROM @CumulativePatches
		
		EXEC @RETURNVALUE = xtr_DeleteObsPatches @PATCHCODE, @BATCHID
		SET @DELETEDOBSRECORDS = @DELETEDOBSRECORDS + @RETURNVALUE
		DELETE FROM @CumulativePatches WHERE PATCHCODE = @PATCHCODE

	END TRY

		BEGIN CATCH
		DELETE FROM @CumulativePatches WHERE PATCHCODE = @PATCHCODE
		END CATCH
END
			INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
			VALUES (@BATCHID, GETUTCDATE(), 'xtr_DeleteObsPatches', 'Deleted ' + CAST(@DELETEDOBSRECORDS AS NVARCHAR(100)) + ' records')
END TRY
	
BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH
-- Calls the procedure xtr_DeleteODPatches and removes any patch that has not been detected in the last 90 days where the machine
-- has been scanned in the last 90 days
BEGIN
		
		EXEC @RETURNVALUE = xtr_DeleteODPatches @BATCHID
		SET @DELETEDODRECORDS =  @RETURNVALUE

			INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
			VALUES (@BATCHID, GETUTCDATE(), 'xtr_DeleteODPatches', 'Deleted ' + CAST(@DELETEDODRECORDS AS NVARCHAR(100)) + ' records')
END

BEGIN TRY
EXEC @RETURNVALUE = xtr_CurrentPatchCount @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_CurrentPatchCount', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH

BEGIN TRY
EXEC @RETURNVALUE = xtr_DistinctAssessed @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_DistinctAssessed', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH


BEGIN TRY
EXEC @RETURNVALUE = xtr_DistinctDeployed @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_DistinctDeployed', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH

BEGIN TRY
EXEC @RETURNVALUE = xtr_DistinctPatched @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_DistinctPatched', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH




BEGIN TRY

DECLARE @LinuxCumulativePatches TABLE (
ID INT,
PATCHCODE VARCHAR(256),
ACTIVE INT
)
SET @ENTITYNAME = 'xtr_LinuxUpdateData'
SET  @STAGEDRECORDCOUNT = 0
SET @ID = 0
SET @PATCHCODE = ''
SET @BATCHID = (SELECT ISNULL(max(BATCHID),0) + 1 FROM dbo.xtrEntityProcessLog)
SET @DELETEDRECORDS = 0
SET @RETURNVALUE = 0
BEGIN

EXEC xtr_LinuxCurrentPatchStatus @BATCHID, @RECORDSSTAGED = @STAGEDRECORDCOUNT OUTPUT

END


INSERT INTO @LinuxCumulativePatches
SELECT 
	ID,
	PATCHCODE,
	ACTIVE
FROM dbo.xtrLinuxCumulativePatches
WHERE ACTIVE = 1


WHILE (SELECT COUNT(0) FROM @LinuxCumulativePatches) > 0
BEGIN
	BEGIN TRY
	
		SELECT TOP 1 
			@ID = ID,
			@PATCHCODE = PATCHCODE
 		FROM @LinuxCumulativePatches


		
		EXEC @RETURNVALUE = xtr_LinuxDeleteCPatches @PATCHCODE, @BATCHID
		SET @DELETEDRECORDS = @DELETEDRECORDS + @RETURNVALUE
		DELETE FROM @LinuxCumulativePatches WHERE PATCHCODE = @PATCHCODE


	END TRY

		BEGIN CATCH
		DELETE FROM @LinuxCumulativePatches WHERE PATCHCODE = @PATCHCODE
		END CATCH


END

			INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
			VALUES (@BATCHID, GETUTCDATE(), 'xtr_LinuxDeleteCPatches', 'Deleted ' + CAST(@DELETEDRECORDS AS NVARCHAR(100)) + ' records')

END TRY
	
BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH



BEGIN TRY
EXEC @RETURNVALUE = xtr_LinuxCurrentPatchCount @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_LinuxCurrentPatchCount', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH



BEGIN TRY
EXEC @RETURNVALUE = xtr_LinuxDistinctDeployed @BATCHID

INSERT INTO dbo.xtrEntityProcessLog (BATCHID, LOGDATE, PROCEDURENAME, DESCRIPTION) 
VALUES (@BATCHID, GETUTCDATE(), 'xtr_LinuxDistinctDeployed', 'Inserted ' + CAST(@RETURNVALUE AS NVARCHAR(100)) + ' records')

END TRY

BEGIN CATCH
EXEC xtr_LogErrorInfo @BATCHID, @ENTITYNAME
END CATCH



END
