USE [ACSYSTEM]
GO

/****** Object:  StoredProcedure [dbo].[procGetNextBatch_WP]    Script Date: 4/27/2022 12:26:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[procGetNextBatch_WP] (@lUserProfileID int , @lStates int , @lInProgressState int , @dtAcisStartTime datetime , @strMachineName nvarchar(255) , @lOsProcessID int , @strProcessName nvarchar(32) , @strStationID nvarchar(32) , @strLockID CHAR(38) , @lProcessID int , @FilterUserID nvarchar(255) , @BatchNameEQ nvarchar(128) , @BatchNameNE nvarchar(128) , @BatchNameLT nvarchar(128) , @BatchNameGT nvarchar(128) , @BatchNamePM nvarchar(260) , @BatchNameNL int , @BatchNameNN int , @ClassNameEQ int , @QueueEQ int , @QueueNE int , @StatusEQ int , @StatusNE int , @PriorityEQ int , @PriorityNE int , @PriorityLT int , @PriorityGT int , @ContainsErrorsEQ int , @ContainsErrorsNE int , @StationIDEQ nvarchar(32) , @StationIDNE nvarchar(32) , @StationIDLT nvarchar(32) , @StationIDGT nvarchar(32) , @StationIDPM nvarchar(68) , @StationIDNL int , @StationIDNN int , @CreationDateLT datetime , @CreationDateGT datetime , @CreationDateDT datetime , @BatchFieldValueEQ nvarchar(260) , @BatchFieldValueNE nvarchar(260) , @BatchFieldValueLT nvarchar(260) , @BatchFieldValueGT nvarchar(260) , @BatchFieldValuePM nvarchar(260) , @BatchFieldValueNL int , @BatchFieldValueNN int , @BatchFieldNameEQ nvarchar(34) , @ScanStationIDEQ nvarchar(32) , @ScanStationIDNE nvarchar(32) , @ScanStationIDLT nvarchar(32) , @ScanStationIDGT nvarchar(32) , @ScanStationIDPM nvarchar(32) , @ScanStationIDNL int , @ScanStationIDNN int , @ScanUserIDEQ nvarchar(128) , @ScanUserIDNE nvarchar(128) , @ScanUserIDLT nvarchar(128) , @ScanUserIDGT nvarchar(128) , @ScanUserIDPM nvarchar(128) , @ScanUserIDNL int , @ScanUserIDNN int , @Reserved01BA int ) AS 
	DECLARE @lExternalBatchID INT;
DECLARE @strLockName NVARCHAR(32);
DECLARE @strExistingLockID AS CHAR(38);
DECLARE @lIsVerificationModule INT = dbo.IsVerificationModule(@lProcessID);
DECLARE @lRetry INT;
SET @lRetry = 5;
WHILE @lRetry > 0
BEGIN
	DELETE FROM GetNextBatchSessions WHERE LastUpdateTime < DATEADD(mi, -2, GETDATE()); 
	UPDATE GetNextBatchSessions SET LastUpdateTime = GETDATE() WHERE MachineName=@strMachineName AND OsProcessID = @lOsProcessID AND ProcessID = @lProcessID 
	IF @@ROWCOUNT = 0 
		INSERT INTO GetNextBatchSessions(MachineName, OsProcessID, ProcessID, LastUpdateTime) VALUES(@strMachineName, @lOsProcessID, @lProcessID, GETDATE()) 
	DECLARE @lPartitions INT;
	DECLARE @lMyPartition INT; 
	SET @lPartitions = (SELECT COUNT(*) FROM GetNextBatchSessions WHERE ProcessID=@lProcessID);
	WITH OrderedSessions AS 
	(
		SELECT MachineName, OsProcessID, ROW_NUMBER() OVER (ORDER BY MachineName, OsProcessID) AS RowNumber
		FROM GetNextBatchSessions WHERE ProcessID = @lProcessID 
	)
	SELECT @lMyPartition = RowNumber FROM OrderedSessions WHERE MachineName = @strMachineName AND OsProcessID = @lOsProcessID 
	-- Special processing for RSAs which do not require filtering
	IF @lProcessID = 15000
	BEGIN
		UPDATE BatchCatalog SET @lExternalBatchID = ExternalBatchID, ProbablyInUse = ProbablyInUse + 1 WHERE ExternalBatchID = (
			SELECT TOP 1 BatchCatalog.ExternalBatchID
			FROM BatchCatalog WHERE @lUserProfileID = 0
					AND BatchCatalog.ProcessID = @lProcessID
					AND ((@lStates) & (State)) <> 0
					AND (
						@lInProgressState = 0
						OR InProgressState = @lInProgressState
						)
					AND (
						@dtAcisStartTime IS NULL
						OR NOT EXISTS (
							(
								SELECT 1
								FROM AcisRTransfer, AcisRCentralSite
								WHERE AcisRTransfer.CentralSiteGUID = AcisRCentralSite.SiteGUID
									AND AcisRCentralSite.LastFailed > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								
								UNION
								
								SELECT 1
								FROM AcisRTransfer
								WHERE AcisRTransfer.LastStatusCheck > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								)
							)
						)
		ORDER BY Priority, CASE (BatchCatalog.ExternalBatchID % @lPartitions) + 1 WHEN @lMyPartition THEN 0 ELSE 1 END, BatchCatalog.ProbablyInUse, BatchCatalog.ExternalBatchID 
		)
	END
	ELSE
	BEGIN
		UPDATE BatchCatalog SET @lExternalBatchID = ExternalBatchID, ProbablyInUse = ProbablyInUse + 1 WHERE ExternalBatchID = (
			SELECT TOP 1 BatchCatalog.ExternalBatchID
			FROM BatchCatalog
			WHERE BatchCatalog.ExternalBatchID IN (
				SELECT BatchCatalog.ExternalBatchID
				FROM  BatchCatalog
				WHERE @lUserProfileID = 0
					AND BatchCatalog.ProcessID = @lProcessID
					AND ((@lStates) & (State)) <> 0
					AND (@lIsVerificationModule = 0
						OR @lUserProfileID = 0
						OR ValProfileKey <> @lUserProfileID)
					AND (@lInProgressState = 0
						OR InProgressState = @lInProgressState)
					AND (@dtAcisStartTime IS NULL
						OR NOT EXISTS (
							(
								SELECT 1
								FROM AcisRTransfer, AcisRCentralSite
								WHERE AcisRTransfer.CentralSiteGUID = AcisRCentralSite.SiteGUID
									AND AcisRCentralSite.LastFailed > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								
								UNION
								
								SELECT 1
								FROM AcisRTransfer
								WHERE AcisRTransfer.LastStatusCheck > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								)
							)
						)
		AND 
 		-- Filter on everything else 
		((@BatchNameEQ IS NULL) or (BatchName = @BatchNameEQ)) AND
		((@BatchNameNE IS NULL) or (BatchName <> @BatchNameNE)) AND
		((@BatchNameLT IS NULL) or (BatchName < @BatchNameLT)) AND
		((@BatchNameGT IS NULL) or (BatchName > @BatchNameGT)) AND
		((@BatchNamePM IS NULL) or (BatchName LIKE @BatchNamePM ESCAPE '\')) AND 
		((@PriorityEQ IS NULL) or (Priority = @PriorityEQ)) AND 
		((@PriorityNE IS NULL) or (Priority <> @PriorityNE)) AND 
		((@PriorityLT IS NULL) or (Priority < @PriorityLT)) AND 
		((@PriorityGT IS NULL) or (Priority > @PriorityGT)) AND 
		((@ContainsErrorsEQ IS NULL) or (ContainsErrors = @ContainsErrorsEQ)) AND 
		((@ContainsErrorsNE IS NULL) or (ContainsErrors <> @ContainsErrorsNE)) AND 
		((@QueueEQ IS NULL) or (BatchCatalog.ProcessID = @QueueEQ)) AND 
		((@QueueNE IS NULL) or (BatchCatalog.ProcessID <> @QueueNE)) AND 
		((@StationIDEQ IS NULL) or (StationID = @StationIDEQ)) AND 
		((@StationIDNE IS NULL) or (StationID <> @StationIDNE)) AND 
		((@StationIDLT IS NULL) or (StationID < @StationIDLT)) AND 
		((@StationIDGT IS NULL) or (StationID > @StationIDGT)) AND 
		((@StationIDPM IS NULL) or (StationID LIKE @StationIDPM ESCAPE '\')) AND 
		((@ScanStationIDEQ IS NULL) or (ScanStationID = @ScanStationIDEQ)) AND 
		((@ScanStationIDNE IS NULL) or (ScanStationID <> @ScanStationIDNE)) AND 
		((@ScanStationIDLT IS NULL) or (ScanStationID < @ScanStationIDLT)) AND 
		((@ScanStationIDGT IS NULL) or (ScanStationID > @ScanStationIDGT)) AND 
		((@ScanStationIDPM IS NULL) or (ScanStationID LIKE @ScanStationIDPM ESCAPE '\')) AND 
		((@ScanUserIDEQ IS NULL) or (ScanUserID = @ScanUserIDEQ)) AND 
		((@ScanUserIDNE IS NULL) or (ScanUserID <> @ScanUserIDNE)) AND 
		((@ScanUserIDLT IS NULL) or (ScanUserID < @ScanUserIDLT)) AND 
		((@ScanUserIDGT IS NULL) or (ScanUserID > @ScanUserIDGT)) AND 
		((@ScanUserIDPM IS NULL) or (ScanUserID LIKE @ScanUserIDPM ESCAPE '\')) AND 
		((@CreationDateLT IS NULL) or (CreationDate < @CreationDateLT)) AND 
		((@CreationDateGT IS NULL) or (CreationDate > @CreationDateGT)) AND 
		((@Reserved01BA IS NULL) or ( ((@Reserved01BA) & (Reserved01)) <> 0)) AND 
		((@StatusEQ IS NULL) or ( ((@StatusEQ) & (State)) <> 0)) AND 
		((@StatusNE IS NULL) or ( ((@StatusNE) & (State)) = 0)) AND 
		((@CreationDateDT IS NULL) or ((CreationDate >= @CreationDateDT) AND CreationDate < DATEADD(day, 1, @CreationDateDT))) 
				UNION
				SELECT BatchCatalog.ExternalBatchID
				FROM  BatchCatalog, viewUserHaveBatchDefAccess
				WHERE BatchCatalog.ClassName = viewUserHaveBatchDefAccess.BatchClassName
					AND viewUserHaveBatchDefAccess.UserProfilePrimaryKey = @lUserProfileID
					AND BatchType = 1
					AND viewUserHaveBatchDefAccess.ExternalBatchID = BatchCatalog.ExternalBatchID
					AND BatchCatalog.ProcessID = @lProcessID
					AND ((@lStates) & (State)) <> 0
					AND (@lIsVerificationModule = 0
						OR @lUserProfileID = 0
						OR ValProfileKey <> @lUserProfileID)
					AND (@lInProgressState = 0
						OR InProgressState = @lInProgressState)
					AND (@dtAcisStartTime IS NULL
						OR NOT EXISTS (
							(
								SELECT 1
								FROM AcisRTransfer, AcisRCentralSite
								WHERE AcisRTransfer.CentralSiteGUID = AcisRCentralSite.SiteGUID
									AND AcisRCentralSite.LastFailed > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								
								UNION
								
								SELECT 1
								FROM AcisRTransfer
								WHERE AcisRTransfer.LastStatusCheck > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								)
							)
						)
		AND 
 		-- Filter on everything else 
		((@BatchNameEQ IS NULL) or (BatchName = @BatchNameEQ)) AND
		((@BatchNameNE IS NULL) or (BatchName <> @BatchNameNE)) AND
		((@BatchNameLT IS NULL) or (BatchName < @BatchNameLT)) AND
		((@BatchNameGT IS NULL) or (BatchName > @BatchNameGT)) AND
		((@BatchNamePM IS NULL) or (BatchName LIKE @BatchNamePM ESCAPE '\')) AND 
		((@PriorityEQ IS NULL) or (Priority = @PriorityEQ)) AND 
		((@PriorityNE IS NULL) or (Priority <> @PriorityNE)) AND 
		((@PriorityLT IS NULL) or (Priority < @PriorityLT)) AND 
		((@PriorityGT IS NULL) or (Priority > @PriorityGT)) AND 
		((@ContainsErrorsEQ IS NULL) or (ContainsErrors = @ContainsErrorsEQ)) AND 
		((@ContainsErrorsNE IS NULL) or (ContainsErrors <> @ContainsErrorsNE)) AND 
		((@QueueEQ IS NULL) or (BatchCatalog.ProcessID = @QueueEQ)) AND 
		((@QueueNE IS NULL) or (BatchCatalog.ProcessID <> @QueueNE)) AND 
		((@StationIDEQ IS NULL) or (StationID = @StationIDEQ)) AND 
		((@StationIDNE IS NULL) or (StationID <> @StationIDNE)) AND 
		((@StationIDLT IS NULL) or (StationID < @StationIDLT)) AND 
		((@StationIDGT IS NULL) or (StationID > @StationIDGT)) AND 
		((@StationIDPM IS NULL) or (StationID LIKE @StationIDPM ESCAPE '\')) AND 
		((@ScanStationIDEQ IS NULL) or (ScanStationID = @ScanStationIDEQ)) AND 
		((@ScanStationIDNE IS NULL) or (ScanStationID <> @ScanStationIDNE)) AND 
		((@ScanStationIDLT IS NULL) or (ScanStationID < @ScanStationIDLT)) AND 
		((@ScanStationIDGT IS NULL) or (ScanStationID > @ScanStationIDGT)) AND 
		((@ScanStationIDPM IS NULL) or (ScanStationID LIKE @ScanStationIDPM ESCAPE '\')) AND 
		((@ScanUserIDEQ IS NULL) or (ScanUserID = @ScanUserIDEQ)) AND 
		((@ScanUserIDNE IS NULL) or (ScanUserID <> @ScanUserIDNE)) AND 
		((@ScanUserIDLT IS NULL) or (ScanUserID < @ScanUserIDLT)) AND 
		((@ScanUserIDGT IS NULL) or (ScanUserID > @ScanUserIDGT)) AND 
		((@ScanUserIDPM IS NULL) or (ScanUserID LIKE @ScanUserIDPM ESCAPE '\')) AND 
		((@CreationDateLT IS NULL) or (CreationDate < @CreationDateLT)) AND 
		((@CreationDateGT IS NULL) or (CreationDate > @CreationDateGT)) AND 
		((@Reserved01BA IS NULL) or ( ((@Reserved01BA) & (Reserved01)) <> 0)) AND 
		((@StatusEQ IS NULL) or ( ((@StatusEQ) & (State)) <> 0)) AND 
		((@StatusNE IS NULL) or ( ((@StatusNE) & (State)) = 0)) AND 
		((@CreationDateDT IS NULL) or ((CreationDate >= @CreationDateDT) AND CreationDate < DATEADD(day, 1, @CreationDateDT))) 
				UNION
				SELECT BatchCatalog.ExternalBatchID
				FROM  BatchCatalog, viewUserBatchClasses
				WHERE BatchCatalog.ClassName = viewUserBatchClasses.BatchClassName
					AND viewUserBatchClasses.UserProfilePrimaryKey = @lUserProfileID
					AND BatchCatalog.BatchType = 0
					AND BatchCatalog.ProcessID = @lProcessID
					AND ((@lStates) & (State)) <> 0
					AND (@lIsVerificationModule = 0
						OR @lUserProfileID = 0
						OR ValProfileKey <> @lUserProfileID)
					AND (@lInProgressState = 0
						OR InProgressState = @lInProgressState)
					AND (@dtAcisStartTime IS NULL
						OR NOT EXISTS (
							(
								SELECT 1
								FROM AcisRTransfer, AcisRCentralSite
								WHERE AcisRTransfer.CentralSiteGUID = AcisRCentralSite.SiteGUID
									AND AcisRCentralSite.LastFailed > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								
								UNION
								
								SELECT 1
								FROM AcisRTransfer
								WHERE AcisRTransfer.LastStatusCheck > @dtAcisStartTime
									AND BatchCatalog.BatchGUID = AcisRTransfer.TID
								)
							)
						)
		AND 
 		-- Filter on everything else 
		((@BatchNameEQ IS NULL) or (BatchName = @BatchNameEQ)) AND
		((@BatchNameNE IS NULL) or (BatchName <> @BatchNameNE)) AND
		((@BatchNameLT IS NULL) or (BatchName < @BatchNameLT)) AND
		((@BatchNameGT IS NULL) or (BatchName > @BatchNameGT)) AND
		((@BatchNamePM IS NULL) or (BatchName LIKE @BatchNamePM ESCAPE '\')) AND 
		((@PriorityEQ IS NULL) or (Priority = @PriorityEQ)) AND 
		((@PriorityNE IS NULL) or (Priority <> @PriorityNE)) AND 
		((@PriorityLT IS NULL) or (Priority < @PriorityLT)) AND 
		((@PriorityGT IS NULL) or (Priority > @PriorityGT)) AND 
		((@ContainsErrorsEQ IS NULL) or (ContainsErrors = @ContainsErrorsEQ)) AND 
		((@ContainsErrorsNE IS NULL) or (ContainsErrors <> @ContainsErrorsNE)) AND 
		((@QueueEQ IS NULL) or (BatchCatalog.ProcessID = @QueueEQ)) AND 
		((@QueueNE IS NULL) or (BatchCatalog.ProcessID <> @QueueNE)) AND 
		((@StationIDEQ IS NULL) or (StationID = @StationIDEQ)) AND 
		((@StationIDNE IS NULL) or (StationID <> @StationIDNE)) AND 
		((@StationIDLT IS NULL) or (StationID < @StationIDLT)) AND 
		((@StationIDGT IS NULL) or (StationID > @StationIDGT)) AND 
		((@StationIDPM IS NULL) or (StationID LIKE @StationIDPM ESCAPE '\')) AND 
		((@ScanStationIDEQ IS NULL) or (ScanStationID = @ScanStationIDEQ)) AND 
		((@ScanStationIDNE IS NULL) or (ScanStationID <> @ScanStationIDNE)) AND 
		((@ScanStationIDLT IS NULL) or (ScanStationID < @ScanStationIDLT)) AND 
		((@ScanStationIDGT IS NULL) or (ScanStationID > @ScanStationIDGT)) AND 
		((@ScanStationIDPM IS NULL) or (ScanStationID LIKE @ScanStationIDPM ESCAPE '\')) AND 
		((@ScanUserIDEQ IS NULL) or (ScanUserID = @ScanUserIDEQ)) AND 
		((@ScanUserIDNE IS NULL) or (ScanUserID <> @ScanUserIDNE)) AND 
		((@ScanUserIDLT IS NULL) or (ScanUserID < @ScanUserIDLT)) AND 
		((@ScanUserIDGT IS NULL) or (ScanUserID > @ScanUserIDGT)) AND 
		((@ScanUserIDPM IS NULL) or (ScanUserID LIKE @ScanUserIDPM ESCAPE '\')) AND 
		((@CreationDateLT IS NULL) or (CreationDate < @CreationDateLT)) AND 
		((@CreationDateGT IS NULL) or (CreationDate > @CreationDateGT)) AND 
		((@Reserved01BA IS NULL) or ( ((@Reserved01BA) & (Reserved01)) <> 0)) AND 
		((@StatusEQ IS NULL) or ( ((@StatusEQ) & (State)) <> 0)) AND 
		((@StatusNE IS NULL) or ( ((@StatusNE) & (State)) = 0)) AND 
		((@CreationDateDT IS NULL) or ((CreationDate >= @CreationDateDT) AND CreationDate < DATEADD(day, 1, @CreationDateDT))) 
				)
		ORDER BY Priority, CASE (BatchCatalog.ExternalBatchID % @lPartitions) + 1 WHEN @lMyPartition THEN 0 ELSE 1 END, BatchCatalog.ProbablyInUse, BatchCatalog.ExternalBatchID 
		)
	END;
	IF @lExternalBatchID IS NULL
		SET @lRetry = 0; -- We do not need to retry if not finding a batch available for this process
	ELSE
	BEGIN
		-- If the process is Release and batch is configured for export timing, 
		-- client code would check if it is the time to export batch and then decide to add lock later.
		IF (@lProcessID=7) AND (LEN(@strLockID)>0) AND (EXISTS (SELECT 1 FROM BatchCatalog LEFT JOIN BatchDef ON BatchCatalog.BatchDefID=BatchDef.BatchDefID
				WHERE ExternalBatchID=@lExternalBatchID AND BatchDef.RelTiming>0 AND BatchCatalog.Priority>=BatchDef.RelPriority))
			SET @strLockID = '';
		IF LEN(@strLockID) > 0
		BEGIN
			SET @strExistingLockID = NULL;
			SET @strLockName = CONVERT(NVARCHAR(32), @lExternalBatchID);
			BEGIN TRAN 
				EXEC procAddLock N'Batch', @strLockName, @strMachineName, @strProcessName, @strStationID, @strLockID, @strExistingLockID OUT, 0; 
				IF (@strExistingLockID IS NOT NULL)
				BEGIN
					-- If not being able to lock batch because of a conflict, this might be due to the change of the GetNextBatchSessions table,
					-- reset the BatchId and re-try the procedure to find another batch
					EXEC procDecrementProbablyInUse @lExternalBatchID;
					SET @lExternalBatchID = NULL;
				END
				ELSE
				BEGIN
					UPDATE BatchCatalog SET LockID = @strLockID WHERE ExternalBatchID = @lExternalBatchID;
					SET @lRetry = 0; -- If finding a batch and being able to lock it, stop retrying
				END;
			COMMIT; 
		END;
		ELSE
			SET @lRetry = 0; -- If we specify to lock batch later, stop retrying
	END;
	SET @lRetry = @lRetry-1;
END;
SELECT * FROM BatchCatalog WHERE ExternalBatchID=@lExternalBatchID;
GO

