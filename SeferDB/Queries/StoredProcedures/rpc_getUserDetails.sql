IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserDetails')
	BEGIN
		DROP  Procedure  rpc_getUserDetails
	END

GO

CREATE Procedure rpc_getUserDetails

	(
		@UserName varchar(20)
		
	)


AS
	select
	UserName,
	UserDescription,
	PhoneNumber,
	FirstName,
	LastName
	from
	Users
	Where
	UserName = @UserName


GO


GRANT EXEC ON rpc_getUserDetails TO PUBLIC

GO


