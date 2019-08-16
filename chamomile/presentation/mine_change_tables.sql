--
--
use [fhlmc];

go

if schema_id(N'subject_area__party__secure') is null
  execute (N'create schema subject_area__party__secure');

go

if (select is_cdc_enabled
    from   sys.databases
    where  name = N'fhlmc') = 1
  exec sys.sp_cdc_disable_db;

go

if (select is_cdc_enabled
    from   sys.databases
    where  name = N'fhlmc') = 0
  exec sys.sp_cdc_enable_db;

go

--
-- Getting information about the change data capture enabled table
---------------------------------------------------------------------------------------------------
execute sys.sp_cdc_help_change_data_capture
  @source_schema = N'subject_area__party__secure',
  @source_name = N'party';

--
--	Returns captured columns only for the @capture_instance
execute sys.sp_cdc_get_captured_columns
  @capture_instance = 'subject_area__party__secure__party';

--
--	Notice that there are new objects and functions created for the change data capture enabled table
select object_schema_name([obj].[object_id]) as [schema]
       , [name]
       , [type_desc]
       , [create_date]
from   sys.objects as [obj]
where  lower([obj].[name]) like lower(N'%party%')
order  by [schema]
          , [name];

--
---------------------------------------------------------------------------------------------------
select tbl.[name]   as [source_table]
       , cpt.[name] as [capture_table]
       , [ct].[capture_instance]
       , [cc].[column_name]
       , [cc].[column_type]
from   cdc.captured_columns as [cc]
       join cdc.change_tables as ct
         on ct.[object_id] = [cc].[object_id]
       join sys.tables as cpt
         on cpt.object_id = cc.object_id
       join sys.tables as tbl
         on tbl.object_id = ct.[source_object_id]
       join sys.schemas as sch
         on sch.schema_id = tbl.schema_id
where  sch.name = N'subject_area__party__secure'
       and tbl.name = N'party';

select *
from   cdc.subject_area_party_secure_party_ct;

go

select *
from   cdc.change_tables;

--
--	Returns one row for each index column associated with a change table.
select *
from   cdc.index_columns;

--
-- Returns one row for each transaction having rows in a change table. 
select *
from   cdc.lsn_time_mapping

--
-- get journal record
---------------------------------------------------------------------------------------------------
declare @from_lsn binary(10),
        @to_lsn   binary(10)

set @from_lsn = sys.fn_cdc_get_min_lsn('subject_area__party__secure__party');
set @to_lsn = sys.fn_cdc_get_max_lsn();

select sys.fn_cdc_map_lsn_to_time([change_table].[__$start_lsn]) as [start_time]
       , convert([bigint], [change_table].[__$start_lsn])        as [start_lsn]
       , convert([bigint], [change_table].[__$seqval])           as [seqval]
       , convert([bigint], [change_table].[__$update_mask])      as [update_mask]
       , [change_table].[__$operation]                           as [operation]
       , convert([bigint], [change_table].[__$update_mask])      as [update_mask]
       , [party].*
from   cdc.fn_cdc_get_all_changes_subject_area__party__secure__party (@from_lsn
                                                                      , @to_lsn
                                                                      , N'all') as [change_table]
       join [subject_area__party__secure].[party] as [party]
         on [party].[id] = [change_table].[id]
for xml path(N'change'), root(N'change_list');

go

--
-- get data warehouse record
---------------------------------------------------------------------------------------------------
declare @alias_list [nvarchar](max)=N'';

with [get_alias]
     as (select [phone].[value] as [phone]
         from   [meta_data__secure].[data] as [phone]
                join [subject_area__party__secure].[party] as [party]
                  on [phone].[parent] = [party].[id]
         where  [phone].[type] = N'name')
select @alias_list = coalesce(@alias_list, N', ', N'') + [phone]
                     + ', '
from   [get_alias];

set @alias_list = left(@alias_list
                       , len(@alias_list) - 1);

declare @phone_list [nvarchar](max)=N'';

with [get_phones]
     as (select [phone].[value]
                + isnull(N'(' + [phone].[description] + N')', N'') as [phone]
         from   [meta_data__secure].[data] as [phone]
                join [subject_area__party__secure].[party] as [party]
                  on [phone].[parent] = [party].[id]
         where  [phone].[type] = N'phone')
select @phone_list = coalesce(@phone_list, N', ', N'') + [phone]
                     + ', '
from   [get_phones];

set @phone_list = left(@phone_list
                       , len(@phone_list) - 1);

declare @from_lsn binary(10),
        @to_lsn   binary(10);

set @from_lsn = sys.fn_cdc_get_min_lsn('subject_area__party__secure__party');
set @to_lsn = sys.fn_cdc_get_max_lsn();

select sys.fn_cdc_map_lsn_to_time([change_table].[__$start_lsn]) as [start_time]
       , [change_table].[__$operation]                           as [operation]
       , convert([bigint], [change_table].[__$update_mask])      as [update_mask]
       , [party].*
       , @phone_list                                             as [phone_list]
       , @alias_list                                             as [alias_list]
from   cdc.fn_cdc_get_all_changes_subject_area__party__secure__party (@from_lsn
                                                                      , @to_lsn
                                                                      , N'all') as [change_table]
       left join [subject_area__party__secure].[party] as [party]
              on [party].[id] = [change_table].[id]
       join [meta_data__secure].[data] as [phone]
         on [phone].[parent] = [party].[id]
for xml path(N'change'), root(N'change_list');

go 
