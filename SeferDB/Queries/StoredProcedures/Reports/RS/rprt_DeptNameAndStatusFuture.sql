IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptNameAndStatusFuture')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptNameAndStatusFuture
	END
GO

CREATE Procedure [dbo].[rprt_DeptNameAndStatusFuture]
(
	@DeptProperty_cond varchar(max)=null,
	@ValidFrom_cond varchar(max)=null,	
	@ValidTo_cond varchar(max)=null,
	@Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@status varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@DirectPhone varchar (2)=null,	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@subAdminClinic varchar (2)=null, 
	@ValidInterval varchar (2)=null, 
	@Membership  varchar (2)=null,

	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
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
	@xDeptProperty_cond varchar(max)=null,
	@xValidFrom_cond varchar(max)=null,	
	@xValidTo_cond varchar(max)=null,
	@xMembership_cond varchar(max)=null 
'

---------------------------

SET @sql = 'SELECT distinct * FROM (SELECT ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable' + @NewLineChar;

IF(@ValidFrom_cond is null OR @ValidFrom_cond = '-1' OR @ValidFrom_cond = '')
	SET @ValidFrom_cond = GETDATE();
	
IF(@ValidTo_cond is null OR @ValidTo_cond = '')
	SET @ValidTo_cond = '-1';


SET @sqlFrom = 
'FROM Dept AS d ' 
IF(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar +
' LEFT JOIN Dept AS dAdmin ON d.administrationCode = dAdmin.deptCode '
IF(@district = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
' LEFT JOIN Dept AS dDistrict ON d.districtCode = dDistrict.deptCode '
IF(@subAdminClinic = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +   
	'LEFT JOIN Dept AS dSubAdmin ON d.subAdministrationCode = dSubAdmin.deptCode '
IF(@unitType = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +   
	' LEFT JOIN View_UnitType AS UnitType ON d.typeUnitCode = UnitType.UnitTypeCode '
IF(@subUnitType = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar +    
	' LEFT JOIN View_SubUnitTypes AS SubUnitType ON d.subUnitTypeCode = SubUnitType.subUnitTypeCode AND d.typeUnitCode = SubUnitType.UnitTypeCode '
SET @sqlFrom = @sqlFrom + @NewLineChar + 	
 ' LEFT JOIN PopulationSectors AS ps ON d.populationSectorCode = ps.PopulationSectorID '
IF(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
IF(@city = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN Cities ON d.CityCode =  Cities.CityCode '
IF(@Phone1 = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	 
 'LEFT JOIN DeptPhones dp1 ON d.DeptCode = dp1.DeptCode AND dp1.PhoneType = 1 AND dp1.phoneOrder = 1 '
IF(@Phone2 = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN DeptPhones dp2 ON d.DeptCode = dp2.DeptCode AND dp2.PhoneType = 1 AND dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' 
IF(@Fax = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN DeptPhones dp3 ON d.DeptCode = dp3.DeptCode AND dp3.PhoneType = 2 AND dp3.phoneOrder = 1 '
IF(@status = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' JOIN DIC_ActivityStatus AS CurrentDeptStatus ON d.Status = CurrentDeptStatus.Status '
SET @sqlFrom = @sqlFrom + @NewLineChar + 
' LEFT JOIN DeptStatus ON d.DeptCode = DeptStatus.DeptCode
JOIN DIC_ActivityStatus AS FutureDeptStatus ON DeptStatus.Status = FutureDeptStatus.Status
 
LEFT JOIN DeptNames ON d.DeptCode = DeptNames.DeptCode '

SET @sqlWhere = ' WHERE 1=1 ';
IF(@Membership_cond <> '-1')
	SET @sqlWhere = @sqlWhere + @NewLineChar +
	' AND  
		 (
		 d.IsCommunity = 1 AND 1 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR d.IsMushlam = 1 AND 2 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR d.IsHospital = 1 AND 3 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		) '

SET @sqlWhere = @sqlWhere + @NewLineChar +		
	'AND
	(
		(@xDeptProperty_cond = ''0'' AND DeptStatus.FromDate >= @xValidFrom_cond ) '
IF(	@ValidTo_cond <> '-1')
	SET @sqlWhere = @sqlWhere + @NewLineChar +			
		' AND (DeptStatus.FromDate <= @xValidTo_cond ) '
SET @sqlWhere = @sqlWhere + @NewLineChar +			
	' OR 
	 (@xDeptProperty_cond = ''1'' AND DeptNames.FromDate >=  @xValidFrom_cond ' 
IF(	@ValidTo_cond <> '-1')
	SET @sqlWhere = @sqlWhere + @NewLineChar + 
		' AND (DeptNames.FromDate <= @xValidTo_cond  ) '
SET @sqlWhere = @sqlWhere + @NewLineChar +			
	') )
 ' 

---------------------------
IF(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName AS AdminClinicName,
				 isNull(dAdmin.DeptCode, -1) AS AdminClinicCode '+ @NewLineChar;
	end	
	
IF(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName AS DistrictName, isNull(dDistrict.deptCode, -1) AS DeptCode '+ @NewLineChar;
	end

IF(@status = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' d.Status AS StatusCode, CurrentDeptStatus.statusDescription AS StatusName '+ @NewLineChar;
	end 	
IF(@sector = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' ps.PopulationSectorID AS SectorCode, ps.PopulationSectorDescription AS SectorName'+ @NewLineChar;
end 

----------------------Future dept changes --------------------------
IF( @ValidInterval = '1' )
begin 

	IF(@DeptProperty_cond = '0')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' FutureDeptStatus.statusDescription AS FutureStatusName, 
							FutureDeptStatus.status AS FutureStatusCode '+ @NewLineChar;
	
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' CONVERT(VARCHAR(10), DeptStatus.FromDate, 103) AS FromDate '+ @NewLineChar;
	
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' CONVERT(VARCHAR(10), DeptStatus.ToDate, 103) AS ToDate '+ @NewLineChar;
	end 
	
	else IF(@DeptProperty_cond = '1')
	begin 
	 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' DeptNames.deptName AS FutureDeptName '+ @NewLineChar;
							
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' CONVERT(VARCHAR(10), DeptNames.FromDate, 103) AS FromDate '+ @NewLineChar;
	
		--SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		--SET @sql = @sql + ' CONVERT(VARCHAR(10), DeptNames.ToDate, 103) AS ToDate '+ @NewLineChar;
	end 

end 
----------------------------------------------

IF(@unitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' UnitType.UnitTypeCode AS UnitTypeCode, UnitType.UnitTypeName AS UnitTypeName '+ @NewLineChar;
	end	
	
IF(@subUnitType = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
		' subUnitType.subUnitTypeCode AS subUnitTypeCode, subUnitType.subUnitTypeName AS subUnitTypeName '+ 
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

IF(@subAdminClinic = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'dSubAdmin.DeptCode AS SubAdminClinicCode, dSubAdmin.DeptName AS SubAdminClinicName '+ @NewLineChar;
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
 

--=================================================================

SET @Sql = @Sql + @SqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @Sql 

SET DATEFORMAT dmy;

EXECUTE sp_executesql @Sql, @params, 
	@xDeptProperty_cond = @DeptProperty_cond,
	@xValidFrom_cond = @ValidFrom_cond,	
	@xValidTo_cond = @ValidTo_cond,
	@xMembership_cond = @Membership_cond	

SET @ErrCode = @sql 
RETURN 
SET DATEFORMAT mdy;

GO

GRANT EXEC ON [dbo].rprt_DeptNameAndStatusFuture TO PUBLIC
GO