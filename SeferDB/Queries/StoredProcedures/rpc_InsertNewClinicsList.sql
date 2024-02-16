IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertNewClinicsList')
	BEGIN
		DROP  Procedure  rpc_InsertNewClinicsList
	END
GO

CREATE Procedure dbo.rpc_InsertNewClinicsList

AS

INSERT INTO InterfaceFromSimulNewDepts
( SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID)
SELECT 
SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID 
FROM vInterface_NewDepts
WHERE SimulDeptId NOT IN (SELECT SimulDeptId FROM InterfaceFromSimulNewDepts) 

GO

 
GRANT EXEC ON rpc_InsertNewClinicsList TO PUBLIC

GO
