/*
	last contract from premiums, match to mg table
*/
with [get_last_premium_record]
     as (select [contract_number]
                , [effective_date]
         from   (select [contract_number]
                        , [effective_date]
                        , row_number()
                            over (
                              partition by [contract_number]
                              order by [effective_date] desc) as [row_number]
                 from   [dbo].[premiums]) as [premiums]
         where  [row_number] = 1)
select *
from   [dbo].[member_grievance] as [member_grievance]
       join [get_last_premium_record]
         on [member_grievance].[contract_number] = [get_last_premium_record].[contract_number]
where  grievance_type = 'G'
       and closedate >= '01/01/2014'
       and closedate <= '03/31/2014';

select [contract_number] as [contract_number]
       , [company]       as [company]
from   [dbo].[premiums]
group  by grouping sets (( [contract_number], [company] ));

select case
         when [flower] is null then N'total'
         else [flower]
       end        as [flower]
       , case
           when [color] is null then 'total'
           else [color]
         end      as [color]
       , count(*) as [count]
from   ##flowers
group  by grouping sets (( [flower], [color] )) 
