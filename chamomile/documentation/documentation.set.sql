use [chamomile];

go

if schema_id(N'documentation') is null
  execute(N'create schema documentation');

go

if object_id(N'[documentation].[set]'
             , N'P') is not null
  drop procedure [documentation].[set];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'documentation'
            , @object [sysname] = N'set';
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
create procedure [documentation].[set] @object_fqn    [nvarchar](max)
                                       , @description [nvarchar](max) = null
                                       , @prototype   [xml] = null
                                       , @data        [xml] = null
                                       , @sequence    [int] = 0
                                       , @delete      [int] = 0
                                       , @stack       xml([chamomile].[xsc]) = null output
as
  begin
      declare @stack_prototype [nvarchar](max) = N'[chamomile].[xsc].[stack].[prototype]';
      declare @subject_fqn         [nvarchar](max),
              @message             [nvarchar](max),
              @builder             [xml],
              @id                  [uniqueidentifier],
              @stack_builder       [xml],
              @subject_description [nvarchar](max),
              @timestamp           [sysname] = convert([sysname], current_timestamp, 126);

      --
      -------------------------------------------
      execute [dbo].[sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @subject_fqn = @builder.value(N'(/*/fqn/@fqn)[1]'
                                        , N'[nvarchar](max)');
      set @subject_description = N'Created by ' + @subject_fqn + N'.';
      set @object_fqn=lower(@object_fqn);

      --
      -------------------------------------------
      if @delete = 1
        begin
            set @stack_builder.modify('delete */object/*/*[@sequence=sql:variable("@sequence")]');

            execute [repository].[set]
              @stack=@stack_builder output;

            set @stack = @stack_builder;
        end;
      else if @delete = 2
        begin
            set @id = (select [id]
                       from   [repository].[get] (null
                                                  , @object_fqn));

            if @id is not null
              begin
                  execute [repository].[set]
                    @id =@id,
                    @delete = 1;

                  --
                  -------------------------------------
                  if ( @stack_builder.value(N'count (/*/object/*)'
                                            , N'[int]') = 0 )
                    set @id = (select [id]
                               from   [repository].[get] (null
                                                          , @object_fqn));

                  execute [repository].[set]
                    @id =@id,
                    @delete = 1;
              end;

            set @stack = (select [entry]
                          from   [repository].[get] (null
                                                     , @object_fqn));
        end;
      --
      -------------------------------------------
      else
        begin
            --
            -------------------------------------------
            if @data is null
              begin
                  begin
                      set @message= N'@data cannot be null unless @delete in {1|2}';

                      raiserror (100068,1,1,@message,@subject_fqn);

                      return 100068;
                  end;
              end;

            if @object_fqn is null
              begin
                  begin
                      set @message= N'@object_fqn cannot be null';

                      raiserror (100068,1,1,@message,@subject_fqn);

                      return 100068;
                  end;
              end;

            set @description = coalesce(@description
                                        , @object_fqn);
            --
            -------------------------------------------------
            set @stack_builder = (select [entry]
                                  from   [repository].[get](null
                                                            , @object_fqn));

            --
            -------------------------------------------
            if @stack_builder is null
              begin
                  set @stack_builder = [utility].[get_prototype](@stack_prototype);
                  set @stack_builder.modify(N'replace value of (/*/subject/description/text())[1] with sql:variable("@subject_description")');
                  set @stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
                  set @stack_builder.modify(N'replace value of (/*/subject/@fqn)[1] with sql:variable("@subject_fqn")');
                  --
                  -------------------------------------------
                  set @prototype.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@object_fqn")');
                  set @prototype.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
                  set @prototype.modify(N'replace value of (/*/description/text())[1] with sql:variable("@description")');
                  set @stack_builder.modify(N'insert sql:variable("@prototype") as last into (/*/object)[1]');
              end;

            --
            -------------------------------------------
            if @stack_builder.exist(N'/*/object/*/*[@sequence=sql:variable("@sequence")]') = 1
              set @stack_builder.modify('delete /*/object/*/*[@sequence=sql:variable("@sequence")]');
            else if @sequence = 0
              set @sequence = isnull(@stack_builder.value(N'max (/*/object/*/*/@sequence)[1]', N'[int]')
                                     + 1
                                     , 1);

            --
            -------------------------------------------
            if @data.exist(N'(/*/@sequence)[1]') = 0
              set @data.modify('insert attribute sequence {sql:variable("@sequence")} as first into (/*)[1]');
            else
              set @data.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');

            --
            -------------------------------------------
            set @stack_builder.modify(N'insert sql:variable("@data") as last into (/*/object/*)[1]');

            execute [repository].[set]
              @stack=@stack_builder output;

            set @stack = @stack_builder;
        end;
  end;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'mutator for the documentation package. Creates, updates, or deletes documentation in the repository.',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'todo',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set';

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@object_fqn'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@object_fqn';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@object_fqn nvarchar (max) - the fully qualified name of the object to mutate in "[category].[class].[type]" format.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@object_fqn';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@description'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@description';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@description nvarchar (max) - the description of the documentation object.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@description';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@prototype'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@prototype';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@prototype xml - the xml prototype for the object; how it will be stored.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@prototype';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@data'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@data';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@data xml - an xml object to be stored as documentation.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@data';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@sequence'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@sequence';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@sequence [int] - the sequence number of the documentation in the documentation object. if 0, the next largest value is used. if exists, the existing sequence is updated.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@sequence';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@delete'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@delete';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@delete int - if 0, ignored. if 1, the sequence is deleted. if 2, the entire documentation object is deleted.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@delete';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'procedure'
                                            , N'set'
                                            , N'parameter'
                                            , N'@stack'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'procedure',
    @level1name=N'set',
    @level2type=N'parameter',
    @level2name=N'@stack';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@stack [xml] - the output of the entire documentation object which was updated in the repository.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'procedure',
  @level1name=N'set',
  @level2type=N'parameter',
  @level2name=N'@stack'; 
