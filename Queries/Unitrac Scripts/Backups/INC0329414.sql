USE [UniTrac]
GO 

--DROP TABLE #tmpRC
SELECT RC.ID INTO #tmpRC
--SELECT L.RECORD_TYPE_CD, rc.RECORD_TYPE_CD, rc.PURGE_DT, RC.* 
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2771') AND RC.TYPE_CD = 'FLOOD'
AND L.BRANCH_CODE_TX = '1ST LIEN'AND RC.STATUS_CD = 'T'
AND RC.PURGE_DT IS NULL AND L.RECORD_TYPE_CD IN ('A', 'G')
--162 deleted


UPDATE RC
SET RC.STATUS_CD = 'A', RC.UPDATE_DT = GETDATE(), RC.LOCK_ID = RC.LOCK_ID+1, RC.UPDATE_USER_TX = 'INC0329414'
--SELECT * 
FROM dbo.REQUIRED_COVERAGE RC 
WHERE ID IN (SELECT * FROM #tmpRC)



INSERT INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.RequiredCoverage' , L.ID , 'INC0329414' , 'N' , 
 GETDATE() ,  1 , 
'Moved from Track to Active Status', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.RequiredCoverage' , L.ID , 'PEND' , 'N'
FROM dbo.REQUIRED_COVERAGE L 
WHERE L.ID IN (SELECT * FROM #tmpRC)

