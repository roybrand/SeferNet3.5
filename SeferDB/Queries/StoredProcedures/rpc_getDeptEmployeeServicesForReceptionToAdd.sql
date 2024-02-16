IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeServicesForReceptionToAdd')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeServicesForReceptionToAdd
	END

GO

CREATE Procedure dbo.rpc_getDeptEmployeeServicesForReceptionToAdd
	(
		@receptionID int,
		@deptCode int,
		@employeeID int
	)

AS

IF @receptionID is null 
BEGIN
	SET @receptionID = 0
END

IF(@receptionID <> 0)
BEGIN
SELECT
xdes.serviceCode,
services.serviceDescription,

-- The last "LEFT JOIN" is for this purpose only:
-- if 'canBeAdded'== 1 then an appropriate service isn't attributed to the reception yet AND can be attributed
-- When @receptionID is NUL it means that it's about to add a new reception and all the professions could be added
'canBeAdded' = CASE IsNull(deptEmployeeReceptionServices.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = services.serviceCode,
'groupName' = serviceDescription

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN services ON xdes.serviceCode = services.serviceCode
LEFT JOIN serviceParentChild ON services.serviceCode = serviceParentChild.childCode

LEFT JOIN deptEmployeeReceptionServices ON xdes.serviceCode = deptEmployeeReceptionServices.serviceCode
	AND ( @receptionID = 0 OR deptEmployeeReceptionServices.receptionID = @receptionID)

WHERE xd.EmployeeID = @EmployeeID
AND xd.deptCode = @DeptCode
AND parentCode is null

UNION

SELECT
xdes.serviceCode,
services.serviceDescription,
'canBeAdded' = CASE IsNull(deptEmployeeReceptionServices.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = P.serviceDescription

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xdes.DeptEmployeeID
INNER JOIN services ON xdes.serviceCode = services.serviceCode
LEFT JOIN serviceParentChild ON services.serviceCode = serviceParentChild.childCode

LEFT JOIN deptEmployeeReceptionServices ON xdes.serviceCode = deptEmployeeReceptionServices.serviceCode
	AND ( @receptionID = 0 OR deptEmployeeReceptionServices.receptionID = @receptionID)

INNER JOIN services as P ON serviceParentChild.parentCode = P.serviceCode

WHERE xd.EmployeeID = @EmployeeID
AND xd.deptCode = @DeptCode
AND parentCode is NOT null

ORDER BY groupName, parentCode
END

ELSE

BEGIN
SELECT
x_D_E_S.serviceCode,
service.serviceDescription,

'canBeAdded' = 1,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = service.serviceCode,
'groupName' = serviceDescription

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN service ON x_D_E_S.serviceCode = service.serviceCode
LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode

WHERE x_D_E_S.EmployeeID = @EmployeeID
AND x_D_E_S.deptCode = @DeptCode
AND parentCode is null

UNION

SELECT
x_D_E_S.serviceCode,
service.serviceDescription,
'canBeAdded' = 1,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = P.serviceDescription

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN service ON x_D_E_S.serviceCode = service.serviceCode
LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode

INNER JOIN service as P ON serviceParentChild.parentCode = P.serviceCode

WHERE EmployeeID = @EmployeeID
AND deptCode = @DeptCode
AND parentCode is NOT null

ORDER BY groupName, parentCode

END
GO

GRANT EXEC ON rpc_getDeptEmployeeServicesForReceptionToAdd TO PUBLIC

GO

