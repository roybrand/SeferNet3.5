IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndServicesRemarks')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndServicesRemarks
	END
GO

CREATE Procedure dbo.rprt_DeptAndServicesRemarks
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@SectorCodes varchar(max)=null,
	@RemarkType_cond varchar(max)=null,
	@Remark_cond varchar(max)=null,
	@IsConstantRemark_cond varchar(max)=null,
	@IsSharedRemark_cond varchar(max)=null,
	@ShowRemarkInInternet_cond varchar(max)=null,
	@IsFutureRemark_cond varchar(max)=null,
	@IsValidRemark_cond varchar(max)=null,
	@Membership_cond varchar(max)=null, 

	@district varchar (2)= null,	
	@adminClinic varchar (2) = null,		
	@ClinicName varchar (2)= null,
	@ClinicCode varchar (2)= null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@Remark varchar (2)=null,
	@IsSharedRemark varchar (2)=null,
	@ShowRemarkInInternet varchar (2)=null,
	@RemarkValidFrom varchar (2)=null,
	@RemarkValidTo varchar (2)=null,
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
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,
	@xSubUnitTypeCodes varchar(max)=null,
	@xSectorCodes varchar(max)=null,
	@xRemarkType_cond varchar(max)=null,
	@xRemark_cond varchar(max)=null,
	@xIsConstantRemark_cond varchar(max)=null,
	@xIsSharedRemark_cond varchar(max)=null,
	@xShowRemarkInInternet_cond varchar(max)=null,
	@xIsFutureRemark_cond varchar(max)=null,
	@xMembership_cond varchar(max)=null
'
	 

---------------------------
SET @Sql = 'SELECT distinct * FROM (SELECT ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable' + @NewLineChar;

SET @sqlWhere = '';

SET @SqlFrom = 
'FROM Dept AS d    
JOIN Dept AS d2 ON d.deptCode = d2.deptCode	
	AND d.status = 1 '
IF(	@Membership_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +
	'AND ( 
		 d.IsCommunity = 1 and 1 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond))
		OR d.IsMushlam = 1 and 2 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR d.IsHospital = 1 and 3 IN (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		) '
IF(	@AdminClinicCode <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +		
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode))) '
IF(	@DistrictCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +	
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) 
	  OR d.DeptCode IN ( SELECT x_Dept_District.DeptCode 
						FROM dbo.SplitString( @xDistrictCodes ) AS T 
						JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(	@UnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +		
	' AND (d.typeUnitCode IN (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) )'
IF(	@SubUnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +	
	' AND (d.subUnitTypeCode IN (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) )'
IF(	@SectorCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar +		
	' AND (d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( @xSectorCodes )) )'
	
IF(@adminClinic = '1' )	
	SET @SqlFrom = @SqlFrom + @NewLineChar +	 
	' LEFT JOIN dept AS dAdmin ON d.administrationCode = dAdmin.deptCode '
IF(@district = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar +	 
	' LEFT JOIN dept AS dDistrict ON d.districtCode = dDistrict.deptCode '
IF(@unitType = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN View_UnitType AS UnitType ON d.typeUnitCode = UnitType.UnitTypeCode '
IF(@subUnitType = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN View_SubUnitTypes AS SubUnitType ON d.subUnitTypeCode = SubUnitType.subUnitTypeCode and  d.typeUnitCode = SubUnitType.UnitTypeCode '
IF(@sector = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar +  
	' LEFT JOIN PopulationSectors AS ps ON d.populationSectorCode = ps.PopulationSectorID '
IF(@simul = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar +  	
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
IF(@city = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar +  	
	' LEFT JOIN Cities ON d.CityCode = Cities.CityCode '
	
SET @SqlFrom = @SqlFrom + @NewLineChar +   
 ' JOIN View_DeptAndServicesRemarks AS VRemarks ON d.deptCode = VRemarks.deptCode '
IF(@RemarkType_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar +  	
	' AND (VRemarks.RemarkType IN (SELECT IntField FROM dbo.SplitString( @xRemarkType_cond )) ) '
IF(@Remark_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (VRemarks.remarkID IN (SELECT IntField FROM dbo.SplitString( @xRemark_cond )) ) '
IF(@IsConstantRemark_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND ( VRemarks.IsConstantRemark = @xIsConstantRemark_cond ) '
IF(@IsSharedRemark_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (VRemarks.IsSharedRemark = @xIsSharedRemark_cond ) '
IF(@ShowRemarkInInternet_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (VRemarks.displayInInternet = @xShowRemarkInInternet_cond ) '
IF(@IsFutureRemark_cond <> '-1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (VRemarks.IsFutureRemark = @xIsFutureRemark_cond ) ' 
IF(@IsValidRemark_cond <> '-1')
	BEGIN
		IF(@IsValidRemark_cond = '1')
			SET @SqlFrom = @SqlFrom + @NewLineChar + 		
			' AND ( VRemarks.validTo >= GETDATE() OR VRemarks.validTo is NULL ) '
		ELSE
			SET @SqlFrom = @SqlFrom + @NewLineChar + 		
			' AND (VRemarks.validTo < GETDATE() ) ' 
	END

----------------------------------------------	
IF(@adminClinic = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + ' dAdmin.DeptName AS AdminClinicName,
				 dAdmin.DeptCode AS AdminClinicCode '+ @NewLineChar;
	end	
	
IF(@district = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);	
		SET @Sql = @Sql + ' dDistrict.DeptName AS DistrictName, isNull(dDistrict.deptCode, -1) AS DeptCode '+ @NewLineChar;
	end

IF(@unitType = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + ' UnitType.UnitTypeCode AS UnitTypeCode, UnitType.UnitTypeName AS UnitTypeName '+ @NewLineChar;
	end	
	
IF(@subUnitType = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 
		' subUnitType.subUnitTypeCode AS subUnitTypeCode, subUnitType.subUnitTypeName AS subUnitTypeName '+ 
		@NewLineChar;
	end 
	
IF( @ClinicName= '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 'd.DeptName AS ClinicName ' + @NewLineChar;	
	end

IF( @ClinicCode= '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + ' d.deptCode AS ClinicCode ' + @NewLineChar;	
	end

IF(@simul = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 'deptSimul.Simul228 AS Code228 '+ @NewLineChar;
	end 

IF(@city = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);			
		SET @Sql = @Sql + ' Cities.CityCode AS CityCode, Cities.CityName AS CityName'+ @NewLineChar;
	end

IF (@address = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 'dbo.GetAddress(d.deptCode) AS ClinicAddress '+ @NewLineChar;
	end	

IF(@Membership = '1')
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);			
		SET @Sql = @Sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end AS IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end AS 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end AS IsHospital	
		'+ @NewLineChar;
	end
 
IF(@MangerName = '1')
begin 
	SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
	SET @Sql = @Sql + ' dbo.fun_getManagerName(d.deptCode) AS MangerName '+ @NewLineChar;							   
end

IF(@adminMangerName = '1')
begin 
	SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
	SET @Sql = @Sql + ' dbo.fun_getAdminManagerName(d.deptCode) AS AdminMangerName '+ @NewLineChar;
end		

IF(@sector = '1')
begin 
	SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
	SET @Sql = @Sql + ' ps.PopulationSectorID AS SectorCode, ps.PopulationSectorDescription AS SectorName'+ @NewLineChar;
end 

--------- Remarks ---------------------------
IF(@Remark = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		--SET @Sql = @Sql + 'replace( VRemarks.RemarkText,''#'', '''')  AS RemarkText, 
		SET @Sql = @Sql + 'VRemarks.RemarkTextFormatted AS RemarkText, 
		VRemarks.remarkID AS RemarkID '+ @NewLineChar;
	end	
	
IF(@IsSharedRemark = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 'case when VRemarks.IsSharedRemark = 1 then ''כן'' else ''לא'' end AS IsSharedRemark'+ @NewLineChar;
		
	end		
	
IF(@ShowRemarkInInternet = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + 'case when VRemarks.displayInInternet = 1 then ''כן'' else ''לא'' end AS ShowRemarkInInternet'+ @NewLineChar;
	end	

IF(@RemarkValidFrom = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + ' VRemarks.ValidFrom AS RemarkValidFrom '+ @NewLineChar;
	end		
	
IF(@RemarkValidTo = '1' )
	begin 
		SET @Sql= dbo.SqlDynamicColumnCommaSeparator(@Sql);
		SET @Sql = @Sql + ' VRemarks.ValidTo AS RemarkValidTo '+ @NewLineChar;
	end	

--=================================================================

SET @Sql = @Sql + @SqlFrom + @sqlWhere + @sqlEnd

--print '--===== @Sql string length = ' + str(len(@Sql))
--Exec rpc_HelperLongPrint @Sql 

SET DATEFORMAT dmy;

EXECUTE sp_executesql @Sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xUnitTypeCodes = @UnitTypeCodes,
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xSectorCodes = @SectorCodes,
	@xRemarkType_cond = @RemarkType_cond,
	@xRemark_cond = @Remark_cond,
	@xIsConstantRemark_cond = @IsConstantRemark_cond,
	@xIsSharedRemark_cond = @IsSharedRemark_cond,
	@xShowRemarkInInternet_cond = @ShowRemarkInInternet_cond,
	@xIsFutureRemark_cond = @IsFutureRemark_cond,
	@xMembership_cond = @Membership_cond	
 

SET DATEFORMAT mdy;
SET @ErrCode = @Sql 
RETURN 
SET DATEFORMAT mdy;
GO

GRANT EXEC ON [dbo].rprt_DeptAndServicesRemarks TO PUBLIC
GO