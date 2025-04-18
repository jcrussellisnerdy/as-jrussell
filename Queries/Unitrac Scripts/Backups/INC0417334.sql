USE [UniTrac]
GO 

----To see what loan status is
SELECT l.number_tx, L.PURGE_DT, L.RECORD_TYPE_CD, P.PURGE_DT, P.RECORD_TYPE_CD, C.PURGE_DT, RC.PURGE_DT, RC.RECORD_TYPE_CD,
L.ID, P.ID, C.ID, RC.ID, l.update_user_tx, p.update_user_tx, c.update_user_tx, rc.update_user_tx
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2075') AND L.NUMBER_TX IN ('51085-151')



---Backs up loans 
--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT L.* 
INTO UniTracHDStorage..INC0417334_L
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2075') AND L.NUMBER_TX IN ('51085-151')



--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT C.* 
INTO UniTracHDStorage..INC0417334_C
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2075') AND L.NUMBER_TX IN ('51085-151')



--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT P.* 
INTO UniTracHDStorage..INC0417334_P
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2075') AND L.NUMBER_TX IN ('51085-151')



--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT RC.*
INTO UniTracHDStorage..INC0417334_RC
 FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX IN ('2075') AND L.NUMBER_TX IN ('51085-151')



/*

--Mark them active
UPDATE dbo.REQUIRED_COVERAGE
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'G', PURGE_DT = NULL
--SELECT * FROM dbo.REQUIRED_COVERAGE
WHERE ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_RC)

UPDATE LOAN 
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'G', PURGE_DT = NULL
--SELECT * FROM LOAN
WHERE ID IN (SELECT ID FROM  UniTracHDStorage..INC0417334_L)


UPDATE PROPERTY
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'G', PURGE_DT = NULL
--SELECT * FROM PROPERTY
WHERE ID IN (SELECT ID FROM  UniTracHDStorage..INC0417334_P)


UPDATE dbo.COLLATERAL
SET PURGE_DT = NULL
WHERE ID IN (SELECT ID FROM  UniTracHDStorage..INC0417334_C)



INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.RequiredCoverage' , RC.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Make Loan Active', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.RequiredCoverage' , RC.ID , 'PEND' , 'N'
FROM REQUIRED_COVERAGE RC 
WHERE RC.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_RC)

INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.Loan' , L.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Make Loan Active', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.Loan' , L.ID , 'PEND' , 'N'
FROM LOAN L 
WHERE L.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_L)



INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.Property' , P.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Make Loan Active', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.Property' , P.ID , 'PEND' , 'N'
FROM PROPERTY P
WHERE P.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_P)


SELECT 'EXEC SaveSearchFullText', P.ID 
FROM PROPERTY P
WHERE P.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_P)


EXEC SaveSearchFullText	170732452

*/


---Please reach out to user to find out if this loan(s) need to stay active or if they can be reset back to deleted or archived if so please use the following script

/*
--Delete them back

UPDATE dbo.REQUIRED_COVERAGE
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'D', PURGE_DT = NULL
--SELECT * FROM dbo.REQUIRED_COVERAGE
WHERE ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_RC)

UPDATE LOAN 
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'D', PURGE_DT = NULL
--SELECT * FROM LOAN
WHERE ID IN (SELECT ID FROM  UniTracHDStorage..INC0417334_L)


UPDATE PROPERTY
SET  UPDATE_DT = GETDATE(),UPDATE_USER_TX = 'INC0417334', LOCK_ID = CASE WHEN LOCK_ID >= 255 THEN 1 ELSE LOCK_ID + 1 END, RECORD_TYPE_CD = 'D', PURGE_DT = NULL
--SELECT * FROM PROPERTY
WHERE ID IN (SELECT ID FROM  UniTracHDStorage..INC0417334_P)


INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.RequiredCoverage' , RC.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Marked back to deleted', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.RequiredCoverage' , RC.ID , 'PEND' , 'N'
FROM REQUIRED_COVERAGE RC 
WHERE RC.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_RC)

INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.Loan' , L.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Marked back to deleted', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.Loan' , L.ID , 'PEND' , 'N'
FROM LOAN L 
WHERE L.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_L)



INSERT  INTO PROPERTY_CHANGE
 ( ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN )
 SELECT DISTINCT 'Allied.UniTrac.Property' , P.ID , 'INC0417334' , 'N' , 
 GETDATE() ,  1 , 
 'Marked back to deleted', 
 'Y' , 'N' , 1 ,  'Allied.UniTrac.Property' , P.ID , 'PEND' , 'N'
FROM PROPERTY P
WHERE P.ID IN (SELECT ID FROM UniTracHDStorage..INC0417334_P)

*/






