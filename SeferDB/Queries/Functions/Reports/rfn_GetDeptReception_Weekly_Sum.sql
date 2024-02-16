CREATE function [dbo].[rfn_GetDeptReception_Weekly_Sum]
 (
	@DeptCode int,
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15),
	@ObjectType_cond  varchar(50)
 ) 
RETURNS 
@ResultTable table
(
	ReceptionRowNumber int,
	ObjectType varchar(10), 
	deptCode int,
	serviceCode int,
	serviceDescription varchar(100),
	serviceGivenByPersonCode int,
	serviceGivenByPerson varchar(50),
	receptionID int,
	receptionDay int,
	ReceptionDayName varchar(50),
	openingHour varchar(5),
	closingHour	varchar(5),
	totalHours	float,
	ReceptionRoom varchar(10),
	validFrom smalldateTime,
	validTo smalldateTime,
	remarkText varchar(500),
	viaPerson int,
	totalHoursToSum	float,
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
SELECT ROW_NUMBER() OVER(ORDER BY ObjectType, receptionDay, openingHour ) as RowNumber ,* FROM
(
SELECT 
DeptReception.ReceptionHoursTypeID as ObjectType, 
DeptReception.deptCode,
'serviceCode' = 0,
'serviceDescription' = DIC_ReceptionHoursTypes.ReceptionTypeDescription, --'שעות קבלה',
'serviceGivenByPersonCode' = 0,
'serviceGivenByPerson' = 'צוות מרפאה',
DeptReception.receptionID,
DeptReception.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
DeptReception.openingHour,
DeptReception.closingHour,
'totalHours' = [dbo].rfn_TimeInterval_float(DeptReception.openingHour, DeptReception.closingHour),
'ReceptionRoom' = '',
DeptReception.validFrom,
DeptReception.validTo,
DepRecRem.RemarkText,
0 as viaPerson,
'totalHoursToSum' = CASE WHEN DeptReception.receptionDay < 8 THEN [dbo].rfn_TimeInterval_float(DeptReception.openingHour, DeptReception.closingHour)*ISNULL(DIC_Rem.Factor, 1) ELSE 0 END,
0 as WeekHoursSum,
'NotExpired' = CASE WHEN  
	(
 		( DeptReception.validTo is null AND DeptReception.validFrom <=  @DateNow )
		OR 
		(DeptReception.validTo >= @DateNow AND DeptReception.validFrom <=  @DateNow )
	)
	AND 
	(			
		( DeptReception.validTo is null OR DeptReception.validTo >= @DateNow  )
			AND
		( DeptReception.validFrom <=  @DateNow )
	) THEN 1 ELSE 0 END
						

FROM [dbo].[DeptReception]
INNER JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	AND [DeptReception].deptCode = @DeptCode
INNER JOIN DIC_ReceptionHoursTypes ON DeptReception.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
LEFT JOIN DeptReceptionRemarks as DepRecRem on DeptReception.receptionId = DepRecRem.ReceptionID
LEFT JOIN DIC_GeneralRemarks DIC_Rem on DepRecRem.RemarkID = DIC_Rem.remarkID

WHERE DeptReception.deptCode = @DeptCode
	AND (	@ValidTo is null 
			OR 
			( DeptReception.validTo is null AND DeptReception.validFrom <=  @ValidTo )
			OR 
			(DeptReception.validTo >= @ValidTo AND DeptReception.validFrom <=  @ValidTo )
		)
	AND (	@ValidFrom is null 
			OR 
			(( DeptReception.validTo is null OR DeptReception.validTo >= @ValidFrom  )
				AND
			( DeptReception.validFrom <=  @ValidFrom ))
		)
	AND (@ObjectType_cond ='-1'
		OR DeptReception.ReceptionHoursTypeID in (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ObjectType_cond) )
		)
) as T

UPDATE @ResultTable
SET WeekHoursSum = T.WeekHoursSum
FROM @ResultTable rt
LEFT JOIN (
SELECT ObjectType, MIN(ReceptionRowNumber) as ReceptionRowNumber, SUM(totalHoursToSum) as WeekHoursSum, NotExpired FROM @ResultTable rt2
GROUP BY ObjectType, NotExpired
HAVING NotExpired = 1
) T ON rt.ReceptionRowNumber = T.ReceptionRowNumber AND rt.ObjectType = T.ObjectType AND rt.NotExpired = T.NotExpired


RETURN  
END

GO
