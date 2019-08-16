/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		table used for [chamomile].[presentation].[unbreakable_code]

	--
	--	notes
	---------------------------------------------
		this unbreakable_code is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

			--
			-- code block begin
			-------------------------------------
				<run code here>
			-------------------------------------
			-- code block end
			--
	
	--
	-- references
	---------------------------------------------
		sys.dm_tran_active_transactions (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms174302.aspx
		Unit unbreakable_codeing - http://en.wikipedia.org/wiki/Unit_unbreakable_codeing
*/
use [chamomile];

go

if schema_id(N'unbreakable_code') is null
  execute (N'create schema unbreakable_code');

go

if object_id(N'[unbreakable_code].[flower]'
             , N'U') is not null
  drop table [unbreakable_code].[flower];

go

create table [unbreakable_code].[flower]
  (
     [id]       [int] identity(1, 1) not null primary key clustered
     , [flower] [sysname],
          constraint [unbreakable_code.flower.flower.unique] unique ([flower])
     , [color]  [sysname]
  );

go 
