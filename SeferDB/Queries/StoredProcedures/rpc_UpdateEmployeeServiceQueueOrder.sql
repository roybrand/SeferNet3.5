IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceQueueOrder')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceQueueOrder
	END
GO

CREATE PROCEDURE [dbo].[rpc_UpdateEmployeeServiceQueueOrder]
	@x_Dept_Employee_ServiceID INT,
	@queueOrder INT
AS

UPDATE x_Dept_Employee_Service
SET QueueOrder = @queueOrder
WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
GO


GRANT EXEC ON rpc_UpdateEmployeeServiceQueueOrder TO PUBLIC
GO