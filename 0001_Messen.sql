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

M�glichkeiten:  Prozeduren, Plan Cache

Ziel:  logische Lesevorg�nge:  sollte weniger werden


---Ausf�hrungspl�ne

--Gesch�tzter Plan: Plan vor Abfrage 
--je dicker der Pfeil, desto mehr Datens�tze


--SORT
--JOIN
--IX SCAN oder SEEK
--Table SCAN

--SCAN = Alles
--SEEK = etwas gezielt herauspicken

--UNterschiede zwischen tats. Datens�tzen und gesch�tzten Datens�tzen

--QueryStore
--Sammlt Abfragen auf Dauer...
inklusive IO, RAM, CPU, Pl�ne

gibt es ab SQL 2016 und muss dort aktiviert werden (pro DB)
ab SQL 2022 standardm��ig aktiviert



