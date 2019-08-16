USE [chamomile];

go

DECLARE @timestamp               DATETIMEOFFSET = sysdatetimeoffset()
        , @count                 DECIMAL(10, 4) = 0
        , @seconds               DECIMAL(10, 4)
        , @retrievals_per_second DECIMAL(10, 4);

EXECUTE [queue].[pop] @count=@count output;

SELECT @seconds = cast(DATEDIFF(MILLISECOND, @timestamp, SYSDATETIMEOFFSET()) AS DECIMAL(10, 4)) / 1000;

IF @seconds > 0
  SELECT @retrievals_per_second = @count / @seconds;

SELECT @seconds                 AS [seconds]
       , @count                 AS [count]
       , @retrievals_per_second AS [retrievals_per_second];

SELECT count(*) AS [oltp_queue_count]
FROM   [chamomile].[dbo].[oltp_queue]; 
