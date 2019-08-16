/* 
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com) 1959-2015 (aka; my life), 
		all rights reserved. 
	All software contained herein is licensed as [chamomile] (http://www.ChamomileSQL.com/license.html)
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
  --------------------------------------------- 

  -- 
  --  description 
  --------------------------------------------- 
	This presentation covers the "create table" portion of the referenced exam.

	70-461 Querying Microsoft SQL Server 2012 - Troubleshoot and optimize (25%)
		Optimize queries
		Understand statistics; read query plans; plan guides; DMVs; hints; statistics IO; 
			dynamic vs. parameterized queries; describe the different join types (HASH, 
			MERGE, LOOP) and describe the scenarios they would be used in.

  -- 
  --  notes 
  --------------------------------------------- 
    this presentation is designed to be run incrementally a code block at a time.  
    code blocks are delineated as: 

    -- 
    -- code block begin 
    ----------------------------------------- 
       
    ----------------------------------------- 
    -- code block end 
    -- 
   
  -- 
  -- references 
  --------------------------------------------- 
  Join Hints (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms173815.aspx
  Advanced Query Tuning Concepts - https://technet.microsoft.com/en-US/library/ms191426(v=SQL.105).aspx
  Understanding Nested Loops Joins - https://technet.microsoft.com/en-US/library/ms191318(v=sql.105).aspx
  Understanding Merge Joins - https://technet.microsoft.com/en-US/library/ms190967(v=sql.105).aspx
  Understanding Hash Joins - https://technet.microsoft.com/en-US/library/ms189313(v=sql.105).aspx
  Query Tuning - https://msdn.microsoft.com/en-us/library/ms176005(v=SQL.100).aspx
*/
-- 
-- code block begin 
-------------------------------------------------
if schema_id(N'flower') is null
  execute (N'create schema flower');

go 
