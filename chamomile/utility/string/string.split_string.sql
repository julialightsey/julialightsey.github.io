use [chamomile];

go

if exists (select *
           from   sys.objects
           where  object_id = object_id(N'[utility].[split_string]')
                  and type in ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  drop function [utility].[split_string];

go

set ansi_nulls on;

go

set quoted_identifier on;

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------
		
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	declare @schema   [sysname] = N'utility'
			, @object [sysname] = N'split_string';

	select [schemas].[name]
		   , [objects].[name]
		   , [extended_properties].[name]
		   , [extended_properties].[value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id] = [extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [objects].[schema_id] = [schemas].[schema_id]
	where  [schemas].[name] = @schema
		   and [objects].[name] = @object; 
		   
	select * from [utility].[split_string](N'"this"."string"."gets"."split"."and"."removes"."leading"."and"."trailing"."quotes"', N'"."', N'"', N'"');
	select * from [utility].[split_string](N'"this"."string"."gets"."split"."but"."leaves"."leading"."and"."trailing"."quotes"', N'"."', null, null);
	select * from [utility].[split_string](N'[netbios_name].[machine_name].[instance].[database].[schema].[table].[column]', N'].[', N'[', N']');
	
	Jeff Moden
Senior DBA and T-SQL Mentor at Proctor Financial

No Ma'am. No casting of stones. It would only be suggestions backed up with code like I tried to make previously. Since YAGNI is in full swing for you and you already know the ramifications of such a principle, I'll forgo the suggestions for performance. 

I am, however, duty bound to forewarn you that your code, as it is currently written, won't handle spaces for delimiters nor will it handle over 100 elements. If you only fix the recursion limit (an easy fix, for sure), be careful not to use "0" for the recursion limit because if someone accidently uses a space for the delimiter, the code will loop forever. 

Also be aware that the leading and trailing deletion characters don't actually do what I believe you intended them to. They don't work by character. They only work by number of characters. For example, if leading and trailing double quotes are expected but don't appear, then the first character of the first element will be obliterated as will the last character of the last element. 

Of course, you have an esoteric use for this function. I just hope that someone else doesn't use it (because of the generic name) for a different purpose that may not fit the function. 

Thank you for sharing your code. It IS interesting that you thought of getting rid of leading and trailing characters and you've given me some ideas.

see [utility_test].[strip_lead_and_lag]
*/
create function [utility].[split_string] (@input       [nvarchar](max)
                                          , @separator [sysname]
                                          , @lead      [sysname]
                                          , @lag       [sysname])
returns @node_list table (
  [index] [int],
  [node]  [nvarchar](max))
  begin
      declare @separator_length [int]= len(@separator),
              @lead_length      [int] = isnull(len(@lead)
                       , 0),
              @lag_length       [int] = isnull(len(@lag)
                       , 0);

      --
      set @input = right(@input
                         , len(@input) - @lead_length);
      set @input = left(@input
                        , len(@input) - @lag_length);

      --
      with [splitter]([index], [starting_position], [start_location])
           as (select cast(@separator_length as [bigint])
                      , cast(1 as [bigint])
                      , charindex(@separator
                                  , @input)
               union all
               select [index] + 1
                      , [start_location] + @separator_length
                      , charindex(@separator
                                  , @input
                                  , [start_location] + @separator_length)
               from   [splitter]
               where  [start_location] > 0)
      --
      insert into @node_list
                  ([index],
                   [node])
      select [index] - @separator_length as [index]
             , substring(@input
                         , [starting_position]
                         , case
                             when [start_location] > 0 then [start_location] - [starting_position]
                             else len(@input)
                           end)          as [node]
      from   [splitter];

      --
      return;
  end;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'split_string'
                                            , N'PARAMETER'
                                            , N'@input'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'split_string',
    @level2type=N'PARAMETER',
    @level2name=N'@input'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@input nvarchar(max) - The string to split.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'split_string',
  @level2type=N'PARAMETER',
  @level2name=N'@input'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'split_string'
                                            , N'PARAMETER'
                                            , N'@separator'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'split_string',
    @level2type=N'PARAMETER',
    @level2name=N'@separator'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@separator char(1) - The character on which to split the string.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'split_string',
  @level2type=N'PARAMETER',
  @level2name=N'@separator'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'[utility].[split_string] splits a string based on a single character value and returns a table with the nodes. [utility].[split_string] is based on code I found at http://stackoverflow.com/questions/2647/split-string-in-sql. While I have taken it and refactored it to match the standards I use in Chamomile, credit should go to the original author for the design. [bigint] is used as previous version would fail for input string longer than 4000 chars. This version takes care of the limitation:',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'split_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'<ol>
		<li>select [index],[node] from [utility].[split_string] (N''aa.aba.ac'', N''.'');</li>
		<li>select [index],[node] from [utility].[split_string] (N''254-372-4569, (817) 956-3259, +052 1234 5678'', N'','');</li>
		<li>select [index],[node] from [utility].[split_string] (N''12.0.2000.8'', N''.'');</li>
	</ol>',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'split_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'get_license'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'get_license',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'get_license',
  @value =N'select [chamomile].[utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'split_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140706'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'function'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140706',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'function',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140706',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'function',
  @level1name=N'split_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'function'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'function',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'function',
  @level1name=N'split_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.92.00'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'function'
                                            , N'split_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.92.00',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'function',
    @level1name=N'split_string'

go

exec sys.sp_addextendedproperty
  @name =N'release_00.92.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'function',
  @level1name=N'split_string'

go 
