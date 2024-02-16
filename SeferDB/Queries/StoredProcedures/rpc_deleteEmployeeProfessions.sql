IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeProfessions')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeProfessions
	END
GO

CREATE Procedure dbo.rpc_deleteEmployeeProfessions
	(
		@EmployeeID int,
		@ServiceCodes varchar(100) = ''
	)

AS

BEGIN

	DELETE FROM x_Dept_Employee_Service 
	FROM x_Dept_Employee_Service  xdes
	INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	WHERE employeeID = @employeeID
	AND xdes.serviceCode NOT IN
		(SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ServiceCodes))

	DELETE FROM deptEmployeeReceptionServices 
	FROM deptEmployeeReceptionServices ders
	INNER JOIN deptEmployeeReception der ON ders.receptionID = der.receptionID
	INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID
	AND ders.serviceCode NOT IN (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ServiceCodes))

	DELETE FROM deptEmployeeReception 
	FROM deptEmployeeReception der
	INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID
	AND NOT EXISTS 
		(SELECT * FROM deptEmployeeReceptionServices ders
		WHERE ders.receptionID = der.receptionID 
		AND serviceCode IN (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ServiceCodes))
		)
	
	DELETE FROM EmployeeServices WHERE EmployeeID = @employeeID
	AND EmployeeServices.serviceCode NOT IN (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ServiceCodes))
	
END
GO

GRANT EXEC ON dbo.rpc_deleteEmployeeProfessions TO [clalit\webuser]

GO