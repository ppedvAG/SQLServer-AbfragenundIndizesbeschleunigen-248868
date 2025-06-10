/*

MESSEN


*/

set statistics io, time on --kostet
--Anzahl der Seiten
--CPU Dauer in ms
--Dauer in ms
--Anlayse und Kompilierzeit in ms
--Gilt nur in der aktuellen Session

set statistics io, time off

select * from sysmessages where msglangid = 1031

/*

SQL Server-Analyse- und Kompilierzeit: 
, CPU-Zeit = 0 ms, verstrichene Zeit = 2 ms.

sollte immer 0 sein

Möglichkeiten:  Prozeduren, Plan Cache

Ziel:  logische Lesevorgänge:  sollte weniger werden


---Ausführungspläne

--Geschätzter Plan: Plan vor Abfrage 
--je dicker der Pfeil, desto mehr Datensätze


--SORT
--JOIN
--IX SCAN oder SEEK
--Table SCAN

--SCAN = Alles
--SEEK = etwas gezielt herauspicken

--UNterschiede zwischen tats. Datensätzen und geschätzten Datensätzen

--QueryStore
--Sammlt Abfragen auf Dauer...
inklusive IO, RAM, CPU, Pläne

gibt es ab SQL 2016 und muss dort aktiviert werden (pro DB)
ab SQL 2022 standardmäßig aktiviert



