use [chamomile];

go

declare @first_work_day_of_period  [datetime] = N'20180714'
        , @last_work_day_of_period [datetime] = dateadd(second, -1, current_timestamp)
        , @client                  [sysname] = N'<client>';

select convert([date], [start])                                        as [date]
       , convert([nvarchar](max), [entry].query(N'(/*/entry/text())')) as [entry]
from   [chamomile].[work__secure].[log]
where  [client] = @client
       and [start] between @first_work_day_of_period and @last_work_day_of_period;

select [id]
       , [start]
       , [end]
       , cast(cast(datediff(minute, [start], coalesce([end], current_timestamp)) as float) / 60 as [decimal](16, 2)) as [logged_time]
       , [entry]
from   [chamomile].[work__secure].[log]
where  [client] = @client
       and [start] between @first_work_day_of_period and @last_work_day_of_period;

select cast([start] as date)                                                                                              as [date]
       , sum(cast(cast(datediff(minute, [start], coalesce([end], current_timestamp)) as float) / 60 as [decimal](16, 2))) as [logged_time]
from   [chamomile].[work__secure].[log]
where  [client] = @client
       and [start] between @first_work_day_of_period and @last_work_day_of_period
group  by cast([start] as date);

select sum(cast(cast(datediff(minute, [start], coalesce([end], current_timestamp)) as float) / 60 as [decimal](16, 2))) as [total_hours]
from   [chamomile].[work__secure].[log]
where  [client] = @client
       and [start] between @first_work_day_of_period and @last_work_day_of_period; 
