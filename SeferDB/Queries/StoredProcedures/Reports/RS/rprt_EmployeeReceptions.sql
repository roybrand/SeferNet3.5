IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeReceptions
	END
GO

CREATE Procedure [dbo].[rprt_EmployeeReceptions]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@CitiesCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@ServiceCodes varchar(max)=null,
	@ProfessionCodes varchar(max)=null,
	@PositionCodes varchar(max)=null,
	@ExpertProfessionCodes varchar(max)=null,
	@AgreementType_cond varchar(max)=null,
	@EmployeeSex_cond varchar(max)=null, 
	@ValidFrom_cond varchar(max)=null,
	@ValidTo_cond varchar(max)=null,

	@district varchar (2)= null,
	@adminClinic varchar (2) = null,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,

	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepWeekHoursSum varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@EmployeeLanguages varchar(2)= null,	

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
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
	@xCitiesCodes varchar(max)=null, 	 
	@xEmployeeSector_cond varchar(max)=null,	
	@xUnitTypeCodes varchar(max)=null,
	@xSubUnitTypeCodes varchar(max)=null,
	@xServiceCodes varchar(max)=null, 	 
	@xProfessionCodes varchar(max)=null,
	@xUnitedServiceCodes varchar(max)=null,	
	@xPositionCodes varchar(max)=null,
	@xExpertProfessionCodes varchar(max)=null,
	@xAgreementType_cond varchar(max)=null,
	@xValidFrom_cond varchar(max)=null,
	@xValidTo_cond varchar(max)=null	
'

SET @Declarations = ''

---------------------------

SET @sql = 'SELECT distinct * FROM (SELECT ' + @NewLineChar;
SET @sqlEnd = ') as resultTable '

if(@EmployeeName = '1')
	begin 
		SET @sqlEnd = @sqlEnd + ' order by EmployeeLastName'+ @NewLineChar;
	end

SET @SqlFrom = 'FROM Employee 
LEFT JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID '
if(@DistrictCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
if(@EmployeeSector_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) ) '
if(@EmployeeSex_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (Employee.Sex IN (SELECT IntField FROM dbo.SplitString(@xEmployeeSex_cond ))) '
if(@PositionCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Position 
			JOIN x_Dept_Employee xde
				on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
			WHERE Employee.employeeID = xde.employeeID	
			AND positionCode IN (SELECT IntField FROM dbo.SplitString( @xPositionCodes ))) > 0
		) '
if(@UnitedServiceCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 			
	' AND (
		(	SELECT count(*) 
			FROM EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID								
			AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0
		) '
if(@ExpertProfessionCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (
		(	SELECT count(*) 
			FROM  EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID AND EmployeeServices.expProfession = 1
			AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
		) '
if(@AgreementType_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@xAgreementType_cond ))) '

SET @SqlFrom = @SqlFrom +
' LEFT JOIN Dept as d ON d.deptCode = x_Dept_Employee.deptCode '
if(@AdminClinicCode <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.administrationCode in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
if(@UnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.typeUnitCode in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
if(@SubUnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) ) '
if(@CitiesCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
if(@adminClinic = '1') 
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN dept as dAdmin ON d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN dept as dDistrict ON Employee.primaryDistrict = dDistrict.deptCode '

SET @SqlFrom = @SqlFrom +
' LEFT JOIN View_UnitType as UnitType ON d.typeUnitCode =  UnitType.UnitTypeCode   
LEFT JOIN View_SubUnitTypes as SubUnitType ON d.subUnitTypeCode =  SubUnitType.subUnitTypeCode AND  d.typeUnitCode =  SubUnitType.UnitTypeCode '
if(@simul = '1')
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '

if(@EmployeeSector = '1')
	SET @SqlFrom = @SqlFrom +	
	' INNER JOIN View_EmployeeSector ON Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
--SET @SqlFrom = @SqlFrom +
--' LEFT JOIN dbo.View_DeptEmployeeReceptions AS V_DEReception 
--	ON x_Dept_Employee.deptCode = V_DEReception.deptCode
--	AND x_Dept_Employee.AgreementType = V_DEReception.AgreementType
--	AND x_Dept_Employee.employeeID = V_DEReception.employeeID '

SET @sqlFrom = @sqlFrom +  
' OUTER APPLY dbo.rfn_GetDeptEmployeeReception_Weekly_Sum(x_Dept_Employee.DeptEmployeeID, 
		isNull(@xValidFrom_cond, ''null''),
		IsNull(@xValidTo_cond, ''null'')  
		) AS [DeptReception] 
'


--if(@ValidFrom_cond <> '-1' OR @ValidTo_cond <> '-1')
--	SET @SqlFrom = @SqlFrom +		
--' JOIN Employee as Emp3 ON Employee.employeeID = Emp3.employeeID 
--	 AND[dbo].rfn_CheckExpirationDate_str
--	(CONVERT(varchar(10), V_DEReception.validFrom, 20),
--	 CONVERT(varchar(10), V_DEReception.validTo, 20), 
--	  IsNull(@xValidFrom_cond, null),
--	  IsNull(@xValidTo_cond, null)) = 1 '
if(@EmployeeExpertProfession = '1')
	SET @SqlFrom = @SqlFrom +	 
' LEFT JOIN [dbo].View_EmployeeExpertProfessions as DEExpProfessions 
	on Employee.employeeID = DEExpProfessions.employeeID '
if(@EmployeePosition = '1' )
	SET @SqlFrom = @SqlFrom +
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		ON x_Dept_Employee.deptCode = DEPositions.deptCode
		AND x_Dept_Employee.AgreementType = DEPositions.AgreementType
		AND Employee.employeeID = DEPositions.employeeID ' 
		
SET @SqlWhere = ' WHERE 1=1 AND x_Dept_Employee.active = 1 '

 
if(@EmployeeName = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@district = '1')
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		SET @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end
	
if(@adminClinic = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@EmployeePosition = '1' )
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeExpertProfession = '1')
	begin
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

	
if (@EmployeeSex = '1')
begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end


------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@EmployeeServices = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'DeptReception.serviceDescription  as serviceDescription,
	 DeptReception.serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @EmployeeProfessions -------------------------------------------------------

if(@EmployeeProfessions = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + 'DeptReception.ProfessionDescription  as ProfessionDescription,
	 DeptReception.ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		SET @sql = @sql + ' DeptReception.ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 
		

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' DeptReception.openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' DeptReception.closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' DeptReception.totalHours  as totalHours ' + @NewLineChar;
end 

if(@RecepWeekHoursSum = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' DeptReception.WeekHoursSum  as WeekHoursSum ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' CONVERT(varchar(10), DeptReception.validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' CONVERT(varchar(10), DeptReception.validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	SET @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	SET @sql = @sql + ' DeptReception.remarkText  as RecepRemark ' + @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 

--=================================================================
set @sql = @sql + @SqlFrom + @sqlWhere + @sqlEnd
 
SET @sql = 'SET DATEFORMAT dmy ' + @NewLineChar + @sql + @NewLineChar + 'SET DATEFORMAT mdy;'

--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 
			
SET DATEFORMAT dmy;

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xCitiesCodes = @CitiesCodes,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xUnitTypeCodes = @UnitTypeCodes,			
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xServiceCodes = @ServiceCodes,	
	@xProfessionCodes = @ProfessionCodes,
	@xUnitedServiceCodes = @UnitedServiceCodes,			
	@xPositionCodes = @PositionCodes,
	@xExpertProfessionCodes = @ExpertProfessionCodes,
	@xAgreementType_cond = @AgreementType_cond,
	@xValidFrom_cond = @ValidFrom_cond,	
	@xValidTo_cond = @ValidTo_cond

SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 
GO

GRANT EXEC ON [dbo].rprt_EmployeeReceptions TO PUBLIC
GO