-- IMPLEMENTATION PLAN
-- RBC Insert 
--		optional Rate Group Id

/*
Related ServiceNow: CSH-31515
Environment: Production
Server: UT-PRD-LISTENER
*/

use unitrac

/* ///////////////////////////////////////////////////////// */

/*       Add the following information     */
declare 
	@update_user_tx		varchar(15)		= 'CSH31515_2',

-- Used to create RATE_GROUP_ID entry
	@carrier			varchar(50)		= 'Lloyds.Haz',
	@rate_group_code_tx varchar(50)		= 'Lloyds_Nasa_BW'

/* ///////////////////////////////////////////////////////// */


/* FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF */

--	Flags
declare
	@IF_CREATE_RATE_GROUP		varchar(10)	= 'FALSE',	-- default = TRUE : Will create a Rate Group Id, 
														-- if FALSE : @rate_group_code_tx must exist and the value will be used
	@IF_INSERT_RATE_BY_CRITERIA	varchar(10)	= 'TRUE',	-- default = TRUE : !!! SET TO TRUE ONLY WHEN READY TO UPDATE		
														-- SET TO FALSE TO SANITY CHECK SELECT OUTPUTS PRIOR TO UPDATE
	

---------------------------------------------------------------
-- DO NOT MODIFY IF ON PRODUCTION SERVER -- FOR DEVELOPMENT TESTING ONLY

	@IF_DROP_BACKOUT		varchar(10)	= 'FALSE',	-- default = FALSE	: THIS IS ONLY SET TO TRUE FOR TESTING ON NON-PRODUCTION SERVERS
	@IF_CREATE_BACKOUT		varchar(10)	= 'TRUE',	-- default = TRUE	: THIS IS ONLY SET TO FALSE WHEN DEVELOPING IMPLEMENTATION PLAN
	@IF_VERBOSE				varchar(10) = 'TRUE'	-- default = TRUE

----------------------------------------------------------------

/* FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF */

-- Other variables
declare
	@backout_table		varchar(100)	= 'HDTStorage..' + @update_user_tx + '_Backout',
	@carrier_id			bigint			= (select id from carrier where code_tx = @carrier),
	@taxamt				float			= 0/100,
	@rate_group_id		bigint


--****************************************************

-- Get the file created by rbc_file_prep.linq.
--		It takes an xlsx file from the client in a specific format and creates a txt file for BULK insert into #tmpRBC table

if object_id('tempdb.dbo.#tmpRBC','U') is not null drop table #tmpRBC
create table #tmpRBC(
	state varchar(max),
	collateral varchar(100),
	rate float,
	property_code varchar(100)
)

BULK INSERT #tmpRBC 
FROM '\\ON-SQLCLSTPRD-1\BulkInserts$\CSH31515_2\CSH31515_2_RBC.txt'
--FROM '\\UTQA-SQL-14\e$\BulkInserts\CSH30463_2\rbc_data.txt'
--FROM '\\UT-SQLSTG-01\e$\BulkInserts\CSH31515_2\CSH31515_2_RBC.txt'
WITH
(
	FIRSTROW			= 1,
	FIELDTERMINATOR		= '\t',
	ROWTERMINATOR		= '\n'
);

-- Visual check
if(@IF_VERBOSE = 'TRUE') select '' 'carrier', *	from carrier where code_tx = @carrier
if(@IF_VERBOSE = 'TRUE') select '' '#tmpRBC', * from #tmpRBC


--****************************************************

-- Create Entry in RATE_GROUP_ID
if(@IF_CREATE_RATE_GROUP = 'TRUE')
begin
	-- Check if Lender already exist in RATE_GROUP_ID table
	if
	(
		(
			select 
					count(*) 
			from 
					rate_group_id
			where 
					code_tx			= @rate_group_code_tx
					and carrier_id	= @carrier_id
		) <> 0
	)
	begin
		print 'THIS LENDER ALREADY EXISTS FOR THIS CARRIER'
		print 'Choose another name for the Rate Group'
		select '' 'Names already in use', code_tx from rate_group_id
		set noexec on -- Exit this script
	end
	else
	begin
		print 'The Lender is not in the RATE_GROUP_ID table and will be added'
	end

	-- Insert this Lender into the RATE_GROUP_ID table
	insert into
			RATE_GROUP_ID 
			(
				CARRIER_ID,
				CODE_TX,
				CREATE_DT,
				PURGE_DT,
				UPDATE_DT,
				UPDATE_USER_TX,
				LOCK_ID,
				CARRIER_VUT_KEY
			)
	select
				c.id,
				@rate_group_code_tx,
				getdate(),
				null,
				getdate(),
				@update_user_tx,
				1,
				c.vut_key
	from 
			carrier c
	where
			c.CODE_TX = @carrier

	-- Store the ID of this entry for use later
	select @rate_group_id = (SELECT SCOPE_IDENTITY())

end
else -- Rate Group Id already exists for this Lender so get that and apply to @rate_group_id
begin
	if
	((
		select 
				count(*) 
		from 
				rate_group_id
		where 
				code_tx			= @rate_group_code_tx
				and carrier_id	= @carrier_id
	) > 0 )
	begin
	
		set @rate_group_id =
		(
		select
				top 1 id
		from 
				rate_group_id
		where 
				code_tx			= @rate_group_code_tx
				and carrier_id	= @carrier_id
		)
	end
	else -- There was more than a single rate_group_id for this Carrier Id, Lender pair
	begin
		print 'THERE WAS MORE THAN A SINGLE RATE_GROUP_ID FOR THIS CARRIER/LENDER PAIR'
		print 'Check names of Carrier and Lender'
		select '' 'Names already in use', code_tx from rate_group_id
		set noexec on -- Exit this script
	end
end

if(@IF_VERBOSE = 'TRUE') select '' 'rate_group_id', *	from rate_group_id where carrier_id = @carrier_id and code_tx = @rate_group_code_tx

--------------------------------------------------------------------------------------------

-- Create Temp Table of intended Inserts into RATE_BY_CRITERIA table
if object_id('tempdb.dbo.#tmpRBCInsert','U') is not null drop table #tmpRBCInsert
select
			distinct rpc.coverage_type_cd	as COVERAGE_TYPE_CD,
			@rate_group_id					as RATE_GROUP_ID,
			t.state							as STATE,
			'00000'							as ZIP,
			t.property_code					as RATE_PROPERTY_CODE_TX,
			'Amount'						as PREMIUM_RATE_FACTOR,
			t.rate							as PREMIUM_AMOUNT,
			null							as TAX1_RATE_FACTOR,
			null							as TAX1_AMOUNT,
			'Percent'						as TAX2_RATE_FACTOR,
			@taxAmt							as TAX2_AMOUNT,
			NULL							as FEE_RATE_FACTOR,
			null							as FEE_AMOUNT,
			null							as OTHER_RATE_FACTOR,
			null							as OTHER_AMOUNT,
			null							as ICC_RATE_FACTOR,
			null							as ICC_FEE_AMOUNT, 
			0								as MISCELLANEOUS,
			null							as PROCTOR_CODE,
			'Y'								as ACTIVE_IN,
			getdate()						as CREATE_DT,
			getdate()						as UPDATE_DT,
			NULL							as PURGE_DT,
			@update_user_tx					as UPDATE_USER_TX,
			1								as LOCK_ID
into
		#tmpRBCInsert
from
		#tmpRBC t
join	
		rate_property_code rpc
			on rpc.code_tx = t.property_code
			and rpc.carrier_id = @carrier_id
order by state, property_code, coverage_type_cd

if(@IF_VERBOSE = 'TRUE') select '' '#tmbRBC', * from #tmpRBC
if(@IF_VERBOSE = 'TRUE') select '' '#tmpInsert', * from #tmpRBCInsert


-- Create Backout
if(@IF_DROP_BACKOUT = 'TRUE')
begin
	exec('
		drop table ' + @backout_table + '
	')
end
if(@IF_CREATE_BACKOUT = 'TRUE')
begin 
	exec('
		select * into ' + @backout_table + ' from #tmpRBCInsert

		select '''' ''Backout Table'', * from ' + @backout_table + '
	')
end

if(@IF_VERBOSE = 'TRUE') select '' 'JUST BEFORE INSERT INTO RBC'

-- Apply Insert
if(@IF_INSERT_RATE_BY_CRITERIA = 'TRUE')
begin

	insert into 
		RATE_BY_CRITERIA
		(
			RATE_GROUP_ID,
			STATE,
			ZIP,
			RATE_PROPERTY_CODE_TX,
			COVERAGE_TYPE_CD,
			PREMIUM_RATE_FACTOR,
			PREMIUM_AMOUNT,
			TAX1_RATE_FACTOR,
			TAX1_AMOUNT,
			TAX2_RATE_FACTOR,
			TAX2_AMOUNT,
			FEE_RATE_FACTOR,
			FEE_AMOUNT,
			OTHER_RATE_FACTOR,
			OTHER_AMOUNT,
			ICC_RATE_FACTOR,
			ICC_FEE_AMOUNT, 
			MISCELLANEOUS,
			PROCTOR_CODE,
			ACTIVE_IN,
			CREATE_DT,
			UPDATE_DT,
			PURGE_DT,
			UPDATE_USER_TX,
			LOCK_ID
		)
	select
			RATE_GROUP_ID,
			STATE,
			ZIP,
			RATE_PROPERTY_CODE_TX,
			COVERAGE_TYPE_CD,
			PREMIUM_RATE_FACTOR,
			PREMIUM_AMOUNT,
			TAX1_RATE_FACTOR,
			TAX1_AMOUNT,
			TAX2_RATE_FACTOR,
			TAX2_AMOUNT,
			FEE_RATE_FACTOR,
			FEE_AMOUNT,
			OTHER_RATE_FACTOR,
			OTHER_AMOUNT,
			ICC_RATE_FACTOR,
			ICC_FEE_AMOUNT, 
			MISCELLANEOUS,
			PROCTOR_CODE,
			ACTIVE_IN,
			CREATE_DT,
			UPDATE_DT,
			PURGE_DT,
			UPDATE_USER_TX,
			LOCK_ID
	from
			#tmpRBCInsert

	-- Visual check
	if(@IF_VERBOSE = 'TRUE') select '' 'RATE_BY_CRITERIA', * from rate_by_criteria where update_user_tx = @update_user_tx

end

set noexec off
