--
-- get procedure documentation
------------------------------------------------  
declare @schema      [sysname] = N'<schema>',
        @object      [sysname] = N'<object>',
        @html        [nvarchar](max),
        @column_list [nvarchar](max),
        @procedure   [nvarchar](max);

--
set @html = N'<table class="procedure"><tr><th colspan="3"><h1>['
            + @schema + N'].[' + @object + N']</h1></th></tr>'
            + N'<tr><th colspan="3"><h2>'
            + (select [type_desc]
               from   [sys].[objects]
               where  object_schema_name(object_id) = @schema
                      and object_name(object_id) = @object)
            + N'</h2></th></tr></table>';

--
-------------------------------------------------
select @column_list = coalesce(@column_list + N'', N'')
                      + N'<tr><td width="0">' + [parameters].[name]
                      + N' ' + case when type_name([parameters].[system_type_id]) = N'nvarchar' then case when [parameters].[max_length] = -1 then N'[nvarchar](max)' else N'[nvarchar](' + cast([parameters].[max_length] as [sysname]) + N')' end else N'[' + type_name([parameters].[system_type_id]) + N']' end + case when columnproperty (object_id, [parameters].[name], N'IsOutParam') = 1 then N' output' else N'' end + N'</td>' + N'<td>'
                      + isnull([extended_properties].[name], N'')
                      + N'</td>' + N'<td>'
                      + cast(isnull([extended_properties].[value], N'') as [sysname])
                      + N'</td></tr>'
from   [sys].[parameters] as [parameters]
       left join [sys].[extended_properties] as [extended_properties]
              on [extended_properties].[major_id] = [parameters].[object_id]
                 and [parameters].[parameter_id] = [extended_properties].[minor_id]
where  object_schema_name(object_id) = @schema
       and object_name(object_id) = @object
       and [parameters].[parameter_id] > 0
order  by [parameters].[parameter_id];

--
select N'<div>' + @html
       + N'<details><summary>column documentation</summary>'
       + N'<table class="procedure"><tr><th>parameter</th><th>property</th><th>value</th></tr>'
       + @column_list + N'</table></details>'
       + N'</table></div>'; 
