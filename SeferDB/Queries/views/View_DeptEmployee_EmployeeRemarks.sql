
/****** Object:  View [dbo].[View_DeptEmployee_EmployeeRemarks]    Script Date: 12/25/2011 13:07:00 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployee_EmployeeRemarks]'))
DROP VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
GO

CREATE VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
AS
 
SELECT 
xd.DeptCode as DeptCode,
xd.EmployeeID,
xd.DeptCode as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText) as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ActiveFrom as ValidFrom,
EmployeeRemarks.ValidTo,
EmployeeRemarks.updateDate,
xd.DeptEmployeeID


FROM x_Dept_Employee_EmployeeRemarks as x_D_E_ER
INNER JOIN EmployeeRemarks ON x_D_E_ER.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
INNER JOIN x_Dept_Employee xd ON x_D_E_ER.DeptEmployeeID = xd.DeptEmployeeID


UNION

SELECT
Dept.deptCode as DeptCode,
EmployeeRemarks.EmployeeID,
0 as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText) as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ActiveFrom as ValidFrom,
EmployeeRemarks.ValidTo,
EmployeeRemarks.updateDate,
x_D_E.DeptEmployeeID

FROM EmployeeRemarks 
join x_Dept_Employee as x_D_E on EmployeeRemarks.EmployeeID = x_D_E.employeeID
join Dept on Dept.deptCode = x_D_E.DeptCode
	and (
		(EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and Dept.IsCommunity = 1)  
	or (EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and Dept.IsMushlam = 1)
	or (EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and Dept.IsHospital = 1)
	)

GO

grant select on View_DeptEmployee_EmployeeRemarks to public 
go


