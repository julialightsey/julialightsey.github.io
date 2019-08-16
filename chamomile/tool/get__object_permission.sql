-- Query [sys].database_permissions to see applicable permissions
select [database_permissions].[class_desc]        as [class_desc]
       , [schemas].[name]                         as [schema]
       , [objects].[name]                         as [object]
       , [database_permissions].[permission_name] as [permission_name]
       , [database_permissions].[state_desc]      as [state_desc]
       , [database_principals].[name]             as [user]
       , [database_principals].*
from   [sys].[database_permissions] as [database_permissions]
       join [sys].[database_principals] as [database_principals]
         on [database_permissions].[grantee_principal_id] = [database_principals].[principal_id]
       join [sys].[objects] as [objects]
         on [database_permissions].[major_id] = [objects].[object_id]
       join [sys].[schemas] as [schemas]
         on [objects].[schema_id] = [schemas].[schema_id]
where  [database_permissions].[class_desc] = 'OBJECT_OR_COLUMN'
union all
select [database_permissions].[class_desc]        as [class_desc]
       , [schemas].[name]                         as [schema]
       , '-----'                                  as [object]
       , [database_permissions].[permission_name] as [permission_name]
       , [database_permissions].[state_desc]      as [state_desc]
       , [database_principals].[name]             as [user]
       , [database_principals].*
from   [sys].[database_permissions] [database_permissions]
       join [sys].[database_principals] [database_principals]
         on [database_permissions].[grantee_principal_id] = [database_principals].[principal_id]
       join [sys].[schemas] [schemas]
         on [database_permissions].[major_id] = [schemas].[schema_id]
where  [database_permissions].[class_desc] = 'SCHEMA'
order  by [schema]
          , [object]
		  , [state_desc]
          , [permission_name]; 
