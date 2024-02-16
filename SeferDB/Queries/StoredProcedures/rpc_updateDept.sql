IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_updateDept')
	BEGIN
		PRINT 'Dropping Procedure rpc_updateDept'
		DROP  Procedure  rpc_updateDept
	END

GO

CREATE Procedure [dbo].[rpc_updateDept]
	(
	@DeptCode int,
	@DeptType int,
	@UnitType int,
	@SubUnitType int,
	@ManagerName varchar(50),
	@AdministrativeManagerName varchar(50),		
	@DistrictCode int,
	@AdministrationCode int,
	@SubAdministrationCode int,
	@ParentClinicCode int,
	@Parking int,
	@PopulationSectorCode int,
	@CityCode int,
	@StreetCode varchar(50),
	@StreetName varchar(50),
	@House varchar(50),
	@Flat varchar(50),
	@Floor varchar(10),
	@AddressComment varchar(500),
	@building varchar(500),
    @linkToBlank17 varchar(500),
    @linkToContactUs varchar(500),
	@Transportation varchar(50),
	@Email varchar(50),
	@ShowEmailInInternet int,
	@ShowUnitInInternet int,	
	@allowQueueOrder bit,
	@CascadeUpdateSubDeptPhones tinyint,
	@CascadeUpdateEmployeeInClinicPhones tinyint,
	@UpdateUser varchar(50),
	@NeighbourhoodOrInstituteCode varchar(50),
	@IsSite int,
	@AdditionalDistricts varchar(100),
	@IsCommunity int,
	@IsMushlam int,
	@IsHospital int,
	@typeOfDefenceCode int,
    @defencePolicyCode int,
    @isUnifiedClinic bit,
    @hasElectricalPanel bit,
    @hasGenerator bit,
	@DeptShalaCode bigint,

	@ErrorStatus int output
	)

AS

IF RTRIM(LTRIM(@StreetName)) = ''
BEGIN
	SET @StreetName = null
	SET @StreetCode = null
END

DECLARE @subAdministrationCodeOld int = (SELECT subAdministrationCode FROM Dept WHERE deptCode = @DeptCode)
DECLARE @Simul228 int = (SELECT ISNULL(Simul228, -1) FROM deptSimul WHERE deptCode = @DeptCode)

UPDATE dept
SET 
deptType = @DeptType,
typeUnitCode = @UnitType,
subUnitTypeCode = @SubUnitType,
managerName = @ManagerName,
administrativeManagerName = @AdministrativeManagerName,
districtCode = @DistrictCode,
administrationCode = @AdministrationCode,
subAdministrationCode = @SubAdministrationCode,
ParentClinic = @ParentClinicCode,
parking = @Parking,
populationSectorCode = @PopulationSectorCode,	
cityCode = @CityCode,
StreetCode = @StreetCode,
streetName = @StreetName,
NeighbourhoodOrInstituteCode = @NeighbourhoodOrInstituteCode,
IsSite = @IsSite,
house = @House,
flat = @Flat,
floor = @Floor,
addressComment = @AddressComment,
Building = @building,
LinkToBlank17 = @linkToBlank17,
LinkToContactUs = @linkToContactUs,
transportation = @Transportation,
email = @Email,
showEmailInInternet = @ShowEmailInInternet,
showUnitInInternet = @ShowUnitInInternet,
IsCommunity	= @IsCommunity,
IsMushlam =	@IsMushlam,
IsHospital = @IsHospital,
QueueOrder = CASE @allowQueueOrder WHEN 0 THEN NULL ELSE QueueOrder END,
dept.TypeOfDefenceCode = @typeOfDefenceCode,
dept.DefencePolicyCode = @defencePolicyCode,
dept.IsUnifiedClinic = @isUnifiedClinic,
dept.HasElectricalPanel = @hasElectricalPanel,
dept.HasGenerator = @hasGenerator,
dept.DeptShalaCode = @DeptShalaCode,
updateDate = getdate(),
UpdateUser = @UpdateUser

WHERE deptCode = @DeptCode

DELETE FROM x_Dept_District WHERE deptCode = @DeptCode

INSERT INTO x_Dept_District
(deptCode, districtCode)
SELECT 
@DeptCode, IntField 
FROM dbo.SplitString(@AdditionalDistricts)
WHERE IntField <> @DistrictCode


IF(@SubAdministrationCode <> -1 AND @subAdministrationCodeOld <> @SubAdministrationCode AND @Simul228 = -1)
BEGIN
	SET @Simul228 =
			(SELECT CASE WHEN C405.SimulConvertId is null THEN null ELSE CAST (RIGHT( RTRIM( IsNull(C405.SimulConvertId, 0) ), 4) as int) END
				as Simul228 
				FROM Conversion405 C405 WHERE C405.SimulId = @DeptCode AND C405.SystemId = 11 AND C405.InActive = 0
			)
	IF(@Simul228 is NOT null)
	BEGIN
		UPDATE deptSimul SET Simul228 = @Simul228 WHERE deptCode = @DeptCode
	END
	ELSE
	BEGIN
		DECLARE @Simul228_SubAdminNew int = (SELECT Simul228 FROM deptSimul WHERE deptCode = @SubAdministrationCode)

		IF(@Simul228_SubAdminNew is NOT null)
		BEGIN
			UPDATE deptSimul SET Simul228 = @Simul228_SubAdminNew WHERE deptCode = @DeptCode
		END
	END

END

SET @ErrorStatus = @@Error

GO




GRANT EXEC ON rpc_updateDept TO PUBLIC
GO
   