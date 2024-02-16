IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderPhones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderPhones]
GO

CREATE FUNCTION [dbo].[fun_GetQueueOrderPhones] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	Phone varchar(20),
	QueueOrderMethodID int,		
	deptCode int,
	employeeID bigint,
	serviceCode int
)
as
begin
	/* The first select is from the service phones,
	   if it's empty the next select is from the employee phones,
	   and if there is no result, the next select is from the dept
	   phones.
	*/
	insert into @ResultTable
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(ESQOP.Preprefix, ESQOP.Prefix, ESQOP.Phone, ESQOP.Extension) as Phone,  
	ESQOM.EmployeeServiceQueueOrderMethodID,
	dept.deptCode,
	xDE.employeeID,
	xDEs.serviceCode
	
	
	FROM EmployeeServiceQueueOrderPhones ESQOP
	join employeeServiceQueueOrderMethod ESQOM on ESQOM.employeeServiceQueueOrderMethodID = ESQOP.employeeServiceQueueOrderMethodID
	join x_dept_employee_service xDES on xDES.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE on xDE.deptEmployeeID = xDES.deptEmployeeID
	join dept on dept.deptCode = xDE.deptCode
	join DIC_QueueOrderMethod on DIC_QueueOrderMethod.QueueOrderMethod = ESQOM.QueueOrderMethod
	WHERE (xDEs.serviceCode = @serviceCode)
	and (dept.deptCode = @deptCode)
	and(xDE.employeeID = @employeeID) 
	
	UNION
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(DEQOP.Preprefix, DEQOP.Prefix, DEQOP.Phone, DEQOP.Extension) as Phone,  
	EQOM.QueueOrderMethodID,
	xDE.deptCode,
	xDE.employeeID,
	x_D_E_S.serviceCode
	
	FROM DeptEmployeeQueueOrderPhones DEQOP
	join EmployeeQueueOrderMethod EQOM on DEQOP.QueueOrderMethodID = EQOM.QueueOrderMethodID
	join x_dept_employee xDE on xDE.deptEmployeeID = EQOM.deptEmployeeID
	join dept on xDE.deptCode = dept.deptCode
	left JOIN x_Dept_Employee_Service x_D_E_S
		ON xDE.deptemployeeID = x_D_E_S.deptemployeeID
	
	WHERE xDE.deptCode = @DeptCode and xDE.employeeID = @employeeID
	and x_D_E_S.serviceCode = @serviceCode 
	AND NOT EXISTS
	(SELECT * FROM EmployeeServiceQueueOrderMethod ESQOM
	join x_dept_employee_service xDES on xDES.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE2 on xDE2.deptEmployeeID = xDES.deptEmployeeID
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID 
	AND xDES.serviceCode = x_D_E_S.serviceCode)
	
	
	UNION
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(DQOP.Preprefix, DQOP.Prefix, DQOP.Phone, DQOP.Extension) as Phone,
	DQOP.QueueOrderMethodID,
	xDE.deptCode,
	xDE.employeeID,
	xDES.serviceCode
	
	from DeptQueueOrderPhones DQOP
	join deptQueueOrderMethod DQOM on DQOM.QueueOrderMethodID = DQOP.QueueOrderMethodID
	join Dept on dept.deptCode = DQOM.deptCode
	join x_dept_employee xDE on dept.deptCode = xDE.deptCode
	join x_dept_employee_service xDES on xDE.deptEmployeeID = xDES.deptEmployeeID
	
	WHERE 
	DQOM.deptCode = @deptCode
	and xDE.employeeID = @employeeID 
	and xDES.serviceCode = @serviceCode
	AND NOT EXISTS
	(SELECT * FROM EmployeeServiceQueueOrderMethod ESQOM
	join x_dept_employee_service xDES2 on xDES2.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE2 on xDE2.deptEmployeeID = xDES2.deptEmployeeID
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID 
	AND xDES2.serviceCode = xDES.serviceCode)
	
	AND NOT EXISTS
	(SELECT * FROM EmployeeQueueOrderMethod EQOM
	join x_dept_employee xDE2 on EQOM.deptEmployeeID = xDE2.deptEmployeeID
	
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID)
	
	return
end





GO


