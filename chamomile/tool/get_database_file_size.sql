if object_id(N'tempdb..##builder', N'U') is not null
  drop table ##builder;

go

create table ##builder
  (
     [database]        sysname
     , [name]          sysname
     , [type_desc]     nvarchar(40)
     , [physical_name] nvarchar(max)
     , [size]          int
     , [max_size]      int
     , [growth]        int
  );

insert into ##builder
            ([database]
             , [name]
             , [type_desc]
             , [physical_name]
             , [size]
             , [max_size]
             , [growth])
select [databases].[name]
       , [master_files].[name]
       , [master_files].[type_desc]
       , [master_files].[physical_name]
       , [master_files].[size]
       , [master_files].[max_size]
       , [master_files].[growth]
from   [sys].[master_files] as [master_files]
       join [sys].[databases] as [databases]
         on [databases].[database_id] = [master_files].[database_id]
where  [databases].[database_id] > 4;

select [database]                                                                                     as [database]
       , [name]                                                                                       as [file_name]
       , [type_desc]                                                                                  as [type_desc]
       , [physical_name]                                                                              as [physical_name]
       , format(cast(cast([size] as decimal(16, 2)) * 8 / 1024 as decimal(16, 3)), N'###,###,###.00') as [size_mb]
       , format(case
                  when [max_size] = -1 then [max_size]
                  else cast(cast([max_size] as decimal(16, 2)) * 8 / 1024 as decimal(16, 3))
                end, N'###,###,###.##')                                                               as [max_size_mb]
       , format([growth], N'###,###,###')                                                             as [growth]
from   ##builder
order  by [size] desc
          , [database]
          , [name]
          , [physical_name]; 
