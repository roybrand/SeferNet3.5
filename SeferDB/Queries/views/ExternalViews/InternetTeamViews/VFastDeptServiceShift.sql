/****** Object:  View [dbo].[VFastDeptServiceShift]    Script Date: 10/04/2011 16:06:35 ******/
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'VFastDeptServiceShift')
	DROP VIEW [dbo].[VFastDeptServiceShift]
GO

/*
	שולף את החלוקה למשמרות עבור שעות קבלה של שירותים בכל היחידה 
	Owner : Internet Team
*/
CREATE view [dbo].[VFastDeptServiceShift]    
as    
select     
	stuff(case when MAX(shifts&1)=1 then ';בוקר' else '' end    
			+case when MAX(shifts&2)=2 then ';צהריים' else '' end    
			+case when MAX(shifts&4)=4 then ';ערב' else '' end    
			+case when MAX(shifts&8)=8 then ';לילה' else '' end,1,1,''
	) shift    
	,deptCode
	,servicecode    
	from (select '' + 
			case when (openingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
					or (closingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
					or (openingDateHour<'1900-01-01 06:00' and closingDateHour>'1900-01-01 12:00')    
			then 1 else 0 end +    
			case when (openingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
					or (closingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
					or (openingDateHour<'1900-01-01 12:01' and closingDateHour>'1900-01-01 16:00')    
			then 2 else 0 end +    
			case when (openingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
					or (closingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
					or (openingDateHour<'1900-01-01 16:01' and closingDateHour>'1900-01-01 22:00')    
			then 4 else 0 end +    
			(case when (openingDateHour between '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (closingDateHour between  '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (openingDateHour<'1900-01-01 22:01' and closingDateHour>'1900-01-02 00:00')    
			then 8 else 0 end    
			|    
			case when (openingDateHour between '1900-01-01 00:00' and '1900-01-01 05:59')     
				or (closingDateHour between  '1900-01-01 00:00' and '1900-01-01  05:59')     
				or (openingDateHour<'1900-01-01 00:00' and closingDateHour>'1900-01-01  05:59')    
			then 8 else 0 end 
		) shifts
		,deptCode
		,servicecode
		,openingDateHour
		,closingDateHour
		from (select	cast(openingDateHour as datetime) openingDateHour,    
						cast(closingDateHour  as datetime) + case when cast(openingDateHour as datetime)>=cast(closingDateHour  as datetime) then 1 else 0 end closingDateHour    
						,deptCode
						,servicecode    
				from (select	REPLACE(openingHour,'24:','00:') openingDateHour
								,REPLACE(closingHour,'24:','00:') closingDateHour
								,deptCode
								,ders.serviceCode    
						from deptEmployeeReception der
						join deptEmployeeReceptionServices ders
						on der.receptionID = ders.receptionID
						join x_Dept_Employee xde 
						on der.DeptEmployeeID = xde.DeptEmployeeID
						join x_Dept_Employee_Service xdes
						on xde.DeptEmployeeID = xdes.DeptEmployeeID
						and ders.serviceCode = xdes.serviceCode
						join Employee e
						on xde.employeeID = e.employeeID
						and e.IsMedicalTeam = 1
						where  GETDATE() between ISNULL(der.validFrom,'1900-01-01') and ISNULL(der.validTo,'2079-01-01')  
				) deptservicereception    
		)deptservicereception    
	) deptservicereception    
group by deptCode,servicecode    
    
     
GO

GRANT SELECT ON [dbo].[VFastDeptServiceShift] TO [public] AS [dbo]
GO
