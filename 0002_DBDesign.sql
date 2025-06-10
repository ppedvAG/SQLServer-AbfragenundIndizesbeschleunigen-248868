/*
Normalisierung
1, 2 3, BC 4, 5 NF

1. NF atomar  in jeder Zelle nur ein Wert
2. NF Primärschlüsssel..Eindeutigkeit eines Datensatzes
3. NF keine Abhängikeit zwischen den Spoalten ausserhalb des PK


Normalisierung macht langsam
Redundanz ist schnell..aber man muss sie pflegen

-- Kunden-- Bestellungen (BestNr, BDatum, Frachtkosten..) --Position(PrNr, Menge, Preis)
--   1MIO       2 MIO												4MIO 

--Umsatz pro Kundenland: 7 MIO
--wenn wir die RSumme in Bestellungen, dann nur noch 3 MIO
--wie kann man die Redundanz pflegen.. Trigger, SP (kein ändenr auf Tab aaber mit Prozeduren)

--Trigger ist langsam
--Proz sind schnell

--Datentypen

'Otto'

varchar(50).....'Otto'   4
char(50) ...    'Otto                                  ' 50
nvarchar(50)..   'Otto'   4 * 2 (unicode)     8
nchar(50)..      'Otto                                 ' 50 * 2     100
text() --ist depricated, langsam, kann bis zu 2 GB Daten besitzen
varchar(max)-- kann auch 2 GB 

Datum
datetime   ms --SQL merkt sich das als ganze Zahl.. nur 2 bis 3 ms genau
smalldatetime  sek
datetime2  ns
datetimeoffset ns plus Zeitzone +2
date nur Datum
time  nur Zeit


Preis
int +-2,1 Mrd
smallint 32000
bigint 
tinyint +255
decimal(8,2) .. 8 Stellen davon 2 Nachkommastellen
money.. 8 Nachkommastellen
float .. ca 20 Nachkommastellen


--Egal der Platz auf der HDD ist ausreichend..
-- so wie die DS auf der Platte liegen, genauso kommen die in den RAM




*/

use Northwind;
GO --Batchdelimiter

select * from orders

--alle Bestellungen aus dem Jahr 1997 --orderdate

select * from orders where orderdate like '%1997%' --408.. aber schlecht und langsam, aber richtig
select * from orders where year(orderdate) = 1997 --408  ..aber langsam , etwas besser, aber auch richtig
select * from orders where  --schnell aber falsch
	orderdate >= '1.1.1997' AND orderdate <= '31.12.1997 23:59:59.999' --411
select * from orders --schnell aber evtl falsch
	where orderdate >= '1.1.1997' AND orderdate < '1.1.1998'


select country, customerid from customers

--Die Tabellen verwenden sehr häufig datetime 
--ohne es wirklich zu nutzen ein date hätte gebraucht

--auch nvarchar oder nchar ohn e dass es sein muss..
--auf hdd Platz Verschwendung

--


--SQL Server Datendateien bestehen aus Seiten und Blöcken

/*
Seiten sind 
immer 8192 bytes groß
haben max 700 Slots
1 DS kann max 8060  bytes groß sein

von 1 Seite kann max 8072 Zeichen wg Verwaltungskopf verwendet werden
ein DS muss in Seite passen ... i.d.R Ausnahme wie varchar(max)
Seiten werden 1:1 von HDD in RAM gelesen
Jede Seite hat eine eindeutige Nummer (1,2,3,4,5,6,7..)
8 Seiten am Stück sind ein Block
SQL Server liest gerne blockweise, also 64k

ich wäre soweit;-)


*/

create table t1 (id int identity, spx char(4100), sp2 char(4100))

--Meldung 1701, Ebene 16, Status 1, Zeile 107
--Fehler beim Erstellen oder Ändern der t1-Tabelle, weil die Mindestzeilengröße 8211 betragen würde, einschließlich 7 Bytes an internen Verwaltungsbytes. Dies überschreitet die maximal zulässige Größe für Tabellenzeilen von 8060 Bytes.

create table t1 (id int identity, spx char(4100), sp2 varchar(4100)) --klappt





--Feststellung : wie voll sind Seiten

dbcc showcontig('orders')

--- Gescannte Seiten.............................: 45510
--- Mittlere Seitendichte (voll).....................: 60.88%















































/*

Normalisierung ..keine schlechte Idee
		        .. aber evtl Redundanz einzubringen (reale Werte: RSumme)
				 --> vor allem, wenn ein Join gespart wird.

				 --#temp tabellen sind auch Redundanz


Datentypen gut justieren


Platzverschwendung: Seiten können Leerräume haben--> 1:1 --> RAM
bei geringen Füllgrad: Kompression (Page!, Row)  40-60%
--> Page kostet deutlich mehr CPU als Row Kompression
--Abfragen auf komprimierte Tabellen profitieren kaum seitens Performance
--eher profit. andere
--transp für Anwendung.. Daten im RAM auch komprimiert , aber bei Client dekomprimiert

Wie messe ich Platzverschwendung

dbcc showcontig('tabelle') ---depricated

--Seiten 1000000
--Fgrad: 90%--> ?



*/
















/*
ref integrität
Tab
PK FK
Datentypen
Normalisierung (1. 2. 3. BC 4. 5.)
Redundanz #t, zusätzlichen Spalten
Generalisierung


--DB Design

--Normalisierung ist ok.. aber Redundanz ist schnell
--#tabellen sind Redundanz, 
	
--zusätzlich Spalten wie Rechnugssumme.. aber wie pflegen ? Trigger ..schlechte performance, evtl in Logik (Porzeduren auslagern), 
	dann aber mit Rechten absichern


--Datentypen

/*  Otto
nvarchar(50)  'otto'    4 
char(50)     'otto                                  '   50
text()   nicht mehr verwenden.. seit SQL 2005 depricated  auch image ..kann 2 GB daten besítzen
nvarchar(50)  'otto'   4   *2   --> 8 
nchar(50)   'otto                         ' 50 * 2 --> 100

n = Unicode 


Regel: bei fixen Längen immer char!


--auschlaggeben ist allerdings auch das Verhalten beim Speichern von Daten in den Datendateien
--siehe Seiten und Blöcke

Seiten : 8192 bytes haben Platz für max 700 Datensätze
 1 DS muss in eine Seiten passen und kann max 8060 belegen
 Seiten kommen 1:1 in Arbeitsspeicher, daher ist es wichtig, dass bei Abfragen die Seitenzahlen, die gbraucht werden ,
 zu reduzieren, um sie peformanter zu machen

8 Seiten am Stück = Block
SQL liest Blockweise aus


--Prüfe im Diagram ob alle PK auf eine Beziehung zu anderen Tabellen (FK) haben--Indizes

--Sind die Datentypen apssend?


--Beim Erstellen einer DB: Initialgrößen der Dateien anpassen.. wie groß in 3 Jahren
--Wachstumsraten festlegen: selten aber nicht aufwendig? 1000 MB zB


*/

create database testdb
---> uiuiui viele Fehler!

--GUID
--varchar(50), nvarchar(50), nchar(50), char(50)

*/

use testdb


create table t1 (id int identity, spx char(4100))


insert into t1
select 'XY'
GO 20000

--19 Sekunden--ist aber 160MB
--Wie haben 20000*4kb  80MB


dbcc showcontig ('t1')
-- Gescannte Seiten.............................: 20000
-- Mittlere Seitendichte (voll).....................: 50.79%

set statistics io, time on--io = Seiten,, time Dauer und CPU Zeit in ms
--Achtung Messen kostet

select * from t1 where id  = 100
--Tabelle: "t1". Anzahl von Überprüfungen: 1, logische Lesevorgänge: 20000


--Wo haben wir die 20 Sek her

--Besser durch: Datentypen anpassen
--Anwendung muss redesigned werden

--schlchte Auslastung der Seiten kann man evtl mit Kompression etwas beheben



--man könnte komprimieren
--Tab mit 20000 Seiten ... 16 ms ... 20000 Seiten im RAM (160MB)
--nach Kompression:
--ca 0,5 MB   --> Seiten von IO..ca 30  und wieviel in RAM 0,5MB --- der Client bekommmt 160 MB
---> CPU muss höher weil der der Stream zum Client dekomoriiert
--aber auf dem Server bleibt es komprimiert

USE [testdb]
ALTER TABLE [dbo].[t1] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)


--Normalerweiese werden ca 40 bis 60% Kompressionrate
--meine Erwartung : komp Tabellen sind selten schneller--> RAM Platz für anderer Daten schaffen

---













