IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDefaultDeptNameForIndependentClinic')
	BEGIN
		DROP  Procedure  rpc_GetDefaultDeptNameForIndependentClinic
	END

GO

CREATE Procedure dbo.rpc_GetDefaultDeptNameForIndependentClinic
(
	@DeptCode int
)

AS
	
	SELECT [dbo].[fun_GetDefaultDeptNameForIndependentClinic](@DeptCode)
GO


GRANT EXEC ON rpc_GetDefaultDeptNameForIndependentClinic TO [clalit\webuser]
GO

GRANT EXEC ON rpc_GetDefaultDeptNameForIndependentClinic TO [clalit\IntranetDev]
GO