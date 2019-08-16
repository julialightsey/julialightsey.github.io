/* 
	All content is licensed as [chamomile] (http://www.KELightsey.com/license.html) and  
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
	--------------------------------------------- 

	-- 
	--  description 
	--------------------------------------------- 
	This query shows all tables and row counts for the current database.

	-- 
	--  parameters 
	--------------------------------------------- 
	@is_ms_shipped [int] = null - set to 0 for only user tables.
	@index_id      [int] = 2	- defaults to 2 for only clustered indexes and heaps
		(actual tables). A value for [indexes].[index_id] of 2 or greater indicates
		a different type of index, therefore not actually a table.

	-- 
	--  notes 
	--------------------------------------------- 
	this presentation is designed to be run incrementally a code block at a time.  
	code blocks are delineated as: 

    -- 
    -- code block begin 
    ----------------------------------------- 
       
    ----------------------------------------- 
    -- code block end 
    -- 

  -- 
  -- references 
  --------------------------------------------- 
	sys.indexes (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms173760.aspx
	sys.dm_db_partition_stats (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms187737.aspx
*/
-- 
-- code block begin 
-------------------------------------------------
declare @is_ms_shipped [int] = null
        , @index_id    [int] = 2;

select [schemas].[name]                      as [schema]
       , [objects].[name]                    as [object]
       , [dm_db_partition_stats].[row_count] as [row_count]
       , case
           when [indexes].[index_id] = 0 then N'heap'
           when [indexes].[index_id] = 1 then N'clustered_index'
           else N'non_clustered_index'
         end                                 as [table_type]
       , [indexes].[index_id]                as [index_id]
from   sys.[indexes] as [indexes]
       inner join [sys].[objects] as [objects]
               on [indexes].[object_id] = [objects].[object_id]
       inner join [sys].[schemas] as [schemas]
               on [schemas].[schema_id] = [objects].[schema_id]
       inner join [sys].[dm_db_partition_stats] as [dm_db_partition_stats]
               on [indexes].[object_id] = [dm_db_partition_stats].[object_id]
                  and [indexes].[index_id] = [dm_db_partition_stats].[index_id]
where  ( ( [indexes].[index_id] < @index_id )
          or ( @index_id is null ) )
       and ( ( [objects].[is_ms_shipped] = @is_ms_shipped )
              or ( @is_ms_shipped is null ) )
       and [schemas].[name] not in ( N'sys' )
order  by [row_count] desc
          , [objects].[name];
-------------------------------------------------
-- code block end 
-- 
