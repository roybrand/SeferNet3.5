IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeReceptions')
	BEGIN
		DROP  View View_DeptEmployeeReceptions
	END
GO

CREATE VIEW [dbo].[View_DeptEmployeeReceptions]
AS
SELECT *
FROM         
(
----------------- deptEmployeeReceptionProfession --------------------
SELECT
x_dept_employee.deptCode,
x_dept_employee.employeeId,
x_dept_employee.AgreementType,
serviceDescription = null,
serviceCode = null,
Services.ServiceDescription as ProfessionDescription,
Services.ServiceCode as ProfessionCode,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
recep.validFrom,
recep.validTo,
RecRemarks.remarkText,
recep.ReceptionRoom

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep  
on	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID	
inner join dbo.deptEmployeeReceptionServices as RecProf on Recep.receptionID = RecProf.receptionID  
inner join Services	ON RecProf.ServiceCode = Services.ServiceCode
	and Services.IsProfession = 1  
inner join DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.EmployeeReceptionID

		
UNION
----------------- deptEmployeeReceptionServices --------------------
SELECT
x_dept_employee.deptCode,
x_dept_employee.employeeId,
x_dept_employee.AgreementType,
Services.serviceDescription,
RecServ.serviceCode,
ProfessionDescription = null,
ProfessionCode = null,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
recep.validFrom,
recep.validTo,
RecRemarks.remarkText,
recep.ReceptionRoom

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep  on	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID	
inner join dbo.deptEmployeeReceptionServices as RecServ on Recep.receptionID = RecServ.receptionID  
inner join Services	ON RecServ.serviceCode = Services.serviceCode 
	and Services.IsService = 1 
inner join DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID

 )
AS subq

GO






