/*


	truncate table unbreakable_code.flower
    declare @error_stack xml;
    execute [unbreakable_code].[set_flower]
      @flower       =N'red'
      , @color      ='white'
      , @error_stack=@error_stack output
    select @error_stack as N'@error_stack';
    select *
    from   [unbreakable_code].[flower]; 
    
    
    


	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		a demonstration of the technique required to implement transactions
		in production code while allowing unit unbreakable_codeing without impacting production state. 
		This is referred to as non-destructive unbreakable_codeing.

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

		sys.dm_tran_active_transactions requires VIEW SERVER STATE permission on the server.
	
	--
	-- references
	---------------------------------------------
		sys.dm_tran_active_transactions (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms174302.aspx
		Unit testing - http://en.wikipedia.org/wiki/Unit_unbreakable_codeing
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'unbreakable_code') is null
  execute (N'create schema unbreakable_code');

go

-------------------------------------------------
-- code block end
--
if object_id(N'[unbreakable_code].[set_flower]'
             , N'P') is not null
  drop procedure [unbreakable_code].[set_flower];

go

--
-- code block begin
-------------------------------------------------
create procedure [unbreakable_code].[set_flower] @flower        [sysname]
                                                 , @color       [sysname]
                                                 , @stack       [xml] = null output
                                                 , @error_stack [xml] = null output
as
  begin
      set transaction isolation level serializable;
      set nocount on;

      declare @message             [nvarchar](max),
              @application_message [xml]
              --
              -- create unique transaction name, must be 32 characters or less
              -- todo - necessary for parallel operations?
              -----------------------------------
              ,
              @transaction         [nvarchar](32) = N'set_flower_'
                + cast(round(rand()*100000, -1) as [sysname])
                + N'_'
                + cast(datepart(millisecond, current_timestamp) as [sysname]);

      set @error_stack = null;

      --
      -- Check to see if there is an existing transaction in this context. Only if there is not
      --	do we start a new transaction.
      -- Name the transaction so we can easily find it when we need to rollback or commit.
      -------------------------------------------
      if @@trancount = 0
        begin
            begin transaction @transaction;

            select N'began transaction (' + @transaction
                   + N') ((' + object_schema_name(@@procid)
                   + N'].[' + + object_name(@@procid) + N'])';
        end;

      begin try
          insert into [unbreakable_code].[flower]
                      ([flower],
                       [color])
          values      (@flower,
                       @color);

          --
          -- Only commit the transaction starting within THIS procedure!
          -- Using @@trancount will cause the calling unit unbreakable_code to fail
          -- as a non-descriminate rollback will rollback the calling
          -- transaction. Then, when the unit unbreakable_code tries to rollback it
          -- will throw an error with a "transaction not found for rollback"
          -------------------------------------------
          if exists (select *
                     from   [sys].[dm_tran_active_transactions]
                     where  [name] = @transaction)
            begin
                select N'in process commit transaction ('
                       + @transaction + N') (('
                       + object_schema_name(@@procid) + N'].[' +
                       + object_name(@@procid) + N'])';

                commit transaction @transaction;
            end;
      end try

      begin catch
          --
          -- Only rollback the transaction starting within THIS procedure!
          ---------------------------------------
          set @application_message = N'<application_message>
			<parameters>
				<flower>' + @flower + '</flower>
				<color>' + @color
                                     + N'</color>
			</parameters></application_message>';

          execute [utility].[handle_error]
            @procedure_id = @@procid,
            @application_message = @application_message,
            @stack =@error_stack output;

          --
          ---------------------------------------
          if exists (select *
                     from   [sys].[dm_tran_active_transactions]
                     where  [name] = @transaction)
            begin
                select N'out of process rollback transaction ('
                       + @transaction + N') (('
                       + object_schema_name(@@procid) + N'].[' +
                       + object_name(@@procid) + N'])';

                rollback transaction @transaction;
            end;
      end catch
  end

go
-------------------------------------------------
-- code block end
--
