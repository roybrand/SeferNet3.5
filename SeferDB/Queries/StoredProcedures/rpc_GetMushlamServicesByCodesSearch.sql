IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetMushlamServicesByCodesSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_GetMushlamServicesByCodesSearch]
GO

CREATE Procedure [dbo].[rpc_GetMushlamServicesByCodesSearch]
(
	@serviceCodes VARCHAR(100),
    @deptName VARCHAR(100),
    @cityCode INT,
    @districtCodes VARCHAR(100),
    @openAtHour VARCHAR(10),    
    @openFromHour VARCHAR(10),
    @openToHour VARCHAR(10),
    @receptionDays VARCHAR(30)
)

AS

DECLARE @str VARCHAR(max)

SELECT * INTO #tempServices
FROM
(
	SELECT distinct ser.ServiceCode,
	MushlamServiceName + ' - ' + mtt.Description as MushlamServiceName,
	msi.PrivateRemark, msi.AgreementRemark,
	mtt.Description as TreatmentDescription
	,msi.GroupCode
	,msi.SubGroupCode
	,msi.ServiceCode as originalServiceCode
	FROM [Services] ser 
	INNER JOIN MushlamTreatmentTypesToSefer mtt ON ser.ServiceCode = mtt.SeferCode
	INNER JOIN MushlamServicesInformation msi ON mtt.ParentServiceID = msi.ServiceCode
	WHERE IsInMushlam = 1
	AND ser.ServiceCode IN
	(
		SELECT IntField
		FROM dbo.SplitString(@serviceCodes)
	)


	UNION

	SELECT distinct ser.ServiceCode,
	case when MushlamServiceName = ser.ServiceDescription then MushlamServiceName
			else MushlamServiceName + ' - ' + ser.ServiceDescription end 
	as MushlamServiceName, 
	msi.PrivateRemark, msi.AgreementRemark,
	'' as TreatmentDescription
	,msi.GroupCode
	,msi.SubGroupCode
	,msi.ServiceCode as originalServiceCode
	FROM [Services] ser 
	INNER JOIN MushlamServicesToSefer mss on ser.ServiceCode = mss.SeferCode
	INNER JOIN MushlamServicesInformation msi ON mss.GroupCode = msi.GroupCode and mss.SubGroupCode = msi.SubGroupCode
	WHERE IsInMushlam = 1
	AND ser.ServiceCode IN
	(
		SELECT IntField
		FROM dbo.SplitString(@serviceCodes)
	)

) as t



SET @str =	'SELECT t.ServiceCode, t.MushlamServiceName, t.PrivateRemark, t.AgreementRemark,
		t.TreatmentDescription ,t.GroupCode	,t.SubGroupCode, t.originalServiceCode, 
		(select COUNT(*)
			from x_dept_employee_service xdes  
			LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
			LEFT JOIN Dept d ON xd.DeptCode = d.DeptCode 
			' 


IF (@openAtHour <> '') OR (@openFromHour <> '') OR (@openToHour <> '') OR (@receptionDays <> '')
	SET @str = @str + 
			'LEFT JOIN DeptEmployeeReception der ON xdes.DeptEmployeeID = der.DeptEmployeeID 
			LEFT JOIN DeptEmployeeReceptionServices ders ON der.ReceptionID = ders.ReceptionID AND xdes.ServiceCode = ders.ServiceCode 
			' 
			

SET @str = @str + 'WHERE t.ServiceCode = xdes.ServiceCode
			'


IF @deptName <> '' 
SET @str = @str +  ' AND d.DeptName LIKE ' + CHAR(39) + '%' + CHAR(39) + ' + ''' + @deptName + ''' + ' + CHAR(39) + '%' + CHAR(39)


IF @cityCode IS NOT NULL 
SET @str = @str +  ' AND d.CityCode = ' + CONVERT(VARCHAR,@cityCode)

IF @districtCodes <> ''
SET @str = @str +  ' AND d.districtCode IN (Select IntField from dbo.SplitString(' + @districtCodes + ')) '


IF @openAtHour <> ''
BEGIN
	DECLARE @openAtHour_real REAL
	SET @openAtHour_real = CAST (LEFT(@openAtHour,2) as real) + CAST (RIGHT(@openAtHour,2) as real)/60 
	SET @str = @str + ' 
				AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) + '
				AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) 
END


IF (@openFromHour <> '') AND (@openToHour <> '')
BEGIN
	DECLARE @openFromHour_real REAL
	DECLARE @openToHour_real REAL
	SET @openFromHour_real = CAST (LEFT(@openFromHour,2) as real) + CAST (RIGHT(@openFromHour,2) as real)/60 
	SET @openToHour_real = CAST (LEFT(@openToHour,2) as real) + CAST (RIGHT(@openToHour,2) as real)/60 
	SET @str = @str +  ' AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openFromHour_real) + CHAR(39)
					+  ' AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openToHour_real) + CHAR(39)
END

IF @receptionDays <> ''
	SET @str = @str + ' AND der.ReceptionDay IN (SELECT IntField FROM dbo.SplitString(' + @receptionDays + '))'



SET @str = @str  + ' AND xd.AgreementType IN (3,4)
					and xd.active = 1 and d.status = 1 and xdes.Status = 1
					and ((t.originalServiceCode = 180300 and d.typeUnitCode = 112
							and exists (select * from x_dept_employee_service xdes2 
								where xdes2.DeptEmployeeID = xd.DeptEmployeeID
								and xdes2.serviceCode = t.ServiceCode)
							and exists (select * from x_dept_employee_service xdes2 
										where xdes2.DeptEmployeeID = xd.DeptEmployeeID
										and xdes2.serviceCode = 180300))
					or (t.originalServiceCode <> 180300 and (d.typeUnitCode <> 112 or xd.employeeID = 1000000019)))
					) as NumOfSuppliers 
			FROM #tempServices t
			ORDER BY t.treatmentDescription, t.MushlamServiceName'


exec rpc_HelperLongPrint @str

EXEC(@str)
		        

GO

GRANT EXEC ON rpc_GetMushlamServicesByCodesSearch TO PUBLIC
GO   