use [chamomile];

go

if object_id ('[repository__secure].[repository__secure.mutable.disallow__mutable_entry_if_immutable_exists]'
              , 'TR') is not null
  drop trigger [repository__secure].[repository__secure.mutable.disallow__mutable_entry_if_immutable_exists];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'repository__secure', @object [sysname] = N'mutable';
	--  
	select N'[' +object_schema_name([extended_properties].[major_id]) +N'].['+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
				else Object_name([objects].[object_id]) +N']' + coalesce(N'.['+[columns].[name] + N']', N'')
			end                                                                as [object]
		   ,case when [extended_properties].[minor_id]=0 
				then [objects].[type_desc]
				else N'COLUMN'
			end                                                                as [type]
		   ,[extended_properties].[name]                                       as [property]
		   ,[extended_properties].[value]                                      as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   left join [sys].[columns] as [columns]
				  on [extended_properties].[major_id]=[columns].[object_id] and
					 [columns].[column_id]=[extended_properties].[minor_id]
	where   coalesce(Object_schema_name([objects].[parent_object_id]), Object_schema_name([extended_properties].[major_id]))=@schema and
			coalesce(Object_name([objects].[parent_object_id]), Object_name([extended_properties].[major_id]))=@object
	order  by [columns].[name],[object],[type],[property]; 
*/
create trigger [repository__secure].[repository__secure.mutable.disallow__mutable_entry_if_immutable_exists]
on [repository__secure].[mutable]
after update, insert
as
  begin
      declare @trigger [nvarchar](max) = (select N'[' + object_schema_name(@@procid) + N'].['
                        + object_name(parent_id) + '].['
                        + object_name(@@procid) + N']'
                 from   sys.triggers
                 where  object_id = @@procid),
              @parent  [nvarchar](max) = (select N'[' + object_schema_name(parent_id) + N'].['
                        + object_name(parent_id) + N']'
                 from   sys.triggers
                 where  object_id = @@procid);

      if (select count(*)
          from   [inserted] as [inserted]
                 join [repository__secure].[immutable] as [immutable]
                   on [immutable].[source] = [inserted].[source]
                      and [immutable].[category] = [inserted].[category]
                      and [immutable].[class] = [inserted].[class]
                      and [immutable].[type] = [inserted].[type]) > 1
        begin
            raiserror ('In trigger (%s). Mutable entries are not allowed when there is an existing immutable entry for category, class, type. (%s) .',16,1,@trigger,@parent);

            rollback transaction;
        end;

      return;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'trigger'
                                          , N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'trigger',
    @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The trigger disallows entries with overlapping [active],[expire] dates.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'trigger',
  @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20140804'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'trigger'
                                          , N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists'))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140804',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'trigger',
    @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'KELightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'trigger',
  @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_metadata'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'trigger'
                                          , N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists'))
  exec sys.sp_dropextendedproperty
    @name = N'package_metadata',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'trigger',
    @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

exec sys.sp_addextendedproperty
  @name = N'package_metadata',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'trigger',
  @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'release_00.93.00'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'trigger'
                                          , N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists'))
  exec sys.sp_dropextendedproperty
    @name = N'release_00.93.00',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'trigger',
    @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'trigger',
  @level2name = N'repository__secure.mutable.disallow__mutable_entry_if_immutable_exists';

go 
