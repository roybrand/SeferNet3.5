/****** Object:  View [dbo].[view_DeptEmployeeServiceRemarks]    Script Date: 12/25/2011 13:07:00 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[view_DeptEmployeeServiceRemarks]'))
DROP VIEW [dbo].[view_DeptEmployeeServiceRemarks]
GO

CREATE VIEW [dbo].[view_DeptEmployeeServiceRemarks]
AS
 
SELECT 
 DeptEmployeeServiceRemarkID
, RemarkID
, RemarkText
, ActiveFrom as ValidFrom
, ValidTo
, DisplayInInternet
, UpdateDate
, UpdateUser
, x_dept_employee_serviceID

FROM DeptEmployeeServiceRemarks as DESR

GO