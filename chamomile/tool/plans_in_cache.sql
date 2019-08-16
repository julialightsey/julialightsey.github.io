SELECT qs.plan_handle
       , a.attrlist
FROM   sys.dm_exec_query_stats qs
       CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) est
       CROSS APPLY (SELECT epa.attribute + '='
                           + CONVERT(NVARCHAR(127), epa.value) + '   '
                    FROM   sys.dm_exec_plan_attributes(qs.plan_handle) epa
                    WHERE  epa.is_cache_key = 1
                    ORDER  BY epa.attribute
                    FOR XML PATH('')) AS a(attrlist)
WHERE  est.objectid = object_id ('<procedure>')
       AND est.dbid = db_id('<database>') 
