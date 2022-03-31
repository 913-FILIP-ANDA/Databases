USE lab2
GO

CREATE OR ALTER PROCEDURE ChangeVersion (@WantedVersion int)
AS      
	DECLARE @CurrentVersion int
	DECLARE @Procedure VARCHAR(50)
	SET @CurrentVersion = (SELECT CURRENTVERSION.CrtV
						FROM CURRENTVERSION)
	IF (@WantedVersion < 0 OR @WantedVersion > 7)
		RAISERROR('This version does not exist.', 16,16);
	ELSE 
		BEGIN
		IF (@WantedVersion > @CurrentVersion)
			BEGIN
			WHILE(@CurrentVersion != @WantedVersion)
				BEGIN
					SET @Procedure = (SELECT VERSIONS.USP
									FROM VERSIONS
									WHERE VERSIONS.TGetV = @CurrentVersion + 1)
					EXEC @Procedure
					SET @CurrentVersion = @CurrentVersion + 1
					UPDATE CURRENTVERSION SET CrtV = @CurrentVersion
				END;
			END;
		ELSE
			BEGIN 
			WHILE (@CurrentVersion != @WantedVersion)
				BEGIN
					SET @Procedure = (SELECT VERSIONS.RUSP
									FROM VERSIONS
									WHERE VERSIONS.TGetV = @CurrentVersion)
					EXEC @Procedure
					SET @CurrentVersion = @CurrentVersion - 1
					UPDATE CURRENTVERSION SET CrtV = @CurrentVersion
				END;
			END;
		END;
GO   

EXEC ChangeVersion 0
SELECT * FROM CURRENTVERSION;
SELECT * FROM VERSIONS;
GO


--a) modify the type of a column;
CREATE OR ALTER PROCEDURE USP_modify_type
AS
	ALTER TABLE Transactions
	ALTER COLUMN price varchar(17);
GO

EXEC USP_modify_type
GO

--undo
CREATE OR ALTER PROCEDURE USP_modify_type_undo
AS
	ALTER TABLE Transactions
	ALTER COLUMN price int;
GO

EXEC USP_modify_type_undo
GO

--b-add / remove a column;
CREATE OR ALTER PROCEDURE USP_add
AS
	ALTER TABLE Employees
	ADD address varchar(20);
GO

EXEC USP_add
GO

--undo
CREATE OR ALTER PROCEDURE USP_add_undo
AS
	ALTER TABLE Employees
	DROP COLUMN address;
GO

EXEC USP_add_undo
GO


--c-add / remove a DEFAULT constraint;
CREATE OR ALTER PROCEDURE USP_add_default_constraint
AS
	ALTER TABLE Stores
	ADD CONSTRAINT city_Cluj DEFAULT 'Cluj' FOR StoreAddress
GO

EXEC USP_add_default_constraint
GO

--undo
CREATE OR ALTER PROCEDURE USP_add_default_constraint_undo

AS
	ALTER TABLE Stores
	DROP CONSTRAINT city_Cluj;
GO

EXEC USP_add_default_constraint_undo
GO


--d- add / remove a primary key;
CREATE TABLE NewTable
(
	pkey SMALLINT NOT NULL,
	descr VARCHAR(50),
	CONSTRAINT PK_pkey PRIMARY KEY(pkey)
)
GO

--add
CREATE OR ALTER PROCEDURE USP_remove_pk
AS
	ALTER TABLE NewTable
	DROP CONSTRAINT PK_pkey
GO

EXEC USP_remove_pk
GO

--undo
CREATE OR ALTER PROCEDURE USP_remove_pk_undo
AS
	ALTER TABLE NewTable
	ADD CONSTRAINT PK_pkey PRIMARY KEY(pkey)
GO

EXEC USP_remove_pk_undo
GO


--e-add / remove a candidate key;
CREATE OR ALTER PROCEDURE USP_add_candkey
	
AS
	ALTER TABLE Categories
	ADD CONSTRAINT ck_CategoryName UNIQUE (CategoryName);
	
GO

EXEC USP_add_candkey
GO

--undo
CREATE OR ALTER PROCEDURE USP_add_candkey_undo
AS
	ALTER TABLE Categories
	DROP CONSTRAINT ck_CategoryName;
GO

EXEC USP_add_candkey_undo
GO


--f-add / remove a foreign key;
CREATE OR ALTER PROCEDURE USP_add_fk
	
AS
	ALTER TABLE Teas
	ADD CONSTRAINT fk_CategoryId FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);
	
GO

EXEC USP_add_fk
GO

--undo
CREATE OR ALTER PROCEDURE USP_add_fk_undo
AS
	ALTER TABLE Teas
	DROP CONSTRAINT fk_CategoryId;
GO

EXEC USP_add_fk_undo
GO


--g- create / drop a table.
CREATE OR ALTER PROCEDURE USP_create
AS
	CREATE TABLE create_test (
		fake_id int
	);
GO

EXEC USP_create
GO

--undo
CREATE OR ALTER PROCEDURE USP_create_undo
AS
	DROP TABLE IF EXISTS create_test;
GO

EXEC USP_create_undo
GO


/*CREATE TABLE CURRENT VERSION*/
CREATE TABLE CURRENTVERSION (
	CrtV INT
)

INSERT INTO CURRENTVERSION VALUES (0)
SELECT * FROM CURRENTVERSION;

/*CREATE VERSIONS TGetV, TABLE USP, RUSP*/
CREATE TABLE VERSIONS (
	TGetV INT,
	USP VARCHAR(50),
	RUSP VARCHAR(50),
)

INSERT INTO VERSIONS VALUES (1, 'USP_modify_type','USP_modify_type_undo')
INSERT INTO VERSIONS VALUES (2, 'USP_add','USP_add_undo')
INSERT INTO VERSIONS VALUES (3, 'USP_add_default_constraint','USP_add_default_constraint_undo')
INSERT INTO VERSIONS VALUES (4, 'USP_remove_pk','USP_remove_pk_undo')
INSERT INTO VERSIONS VALUES (5, 'USP_add_candkey','USP_add_candkey_undo')
INSERT INTO VERSIONS VALUES (6, 'USP_add_fk','USP_add_fk_undo')
INSERT INTO VERSIONS VALUES (7, 'USP_create','USP_create_undo')



