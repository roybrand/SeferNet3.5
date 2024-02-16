IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetMushlamServiceExtendedSearch]') AND type in (N'P', N'PC'))
    BEGIN
	    DROP  Procedure  rpc_GetMushlamServiceExtendedSearch
    END

GO

CREATE Procedure dbo.rpc_GetMushlamServiceExtendedSearch
(
	@searchText VARCHAR(100),
    @deptName VARCHAR(100),
    @cityCode INT,
    @districtCodes VARCHAR(100),
    @openAtHour VARCHAR(10),    
    @openFromHour VARCHAR(10),
    @openToHour VARCHAR(10),
    @receptionDays VARCHAR(30),
    @deptCode int 
)

AS

DECLARE @str VARCHAR(MAX)


-- services
SELECT * INTO #tempServices
FROM
(
	SELECT distinct ser.ServiceCode, msi.ServiceCode as ParentCode,
	case when MushlamServiceName = ser.ServiceDescription then MushlamServiceName
			else MushlamServiceName + ' - ' + ser.ServiceDescription end 
	as MushlamServiceName, 
	msi.PrivateRemark, msi.AgreementRemark,
	msi.GroupCode,
	msi.SubGroupCode,
	msi.ClalitRefund,
	msi.SelfParticipation,
	msi.RequiredDocuments
	,msi.ServiceCode as originalServiceCode
	FROM [Services] ser
	INNER JOIN MushlamServicesToSefer msts  ON ser.ServiceCode = msts.SeferCode
	INNER JOIN MushlamServicesInformation msi ON msts.GroupCode = msi.GroupCode AND msts.SubGroupCode = msi.SubGroupCode
	WHERE IsInMushlam = 1
	AND (ServiceDescription LIKE '%' + @searchText + '%' 
		 OR ShowExpert LIKE '%' + @searchText + '%'
		 OR GeneralRemark LIKE '%' + @searchText + '%'
		 OR MushlamServiceName LIKE '%' + @searchText + '%')


	UNION

	-- synonyms
	SELECT msi.ServiceCode, msi.ServiceCode as parentCode,
	msi.MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark,
	msi.GroupCode,
	msi.SubGroupCode,
	msi.ClalitRefund,
	msi.SelfParticipation,
	msi.RequiredDocuments
	,msi.ServiceCode as originalServiceCode
	FROM MushlamServiceSynonyms syn
	INNER JOIN MushlamServicesInformation msi ON syn.GroupCode = msi.GroupCode AND syn.SubGroupCode = msi.SubGroupCode
	WHERE syn.ServiceSynonym like '%' + @searchText + '%'
	and not exists (select ser.ServiceCode FROM [Services] ser
					INNER JOIN MushlamServicesToSefer msts  ON ser.ServiceCode = msts.SeferCode
					INNER JOIN MushlamServicesInformation msi ON msts.GroupCode = msi.GroupCode AND msts.SubGroupCode = msi.SubGroupCode
					WHERE IsInMushlam = 1
					AND (ServiceDescription LIKE '%' + @searchText + '%' 
						 OR ShowExpert LIKE '%' + @searchText + '%'
						 OR GeneralRemark LIKE '%' + @searchText + '%'
						 OR MushlamServiceName LIKE '%' + @searchText + '%'))


	UNION

	-- treatment types
	SELECT treat.SeferCode as serviceCode,
	treat.ParentServiceID as ParentCode,
	msi.MushlamServiceName + ' - ' + treat.Description as MushlamServiceName,
	msi.PrivateRemark, msi.AgreementRemark,
	msi.GroupCode,
	msi.SubGroupCode,
	msi.ClalitRefund,
	msi.SelfParticipation,
	msi.RequiredDocuments
	,msi.ServiceCode as originalServiceCode
	FROM MushlamTreatmentTypesToSefer treat
	INNER JOIN MushlamServicesInformation msi ON  Treat.ParentServiceID = msi.ServiceCode 
	WHERE Treat.Description like '%' + @searchText + '%'   

) as x



SET @str =	'SELECT t.serviceCode,	t.ParentCode, t.MushlamServiceName, t.PrivateRemark, t.AgreementRemark,
					t.GroupCode, t.SubGroupCode, t.ClalitRefund, t.SelfParticipation, t.RequiredDocuments,
					(select COUNT(' + CASE WHEN @openAtHour <> '' OR  @openFromHour <> '' OR @openToHour <> '' OR @receptionDays <> '' 
											THEN 'der.DeptEmployeeID'
										ELSE 
											CASE WHEN @cityCode <> '' OR @districtCodes <> '' OR @deptName <> '' OR @deptCode IS NOT NULL
													THEN 'd.DeptCode'
												 ELSE '*'
											END
										END + ') 			
					FROM x_dept_employee_service xdes 		
					LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
					LEFT JOIN Dept d ON xd.DeptCode = d.DeptCode ' 


IF @deptName <> ''
SET @str = @str +  ' AND d.DeptName LIKE ' + CHAR(39) + '%' + CHAR(39) + ' + ''' + @deptName + ''' + ' + CHAR(39) + '%' + CHAR(39)


IF @cityCode <> ''
SET @str = @str +  ' AND d.CityCode = ' + CONVERT(VARCHAR,@cityCode)


IF @districtCodes <> ''
SET @str = @str +  ' AND d.districtCode IN (Select IntField from dbo.SplitString(' + @districtCodes + ')) '

if @deptCode is not null
SET @str = @str +  ' AND d.deptCode = ' + CONVERT(VARCHAR,@deptCode)


IF (@openAtHour <> '') OR (@openFromHour <> '') OR (@openToHour <> '') OR (@receptionDays <> '')
BEGIN
	SET @str = @str + 
			' LEFT JOIN 
			( SELECT der.DeptEmployeeID 
			  FROM DeptEmployeeReception der 
			  WHERE (1=1) ' 


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


	SET @str = @str + ' GROUP BY der.DeptEmployeeID) as der ON xdes.DeptEmployeeID = der.DeptEmployeeID ' 
END


			  
			

SET @str = @str + ' 
					WHERE t.ServiceCode = xdes.ServiceCode 
					AND xd.AgreementType IN (3,4)
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
				'

SET @str = @str  + ' 
					FROM #tempServices t
					ORDER BY t.MushlamServiceName'

--exec rpc_HelperLongPrint @str

EXEC (@str) 
                
GO


GRANT EXEC ON rpc_GetMushlamServiceExtendedSearch TO PUBLIC

GO            
