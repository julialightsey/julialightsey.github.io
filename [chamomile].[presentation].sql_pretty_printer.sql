/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------

	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	---------------------------------------------
*/
--
-- by hand
-------------------------------------------------
declare @flower [sysname], @color [sysname];
select case @color  when N'white'  then  @flower + N' has no color' when N'black' then  @flower + N' has all colors' else @flower + N' has many colors' end; 

go

--
-- stacked, before comma with space
-------------------------------------------------
declare @flower  [sysname]
        , @color [sysname];

select case @color
           when N'white'
               then
             @flower + N' has no color'
           when N'black'
               then
             @flower + N' has all colors'
           else
             @flower + N' has many colors'
       end;

go 


--
-- by hand
-------------------------------------------------
declare @variable as table ([id] [int] identity(1,1) not null primary key clustered, [flower] [sysname], [color] [sysname]);

go

--
-- stacked, before comma with space
-------------------------------------------------
declare @variable as table (
  [id]       [int] identity(1, 1) not null primary key clustered
  , [flower] [sysname]
  , [color]  [sysname]
  ); 

  
--
-- by hand
-------------------------------------------------
insert into @variable ([flower], [color]) values (N'rose', N'red'), (N'chamomile', N'white'), (N'marigold', N'yellow');

--
-- wrapped
-------------------------------------------------
insert into @variable
            ([flower],[color])
values      (N'rose',N'red'),
            (N'chamomile',N'white'),
            (N'marigold',N'yellow'); 

--
-- stacked column list, stacked value list, , before comma with space
-------------------------------------------------
insert into @variable
            ([flower]
             , [color])
values      (N'rose'
             , N'red'),
            (N'chamomile'
             , N'white'),
            (N'marigold'
             , N'yellow'); 



--
-- stacked column list, wrapped value list, before comma with space
-------------------------------------------------
insert into @variable
            ([flower]
             , [color])
values      (N'rose',N'red'),
            (N'chamomile',N'white'),
            (N'marigold',N'yellow');

go 


