use [david];

go

set nocount on;

go

declare @schema   [sysname] = N'staging'
        , @object [sysname] = N'pid_range_mapping'
        , @id     [nvarchar](36)
        , @sql    [nvarchar](max);
declare @receiver as table
  (
     [max_length] int
  );
declare @results as table
  (
     [id]           nvarchar(36)
     , [object]     nvarchar(250)
     , [column]     nvarchar(250)
     , [type]       nvarchar(250)
     , [max_length] nvarchar(250)
     , [max_value]  nvarchar(250)
     , [sql_text]   nvarchar(250)
  );

insert into @results
            ([id],
             [object],
             [column],
             [type],
             [max_length],
             [max_value],
             [sql_text])
select newid()
       , object_name([columns].object_id)
       , [columns].name
       , [types].name
       , case
           when [types].name != 'nvarchar' then 'NA'
           when [columns].max_length = -1 then 'Max'
           else cast([columns].max_length as varchar)
         end
       , 'NA'
       , 'SELECT Max(Len(' + [columns].name
         + ')) FROM '
         + object_schema_name([columns].object_id)
         + '.' + object_name([columns].object_id)
from   sys.columns as [columns]
       inner join sys.types as [types]
               on [columns].user_type_id = [types].user_type_id
where  object_name([columns].object_id) = @object
       and object_schema_name([columns].object_id) = @schema
order  by [columns].name;

declare [length_cursor] cursor for
  select [id]
         , [sql_text]
  from   @results
  where  [max_length] != 'NA'
  order  by [column];

open [length_cursor];

fetch next from [length_cursor] into @id, @sql;

while @@fetch_status = 0
  begin
      insert into @receiver
                  ([max_length])
      exec(@sql);

      update @results
      set    [max_value] = (select [max_length]
                            from   @receiver)
      where  [id] = @id;

      delete from @receiver;

      fetch next from [length_cursor] into @id, @sql;
  end;

close [length_cursor];

deallocate [length_cursor];

select [object]
       , [column]
       , [type]
       , [max_length]
       , [max_value]
from   @results;

select N', ' + quotename([column], N']') + N' '
       + quotename([type], N']') + N' ('
       + isnull([max_value], N'0') + N')'
from   @results
order  by [column]; 
