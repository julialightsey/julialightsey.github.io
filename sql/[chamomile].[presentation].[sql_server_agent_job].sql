--http://www.mssqltips.com/sqlservertip/2561/querying-sql-server-agent-job-information/
--
declare @stack         xml([chamomile].[xsc])
        , @name        [nvarchar](1000) =N'[chamomile].[documentation].[job].[get_change]'
        , @value       [nvarchar](max) = N'64058A26-0DC5-497B-B512-4C4EE1F071F0'
        , @description [nvarchar](max) = N'documentation using both name and job id';
execute [utility].[set_meta_data]
  @name         =@name
  , @value      =@value
  , @description=@description
  , @stack      =@stack output;
select [utility].[get_meta_data](@name);
select *
from   [utility].[get_meta_data_list] (@name);
go
--
--
declare @name [sysname] = N'get_change';
select *
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       left join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
              on [sysjobs].[job_id] = [sysjobsteps].[job_id]
where  [sysjobs].[name] = @name;
--
--
select *
from   [msdb].[dbo].[sysjobsteps] as [sysjobsteps];
--
--
select *
from   [msdb].[dbo].[sysjobs] as [sysjobs] 
