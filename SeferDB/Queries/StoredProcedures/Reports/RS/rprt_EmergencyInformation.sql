ALTER PROCEDURE [dbo].[rprt_EmergencyInformation]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@StatusCodes varchar(max)=null,
	@SectorCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@Membership_cond varchar(max)=null,

	@TypeOfDefense VARCHAR(3)=null,
	@DefensivePolicy VARCHAR(3)=null,
	@IsUnifiedClinic VARCHAR(1)=null,
	@HasElectricalPanel VARCHAR(1)=null,
	@HasGenerator VARCHAR(1)=null,
	@Membership VARCHAR(1)=null,
	@District varchar (2)= null,
	@AdminClinic varchar (2) = null,
	@UnitType varchar (2)=null,
	@SubUnitType varchar (2)=null,
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@Simul varchar (2)=null,
	@City varchar (2)=null,
	@Address varchar (2)=null,
	@StreetName varchar (2)=null,
	@House varchar (2)=null,
	@Floor varchar (2)=null,
	@Flat varchar (2)=null,
	@AddressComment varchar (2)=null,
	@DeptCoordinates varchar (2)=null,
	@Email varchar (2)=null,
	@SubAdminClinic varchar (2)=null,
	@Sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@AdminMangerName varchar (2)=null,
	@DeptHandicappedFacilities varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT

) with recompile

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @sql nvarchar(max)
DECLARE @sqlEnd nvarchar(max)
DECLARE @sqlFrom varchar(max)
DECLARE @SqlWhere nvarchar(max)

SET @params = 
'	 @xDistrictCodes varchar(max)=null,
	 @xAdminClinicCode varchar(max)=null,
	 @xUnitTypeCodes varchar(max)=null,
	 @xSubUnitTypeCodes varchar(max)=null,
	 @xSectorCodes varchar(max)=null,
	 @xEmployeeSector_cond varchar(max)=null,	
	 @xExpertProfessionCodes varchar(max)=null,
	 @xCitiesCodes varchar(max)=null,
	 @xMembership_cond varchar(max)=null 
'

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10) 
--SET @sql = ' '

SET @sql =  'SELECT distinct * from
			(select d.DeptName as ClinicName,
			        d.DeptCode as ClinicCode ' + @NewLineChar;
			
set @sqlEnd = ') as resultTable ' + @NewLineChar;

set @sqlFrom = 
'FROM dept as d
'

--EXECUTE dbo.AddLog @PageName='', @FunctionName='', @Description = @DefensivePolicy

if(@TypeOfDefense = '1') set @sqlFrom = @sqlFrom + ' left join DIC_TypeOfDefence as TD on TD.TypeOfDefenceCode = d.TypeOfDefenceCode '

if(@DefensivePolicy = '1') set @sqlFrom = @sqlFrom + ' left join DIC_DefencePolicy as DP on DP.DefencePolicyCode = d.DefencePolicyCode '

if(@District = '1') set @sqlFrom = @sqlFrom + 'left join dept as dDistrict on d.districtCode = dDistrict.deptCode '	

if(@AdminClinic = '1') set @sqlFrom = @sqlFrom + 'left join dept as dAdmin on d.administrationCode = dAdmin.deptCode '

if(@SubAdminClinic = '1') set @sqlFrom = @sqlFrom +	 'left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '

if(@UnitType = '1') set @sqlFrom = @sqlFrom + 'left join View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode '

if(@SubUnitType = '1') set @sqlFrom = @sqlFrom +  'left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and d.typeUnitCode =  SubUnitType.UnitTypeCode '

if(@Sector = '1') set @sqlFrom = @sqlFrom + 'left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '		

if(@Simul = '1') set @sqlFrom = @sqlFrom + 'left join deptSimul on d.DeptCode = deptSimul.DeptCode '

if(@City = '1') set @sqlFrom = @sqlFrom + 'left join Cities on d.CityCode =  Cities.CityCode ' 
	 
if(@Phone1 = '1') set @sqlFrom = @sqlFrom + ' left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 '

if(@Phone2 = '1') set @sqlFrom = @sqlFrom +  ' left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '

if(@DirectPhone = '1') set @sqlFrom = @sqlFrom + ' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '

if(@DeptCoordinates = '1') set @sqlFrom = @sqlFrom + ' left join x_dept_XY on d.deptCode = x_dept_XY.deptCode '

----------------------------------------------------------

IF(@TypeOfDefense = '1')
	begin
		set @sql = @sql + ',TD.TypeOfDefenceDefinition ' + @NewLineChar;
	end

IF(@DefensivePolicy = '1') 
	begin 
		set @sql = @sql + ',DP.DefencePolicyDefinition as MaximumDefensivePolicy' + @NewLineChar;
	end
	
IF(@IsUnifiedClinic = '1')
	begin
	
		set @sql = @sql + ',case when d.IsUnifiedClinic = 1 then ''כן'' else ''לא'' end as IsUnifiedClinic ' + @NewLineChar;
	end

IF(@HasElectricalPanel = '1')
	begin	
		set @sql = @sql + ',case when d.HasElectricalPanel = 1 then ''כן'' else ''לא'' end as HasElectricalPanel ' + @NewLineChar;	
	end

IF(@HasGenerator = '1')
begin 
	set @sql = @sql + ',case when d.HasGenerator = 1 then ''כן'' else ''לא'' end as HasGenerator '+ @NewLineChar;
end 

IF(@District = '1')
	begin 
		set @sql = @sql + ',dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

 IF(@AdminClinic = '1') 
	begin 
		set @sql = @sql + ',dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end		

IF(@UnitType = '1')
	begin 
		set @sql = @sql + ',UnitType.UnitTypeCode as UnitTypeCode, UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	

IF(@subUnitType = '1')
	begin 
		set @sql = @sql + ',subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 

IF(@simul = '1')
begin 
	set @sql = @sql + ',deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

IF(@city = '1')
	begin 
		set @sql = @sql + ',Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

IF(@Membership = '1')
	begin 
		set @sql = @sql + 
		',case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql = @sql + ',dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if (@streetName = '1')
	begin 
		set @sql = @sql + ',d.streetName '+ @NewLineChar;
	end	
	
if (@house = '1')
	begin 
		set @sql = @sql + ',d.house '+ @NewLineChar;
	end	
	
if (@floor = '1')
	begin 
		set @sql = @sql + ',d.floor '+ @NewLineChar;
	end
		
if (@flat = '1')
	begin 
		set @sql = @sql + ',d.flat '+ @NewLineChar;
	end	
 
IF(@subAdminClinic = '1')
begin 
	set @sql = @sql + ',dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

IF(@MangerName = '1')
begin 
	set @sql = @sql + ',dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

IF(@adminMangerName = '1')
begin 
	set @sql = @sql + ',dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

IF(@Phone1 = '1')
begin 
	set @sql = @sql + ',dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;	
end

IF(@Phone2 = '1')
begin 
	set @sql = @sql + ',dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end

IF(@DirectPhone = '1')
begin 
	set @sql = @sql + ',dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 

if(@Email = '1')
begin 
	set @sql = @sql + ',d.Email as Email '+ @NewLineChar;
end	

IF(@sector = '1')
begin 
	set @sql = @sql + ',ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

IF(@addressComment = '1')
begin 
	set @sql = @sql + ',d.addressComment as AddressComment '+ @NewLineChar;
end
										 
IF(@DeptHandicappedFacilities = '1')
begin 
	set @sql = @sql + 
	--' dbo.rfn_GetDeptHandicappedFacilities(d.DeptCode) as DeptHandicappedFacilities '+ @NewLineChar;
	
	' 	,(select stuff((select distinct '','' + DIC_HF.FacilityDescription 
		from DeptHandicappedFacilities as DHF
		join DIC_HandicappedFacilities as DIC_HF 
		on DHF.FacilityCode = DIC_HF.FacilityCode
		and DeptCode = d.DeptCode 
		for xml path('''')),1,1,''''
							)) as DeptHandicappedFacilities '
	+ @NewLineChar;
	
end

if(@DeptCoordinates = '1')
begin 
	set @sql = @sql + 
		',CONVERT(decimal(10,3), x_dept_XY.xcoord ) as XCoord  
		,CONVERT(decimal(10,3), x_dept_XY.ycoord ) as YCoord 
		,CONVERT(decimal(15,13), x_dept_XY.XLongitude ) as XLongitude 
		,CONVERT(decimal(15,13), x_dept_XY.YLatitude ) as YLatitude 			
		'  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end

--=================================================================
SET @SqlWhere = 'WHERE 1=1 '

IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString( @xDistrictCodes ) as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '

IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
	
/*IF(@MaximumDefensivePolicy <> '-1' AND @MaximumDefensivePolicy <> '')
	SET @SqlWhere = @SqlWhere +
	' AND (d.DefencePolicyCode IN (SELECT IntField FROM dbo.SplitString( @xMaximumDefensivePolicy ))) '
	*/
--IF(@StatusCodes <> '-1')
--	SET @SqlWhere = @SqlWhere +	
--	' AND (d.Status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '

IF(@CitiesCodes <> '-1' AND @CitiesCodes <> '')
	SET @SqlWhere = @SqlWhere +	
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
	
IF(@Membership_cond <> '-1')
	SET @SqlWhere = @SqlWhere +			
	' AND ( 
		   d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )) 
		) '
IF(@AdminClinicCode <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
IF(@UnitTypeCodes <> '-1' AND @UnitTypeCodes <> '')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.typeUnitCode in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes ))) '
IF(@SubUnitTypeCodes <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND ( d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes ))) '
IF(@SectorCodes <> '-1')
	SET @SqlWhere = @SqlWhere +		
	' AND (d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( @xSectorCodes ))) '
	
set @sql = @sql + @sqlFrom + @SqlWhere + @sqlEnd 

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql

/*
insert into dbo._test_queries([text]) values('EmergencyInformation: ' + @sql + ' ||| @DistrictCodes = ' + @DistrictCodes
                                                                             + ' | @AdminClinicCode = ' + @AdminClinicCode
																			 + ' | @UnitTypeCodes = ' + @UnitTypeCodes
																			 + ' | @AdminClinicCode = ' + @AdminClinicCode
																			 + ' | @SubUnitTypeCodes = ' + @SubUnitTypeCodes
																			 + ' | @CitiesCodes = ' + @CitiesCodes
																			 + ' | @Membership_cond = ' + @Membership_cond)
*/

EXECUTE sp_executesql @sql, @params,
	                  @xDistrictCodes = @DistrictCodes,
					  @xAdminClinicCode = @AdminClinicCode,
					  @xUnitTypeCodes = @UnitTypeCodes,
					  @xSubUnitTypeCodes = @SubUnitTypeCodes,
	                  @xSectorCodes = @SectorCodes,
	                  @xCitiesCodes = @CitiesCodes,
					  @xMembership_cond = @Membership_cond


SET @ErrCode = @sql

RETURN
