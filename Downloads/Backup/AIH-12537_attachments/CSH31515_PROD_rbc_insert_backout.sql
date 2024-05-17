-- BACKOUT PLAN
-- RBC Insert 
--		optional Rate Group Id

/*
Related ServiceNow: CSH-31515
Environment: Production
Server: UT-PRD-LISTENER
*/

use unitrac

----------------------------------------------------------------
--	Flags
declare
	@IF_APPLY_DELETE		varchar(10)	= 'FALSE'	-- default = FALSE	: SET TO TRUE WHEN YOU ARE SURE YOU ARE READY TO DELETE
----------------------------------------------------------------


-- Create Temp Table
if object_id('tempdb.dbo.#tmpBackout','U') is not null drop table #tmpBackout
select * into #tmpBackout from HDTStorage..CSH31515_Backout


declare	
	@update_user_tx		varchar(15)		= 'CSH31515',
	@rate_group_id		int				= (select distinct rate_group_id from #tmpBackout),
	@insert_count		int				= (select count(*) from #tmpBackout)

declare
	@update_user_tx_bo	varchar(15)		= @update_user_tx + 'BO',
	@delete_predicate	varchar(max)
		= 'from rate_by_criteria where rate_group_id = ' + CONVERT(varchar(10),@rate_group_id) + ' and update_user_tx = '''+ @update_user_tx + ''''

declare @result table (delete_count int);
insert into @result (delete_count) exec ('select count(*) ' + @delete_predicate );
declare @delete_count int = (select delete_count from @result)

declare @before_msg varchar(max) = CONVERT(varchar(10),@delete_count)
-- Visual Check
select '' 'BEFORE Backout = ' , * from rate_by_criteria where rate_group_id = @rate_group_id


-- Visual Check
select '' 'Must be equal to continue', @delete_count 'delete_count', @insert_count 'insert_count'


-- Apply Delete if record counts are equal
if(@IF_APPLY_DELETE = 'TRUE')
BEGIN
	if(@delete_count = @insert_count)
	begin
		declare @rbc_before_delete_count	int = (select count(*) from rate_by_criteria where rate_group_id = @rate_group_id)
	
		select '' 'counts are equal'
		exec ('delete ' + @delete_predicate )

		declare @rbc_after_delete_count		int = (select count(*) from rate_by_criteria where rate_group_id = @rate_group_id)

		select '' 'Must be equal', @delete_count 'Plan Deleted', @rbc_before_delete_count - @rbc_after_delete_count 'Actual Deleted'
	end
END

-- Visual Check
select '' 'AFTER Backout Should be empty', * from rate_by_criteria where rate_group_id = @rate_group_id
