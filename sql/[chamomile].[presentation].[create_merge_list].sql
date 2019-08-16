/*

*/
--
-- merge source list
--------------------------------------------------------------------------
declare @list [nvarchar](max);

select @list = coalesce(@list, N', ', N'') + N'@'
               + [columns].[name] + N' as [' + [columns].[name]
               + N'], '
from   [sys].[columns] as [columns]
where  object_schema_name([columns].[object_id]) = N'letter_secure'
       and object_name([columns].[object_id]) = N'interface'
order  by [columns].[name];

select @list; 

--
-- merge update list
--------------------------------------------------------------------------
declare @list [nvarchar](max);

select @list = coalesce(@list, N', ', N'') + N'['
               + [columns].[name] + N'] = source.[' + [columns].[name]
               + N'], '
from   [sys].[columns] as [columns]
where  object_schema_name([columns].[object_id]) = N'letter_secure'
       and object_name([columns].[object_id]) = N'interface'
order  by [columns].[name];

select @list; 
