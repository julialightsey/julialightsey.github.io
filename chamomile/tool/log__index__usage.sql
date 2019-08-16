/*
	All zero values mean that the table is not used, or the SQL Server service restarted recently.
	An index with zero or small number of seeks, scans or lookups and large number of updates is a useless index and should be removed, after verifying with the system owner, as the main purpose of adding the index is speeding up the read operations.
	An index that is scanned heavily with zero or small number of seeks means that the index is badly used and should be replaced with more optimal one.
	An index with large number of Lookups means that we need to optimize the index by adding the frequently looked up columns to the existing index non-key columns using the INCLUDE clause.
	A table with a very large number of Scans indicates that SELECT * queries are heavily used, retrieving more columns than what is required, or the index statistics should be updated.
	A Clustered index with large number of Scans means that a new Non-clustered index should be created to cover a non-covered query.
	Dates with NULL values mean that this action has not occurred yet.
	Large scans are OK in small tables.
	Your index is not here, then no action is performed on that index yet.
*/
--
declare @entry                    xml
        , @application            nvarchar(450)
        , @maximum_fragmentation  [int] = 10
        , @minimum_page_count     [int] = 100
        , @fillfactor             [int] = null
        , @reorganize_demarcation [int] = 25
        , @defrag_count_limit     [int] = null
        , @timestamp__string      [sysname];

select @timestamp__string = convert([sysname], current_timestamp, 126)
       , @application = N'log__index__usage';

select @entry = (select quotename(db_name()) + N'.'
                        + quotename(OBJECT_SCHEMA_NAME([indexes].[OBJECT_ID]))
                        + N'.'
                        + quotename(OBJECT_NAME([indexes].[OBJECT_ID]))      as [table]
                        , [indexes].name                                     as [index]
                        , [indexes].[type_desc]                              as [index_type]
                        , SUM([dm_db_partition_stats].[used_page_count]) * 8 as [Index_size_kb]
                        , [dm_db_index_usage_stats].[user_seeks]             as [user_seeks]
                        , [dm_db_index_usage_stats].[user_scans]             as [user_scans]
                        , [dm_db_index_usage_stats].[user_lookups]           as [user_lookups]
                        , [dm_db_index_usage_stats].[user_updates]           as [user_updates]
                        , [dm_db_index_usage_stats].[last_user_seek]         as [last_user_seek]
                        , [dm_db_index_usage_stats].[last_user_scan]         as [last_user_scan]
                        , [dm_db_index_usage_stats].[last_user_lookup]       as [last_user_lookup]
                        , [dm_db_index_usage_stats].[last_user_update]       as [last_user_update]
                 from   [sys].[indexes] as [indexes]
                        inner join [sys].[dm_db_index_usage_stats] as [dm_db_index_usage_stats]
                                on [dm_db_index_usage_stats].[index_id] = [indexes].[index_id]
                                   and [dm_db_index_usage_stats].[OBJECT_ID] = [indexes].[OBJECT_ID]
                        inner join [sys].[dm_db_partition_stats] as [dm_db_partition_stats]
                                on [dm_db_partition_stats].[object_id] = [indexes].[object_id]
                 where  OBJECTPROPERTY([indexes].[OBJECT_ID], 'IsUserTable') = 1
                 group  by quotename(db_name()) + N'.'
                           + quotename(OBJECT_SCHEMA_NAME([indexes].[OBJECT_ID]))
                           + N'.'
                           + quotename(OBJECT_NAME([indexes].[OBJECT_ID]))
                           , [indexes].name
                           , [indexes].[type_desc]
                           , [dm_db_index_usage_stats].[user_seeks]
                           , [dm_db_index_usage_stats].[user_scans]
                           , [dm_db_index_usage_stats].[user_lookups]
                           , [dm_db_index_usage_stats].[user_updates]
                           , [dm_db_index_usage_stats].[last_user_seek]
                           , [dm_db_index_usage_stats].[last_user_scan]
                           , [dm_db_index_usage_stats].[last_user_lookup]
                           , [dm_db_index_usage_stats].[last_user_update]
                 for xml path(N'table'), root(N'table__list'));

if @entry is null
  begin
      set @entry = N'<table__list />';
  end;

set @entry.modify(N'insert attribute timestamp {sql:variable("@timestamp__string")} as last into (/*)[1]');
set @entry.modify(N'insert attribute subject {sql:variable("@application")} as first into (/*)[1]');

-- 
execute [utility].[utility].[set__log]
  @entry = @entry
  , @application = @application;

select top(1) *
from   [utility].[utility].[log]
order  by [created] desc;

GO 
