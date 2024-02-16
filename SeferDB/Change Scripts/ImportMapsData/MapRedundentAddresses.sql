
  
  --These are streets that exist in Street table but DON'T EXIST in the x_streets table ( the excell file )
  --this will report to the Customer about these streets and give the customer the option to update the streets
  -- or delete them if required
SELECT     Streets.CityCode, Streets.Name, 
  Cities.cityName
FROM         Streets INNER JOIN
                      Cities ON Streets.CityCode = Cities.cityCode LEFT OUTER JOIN
                          (SELECT     citycode, street
                            FROM          x_Street AS xs
                            WHERE      (street IS NOT NULL)) AS xs2
                             ON xs2.citycode = Streets.CityCode AND xs2.street = Streets.Name
WHERE     (xs2.citycode IS NULL) AND (Streets.Name IS NOT NULL)
order by Streets.CityCode, Streets.Name


--same deal as above description for cities - we'll let the customer decide what to do with them
SELECT     c.cityCode AS cityCode, c.cityName AS cityName, c.districtCode, c.CityCodeMF
FROM         x_City AS x RIGHT OUTER JOIN
                      Cities AS c ON c.cityCode = x.citycode
WHERE     (x.citycode IS NULL)

--all the depts that their StreetCode doesn't exist in the streets excell file
select subq.Name,subq.cityName,d.* from dept d
inner join
(
SELECT Streets.StreetCode,Streets.Name ,Cities.cityName 
FROM         Streets INNER JOIN
                      Cities ON Streets.CityCode = Cities.cityCode LEFT OUTER JOIN
                          (SELECT     citycode, street
                            FROM          x_Street AS xs
                            WHERE      (street IS NOT NULL)) AS xs2
                             ON xs2.citycode = Streets.CityCode AND xs2.street = Streets.Name
WHERE     (xs2.citycode IS NULL) AND (Streets.Name IS NOT NULL)
) subq on d.StreetCode = subq.StreetCode

--all the depts that their city code doesn't exist in the cities excell file
select subq.cityName,d.* from dept d
inner join
( 
SELECT     c.cityCode AS cityCode,c.cityName
FROM         x_City AS x RIGHT OUTER JOIN
                      Cities AS c ON c.cityCode = x.citycode
WHERE     (x.citycode IS NULL)
) subq on d.cityCode = subq.cityCode

-------------------- this result data checks that dept table-> NeighbourhoodOrInstituteCode really  exits
-- in 1 of these tables Neighbourhoods or  Atarim
select * 
FROM         Dept AS d LEFT OUTER JOIN                        
                      Neighbourhoods AS n  ON 
                      d.NeighbourhoodOrInstituteCode = n.NeighbourhoodCode 
WHERE     (d.NeighbourhoodOrInstituteCode <> '') and d.IsSite = 0
and n.NeighbourhoodCode is null


select * 
FROM         Dept AS d LEFT OUTER JOIN                        
                      Atarim AS a  ON 
                      d.NeighbourhoodOrInstituteCode = a.InstituteCode
WHERE     (d.NeighbourhoodOrInstituteCode <> '') and d.IsSite =1
and a.InstituteCode is null