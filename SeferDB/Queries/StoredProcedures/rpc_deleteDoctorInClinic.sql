IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDoctorInClinic')
	BEGIN
		DROP  Procedure  rpc_deleteDoctorInClinic
	END

GO

CREATE Procedure [dbo].[rpc_deleteDoctorInClinic]
(
	@DeptEmployeeID int,
	@deptCode int
)

AS
	
	DELETE x_Dept_Employee_EmployeeRemarks
	WHERE DeptEmployeeID  = @DeptEmployeeID		
		
	DELETE FROM x_dept_Employee 
	WHERE DeptEmployeeID = @DeptEmployeeID
		 
	EXECUTE rpc_Update_EmployeeInClinic_preselected null, @deptCode, null 
		 

GO


GRANT EXEC ON rpc_deleteDoctorInClinic TO PUBLIC

GO


