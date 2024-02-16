IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndOfficeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndOfficeReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptAndOfficeReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
    @Membership_cond varchar(max)=null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
)with recompile 

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @Where nvarchar(max)
DECLARE @SqlEnd nvarchar(max)


SET @params = 
'	@xDistrictCodes varchar(max)= null,
	@xAdminClinicCode varchar(max)= null,
	@xReceptionHoursSpan_cond varchar(max) = null,
	@xMembership_cond varchar(max) = null,
	@xIsExcelVersion varchar (2) = null '


SET @Declarations =
' DECLARE @xNewLineChar AS CHAR(2) 
  SET @xNewLineChar = CHAR(13) + CHAR(10)
  DECLARE @currentDate datetime SET @currentDate = GETDATE() 
  DECLARE @xReceptionHoursSpan int '
 
 IF (@ReceptionHoursSpan_cond is null OR @ReceptionHoursSpan_cond = '-1' OR ISDATE(@ReceptionHoursSpan_cond)= 0)
	SET @Declarations = @Declarations + ' SET @xReceptionHoursSpan = 24*60 '
 ELSE
	SET @Declarations = @Declarations + 
	' SET @xReceptionHoursSpan = datediff(minute,''00:00'', @xReceptionHoursSpan_cond) '
	
SET @Declarations = @Declarations + ' SET DATEFORMAT dmy '

SET @Sql = 
' SELECT distinct * FROM
(select 
 dDistrict.DeptName as DistrictName 
, dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity 
,case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam
,case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital

,(select ReceptionTypeDescription from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceDescription 
,(select ReceptionHoursTypeID from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceCode 

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,(SELECT stuff((	SELECT  cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM DeptReception DR
					WHERE DR.deptCode = d.DeptCode
					AND DR.receptionDay = DeptReception.receptionDay
					AND DR.validFrom <= @currentDate 
					AND DR.ReceptionHoursTypeID = 1
					ORDER BY openingHour							
					for xml path('''')),1,1,''''
					)) AS deptReceptions -- DeptreceptionHours

,(SELECT stuff((	SELECT  cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM DeptReception DR
					WHERE DR.deptCode = d.DeptCode
					AND DR.receptionDay = DeptReception.receptionDay
					AND DR.validFrom <= @currentDate 
					AND DR.ReceptionHoursTypeID = 2
					ORDER BY openingHour							
					for xml path('''')),1,1,''''
					)) AS deptReceptions -- OfficeServicesReceptionHours
					
,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from dept  as d    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

left join DeptReception on d.deptCode = DeptReception.deptCode
	and DeptReception.ReceptionHoursTypeID = 1
JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

cross apply rfn_GetDeptAndServiceReceptionIntervalNonIntersection(d.deptCode, DeptReception.receptionDay, @xReceptionHoursSpan_cond) as Intervals '

SET @Where = ' WHERE d.status = 1 '
IF(@Membership_cond <> '-1')
	SET @Where = @Where + 
	' AND ( (d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )))
			OR (d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond)))
			OR (d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond )))
		)'
IF(@DistrictCodes <> '-1')
	SET @Where = @Where + 
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString(@xDistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
		)'
		
IF(@AdminClinicCode <> '-1')
	SET @Where = @Where + 		
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode)) ) '

SET @SqlEnd = 
	' ) as resultTable
	order by DeptCode, ClinicCode, ReceptionDayName

SET DATEFORMAT mdy 

RETURN '

SET @Sql = @Declarations + @Sql + @Where + @SqlEnd

exec sp_executesql @Sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xReceptionHoursSpan_cond = @ReceptionHoursSpan_cond,
    @xMembership_cond = @Membership_cond, 
	@xIsExcelVersion = @IsExcelVersion

GO

GRANT EXEC ON [dbo].rprt_DeptAndOfficeReceptionDifferences TO PUBLIC
GO