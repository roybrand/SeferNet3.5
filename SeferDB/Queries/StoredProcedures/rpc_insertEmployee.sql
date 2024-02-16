IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployee')
	BEGIN
		DROP  Procedure  rpc_insertEmployee
	END

GO

CREATE Procedure rpc_insertEmployee
	(
		@employeeID int,
		@degreeCode int,
		@firstName varchar(50),
		@lastName varchar(50),
		@EmployeeSectorCode int,
		@sex int,
		@badgeID int,
		@licenseNumber int,
		@primaryDistrict int,
		@active int,
		@statusOpenDate datetime,
		@statusCloseDate datetime,
		@email varchar(50),
		@showEmailInInternet int,
		
		@PrePrefix_Home int,
		@Prefix_Home int,
		@Phone_Home int,
		@IsUnlisted_Home int,
		@PrePrefix_Cell int,
		@Prefix_Cell int,
		@Phone_Cell int,
		@IsUnlisted_Cell int,
		
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

IF @statusOpenDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @statusOpenDate = null
	END		
IF @statusCloseDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @statusCloseDate = null
	END	
		
IF @PrePrefix_Home = -1
	BEGIN
		SET @PrePrefix_Home = null
	END
IF @Prefix_Home = -1
	BEGIN
		SET @Prefix_Home = null
	END
IF @PrePrefix_Cell = -1
	BEGIN
		SET @PrePrefix_Cell = null
	END
IF @Prefix_Cell = -1
	BEGIN
		SET @Prefix_Cell = null
	END


BEGIN TRY

		INSERT INTO Employee
		(employeeID, degreeCode, firstName, lastName, EmployeeSectorCode, sex, badgeID, licenseNumber, 
			primaryDistrict, active, statusOpenDate, statusCloseDate, updateUser)
		VALUES
		(@employeeID, @degreeCode, @firstName, @lastName, @EmployeeSectorCode, @sex, @badgeID, @licenseNumber,
			@primaryDistrict, @active, @statusOpenDate, @statusCloseDate, @updateUser)
			
	SET @ErrCode = @@Error
END TRY
BEGIN CATCH
	SET @ErrCode = @@Error
END CATCH

GO

GRANT EXEC ON rpc_insertEmployee TO PUBLIC

GO

