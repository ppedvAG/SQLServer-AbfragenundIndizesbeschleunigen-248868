
create table t1 (id int identity, spx char(4100));
GO

insert into t1 
select 'XY';
GO 20000 --22 Sek .. 17 Sek ..20 Sek.. 1 Sekunde


--1 DS hat ca 4kb--> 20000*4kb --> 80MB--> aber 160MB

--Pr�fung
dbcc showcontig('t1')
--- Gescannte Seiten.............................: 20000
-- Mittlere Seitendichte (voll).....................: 50.79%


/*

Seiten hat 8192 bytes
Seite muss in der Regel einen ganzen DS  enthalten  (bei fixen L�ngen)

jeder nicht genutze Patz in der Seite ist verlust auf HDD und RAM

*/

create table t2 (id int, spx varchar(4100), spy char(4100))







--Bl�cke sind 8 Seiten am St�ck
--Sperren



