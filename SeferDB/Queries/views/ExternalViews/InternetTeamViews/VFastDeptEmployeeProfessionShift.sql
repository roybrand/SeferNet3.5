/****** Object:  View [dbo].[VFastDeptEmployeeProfessionShift]    Script Date: 10/24/2011 11:28:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastDeptEmployeeProfessionShift]'))
DROP VIEW [dbo].[VFastDeptEmployeeProfessionShift]
GO

CREATE view [dbo].[VFastDeptEmployeeProfessionShift]    
as    
	select stuff(case when MAX(shifts&1)=1 then ';בוקר' else '' end    
				+case when MAX(shifts&2)=2 then ';צהריים' else '' end    
				+case when MAX(shifts&4)=4 then ';ערב' else '' end    
				+case when MAX(shifts&8)=8 then ';לילה' else '' end,1,1,''
			) shift
			,DeptEmployeeID
			,ServiceCode
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
					,DeptEmployeeID
					,ServiceCode
					,openingDateHour
					,closingDateHour    
					from (select cast(openingDateHour as datetime) openingDateHour    
								,cast(closingDateHour  as datetime) + case when cast(openingDateHour as datetime)>=cast(closingDateHour  as datetime) then 1 else 0 end closingDateHour    
								,DeptEmployeeID
								,ServiceCode  
							from (select REPLACE(openingHour,'24:','00:') openingDateHour
										,REPLACE(closingHour,'24:','00:') closingDateHour
										,DeptEmployeeID
										,ServiceCode
										from (SELECT  DeptEmployeeID, ders.serviceCode ,openingHour,closingHour,validFrom,validTo
												FROM DeptEmployeeReception der
												INNER JOIN deptEmployeeReceptionServices ders
												ON der.receptionID = ders.receptionID
												INNER JOIN Services s
												on ders.serviceCode = s.ServiceCode
												and s.IsProfession = 1 -- רוצים לקבל רק מקצועות, ללא שירותים
										) deptservicereception  
										where  GETDATE() between ISNULL(deptservicereception.validFrom,'1900-01-01') and ISNULL(deptservicereception.validTo,'2079-01-01')  
							) deptservicereception    
					) deptservicereception    
			) deptservicereception    
group by DeptEmployeeID,ServiceCode

GO


GRANT SELECT ON [dbo].[VFastDeptEmployeeProfessionShift] TO [public] AS [dbo]
GO


