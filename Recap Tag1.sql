/*
DB Design

Normalisierung  OLTP

Redundanz  OLAP
--Pflege der Redundanz

Proz + Rechte

Trigger: 
INS -->   Inserted
DEL  -- > deleted
UP   INS + DEL

begin tran

del   (trigger)
commit

rollback


*/
--Idee tempor�re Tabellen als Redundanz
--zB mit Rollup kombiniert
--keine weitere "Rechnerei" notwendig

select Shipcountry, shipcity, sum(freight)  as Frachtkosten
into #t
from orders
group by Shipcountry, shipcity
with rollup
select * from #t

create proc #procname


--Ref Integrit�t sch�tzt und ist schnell
delete from customers where customerid = 'FISSA'
--geht --- weil nachgesehen wurde, ob der Wert in Orders existiert
--ist einer vorhanden , wird das L�schen verhindert


--Datentypen . leidiges Thema datetime


select * from orders	
where year(orderdate) = 1997--korrekt aber langsam


select * from orders	
where datepart(yy,orderdate) = 1997 korrekt aber langsam


select * from orders	
where orderdate between '1.1.1997' and '31.12.1997' --schnell aber falsch


select * from orders	
where orderdate like '%1997%' langsam aber korrekt

select * from orders
where  orderdate >= '1.1.1997' and OrderDate < '31.12.1997 23:59:59.999'
order by orderdate desc