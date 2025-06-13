-- Retrieve the different cached Execution Plans

dbcc freeproccache
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;



SELECT
	st.text, 
	qp.query_plan, 
	qs.*
From sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE  text like '%cust%'