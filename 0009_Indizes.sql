/*
Heap
CL Index = Tabelle
NON CL IX
------------------------------------------
eindeutiger Index  PK --wertvoller Hinweis für SQL, da bei = nur 1 ds existert
						damit wäre der Nicht gruppiertesehr gut geeignet

zusammengesetzter IX --mehr Spalten im where... max 16 Spalten bzw 32 Spalten
				     --meist reichen max 4 Spalten --Das Resultat muss zu einer geringen 
					 --WHERE Spalten

IX mit eingeschlossenen Spalten   ..
						Select ..ca 1023 Spalten MÖGLICH

gefilterter IX			..lohnt sicht, wenn sich die Ebene reduzieren lassen

abdeckender IX -- reine SEEKs ..keine Lookups

ind Sicht --vebunden mit sehr viele Einschränkungen
			Ergebnis der Sicht wird physikalisch abgelegt (gr IX)

realer hypothetischer IX -- DB Optimierungsratgebener erstellt _dta_Indizes 
						-- und löscht diese wieder
						-- Resultat des Ratgebers: welche Indizes sollte man erstellen und welche löschen
						-- auf der Basis eines typischen Workloads


part Index   -- entspricht viele gefilterten Indizes.. jeder fall wird abgdeckt
			 -- bei großen Datenmengen (IX Ebenen > 4 )
			 -- 
------------------------------------------
Columnstore IX (Nicht gr, gruppiert) ..gut für Archivdaten, wenig ändern (ab SQL 2014)
		--INS UP DEL erzeugen Datasätze in Heapstrukturen
		--die erst nach einer best Menge (ca 1 Mio) und in best. Intervallen aufgelöst werden

		--Vorteil: serh hohe Kompression
		--   weniger IO--> weniger RAM-->weniger CPU Verbrauch


IX haben ihre Finger dort drin:
	machen Abfragen schneller
	machen I U D langsamer
	Sperrniveaus sind abhängig von IX
	reduzieren IO /Seiten --> RAM  --> CPU
	toDos
	überflüssige IX entfernen
	fehlende IX  hinzufügen
	Fragemntierung --> defragmentieren




*/

/*
--Nicht gruppierter IX

--gut bei wenigen Ergebniszeilen, je mehr desto schlechter
--Lookup Suche aus dem IX heraus in den HEAP (telefonanruf)
--where .. Suche mit = , vor allem wenn die Spalte eindeutig ist
--ganz schlecht bit Spalten

--> rel wenig!!  kann auch 1% sein
--man kann ca 1000 Nicht gr IX pro Tabelle haben

CL IX gibts nur einmal pro Tabelle

ist besonders geeingnet für Suchen nach Bereichen
ist aber auch gut für eindeutige Werte, was aber der N gr auch sehr gut

*/

--Spieltablle
select * into ku1 from ku

--ID Wert
alter table ku1 add ID int identity

/*
SCAN SEEK

TABLE SCAN

 IX SEEK	IX SCAN
 CL IX SEEK  CL IX SCAN

 Lookup.. Nachschlagen (nur bei N CL IX) .. 1:204:05   Datei:Seite:Slot

*/
--SQL weiss vorher die Anzahl der Ergebnisse.. Statistiken.. Stichproben
--werden erstellt bei IX anlegen oder bei Abfrage mit where und der entspr Spalte
--Entsch: SCAN VS SEEK

select id from ku1 where id = 100 --Table SCAN

select city from ku1 where city = 'Berlin'

select top 3 * from ku1
--muss besser werden: 
select id from ku1 where id = 100 --Table SCAN

--festgelegt: CL IX auf orderdate..also NCL IX auf ID

--NIX_ID
set statistics io, time on
select id from ku1 where id = 100 --IX SEEK --3 von 59420

--IX SEEK --> Lookup --50%  4 Seiten
select id, city from ku1 where id = 100 -- 4 
select id, city from ku1 where id < 100  --105
select id, city from ku1 where id < 12000 --jetzt schon  Table Scan  1% 

--Idee Lookup muss weg
--IX_ID_CI
select id, city from ku1 where id = 100 --3
select id, city from ku1 where id < 100 --3
select id, city from ku1 where id < 120000 --3 --sogar bei 10 % noch Seek

--zusammengesetzter IX bringt nur was, wenn die Spalten im where gefragten
--Limit: max 16 Spalten inm NCL IX zusammengesetz.. max 900bytes

--ohje... IX Seek mit Lookup
--IX mit eingeschl Spalten. zusätzl Spalten werden bei den Pointern hinzugefügt,
--aber nicht im Baum

--IX Seek auf NIX_ID_i_CICY
select id, city, country from ku1 where id = 100

--Jeder PK , den wir setzen, wird als CL IX eindeutig implentiert
--ausser: man hat bereits einen CL IX
--PK: mag eindeutig sein.. wie egal
--man kann den PK (CL IX) per Entwurfsansicht ändenr in N CL IX

select * from customers

insert into customers (CustomerID, CompanyName) values ('pped2', 'Xppedv AG')

--2 Indizes zur Auswahl
select id, city from ku1 where id = 100

--select top 3 * from ku1

--NIX_CY_FR_i_LN_UP_QU
select lastname,sum(unitprice*quantity) from ku1 
		where 
				freight < 5 and country = 'UK'
		group by 
				lastname



--bei oder kein Vorschlag mehr --2 Indizes hier !!
select lastname,sum(unitprice*quantity) from ku1 
		where 
				freight < 5 or country = 'UK'
		group by 
				lastname


--was macht SQL mit AND und OR.. AND wird stärker gebunden
--
select lastname,sum(unitprice*quantity) from ku1 
		where 
				freight < 5 or (country = 'UK' and Productid = 2)
		group by 
				lastname


select lastname,sum(unitprice*quantity) from ku1 
		where 
				(freight < 5 or country = 'UK') and Productid = 2
		group by 
				lastname


select distinct Country from ku1
select distinct City from ku1

select city, count(*) from ku1 group by city


select freight, lastname from ku1 where city = 'Berlin' and freight < 2

--ein gefilterter IX deckt nur einen teil der Daten ab.
--macht Sinn, wenn sich dadurch die Anzahl der Ebenen reduzieren
--aber es wird nur eine Fall betrachtet.. aber die anderen Fälle



select country, count(*) from ku1 group by country

create view v1
as
select country, count(*)as Anz from ku1 group by country

select * from v1 --gleich schnell

Alter view v1 with schemabinding
as
select country,  sum(freight) as Summe from dbo.ku1 group by country

--Amazon: weltweit.. 2000000Mrd .. Umsatz weltweit pro Land


--ind Sicht legt das errechnte Ergbnis und indizert es
--nur die Ent Version , schiebt der Software die Sicht unter
--falls Änderungen anden Daten entstehen--> Sicht muss immer aktuell sein, also auch der IX


---besser

select * into ku2 from ku1
select * into ku3 from ku1


select top 3 * from ku2
--Abfrage mit Agg, where 

--44452 , CPU-Zeit = 516 ms, verstrichene Zeit = 139 ms.
select year(orderdate) as jahr, shipcity, sum(freight) as sum_freight
from ku2 where shipcity like 'G%'
group by orderdate, shipcity

--c  CPU-Zeit = 62 ms, verstrichene Zeit = 58 ms. und 365 Seiten

--nun bei KU3

select year(orderdate) as jahr, shipcity, sum(freight) as sum_freight
from ku3 where shipcity like 'G%'
group by orderdate, shipcity


select year(orderdate) as jahr, shipcity, sum(freight) as sum_freight
from ku3 where shipcountry like 'G%'
group by orderdate, shipcity

--statt 400MB nur 4,5 MB--nach Archivkomperssion: 3 MB---> 1:1 im RAM

--Oberfaul im Staate Dänemark







--CL IX  NCL   CS
/*
CL IX


NCL IX: Kopie der Daten und m des Baumes Leaf (Pointer) 
 ---> Lookup  ..sollte man vermeiden

--> Spalten mit in IX (Schlüsselspalten) im kompletten Baum
	-->16 bzw 900 bytes.. ca 4 ausreichend

--> eingeschlossenen Spalten (nur im Leaf)


CL IX = Tabelle im sortierter Form


Spalten A B C
Anzahl der Indizes: 1000
ABC
A --überflüssig
 ---AB  überflüssig
 --tut bei I U D weh

 TABLE SCAN --- CL IX SCAN
 --eigtl gleich (CL geht von Wurzel aus)


 --CL IX SCAN  CL IX SEEK!

 --TABLE SCAN --- IX SCAN besser

 --IX SEEK --> HEAP 
 --IX SEEK --> CL IX nur die Anzahl der Ebene - 1 mehr


 --jede Spalte des CL IX Schlüssel ist in jedem NCL enthalten
 --? uniqueidentifier


 delete from customers where customerid = 'PARIS'


 2000 MB HEAP
 CL 2 NCL -- 360MB

 REBUILD mit/ohne tempdb online offline
			kleinster Platzbedarf   ohne offline  860MB 
			größter Platzbedarf     mit  online  1100 MB

			--Füllfaktor default 100% = 0 .. Rate zu L:S Verhältnis
			--Seitenteilung bringt immer Füllfaktor 50% --> Fragemtnierung
			--		--> REBUILD (ab 30%) oder REORG (ab10%)
					-- ab SQL 2016 --> Wartungsplan

					vor SQL 2016 Ola Hallengren


--where f(Spalte)= 100

--where spalte = f(wert)

--DB Design

select * from orders


JAHR, QU, MAILPRÄFIX   MAILDOM


dbcc freeproccache




*/


exec gpSuchID 500000

dbcc freeproccache























*/


select top 3 * from ku

--Abfrage where AGG
set statistics io, time on
select orderid, sum(unitprice*quantity)
from ku
where city = 'berlin'-- country = 'Germany'
group by orderid

--NIX_CY_incl_oidupqu

CREATE NONCLUSTERED INDEX NIX_CY_incl_oidupqu
ON [dbo].[KU] ([Country])
INCLUDE ([OrderID],[UnitPrice],[Quantity])

--Seiten:  967  CPU-Zeit = 16 ms, verstrichene Zeit = 20 ms.

select orderid, sum(unitprice*quantity)
from ku2
where city = 'berlin'-- country = 'Germany'
group by orderid