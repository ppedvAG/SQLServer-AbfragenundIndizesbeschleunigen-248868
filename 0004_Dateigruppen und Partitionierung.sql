--Dateigruppen


--verteile Tabellendaten auf versch Datenträger (HOT and Cold Data)
--Last dess Lesen vom Schreiben trennen. zB:
--Messdatensammeln und Stammdaten lesen


create table tabelle1 (id int) ON Dateigruppe

--_Dateigruppe: eine weitere Datendatei (.ndf)   Dateigruppe synonym für Pfad und Dateiname:  c:\prgramme....\..ndf

create table Archivtabelle (id int) on ARCHIV

--Wie kann ich Tabellen auf anderen Dateigruppen schieben..?
--2 Möglichkeiten:
--CLustered INDEX oder Tabelle neu erstellen

USE [master]
GO

GO
ALTER DATABASE [Northwind] ADD FILEGROUP [HOT]
GO
ALTER DATABASE [Northwind] ADD FILE 
( 
	  NAME = N'nwhotdata'
	, FILENAME = N'E:\_SQLDATA\nwhotdata.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB 
) 
TO FILEGROUP [HOT]
GO

