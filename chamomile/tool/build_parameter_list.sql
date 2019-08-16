--
--
--
-- build parameters
--------------------------------------------------------------------------
DECLARE @list     [nvarchar](MAX)
        , @prefix [sysname] = N'@'
        , @schema [sysname] = N'schema'
        , @object [sysname] = N'table or view';

SELECT @list = COALESCE(@list + N', ', N'') + @prefix
               + [columns].[name] + CASE
               --
               WHEN [types].[name] IN ( N'varchar', N'char' ) THEN N' [' + [types].[name] + '] (' + CAST([columns].[max_length] AS [sysname]) + N')'
               --
               WHEN [types].[name] IN ( N'nvarchar', N'nchar' ) THEN N' [' + [types].[name] + '] (' + CAST([columns].[max_length] / 2 AS [sysname]) + N')'
               --
               WHEN [types].[name] = N'decimal' THEN N' [' + [types].[name] + '] (' + CAST([columns].[precision] AS [sysname]) + N', ' + CAST([columns].[scale] AS [sysname]) + ')'
               --
               ELSE N' [' + [types].[name] + '] '
               --
               END
               --
               + N' = null'
FROM   [sys].[columns] AS [columns]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [columns].[object_id]
       JOIN [sys].[types] AS [types]
         ON [types].[user_type_id] = [columns].[user_type_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
WHERE  [schemas].[name] = @schema
       AND [tables].[name] = @object
--ORDER BY [columns].[column_id];
ORDER  BY [columns].[name];

SELECT @list; 


-- todo - build from remote database, call procedure remotely?
-- todo - create views
--------------------------------------------------------------------------
declare @table_schema     [sysname]=N'dbo',
        @table            [sysname] =N'letters_exhibits',
        @procedure_schema [sysname]=N'letter',
        @procedure        [sysname]=N'set_set_exhibit',
        @builder          [nvarchar](max),
        @sql              [nvarchar](max);

select @builder = coalesce(@builder + N', ', N'') + N'@'
                  + [columns].[name] +
                  --
                  case when [types].[name]=N'varchar' then N' [' + [types].[name] + N']('+cast([columns].[max_length] as [sysname]) + N')'
                  --
                  when [types].[name]=N'nvarchar' then N' [' + [types].[name] + N']('+cast([columns].[max_length]/2 as [sysname]) + N')'
                  --
                  when [types].[name] in (N'datetime', N'int') then N' [' + [types].[name] + N']'
                  --
                  else N' [' + [types].[name] + N'] ' end + N' = null '
from   [sys].[columns] as [columns]
       join [sys].[types] as [types]
         on [types].[user_type_id] = [columns].[user_type_id]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
where  object_schema_name([tables].[object_id]) = @table_schema
       and [tables].[name] = @table;

/*
if schema_id(N'' + @procedure_schema + '') is null
  execute (N'create schema ' + @procedure_schema + '');

if object_id(N'[' + @procedure_schema + N'].[' + @procedure + ']'
             , N'P') is not null
  execute (N'drop procedure [' + @procedure_schema + N'].[' + @procedure+N']');
*/
set @sql = N'if object_id(N''[' + @procedure_schema
           + N'].[' + @procedure
           + ']'', N''P'') is not null drop procedure ['
           + @procedure_schema + N'].[' + @procedure + ']';
set @sql = @sql + N'create procedure ['
           + @procedure_schema + N'].[' + @procedure + N'] '
           + @builder + N' as begin            
				set nocount on;
				execute as user = N''replace_me-secure_schema_user'';
				select N''replace_me''; 
           end  ';

select @sql;

/*
execute sp_executesql
  @sql = @sql;
*/
go 
