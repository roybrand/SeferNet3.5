IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptList_PagedSorted')
	BEGIN
		DROP  Procedure  rpc_getDeptList_PagedSorted
	END
GO

CREATE Procedure [dbo].[rpc_getDeptList_PagedSorted]
	(
	@UserIsLogged bit,
	@DistrictCodes varchar(max)=null,
	@CityCode int=null,
	@typeUnitCode varchar(max)=null,
	@subUnitTypeCode varchar(max) = null,
	@ServiceCodes varchar(max) = null,
	@DeptName varchar(max)=null,
	@DeptCode int=null,
	@ReceptionDays varchar(max)=null,
	@OpenAtHour varchar(5)=null,
	@OpenFromHour varchar(5)=null,
	@OpenToHour varchar(5)=null,
	@OpenNow bit,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit,
	@status int = null,
	@populationSectorCode int = null,
	@deptHandicappedFacilities varchar(max),
	@ReceiveGuests bit,

	@PageSise int,
	@StartingPage int,
	@SortedBy varchar(max),
	@IsOrderDescending int,
	
	@CoordinateX float=null,
	@CoordinateY float=null,
	@MaxNumberOfRecords int=null,

	@ClalitServiceCode varchar(max), 
	@ClalitServiceDescription varchar(max), 
	@MedicalAspectCode varchar(max), 
	@MedicalAspectDescription varchar(max),
	@ServiceCodeForMuslam varchar(max) = null,
	@GroupCode int = null,
	@SubGroupCode int = null,
	@QueueOrderOptionsAndMethods varchar(100) = null	-- NEW parameter
	)


AS

-- DECLARATIONS
BEGIN
	DECLARE @params nvarchar(max)
	DECLARE @Declarations nvarchar(max)
	DECLARE @Sql1 nvarchar(max)
	DECLARE @Sql2 nvarchar(max)
	DECLARE @SqlEnd nvarchar(max)

	DECLARE @SqlWhere1 nvarchar(max)
	DECLARE @SqlWhere2 nvarchar(max)

	declare @OrganizationSectorIDList varchar(5) = ''
	set @OrganizationSectorIDList = case when @isCommunity is null then '0' else '1' end
	set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isMushlam is null then '0' else '2' end
	set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isHospital is null then '0' else '3' end

	if(@ServiceCodeForMuslam is not null)
		SET @ServiceCodes = @ServiceCodeForMuslam

	DECLARE @AgreementTypeList [tbl_UniqueIntArray]   
	INSERT INTO @AgreementTypeList
	select AgreementTypeID from DIC_AgreementTypes
	where OrganizationSectorID in (Select IntField from dbo.SplitString(@OrganizationSectorIDList))

	-- @ClalitServiceCode actually bring us additional ServiceCode
	DECLARE @AdditionalServiceCode int
	 
	SELECT DISTINCT @AdditionalServiceCode = MedicalAspectsToSefer.SeferCode
	FROM MF_MedicalAspects830
	JOIN MedicalAspectsToSefer ON MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
	WHERE MF_MedicalAspects830.ClalitServiceCode = @ClalitServiceCode	
		
	IF @AdditionalServiceCode is NOT null
	BEGIN
		IF @ServiceCodes is null
			SET @ServiceCodes = @AdditionalServiceCode
		ELSE
			BEGIN
				SET @ServiceCodes = @ServiceCodes + ',' + @AdditionalServiceCode
			END
	END

	DECLARE @ReceptionDayNow tinyint
	DECLARE @OpenAtThisHour time

	IF(@OpenNow = 1)
		BEGIN
			SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
			IF(@ReceptionDays is NULL)
				SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
			ELSE
				IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
				SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))

			SET @OpenAtThisHour = GETDATE();
		END

	DECLARE @ServiceCodesList [tbl_UniqueIntArray] 
	DECLARE @Top1From_ServiceCodesList int = 0	

	IF @ServiceCodes is NOT null
	BEGIN
		INSERT INTO @ServiceCodesList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ServiceCodes)
		SET @Top1From_ServiceCodesList = (SELECT TOP 1 IntVal FROM @ServiceCodesList)
	END

	DECLARE @ReceptionDaysList [tbl_UniqueIntArray] 
	IF @ReceptionDays is NOT null
		INSERT INTO @ReceptionDaysList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ReceptionDays) 
	/*
	IF (@CoordinateX is NOT null AND @CityCode is NOT null AND @DistrictCodes is null AND @ServiceCodes is null)
	BEGIN
		SET @DistrictCodes = CAST((SELECT TOP 1 districtCode FROM Cities where cityCode = @CityCode) AS varchar(7))
	END
	*/
	
	IF (@CoordinateX is null AND @CityCode is NOT null AND @DistrictCodes is null AND @ServiceCodes is null)
	BEGIN
		SET @DistrictCodes = CAST((SELECT TOP 1 districtCode FROM Cities where cityCode = @CityCode) AS varchar(7))
	END
	
	DECLARE @ShowWithNoReceptionHours tinyint
		IF(@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null OR @OpenNow = 1 OR @ReceptionDays is NOT NULL)
			SET @ShowWithNoReceptionHours = 1
		ELSE
			SET @ShowWithNoReceptionHours = 0

	DECLARE @DateNow date = GETDATE()

	DECLARE @CheckWorkingHours tinyint
		IF(@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null OR @OpenNow = 1 OR @ReceptionDays IS NOT NULL )
			SET @CheckWorkingHours = 1
		ELSE
			SET @CheckWorkingHours = 0

	DECLARE @StartingPosition int = 0

	DECLARE @HandicappedFacilitiesCount int
	SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@DeptHandicappedFacilities)), 0)

	DECLARE @Count int	

	IF (@CoordinateX is NOT null)
	BEGIN
		SET @SortedBy = 'distance'
	END

-- *************************************************************

	SELECT IntField as MethodCode
	INTO #QueueOrderMethods
	FROM dbo.SplitString(@QueueOrderOptionsAndMethods)
	WHERE IntField > 0

	SELECT ( IntField + 2 ) as OptionCode
	INTO #QueueOrderOptions
	FROM dbo.SplitString(@QueueOrderOptionsAndMethods)
	WHERE IntField <= 0

	SELECT distinct Dept.deptCode, x_Dept_Employee_Service.DeptEmployeeID, x_Dept_Employee_Service.serviceCode, x_Dept_Employee.EmployeeID
	INTO #AllEmployeeServicesRecordsFilteredByQueueOrder
	FROM Dept
	LEFT JOIN x_Dept_Employee ON Dept.deptCode = x_Dept_Employee.deptCode
	LEFT JOIN x_Dept_Employee_Service ON x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod ON x_Dept_Employee_Service.x_Dept_Employee_ServiceID = EmployeeServiceQueueOrderMethod.x_dept_employee_serviceID

	LEFT JOIN EmployeeQueueOrderMethod ON x_Dept_Employee.DeptEmployeeID = EmployeeQueueOrderMethod.DeptEmployeeID
	LEFT JOIN DeptQueueOrderMethod ON Dept.deptCode = DeptQueueOrderMethod.deptCode

	LEFT JOIN #QueueOrderMethods SQOM ON EmployeeServiceQueueOrderMethod.QueueOrderMethod = SQOM.MethodCode
	LEFT JOIN #QueueOrderOptions SQOO ON x_Dept_Employee_Service.QueueOrder = SQOO.OptionCode

	LEFT JOIN #QueueOrderMethods EQOM ON EmployeeQueueOrderMethod.QueueOrderMethod = EQOM.MethodCode
	LEFT JOIN #QueueOrderOptions EQOO ON x_Dept_Employee.QueueOrder = EQOO.OptionCode

	LEFT JOIN #QueueOrderMethods DQOM ON DeptQueueOrderMethod.queueOrderMethod = DQOM.MethodCode
	LEFT JOIN #QueueOrderOptions DQOO ON Dept.QueueOrder = DQOO.OptionCode

	LEFT JOIN @ServiceCodesList as scl ON x_Dept_Employee_Service.serviceCode = scl.IntVal

	WHERE  (@QueueOrderOptionsAndMethods IS NULL)
	OR
	(
		( @ServiceCodes IS NULL OR @ServiceCodes = '' )
		AND 
		( DQOM.MethodCode IS NOT NULL OR DQOO.OptionCode IS NOT NULL )
	)
	OR
	(
		(
			(SQOM.MethodCode is not null OR SQOO.OptionCode is not null)
			OR 
			(x_Dept_Employee_Service.QueueOrder IS NULL AND (EQOM.MethodCode is not null OR EQOO.OptionCode is not null))
		)

		AND (scl.IntVal IS NOT NULL)
	)

	--SELECT * FROM #AllEmployeeServicesRecordsFilteredByQueueOrder
END

CREATE TABLE #tempTableAllRows 
( deptCode int, 
deptName varchar(100), 
deptType int, 
deptLevel int, 
displayPriority tinyint, 
ShowUnitInInternet tinyint, 
deptTypeDescription varchar(50),
typeUnitCode int,
subUnitTypeCode int,
SubstituteName varchar(100),
IsCommunity bit,
IsMushlam bit,
IsHospital bit,
UnitTypeName varchar(100),
cityCode int,
cityName varchar(50),
street varchar(50),
house varchar(50),
flat varchar(50),
addressComment varchar(500),
[address] varchar(600),
phone varchar(100),
remark varchar(500),
countDeptRemarks int,
countReception int,
Simul228 int,
distance float,
[status] smallint,
orderDeptNameLike tinyint,
xcoord float,
ycoord float,
ServiceDescription varchar(1000),
ServiceID int,
IsMedicalTeam bit,
doctorName varchar(50),
employeeID bigint,
ShowHoursPicture bit,
ShowRemarkPicture bit,
ServicePhones varchar(50),
serviceStatus tinyint,
employeeStatus tinyint,
agreementType tinyint,
ReceiveGuests smallint,
QueueOrderDescription varchar(50),
DeptEmployeeID int,
EmployeeHasReception tinyint,
ServiceOrEvent tinyint,
OrderValue int,
RowNumber int
);

-- SELECT WITH SERVICES
IF (@ServiceCodes is NOT null)
BEGIN
--SELECT * INTO #tempTableAllRows FROM 
INSERT INTO #tempTableAllRows
(deptCode , 
deptName , 
deptType , 
deptLevel , 
displayPriority , 
ShowUnitInInternet , 
deptTypeDescription ,
typeUnitCode ,
subUnitTypeCode ,
SubstituteName ,
IsCommunity ,
IsMushlam ,
IsHospital ,
UnitTypeName ,
cityCode ,
cityName ,
street ,
house ,
flat ,
addressComment ,
[address] ,
phone ,
remark ,
countDeptRemarks ,
countReception ,
Simul228 ,
distance ,
[status] ,
orderDeptNameLike ,
xcoord ,
ycoord ,
ServiceDescription ,
ServiceID ,
IsMedicalTeam ,
doctorName ,
employeeID ,
ShowHoursPicture ,
ShowRemarkPicture ,
ServicePhones ,
serviceStatus ,
employeeStatus ,
agreementType ,
ReceiveGuests ,
QueueOrderDescription ,
DeptEmployeeID ,
EmployeeHasReception ,
ServiceOrEvent ,
OrderValue ,
RowNumber )
SELECT * FROM
(
	SELECT *,
	'RowNumber'= CASE @SortedBy 
		WHEN 'deptName' THEN
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptName ) 
			END 
		WHEN 'cityName' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY cityName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY cityName )
			END 
		WHEN 'phone' THEN 
			CASE @IsOrderDescending
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY phone DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY phone ) 
			END 
		WHEN 'address' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY address DESC )
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY address ) 
			END 
		WHEN 'doctorName' THEN 
			CASE @IsOrderDescending  
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY doctorName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY doctorName ) 
			END 
		WHEN 'ServiceDescription' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription ) 
			END 
		WHEN 'subUnitTypeCode' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity ASC, IsMushlam DESC, IsHospital DESC, subUnitTypeCode DESC) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity DESC, IsMushlam ASC, IsHospital ASC, subUnitTypeCode ASC) 
			END 
		WHEN 'distance' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY distance DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode ) 
			END 
		ELSE 
			CASE @ShowWithNoReceptionHours 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), OrderValue ) 
			ELSE ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), EmployeeHasReception DESC, OrderValue ) 
			END
		END				

	FROM (
		SELECT distinct
		dept.deptCode,
		dept.deptName,
		dept.deptType,
		dept.deptLevel,
		dept.displayPriority,
		dept.ShowUnitInInternet,
		DIC_DeptTypes.deptTypeDescription,
		dept.typeUnitCode, 
		IsNull(dept.subUnitTypeCode, -1) as subUnitTypeCode,
		SubUnitTypeSubstituteName.SubstituteName,
		dept.IsCommunity,
		dept.IsMushlam,
		dept.IsHospital,
		UnitType.UnitTypeName,
		dept.cityCode,
		Cities.cityName,
		dept.streetName as street,
		dept.house,
		dept.flat,
		dept.addressComment, 
		dbo.GetAddress(dept.deptCode) as address,
		dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
		DeptPhones.remark,
		CASE WHEN EXISTS
			(SELECT * from View_DeptRemarks
			WHERE deptCode = dept.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			AND (IsSharedRemark = 0 OR dept.IsCommunity = 1))

			OR 
	
			EXISTS
			(SELECT * from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
			WHERE v_DE_ER.deptCode = dept.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01')))
		THEN 1 ELSE 0 END as countDeptRemarks,
		CASE WHEN EXISTS
			(select * from DeptReception_Regular_ThisWeek
			where deptCode = dept.deptCode AND closingHour <> '') THEN 1 ELSE 0 END
		as 	countReception,
		Simul228,
		(x_dept_XY.xcoord - @CoordinateX)*(x_dept_XY.xcoord - @CoordinateX) + (x_dept_XY.ycoord - @CoordinateY)*(x_dept_XY.ycoord - @CoordinateY)
		as distance,
		dept.status,
			CASE WHEN @DeptName is NOT null AND dept.DeptName like @DeptName + '%' THEN 0
				 WHEN @DeptName is NOT null AND dept.DeptName like + '%'+ @DeptName + '%'  THEN 1
				 ELSE 0 END
		as orderDeptNameLike,
		dbo.x_dept_XY.xcoord,
		dbo.x_dept_XY.ycoord,
		CASE WHEN @IsHospital = 1 AND Employee.IsMedicalTeam = 1 AND xDE.AgreementType = 5 
			THEN dbo.fun_GetMedicalAspectsForService(T_services.ServiceCode, xDE.DeptEmployeeID)
			ELSE T_services.ServiceDescription  
			END as ServiceDescription,
		T_services.ServiceCode as ServiceID,
		Employee.IsMedicalTeam as IsMedicalTeam, 
		DegreeName + space(1) + Employee.lastName + space(1) + Employee.firstName as doctorName, 
		Employee.employeeID as employeeID, 
		  CASE WHEN isNull(T_services.ReceptionCount, 0) = 0 then 0 else 1 end
		as ShowHoursPicture,
		CASE WHEN EXISTS 
			(SELECT View_DeptRemarks.deptCode
			from View_DeptRemarks
			JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
			WHERE deptCode = xde.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			) THEN 3 
				ELSE 
			  CASE WHEN EXISTS
				(select DESR.RemarkID from view_DeptEmployeeServiceRemarks DESR
					where T_services.x_dept_employee_serviceID = DESR.x_dept_employee_serviceID
					AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
					)  THEN 1 
					ELSE 
						  CASE WHEN EXISTS
							(select v_DE_ER.DeptCode from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
							WHERE v_DE_ER.DeptEmployeeID = xde.DeptEmployeeID
							AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
							) THEN 2 
						
							ELSE 				
							  CASE WHEN EXISTS
								(SELECT der.receptionID 
								FROM deptEmployeeReception der
								JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID 
								JOIN DeptEmployeeReceptionRemarks derr ON derr.EmployeeReceptionID = der.receptionID
								WHERE der.DeptEmployeeID = xde.DeptEmployeeID  
								AND ders.serviceCode = T_services.serviceCode
								AND (@DateNow between ISNULL(der.ValidFrom,'1900-01-01') and ISNULL(der.ValidTo,'2079-01-01'))
								) THEN 4 ELSE 0 END				
							END		
					END 
			END
	as ShowRemarkPicture,
	  stuff((SELECT '', ''  + convert(varchar(10), x.phone)
			FROM (select dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) as phone
				FROM x_Dept_Employee_Service 
				JOIN EmployeeServicePhones on EmployeeServicePhones.x_Dept_Employee_ServiceID = x_Dept_Employee_Service.x_Dept_Employee_ServiceID
				where x_Dept_Employee_Service.serviceCode = T_services.serviceCode
				and x_Dept_Employee_Service.DeptEmployeeID = xDE.DeptEmployeeID
			) x
			for xml path('')
		),1,1,'')
	as ServicePhones,
	T_services.status as serviceStatus,
	xDE.active as employeeStatus,
	xDE.agreementType,

	CASE WHEN T_services.ServiceCode is null THEN 0 ELSE emp_pr.ReceiveGuests END 
		as ReceiveGuests,
	CASE WHEN ServiceQueueOrderDescription is not null THEN ServiceQueueOrderDescription ELSE emp_pr.QueueOrderDescription END
		as QueueOrderDescription, 
	xDE.DeptEmployeeID,
	emp_pr.HasReception as EmployeeHasReception,
	1 as ServiceOrEvent, /* 1 for service, 0 for event */
	CASE WHEN @SortedBy is null THEN RandomOrderSelect.OrderValue ELSE 1 END as OrderValue

	--INTO #SelectedData 
		FROM dept
		INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
		INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
		INNER JOIN Cities on dept.cityCode = Cities.cityCode
		LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
			AND DeptPhones.phoneType = 1 AND phoneOrder = 1
		LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
		LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
		LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode

		INNER JOIN x_dept_employee xDE on Dept.deptCode = xDE.deptCode 
			AND xDE.AgreementType in (select * from @AgreementTypeList)
		INNER JOIN EmployeeInClinic_preselected emp_pr ON xDE.DeptEmployeeID = emp_pr.DeptEmployeeID
			AND (@ReceiveGuests <> 1 OR emp_pr.ReceiveGuests = 1 OR emp_pr.ReceiveGuests = 2)
		INNER JOIN Employee on Employee.employeeID = xDE.employeeID
		LEFT JOIN DIC_EmployeeDegree on DIC_EmployeeDegree.DegreeCode = Employee.degreeCode 

		INNER JOIN  
		(		
			SELECT DISTINCT
				xDE2.DeptEmployeeID,
				0 as x_dept_employee_serviceID,
				1 as status, 
				null as ServiceQueueOrderDescription,
				CASE WHEN @ServiceCodeForMuslam is NOT null THEN @ServiceCodeForMuslam
					ELSE @Top1From_ServiceCodesList END as ServiceCode, 
				' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + [dbo].[fun_GetEmployeeMushlamInDeptServices](xDE2.EmployeeID,xDE2.deptCode,1) as ServiceDescription,
				(	SELECT COUNT(*) FROM x_Dept_Employee_Service
					JOIN deptEmployeeReception_Regular ON x_Dept_Employee_Service.DeptEmployeeID = deptEmployeeReception_Regular.DeptEmployeeID
							AND @DateNow between ISNULL(validFrom,'1900-01-01') and ISNULL(validTo,'2079-01-01')
					WHERE x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID
					AND x_Dept_Employee_Service.serviceCode = 180300) as ReceptionCount		

				FROM x_dept_employee xDE2
				JOIN Employee E ON xDE2.employeeID = E.employeeID
				JOIN EmployeeInClinic_preselected Pre ON xDE2.DeptEmployeeID = Pre.DeptEmployeeID

				WHERE EXISTS (	SELECT * FROM x_Dept_Employee_Service 
								WHERE x_Dept_Employee_Service.serviceCode = 180300
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID ) 
				AND (	(@ServiceCodeForMuslam is NOT null 
							AND 
							EXISTS (SELECT * FROM x_Dept_Employee_Service
									WHERE x_Dept_Employee_Service.serviceCode = @ServiceCodeForMuslam
									AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID )	
						)
						OR
						(@ServiceCodeForMuslam is null 
							AND 
							EXISTS (SELECT * FROM x_Dept_Employee_Service 
									WHERE x_Dept_Employee_Service.serviceCode in (SELECT IntVal FROM @ServiceCodesList )
									AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID )
						)
					)
				AND	(@Status is null
					OR (@Status = 0 AND xDE2.active = 0)
					OR (@Status = 1 AND (xDE2.active = 1 OR (@UserIsLogged = 1 AND xDE2.active = 2 )))
					OR (@Status = 2 AND (xDE2.active = 1 ))
					)

				AND ( @CheckWorkingHours <> 1
			
					OR
					-- *******************
					EXISTS 
						(
						SELECT * FROM deptEmployeeReception_Regular dER 
						JOIN deptEmployeeReceptionServices dERS on dER.DeptEmployeeReceptionID = dERS.receptionID 
						LEFT JOIN DeptEmployeeReceptionRemarks DERR ON dER.DeptEmployeeReceptionID = DERR.EmployeeReceptionID 

						WHERE ( @DateNow between ISNULL(dER.validFrom,'1900-01-01') and ISNULL(dER.validTo,'2079-01-01') )
						AND dERS.serviceCode IN (SELECT IntVal FROM @ServiceCodesList )
						AND xDE2.DeptEmployeeID = dER.DeptEmployeeID
						AND xDE2.AgreementType in (select * from @AgreementTypeList)

						AND ( @OpenFromHour IS NULL 
						
							OR ( dER.openingHour < @OpenToHour AND dER.closingHour > @OpenFromHour )
							)

						AND ( @OpenAtHour IS NULL 
						
								OR ( dER.openingHour <= @OpenAtHour AND dER.closingHour > @OpenAtHour )
							)

						AND ( @OpenNow <> 1  
						
							OR ( dER.openingHour <= @OpenAtThisHour AND dER.closingHour > @OpenAtThisHour )
							)

						AND ( @ReceptionDays IS NULL 
						
							OR  dER.receptionDay in (select IntVal from @ReceptionDaysList) 
							)
						AND (DERR.RemarkID IS NULL OR DERR.RemarkID NOT IN (156, 404))

						)
					-- END **************
					OR
					(
						(
								(E.IsMedicalTeam = 0 AND Pre.HasReception = 0)
								OR
								(	E.IsMedicalTeam = 1
									AND
									NOT EXISTS 
									(
										SELECT deptCode
										FROM x_Dept_Employee xDE
										JOIN deptEmployeeReception_Regular dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
										AND @DateNow between ISNULL(dER.validFrom,'1900-01-01') and ISNULL(dER.validTo,'2079-01-01')
										JOIN deptEmployeeReceptionServices dERS on dER.DeptEmployeeReceptionID = dERS.receptionID 
										WHERE xDE.AgreementType in (select * from @AgreementTypeList)
										AND exists (select * from @ServiceCodesList where IntVal = dERS.serviceCode)
										AND xDE.deptCode = xDE2.deptCode
										AND xDE.employeeID = xDE2.employeeID
									)
								)
						)
						AND -- NEW condition
						(
							EXISTS 
							(SELECT deptCode FROM DeptReception_Regular_ThisWeek as T
							 WHERE T.deptCode = xDE2.deptCode
							AND T.closingHour <> ''
							AND ( @OpenFromHour IS NULL 
									OR ( T.closingHour <> '' AND (T.openingHour < @OpenToHour AND T.closingHour > @OpenFromHour ))
								)

							AND ( @OpenAtHour IS NULL 
								OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtHour AND T.closingHour > @OpenAtHour) )
								)

							AND ( @OpenNow <> 1  
								OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtThisHour AND T.closingHour > @OpenAtThisHour) )
								)

							AND ( @ReceptionDays IS NULL 
								OR (T.closingHour <> '' AND T.receptionDay in (select IntVal from @ReceptionDaysList) )
								)

							)
				
						)
					)
				)



				UNION

				SELECT DISTINCT
				xDE2.DeptEmployeeID,
				xDES.x_dept_employee_serviceID,
				xDES.status,
				DIC_QueueOrder.QueueOrderDescription as ServiceQueueOrderDescription, 
				[Services].ServiceCode,
				[Services].ServiceDescription as ServiceDescription,
				[View_DeptEmployeeReceptionCount].ReceptionCount
				FROM x_dept_employee xDE2
				JOIN Employee E ON xDE2.employeeID = E.employeeID
				JOIN EmployeeInClinic_preselected Pre ON xDE2.DeptEmployeeID = Pre.DeptEmployeeID
				JOIN x_Dept_Employee_Service xDES on xDE2.DeptEmployeeID = xDES.DeptEmployeeID
					AND xDES.serviceCode IN (SELECT IntVal FROM @ServiceCodesList )
				LEFT JOIN DIC_QueueOrder on xDES.QueueOrder = DIC_QueueOrder.QueueOrder
				JOIN [Services] on [Services].ServiceCode = xDES.serviceCode
				LEFT JOIN [View_DeptEmployeeReceptionCount] on [View_DeptEmployeeReceptionCount].DeptEmployeeID = xDE2.DeptEmployeeID
					and [View_DeptEmployeeReceptionCount].serviceCode = xDES.serviceCode
					--and xDE2.AgreementType in (select * from @AgreementTypeList)
				WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
									WHERE x_Dept_Employee_Service.serviceCode = 180300
									AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	)
				AND (@Status is null
					OR (@Status = 0 AND xDES.status = 0)
					OR (@Status = 1 AND (xDES.status = 1 OR (@UserIsLogged = 1 AND xDES.status = 2 ))) 
					OR (@Status = 2 AND (xDES.status = 1 ))
					)
				AND	(@Status is null
					OR (@Status = 0 AND xDE2.active = 0)
					OR (@Status = 1 AND (xDE2.active = 1 OR (@UserIsLogged = 1 AND xDE2.active = 2 )))
					OR (@Status = 2 AND (xDE2.active = 1 ))
					)

				AND ( @CheckWorkingHours <> 1
			
					OR
					-- *******************
					EXISTS 
						(
						SELECT * FROM deptEmployeeReception_Regular dER 
						JOIN deptEmployeeReceptionServices dERS on dER.DeptEmployeeReceptionID = dERS.receptionID 
						LEFT JOIN DeptEmployeeReceptionRemarks DERR ON dER.DeptEmployeeReceptionID = DERR.EmployeeReceptionID 

						WHERE ( @DateNow between ISNULL(dER.validFrom,'1900-01-01') and ISNULL(dER.validTo,'2079-01-01') )
						AND dERS.serviceCode IN (SELECT IntVal FROM @ServiceCodesList )
						AND xDE2.DeptEmployeeID = dER.DeptEmployeeID
						AND xDE2.AgreementType in (select * from @AgreementTypeList)

						AND ( @OpenFromHour IS NULL 
						
							OR ( dER.openingHour < @OpenToHour AND dER.closingHour > @OpenFromHour )
							)

						AND ( @OpenAtHour IS NULL 
						
								OR ( dER.openingHour <= @OpenAtHour AND dER.closingHour > @OpenAtHour )
							)

						AND ( @OpenNow <> 1  
						
							OR ( dER.openingHour <= @OpenAtThisHour AND dER.closingHour > @OpenAtThisHour )
							)

						AND ( @ReceptionDays IS NULL 
						
							OR  dER.receptionDay in (select IntVal from @ReceptionDaysList) 
							)

						AND (DERR.RemarkID IS NULL OR DERR.RemarkID NOT IN (156, 404))

						)
					-- END **************
					OR
					(
						(
								(E.IsMedicalTeam = 0 AND Pre.HasReception = 0)
								OR
								(	E.IsMedicalTeam = 1
									AND
									NOT EXISTS 
									(
										SELECT deptCode
										FROM x_Dept_Employee xDE
										JOIN deptEmployeeReception_Regular dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
										AND @DateNow between ISNULL(dER.validFrom,'1900-01-01') and ISNULL(dER.validTo,'2079-01-01')
										JOIN deptEmployeeReceptionServices dERS on dER.DeptEmployeeReceptionID = dERS.receptionID 
										WHERE xDE.AgreementType in (select * from @AgreementTypeList)
										AND exists (select * from @ServiceCodesList where IntVal = dERS.serviceCode)
										AND xDE.deptCode = xDE2.deptCode
										AND xDE.employeeID = xDE2.employeeID
									)
								)
						)
						AND -- NEW condition
						(
							EXISTS 
							(SELECT deptCode FROM DeptReception_Regular_ThisWeek as T
							 WHERE T.deptCode = xDE2.deptCode
							AND T.closingHour <> ''
							AND ( @OpenFromHour IS NULL 
									OR ( T.closingHour <> '' AND (T.openingHour < @OpenToHour AND T.closingHour > @OpenFromHour ))
								)

							AND ( @OpenAtHour IS NULL 
								OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtHour AND T.closingHour > @OpenAtHour) )
								)

							AND ( @OpenNow <> 1  
								OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtThisHour AND T.closingHour > @OpenAtThisHour) )
								)

							AND ( @ReceptionDays IS NULL 
								OR (T.closingHour <> '' AND T.receptionDay in (select IntVal from @ReceptionDaysList) )
								)

							)
				
						)
					)
				)
	/*
	DELETE FROM [dbo].[DeptEmployeeID_selected] 
	DELETE FROM [dbo].[DeptEmployeeID_selected_NEW]
	*/
		)	as T_services 
			ON 	T_services.DeptEmployeeID = xDE.DeptEmployeeID	

		LEFT JOIN x_dept_medicalAspect 
			ON @MedicalAspectCode is NOT NULL AND Dept.deptCode = x_dept_medicalAspect.NewDeptCode

		LEFT JOIN vMushlamCervices 
			ON @ServiceCodeForMuslam is NOT NULL AND T_services.ServiceCode = vMushlamCervices.ServiceCode
			AND vMushlamCervices.ServiceCode is NOT NULL		

		LEFT JOIN (Select CAST(DeptEmployeeID as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
			from x_Dept_Employee) RandomOrderSelect 
			ON @SortedBy is null AND T_services.DeptEmployeeID = RandomOrderSelect.KeyValue

		LEFT JOIN #AllEmployeeServicesRecordsFilteredByQueueOrder 
			ON xDE.DeptEmployeeID = #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID

		WHERE 1= 1

		AND	(@DistrictCodes is null
				OR
				 (
						exists (SELECT IntField FROM dbo.SplitString(@DistrictCodes) where dept.districtCode = IntField) 
						OR
						exists (SELECT IntField FROM dbo.SplitString(@DistrictCodes) as T
								JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode
								WHERE x_Dept_District.DeptCode = dept.DeptCode)
						OR (deptLevel = 1 AND dept.IsHospital = 0)
				  ) 
			)
		AND (@QueueOrderOptionsAndMethods IS NULL OR @QueueOrderOptionsAndMethods = '' 
			OR ( @ServiceCodes IS NOT NULL AND #AllEmployeeServicesRecordsFilteredByQueueOrder.DeptEmployeeID IS NOT NULL) 
			OR ( @ServiceCodes IS NULL AND #AllEmployeeServicesRecordsFilteredByQueueOrder.deptCode IS NOT NULL) 			
			) -- !!! NEW

		AND	(@CityCode is NULL
			OR
			@CoordinateX is  NOT NULL
			OR
				( 
					(dept.CityCode = @CityCode
						OR 
						(
						--(@xTypeUnitCode is NOT null OR @xServiceCodes is NOT null)
						--AND 
						dept.deptLevel = 1 
							OR (dept.deptLevel = 2 
								AND exists (SELECT districtCode FROM Cities WHERE cityCode = @CityCode
											and (districtCode = dept.districtCode
													OR districtCode IN (SELECT districtCode FROM x_Dept_District WHERE x_Dept_District.deptCode = dept.deptCode)
												)
											)
								)
						)
					)
				)
			)

		AND	(@Status is null
			OR (@Status = 0 AND dept.status = 0)
			OR (@Status = 1 AND (dept.status = 1 OR (@UserIsLogged = 1 AND dept.status = 2 ))) 
			OR (@Status = 2 AND dept.status = 2 )
			)

		AND (@typeUnitCode is null
			OR
			(dept.typeUnitCode in (Select IntField from dbo.SplitString(@TypeUnitCode)) )
			)

		AND (@subUnitTypeCode is null
			OR
			(dept.subUnitTypeCode in (Select IntField from dbo.SplitString(@SubUnitTypeCode)))
			)

		AND (@DeptName is null
			OR
			 (dept.DeptName like '%' + @DeptName + '%'  
			 OR dept.DeptName like @DeptName + '%'
			 OR dept.DeptName = @DeptName	) 
		
			)

		AND (@DeptCode is null OR dept.deptCode = @DeptCode OR deptSimul.Simul228 = @DeptCode)
	
		AND (@MedicalAspectCode is null
			OR x_dept_medicalAspect.MedicalAspectCode = @MedicalAspectCode 
			)

		AND(@deptHandicappedFacilities IS NULL 
			OR exists (SELECT deptCode FROM dept as New
				  WHERE dept.deptCode = New.deptCode
				  AND (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
						WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@DeptHandicappedFacilities))
						AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )	
		)

		AND ((@isCommunity IS NOT NULL OR @isMushlam IS NOT NULL OR @isHospital IS NOT NULL)
			AND ( @IsCommunity = dept.IsCommunity OR @IsMushlam = dept.isMushlam OR @IsHospital = dept.isHospital ) 
			)

		AND (@populationSectorCode IS NULL 
			OR dept.populationSectorCode = @PopulationSectorCode
		)

		AND (@CoordinateX IS NULL OR (x_dept_XY.xcoord is NOT null AND x_dept_XY.ycoord is NOT null))

		AND (@ServiceCodeForMuslam IS NULL
			OR 
				(
				vMushlamCervices.ServiceCode = @ServiceCodeForMuslam
				AND xDE.AgreementType IN (3,4)
				AND xDE.active = 1 and dept.status = 1 and T_services.Status = 1
				AND (	(vMushlamCervices.originalServiceCode = 180300 and dept.typeUnitCode = 112
						AND 
						exists (select * from x_dept_employee_service xdes2 
								where xdes2.DeptEmployeeID = xDE.DeptEmployeeID
								AND xdes2.serviceCode = vMushlamCervices.ServiceCode)
						AND 
						exists (select * from x_dept_employee_service xdes2 
								where xdes2.DeptEmployeeID = xDE.DeptEmployeeID
								AND xdes2.serviceCode = 180300)
						)
						OR 
						(vMushlamCervices.originalServiceCode <> 180300 and (dept.typeUnitCode <> 112 or Employee.IsMedicalTeam = 1))
					)
				AND	(@GroupCode IS NULL OR vMushlamCervices.GroupCode = @GroupCode)
				AND (@SubGroupCode IS NULL OR vMushlamCervices.SubGroupCode = @SubGroupCode)
				)
			)

	-- EVENTS

		UNION

		SELECT
		dept.deptCode,
		dept.deptName,
		dept.deptType,
		dept.deptLevel,
		dept.displayPriority,
		dept.ShowUnitInInternet,
		DIC_DeptTypes.deptTypeDescription,
		dept.typeUnitCode,
		IsNull(dept.subUnitTypeCode, -1) as subUnitTypeCode,
		SubstituteName = '',
		dept.IsCommunity,
		dept.IsMushlam,
		dept.IsHospital,
		UnitType.UnitTypeName,
		dept.cityCode,
		Cities.cityName,
		dept.streetName as street,
		dept.house,
		dept.flat,
		dept.addressComment,
		dbo.GetAddress(dept.deptCode)
		as address,
		dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
		DeptPhones.remark,	
			(SELECT COUNT(*) 
			from View_DeptRemarks
			WHERE deptCode = dept.deptCode
			AND @DateNow between ISNULL(validFrom,'1900-01-01') and ISNULL(validTo,'2079-01-01')
			AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
			)
		as countDeptRemarks,
			(select count(*) 
			from DeptReception_Regular_ThisWeek
			where deptCode = dept.deptCode AND closingHour <> '' )
		as countReception,
		Simul228 = null,
			(xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY)
		as distance,
		dept.status,
			CASE --WHEN @xDeptName is null THEN 0 
				 WHEN @DeptName is NOT null AND dept.DeptName like @DeptName +'%' THEN 0
				 WHEN @DeptName is NOT null AND dept.DeptName like '%'+ @DeptName + '%' THEN 1
				 ELSE 0 END
		as orderDeptNameLike, 
		dbo.x_dept_XY.xcoord,
		dbo.x_dept_XY.ycoord,					
			DIC_Events.EventName
		as ServiceDescription,
			DeptEvent.DeptEventID
		as ServiceID,
		'' as IsMedicalTeam, 
		'' as doctorName, 
		0000 as employeeID,
		1 as ShowHoursPicture,
		0 as ShowRemarkPicture, 
		'' as ServicePhones,
		1 as serviceStatus,
		1 as employeeStatus,
		0 as AgreementType,
		0 as ReceiveGuests,
		'' as QueueOrderDescription,
		0 as DeptEmployeeID,
		0 as EmployeeHasReception,
		0 as ServiceOrEvent, -- 1 for service, 0 for event 
		CASE WHEN @SortedBy is null THEN RandomOrderSelect.OrderValue ELSE 1 END as OrderValue

		FROM DeptEvent
		INNER JOIN dept ON DeptEvent.deptCode = dept.deptCode
		INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
		INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
		INNER JOIN Cities on dept.cityCode = Cities.cityCode
		LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
			AND DeptPhones.phoneType = 1 AND phoneOrder = 1	
		INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
			AND DIC_Events.IsActive = 1
			AND DIC_Events.EventCode IN (select IntVal from @ServiceCodesList)
		LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode 

		LEFT JOIN (Select CAST(DeptEventID as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
		from DeptEvent as DeptEvent2) RandomOrderSelect 
		ON DeptEvent.DeptEventID = RandomOrderSelect.KeyValue

		WHERE  
			(@DistrictCodes IS NULL 
			OR
				(
					dept.districtCode IN (Select IntField from dbo.SplitString(@DistrictCodes))
					OR 
					dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
									JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
				)
			)
		
		--AND exists (select * from @ServiceCodesList where IntVal = DIC_Events.EventCode)

		AND (
				( @CityCode is NOT null AND @CoordinateX is null)
			OR

				( dept.CityCode = @CityCode
					OR (@typeUnitCode is null
						OR 
						(dept.deptLevel = 1 
							OR (dept.deptLevel = 2 
								AND exists (SELECT districtCode FROM Cities 
											WHERE cityCode = @CityCode 
											and (dept.districtCode = districtCode
													OR districtCode IN (SELECT districtCode FROM x_Dept_District WHERE x_Dept_District.deptCode = dept.deptCode)
												)
											)
								)
						)
					)
				)
			)

		AND (@typeUnitCode is null OR typeUnitCode in (Select IntField from dbo.SplitString(@TypeUnitCode))	)

		AND (@subUnitTypeCode is null OR subUnitTypeCode = @SubUnitTypeCode)

		AND (@DeptName is null OR (dept.DeptName like @DeptName + '%'))

		AND ( @CheckWorkingHours <> 1
			OR
			EXISTS 
				(SELECT deptCode FROM DeptReception_Regular_ThisWeek as T
					WHERE T.deptCode = dept.deptCode
					AND T.closingHour <> ''
					AND ( @OpenFromHour IS NULL 
							OR ( T.closingHour <> '' AND (T.openingHour < @OpenToHour AND T.closingHour > @OpenFromHour ))
						)

					AND ( @OpenAtHour IS NULL 
						OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtHour AND T.closingHour > @OpenAtHour) )
						)

					AND ( @OpenNow <> 1  
						OR ( T.closingHour <> '' AND ( T.openingHour <= @OpenAtThisHour AND T.closingHour > @OpenAtThisHour) )
						)

					AND ( @ReceptionDays IS NULL 
						OR (T.closingHour <> '' AND T.receptionDay in (select IntVal from @ReceptionDaysList) )
						)
				)
			)

		AND (@deptHandicappedFacilities is null 
			OR 
			EXISTS (SELECT deptCode FROM dept as New
							WHERE dept.deptCode = New.deptCode
								and (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
									WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@DeptHandicappedFacilities))
									AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
			)

		AND (@deptCode is null OR Dept.deptCode = @DeptCode)

		AND (@CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))

		AND ( (@DateNow between ISNULL(DeptEvent.FromDate,'1900-01-01') and ISNULL(DeptEvent.ToDate,'2079-01-01') AND @Status = 1)
			  OR
			  ((DeptEvent.FromDate > @DateNow OR DeptEvent.ToDate < @DateNow) AND @Status = 0)
			) 
		  
		AND (Dept.Status <> 0) 
		AND ((@isCommunity is null AND @isMushlam is null AND @isHospital is null)
			OR
			(    (@IsCommunity IS NOT NULL AND dept.IsCommunity = @IsCommunity)
				OR (@IsMushlam IS NOT NULL AND dept.IsMushlam = @IsMushlam)
				OR (@IsHospital IS NOT NULL AND dept.IsHospital = @IsHospital)
			   )
			)


	-- END OF EVENTS
		) as innerDeptSelection
	) as middleSelection

	--SELECT * FROM #SelectedData
	--DELETE FROM [DeptEmployeeID_selected_NEW]
	--INSERT INTO [dbo].[DeptEmployeeID_selected_NEW]
	--([DeptEmployeeID])
	--SELECT DeptEmployeeID FROM #SelectedData

END

ELSE
BEGIN

INSERT INTO #tempTableAllRows
(deptCode , 
deptName , 
deptType , 
deptLevel , 
displayPriority , 
ShowUnitInInternet , 
deptTypeDescription ,
typeUnitCode ,
subUnitTypeCode ,
SubstituteName ,
IsCommunity ,
IsMushlam ,
IsHospital ,
UnitTypeName ,
cityCode ,
cityName ,
street ,
house ,
flat ,
addressComment ,
[address] ,
phone ,
remark ,
countDeptRemarks ,
countReception ,
Simul228 ,
distance ,
[status] ,
orderDeptNameLike ,
xcoord ,
ycoord ,
ServiceDescription ,
ServiceID ,
IsMedicalTeam ,
doctorName ,
employeeID ,
ShowHoursPicture ,
ShowRemarkPicture ,
ServicePhones ,
serviceStatus ,
employeeStatus ,
agreementType ,
ReceiveGuests ,
QueueOrderDescription ,
DeptEmployeeID ,
EmployeeHasReception ,
ServiceOrEvent ,
OrderValue ,
RowNumber )

SELECT * FROM
(
	SELECT *,
	'RowNumber'= CASE @SortedBy 
		WHEN 'deptName' THEN
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptName ) 
			END 
		WHEN 'cityName' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY cityName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY cityName )
			END 
		WHEN 'phone' THEN 
			CASE @IsOrderDescending
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY phone DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY phone ) 
			END 
		WHEN 'address' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY address DESC )
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY address ) 
			END 
		WHEN 'doctorName' THEN 
			CASE @IsOrderDescending  
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY doctorName DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY doctorName ) 
			END 
		WHEN 'ServiceDescription' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription ) 
			END 
		WHEN 'subUnitTypeCode' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity ASC, IsMushlam DESC, IsHospital DESC, subUnitTypeCode DESC) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity DESC, IsMushlam ASC, IsHospital ASC, subUnitTypeCode ASC) 
			END 
		WHEN 'distance' THEN 
			CASE @IsOrderDescending 
			WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY distance DESC ) 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode ) 
			END 
		ELSE 
			CASE @ShowWithNoReceptionHours 
			WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), OrderValue ) 
			ELSE ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), EmployeeHasReception DESC, OrderValue ) 
			END
		END				

	FROM (
		SELECT distinct
		dept.deptCode,
		dept.deptName,
		dept.deptType,
		dept.deptLevel,
		dept.displayPriority,
		dept.ShowUnitInInternet,
		DIC_DeptTypes.deptTypeDescription,
		dept.typeUnitCode, 
		IsNull(dept.subUnitTypeCode, -1) as subUnitTypeCode,
		SubUnitTypeSubstituteName.SubstituteName,
		dept.IsCommunity,
		dept.IsMushlam,
		dept.IsHospital,
		UnitType.UnitTypeName,
		dept.cityCode,
		Cities.cityName,
		dept.streetName as street,
		dept.house,
		dept.flat,
		dept.addressComment, 
		dbo.GetAddress(dept.deptCode) as address,
		dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
		DeptPhones.remark,
		CASE WHEN EXISTS
			(SELECT * from View_DeptRemarks
			WHERE deptCode = dept.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			AND (IsSharedRemark = 0 OR dept.IsCommunity = 1))

			OR 
	
			EXISTS
			(SELECT * from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
			WHERE v_DE_ER.deptCode = dept.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01')))
		THEN 1 ELSE 0 END as countDeptRemarks,
		CASE WHEN EXISTS
			(select * from DeptReception_Regular_ThisWeek
			where deptCode = dept.deptCode AND closingHour <> '') THEN 1 ELSE 0 END
		as 	countReception,
		Simul228,
		(x_dept_XY.xcoord - @CoordinateX)*(x_dept_XY.xcoord - @CoordinateX) + (x_dept_XY.ycoord - @CoordinateY)*(x_dept_XY.ycoord - @CoordinateY)
		as distance,
		dept.status,
			CASE WHEN @DeptName is NOT null AND dept.DeptName like @DeptName + '%' THEN 0
				 WHEN @DeptName is NOT null AND dept.DeptName like + '%'+ @DeptName + '%'  THEN 1
				 ELSE 0 END
		as orderDeptNameLike,
		dbo.x_dept_XY.xcoord,
		dbo.x_dept_XY.ycoord,
		'' as ServiceDescription,
		'' as ServiceID,
		0 as IsMedicalTeam, 
		'' as doctorName, 
		'' as employeeID, 
		0 as ShowHoursPicture,
		0 as ShowRemarkPicture,
		'' as ServicePhones,
		1 as serviceStatus,
		1 as employeeStatus,
		0 as agreementType,
		0 as ReceiveGuests,
		'' as QueueOrderDescription, 
		0 as DeptEmployeeID,
		0 as EmployeeHasReception,
		1 as ServiceOrEvent, /* 1 for service, 0 for event */
		CASE WHEN @SortedBy is null THEN RandomOrderSelect.OrderValue ELSE 1 END as OrderValue

	--INTO #SelectedData 
		FROM dept
		INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
		INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
		INNER JOIN Cities on dept.cityCode = Cities.cityCode
		LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
			AND DeptPhones.phoneType = 1 AND phoneOrder = 1
		LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
		LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
		LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode
		
		LEFT JOIN x_dept_medicalAspect 
			ON @MedicalAspectCode is NOT NULL AND Dept.deptCode = x_dept_medicalAspect.NewDeptCode

		LEFT JOIN (Select CAST(DeptCode as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
			from dept) RandomOrderSelect 
			ON @SortedBy is null AND dept.deptCode = RandomOrderSelect.KeyValue

		WHERE 1= 1

		AND	(@DistrictCodes is null
				OR
				 (
						exists (SELECT IntField FROM dbo.SplitString(@DistrictCodes) where dept.districtCode = IntField) 
						OR
						exists (SELECT IntField FROM dbo.SplitString(@DistrictCodes) as T
								JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode
								WHERE x_Dept_District.DeptCode = dept.DeptCode)
						OR (deptLevel = 1 AND dept.IsHospital = 0)
				  ) 
			)
		AND	(@CityCode is NULL
			OR
			@CoordinateX is  NOT NULL
			OR
				( 
					(dept.CityCode = @CityCode
						OR 
						(
						(@TypeUnitCode is NOT null)
						AND 
						dept.deptLevel = 1 
							OR (dept.deptLevel = 2 
								AND exists (SELECT districtCode FROM Cities WHERE cityCode = @CityCode
											and (districtCode = dept.districtCode
													OR districtCode IN (SELECT districtCode FROM x_Dept_District WHERE x_Dept_District.deptCode = dept.deptCode)
												)
											)
								)
						)
					)
				)
			)

		AND	(@Status is null
			OR (@Status = 0 AND dept.status = 0)
			OR (@Status = 1 AND (dept.status = 1 OR (@UserIsLogged = 1 AND dept.status = 2 ))) 
			OR (@Status = 2 AND dept.status = 2 )
			)

		AND ( @CheckWorkingHours <> 1
			OR
			EXISTS 
				(SELECT deptCode FROM DeptReception_Regular_ThisWeek as T
					WHERE T.deptCode = dept.deptCode
					AND T.closingHour <> ''
					AND ( @OpenFromHour IS NULL 
							OR ( T.openingHour < @OpenToHour AND T.closingHour > @OpenFromHour )
						)

					AND ( @OpenAtHour IS NULL 
						OR ( T.openingHour <= @OpenAtHour AND T.closingHour > @OpenAtHour )
						)

					AND ( @OpenNow <> 1  
						OR ( T.openingHour <= @OpenAtThisHour AND T.closingHour > @OpenAtThisHour )
						)

					AND ( @ReceptionDays IS NULL 
						OR  T.receptionDay in (select IntVal from @ReceptionDaysList) 
						)

				)
			)

		AND (@typeUnitCode is null
			OR
			(dept.typeUnitCode in (Select IntField from dbo.SplitString(@TypeUnitCode)) )
			)

		AND (@subUnitTypeCode is null
			OR
			(dept.subUnitTypeCode in (Select IntField from dbo.SplitString(@SubUnitTypeCode)))
			)

		AND (@DeptName is null
			OR
			 (dept.DeptName like '%' + @DeptName + '%'  
			 OR dept.DeptName like @DeptName + '%'
			 OR dept.DeptName = @DeptName	) 
		
			)

		AND (@DeptCode is null OR dept.deptCode = @DeptCode OR deptSimul.Simul228 = @DeptCode)
	
		AND (@MedicalAspectCode is null
			OR x_dept_medicalAspect.MedicalAspectCode = @MedicalAspectCode 
			)

		AND(@deptHandicappedFacilities IS NULL 
			OR exists (SELECT deptCode FROM dept as New
				  WHERE dept.deptCode = New.deptCode
				  AND (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
						WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@DeptHandicappedFacilities))
						AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )	
		)

		AND ((@isCommunity IS NOT NULL OR @isMushlam IS NOT NULL OR @isHospital IS NOT NULL)
			AND ( @IsCommunity = dept.IsCommunity OR @IsMushlam = dept.isMushlam OR @IsHospital = dept.isHospital ) 
			)

		AND (@populationSectorCode IS NULL 
			OR dept.populationSectorCode = @PopulationSectorCode
		)

		AND (@CoordinateX IS NULL OR (x_dept_XY.xcoord is NOT null AND x_dept_XY.ycoord is NOT null))

		) as innerDeptSelection
	) as middleSelection


END
---- ***** Common part ****************************************************

IF(@MaxNumberOfRecords is NOT null)
BEGIN
	IF(@MaxNumberOfRecords < @PageSise)
	BEGIN
		SET @PageSise = @MaxNumberOfRecords
	END
END

SELECT TOP (@PageSise) * 
INTO #tempTableFinalSelect
FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition
	AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber

SELECT * FROM #tempTableFinalSelect

-- @Count - number to be shown on page (paging controls)
SET @Count = (SELECT COUNT(*) FROM #tempTableAllRows)

IF(@MaxNumberOfRecords is NOT null)
BEGIN
	IF(@Count > @MaxNumberOfRecords)
	BEGIN
		SET @Count = @MaxNumberOfRecords
	END
END


SELECT @Count

DECLARE @DeptCodeList varchar(max) = ''
SELECT TOP (SELECT @Count) @DeptCodeList = @DeptCodeList + CAST(deptCode as varchar(10)) + ',' 
FROM (SELECT DISTINCT deptCode FROM #tempTableFinalSelect) T

SELECT @DeptCodeList

-- QueueOrderMethods (via employees services)
SELECT esqom.QueueOrderMethod, #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, 
	DIC_ReceptionDays.receptionDayName, esqoh.FromHour, esqoh.ToHour, xdes.serviceCode as ServiceID
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTableFinalSelect ON xdes.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID
	AND xdes.serviceCode = #tempTableFinalSelect.ServiceID
LEFT JOIN EmployeeServiceQueueOrderHours esqoh ON esqom.EmployeeServiceQueueOrderMethodID = esqoh.EmployeeServiceQueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON esqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode

UNION

-- QueueOrderMethods (via Employee)
SELECT eqom.QueueOrderMethod, #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, 
	DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
	,xdes.serviceCode as ServiceID
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempTableFinalSelect ON eqom.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID 
LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
-- exclude when queue order for service exists
JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
	AND xdes.serviceCode = #tempTableFinalSelect.ServiceID	
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 
WHERE esqom.QueueOrderMethod is null
AND xdes.QueueOrder IS NULL

-- DeptPhones (new via employees services)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID
	,dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTableFinalSelect ON xdes.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID 
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTableFinalSelect.deptCode = DeptPhones.deptCode
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 --OPTION (FORCE order)

UNION

-- DeptPhones (old via Employee)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTableFinalSelect  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTableFinalSelect.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTableFinalSelect.deptCode = DeptPhones.deptCode

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	AND  esqom.QueueOrderMethod = 1
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 
AND ShowPhonePicture = 1 AND esqom.x_dept_employee_serviceID is null
OPTION (FORCE order)

-- SpecialPhones (new via employees services)
SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
FROM #tempTableFinalSelect
JOIN x_Dept_Employee xde ON #tempTableFinalSelect.deptCode = xde.deptCode
	AND #tempTableFinalSelect.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

UNION

-- SpecialPhones (old via Employee)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTableFinalSelect  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTableFinalSelect.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
	AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
WHERE esqom.x_dept_employee_serviceID is null

-- For values to be passed as parameters for page by page searches
IF (@ServiceCodes is null)
	BEGIN
		 SELECT deptCode FROM #tempTableAllRows ORDER BY RowNumber
	END
ELSE
	BEGIN
		SELECT ServiceID, DeptEmployeeID, ServiceOrEvent FROM #tempTableAllRows ORDER BY RowNumber
	END

