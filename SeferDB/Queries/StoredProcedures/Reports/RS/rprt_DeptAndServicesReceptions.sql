IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndServicesReceptions')
	BEGIN
		DROP  Procedure  rprt_DeptAndServicesReceptions
	END
GO

CREATE Procedure dbo.rprt_DeptAndServicesReceptions
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@ServiceCodes varchar(max)=null, ---!
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@StatusCodes varchar(max)=null,	---!
	@SectorCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null, ---!
	@ServiceGivenBy_cond varchar(max)=null, ---!
	@ObjectType_cond varchar(max)=null, 
	@ValidFrom_cond varchar(max)=null,
	@ValidTo_cond varchar(max)=null,
	@Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@ServiceDescription varchar (2)=null,	
	@ServiceGivenByPersons varchar (2)=null,
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepWeekHoursSum varchar (2)=null,
	@ReceptionRoom varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	@Membership  varchar (2)=null,

	@IsExcelVersion varchar (2)= null,
	@ErrCode varchar(max) OUTPUT
	
)with recompile

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @sqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

SET @params = 
'	
	 @xDistrictCodes varchar(max)=null,
	 @xAdminClinicCode varchar(max)=null,	
	 @xServiceCodes varchar(max)=null, 
	 @xUnitTypeCodes varchar(max)=null,
	 @xSubUnitTypeCodes varchar(max)=null,
	 @xStatusCodes varchar(max)=null, 
	 @xSectorCodes varchar(max)=null,
	 @xCitiesCodes varchar(max)=null, 
	 @xServiceGivenBy_cond varchar(max)=null, 
	 @xObjectType_cond varchar(max)=null, 
	 @xValidFrom_cond varchar(max)=null,
	 @xValidTo_cond varchar(max)=null,
	 @xMembership_cond varchar(max)=null
	'
--------------------------------------
SET @Declarations = ''
--' DECLARE @xNewLineChar AS CHAR(2) 
--  SET @xNewLineChar = CHAR(13) + CHAR(10) '

-- DECLARE @xReceptionHoursSpan int '

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)


SET @Sql = 'SELECT distinct *  FROM
			(select ' + @NewLineChar 
SET @sqlEnd = ') as resultTable ' + @NewLineChar 

SET @sqlFrom = 
' FROM dept as d    
 JOIN dept as d2 on d.deptCode = d2.deptCode	
	AND d.status = 1 '
IF(	@Membership_cond <> '-1')
	SET @sqlFrom = @sqlFrom + 
	' AND ( d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		   or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		   or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		)'
IF(	@AdminClinicCode <> '-1')
	SET @sqlFrom = @sqlFrom + 		
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )))
	'
IF(	@DistrictCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 		
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes ))) 
	'
IF(	@UnitTypeCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 	
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )))
	'
IF(	@SubUnitTypeCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 		
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )))
	'
IF(	@SectorCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 		
	' AND (d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( @xSectorCodes )))
	'
IF(	@ServiceCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 	
' AND (
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		join x_Dept_Employee
		on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE x_Dept_Employee.deptCode = d.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xServiceCodes ))) > 0
	) '
	
SET @sqlFrom = @sqlFrom + 			 
 ' LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode '
IF(@subAdminClinic <> '0')  
	SET @sqlFrom = @sqlFrom +
	'LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '
IF(@unitType <> '0')  	
	SET @sqlFrom = @sqlFrom +	
	 ' LEFT JOIN View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode ' 
IF(@subUnitType <> '0')  		 
	SET @sqlFrom = @sqlFrom + 
	 ' LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode '
IF(@sector = '1')
	SET @sqlFrom = @sqlFrom +  
	' left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '
IF(@simul = '1') 	
	SET @sqlFrom = @sqlFrom +  
	' LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode '
IF(@city = '1')
	SET @sqlFrom = @sqlFrom + 	 
	' LEFT JOIN Cities on d.CityCode = Cities.CityCode '
 
IF(@Phone1 = '1')	
	SET @sqlFrom = @sqlFrom + 		 
 ' LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 '
IF(@Phone2 = '1')	
	SET @sqlFrom = @sqlFrom + 	  
 ' LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '
IF(@Fax = '1')	
	SET @sqlFrom = @sqlFrom +   
 ' LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '
 
IF(@MangerName = '1')
	SET @sqlFrom = @sqlFrom +   
 ' LEFT JOIN vManagers on d.DeptCode = vManagers.DeptCode ' 
 
IF(@adminMangerName = '1')
	SET @sqlFrom = @sqlFrom +   
 ' LEFT JOIN vAdminManagers on d.DeptCode = vAdminManagers.DeptCode '

SET @sqlFrom = @sqlFrom +  
' cross APPLY dbo.rfn_GetDeptReception_Weekly_Sum(d.deptCode, 
		isNull(@xValidFrom_cond, ''null''),
		IsNull(@xValidTo_cond, ''null''),  
		@xObjectType_cond) AS [DeptReception] '
--' cross APPLY dbo.rfn_GetDeptAndServicesReception(d.deptCode, 
--		isNull(@xValidFrom_cond, ''null''),
--		IsNull(@xValidTo_cond, ''null''),  
--		@xObjectType_cond, 
--		@xServiceGivenBy_cond) AS [DeptReception] '



SET @SqlWhere = ' WHERE 1=1 '

IF(@StatusCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	  
	' AND (d.status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '
IF(@CitiesCodes <> '-1')
	SET @SqlWhere = @SqlWhere + 	 		
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
 
-----------------------------------------------------------
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName,
				 dAdmin.DeptCode as AdminClinicCode ' + @NewLineChar 
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, isNull(dDistrict.deptCode, -1) as DeptCode '+ @NewLineChar;
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

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
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
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode, dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	' CASE WHEN vManagers.managerName IS NOT null THEN vManagers.managerName 
		  ELSE CASE WHEN d.managerName IS NOT null and d.managerName <> '''' THEN d.managerName 
			   ELSE '''' END 
		  END as MangerName '
	+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	' CASE WHEN vAdminManagers.adminManagerName IS NOT null THEN vAdminManagers.adminManagerName 
		   ELSE CASE WHEN d.administrativeManagerName IS NOT null and d.administrativeManagerName <> '''' THEN d.administrativeManagerName 
			    ELSE '''' END 	
		   END as AdminMangerName '

	+ @NewLineChar;
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
if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode, ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 
------------ serviceDescription -------------------------------------------------------------------------------------

if(@serviceDescription = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription as serviceDescription,
	 [DeptReception].serviceCode as serviceCode ' + @NewLineChar;
end 
----------- serviceIsGivenByPerson-------------------------------------
if(@serviceGivenByPersons = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceGivenByPerson  as ''serviceGivenByPerson'', 
	[DeptReception].serviceGivenByPersonCode as ''serviceGivenByPersonCode''' + @NewLineChar;
end 
------------ RecepDay --------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName as ReceptionDayName ' + @NewLineChar;
	end 
----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour as openingHour ' + @NewLineChar;
end 
----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour as closingHour ' + @NewLineChar;
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
	set @sql = @sql + ' CONVERT(varchar(max), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 
----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(max), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 
----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 

--=================================================================
set @sql = @Declarations + @sql + @sqlFrom + @SqlWhere + @sqlEnd

--Exec Helper_LongPrint @sql

EXECUTE sp_executesql @sql, @params,
	 @xDistrictCodes = @DistrictCodes,
	 @xAdminClinicCode = @AdminClinicCode,	
	 @xServiceCodes = @ServiceCodes, 
	 @xUnitTypeCodes = @UnitTypeCodes,
	 @xSubUnitTypeCodes = @SubUnitTypeCodes,
	 @xStatusCodes = @StatusCodes,
	 @xSectorCodes = @SectorCodes,
	 @xCitiesCodes = @CitiesCodes, 
	 @xServiceGivenBy_cond = @ServiceGivenBy_cond, 
	 @xObjectType_cond = @ObjectType_cond, 
	 @xValidFrom_cond = @ValidFrom_cond,
	 @xValidTo_cond = @ValidTo_cond,
	 @xMembership_cond = @Membership_cond

SET @ErrCode = @sql 
RETURN 

GO

GRANT EXEC ON dbo.rprt_DeptAndServicesReceptions TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rprt_DeptAndServicesReceptions TO [clalit\IntranetDev]
GO