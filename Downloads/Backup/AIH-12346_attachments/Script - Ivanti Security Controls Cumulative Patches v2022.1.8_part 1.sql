use SHAVLIK

IF (select count(*) from xtrCumulativePatches) <> '0'
BEGIN
		TRUNCATE TABLE xtrCumulativePatches
			PRINT 'Data Cleared on xtrCumulativePatches'
END;
 
IF (select count(*) from xtrLinuxCumulativePatches) <> '0'
BEGIN 
		TRUNCATE TABLE xtrLinuxCumulativePatches
			PRINT 'Data Cleared on xtrLinuxCumulativePatches'
END;

