use [chamomile];

go

if schema_id(N'work') is null
  execute (N'create schema work');

go

if object_id(N'[work].[set__log]', N'P') is not null
  drop procedure [work].[set__log];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'work', @object [sysname] = N'set__log';
	--
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end +
				case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  then N' output'
					else N''
				end
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
go

create procedure [work].[set__log] @client           [sysname]
                                   , @start_new      [bit] = 0
                                   , @end_current    [bit] = 0
                                   , @add_to_current [bit] = 0
                                   , @add_to_entry   [int] = 0
                                   , @entry          [xml] = null
                                   , @timestasmp     [datetime] = null
as
  begin
      set nocount on;

      declare @message      [nvarchar](max)
              , @entry_list [xml]
              , @count      [int]
              , @id         [int];

      --
      if (select count(*)
          from   [work__secure].[log]
          where  [end] is null) > 1
        begin
            set @message = N'[work__secure].[log] data is corrupt. There are multiple unended sessions. What happens if you are working on multiple jobs simultaneously, or is that possible?';

            throw 51000, @message, 1;
        end;

      set @id = (select [id]
                 from   [work__secure].[log]
                 where  [client] = @client
                        and [end] is null);

      --
      if @add_to_entry > 0
        begin
            set @entry_list = (select [entry]
                               from   [work__secure].[log]
                               where  [id] = @add_to_entry);
            set @entry_list.modify(N'insert sql:variable("@entry") as last into (/*)[1]');

            update [work__secure].[log]
            set    [entry] = @entry_list
            where  [id] = @add_to_entry;
        end
      --
      else if @add_to_current = 1
        begin
            if @entry is null
              begin
                  set @message = N'Cannot add empty value of @entry to current.';

                  throw 51000, @message, 1;
              end;
            else
              begin
                  set @entry_list = (select [entry]
                                     from   [work__secure].[log]
                                     where  [id] = @id);
                  set @entry_list.modify(N'insert sql:variable("@entry") as last into (/*)[1]');

                  update [work__secure].[log]
                  set    [entry] = @entry_list
                  where  [id] = @id;

              end;
        end;

      --
      else if @end_current = 1
        begin
            update [work__secure].[log]
            set    [end] = current_timestamp
            where  [id] = @id;
        end;

      --
      else if @start_new = 1
        begin
            insert into [work__secure].[log]
                        ([client],[start])
            values      (@client,current_timestamp );
        end;
  end;

go 

EXEC sys.sp_addextendedproperty
  @name = N'execute_as__add_to_current'
  , @value = N'declare @entry [xml] = N''<entry timestamp="''
	 + convert(sysname, current_timestamp, 126)
	 + N''">Descriptive entry for work accomplished or in progress.</entry>'';
    execute [chamomile].[work].[set__log] @client = N''<client_name>'', @add_to_current = 1, @entry = @entry;'
  , @level0type = N'schema'
  , @level0name = N'work'
  , @level1type = N'procedure'
  , @level1name = N'set__log';

go

EXEC sys.sp_addextendedproperty
  @name = N'execute_as__end_current'
  , @value = N'execute [chamomile].[work].[set__log] @client = N''<client_name>'', @end_current = 1;'
  , @level0type = N'schema'
  , @level0name = N'work'
  , @level1type = N'procedure'
  , @level1name = N'set__log';

go

EXEC sys.sp_addextendedproperty
  @name = N'execute_as__start_new'
  , @value = N'execute [chamomile].[work].[set__log] @client = N''<client_name>'', @start_new = 1;'
  , @level0type = N'schema'
  , @level0name = N'work'
  , @level1type = N'procedure'
  , @level1name = N'set__log';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'Mutator for [work__secure].[log].'
  , @level0type = N'schema'
  , @level0name = N'work'
  , @level1type = N'procedure'
  , @level1name = N'set__log';

go