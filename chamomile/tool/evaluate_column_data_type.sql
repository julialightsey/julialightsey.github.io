--
if object_id(N'tempdb..#builder', N'U') is not null
  drop table #builder;

go

if object_id(N'tempdb..#evaluator', N'U') is not null
  drop table #evaluator;

go

if object_id(N'tempdb..#result', N'U') is not null
  drop table #result;

go

--
-------------------------------------------------
declare @schema             [sysname] = N'dbo'
        , @table            [sysname] = N'employees'
        , @is_numeric_count [int]
        , @is_date_count    [int]
        , @distinct_count   [int];

create table #builder
  (
     [result] [nvarchar](256),
     constraint [builder__pk] unique ([result])
  );

create table #evaluator
  (
     [result] [nvarchar](256)
     , [is_numeric] as isnumeric([result])
     , [is_date] as isdate([result])
  );

create table #result
  (
     [column]       [sysname]
     , [column_id]  [int]
     , [type_guess] [nvarchar](128)
  );

declare @column             [sysname]
        , @column_id        [int]
        , @get_distinct_sql [nvarchar](max)
        , @get_max_sql      [nvarchar](max)
        , @parameters       [nvarchar](max) = N'@big_count [bigint] output'
        , @big_count        [bigint]
        , @count            [int]
        , @max              [int]
        , @max_length       [int]
        , @type_guess       [sysname];

--
begin
    declare [column_cursor] cursor for
      select N'select distinct '
             + quotename([columns].[name]) + N' from '
             + quotename(@schema) + N'.' + quotename(@table)
             , N'select @big_count = max('
               + quotename([columns].[name]) + N') from '
               + quotename(@schema) + N'.' + quotename(@table)
             , [columns].[name]
             , [columns].[column_id]
      from   [sys].[columns] as [columns]
             join [sys].[tables] as [tables]
               on [tables].[object_id] = [columns].[object_id]
             join [sys].[schemas] as [schemas]
               on [schemas].[schema_id] = [tables].[schema_id]
      where  [schemas].[name] = @schema
             and [tables].[name] = @table
      order  by [columns].[column_id];

    open [column_cursor];

    fetch next from [column_cursor] into @get_distinct_sql, @get_max_sql, @column, @column_id;

    while @@fetch_status = 0
      begin
          truncate table #builder;

          truncate table #evaluator;

          insert into #builder
          execute sp_executesql
            @get_distinct_sql;

          -- ignore NULL values
          delete from #builder
          where  [result] is null
                  or upper([result]) = N'NULL';

          -- get ISNUMERIC and ISDATE result
          insert into #evaluator
                      ([result])
          select [result]
          from   #builder;

          --
          begin
              select @is_numeric_count = count([is_numeric])
                     , @is_date_count = count([is_date])
                     , @count = count(*)
              from   #evaluator;

              --
              -- evaluate for ISNUMERIC 
              ---------------------------------------
              if @is_numeric_count = @count
                 and (select count(distinct( [is_numeric] ))
                      from   #evaluator) = 1
                 and (select max([is_numeric])
                      from   #evaluator) = 1
                begin
                    begin try
                        execute sp_executesql
                          @get_distinct_sql= @get_max_sql
                          , @parameters = @parameters
                          , @big_count = @big_count output;
                    end try
                    begin catch
                        select @get_distinct_sql
                               , @get_max_sql
                               , @is_numeric_count as [@is_numeric_count]
                               , @is_date_count    as [@is_date_count]
                               , @count
                               , @parameters
                               , @big_count;
                    end catch;

                    insert into #result
                                ([column]
                                 , [type_guess]
                                 , [column_id])
                    select @column
                           , case
                               when @big_count > 2147483647 then N'[bigint]'
                               else N'[int]'
                             end
                           , @column_id
                end;

              --
              -- evaluate for ISDATE
              ---------------------------------------
              if @is_date_count = @count
                 and (select count(distinct( [is_date] ))
                      from   #evaluator) = 1
                 and (select max([is_date])
                      from   #evaluator) = 1
                begin
                    insert into #result
                                ([column]
                                 , [type_guess]
                                 , [column_id])
                    select @column
                           , N'[datetime]'
                           , @column_id;
                end;
              --
              -- otherwise, it is a string
              ---------------------------------------
              else
                begin
                    select @max_length = max(len([result]))
                    from   #evaluator;

                    insert into #result
                                ([column]
                                 , [type_guess]
                                 , [column_id])
                    select @column
                           , N'[nvarchar]('
                             + convert(sysname, @max_length) + N')'
                           , @column_id;
                end;
          end;

          --
          fetch next from [column_cursor] into @get_distinct_sql, @get_max_sql, @column, @column_id;
      end;

    close [column_cursor];

    deallocate [column_cursor];
end;

select [column]
       , [type_guess]
from   #result
order  by [column_id]; 
