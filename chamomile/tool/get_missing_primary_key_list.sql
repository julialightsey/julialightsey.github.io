/*
	Find tables that do not have primary keys
*/
select [schemas].[name]  as [schema]
       , [tables].[name] as [table]
from   [sys].[tables] as [tables]
       inner join [sys].[schemas] as [schemas]
               on [tables].[schema_id] = [schemas].[schema_id]
where  [tables].[type] = 'U'
       and not exists (select [key_constraints].[name]
                       from   [sys].[key_constraints] as [key_constraints]
                       where  [key_constraints].[parent_object_id] = [tables].[object_id]
                              and [key_constraints].[schema_id] = [schemas].[schema_id]
                              and [key_constraints].[type] = 'PK')

go 
