IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderMethods]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderMethods]
GO


CREATE FUNCTION [dbo].[fun_GetQueueOrderMethods] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	QueueOrderMethodID int,
	QueueOrderMethod int,		
	employeeID bigint,
	QueueOrderMethodDescription varchar(50),
	ShowPhonePicture tinyint,
	SpecialPhoneNumberRequired tinyint
)
as
BEGIN

	DECLARE @PermitOrderMethods int

	SET @PermitOrderMethods = 
	(SELECT DIC_QO_S.PermitOrderMethods 
	FROM x_Dept_Employee x_DE
	LEFT JOIN x_Dept_Employee_Service x_DES ON x_DE.DeptEmployeeID = x_DES.DeptEmployeeID
	LEFT JOIN DIC_QueueOrder DIC_QO_S ON x_DES.QueueOrder = DIC_QO_S.QueueOrder  
	WHERE x_DE.deptCode = @DeptCode 
	and x_DE.employeeID = @EmployeeID
	and x_DES.serviceCode = @ServiceCode)  

	IF @PermitOrderMethods is not null
	BEGIN

		INSERT INTO @ResultTable
		SELECT 
		esqom.EmployeeServiceQueueOrderMethodID as 'QueueOrderMethodID',
		esqom.QueueOrderMethod,
		xDE.DeptEmployeeID,
		DIC_QueueOrderMethod.QueueOrderMethodDescription,
		DIC_QueueOrderMethod.ShowPhonePicture,
		DIC_QueueOrderMethod.SpecialPhoneNumberRequired

		FROM EmployeeServiceQueueOrderMethod esqom
		INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
		INNER JOIN x_Dept_Employee xDE ON xdes.DeptEmployeeID = xDE.DeptEmployeeID
		INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
		WHERE xDE.deptCode = @DeptCode
		AND xDE.EmployeeID = @EmployeeID
		AND xdes.serviceCode = @serviceCode
	END

	ELSE
	BEGIN

		INSERT INTO @ResultTable
		SELECT 
		EQOM.QueueOrderMethodID,
		EQOM.QueueOrderMethod,
		xDE.DeptEmployeeID,
		DIC_QueueOrderMethod.QueueOrderMethodDescription,
		DIC_QueueOrderMethod.ShowPhonePicture,
		DIC_QueueOrderMethod.SpecialPhoneNumberRequired

		FROM EmployeeQueueOrderMethod EQOM
		INNER JOIN DIC_QueueOrderMethod ON EQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
		INNER JOIN x_dept_employee xDE ON EQOM.DeptEmployeeID = xDE.DeptEmployeeID	
		WHERE xDE.deptCode = @DeptCode 
		AND xDE.EmployeeID = @employeeID

	END

	RETURN
END

GO


