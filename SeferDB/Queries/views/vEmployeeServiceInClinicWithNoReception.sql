IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeServiceInClinicWithNoReception]'))
DROP VIEW [dbo].[vEmployeeServiceInClinicWithNoReception]
GO

CREATE VIEW vEmployeeServiceInClinicWithNoReception
AS
SELECT xDE.employeeID, xDE.deptCode, xDE.AgreementType, xDE.DeptEmployeeID
, s.ServiceDescription, s.ServiceCode, s.IsProfession, s.IsService
, CASE es.expProfession	WHEN 1 THEN 1 ELSE 0 END as expProfession
FROM x_Dept_Employee xDE
inner join x_Dept_Employee_Service as xDES ON xDE.DeptEmployeeID = xDES.DeptEmployeeID
inner join [Services] s on xDES.serviceCode = s.ServiceCode
LEFT join EmployeeServices es ON xDE.employeeID = es.EmployeeID
	AND xDES.serviceCode = es.serviceCode
WHERE xDE.active = 1 AND xDES.Status = 1
AND (SELECT COUNT(*)
	FROM deptEmployeeReception deR
	JOIN deptEmployeeReceptionServices deRS ON deR.receptionID = deRS.receptionID
	WHERE deR.DeptEmployeeID = xDE.DeptEmployeeID 
	AND deRS.serviceCode = xDES.serviceCode) = 0

GO

grant select on v_DeptReception to public 
go

GRANT select ON v_DeptReception TO [clalit\webuser]
GO

GRANT select ON v_DeptReception TO [clalit\IntranetDev]
GO