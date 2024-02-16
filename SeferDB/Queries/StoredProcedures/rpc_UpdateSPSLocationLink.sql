IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateSPSLocationLink')
    BEGIN
	    DROP  Procedure  rpc_UpdateSPSLocationLink
    END
GO

CREATE Procedure [dbo].[rpc_UpdateSPSLocationLink]
(
	@sourceTable as Dept_SPSLocationLink READONLY,	
	@numOfRowsAffected INT OUTPUT
)

AS

	UPDATE x_dept_XY
	SET x_dept_XY.LocationLink = T.LocationLink,
	x_dept_XY.XLongitude = T.XLongitude,
	x_dept_XY.YLatitude = T.YLatitude
		
	FROM x_dept_XY
	JOIN @sourceTable T ON x_dept_XY.deptCode = T.deptCode
  
	SET @numOfRowsAffected = @@ROWCOUNT	

GO

GRANT EXEC ON rpc_UpdateSPSLocationLink TO [clalit\webuser]
GO