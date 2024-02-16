                     
-----------script seperator----

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'View_AllDeptAddressAndPhone')
	BEGIN
		PRINT 'Dropping View View_AllDeptAddressAndPhone'
		DROP  View  View_AllDeptAddressAndPhone
	END

GO

PRINT 'Creating View View_AllDeptAddressAndPhone'
GO     
CREATE VIEW dbo.View_AllDeptAddressAndPhone
AS
SELECT     dbo.Dept.deptCode, dbo.Dept.deptName, dbo.UnitType.UnitTypeName, CASE (StreetCode) WHEN NULL 
                      THEN StreetName ELSE StreetName + ' ' + house END AS Address, dbo.Cities.cityName, dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, 
                      dp.prefix, dp.phone, dp.extension) AS Phone, dbo.Dept.typeUnitCode, dbo.Dept.status, dbo.Dept.districtCode, dbo.Dept.administrationCode, 
                      dbo.Dept.deptType
FROM         dbo.Dept INNER JOIN
                      dbo.UnitType ON dbo.Dept.typeUnitCode = dbo.UnitType.UnitTypeCode INNER JOIN
                      dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode LEFT OUTER JOIN
                      dbo.DeptPhones AS dp ON dbo.Dept.deptCode = dp.deptCode AND dp.phoneType = 1 AND dp.phoneOrder = 1

GO


GRANT SELECT  ON View_AllDeptAddressAndPhone TO PUBLIC
                              GO
   