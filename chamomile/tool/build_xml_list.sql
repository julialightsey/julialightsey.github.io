SELECT N', cast(isnull(' + [name] + N', N'''') AS SYSNAME) AS N''' + [name] + N''''
FROM   [sys].[parameters] AS [parameters]
WHERE  object_schema_name([object_id]) = N'dbo'
       AND object_name([object_id]) = N'FloorEvent_Submit'
ORDER  BY [name];


--
--
-- todo - build from remote database, call view remotely?
--------------------------------------------------------------------------
declare @table_schema [sysname]=N'<schema>',
        @table        [sysname] =N'<table>',
        @view_schema  [sysname]=N'<schema>',
        @view         [sysname]=N'<view>',
        @builder      [nvarchar](max),
        @sql          [nvarchar](max);

select @builder = coalesce(@builder + N', ', N'')
                  + N'isnull([' + [columns].[name]
                  + N'], N''null'') as ''@' + [columns].[name]
                  + N''''
from   [sys].[columns] as [columns]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
where  object_schema_name([tables].[object_id]) = @table_schema
       and [tables].[name] = @table;

set @sql = N'if object_id(N''[' + @view_schema + N'].['
           + @view
           + ']'', N''V'') is not null drop view ['
           + @view_schema + N'].[' + @view + ']';
set @sql = @sql + N'create view [' + @view_schema + N'].['
           + @view + N'] ' + N' as             
				select ' + @builder + N' from ['
           + @table_schema + N'].[' + @table + N'];';

select @sql; 
