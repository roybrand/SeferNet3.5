IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceInDeptCurrentStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceInDeptCurrentStatus
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeServiceInDeptCurrentStatus
(	
	@employeeID BIGINT,
	@deptCode	INT,
	@serviceCode INT,
	@status SMALLINT,
	@updateUser VARCHAR(30)
)

AS

DECLARE @deptEmployeeID INT

SET @deptEmployeeID = (SELECT DeptEmployeeID	
					   FROM x_Dept_Employee 
					   WHERE deptCode = @deptCode
					   AND employeeID = @employeeID)


UPDATE x_Dept_Employee_Service
SET Status = @status , UpdateUser = @updateUser, UpdateDate = GETDATE()
WHERE DeptEmployeeID = @deptEmployeeID
AND ServiceCode = @serviceCode

IF ( @status = 0 )
BEGIN
	DELETE FROM deptEmployeeReception
	WHERE receptionID IN
	(	SELECT deptEmployeeReception.receptionID
		FROM deptEmployeeReception
		INNER JOIN deptEmployeeReceptionServices 
			ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
			AND deptEmployeeReception.DeptEmployeeID = @deptEmployeeID			
			AND deptEmployeeReceptionServices.serviceCode = @serviceCode
	)
END

GO


GRANT EXEC ON rpc_UpdateEmployeeServiceInDeptCurrentStatus TO PUBLIC

GO


