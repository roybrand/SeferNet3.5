IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DailyUpdate]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_DailyUpdate]
GO


CREATE Procedure [dbo].[rpc_DailyUpdate]

AS

	exec rpc_updateDeptNames
	exec rpc_updateDeptFromDeptStatus
	exec rpc_UpdateEmployeeStatus
	exec rpc_updateX_D_Emp_FromEmployeeStatusInDept
	exec rpc_UpdateEmployeeServiceInDeptStatus
	exec rpc_DeleteOldDeptAndEmployeeRemarks

GO


GRANT EXEC ON [rpc_DailyUpdate] TO PUBLIC

GO

