IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_InsertDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_InsertDeptEmployeeServiceRemark
(
	@deptEmployeeID INT,  
	@serviceCode INT, 
	@remarkID INT, 
	@remarkText VARCHAR(500), 
    @dateFrom DATETIME, 
    @dateTo DATETIME,  
    @displayOnInternet BIT, 
    @userName VARCHAR(30)
)

AS

DECLARE @deptEmployeeServiceID INT

SELECT @deptEmployeeServiceID = x_Dept_Employee_ServiceID		
								FROM x_Dept_Employee_Service xdes		
								INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
								WHERE xd.deptEmployeeID = @deptEmployeeID
								AND xdes.serviceCode = @serviceCode 

IF EXISTS 
(
	SELECT * 
	FROM DeptEmployeeServiceRemarks
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID
)

	UPDATE DeptEmployeeServiceRemarks
	SET RemarkID = @remarkID, 
		RemarkText = @remarkText, 
		ValidFrom = @dateFrom,
		ValidTo = @dateTo,
		DisplayInInternet = @displayOnInternet,
		UpdateDate = GETDATE(),
		UpdateUser = @userName
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID

ELSE
BEGIN

INSERT INTO DeptEmployeeServiceRemarks
VALUES (@remarkID, @remarkText, @dateFrom, @dateTo,  @displayOnInternet, GETDATE(), @userName, @deptEmployeeServiceID )


UPDATE x_dept_employee_service
SET DeptEmployeeServiceRemarkID = @@IDENTITY
WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID

END

GO


GRANT EXEC ON dbo.rpc_InsertDeptEmployeeServiceRemark TO PUBLIC

GO





