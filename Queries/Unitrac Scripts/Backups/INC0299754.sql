USE UniTrac

SELECT 
        CONVERT(DATE, rh.CREATE_DT) AS [Day], COUNT(rh.ID) [Completed] 
FROM    dbo.REPORT_HISTORY rh
        JOIN DOCUMENT_CONTAINER dc ON dc.ID = rh.DOCUMENT_CONTAINER_ID
WHERE   rh.STATUS_CD = 'comp'
        AND rh.GENERATION_SOURCE_CD = 'u'
        AND rh.CREATE_DT >= '2017-05-01'
GROUP BY CONVERT(DATE, rh.CREATE_DT)







