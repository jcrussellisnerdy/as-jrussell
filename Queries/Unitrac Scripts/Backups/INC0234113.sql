USE [UniTrac]
GO 

--Loan Screen Information - LOAN/COLLATERAL/PROPERTY/OWNER/REQUIRED COVERAGE
SELECT DISTINCT
        L.NUMBER_TX ,
		LO.NAME_TX [Divison],
        IH.ISSUE_DT ,
		RC1.DESCRIPTION_TX [Activity Issue Reason], 
        RC2.DESCRIPTION_TX [Loan Record Type] ,
        RC3.DESCRIPTION_TX [Loan Status] ,
        RC4.DESCRIPTION_TX [Loan Type] ,
        O.LAST_NAME_TX ,
        O.FIRST_NAME_TX ,
        OA.CITY_TX ,
        OA.STATE_PROV_TX ,
        OA.COUNTRY_TX ,
        OA.POSTAL_CODE_TX, lo.LENDER_ID
FROM    LOAN L
        INNER JOIN COLLATERAL C ON L.ID = C.LOAN_ID
        INNER JOIN OWNER_LOAN_RELATE OL ON L.ID = OL.LOAN_ID
        INNER JOIN OWNER O ON OL.OWNER_ID = O.ID
        INNER JOIN OWNER_ADDRESS OA ON O.ADDRESS_ID = OA.ID
        INNER JOIN dbo.INTERACTION_HISTORY IH ON IH.PROPERTY_ID = C.PROPERTY_ID --AND IH.TYPE_CD = 'CPI'
        INNER JOIN dbo.FORCE_PLACED_CERTIFICATE FPC ON FPC.LOAN_ID = L.ID
        INNER JOIN dbo.CPI_QUOTE CQ ON CQ.ID = FPC.CPI_QUOTE_ID
        INNER JOIN dbo.CPI_ACTIVITY CA ON CA.CPI_QUOTE_ID = CQ.ID
        INNER JOIN LENDER_ORGANIZATION LO ON Lo.CODE_TX = L.DIVISION_CODE_TX AND LO.LENDER_ID = '730'
                                             AND Lo.TYPE_CD = 'DIV'
        INNER JOIN dbo.REF_CODE RC2 ON RC2.CODE_CD = L.RECORD_TYPE_CD
                                       AND RC2.DOMAIN_CD = 'RecordType'
        INNER JOIN dbo.REF_CODE RC3 ON RC3.CODE_CD = L.STATUS_CD
                                       AND RC3.DOMAIN_CD = 'LoanStatus'
        INNER JOIN dbo.REF_CODE RC4 ON RC4.CODE_CD = L.TYPE_CD
                                       AND RC4.DOMAIN_CD = 'LoanType'
		 INNER JOIN dbo.REF_CODE RC1 ON RC1.CODE_CD = CA.REASON_CD
                                       AND RC1.DOMAIN_CD = 'CPIActivityIssueReason'
WHERE   L.LENDER_ID = '730'
        AND CA.REASON_CD = 'Q' AND L.DIVISION_CODE_TX = '3'
ORDER BY IH.ISSUE_DT DESC 



SELECT LO.TYPE_CD, LO.CODE_TX , Lo.NAME_TX,*
FROM LENDER L
INNER JOIN LENDER_ORGANIZATION LO ON L.ID = LO.LENDER_ID
INNER JOIN RELATED_DATA RD ON LO.ID = RD.RELATE_ID --AND RD.DEF_ID = '105'
WHERE L.CODE_TX = '6155' AND Lo.TYPE_CD = 'DIV'



SELECT * FROM dbo.REF_CODE
WHERE CODE_CD = 'Q'


