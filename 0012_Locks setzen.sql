----
-- LOCKS
-- UPDLOCK, TABLOCKX
-- PAGLOCK, ROWLOCK, TABLOCK
-- HOLDLOCK   
 --NOLOCK   
 --NOWAIT  
 --READCOMMITTED
 --READUNCOMMITTED

 ---

 --set transaction isolation level read uncommitted (Lesen trotz update)
 --                                     repeatable read (nur lesen, kein Update, aber insert
 --                                     Serializable  (kein Insert)   
Begin tran
UPDATE Products 
WITH (Rowlock)  
SET Unitprice = Unitprice * 1.10  
WHERE ProductID between 1 and 5;  
rollback

Begin tran
UPDATE Products 
WITH (tablock)  
SET Unitprice = Unitprice * 1.10  
WHERE ProductID between 1 and 5;  
rollback


Begin tran
UPDATE Products 
WITH (pagLock)  
SET Unitprice = Unitprice * 1.10  
WHERE ProductID between 1 and 5;  
rollback

Begin tran
UPDATE Products 
WITH (Nowait)  
SET Unitprice = Unitprice * 1.10  
WHERE ProductID between 1 and 5;  
rollback


Begin tran
UPDATE Products 
WITH (Holdlock)  
SET Unitprice = Unitprice * 1.10  
WHERE ProductID between 1 and 5;  
rollback



Begin tran
select * from Products 
WITH (readuncommitted)  
WHERE ProductID between 1 and 5;  
rollback