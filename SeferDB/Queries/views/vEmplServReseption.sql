IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmplServReseption]'))
DROP VIEW [dbo].[vEmplServReseption]
GO

CREATE VIEW [dbo].[vEmplServReseption]

AS
SELECT employeeID, deptCode, serviceCode, receptionDay, openingHour, closingHour,
der.validFrom, der.validTo, der.ReceiveGuests
FROM deptEmployeeReception_Regular as der
INNER JOIN deptEmployeeReceptionServices ders ON der.DeptEmployeeReceptionID = ders.receptionID
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
GROUP BY employeeID, deptCode, serviceCode, receptionDay, openingHour, closingHour,
der.validFrom, der.validTo, der.ReceiveGuests

GO	

GRANT SELECT ON vEmplServReseption TO [clalit\webuser]
GO

GRANT SELECT ON vEmplServReseption TO [clalit\IntranetDev]
GO