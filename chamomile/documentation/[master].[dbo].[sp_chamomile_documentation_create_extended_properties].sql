use [master];

go

if object_id(N'[dbo].[sp_chamomile_documentation_create_extended_properties]'
             , N'P') is not null
  drop procedure [dbo].[sp_chamomile_documentation_create_extended_properties];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	-- to view documentation
	---------------------------------------------
	use [master];
    go
    declare @schema   [sysname] = N'dbo'
            , @object [sysname] = N'sp_chamomile_documentation_create_extended_properties';
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
create procedure [dbo].[sp_chamomile_documentation_create_extended_properties] @object_fqn         [sysname]
                                                                               , @bcp_command      [nvarchar](max) = null output
                                                                               , @documentation    [nvarchar](max) = null output
                                                                               , @stack            [xml] = null output
                                                                               , @timestamp_output [bit]= 0
                                                                               , @license          [nvarchar](max) = null
                                                                               , @todo             [nvarchar](max) = null
                                                                               , @package          [sysname]
                                                                               , @classification   [sysname] = N'low'
                                                                               , @release          [sysname]
                                                                               , @revision         [sysname]
                                                                               , @author           [nvarchar](max)
as
  begin
      set nocount on;

      declare @server             [nvarchar](max),
              @name               [sysname] = N'description',
              @output             [nvarchar](max),
              @minor_type         [sysname],
              @object_type        [sysname],
              @schema             [sysname],
              @object             [sysname],
              @message            [nvarchar](max),
              @body_01            [nvarchar](max),
              @body_02            [nvarchar](max),
              @body_03            [nvarchar](max),
              @body_04            [nvarchar](max),
              @body_04a           [nvarchar](max),
              @body_05            [nvarchar](max),
              @body_06            [nvarchar](max),
              @body_07            [nvarchar](max),
              @body_07a           [nvarchar](max),
              @body_08            [nvarchar](max),
              @body_09            [nvarchar](max),
              @body_10            [nvarchar](max),
              @body_11            [nvarchar](max),
              @body_12            [nvarchar](max),
              @builder            [xml],
              @subject_fqn        [nvarchar](1000),
              @normalized_server  [nvarchar](1000),
              @id                 [uniqueidentifier],
              @log_prototype      [xml],
              @xml_builder        [xml],
              @stripped_timestamp [sysname],
              @timestamp          [sysname] = convert([sysname], current_timestamp, 126),
              @data               [xml] = N'<valid_xml>text</valid_xml>',
              @description        [nvarchar](max) = N'test log entry';

      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @normalized_server=@builder.value(N'(/*/normalized_server/@name)[1]'
                                            , N'[nvarchar](1000)');
      set @subject_fqn=@builder.value(N'(/*/fqn/@fqn)[1]'
                                      , N'[nvarchar](1000)');
      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @stripped_timestamp = @builder.value(N'(/*/@stripped_timestamp)[1]'
                                               , N'[sysname]');

      --
      -------------------------------------------
      select @schema = parsename(@object_fqn
                                 , 2)
             , @object = parsename(@object_fqn
                                   , 1);

      select @object_type = (select [objects].[type_desc]
                             from   [sys].[objects] as [objects]
                             where  object_schema_name([objects].[object_id]) = @schema
                                    and [objects].[name] = @object)
             , @license = coalesce(@license
                                   , [chamomile].[utility].[get_meta_data](N'[chamomile].[documentation].[license]'))
             , @todo = coalesce (@todo
                                 , N'{todo: business description | where to find the value | how to use the value | what constraints are on the value}');

      --
      -------------------------------------------
      if lower(@object_type) like ( N'%procedure%' )
        begin
            select @minor_type = N'parameter'
                   , @object_type = N'procedure';
        end
      else if lower(@object_type) like ( N'%function%' )
        begin
            select @minor_type = N'parameter'
                   , @object_type = N'function';
        end
      else if lower(@object_type) like ( N'%user_table%' )
        begin
            select @minor_type = N'column'
                   , @object_type = N'table';
        end
      else if lower(@object_type) like ( N'%view%' )
        begin
            select @minor_type = N'column'
                   , @object_type = N'view';
        end
      else if @object_type is null
        begin
            set @message = N'@object_type not found for; database="'
                           + db_name() + N'", @schema="' + @schema
                           + N'", @object="' + @object + N'", @package="'
                           + @package + N'", @revision="' + @revision
                           + N'", @author="' + @author + N'".';

            raiserror (@message,10,1);

            return 64;
        end
      else
        begin
            set @message = N'@object_type not supported for; database="'
                           + db_name() + N'", @schema="' + @schema
                           + N'", @object="' + @object + N'", @package="'
                           + @package + N'", @revision="' + @revision
                           + N'", @author="' + @author + N'".';

            raiserror (@message,10,1);

            return 64;
        end

      set @body_01 = N'if exists (select *
           from   ::fn_listextendedproperty(N';
      set @body_02 = ', N''schema''
                                            , N';
      set @body_03=' , N''' + @object_type
                   + '''
                                            , N';
      set @body_04=', N''' + @minor_type
                   + '''
                                            , N';
      set @body_04a='))
  exec sys.sp_dropextendedproperty
    @name        =N';
      set @body_05=', @level0type=N''schema''
    , @level0name=N';
      set @body_06=', @level1type=N''' + @object_type
                   + '''
    , @level1name=N'
      set @body_07=', @level2type=N''' + @minor_type
                   + '''
    , @level2name=N';
      set @body_07a=';
	  
	  

exec sys.sp_addextendedproperty
  @name        =N';
      set @body_08='
  , @value     =N';
      set @body_09='
  , @level0type=N''schema''
  , @level0name=N';
      set @body_10='
  , @level1type=N''' + @object_type
                   + '''
  , @level1name=N';
      set @body_11='
  , @level2type=N''' + @minor_type
                   + '''
  , @level2name=N';
      set @body_12 = ';';
      --
      ----------------------------------------------
      set @output = N'  ';
      --
      -- description
      ----------------------------------------------
      set @output = @output
                    + N'if exists (select *
           from   ::fn_listextendedproperty(N''description''
                                            , N''SCHEMA''
                                            , N'''
                    + @schema
                    + '''
                                            , N'''
                    + @object_type
                    + '''
                                            , N'''
                    + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''description''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                    + '''
    , @level1type=N''' + @object_type
                    + '''
    , @level1name=N''' + @object
                    + ''';

				  

exec sys.sp_addextendedproperty
  @name        =N''description''
  , @value     =N''' + @todo
                    + '''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                    + '''
  , @level1type=N''' + @object_type
                    + '''
  , @level1name=N''' + @object + ''';';

      --
      -- execute_as
      --------------------------------------------------------------------------
      if @object_type in ( N'procedure', N'function' )
        set @output = @output
                      + N'
if exists (select *
           from   ::fn_listextendedproperty(N''execute_as''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''execute_as''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';
					
exec sys.sp_addextendedproperty
  @name        =N''execute_as''
  , @value     =N''todo''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + N''';';

      --
      -- license
      ----------------------------------------------
      if @license is not null
        set @output = @output
                      + N'
			  if exists (select *
           from   ::fn_listextendedproperty(N''license''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''license''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';
				  
exec sys.sp_addextendedproperty
  @name        =N''license''
  , @value     =N''' + @license
                      + '''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';';

      --
      -- classification
      ----------------------------------------------
      if @classification is not null
        set @output = @output
                      + N'
			  if exists (select *
           from   ::fn_listextendedproperty(N''classification''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''classification''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';
				  
exec sys.sp_addextendedproperty
  @name        =N''classification''
  , @value     =N''' + @classification
                      + '''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';';

      --
      -- todo
      ----------------------------------------------
      if @todo is not null
        set @output = @output
                      + N'


			  if exists (select *
           from   ::fn_listextendedproperty(N''todo''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''todo''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';
				  
exec sys.sp_addextendedproperty
  @name        =N''todo''
  , @value     =N''' + @todo
                      + '''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';';

      --
      -- revision
      ----------------------------------------------
      if @revision is not null
        set @output = @output
                      + N'


if exists (select *
           from   ::fn_listextendedproperty(N'''
                      + @revision
                      + '''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''' + @revision
                      + '''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';
				  
exec sys.sp_addextendedproperty
  @name        =N''' + @revision
                      + '''
  , @value     =N''' + @author
                      + '''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';
				  
			   ';

      --
      -- package
      ----------------------------------------------
      if @package is not null
        set @output = @output
                      + N'

if exists (select *
           from   ::fn_listextendedproperty(N'''
                      + @package
                      + '''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''' + @package
                      + '''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';

				  

exec sys.sp_addextendedproperty
  @name        =N''' + @package
                      + '''
  , @value     =N''''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';
  
        ';

      --
      -- release
      ----------------------------------------------
      if @release is not null
        set @output = @output
                      + N'

if exists (select *
           from   ::fn_listextendedproperty(N'''
                      + @release
                      + '''
                                            , N''SCHEMA''
                                            , N'''
                      + @schema
                      + '''
                                            , N'''
                      + @object_type
                      + '''
                                            , N'''
                      + @object + '''
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name        =N''' + @release
                      + '''
    , @level0type=N''SCHEMA''
    , @level0name=N''' + @schema
                      + '''
    , @level1type=N''' + @object_type
                      + '''
    , @level1name=N''' + @object
                      + ''';

				  

exec sys.sp_addextendedproperty
  @name        =N''' + @release
                      + '''
  , @value     =N''''
  , @level0type=N''SCHEMA''
  , @level0name=N''' + @schema
                      + '''
  , @level1type=N''' + @object_type
                      + '''
  , @level1name=N''' + @object + ''';
  
  ';

      --
      -- procedure parameters
      ----------------------------------------
      if @object_type = N'procedure'
        select @output = coalesce(@output + N' ', N'') + @body_01
                         + N'''' + @name + N'''' + @body_02 + N'''' + @schema + N''''
                         + @body_03 + N'''' + @object + N'''' + @body_04 + N''''
                         + [minor_object].[name] + N'''' + @body_04a + N''''
                         --
                         + @name + N'''' + @body_05 + N'''' + @schema + N''''
                         + @body_06 + N'''' + @object + N'''' + @body_07 + N''''
                         + [minor_object].[name] + N'''' + @body_07a + N''''
                         --
                         + @name + N'''' + @body_08 + N''''
                         + [minor_object].[name] +
                         --
                         case
                         --
                         when [types].[name] = N'nvarchar' then N' ' +types.name + ' ('+cast([minor_object].[max_length]/2 as [sysname]) + N')'
                         --
                         when [types].[name] = N'varchar' then N' ' +types.name + ' ('+cast([minor_object].[max_length] as [sysname]) + N')'
                         --
                         when [types].[name] in (N'decimal', N'float') then N' ' +types.name + ' ('+ cast([minor_object].[precision] as [sysname])+N', '+cast([minor_object].[scale] as [sysname])+')'
                         --
                         else N' ' +types.name end
                         --
                         + N' - ' + @todo + N''''
                         + @body_09 + N'''' + @schema + N'''' + @body_10 + N''''
                         + @object + N'''' + @body_11 + N''''
                         + [minor_object].[name] + N'''' + @body_12
        from   [sys].[parameters] as [minor_object]
               join [sys].[procedures] as [major_object]
                 on [major_object].[object_id] = [minor_object].[object_id]
               join [sys].[types] as [types]
                 on [types].[user_type_id] = [minor_object].[user_type_id]
        where  object_schema_name([minor_object].[object_id]) = @schema
               and [major_object].[name] = @object
        order  by [major_object].[name];

      --
      -- function parameters
      --------------------------------------------------------------------------
      if @object_type in( N'function' )
        select @output = coalesce(@output + N' ', N'') + @body_01
                         + N'''' + @name + N'''' + @body_02 + N'''' + @schema + N''''
                         + @body_03 + N'''' + @object + N'''' + @body_04 + N''''
                         + [minor_object].[name] + N'''' + @body_04a + N''''
                         --
                         + @name + N'''' + @body_05 + N'''' + @schema + N''''
                         + @body_06 + N'''' + @object + N'''' + @body_07 + N''''
                         + [minor_object].[name] + N'''' + @body_07a + N''''
                         --
                         + @name + N'''' + @body_08 + N''''
                         + [minor_object].[name] +
                         --
                         case
                         --
                         when [types].[name] = N'nvarchar' then N' ' +types.name + ' ('+cast([minor_object].[max_length]/2 as [sysname]) + N')'
                         --
                         when [types].[name] = N'varchar' then N' ' +types.name + ' ('+cast([minor_object].[max_length] as [sysname]) + N')'
                         --
                         when [types].[name] in (N'decimal', N'float') then N' ' +types.name + ' ('+ cast([minor_object].[precision] as [sysname])+N', '+cast([minor_object].[scale] as [sysname])+')'
                         --
                         else N' ' +types.name end
                         --
                         + N' - ' + @todo + N''''
                         + @body_09 + N'''' + @schema + N'''' + @body_10 + N''''
                         + @object + N'''' + @body_11 + N''''
                         + [minor_object].[name] + N'''' + @body_12
        from   [sys].[parameters] as [minor_object]
               join [sys].[objects] as [major_object]
                 on [major_object].[object_id] = [minor_object].[object_id]
               join [sys].[types] as [types]
                 on [types].[user_type_id] = [minor_object].[user_type_id]
        where  object_schema_name([minor_object].[object_id]) = @schema
               and [major_object].[name] = @object
               and [major_object].[type_desc] like N'%function%'
               and len([minor_object].[name]) > 0
               and [minor_object].[name] is not null
        order  by [major_object].[name];

      --
      -- table columns
      --------------------------------------------------------------------------
      if @object_type = N'table'
        select @output = coalesce(@output + N' ', N'') + @body_01
                         + N'''' + @name + N'''' + @body_02 + N'''' + @schema + N''''
                         + @body_03 + N'''' + @object + N'''' + @body_04 + N''''
                         + [minor_object].[name] + N'''' + @body_04a + N''''
                         --
                         + @name + N'''' + @body_05 + N'''' + @schema + N''''
                         + @body_06 + N'''' + @object + N'''' + @body_07 + N''''
                         + [minor_object].[name] + N'''' + @body_07a + N''''
                         --
                         + @name + N'''' + @body_08 + N'''['
                         + [minor_object].[name] + N']' +
                         --
                         case
                         --
                         when [types].[name] = N'nvarchar' then N' [' +types.name + '] ('+cast([minor_object].[max_length]/2 as [sysname]) + N')'
                         --
                         when [types].[name] = N'varchar' then N' [' +types.name + '] ('+cast([minor_object].[max_length] as [sysname]) + N')'
                         --
                         when [types].[name] in (N'decimal', N'float') then N' [' +types.name + '] ('+ cast([minor_object].[precision] as [sysname])+N', '+cast([minor_object].[scale] as [sysname])+')'
                         --
                         else N' [' +types.name + ']' end
                         --
                         + N' - ' + @todo
                         + N'''' + @body_09 + N'''' + @schema + N'''' + @body_10
                         + N'''' + @object + N'''' + @body_11 + N''''
                         + [minor_object].[name] + N'''' + @body_12
        from   [sys].[columns] as [minor_object]
               join [sys].[tables] as [major_object]
                 on [major_object].[object_id] = [minor_object].[object_id]
               join [sys].[types] as [types]
                 on [types].[user_type_id] = [minor_object].[user_type_id]
        where  object_schema_name([minor_object].[object_id]) = @schema
               and [major_object].[name] = @object
        order  by [major_object].[name];

      --
      -- view columns
      --------------------------------------------------------------------------
      if @object_type = N'view'
        select @output = coalesce(@output + N' ', N'') + @body_01
                         + N'''' + @name + N'''' + @body_02 + N'''' + @schema + N''''
                         + @body_03 + N'''' + @object + N'''' + @body_04 + N''''
                         + [minor_object].[name] + N'''' + @body_04a + N''''
                         --
                         + @name + N'''' + @body_05 + N'''' + @schema + N''''
                         + @body_06 + N'''' + @object + N'''' + @body_07 + N''''
                         + [minor_object].[name] + N'''' + @body_07a + N''''
                         --
                         + @name + N'''' + @body_08 + N'''['
                         + [minor_object].[name] + N']' +
                         --
                         case
                         --
                         when [types].[name] = N'nvarchar' then N' [' +types.name + '] ('+cast([minor_object].[max_length]/2 as [sysname]) + N')'
                         --
                         when [types].[name] = N'varchar' then N' [' +types.name + '] ('+cast([minor_object].[max_length] as [sysname]) + N')'
                         --
                         when [types].[name] in (N'decimal', N'float') then N' [' +types.name + '] ('+ cast([minor_object].[precision] as [sysname])+N', '+cast([minor_object].[scale] as [sysname])+')'
                         --
                         else N' [' +types.name + ']' end
                         --
                         + N' - ' + @todo
                         + N'''' + @body_09 + N'''' + @schema + N'''' + @body_10
                         + N'''' + @object + N'''' + @body_11 + N''''
                         + [minor_object].[name] + N'''' + @body_12
        from   [sys].[columns] as [minor_object]
               join [sys].[views] as [major_object]
                 on [major_object].[object_id] = [minor_object].[object_id]
               join [sys].[types] as [types]
                 on [types].[user_type_id] = [minor_object].[user_type_id]
        where  object_schema_name([minor_object].[object_id]) = @schema
               and [major_object].[name] = @object
        order  by [major_object].[name];

      --
      -- load documentation into repository and create bcp extraction command
      -------------------------------------------
      begin
          set @log_prototype =[chamomile].[utility].[get_prototype](N'[chamomile].[log].[stack].[prototype]');
          set @description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis]');
          set @log_prototype.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
          set @log_prototype.modify(N'replace value of (/log/description/text())[1] with sql:variable("@output")');
          set @documentation = @output;
          --
          -------------------------------------------
          set @stack = null;

          execute [chamomile].[utility].[set_log]
            @object_fqn = @object_fqn,
            @log = @log_prototype,
            @sequence = 1,
            @stack = @stack output;

          --
          -------------------------------------------
          if @timestamp_output = 1
            set @message = N'_' + @stripped_timestamp;
          else
            set @message = N'';

          --
          -------------------------------------------
          set @bcp_command = N'BCP "select [chamomile].[utility].[get_log_text](N'''
                             + @object_fqn + N''');" queryout '
                             + @subject_fqn + '_' + @object_fqn + @message
                             + N'.sql' + N' -t, -T -c -d ' + db_name() + N' -S '
                             + @server + N';';
      end;
  end;

go

exec [sp_ms_marksystemobject]
  N'sp_chamomile_documentation_create_extended_properties';

go

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'todo',
  @value =N'<ol>
	<li>Fix 0 parameter (return parameter) for function.</li>
	<li>Fix missing go statements</li>
	<li>Get boilerplate from meta data.</li>
  </ol>',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[documentation].[license]'');',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'This is a utility function used to generate boilerplate extended properties for various objects. It is useful when you have a view or table with a large number of columns, or a procedure or function with a large number of parameters, and cutting and pasting becomes onerous. Based on the input parameters, extended properties are generated for each column or parameter for "description". You only then have to fill out the "todo" in the value section to describe what each column or parameter is. This is a "rough" query and is not intended for production use. It is not tested and is only intended to be used for generating boilerplate as a utility method.',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'-- select text of [bcp command] output and execute in command window. The extended properties are copied to a file as named in the bcp command.
-- use [{target_database}];
use [chamomile];
go
declare @bcp_command     [nvarchar](max)
        , @documentation [nvarchar](max)
        , @stack         [xml]
        , @return_code   [int];
execute @return_code = [dbo].[sp_chamomile_documentation_create_extended_properties]
  @object_fqn       =N''[utility].[set_log]''
  , @package        =N''package_chamomile_log''
  , @release        =N''release_00.93.00''
  , @revision       =N''revision_20140723''
  , @classification = N''low''
  , @license = N''select [utility].[get_meta_data](N''''[chamomile].[license]'''');''
  , @author         =N''Katherine E. Lightsey''
  , @bcp_command    =@bcp_command output
  , @documentation  = @documentation output
  , @stack          = @stack output;
select @bcp_command     as N''@bcp_command''
       , @documentation as N''@documentation ''
       , @stack         as N''@stack''
       , @return_code   as N''@return_code'';',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140706'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140706',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140706',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.92.00'
                                            , N'schema'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_chamomile_documentation_create_extended_properties'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.92.00',
    @level0type=N'schema',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_chamomile_documentation_create_extended_properties'

go

exec sys.sp_addextendedproperty
  @name =N'release_00.92.00',
  @value =N'',
  @level0type=N'schema',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_chamomile_documentation_create_extended_properties'

go 
