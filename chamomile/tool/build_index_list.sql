/*
	todo, except current column
*/
set nocount on;

declare @include   [nvarchar](max)
        , @column  [sysname]
        , @schema  [sysname]= N'dbo'
        , @object  [sysname] = N'ExtPAIntelOrderDetails'
        , @message [nvarchar](max);
declare @index_list as table
  (
     [column]    [sysname]
     , [include] [nvarchar](max)
  );

--
-------------------------------------------------
begin
    if (select count(*)
        from   [sys].[tables]
        where  object_schema_name([object_id]) = @schema
               and [name] = @object) != 1
      begin
          set @message = N'Table ' + quotename(@schema, N']') + N'.'
                         + quotename(@object, N']')
                         + N' does not exist in database '
                         + quotename(db_name(), N']') + N'.';

          throw 51000, @message, 1;
      end;
end;

--
-------------------------------------------------
insert into @index_list
            ([column])
select [name]
from   sys.columns
where  object_schema_name(object_id) = @schema
       and object_name(object_id) = @object;

declare [index_cursor] cursor for
  select [column]
  from   @index_list
  order  by [column];

open [index_cursor];

fetch next from [index_cursor] into @column;

while @@fetch_status = 0
  begin
      set @include=null;

      select @include = coalesce(@include + N', ', N' ')
                        + quotename([column], N']')
      from   @index_list
      order  by [column];

      print '--
------------------------------------------------- 
if Indexproperty (Object_id(''[' + @schema
            + N'].[' + @object + N']''), ''' + @schema + N'.'
            + @object + N'.' + @column + N'.nonclustered_index'', ''IndexID'') is not null
  drop index [' + @schema
            + N'.' + @object + N'.' + @column
            + N'.nonclustered_index] on [' + @schema
            + N'].[' + @object
            + N'];
go
create nonclustered index [' + @schema + N'.'
            + @object + N'.' + @column
            + N'.nonclustered_index] on '
            + quotename(@schema, N']') + N'.'
            + quotename(@object, N']') + N'([' + @column
            + N'])
  include (' + @include + N');
go';

      fetch next from [index_cursor] into @column;
  end;

close [index_cursor];

deallocate [index_cursor]; 
