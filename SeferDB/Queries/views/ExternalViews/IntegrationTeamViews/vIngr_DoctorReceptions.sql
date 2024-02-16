
/*-------------------------------------------------------------------------
Get all doctors receptions data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorReceptions]'))
	DROP VIEW [dbo].vIngr_DoctorReceptions
GO


CREATE VIEW [dbo].vIngr_DoctorReceptions
AS
select xde.deptCode as ClinicCode, xde.employeeID as DoctorID, ders.serviceCode, 
		der.receptionDay, der.openingHour, der.closingHour,
		derr.RemarkID, derr.RemarkText
from deptEmployeeReception der
join deptEmployeeReceptionServices ders
on der.receptionID = ders.receptionID
join x_Dept_Employee xde
on der.DeptEmployeeID = xde.DeptEmployeeID
left join DeptEmployeeReceptionRemarks derr
on der.receptionID = derr.EmployeeReceptionID
where GETDATE() between ISNULL(der.validFrom, '1900-01-01') and ISNULL(der.validTo, '2079-01-01')

GO


GRANT SELECT ON [dbo].vIngr_DoctorReceptions TO [public] AS [dbo]
GO
