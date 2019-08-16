--
-- http://www.sommarskog.se/query-plan-mysteries.html#tableandindexdefs
-------------------------------------------------
DECLARE @tbl NVARCHAR(265);

SELECT @tbl = '<table_name>';

SELECT [o].[name]
       , [i].[index_id]
       , [i].[name]
       , [i].[type_desc]
       , SUBSTRING([ikey].[cols]
                   , 3
                   , LEN([ikey].[cols])) AS [key_cols]
       , SUBSTRING([inc].[cols]
                   , 3
                   , LEN([inc].[cols]))  AS [included_cols]
       , STATS_DATE([o].[object_id]
                    , [i].[index_id])    AS [stats_date]
       , [i].[filter_definition]
FROM   [sys].[objects] [o]
       JOIN [sys].[indexes] [i]
         ON [i].[object_id] = [o].[object_id]
       CROSS APPLY (SELECT ', ' + [c].[name] + CASE [ic].[is_descending_key] WHEN 1 THEN ' DESC' ELSE '' END
                    FROM   [sys].[index_columns] [ic]
                           JOIN [sys].[columns] [c]
                             ON [ic].[object_id] = [c].[object_id]
                                AND [ic].[column_id] = [c].[column_id]
                    WHERE  [ic].[object_id] = [i].[object_id]
                           AND [ic].[index_id] = [i].[index_id]
                           AND [ic].[is_included_column] = 0
                    ORDER  BY [ic].[key_ordinal]
                    FOR XML PATH('')) AS [ikey] ( [cols] )
       OUTER APPLY (SELECT ', ' + [c].[name]
                    FROM   [sys].[index_columns] [ic]
                           JOIN [sys].[columns] [c]
                             ON [ic].[object_id] = [c].[object_id]
                                AND [ic].[column_id] = [c].[column_id]
                    WHERE  [ic].[object_id] = [i].[object_id]
                           AND [ic].[index_id] = [i].[index_id]
                           AND [ic].[is_included_column] = 1
                    ORDER  BY [ic].[index_column_id]
                    FOR XML PATH('')) AS [inc] ( [cols] )
WHERE  [o].[name] = @tbl
       AND [i].[type] IN ( 1, 2 )
ORDER  BY [o].[name]
          , [i].[index_id]; 
