/*
	View for integration team for spGetClinicAndDoctorDetails & spGetClinicOrDoctorDetails stores
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vWS_x_Dept_Employee]'))
	DROP VIEW [dbo].[vWS_x_Dept_Employee]
GO

CREATE VIEW [dbo].[vWS_x_Dept_Employee]
AS SELECT  deptCode ,
        employeeID ,
        CascadeUpdateDeptEmployeePhonesFromClinic ,
        DeptEmployeeID 
FROM x_Dept_Employee  WHERE active=1

GO

GRANT SELECT ON [dbo].[vWS_x_Dept_Employee] TO [public] AS [dbo]
GO
