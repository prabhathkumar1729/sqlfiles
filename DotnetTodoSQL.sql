
CREATE DATABASE todoDB;

CREATE TABLE profile
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(25) NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE,
	PhoneNo VARCHAR(10) NOT NULL CHECK (LEN(PhoneNo) = 10),
	IsUserActive BIT DEFAULT 1
)
CREATE TABLE Credentials
(
	CredentialsId INT IDENTITY(1000,1),
	UserId INT NOT NULL,
	UserEmail VARCHAR(100) NOT NULL,
	UserPass VARCHAR(20) NOT NULL,
	CONSTRAINT FK_Credentials_User
	FOREIGN KEY (UserId)
	REFERENCES [profile] (Id)
)
CREATE TABLE todos
(
	TodoId INT IDENTITY (1,1) PRIMARY KEY,
	UserId INT NOT NULL,
	Task VARCHAR(max) NOT NULL,
	CreatedData DATETIME DEFAULT GETDATE(),
	IsCompleted BIT DEFAULT 0,
	IsTodoActive BIT DEFAULT 1,
	CONSTRAINT FK_Todo_User
	FOREIGN KEY (UserId)
	REFERENCES [profile] (Id)
)

GO
CREATE PROCEDURE RegisterUser
   ( @Email VARCHAR(100),
    @Password VARCHAR(100),
    @Name VARCHAR(100),
    @PhoneNo VARCHAR(10))
AS
BEGIN
    INSERT INTO profile (Name, Email, PhoneNo)
    VALUES (@Name, @Email, @PhoneNo);

	DECLARE @UserId INT;
    SET @UserId = SCOPE_IDENTITY();

	INSERT INTO Credentials (UserId, UserEmail, UserPass)
    VALUES (@UserId, @Email, @Password);

	RETURN 1;
END

															

SELECT * FROM Credentials;
SELECT * FROM profile;
SELECT * FROM todos;

