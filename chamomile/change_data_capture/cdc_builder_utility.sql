declare @from_lsn [binary](10) = [sys].fn_cdc_get_min_lsn('<schema>.<table_to_capture>'),
        @to_lsn   [binary](10) = [sys].fn_cdc_get_max_lsn();

select top(1000) *
from   [cdc].[fn_cdc_get_all_changes_<schema>.<table_to_capture>] (@from_lsn
                                                       , @to_lsn
                                                       , N'all')
where  [__$operation] = 2
order  by [__$start_lsn];

--
-- 13,319,356
-------------------------------------------------
select count(*)
from   [cdc].[<schema>.<table_to_capture>_ct];

--
-- 1 = delete
-- 6,658,503
-------------------------------------------------
select count(*)
from   [cdc].[<schema>.<table_to_capture>_ct]
where  [__$operation] = 1;

--
-- 2 = insert
-- 6,660,853
-------------------------------------------------
select count(*)
from   [cdc].[<schema>.<table_to_capture>_ct]
where  [__$operation] = 2;

--
-- 3 = update (old values) Column data has row values before executing the update statement.
-- 0
-------------------------------------------------
select count(*)
from   [cdc].[<schema>.<table_to_capture>_ct]
where  [__$operation] = 3;

--
-- 4 = update (new values) Column data has row values after executing the update statement.
-- 0
-------------------------------------------------
select count(*)
from   [cdc].[<schema>.<table_to_capture>_ct]
where  [__$operation] = 4; 
