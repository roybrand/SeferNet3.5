IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorAbsenceDetails')
	BEGIN
		DROP  Procedure  rpc_getDoctorAbsenceDetails
	END

GO

CREATE Procedure rpc_getDoctorAbsenceDetails

	(
		@AbsenceCode int
	)
		

AS


SELECT 
absenceCode,
EmployeeID, 
deptEmployeeAbsence.reasonCode,
deptEmployeeAbsence.deptCode,
dept.deptName,
reasonDescription,
fromDate,
toDate,
deptEmployeeAbsence.UpdateUserName

FROM deptEmployeeAbsence
INNER JOIN absenceReasons ON  deptEmployeeAbsence.reasonCode = absenceReasons.reasonCode
inner join dept on deptEmployeeAbsence.deptCode = dept.deptCode

WHERE AbsenceCode=@AbsenceCode

GO


GRANT EXEC ON rpc_getDoctorAbsenceDetails TO PUBLIC

GO


