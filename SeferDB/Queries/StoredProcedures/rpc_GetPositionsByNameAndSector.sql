IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetPositionsByNameAndSector')
	BEGIN
		DROP  Procedure  rpc_GetPositionsByNameAndSector
	END

GO

CREATE Procedure dbo.rpc_GetPositionsByNameAndSector
(
	@prefixText VARCHAR(20),
	@employeeID BIGINT
)


AS


SELECT  P.PositionCode,PositionDescription

FROM Position as p
INNER JOIN employee ON employee.employeeID = @employeeID AND p.relevantSector = employee.employeeSectorCode

WHERE  PositionDescription LIKE '%' + @prefixText + '%' 
AND ((employee.sex = 0 AND p.gender = 1) OR ( employee.sex <> 0 AND employee.sex = p.gender))

ORDER BY p.PositionDescription


GO


GRANT EXEC ON rpc_GetPositionsByNameAndSector TO PUBLIC

GO


