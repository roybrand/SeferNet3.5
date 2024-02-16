IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getReportDeptsByTypesProfessionsDynamicExcell')
	BEGIN
		DROP  Procedure  rpc_getReportDeptsByTypesProfessionsDynamicExcell
	END

GO

create Procedure [dbo].[rpc_getReportDeptsByTypesProfessionsDynamicExcell]
(
	 @ProfessionCodes varchar(50)=null,
	 @DistrictCodes varchar(50)=null,
	 @AdminClinicCode varchar(50)=null,
	 @CitiesCodes varchar(20)=null,
	 @StatusCodes varchar(20)=null,
	 @UnitTypeCodes varchar(20)=null,
	 @SubUnitTypeCodes varchar(20)=null,
	 @SectorCodes varchar(20)=null,
	 @ServiceCodes varchar(20)=null,
	 ------------------------------------------
	 @PageSise int =null,
	 @StartingPage int =null,	
	 ------------------------------------------
	 @SortedBy varchar(500)=null,	
	 @IsOrderDescending varchar(20) =null,
	 ------------------------------------------- 
	 
	@district varchar (1)= null,	
	@adminClinic varchar (1) = null ,	
	@subAdminClinic varchar (1)=null, 
	@unitType varchar (1)=null,		
	@subUnitType varchar (1)=null,

	
	 @status varchar (1)=null,
	 @statusFromDate varchar (1)=null,
	 @statusToDate varchar (1)=null,		
	 @simul varchar (1)=null,	
	 @city varchar (1)=null,	
	 @address varchar (1)=null,
	 @addressComment varchar (1)=null, 	
	 @Phone1 varchar (1)=null,
	 @Phone2 varchar (1)=null,
	 @Fax varchar (1)=null,
	 @Email varchar (1)=null,
	 @showEmailInInternet varchar (1)=null, 	
	 @SectorCode varchar (1)=null,
	 @transportation varchar (1)=null,
	 @AccessToClinic varchar (1)=null,
	 @DisabledServices varchar (1)=null,
	 @ElevatorOrOneFloorStructure varchar (1)=null,
	 @ElectricBed varchar (1)=null,
	 @deptLevelDesc varchar (1)=null,
	 @MangerName varchar (1)=null,
	 @AdminMangerName varchar (1)=null,
	 @EmployeeServices varchar (1)=null,
	 @DeptServices varchar (1)=null,
	 @professions varchar (1)=null,
	 @ClinicName varchar (1)=null,	
	@fromDateName varchar (1)=null,
	@ErrCode VARCHAR(4000) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(4000)
declare  @sqlFrom varchar(1000)
declare  @sqlJoin nvarchar(4000)
declare  @sqlWhere nvarchar(4000)
declare @sqlSort nvarchar(4000)
---------------------------
set @sql = ' SELECT distinct ';
set @sqlFrom = ' from dept  as d  ';
set @sqlJoin = ' ';
set @sqlWhere = 'WHERE ';
---------------------------
DECLARE @SortedByDefault varchar(50)
if(@SortedByDefault is null)
	BEGIN 
		SET @SortedByDefault = 'DistrictName'
	END	

IF (@SortedBy is null)
	BEGIN 
		SET @SortedBy = @SortedByDefault ;
	END
	

-- @StartingPage enumeration starts from 1. Here we start from  0
if @StartingPage > 0
begin 
	SET @StartingPage = @StartingPage - 1
END 

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)
--set @IsOrderDescending = '1'

--================================================
	
--set @district= '1';
--set @DistrictCodes =  '-1';
----set @DistrictCodes =  '40000,200000,50000';
----set @DistrictCodes =  '200000';
--
--set @adminClinic = '0';
--set @AdminClinicCode =  '-1';
----set @AdminClinicCode =  '73000,55000';
--
--set @subAdminClinic = '0';
--
--set @unitType = '0';
----set @UnitTypeCodes='-1';
--set @UnitTypeCodes='801,1,904';
--
--set @subUnitType = '0'
--set @SubUnitTypeCodes ='-1'
--
--set @status='0'
--set @StatusCodes = '-1'
--
--set @fromDate = '0'
--set @toDate= '0'
--
--set @simul='0'
--
--set @city='0'
--set @address='0'
--set @addressComment = '0'
--
--set @Phone1='0'
--set @Phone2='0'
--set @Fax='0'
--
--set @Email='0'
--set @showEmailInInternet='0'
--
--set @SectorCode= '0'
--set @SectorCodes='-1'
--set @transportation = '0'
--
--set @AccessToClinic = '0'
--set @DisabledServices ='0'
----
--set @ElevatorOrOneFloorStructure='0'
--set @ElectricBed = '0'
----
--set @deptLevelDesc = '0'
--set @MangerName= '0'
----
--set @AdminMangerName = '0'
----
--set @EmployeeServices='1'
--set @DeptServices ='1'
--
--set @professions= '1'
--set @ProfessionCodes ='-1'

--==============================================
-- select columns
--==============================================

---------------adminClinic----------------------------------------------------			
if(@adminClinic = '1' )
begin 

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dAdmin.DeptName as AdminClinicName , dAdmin.DeptCode as AdminClinicCode ' ;

	set @sqlJoin = @sqlJoin +  ' left join dept as dAdmin on d.administrationCode = dAdmin.deptCode  ' ;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' +  @AdminClinicCode  + ''' = ''-1'' or dAdmin.DeptCode  in (SELECT IntField FROM dbo.SplitString( ''' +  @AdminClinicCode + '''))) ';
end 
-------------district----------------------------------
if(@district = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
	set @sql = @sql + ' dDistrict.DeptName as DistrictName , dDistrict.deptCode as DistrictCode ' ;
	
	set @sqlJoin = @sqlJoin +  ' left join dept as dDistrict on d.districtCode = dDistrict.deptCode ' ;

	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '( '''+ @DistrictCodes + ''' = ''-1'' or dDistrict.deptCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + '''))) '   ;
end

---------------SubAdminClinic----------------------------------------------------------------------------
if(@subAdminClinic = '1')
begin 
set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;

set @sqlJoin = @sqlJoin +  'left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '+ @NewLineChar;
end 
-----------------UnitType-----------------------------------------------------------
if(@unitType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode,UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' +  @UnitTypeCodes  + ''' = ''-1'' or UnitType.UnitTypeCode  in (SELECT IntField FROM dbo.SplitString( ''' +  @UnitTypeCodes + '''))) '+ @NewLineChar;
end 
---------------------subUnitType-----------------------------------------------------------------------------
if(@subUnitType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join subUnitType as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' +  @SubUnitTypeCodes  + ''' = ''-1'' or subUnitType.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' +  @SubUnitTypeCodes + '''))) '+ @NewLineChar;
end 
------------------Status------fromDate-----toDate----------------------------------------------------------------------------
if(@status = '1' or @statusFromDate = '1' or @statusToDate= '1')
begin 
	if(@status = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptStatus.Status as StatusCode, DIC_DeptStatus.statusDescription as StatusName ';
	end 

	if(@statusFromDate = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(VARCHAR(10), DeptStatus.FromDate, 103) AS StatusFromDate ';
	end 
	
--	if(@statusToDate = '1')
--	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(VARCHAR(10), DeptStatus.ToDate, 103) AS StatusToDate ';
--	end 

	set @sqlJoin = @sqlJoin +  ' left join DeptStatus on d.DeptCode = DeptStatus.DeptCode '+ @NewLineChar + 
							   ' inner join DIC_DeptStatus on DeptStatus.Status = DIC_DeptStatus.Status '+ @NewLineChar;
--	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' +  @StatusCodes  + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' +  @StatusCodes + '''))) '+ @NewLineChar;
end 
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join deptSimul on d.DeptCode = deptSimul.DeptCode '+ @NewLineChar;	
end 
-----------------City----Address--------------------------------------------------------------------
if(@city = '1' or @address = '1')
begin 
	
	if(@city = '1')
		begin 
			set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
			set @sql = @sql + ' Cities.CityCode, Cities.CityName '+ @NewLineChar;
		end

	if (@address = '1')
		begin 
			set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
			set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
		end
	
	set @sqlJoin = @sqlJoin +  ' left join Cities on d.CityCode =  Cities.CityCode '+ @NewLineChar;
end 
-----------------addressComment----------------------------------------------------------------------------------------
if(@addressComment = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.addressComment as AddressComment '+ @NewLineChar;
end 
---------Phone1---------------------------------------------------------------
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp1.prePrefix, dp1.Prefix,dp1.Phone ) as Phone1 '+ @NewLineChar;;

	set @sqlJoin = @sqlJoin +  ' left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  '+ @NewLineChar;
end 
----------Phone2--------------------------------------------------------------------------------
if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp2.prePrefix, dp2.Prefix, dp2.Phone) as Phone2 '+ @NewLineChar;;

	set @sqlJoin = @sqlJoin +  ' left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '+ @NewLineChar;
end 
----------Fax--------------------------------------------------------------------------------
if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp3.prePrefix, dp3.Prefix, dp3.Phone) as Fax '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '+ @NewLineChar;
end 
----------Email--------------------------------------------------------------------------------
if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end 
----------showEmailInInternet--------------------------------------------------------------------------------
if(@showEmailInInternet = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.showEmailInInternet as showEmailInInternet '+ @NewLineChar;
end 
---------SectorCode**---------------------------------------------------------------
if(@SectorCode = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' + @SectorCodes + ''' = ''-1'' or ps.PopulationSectorID IN (SELECT IntField FROM dbo.SplitString(''' + @SectorCodes + ''' )))' + @NewLineChar;
end 

---------transportation---------------------------------------------------------------
if(@transportation = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.transportation as transportation '+ @NewLineChar;
end 
-----------AccessToClinic---------------------------------------------------------------
if(@AccessToClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' case when DHC1.FacilityCode is not null then ''כן'' else ''לא'' end as AccessToClinic'+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DeptHandicappedFacilities as DHC1 on d.DeptCode = DHC1.DeptCode and DHC1.FacilityCode = 1 '+ @NewLineChar;
end 
-----------DisabledServices---------------------------------------------------------------
if(@DisabledServices = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
			when DHC2.FacilityCode is not null then ''כן''
			else ''לא''
		end as DisabledServices'+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DeptHandicappedFacilities as DHC2 on d.DeptCode = DHC2.DeptCode and DHC2.FacilityCode = 2 '+ @NewLineChar;
end 
-----------ElevatorOrOneFloorStructure---------------------------------------------------------------
if(@ElevatorOrOneFloorStructure = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
			when DHC3.FacilityCode is not null then ''כן''
			else ''לא''
		end as ElevatorOrOneFloorStructure'+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DeptHandicappedFacilities as DHC3 on d.DeptCode = DHC3.DeptCode and DHC3.FacilityCode = 3 '+ @NewLineChar;
end 
-----------ElectricBed---------------------------------------------------------------
if(@ElectricBed = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
			when DHC4.FacilityCode is not null then ''כן''
			else ''לא''
		end as ElectricBed '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DeptHandicappedFacilities as DHC4 on d.DeptCode = DHC4.DeptCode and DHC4.FacilityCode = 4 '+ @NewLineChar;
end 
-----------deptLevelDesc---------------------------------------------------------------
if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode '+ @NewLineChar;
end 
---------MangerName---------------------------------------------------------------
if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   

end ;
---------AdminMangerName---------------------------------------------------------------
if(@AdminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end 
-----------services of employees ---------------------------------------------------------------
if(@EmployeeServices = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' x_Dept_Employee_Service.serviceCode	as EmployeeServiceCode,		
		(select serviceDescription 
			from service 
			where '+
			'service.serviceCode = x_Dept_Employee_Service.serviceCode) as EmployeeServices '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join x_Dept_Employee_Service as x_Dept_Employee_Service on d.DeptCode = x_Dept_Employee_Service.deptCode  ' + @NewLineChar ;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '( '''+
				@ServiceCodes + ''' is null 
				OR
				( 
					SELECT COUNT(*)
					FROM x_Dept_Employee_Service 
					WHERE ''' + @ServiceCodes + ''' = ''-1'' or ' + 
					' serviceCode IN (SELECT IntField FROM dbo.SplitString(''' + @ServiceCodes + '''))
					AND d.deptCode = x_Dept_Employee_Service.deptCode

				) > 0
			)' + @NewLineChar;			
end 
-------------services of clinics ---------------------------------------------------------------
if(@DeptServices = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' x_dept_Service.serviceCode	as DeptServiceCode ,				
		dbo.fun_GetDeptServices(d.DeptCode) as DeptServices  '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' left join x_dept_Service as x_dept_Service on d.DeptCode = x_dept_Service.deptCode  ' + @NewLineChar ;

	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '('''+
				@ServiceCodes + ''' is null 
				OR
				( 
					SELECT COUNT(*)
					FROM x_dept_service 
					WHERE ''' + @ServiceCodes + ''' = ''-1'' or ' + 
					' serviceCode IN (SELECT IntField FROM dbo.SplitString(''' + @ServiceCodes + '''))
					AND d.deptCode = x_dept_service.deptCode

				) > 0
			)' + @NewLineChar;			
			
end 
-----------professions ---------------------------------------------------------------
--DIFFERENCE !!!
-- because this report different from original report ( not Excell) - each professions must be different row 
--in original report all professions must be in one line 
-- we have here two additional joins 
---
if(@professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' x_Dept_Employee_Profession.professionCode ,	professions.professionDescription ' + @NewLineChar;
	
	set @sqlJoin = @sqlJoin +  ' inner join x_Dept_Employee_Profession on  d.deptCode= x_Dept_Employee_Profession.deptCode ' + @NewLineChar ;
	set @sqlJoin = @sqlJoin +  ' inner join professions on x_Dept_Employee_Profession.professionCode = professions.professionCode ' + @NewLineChar ;

	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' + @ProfessionCodes + ''' = ''-1'' 
	OR
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Profession 
		WHERE deptCode = d.deptCode									
		AND professionCode IN 
		(SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)' + @NewLineChar;

end 
--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ,d.DeptName as ClinicName ' ;	
end 
---------------------@fromDateName-----------------------------------------------------------------------------
if(@fromDateName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' (select top 1 fromDate
			from dbo.DeptNames
			where fromDate <=getDate() and deptCode=d.DeptCode
			order by fromDate) as fromDateName '+ @NewLineChar;
end 
---finish 


--=================================================================
set @sql = @sql + @sqlFrom

if(len (@sqlJoin) > 1)
begin 
	set @sql = @sql + @sqlJoin 
end
if(len (@sqlWhere) > 6)
begin 
	set @sql = @sql + @sqlWhere
end

--==Sorting ========================================

if(@SortedBy is not  null)
begin 
set @sql = 'SELECT *,''RowNumber'' = CASE ''' + @SortedBy + ''''+ 
		   ' WHEN ''' + @SortedBy + ''' THEN '+ 
		   '	CASE ' + @IsOrderDescending +  
		   '		WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ' + @SortedBy + '  DESC )' +  
		   '		WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ' + @SortedBy + ' )' +  
		   '	END ' +  
		   'end
		
into #dd3 
FROM
(' + @sql+ ') as innerSelection ' ;

--
set @sql = @sql + ' select * from #dd3'+ 
		' drop table #dd3 ' + @NewLineChar ;

end 


PRINT @sql 
EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 
GO

GRANT EXEC ON rpc_getReportDeptsByTypesProfessionsDynamicExcell TO PUBLIC

GO

 