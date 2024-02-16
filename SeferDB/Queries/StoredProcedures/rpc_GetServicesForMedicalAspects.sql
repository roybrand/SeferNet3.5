--rpc_GetServicesForMedicalAspects
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesForMedicalAspects')
	BEGIN
		DROP  Procedure  dbo.rpc_GetServicesForMedicalAspects
	END
GO

CREATE Procedure dbo.rpc_GetServicesForMedicalAspects
(
	@DeptCode int,
	@MedicalAspectsList varchar(max)
) 

AS

DECLARE @strServices varchar(max)
SET @strServices = ''

SELECT  @strServices = @strServices + CAST(T.ServiceCode as varchar(10)) + ',' 
FROM 
(
	SELECT DISTINCT s.ServiceCode
	FROM [dbo].[rfn_SplitStringByDelimiterValuesToInt](@MedicalAspectsList, ',') as T
	JOIN MedicalAspectsToSefer MAtoS ON T.ItemID = MAtoS.MedicalAspectCode
	JOIN [Services] s ON s.ServiceCode = MAtoS.SeferCode
	WHERE s.ServiceCode NOT IN
	(
		SELECT x_Dept_Employee_Service.ServiceCode 
		FROM x_Dept_Employee_Service
		JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		LEFT JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID	
		WHERE x_Dept_Employee.deptCode = @DeptCode
		AND Employee.IsMedicalTeam = 1
	)  
) as T

IF(LEN(@strServices) > 0)
BEGIN
	SET @strServices = LEFT( @strServices, LEN(@strServices) -1 )
END

SELECT TOP 1 @strServices as [Services] FROM Dept

GO

GRANT EXEC ON [dbo].rpc_GetServicesForMedicalAspects TO PUBLIC
GO