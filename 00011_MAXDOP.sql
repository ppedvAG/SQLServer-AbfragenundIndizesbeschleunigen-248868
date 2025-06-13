/*
MAXDOP: Anzahl der verwendete kerne 
Kostenschwellwert: kosten im Plan

Default bis SQL 2017
MAXDOP: 0 (alle)
Kostenschwellwert: 5 --> 25

MAXDOP einstellbar auf Server, auf DB und per Abfrage  option (maxdop kernzahl)

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 4;
GO

seit 2019 in Setup: max 8 oder Anzahl der Kerne
aber in der Praxis oft weniger als 8 besser.. beginne mit 50%

Effekt: Abfrage ist unmerklich langsamer , aber wir brauchen weniger CPU, und 
		ein paar CPUS müssen nichts tun


..die nächste Abfrage bekommt die neuen Settings.. kein Neustart, keine disconnect



*/
















set statistics io, time on
select country, city,sum(unitprice*quantity) from ku group by country, city

--2 Pfeile=Paralellism--mehr CPUs
--ca 1,5 Sek CPU und 250ms Dauer
 --mehr CPUs müssen beteiligt sein
 ----> ok, aber wieviele Kerne? einer oder alle per default

 --ab wann verwendet er mehr CPUs..

 --Kostenschwellwert per deault bei 5 SQL Dollar

select customerid,sum(freight) from orders group by customerid


--lohnt sich folglich mehr Cpus einzusetzen; ja
--je mehr umso besser: irgendow muss es eine Grenze geben


--mit einer CPU
--, CPU-Zeit = 641 ms, verstrichene Zeit = 647 ms.

EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'6'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO

select country, city,sum(unitprice*quantity) from ku group by country, city


--SUSPENDED --> RUNNABLE-->RUNNING

--seit SQL 2019: max 8 Kerne ..evtl mal mit 50%

--OLAP 25   OLTP 50 Kostenschwellwert
--gilt für ganzen Server

--mittlerweile auch pro DB
USE [Northwind]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 4;
GO

--je näher an der Abfrage desto mehr zählt die Einstellung
select country, city,sum(unitprice*quantity) from ku
where city = 'Berlin'
 group by country, city
option (maxdop 6)

--Woran erkenne ich dass mehr CPU sich lohne
--> CPU > Dauer
--wenn ein Repartion Stream auftaucht und ein Gather Stream mit x %
--jetzt ziemlich sicher, dass weniger CPUs besser sind


--Messen per CXPACKET .... sys.dm_os_wait_stats