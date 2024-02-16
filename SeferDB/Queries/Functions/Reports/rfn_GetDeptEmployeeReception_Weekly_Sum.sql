CREATE function [dbo].[rfn_GetDeptEmployeeReception_Weekly_Sum]
 (
	@DeptEmployeeID int,
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15)
 ) 
RETURNS 
@ResultTable table
(
	ReceptionRowNumber int,
	deptEmployeeID int,
	serviceDescription varchar(100),
	serviceCode int,
	ProfessionDescription varchar(100),
	ProfessionCode int,
	receptionID int,
	receptionDay int,
	ReceptionDayName varchar(50),
	openingHour varchar(5),
	closingHour	varchar(5),
	totalHours	float,
	totalHoursToSum	float,
	validFrom smalldateTime,
	validTo smalldateTime,
	remarkText varchar(500),
	ReceptionRoom varchar(10),
	WeekHoursSum float,
	NotExpired bit
)
as

BEGIN

----------parameters casting------------------------
DECLARE @ValidFrom Date
DECLARE @ValidTo Date
DECLARE @DateNow Date = getdate()

if (isdate(@ValidTo_str)= 0 )
	set @ValidTo = null
else
	set @ValidTo = CAST(@ValidTo_str as Date) 

if (isdate(@ValidFrom_str) = 0)
	set @ValidFrom = null
else
	set @ValidFrom = CAST(@ValidFrom_str as Date)

----------------------------------
INSERT INTO @ResultTable

SELECT ROW_NUMBER() OVER(ORDER BY deptEmployeeID, serviceCode, ProfessionCode, receptionDay, openingHour) as RowNumber ,* 
FROM 
(
SELECT 
----------------- deptEmployeeReceptionProfession --------------------
x_dept_employee.deptEmployeeID,
serviceDescription = null,
serviceCode = null,
[Services].ServiceDescription as ProfessionDescription,
[Services].ServiceCode as ProfessionCode,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
'totalHoursToSum' = CASE WHEN recep.receptionDay < 8 THEN [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour)*ISNULL(DIC_Rem.Factor, 1) ELSE 0 END,
recep.validFrom,
recep.validTo,
RecRemarks.remarkText,
recep.ReceptionRoom,
0 as WeekHoursSum,
'NotExpired' = CASE WHEN  
	(
 		( Recep.validTo is null AND Recep.validFrom <=  @DateNow )
		OR 
		(Recep.validTo >= @DateNow AND Recep.validFrom <=  @DateNow )
	)
	AND 
	(			
		( Recep.validTo is null OR Recep.validTo >= @DateNow  )
			AND
		( Recep.validFrom <=  @DateNow )
	) THEN 1 ELSE 0 END
						
FROM x_dept_employee

INNER JOIN [dbo].DeptEmployeeReception as Recep  
	ON	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID	
INNER JOIN dbo.deptEmployeeReceptionServices as RecProf on Recep.receptionID = RecProf.receptionID  
INNER JOIN [Services]	ON RecProf.ServiceCode = [Services].ServiceCode
	AND [Services].IsProfession = 1  
INNER JOIN DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.EmployeeReceptionID
LEFT JOIN DIC_GeneralRemarks DIC_Rem on RecRemarks.RemarkID = DIC_Rem.remarkID

WHERE Recep.DeptEmployeeID = @DeptEmployeeID
	AND (	@ValidTo is null 
			OR 
			( Recep.validTo is null AND Recep.validFrom <=  @ValidTo )
			OR 
			(Recep.validTo >= @ValidTo AND Recep.validFrom <=  @ValidTo )
		)
	AND (	@ValidFrom is null 
			OR 
			(( Recep.validTo is null OR Recep.validTo >= @ValidFrom  )
				AND
			( Recep.validFrom <=  @ValidFrom ))
		)

UNION
----------------- deptEmployeeReceptionServices --------------------
SELECT
x_dept_employee.deptEmployeeID,
[Services].serviceDescription,
RecServ.serviceCode,
ProfessionDescription = null,
ProfessionCode = null,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
'totalHoursToSum' = CASE WHEN recep.receptionDay < 8 THEN [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour)*ISNULL(DIC_Rem.Factor, 1) ELSE 0 END,
recep.validFrom,
recep.validTo,
RecRemarks.remarkText,
recep.ReceptionRoom,
0 as WeekHoursSum,
'NotExpired' = CASE WHEN  
	(
 		( Recep.validTo is null AND Recep.validFrom <=  @DateNow )
		OR 
		(Recep.validTo >= @DateNow AND Recep.validFrom <=  @DateNow )
	)
	AND 
	(			
		( Recep.validTo is null OR Recep.validTo >= @DateNow  )
			AND
		( Recep.validFrom <=  @DateNow )
	) THEN 1 ELSE 0 END

FROM x_dept_employee

INNER JOIN [dbo].DeptEmployeeReception as Recep  on	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID	
INNER JOIN dbo.deptEmployeeReceptionServices as RecServ on Recep.receptionID = RecServ.receptionID  
INNER JOIN [Services] ON RecServ.serviceCode = [Services].serviceCode 
	AND [Services].IsService = 1 
INNER JOIN DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
LEFT JOIN DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID
LEFT JOIN DIC_GeneralRemarks DIC_Rem on RecRemarks.RemarkID = DIC_Rem.remarkID

WHERE Recep.DeptEmployeeID = @DeptEmployeeID
	AND (	@ValidTo is null 
			OR 
			( Recep.validTo is null AND Recep.validFrom <=  @ValidTo )
			OR 
			(Recep.validTo >= @ValidTo AND Recep.validFrom <=  @ValidTo )
		)
	AND (	@ValidFrom is null 
			OR 
			(( Recep.validTo is null OR Recep.validTo >= @ValidFrom  )
				AND
			( Recep.validFrom <=  @ValidFrom ))
		)

) as T

UPDATE @ResultTable
SET WeekHoursSum = Gr_T.WeekHoursSum
FROM @ResultTable rt
LEFT JOIN 
 ( SELECT deptEmployeeID, serviceCode, ProfessionCode, MIN(ReceptionRowNumber) as RowNumber, SUM(totalHoursToSum) as WeekHoursSum
 FROM @ResultTable rt2
 GROUP BY deptEmployeeID, serviceCode, ProfessionCode) Gr_T
	ON rt.deptEmployeeID = Gr_T.deptEmployeeID

	AND ISNULL(rt.serviceCode, 0) = ISNULL(Gr_T.serviceCode,0)
	AND ISNULL(rt.ProfessionCode, 0) = ISNULL(Gr_T.ProfessionCode,0)
	AND rt.ReceptionRowNumber = Gr_T.RowNumber

RETURN  
END

GO