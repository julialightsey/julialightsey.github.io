/*

*/
--
-------------------------------------------------
select @@trancount as N'before begin';

begin transaction;

select @@trancount as N'after begin transaction';

commit transaction;

select @@trancount as N'after commit transaction';

--
-------------------------------------------------
select @@trancount as N'before begin';

begin transaction [transaction_test];

select @@trancount as N'after begin transaction_test';

commit transaction [transaction_test];

select @@trancount as N'after commit transaction_test';

--
-- nested transactions
-- note that the external transaction is rolled back as well
-------------------------------------------------
select @@trancount as N'before begin';

begin transaction [transaction_test];

begin
    select @@trancount as N'after begin transaction_test';

    begin transaction [nested_transaction];

    select @@trancount as N'after begin nested_transaction';

    rollback;
end;

commit transaction [transaction_test];

select @@trancount as N'after commit transaction_test';

--
-- nested transactions
-- error: Cannot roll back nested_transaction. No transaction or savepoint of that name was found.
-------------------------------------------------
select @@trancount as N'before begin';

begin transaction [transaction_test];

begin
    select @@trancount as N'after begin transaction_test';

    begin transaction [nested_transaction];

    select @@trancount as N'after begin nested_transaction';

    rollback transaction [nested_transaction];
end;

commit transaction [transaction_test];

select @@trancount as N'after commit transaction_test'; 
