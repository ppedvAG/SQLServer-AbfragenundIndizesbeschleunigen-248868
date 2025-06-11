/*

Große Tabellen kleiner machen Idee

1) part. Sicht
2) Partitionierung


zu 1)
statt einer tabelle viele kleinere Tabellen
Sicht die alle Tabellen mit UNION ALL zusammenfasst
damit wir einen Vorteil haben: CHECK Einschränkungen jahr=2020
--das hilft dem Plan genau einer der Tabellen der Sicht herauszupicken

negativ: hilft nur wenn die entspr Spalte auch im where abgefragt
         umständllich

		 das geht nicht: identity, PK FK muss angepasst-- Referentielle Integrität

zu 2)
	es bleibt die Tabelle

	man braucht:
		function
		
		create partition function fname (datentyp)
		as
		RANGE LEFT |RIGHT for Values(Grenzwert1, Grenzwert2,..)

		--Returnwert: 1 , 2, 3, 4...

		Part-Schema

		create partition scheme SchName
		as
		partition fname to (Dgruppe1, Dgruppe2, ...)
		---                       1      2

				Tabelle  liegt auf Schema

		create table tabellename (id int, ...) ON SchName(Spalte)

		+ Flexibel
		 Grenze dazu : 
		 alter partition scheme schName next used Dgruppe

		 alter partition function fname() split range (grenzwert)
		 

		 Grenze entfernen
		 alter partition function fName merge range (grenzwert)

		 einz. Part. können komprimiert

		 Archivieren

		 alter table tabName switch partition ZAHL to ArchivTab
		 aber es muss gelten: Archivschema  muss exakt aussehen wir OrgTabelle
								allerdings identity nein, aber trotzdem not null

							Archiv muss auf selber Dgruppe sein wie partition ZAHL

							Daten werden nicht verschoben, sondern part wird in Tabe umgewandelt


	best Tabelle, die auf einer Dgruppen oder Schema liegen, können nur mit einem Löschen 
	auf andere Dgruppen oder Schemas verschoben werden
	---Ausnahme best Index


































Daten seit dem Jahr 2000 .. Tab Umsatz

TAB A  10000
TAB B  100000

Abfrage, mit 10 zeilen Ergebnis
--welche Tab ist schneller:  A

*/


--Salamitaktiv.. statt einer großen Tabelle viele kleine


--Die Anwendung braucht aber "UMSATZ"


create table u2020(id int identity, jahr int, spx int)

create table u2019(id int identity, jahr int, spx int)

create table u2018(id int identity, jahr int, spx int)

create table u2017(id int identity, jahr int, spx int)




--UMSATZ????
select * from umsatz


--Sicht!!

create view Umsatz
as
select * from u2020
UNION ALL
select * from u2019
UNION ALL
select * from u2018
UNION ALL
select * from u2017


--Messen:
--im Plan: SCAN = A bis Z Suche..komplettes durchwühlen--- SEEK (TOP!!) herauspicken
select * from umsatz where jahr = 2019

--besser durch: Check Constraints
ALTER TABLE dbo.u2017 ADD CONSTRAINT CK_u2017 CHECK (jahr=2017)

ALTER TABLE dbo.u2018 ADD CONSTRAINT CK_u2018 CHECK (jahr=2018)

ALTER TABLE dbo.u2019 ADD CONSTRAINT CK_u2019 CHECK (jahr=2019)

ALTER TABLE dbo.u2020 ADD CONSTRAINT CK_u2020 CHECK (jahr=2020)

select * from umsatz where jahr = 2019
select * from umsatz where id = 2019


--auch NOT NULL ist cool...


--INS UP DEL auf Sichten
---ja, aber nicht immer

insert into umsatz (id,jahr, spx) values(1,2017, 100)

--fordert einen PK für alle Tabellen.. Der DS muss auf die Sicht eindeutig sein
--Identity muss raus
--jetzt muss aber der ID Wert manuell gefüllt werden

-- Jetzt ist die Anw draussen!!

--Sequenzen
USE [testdb]

CREATE SEQUENCE [dbo].[UID] 
 START WITH 2
 INCREMENT BY 1

select next value for UID


insert into umsatz (id,jahr, spx) values(next value for UID,2018, 100)


select * from umsatz

--deutlich flexibler: partitionierung


--Dateigruppe


USE [master]
GO
ALTER DATABASE [testdb] ADD FILEGROUP [HOT]
GO
ALTER DATABASE [testdb] ADD FILE ( NAME = N'testhotdata', FILENAME = N'D:\_SQLDB\testhotdata.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [HOT]
GO



create table t2 (id int) ON HOT

--Lege Dateigruppe HOT mit Datei auf Northwind an.....
--verschiebe die Tabelle Orders auf HOT....??

--geht per Entwurfsansicht in Objektexplorer...  F4 Eigenschaften
--Vorsicht: Löscht Tabelle.. oder ein best IX  CL IX....


---physikalische Part:

------------------100]----------------200]------------------- int
--            1                  2               3


create partition function fZahl(int)
as
RANGE LEFT FOR VALUES (100,200)

select $partition.fZahl(117) --> 2



--Partschema: f() + Dgruppen
--bis100, bis200, rest, bis5000


--part Scheme

create partition scheme schZahl
as
partition fzahl to (bis100,bis200,rest)
----                  1      2      3



create table ptab (id int identity, nummer int, spx char(4100))
		ON schZahl(nummer)

--Datensätze liegen immer dort wo sie lt Funktion und Schema sein müssen..
--insofern werden sie auch verschoben

--Schelife für Insert
set statistics io, time off

declare @i as int = 0

while @i<=20000
	begin 
		insert into ptab values(@i, 'XY')
		set @i+=1
	end

--besser: Plan und stats
set statistics io, time on

select * from ptab where id = 117

select * from ptab where nummer = 117


--hmmm.... neue Grenze

----------------100-----200-----------5000------------------
--  1                 2      3                 4


--Tabelle, F() Scheme
--schema, f(),  Tabelle nie

--F braucht neue Grenze

alter partition scheme schZahl next used bis5000

select $partition.fZahl(nummer), min(nummer), max(nummer), count(*)
from ptab group by $partition.fzahl(nummer)

--bisher noch ekein physik. Änderung

alter partition function fzahl() split range(5000)


select $partition.fZahl(nummer), min(nummer), max(nummer), count(*)
from ptab group by $partition.fzahl(nummer)

select * from ptab where nummer = 6117


-----100!----------------200------------5000--------------

--evtl mal Grenze rausnehmen
--f()!, scheme nö, Tab nö


/****** Object:  PartitionScheme [schZahl]    Script Date: 09.12.2020 14:17:10 ******/
CREATE PARTITION SCHEME [schZahl] AS
PARTITION [fZahl] TO ([bis100], [bis200], [bis5000], [rest])

/****** Object:  PartitionFunction [fZahl]    Script Date: 09.12.2020 14:17:31 ******/
CREATE PARTITION FUNCTION [fZahl](int)
AS 
RANGE LEFT FOR VALUES (100, 200, 5000)
GO

alter partition function fzahl() merge range (100)


select * from ptab where nummer = 17


select $partition.fZahl(nummer), min(nummer), max(nummer), count(*)
from ptab group by $partition.fzahl(nummer)



select * from ptab where nummer = 6401
--auch Kompresssion pro Part
ALTER TABLE [dbo].[ptab]
REBUILD PARTITION = 3 
WITH(DATA_COMPRESSION = PAGE )


--Archivieren
--Datensätze müssen aus tab raus und in andere Tab rein

--Verschieben von Datensätze

create table archiv (id int not null,nummer int, spx char(4100))
	ON bis200 --muss auch die DGruppe, auf der die part liegt..


alter table ptab switch partition 1 to archiv

select * from archiv

select $partition.fZahl(nummer), min(nummer), max(nummer), count(*)
from ptab group by $partition.fzahl(nummer)


--100MB/Sek
--bis200 100000000 MB --> dauer: 10 Sek  nö... ca 1 ms


CREATE PARTITION SCHEME [schZahl] AS
PARTITION [fZahl] TO ([bis100], [bis200], [bis5000], [rest])

/****** Object:  PartitionFunction [fZahl]    Script Date: 09.12.2020 14:17:31 ******/
CREATE PARTITION FUNCTION [fZahl](datetime)
AS 
RANGE LEFT FOR VALUES ('31.12.2019 23:59:59.997','1.1.2020','')
GO ---------------------------korrekt               falsch

--A bis M     N bis R   S bis Z
CREATE PARTITION FUNCTION [fZahl](varchar(50))
AS 
RANGE LEFT FOR VALUES ('N','RZZZZZZZZZZZZZZZZZ') --kein Wildcards
GO


CREATE PARTITION FUNCTION [fZahl](date)
AS 
RANGE LEFT FOR VALUES (Getdate()-30, getdate()+30)
GO
´--nicht sinnvoll


CREATE PARTITION SCHEME [schZahl] AS
PARTITION [fZahl] TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])

--primary ja..geht. ..und macht Sinn, da wir es wie viele kleine Tabellen behandeln
--ab SQL 2016 Sp1 auch in Std oder sogar Express

