	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeReception')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeReception
	END

GO

CREATE Procedure [dbo].[rpc_DeleteEmployeeReception]
(
	@employeeID BIGINT,
	@deptCode INT,
	@agreementType INT
)

AS

SET XACT_ABORT on
BEGIN TRY
	DELETE DeptEmployeeReception
	FROM DeptEmployeeReception der
	INNER JOIN x_dept_employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE ( @deptCode = -1 AND EmployeeID = @employeeID   
			AND (@agreementType = -1 OR agreementType = @agreementType))
	OR (EmployeeID = @employeeID AND DeptCode = @deptCode AND (@agreementType = -1 OR agreementType = @agreementType))

	DELETE deptEmployeeReception_Regular
	FROM deptEmployeeReception_Regular der
	INNER JOIN x_dept_employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE ( @deptCode = -1 AND EmployeeID = @employeeID   
			AND (@agreementType = -1 OR agreementType = @agreementType))
	OR (EmployeeID = @employeeID AND DeptCode = @deptCode AND (@agreementType = -1 OR agreementType = @agreementType))
END TRY
BEGIN CATCH
	Exec master.dbo.sp_RethrowError
END CATCH
GO




GRANT EXEC ON rpc_DeleteEmployeeReception TO PUBLIC

GO


