if object_id ('[utility__secure].[utility__secure__metadata__disallow__delete]'
              , 'TR') is not null
  drop trigger [utility__secure].[utility__secure__metadata__disallow__delete];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema   [sysname] = N'utility__secure', @object [sysname] = N'utility__secure__metadata__disallow__delete';
	select [extended_properties].[name]    as [property]
		   , [extended_properties].[value] as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id] = [extended_properties].[major_id]
		   left join [sys].[columns] as [columns]
				  on [extended_properties].[major_id] = [columns].[object_id]
					 and [columns].[column_id] = [extended_properties].[minor_id]
	where  object_schema_name([extended_properties].[major_id]) = @schema
		   and object_name([objects].[object_id]) = @object
	order  by [property];  
*/
create trigger [utility__secure].[utility__secure__metadata__disallow__delete]
on [utility__secure].[metadata]
for update, delete
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

      raiserror ('In trigger (%s). The target table (%s) is insert only. Updates and deletes are not allowed.',16,1,@trigger,@parent);

      rollback transaction;

      return;
  end;

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The trigger disallows deletes. The target table only allows inserts.',
  @level0type = N'schema',
  @level0name = N'utility__secure',
  @level1type = N'table',
  @level1name = N'metadata',
  @level2type = N'trigger',
  @level2name = N'utility__secure__metadata__disallow__delete';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'KELightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'utility__secure',
  @level1type = N'table',
  @level1name = N'metadata',
  @level2type = N'trigger',
  @level2name = N'utility__secure__metadata__disallow__delete';

go

exec sys.sp_addextendedproperty
  @name = N'package_metadata',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'utility__secure',
  @level1type = N'table',
  @level1name = N'metadata',
  @level2type = N'trigger',
  @level2name = N'utility__secure__metadata__disallow__delete';

go

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'utility__secure',
  @level1type = N'table',
  @level1name = N'metadata',
  @level2type = N'trigger',
  @level2name = N'utility__secure__metadata__disallow__delete';

go 
