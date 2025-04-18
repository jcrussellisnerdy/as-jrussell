USE UniTrac;


SELECT   *
FROM     dbo.WORK_QUEUE
WHERE    WORKFLOW_DEFINITION_ID = 3
ORDER BY NAME_TX ASC;


SELECT * --INTO UniTracHDStorage..INC0318179
FROM   dbo.WORK_QUEUE W
WHERE  ID IN ( 128, 127, 88, 365, 188, 121, 14, 119, 123, 122, 297, 216, 22 ,
               182 ,293, 37, 367, 368, 130, 85, 120, 117, 125, 369, 129
             ) AND W.ACTIVE_IN = 'N'
ORDER BY NAME_TX ASC;

UPDATE W
SET    W.PURGE_DT =NULL, W.LOCK_ID = W.LOCK_ID+1, W.UPDATE_DT= GETDATE(), W.UPDATE_USER_TX = 'INC0318179'
--SELECT * 
FROM   dbo.WORK_QUEUE W
WHERE  ID IN ( 128, 127, 88, 365, 188, 121, 14, 119, 123, 122, 297, 216, 22 ,
               182 ,293, 37, 367, 368, 130, 85, 120, 117, 125, 369, 129
             ) AND W.ACTIVE_IN = 'Y'





SELECT *
FROM   dbo.WORK_QUEUE
WHERE  ID IN ( 181, 269 );