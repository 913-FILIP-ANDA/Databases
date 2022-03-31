CREATE TABLE product_type(
	ptid INT PRIMARY KEY,
	prod_name VARCHAR(100),
	country VARCHAR(100),
	);

CREATE TABLE producer(
	pid INT PRIMARY KEY,
	country VARCHAR(100),
	);

CREATE TABLE product(
	pid INT PRIMARY KEY,
	product_name VARCHAR(100),
	price DECIMAL(12,2),
	expiration_date DATE,
	producer_id INT,
	id_type INT,

	FOREIGN KEY (producer_id) REFERENCES producer(pid) ON DELETE CASCADE,
	FOREIGN KEY (id_type) REFERENCES product_type(ptid) ON DELETE CASCADE,
);

CREATE TABLE delivery(
	did INT PRIMARY KEY,
	car_number VARCHAR(100),
	company VARCHAR(100),
	);

CREATE TABLE product_delivery(
	did INT FOREIGN KEY REFERENCES delivery(did) ON DELETE CASCADE,
	pid INT FOREIGN KEY REFERENCES product(pid) ON DELETE CASCADE,
	day_of_delivery date,
	);

CREATE TABLE client(
	cid INT PRIMARY KEY,
	);
CREATE TABLE buys(
	cid INT FOREIGN KEY REFERENCES client(cid) ON DELETE CASCADE,
	pid INT FOREIGN KEY REFERENCES product(pid) ON DELETE CASCADE,
	);
GO
CREATE VIEW unavailableProducts AS
SELECT P.pid
FROM product P
WHERE P.expiration_date < '2021-10-20'
UNION
SELECT B.pid
FROM buys B, product P
WHERE P.pid = B.pid;

GO

CREATE VIEW shorsellProducts AS
SELECT P.product_name
FROM product P
WHERE P.price < 10 OR expiration_date < '2022-01-01';

GO

CREATE VIEW nb_min_expiration_date_Romania AS
SELECT P.producer_id ,MIN(P.expiration_date) AS min_exp_date, COUNT(DISTINCT P.id_type) AS  nb_of_prod
FROM product P
GROUP BY P.producer_id
HAVING P.producer_id = ANY(
	SELECT PR.pid
	FROM producer PR
	WHERE PR.country = 'Romania'
);

GO
CREATE OR ALTER PROCEDURE createTest (@name NVARCHAR(50)) AS
    IF NOT EXISTS (SELECT * FROM Tests WHERE Name=@name)
	BEGIN
        INSERT INTO Tests(Name) VALUES(@name)
	END
GO

CREATE OR ALTER PROCEDURE createTable(@name NVARCHAR(50)) AS
 IF NOT EXISTS (SELECT * FROM Tables WHERE Name=@name)
	BEGIN
        INSERT INTO Tables(Name) VALUES (@name)
       END
GO

CREATE OR ALTER PROCEDURE createView(@name NVARCHAR(50)) AS
IF NOT EXISTS (SELECT * FROM Views WHERE Name=@name)
	BEGIN
        INSERT INTO Views(Name) VALUES(@name)
		END


GO
CREATE OR ALTER PROCEDURE populateTableproduct (@rows INT) AS
    WHILE @rows > 0 
	BEGIN
        INSERT INTO product(pid, product_name, price,expiration_date, producer_id,id_type) VALUES
            (@rows,'Name',100,'2021-12-20',
             (SELECT TOP 1 pid FROM producer ORDER BY newid()),
			 (SELECT TOP 1 ptid FROM product_type )
            )
        set @rows = @rows - 1
       END
GO

CREATE OR ALTER PROCEDURE populateTabledelivery (@rows INT) AS
    WHILE @rows > 0 
	BEGIN
        INSERT INTO delivery(did, car_number, company) VALUES
            (@rows,'HD-99-GGG','Company')
        set @rows = @rows - 1
       END



GO
CREATE OR ALTER PROCEDURE populateTableproduct_delivery (@rows INT) AS
   DECLARE @newDID INT
   DECLARE @newPID INT
   WHILE @rows > 0
   BEGIN
		SET @newDID = (SELECT TOP 1 did FROM delivery ORDER BY NEWID())
		SET @newPID = (SELECT TOP 1 pid FROM product ORDER BY NEWID())
		WHILE EXISTS (SELECT * FROM product_delivery WHERE pid = @newPID AND did = @newDID)
		BEGIN
			SET @newDID = (SELECT TOP 1 did FROM delivery ORDER BY NEWID())
			SET @newPID = (SELECT TOP 1 pid FROM product ORDER BY NEWID())
		END
		INSERT INTO product_delivery(did,pid,day_of_delivery) VALUES (@newDID, @newPID, '2020-10-30')
		SET @rows = @rows - 1
	END


GO
CREATE OR ALTER PROCEDURE connectTestandTable(@test NVARCHAR(50), @table VARCHAR(50), @NoOfRows INT, @position INT) AS
	
	IF EXISTS(SELECT* 
	FROM TestTables TT JOIN Tests T ON TT.TestID = T.TestID
	WHERE T.Name=@test AND TT.Position = @position)
	BEGIN PRINT 'INCORRECT POSITION'
		RETURN
	END

	IF @NoOfRows<0
	BEGIN PRINT 'NB OF ROWS MUST BE POSITIVE!'
	RETURN 
	END

	IF @position<0
	BEGIN PRINT 'POSITION MUST BE POSITIVE!'
	RETURN
	END

	IF (@test IN(SELECT Name FROM Tests) and @table IN(SELECT Name FROM Tables))
	BEGIN
		DECLARE @testID INT, @tableID INT
		SET @testID = (SELECT TestID FROM Tests WHERE Name = @test)
		SET @tableID = (SELECT TableID FROM Tables WHERE Name = @table)
        INSERT INTO TestTables(TestID, TableID, NoOfRows,Position) VALUES 
		(@testID, @tableID, @NoOfRows,@position)
       END
	ELSE
		BEGIN
			PRINT 'Test or Table incorrect!'
		END



GO
CREATE OR ALTER PROCEDURE connectTestandView(@test NVARCHAR(50), @view NVARCHAR(50)) AS
	IF (@test IN(SELECT Name FROM Tests) and @view IN(SELECT Name FROM Views))
	BEGIN
		DECLARE @testID INT, @viewID INT
		SET @testID = (SELECT TestID FROM Tests WHERE Name = @test)
		SET @viewID = (SELECT ViewID FROM Views WHERE Name = @view)
        INSERT INTO TestViews(TestID, ViewID) VALUES 
		(@testID, @viewID)
       END
	ELSE
	BEGIN PRINT 'TEST OR VIEW INCORRECT!'
	END

GO
CREATE OR ALTER PROCEDURE runTests (@test NVARCHAR(50)) AS
	IF @test NOT IN (SELECT Name FROM Tests)
	BEGIN PRINT 'INCORRECT TEST!'
	RETURN
	END

	DECLARE @testRunID INT, @table NVARCHAR(50), @noOfRows INT, @tableID INT,
	@startTests DATETIME2, @endTests DATETIME2, @currentTestStart DATETIME2,
	@currentTestEnd DATETIME2, @procedure VARCHAR(100), @viewID INT, @view VARCHAR(50),
	@stmt VARCHAR(50), @testID INT

	SET @testID = (SELECT T.TestID FROM Tests T WHERE T.Name = @test)

	INSERT INTO TestRuns(Description) VALUES(@testID)
	SET @testRunID = CONVERT(INT, (SELECT last_value FROM sys.identity_columns WHERE name = 'TestRunID'))

	DECLARE TablesCursor CURSOR SCROLL FOR
	SELECT T.TableID, T.Name, TT.NoOfRows FROM TestTables TT INNER JOIN Tables T on T.TableID = TT.TableID
	WHERE TT.TestID = @testID
	ORDER BY TT.Position

	DECLARE ViewsCursor CURSOR FOR
	SELECT V.ViewID, V.Name FROM Views V INNER JOIN TestViews T ON V.ViewID = T.ViewID
	WHERE T.TestID = @testID

	OPEN TablesCursor

	--delete data
	FETCH LAST FROM TablesCursor INTO @tableID, @table, @noOfRows
	
	WHILE @@FETCH_STATUS = 0--while there still are rows
	BEGIN 
		EXEC ('delete from ' + @table)
		FETCH PRIOR FROM TablesCursor INTO @tableID, @table, @noOfRows
	END
	CLOSE TablesCursor

	SET @startTests = SYSDATETIME()

	OPEN TablesCursor

	--insert data
	FETCH FIRST FROM TablesCursor INTO @tableID, @table, @noOfRows

	WHILE @@FETCH_STATUS = 0 --while there still are rows
	BEGIN
		SET @currentTestStart = SYSDATETIME()
		SET @procedure = 'populateTable' + @table
		IF @procedure IN (SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES)
		BEGIN
			EXEC @procedure @noOfRows
			SET @currentTestEnd = SYSDATETIME()
			INSERT INTO TestRunTables(TestRunID, TableID,StartAt,EndAt)
			VALUES (@testRunID, @tableID, @currentTestStart, @currentTestEnd)
			FETCH NEXT FROM TablesCursor INTO @tableID, @table, @noOfRows
		END
		ELSE
			BEGIN
				PRINT @procedure + ' not existent '
				RETURN
			END
	END

	DEALLOCATE TablesCursor

	OPEN ViewsCursor
	FETCH FROM ViewsCursor INTO @viewID, @view
	WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @currentTestStart = SYSDATETIME()
			SET @stmt = 'SELECT * FROM ' + @view
			SET @currentTestEnd = SYSDATETIME()

			INSERT INTO TestRunViews(TestRunID, ViewID, StartAt,EndAt)
			VALUES (@testRunID, @viewID, @currentTestStart, @currentTestEnd)
			FETCH NEXT FROM ViewsCursor INTO @viewID, @view
		END
	SET @endTests = SYSDATETIME()
	CLOSE ViewsCursor
	DEALLOCATE ViewsCursor

	UPDATE TestRuns
	SET StartAt = @startTests, EndAt = @endTests
	WHERE TestRunID = @testRunID

GO

EXEC createView 'shortSellProducts'
EXEC createView 'unavailableProducts'
EXEC createTable 'product'
EXEC createTable 'delivery'
EXEC createTable 'product_delivery'
EXEC createTest 'Test1'
EXEC createTest 'Test2'
EXEC createTest 'Test3'
EXEC connectTestAndTable 'Test1', 'product', 200, 1
EXEC connectTestAndTable 'Test1', 'delivery', 200, 2
EXEC connectTestandTable 'Test2', 'product_delivery', 400, 3
EXEC connectTestAndView 'Test1', 'shortSellProducts'
EXEC connectTestAndView 'Test1', 'unavailableProducts'

EXEC runTests 'Test1'
EXEC runTests 'Test2'
EXEC runTests 'Test3'
SELECT * FROM TestRuns

SELECT * FROM TestRunTables
SELECT * FROM TestRunViews
Select * from Views




