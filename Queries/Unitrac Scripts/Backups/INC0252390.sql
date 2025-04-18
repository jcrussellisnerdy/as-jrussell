USE [UniTrac]
GO

DECLARE
	@queueId bigint,
	@topVal int = null,
	@userId bigint,
	@lenderId bigint = NULL,
    @userRoles nvarchar(100) = null

BEGIN

SET @userId = '106'
SET @queueId = '33'

if (@userId = 0)
	SET @userId = NULL
	
if(@topval = 0)
	SET @topVal = null

if(@lenderId = 0)
	SET @lenderId = null

IF @topVal IS NOT NULL
	SET ROWCOUNT @topVal
ELSE
	SET ROWCOUNT 0

IF @userRoles = ''
	SET @userRoles = null

create table #USER_LEVELS
(
	USER_ROLE_CD NVARCHAR(100)
)

IF @userRoles is not null 
BEGIN
	INSERT INTO #USER_LEVELS (USER_ROLE_CD)
	SELECT STRVALUE FROM dbo.SplitFunction(@userRoles,',')
END
ELSE
BEGIN
	INSERT INTO #USER_LEVELS (USER_ROLE_CD)
	SELECT CODE_CD FROM REF_CODE WHERE DOMAIN_CD = 'WorkQueueUserLevel' and PURGE_DT is null and ACTIVE_IN = 'Y'
END

  
if (@userId is not null)
BEGIN
	SELECT
		wi.ID,		wi.CREATE_DT as 'CreateDate',
		(SELECT MEANING_TX FROM REF_CODE Where CODE_CD = CONVERT(VARCHAR(10), wqwir.SLA_LEVEL_NO) and DOMAIN_CD = 'SLALevel') as 'SLALevel',
		        wi.CONTENT_XML.value('(/Content/Loan/Number)[1]', 'varchar (50)') [Loan Number] ,
        wi.CONTENT_XML.value('(/Content/Owner/Name)[1]', 'varchar (50)') [Owner] ,
        wi.CONTENT_XML.value('(/Content/Lender/Name)[1]', 'varchar (50)') [Lender Name] ,
        wi.CONTENT_XML.value('(/Content/Lender/Code)[1]', 'varchar (50)') [Lender Code] ,
        wi.CONTENT_XML.value('(/Content/Coverage/Type)[1]', 'varchar (50)') [Coverage],
		wi.CONTENT_XML.value('(/Content/Property/AddressLine1)[1]', 'varchar (50)') [Property Address] ,
		wi.CONTENT_XML.value('(/Content/Property/PostalCode)[1]', 'varchar (50)') [Property PostalCode], 
			wi.CONTENT_XML.value('(/Content/Property/VIN)[1]', 'varchar (50)') [VIN],
				wi.CONTENT_XML.value('(/Content/Property/Year)[1]', 'varchar (50)') [Year],
				wi.CONTENT_XML.value('(/Content/Property/Make)[1]', 'varchar (50)') [Make],
				wi.CONTENT_XML.value('(/Content/Property/Model)[1]', 'varchar (50)') [Model]
INTO UniTracHDStorage..INC0252390
	FROM 
		WORK_ITEM wi (nolock)
		JOIN WORK_QUEUE_WORK_ITEM_RELATE wqwir (nolock) ON wqwir.WORK_ITEM_ID = wi.ID
		JOIN WORK_QUEUE wq (nolock) ON wq.ID = wqwir.WORK_QUEUE_ID 
		JOIN WORKFLOW_DEFINITION wfd (nolock) ON wfd.ID = wq.WORKFLOW_DEFINITION_ID
		JOIN USER_WORK_QUEUE_RELATE uwqr (nolock) on uwqr.WORK_QUEUE_ID = wqwir.WORK_QUEUE_ID AND uwqr.USER_ROLE_CD = wi.USER_ROLE_CD
		OUTER APPLY wi.CONTENT_XML.nodes('/Content/Lender/Id') AS T1(LenderId)
	    INNER JOIN #USER_LEVELS ur on ur.USER_ROLE_CD = wi.USER_ROLE_CD
	WHERE 
		wqwir.WORK_QUEUE_ID = @queueId
		AND uwqr.USER_ID = @userId
		AND wi.STATUS_CD NOT IN ('Complete', 'Error', 'Withdrawn')
		AND uwqr.PURGE_DT is null
		AND wqwir.PURGE_DT is null
		AND wi.PURGE_DT is null
		AND wq.PURGE_DT is NULL
		AND wfd.purge_dt IS NULL
		AND (@lenderId is null or T1.LenderId.value('text()[1]', 'bigint') = @lenderId)
	ORDER BY 
		wqwir.PRIORITY1_NO asc, 
		wqwir.PRIORITY2_NO asc, 
		wqwir.PRIORITY3_NO asc, 
		wqwir.PRIORITY4_NO asc,  
		WI.CREATE_DT ASC
end
SET ROWCOUNT 0 
	
END


--DROP TABLE #USER_LEVELS



SELECT * FROM #USER_LEVELS