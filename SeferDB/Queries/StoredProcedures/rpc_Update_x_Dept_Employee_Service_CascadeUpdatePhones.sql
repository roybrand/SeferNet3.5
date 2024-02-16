IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones')
	BEGIN
		DROP  Procedure  rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones
	END
GO

CREATE Procedure dbo.rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones
	(
		@x_Dept_Employee_ServiceID int,
		@CascadeUpdatePhones bit
	)

AS

	UPDATE x_Dept_Employee_Service
	SET CascadeUpdateEmployeeServicePhones = @CascadeUpdatePhones
	WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID


	
GO

GRANT EXEC ON rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones TO PUBLIC

GO