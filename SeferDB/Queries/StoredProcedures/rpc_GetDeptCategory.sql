IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptCategory')
BEGIN
	DROP  Procedure  rpc_GetDeptCategory
END

GO

CREATE Procedure [dbo].[rpc_GetDeptCategory]
	
AS
	SELECT * FROM DIC_DeptCategory
GO

GRANT EXEC ON rpc_GetDeptCategory TO PUBLIC
GO