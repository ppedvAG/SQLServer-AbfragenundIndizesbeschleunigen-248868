---JOIN 
/*
--SQL Server versucht aus einer Reihen von Ausführungsplänen, 
die er vorab ermittelt den günstigsten herauszufinden

Meist stimmt dies. Allerdings kann man "Auffälligkeiten" entdecken

--unter anderem tauchen Sortieroperatoren auf, obwohl kein 
--orer by zu finden war. Das kann dan den JOIN Methoden liegen

inner loop join

inner hash join
es wird eine Hashtabelle zu Ermittlen der übereinstimmenden 
Join Spalten der Tabellen
Git bei großen Tabellen, leicht parallelisierbar, kein Index vorhanden

inner merge join
beide tabellen werden jeweiles einmal gleichzeitig durchsucht
das kann nur dann funktionieren, wenn sortiert
(entweder durch CL IX oder sortier operator :-))

inner loop join
kleine Tabellen wird zeilenweise durchlaufen
pro Zeile wird in der größeren Tabelle nach dem Wert gesucht 
--gut , wenn eine Tabelle bzw (Where)Ergebnis sehr klei ist und 
die größere sortiert ist.

Adaptiv Join
--SQL kann während der Laufzeit wählen
--aber nur zwischen Hash und loop join


*/
select * from customers c inner merge join orders o on c.CustomerID= o.CustomerID

select * from customers c inner loop join orders o on c.CustomerID= o.CustomerID

select * from customers c inner hash join orders o on c.CustomerID= o.CustomerID



set statistics io, time on
