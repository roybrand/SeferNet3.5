IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDoctorByFullName')
	BEGIN
		DROP  Procedure  rpc_GetDoctorByFullName
	END

GO

CREATE Procedure dbo.rpc_GetDoctorByFullName
(
	@name1 VARCHAR(20),
	@name2 VARCHAR(20),
	@name3 VARCHAR(20),
	@SearchExtended BIT
)

AS

IF @name2 = '' 
BEGIN
	SELECT DegreeName,LastName,FirstName
	FROM Employee
	INNER JOIN Dic_EmployeeDegree ON Employee.DegreeCode = Dic_EmployeeDegree.DegreeCode
	INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
	WHERE (
			(FirstName LIKE @name1 + '%' OR LastName LIKE @name1 + '%') 
			OR 
			(FirstName LIKE '%' + @name1 + '%' OR LastName LIKE '%' + @name1 + '%' AND @searchExtended = 1)
		  )
	AND IsDoctor = 1
END
ELSE
BEGIN

	SELECT DegreeName,LastName,FirstName
	FROM Employee
	INNER JOIN Dic_EmployeeDegree ON Employee.DegreeCode = Dic_EmployeeDegree.DegreeCode
	INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
	WHERE (
			(FirstName LIKE @name1 + '%' AND LastName LIKE @name2 + CASE @name3 WHEN '' THEN '%' 
																	ELSE ' ' + @name3 + '%' END) 
			OR 
			(FirstName LIKE @name1 + ' ' + @name2 + '%' AND LastName LIKE CASE @name3 WHEN '' THEN  LastName
																	ELSE @name3 + '%' END)
			OR 
			(FirstName LIKE @name2 + CASE @name3 WHEN '' THEN '%'
									  ELSE ' ' + @name3 + '%' END 
			 AND LastName LIKE @name1 + '%')

			OR 
			(FirstName LIKE '%' + @name1 + ' ' + @name2 + '%' AND LastName LIKE CASE @name3 WHEN '' THEN LastName
																		  ELSE '%' + @name3 + '%' END 
																		AND @searchExtended = 1)														  
			OR 
			(FirstName LIKE '%' + @name1 + '%' AND LastName LIKE '%' + @name2 + CASE @name3 WHEN '' THEN '%'
																				ELSE ' ' + @name3 + '%' END 
																		AND @searchExtended = 1)
			OR 
			(FirstName LIKE '%' + @name2 +  CASE @name3 WHEN '' THEN '%'
											ELSE ' ' + @name3 + '%' END
			 AND LastName LIKE '%' + @name1 + '%' AND @searchExtended = 1)
		   )
	AND IsDoctor = 1
END



GO


GRANT EXEC ON rpc_GetDoctorByFullName TO PUBLIC

GO


