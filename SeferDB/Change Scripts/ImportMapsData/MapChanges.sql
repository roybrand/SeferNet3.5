/*
Check and update maps tables

---- Get tables from GIS_TEST db (MKSQLT156\INSTANCE02)
* insert temp data into temp tables AS IS

V_Settlements		==> select * from x_City			--delete x_City
V_Streets			==> select * from x_Streets			--delete x_Streets
V_Neighbourhoods	==> select * from x_Neighborhood	--delete x_Neighborhood
V_Institutes		==> select * from x_Institute		--delete x_Institute

-- Get Addresses_All_p data from 3 tables
V_Addresses_All		==> select * from Addresses_All_p			--delete Addresses_All_p
V_Blk				==> select * from Addresses_All_25112013	--delete Addresses_All_25112013
V_Streets			==>	x_Streets (from step 1)

	2) Get Addresses_All_p data from 3 tables
		V_Addresses_All	==> Addresses_All_p
		V_Blk			==> Addresses_All_25112013
		V_Streets		==> x_Streets (from step 1)


-- At the end of all sql inserts\update - run SeferNetCoordinates calculator!

*/

go

---********************** Data changes **************************************
-- Handle not numeric city codes
-----------------------------------------------------------------------------

--update x_City
--set citycode = case when citycode like '%U' then '100000' +  REPLACE(citycode,'u','')
--				when citycode like '%P' then '200000' +  REPLACE(citycode,'p','')
--				when citycode like '%M' then '300000' +  REPLACE(citycode,'m','')
--				else citycode end
----select citycode, cityname
----, case when citycode like '%U' then '1000000' +  REPLACE(citycode,'u','')
----				when citycode like '%P' then '2000000' +  REPLACE(citycode,'p','')
----				when citycode like '%M' then '3000000' +  REPLACE(citycode,'m','')
----				else citycode end as newCode
--from x_City
--where citycode like '%U' or citycode like '%P' or citycode like '%M'
--or ISNUMERIC(citycode)  = 0


BEGIN TRANSACTION;
BEGIN TRY

--*********************** Cities table ****************************
--insert into city table
-- we only insert the cityCodes that are numbers as is,
-- with cityCodes that has letters in them we perform a fix 
--for example 951u will be fixed to 1000951
--(letters means that they are part of united city and their name has changed)

-----------------1. update
-- we get the city name from GIS database 
--district code from the Main Frame table
if exists
(
select * from INFORMATION_SCHEMA.TABLES where 
INFORMATION_SCHEMA.TABLES.TABLE_NAME in ('x_City','MF_Cities200')
)
begin 

	--all data from excell that doesn't exist in Streets  
	--insert 
 
	print 'before insert Cities from x_city'
		
	INSERT INTO [dbo].[Cities]
			([cityCode]
			,[cityName]
			,[districtCode]
			,[updateDate]
			,[updateUserName]
			,[X]
			,[Y]
			,[CityCodeMF])      
	select x.cityCode,x.cityName,
				null,
				GETDATE(),
				999,
				x.X,  
				x.Y,
				null		   
	from x_City x left join Cities c
	on c.cityCode = x.cityCode 
	where c.cityCode is null
	and x.cityCode is not null
	and ISNUMERIC(x.citycode) > 0

	print 'before update Cities x,y from x_city'

	--update city coords
    update c
    set
		c.X = x.X,
		c.Y = x.Y,
		c.updateDate = GETDATE(),
		c.updateUserName = 999,
		c.cityName = x.cityName
	from x_City x  join Cities c 
	on c.cityCode = x.cityCode 
	where ISNUMERIC(x.citycode) > 0
	  
	print 'before update district from mf_cities200'
	
	--update district from main frame
	update c
		set c.districtCode = mf.DistrictCodeLong
	from x_City x  
	join Cities c left join MF_Cities200 mf on c.cityCode = mf.Code on c.cityCode = x.cityCode 
	where (c.districtCode <> mf.DistrictCodeLong or
			c.districtCode is null )
		and ISNUMERIC(x.citycode) > 0
	  
	print 'before update CityCodeMF from mf_cities200'
	--update code from main frame
	update c
		set c.CityCodeMF = mf.Code
	from x_City x 
	join Cities c left join MF_Cities200 mf on c.cityCode = mf.Code on c.cityCode = x.cityCode 
	where ISNUMERIC(x.citycode) > 0

	-- Delete old cities	
	delete c
	from Cities c
	left join x_City xc on  ISNUMERIC(xc.citycode) > 0 and c.cityCode = xc.citycode
	where xc.cityname is null
	and not exists (select 1 from Dept d where d.cityCode = c.cityCode)
	and ISNUMERIC(xc.citycode) > 0

	-- Delete no district cities
	delete c
	from Cities c
	where c.districtCode is null

	---------------------------fix cityCode of Depts
    
                   
	-- all the city codes that are in use by dept and their code is not in city table                      
	declare  @tblCodeFix table(deptOldCode int, deptNewCode int)

	insert into @tblCodeFix
	select distinct  d.cityCode,null                      
			from Dept d
			where d.cityCode not in 
			(
			select c.cityCode from Cities c
			)

	-- Tell all this cities to sefer manager (Irit Lerner for now)
	print 'Tell all this cities to sefer manager (Irit Lerner for now)'
	select * from @tblCodeFix
							  							  
	----we get the city codes from cities that are in the main frame table
	---- we hope that somewhere in the mf table there will city with correct code 
	---- possibly in split cities that were united like 'kadima' and 'tzoran' became 
	---- 1 city	- 'kadima tzoran' so we get at least 1 code and we replace the old, 
	---- code with 1 that we found		  
		
	--update tbl
	--	set	tbl.deptNewCode = subq.NewCode
	--from @tblCodeFix tbl 
	--join (
	--	select tbl.deptOldCode as OldCode,fm.NewCityCode as NewCode
	--	from MF_Cities200 fm inner join 
	--		@tblCodeFix tbl
	--	on tbl.deptOldCode = fm.Code and fm.Code <> fm.NewCityCode	 	
		
	--	union 
			  
	--	select tbl.deptOldCode as OldCode,fm.Code as NewCode  			
	--	from MF_Cities200 fm inner join
	--	@tblCodeFix tbl
	--	on tbl.deptOldCode = fm.NewCityCode 	and fm.Code <> fm.NewCityCode	
	--) as subq on tbl.deptOldCode = subq.OldCode
		  
		
	--print 'before update depts->cityCode with the codes from excell->City table - done with the temp table'

	--update d
	--	set d.cityCode = tbl.deptNewCode
	--from dept d 
	--inner join @tblCodeFix tbl on tbl.deptOldCode = d.cityCode
	--where tbl.deptNewCode is not null   

end


--*********************** Streets table ****************************
if exists
(
	select * from INFORMATION_SCHEMA.TABLES where 
	INFORMATION_SCHEMA.TABLES.TABLE_NAME = 'x_Streets')
begin

	
	delete Streets

	insert into Streets
	(CityCode, StreetCode, Name, X, Y, MapaStreetCode)
	(SELECT   
			xs2.[citycode]
			,dbo.GetXYCode(xs2.x, xs2.y) as StreetCode
			,xs2.street
			,xs2.x
			,xs2.y
			,isnull(xs2.streetcode, 0)
		FROM   dbo.x_Streets xs2
		where ISNUMERIC(xs2.citycode) <> 0
		and xs2.citycode is not null 
	)

	-- Update existig dept data
	--select d.deptCode, d.deptName, d.cityCode, d.StreetCode, d.streetName --, s.StreetCode, s.Name
	update d set StreetCode = s.StreetCode
	from Dept d
	left join Streets s on d.cityCode = s.CityCode and d.streetName = s.Name
	where not exists (select 1 from Streets s where s.StreetCode = d.StreetCode)
	and d.StreetCode is not null and d.StreetCode <> ''
	and s.StreetCode is not null

end  

--*************** Dept table - NeighbourhoodOrInstituteCode column with NeighbourhoodCode or InstituteCode ******************
-- must be done before deleting Neighbourhood and Inititute tables so we won't lose the code

update d
set d.NeighbourhoodOrInstituteCode = dbo.GetXYCode(xnb.x, xnb.y)
--select * 
FROM Dept AS d 
LEFT OUTER JOIN x_Neighborhood xnb 
INNER JOIN Neighbourhoods AS n	ON xnb.nybname = n.NybName AND xnb.citycode = n.CityCode 
								ON d.NeighbourhoodOrInstituteCode = n.NeighbourhoodCode 
WHERE (d.NeighbourhoodOrInstituteCode <> '') and d.IsSite = 0
and xnb.citycode is not null

update d
set d.NeighbourhoodOrInstituteCode = dbo.GetXYCode(xins.x, xins.y)
--select * 
FROM Dept AS d 
left JOIN x_Institute xins 
INNER JOIN Atarim	ON xins.institutename = Atarim.InstituteName AND xins.citycode = Atarim.CityCode 
					ON d.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
WHERE (d.NeighbourhoodOrInstituteCode <> '') and d.IsSite = 1
	and xins.citycode is not null

 --********************** Atarim table ***************************


if exists
(
select * from INFORMATION_SCHEMA.TABLES where 
INFORMATION_SCHEMA.TABLES.TABLE_NAME = 'x_Institute')
begin
	print 'before delete [Atarim]'


	--we have to delete all the atarim first because some cities have identical
	-- site names like 'מגרש ספורט' appear many times in some cities 
	-- so we can't update the site by the name because we don't know what it replaces 
	--and we can't just insert it because then we'll have duplicates
	delete from [dbo].[Atarim]  
	
	print 'before insert [Atarim]'
	
	INSERT INTO [dbo].[Atarim]    
	([institutename], [citycode], [X], [Y], InstituteCode) 
	(select [institutename]     
				,[citycode]
				,[X]
				,[Y]
				,InstituteXYCode 
	 from 
		(SELECT   [institutename]     
				,[citycode]
				,[X]
				,[Y]
				,dbo.GetXYCode(X, Y)  as InstituteXYCode 
				,ROW_NUMBER() over (Partition By citycode, institutename order by institutename) as RN
		FROM [dbo].[x_Institute]
		where CityCode is not null 
				and ISNUMERIC(citycode) <> 0
				and institutename is not null
		)t where t.RN = 1
	)

end

---************************ neighbourhood table ***********************************
--insert into neighbourhood

if exists
(
select * from INFORMATION_SCHEMA.TABLES where 
INFORMATION_SCHEMA.TABLES.TABLE_NAME = 'x_Neighborhood')
begin
	print 'before delete [neighbourhood]'

	delete from [dbo].[Neighbourhoods]  

	print 'before insert [neighbourhood]'

	INSERT INTO [dbo].[Neighbourhoods]
	([NybName], [CityCode], [X], [Y], NeighbourhoodCode)
	(SELECT xat.nybname, xat.[CityCode], xat.[X], xat.[Y], xat.NeighborhoodXYCode
		FROM [dbo].[Neighbourhoods] nb
		right JOIN 
		(				
			--this max prevent duplicate x,y code
			select max(subq.nybname) as nybname, subq.cityCode, subq.[X], subq.[Y], subq.NeighborhoodXYCode
			from 
			(	SELECT dbo.x_Neighborhood.nybname,
						dbo.Cities.cityCode,
						x_Neighborhood.[X],
						x_Neighborhood.[Y],
						dbo.GetXYCode(x_Neighborhood.X, x_Neighborhood.Y)  as NeighborhoodXYCode  
				FROM dbo.x_Neighborhood 
				left JOIN dbo.Cities ON dbo.x_Neighborhood.cityCode = dbo.Cities.cityCode
				where dbo.x_Neighborhood.cityCode is not null
						and dbo.x_Neighborhood.nybname is not null
			) subq
			group by subq.cityCode, subq.[X], subq.[Y], subq.NeighborhoodXYCode
		) AS xat ON xat.cityCode = nb.cityCode and xat.nybname = nb.NybName
		where nb.cityCode is null
			and xat.cityCode is not null and ISNUMERIC(xat.CityCode) <> 0
	)
	  
end  


---***********************************************************Dept table - with streetcode

--	print 'before update dept-> MFStreetCode and reset street column '
		
--	if not exists ( select * from [dbo].[Dept] where MFStreetCode is not null )
--	begin
--		UPDATE [dbo].[Dept]
--		SET  [MFStreetCode] = [street],[street] = NULL		 
--	end  
----updating streetcodes according to the match of streetname which is stored at the Street table
print 'before update dept StreetCode from Streets->StreetCode'

update d     
set d.StreetCode = dbo.Streets.StreetCode
FROM         dbo.Dept d  JOIN
                      dbo.Streets ON d.cityCode = dbo.Streets.CityCode AND d.streetName = dbo.Streets.Name


select * 
from Streets s
where s.Name not in (select xs.street from x_Streets xs where ISNUMERIC(xs.citycode) > 0 and xs.citycode = s.CityCode)
and exists (select * from Dept d where d.cityCode = s.CityCode and d.streetName = s.Name)

-------***************************************************************************

---- ***** All addresser *********************************************************
-- Import all adresser from GIS database

	--2) Get Addresses_All_p data from 3 tables
	--	V_Addresses_All	==> Addresses_All_p
	--	V_Blk			==> Addresses_All_25112013
	--	V_Streets		==> x_Streets (from step 1)


delete [Addresses_All]
 
-- Reset identity column
DBCC CHECKIDENT ('[Addresses_All]', RESEED, 0) 
--GO


insert into Addresses_All
(CityName, CityCode, Street, StreetCode, HouseNumber, Address, XCoordinate, YCoordinate)
select c.cityName, s.CityCode, s.Name, s.MapaStreetCode, 0, s.Name, s.X, s.Y
from Streets s
join Cities c on s.CityCode = c.CityCode

insert into Addresses_All
(CityName, CityCode, Street, StreetCode, HouseNumber, Address, XCoordinate, YCoordinate)
select CityName, CityCode, Street, StreetCode, HouseNumber, Address, XCoordinate, YCoordinate
from Addresses_All_p

-- בגלל כפילות כתובות בין V_Blk ובין V_Streets  
-- אך עם קואורדינטות שונות, יש לסנן בקליטה לספר השירות ולקחת מ- V_Streets 
-- ולא מ- V_Blk
insert into Addresses_All
(CityName, CityCode, Street, StreetCode, HouseNumber, Address, XCoordinate, YCoordinate)
(select aN.CityName, aN.CityCode, aN.Street, aN.StreetCode, aN.HouseNumber, aN.Address
	, aN.XCoordinate, aN.YCoordinate --	AddressID	XCoodinateWGS	YCoodinateWGS
from Addresses_All_25112013 aN
left join Addresses_All a on an.CityCode = a.CityCode 
and ((an.Street = a.Street and an.HouseNumber = a.HouseNumber) 
		or (an.XCoordinate = a.XCoordinate and an.YCoordinate = a.YCoordinate))
where ISNUMERIC(an.CityCode) > 0
and a.Address is null and a.CityName is null
)

-------***************************************************************************


END TRY
BEGIN CATCH
	SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

GO
