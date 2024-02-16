IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptCurrentStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptCurrentStatus
	END

GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeInDeptCurrentStatus]
(		
	@employeeID BIGINT,
	@deptCode INT,
	@agreementType INT,
	@status	TINYINT,
	@updateUser VARCHAR(30)
)

AS

UPDATE x_Dept_Employee 
SET Active = @status, updateDate = GETDATE(),  UpdateUserName = @updateUser
WHERE DeptCode = @deptCode 
AND EmployeeID = @employeeID
AND AgreementType = @agreementType

DELETE FROM x_Dept_Employee_Position
FROM x_Dept_Employee_Position xdep
INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID  = @employeeID 
AND xd.deptCode = @deptCode
AND AgreementType = @agreementType
AND @status = 0

DELETE FROM x_Dept_Employee_Service
FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE EmployeeID = @employeeID 
AND xd.deptCode = @deptCode
AND AgreementType = @agreementType
AND @status = 0

GO


GRANT EXEC ON rpc_UpdateEmployeeInDeptCurrentStatus TO PUBLIC

GO


