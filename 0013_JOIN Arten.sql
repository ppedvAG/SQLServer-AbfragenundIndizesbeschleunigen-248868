---JOIN 
/*
--SQL Server versucht aus einer Reihen von Ausf�hrungspl�nen, 
die er vorab ermittelt den g�nstigsten herauszufinden

Meist stimmt dies. Allerdings kann man "Auff�lligkeiten" entdecken

--unter anderem tauchen Sortieroperatoren auf, obwohl kein 
--orer by zu finden war. Das kann dan den JOIN Methoden liegen

inner loop join

inner hash join
es wird eine Hashtabelle zu Ermittlen der �bereinstimmenden 
Join Spalten der Tabellen
Git bei gro�en Tabellen, leicht parallelisierbar, kein Index vorhanden

inner merge join
beide tabellen werden jeweiles einmal gleichzeitig durchsucht
das kann nur dann funktionieren, wenn sortiert
(entweder durch CL IX oder sortier operator :-))

inner loop join
kleine Tabellen wird zeilenweise durchlaufen
pro Zeile wird in der gr��eren Tabelle nach dem Wert gesucht 
--gut , wenn eine Tabelle bzw (Where)Ergebnis sehr klei ist und 
die gr��ere sortiert ist.

Adaptiv Join
--SQL kann w�hrend der Laufzeit w�hlen
--aber nur zwischen Hash und loop join


*/
select * from customers c inner merge join orders o on c.CustomerID= o.CustomerID

select * from customers c inner loop join orders o on c.CustomerID= o.CustomerID

select * from customers c inner hash join orders o on c.CustomerID= o.CustomerID



set statistics io, time on
