IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_ReportgetDeptsByTypesServicesDynamic')
	BEGIN
		DROP  Procedure  rpc_ReportgetDeptsByTypesServicesDynamic
	END

GO

create Procedure [dbo].[rpc_ReportgetDeptsByTypesServicesDynamic]
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

	 ------------------------------------------- 
	 
	@district varchar (1)= null,	
	@adminClinic varchar (1) = null ,	
	@subAdminClinic varchar (1)=null, 
	@unitType varchar (1)=null,		
	@subUnitType varchar (1)=null,	
	@simul varchar (1)=null,	
	@city varchar (1)=null,	
	@address varchar (1)=null,	
	@Phone1 varchar (1)=null,
	@Phone2 varchar (1)=null,
	@Fax varchar (1)=null,
	@Email varchar (1)=null,
	@SectorCode varchar (1)=null,	 
	@deptLevelDesc varchar (1)=null,
	@MangerName varchar (1)=null,
	@AdminMangerName varchar (1)=null,
	@EmployeeServices varchar (1)=null,
	@DeptServices varchar (1)=null,
	@serviceIsGivenByPersons varchar (1)=null,
	@professions varchar (1)=null,
	@ClinicName varchar (1)=null,		
	@ErrCode VARCHAR(4000) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
set @NewLineChar = ''

--set variables 
declare  @sql nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlJoin nvarchar(max)
declare  @sqlWhere nvarchar(max)

---------------------------
set @sql = ' SELECT distinct ';
set @sqlFrom = ' from dept  as d  ';
set @sqlJoin = ' ';
set @sqlWhere = 'WHERE ';

--==============================================
-- select columns
--==============================================

---------------adminClinic----------------------------------------------------			
if(@adminClinic = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dAdmin.DeptName as AdminClinicName , isNull(dAdmin.DeptCode , -1) as AdminClinicCode ' ;

	set @sqlJoin = @sqlJoin +  ' left join dept as dAdmin on d.administrationCode = dAdmin.deptCode  ' ;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(''' +  @AdminClinicCode  + ''' = ''-1'' or dAdmin.DeptCode  in (SELECT IntField FROM dbo.SplitString( ''' +  @AdminClinicCode + '''))) ';
end 

-------------district----------------------------------
if(@district = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
	set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode ' ;
	
	
	set @sqlJoin = @sqlJoin +  ' left join dept as dDistrict on d.districtCode = dDistrict.deptCode ' ;

	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '( '''+ @DistrictCodes + ''' = ''-1'' or dDistrict.deptCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + '''))) '   ;
end


-----------------UnitType-----------------------------------------------------------
if(@unitType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode,UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(' +  @UnitTypeCodes  + ' = ''-1'' or UnitType.UnitTypeCode  in (SELECT IntField FROM dbo.SplitString( ' +  @UnitTypeCodes + '))) '+ @NewLineChar;
end 

---------------------subUnitType-----------------------------------------------------------------------------
if(@subUnitType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' subUnitType.subUnitTypeCode as subUnitTypeCode, subUnitType.subUnitTypeName as subUnitTypeName '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join subUnitType as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(' +  @SubUnitTypeCodes  + ' = ''-1'' or subUnitType.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ' +  @SubUnitTypeCodes + '))) '+ @NewLineChar;
end 
--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ,d.DeptName as ClinicName ' ;	
end 

---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join deptSimul on d.DeptCode = deptSimul.DeptCode '+ @NewLineChar;	
end 

---------------SubAdminClinic----------------------------------------------------------------------------
if(@subAdminClinic = '1')
begin 
set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;

set @sqlJoin = @sqlJoin +  'inner join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode '+ @NewLineChar;
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
	
	set @sqlJoin = @sqlJoin +  ' inner join Cities on d.CityCode =  Cities.CityCode '+ @NewLineChar;
end 
---------Phone1---------------------------------------------------------------
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp1.prePrefix, dp1.Prefix,dp1.Phone ) as Phone1 '+ @NewLineChar;;

	set @sqlJoin = @sqlJoin +  ' inner join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  '+ @NewLineChar;
end 
----------Phone2--------------------------------------------------------------------------------
if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp2.prePrefix, dp2.Prefix, dp2.Phone) as Phone2 '+ @NewLineChar;;

	set @sqlJoin = @sqlJoin +  ' inner join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 '+ @NewLineChar;
end 
----------Fax--------------------------------------------------------------------------------
if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_FormatPhoneReverse(dp3.prePrefix, dp3.Prefix, dp3.Phone) as Fax '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 '+ @NewLineChar;
end 
----------Email--------------------------------------------------------------------------------
if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end 
---------SectorCode**---------------------------------------------------------------
if(@SectorCode = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID '+ @NewLineChar;
	
	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(' + @SectorCodes + ' = ''-1'' or ps.PopulationSectorID IN (SELECT IntField FROM dbo.SplitString(' + @SectorCodes + ' )))' + @NewLineChar;
end 

-----------deptLevelDesc---------------------------------------------------------------
if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;

	set @sqlJoin = @sqlJoin +  ' inner join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode '+ @NewLineChar;
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
	set @sql = @sql + '  isNull(x_Dept_Employee_Service.serviceCode , -1)	as EmployeeServiceCode,		
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
------------serviceIsGivenByPerson-------------------------------------
if(@serviceIsGivenByPersons = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' (select PersonsName from dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes(d.DeptCode)) as ''serviceIsGivenByPerson''' + @NewLineChar;
	set @sqlJoin = @sqlJoin +  ' inner join rfn_GetReportServiceDetailsForDeptsByServicesTypes as x_dept_Service on d.DeptCode = dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes(d.DeptCode)  ' + @NewLineChar ;

end 

-----------professions ---------------------------------------------------------------
if(@professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_GetDeptProfessionsCodes_New(d.DeptCode) as ''professionDescription''' + @NewLineChar;

	set @sqlWhere = dbo.SqlDynamicWhereAndSeparator(@sqlWhere);
	set @sqlWhere = @sqlWhere + '(' + @ProfessionCodes + ' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Profession 
		WHERE deptCode = d.deptCode									
		AND professionCode IN 
		(SELECT IntField FROM dbo.SplitString( ' + @ProfessionCodes + ' ))) > 0
	)' + @NewLineChar;

end 
---------------------------------------------------


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




PRINT @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 
GO

GRANT EXEC ON dbo.rpc_ReportgetDeptsByTypesServicesDynamic TO PUBLIC

GO

/* declare @DeptCode int 
set @DeptCode=43300


SELECT  
x_D_E_S.serviceCode,
service.serviceDescription,
'phones' = '',
--'queueOrderManner' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;') + ' ' + DIC_QueueOrderMethod.QueueOrderMethodDescription  ,					

'queueOrderManner' = case 
when x_dept_employee.QueueOrder =3 then  IsNull(DIC_QueueOrderMethod.QueueOrderMethodDescription, '&nbsp;')
else IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;')  + ' ' +  IsNull(DIC_QueueOrderMethod.QueueOrderMethodDescription, '&nbsp;')  
end ,

'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'serviceIsGivenByPerson' = x_dept_employee.employeeID,
'PersonsName' = DegreeName + ' ' + firstName + ' ' + lastName,
service.showOrder,
'employeeID' = x_dept_employee.employeeID

FROM x_dept_employee

INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee_Service as x_D_E_S 
		ON x_dept_employee.deptCode = x_D_E_S.deptCode 	AND x_dept_employee.employeeID = x_D_E_S.employeeID
INNER JOIN service	ON x_D_E_S.serviceCode = service.serviceCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder
left JOIN EmployeeQueueOrderMethod 
		ON x_dept_employee.deptCode = EmployeeQueueOrderMethod.deptCode 	AND 
		   x_dept_employee.employeeID = EmployeeQueueOrderMethod.employeeID

left join DIC_QueueOrderMethod on EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod


WHERE x_dept_employee.deptCode = @DeptCode


union 


select x_D_S.serviceCode,
service.serviceDescription,
'phones' = dbo.fun_getDeptServicePhones(43300, x_D_S.serviceCode),
'queueOrderManner' = case 
when x_D_S.QueueOrder =3 then  IsNull(DIC_QueueOrderMethod.QueueOrderMethodDescription, '&nbsp;')
else IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;')  + ' ' +  IsNull(DIC_QueueOrderMethod.QueueOrderMethodDescription, '&nbsp;')  
end ,
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'serviceIsGivenByPerson' = 0,
'PersonsName' = 'צוות מרפאה',
service.showOrder,
'employeeID'= ''
FROM x_dept_service AS x_D_S
INNER JOIN	service	ON x_D_S.serviceCode = service.serviceCode
LEFT JOIN ServiceQueueOrderMethod ON x_D_S.serviceCode = ServiceQueueOrderMethod.serviceCode
	AND x_D_S.deptCode = ServiceQueueOrderMethod.deptCode
	--AND ServiceQueueOrderMethod.QueueOrderMethod = 1
LEFT JOIN DIC_QueueOrder ON  x_D_S.QueueOrder = DIC_QueueOrder.QueueOrder
left join DIC_QueueOrderMethod on ServiceQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod

WHERE x_D_S.deptCode =43300
*/