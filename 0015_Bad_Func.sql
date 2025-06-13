/*

speicherbar wie Prozeduren
Parametrisierbar
Skalawertfunktion, Tabellenwertfunktionen

!! F() sind immer schlecht, bis das Gegenteil bewiesen ist
F() werden  i.d.r nicht parl

Was geht nicht: #tab Begin try MADOPX > 1


*/

use Northwind

select * from customers  where customerid like 'A%' --SEEK

select * from customers  where left(customerid,1) = 'A' --SCAN   



--Pläne ansehen. Ist die DB im KOmpabilitätslevel 2016 oder früher
-- --> Kosten für F() etrem gering, was nicht sein kann
		--order details hat fast 3 mal soviele Zeilen wie orders
---> im tats. Plan taucht sie nicht auf
-->  in den Messungen statistics io ebenfalls nicht

--Sieht nur cool aus...
set statistics io , time on 
GO 



select f(spalte) , f(wert) from f(Wert) wher f(Spalte) > f(wert)



select * from  [Order Details]


select dbo.fRngSumme(orderid)  --  10248--> 440

--Skalrfunktion
create function fdemo(@par1 int, @par2 int) resturns int
as
BEGIN
			return (select .).
END;
GO


create function fRngSumme(@bestid int)  returns money
as
BEGIN
		--Testszenario : select dbo.frngsumme(10248) --> 440
		return(select sum(unitprice*quantity) from [Order Details] where orderid = @bestid)
END

ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 130
GO

select dbo.frngSumme(10248)

--Abhängig vom Kompabilitätsgrad wird hier 
--im Plan geschwindelt :-)
--keine Verwendung der Tab Order details??

--Gerade hier fallen die Kosten an!!

ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 160

--Geht man mit dem Komp-Grad höher 
--wird die f ordentlich erkannt und in eine Subquery aufgelöst


select dbo.frngSumme(orderid), Orderid, orderdate from orders where rngsumme < 1000



set statistics io, time on


--Verwendet man die f als berechnet Spalte ist auch SQL 2022
--nicht mehr in der Lage das Problem zu beheben



alter table orders add RngSumme as dbo.fRngSumme(orderid)

--wieder keine Anzeige der Order Details--> kein optimaler Plan

