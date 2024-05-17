use UniTrac


select * 
from CARRIER 
where CODE_TX = 'NG-10%'


select *
from TRADING_PARTNER
where NAME_TX like 'Nat%'


select top 10 *
from DELIVERY_DETAIL
where DELIVERY_CODE_TX = 'ArchOutFolder'
and VALUE_TX like '%EOM%'


select *
from DELIVERY_DETAIL
where DELIVERY_INFO_GROUP_ID = 




