IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDeptServicesRemarks]'))
DROP VIEW [dbo].[vDeptServicesRemarks]
GO

CREATE VIEW [dbo].[vDeptServicesRemarks]
AS

SELECT
DESR.DeptEmployeeServiceRemarkID,
DeptCode,
ServiceCode,
RemarkID,
RemarkText = REPLACE( DESR.RemarkText, '#', ''),
displayInInternet,
ValidFrom,
ValidTo,
IsMedicalTeam
FROM DeptEmployeeServiceRemarks DESR
join x_Dept_Employee_Service xDES on DESR.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
join Employee on Employee.employeeID = xDE.employeeID
WHERE 
	  (DESR.ValidFrom IS NULL OR
	  DESR.ValidFrom <= GETDATE()) AND (DESR.ValidTo IS NULL OR
	  DESR.ValidTo >= GETDATE())

GO

grant select on vDeptServicesRemarks to public 

GO
