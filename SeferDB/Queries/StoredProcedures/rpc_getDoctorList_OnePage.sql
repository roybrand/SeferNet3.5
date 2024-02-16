IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorList_OnePage')
	BEGIN
		DROP  Procedure  rpc_getDoctorList_OnePage
	END
GO

CREATE Procedure [dbo].[rpc_getDoctorList_OnePage]
(
@CodesListForPage varchar(max) = null,
@IsOrderDescending int = null,
@isGetEmployeesReceptionHours bit = null

)

AS

DECLARE @DateNow date = GETDATE()

SELECT ItemID as selected_ID, ROW_NUMBER() OVER(ORDER BY rowNum ) as RowNumber 
INTO #IDsList_Table
FROM
(   
	SELECT ItemID, 1 as rowNum  FROM [dbo].[rfn_SplitStringValues](@CodesListForPage )
) T

CREATE TABLE #tempTableAllRows
(
	RowNumber int,
	ID bigint NOT NULL,
	employeeID bigint NOT NULL,
	EmployeeName varchar(100) NULL,	
	lastName varchar(50) NULL,
	firstName varchar(50) NULL,
	deptName varchar(100) NULL,
	deptCode int NULL,
	DeptEmployeeID bigint NULL,
	QueueOrderDescription varchar(50) NULL,
	[address] varchar(500) NULL,
	cityName varchar(50) NULL,
	phone varchar(50) NULL,
	fax varchar(50) NULL,
	HasReception bit NULL,
	expert varchar(500) NULL,		
	HasRemarks bit NULL,
	professions varchar(500) NULL,
	[services] varchar(500) NULL,
	positions varchar(500) NULL,
	AgreementType tinyint NULL,
	AgreementTypeDescription varchar(50) NULL,
	EmployeeLanguage varchar(100) NULL,
	EmployeeLanguageDescription varchar(500) NULL,
	hasMapCoordinates tinyint NULL,
	EmployeeStatus tinyint NULL,
	EmployeeStatusInDept tinyint NULL,
	IsMedicalTeam bit NULL,
	IsVirtualDoctor bit NULL,
	ReceiveGuests int NULL,
	xcoord float NULL,
	ycoord float NULL,
)
-- *************************

INSERT INTO #tempTableAllRows SELECT * FROM
	( 

SELECT DISTINCT 
#IDsList_Table.RowNumber,
EmployeeInClinic_preselected.ID,
EmployeeInClinic_preselected.employeeID,
EmployeeInClinic_preselected.EmployeeName,
EmployeeInClinic_preselected.lastname,
EmployeeInClinic_preselected.firstName,
EmployeeInClinic_preselected.deptName,
EmployeeInClinic_preselected.deptCode,
EmployeeInClinic_preselected.DeptEmployeeID,
EmployeeInClinic_preselected.QueueOrderDescription,
EmployeeInClinic_preselected.address,
EmployeeInClinic_preselected.cityName,
EmployeeInClinic_preselected.phone,
EmployeeInClinic_preselected.fax,
EmployeeInClinic_preselected.HasReception,
'expert' = EmployeeInClinic_preselected.ExpProfession,
EmployeeInClinic_preselected.HasRemarks,
CASE WHEN @IsOrderDescending = 0 THEN EmployeeInClinic_preselected.professions_ASC
	ELSE EmployeeInClinic_preselected.professions_DESC END as 'professions',
EmployeeInClinic_preselected.[services],
EmployeeInClinic_preselected.positions,	
EmployeeInClinic_preselected.AgreementType,
EmployeeInClinic_preselected.AgreementTypeDescription,
EmployeeInClinic_preselected.EmployeeLanguage,
EmployeeInClinic_preselected.EmployeeLanguageDescription,		
EmployeeInClinic_preselected.hasMapCoordinates,
EmployeeInClinic_preselected.EmployeeStatus,
EmployeeInClinic_preselected.EmployeeStatusInDept,

EmployeeInClinic_preselected.IsMedicalTeam,
EmployeeInClinic_preselected.IsVirtualDoctor,
EmployeeInClinic_preselected.ReceiveGuests,
EmployeeInClinic_preselected.xcoord,
EmployeeInClinic_preselected.ycoord

FROM EmployeeInClinic_preselected

JOIN #IDsList_Table ON EmployeeInClinic_preselected.ID = #IDsList_Table.selected_ID

) as middleSelection

ORDER BY RowNumber

SELECT * INTO #tempTable FROM #tempTableAllRows

SELECT #tempTable.*,
		CASE WHEN EXISTS
			(SELECT * from View_DeptRemarks
			JOIN Dept d ON View_DeptRemarks.deptCode = d.deptCode
			WHERE View_DeptRemarks.deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			AND (IsSharedRemark = 0 OR d.IsCommunity = 1)
			)

			OR 
	
			EXISTS
			(SELECT * from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
			WHERE v_DE_ER.deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01')))
		THEN 1 ELSE 0 END as countDeptRemarks,
		CASE WHEN EXISTS
			(select * from DeptReception_Regular
			where deptCode = #tempTable.deptCode
			AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
			) THEN 1 ELSE 0 END
		as 	countReception
FROM #tempTable

/***** DeptPhones ************************/
SELECT *
INTO #tempTableDeptPhones
FROM(
-- DeptPhones (new via employees services)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID
	,dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID 
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 

UNION

-- DeptPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	AND  esqom.QueueOrderMethod = 1
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 
AND ShowPhonePicture = 1 AND esqom.x_dept_employee_serviceID is null
--OPTION (FORCE order)
) T

/*****  END DeptPhones ************************/

/*****  QueueOrderPhones ************************/
SELECT *
INTO #tempQueueOrderPhones
FROM(
-- SpecialPhones (new via employees services)
SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
FROM #tempTable
JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
	AND #tempTable.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	--AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

UNION

-- SpecialPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
WHERE esqom.x_dept_employee_serviceID is null
) T
/*****  END QueueOrderPhones ************************/

/********************  QueueOrderMethods *************************/
SELECT QO.*, Ph.Phone
INTO #tempTableQueueOrder
FROM(
	-- QueueOrderMethods (via employees services)
	SELECT ISNULL(esqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, esqoh.FromHour, esqoh.ToHour, xdes.serviceCode as ServiceID,
		s.ServiceDescription,
		DIC_QueueOrder.QueueOrderDescription, DIC_QueueOrder.QueueOrder,
		#tempTable.RowNumber
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_Dept_Employee xde ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID
	INNER JOIN [Services] s ON xdes.serviceCode = s.ServiceCode	
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
	LEFT JOIN dbo.DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder

	LEFT JOIN EmployeeServiceQueueOrderHours esqoh ON esqom.EmployeeServiceQueueOrderMethodID = esqoh.EmployeeServiceQueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON esqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	WHERE xdes.QueueOrder is not null
	
	UNION

	-- QueueOrderMethods (via Employee)
	SELECT ISNULL(eqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
		,xdes.serviceCode as ServiceID, s.ServiceDescription,
		ISNULL(DIC_QueueOrder.QueueOrderDescription, '') as QueueOrderDescription, ISNULL(DIC_QueueOrder.QueueOrder, 2) as QueueOrder,
		#tempTable.RowNumber		
	FROM #tempTable
	LEFT JOIN EmployeeQueueOrderMethod eqom ON eqom.DeptEmployeeID = #tempTable.DeptEmployeeID 
	LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	JOIN x_Dept_Employee xde ON #tempTable.DeptEmployeeID = xde.DeptEmployeeID
	LEFT JOIN dbo.DIC_QueueOrder ON xde.QueueOrder = DIC_QueueOrder.QueueOrder
	-- exclude when queue order for service exists
	JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
	WHERE xdes.QueueOrder is null
	
	) QO
LEFT JOIN
(	
	-- SpecialPhones (new via employees services)
	SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
	FROM #tempTable
	JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
		AND #tempTable.employeeID = xde.employeeID
	JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

	UNION

	-- SpecialPhones (old via Employee)
	SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
	FROM #tempTable  
	INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
	INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

	LEFT JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom
		ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	WHERE esqom.x_dept_employee_serviceID is null
) Ph 
	ON QO.deptCode = Ph.deptCode 
	AND QO.employeeID = Ph.employeeID
	AND QO.ServiceID = Ph.ServiceID	

----------------------------------------
SELECT DISTINCT QueueOrderMethod, ISNULL(QueueOrder, 2) as QueueOrder, deptCode, employeeID, ServiceID
INTO #tempTableMarker
FROM #tempTableQueueOrder

SELECT QueueOrderMethod, QueueOrder, deptCode, employeeID, ServiceID,
LEFT(CAST(QueueOrder as varchar(1))
		+ REPLACE(
			 stuff((SELECT ',' + CONVERT(VARCHAR,QueueOrderMethod) 
			 FROM #tempTableMarker ttM2
			 WHERE ttM2.employeeID = ttM.employeeID
			 AND  ttM2.deptCode = ttM.deptCode
			 AND  ttM2.ServiceID = ttM.ServiceID
			 order by ttM2.QueueOrderMethod
			 for xml path ('')
			 ), 1, 1, ''), ',','')
		+ '0000', 5)
		 as 'Marker'
INTO #tempTableMarkerStuff
FROM #tempTableMarker ttM

----------------------------------------
SELECT ttQO.QueueOrderMethod, ttQO.QueueOrderDescription, ttQO.QueueOrder, ttQO.deptCode, ttQO.employeeID, ttQO.receptionDayName, ttQO.FromHour, ttQO.ToHour, ttQO.ServiceID, ttQO.ServiceDescription
,ttM.Marker + LEFT( REPLACE( REPLACE(ISNULL(ttQO.Phone, '000000000'), '-', ''),'*', '')  , 9) as 'Marker'
,ttQO.RowNumber
,ttDP.Phone as DeptPhone, ttQOP.Phone as QueueOrderPhone
FROM #tempTableQueueOrder ttQO
JOIN #tempTableMarkerStuff ttM 
	ON ttQO.deptCode = ttM.deptCode AND ttQO.employeeID = ttM.employeeID
	AND ttQO.ServiceID = ttM.ServiceID AND ttQO.QueueOrderMethod = ttM.QueueOrderMethod
	AND ttQO.QueueOrder = ttM.QueueOrder

LEFT JOIN #tempTableDeptPhones ttDP
	ON ttQO.deptCode = ttDP.deptCode
	AND ttQO.employeeID = ttDP.employeeID
	AND ttQO.ServiceID = ttDP.ServiceID
	
LEFT JOIN #tempQueueOrderPhones ttQOP
	ON ttQO.deptCode = ttQOP.deptCode
	AND ttQO.employeeID = ttQOP.employeeID
	AND ttQO.ServiceID = ttQOP.ServiceID	
/******************** END  QueueOrderMethods *************************/

DROP TABLE #tempTable
DROP TABLE #tempTableQueueOrder
DROP TABLE #tempTableMarkerStuff
DROP TABLE #tempTableMarker
DROP TABLE #tempTableDeptPhones
DROP TABLE #tempQueueOrderPhones


IF(@isGetEmployeesReceptionHours = 1)
BEGIN
	SELECT v.[deptCode]
		  ,v.[receptionID]
		  ,v.[EmployeeID]
		  ,v.[receptionDay]
		  ,v.[openingHour]
		  ,v.[closingHour]
		  ,v.[ReceptionDayName]
		  ,v.[OpeningHourText]
		  ,v.[EmployeeSectorCode]
		  ,v.[ServiceDescription]
		  ,DERR.RemarkText
		  ,v.[ServiceCode]
		  ,v.[AgreementType]
	  FROM [dbo].[vEmployeeReceptionHours_Having180300service] v
	  left join deptEmployeeReception dER on v.receptionID = dER.receptionID
	  left join DeptEmployeeReceptionRemarks DERR on dER.receptionID = DERR.EmployeeReceptionID
	  inner join #tempTableAllRows tbl
	  on tbl.deptCode = v.deptCode
	  and tbl.EmployeeID = v.EmployeeID
	  and tbl.AgreementType = v.AgreementType
	  order by v.[EmployeeID],v.[deptCode],v.[ServiceDescription]


	--Remarks
	SELECT distinct
		v_DE_ER.EmployeeID,
		v_DE_ER.DeptCode,
		dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText,
		CONVERT(VARCHAR(2),DAY(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(v_DE_ER.ValidTo)) as ValidTo
	FROM View_DeptEmployee_EmployeeRemarks v_DE_ER
		inner join #tempTableAllRows tbl
		on tbl.deptCode = v_DE_ER.deptCode
		and tbl.EmployeeID = v_DE_ER.EmployeeID
		where GETDATE() between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
						and ISNULL(v_DE_ER.validTo,'2079-01-01')

	UNION

	SELECT
		xde.EmployeeID,
		xde.DeptCode,
		dbo.rfn_GetFotmatedRemark(desr.RemarkText),
		CONVERT(VARCHAR(2),DAY(desr.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(desr.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(desr.ValidTo))
	FROM DeptEmployeeServiceRemarks desr
	INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
	inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
	inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
	and tbl.EmployeeID = xde.EmployeeID
	where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
						and ISNULL(desr.validTo,'2079-01-01')

END

DROP TABLE #tempTableAllRows

GO

GRANT EXEC ON dbo.rpc_getDoctorList_OnePage TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getDoctorList_OnePage TO [clalit\IntranetDev]
GO