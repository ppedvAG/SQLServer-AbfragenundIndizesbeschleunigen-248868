
dbcc showcontig('ku')

-- Gescannte Seiten.............................: 41082
-- Mittlere Seitendichte (voll).....................: 98.15%

set statistics io, time on

select * from ku where id = 10

-- 56998
---akt Version des Showcontig
select * from sys.dm_db_index_physical_stats(db_id(),object_id('ku'),NULL,NULL,'detailed')

--forwar_record_count

--CL Index ist die Lösung
--CL = Tabelle in sortierter
--bei CL IX gibt es keine forw_rec_counts mehr
