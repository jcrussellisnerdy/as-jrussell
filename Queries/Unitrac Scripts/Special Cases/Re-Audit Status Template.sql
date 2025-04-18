--SELECT * FROM LENDER WHERE CODE_TX = '4750'
---- 2231

-- DROP TABLE #TMPPLCY
SELECT LOAN.NUMBER_TX , LOAN.DIVISION_CODE_TX , LOAN.BRANCH_CODE_TX , 
COLL.LOAN_ID , COLL.ID AS COLL_ID , 
---COLL.PROPERTY_ID , 
RC.TYPE_CD AS RC_TYPE_CD , RC.ID AS RC_ID , 
RC.SUMMARY_SUB_STATUS_CD , RC.SUMMARY_STATUS_CD , RC.EXPOSURE_DT , 
RC.CPI_QUOTE_ID , RC.NOTICE_DT , RC.NOTICE_SEQ_NO , RC.NOTICE_TYPE_CD , 
RC.LAST_EVENT_DT , RC.LAST_EVENT_SEQ_ID , RC.LAST_SEQ_CONTAINER_ID , 
PLCY.* , 0 AS EXCLUDE
INTO #TMPPLCY
FROM LOAN
JOIN COLLATERAL COLL ON COLL.LOAN_ID = LOAN.ID
AND COLL.PURGE_DT IS NULL AND LOAN.PURGE_DT IS NULL
AND COLL.PRIMARY_LOAN_IN = 'Y'
JOIN PROPERTY PR ON PR.ID = COLL.PROPERTY_ID
AND PR.PURGE_DT IS NULL
JOIN REQUIRED_COVERAGE RC ON RC.PROPERTY_ID = COLL.PROPERTY_ID
AND RC.PURGE_DT IS NULL
CROSS APPLY
(
SELECT * FROM dbo.GetCurrentCoverage(PR.ID , RC.ID , RC.TYPE_CD)
)  AS PLCY
WHERE LOAN.LENDER_ID = 2260
AND LOAN.NUMBER_TX IN 
('100021245')
ORDER BY NUMBER_TX
----909

--SELECT * FROM #TMPPLCY

UPDATE #TMPPLCY SET EXCLUDE = 1 WHERE SUMMARY_SUB_STATUS_CD = 'R'
----0

--SELECT DISTINCT SUMMARY_STATUS_CD , SUMMARY_SUB_STATUS_CD FROM #TMPPLCY
--WHERE EXCLUDE = 0 

UPDATE #TMPPLCY SET EXCLUDE = 2 WHERE SUMMARY_SUB_STATUS_CD <> 'D'
AND EXCLUDE = 0
----- 4

UPDATE #TMPPLCY SET EXCLUDE = 3 WHERE SUMMARY_STATUS_CD <> 'E'
AND EXCLUDE = 0
----49



SELECT  EXCLUDE, PC.PURGE_DT, T1.* , PC.ID AS PC_ID , PC.START_DT , PC.END_DT , PC.TYPE_CD , PC.SUB_TYPE_CD ,
PC.UPDATE_USER_TX AS PC_UPDATE_USER_TX
INTO #TMPPC
FROM POLICY_COVERAGE PC JOIN #TMPPLCY T1 ON T1.ID = PC.OWNER_POLICY_ID
WHERE PC.PURGE_DT IS NULL
AND EXCLUDE = 0 
----- 874

SELECT * 
--INTO #TMPPLCY_01
FROM #TMPPLCY
WHERE EXCLUDE = 0
----856


SELECT * 
INTO UnitracHDStorage.dbo.INC0
FROM #TMPPLCY
---- 909

SELECT * 
INTO UnitracHDStorage.dbo.INC0
FROM #TMPPC
---- 874

UPDATE PLCY SET 
SUB_STATUS_CD = 'R', 
UPDATE_DT = GETDATE() , 
UPDATE_USER_TX = 'INC0218350' , 
LOCK_ID = PLCY.LOCK_ID % 255 + 1
---- SELECT *
FROM OWNER_POLICY PLCY JOIN #TMPPLCY_01 T1 ON T1.ID = PLCY.ID
AND PLCY.STATUS_CD = 'E'
AND PLCY.SUB_STATUS_CD = 'D'
----- 845

UPDATE RC SET GOOD_THRU_DT = NULL , 
EXPOSURE_DT = NULL ,
INSURANCE_STATUS_CD = 'E' , 
INSURANCE_SUB_STATUS_CD = 'R' , 
SUMMARY_STATUS_CD = 'E' , 
SUMMARY_SUB_STATUS_CD = 'R' , 
NOTICE_DT = NULL , 
NOTICE_SEQ_NO = NULL , 
NOTICE_TYPE_CD = NULL , 
LAST_EVENT_DT = NULL , 
LAST_EVENT_SEQ_ID = NULL , 
LAST_SEQ_CONTAINER_ID = NULL ,
CPI_QUOTE_ID = NULL , 
UPDATE_DT = GETDATE() , 
UPDATE_USER_TX = 'INC0218350' , 
LOCK_ID = RC.LOCK_ID % 255 + 1
---- SELECT *
FROM REQUIRED_COVERAGE RC JOIN #TMPPLCY_01 T1 ON T1.RC_ID = RC.ID
WHERE EXCLUDE = 0 
AND RC.SUMMARY_SUB_STATUS_CD = 'D'
AND RC.SUMMARY_STATUS_CD = 'E'
AND RC.INSURANCE_SUB_STATUS_CD = 'D'
AND RC.INSURANCE_STATUS_CD = 'E'
----- 856

INSERT INTO
	PROPERTY_CHANGE (
		ENTITY_NAME_TX,
		ENTITY_ID,
		USER_TX,
		ATTACHMENT_IN,
		CREATE_DT,
		AGENCY_ID,
		DESCRIPTION_TX,
		DETAILS_IN,
		FORMATTED_IN,
		LOCK_ID,
		PARENT_NAME_TX,
		PARENT_ID,
		TRANS_STATUS_CD,
		UTL_IN)
SELECT DISTINCT
	'Allied.UniTrac.RequiredCoverage',
	RC_ID,
	'INC0218350',
	'N',
	GETDATE(),
	1,
	'Changed Summary status to Re-audit Expired',
	'N',
	'Y',
	1,
	'Allied.UniTrac.RequiredCoverage',
	RC_ID,
	'PEND',
	'N'
FROM
	 #TMPPLCY_01 WHERE EXCLUDE = 0 
	 ----- 853
	 


