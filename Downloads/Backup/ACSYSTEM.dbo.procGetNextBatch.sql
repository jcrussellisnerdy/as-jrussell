USE [ACSYSTEM]
GO

/****** Object:  StoredProcedure [dbo].[procGetNextBatch]    Script Date: 4/27/2022 12:26:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[procGetNextBatch] (@lUserProfileID int , @lStates int , @lInProgressState int , @dtAcisStartTime datetime , @strMachineName nvarchar(255) , @lOsProcessID int , @strProcessName nvarchar(32) , @strStationID nvarchar(32) , @strLockID CHAR(38) , @lProcessID int , @FilterUserID nvarchar(255) , @BatchNameEQ nvarchar(128) , @BatchNameNE nvarchar(128) , @BatchNameLT nvarchar(128) , @BatchNameGT nvarchar(128) , @BatchNamePM nvarchar(260) , @BatchNameNL int , @BatchNameNN int , @ClassNameEQ int , @QueueEQ int , @QueueNE int , @StatusEQ int , @StatusNE int , @PriorityEQ int , @PriorityNE int , @PriorityLT int , @PriorityGT int , @ContainsErrorsEQ int , @ContainsErrorsNE int , @StationIDEQ nvarchar(32) , @StationIDNE nvarchar(32) , @StationIDLT nvarchar(32) , @StationIDGT nvarchar(32) , @StationIDPM nvarchar(68) , @StationIDNL int , @StationIDNN int , @CreationDateLT datetime , @CreationDateGT datetime , @CreationDateDT datetime , @BatchFieldValueEQ nvarchar(260) , @BatchFieldValueNE nvarchar(260) , @BatchFieldValueLT nvarchar(260) , @BatchFieldValueGT nvarchar(260) , @BatchFieldValuePM nvarchar(260) , @BatchFieldValueNL int , @BatchFieldValueNN int , @BatchFieldNameEQ nvarchar(34) , @ScanStationIDEQ nvarchar(32) , @ScanStationIDNE nvarchar(32) , @ScanStationIDLT nvarchar(32) , @ScanStationIDGT nvarchar(32) , @ScanStationIDPM nvarchar(32) , @ScanStationIDNL int , @ScanStationIDNN int , @ScanUserIDEQ nvarchar(128) , @ScanUserIDNE nvarchar(128) , @ScanUserIDLT nvarchar(128) , @ScanUserIDGT nvarchar(128) , @ScanUserIDPM nvarchar(128) , @ScanUserIDNL int , @ScanUserIDNN int , @Reserved01BA int ) AS 
	DECLARE @nextCursorID AS INT;
DECLARE @lTopBatch AS INT;
DECLARE @lRetry AS INT;
DECLARE @strExistingLockID AS CHAR(38);
DECLARE @lIsVerificationModule INT = dbo.IsVerificationModule(@lProcessID);

SET @lTopBatch = 100; -- start with a seed number
SET @lRetry = 5; -- retry 5 times, increase the seed number to double after each retry
WHILE (@lRetry > 0)
BEGIN
	DECLARE @lExternalBatchID AS INT;
	DECLARE @lBatchCount AS INT;
	DECLARE @strLockName NVARCHAR(32);

	SET @lExternalBatchID = NULL;
	SET @lBatchCount = 0;

	IF @lProcessID = 15000
	BEGIN 
		DECLARE nextBatchCursorForRSA CURSOR LOCAL FORWARD_ONLY DYNAMIC SCROLL_LOCKS 
		FOR
			SELECT TOP (@lTopBatch) ExternalBatchID FROM BatchCatalog 
			WHERE @lUserProfileID = 0
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
		ORDER BY Priority, ProbablyInUse, ExternalBatchID 
		OPTION(FAST 1); -- Specifies that the query is optimized for fast retrieval of the first number_rows. 
		OPEN nextBatchCursorForRSA;
			WHILE @lExternalBatchID IS NULL 
			BEGIN 
				FETCH NEXT FROM nextBatchCursorForRSA INTO @nextCursorID 
				IF @@FETCH_STATUS = -2 
				BEGIN
					SET @lBatchCount = @lBatchCount+1;
					CONTINUE; 
				END
				ELSE IF @@FETCH_STATUS <> 0 
					BREAK; 
				SET @lBatchCount = @lBatchCount+1;
				UPDATE BatchCatalog SET ProbablyInUse = ProbablyInUse + 1, 
					@lExternalBatchID=@nextCursorID,
					DequeueTime = GETUTCDATE() 
				WHERE ExternalBatchID=@nextCursorID 
					AND (ProbablyInUse=0 OR GETUTCDATE() > DATEADD(mi, 5, DequeueTime))
					AND BatchCatalog.ProcessID = @lProcessID 
					AND ((@lStates) & (State)) <> 0; 
			END; 
		CLOSE nextBatchCursorForRSA;
		DEALLOCATE nextBatchCursorForRSA;
		-- Try to lock batch ASAP
		IF NOT @lExternalBatchID IS NULL
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
					IF (@strExistingLockID IS NOT NULL)	-- If unable to insert a lock, decrement the ProbablyInUse and reset the ExternalBatchID 
					BEGIN 
						EXEC procDecrementProbablyInUse @lExternalBatchID;
						SET @lBatchCount = @lTopBatch; -- Create a chance to retry finding an available batch
						SET @lExternalBatchID = NULL;
					END; 
					ELSE
						UPDATE BatchCatalog SET LockID = @strLockID WHERE ExternalBatchID = @lExternalBatchID;
				COMMIT 
			END;
		END;
	END 
	ELSE 
	BEGIN 
		DECLARE nextBatchCursor CURSOR LOCAL FORWARD_ONLY DYNAMIC SCROLL_LOCKS 
		FOR
			SELECT TOP (@lTopBatch) b.ExternalBatchID FROM BatchCatalog b
			WHERE b.ExternalBatchID IN (
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
		ORDER BY Priority, ProbablyInUse, ExternalBatchID 
		OPTION(FAST 1); -- Specifies that the query is optimized for fast retrieval of the first number_rows. 
		OPEN nextBatchCursor;
			WHILE @lExternalBatchID IS NULL 
			BEGIN 
				FETCH NEXT FROM nextBatchCursor INTO @nextCursorID 
				IF @@FETCH_STATUS = -2 
				BEGIN
					SET @lBatchCount = @lBatchCount+1;
					CONTINUE; 
				END
				ELSE IF @@FETCH_STATUS <> 0 
					BREAK; 
				SET @lBatchCount = @lBatchCount+1;
				UPDATE BatchCatalog SET ProbablyInUse = ProbablyInUse + 1, 
					@lExternalBatchID=@nextCursorID,
					DequeueTime = GETUTCDATE() 
				WHERE ExternalBatchID=@nextCursorID 
					AND (ProbablyInUse=0 OR GETUTCDATE() > DATEADD(mi, 5, DequeueTime))
					AND BatchCatalog.ProcessID = @lProcessID 
					AND ((@lStates) & (State)) <> 0; 
			END; 
		CLOSE nextBatchCursor;
		DEALLOCATE nextBatchCursor;
		-- Try to lock batch ASAP
		IF NOT @lExternalBatchID IS NULL
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
					IF (@strExistingLockID IS NOT NULL)	-- If unable to insert a lock, decrement the ProbablyInUse and reset the ExternalBatchID 
					BEGIN 
						EXEC procDecrementProbablyInUse @lExternalBatchID;
						SET @lBatchCount = @lTopBatch; -- Create a chance to retry finding an available batch
						SET @lExternalBatchID = NULL;
					END; 
					ELSE
						UPDATE BatchCatalog SET LockID = @strLockID WHERE ExternalBatchID = @lExternalBatchID;
				COMMIT 
			END;
		END;
	END 

	-- If there was a full list returned from the SELECT but no batches were found after iterating the entire cursor,
	-- that may be due to a contention where all other connections picked up the batches, 
	-- if so we increase the number of batches returned from the SELECT to give more room for the next loop
	IF ((@lExternalBatchID IS NULL) AND (@lBatchCount > 0) AND (@lBatchCount >= @lTopBatch))
	BEGIN
		SET @lTopBatch = @lTopBatch * 2;
		SET @lRetry = @lRetry - 1;
	END
	ELSE
	BEGIN
		SET @lRetry = 0;
	END
END
SELECT * FROM BatchCatalog WHERE ExternalBatchID=@lExternalBatchID;
GO

