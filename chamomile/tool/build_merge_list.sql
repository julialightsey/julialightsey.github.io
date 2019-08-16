--
-- merge source list
--------------------------------------------------------------------------
DECLARE @list [nvarchar](max);

SELECT @list = COALESCE(@list, N', ', N'') + N'@'
               + [columns].[name] + N' as [' + [columns].[name]
               + N'], '
FROM   [sys].[columns] AS [columns]
WHERE  object_schema_name([columns].[object_id]) = N'<schema>'
       AND object_name([columns].[object_id]) = N'<object>'
ORDER  BY [columns].[name];

SELECT @list AS [source_list];

go

--
-- merge update list
--------------------------------------------------------------------------
DECLARE @list [nvarchar](max);

SELECT @list = COALESCE(@list, N', ', N'') + N'['
               + [columns].[name] + N'] = source.['
               + [columns].[name] + N'], '
FROM   [sys].[columns] AS [columns]
WHERE  object_schema_name([columns].[object_id]) = N'<schema>'
       AND object_name([columns].[object_id]) = N'<object>'
ORDER  BY [columns].[name];

SELECT @list AS [update_list];

GO

--
-- merge VALUES list
--------------------------------------------------------------------------
DECLARE @list1   [nvarchar](max)
        , @list2 nvarchar(max);

SELECT @list1 = COALESCE(@list1 + N', ', N'') + N'@'
                + [columns].[name]
FROM   [sys].[columns] AS [columns]
WHERE  object_schema_name([columns].[object_id]) = N'<schema>'
       AND object_name([columns].[object_id]) = N'<object>'
ORDER  BY [columns].[name];

--
SELECT @list2 = COALESCE(@list2 + N', ', N'') + N'['
                + [columns].[name] + N']'
FROM   [sys].[columns] AS [columns]
WHERE  object_schema_name([columns].[object_id]) = N'<schema>'
       AND object_name([columns].[object_id]) = N'<object>'
ORDER  BY [columns].[name];

SELECT N'USING (VALUES (' + @list1 + N') AS SOURCE('
       + @list2 + N')' AS [values_list];

go 

select N' or ((target.[' + [name] + N'] != source.[' + [name] + N']) or (target.[' + [name] + N'] is null and source.[' + [name] + N'] is not null)  or (source.[' + [name] + N'] is null and target.[' + [name] + N'] is not null))'
from   [sys].[columns] as [columns]
where  object_schema_name([object_id]) = N'<schema>'
       and object_name([object_id]) = N'<object>'
order  by [column_id]; 
go

select N' , target.[' + [name] + N'] = source.[' + [name] + N']'
from   [sys].[columns] as [columns]
where  object_schema_name([object_id]) = N'<schema>'
       and object_name([object_id]) = N'<object>'
order  by [column_id]; 
go
