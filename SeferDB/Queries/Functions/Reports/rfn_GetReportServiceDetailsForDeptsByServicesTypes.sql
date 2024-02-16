IF EXISTS (SELECT * FROM sysobjects WHERE type = 'IF' AND name = 'rfn_GetReportServiceDetailsForDeptsByServicesTypes')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes
	END
GO

create  function dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes
 (
	@DeptCode int
 ) 
RETURNS TABLE

as

return 	
(

--=======
-- doctors services details 
--=======
-------------Services of Doctors in Clinic --------------------------------------
SELECT DISTINCT
x_D_E_S.serviceCode,
x_dept_employee.deptCode,
Services.serviceDescription,
'phones' = '',

CASE WHEN QueueOrderDetailsServ.QueueOrderDescription IS NULL 
	 THEN QueueOrderDetails.QueueOrderDescription 
	 ELSE QueueOrderDetailsServ.QueueOrderDescription END as QueueOrderDescription, 
CASE WHEN QueueOrderDetailsServ.QueueOrderClinicTelephone IS NULL
	 THEN QueueOrderDetails.QueueOrderClinicTelephone
	 ELSE QueueOrderDetailsServ.QueueOrderClinicTelephone END as QueueOrderClinicTelephone, 
CASE WHEN QueueOrderDetailsServ.QueueOrderSpecialTelephone IS NULL
	 THEN QueueOrderDetails.QueueOrderSpecialTelephone
	 ELSE QueueOrderDetailsServ.QueueOrderSpecialTelephone END as QueueOrderSpecialTelephone,
CASE WHEN QueueOrderDetailsServ.QueueOrderTelephone2700 IS NULL
	 THEN QueueOrderDetails.QueueOrderTelephone2700
	 ELSE QueueOrderDetailsServ.QueueOrderTelephone2700 END as QueueOrderTelephone2700,
CASE WHEN QueueOrderDetailsServ.QueueOrderInternet IS NULL
	 THEN QueueOrderDetails.QueueOrderInternet
	 ELSE QueueOrderDetailsServ.QueueOrderInternet END as QueueOrderInternet,
	
'serviceIsGivenByPerson' = x_dept_employee.employeeID,
'PersonsName' = DegreeName + ' ' + lastName + ' ' + firstName,
Services.showOrder,
viaPerson = 1,
'employeeID' = x_dept_employee.employeeID ,
replace(dbo.fun_getRemarkByServiceByEmployee(x_dept_employee.deptCode,x_dept_employee.employeeID , x_D_E_S.serviceCode), '&quot;', char(34))
 as remark

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID and x_dept_employee.deptCode = @DeptCode
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee_Service as x_D_E_S 
	ON x_dept_employee.DeptEmployeeID = x_D_E_S.DeptEmployeeID
INNER JOIN Services	
	ON x_D_E_S.serviceCode = Services.serviceCode
	and Services.IsService = 1 
cross apply rfn_GetDeptEmployeeQueueOrderDetails(x_dept_employee.deptCode, x_dept_employee.employeeID) as QueueOrderDetails
cross apply rfn_GetDeptEmployeeServiceQueueOrderDetails(x_dept_employee.deptCode, x_dept_employee.employeeID, x_D_E_S.serviceCode) as QueueOrderDetailsServ


) 

/*GO
grant exec on dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes to public 
*/
GO
