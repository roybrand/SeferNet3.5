IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServicePhones
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int,
	@phoneOrder int,
	@prePrefix tinyint,
	@prefix int,
	@phone int,
	@extension int,
	@updateUser varchar(50)
AS

	INSERT INTO EmployeeServicePhones
	(x_Dept_Employee_ServiceID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser)
	VALUES
	(@x_Dept_Employee_ServiceID, @phoneType, @phoneOrder, @prePrefix, @prefix, @phone, @extension, @updateUser)
GO

GRANT EXEC ON dbo.rpc_InsertEmployeeServicePhones TO PUBLIC
GO