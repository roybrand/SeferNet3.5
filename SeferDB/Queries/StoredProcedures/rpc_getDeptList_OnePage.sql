IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptList_OnePage')
	BEGIN
		DROP  Procedure  rpc_getDeptList_OnePage
	END
GO

CREATE Procedure [dbo].[rpc_getDeptList_OnePage]
	(
	@CodesListForPage_1 varchar(max)=null,
	@CodesListForPage_2 varchar(max)=null,
	@CodesListForPage_3 varchar(max)=null,
		
	@ServiceCodes varchar(max) = null,

	@ReceptionDays varchar(max)=null,
	@OpenAtHour varchar(5)=null,
	@OpenFromHour varchar(5)=null,
	@OpenToHour varchar(5)=null,
	@OpenNow bit,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit,

	@ReceiveGuests bit,
	
	@CoordinateX float=null,
	@CoordinateY float=null,

	@ClalitServiceCode varchar(max), 

	@ServiceCodeForMuslam varchar(max) = null
	)

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql1 nvarchar(max)
DECLARE @Sql2 nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

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
DECLARE @OpenAtThisHour real

IF(@OpenNow = 1)
	BEGIN
		SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
		IF(@ReceptionDays is NULL)
			SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
		ELSE
			IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
			SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))
	END

DECLARE @ServiceCodesList [tbl_UniqueIntArray]   
IF @ServiceCodes is NOT null
	INSERT INTO @ServiceCodesList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ServiceCodes)

DECLARE @ReceptionDaysList [tbl_UniqueIntArray] 
IF @ReceptionDays is NOT null
	INSERT INTO @ReceptionDaysList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ReceptionDays) 
	
SET @Declarations =
'	
	DECLARE @DateNow date = GETDATE()
	DECLARE @xOpenAtHour_time time
	DECLARE @xOpenFromHour_time time
	DECLARE @xOpenToHour_time time
	DECLARE @xOpenAtThisHour_time time
	
	IF @xOpenFromHour IS NOT NULL
		SET @xOpenFromHour_time = CAST(@xOpenFromHour as time) 
		
	IF @xOpenToHour IS NOT NULL
		SET @xOpenToHour_time = CAST(@xOpenToHour as time)
		
	IF @xOpenAtHour IS NOT NULL
		SET @xOpenAtHour_time = CAST(@xOpenAtHour as time) 
		
'
IF(@OpenNow = 1)
	SET @Declarations = @Declarations + 
	'SET @xOpenAtThisHour_time = CAST((CAST(DATEPART(HOUR, GETDATE()) as varchar(2)) + '':'' + CAST(DATEPART(MINUTE, GETDATE()) as varchar(2))) as time)
	'
SET @Declarations = @Declarations +
'		
	IF (@xCoordinateX = -1)
	BEGIN
		SET @xCoordinateX = null
		SET @xCoordinateY = null
	END
	
	'
IF(@ServiceCodes is null)
-- @CodesListForPage_1 are deptCodes
-- @CodesListForPage_2 && @CodesListForPage_2 not relevand
	BEGIN	
		SET @Declarations = @Declarations +
	-- DeptCodes' list
		'SELECT ItemID as DeptCode, ROW_NUMBER() OVER(ORDER BY rowNum ) as RowNumber 
		INTO #CodesList_Table
		FROM
		(   
			SELECT ItemID, 1 as rowNum  FROM [dbo].[rfn_SplitStringValues](@xCodesListForPage_1 )
		) T
		'

	END
ELSE
	BEGIN
		SET @Declarations = @Declarations +
	-- ServiceID/DeptEventID's list
		'SELECT ItemID as KeyValue, ROW_NUMBER() OVER(ORDER BY rowNum ) as RowNumber 
		INTO #CodesList1_Table
		FROM
		(   
			SELECT ItemID, 1 as rowNum  FROM [dbo].[rfn_SplitStringValues](@xCodesListForPage_1 )
		) T
		' +
	-- DeptEmployeeID's list
		'			
		SELECT ItemID as KeyValue, ROW_NUMBER() OVER(ORDER BY rowNum ) as RowNumber 
		INTO #CodesList2_Table
		FROM
		(   
			SELECT ItemID, 1 as rowNum  FROM [dbo].[rfn_SplitStringValues](@xCodesListForPage_2 )
		) T
		' +
	-- ServiceOrEvent's list		
		'
		SELECT ItemID as KeyValue, ROW_NUMBER() OVER(ORDER BY rowNum ) as RowNumber 
		INTO #CodesList3_Table
		FROM
		(   
			SELECT ItemID, 1 as rowNum  FROM [dbo].[rfn_SplitStringValues](@xCodesListForPage_3 )
		) T				
		' +
		'
		SELECT #CodesList1_Table.KeyValue as ServiceID
		, #CodesList2_Table.KeyValue as DeptEmployeeID
		, #CodesList3_Table.KeyValue as ServiceOrEvent		
		,#CodesList1_Table.RowNumber 
		
		INTO #CodesList_Table
		FROM #CodesList1_Table			
		JOIN #CodesList2_Table ON #CodesList1_Table.RowNumber = #CodesList2_Table.RowNumber
		JOIN #CodesList3_Table ON #CodesList1_Table.RowNumber = #CodesList3_Table.RowNumber		
		'
		
	END	
	
SET @params = 
'	@xCodesListForPage_1 varchar(max)=null,
	@xCodesListForPage_2 varchar(max)=null,
	@xCodesListForPage_3 varchar(max)=null,

	@xServiceCodes varchar(max) = null,
	@xServiceCodesList [tbl_UniqueIntArray] READONLY,

	@xReceptionDaysList [tbl_UniqueIntArray] READONLY,
	@xOpenAtHour varchar(5)=null,
	@xOpenFromHour varchar(5)=null,
	@xOpenToHour varchar(5)=null,
	@xIsCommunity bit,
	@xIsMushlam bit,
	@xIsHospital bit,

	@xAgreementTypeList [tbl_UniqueIntArray] READONLY,
	
	@xCoordinateX float=null,
	@xCoordinateY float=null,

	@xClalitServiceCode varchar(max), 

	@xServiceCodeForMuslam varchar(max)=null
'

SET @Sql1 = 
' 
	
SELECT * INTO #tempTableFinalSelect FROM '

-- middle selection - "dept itself" + RowNumber

SET @Sql1 = @Sql1 + '(SELECT *
'

SET @Sql1 = @Sql1 +				
' FROM ' +
-- inner selection - "dept itself"
'(
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
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
	)
		+
  CASE 
	(select COUNT(*) from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
	WHERE v_DE_ER.deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	)WHEN 0 THEN 0 ELSE 1 END		
as countDeptRemarks,
	(select count(receptionID) 
	from DeptReception_Regular
	where deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	)
as 	countReception,
Simul228,
	(x_dept_XY.xcoord - @xCoordinateX)*(x_dept_XY.xcoord - @xCoordinateX) + (x_dept_XY.ycoord - @xCoordinateY)*(x_dept_XY.ycoord - @xCoordinateY)
as distance,
dept.status,
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord,
'

IF(@ServiceCodes is null)
BEGIN
	SET @Sql1 = @Sql1 + 
	 CHAR(39)+CHAR(39)+ ' as ServiceDescription, ' +
	 CHAR(39)+CHAR(39)+ ' as ServiceID,
0 as IsMedicalTeam, ' +
	 CHAR(39)+CHAR(39)+ ' as doctorName, ' +
	 CHAR(39)+CHAR(39)+ ' as employeeID,  
0 as ShowHoursPicture, 
0 as ShowRemarkPicture, ' +
	 CHAR(39)+CHAR(39)+ ' as ServicePhones, 
1 as serviceStatus,
1 as employeeStatus, 
0 as AgreementType, 
0 as ReceiveGuests,
'''' as QueueOrderDescription,
0 as DeptEmployeeID,
'
	 
END
ELSE
BEGIN
	SET @Sql1 = @Sql1 + 
'CASE	WHEN @xIsHospital = 1 AND Employee.IsMedicalTeam = 1 AND xDE.AgreementType = 5 
		THEN dbo.fun_GetMedicalAspectsForService(T_services.ServiceCode, xDE.DeptEmployeeID)
		ELSE T_services.ServiceDescription  
		END as ServiceDescription,
T_services.ServiceCode as ServiceID, 
Employee.IsMedicalTeam as IsMedicalTeam, 
DegreeName + space(1) + Employee.lastName + space(1) + Employee.firstName as doctorName, 
Employee.employeeID as employeeID, 
  CASE WHEN isNull(T_services.ReceptionCount, 0) = 0 then 0 else 1 end
as ShowHoursPicture, 
  CASE
	(select COUNT(*) from DeptEmployeeServiceRemarks DESR
		where T_services.x_dept_employee_serviceID = DESR.x_dept_employee_serviceID
		AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
		)WHEN 0 THEN 0 ELSE 1 END 
		+
  CASE 
	(select COUNT(*) from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
	WHERE v_DE_ER.DeptEmployeeID = xde.DeptEmployeeID
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	)WHEN 0 THEN 0 ELSE 1 END
		+
  CASE 
	(SELECT COUNT(*) 
	from View_DeptRemarks
	JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
	WHERE deptCode = xde.deptCode
	--AND GR.RemarkCategoryID = 4
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	)WHEN 0 THEN 0 ELSE 1 END	
as ShowRemarkPicture,
  stuff((SELECT ' + CHAR(39) + ',' + CHAR(39) + ' + convert(varchar(10), x.phone)
		FROM (select dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) as phone
			FROM x_Dept_Employee_Service join EmployeeServicePhones
			on EmployeeServicePhones.x_Dept_Employee_ServiceID = x_Dept_Employee_Service.x_Dept_Employee_ServiceID
			join x_Dept_Employee on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			where x_Dept_Employee_Service.serviceCode = T_services.serviceCode
			and x_Dept_Employee.DeptEmployeeID = xDE.DeptEmployeeID
			and x_Dept_Employee.AgreementType in (select * from @xAgreementTypeList)
		) x
		for xml path('+ CHAR(39) + CHAR(39) +')
	),1,1,'+ CHAR(39) + CHAR(39) +')
as ServicePhones,
T_services.status as serviceStatus,
xDE.active as employeeStatus,
xDE.agreementType,
CASE WHEN T_services.ServiceCode is null THEN 0 
	ELSE 
		emp_pr.ReceiveGuests
	END as ReceiveGuests,
CASE WHEN ServiceQueueOrderDescription is not null THEN ServiceQueueOrderDescription ELSE emp_pr.QueueOrderDescription END as QueueOrderDescription, 
xDE.DeptEmployeeID,
' 	
		 
END	

SET @Sql1 = @Sql1 + 
	' 1 as ServiceOrEvent /* 1 for service, 0 for event */

	,#CodesList_Table.RowNumber
	'
	
SET @Sql1 = @Sql1 + 
'FROM dept
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
	AND DeptPhones.phoneType = 1 AND phoneOrder = 1
LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode
'

IF(@ServiceCodes is NOT null OR @ServiceCodeForMuslam is NOT null)
BEGIN
	SET @Sql1 = @Sql1 +	
	'INNER JOIN x_dept_employee xDE on Dept.deptCode = xDE.deptCode '
--		
	SET @Sql1 = @Sql1 +		
	'INNER JOIN EmployeeInClinic_preselected emp_pr on xDE.deptCode = emp_pr.deptCode
	AND xDE.employeeID = emp_pr.employeeID AND xDE.AgreementType = emp_pr.AgreementType
	'
	
	IF(@ReceiveGuests = 1 AND (@OpenAtHour is null AND @OpenFromHour is null AND @OpenToHour is null AND @OpenNow <> 1)) 
		SET @Sql1 = @Sql1 +	
		' AND (emp_pr.ReceiveGuests = 1 OR emp_pr.ReceiveGuests = 2) '		
--
	SET @Sql1 = @Sql1 +	
	'INNER JOIN Employee on Employee.employeeID = xDE.employeeID
	LEFT JOIN DIC_EmployeeDegree on DIC_EmployeeDegree.DegreeCode = Employee.degreeCode 
 
	INNER JOIN  
	(		SELECT 
			xDE2.DeptEmployeeID,
			0 as x_dept_employee_serviceID,
			1 as status, 
			null as ServiceQueueOrderDescription,
			'
			IF(@ServiceCodeForMuslam is NOT null)
				SET @Sql1 = @Sql1 +	
				' @xServiceCodeForMuslam as ServiceCode, '
			ELSE
				SET @Sql1 = @Sql1 +	
				' (select TOP 1 IntVal from @xServiceCodesList) as ServiceCode, '
	SET @Sql1 = @Sql1 +					
			'
			'' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: '' + [dbo].[fun_GetEmployeeMushlamInDeptServices](xDE2.EmployeeID,xDE2.deptCode,1) as ServiceDescription,
			(	SELECT COUNT(*) FROM x_Dept_Employee_Service
				JOIN deptEmployeeReception_Regular ON x_Dept_Employee_Service.DeptEmployeeID = deptEmployeeReception_Regular.DeptEmployeeID
						AND CAST(@DateNow as date) between ISNULL(validFrom,''1900-01-01'') and ISNULL(validTo,''2079-01-01'')
				WHERE x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID
				AND x_Dept_Employee_Service.serviceCode = 180300)	as ReceptionCount		

			FROM x_dept_employee xDE2

			WHERE EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	) '
			IF(@ServiceCodeForMuslam is NOT null)
				SET @Sql1 = @Sql1 +	
				' AND  EXISTS (	SELECT * FROM x_Dept_Employee_Service
								WHERE x_Dept_Employee_Service.serviceCode = @xServiceCodeForMuslam
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	) 
				'
			ELSE
				SET @Sql1 = @Sql1 +	
				' AND EXISTS (	SELECT * FROM x_Dept_Employee_Service 
								WHERE x_Dept_Employee_Service.serviceCode in (SELECT IntVal FROM @xServiceCodesList )
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID )
				'

	SET @Sql1 = @Sql1 +	
			'UNION

			SELECT 
			xDE2.DeptEmployeeID,
			xDES.x_dept_employee_serviceID,
			xDES.status,
			DIC_QueueOrder.QueueOrderDescription as ServiceQueueOrderDescription, 
			[Services].ServiceCode,
			[Services].ServiceDescription as ServiceDescription,
			[View_DeptEmployeeReceptionCount].ReceptionCount
			FROM x_dept_employee xDE2
			INNER JOIN x_Dept_Employee_Service xDES on xDE2.DeptEmployeeID = xDES.DeptEmployeeID
			LEFT JOIN DIC_QueueOrder on xDES.QueueOrder = DIC_QueueOrder.QueueOrder
			INNER JOIN [Services] on [Services].ServiceCode = xDES.serviceCode
			LEFT JOIN [View_DeptEmployeeReceptionCount] on [View_DeptEmployeeReceptionCount].DeptEmployeeID = xDE2.DeptEmployeeID
				and [View_DeptEmployeeReceptionCount].serviceCode = xDES.serviceCode
				and xDE2.AgreementType in (select * from @xAgreementTypeList)
			WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	)
	)	as T_services 
		ON 	T_services.DeptEmployeeID = xDE.DeptEmployeeID	
	'
END

IF(@ServiceCodeForMuslam is NOT null)
	SET @Sql1 = @Sql1 +	
' INNER JOIN vMushlamCervices ON T_services.ServiceCode = vMushlamCervices.ServiceCode
'

IF(@ServiceCodes is NOT null OR @ServiceCodeForMuslam is NOT null)
BEGIN
	SET @Sql1 = @Sql1 +	
	'
	INNER JOIN #CodesList_Table 
		ON T_services.ServiceCode = #CodesList_Table.ServiceID
		AND T_services.deptEmployeeID = #CodesList_Table.deptEmployeeID
		AND #CodesList_Table.ServiceOrEvent = 1
	'
END
ELSE
BEGIN
	SET @Sql1 = @Sql1 +	
	'INNER JOIN #CodesList_Table ON dept.deptCode = #CodesList_Table.deptCode
	'
END

/*********** EVENTS ***********/
SET @Sql2 = ''

IF(	@ServiceCodes IS NOT NULL )
BEGIN
	SET @Sql2 =

	' UNION


	SELECT
	dept.deptCode,
	dept.deptName,
	dept.deptType,
	dept.deptLevel,
	dept.displayPriority,
	dept.ShowUnitInInternet,
	DIC_DeptTypes.deptTypeDescription,
	dept.typeUnitCode,
		CASE IsNull(dept.subUnitTypeCode, -1) 
						WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
						ELSE dept.subUnitTypeCode END
	as subUnitTypeCode,
	SubstituteName = ' +CHAR(39)+CHAR(39)+ ',
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
		AND @DateNow between ISNULL(validFrom,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(validTo,'+CHAR(39)+'2079-01-01'+CHAR(39)+')
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
		)
	as countDeptRemarks,
		(select count(receptionID) 
		from DeptReception_Regular
		where deptCode = dept.deptCode
		AND (@DateNow between ISNULL(validFrom,''1900-01-01'') and ISNULL(validTo,''2079-01-01'')))
	as countReception,
	Simul228 = null,
		(xcoord - @xCoordinateX)*(xcoord - @xCoordinateX) + (ycoord - @xCoordinateY)*(ycoord - @xCoordinateY)
	as distance,
	dept.status,
	dbo.x_dept_XY.xcoord,
	dbo.x_dept_XY.ycoord,					
		DIC_Events.EventName
	as ServiceDescription,
		DeptEvent.DeptEventID
	as ServiceID,'
	+CHAR(39)+CHAR(39)+' as IsMedicalTeam, '
	+CHAR(39)+CHAR(39)+' as doctorName, 
	0000 as employeeID,
	1 as ShowHoursPicture,
	0 as ShowRemarkPicture, '
	+CHAR(39)+CHAR(39)+' as ServicePhones,
	1 as serviceStatus,
	1 as employeeStatus,
	0 as AgreementType,
	0 as ReceiveGuests,
	'''' as QueueOrderDescription,
	0 as DeptEmployeeID,
	0 as ServiceOrEvent -- 1 for service, 0 for event
	
	,#CodesList_Table.RowNumber
	' 
	
SET @Sql2 = @Sql2 + 

	'FROM DeptEvent
	INNER JOIN dept ON DeptEvent.deptCode = dept.deptCode
	INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
	INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
	INNER JOIN Cities on dept.cityCode = Cities.cityCode
	LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
		AND DeptPhones.phoneType = 1 AND phoneOrder = 1	INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
	LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode 

	--INNER JOIN #OrderTable ON dept.deptCode = #OrderTable.KeyValue
'
IF(@ServiceCodes is NOT null OR @ServiceCodeForMuslam is NOT null)
BEGIN
	SET @Sql2 = @Sql2 +	
	'
	INNER JOIN #CodesList_Table 
		ON DeptEvent.DeptEventID = #CodesList_Table.ServiceID
		AND #CodesList_Table.ServiceOrEvent = 0
	'
END
ELSE
BEGIN
	SET @Sql2 = @Sql2 +	
	'INNER JOIN #CodesList_Table ON dept.deptCode = #CodesList_Table.deptCode
	'
END

		  
END
--------------------------------------------
SET @SqlEnd =

'
) as innerDeptSelection
) as middleSelection
ORDER BY RowNumber

--print ''before SELECT * FROM #tempTableFinalSelect''

SELECT * FROM #tempTableFinalSelect

-- select with same joins and conditions as above
-- just to get count of all the records in select

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
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 OPTION (FORCE order)
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
--

DROP TABLE #tempTableFinalSelect
'
------------------------------------------------------------------------

SET @Sql1 = @Declarations + @Sql1 + @Sql2 + @SqlEnd

--Exec rpc_HelperLongPrint @Sql1 

exec sp_executesql @Sql1, @params,
	@xCodesListForPage_1 = @CodesListForPage_1,
	@xCodesListForPage_2 = @CodesListForPage_2,	
	@xCodesListForPage_3 = @CodesListForPage_3,
	
	@xServiceCodes = @ServiceCodes,
	@xServiceCodesList = @ServiceCodesList,

	@xReceptionDaysList = @ReceptionDaysList,
	@xOpenAtHour = @OpenAtHour,
	@xOpenFromHour = @OpenFromHour,
	@xOpenToHour = @OpenToHour,
	@xIsCommunity = @IsCommunity,
	@xIsMushlam = @IsMushlam,
	@xIsHospital = @IsHospital,

	@xAgreementTypeList = @AgreementTypeList,
	
	@xCoordinateX = @CoordinateX,
	@xCoordinateY = @CoordinateY,
	
	@xClalitServiceCode = @ClalitServiceCode, 

	@xServiceCodeForMuslam = @ServiceCodeForMuslam

GO

GRANT EXEC ON dbo.rpc_getDeptList_OnePage TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getDeptList_OnePage TO [clalit\IntranetDev]
GO
