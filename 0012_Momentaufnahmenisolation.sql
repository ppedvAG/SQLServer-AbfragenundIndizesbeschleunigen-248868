--Standardmäßg werden bei Transactions der reihe nach Datensätze Tabellen Seiten Partitionen gesperrt
--Das Sperrniveau ist sehr starlk von der IX Qualität abhängig. Wie finde ich den DS?
--SQL hebt allerdings das SPerrniveau, wenn viele Einzelsperren zu teuer werden

--Alternativen Locks zu umgehen
--bessere Indizes
--READ UNCOMMITTED.. Lesen des gerade sich verändernden DS
--Zeilenversionierung
--man liest den Wert , wie er vor bgein tran war bis ein commit einsetzt

--!!!!! Die DS werden in tempdb kopiert --> hohe TRaffice evtl..

--Aktivieren der Momenaufnahmenisolation

USE [master]
GO
ALTER DATABASE [NwindBig] SET COMPATIBILITY_LEVEL = 160
GO
ALTER DATABASE [NwindBig] SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO
ALTER DATABASE [NwindBig] SET ALLOW_SNAPSHOT_ISOLATION ON
GO
