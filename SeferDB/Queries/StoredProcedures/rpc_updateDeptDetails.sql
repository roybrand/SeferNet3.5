IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptDetails')
	BEGIN
		DROP  Procedure  rpc_updateDeptDetails
	END

GO

CREATE Procedure rpc_updateDeptDetails

	(
		@DeptCode int,
		@DeptType int,
		@DeptName varchar(50),
		@UnitType int,
		@SubUnitType int,
		@ShowSeferNameFromDate datetime,
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
		@Entrance char(1),
		@Flat varchar(50),
		@Floor varchar(10),
		@AddressComment varchar(50),
		@Elevator int,
		@Transportation varchar(50),
		@Email varchar(50),
		@showEmailInInternet int,
		@SeparateUnit int,
		@CascadeUpdateSubDeptPhones int,
		@CascadeUpdateEmployeeInClinicPhones int,
		@QueueOrderMethod int,
		@UpdateQueueOrderServices int,
		@UpdateQueueOrderDoctors int,
		@UpdateUser varchar(50),
		
		@ErrorStatus int output
	)

AS

IF @ShowSeferNameFromDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ShowSeferNameFromDate = null
	END	

DECLARE @Count int, @CurrDeptCode int
SET @Count = 0
SET @ErrorStatus = 0

BEGIN TRY
	BEGIN TRANSACTION

		UPDATE dept
		SET 
		deptType = @DeptType,
		deptName = @DeptName,
		typeUnitCode = @UnitType,
		subUnitTypeCode = @SubUnitType,
		showSeferNameFromDate = @ShowSeferNameFromDate,
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
		entrance = @Entrance,
		flat = @Flat,
		floor = @Floor,
		addressComment = @AddressComment,
		elevator = @Elevator,
		transportation = @Transportation,
		email = @Email,
		showEmailInInternet = @showEmailInInternet,
		showUnitInInternet = @SeparateUnit,
		CascadeUpdateSubDeptPhones = @CascadeUpdateSubDeptPhones,
		CascadeUpdateEmployeeInClinicPhones = @CascadeUpdateEmployeeInClinicPhones,
		QueueOrderMethod = @QueueOrderMethod,
		--UpdateQueueOrderServices = @UpdateQueueOrderServices,
		--UpdateQueueOrderDoctors = @UpdateQueueOrderDoctors,

		UpdateUser = @UpdateUser
		WHERE deptCode = @DeptCode
	
		SET @ErrorStatus = @@Error
		IF @ErrorStatus > 0
			BEGIN
				ROLLBACK
				RETURN 
			END

--- SubDeptPhones
		IF @CascadeUpdateSubDeptPhones = 0 
			BEGIN
				UPDATE Dept
				SET CascadeUpdateSubDeptPhones = @CascadeUpdateSubDeptPhones
				WHERE deptCode = @DeptCode
			END

		IF @CascadeUpdateSubDeptPhones = 1 
			BEGIN
				UPDATE Dept
				SET CascadeUpdateSubDeptPhones = @CascadeUpdateSubDeptPhones
				WHERE deptCode = @DeptCode
			
				DELETE FROM deptPhones 
					WHERE deptCode IN (select deptCode from dept where subAdministrationCode = @DeptCode)

				INSERT INTO deptPhones
					(deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, updateDate, updateUser)
				SELECT subDept.deptCode, phoneType, phoneOrder, prePrefix, prefix, phone, getdate(), @UpdateUser
				FROM dept
				INNER JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
				INNER JOIN dept as subDept ON dept.deptCode = subDept.subAdministrationCode
				WHERE dept.deptCode = @deptCode
			END	


--- DoctorInClinicPhones
		IF @CascadeUpdateEmployeeInClinicPhones = 0 
			BEGIN
				UPDATE Dept
				SET CascadeUpdateEmployeeInClinicPhones = @CascadeUpdateEmployeeInClinicPhones
				WHERE deptCode = @DeptCode
			END

		IF @CascadeUpdateEmployeeInClinicPhones = 1 
			BEGIN
				UPDATE Dept
				SET CascadeUpdateEmployeeInClinicPhones = @CascadeUpdateEmployeeInClinicPhones
				WHERE deptCode = @DeptCode
				
				DELETE FROM DeptEmployeePhones
				WHERE deptCode = @deptCode
				AND deptCode IN (SELECT deptCode FROM x_Dept_Employee 
									WHERE CascadeUpdateDeptEmployeePhonesFromClinic = 1
									AND deptCode = @deptCode)

				INSERT INTO DeptEmployeePhones
					(deptCode, employeeID, phoneType, phoneOrder, prePrefix, prefix, phone, updateUser, updateDate)
				SELECT @deptCode, employeeID, phoneType, phoneOrder, prePrefix, prefix, phone, @UpdateUser, getdate()
				FROM DeptPhones
				INNER JOIN x_Dept_Employee ON DeptPhones.deptCode = x_Dept_Employee.deptCode
				WHERE DeptPhones.deptCode = @deptCode
				AND DeptPhones.deptCode IN (SELECT deptCode FROM x_Dept_Employee 
									WHERE CascadeUpdateDeptEmployeePhonesFromClinic = 1
									AND deptCode = @deptCode)
				
			END

	COMMIT
	RETURN 
	
END TRY
BEGIN CATCH
	ROLLBACK
	SET @ErrorStatus = @@Error
	RETURN 
END CATCH
		
----- CascadePhones
/*
	IF @CascadePhones=1 
		BEGIN
			IF @Phone1 is not null
				BEGIN
					update deptPhones
					set prePrefix=@prePrefix1, prefix=@prefix1, phone= @phone1 
					where 
					deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
					and phoneType=1 and phoneOrder=1
				END
			ELSE				
				BEGIN
					DELETE FROM deptPhones 
					WHERE deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
						and phoneType=1 and phoneOrder=1
				END	
				
			IF @Phone2 is not null
				BEGIN
					update deptPhones
					set prePrefix=@prePrefix2, prefix=@prefix2, phone= @phone2 
					where 
					deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
					and phoneType=1 and phoneOrder=2
				END					
			ELSE
				BEGIN
					DELETE FROM deptPhones 
					where 
					deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
					and phoneType=1 and phoneOrder=2
				END
				
			IF @Fax is not null
				BEGIN
					update deptPhones
					set 
					prePrefix=@PrePrefixFax, 
					prefix=@PrefixFax,
					phone= @Fax 
					where 
					deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
					and phoneType=2 and phoneOrder=1
				END
			ELSE
				BEGIN
					DELETE FROM deptPhones
					where 
					deptCode in (select deptCode from dept where subAdministrationCode = @deptCode)
					and phoneType=2 and phoneOrder=1
				END
		END
	SET @Err = @@Error
	IF @Err > 0
		BEGIN
			ROLLBACK
			SET @ErrorStatus=@Err
			RETURN 
		END
		
*/		
----- CascadeDoctorPhones
/*
	IF @CascadeDoctorPhones = 1 
		BEGIN
			IF @Phone1 is not null
				BEGIN
					update DeptEmployeePhones
					set prePrefix=@prePrefix1, prefix=@prefix1, phone= @phone1 
					where
					(
						deptCode = @deptCode
						or 
						deptCode in 
						(select deptCode from dept where subAdministrationCode=deptCode)
					)
					and phoneType=1 and phoneOrder=1
				END
			ELSE				
				BEGIN
					DELETE FROM DeptEmployeePhones
					where
					(
						deptCode = @deptCode
						or 
						deptCode in 
						(select deptCode from dept where subAdministrationCode=deptCode)
					)
					and phoneType=1 and phoneOrder=1
				END	
				
			IF @Phone2 is not null
				BEGIN
					update DeptEmployeePhones
					set prePrefix=@prePrefix2, prefix=@prefix2, phone= @phone2 
					where (
						deptCode = @deptCode
						OR 
						deptCode in 
						(select deptCode from dept where subAdministrationCode=deptCode)
					)
					and phoneType=1 and phoneOrder=2
				END					
			ELSE
				BEGIN
					DELETE FROM DeptEmployeePhones
					where 
					(
						deptCode = @deptCode
						OR 
						deptCode in 
						(select deptCode from dept where subAdministrationCode=deptCode)
					)
					and phoneType=1 and phoneOrder=2
				END
				
		END
	SET @Err = @@Error
	IF @Err > 0
		BEGIN
			ROLLBACK
			SET @ErrorStatus=@Err
			RETURN 
		END
*/
GO


GRANT EXEC ON rpc_updateDeptDetails TO PUBLIC

GO


