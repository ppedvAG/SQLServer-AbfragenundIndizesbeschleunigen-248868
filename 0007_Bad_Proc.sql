--Prozeduren sind daher schneller
--da beim ersten Aufruf ein Plan erstellt wird und auch über den Neustart 
--bestehen bleibt

--Allerdings ist gut , aber auch schlecht zugleich
--je nach ABfrage (where Bedingung) kann ein anderer Plan besser sein
--eine Adhoc Abfrage kann sich anpassen
--aber die Prozedur verwendet immer den selben Plan...
--in unsererm Fall 1 Mio Seiten, obwohl die Tabelle nur 56000 besitzt



--Prozeduren sollte nicht benutzerfreundich sein

exec gpSucheKunde 'ALFKI'-- 1 Treffer
exec gpSucheKunde 'A'-- 4 Treffer
exec gpSucheKunde -- alle Treffer

create proc gpSucheKunden @kdid varchar(5)='%'  --A  'A    '
as
select * from customers where customerid like @kdid +'%'

exec gpSucheKunden 'ALFKI'

--das ist schlelt, aber warum??

exec gp_SucheKunden ''

--weiteres Beispiel

set statistics io, time on

select * from ku where id < 900000
--bei 10750 würde SQL Se3rver zu einem Table Scan übergehen
--aber nicht bei einer Prozedur (Ausnahmen: IQP)
create proc gpDemo1 @zahl int
as
select * from ku where id < @zahl;
GO

--besser so (Bsp)
create proc gpDemo1 @zahl int
as
IF @zahl < 10750
exec gpSuchekundenwenige
else
exec gpKundenviele @par
select * from ku where id < @zahl;
GO

--create procedure gpDemo with recompile
create or alter proc gpDemo1 @zahl int --with recompile
as
select * from ku where id < @zahl;
GO


exec gpDemo1 100000






set statistics io, time on


select * from ku where id < 10--56000 500ms

--SCAN A bis Z alles anschauen
--Seek = herauspicken  12 Seiten 0 ms

create or alter proc gpsucheID @id int
as
select * from ku where id < @id


exec gpsucheId 10


select * from ku where id < 11000


exec gpsucheId 100000 -- tab hat 56000 Seiten , aber Proc liest 900000


select * from ku where id < 10

dbcc freeproccache
-- vorsicht damit werden alle Pläne aller DBs gelöscht..
--auch die der Prozeduren.. hohe CPU Last zu erwarten
--aber Prozeduren müssen einen neuen Planb erstellen

--Wo kann man sehr gut schlechte Prozeduren erkennen?
--Abfragespeicher akltivieren..
--Prozeduren sollten keine großen Abweichen haben....

--evtl intervall auf kürzere Zeit einstellen
