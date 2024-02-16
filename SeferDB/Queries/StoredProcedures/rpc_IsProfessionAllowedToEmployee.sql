IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_IsProfessionAllowedToEmployee')
	BEGIN
		DROP  Procedure  rpc_IsProfessionAllowedToEmployee
	END

GO

CREATE Procedure dbo.rpc_IsProfessionAllowedToEmployee
(
		@employeeID BIGINT,
		@professionsAllowed BIT OUTPUT
)

AS


IF EXISTS 
(
	SELECT *
	FROM Employee e
	INNER JOIN EmployeeSector es
	ON e.EmployeeSectorCode = es.EmployeeSectorCode
	WHERE e.EmployeeID = @employeeID AND es.RelevantForProfession = 1
)

	SET @professionsAllowed = 1
ELSE
	SET @professionsAllowed = 0


GO


GRANT EXEC ON rpc_IsProfessionAllowedToEmployee TO PUBLIC

GO


