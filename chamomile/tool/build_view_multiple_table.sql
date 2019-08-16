SELECT N', ' + quotename([tables].[name]) + N'.'
       + quotename([columns].[name]) + N' AS '
       + quotename([columns].[name])
FROM   [sys].[columns] AS [columns]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [columns].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
WHERE  [schemas].[name] IN ( N'dbo' )
       AND [tables].[name] IN ( N'table_01', N'table_01', N'table_nn' )
       AND [columns].[name] NOT IN ( N'<do not include this column name>' )
ORDER  BY [columns].[name]; 
