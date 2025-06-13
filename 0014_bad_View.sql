
create table ma.projekte (id int)

create table ma.kst (id int)
select * from (select * from customers where country = 'UK') c



create view vdemo1
as
select * from customers where country = 'UK'

select * from vdemo1 

select * from (select * from customers where country = 'UK') c



create table slf (id int identity, stadt int, land int)

insert into slf
select 10, 100
union all
select 20, 200
union all
select 30, 300

select * from slf

create view vdemo
as
select * from slf

select * from vdemo



alter table slf add fluss int

update slf set fluss = id*1000

select * from vdemo --fluss fehlt trotz *

alter table slf drop column land


select * from vdemo --horror!! 


---jetzt neu un dbesser!
drop table slf
drop view vdemo

create table slf (id int identity, stadt int, land int)

insert into slf
select 10, 100
union all
select 20, 200
union all
select 30, 300

select * from slf

create view vdemo with schemabinding--du musst exakt arbeiten
as
select id, stadt , land from dbo.slf

--kein * und Schema muss angegeben werden


alter table slf add fluss int
update slf set fluss = id * 1000

select * from vdemo

alter table slf drop column land
--kann nicht gelöscht werden, da sonst View nicht mehr funktioniert


create or alter view vBestellung
as
SELECT Customers.CustomerID, Customers.CompanyName, 
   Customers.ContactName, Customers.ContactTitle, Customers.City, 
   Customers.Country, Orders.EmployeeID, Orders.OrderDate, 
   Orders.Freight, Orders.ShipCity, Orders.ShipCountry, 
   [Order Details].OrderID, [Order Details].ProductID, 
   [Order Details].UnitPrice, [Order Details].Quantity, 
      ([Order Details].UnitPrice * [Order Details].Quantity) as PosSumme, 
   Products.ProductName, Products.UnitsInStock, Employees.FirstName, 
   Employees.LastName
FROM Customers INNER JOIN
   Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
   [Order Details] ON 
   Orders.OrderID = [Order Details].OrderID INNER JOIN
   Products ON 
   [Order Details].ProductID = Products.ProductID INNER JOIN
   Employees ON Orders.EmployeeID = Employees.EmployeeID


select * from vBestellung order by orderid


--Wie hoch sind die Lieferkosten in UK (Land des Kunden)?

--wieviel: ca...8500

select sum(freight) from orders

select sum(freight) from customers c inner join orders o on c.CustomerID= o.CustomerID
where c.Country= 'UK'
select sum(freight) from vBestellung where country = 'UK'



