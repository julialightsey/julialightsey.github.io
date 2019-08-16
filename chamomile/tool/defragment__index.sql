select db_name() as [database];
go
declare @maximum_fragmentation    [int] = 10
        , @minimum_page_count     [int] = 100
        , @fillfactor             [int] = null
        , @reorganize_demarcation [int] = 25
        , @defrag_count_limit     [int] = null
        , @output                 [xml] = null
        --
        , @analyze__only          [bit] = 0
        , @verbose                [bit] = 1;
declare @schema                         [sysname]
        , @table                        [sysname]
        , @index                        [sysname]
        , @average_fragmentation_before decimal(10, 2)
        , @average_fragmentation_after  decimal(10, 2)
        , @sql                          [nvarchar](max)
        , @xml_builder                  [xml]
        , @defrag_count                 [int] = 0
        , @start                        datetime2
        , @complete                     datetime2
        , @elapsed                      decimal(10, 2)
        --
        , @timestamp                    datetime = current_timestamp
        , @application                  [sysname] = N'defragment';

--
-------------------------------------------
select @output = coalesce(@output, N'<index_list subject="' + @application + '" timestamp="' + convert(sysname, @timestamp, 126) + '"/>')
       , @defrag_count_limit = coalesce(@defrag_count_limit, 1000);

--
-------------------------------------------
set @output.modify(N'insert attribute maximum_fragmentation {sql:variable("@maximum_fragmentation")} as last into (/*)[1]');
set @output.modify(N'insert attribute minimum_page_count {sql:variable("@minimum_page_count")} as last into (/*)[1]');
set @output.modify(N'insert attribute fillfactor {sql:variable("@fillfactor")} as last into (/*)[1]');
set @output.modify(N'insert attribute reorganize_demarcation {sql:variable("@reorganize_demarcation")} as last into (/*)[1]');
set @output.modify(N'insert attribute defrag_count_limit {sql:variable("@defrag_count_limit")} as last into (/*)[1]');

--
-------------------------------------------
declare [table_cursor] cursor for
  select [schemas].[name]                                              as [schema]
         , [tables].[name]                                             as [table]
         , [indexes].[name]                                            as [index]
         , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [avg_fragmentation_in_percent]
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
            , [tables].[name];

--
-------------------------------------------
begin
    open [table_cursor];

    fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

    while @@fetch_status = 0
          and ( @defrag_count < @defrag_count_limit )
      begin
          if @average_fragmentation_before > @reorganize_demarcation
            begin
                set @sql = 'alter index [' + @index + N'] on [' + @schema + N'].[' + @table + '] rebuild ';

                if @fillfactor is not null
                  begin
                      set @sql = @sql + ' with (fillfactor=' + cast(@fillfactor as [sysname]) + ')';
                  end;

                set @sql = @sql + ' ; ';
            end;
          else
            begin
                set @sql = 'alter index [' + @index + N'] on [' + @schema + N'].[' + @table + '] reorganize';
            end;

          --
          -------------------------------
          if @sql is not null
            begin
                --
                ---------------------------
                set @start = current_timestamp;

                if @analyze__only <> 1
                  begin;
                      execute (@sql);
                  end;

                if @analyze__only <> 1
                    or @verbose = 1
                  begin;
                      select quotename(@schema) + N'.' + quotename(@table) as [object]
                             , @index                                      as [index]
                             , @average_fragmentation_before               as [average_fragmentation_before]
                             , @sql                                        as [sql];
                  end;

                set @complete = current_timestamp;
                set @elapsed = datediff(millisecond, @start, @complete);
                --
                -- build output
                ---------------------------
                set @xml_builder = (select @schema                                                                               as N'@schema'
                                           , @table                                                                              as N'@table'
                                           , @index                                                                              as N'@index'
                                           , @average_fragmentation_before                                                       as N'@average_fragmentation_before'
                                           , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] as decimal(10, 2)) as N'@average_fragmentation_after'
                                           , @elapsed                                                                            as N'@elapsed_milliseconds'
                                           , @sql                                                                                as N'sql'
                                    from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, 'LIMITED') as [dm_db_index_physical_stats]
                                           join [sys].[indexes] as [indexes]
                                             on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                                and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
                                           join [sys].[tables] as [tables]
                                             on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
                                           join [sys].[schemas] as [schemas]
                                             on [schemas].[schema_id] = [tables].[schema_id]
                                    where  [schemas].[name] = @schema
                                           and [tables].[name] = @table
                                           and [indexes].[name] = @index
                                    for xml path(N'result'), root(N'index'));

                --
                ---------------------------
                if @xml_builder is not null
                  begin
                      set @output.modify(N'insert sql:variable("@xml_builder") as last into (/*)[1]');
                  end;
            end;

          set @defrag_count = @defrag_count + 1;

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
      end;

    close [table_cursor];

    deallocate [table_cursor];
end;

if @analyze__only <> 1
  begin
      exec sp_updatestats
        @resample = N'resample';
  end;

go 
