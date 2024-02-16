IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorAbsence')
	BEGIN
		DROP  Procedure  rpc_getDoctorAbsence
	END

GO

CREATE Procedure rpc_getDoctorAbsence

	(
		@EmployeeID int,		
		@UserFullName varchar(50)
	)
AS
	
	
	 CREATE TABLE #dept_temp (
     deptCode int NOT NULL PRIMARY KEY CLUSTERED
    
    )

    insert into #dept_temp
    exec rpc_getUserPermittedDepts @UserFullName
     
    declare @UserName varchar(50)
	SET @UserName = right(@UserFullName ,len(@UserFullName)-7) 
		

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
INNER JOIN #dept_temp ON Dept.DeptCode = #dept_temp.DeptCode

WHERE EmployeeID=@EmployeeID 

DROP TABLE #dept_temp

GO


GRANT EXEC ON rpc_getDoctorAbsence TO PUBLIC

GO

