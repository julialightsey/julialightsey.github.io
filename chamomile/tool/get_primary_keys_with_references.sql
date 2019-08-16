/*
	--
	--	description
	---------------------------------------------
	List all primary keys in a database along with the associated foreign keys from other tables.
*/
with [get_primary_keys]
     as (select N'['
                + object_schema_name([columns].[object_id])
                + N'].[' + [tables].[name] + N'].['
                + [columns].[name] + N']' as [primary_key]
                , [indexes].[name]        as [index]
                , [types].[name]          as [type]
         from   [sys].[indexes] as [indexes]
                inner join [sys].[index_columns] as [index_columns]
                        on [indexes].[object_id] = [index_columns].[object_id]
                           and [indexes].index_id = [index_columns].index_id
                join [sys].[tables] as [tables]
                  on [tables].[object_id] = [index_columns].[object_id]
                join [sys].[columns] as [columns]
                  on [columns].[object_id] = [tables].[object_id]
                     and [columns].[column_id] = [index_columns].[column_id]
                join [sys].[types] as [types]
                  on [types].[user_type_id] = [columns].[user_type_id]
         where  [indexes].[is_primary_key] = 1),
     [get_foreign_keys]
     as (select N'['
                + object_schema_name([referenced_column].[object_id])
                + N'].['
                + object_name([referenced_column].[object_id])
                + N'].[' + [referenced_column].[name] + N']' as [referenced_object]
                , N'['
                  + object_schema_name([foreign_keys].[parent_object_id])
                  + N'].['
                  + object_name([foreign_keys].[parent_object_id])
                  + N'].[' + [referencing_column].[name] + N'].['
                  + object_name([foreign_key_columns].[constraint_object_id])
                  + N']'                                     as [referencing_object]
         from   [sys].[foreign_keys] as [foreign_keys]
                --
                join [sys].[foreign_key_columns] as [foreign_key_columns]
                  on [foreign_keys].[object_id] = [foreign_key_columns].[constraint_object_id]
                --
                join [sys].[columns] as [referencing_column]
                  on [foreign_key_columns].[parent_column_id] = [referencing_column].[column_id]
                     and [foreign_key_columns].[parent_object_id] = [referencing_column].[object_id]
                --
                join [sys].[columns] as [referenced_column]
                  on [foreign_key_columns].[referenced_column_id] = [referenced_column].[column_id]
                     and [foreign_key_columns].[referenced_object_id] = [referenced_column].[object_id])
select [primary_key].[primary_key]
       , [primary_key].[index]
       , [primary_key].[type]
       , [foreign_key].[referencing_object] as [foreign_key]
from   [get_primary_keys] as [primary_key]
       left join [get_foreign_keys] as [foreign_key]
              on [foreign_key].[referenced_object] = [primary_key].[primary_key]
order  by [primary_key];

go 
