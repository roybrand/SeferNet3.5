IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'View_DeptDetails')
	BEGIN
		PRINT 'Dropping View View_DeptDetails'
		DROP  View  View_DeptDetails
	END

GO

PRINT 'Creating View View_DeptDetails'
GO     

 
create VIEW [dbo].[View_DeptDetails]
AS
SELECT     dbo.Dept.deptCode, dbo.Dept.deptName, dbo.Dept.deptType, dbo.Dept.deptLevel, dbo.DIC_DeptTypes.deptTypeDescription, dbo.Dept.typeUnitCode, 
            CASE IsNull(dept.subUnitTypeCode, - 1) WHEN 0 THEN 0 ELSE - 1 END AS subUnitTypeCode, dbo.UnitType.UnitTypeName, dbo.Dept.cityCode, 
            dbo.Cities.cityName, dbo.Dept.streetName AS street, dbo.Dept.house, dbo.Dept.flat, dbo.Dept.addressComment, dbo.GetAddress(dbo.Dept.deptCode) 
            AS address, dbo.GetDeptPhoneNumber(dbo.Dept.deptCode, 1, 1) AS phone, dbo.x_dept_XY.xcoord, dbo.x_dept_XY.ycoord,
            dbo.x_dept_XY.XLongitude, dbo.x_dept_XY.YLatitude,
			dbo.Dept.districtCode, 
            dbo.deptSimul.Simul228, dbo.Dept.status, dbo.Dept.populationSectorCode
FROM         dbo.Dept INNER JOIN
                      dbo.DIC_DeptTypes ON dbo.Dept.deptType = dbo.DIC_DeptTypes.deptType INNER JOIN
                      dbo.UnitType ON dbo.Dept.typeUnitCode = dbo.UnitType.UnitTypeCode INNER JOIN
                      dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode LEFT OUTER JOIN
                      dbo.deptSimul ON dbo.Dept.deptCode = dbo.deptSimul.deptCode LEFT OUTER JOIN
                      dbo.x_dept_XY ON dbo.Dept.deptCode = dbo.x_dept_XY.deptCode


GO


GRANT SELECT  ON View_DeptDetails TO PUBLIC
GO
       