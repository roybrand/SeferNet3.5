IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDoctorHours')
	BEGIN
		DROP  Procedure  rpc_deleteDoctorHours
	END

GO

CREATE Procedure dbo.rpc_deleteDoctorHours
	(
		@receptionID int,
		@ErrorCode int output
	)

AS

	
		DELETE FROM DeptEmployeeReceptionRemarks
		WHERE EmployeeReceptionID = @receptionID
		
		DELETE FROM deptEmployeeReceptionProfessions
		WHERE receptionID = @receptionID
	
		DELETE FROM deptEmployeeReception
		WHERE deptEmployeeReception.receptionID = @receptionID
		
		SET @ErrorCode = @@Error
		
GO

GRANT EXEC ON rpc_deleteDoctorHours TO PUBLIC

GO

