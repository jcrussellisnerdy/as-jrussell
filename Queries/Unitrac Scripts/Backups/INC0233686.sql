--1) Main Service Center Query (SERVICE_CENTER_FUNCTION_LENDER_RELATE)
SELECT C.CODE_TX, C.NAME_TX, SCFLR.ID as SCFLR_ID,*
FROM LENDER L
INNER JOIN SERVICE_CENTER_FUNCTION_LENDER_RELATE SCFLR ON L.ID = SCFLR.LENDER_ID AND SCFLR.PURGE_DT IS NULL
INNER JOIN SERVICE_CENTER_FUNCTION SCF ON SCFLR.SERVICE_CENTER_FUNCTION_ID = SCF.ID AND SCF.PURGE_DT IS NULL
INNER JOIN SERVICE_CENTER C ON SCF.SERVICE_CENTER_ID = C.ID  AND C.PURGE_DT IS NULL
WHERE L.CODE_TX = '2715'

--SCFLR ROW
SELECT *
FROM SERVICE_CENTER_FUNCTION_LENDER_RELATE
WHERE ID IN (XXXXXXXXX)

--Available Service Centers
SELECT *
FROM SERVICE_CENTER 
WHERE CODE_TX NOT LIKE '%/%'

--Update Query
UPDATE SCFLR
SET SERVICE_CENTER_FUNCTION_ID = '103'
--SELECT  C.CODE_TX, C.NAME_TX,SCFLR.* 
FROM LENDER L
INNER JOIN SERVICE_CENTER_FUNCTION_LENDER_RELATE SCFLR ON L.ID = SCFLR.LENDER_ID AND SCFLR.PURGE_DT IS NULL
INNER JOIN SERVICE_CENTER_FUNCTION SCF ON SCFLR.SERVICE_CENTER_FUNCTION_ID = SCF.ID AND SCF.PURGE_DT IS NULL
INNER JOIN SERVICE_CENTER C ON SCF.SERVICE_CENTER_ID = C.ID  AND C.PURGE_DT IS NULL
WHERE SCFLR.ID IN (2842)



--2) Service Center Setup by Division
SELECT RD.VALUE_TX,LO.NAME_TX,RD.ID as RD_ID,*
FROM LENDER L
INNER JOIN LENDER_ORGANIZATION LO ON L.ID = LO.LENDER_ID
INNER JOIN RELATED_DATA RD ON LO.ID = RD.RELATE_ID AND RD.DEF_ID = '105'
WHERE L.CODE_TX = '2715'

--RELATED_DATA ROW(S)
SELECT *
FROM RELATED_DATA
WHERE ID IN (XXXXXXXXX)

--Available Service Centers
SELECT *
FROM SERVICE_CENTER 
WHERE CODE_TX NOT LIKE '%/%'

--Update Query
UPDATE RELATED_DATA
SET VALUE_TX = 'Plano'
WHERE ID IN (XXXXXXXXX)




----Inserting a new Lender row

declare @lenderCode nvarchar(10), @centerCode nvarchar(20), @rddID bigint
set @lenderCode = '2715'
SET @centerCode = 'Carmel'
set @rddID = (select id from RELATED_DATA_DEF where RELATE_CLASS_NM = 'LenderOrganization' and NAME_TX = 'AssociatedServiceCenter')

--INSERT into RELATED_DATA (DEF_ID, RELATE_ID, VALUE_TX, CREATE_DT, UPDATE_DT, UPDATE_USER_TX, LOCK_ID)
select @rddID DEF_ID, div.id, div.NAME_TX, @centerCode, GETDATE(), GETDATE(), 'script', 1
from LENDER_ORGANIZATION div
   inner join LENDER l on l.ID = div.LENDER_ID 
where l.CODE_TX = @lenderCode
   and div.TYPE_CD = 'DIV' and div.PURGE_DT is null  --AND div.NAME_TX = 'Vehicle Loan'   

go


