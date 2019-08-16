declare @find_text [sysname] = N'<find_text>';

with [search_sql_text]
     as (select N'['
                + object_schema_name([procedures].[object_id])
                + N'].[' + [procedures].[name] + N']'         as [object]
                , N'sql_text'                                 as [source]
                , object_definition([procedures].[object_id]) as [definition]
         from   [sys].[procedures] as [procedures]
         where  object_definition([procedures].[object_id]) like '%Dm%'
                 or object_definition([procedures].[object_id]) like '%Ft%'),
     [search_procedure_name]
     as (select N'['
                + object_schema_name([procedures].[object_id])
                + N'].[' + [procedures].[name] + N']'         as [object]
                , N'procedure_name'                           as [source]
                , object_definition([procedures].[object_id]) as [definition]
         from   [sys].[procedures] as [procedures]
         where  [procedures].[name] like N'%' + @find_text + '%')
--
select [object]
       , [source]
       , [definition]
from   [search_sql_text]
union
select [object]
       , [source]
       , [definition]
from   [search_procedure_name]
order  by [object]; 
