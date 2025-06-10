
create table t1 (id int identity, spx char(4100));
GO

insert into t1 
select 'XY';
GO 20000 --22 Sek .. 17 Sek ..20 Sek.. 1 Sekunde


--1 DS hat ca 4kb--> 20000*4kb --> 80MB--> aber 160MB

--Prüfung
dbcc showcontig('t1')
--- Gescannte Seiten.............................: 20000
-- Mittlere Seitendichte (voll).....................: 50.79%


/*

Seite hat 8192 bytes
1 DS muss in Seite passen (hier zählen nur die Längen fixen Datentypen)
1DS mit fixen Längen muss <) 8060 sein
Die Nutzlast der Seite = 8072 bytes
Maximala Anzahl der DS pro Seite = 700

--Blöcke sind 8 Seiten am Stück
--Sperren

jeder nicht genutzte Patz in der Seite ist Verlust auf HDD und RAM

!! SQL Server holt immer komplette Seiten und Blöcke 1:1 in Speicher - ungeachtet wie hoch die Auslastung sein sollte

*/

create table t2 (id int, spx varchar(4100), spy char(4100))










