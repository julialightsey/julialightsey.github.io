/*
	--
	--	description
	---------------------------------------------
		List all tables in a database along with sizes.
		If you want to separate table space from index space, you need to use AND i.index_id IN (0,1) 
			for the table space (index_id = 0 is the heap space, index_id = 1 is the size of the 
			clustered index = data pages) and AND i.index_id > 1 for the index-only space
-- sys.allocation_units (Transact-SQL) https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-allocation-units-transact-sql
-- Understanding Pages and Extents https://technet.microsoft.com/en-us/library/ms190969(v=sql.105).aspx
*/
SELECT [schemas].[name]                                                                       AS [schema]
       , [tables].[name]                                                                      AS [table]
       , [partitions].[rows]                                                                  AS [row_count]
       , SUM([allocation_units].[total_pages]) * 8                                            AS [total_space_kb]
                , SUM([allocation_units].[total_pages]) / 128                                          AS [total_space_mb]
                , SUM([allocation_units].[total_pages]) / 128 / 1024                                   AS [total_space_gb]
       , SUM([allocation_units].[used_pages]) * 8                                             AS [used_space_kb]
       , ( SUM([allocation_units].[total_pages]) - SUM([allocation_units].[used_pages]) ) * 8 AS [unused_space_kb]
FROM   [sys].[tables] AS [tables]
       INNER JOIN [sys].[schemas] AS [schemas]
               ON [schemas].[schema_id] = [tables].[schema_id]
       INNER JOIN [sys].[indexes] AS [indexes]
               ON [tables].[object_id] = [indexes].[object_id]
       INNER JOIN [sys].[partitions] AS [partitions]
               ON [indexes].[object_id] = [partitions].[object_id]
                  AND [indexes].[index_id] = [partitions].[index_id]
       INNER JOIN [sys].[allocation_units] AS [allocation_units]
               ON [partitions].[partition_id] = [allocation_units].[container_id]
WHERE  [tables].[name] NOT LIKE 'dt%'
       AND [tables].[is_ms_shipped] = 0
       AND [indexes].[object_id] > 255
GROUP  BY [schemas].[name]
          , [tables].[name]
          , [partitions].[rows]
--ORDER  BY SUM([allocation_units].[total_pages]) * 8;
ORDER  BY [schemas].[name]
          , [tables].[name];
--ORDER  BY [row_count] DESC; 


--
-- temp tables
-------------------------------------------------
SELECT [tables].[name]                                               AS [table]
       , [dm_db_partition_stats].[row_count]                         AS [row_count]
       , [dm_db_partition_stats].[used_page_count] * 8               AS [used_size_kb]
       , [dm_db_partition_stats].[used_page_count] * 8 / 1024.00     AS [used_size_mb]
       , [dm_db_partition_stats].[reserved_page_count] * 8           AS [reserved_size_kb]
       , [dm_db_partition_stats].[reserved_page_count] * 8 / 1024.00 AS [reserved_size_mb]
FROM   [tempdb].[sys].[partitions] AS [partitions]
       INNER JOIN tempdb.[sys].[dm_db_partition_stats] AS [dm_db_partition_stats]
               ON [partitions].[partition_id] = [dm_db_partition_stats].[partition_id]
                  AND [partitions].[partition_number] = [dm_db_partition_stats].[partition_number]
       INNER JOIN tempdb.[sys].[tables] AS [tables]
               ON [dm_db_partition_stats].[object_id] = [tables].[object_id]
ORDER  BY [tables].[name]; 
