IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_Employees')
	BEGIN
		DROP  Procedure  dbo.rprt_Employees
	END
GO

CREATE Procedure [dbo].[rprt_Employees]
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
	@EmployeeLanguage_cond varchar(max)=null, 
	@EmployeeSex_cond varchar(max)=null, 
	@StatusCodes varchar(max)=null,
	@DeptEmployeeStatusCodes varchar(max)=null,

	@district varchar (2)= null,	
	@ClinicDistrict varchar (2)= null,
	@adminClinic varchar (2) = null,		 
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, --  Dept QueueOrderDescription 

	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@EmployeeEmail varchar (2)=null,
	@ShowEmployeeEmailInInternet varchar (2)=null,
	@EmployeeHomePhone varchar (2)=null,
	@EmployeeCellPhone varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@EmployeeDegree varchar(2)= null,
	@EmployeeStatus varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	
	@EmployeeLanguages varchar(2)= null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(4000) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @params nvarchar(max)
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
	@xEmployeeLanguage_cond varchar(max)=null, 
	@xEmployeeSex_cond varchar(max)=null, 
	@xStatusCodes varchar(max)=null,
	@xDeptEmployeeStatusCodes varchar(max)=null
'

---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 'FROM Employee 
LEFT JOIN x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
LEFT JOIN Dept as d on d.deptCode = x_Dept_Employee.deptCode '

if(@EmployeeStatus = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active '
if(@DeptEmployeeStatus = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	'JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active '
if (@AgreementType = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	'JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID '
if(@EmployeeLanguage_cond <> '-1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar +
	' LEFT JOIN EmployeeLanguages on EmployeeLanguages.EmployeeID = Employee.employeeID '
if(@adminClinic = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode '
if(@district = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN dept as dDistrict on Employee.primaryDistrict = dDistrict.deptCode '
if(@ClinicDistrict = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN dept as deptDistrict on d.DistrictCode = deptDistrict.deptCode '
if(@simul = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode '
if(@city = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN Cities on d.CityCode =  Cities.CityCode ' 
SET @sqlFrom = @sqlFrom + @NewLineChar + 	
' cross apply rfn_GetDeptEmployeeQueueOrderDetails(x_Dept_Employee.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails '
if(@EmployeeSector = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode '
if(@EmployeeDegree = '1')	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode '

if(@DeptEmployeePhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
'LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1
LEFT JOIN DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
LEFT JOIN DeptPhones as deptPh1  
	on d.deptCode = deptPh1.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh1.PhoneType = 1 and deptPh1.phoneOrder = 1  
LEFT JOIN DeptPhones as deptPh2  
	on d.deptCode = deptPh2.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh2.PhoneType = 1 and deptPh2.phoneOrder = 2 '

if(@DeptEmployeeFax = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID 
		and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
	LEFT JOIN DeptPhones as deptPh3 
		on d.deptCode = deptPh3.deptCode 
		and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
		and deptPh3.PhoneType = 2 and deptPh3.phoneOrder = 1 '

if(@EmployeeHomePhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	'LEFT JOIN EmployeePhones as  EmployeePhones1  on  Employee.employeeID = EmployeePhones1.employeeID 
	and EmployeePhones1.PhoneType = 1 and EmployeePhones1.phoneOrder = 1 '
if(@EmployeeCellPhone = '1')
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	 
	' LEFT JOIN EmployeePhones as EmployeePhones2  on Employee.employeeID = EmployeePhones2.employeeID 
	and EmployeePhones2.PhoneType = 3 and EmployeePhones2.phoneOrder = 1 '
if(@EmployeeProfessions = '1' )
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN [dbo].View_EmployeeProfessions as DEProfessions	
		on Employee.employeeID = DEProfessions.employeeID '
if(@EmployeeExpertProfession = '1') 		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	'LEFT JOIN [dbo].View_EmployeeExpertProfessions as DEExpProfessions 
		on Employee.employeeID = DEExpProfessions.employeeID '
if(@EmployeePosition = '1' ) 	
	SET @sqlFrom = @sqlFrom + @NewLineChar + 
	' LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID '
if(@EmployeeServices = '1' )		
	SET @sqlFrom = @sqlFrom + @NewLineChar + 	
	' LEFT JOIN [dbo].View_EmployeeServices as DEServices 
		on Employee.employeeID = DEServices.employeeID '
if(@DeptEmployeeRemark = '1' )  -- changed		
	SET @sqlFrom = @sqlFrom + @NewLineChar +	
	'LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and x_Dept_Employee.employeeID = DERemarks.employeeID '
		
SET @sqlWhere = ' WHERE 1=1 ';
if(@DistrictCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) ) '
if(@EmployeeSector_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSector_cond )) ) '
if(@EmployeeSex_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.Sex IN (SELECT IntField FROM dbo.SplitString( @xEmployeeSex_cond ))) '
if(@StatusCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (Employee.active IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '
if(@PositionCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (
		(	SELECT count(*) 
			FROM x_Dept_Employee_Position 
			inner join x_Dept_Employee xde
			on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
			WHERE Employee.employeeID = xde.employeeID	
			AND positionCode IN (SELECT IntField FROM dbo.SplitString( @xPositionCodes ))) > 0
		) '
if(@UnitedServiceCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 		
	' AND (
		(	SELECT count(*) 
			FROM EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID								
			AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xUnitedServiceCodes ))) > 0
		) '
if(@ExpertProfessionCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	
	' AND (
		(	SELECT count(*) 
			FROM  EmployeeServices 
			WHERE Employee.employeeID = EmployeeServices.employeeID 	and EmployeeServices.expProfession = 1
			and EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( @xExpertProfessionCodes ))) > 0
		) '
if(@AdminClinicCode <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (d.administrationCode  in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
if(@UnitTypeCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
if(@SubUnitTypeCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) ) '
if(@CitiesCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) ) '
if(@AgreementType_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 	 
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) '
if(@DeptEmployeeStatusCodes <> '-1')
	SET @sqlWhere = @sqlWhere + 		 
	' AND (x_Dept_Employee.active IN (SELECT IntField FROM dbo.SplitString( @xDeptEmployeeStatusCodes )) ) '
if(@EmployeeLanguage_cond <> '-1')
	SET @sqlWhere = @sqlWhere + 
	' AND (EmployeeLanguages.LanguageCode IN (SELECT IntField FROM dbo.SplitString( @xEmployeeLanguage_cond )) ) '

if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '
		+ @NewLineChar;
	end
	
if(@ClinicDistrict = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + 'deptDistrict.DeptName as ClinicDistrictName , isNull(deptDistrict.deptCode , -1) as ClinicDistrictCode '
		+ @NewLineChar;
	end	

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 	

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if (@AgreementType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
			+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
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

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	

if(@EmployeePosition = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeProfessions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@EmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end

if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh1.prePrefix, deptPh1.Prefix, deptPh1.Phone, deptPh1.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh2.prePrefix, deptPh2.Prefix, deptPh2.Phone, deptPh2.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
end

if(@DeptEmployeeFax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh3.prePrefix, deptPh3.Prefix, deptPh3.Phone, deptPh3.Extension ) 
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
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

--------- homePhone ---------------------------------------------------------------
if(@EmployeeHomePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones1.prePrefix, EmployeePhones1.Prefix,EmployeePhones1.Phone, EmployeePhones1.extension ) as EmployeePrivatePhone1, 
				case when EmployeePhones1.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone1_isUnlisted'
				+ @NewLineChar;
end

---------- cellPhone --------------------------------------------------------------------------------
if(@EmployeeCellPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones2.prePrefix, EmployeePhones2.Prefix, EmployeePhones2.Phone, EmployeePhones2.extension) as EmployeePrivatePhone2, 
			case when EmployeePhones2.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone2_isUnlisted'
			+ @NewLineChar;
end 
---------- EmployeeLanguages --------------------------------------------------------------------------------
if(@EmployeeLanguages = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_GetEmployeeLanguages(Employee.employeeID) as EmployeeLanguages' 
			+ @NewLineChar;
end 

--=================================================================
set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 


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
	@xEmployeeLanguage_cond = @EmployeeLanguage_cond,
	@xEmployeeSex_cond = @EmployeeSex_cond,	
	@xStatusCodes = @StatusCodes,
	@xDeptEmployeeStatusCodes = @DeptEmployeeStatusCodes
	
SET @ErrCode = @sql 
RETURN 
GO

GRANT EXEC ON [dbo].rprt_Employees TO PUBLIC
GO
