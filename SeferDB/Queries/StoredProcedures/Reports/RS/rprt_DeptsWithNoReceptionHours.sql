IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptsWithNoReceptionHours')
	BEGIN
		DROP  PROCEDURE  rprt_DeptsWithNoReceptionHours
	END
GO

CREATE PROCEDURE [dbo].[rprt_DeptsWithNoReceptionHours]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@StatusCodes varchar(max)=null,	
	@SectorCodes varchar(max)=null,
	@CitiesCodes varchar(max)=null,
	@Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@status varchar (2)=null,			
	@statusFromDate varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@fromDateName varchar (2)=null,			
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@streetName varchar (2)=null,
	@house varchar (2)=null,	
	@floor varchar (2)=null,
	@flat varchar (2)=null,	

	@addressComment varchar (2)=null, 	
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null, 
	@DirectPhone varchar (2)=null,-- NEW
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	
	@transportation varchar (2)=null,
	@deptLevelDesc varchar (2)=null,
	@DeptHandicappedFacilities varchar (2)=null, -- name changed
	@Membership  varchar (2)=null,
	@IsExcelVersion varchar (2)= null,
	@showUnitInInternet varchar (2)=null,
	@DeptCoordinates varchar (2)=null,
	
	@ErrCode VARCHAR(max) OUTPUT
	
-----------------------------------------
)with recompile

AS
--------------------------------------
DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE  @sql nvarchar(max)
DECLARE  @sqlEnd nvarchar(max)
DECLARE  @sqlFrom varchar(max)
DECLARE @SqlWhere nvarchar(max)

SET @params = 
'	
	 @xDistrictCodes varchar(max)=null,
	 @xAdminClinicCode varchar(max)=null,	
	 @xUnitTypeCodes varchar(max)=null,
	 @xSubUnitTypeCodes varchar(max)=null,
	 @xStatusCodes varchar(max)=null, 
	 @xSectorCodes varchar(max)=null,
	 @xCitiesCodes varchar(max)=null, 
	 @xMembership_cond varchar(max)=null 
'

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10) 
SET @sql = 'DECLARE @DateNow datetime = getdate()
			'


SET @sql = @sql + 
	'SELECT distinct *  from
			(select ' + @NewLineChar;
			
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM dept as d '   

if(@adminClinic = '1')
	set @sqlFrom = @sqlFrom +	 
	'left join dept as dAdmin on d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	set @sqlFrom = @sqlFrom +	
	'left join dept as dDistrict on d.districtCode = dDistrict.deptCode '	
if(@subAdminClinic = '1')
	set @sqlFrom = @sqlFrom +		
	'left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '
if(@unitType = '1')
	set @sqlFrom = @sqlFrom +
	'left join View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode '
if(@subUnitType = '1')
	set @sqlFrom = @sqlFrom +
	'left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and d.typeUnitCode =  SubUnitType.UnitTypeCode '
if(@sector = '1')
	set @sqlFrom = @sqlFrom +
	' left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '		
set @sqlFrom = @sqlFrom +   
 'left join deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')
	set @sqlFrom = @sqlFrom + 
 'left join Cities on d.CityCode =  Cities.CityCode ' 
if(@status = '1' or @statusFromDate = '1') 
	set @sqlFrom = @sqlFrom +  
	 'LEFT JOIN 
		(SELECT MAX(StatusID) as StatusID, DeptCode, Status, FromDate, ToDate
		  FROM DeptStatus
		  GROUP BY DeptCode, Status, FromDate, ToDate
		  HAVING FromDate < GETDATE()
		  AND (ToDate is null OR ToDate > GETDATE())
		) AS DeptStatus
		  ON d.deptCode = DeptStatus.DeptCode
		  and d.status = DeptStatus.Status
	  LEFT JOIN DIC_ActivityStatus on d.status = DIC_ActivityStatus.status   
		  '
	 
set @sqlFrom = @sqlFrom +   
 ' left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode '
if(@Phone1 = '1')
	set @sqlFrom = @sqlFrom +
	' left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 '
if(@Phone2 = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 '
if(@Fax = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '
if(@DeptCoordinates = '1')	
	set @sqlFrom = @sqlFrom +  	
	' left join x_dept_XY on d.deptCode = x_dept_XY.deptCode '

-----------------------------------------------------------
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
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

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
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

if(@status = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Status as StatusCode , DIC_ActivityStatus.statusDescription as StatusName '+ @NewLineChar;
	end 

if(@statusFromDate = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.FromDate, 103) AS StatusFromDate '+ @NewLineChar;
	
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.ToDate, 103) AS StatusToDate '+ @NewLineChar;
	end 

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if (@streetName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.streetName '+ @NewLineChar;
	end	
	
if (@house = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.house '+ @NewLineChar;
	end	
	
if (@floor = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.floor '+ @NewLineChar;
	end
		
if (@flat = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.flat '+ @NewLineChar;
	end	
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
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

if(@showUnitInInternet = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
		when d.showUnitInInternet = ''1'' then ''כן''
		else ''לא''
	end as showUnitInInternet '+ @NewLineChar;		
end

if(@fromDateName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' (select top 1 
			CONVERT(VARCHAR(10), FromDate, 103)  
			from dbo.DeptNames
			where deptCode=d.DeptCode and fromDate <=getDate()
			order by fromDate desc) as fromDateName '+ @NewLineChar;
end 

if(@addressComment = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.addressComment as AddressComment '+ @NewLineChar;
end
										 
if(@DeptHandicappedFacilities = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	--' dbo.rfn_GetDeptHandicappedFacilities(d.DeptCode) as DeptHandicappedFacilities '+ @NewLineChar;
	
	' 	(select stuff((select distinct '','' + DIC_HF.FacilityDescription 
		from DeptHandicappedFacilities as DHF
		join DIC_HandicappedFacilities as DIC_HF 
		on DHF.FacilityCode = DIC_HF.FacilityCode
		and DeptCode = d.DeptCode 
		for xml path('''')),1,1,''''
							)) as DeptHandicappedFacilities '
	+ @NewLineChar;
	
end

if(@transportation = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.transportation as transportation '+ @NewLineChar;
end

if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'isNull(ddl.deptLevelCode , -1)	as deptLevelCode ,	 
		ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;
end

if(@DeptCoordinates = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		'CONVERT(decimal(10,3), x_dept_XY.xcoord ) as XCoord  
		,CONVERT(decimal(10,3), x_dept_XY.ycoord ) as YCoord 
		,CONVERT(decimal(15,13), x_dept_XY.XLongitude ) as XLongitude 
		,CONVERT(decimal(15,13), x_dept_XY.YLatitude ) as YLatitude 			
		'  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end

--=================================================================
SET @SqlWhere = 
' WHERE 1=1 
  AND (SELECT COUNT(*) FROM DeptReception 
	WHERE DeptReception.deptCode = d.deptCode
	AND DeptReception.ReceptionHoursTypeID = 1
	AND (DeptReception.validTo is null OR DeptReception.validTo >= @DateNow)
	AND (DeptReception.validFrom < @DateNow) 
	) = 0
 '
IF(@DistrictCodes <> '-1')
	SET @SqlWhere = @SqlWhere +
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString( @xDistrictCodes ) as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(@StatusCodes <> '-1')
	SET @SqlWhere = @SqlWhere +	
	' AND (d.Status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '

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


EXECUTE sp_executesql @sql, @params,
	 @xDistrictCodes = @DistrictCodes,
	 @xAdminClinicCode = @AdminClinicCode,	
	 @xUnitTypeCodes = @UnitTypeCodes,
	 @xSubUnitTypeCodes = @SubUnitTypeCodes,
	 @xStatusCodes = @StatusCodes, 
	 @xSectorCodes = @SectorCodes,
	 @xCitiesCodes = @CitiesCodes, 
	 @xMembership_cond = @Membership_cond	 
SET @ErrCode = @sql 
RETURN

GO

GRANT EXEC ON [dbo].rprt_DeptsWithNoReceptionHours TO [clalit\webuser]
GO

GRANT EXEC ON [dbo].rprt_DeptsWithNoReceptionHours TO [clalit\IntranetDev]
GO