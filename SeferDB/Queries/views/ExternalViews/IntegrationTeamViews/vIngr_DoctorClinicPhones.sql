

/*-------------------------------------------------------------------------
Get all employee dept phones for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorClinicPhones]'))
	DROP VIEW [dbo].vIngr_DoctorClinicPhones
GO


CREATE VIEW [dbo].vIngr_DoctorClinicPhones
AS

select xde.employeeID as DoctorID, xde.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from x_Dept_Employee xde
join DeptPhones dp
on xde.deptCode = dp.deptCode
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode
where (xde.CascadeUpdateDeptEmployeePhonesFromClinic = 1 or 
		xde.CascadeUpdateDeptEmployeePhonesFromClinic is null)
union
select xde.employeeID as DoctorID, xde.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from x_Dept_Employee xde
join DeptEmployeePhones dp
on xde.DeptEmployeeID = dp.DeptEmployeeID
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode
where xde.CascadeUpdateDeptEmployeePhonesFromClinic = 0
--order by DoctorID, ClinicCode

GO


GRANT SELECT ON [dbo].vIngr_DoctorClinicPhones TO [public] AS [dbo]
GO
