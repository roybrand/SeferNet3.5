IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateUserViaAD')
	BEGIN
		DROP  Procedure  rpc_updateUserViaAD
	END

GO

CREATE Procedure dbo.rpc_updateUserViaAD
	(
		@UserName varchar(50),
		@UserID bigint,
		@FirstName varchar(50),
		@LastName varchar(50),
		@Email varchar(50),
		@PhoneNumber varchar(50)
	)

AS

	update Users
	set
	UserID = @UserID,
	FirstName = @FirstName,
	LastName = @LastName,
	Email = @Email,
	PhoneNumber = @PhoneNumber
	where
	UserName = @UserName

GO

GRANT EXEC ON rpc_updateUserViaAD TO PUBLIC

GO

