--
-- create text documentation
---------------------------------------------
/*
	select *
    from   [repository].[get_list](N'prototype')
    where  [fqn] like N'%documentation%'
            or [fqn] like N'%log%'
    order  by [fqn]; 
    
*/
begin
    begin transaction;

    declare @stack      xml,
            @object_fqn [nvarchar](max)=N'[chamomile].[documentation].[get].[test_01]';
    declare @documentation [nvarchar](max) = N'test documentation for ' + @object_fqn;

    --
    -- delete existing documentation
    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @delete = 2;

    --
    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @documentation =@documentation,
      @type =N'text',
      @stack =@stack output;

    --
    ---------------------------------------------
    if(select [documentation].[get] (@object_fqn)) is null
      select N'fail';
    else
      select N'pass';

    --
    -- delete test documentation
    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =@object_fqn,
      @delete = 2;

    rollback;
end;

--
-- create html documentation
---------------------------------------------
begin
    begin transaction;

    declare @stack xml;

    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_01]',
      @documentation =N'<ol><li><b>test</b> modified documentation for</li><li>[chamomile].[documentation].[get].[test_01].</li></ol>',
      @type =N'html',
      @sequence = 33,
      @stack =@stack output;

    select @stack as N'@stack output';

    if (select [documentation].[get] (N'[chamomile].[documentation].[get].[test_01]')) is not null
      select N'pass';
    else
      select N'fail';

    --
    -- delete documentation
    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_01]',
      @delete = 2;

    if (select [documentation].[get] (N'[chamomile].[documentation].[get].[test_01]')) is null
      select N'pass';
    else
      select N'fail';

    rollback;
end;

--
-- delete a specific documentation sequence
-------------------------------------------------
begin
    begin transaction;

    declare @stack xml;

    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_01]',
      @documentation =N'sequence 12 test modified documentation for [chamomile].[documentation].[get].[test_01].',
      @type =N'text',
      @sequence = 12,
      @stack =@stack output;

    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_01]',
      @documentation =N'sequence 13 test modified documentation for [chamomile].[documentation].[get].[test_01].',
      @type =N'text',
      @sequence = 13,
      @stack =@stack output;

    select [documentation].[get] (N'[chamomile].[documentation].[get].[test_01]');

    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_01]',
      @documentation =N'test modified documentation for [chamomile].[documentation].[get].[test_01].',
      @type =N'text',
      @delete = 1,
      @sequence = 12,
      @stack =@stack output;

    select @stack as N'@stack output';

    select [documentation].[get] (N'[chamomile].[documentation].[get].[test_01]');

    rollback;
end;

--
-- automatically increment sequence
---------------------------------------------
begin
    begin transaction;

    declare @stack xml;

    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_02]',
      @documentation =N'<ol><li><b>test</b> modified documentation for</li><li>[chamomile].[documentation].[get].[test_02].</li></ol>',
      @type =N'html',
      @stack =@stack output;

    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_02]',
      @documentation =N'second sequence',
      @type =N'text',
      @stack =@stack output;

    select @stack as N'@stack output';

    select [documentation].[get] (N'[chamomile].[documentation].[get].[test_02]');

    --
    -- delete documentation
    ---------------------------------------------
    execute [chamomile].[documentation].[set]
      @object_fqn =N'[chamomile].[documentation].[get].[test_02]',
      @delete = 2;

    rollback;
end; 
