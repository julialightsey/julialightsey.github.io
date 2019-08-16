/*
    KELightsey@gmail.com
    20180623
    This script creates the test objects required for the unit_test presentation.
    Note that this script is simplistic in many respects. The objects contain little or no error handling
	   and the mechanism for populating sample data is not robust. The purpose in this script is not
	   to demonstrate best practices for creating and managing these types of objects. It is only to 
	   create sample objects and data on which a test harness can be created and demonstrated.
*/
--
-- change to an appropriate test database
-------------------------------------------------
-------------------------------------------------
use [chamomile];

go

--
-- enable database for snapshot isolation level, or use serializable
-------------------------------------------------
-------------------------------------------------
alter database [chamomile]

set READ_COMMITTED_SNAPSHOT on;

GO

alter database [chamomile]

set ALLOW_SNAPSHOT_ISOLATION on;

GO

--
-- create the schemas for the objects
-------------------------------------------------
-------------------------------------------------
if schema_id(N'account') is null
  execute (N'create schema account');

go

if schema_id(N'person') is null
  execute (N'create schema person');

go

--
-- create test object and data
-------------------------------------------------
-------------------------------------------------
if object_id(N'[account].[primary]', N'U') is not null
  drop table [account].[primary];

go

if object_id(N'[person].[primary]', N'U') is not null
  drop table [person].[primary];

go

--
-------------------------------------------------
create table [person].[primary] (
  [id]               [int] identity(1, 1) not null,
    constraint [person__primary__id__pk] primary key clustered ([id])
  , [first_name]     [nvarchar](128) not null
  , [last_name]      [nvarchar](128) not null
  , [middle_initial] [nvarchar](1) null
  , [date_of_birth]  [date] not null
  , [age] as datediff(year, [date_of_birth], current_timestamp) - case
                                                              when dateadd(year, datediff(year, [date_of_birth], current_timestamp), [date_of_birth]) > current_timestamp then 1
                                                              else 0
                                                            end
  );

go

--
-------------------------------------------------
create table [account].[primary] (
  [id]           [int] identity(1, 1) not null,
    constraint [account__primary__id__pk] primary key clustered ([id])
    , [type]       [sysname] constraint [account__primary__type__ck] check ([type] in (N'savings', N'checking', N'money_market'))
    , [person__id] [int]
    constraint [account__primary__person__id__fk] foreign key ([person__id]) references [person].[primary]([id])
  , [open_date]  [datetime] constraint [account__primary__open_date__df] default (current_timestamp)
  );

go

--
-- populate sample data
-------------------------------------------------
-------------------------------------------------
insert into [person].[primary]
            ([first_name],[last_name],[middle_initial],[date_of_birth])
values      (N'Bob',N'Smith',null,N'1999-01-25'),
            (N'Sally',N'Brown',N'T',N'1959-12-07'),
            (N'Janet',N'Brockman',N'B',N'1983-10-21');

go

--
-- Bob Smith gets one of each of the three types of accounts
-------------------------------------------------
declare @person__id [int] = (select top(1) [id]
   from   [person].[primary]
   where  [first_name] = N'Bob'
          and [last_name] = N'Smith');

insert into [account].[primary]
            ([type],[person__id])
values      (N'savings',@person__id),
            (N'checking',@person__id),
            (N'money_market',@person__id);

--
-- Sally Brown gets a savings and checking account
-------------------------------------------------
select @person__id = (select top(1) [id]
                      from   [person].[primary]
                      where  [first_name] = N'Sally'
                             and [last_name] = N'Brown');

insert into [account].[primary]
            ([type],[person__id])
values      (N'savings',@person__id),
            (N'checking',@person__id);

--
-- Janet Brockman gets no accounts
-------------------------------------------------
--
-- [person].[get_age] retrieves the age of a person from the calculated column.
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
if object_id(N'[person].[get_age]', N'P') is not null
  drop procedure [person].[get_age];

go

create procedure [person].[get_age] @id    [int]
                                    , @age [int] output
as
  begin
      select @age = [age]
      from   [person].[primary]
      where  [id] = @id;
  end;

go

--
-- [account].[get_list] retrieves an [xml] object with a list of accounts]
--  for a given person based on id.
-------------------------------------------------
if object_id(N'[account].[get_list]', N'P') is not null
  drop procedure [account].[get_list];

go

create procedure [account].[get_list] @id       [int]
                                      , @output [xml] output
as
  begin
      set @output = (select [person].[first_name]  as N'@first_name'
                            , [person].[last_name] as N'@last_name'
                            , [person].[id]        as N'@person__id'
                            , [account].[id]       as N'@account__id'
                            , [account].[type]     as N'@account__type'
                     from   [account].[primary] as [account]
                            join [person].[primary] as [person]
                              on [person].[id] = [account].[person__id]
                     where  [person].[id] = @id
                     for xml path(N'account'), root(N'account_list'));
  end;

go 


--
-- create mutator/setter object
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
--
-- [person].[set_date_of_birth] sets the date of birth for a person.
-------------------------------------------------
if object_id(N'[person].[set_date_of_birth]', N'P') is not null
  drop procedure [person].[set_date_of_birth];

go

create procedure [person].[set_date_of_birth] @id              [int]
                                              , @date_of_birth [date]
as
  begin
      update [person].[primary]
      set    [date_of_birth] = @date_of_birth
      where  [id] = @id;
  end;

go

--
-- [person].[set_account] creates or updates an account for a person
-------------------------------------------------
if object_id(N'[person].[set_account]', N'P') is not null
  drop procedure [person].[set_account];

go

create procedure [person].[set_account] @id          [int]
                                        , @open_date [date]
as
  begin
      update [account].[primary]
      set    [open_date] = @open_date
      where  [person__id] = @id;
  end;

go

--
-- [account].[get_age] gets the age of an account.
-------------------------------------------------
if object_id(N'[account].[get_age]', N'P') is not null
  drop procedure [account].[get_age];

go

create procedure [account].[get_age] @account__id  [int] = null
                                     , @person__id [int] = null
                                     , @age        [int] output
as
  begin
      select @age = datediff(year, [open_date], current_timestamp) - case
                                                                       when dateadd(year, datediff(year, [open_date], current_timestamp), [open_date]) > current_timestamp then 1
                                                                       else 0
                                                                     end
      from   [account].[primary] as [account]
             join [person].[primary] as [person]
               on [person].[id] = [account].[person__id]
      where  ( [account].[id] = @account__id
                or @account__id is null )
             and ( [account].[person__id] = @person__id
                    or @person__id is null );
  end;

go 
