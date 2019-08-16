SELECT [dm_exec_sql_text].[text]
       , *
FROM   [sys].[dm_tran_active_transactions] AS [dm_tran_active_transactions]
       JOIN [sys].[dm_tran_session_transactions] AS [dm_tran_session_transactions]
         ON [dm_tran_session_transactions].[transaction_id] = [dm_tran_active_transactions].[transaction_id]
       LEFT JOIN [sys].[dm_exec_sessions] AS [dm_exec_sessions]
              ON [dm_exec_sessions].[session_id] = [dm_tran_session_transactions].[session_id]
       LEFT JOIN [sys].[dm_exec_requests] AS [dm_exec_requests]
              ON [dm_exec_requests].[session_id] = [dm_exec_sessions].[session_id]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_requests].[sql_handle]) AS [dm_exec_sql_text];
