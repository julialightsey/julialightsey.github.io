use [chamomile];

go

declare @recvreplymsg nvarchar(100);
declare @recvreplydlghandle uniqueidentifier;

begin transaction;

waitfor ( receive top(1) @recvreplydlghandle = conversation_handle, @recvreplymsg = message_body from initiatorqueueintact ), timeout 5000;

end conversation @recvreplydlghandle;

-- Display recieved request.
select @recvreplymsg as receivedreplymsg;

commit transaction;

go 
