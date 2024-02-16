IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEvents')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEvents
	END
GO

CREATE Procedure [dbo].[rprt_DeptEvents]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,	
	@CitiesCodes varchar(max)=null,
	@StatusCodes varchar(max)=null,
	@UnitTypeCodes varchar(max)=null,
	@SubUnitTypeCodes varchar(max)=null,
	@SectorCodes varchar(max)=null,
	@DeptEvents_cond varchar(max)=null,
	@EventStartDate_cond varchar(max)=null,
	@EventFinishDate_cond varchar(max)=null,
	@Membership_cond varchar(max)=null, 

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
	@DirectPhone varchar (2)=null,-- NEW	
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@subAdminClinic varchar (2)=null, 
	@EventName varchar (2)=null,
	@EventDescription varchar (2)=null,
	@EventDisplayingDates varchar (2)=null,
	@EventMeetingsNumber varchar (2)=null,
	@EventMeetingsDetails varchar (2)=null,
	@EventPrice varchar (2)=null,
	@EventTargetPopulation varchar (2)=null,
	@EventPhones varchar (2)=null,
	@EventRemark varchar (2)=null,
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
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @SqlFrom nvarchar(max)
DECLARE @SqlWhere nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

SET @params = 
'	
	@xDistrictCodes varchar(max)=null,
	@xAdminClinicCode varchar(max)=null,
	@xCitiesCodes varchar(max)=null, 	
	@xStatusCodes varchar(max)=null,
	@xUnitTypeCodes varchar(max)=null,	
	@xSubUnitTypeCodes varchar(max)=null,	 
	@xSectorCodes varchar(max)=null,
	@xDeptEvents_cond varchar(max)=null,
	@xEventStartDate_cond varchar(max)=null,	
	@xEventFinishDate_cond varchar(max)=null,	
	@xMembership_cond varchar(max)=null 
'

SET @Declarations = ''

set @sql = 'SELECT distinct * FROM (select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'FROM Dept as d    
JOIN Dept as d2 ON d.deptCode = d2.deptCode	'
if(@Membership_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND ( 
		 d.IsCommunity = 1 AND 1 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR d.IsMushlam = 1 AND 2 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		OR d.IsHospital = 1 AND 3 in (SELECT IntField FROM dbo.SplitString( @xMembership_cond ))
		) '
if(@AdminClinicCode <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 		
	' AND (d.administrationCode  in (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode ))) '
if(@DistrictCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString( @xDistrictCodes )) 
	OR d.DeptCode IN (  SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes ) as T 
						JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
if(@UnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( @xUnitTypeCodes )) ) '
if(@SubUnitTypeCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( @xSubUnitTypeCodes )) ) '
if(@CitiesCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.CityCode IN (SELECT IntField FROM dbo.SplitString( @xCitiesCodes )) )'
if(@SectorCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( @xSectorCodes )) ) '
if(@DeptEvents_cond <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (
	(	SELECT count(*) 
		FROM DeptEvent 
		WHERE d.DeptCode = DeptEvent.DeptCode									
		AND DeptEvent.EventCode IN (SELECT IntField FROM dbo.SplitString( @xDeptEvents_cond ))) > 0
	) '
if(@StatusCodes <> '-1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' AND (d.Status IN (SELECT IntField FROM dbo.SplitString( @xStatusCodes )) ) '
	
if(@adminClinic = '1' )
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN dept as dAdmin ON d.administrationCode = dAdmin.deptCode '	
if(@district = '1' )
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN dept as dDistrict ON d.districtCode = dDistrict.deptCode ' 	
if(@subAdminClinic = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN dept as dSubAdmin ON d.subAdministrationCode = dSubAdmin.deptCode '
if(@unitType = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN View_UnitType as UnitType ON d.typeUnitCode =  UnitType.UnitTypeCode '
if(@subUnitType = '1')	
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN View_SubUnitTypes as SubUnitType ON d.subUnitTypeCode = SubUnitType.subUnitTypeCode AND d.typeUnitCode = SubUnitType.UnitTypeCode '
if(@sector = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN PopulationSectors as ps ON d.populationSectorCode = ps.PopulationSectorID '
if(@simul = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode '
if(@city = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN Cities ON d.CityCode = Cities.CityCode '
if(@Phone1 = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	
	' LEFT JOIN DeptPhones dp1 ON d.DeptCode = dp1.DeptCode AND dp1.PhoneType = 1 AND dp1.phoneOrder = 1 '
if(@Phone2 = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN DeptPhones dp2 ON d.DeptCode = dp2.DeptCode AND dp2.PhoneType = 1 AND dp2.phoneOrder = 2 '
if(@DirectPhone = '1')
	set @sqlFrom = @sqlFrom +  
	' left join DeptPhones dp4 on d.DeptCode = dp4.DeptCode and dp4.PhoneType = 5 and dp4.phoneOrder = 1 ' 

if(@Fax = '1')
	SET @SqlFrom = @SqlFrom + @NewLineChar + 
	' LEFT JOIN DeptPhones dp3 ON d.DeptCode = dp3.DeptCode AND dp3.PhoneType = 2 AND dp3.phoneOrder = 1 '



SET @SqlFrom = @SqlFrom + @NewLineChar + 		

 'LEFT JOIN DeptEvent ON d.deptCode = DeptEvent.deptCode
 LEFT JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
 LEFT JOIN dbo.View_DeptEventParticularsStartFinish as EventParticulars ON DeptEvent.DeptEventID = EventParticulars.DeptEventID '
 
if(@EventStartDate_cond <> '-1' OR @EventFinishDate_cond <> '-1') 
SET @SqlFrom = @SqlFrom + @NewLineChar +  
' JOIN Dept as d4 ON d.deptCode = d4.deptCode
	AND[dbo].rfn_CheckExpirationDate_str
	(CONVERT(varchar(10), EventParticulars.startDate, 103),
	 CONVERT(varchar(10), EventParticulars.finishDate, 103), 
	 + ISNULL(@xEventStartDate_cond, null),
	 + ISNULL(@xEventFinishDate_cond, null)) = 1 '

if(@EventPhones = '1' )	 
	SET @SqlFrom = @SqlFrom + @NewLineChar + 	 
	 'LEFT JOIN DeptEventPhones as DeptEventPhones1 ON DeptEvent.DeptEventID = DeptEventPhones1.DeptEventID
				AND DeptEventPhones1.PhoneType = 1 AND DeptEventPhones1.phoneOrder = 1
	LEFT JOIN DeptPhones DeptPhones1 ON d.DeptCode = DeptPhones1.DeptCode AND DeptPhones1.PhoneType = 1 AND DeptPhones1.phoneOrder = 1 
	' 
SET @sqlWhere = ''

if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName, ISNULL(dDistrict.deptCode, -1) as DeptCode '+ @NewLineChar;
	end

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end

if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
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
---------------SubAdminClinic----------------------------------------------------------------------------
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
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

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

---------Phone1---------------------------------------------------------------
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) 
	+ CASE WHEN dp1.remark is NULL OR dp1.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp1.remark END as Phone1 '+ @NewLineChar;
end
----------Phone2--------------------------------------------------------------------------------
if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) 
	+ CASE WHEN dp2.remark is NULL OR dp2.remark = '''' THEN '''' ELSE CHAR(13) + CHAR(10) + dp2.remark END as Phone2 '+ @NewLineChar;
end 
---------- Clinic DirectPhone--------------------------------------------------------------------------------
if(@DirectPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp4.prePrefix, dp4.Prefix, dp4.Phone, dp4.extension) as DirectPhone '+ @NewLineChar;
end 
----------Fax--------------------------------------------------------------------------------
if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end
----------Email--------------------------------------------------------------------------------
if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end
 
 ---------MangerName---------------------------------------------------------------
if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end
---------AdminMangerName---------------------------------------------------------------
if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@EventName = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_Events.EventName as EventName, DeptEvent.EventCode  as EventCode ' + @NewLineChar;
	end
	
if(@EventDescription = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.EventDescription as EventDescription ' + @NewLineChar;
	end
	
if(@EventDisplayingDates = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(10), DeptEvent.FromDate, 103)  as DisplayFromDate ' + ',' + @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), DeptEvent.ToDate, 103)   as DisplayToDate ' + @NewLineChar;
	end	

if(@EventMeetingsNumber = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.MeetingsNumber as MeetingsNumber ' + @NewLineChar;
	end
	
if(@EventPrice = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.MemberPrice as MemberPrice ' + ',' + @NewLineChar;
		set @sql = @sql + 'DeptEvent.FullMemberPrice as FullMemberPrice ' + ',' +@NewLineChar;
		set @sql = @sql + ' DeptEvent.CommonPrice as CommonPrice ' + @NewLineChar;
	end			
	
if(@EventTargetPopulation = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.TargetPopulation as TargetPopulation ' + @NewLineChar;
	end
if(@EventPhones = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		'case when DeptEvent.CascadeUpdatePhonesFromClinic = 1 
		then dbo.fun_ParsePhoneNumberWithExtension(DeptPhones1.prePrefix, DeptPhones1.Prefix, DeptPhones1.Phone, DeptPhones1.extension) 
		else dbo.fun_ParsePhoneNumberWithExtension(DeptEventPhones1.prePrefix, DeptEventPhones1.Prefix, DeptEventPhones1.Phone, DeptEventPhones1.extension) 
		end as EventPhone1 ';
	end
if(@EventRemark = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.Remark as Remark ' + @NewLineChar;
	end			
		
------------ RecepDay --------------------------------------------
if(@EventMeetingsDetails = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].Date, 103)  as EventDate ' + ',' +@NewLineChar;
		set @sql = @sql + ' [EventParticulars].Day  as ReceptionDayName ' + ',' +@NewLineChar;
		set @sql = @sql + ' [EventParticulars].openingHour  as openingHour '+ ',' + @NewLineChar;
		set @sql = @sql + ' [EventParticulars].closingHour  as closingHour '+ ',' + @NewLineChar;
		set @sql = @sql + ' [EventParticulars].totalHours  as totalHours'+ ',' +  @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].startDate, 103)  as startDate '+ ',' +  @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].finishDate, 103)  as finishDate '+ @NewLineChar;
		
		
end 

--=================================================================
set @sql = @sql + @SqlFrom + @sqlWhere + @sqlEnd

--print '--------- sql query full ----------'
--print '--===== @sql string length = ' + str(len(@sql))
--Exec rpc_HelperLongPrint @sql 

SET DATEFORMAT dmy;

EXECUTE sp_executesql @sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xCitiesCodes = @CitiesCodes,
	@xStatusCodes = @StatusCodes,	
	@xUnitTypeCodes = @UnitTypeCodes,	
	@xSubUnitTypeCodes = @SubUnitTypeCodes,
	@xSectorCodes = @SectorCodes,		
	@xDeptEvents_cond = @DeptEvents_cond,
	@xEventStartDate_cond = @EventStartDate_cond,
	@xEventFinishDate_cond = @EventFinishDate_cond,
	@xMembership_cond = @Membership_cond

SET DATEFORMAT mdy;
SET @ErrCode = @sql 
RETURN 

GO

GRANT EXEC ON [dbo].rprt_DeptEvents TO PUBLIC
GO
