use [chamomile];

go

-- 
--------------------------------------------------------------------------
if schema_id(N'administration') is null
  execute (N'create schema administration');

go

if object_id(N'[administration].[get_query_performance]'
             , N'P') is not null
  drop procedure [administration].[get_query_performance];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'get_query_performance';
	--
	-------------------------------------------------
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end + case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  
					then N' output'
					else N'' end
		end                                                                     as [object]
       ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
			else N'PARAMETER'
        end                                                                     as [type]
		   ,[extended_properties].[name]                                        as [property]
		   ,[extended_properties].[value]                                       as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and [objects].[name]=@object
	order  by [parameters].[parameter_id],[object],[type],[property]; 
*/
create procedure [administration].[get_query_performance] @log        [bit]=0
                                                          , @identity [int] = null output
                                                          , @output   [xml] = null output
as
  begin
      declare @category    [sysname] = object_schema_name(@@procid),
              @class       [sysname]=object_name(@@procid),
              @type        [sysname]=N'@output',
              @description [nvarchar](max) = N'logged output';

      select @output = (select cast(cume_dist()
                                      over (
                                        order by [total_elapsed_time])as decimal (5, 2))   as [cumulative_distribution]
                               , cast(percent_rank()
                                        over (
                                          order by [total_elapsed_time])as decimal (5, 2)) as [percent_rank]
                               , *
                        from   [sys].[dm_exec_query_stats]
                               cross apply [sys].[dm_exec_sql_text](sql_handle) as [sql_text]
                        order  by [cumulative_distribution] desc
                        for xml path(N'query'), root (N'query_list'));

      if @log = 1
        begin
            execute [log].[set]
              @category=@category,
              @class=@class,
              @type=N'@output',
              @entry=@output,
              @description=N'logged output',
              @identity=@identity output;
        end;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'todo'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'todo',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'todo',
  @value = N'1) Get license from metadata.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'license'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'license',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'license',
  @value = N'All content is copyright Katherine E. Lightsey (http://www.KELightsey.com) 1959-2015 (aka; my life), 
	all rights reserved. 
  All software contained herein is licensed as [chamomile] (http://www.ChamomileSQL.com/license.html) and as open 
	source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Identify and (optionally) log query performance to allow analysis. Using cume_dist() 
	and percent_rank()to identify worst performing queries.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150801'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150801',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150801',
  @value = N'KELightsey@gmail.com – Created as a procedure and added logging.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20140804'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140804',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'KELightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_administration'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_administration',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'package_administration',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'release_00.93.00'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'release_00.93.00',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
	declare @output [xml], @identity [int];
	execute [administration].[get_query_performance] @log=1, @output=@output output, @identity=@identity output;
	select @output as [output], @identity as [identity];
	select * from [log].[data] where [id] = @identity;',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , N'parameter'
                                          , N'@log'))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance',
    @level2type = N'parameter',
    @level2name = N'@log';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@log [bit]=0 - if 1, log the output',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance',
  @level2type = N'parameter',
  @level2name = N'@log';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , N'parameter'
                                          , N'@identity'))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance',
    @level2type = N'parameter',
    @level2name = N'@identity';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@identity [int] = null output - returns the identity column of the logged object, if logged.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance',
  @level2type = N'parameter',
  @level2name = N'@identity';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_query_performance'
                                          , N'parameter'
                                          , N'@output'))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_query_performance',
    @level2type = N'parameter',
    @level2name = N'@output';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@output   [xml] = null output - returns the output of the procedure. If logged, inserted into the [log].[entry].',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_query_performance',
  @level2type = N'parameter',
  @level2name = N'@output';

go 
