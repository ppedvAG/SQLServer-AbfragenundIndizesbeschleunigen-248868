--Wichtige Katalogsichten des Query Stores:
sys.query_store_query: Enthält Informationen über die Abfragen, die vom Query Store erfasst wurden.
sys.query_store_plan: Beinhaltet Informationen zu den Ausführungsplänen der Abfragen.
sys.query_store_runtime_stats: Liefert Leistungsdaten (Laufzeitstatistiken) der Abfragen.
sys.query_store_runtime_stats_interval: Zeigt die Zeitintervalle, in denen die Leistungsdaten aggregiert werden.
sys.query_store_query_text: Speichert den tatsächlichen Text der Abfragen.
--Beispiele für T-SQL-Abfragen:

--1. Abfragen der am meisten verwendeten SQL-Abfragen
--Diese Abfrage gibt eine Liste der Abfragen mit der höchsten Ausführungszeit zurück:

SELECT 
    qsqt.query_sql_text,
    SUM(qrs.count_executions) AS execution_count,
    SUM(qrs.count_executions * qrs.avg_logical_io_reads) AS total_logical_reads,
    SUM(qrs.count_executions * qrs.avg_logical_io_writes) AS total_logical_writes,
    SUM(qrs.count_executions * qrs.avg_cpu_time) AS total_cpu_time,
    SUM(qrs.count_executions * qrs.avg_duration) AS total_duration
FROM 
    sys.query_store_query_text AS qsqt
INNER JOIN 
    sys.query_store_query AS qsq ON qsqt.query_text_id = qsq.query_text_id
INNER JOIN 
    sys.query_store_plan AS qsp ON qsq.query_id = qsp.query_id
INNER JOIN 
    sys.query_store_runtime_stats AS qrs ON qsp.plan_id = qrs.plan_id
GROUP BY 
    qsqt.query_sql_text
ORDER BY 
    execution_count DESC;




--Ja, der Query Store kann mithilfe von T-SQL-Abfragen genutzt werden, um Informationen über Abfragen, Ausführungspläne und Leistungsdaten abzurufen. Der SQL Server speichert diese Informationen in speziellen Query Store-Katalogsichten, die für Abfragen zur Verfügung stehen.

--Wichtige Katalogsichten des Query Stores:
sys.query_store_query: Enthält Informationen über die Abfragen, die vom Query Store erfasst wurden.
sys.query_store_plan: Beinhaltet Informationen zu den Ausführungsplänen der Abfragen.
sys.query_store_runtime_stats: Liefert Leistungsdaten (Laufzeitstatistiken) der Abfragen.
sys.query_store_runtime_stats_interval: Zeigt die Zeitintervalle, in denen die Leistungsdaten aggregiert werden.
sys.query_store_query_text: Speichert den tatsächlichen Text der Abfragen.
--Beispiele für T-SQL-Abfragen:

--1. Abfragen der am meisten verwendeten SQL-Abfragen
--Diese Abfrage gibt eine Liste der Abfragen mit der höchsten Ausführungszeit zurück:
SELECT TOP 10 
    ROUND(CONVERT(FLOAT, SUM(rs.avg_duration * rs.count_executions)) / NULLIF(SUM(rs.count_executions), 0), 2) AS avg_duration_ms,
    SUM(rs.count_executions) AS total_execution_count,
    qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    p.plan_id,
    MAX(rs.last_execution_time) AS last_execution_time
FROM 
    sys.query_store_query_text AS qt
INNER JOIN 
    sys.query_store_query AS q ON qt.query_text_id = q.query_text_id
INNER JOIN 
    sys.query_store_plan AS p ON q.query_id = p.query_id
INNER JOIN 
    sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
-- Optional: Zeitraum einschränken, z.B. auf die letzte Stunde
-- WHERE rs.last_execution_time > DATEADD(HOUR, -1, GETUTCDATE())
GROUP BY 
    qt.query_sql_text, q.query_id, qt.query_text_id, p.plan_id
ORDER BY 
    avg_duration_ms DESC;




--2. Abfrage der regressiven Pläne
--Diese Abfrage zeigt, welche Abfragen einen schlechteren Plan bekommen haben:

WITH PlanPerformance AS (
    SELECT
        q.query_id,
        qt.query_sql_text,
        p.plan_id,
        MAX(rs.avg_duration) AS max_avg_duration,
        MIN(rs.avg_duration) AS min_avg_duration
    FROM sys.query_store_query AS q
    INNER JOIN sys.query_store_query_text AS qt ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
    INNER JOIN sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
    GROUP BY q.query_id, qt.query_sql_text, p.plan_id
),
RegressionCandidates AS (
    SELECT
        query_id,
        query_sql_text,
        MAX(max_avg_duration) AS aktuelle_max_avg_duration,
        MIN(min_avg_duration) AS historische_min_avg_duration
    FROM PlanPerformance
    GROUP BY query_id, query_sql_text
)
SELECT
    query_id,
    query_sql_text,
    aktuelle_max_avg_duration / 1000.0 AS aktuelle_max_avg_duration_ms,
    historische_min_avg_duration / 1000.0 AS historische_min_avg_duration_ms,
    (aktuelle_max_avg_duration - historische_min_avg_duration) / 1000.0 AS differenz_ms,
    CASE 
        WHEN aktuelle_max_avg_duration > historische_min_avg_duration * 1.5 
        THEN 'Regression möglich'
        ELSE 'Keine Regression'
    END AS regression_status
FROM RegressionCandidates
WHERE aktuelle_max_avg_duration > historische_min_avg_duration * 1.5
ORDER BY differenz_ms DESC;





--3. Ausführungspläne anzeigen
--Diese Abfrage zeigt die Ausführungspläne für eine bestimmte Abfrage basierend auf ihrer Query-ID:

declare @queryid int = 1110
SELECT 
    p.plan_id,
    p.query_id,
    p.engine_version,
    p.compatibility_level,
    p.is_forced_plan,
    p.last_execution_time,
    TRY_CAST(p.query_plan AS XML) AS query_plan_xml,
    SUM(rs.count_executions) AS total_executions,
    SUM(rs.count_executions * rs.avg_duration) / NULLIF(SUM(rs.count_executions), 0) AS avg_duration,
    SUM(rs.count_executions * rs.avg_cpu_time) / NULLIF(SUM(rs.count_executions), 0) AS avg_cpu_time,
    SUM(rs.count_executions * rs.avg_logical_io_reads) / NULLIF(SUM(rs.count_executions), 0) AS avg_logical_io_reads,
    SUM(rs.count_executions * rs.avg_logical_io_writes) / NULLIF(SUM(rs.count_executions), 0) AS avg_logical_io_writes
FROM 
    sys.query_store_plan AS p
JOIN 
    sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
WHERE 
    p.query_id = @QueryId
GROUP BY
    p.plan_id, p.query_id, p.engine_version, p.compatibility_level, p.is_forced_plan, p.last_execution_time, p.query_plan
ORDER BY 
    avg_duration DESC;

--Welche Abfrage hat mehr Pläne
SELECT 
    query_id,
    COUNT(plan_id) AS plan_count
FROM 
    sys.query_store_plan
GROUP BY 
    query_id
HAVING 
    COUNT(plan_id) > 1
ORDER BY 
    plan_count DESC;

--Abfragen mit hohen Abweichungen
SELECT 
    q.query_id,
    qt.query_sql_text,
    COUNT(DISTINCT p.plan_id) AS plan_count,
    MAX(rs.max_duration) / 1000.0 AS max_duration_ms,
    MIN(rs.min_duration) / 1000.0 AS min_duration_ms,
    (MAX(rs.max_duration) - MIN(rs.min_duration)) / 1000.0 AS duration_diff_ms
FROM 
    sys.query_store_query AS q
INNER JOIN 
    sys.query_store_query_text AS qt ON q.query_text_id = qt.query_text_id
INNER JOIN 
    sys.query_store_plan AS p ON q.query_id = p.query_id
INNER JOIN 
    sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
GROUP BY 
    q.query_id, qt.query_sql_text
HAVING 
    (MAX(rs.max_duration) - MIN(rs.min_duration)) > 100000 -- z.B. nur Abfragen mit >100s Differenz
ORDER BY 
    duration_diff_ms DESC;

