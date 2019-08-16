USE [chamomile];

go

DECLARE @timestamp           DATETIMEOFFSET = sysdatetimeoffset()
        , @count             INT = 1000
        , @seconds           DECIMAL(10, 4)
        , @pushes_per_second DECIMAL(10, 4)
        , @bytes_per_second  DECIMAL(10, 4)
        , @object_size       INT;
DECLARE @object XML = N'<object_list>
  <object>
    <color>red</color>
    <size>large</size>
    <description>Something bigger than small but smaller than massive.</description>
    <category>
	   <shelf>1</shelf>
	   <aisle>3</aisle>
	   <warehouse>St. Louis, MO</warehouse>
	   <manager>Greg</manager>
    </category>
  </object>
</object_list>';

SELECT @object_size = DATALENGTH(@object);

EXECUTE [queue].[push] @count    =@count
                       , @object = @object;

SELECT @seconds = cast(DATEDIFF(MILLISECOND, @timestamp, SYSDATETIMEOFFSET()) AS DECIMAL(10, 4)) / 1000;

IF @seconds > 0
  BEGIN
      SELECT @pushes_per_second = @count / @seconds
             , @bytes_per_second = @object_size / @seconds;
  END;

SELECT @seconds             AS [seconds]
       , @count             AS [count]
       , @object_size       AS [object_size]
       , @pushes_per_second AS [pushes_per_second]
       , @bytes_per_second  AS [bytes_per_second];

SELECT count(*) AS [oltp_queue_count]
FROM   [chamomile].[dbo].[oltp_queue]; 
