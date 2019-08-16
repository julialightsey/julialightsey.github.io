SELECT [objects].[type_desc]                                                                          AS [type]
       , QUOTENAME([schemas].[name]) + '.'
         + QUOTENAME([objects].[name])                                                                AS [object_name]
       , ( LEN([sql_modules].[definition]) - LEN(REPLACE([sql_modules].[definition], CHAR(10), '')) ) AS [lines_of_code]
FROM   [sys].[sql_modules] AS [sql_modules]
       INNER JOIN [sys].[objects] AS [objects]
               ON [sql_modules].[object_id] = [objects].[object_id]
       INNER JOIN [sys].[schemas] AS [schemas]
               ON [schemas].[schema_id] = [objects].[schema_id];

SELECT sum (LEN([sql_modules].[definition]) - LEN(REPLACE([sql_modules].[definition], CHAR(10), ''))) AS [total_lines_of_code]
       , count(*)                                                                                     AS [total_objects]
FROM   [sys].[sql_modules] AS [sql_modules]
       INNER JOIN [sys].[objects] AS [objects]
               ON [sql_modules].[object_id] = [objects].[object_id]
       INNER JOIN [sys].[schemas] AS [schemas]
               ON [schemas].[schema_id] = [objects].[schema_id]; 
