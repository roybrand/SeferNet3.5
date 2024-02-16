IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptSubAdminClinics')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptSubAdminClinics
	END
GO

CREATE Procedure [dbo].[rprt_DeptSubAdminClinics]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@CitiesCodes varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubClinicUnitTypeCodes varchar(max)=null,
	@Membership_cond varchar(max)=null,
	@StatusCodes varchar(max)=null,
	@SubClinicStatusCodes varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@subAdminClinic varchar (2)=null, 

	@SubClinicName varchar (2)=null,
	@SubClinicCode varchar (2)=null,
	@SubClinicSimul varchar (2)=null,
	@SubClinicUnitType varchar (2)=null,		
	@SubClinicSubUnitType varchar (2)=null,	
	@SubClinicCity varchar (2)=null,
	@SubClinicAddress varchar (2)=null,
	@SubClinicPhone1 varchar (2)=null,
	@SubClinicPhone2 varchar (2)=null,
	@SubClinicFax varchar (2)=null,
	@SubClinicEmail varchar (2)=null,
	@Membership  varchar (2)=null,
	@status  varchar (2)=null,
	@SubClinicStatus  varchar (2)=null,

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xCitiesCodes varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,	
	@xSubClinicUnitTypeCodes varchar(max)=null,	 	
	@xMembership_cond varchar(max)=null,	 	
	@xStatusCodes varchar(max)=null, 	
	@xSubClinicStatusCodes varchar(max)=null	
'

---------------------------
SET @sql = 'SELECT distinct * FROM (select ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable' + @NewLineChar;

SET DATEFORMAT dmy;

SET @sqlFrom = 
'FROM Dept AS d   
JOIN Dept AS d2 ON d.deptCode = d2.deptCode	'
IF(@Membership_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' 
		AND (  d.IsCommunity = 1 AND 1 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		 OR d.IsMushlam = 1 AND 2 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		 OR d.IsHospital = 1 AND 3 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		) '
IF(@AdminClinicCode <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +		
	' AND (d.administrationCode  IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )))'
IF(@DistrictCodes <> '-1')
	SET @sqlFrom = @sqlFrom + 	
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) 
	      OR d.DeptCode IN (SELECT x_Dept_District.DeptCode 
							FROM dbo.SplitString( @xDistrictCodes ) AS T 
							JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(@UnitTypeCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 								
	' AND (d.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
IF(@CitiesCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
IF(@StatusCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' AND (d.Status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '
IF(@status = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN DIC_ActivityStatus ON d.Status = DIC_ActivityStatus.status '
IF(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar +   	
	' LEFT JOIN dept AS dAdmin ON d.administrationCode = dAdmin.deptCode '
IF(@district = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	 ' LEFT JOIN dept AS dDistrict ON d.districtCode = dDistrict.deptCode '
IF(@subAdminClinic = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +	 
	' LEFT JOIN dept AS dSubAdmin ON d.subAdministrationCode = dSubAdmin.deptCode '
IF(@unitType = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN View_UnitType AS UnitType ON d.typeUnitCode = UnitType.UnitTypeCode '
IF(@subUnitType = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_SubUnitTypes AS SubUnitType ON d.subUnitTypeCode = SubUnitType.subUnitTypeCode AND d.typeUnitCode =  SubUnitType.UnitTypeCode '
IF(@sector = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +  
	' LEFT JOIN PopulationSectors AS ps ON d.populationSectorCode = ps.PopulationSectorID '
IF(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +  	 
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
IF(@city = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN Cities ON d.CityCode =  Cities.CityCode '
IF (@Phone1 = '1' OR @SubClinicPhone1 = '1')	 
	SET @sqlFrom = @sqlFrom + @NewLineChar +  
	' LEFT JOIN DeptPhones dp1 ON d.DeptCode = dp1.DeptCode AND dp1.PhoneType = 1 AND dp1.phoneOrder = 1 '
IF (@Phone2 = '1' OR @SubClinicPhone2 = '1')	 
	SET @sqlFrom = @sqlFrom + @NewLineChar +  	
	' LEFT JOIN DeptPhones dp2 ON d.DeptCode = dp2.DeptCode AND dp2.PhoneType = 1 AND dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' 

IF (@Fax = '1' OR @SubClinicFax = '1')	 
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN DeptPhones dp3 ON d.DeptCode = dp3.DeptCode AND dp3.PhoneType = 2 AND dp3.phoneOrder = 1 '
 
SET @sqlFrom = @sqlFrom + @NewLineChar + 		
'JOIN Dept AS SubClinics ON d.deptCode = SubClinics.subAdministrationCode '
IF (@SubClinicStatusCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' AND (SubClinics.Status IN (SELECT IntField FROM dbo.SplitString( @xSubClinicStatusCodes )) ) '

IF (@Membership_cond <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' AND (
		 SubClinics.IsCommunity = 1 AND 1 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR SubClinics.IsMushlam = 1 AND 2 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR SubClinics.IsHospital = 1 AND 3 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		)'
IF (@SubClinicUnitTypeCodes <> '-1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 		
	' AND (SubClinics.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xSubClinicUnitTypeCodes )) )
	---AND SubClinics.status = 1 '
	
SET @sqlFrom = @sqlFrom + @NewLineChar + 
' LEFT JOIN DIC_ActivityStatus AS SubClinicDIC_ActivityStatus ON SubClinics.Status = SubClinicDIC_ActivityStatus.status '
IF(@SubClinicUnitType = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_UnitType AS SubClinicUnitType ON SubClinics.typeUnitCode = SubClinicUnitType.UnitTypeCode '
IF(@SubClinicSubUnitType = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	'LEFT JOIN View_SubUnitTypes AS SubClinicSubUnitType ON SubClinics.subUnitTypeCode = SubClinicSubUnitType.subUnitTypeCode
		AND  SubClinics.typeUnitCode = SubClinicSubUnitType.UnitTypeCode '
IF(@SubClinicSimul = '1')		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 		
	' LEFT JOIN deptSimul AS SubClinicDeptSimul ON SubClinics.DeptCode = SubClinicDeptSimul.DeptCode '
IF(@SubClinicCity = '1')		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN Cities AS SubClinicCities ON SubClinics.CityCode = SubClinicCities.CityCode '
IF(@SubClinicPhone1 = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +  
	'LEFT JOIN DeptPhones SubClinic_dp1 ON SubClinics.DeptCode = SubClinic_dp1.DeptCode AND SubClinic_dp1.PhoneType = 1 AND SubClinic_dp1.phoneOrder = 1 '
IF(@SubClinicPhone2 = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +  	
	'LEFT JOIN DeptPhones SubClinic_dp2 ON SubClinics.DeptCode = SubClinic_dp2.DeptCode AND SubClinic_dp2.PhoneType = 1 AND SubClinic_dp2.phoneOrder = 2 '
IF(@SubClinicFax = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +  
	'LEFT JOIN DeptPhones SubClinic_dp3 ON SubClinics.DeptCode = SubClinic_dp3.DeptCode AND SubClinic_dp3.PhoneType = 2 AND SubClinic_dp3.phoneOrder = 1 '

---------------------------
SET @sqlWhere = ''

IF(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName AS AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) AS AdminClinicCode '+ @NewLineChar;
	end	
	
IF(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName AS DistrictName , isNull(dDistrict.deptCode , -1) AS DeptCode '+ @NewLineChar;
	end

IF(@unitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' UnitType.UnitTypeCode AS UnitTypeCode , UnitType.UnitTypeName AS UnitTypeName '+ @NewLineChar;
	end	
	
IF(@subUnitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
		' subUnitType.subUnitTypeCode AS subUnitTypeCode , subUnitType.subUnitTypeName AS subUnitTypeName '+ 
		@NewLineChar;
	end 
	
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

IF(@status = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' d.Status AS StatusCode, DIC_ActivityStatus.statusDescription AS StatusName '+ @NewLineChar;
	end 

IF(@subAdminClinic = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'dSubAdmin.DeptCode AS SubAdminClinicCode, dSubAdmin.DeptName AS SubAdminClinicName '+ @NewLineChar;
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
	
IF(@Phone1 = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end

IF(@Phone2 = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end

if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 

IF(@Fax = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) AS Fax '+ @NewLineChar;
end

IF(@Email = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' d.Email AS Email '+ @NewLineChar;
end
 
IF(@MangerName = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) AS MangerName '+ @NewLineChar;							   
end

IF(@adminMangerName = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) AS AdminMangerName '+ @NewLineChar;
end		

IF(@sector = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' ps.PopulationSectorID AS SectorCode, ps.PopulationSectorDescription AS SectorName'+ @NewLineChar;
end 

IF(@Membership = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		SET @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end AS IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end AS 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end AS IsHospital	
		'+ @NewLineChar;
	end

---------------- SubClinics -----------------------------------

IF( @SubClinicName= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'SubClinics.DeptName AS SubClinicName ' + @NewLineChar;	
	end

IF( @SubClinicCode= '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' SubClinics.deptCode AS SubClinicCode, SubClinics.[subAdministrationCode] AS SubClinics_subAdministrationCode' + @NewLineChar;	
	end

IF(@SubClinicSimul = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'SubClinicDeptSimul.Simul228 AS SubClinicCode228 '+ @NewLineChar;
	end 
	
IF(@SubClinicUnitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' SubClinicUnitType.UnitTypeCode AS SubClinicUnitTypeCode, SubClinicUnitType.UnitTypeName AS SubClinicUnitTypeName '+ @NewLineChar;
	end	
	
IF(@SubClinicSubUnitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
		' SubClinicSubUnitType.subUnitTypeCode AS SubClinicSubUnitTypeCode, SubClinicSubUnitType.subUnitTypeName AS SubClinicSubUnitTypeName '+ 
		@NewLineChar;
	end 
	
IF(@SubClinicCity = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		SET @sql = @sql + ' SubClinicCities.CityCode AS SubClinicCityCode, SubClinicCities.CityName AS SubClinicCityName'+ @NewLineChar;
	end

IF(@SubClinicStatus = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' SubClinics.Status AS SubClinicStatusCode, SubClinicDIC_ActivityStatus.statusDescription AS SubClinicStatusName '+ @NewLineChar;
	end 

IF (@SubClinicAddress = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'dbo.GetAddress(SubClinics.deptCode) AS SubClinicAddress '+ @NewLineChar;
		SET @sql = @sql + ',case when (Cities.CityName = SubClinicCities.CityName
		AND d.streetName  = SubClinics.streetName 
		AND d.house = SubClinics.house )
        then ''כן'' else ''לא'' end  AS SubClinicEqualClinicAddress'
        + @NewLineChar;
	end	
	
IF(@SubClinicPhone1 = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	--SET @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp1.prePrefix, SubClinic_dp1.Prefix, SubClinic_dp1.Phone, SubClinic_dp1.extension ) AS SubClinicPhone1 '+ @NewLineChar;;
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp1.prePrefix, SubClinic_dp1.Prefix,SubClinic_dp1.Phone, SubClinic_dp1.extension ) 
	+ CASE WHEN SubClinic_dp1.remark is NULL OR SubClinic_dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + SubClinic_dp1.remark END as SubClinicPhone1 '+ @NewLineChar;
	SET @sql = @sql + ',case when (dp1.prePrefix = SubClinic_dp1.prePrefix
		AND dp1.Prefix  = SubClinic_dp1.Prefix 
		AND dp1.Phone = SubClinic_dp1.Phone)
        then ''כן'' else ''לא'' end  AS SubClinicEqualClinicPhone1'
        + @NewLineChar;
end

IF(@SubClinicPhone2 = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	--SET @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp2.prePrefix, SubClinic_dp2.Prefix, SubClinic_dp2.Phone, SubClinic_dp2.extension) AS SubClinicPhone2 '+ @NewLineChar;;
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp2.prePrefix, SubClinic_dp2.Prefix,SubClinic_dp2.Phone, SubClinic_dp2.extension ) 
	+ CASE WHEN SubClinic_dp2.remark is NULL OR SubClinic_dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + SubClinic_dp2.remark END as SubClinicPhone2 '+ @NewLineChar;
	SET @sql = @sql + ',case when (dp2.prePrefix = SubClinic_dp2.prePrefix
		AND dp2.Prefix  = SubClinic_dp2.Prefix 
		AND dp2.Phone = SubClinic_dp2.Phone)
        then ''כן'' else ''לא'' end  AS SubClinicEqualClinicPhone2'
        + @NewLineChar;
end 

IF(@SubClinicFax = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp3.prePrefix, SubClinic_dp3.Prefix, SubClinic_dp3.Phone, SubClinic_dp3.extension) AS SubClinicFax '+ @NewLineChar;
	SET @sql = @sql + ',case when (dp3.prePrefix = SubClinic_dp3.prePrefix
		AND dp3.Prefix  = SubClinic_dp3.Prefix 
		AND dp3.Phone = SubClinic_dp3.Phone)
        then ''כן'' else ''לא'' end  AS SubClinicEqualClinicFax'
        + @NewLineChar;
end

IF(@SubClinicEmail = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' SubClinics.Email AS SubClinicEmail '+ @NewLineChar;
	SET @sql = @sql + ',case when d.Email = SubClinics.Email then ''כן'' else ''לא'' end  AS SubClinicEqualClinicEmail'
		+ @NewLineChar;
end

IF(@Membership = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		SET @sql = @sql + 
		'case when SubClinics.IsCommunity = 1 then ''כן'' else ''לא'' end AS SubClinicIsCommunity, 
		case when SubClinics.IsMushlam = 1 then ''כן'' else ''לא'' end AS 	SubClinicIsMushlam,
		case when SubClinics.IsHospital = 1 then ''כן'' else ''לא'' end AS SubClinicIsHospital	
		'+ @NewLineChar;
	end
		
--=================================================================

SET @sql = @sql + @SqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 


EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xCitiesCodes = @CitiesCodes,	
	@xUnitTypeCodes = @UnitTypeCodes,
	@xStatusCodes = @StatusCodes,
	@xSubClinicUnitTypeCodes = @SubClinicUnitTypeCodes,
	@xMembership_cond = @Membership_cond,
	@xSubClinicStatusCodes = @SubClinicStatusCodes

SET @ErrCode = @sql 
RETURN 
SET DATEFORMAT mdy;

GO

GRANT EXEC ON [dbo].rprt_DeptSubAdminClinics TO PUBLIC
GO