IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertX_dept_XY')
	BEGIN
		DROP  Procedure  rpc_InsertX_dept_XY
	END

GO

CREATE Procedure dbo.rpc_InsertX_dept_XY

	(
		@DeptCode int,
		@xcoord float,
		@ycoord float,
		@XLongitude float, @YLatitude float,
		@updateCoordinatesManually bit,
		@locationLink varchar(200),
		@ErrorCode int = 0 OUTPUT
	)


AS

	INSERT INTO x_dept_XY 
	(deptCode, xcoord, ycoord, XLongitude, YLatitude, UpdateManually, LocationLink)
	VALUES
	(@DeptCode, @xcoord, @ycoord, @XLongitude, @YLatitude, @updateCoordinatesManually, @locationLink)

	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_InsertX_dept_XY TO PUBLIC

GO
