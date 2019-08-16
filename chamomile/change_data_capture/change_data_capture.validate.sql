
if object_id(N'[change_data_capture].[validate]', N'P') is not null
	drop procedure [change_data_capture].[validate];
go
/*
	declare @total_row_count [int];
	execute [change_data_capture].[validate] @total_row_count=@total_row_count output;
	select @total_row_count as [total_row_count];
	if @total_row_count > 0 
		raiserror(N'Failed - Not all change tables were mined successfully.', 16, 1);
*/
create procedure [change_data_capture].[validate]  @total_row_count [int] = 0 output
as
	begin
		declare @count            [int] = 0, 
				@capture_instance [sysname],
				@change_table     [sysname], 
				@suffix           [sysname]=N'_CT', 
				@prefix           [sysname]=N'[cdc].',
				@sql              [nvarchar](MAX), 
				@parameters       [nvarchar](max) = N'@change_table [sysname], @count [int] output';
				
		set @total_row_count = coalesce(@total_row_count, 0);
	
		declare [change_table_cursor] cursor for 
		  select [capture_instance] 
		  from   [cdc].[change_tables]; 

		open [change_table_cursor]; 

		fetch NEXT from [change_table_cursor] into @capture_instance; 

		while @@FETCH_STATUS = 0 
		  begin 
			  set @change_table = @prefix 
								  + quotename(@capture_instance + @suffix, N']'); 
			  set @sql =N'select @count = (select count(*) from ' 
						+ @change_table + N');'; 

			  execute [sys].[sp_executesql] 
				@sql = @sql, 
				@parameters = @parameters, 
				@change_table = @change_table, 
				@count = @count output; 
			  
			  set @total_row_count = @total_row_count + coalesce(@count, 0);

			  fetch NEXT from [change_table_cursor] into @capture_instance; 
		  end; 

		close [change_table_cursor]; 

		deallocate [change_table_cursor];
	end;
go