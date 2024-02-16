IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptGeneralBelongingsByEmployee')
    BEGIN
	    DROP  Procedure  rpc_GetDeptGeneralBelongingsByEmployee
    END

GO

CREATE Procedure dbo.rpc_GetDeptGeneralBelongingsByEmployee
(
	@deptEmployeeID INT
)

AS


SELECT Dept.DeptCode, Isnull(IsCommunity,0) as IsCommunity, IsNull(isMushlam,0) as isMushlam, IsNull(IsHospital,0) as IsHospital
FROM Dept
INNER JOIN x_dept_employee xd ON Dept.DeptCode = xd.DeptCode
WHERE DeptEmployeeID = @deptEmployeeID

                
GO


GRANT EXEC ON rpc_GetDeptGeneralBelongingsByEmployee TO PUBLIC

GO            
