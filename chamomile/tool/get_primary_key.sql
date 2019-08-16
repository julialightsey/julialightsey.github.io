/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		List all primary keys in a database along with the associated foreign keys from other tables.



	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	---------------------------------------------

*/
with [top]
     as (select N'['
                + isnull(convert([sysname], serverproperty(N'ComputerNamePhysicalNetBIOS')), N'default')
                + N'].['
                + isnull(convert([sysname], serverproperty(N'MachineName')), N'default')
                + N'].['
                + isnull(convert([sysname], serverproperty(N'InstanceName')), N'default')
                + N'].[' + db_name() + N'].[' + [schemas].[name]
                + N'].[' + [referenced_table].[name] + N'].['
                + [referenced_column].[name] + N']' as [fqn]
                , count(*)                          as [count]
         from   [sys].[foreign_keys] [foreign_keys]
                join [sys].[foreign_key_columns] as [foreign_key_columns]
                  on [foreign_keys].[object_id] = [foreign_key_columns].constraint_object_id
                join [sys].[columns] [referencing_column]
                  on [foreign_key_columns].constraint_column_id = [referencing_column].column_id
                     and [foreign_key_columns].parent_object_id = [referencing_column].[object_id]
                join [sys].[columns] [referenced_column]
                  on [foreign_key_columns].referenced_column_id = [referenced_column].column_id
                     and [foreign_key_columns].referenced_object_id = [referenced_column].[object_id]
                join [sys].[tables] as [referencing_table]
                  on [referencing_table].[object_id] = [foreign_keys].[parent_object_id]
                join [sys].[tables] as [referenced_table]
                  on [referenced_table].[object_id] = [referenced_column].[object_id]
                join [sys].[schemas] as [schemas]
                  on [schemas].[schema_id] = [referenced_table].[schema_id]
         group  by [referenced_column].[name]
                   , [referenced_table].[name]
                   , [schemas].[name]),
     [weight]
     as (select cast(sum([count]) as [decimal](20, 4)) as [sum]
         from   [top])
select [top].[fqn]                                   as [fqn]
       , [top].[count]                               as [count]
       , [weight].[sum]                              as [sum]
       , 100 * [top].[count] / [sum]                 as [percent]
       , ntile(5)
           over (
             order by (100 * [top].[count] / [sum])) as [ntile]
       , rank()
           over (
             order by (100 * [top].[count] / [sum])) as [rank]
       , dense_rank()
           over (
             order by (100 * [top].[count] / [sum])) as [dense_rank]
from   [top]
       cross join [weight]
order  by [ntile] desc
          , [top].[count] desc;

select [schemas].[name]   as [schema]
       , [tables].[name]  as [table]
       , [columns].[name] as [column]
       , [indexes].[name] as [index]
       , [types].[name]   as [type]
from   sys.indexes as [indexes]
       inner join [sys].[index_columns] as [index_columns]
               on [indexes].[object_id] = [index_columns].[object_id]
                  and [indexes].index_id = [index_columns].index_id
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [index_columns].[object_id]
       join [sys].[columns] as [columns]
         on [columns].[object_id] = [tables].[object_id]
            and [columns].[column_id] = [index_columns].[column_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
       join [sys].[types] as [types]
         on [types].[user_type_id] = [columns].[user_type_id]
where  [indexes].[is_primary_key] = 1;

go 
