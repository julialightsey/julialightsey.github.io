use [chamomile];

go

if schema_id(N'utility') is null
  execute (N'create schema utility');

go

if object_id(N'[utility].[strip_string]'
             , N'FN') is not null
  drop function [utility].[strip_string];

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
			, @object [sysname] = N'strip_string';
    select [schemas].[name]                as [schema]
           , [objects].[name]              as [object]
           , [extended_properties].[name]  as [property]
           , [extended_properties].[value] as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[objects] as [objects]
             on [objects].[object_id] = [extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [objects].[schema_id] = [schemas].[schema_id]
    where  [schemas].[name] = @schema
           and [objects].[name] = @object; 
*/
create function [utility].[strip_string](@input    [nvarchar](max)
                                         , @filter [sysname]
                                         , @prefix [sysname]
                                         , @remove [bit] = 0)
returns [nvarchar](max)
as
  begin
      --
      -- handle prefix ignore
      --------------------------------------------------------------------
      if ( substring(@input
                     , 0
                     , len(@prefix) + 1) = @prefix )
        set @input = substring(@input
                               , len(@prefix) + 1
                               , len(@input));

      --
      -- if (@remove = 1) remove characters from @input that exist in @filter
      -- if (@remove = 0) leave only characters from @input that exist in @filter
      --------------------------------------------------------------------
      if ( @remove = 1 )
        set @filter = '%[' + @filter + ']%'
      else
        set @filter = N'%[^' + @filter + N']%';

      --
      --------------------------------------------------------------------
      while patindex(@filter
                     , @input) > 0
        set @input = stuff(@input
                           , patindex(@filter
                                      , @input)
                           , 1
                           , '');

      --
      -- replace prefix if required
      --------------------------------------------------------------------
      if ( @prefix is not null )
        set @input=@prefix + @input;

      return @input;
  end

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](null, N''[chamomile].[documentation].[[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'If (@remove = 1) remove characters from @input that exist in @filter. 
	If (@remove = 0) leave only characters from @input that exist in @filter. Review the 
		test cases thoroughly. The regular expression functionality in Transact SQL is 
		very limited, and some characters must be in certain order!',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'see [utility_test].[strip_string] for sample cases.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140706'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140706',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140706',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140527'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140527',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140527',
  @value =N'Katherine E. Lightsey - streamlined code.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , N'PARAMETER'
                                            , N'@input'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string',
    @level2type=N'PARAMETER',
    @level2name=N'@input'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@input [nvarchar](max) - the input string that is strip_stringped to only the 
		characters in @filter or with only the filter characters remaining dependent upon 
		the setting for @remove.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string',
  @level2type=N'PARAMETER',
  @level2name=N'@input'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , N'PARAMETER'
                                            , N'@filter'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string',
    @level2type=N'PARAMETER',
    @level2name=N'@filter'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@filter [sysname] - the input filter which includes all the characters 
		that will be allowed in the output.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string',
  @level2type=N'PARAMETER',
  @level2name=N'@filter'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , N'PARAMETER'
                                            , N'@remove'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string',
    @level2type=N'PARAMETER',
    @level2name=N'@remove'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@remove [bit]=0 - if default (0), the filter characters are the only characters 
	remaining in the input string. If set to 1, the filter characters are removed from the input string.',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string',
  @level2type=N'PARAMETER',
  @level2name=N'@remove'

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.92.00'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'FUNCTION'
                                            , N'strip_string'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.92.00',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'FUNCTION',
    @level1name=N'strip_string'

go

exec sys.sp_addextendedproperty
  @name =N'release_00.92.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'FUNCTION',
  @level1name=N'strip_string'

go 
