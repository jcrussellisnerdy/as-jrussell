-- BACKOUT PLAN
-- Add EDI Trading Partner V2

/*
Related ServiceNow: CSH-32797
Environment: Production
Server: UT-PRD-LISTENER
*/

use unitrac

declare 
	@update_user_tx		varchar(15)	= 'CSH32797'
declare
	@update_user_tx_bo	varchar(15)	= @update_user_tx + 'BO'
declare
	@IF_BACKOUT			varchar(10)	= 'FALSE'	-- TRUE FALSE


select count(*) 'TRADING_PARTNER'						from TRADING_PARTNER					where update_user_tx = @update_user_tx
select count(*) 'DELIVERY_INFO'							from DELIVERY_INFO						where update_user_tx = @update_user_tx
select count(*) 'DELIVERY_INFO_GROUP'					from DELIVERY_INFO_GROUP				where update_user_tx = @update_user_tx
select count(*) 'DELIVERY_DETAIL'						from DELIVERY_DETAIL					where update_user_tx = @update_user_tx
select count(*) 'RELATED_DATA'							from RELATED_DATA						where update_user_tx = @update_user_tx and def_id in (71, 102)
select count(*) 'PREPROCESSING_DETAIL'					from PREPROCESSING_DETAIL				where update_user_tx = @update_user_tx
select count(*) 'PPDATTRIBUTE'							from PPDATTRIBUTE						where update_user_tx = @update_user_tx
select count(*) 'DELIVERY_INFO_DELIVER_TO_TP_RELATE'	from DELIVERY_INFO_DELIVER_TO_TP_RELATE where update_user_tx = @update_user_tx

-----------------------------------------------------------------
------------------	BACKOUT
-----------------------------------------------------------------
if(@IF_BACKOUT = 'TRUE')
BEGIN
	-- Done in reverse order
	select 'IF_BACKOUT = TRUE'

	-- Create Temp Table
	if object_id('tempdb.dbo.#tbl_ids','U') is not null drop table #tbl_ids 
	select * into #tbl_ids from  HDTStorage..CSH32797_1_Backout		-- << Need to manually add the backout table name from the implementation plan
	select '' '#tbl_ids', * from #tbl_ids
	
	BEGIN

		select '' 'BEFORE Backout', * from #tbl_ids

		-- DELIVERY_INFO_DELIVER_TO_TP_RELATE
		if((select count(*) from #tbl_ids where tbl = 'delivery_info_deliver_to_tp_relate') > 0)
		BEGIN
			select 'purge delivery_info_deliver_to_tp_relate'
			update	
					delivery_info_deliver_to_tp_relate 
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'delivery_info_deliver_to_tp_relate') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- PPDATTRIBUTE
		if((select count(*) from #tbl_ids where tbl = 'ppdattribute') > 0)
		BEGIN
			select 'purge ppdattribute'
			update	
					ppdattribute  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'ppdattribute') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- PREPROCESSING_DETAIL
		if((select count(*) from #tbl_ids where tbl = 'preprocessing_detail') > 0)
		BEGIN
			select 'purge preprocessing_detail'
			update	
					preprocessing_detail  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'preprocessing_detail') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- RELATED_DATA
		-- 71
		if((select count(*) from #tbl_ids where tbl = 'related_data_71') > 0)
		BEGIN
			select 'delete related_data_71'
			delete 
			from	related_data 
			where	id = (select id from #tbl_ids where tbl = 'related_data_71') 
					and UPDATE_USER_TX = @update_user_tx
					and DEF_ID = 71
		END


			if((select count(*) from #tbl_ids where tbl = 'related_data_102') > 0)
		BEGIN
			select 'delete related_data_102'
			delete 
			from	related_data 
			where	id = (select id from #tbl_ids where tbl = 'related_data_102') 
					and UPDATE_USER_TX = @update_user_tx
					and DEF_ID = 71
		END


		-- DELIVERY_DETAIL
		if((select count(*) from #tbl_ids where tbl = 'delivery_detail') > 0)
		BEGIN
			select 'purge delivery_detail'
			update	
					delivery_detail  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					delivery_info_group_id = (select id from #tbl_ids where tbl = 'delivery_detail') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- DELIVERY_INFO_GROUP
		if((select count(*) from #tbl_ids where tbl = 'delivery_info_group') > 0)
		BEGIN
			select 'purge delivery_info_group'
			update	
					delivery_info_group  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'delivery_info_group') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- DELIVERY_INFO
		if((select count(*) from #tbl_ids where tbl = 'delivery_info') > 0)
		BEGIN
			select 'purge delivery_info'
			update	
					delivery_info  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'delivery_info') 
					and UPDATE_USER_TX = @update_user_tx
		END


		-- TRADING_PARTNER
		if((select count(*) from #tbl_ids where tbl = 'trading_partner') > 0)
		BEGIN
			select 'purge trading_partner'
			update	
					trading_partner  
			set
					PURGE_DT			= GETDATE(),
					UPDATE_USER_TX		= @update_user_tx_bo,
					UPDATE_DT			= GETDATE(),
					LOCK_ID 			= LOCK_ID % 255 + 1
			where	
					id = (select id from #tbl_ids where tbl = 'trading_partner') 
					and UPDATE_USER_TX = @update_user_tx
		END

	END
END


select '' 'TRADING_PARTNER', PURGE_DT, *		from TRADING_PARTNER		where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'DELIVERY_INFO', PURGE_DT, *			from DELIVERY_INFO			where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'DELIVERY_INFO_GROUP', PURGE_DT, *	from DELIVERY_INFO_GROUP	where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'DELIVERY_DETAIL', PURGE_DT, *		from DELIVERY_DETAIL		where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'RELATED_DATA', *						from RELATED_DATA			where update_user_tx in (@update_user_tx_bo, @update_user_tx) and def_id in (71, 102)
select '' 'PREPROCESSING_DETAIL', PURGE_DT, *	from PREPROCESSING_DETAIL	where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'PPDATTRIBUTE', PURGE_DT, *			from PPDATTRIBUTE			where update_user_tx in (@update_user_tx_bo, @update_user_tx)
select '' 'DELIVERY_INFO_DELIVER_TO_TP_RELATE', PURGE_DT, * from DELIVERY_INFO_DELIVER_TO_TP_RELATE where update_user_tx in (@update_user_tx_bo, @update_user_tx)
