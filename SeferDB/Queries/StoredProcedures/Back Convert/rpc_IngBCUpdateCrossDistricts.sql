ALTER Procedure [dbo].[rpc_IngBCUpdateCrossDistricts]  
as 
begin 
update SeferProd_30052011.dbo.employee 
set active = newe.active 
from SeferProd_30052011.dbo.employee as e 
inner join SeferProd_30052011.dbo.x_dept_emp  as x 
on e.id_emp = x.id_emp 
inner join SeferProd_30052011.dbo.dept as d 
on x.key_dept = d.key_dept 
inner join employee as newe 
on e.id_emp = newe.employeeid 
inner join dept as newDept 
on x.key_dept  = newDept.deptCode 
inner join Ing_BCConvertDistricts  as bccd
on (d.key_inst = bccd.DistrictCode 
 or newe.PrimaryDistrict = bccd.DistrictCode ) 
 and bccd.BCConvert = 1  
Where d.key_inst <> newe.PrimaryDistrict
and Datediff(hh, x.BackConvertUpdateDate , getdate()) <= 1 
and dbo.rfn_ingBCIsBC(NewE.IsInCommunity  , NewE.IsInMushlam , NewE.IsInHospitals , NewE.EmployeeID) = 1
and dbo.rfn_ingBCIsBC(newDept.IsCommunity , newDept.IsMushlam , newDept.IsHospital, newDept.deptCode ) = 1


exec rpc_ingBCWriteToLog 'employee', 'employee', 'Update crs', @@ROWCOUNT  

end

	

