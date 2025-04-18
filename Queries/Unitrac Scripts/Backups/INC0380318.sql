USE [UniTrac]
GO 

--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT rc.* 
into unitrachdstorage..INC0380318
FROM LOAN L
INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
INNER JOIN PROPERTY P ON C.PROPERTY_ID = P.ID
INNER JOIN REQUIRED_COVERAGE RC ON P.ID = RC.PROPERTY_ID
INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
INNER JOIN dbo.LENDER LL ON LL.ID = L.LENDER_ID
WHERE LL.CODE_TX = '3107' AND 
L.NUMBER_TX IN ('1928','1528','1776',
'980','1004','402','622','1115','1115','1115','1150','402','1115','1115','402','270','1568','1568',
'49','1626','622','1384','829','49','1384','444','52','1115','516','726','829','1004','457','1529','68','685','1169','1074','685',
'1494','631','1494','588','1116','1717','1320','588','533','539','961','807','1284','1905','672','520','1115','980',
'688','794','1115','589','1015','1232','898','1625','519','701','1096','596','1132') and rc.status_cd = 'W'





-- Update RequiredCoverage Status from Wavie to Active
UPDATE RC SET STATUS_CD = 'A',
UPDATE_DT = GETDATE() , UPDATE_USER_TX = 'INC0380318' , 
LOCK_ID = RC.LOCK_ID % 255 + 1
---- SELECT RC.STATUS_CD, tmp.STATUS_CD ,   *
FROM REQUIRED_COVERAGE RC 
JOIN unitrachdstorage..INC0380318 TMP 
ON TMP.ID = RC.ID 
---- 135



--SELECT DISTINCT LOAN_ID FROM #TMPLOAN

-- Add Property change log
 INSERT INTO PROPERTY_CHANGE
 (
 ENTITY_NAME_TX , ENTITY_ID , USER_TX , ATTACHMENT_IN , 
 CREATE_DT , AGENCY_ID , DESCRIPTION_TX ,  DETAILS_IN , FORMATTED_IN ,
 LOCK_ID , PARENT_NAME_TX , PARENT_ID , TRANS_STATUS_CD , UTL_IN
 )
 SELECT DISTINCT 'Allied.UniTrac.RequiredCoverage' , TMP.ID , 'INC0380318' , 'N' ,
 GETDATE(),  1 ,
 'Changed Status from Waive to Active' ,
 'N' , 'Y' , 1 ,  'Allied.UniTrac.RequiredCoverage' , TMP.ID , 'PEND' , 'N'
 FROM  unitrachdstorage..INC0380318 TMP 
 ---- 135

