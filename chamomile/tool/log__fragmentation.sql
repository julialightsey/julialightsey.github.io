--
declare @log__entry               [bit] = 0
        , @entry                  xml
        , @application            nvarchar(450)
        , @maximum_fragmentation  [int] = 10
        , @minimum_page_count     [int] = 100
        , @fillfactor             [int] = null
        , @reorganize_demarcation [int] = 25
        , @defrag_count_limit     [int] = null
        , @timestamp__string      [sysname];

select @timestamp__string = convert([sysname], current_timestamp, 126)
       , @application = N'log__fragmentation';

select @entry = (select quotename(db_name()) + N'.' + quotename([schemas].[name]) + N'.' + quotename([tables].[name]) as [table]
                        , [indexes].[name]                                                                            as [index]
                        , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [sysname])              as [avg_fragmentation_in_percent]
                 from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, 'LIMITED') as [dm_db_index_physical_stats]
                        join [sys].[indexes] as [indexes]
                          on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                             and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
                        join [sys].[tables] as [tables]
                          on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
                        join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [tables].[schema_id]
                 where  [indexes].[name] is not null
                        and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
                        and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
                 order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc
                           , [schemas].[name]
                           , [tables].[name]
                 for xml path(N'table'), root(N'table__list'));

if @entry is null
  begin
      set @entry = N'<table__list />';
  end;

set @entry.modify(N'insert attribute timestamp {sql:variable("@timestamp__string")} as last into (/*)[1]');
set @entry.modify(N'insert attribute subject {sql:variable("@application")} as first into (/*)[1]');

--
if @log__entry = 0
  begin
      select @entry as [entry];
  end
else
  begin
      execute [utility].[utility].[set__log]
        @entry = @entry
        , @application = @application;

      select top(1) *
      from   [utility].[utility].[log]
      order  by [created] desc;
  end;

GO 
