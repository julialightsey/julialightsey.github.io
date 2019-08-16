set transaction isolation level read uncommitted;
go
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
       , @application = N'log__row_count';

select @entry = (select quotename(db_name()) + N'.'
                        + quotename([schemas].[name]) + N'.'
                        + quotename([tables].[name])                                                           as [table]
                        , [partitions].[rows]                                                                  as [row_count]
                        , SUM([allocation_units].[total_pages]) * 8                                            as [total_space_kb]
                        , SUM([allocation_units].[total_pages]) / 128                                          as [total_space_mb]
                        , SUM([allocation_units].[total_pages]) / 128 / 1024                                   as [total_space_gb]
                        , SUM([allocation_units].[used_pages]) * 8                                             as [used_space_kb]
                        , ( SUM([allocation_units].[total_pages]) - SUM([allocation_units].[used_pages]) ) * 8 as [unused_space_kb]
                 from   [sys].[tables] as [tables]
                        inner join [sys].[schemas] as [schemas]
                                on [schemas].[schema_id] = [tables].[schema_id]
                        inner join [sys].[indexes] as [indexes]
                                on [tables].[object_id] = [indexes].[object_id]
                        inner join [sys].[partitions] as [partitions]
                                on [indexes].[object_id] = [partitions].[object_id]
                                   and [indexes].[index_id] = [partitions].[index_id]
                        inner join [sys].[allocation_units] as [allocation_units]
                                on [partitions].[partition_id] = [allocation_units].[container_id]
                 where  [tables].[name] not like 'dt%'
                        and [tables].[is_ms_shipped] = 0
                        and [indexes].[object_id] > 255
                 group  by [schemas].[name]
                           , [tables].[name]
                           , [partitions].[rows]
                 order  by [schemas].[name]
                           , [tables].[name]
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
