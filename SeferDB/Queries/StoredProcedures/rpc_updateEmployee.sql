IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployee')
	BEGIN
		DROP  Procedure  rpc_updateEmployee
	END
GO

CREATE Procedure [dbo].[rpc_updateEmployee]
	(
		@employeeID bigint,
		@degreeCode int,
		@firstName varchar(50),
		@lastName varchar(50),
		@EmployeeSectorCode int,
		@sex int,
		@primaryDistrict int,
		@email varchar(50),
		@showEmailInInternet bit,
		@updateUser varchar(50)
	)

AS

DECLARE @RelevantForProfession int
SET @RelevantForProfession = (SELECT RelevantForProfession FROM EmployeeSector WHERE EmployeeSectorCode = @EmployeeSectorCode)
	
	UPDATE Employee
	SET degreeCode = @degreeCode,
		firstName = @firstName,
		lastName = @lastName,
		EmployeeSectorCode = @EmployeeSectorCode,
		sex = @sex,
		primaryDistrict = @primaryDistrict,
		email = @email,
		showEmailInInternet = @showEmailInInternet,
		updateUser = @updateUser,
		updateDate = getdate()
	WHERE employeeID = @employeeID
			
	IF(@RelevantForProfession <> 1)
	BEGIN
		DELETE FROM x_Dept_Employee_Service 
		FROM x_Dept_Employee_Service  xdes
		INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE employeeID = @employeeID
		AND xdes.serviceCode IN
			(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

		DELETE FROM deptEmployeeReceptionServices 
		FROM deptEmployeeReceptionServices ders
		INNER JOIN deptEmployeeReception der ON ders.receptionID = der.receptionID
		INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.EmployeeID = @employeeID
		AND ders.serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)


		DELETE FROM deptEmployeeReception 
		FROM deptEmployeeReception der
		INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.EmployeeID = @employeeID
		AND NOT EXISTS 
			(SELECT * FROM deptEmployeeReceptionServices ders
			WHERE ders.receptionID = der.receptionID 
			AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)
			)
		
		DELETE FROM EmployeeServices 
		WHERE EmployeeID = @employeeID
		AND serviceCode in (SELECT serviceCode FROM Services WHERE Services.IsProfession = 1)
		
	END

GO

GRANT EXEC ON dbo.rpc_updateEmployee TO [clalit\webuser]

GO

