/*
	todo
		build from remote database, call view remotely?
		execute_as statement will overflow sql_variant if too large (too many columns).
		handle trailing comma on create view and create execute_as blocks.
*/
declare @database       [sysname] = N'<database>',
        @table_schema   [sysname]=N'<table_schema>',
        @table          [sysname] =N'<table>',
        @view_schema    [sysname]=N'<view_schema>',
        @view           [sysname]=N'<view>',
        @package        [sysname] = N'<package>',
        @revision       [sysname] = N'<revision>',
        @revision_value [nvarchar](max) = N'<revision_value>',
        @description    [nvarchar](max),
        @builder        [nvarchar](max),
        @execute_as     [nvarchar](max),
        @sql            [nvarchar](max),
        @column         [sysname];

set @description=N'a facade for [' + @table_schema + N'].['
                 + @table + N'].';

--
-- use database statement
-------------------------------------------------    
print N'use [' + @database + N'];
go';

--
-- drop statement
-------------------------------------------------    
set @sql=N'if object_id(N''[' + @view_schema + N'].['
         + @view + ']'', N''V'') is not null
	drop view [' + @view_schema + N'].['
         + @view + '];
go';

print @sql;

--
-- script to extract documentation
-------------------------------------------------    
print N'
/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------		
	declare @schema [sysname]=N'''
      + @view_schema + N''', @object [sysname]=N'''
      + @view + ''';
	--  
	select N''['' +object_schema_name([extended_properties].[major_id]) +N''].[''+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N''].[''+
					Object_name([objects].[object_id]) +N'']'' 
				else Object_name([objects].[object_id]) +N'']'' + coalesce(N''.[''+
					[columns].[name] + N'']'', N'''')
			end                                                                as [object]
		   ,case when [extended_properties].[minor_id]=0 
					then [objects].[type_desc]
				 when [extended_properties].[class]=7
					then N''INDEX''
				 else N''COLUMN''
			end                                                                as [type]
		   ,[extended_properties].[name]                                       as [property]
		   ,[extended_properties].[value]                                      as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   left join [sys].[columns] as [columns]
				  on [extended_properties].[major_id]=[columns].[object_id] and
					 [columns].[column_id]=[extended_properties].[minor_id]
	where   coalesce(
				Object_schema_name([objects].[parent_object_id]), 
				Object_schema_name([extended_properties].[major_id]))=@schema and
			coalesce(
				Object_name([objects].[parent_object_id]), 
				Object_name([extended_properties].[major_id]))=@object
	order  by [type],[columns].[name],[object],[property]; 
*/';

--
-- build view statement
-------------------------------------------------
declare [column_cursor] cursor for
  select name
  from   sys.columns
  where  object_schema_name(object_id) = @table_schema
         and object_name(object_id) = @table
  order  by name;

print N'
create view [' + @view_schema + N'].[' + @view
      + ']
as 
	select ';

open [column_cursor];

fetch next from [column_cursor] into @column;

while @@fetch_status = 0
  begin
      print N'		[' + @table + '].[' + @column + N'] as [' + @column
            + N'],';

      fetch next from [column_cursor] into @column;
  end;

close [column_cursor];

deallocate [column_cursor];

print N'from [' + @table_schema + N'].[' + @table
      + N'] as [' + @table + '];
go';

--
-- table documentation
------------------------------------------------- 
print N'
--
------------------------------------------------- 
if exists (select *
		from   Fn_listextendedproperty(
      N''description'', 
      N''schema'', 
      N''' + @view_schema + N''', 
      N''view'', 
      N''' + @view
      + N''', 
      default, 
      default))
  exec sys.sp_dropextendedproperty
    @name=N''description'',
    @level0type=N''schema'',
    @level0name=N''' + @view_schema
      + N''',
    @level1type=N''view'',
    @level1name=N''' + @view + N''';
go
exec sys.sp_addextendedproperty
  @name=N''description'',
  @value=N'''
      + @description + ''',
  @level0type=N''schema'',
  @level0name=N'''
      + @view_schema + N''',
  @level1type=N''view'',
  @level1name=N''' + @view
      + N''';
go 
--
------------------------------------------------- 
if exists (select *
		from   Fn_listextendedproperty(
      N''execute_as'', 
      N''schema'', 
      N''' + @view_schema + N''', 
      N''view'', 
      N''' + @view
      + N''', 
      default, 
      default))
  exec sys.sp_dropextendedproperty
    @name=N''execute_as'',
    @level0type=N''schema'',
    @level0name=N''' + @view_schema
      + N''',
    @level1type=N''view'',
    @level1name=N''' + @view + N''';
go
exec sys.sp_addextendedproperty
  @name=N''execute_as'',
  @value=N''';

--
-- build execute_as statement
-------------------------------------------------
declare [column_cursor] cursor for
  select name
  from   sys.columns
  where  object_schema_name(object_id) = @table_schema
         and object_name(object_id) = @table
  order  by name;

print N'
		select ';

open [column_cursor];

fetch next from [column_cursor] into @column;

while @@fetch_status = 0
  begin
      print N'			[' + @column + N'],';

      fetch next from [column_cursor] into @column;
  end;

close [column_cursor];

deallocate [column_cursor];

print N'		from [' + @view_schema + N'].[' + @view + N'];';

print N''',
  @level0type=N''schema'',
  @level0name=N''' + @view_schema
      + N''',
  @level1type=N''view'',
  @level1name=N''' + @view + N''';
go 
--
------------------------------------------------- 
if exists (select *
           from   Fn_listextendedproperty(
       N'''
      + @package + ''', 
       N''schema'', 
       N''' + @view_schema
      + N''', 
       N''view'', N''' + @view
      + N''', 
       default, 
       default))
  exec sys.sp_dropextendedproperty
    @name=N''' + @package
      + ''',
    @level0type=N''schema'',
    @level0name=N''' + @view_schema
      + N''',
    @level1type=N''view'',
    @level1name=N''' + @view + N''';
go
exec sys.sp_addextendedproperty
  @name=N'''
      + @package + ''',
  @value=N''label_only'',
  @level0type=N''schema'',
  @level0name=N''' + @view_schema
      + N''',
  @level1type=N''view'',
  @level1name=N''' + @view + N''';
go 
--
------------------------------------------------- 
if exists (select *
		from   Fn_listextendedproperty(
	N''' + @revision
      + ''', 
	N''schema'', 
	N''' + @view_schema + N''', 
	N''view'', 
	N''' + @view
      + N''', 
	default, 
	default))
  exec sys.sp_dropextendedproperty
    @name=N''' + @revision
      + ''',
    @level0type=N''schema'',
    @level0name=N''' + @view_schema
      + N''',
    @level1type=N''view'',
    @level1name=N''' + @view + N''';
go
exec sys.sp_addextendedproperty
  @name=N'''
      + @revision + ''',
  @value=N''' + @revision_value
      + ''',
  @level0type=N''schema'',
  @level0name=N''' + @view_schema
      + N''',
  @level1type=N''view'',
  @level1name=N''' + @view + N''';
go 
';

--
-- column documentation
-------------------------------------------------
declare [name_cursor] cursor for
  select name
  from   sys.columns
  where  object_schema_name(object_id) = @table_schema
         and object_name(object_id) = @table
  order  by name;

open [name_cursor];

fetch next from [name_cursor] into @column;

while @@fetch_status = 0
  begin
      print N'
--
------------------------------------------------- 
if exists 
   (select * 
	from   fn_listextendedproperty(
		N''description'', 
		N''schema'', 
		N''' + @view_schema + N''', 
		N''view'', 
		N''' + @view + N''', 
		N''column'', 
		N'''
            + @column + '''))
  exec sys.sp_dropextendedproperty 
	@name        =N''description'' 
	, @level0type=N''schema'' 
	, @level0name=N''' + @view_schema
            + N''' 
	, @level1type=N''view'' 
	, @level1name=N''' + @view
            + N''' 
	, @level2type=N''column'' 
	, @level2name=N''' + @column
            + ''';
go 
exec sys.sp_addextendedproperty 
  @name        =N''description'' 
  , @value     =N''todo'' 
  , @level0type=N''schema'' 
  , @level0name=N''' + @view_schema
            + N''' 
  , @level1type=N''view'' 
  , @level1name=N''' + @view
            + N''' 
  , @level2type=N''column''
  , @level2name=N''' + @column + '''; 
go';

      fetch next from [name_cursor] into @column;
  end;

close [name_cursor];

deallocate [name_cursor];

go 
