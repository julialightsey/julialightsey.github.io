/*
    http://vyaskn.tripod.com/differences_between_set_and_select.htm
    http://stackoverflow.com/questions/3945361/t-sql-set-versus-select-when-assigning-variables

    SET is the ANSI standard for variable assignment, SELECT is not.
    SET can only assign one variable at a time, SELECT can make multiple assignments at once.
    If assigning from a query, SET can only assign a scalar value. If the query returns multiple values/rows then SET will raise an error. SELECT will assign one of the values to the variable and hide the fact that multiple values were returned (so you'd likely never know why something was going wrong elsewhere - have fun troubleshooting that one)
    When assigning from a query if there is no value returned then SET will assign NULL, where SELECT will not make the assignment at all (so the variable will not be changed from it's previous value)
    As far as speed differences - there are no direct differences between SET and SELECT. However SELECT's ability to make multiple assignments in one shot does give it a slight speed advantage over SET.
*/
declare @var varchar(20)

set @var = 'Joe'
set @var = (select name
            from   master.sys.tables
            where  name = 'qwerty')

select @var /* @var is now NULL */
set @var = 'Joe'

select @var = name
from   master.sys.tables
where  name = 'qwerty'

select @var /* @var is still equal to 'Joe' */
