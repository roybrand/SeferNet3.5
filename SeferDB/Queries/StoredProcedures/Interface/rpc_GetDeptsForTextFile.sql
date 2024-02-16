IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsForTextFile')
	BEGIN
		DROP  Procedure  rpc_GetDeptsForTextFile
	END

GO

CREATE Procedure dbo.rpc_GetDeptsForTextFile

AS

SELECT deptCode, teur,city,streetName,house,entrance,flat,doarna,zipCode,preprefix1,prefix1,nphone1,preprefix2,prefix2,nphone2,faxpreprefix,FaxPrefix, nfax,menahel,email,
GEO_X,GEO_Y, filler + char(13) + char(10) as 'filler'
FROM (

SELECT   1  as UnionID ,

 	('SEFER-') AS deptCode,
	('SHERUT' +  space(8)  
		+ CAST( Datepart(yyyy,GETDATE()) as varchar(4)) 
		+ right('0' + CAST(Datepart(mm,GETDATE()) as varchar(2)), 2) 
		+ right('0' + CAST(Datepart(dd,GETDATE()) as varchar(2)),2)
		+ space(28)
	)as teur,
           space(4) AS city,
           space(17) AS streetName,
           space(4) AS house,
           space(1) AS entrance,
           space(3) AS flat,
           space(17) AS doarna,
           space(5) AS zipCode,
           space(2) AS preprefix1,
           space(3) AS prefix1,
           space(7) AS nphone1,
           space(2) AS preprefix2,
           space(3) AS prefix2,
           space(7) AS nphone2,
           space(2) AS faxpreprefix,
           space(3) AS FaxPrefix,
           space(7) AS nfax,
           space(20) AS menahel,
           space(40) AS email,
           space(10) AS GEO_X,
           space(10) AS GEO_Y,           
           space(7) as filler

UNION
SELECT   2  as UnionID ,
     right('000000' + CAST(dept.deptCode AS varchar(6)),6) AS deptCode, 
	   left(CAST(deptName AS varchar(50)) + space(50) ,50)as teur,
           right('0000' + CAST(dept.cityCode AS varchar(4)),4) AS city,
           'street'=
           case 
              WHEN streetName is not null then left(CAST(streetName AS varchar(17)) + space(17) ,17)
			  WHEN ((Atarim.InstituteName is not null OR Neighbourhoods.NybName is not null) AND streetName is null)
			  THEN CAST(LEFT((IsNull(Atarim.InstituteName, '') + IsNull(Neighbourhoods.NybName, '')  + space(17)), 17) AS varchar(17))
              ELSE space(17) end,
			'house'= case
              when house is not null then right('0000' + CAST(house AS varchar(4)),4)
              else '0000' end,
			'entrance'= case 
              when entrance is not null then CAST(entrance AS char(1)) 
              else space(1) end,
			'flat'= case 
              when flat is not null then left(CAST(flat AS varchar(3)) + space(3) ,3)
              else space(3) end,
			'doarna'= space(17),
			'zipCode'= case
              when zipCode is not null then right('00000' + CAST(zipCode AS varchar(5)),5)
              else '00000' end,
			'preprefix1'= case 
              when DP1.prePrefix is not null and DP1.prePrefix = 2 then '90'
              when DP1.prePrefix is not null and DP1.prePrefix <> 2 then right('00' + CAST(DP1.prePrefix AS varchar(2)),2)
              else '00' end,
			'prefix1'= case 
              when PP1.prefixValue is not null  then right('000' + CAST(PP1.prefixValue AS varchar(3)),3)
              else '000' end,
			'nphone1'= case 
              when DP1.phone is not null then right('0000000' + CAST(DP1.phone AS varchar(7)),7)
              else '0000000' end,     
			'preprefix2'= case 
              when DP2.prePrefix is not null and DP2.prePrefix = 2 then '90'
              when DP2.prePrefix is not null and DP2.prePrefix <> 2 then right('00' + CAST(DP2.prePrefix AS varchar(2)),2)
              else '00' end,
			'prefix2'= case 
              when PP2.prefixValue is not null  then right('000' + CAST(PP2.prefixValue AS varchar(3)),3)
              else '000' end,
			'nphone2'= case 
              when DP2.phone is not null then right('0000000' + CAST(right(DP2.phone,7) AS varchar(7)),7)              
              else '0000000' end,     
			'faxpreprefix'= case 
              when DP3.prePrefix is not null then right('00' + CAST(DP3.prePrefix AS varchar(2)),2)              
              else '00' end,
			'FaxPrefix'= case 
              when PP3.prefixValue is not null  then right('000' + CAST(PP3.prefixValue AS varchar(3)),3)              
              else '000' end,
			'nfax'= case 
              when DP3.phone is not null then right('0000000' + CAST(right(DP3.phone,7) AS varchar(7)),7)
              else '0000000' end,     
			'menahel'= case 
              when managerName is not null then left(CAST(managerName AS varchar(20)) + space(20) ,20)              
              else space(20) end, 
			'email'= case 
              when email is not null then UPPER(left(CAST(email AS varchar(40)) + space(40) ,40) )                 
              when email is NULL then  space(40)
           end,
           ISNULL( RIGHT(space(10) +  CAST(CAST( xcoord as decimal(16,3)) as varchar(20)), 10), space(10)) AS GEO_X,
           ISNULL( RIGHT(space(10) +  CAST(CAST( ycoord as decimal(16,3)) as varchar(20)), 10), space(10)) AS GEO_Y, 
           space(7) as filler

FROM dept
LEFT JOIN DeptPhones DP1 ON dept.deptCode = DP1.deptCode and DP1.phoneOrder = 1 and DP1.phoneType = 1
LEFT JOIN DeptPhones DP2 ON dept.deptCode = DP2.deptCode and DP2.phoneOrder = 2 and DP2.phoneType = 1
LEFT JOIN DeptPhones DP3 ON dept.deptCode = DP3.deptCode and DP3.phoneOrder = 1 and DP3.phoneType = 2
LEFT JOIN DIC_PhonePrefix PP1 ON DP1.prefix = PP1.prefixCode
LEFT JOIN DIC_PhonePrefix PP2 ON DP2.prefix = PP2.prefixCode
LEFT JOIN DIC_PhonePrefix PP3 ON DP3.prefix = PP3.prefixCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN Atarim ON dept.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
LEFT JOIN Neighbourhoods ON dept.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode
WHERE len(dept.deptCode)<7 
AND dept.IsCommunity = 1

UNION
SELECT   3  as UnionID ,
 	('SEFER-') AS deptCode,
	('SHERUT' +  space(8)  
		+ CAST( Datepart(yyyy,GETDATE()) as varchar(4)) 
		+ right('0' + CAST(Datepart(mm,GETDATE()) as varchar(2)),2) 
		+ right('0' + CAST(Datepart(dd,GETDATE()) as varchar(2)),2)
		+ right( space(7) + CAST( (SELECT Count(*) FROM dept WHERE len(deptCode)<7 AND IsCommunity = 1) as varchar(7)),7 )
		+ '@@@'
		+ space(18)
	)as teur,
           space(4) AS city,
           space(17) AS streetName,
           space(4) AS house,
           space(1) AS entrance,
           space(3) AS flat,
           space(17) AS doarna,
           space(5) AS zipCode,
           space(2) AS preprefix1,
           space(3) AS prefix1,
           space(7) AS nphone1,
           space(2) AS preprefix2,
           space(3) AS prefix2,
           space(7) AS nphone2,
           space(2) AS faxpreprefix,
           space(3) AS FaxPrefix,
           space(7) AS nfax,
           space(20) AS menahel,
           space(40) AS email,
           space(10) AS GEO_X,
           space(10) AS GEO_Y,           
           space(7) AS filler
) as UnionTbl 

Order by  UnionID

GO

GRANT EXEC ON rpc_GetDeptsForTextFile TO PUBLIC

GO

