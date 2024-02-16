IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndPharmacyReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndPharmacyReceptionDifferences
	END
GO

CREATE Procedure [dbo].[rprt_DeptAndPharmacyReceptionDifferences]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
    @Membership_cond varchar(max)=null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

--SET variables 
DECLARE @params nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)
DECLARE @declarations nvarchar(max)
SET @declarations = ' DECLARE @currentDate datetime SET @currentDate = GETDATE() ' + @NewLineChar

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		SET @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		SET @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
		
SET DATEFORMAT dmy;

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,	
	@xReceptionHoursSpan_cond varchar(max)=null,
	@xMembership_cond varchar(max)=null 
'

SET @sql = 'SELECT distinct * FROM (SELECT ' + @NewLineChar;
SET @sqlEnd = ') AS resultTable order by DeptCode, ClinicCode, ReceptionDayName ' + @NewLineChar;
SET @SqlWhere = ''

SET @sql = @sql +
 'dDistrict.DeptName as DistrictName 
, isNull(dDistrict.deptCode , -1) as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, isNull(dAdmin.DeptCode , -1) as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity 
,case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam
,case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital


,SubClinics.DeptName as SubClinicName 
,SubClinics.deptCode as SubClinicCode 
,SubClinicDeptSimul.Simul228 as SubClinicCode228 
,SubClinicUnitType.UnitTypeCode as SubClinicUnitTypeCode , SubClinicUnitType.UnitTypeName as SubClinicUnitTypeName 
,case when SubClinics.IsCommunity = 1 then ''כן'' else ''לא'' end as SubClinicIsCommunity 
,case when SubClinics.IsMushlam = 1 then ''כן'' else ''לא'' end as 	SubClinicIsMushlam
,case when SubClinics.IsHospital = 1 then ''כן'' else ''לא'' end as SubClinicIsHospital

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName
' + @NewLineChar +
	'  ,(SELECT stuff((	SELECT distinct '' '' + cast(openingHour as varchar(5)) + ''-'' + cast(closingHour as varchar(5)) + ''; ''
						FROM DeptReception DR
						WHERE DR.deptCode = d.DeptCode
						AND DR.receptionDay = DeptReception.receptionDay
						AND DR.validFrom <= @currentDate 
						AND DR.ReceptionHoursTypeID = 1							
						for xml path('''')),1,1,''''
						)) as deptReceptions 
	  ,(SELECT stuff((	SELECT distinct '' '' + cast(openingHour as varchar(5)) + ''-'' + cast(closingHour as varchar(5)) + ''; ''
						FROM DeptReception DR
						WHERE DR.deptCode = SubClinics.DeptCode
						AND DR.receptionDay = DeptReception.receptionDay
						AND DR.validFrom <= @currentDate 
						AND DR.ReceptionHoursTypeID = 1							
						for xml path('''')),1,1,''''
						)) as subDeptReceptions '
+ @NewLineChar +
'--,dbo.rfn_GetDeptReceptionsString(d.DeptCode, DeptReception.receptionDay, 1) as  deptReceptions
--,dbo.rfn_GetDeptReceptionsString(SubClinics.DeptCode, DeptReception.receptionDay, 1) as  subDeptReceptions
,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum 
'

SET @SqlFrom = 
' FROM Dept as d    
JOIN Dept as SubClinics ON d.deptCode = SubClinics.subAdministrationCode 
	AND d.status = 1
	AND SubClinics.status = 1 '
IF(@Membership_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (
		 d.IsCommunity = 1 AND 1 in (SELECT IntField FROM dbo.SplitString(  @xMembership_cond ))
		or d.IsMushlam = 1 AND 2 in (SELECT IntField FROM dbo.SplitString(  @xMembership_cond))
		or d.IsHospital = 1 AND 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		)'
IF(@Membership_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND ( 
		 SubClinics.IsCommunity = 1 AND 1 in (SELECT IntField FROM dbo.SplitString(  @xMembership_cond ))
		or SubClinics.IsMushlam = 1 AND 2 in (SELECT IntField FROM dbo.SplitString(  @xMembership_cond))
		or SubClinics.IsHospital = 1 AND 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		)'
IF(@DistrictCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	'AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString(@xDistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode))
		'
IF(@AdminClinicCode <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 								   
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode)) )'
SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (SubClinics.typeUnitCode  = 401 )-- pharmacy '
	
SET @SqlFrom = @SqlFrom + @NewLineChar + 	
' left JOIN Dept as dDistrict ON d.districtCode = dDistrict.deptCode 
left JOIN Dept as dAdmin ON d.administrationCode = dAdmin.deptCode    
left JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode 	

left JOIN View_UnitType as SubClinicUnitType ON SubClinics.typeUnitCode =  SubClinicUnitType.UnitTypeCode  
left JOIN deptSimul as SubClinicDeptSimul ON SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 

left JOIN DeptReception ON d.deptCode = DeptReception.deptCode
JOIN DIC_ReceptionDays ON DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

left JOIN DeptReception as SubClinicDeptReception ON SubClinics.deptCode = SubClinicDeptReception.deptCode
AND DeptReception.receptionDay = SubClinicDeptReception.receptionDay

cross apply rfn_GetDeptsReceptionIntervalNonIntersection(d.deptCode, SubClinics.deptCode, DeptReception.receptionDay, @xReceptionHoursSpan_cond, @currentDate) as Intervals
'


SET @Sql = @declarations + @Sql + @SqlFrom + @sqlWhere + @sqlEnd
Exec rpc_HelperLongPrint @Sql 

EXECUTE sp_executesql @Sql, @params, 
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,	
	@xReceptionHoursSpan_cond = @ReceptionHoursSpan_cond,
	@xMembership_cond = @Membership_cond	


SET @ErrCode = @sql 

RETURN 
SET DATEFORMAT mdy;
GO

