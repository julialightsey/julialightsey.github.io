/*
select [utility].[get_meta_data](@test_type_meta_data);

*/
declare @error_stack xml([chamomile].[xsc]);
declare @pass_meta_data          [nvarchar](1000)= N'[chamomile].[result].[default].[pass]'
        , @fail_meta_data        [nvarchar](1000)= N'[chamomile].[result].[default].[fail]'
        , @invalid_meta_data     [nvarchar](1000)= N'[chamomile].[invalid].[meta_data]'
        , @invalid_prototype     [nvarchar](1000)= N'[chamomile].[invalid].[prototype]'
        , @utility_xsc_prototype [nvarchar](1000)= N'[chamomile].[xsc].[stack].[prototype]'
        , @test_prototype        [nvarchar](1000)= N'[chamomile].[test].[stack].[prototype]'
        , @pass                  [sysname]
        , @fail                  [sysname]
        , @invalid               [sysname]
		, @invalid_xml [xml]
        , @stack_builder         [xml]
        , @test                  [xml]
        , @message               [nvarchar](max);
select @pass = [utility].[get_meta_data](@pass_meta_data)
       , @fail = [utility].[get_meta_data](@fail_meta_data)
       , @invalid = [utility].[get_meta_data](@invalid_meta_data)
       , @stack_builder = [utility].[get_prototype](@utility_xsc_prototype).query(N'/*/*[2]')
       , @test = [utility].[get_prototype](@test_prototype);
set @error_stack = isnull(@error_stack, (select [data].query(N'/*/*[2]')
                                         from   [repository].[get](null, @utility_xsc_prototype)));
--
-- validate meta data and prototypes
-------------------------------------------------
set @message = null;
with [invalid_data_finder]
     as (select [value], [prototype]
         from   ( values 
			(@fail, @fail_meta_data),
            (cast( @invalid_xml as [nvarchar](max)), @invalid_prototype)
		) as [invalid_data] ([value], [prototype]))
select @message = coalesce(@message, N'', N'') + [prototype]
                  + N', '
from   [invalid_data_finder]
where  [value] is null;
if @message is not null
  select left(@message, len(@message) - 1);
else
  select N'no invalid data'; 
