--
-- find column used in modules
-------------------------------------------------
select object_schema_name([sql_modules].[object_id]) as [schema]
       , object_name([sql_modules].[object_id])      as [method]
       , [sql_modules].[definition]                  as [sql_text]
from   [sys].[sql_modules] as [sql_modules]
where  [sql_modules].[definition] like N'%<find_this_column>%';
--
-- get extended properties
-------------------------------------------------
select object_schema_name([columns].[object_id]) as [schema]
       , object_name([columns].[object_id])      as [object]
       , [columns].[name]                        as [column]
       , type_name([columns].[user_type_id])     as [type]
       , [extended_properties].[name]            as [property]
       , [extended_properties].[value]           as [documentation]
from   [sys].[columns] as [columns]
       left join [sys].[extended_properties] as [extended_properties]
              on [extended_properties].[major_id] = [columns].[object_id]
                 and [extended_properties].[minor_id] = [columns].[column_id]
order  by [columns].[name];

--
-- find tables that do not have a primary key (listed as a HEAP)
-------------------------------------------------
select [schemas].[name]
       , [tables].[name]
       , *
from   sys.indexes as [indexes]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [indexes].[object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [indexes].[type_desc] = N'HEAP';

--
-- find revisions
-------------------------------------------------
with [get_object_list]
     as (select object_schema_name([extended_properties].[major_id]) as [schema]
                , object_name([extended_properties].[major_id])      as [object]
                , cast(right([name]
                             , 6) as [date])                         as [revision_date]
                , [extended_properties].[name]                       as [property]
                , [extended_properties].[value]                      as [value]
         from   [sys].[extended_properties] as [extended_properties]
         where  cast([value] as [nvarchar](max)) like N'%KLightsey@hcpnv.com%'
                and [name] like N'%revision_%')
select [schema]
       , [object]
       , [revision_date]
       , [property]
       , [value]
from   [get_object_list]
order  by [revision_date] desc
          , [schema]
          , [object]; 
