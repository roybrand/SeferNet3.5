IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptsByTypesProfessions_PagedSorted_Excell')
	BEGIN
		DROP  Procedure  rpc_getDeptsByTypesProfessions_PagedSorted_Excell
	END

GO

create Procedure [dbo].[rpc_getDeptsByTypesProfessions_PagedSorted_Excell]

(
	@ProfessionCodes varchar(50)=null,
	 --@DeptServiceCodes varchar(50)=null,
	 @DistrictCodes varchar(50)=null,
	 @AdminClinicCode int =null,
	 @CitiesCodes varchar(20)=null,
	 @StatusCodes varchar(20)=null,
	 @UnitTypeCodes varchar(20)=null,
	 @SubUnitTypeCodes varchar(20)=null,
	 @SectorCodes varchar(20)=null,
	 @ServiceCodes varchar(20)=null,
	---------------------------------
	---------------------------------
	 @PageSise int =null,
	 @StartingPage int =null,
	
	------------------------------------------
	@SortedBy varchar(50)=null,	
	@IsOrderDescending int =null
-----------------------------------------
)with recompile

AS

----set @ProfessionCodes = '63,31'
--set @ProfessionCodes = null
--set @DeptServiceCodes = null
--set @DistrictCodes = null
----set @AdminClinicCode = 41000
--set @CitiesCodes  =null
--SET @StatusCodes = null
--SET @UnitTypeCodes = null
--SET @SectorCodes = null
--set @ServiceCodes = '103,104,106'
--
--
--set @PageSise =10
--set @StartingPage =0
--set @SortedBy =null
--set @IsOrderDescending = 1

DECLARE @SortedByDefault varchar(50)
if(@SortedByDefault is null)
	BEGIN 
		SET @SortedByDefault = 'DistrictName'
	END	

IF (@AdminClinicCode =-1)
	BEGIN 
		SET @AdminClinicCode = null; 
	END

IF (@SortedBy is null)
	BEGIN 
		SET @SortedBy = @SortedByDefault ;
	END
	
print @SortedBy

-- @StartingPage enumeration starts from 1. Here we start from  0
if @StartingPage > 0
begin 
	SET @StartingPage = @StartingPage - 1
END 

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)


SELECT *, 

'RowNumber' = CASE @SortedBy 
			WHEN 'SubAdminClinicName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY SubAdminClinicName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY SubAdminClinicName   )
				END
			WHEN 'DistrictName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY DistrictName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY DistrictName   )
				END
			WHEN 'AdminClinicName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY AdminClinicName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY AdminClinicName   )
				END
			WHEN 'UnitTypeName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY UnitTypeName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY UnitTypeName   )
				END
			WHEN 'ClinicName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ClinicName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ClinicName  )
				END
			WHEN 'subUnitTypeName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY subUnitTypeName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY subUnitTypeName  )
				END
			WHEN 'StatusName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY StatusName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY StatusName  )
				END
			WHEN 'CityName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY CityName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY CityName  )
				END
			WHEN 'ClinicAddress' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ClinicAddress  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ClinicAddress  )
				END
			WHEN 'AddressComment' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY AddressComment  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY AddressComment  )
				END
			WHEN 'Phone1' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY Phone1  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY Phone1  )
				END
			WHEN 'Phone2' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY Phone2  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY Phone2  )
				END
			WHEN 'Fax' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY Fax  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY Fax  )
				END
			WHEN 'Email' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY Email  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY Email  )
				END
			WHEN 'showEmailInInternet' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY showEmailInInternet  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY showEmailInInternet  )
				END
			WHEN 'SectorName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY SectorName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY SectorName  )
				END 
			WHEN 'transportation' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY transportation  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY transportation  )
				END 
			WHEN 'MangerName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY MangerName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY MangerName  )
				END 
			WHEN 'AdminMangerName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY AdminMangerName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY AdminMangerName  )
				END 
			WHEN 'professionDescription' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY professionDescription  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY professionDescription  )
				END 
				WHEN 'AccessToClinic' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY AccessToClinic  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY AccessToClinic  )
				END 
			WHEN 'DisabledServices' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY DisabledServices  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY DisabledServices  )
				END 
			WHEN 'ElevatorOrOneFloorStructure' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ElevatorOrOneFloorStructure  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ElevatorOrOneFloorStructure  )
				END 
			WHEN 'ElectricBed' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ElectricBed  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ElectricBed  )
				END 
			WHEN 'EmployeeServices' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY EmployeeServices  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY EmployeeServices  )
				END 
			WHEN 'DeptServices' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY DeptServices  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY DeptServices  )
				END 			
			ELSE
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY DistrictName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY DistrictName   )
				END
			END	
into #dd3 
FROM
-- inner selection - 
(
	Select distinct d.deptCode as ClinicCode ,						 d.DeptName as ClinicName,  
			dDistrict.DeptName as DistrictName,				 dDistrict.deptCode as DistrictCode, 
			dAdmin.DeptName as AdminClinicName ,			 dAdmin.DeptCode as AdminClinicCode, 
			dSubAdmin.DeptName as SubAdminClinicName ,	
			UnitType.UnitTypeName as UnitTypeName,			 UnitType.UnitTypeCode as UnitTypeCode, 
			subUnitType.subUnitTypeName as subUnitTypeName,	 subUnitType.subUnitTypeCode as subUnitTypeCode, 
			DIC_DeptStatus.statusDescription as StatusName , DeptStatus.Status as StatusCode ,			
			CONVERT(VARCHAR(10), DeptStatus.FromDate, 103) AS StatusFromDate ,			
			CONVERT(VARCHAR(10), DeptStatus.ToDate, 103) AS StatusToDate ,
			deptSimul.Simul228 as Code228,  
			Cities.CityCode, Cities.CityName ,
			dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress, 
			
			d.addressComment as AddressComment, 
			dbo.rfn_FormatPhoneReverse(dp1.prePrefix, dp1.Prefix,dp1.Phone ) as Phone1, 
			dbo.rfn_FormatPhoneReverse(dp2.prePrefix, dp2.Prefix, dp2.Phone) as Phone2, 
			dbo.rfn_FormatPhoneReverse(dp3.prePrefix, dp3.Prefix, dp3.Phone) as Fax ,  
			d.Email as Email , 
			d.showEmailInInternet as showEmailInInternet, 
			ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName  , 
			d.transportation as transportation , 
		case 
			when DHC1.FacilityCode is not null then 'כן'
			else 'לא'
		end as AccessToClinic, 
		case 
			when DHC2.FacilityCode is not null then 'כן'
			else 'לא'
		end as DisabledServices, 
		case 
			when DHC3.FacilityCode is not null then 'כן'
			else 'לא'
		end as ElevatorOrOneFloorStructure, 
		case 
			when DHC4.FacilityCode is not null then 'כן'
			else 'לא'
		end as ElectricBed, 
		
		ddl.deptLevelDescription as deptLevelDesc,  
		case 
			when tblDeptManager.EmployeeID is not null then dbo.rfn_FormatEmployeeName(tblEmpManager.FirstName, tblEmpManager.LastName, tblEmpManager.DegreeCode)
			else d.managerName
		end as MangerName , 
		case 
			when tblAdminDeptManager.EmployeeID is not null then dbo.rfn_FormatEmployeeName(tblAdminEmpManager.FirstName, tblAdminEmpManager.LastName, tblAdminEmpManager.DegreeCode)
			else d.administrativeManagerName
		end as AdminMangerName , 
				
		x_Dept_Employee_Profession.professionCode ,
		professions.professionDescription	,
		
		(select top 1 fromDate
			from dbo.DeptNames
			where fromDate <=getDate() and deptCode=d.DeptCode
			order by fromDate) as fromDateName	,
		
			--services of employees 
		x_Dept_Employee_Service.serviceCode	as EmployeeServiceCode,		
		(select serviceDescription 
			from service 
			where service.serviceCode = x_Dept_Employee_Service.serviceCode) as EmployeeServices ,		
		
		--services of clinics
		x_dept_Service.serviceCode	as DeptServiceCode ,						
		(select serviceDescription 
			from service 
			where service.serviceCode = x_dept_Service.serviceCode) as DeptServices

			
		from dept  as d  
		left join dept as dDistrict on d.districtCode = dDistrict.deptCode
		left join dept as dAdmin on d.administrationCode = dAdmin.deptCode
		left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode

		left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode 
		left join subUnitType as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
		left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
		left join DIC_DeptStatus on DeptStatus.Status = DIC_DeptStatus.Status 
		left join deptSimul on d.DeptCode = deptSimul.DeptCode 
		left join Cities on d.CityCode =  Cities.CityCode
		left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 
		left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2
		left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1
		left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 
		left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode 

		left join DeptHandicappedFacilities as DHC1 on d.DeptCode = DHC1.DeptCode and DHC1.FacilityCode = 1
		left join DeptHandicappedFacilities as DHC2 on d.DeptCode = DHC2.DeptCode and DHC2.FacilityCode = 2
		left join DeptHandicappedFacilities as DHC3 on d.DeptCode = DHC3.DeptCode and DHC3.FacilityCode = 3
		left join DeptHandicappedFacilities as DHC4 on d.DeptCode = DHC4.DeptCode and DHC4.FacilityCode = 4
		
		left join x_Dept_Employee_Position as tblDeptManager on d.DeptCode = tblDeptManager.deptCode and tblDeptManager.PositionCode = 13 
		left join Employee as tblEmpManager on  tblDeptManager.EmployeeID = tblEmpManager.EmployeeID
		left join x_Dept_Employee_Position as tblAdminDeptManager on d.DeptCode = tblAdminDeptManager.deptCode and tblDeptManager.PositionCode = 5
		left join Employee as tblAdminEmpManager on  tblAdminDeptManager.EmployeeID = tblAdminEmpManager.EmployeeID
		left join x_Dept_Employee_Profession on  d.deptCode= x_Dept_Employee_Profession.deptCode
		left join professions on x_Dept_Employee_Profession.professionCode = professions.professionCode

		--services of employees 
		left join x_Dept_Employee_Service as x_Dept_Employee_Service on d.DeptCode = x_Dept_Employee_Service.deptCode 
		--INNER JOIN service	ON x_Dept_Employee_Service.serviceCode = service.serviceCode
		
		--services of clinics
		left join x_dept_Service as x_dept_Service on d.DeptCode = x_dept_Service.deptCode 
		--INNER JOIN service as service2	ON x_dept_Service.serviceCode = service.serviceCode


		WHERE 
		(@DistrictCodes is null or dDistrict.deptCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
		and ( @AdminClinicCode is null or dAdmin.DeptCode = @AdminClinicCode )
		and ( @CitiesCodes  is null or Cities.CityCode IN (SELECT IntField FROM dbo.SplitString(@CitiesCodes)))
		AND ( @StatusCodes is null or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString(@StatusCodes)))
		AND ( @UnitTypeCodes is null or UnitType.UnitTypeCode IN (SELECT IntField FROM dbo.SplitString(@UnitTypeCodes)))
		AND ( @SubUnitTypeCodes is null or subUnitType.subUnitTypeCode IN (SELECT IntField FROM dbo.SplitString(@SubUnitTypeCodes)))
		and ( @SectorCodes is null or ps.PopulationSectorID IN (SELECT IntField FROM dbo.SplitString(@SectorCodes)))
		AND (
				@ServiceCodes is null 
				OR
				( 
					SELECT COUNT(*) FROM x_dept_service 
					WHERE serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes))
					AND d.deptCode = x_dept_service.deptCode

				) > 0
			)
	AND (@ProfessionCodes is null 
	OR 
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Profession 
		WHERE deptCode = d.deptCode									
		AND professionCode IN 
		(SELECT IntField FROM dbo.SplitString(@ProfessionCodes))) > 0
	)	

) as innerSelection  




 SELECT  * FROM #dd3
ORDER BY RowNumber	


GO

GO

GRANT EXEC ON rpc_getDeptsByTypesProfessions_PagedSorted_Excell TO PUBLIC

GO


