-- IMPLEMENTATION PLAN
-- Add Carrier Trading Partner V2

/*
Related ServiceNow: CSH-32797
Environment: Production
Server: UT-PRD-LISTENER
*/

use unitrac

/*
****************************************************
------------- CARRIER TP CREATION -------------------
****************************************************
*/
/*

TRADING_PARTNER 
<EXTERNAL_ID_TX> NG-10%
<NAME_TX> National General 10 pct.

DELIVERY_INFO 
<DOCUMENT_TYPE_CD> EOM 

DELIVERY_INFO_GROUP 
<NAME_TX> National General 10 pct..*.dat 

DELIVERY_DETAIL 
<DELIVERY_CODE_TX> InputFileName 
<VALUE_TX> National General 10 pct..*.dat

DELIVERY_DETAIL 
<DELIVERY_CODE_TX> OutputFileName 
<VALUE_TX> National General 10 pct..*.dat
*/

/* ////////////////  Add the following information  /////////////// */

declare 
	@update_user_tx			varchar(15)		= 'CSH32797_1',

	@environment			varchar(20)		= 'PRODUCTION',			-- STAGING PRODUCTION

	@tp_external_id_tx		varchar(20)		= 'NG-10%',			-- TRADING_PARTNER		<EXTERNAL_ID_TX>
	@tp_name_tx				varchar(50)		= 'National General 10 pct.',				-- TRADING_PARTNER		<NAME_TX>
	@di_document_type_cd	varchar(10)		= 'EOM',				-- DELIVERY_INFO		<DOCUMENT_TYPE_CD>
	@dig_name_tx			varchar(100)	= 'National General 10 pct..*.dat',		-- DELIVERY_INFO_GROUP	<NAME_TX>
	@dd_InputFilename		varchar(200)	= 'National General 10 pct..*.dat',		-- DELIVERY_DETAIL		InputFileName		<VALUE_TX> -- Uses REGEX,	match everything = ".*"
	@dd_OutputFilename		varchar(200)	= 'National General 10 pct..*.dat'		-- DELIVERY_DETAIL		OutputFileName		<VALUE_TX> -- Uses Windows, match everything = "*"

/* //////////////////////////////////////////////////////////////// */

-----------------------------  Set Flags -----------------------------
declare
	
	@IF_UPDATE				varchar(10)		= 'TRUE',	-- TRUE FALSE
	@IF_CREATE_BACKOUT		varchar(10)		= 'TRUE',	-- TRUE FALSE
	@IF_VERBOSE				varchar(10)		= 'TRUE'	-- TRUE FALSE

----------------------------------------------------------------------
		
declare
	@tp_type_cd				varchar(10)		= 'CARRIER_TP',	-- USED IN TRADING_PARTNER TABLE
	@tp_id					int,							-- TRADING_PARTNER
	@di_id					int,							-- DELIVERY_INFO
	@dig_id					int,							-- DELIVERY_INFO_GROUP
	@dd_id					int,							-- DELIVERY_DETAIL		<<<<< NOT USED <<<<<
	@rd_id					int,							-- RELATED_DATA
	@pd_id					int,							-- PREPROCESSING_DETAIL
	@ppda_id				int,							-- PPDATTRIBUTE
	@didttr_id				int								-- DELIVERY_INFO_DELIVER_TO_TP_RELATE



-- If the Trading Partner already exists print a message and do not process
if((select count(*) from trading_partner where  NAME_TX = @tp_name_tx and PURGE_DT IS NULL) > 0) 
BEGIN
	select 'TRADING_PARTNER Already Exists'
	declare @exists_id		int			= (select id from trading_partner where  NAME_TX = @tp_name_tx and PURGE_DT IS NULL)
	declare @exists_id_tx	varchar(10)	= convert(varchar(10), @exists_id)
	PRINT 'Trading Partner (' + @tp_name_tx + ' : ' + @exists_id_tx + ') already exists and so will not be added'
	SET NOEXEC ON	-- NO OTHER STATEMENTS WILL EXECUTE
END


--	This table is used to collect the Ids of all of the tables used in this process as they're created
if object_id('tempdb.dbo.#tbl_ids','U') is not null drop table #tbl_ids
create table #tbl_ids(
	tbl varchar(100),	-- TRADING_PARTNER, DELIVERY_INFO, DELIVERY_INFO_GROUP, DELIVERY_DETAIL, RELATED_DATA, PREPROCESSING_DETAIL, PPDATTRIBUTE, DELIVERY_INFO_DELIVER_TO_TP_RELATE
	id int,				-- Table ID
)


-----------------------------------------------------------------
------------------	TRADING_PARTNER
-----------------------------------------------------------------
BEGIN

	SELECT	'' 'TRADING_PARTNER Before', * FROM TRADING_PARTNER TP WHERE ID in (select id from #tbl_ids where tbl = 'trading_partner')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	TRADING_PARTNER 
				(
					EXTERNAL_ID_TX,
					NAME_TX,
					TYPE_CD,
					STATUS_CD,
					RECEIVE_FROM_TP_ID,
					DELIVER_TO_TP_ID,
					UPDATE_DT,
					UPDATE_USER_TX,
					PURGE_DT,
					LOCK_ID,
					ACTIVE_IN,
					TRANSACTION_XSLT,
					DELIVER_TO_TP_IN,
					CREATE_DT
				) 
		SELECT	
					@tp_external_id_tx,
					@tp_name_tx,
					@tp_type_cd,
					N'ACTIVE',
					0,
					2046,
					GETDATE(),
					@update_user_tx,
					NULL,
					1,
					'Y',
					'',
					'N',
					GETDATE()
				
		set		@tp_id = SCOPE_IDENTITY()

		insert into #tbl_ids (tbl, id) select 'trading_partner', @tp_id

	END

	SELECT	'' 'TRADING_PARTNER After', * FROM TRADING_PARTNER TP WHERE ID in (select id from #tbl_ids where tbl = 'trading_partner')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER TRADING_PARTNER #tbl_ids', * from #tbl_ids

END


-----------------------------------------------------------------
------------------	DELIVERY_INFO
-----------------------------------------------------------------
BEGIN

	select	'' 'DELIVERY_INFO Before', * from DELIVERY_INFO WHERE	id in (select id from #tbl_ids where tbl = 'delivery_info')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	DELIVERY_INFO 
				(
					TRADING_PARTNER_ID,
					DOCUMENT_TYPE_CD,
					DELIVERY_TYPE_CD,
					FILESIZE_VARIANCE_NO,
					DELIVERY_FREQ_CD,
					PREPROCESS_TYPE_CD,
					OVERDUE_DELIVERY_THRESHOLD_NO,
					FILE_FORMAT_TYPE_CD,
					BRANCH_ID,
					UPDATE_DT,
					UPDATE_USER_TX,
					PURGE_DT,
					LOCK_ID,
					ACTIVE_IN
				)
		SELECT 
					(select id from #tbl_ids where tbl = 'trading_partner'),
					@di_document_type_cd,
					'DW',
					10.00,
					'MONTHLY',
					'',
					0,
					'',
					'',
					getdate(),
					@update_user_tx,
					NULL,
					1,
					'Y'

		set		@di_id = SCOPE_IDENTITY()
		
		insert into #tbl_ids (tbl, id) select 'delivery_info', @di_id

	END

	select '' 'DELIVERY_INFO After', * from DELIVERY_INFO WHERE id IN (select id from #tbl_ids where tbl = 'delivery_info')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER DELIVERY_INFO #tbl_ids', * from #tbl_ids 

END


-----------------------------------------------------------------
------------------	DELIVERY_INFO_GROUP
-----------------------------------------------------------------
BEGIN

	SELECT '' 'DELIVERY_INFO_GROUP Before', * FROM DELIVERY_INFO_GROUP WHERE id in (select id from #tbl_ids where tbl = 'delivery_info_group')

	-- IMPORTANT ************************************************
	-- The NAME_TX uses REGEX matching. To match "any" number of "any" characters a combination of a period and an asterisk is used >>  .*
	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	DELIVERY_INFO_GROUP 
				(
					DELIVERY_INFO_ID,
					NAME_TX,
					ORDER_NO,
					UPDATE_DT,
					UPDATE_USER_TX,
					PURGE_DT,
					LOCK_ID
				)
		SELECT 
					(select id from #tbl_ids where tbl = 'delivery_info'),
					@dig_name_tx,
					1,
					GETDATE(),
					@update_user_tx,
					NULL,
					1

		set			@dig_id = SCOPE_IDENTITY()

		insert into #tbl_ids (tbl, id) select 'delivery_info_group', @dig_id

	END

	SELECT '' 'DELIVERY_INFO_GROUP After', * FROM DELIVERY_INFO_GROUP WHERE id in (select id from #tbl_ids where tbl = 'delivery_info_group')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER DELIVERY_INFO_GROUP #tbl_ids', * from #tbl_ids 

END


-----------------------------------------------------------------
------------------	DELIVERY_DETAIL
-----------------------------------------------------------------
BEGIN

	if object_id('tempdb.dbo.#dd_fields','U') is not null drop table #dd_fields
	create table #dd_fields(environment varchar(20), document_type_cd varchar(100), delivery_code_tx varchar(15), value_tx varchar(200))
	insert
	into	#dd_fields (environment, document_type_cd, delivery_code_tx, value_tx)
	values	
	('PRODUCTION',	':EOM:',	'ArchInFolder',		'\\vut-app\EOMFiles\ArchiveInput'),
	('STAGING',		':EOM:',	'ArchInFolder',		'\\nas\utstage_files\LenderFiles\ArchiveInput'),
	('PRODUCTION',	':EOM:',	'ArchOutFolder',	'\\vut-app\EOMFiles\Eastern\\ArchiveOutput'),
	('STAGING',		':EOM:',	'ArchOutFolder',	'\\nas\utstage_files\LenderFiles\Eastern\\ArchiveOutput'),
	('ANY',			':EOM:',	'Compression',		'N'),
	('ANY',			':EOM:',	'Encryption',		'N'),
	('ANY',			':EOM:',	'ExcludeMsgComp',	'N'),
	('ANY',			':EOM:',	'FileFormat',		'Unknown'),
	('ANY',			':EOM:',	'FileSizeVar',		'10'),
	('ANY',			':EOM:',	'IgnFileSzVld',		'Y'),
	('ANY',			':EOM:',	'IgnoreUnknown',	'Y'),
	('ANY',			':EOM:',	'InputFileName',	@dd_InputFilename),		-- THIS USES REGEX CHARACTER MATCHING .*
	('PRODUCTION',	':EOM:',	'InputFolder',		'\\vut-app\EOMFiles'),
	('STAGING',		':EOM:',	'InputFolder',		'\\nas\utstage_files\LenderFiles\'),
	('ANY',			':EOM:',	'LenderFile',		'Y'),
	('ANY',			':EOM:',	'OutputFileName',	@dd_OutputFilename),	-- THIS USES WINDOWS CHARACTER MATCHING *
	('PRODUCTION',	':EOM:',	'OutputFolder',		'\\vut-app\EOMFiles\Eastern\'),
	('STAGING',		':EOM:',	'OutputFolder',		'\\nas\utstage_files\LenderFiles\Eastern\')

	if(@IF_VERBOSE = 'TRUE') select '' '#dd_fields', * from #dd_fields WHERE document_type_cd like '%:' + @di_document_type_cd + ':%'

	SELECT '' 'DELIVERY_DETAIL Before', * FROM DELIVERY_DETAIL WHERE delivery_info_group_id in (select id from #tbl_ids where tbl = 'delivery_info_group')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	DELIVERY_DETAIL
				(
				DELIVERY_INFO_GROUP_ID,
				DELIVERY_CODE_TX,
				VALUE_TX,
				UPDATE_DT,
				UPDATE_USER_TX,
				PURGE_DT,
				LOCK_ID
				)
		SELECT 
				(select id from #tbl_ids where tbl = 'delivery_info_group'),
				ddf.DELIVERY_CODE_TX,
				ddf.VALUE_TX,
				GETDATE(),
				@update_user_tx,
				NULL,
				1
		FROM	
				#dd_fields ddf
		WHERE 
				ddf.document_type_cd like '%:' + @di_document_type_cd + ':%'				-- CHOOSES MORT/VEH TO FILTER #dd_fields according to @di_document_type_cd
				and (ddf.environment = @environment or ddf.environment = 'ANY')				-- CHOOSES PRODUCTION/STAGING/ANY TO FILTER #dd_fields according to @environment

		insert into #tbl_ids (tbl, id) select 'delivery_detail', @dig_id					-- DELIVERY_DETAIL uses the DELIVERY_INFO_GROUP_ID

	END

	SELECT '' 'DELIVERY_DETAIL After', * FROM DELIVERY_DETAIL WHERE delivery_info_group_id in (select id from #tbl_ids where tbl = 'delivery_info_group')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER DELIVERY_DETAIL #tbl_ids', * from #tbl_ids 

END


-----------------------------------------------------------------
------------------	RELATED_DATA DEF_ID
------------------  
------------------	ID	NAME_TX					DESC_TX															RELATE_CLASS_NM
------------------	71	AcceptMultipleFiles		Accepts Mutiple Files for the defined DeliveryInfo				DeliveryInfo
-----------------------------------------------------------------
BEGIN

	SELECT	'' 'RELATED_DATA Before', *	FROM RELATED_DATA WHERE	DEF_ID IN (71, 102) and relate_id = (select id from #tbl_ids where tbl = 'delivery_info') -- delivery_info id ??? HAD A NOTE THAT SEEM TO IMPLY THAT IT WAS THE TRADING_PARTNER ID ???


	-- 71	AcceptMultipleFiles		Accepts Mutiple Files for the defined DeliveryInfo				DeliveryInfo
	/*
	ID			DEF_ID	RELATE_ID	VALUE_TX	START_DT	END_DT	COMMENT_TX			CREATE_DT				UPDATE_DT					UPDATE_USER_TX	LOCK_ID
	6045547		71		1997		Y			NULL		NULL	AcceptMultipleFiles	2012-09-12 09:41:23.767	2012-09-12 09:41:23.767						0
	*/

	if(@IF_UPDATE = 'TRUE')
	BEGIN
	
		INSERT 
		INTO	RELATED_DATA 
				(
				DEF_ID, 
				RELATE_ID, 
				VALUE_TX, 
				COMMENT_TX, 
				CREATE_DT, 
				UPDATE_DT, 
				UPDATE_USER_TX, 
				LOCK_ID
				)
		SELECT
				71,
				(select id from #tbl_ids where tbl = 'delivery_info'),
				'Y',
				'',
				GETDATE(),
				GETDATE(),
				@update_user_tx,
				1

		set		@rd_id = SCOPE_IDENTITY()



		insert into #tbl_ids (tbl, id) select 'related_data_71', @rd_id




				INSERT 
		INTO	RELATED_DATA 
				(
				DEF_ID, 
				RELATE_ID, 
				VALUE_TX, 
				COMMENT_TX, 
				CREATE_DT, 
				UPDATE_DT, 
				UPDATE_USER_TX, 
				LOCK_ID
				)
		SELECT
				102,
				(select id from #tbl_ids where tbl = 'delivery_info'),
				'Y',
				'HoldForReview',
				GETDATE(),
				GETDATE(),
				@update_user_tx,
				1

		set		@rd_id = SCOPE_IDENTITY()



		insert into #tbl_ids (tbl, id) select 'related_data_102', @rd_id


	END

	SELECT	'' 'RELATED_DATA After', * FROM RELATED_DATA WHERE	DEF_ID IN (71, 102) and relate_id = (select id from #tbl_ids where tbl = 'delivery_info') -- delivery_info id ??? HAD A NOTE THAT SEEM TO IMPLY THAT IT WAS THE TRADING_PARTNER ID ???
		
	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER RELATED_DATA #tbl_ids', *	from #tbl_ids 

END


-----------------------------------------------------------------
------------------	PREPROCESSING_DETAIL
-----------------------------------------------------------------
BEGIN

	SELECT	'' 'PREPROCESSING_DETAIL Before', *	FROM PREPROCESSING_DETAIL WHERE	id = (select id from #tbl_ids where tbl = 'preprocessing_detail')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	PREPROCESSING_DETAIL 
				(
				DELIVERY_INFO_GROUP_ID, 
				ORDER_NO, 
				TYPE_CD, 
				VALUE_TX, 
				CODE_CD, 
				UPDATE_DT, 
				UPDATE_USER_TX, 
				LOCK_ID
				)
		SELECT 
				(select id from #tbl_ids where tbl = 'delivery_info_group'),
				1, 
				'XSLT', 
				'PRAETORIAN',
				'PRAETORIAN',
				GETDATE(), 
				@update_user_tx, 
				1

		set		@pd_id = SCOPE_IDENTITY()

		insert into #tbl_ids (tbl, id) select 'preprocessing_detail', @pd_id

	END

	SELECT	'' 'PREPROCESSING_DETAIL After', * FROM PREPROCESSING_DETAIL WHERE id = (select id from #tbl_ids where tbl = 'preprocessing_detail')
	
	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER PREPROCESSING_DETAIL #tbl_ids', *	from #tbl_ids

END


-----------------------------------------------------------------
------------------	PPDATTRIBUTE
-----------------------------------------------------------------
BEGIN

	SELECT	'' 'PPDATTRIBUTE Before', *	FROM PPDATTRIBUTE WHERE	id = (select id from #tbl_ids where tbl = 'ppdattribute')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT 
		INTO	PPDATTRIBUTE
				(
				PREPROCESSING_DETAIL_ID,
				VALUE_TX, 
				CODE_CD, 
				CREATE_DT,UPDATE_DT, 
				UPDATE_USER_TX, 
				LOCK_ID, VALUE_XML, 
				COMMON_STYLESHEET_ID
				)
		SELECT 
				(select id from #tbl_ids where tbl = 'preprocessing_detail'),
				'PRAETORIAN',
				'XSLTScript',
				GETDATE(),
				GETDATE(), 
				@update_user_tx, 
				1, 
				NULL, 
				2

		set		@ppda_id = SCOPE_IDENTITY()

		insert into #tbl_ids (tbl, id) select 'ppdattribute', @ppda_id

	END

	SELECT '' 'PPDATTRIBUTE After', * FROM PPDATTRIBUTE WHERE id = (select id from #tbl_ids where tbl = 'ppdattribute')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER PPDATTRIBUTE #tbl_ids', *	from #tbl_ids 

END


-----------------------------------------------------------------
------------------	DELIVERY_INFO_DELIVER_TO_TP_RELATE
-----------------------------------------------------------------
BEGIN

	SELECT	'' 'DELIVERY_INFO_DELIVER_TO_TP_RELATE After', * FROM DELIVERY_INFO_DELIVER_TO_TP_RELATE WHERE id = 
		(select id from #tbl_ids where tbl = 'delivery_info_deliver_to_tp_relate')

	if(@IF_UPDATE = 'TRUE')
	BEGIN

		INSERT
		INTO	DELIVERY_INFO_DELIVER_TO_TP_RELATE 
				( 
				DELIVERY_INFO_ID,  
				DELIVER_TO_TP_ID,  
				CREATE_dT,  
				UPDATE_DT,  
				UPDATE_USER_TX,  
				LOCK_ID 
				)
		SELECT  
				(select id from #tbl_ids where tbl = 'delivery_info'),  
				2046,  
				GETDATE(),  
				GETDATE(),  
				@update_user_tx,  
				1

		set		@didttr_id = SCOPE_IDENTITY()

		insert into #tbl_ids (tbl, id) select 'delivery_info_deliver_to_tp_relate', @didttr_id

	END

	SELECT	'' 'DELIVERY_INFO_DELIVER_TO_TP_RELATE After', * FROM DELIVERY_INFO_DELIVER_TO_TP_RELATE WHERE id = 
		(select id from #tbl_ids where  tbl = 'delivery_info_deliver_to_tp_relate')

	if(@IF_VERBOSE = 'TRUE') select '' 'AFTER DELIVERY_INFO_DELIVER_TO_TP_RELATE #tbl_ids', * from #tbl_ids 

END


-----------------------------------------------------------------
------------------	Create Backout
-----------------------------------------------------------------
--if object_id('HDTStorage..INC_test_Backout','U') is not null drop table HDTStorage..INC_test_Backout -- THIS IS FOR DEVELOPMENT ONLY REMOVE FOR PROD
if(@IF_CREATE_BACKOUT = 'TRUE') exec('select * into HDTStorage..' + @update_user_tx + '_Backout from #tbl_ids')

if(@IF_VERBOSE = 'TRUE') select '' 'AFTER All Tables #tbl_ids', * from #tbl_ids 

SET NOEXEC OFF -- If NOEXEC was set on due to the Trading Partner already existing, then it must be turned back off
