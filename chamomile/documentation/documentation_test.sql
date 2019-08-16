use [chamomile];

go

/*
	select * from [repository].[get_list](N'documentation')
	where [fqn] like N'%prototype%'
	order by [fqn];
*/
declare @object_fqn  [nvarchar](max) = N'[chamomile].[documentation_stack].[stack].[test_02]',
        @entry       [xml] = N'<html><p>stuff</p></html>',
        @description [nvarchar](max),
        @sequence    [int] = 0,
        @delete      [int] = 0,
        @stack       xml([chamomile].[xsc]) = null;
--
declare @timestamp             [sysname] = convert([sysname], current_timestamp, 126),
        @entry_stack_prototype [nvarchar](max) = N'[chamomile].[documentation_stack].[stack].[prototype]',
        @builder               [xml],
        @subject_fqn           [nvarchar](max);

--
-------------------------------------------
execute [dbo].[sp_get_server_information]
  @procedure_id=@@procid,
  @stack =@builder output;

set @subject_fqn = isnull(@builder.value(N'(/*/fqn/@fqn)[1]'
                                         , N'[nvarchar](max)')
                          , N'[documentation].[set].[test].[script]');
--
-------------------------------------------
set @entry.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
-- if @description is null set it to the description in the entry sequence. it will only be used if there is no current log_entry
set @description = coalesce(@description
                            , @entry.value(N'(/*/description/text())[1]'
                                           , N'[nvarchar](max)'));

--
-------------------------------------------
begin transaction;

execute [documentation].[set]
  @object_fqn =@object_fqn,
  @description =@description,
  @prototype =@entry_stack_prototype,
  @data =@entry,
  @sequence =@sequence,
  @delete =@delete,
  @stack =@stack output;

select @stack;

--
-------------------------------------------
select @entry = N'<text>blah blah blah</text>'
       , @description = N' text b lah blah this is iggied ';

set @entry.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');

execute [documentation].[set]
  @object_fqn =@object_fqn,
  @description =@description,
  @prototype =@entry_stack_prototype,
  @data =@entry,
  @sequence =@sequence,
  @delete =@delete,
  @stack =@stack output;

select @stack;

--
-------------------------------------------
select @entry = N'<data><valid_xml /></data>'
       , @description = N' data stuff, this is iggied ';

set @entry.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');

execute [documentation].[set]
  @object_fqn =@object_fqn,
  @description =@description,
  @prototype =@entry_stack_prototype,
  @data =@entry,
  @sequence =@sequence,
  @delete =@delete,
  @stack =@stack output;

select @stack;

--
-------------------------------------------
select @entry = N'<text>replace data node with text node</text>'
       , @description = N' data stuff, this is iggied ';

set @entry.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');

execute [documentation].[set]
  @object_fqn =@object_fqn,
  @description =@description,
  @prototype =@entry_stack_prototype,
  @data =@entry,
  @sequence =3,
  @delete =@delete,
  @stack =@stack output;

select @stack;

rollback;

go 
