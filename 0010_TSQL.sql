--Prozeduren

--mit in und Output



--thema #t

create or alter proc gpdemo3 @par int
as
select * into #result from orders where freight < @par
waitfor delay '00:00:30'
select @@SPID


exec gpdemo3 10

select * from ##result



.
--Sichten





