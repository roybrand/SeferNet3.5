IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptReception
	END
GO

CREATE function [dbo].[rfn_GetDeptReception]
 (
	@DeptCode int,
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15),
	@ObjectType_cond  varchar(50)
 ) 
RETURNS 
@ResultTable table
(
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
	viaPerson int
)
as

begin

----------parameters casting------------------------
declare @ValidFrom smallDateTime
declare @ValidTo smallDateTime

if (isdate(@ValidTo_str)= 0 )
	set @ValidTo = null
else
	set @ValidTo = convert(smallDateTime, @ValidTo_str, 103 )

if (isdate(@ValidFrom_str) = 0)
	set @ValidFrom = convert(smallDateTime, '1900-01-01', 103 )
else
	set @ValidFrom = convert(smallDateTime, @ValidFrom_str, 103 )

----------------------------------
insert into @ResultTable
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
0 as viaPerson  

FROM [dbo].[DeptReception]
INNER JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	AND [DeptReception].deptCode = @DeptCode
INNER JOIN DIC_ReceptionHoursTypes ON DeptReception.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
LEFT JOIN DeptReceptionRemarks as DepRecRem on DeptReception.receptionId = DepRecRem.ReceptionID

WHERE DeptReception.deptCode = @DeptCode
	and(	@ValidTo is null and DeptReception.validTo is null
		
		or	@ValidTo is not null and DeptReception.validTo is not null
			and @ValidFrom <= DeptReception.validTo and	 DeptReception.validFrom <=  @ValidTo 
		
		or  @ValidTo is not null and DeptReception.validTo is null
			and  DeptReception.validFrom <=  @ValidTo
		
		or	@ValidTo is null and DeptReception.validTo is not null
			and @ValidFrom <= DeptReception.validTo
		)
	AND (@ObjectType_cond ='-1'
		OR DeptReception.ReceptionHoursTypeID in (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@ObjectType_cond) )
		)
return
end

GO


GRANT EXEC ON dbo.rfn_GetDeptReception TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetDeptReception TO [clalit\IntranetDev]
GO