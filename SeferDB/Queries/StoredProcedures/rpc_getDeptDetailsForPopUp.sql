
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_getDeptDetailsForPopUp')
	BEGIN
		DROP  Procedure  rpc_getDeptDetailsForPopUp
	END

GO


CREATE Procedure [dbo].[rpc_getDeptDetailsForPopUp]
	(
		@deptCode int
	)
AS

--- DeptDetails --------------------------------------------------------
SELECT
D.deptName,
D.deptNameFreePart,
D.deptType, -- 1, 2, 3
UnitType.UnitTypeName,
UnitType.UnitTypeCode,
D.deptLevel,
D.managerName,
'substituteManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_dept_employee.deptCode = D.deptCode
							), ''),
D.administrativeManagerName,
'substituteAdministrativeManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToAdministrativeManager = 1
							AND x_dept_employee.deptCode = D.deptCode
							), ''),
'address' = dbo.GetAddress(@DeptCode),
D.cityCode,
Cities.cityName,
D.StreetCode,
'streetName' = RTRIM(LTRIM(D.streetName)),
D.house,
D.flat,
D.floor,
D.entrance,
D.addressComment,
D.zipCode,
D.email,
'showEmailInInternet' = CAST(IsNull(D.showEmailInInternet, 0) as bit),

'districtCode' = IsNull(D.districtCode, -1),
'districtName' = (select districtName from View_AllDistricts where districtCode=D.districtCode),
'administrationCode' = IsNull(D.administrationCode, -1),				-- "מנהלות" 
'subAdministrationCode' = IsNull(D.subAdministrationCode, -1),
'subAdministrationName' = (SELECT dept.deptName 
							FROM dept
							WHERE dept.deptCode = D.subAdministrationCode),
'populationSectorCode' = IsNull(D.populationSectorCode, -1),
D.deptCode,
DIC_ActivityStatus.statusDescription,
DIC_ActivityStatus.status,
'phone1' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 1 -- (Phone)
			AND phoneOrder = 1 ),
'phone2' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 1 -- (Phone)
			AND phoneOrder = 2 ),
'fax' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 2 -- (Fax)
			AND phoneOrder = 1 )

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
INNER JOIN Cities ON D.cityCode = Cities.cityCode
INNER JOIN DIC_ActivityStatus ON D.status = DIC_ActivityStatus.status
INNER JOIN UnitType ON D.typeUnitCode = UnitType.UnitTypeCode

WHERE D.deptCode = @deptCode

GO


GRANT EXEC ON rpc_getDeptDetailsForPopUp TO PUBLIC
GO
         