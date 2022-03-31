create table Ta (
    aid int primary key,
    a2 int unique,
    x int
)

create table Tb (
    bid int primary key,
    b2 int,
    x int
)

create table Tc (
    cid int primary key,
    aid int references Ta(aid),
    bid int references Tb(bid)
)

GO
create or alter procedure insertIntoTa(@rows int) as
    declare @max int
    set @max = @rows*2 + 100
    while @rows > 0 begin
        insert into Ta values (@rows, @max, @rows%120)
        set @rows = @rows-1
        set @max = @max-2
    end

GO
create or alter procedure insertIntoTb(@rows int) as
    while @rows > 0 begin
        insert into Tb values (@rows, @rows%870, @rows%140)
        set @rows = @rows-1
    end

GO
create or alter procedure insertIntoTc(@rows int) as
    declare @aid int
    declare @bid int
    while @rows > 0 begin
        set @aid = (select top 1 aid from Ta order by NEWID())
        set @bid = (select top 1 bid from Tb order by NEWID())
        insert into Tc values (@rows, @aid, @bid)
        set @rows = @rows-1
    end

exec insertIntoTa 10000
exec insertIntoTb 10000
exec insertIntoTc 5000

SELECT * FROM Ta
SELECT * FROM Tb
SELECT * FROM Tc

create nonclustered index index1 on Ta(x)
drop index index1 on Ta
    
select * from Ta order by aid -- Clustered Index Scan
select * from Ta where aid = 1 -- Clustered Index Seek
select a2 from Ta order by a2 -- Nonclustered Index Scan
select a2 from Ta where a2 = 1 -- Nonclustered Index Seek
select x from Ta where a2 = 190 -- Key Lookup

--b. Write a query on table Tb with a WHERE clause of the form *WHERE b2 = value* and analyze its execution plan.
--Create a nonclustered index that can speed up the query. Examine the execution plan again.


select * from Tb where b2 = 50 -- Clustered Index Scan 0.039 cost

create nonclustered index index2 on Tb(b2) include (bid, x)
drop index index2 on Tb

select * from Tb where b2 = 50 -- Nonclustered Index Seek 0.003 cost


--c. Create a view that joins at least 2 tables.
--Check whether existing indexes are helpful; if not, reassess existing indexes / examine the cardinality of the tables.

--0.319
--0.30

GO
CREATE OR ALTER VIEW C_View AS
SELECT Ta.aid, Tb.bid, Tc.cid, Ta.a2, Tb.b2, Ta.x
FROM Tc 
JOIN Ta ON Ta.aid = Tc.aid 
JOIN Tb ON Tb.bid = Tc.bid
GO

SELECT * FROM C_View

CREATE NONCLUSTERED INDEX Index_Tc_1 ON Tc (aid, bid)

SELECT * FROM C_View


DROP INDEX Index_TC_1 ON Tc

