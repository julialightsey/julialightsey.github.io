/*
*/
begin transaction;

begin
    declare @category    [sysname]=N'@category',
            @class       [sysname]=N'@class',
            @type        [sysname]=N'@type',
            @entry       [xml]=N'<entry />',
            @test_entry  [xml],
            @description [nvarchar](max)=N'@description',
            @persistent  [bit] = 0,
            @timestamp   [datetime]=current_timestamp,
            @identity    [uniqueidentifier];

    execute [report].[set]
      @category =@category,
      @class =@class,
      @type =@type,
      @entry =@entry,
      @description =@description,
      @persistent =@persistent,
      @timestamp =@timestamp,
      @identity =@identity output;

    select [report].[get_entry] (@identity
                                 , null
                                 , null
                                 , null
                                 , null
                                 , null);
end;

rollback; 
