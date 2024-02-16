IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeReceptions
	END
GO

CREATE Procedure [dbo].[rprt_DeptEmployeeReceptions]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	@ValidFrom_cond varchar(max)=null,
	@ValidTo_cond varchar(max)=null,

	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,-- NEW	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null, 
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,

	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepWeekHoursSum varchar (2)=null,
	@ReceptionRoom varchar (2)=null,	
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	@EmployeeLanguages varchar(2)= null, 
	@IsExcelVersion varchar (2)=null,

	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @UnitedServiceCodes nvarchar(max) = '-1'

IF(@ServiceCodes <> '-1')
BEGIN
	SET @UnitedServiceCodes = @ServiceCodes
END

IF(@ProfessionCodes <> '-1')
BEGIN
	IF(@ServiceCodes = '-1')
		BEGIN
			SET @UnitedServiceCodes = @ProfessionCodes
		END
	ELSE
		BEGIN
			SET @UnitedServiceCodes = @UnitedServiceCodes + ',' + @ProfessionCodes
		END	
END

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitedServiceCodes varchar(max)=null,		 
	@xExpertProfessionCodes varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	 
	@xAgreementType_cond varchar(max)=null,
	@xValidFrom_cond varchar(max)=null,
	@xValidTo_cond varchar(max)=null
'

SET @Declarations = 'DECLARE @DateNow as date = GETDATE()
'

---------------------------
set @sql = 'SELECT distinct * FROM
			(SELECT ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID '
if(@EmployeeSector = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
if(@AgreementType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	' JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
if(@adminClinic = '1' )
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode ' 
if(@district = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode '
if(@unitType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode	'
if(@subUnitType = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode	 
		AND d.typeUnitCode = SubUnitType.UnitTypeCode '
if(@simul = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')	
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN Cities on d.CityCode =  Cities.CityCode '
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '
set @sqlFrom = @sqlFrom + @NewLineChar +
'cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails '
if(@DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	'LEFT JOIN DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	LEFT JOIN DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 '
if(@DeptEmployeeFax = '1')		
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 '
if(@DeptEmployeePhone = '1' OR @Phone1 = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 ' 
if(@DeptEmployeePhone = '1' OR @Phone2 = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '
if(@DeptEmployeeFax = '1' OR @Fax = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '
if(@sector = '1')
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '
if(@EmployeeExpertProfession = '1') 	
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
		on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEExpProfessions.AgreementType
		and Employee.employeeID = DEExpProfessions.employeeID '
if(@Position = '1' ) 		
	set @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID '
if(@DeptEmployeeRemark = '1' )		
	set @sqlFrom = @sqlFrom + @NewLineChar +	
	' LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID '
--set @sqlFrom = @sqlFrom + 		
--'		
-------------- Dept and services Reception --------------
--LEFT JOIN dbo.View_DeptEmployeeReceptions AS DeptReception on x_Dept_Employee.deptCode = DeptReception.deptCode
--	and x_Dept_Employee.employeeID = DeptReception.employeeID 
--'	

SET @sqlFrom = @sqlFrom +  
' OUTER APPLY dbo.rfn_GetDeptEmployeeReception_Weekly_Sum(x_Dept_Employee.DeptEmployeeID, 
		isNull(@xValidFrom_cond, ''null''),
		IsNull(@xValidTo_cond, ''null'')  
		) AS [DeptReception] 
'
----------------------------------------------------------------------------------
SET @SqlWhere = ' WHERE 1=1 AND x_Dept_Employee.active = 1 
AND (DeptReception.validTo is null OR  DeptReception.validTo > @DateNow)
'
if(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString( @xDistrictCodes ) as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )'
if(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.administrationCode  in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )))'
if(@UnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) )'
if(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) )'
if(@AgreementType_cond <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@xAgreementType_cond ))) '
	
if(@UnitedServiceCodes <> '-1' AND @EmployeeSector_cond = '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND EXISTS (
	(	SELECT *
		FROM x_Dept_Employee_Service as xDS 
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		AND x_Dept_Employee.active = 1						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) 
	)'
if(@UnitedServiceCodes <> '-1' AND @EmployeeSector_cond <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Service as xDES
			JOIN Services S ON xDES.serviceCode = S.ServiceCode
			WHERE xDES.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			AND (
					( Employee.IsMedicalTeam = 1 
					AND
					S.SectorToShowWith IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond ))
					)
					OR
					( Employee.IsMedicalTeam <> 1 
					AND
					Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond ))
					)					
				)

			AND xDES.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))
		) > 0
	)'	

if(@ExpertProfessionCodes <> '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +	
	'AND (
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDS 
		LEFT JOIN EmployeeServices on x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDS.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
	)'	

if(@EmployeeSector_cond <> '-1' AND @ExpertProfessionCodes = '-1')
	SET @SqlWhere = @SqlWhere + @NewLineChar +
	'AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) )'

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end



if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@DeptEmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @Professions -------------------------------------------------------

if(@Professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].ProfessionDescription  as ProfessionDescription,
	 [DeptReception].ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].totalHours  as totalHours ' + @NewLineChar;
end 
----------- RecepWeekHoursSum --------------------------------------------------
if(@RecepWeekHoursSum = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].WeekHoursSum as WeekHoursSum ' + @NewLineChar;
end 

----------- ReceptionRoom --------------------------------------------------
if(@ReceptionRoom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].ReceptionRoom  as receptionRoom ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 
--=================================================================

set @sql = @Declarations + @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
-- Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitedServiceCodes = @UnitedServiceCodes,		
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xCitiesCodes = @CitiesCodes,
	@xAgreementType_cond = @AgreementType_cond,
	@xValidFrom_cond = @ValidFrom_cond,
	@xValidTo_cond = @ValidTo_cond

SET @ErrCode = @sql 
RETURN 

GO

GRANT EXEC ON [dbo].rprt_DeptEmployeeReceptions TO PUBLIC
GO