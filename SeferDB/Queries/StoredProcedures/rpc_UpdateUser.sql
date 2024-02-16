IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateUser')
	BEGIN
		DROP  Procedure  rpc_updateUser
	END

GO

CREATE Procedure dbo.rpc_updateUser
(
	@UserID bigint,
	@UserName varchar(50),
	@Domain varchar(50),
	@UserDescription varchar(50),
	@PhoneNumber varchar(20),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@UpdateUserName varchar(50)
)

AS

	update Users
	SET
	UserName = @UserName,
	Domain = @Domain,
	UserDescription = @UserDescription,
	PhoneNumber =	@PhoneNumber ,
	FirstName =	@FirstName,
	LastName =	@LastName,
	Email = @Email,
	UpdateUser = CASE WHEN @UpdateUserName is not null AND @UpdateUserName <> '' THEN @UpdateUserName ELSE UpdateUser END
	WHERE
	UserID = @UserID 

GO


GRANT EXEC ON dbo.rpc_updateUser TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_updateUser TO [clalit\IntranetDev]
GO

