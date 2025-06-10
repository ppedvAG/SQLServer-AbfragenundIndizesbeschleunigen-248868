/*
Welche Tabelle wird schneller ein Ergebnis iefern:

TAB A 10000 DS
TAB B 100000 DS

beide Tabellen sind absolut gleich, sie haben nur versch Anzahl an DS

Die Abfrage bingt immer nur 10 Zeilen zur�ck

-- kleinere ist schneller.. 

*/

--Idee gro�e Tabelle Umsatz muss schneller werden
--aus Umsatz wird u2021 u2020 u2019 usw...
--Problem: Die Abfrage auf Umsatz geht nicht mehr!!!
--also muss ein "Ersatz" her. --> Sicht 


--Problem: wo ist mein "UMSATZ"
create table u2025 (id int identity, jahr int, spx int)
create table u2024 (id int identity, jahr int, spx int)
create table u2023 (id int identity, jahr int, spx int)
create table u2022 (id int identity, jahr int, spx int)



select * from umsatz --muss wieder funktionieren


--Das kann eine Sicht l�sen...

create or alter view umsatz
as
select * from u2025
UNION ALL --suche nicht nach doppelten DS
select * from u2024
UNION ALL
select * from u2023
UNION ALL
select * from u2022;
GO


--Vergleiche --> Pl�ne : wie verteilt werden die 100% Leistung 
select * from umsatz

select * from umsatz where jahr = 2023

---> Bisher wurde nichts gewonnen..

--Erst der Einsatz vin Check Constraints f�hrt zum Erfolg
--Einsatz von Check Contraints f�hrt dazu, dass SQL Server bestimmte Tabellen zB ignorieren kann
--und daher beim Holen der Daten nicht ber�cksichtigt werden m�ssen.

--Check Contraints als Garantie f�r Einhaltung bestimmter Werte

ALTER TABLE dbo.u2025 ADD CONSTRAINT
	CK_u2025 CHECK (jahr=2025)

ALTER TABLE dbo.u2024 ADD CONSTRAINT
	CK_u2024 CHECK (jahr=2024)

ALTER TABLE dbo.u2023 ADD CONSTRAINT
	CK_u2023 CHECK (jahr=2023)

ALTER TABLE dbo.u2022 ADD CONSTRAINT
	CK_u2022 CHECK (jahr=2022)

--in den Ausf�rhungspll�nen ist deutlich zu sehen, dass SQL Server 
--bestimmte Tabellen aus dem Plan eliminieren konnte




--Select ist nun besser.. aber geht �ber eine Sicht auch INS UP DEL?

--Grunds�tzlich ja
insert into umsatz (id,jahr, spx) values (1,2019, 100)

--aber in diesem Fall:

--PK muss vorhanden sein und Eindeutigkeit �ber alle Tabellen erreichen. 
--Identity alleine reicht nicht aus

--bis dahin: ok f�r Archivdaten, aber nicht f�r Live"umsatz"Daten

--Wie kann man das Problem um Idenity l�sen:
--Sequenzen, aber Anwendung muss angepasst werden

--Seuenz erstellen
CREATE SEQUENCE [dbo].[seqID] 
 START WITH 2
 INCREMENT BY 1


--Abholen der n�chsten ID
 select next value for seqID

--neue TSQL Anweisung f�r INSERT
insert into umsatz (id,jahr, spx) values (next value for seqID,2020, 100)

 select * from umsatz


