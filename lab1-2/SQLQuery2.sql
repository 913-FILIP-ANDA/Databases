USE lab2
drop table Categories
drop table Stores
drop table Teas
drop table Employees
drop table Clients
drop table Inventory
drop table Providers
drop table Transactions
drop table Restocks
drop table Reviews

CREATE TABLE Categories (
	CategoryId int NOT NULL IDENTITY(1, 1) PRIMARY KEY, 
	CategoryName varchar(100)
)

CREATE TABLE Stores (
	StoreId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	StoreAddress varchar(100)
)

CREATE TABLE Teas (
	TeasId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TeasName varchar(100),
	CategoryId int FOREIGN KEY REFERENCES Categories(CategoryId)
)

CREATE TABLE Employees (
	EmployeeId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	EmployeeName varchar(100),
	StoreId int FOREIGN KEY REFERENCES Stores(StoreId)
)

CREATE TABLE Clients (
	CNP bigint NOT NULL PRIMARY KEY,
	ClientName varchar(100)
)


CREATE TABLE Inventory (
	ItemId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	StoreId int NOT NULL FOREIGN KEY REFERENCES Stores(StoreId),
	TeasId int NOT NULL FOREIGN KEY REFERENCES Teas(TeasId),
	Quantity int
)

CREATE TABLE Providers (
	ProviderId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	ProviderName varchar(100)
)

CREATE TABLE Transactions (
	TransactionId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TeasId int NOT NULL FOREIGN KEY REFERENCES Teas(TeasId),
	CNP bigint NOT NULL FOREIGN KEY REFERENCES Clients(CNP),
	EmployeeId int NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeId),
	StoreId int NOT NULL FOREIGN KEY REFERENCES Stores(StoreId),
	Quantity int,
	PurchaseDateTime DateTime DEFAULT CURRENT_TIMESTAMP,
	Price int
)

CREATE TABLE Restocks (
	RestockId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TeasId int NOT NULL FOREIGN KEY REFERENCES Teas(TeasId),
	EmployeeId int NOT NULL FOREIGN KEY REFERENCES Employees(EmployeeId),
	StoreId int NOT NULL FOREIGN KEY REFERENCES Stores(StoreId),
	ProviderId int NOT NULL FOREIGN KEY REFERENCES Providers(ProviderId),
	Quantity int
)


CREATE TABLE Reviews (
	ReviewId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	CNP bigint NOT NULL FOREIGN KEY REFERENCES Clients(CNP),
	TeasId int NOT NULL FOREIGN KEY REFERENCES Teas(TeasId),
	Grade tinyint
)

INSERT INTO Categories (CategoryName)
VALUES ('black tea'), ('green tea'), ('white tea'), ('oolong tea'), ('herbal tea');
SELECT *FROM Categories

INSERT INTO Stores (StoreAddress)
VALUES ('Bucharest no. 1'), ('Cluj-Napoca no. 5'), ('Sibiu no. 101'), ('Brasov no. 76'), ('Constanta no. 4A');
SELECT *FROM Stores

INSERT INTO Teas (TeasName, CategoryId)
VALUES ('Assam', (SELECT CategoryId FROM Categories WHERE CategoryName = 'black tea')), 
('Irish', (SELECT CategoryId FROM Categories WHERE CategoryName = 'black tea')), 
('Sencha', (SELECT CategoryId FROM Categories WHERE CategoryName = 'green tea')), 
('Matcha', (SELECT CategoryId FROM Categories WHERE CategoryName = 'green tea')), 
('Chamomile', (SELECT CategoryId FROM Categories WHERE CategoryName = 'white tea')), 
('Jasmine', (SELECT CategoryId FROM Categories WHERE CategoryName = 'white tea')), 
('Phoenix', (SELECT CategoryId FROM Categories WHERE CategoryName = 'oolong tea')), 
('Milk', (SELECT CategoryId FROM Categories WHERE CategoryName = 'oolong tea')),
('Ginger', (SELECT CategoryId FROM Categories WHERE CategoryName = 'herbal tea')), 
('Lemon', (SELECT CategoryId FROM Categories WHERE CategoryName = 'herbal tea')) 
SELECT *FROM Teas

INSERT INTO Employees (EmployeeName, StoreId)
VALUES ('Andrei', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1')), 
('Alex', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101')), 
('Maria', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5')), 
('Elena', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1')), 
('Ioan', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5')), 
('Bob', (SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'));
SELECT *FROM Employees

INSERT INTO Clients (CNP, ClientName)
VALUES (1, 'Andrew'), (2, 'Mary'), (3, 'Michael'), (4, 'Annabelle'), (5, 'Robert');
SELECT *FROM Clients

INSERT INTO Inventory(StoreId, TeasId, Quantity)
VALUES ((SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1'), (SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 10),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1'), (SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 11),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), (SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 9),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), (SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 8),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101'), (SELECT TeasId FROM Teas WHERE TeasName = 'Milk'), 5),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101'), (SELECT TeasId FROM Teas WHERE TeasName = 'Matcha'), 0),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Brasov no. 76'), (SELECT TeasId FROM Teas WHERE TeasName = 'Irish'), 3),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Constanta no. 4A'), (SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 25),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Constanta no. 4A'), (SELECT TeasId FROM Teas WHERE TeasName = 'Assam'), 1),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Constanta no. 4A'), (SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 13),
((SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), (SELECT TeasId FROM Teas WHERE TeasName = 'Jasmine'), 20)
SELECT *FROM Inventory

INSERT INTO Providers (ProviderName)
VALUES ('FirmA'), ('FirmB'), ('FirmC'), ('FirmD'), ('FirmE');
SELECT *FROM Providers

INSERT INTO Transactions (TeasId, CNP, EmployeeId, StoreId, Quantity, PurchaseDateTime, Price)
VALUES ((SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), (SELECT CNP FROM Clients WHERE ClientName = 'Andrew'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Andrei'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1'), 5, '2020-10-8 10:15:30', 999),
((SELECT TeasId FROM Teas WHERE TeasName = 'Matcha'), (SELECT CNP FROM Clients WHERE ClientName = 'Mary'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Alex'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101'), 5, '2019-8-8 11:21:33', 999),
((SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), (SELECT CNP FROM Clients WHERE ClientName = 'Michael'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Maria'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), 5, '2020-3-15 15:14:01', 300),
((SELECT TeasId FROM Teas WHERE TeasName = 'Jasmine'), (SELECT CNP FROM Clients WHERE ClientName = 'Annabelle'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Elena'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1'), 5, '2019-12-30 21:30:55', 80),
((SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), (SELECT CNP FROM Clients WHERE ClientName = 'Robert'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Ioan'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), 5, '2020-5-3 20:08:00', 300),
((SELECT TeasId FROM Teas WHERE TeasName = 'Phoenix'), (SELECT CNP FROM Clients WHERE ClientName = 'Mary'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Bob'), 
	(SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'), 5, '2019-01-5 16:01:15', 750);
SELECT *FROM Transactions

INSERT INTO Restocks (TeasId, EmployeeId, StoreId, ProviderId, Quantity)
VALUES ((SELECT TeasId FROM Teas WHERE TeasName = 'Matcha'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Maria'), (SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'),
	(SELECT ProviderId FROM Providers WHERE ProviderName = 'FirmA'), 3),
((SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Andrei'), (SELECT StoreId FROM Stores WHERE StoreAddress = 'Bucharest no. 1'),
	(SELECT ProviderId FROM Providers WHERE ProviderName = 'FirmB'), 4),
((SELECT TeasId FROM Teas WHERE TeasName = 'Phoenix'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Bob'), (SELECT StoreId FROM Stores WHERE StoreAddress = 'Cluj-Napoca no. 5'),
	(SELECT ProviderId FROM Providers WHERE ProviderName = 'FirmA'), 5),
((SELECT TeasId FROM Teas WHERE TeasName = 'Ginger'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Alex'), (SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101'),
	(SELECT ProviderId FROM Providers WHERE ProviderName = 'FirmC'), 1),
((SELECT TeasId FROM Teas WHERE TeasName = 'Jasmine'), (SELECT EmployeeId FROM Employees WHERE EmployeeName = 'Alex'), (SELECT StoreId FROM Stores WHERE StoreAddress = 'Sibiu no. 101'),
	(SELECT ProviderId FROM Providers WHERE ProviderName = 'FirmD'), 2);
SELECT *FROM Restocks

INSERT INTO Reviews (CNP, TeasId, Grade)
VALUES ((SELECT CNP FROM Clients WHERE ClientName = 'Andrew'), (SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 7),
((SELECT CNP FROM Clients WHERE ClientName = 'Mary'), (SELECT TeasId FROM Teas WHERE TeasName = 'Matcha'), 9),
((SELECT CNP FROM Clients WHERE ClientName = 'Michael'), (SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 10),
((SELECT CNP FROM Clients WHERE ClientName = 'Annabelle'), (SELECT TeasId FROM Teas WHERE TeasName = 'Jasmine'), 3),
((SELECT CNP FROM Clients WHERE ClientName = 'Robert'), (SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 5),
((SELECT CNP FROM Clients WHERE ClientName = 'Mary'), (SELECT TeasId FROM Teas WHERE TeasName = 'Phoenix'), 6);
SELECT *FROM Reviews

CREATE TABLE ProductTransactions (
	PTId int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	TeasId int NOT NULL FOREIGN KEY REFERENCES Teas(TeasId),
	TransactionId int NOT NULL FOREIGN KEY REFERENCES Transactions(TransactionId),
	Quantity int,
	Price int
)

INSERT INTO ProductTransactions (TeasId, TransactionId, Quantity, Price)
VALUES ((SELECT TeasId FROM Teas WHERE TeasName = 'Sencha'), 1, 5, 999),
((SELECT TeasId FROM Teas WHERE TeasName = 'Matcha'), 2, 5, 999),
((SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 3, 5, 300),
((SELECT TeasId FROM Teas WHERE TeasName = 'Jasmine'), 4, 5, 80),
((SELECT TeasId FROM Teas WHERE TeasName = 'Lemon'), 5, 5, 300),
((SELECT TeasId FROM Teas WHERE TeasName = 'Phoenix'), 6, 5, 750);
SELECT *FROM ProductTransactions

-- insert that violates foreign key constraint integrity?????????
INSERT INTO ProductTransactions (TeasId, TransactionId, Quantity, Price)
VALUES (1337, 1, 5, 999);

SELECT *FROM Employees

-- first update using '=' and 'AND'
UPDATE Employees
SET EmployeeName = 'Andy'
WHERE StoreId = 31 AND EmployeeName = 'Elena';
SELECT *FROM Employees

-- second update using 'OR' and 'LIKE'
UPDATE Stores
SET StoreAddress = 'Somewhere...'
WHERE StoreAddress LIKE 'S%' OR StoreAddress LIKE 'Cluj%';

SELECT *FROM Stores

-- third update using 'IS NOT NULL' and 'AND' and 'BETWEEN'
UPDATE Teas
SET TeasName = 'Mint Tea'
WHERE TeasId IS NOT NULL AND CategoryId BETWEEN 6 AND 7;
SELECT *FROM Teas

-- first delete using '<'
DELETE FROM Reviews
WHERE Grade < 5;
SELECT *FROM Reviews

-- second delete using 'IN'
DELETE FROM ProductTransactions
WHERE TeasId IN(14, 16) AND TeasId >= 15;

SELECT *FROM ProductTransactions


-- A

-- first union using an or;
-- select all Teas (Teasid) with categoryId 6 or where restocked in storeid 31 or with a quantity of 5
SELECT TeasId + 1000 as 'PID'
FROM Teas
WHERE CategoryId = 6
UNION 
SELECT TeasId + 1000 as 'PID'
FROM Restocks
WHERE StoreId = 31 OR Quantity = 5;
SELECT *FROM Teas
SELECT *FROM Restocks

-- second union: union all using an or;
-- select all employees (employeeid) who either restocked something or performed a transaction this year or last year
SELECT EmployeeId
FROM Restocks
UNION ALL
SELECT EmployeeId
FROM Transactions
WHERE YEAR(PurchaseDateTime) = 2021 OR YEAR(PurchaseDateTime) = 2020;
SELECT *FROM Transactions
SELECT *FROM Restocks

-- B

-- first intersect using in
-- select all employees who both restocked something and performed a transaction this year or 2 years ago
SELECT EmployeeId
FROM Restocks
INTERSECT
SELECT EmployeeId
FROM Transactions
WHERE YEAR(PurchaseDateTime) IN (2021, 2019);
SELECT *FROM Transactions
SELECT *FROM Restocks

-- second intersect
-- select all customers who both bought something and left a review
SELECT CNP
FROM Transactions
INTERSECT
SELECT CNP
FROM Reviews
SELECT *FROM Transactions
SELECT *FROM Reviews

-- C

-- first except using not in
-- select all customers who both bought something but didn't leave a review with a grade of 1-9
SELECT CNP % 1000 as 'Last 3 digits of CNP'
FROM Transactions
EXCEPT
SELECT CNP % 1000 as 'Last 3 digits of CNP'
FROM Reviews
WHERE Grade NOT IN (8, 9, 10);
SELECT *FROM Transactions
SELECT *FROM Reviews

-- second except using not in
-- select all employees who restocked something but didn't perform a transaction more than 3 years ago
SELECT EmployeeId
FROM Restocks
EXCEPT
SELECT EmployeeId
FROM Transactions
WHERE YEAR(PurchaseDateTime) NOT IN (2021, 2020, 2019);
SELECT *FROM Transactions
SELECT *FROM Restocks


-- D

-- inner join
-- get what each employee restocked
-- 3 tables join
SELECT E.EmployeeName, T.TeasName
FROM Employees AS E
INNER JOIN Restocks AS R
ON E.EmployeeId = R.EmployeeId
INNER JOIN Teas AS T
ON R.TeasId = T.TeasId;
SELECT *FROM Employees
SELECT *FROM Restocks
SELECT *FROM Teas

-- full join between 3 tables 
-- get from each store the employees, the store address's and the datetime of their purchases
SELECT TOP 100 S.StoreAddress, E.EmployeeName, T.PurchaseDateTime
FROM Stores AS S
FULL JOIN Employees AS E ON E.StoreId = S.StoreId
FULL JOIN Transactions AS T ON T.StoreId = S.StoreId;
SELECT *FROM Stores
SELECT *FROM Employees
SELECT *FROM Transactions

UPDATE Employees
SET StoreId = NULL
WHERE EmployeeName = 'Alex';


-- full join between 3 tables (a m to m relation, Inventory being the relation's table)
-- for each store get the tea and the quantity from inventory
SELECT DISTINCT  S.StoreAddress, T.TeasName, I.Quantity
FROM Stores AS S
FULL JOIN Inventory AS I ON I.StoreId = S.StoreId
INNER JOIN Teas AS T ON I.TeasId = T.TeasId;
SELECT *FROM Teas
SELECT *FROM Stores
SELECT *FROM Inventory

-- left join (get the date/time of each transaction performed by each client)
SELECT C.ClientName, T.PurchaseDateTime
FROM Clients AS C
LEFT JOIN Transactions AS T ON T.CNP = C.CNP;
SELECT *FROM Clients
SELECT *FROM Transactions

-- for each tea we get it's id from a store's inventory
-- REWRITTEN v
SELECT T.TeasName, I.ItemId
FROM Teas AS T
LEFT JOIN Inventory AS I ON I.TeasId = T.TeasId;
SELECT *FROM Teas
SELECT *FROM Inventory

-- right join (get the provider for each restock)
SELECT P.ProviderName, R.RestockId + 10000 as 'RID'
FROM Providers AS P
RIGHT JOIN Restocks AS R ON R.ProviderId = P.ProviderId; 
SELECT *FROM Providers
SELECT *FROM Restocks

--get the review grade for each client
SELECT C.ClientName, R.Grade
FROM Reviews AS R
RIGHT JOIN Clients AS C on R.CNP = C.CNP;
SELECT *FROM Reviews
SELECT *FROM Clients

-- E.  2 queries with the IN operator and a subquery in the WHERE clause; in at least one case, --the subquery should include a subquery in its own WHERE clause;

-- select all clients name who bought a TeasID of 20
SELECT DISTINCT ClientName
FROM Clients
WHERE CNP IN (
	SELECT CNP
	FROM Transactions
	WHERE TransactionId IN (
		SELECT TransactionId
		FROM ProductTransactions
		WHERE TeasId = 20
		)
	);
SELECT *FROM Clients
SELECT *FROM Transactions
SELECT *FROM Teas

-- select all employees who restocked a Teas with id 13
SELECT EmployeeName
FROM Employees
WHERE EmployeeId IN (
	SELECT EmployeeId 
	FROM Restocks
	WHERE TeasId = 13
	);

SELECT *FROM Employees
SELECT *FROM Restocks
SELECT *FROM Teas

-- F. 2 queries with the EXISTS operator and a subquery in the WHERE clause;

-- select all teas who were ever sold
SELECT TeasName
FROM Teas AS T
WHERE EXISTS (
	SELECT TeasId
	FROM ProductTransactions AS PT
	WHERE PT.TeasId = T.TeasId
	);
SELECT *FROM Teas
SELECT *FROM ProductTransactions

-- select all clients who ever left a review
SELECT ClientName
FROM Clients AS C
WHERE EXISTS (
	SELECT CNP
	FROM Reviews AS R
	WHERE R.CNP = C.CNP
	)
ORDER BY ClientName DESC;

SELECT *FROM Clients
SELECT *FROM Reviews


-- G. 2 queries with a subquery in the FROM clause;

-- select all teas with categories > 1 and < 5 and with their name starting with an m
SELECT FilteredProducts.TeasName
FROM (
	SELECT TeasName AS TeasName
	FROM Teas
	WHERE CategoryId > 5 AND CategoryId < 10
) AS FilteredProducts
WHERE FilteredProducts.TeasName LIKE 'm%';

SELECT *FROM Teas

-- select the tea names of the restocked teas restocked by an employee whose name starts with a
SELECT T.TeasName
FROM (
	SELECT TeasId
	FROM Restocks
	WHERE EmployeeId IN (
		SELECT EmployeeId
		FROM Employees
		WHERE EmployeeName LIKE 'a%'
		)
	) AS RestockedProducts
INNER JOIN Teas AS T ON T.TeasId = RestockedProducts.TeasId
ORDER BY T.TeasName ASC;

SELECT *FROM Teas
SELECT *FROM Restocks
SELECT *FROM Employees

-- H.  4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 2 of the --latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, --SUM, AVG, MIN, MAX;

-- gets how many transaction of each cost have been finished
SELECT COUNT(Price) AS 'Count', Price
FROM ProductTransactions
GROUP BY Price;
SELECT *FROM ProductTransactions

-- gets which teas were bought more than once
SELECT COUNT(TeasId) AS 'Count', TeasId
FROM ProductTransactions
GROUP BY TeasId
HAVING COUNT(TeasId) > 1;
SELECT *FROM ProductTransactions

-- gets which Teas were bought a minimum amount of times
SELECT COUNT(TeasId) AS 'Count', TeasId
FROM ProductTransactions
GROUP BY TeasId
HAVING COUNT(TeasId) = (
	SELECT MIN(PIDCount)
	FROM (
		SELECT COUNT(TeasId) AS PIDCount
		FROM ProductTransactions
		GROUP BY TeasId
		) as PIDCounts
	)
SELECT *FROM Teas
SELECT *FROM ProductTransactions

-- Get's the stores that have an average quantity smaller than the average quantity of all inventories of all stores
SELECT AVG(Quantity) AS 'Average Quantity', StoreId
FROM Inventory
GROUP BY StoreId
HAVING AVG(Quantity) < (
	SELECT AVG(I.Quantity)
	FROM Inventory as I
	);

SELECT *FROM Stores
SELECT *FROM Inventory

-- I. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per --operator); rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.

-- select the stores which have any items from category 6
SELECT DISTINCT StoreId
FROM Inventory
WHERE TeasId = ANY (
	SELECT TeasId
	FROM Teas
	WHERE CategoryId = 6
	);
SELECT *FROM Stores
SELECT *FROM Inventory

-- -- rewritten using IN
SELECT DISTINCT StoreId
FROM Inventory
WHERE TeasId IN (
	SELECT TeasId
	FROM Teas
	WHERE CategoryId = 6
	);

SELECT *FROM Stores
SELECT *FROM Inventory

-- select the teas that were ever sold
SELECT TeasName
FROM Teas
WHERE TeasId = ANY (
	SELECT TeasId
	FROM ProductTransactions
	);
SELECT *FROM Teas
SELECT *FROM ProductTransactions

-- rewritten using IN
SELECT TeasName
FROM Teas
WHERE TeasId IN (
	SELECT TeasId
	FROM ProductTransactions
	);

-- select the lowest item in quantity
SELECT TeasId, Quantity
FROM Inventory
WHERE Quantity <= ALL (
	SELECT Quantity
	FROM Inventory
	);
SELECT *FROM Inventory
SELECT *FROM Teas

-- rewritten using min
SELECT TeasId, Quantity
FROM Inventory
WHERE Quantity = (
	SELECT MIN(Quantity)
	FROM Inventory
	);

-- select the most expensive items sold
SELECT TOP 3 TeasId
FROM ProductTransactions
WHERE Price >= ALL (
	SELECT Price
	FROM ProductTransactions
	);
SELECT *FROM ProductTransactions
SELECT *FROM Teas

-- rewritten using max
SELECT TeasId
FROM ProductTransactions
WHERE Price = (
	SELECT MAX(Price)
	FROM ProductTransactions
	);

