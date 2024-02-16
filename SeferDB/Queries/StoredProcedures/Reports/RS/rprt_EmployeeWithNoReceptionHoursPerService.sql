IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeWithNoReceptionHoursPerService')
	BEGIN
		DROP  PROCEDURE  rprt_EmployeeWithNoReceptionHoursPerService
	END
GO

CREATE Procedure [dbo].[rprt_EmployeeWithNoReceptionHoursPerService]
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
	@QueueOrderDescription varchar (2)=null, 
	@EmployeeSex varchar(2)=null, 
	@EmployeeDegree varchar(2)= null,
	@EmployeeLanguages varchar(2)= null, 
	@ReceiveGuests varchar(2)= null,
			
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
	 @xServiceCodes varchar(max)=null, 
	 @xProfessionCodes varchar(max)=null,
	 @xUnitedServiceCodes varchar(max)=null,
	 @xExpertProfessionCodes varchar(max)=null,
	 @xCitiesCodes varchar(max)=null, 	 
	 @xAgreementType_cond varchar(max)=null
'

SET @Declarations = ''

---------------------------
set @sql = 'SELECT distinct * from (select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
JOIN vEmployeeServiceInClinicWithNoReception vEmpServNoReception ON x_Dept_Employee.deptEmployeeID = vEmpServNoReception.deptEmployeeID
JOIN EmployeeInClinic_preselected EmpPresel ON x_Dept_Employee.deptEmployeeID = EmpPresel.deptEmployeeID
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active ' + @NewLineChar;
if(@EmployeeSector = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode ' + @NewLineChar;
if(@adminClinic = '1' )
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode ' + @NewLineChar;
set @sqlFrom = @sqlFrom + 	
'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode ' + @NewLineChar;
if(@unitType = '1')
	set @sqlFrom = @sqlFrom +   
	'LEFT JOIN View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode ' + @NewLineChar;
if(@subUnitType = '1')	
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode = SubUnitType.subUnitTypeCode
		 and  d.typeUnitCode = SubUnitType.UnitTypeCode ' + @NewLineChar;
if(@city = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN Cities on d.CityCode = Cities.CityCode ' + @NewLineChar;
if(@simul = '1')
	set @sqlFrom = @sqlFrom +  
	' LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode ' + @NewLineChar;
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode ' + @NewLineChar;
if(@QueueOrderDescription = '1')	
	set @sqlFrom = @sqlFrom + 
	' cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails ' + @NewLineChar;
if(@DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom + 
	' LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	 LEFT JOIN DeptEmployeePhones as emplPh2 on x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 ' + @NewLineChar;
if(@Phone1 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  			
	' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 ' + @NewLineChar;
if(@Phone2 = '1' OR @DeptEmployeePhone = '1')
	set @sqlFrom = @sqlFrom +  		
	' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 ' + @NewLineChar;
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' + @NewLineChar;
if(@Fax = '1' OR @DeptEmployeeFax = '1')
	set @sqlFrom = @sqlFrom + 		
	' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 ' + @NewLineChar;
if(@sector = '1')	
	set @sqlFrom = @sqlFrom + 	
	' LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID ' + @NewLineChar;
if(@Position = '1' ) 
	set @sqlFrom = @sqlFrom +  
	'LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID ' + @NewLineChar;
if(@DeptEmployeeServices = '1' ) 
	set @sqlFrom = @sqlFrom +  	
	' LEFT JOIN [dbo].View_DeptEmployeeServices as DEServices 
		on x_Dept_Employee.deptCode = DEServices.deptCode 
		and x_Dept_Employee.AgreementType = DEServices.AgreementType
		and Employee.employeeID = DEServices.employeeID ' + @NewLineChar;
if(@DeptEmployeeRemark = '1' ) 
	set @sqlFrom = @sqlFrom + 
	'LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID ' + @NewLineChar;
if(@EmployeeDegree = '1')	
	set @sqlFrom = @sqlFrom +  		
	'LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode ' + @NewLineChar;

SET @SqlWhere = ' WHERE x_Dept_Employee.active = 1 '

IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )) ) '
IF(@UnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
IF(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) ' + @NewLineChar;
IF(@AgreementType_cond <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond )) ) '
IF(@UnitedServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 
	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes )))
	'		  
IF(@ExpertProfessionCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))
			AND vEmpServNoReception.expProfession = 1) 
	'	
--IF(@ServiceCodes <> '-1')
--	SET @SqlWhere = @SqlWhere + 	  
--	' AND ( vEmpServNoReception.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xServiceCodes )))
--	'	
IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes = '-1')
	SET @SqlWhere = @SqlWhere + 
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '	
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
IF(@EmployeeSector_cond <> '-1' AND @ServiceCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	
	' AND ( CASE WHEN Employee.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												 THEN Employee.EmployeeSectorCode 
												 ELSE [Services].SectorToShowWith END
								FROM [Services]
								JOIN x_Dept_Employee_Service as xdes ON [Services].ServiceCode = xdes.ServiceCode
									AND xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 
								), Employee.EmployeeSectorCode)
				 ELSE Employee.EmployeeSectorCode
				 END 
					= @xEmployeeSector_cond
	) '
	
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode, UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ 
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
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode, dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
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
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
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
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
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
	
if(@Professions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' CASE WHEN vEmpServNoReception.IsProfession = 1 
			  THEN vEmpServNoReception.ServiceDescription ELSE '''' END as ProfessionDescription
			, CASE CAST(vEmpServNoReception.IsProfession as varchar(2))
			  WHEN ''1'' THEN CAST(vEmpServNoReception.ServiceCode as varchar(6)) ELSE '''' END as ProfessionCode 
			  ' 
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' CASE CAST(vEmpServNoReception.expProfession as varchar(2)) 
			  WHEN ''1'' THEN '' מומחה/ית'' ELSE '''' END as ExpertProfessionDescription
			 ,vEmpServNoReception.expProfession as ExpertProfessionCode
			 ' 
	end

if(@DeptEmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' CASE WHEN vEmpServNoReception.IsService = 1 
			  THEN vEmpServNoReception.ServiceDescription ELSE '''' END as ServiceDescription
			, CASE CAST(vEmpServNoReception.IsService as varchar(2))
			  WHEN ''1'' THEN CAST(vEmpServNoReception.ServiceCode as varchar(6)) ELSE '''' END as ServiceCode 
			  ' 		
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' EmpPresel.EmployeeLanguageDescription as EmployeeLanguages' + @NewLineChar;
end 
	
if(@QueueOrderDescription = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
		+ @NewLineChar
	end	

if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.phone as EmployeePhone1 ' + @NewLineChar;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpPresel.fax as EmployeeFax ' + @NewLineChar;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql
		 + ' EmpPresel.AgreementType as AgreementTypeCode,
		 EmpPresel.AgreementTypeDescription as AgreementTypeDescription ' + @NewLineChar;
	end	

if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@ReceiveGuests = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CASE  WHEN EmpPresel.ReceiveGuests = 1 THEN ''כן'' ELSE ''לא'' END  as ReceiveGuests '+ @NewLineChar;
	end	
	
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
--=================================================================
--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
-- Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xServiceCodes = @ServiceCodes,
	@xProfessionCodes = @ProfessionCodes,
	@xUnitedServiceCodes = @UnitedServiceCodes,	
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xCitiesCodes = @CitiesCodes,
	@xAgreementType_cond = @AgreementType_cond--,
	--@xDeptEmployeeStatusCodes = @DeptEmployeeStatusCodes
 
SET @ErrCode = @sql 
RETURN 

GO

GO

GRANT EXEC ON [dbo].rprt_EmployeeWithNoReceptionHoursPerService TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rprt_EmployeeWithNoReceptionHoursPerService TO [clalit\IntranetDev]
GO
