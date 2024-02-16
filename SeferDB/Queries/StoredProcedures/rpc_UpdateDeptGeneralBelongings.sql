IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptGeneralBelongings')
    BEGIN
	    DROP  Procedure  rpc_UpdateDeptGeneralBelongings
    END

GO

CREATE Procedure dbo.rpc_UpdateDeptGeneralBelongings
(
	@deptCode int,
	@IsCommunity bit,
	@IsMushlam bit,
	@IsHospital bit
)

AS

UPDATE Dept
SET IsCommunity = ISNULL(@IsCommunity, d.IsCommunity),
IsMushlam = ISNULL(@IsMushlam, d.IsMushlam),
IsHospital = ISNULL(@IsHospital, d.IsHospital)
FROM Dept d
WHERE d.deptCode = @deptCode

GO


GRANT EXEC ON rpc_UpdateDeptGeneralBelongings TO PUBLIC

GO          