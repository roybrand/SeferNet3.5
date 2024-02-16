IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeStatus')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeStatus
	END

GO

CREATE Procedure dbo.rpc_InsertEmployeeStatus
(
	@employeeID BIGINT,
	@status		INT,
	@fromDate	DATETIME,
	@toDate		DATETIME,
	@updateUser	VARCHAR(50)
)


AS

INSERT INTO EmployeeStatus(EmployeeID, Status, FromDate, ToDate, UpdateUser, UpdateDate)
VALUES	(@employeeID, @status, @fromDate, @toDate, @updateUser, GETDATE() )


GO


GRANT EXEC ON rpc_InsertEmployeeStatus TO PUBLIC

GO


