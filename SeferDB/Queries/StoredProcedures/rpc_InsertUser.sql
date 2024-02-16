IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertUser')
	BEGIN
		DROP  Procedure  rpc_InsertUser
	END

GO

CREATE PROCEDURE dbo.rpc_InsertUser

	(
		@UserID bigint,
		@UserName varchar(50),
		@Domain varchar(50),
		@UserDescription varchar(50),
		@PhoneNumber varchar(20),
		@FirstName varchar(50),
		@LastName varchar(50),
		@Email varchar(50),
		@DefinedInAD tinyint,
		@UpdateUserName varchar(50)
	)


AS


	insert into Users
	(UserID, UserName, UserDescription, PhoneNumber, FirstName, LastName, Domain, Email, DefinedInAD, UpdateUser)
	values
	(@UserID,@UserName,@UserDescription,@PhoneNumber,@FirstName,@LastName,@Domain,@Email,@DefinedInAD, @UpdateUserName)
	

GO


GRANT EXEC ON dbo.rpc_updateUser TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_updateUser TO [clalit\IntranetDev]
GO


