IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptGeneralBelongings')
    BEGIN
	    DROP  Procedure  rpc_GetDeptGeneralBelongings
    END

GO

CREATE Procedure dbo.rpc_GetDeptGeneralBelongings
(
	@deptCode INT
)

AS


SELECT DeptCode, Isnull(IsCommunity,0) as IsCommunity, IsNull(isMushlam,0) as isMushlam, IsNull(IsHospital,0) as IsHospital
FROM Dept
WHERE DeptCode = @deptCode

                
GO


GRANT EXEC ON rpc_GetDeptGeneralBelongings TO PUBLIC

GO            
