IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmplServAgreemExpert]'))
DROP VIEW [dbo].[vEmplServAgreemExpert]
GO

CREATE VIEW [dbo].[vEmplServAgreemExpert]

AS
SELECT xd.employeeID, xd.deptCode, xd.AgreementType, xdes.serviceCode, ES.ExpProfession 
			FROM x_Dept_Employee_Service  xdes
			INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
				AND xdes.Status = 1			
			LEFT JOIN EmployeeServices ES ON xdes.serviceCode = ES.serviceCode
				AND xd.EmployeeID = ES.EmployeeID
GO

grant select on vEmplServAgreemExpert to public 
GO	