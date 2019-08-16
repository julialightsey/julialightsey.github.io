/*
	Returns foreign key references in the current database.
*/
select N'['
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
            and [foreign_key_columns].[referenced_object_id] = [referenced_column].[object_id]
order  by [referenced_object]
          , [referencing_object];

select *
from   information_schema.referential_constraints; 

-- https://blog.sqlauthority.com/2013/04/29/sql-server-disable-all-the-foreign-key-constraint-in-database-enable-all-the-foreign-key-constraint-in-database/
-- Disable all the constraint in database
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- Enable all the constraint in database
EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"
