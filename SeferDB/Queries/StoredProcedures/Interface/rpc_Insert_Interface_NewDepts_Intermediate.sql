IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_Interface_NewDepts_Intermediate')
	BEGIN
		DROP  Procedure  rpc_Insert_Interface_NewDepts_Intermediate
	END

GO

CREATE Procedure dbo.rpc_Insert_Interface_NewDepts_Intermediate

AS

INSERT INTO Interface_NewDepts_Intermediate
( SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul)

SELECT 
 SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul 

FROM vInterface_NewDepts

GO

GRANT EXEC ON rpc_Insert_Interface_NewDepts_Intermediate TO PUBLIC

GO

