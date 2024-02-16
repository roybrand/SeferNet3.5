IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDoctorAbsence')
	BEGIN
		DROP  Procedure  rpc_InsertDoctorAbsence
	END

GO

CREATE Procedure rpc_InsertDoctorAbsence
(
		
		@ReasonCode int,
		@EmployeeID int,
		@DeptCode int,
		@FromDate datetime,
		@ToDate datetime,
		@UpdateUserName varchar(50)
	)


AS
	insert into
	deptEmployeeAbsence
	(ReasonCode,EmployeeID,DeptCode,FromDate,ToDate,UpdateUserName)
	values
	(@ReasonCode,@EmployeeID,@DeptCode,@FromDate,@ToDate,@UpdateUserName)
	
	

GO

GRANT EXEC ON rpc_InsertDoctorAbsence TO PUBLIC

GO


