use [utility];

go

if object_id(N'[test].[truncate_deadlock_01]', N'U') is not null
  drop table [test].[truncate_deadlock_01];

go

create table [test].[truncate_deadlock_01]
  (
     [id]      [int] identity(1, 1)
     , [value] [sysname]
  );

go

insert into [test].[truncate_deadlock_01]
            ([value])
values      (N'red'),
            (N'white'),
            (N'blue');

go

set transaction isolation level serializable;

begin transaction;

select *
from   [test].[truncate_deadlock_01];

rollback

commit; 
