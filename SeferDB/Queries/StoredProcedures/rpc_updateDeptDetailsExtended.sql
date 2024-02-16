IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptDetailsExtended')
	BEGIN
		DROP  Procedure  rpc_updateDeptDetailsExtended
	END

GO

CREATE Procedure rpc_updateDeptDetailsExtended
(
	@DeptCode int,
	@DeptType int,
	@DeptName varchar(50),
	@UnitType int,
	@SubUnitType int,
	--@ShowSeferNameFromDate datetime,
	@ManagerName varchar(50),
	@AdministrativeManagerName varchar(50),		
	@DistrictCode int,
	@AdministrationCode int,
	@SubAdministrationCode int,
	@DeptLevel int,
	@Parking int,
	@PopulationSectorCode int,
	@CityCode int,
	@Street varchar(50),
	@House varchar(50),
	@Flat varchar(50),
	@Floor varchar(10),
	@AddressComment varchar(50),
	@Transportation varchar(50),
	@Email varchar(50),
	@showEmailInInternet int,
	@ShowUnitInInternet int,
	@CascadeUpdateSubDeptPhones int,
	@CascadeUpdateEmployeeInClinicPhones int,
	
	@DeptNames varchar(1000),
	@DeptHandicappedFacilities varchar(100),
	@DeptStatuses varchar(1000),
	@DeptPhones varchar(1000),
	@DeptFaxes varchar(1000),
	@UpdateUser varchar(50),
	
	@ErrorStatus int output
)

AS

DECLARE @PhoneType int

BEGIN TRY
	BEGIN TRANSACTION

		UPDATE dept
		SET 
		deptType = @DeptType,
		deptName = @DeptName,
		typeUnitCode = @UnitType,
		subUnitTypeCode = @SubUnitType,
		--showSeferNameFromDate = @ShowSeferNameFromDate,
		managerName = @ManagerName,
		administrativeManagerName = @AdministrativeManagerName,
		districtCode = @DistrictCode,
		administrationCode = @AdministrationCode,
		subAdministrationCode = @SubAdministrationCode,
		deptLevel = @DeptLevel,
		parking = @Parking,
		populationSectorCode = @PopulationSectorCode,	
		cityCode = @CityCode,
		street = @Street,
		house = @House,
		flat = @Flat,
		floor = @Floor,
		addressComment = @AddressComment,
		transportation = @Transportation,
		email = @Email,
		showEmailInInternet = @showEmailInInternet,
		showUnitInInternet = @ShowUnitInInternet,
		CascadeUpdateSubDeptPhones = @CascadeUpdateSubDeptPhones,
		CascadeUpdateEmployeeInClinicPhones = @CascadeUpdateEmployeeInClinicPhones,

		UpdateUser = @UpdateUser
		WHERE deptCode = @DeptCode
	
		SET @ErrorStatus = @@Error
		IF @ErrorStatus > 0
			BEGIN
				ROLLBACK
				RETURN 
			END
			
	--- DeptNames
		DELETE FROM DeptNames where deptCode = @DeptCode

		INSERT INTO DeptNames
		SELECT deptCode, deptName, fromDate, updateDate, updateUser
		FROM dbo.fun_StingToTable_DeptNames(@DeptNames, @DeptCode, @UpdateUser)
		
		SET @ErrorStatus = @@Error
		IF @ErrorStatus > 0
			BEGIN
				ROLLBACK
				RETURN 
			END
			
	--- DeptStatus
		DELETE FROM DeptStatus WHERE DeptCode = @DeptCode
	
		INSERT INTO DeptStatus
		(DeptCode, Status, FromDate, ToDate, UpdateDate, UpdateUser)
		SELECT DeptCode, Status, FromDate, ToDate, UpdateDate, UpdateUser
		FROM dbo.fun_StingToTable_DeptStatus(@DeptStatuses, @DeptCode, @UpdateUser)
		
	--- DeptHandicappedFacilities
		DELETE FROM DeptHandicappedFacilities WHERE DeptCode = @DeptCode
		
		INSERT INTO DeptHandicappedFacilities
		SELECT DeptCode, FacilityCode 
		FROM dbo.fun_StingToTable_DeptHandicappedFacilities(@DeptHandicappedFacilities, @DeptCode)
		
		SET @ErrorStatus = @@Error
		IF @ErrorStatus > 0
			BEGIN
				ROLLBACK
				RETURN 
			END
/* remove comment after phone control will work
	--- DeptPhones
		DELETE FROM DeptPhones WHERE DeptCode = @DeptCode
		
		SET @PhoneType = 1 -- phones
		INSERT INTO DeptPhones
		(deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser)
		SELECT deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser
		FROM dbo.fun_StingToTable_DeptPhones(@DeptPhones, @DeptCode, @PhoneType, @UpdateUser)
		
		SET @PhoneType = 2 -- faxes
		INSERT INTO DeptPhones
		(deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser)
		SELECT deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser
		FROM dbo.fun_StingToTable_DeptPhones(@DeptFaxes, @DeptCode, @PhoneType, @UpdateUser)

--- SubDeptPhones
		IF @CascadeUpdateSubDeptPhones = 1 
			BEGIN
			
				DELETE FROM deptPhones 
					WHERE deptCode IN (SELECT deptCode FROM dept WHERE subAdministrationCode = @DeptCode)

				INSERT INTO deptPhones
					(deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateDate, updateUser)
				SELECT subDept.deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, extension, getdate(), @UpdateUser
				FROM dept
				INNER JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
				INNER JOIN dept as subDept ON dept.deptCode = subDept.subAdministrationCode
				WHERE dept.deptCode = @DeptCode
			END	

--- DoctorInClinicPhones
		IF @CascadeUpdateEmployeeInClinicPhones = 1 
			BEGIN
				
				DELETE FROM DeptEmployeePhones
				WHERE deptCode = @deptCode
				AND deptCode IN (SELECT deptCode FROM x_Dept_Employee 
									WHERE CascadeUpdateDeptEmployeePhonesFromClinic = 1
									AND deptCode = @DeptCode)

				INSERT INTO DeptEmployeePhones
					(deptCode, employeeID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser, updateDate)
				SELECT @deptCode, employeeID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, @UpdateUser, getdate()
				FROM DeptPhones
				INNER JOIN x_Dept_Employee ON DeptPhones.deptCode = x_Dept_Employee.deptCode
				WHERE DeptPhones.deptCode = @DeptCode
				AND DeptPhones.deptCode IN (SELECT deptCode FROM x_Dept_Employee 
									WHERE CascadeUpdateDeptEmployeePhonesFromClinic = 1
									AND deptCode = @deptCode)
				
			END

		SET @ErrorStatus = @@Error
		IF @ErrorStatus > 0
			BEGIN
				ROLLBACK
				RETURN 
			END
*/
	COMMIT
	RETURN 
	
END TRY
BEGIN CATCH
	ROLLBACK
	SET @ErrorStatus = @@Error
	RETURN 
END CATCH


GO

GRANT EXEC ON rpc_updateDeptDetailsExtended TO PUBLIC

GO

