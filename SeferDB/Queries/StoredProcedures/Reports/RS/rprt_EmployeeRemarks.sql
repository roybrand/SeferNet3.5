IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeRemarks')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeRemarks
	END
GO

CREATE Procedure [dbo].[rprt_EmployeeRemarks]
(
	@DistrictCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@Remark_cond varchar(max)=null,
	@IsRemarkAttributedToAllClinics_cond varchar(max)=null,
	@ShowRemarkInInternet_cond varchar(max)=null,
	@IsFutureRemark_cond varchar(max)=null,
	@IsValidRemark_cond varchar(max)=null,
	@AgreementType_cond varchar(max)=null,

	@district varchar (2)= null,
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Remark varchar (2)=null,
	@RemarkAttributedToAllClinics varchar (2)=null,
	@ShowRemarkInInternet varchar (2)=null,
	@RemarkValidFrom varchar (2)=null,
	@RemarkValidTo varchar (2)=null,

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

--SET variables 
DECLARE @params nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @SqlRemSelect nvarchar(max)
DECLARE @SqlServRemSelect nvarchar(max)
DECLARE @SqlTempServRemarks nvarchar(max)

SET @Declarations = 
' DECLARE @xDateNow date = GETDATE()
'

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xEmployeeSector_cond varchar(max)=null,
	@xProfessionCodes varchar(max)=null,
	@xRemark_cond varchar(max)=null,
	@xIsRemarkAttributedToAllClinics_cond varchar(max)=null,
	@xShowRemarkInInternet_cond varchar(max)=null,
	@xIsFutureRemark_cond varchar(max)=null,
	@xAgreementType_cond varchar(max)=null
'

---------------------------
SET @SqlTempServRemarks = 'SELECT x_Dept_Employee_Service.DeptEmployeeID
		, Services.ServiceDescription + '': '' + dbo.rfn_GetFotmatedRemark(DeptEmployeeServiceRemarks.RemarkText) AS ServiceRemark
		,DeptEmployeeServiceRemarks.RemarkID, DeptEmployeeServiceRemarks.DisplayInInternet
		, DeptEmployeeServiceRemarks.ValidFrom, DeptEmployeeServiceRemarks.ValidTo
		INTO #TempServiceRemarks
		FROM x_Dept_Employee_Service
		JOIN x_Dept_Employee ON x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		JOIN Employee ON x_Dept_Employee.EmployeeID = Employee.EmployeeID
		JOIN Services ON x_Dept_Employee_Service.serviceCode = Services.ServiceCode
		JOIN DeptEmployeeServiceRemarks ON x_Dept_Employee_Service.x_Dept_Employee_ServiceID = DeptEmployeeServiceRemarks.x_dept_employee_serviceID
		WHERE x_Dept_Employee_Service.Status = 1 AND Employee.IsMedicalTeam = 0
		' 

SET @sql = 'SELECT distinct * INTO #Tmp FROM (SELECT x_Dept_Employee.deptCode as dc ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable '+ @NewLineChar;
SET @sqlWhere = '';


SET @sqlFrom = 'FROM Employee 
	JOIN Employee AS Emp ON Employee.employeeID = Emp.employeeID
	AND  Employee.Active = 1 '
IF(@DistrictCodes <> '-1')
SET @sqlFrom = @sqlFrom + @NewLineChar +
	' AND ( Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
IF(@EmployeeSector_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(@xEmployeeSector_cond )) ) '
IF(@ProfessionCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	' AND EXISTS(	SELECT * FROM EmployeeServices 
					WHERE Employee.employeeID = EmployeeServices.employeeID								
					AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xProfessionCodes )))
					 '
	
SET @sqlFrom = @sqlFrom + @NewLineChar +	
' JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
LEFT JOIN Dept AS d ON d.deptCode = x_Dept_Employee.deptCode
JOIN View_DeptEmployeesCurrentStatus AS v_DECStatus 
	ON x_Dept_Employee.deptCode = v_DECStatus.deptCode
	AND Employee.employeeID = v_DECStatus.employeeID
	AND v_DECStatus.status = 1 
	'
IF(@AgreementType_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	'AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) 
	'

IF(@EmployeeProfessions = '1' ) 		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeeProfessions AS DEProfessions 
		ON x_Dept_Employee.deptCode = DEProfessions.deptCode
		AND x_Dept_Employee.AgreementType = DEProfessions.AgreementType
		AND Employee.employeeID = DEProfessions.employeeID '
IF(@EmployeePosition = '1' ) 		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeePositions AS DEPositions 
		ON x_Dept_Employee.deptCode = DEPositions.deptCode
		AND x_Dept_Employee.AgreementType = DEPositions.AgreementType
		AND Employee.employeeID = DEPositions.employeeID '
IF(@AgreementType = '1' )		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
IF(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN dept AS dAdmin ON d.administrationCode = dAdmin.deptCode '
IF(@district = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN dept AS dDistrict ON d.districtCode = dDistrict.deptCode '
IF(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
IF(@city = '1') 
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN Cities ON d.CityCode =  Cities.CityCode '
IF(@EmployeeSector = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	' INNER JOIN View_EmployeeSector ON Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '

--==========================================
SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
SET @sql = @sql + ' x_Dept_Employee.DeptEmployeeID '

IF(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName AS DistrictName, isNull(dDistrict.deptCode, -1) AS DeptCode '+ @NewLineChar;
	end
IF(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName AS AdminClinicName, isNull(dAdmin.DeptCode, -1) AS AdminClinicCode '+ @NewLineChar;
	end 
	
-------------- Clinic----------------------------
IF( @ClinicName= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'd.DeptName AS ClinicName ' + @NewLineChar;	
	end

IF( @ClinicCode= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' d.deptCode AS ClinicCode ' + @NewLineChar;	
	end

IF(@simul = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'deptSimul.Simul228 AS Code228 '+ @NewLineChar;
	end 

IF(@city = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		SET @sql = @sql + ' Cities.CityCode AS CityCode, Cities.CityName AS CityName'+ @NewLineChar;
	end

IF (@address = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'dbo.GetAddress(d.deptCode) AS ClinicAddress '+ @NewLineChar;
	end	

------------------------------- Employee --------------------------------------------
IF(@EmployeeName = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'Employee.firstName AS EmployeeFirstName, Employee.lastName AS EmployeeLastName'+ @NewLineChar;
	end
	
IF(@EmployeeID = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeID AS EmployeeID '+ @NewLineChar;
	end

IF(@EmployeeSector = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeSectorCode AS EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription AS EmployeeSectorDescription'+ @NewLineChar;
	end

IF(@EmployeePosition = '1' ) 
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
			' DEPositions.PositionDescriptions AS PositionDescription
			 ,DEPositions.PositionCodes AS PositionCode' 
		+ @NewLineChar;
	end
	
IF(@EmployeeProfessions = '1' ) 
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql +
			' DEProfessions.ProfessionDescriptions AS ProfessionDescription
			 ,DEProfessions.ProfessionCodes AS ProfessionCode ' 
			+ @NewLineChar;
	end

IF(@AgreementType = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
		+ 'DIC_AgreementTypes.AgreementTypeID AS AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription AS AgreementTypeDescription '
		+ @NewLineChar;
	end	

--=================================================================

SET @Sql = @Declarations + @Sql + @SqlFrom + @sqlWhere + @sqlEnd

--Exec rpc_HelperLongPrint @Sql 

-- remarks select

SET @SqlRemSelect = @Sql +
	'
	SELECT DISTINCT T.* '
--------- Remarks ---------------------------
IF(@Remark = '1')
	begin 
		SET @SqlRemSelect = @SqlRemSelect +
		', v_DepEm_EmRem.RemarkTextFormated AS RemarkText,
		v_DepEm_EmRem.DicRemarkID AS RemarkID
		, '''' as ServiceRemark
		'
	end	
IF(@ShowRemarkInInternet = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + 
		', case when v_DepEm_EmRem.displayInInternet = 1 then ''כן'' else ''לא'' end AS ShowRemarkInInternet'
	end	
IF(@RemarkAttributedToAllClinics = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + 
		', case when v_DepEm_EmRem.AttributedToAllClinicsInCommunity = 1 then ''כן'' else ''לא'' end AS RemarkAttributedToAllClinics '
	end	
IF(@RemarkValidFrom = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + ', v_DepEm_EmRem.ValidFrom AS RemarkValidFrom '
	end		
IF(@RemarkValidTo = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect + ', v_DepEm_EmRem.ValidTo AS RemarkValidTo '
	end		
-------------------------------------------------	7
SET @SqlRemSelect = @SqlRemSelect +	
	'
	FROM #Tmp T
	LEFT JOIN View_DeptEmployee_EmployeeRemarks AS v_DepEm_EmRem 
		ON T.dc = v_DepEm_EmRem.DeptCode
		AND T.EmployeeID = v_DepEm_EmRem.EmployeeID
	'
IF(@ShowRemarkInInternet_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + 		
	' AND (v_DepEm_EmRem.displayInInternet IN (SELECT IntField FROM dbo.SplitString( @xShowRemarkInInternet_cond )) ) 
	'
IF(@IsValidRemark_cond = '1')
	SET @SqlRemSelect = @SqlRemSelect + 
	' AND (v_DepEm_EmRem.ValidFrom <= @xDateNow 
			AND (v_DepEm_EmRem.ValidTo is NULL OR v_DepEm_EmRem.ValidTo >= @xDateNow)
			)
	'
IF(@IsValidRemark_cond = '0')
	SET @SqlRemSelect = @SqlRemSelect + 
	' AND (v_DepEm_EmRem.ValidFrom > @xDateNow 
			OR (v_DepEm_EmRem.ValidTo is NOT NULL AND v_DepEm_EmRem.ValidTo < @xDateNow)
			)
	'	
IF(@Remark_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + 	
	' AND (v_DepEm_EmRem.DicRemarkID IN (SELECT IntField FROM dbo.SplitString( @xRemark_cond )) ) 
	'
IF(@IsRemarkAttributedToAllClinics_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + @NewLineChar +		
	' AND (v_DepEm_EmRem.AttributedToAllClinicsInCommunity IN (SELECT IntField FROM dbo.SplitString( @xIsRemarkAttributedToAllClinics_cond )) ) '
IF(@IsFutureRemark_cond <> '-1')
	SET @SqlRemSelect = @SqlRemSelect + @NewLineChar +		
	' AND (	 @xIsFutureRemark_cond = ''1'' AND v_DepEm_EmRem.validFrom >= GETDATE()
		 OR  @xIsFutureRemark_cond = ''0'' AND v_DepEm_EmRem.validFrom < GETDATE() 
		) '
IF(@Remark = '1' )
	begin 
		SET @SqlRemSelect = @SqlRemSelect +
		'WHERE v_DepEm_EmRem.DicRemarkID is not null'
	end	
	
-- Service remarks select

SET @SqlServRemSelect = 
	'
	UNION 
	
	SELECT DISTINCT T.* '
--------- Remarks ---------------------------
IF(@Remark = '1')
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect +
		', '''' AS RemarkText,
		#TempServiceRemarks.RemarkID
		, #TempServiceRemarks.ServiceRemark as ServiceRemark
		'
	end	
IF(@ShowRemarkInInternet = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + 
		', case when #TempServiceRemarks.displayInInternet = 1 then ''כן'' else ''לא'' end AS ShowRemarkInInternet'
	end	
IF(@RemarkAttributedToAllClinics = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + 
		', '' '' AS RemarkAttributedToAllClinics '
	end	
IF(@RemarkValidFrom = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + ', #TempServiceRemarks.ValidFrom AS RemarkValidFrom '
	end		
IF(@RemarkValidTo = '1' )
	begin 
		SET @SqlServRemSelect = @SqlServRemSelect + ', #TempServiceRemarks.ValidTo AS RemarkValidTo '
	end		
-------------------------------------------------	7
SET @SqlServRemSelect = @SqlServRemSelect +	
	'
	FROM #Tmp T
	JOIN #TempServiceRemarks ON T.DeptEmployeeID = #TempServiceRemarks.DeptEmployeeID
	'
IF(@ShowRemarkInInternet_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + 		
	' AND (#TempServiceRemarks.displayInInternet IN (SELECT IntField FROM dbo.SplitString( @xShowRemarkInInternet_cond )) ) 
	'
IF(@IsValidRemark_cond = '1')
	SET @SqlServRemSelect = @SqlServRemSelect + 
	' AND (#TempServiceRemarks.ValidFrom <= @xDateNow 
			AND (#TempServiceRemarks.ValidTo is NULL OR #TempServiceRemarks.ValidTo >= @xDateNow)
			)
	'
IF(@IsValidRemark_cond = '0')
	SET @SqlServRemSelect = @SqlServRemSelect + 
	' AND (#TempServiceRemarks.ValidFrom > @xDateNow 
			OR (#TempServiceRemarks.ValidTo is NOT NULL AND #TempServiceRemarks.ValidTo < @xDateNow)
			)
	'	
IF(@Remark_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + 	
	' AND (#TempServiceRemarks.RemarkID IN (SELECT IntField FROM dbo.SplitString( @xRemark_cond )) ) 
	'

IF(@IsFutureRemark_cond <> '-1')
	SET @SqlServRemSelect = @SqlServRemSelect + @NewLineChar +		
	' AND (	 @xIsFutureRemark_cond = ''1'' AND #TempServiceRemarks.validFrom >= GETDATE()
		 OR  @xIsFutureRemark_cond = ''0'' AND #TempServiceRemarks.validFrom < GETDATE() 
		) '





--print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @Sql 

SET @Sql = @SqlTempServRemarks + @SqlRemSelect + @SqlServRemSelect

SET DATEFORMAT dmy;

EXECUTE sp_executesql @Sql, @params, 
	@xDistrictCodes = @DistrictCodes, 
	@xEmployeeSector_cond = @EmployeeSector_cond, 
	@xProfessionCodes = @ProfessionCodes, 
	@xRemark_cond = @Remark_cond, 
	@xIsRemarkAttributedToAllClinics_cond = @IsRemarkAttributedToAllClinics_cond, 
	@xShowRemarkInInternet_cond = @ShowRemarkInInternet_cond, 
	@xIsFutureRemark_cond = @IsFutureRemark_cond, 
	@xAgreementType_cond = @AgreementType_cond

SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO

GRANT EXEC ON [dbo].rprt_EmployeeRemarks TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rprt_EmployeeRemarks TO [clalit\IntranetDev]
GO
