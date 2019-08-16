use [WorldWideImporters];

go

if schema_id(N'Warehouse__test') is null
  execute (N'create schema Warehouse__test');

go

if object_id(N'[Warehouse__test].[StockItemTransactions__test_01]', N'P') is not null
  drop procedure [Warehouse__test].[StockItemTransactions__test_01];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema   [sysname] = N'Warehouse__test', @object [sysname] = N'StockItemTransactions__test_01';
	select quotename(object_schema_name([extended_properties].[major_id])) + N'.'
		   + case when object_name([objects].[parent_object_id]) is not null then quotename(object_name([objects].[parent_object_id]))
				+ N'.' + quotename(object_name([objects].[object_id]))
			   else quotename(object_name([objects].[object_id]))
					+ case when [parameters].[parameter_id] > 0 then N' ' + coalesce( [parameters].[name], N'')
						else N''
					  end
					+ case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1 then N' output'
						else N''
					  end
			 end                           as [object]
		   , case
			   when [extended_properties].[minor_id] = 0 then [objects].[type_desc]
			   else N'PARAMETER'
			 end                           as [type]
		   , [extended_properties].[name]  as [property]
		   , [extended_properties].[value] as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id] = [extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id] = [objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id] = [parameters].[object_id]
					 and [parameters].[parameter_id] = [extended_properties].[minor_id]
	where  [schemas].[name] = @schema and [objects].[name] = @object
	order  by [parameters].[parameter_id], [object], [type], [property]; 
*/
create procedure [Warehouse__test].[StockItemTransactions__test_01] @output  [xml] output
                                                                    , @error [xml] = null output
as
  begin
      select count(*)                           as [count]
             , cast([LastEditedWhen] as [date]) as [date]
      from   [Warehouse].[StockItemTransactions] as [StockItemTransactions]
      where  [StockItemTransactions].[LastEditedWhen] > N'2016-01-01'
             and [StockItemTransactions].[LastEditedWhen] <= N'2017-01-01'
      group  by cast([LastEditedWhen] as [date])
      order  by count(*) asc
      offset 5 rows fetch next 1 rows only;
	 -- execute [WorldWideImporters].[Integration].[GetMovementUpdates]
      execute [Integration].[GetMovementUpdates] @LastCutoff  =N'2016-01-01'
                                                 , @NewCutoff =N'2016-01-02';
  end;

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'Unit Test for [WorldWideImporters].[Integration].[GetMovementUpdates].'
                                , @level0type = N'schema'
                                , @level0name = N'Warehouse__test'
                                , @level1type = N'procedure'
                                , @level1name = N'StockItemTransactions__test_01';

go

exec sys.sp_addextendedproperty @name         = N'revision_20180811'
                                , @value      = N'KELightsey@gmail.com – Created.'
                                , @level0type = N'schema'
                                , @level0name = N'Warehouse__test'
                                , @level1type = N'procedure'
                                , @level1name = N'StockItemTransactions__test_01';

go 
