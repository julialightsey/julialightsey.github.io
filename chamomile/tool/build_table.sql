/*

*/
declare @list [nvarchar](max);

select @list = coalesce(@list + N', ', N'') + N'['
               + [columns].[name] + N'] ['
               + type_name([columns].[user_type_id]) + N']'
               +
               --
               case
               --
               when type_name([columns].[user_type_id]) =N'varchar' then N'(' + cast([columns].[max_length]as [sysname]) + N')'
               --
               when type_name([columns].[user_type_id]) =N'decimal' then N'(' + cast([columns].[precision]as [sysname]) +N', ' + cast([columns].[scale] as [sysname])+ N')'
               --
               else N''
               --
               end
from   sys.[columns] as [columns]
where  object_schema_name(object_id) = N'report'
       and object_name(object_id) = N'claimHeader'
order  by [columns].[name];

select @list; 
