
-- Modify all files to replace database [chamomile] with the desired database for testing.
-- Create the test objects: execute scripts:
	-- setup.queue.sql 	- Create the service, contract, and queue for testing.
	-- queue.push.sql	- Create the procedure to push objects onto the queue.
	-- queue.pop.sql	- Create the procedure to pop the objects off of the queue.

-- Run tests:
	-- Execute push_test.small_object.sql and examine the results. This gives the time required to push small objects onto the queue.
		-- Execute pop_test.object.sql and examine the results. This gives the time required to pop objects off of the queue.
	-- Execute push_test.large_object.sql and examine the results. This gives the time required to push large objects onto the queue.
		-- Execute pop_test.object.sql and examine the results. This gives the time required to pop objects off of the queue.