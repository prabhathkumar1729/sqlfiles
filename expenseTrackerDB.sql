
create database expenseTrackerDB;

CREATE TABLE Users
(
	Id INT IDENTITY(101,1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE,
	Password VARCHAR(100) NOT NULL,
	SecurityQuestion VARCHAR(200) NOT NULL,
	SecurityAnswer VARCHAR(100) NOT NULL,
	IsUserActive BIT DEFAULT 1 NOT NULL,	
);

CREATE TABLE Transactions
(
	TransactionId INT IDENTITY(1,1) PRIMARY KEY,
	UserId INT NOT NULL,
	TransactionDate DATE NOT NULL,
	Amount DECIMAL(15,2) NOT NULL,
	Category VARCHAR(15) DEFAULT 'Others' NOT NULL,
	Description nvarchar(500) NOT NULL,
	IsActive BIT DEFAULT 1 NOT NULL,
	CONSTRAINT FK_Users	FOREIGN KEY (UserId) REFERENCES [Users] (Id)
)

DROP TABLE Transactions;

DROP TABLE Users;

SELECT * FROM Users;
SELECT * FROM Transactions;
SeLECT DISTINCT( Category) FROM Transactions where UserId = 102 AND IsActive = 1;
SELECT * FROM Transactions WHERE UserId = 101 AND IsActive = 1;

update Transactions set IsActive = 1


truncate table Transactions;
drop table Transactions;
