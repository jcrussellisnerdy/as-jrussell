USE [OspreyDashboard]
GO

/****** Object:  StoredProcedure [dbo].[3MonthEventSuccessRate]    Script Date: 4/25/2022 9:03:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[3MonthEventSuccessRate]
AS
BEGIN

-------------------------------------------------------------------------------------------------------------------------
	-- 9 3 Month Event Success Rate by type
	-------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------
	------ new way to calculate / Event success rate
	------		STEP 1: get all the COMP events for specified range (normalize the event type)
	------		STEP 2: get the group ids for those events
	------		STEP 3: get evaluation event groups by es order numberr and by status for ease of use
	------		STEP 4: aggregate the results

	---- STEP 1: Get the completed evaluation events using update_dt for the lender and date range in question
	SELECT
		LENDER_CD
	,	LENDER_NAME
	,	L_BRANCH_CODE_TX AS 'BRANCH'
	,	CAST(CONVERT(VARCHAR, DATEPART(YEAR, ee.UPDATE_DT)) + '-' + CONVERT(VARCHAR, DATEPART(MONTH, ee.UPDATE_DT)) + '-01' AS DATE) AS 'YEAR_MONTH'
	,	es.ORDER_NO AS 'es_order_no'
	,	es.EVENT_TYPE_CD
	,	es.NOTICE_SEQ_NO
	,	rces.MEANING_TX
	,	rces.MEANING_TX + ' ' + CASE
			WHEN es.EVENT_TYPE_CD = 'NTC' THEN CONVERT(NVARCHAR(10), es.NOTICE_SEQ_NO)
			ELSE ''
		END AS 'EVENT_TYPE'
	,	LOAN_TYPE
	,	ee.GROUP_ID AS 'ee_group_id'
	,	ee.ID AS 'ee_id' INTO #ee_to_consider
	FROM OspreyDashboard.dbo.DATASOURCE_CACHE_STAGING l (NOLOCK)
		JOIN LENDER_ORGANIZATION lo (NOLOCK) ON lo.LENDER_ID = l.LENDER_ID
				AND lo.CODE_TX = L_DIVISION_CODE_TX
            AND lo.TYPE_CD = 'DIV'
				AND lo.purge_dt is null
		JOIN EVALUATION_EVENT ee (NOLOCK) ON ee.REQUIRED_COVERAGE_ID = l.RC_ID
				AND ee.RELATE_ID IS NOT NULL
				AND ee.STATUS_CD = 'COMP'
				AND ee.PURGE_DT IS NULL
				AND ee.UPDATE_DT >= DATEADD(MONTH, -3, CAST(CONVERT(VARCHAR, DATEPART(YEAR, GETDATE())) + '-' + CONVERT(VARCHAR, DATEPART(MONTH, GETDATE())) + '-01' AS DATE))
		JOIN EVENT_SEQUENCE es (NOLOCK) ON es.ID = ee.EVENT_SEQUENCE_ID
				AND es.PURGE_DT IS NULL
				AND es.EVENT_TYPE_CD NOT IN ('DFLT')
		JOIN EVENT_SEQ_CONTAINER esc (NOLOCK) ON esc.ID = es.EVENT_SEQ_CONTAINER_ID
				AND esc.PURGE_DT IS NULL
				AND esc.NOTICE_CYCLE_IN = 'Y'
		JOIN REF_CODE rces (NOLOCK) ON rces.DOMAIN_CD = 'EventSequenceEventType'
				AND rces.PURGE_DT IS NULL
				AND rces.CODE_CD = es.EVENT_TYPE_CD
	WHERE RC_RECORD_TYPE_CD = 'G'
		AND RC_STATUS_CD = 'A'

	---- STEP 2: Get the evaluation events GROUP IDs for those completed events

	SELECT
	DISTINCT
		LENDER_NAME
	,	BRANCH
	,	ee_group_id INTO #ee_groups_to_consider
	FROM #ee_to_consider

	---- STEP 3: Get evaluation event groups by es order numberr and by status for ease of use
	SELECT
		eegtc.ee_group_id
	,	es.ORDER_NO
	,	ee.STATUS_CD INTO #ee_group_status
	FROM #ee_groups_to_consider eegtc
		JOIN EVALUATION_EVENT ee ON ee.GROUP_ID = eegtc.ee_group_id
				AND ee.PURGE_DT IS NULL
		JOIN EVENT_SEQUENCE es ON ee.EVENT_SEQUENCE_ID = es.ID
	GROUP BY	eegtc.ee_group_id
			,	es.ORDER_NO
			,	ee.STATUS_CD

	------ STEP 4: aggregate the results
	SELECT
		etc.LENDER_CD AS 'LENDER_CD'
	,	etc.LENDER_NAME AS 'LENDER_NAME'
	,	etc.BRANCH AS 'BRANCH'
	,	etc.YEAR_MONTH 'YEAR_MONTH'
	,	etc.EVENT_TYPE AS 'EVENT_TYPE'
	,	CASE
			WHEN ISNULL(next_etc.STATUS_CD, '') IN ('', 'COMP') THEN ''
			WHEN ISNULL(next_etc.STATUS_CD, '') IN ('CLR') THEN 'Success'
			ELSE 'Pending'
		END AS 'SEQUENCE_TYPE'
	,	etc.LOAN_TYPE AS 'LOAN_TYPE'
	,	COUNT(etc.ee_id) AS 'EVENT_COUNT'
	FROM #ee_to_consider etc
		LEFT OUTER JOIN #ee_group_status next_etc ON next_etc.ee_group_id = etc.ee_group_id
				AND next_etc.ORDER_NO = etc.es_order_no + 1
	--	join #ee_group_id_status_pivot egsp on egsp.ee_group_id = etc.ee_group_id
	GROUP BY	etc.LENDER_CD
			,	etc.LENDER_NAME
			,	etc.BRANCH
			,	etc.YEAR_MONTH
			,	etc.EVENT_TYPE
			,	CASE
					WHEN ISNULL(next_etc.STATUS_CD, '') IN ('', 'COMP') THEN ''
					WHEN ISNULL(next_etc.STATUS_CD, '') IN ('CLR') THEN 'Success'
					ELSE 'Pending'
				END
			,	etc.LOAN_TYPE
	ORDER BY 4,
	6

end
GO

