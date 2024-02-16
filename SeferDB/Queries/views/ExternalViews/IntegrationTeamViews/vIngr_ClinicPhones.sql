
/*-------------------------------------------------------------------------
Get all dept phones for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicPhones]'))
	DROP VIEW [dbo].vIngr_ClinicPhones
GO


CREATE VIEW [dbo].vIngr_ClinicPhones
AS

select dp.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from DeptPhones dp
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode

GO


GRANT SELECT ON [dbo].vIngr_ClinicPhones TO [public] AS [dbo]
GO
