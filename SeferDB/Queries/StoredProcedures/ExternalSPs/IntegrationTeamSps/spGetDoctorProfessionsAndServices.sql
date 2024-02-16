alter  procedure spGetDoctorProfessionsAndServices
	@doctorPhysicianID  bigint,
	@clinicCodes tbl_UniqueIntArray READONLY,
	@clinicCodesConsider bit -- 0 = false, 1 = true
AS
BEGIN
	-- Return all doctor professions and services data include reception times
	SELECT           
		e.deptCode,
		case when e.IsProfession = 1 then e.serviceCode else 0 end AS ProfessionCode,        
		case when e.IsProfession = 1 then e.ServiceDescription else '' end AS ProfessionName,        
		case when e.IsService = 1 then e.serviceCode else 0 end AS ServiceCode,        
		case when e.IsService = 1 then e.ServiceDescription else '' end AS ServiceDescription,        
		es.expProfession AS IsExpert,
		e.IsProfession,
		e.IsService,
		dER.receptionDay,        
		dER.openingHour,        
		dER.closingHour,
		isnull(derr.RemarkText, '') as Remark		-- NEW Field - For Rubik !
	into #doctorServ
	FROM  dbo.vWS_Dept_Employee_Service_Ext as e
	INNER JOIN vWS_EmployeeServices es ON es.EmployeeID = e.employeeID AND es.serviceCode = e.serviceCode
	INNER JOIN vWS_deptEmployeeReception as dER ON e.DeptEmployeeID = dER.DeptEmployeeID          
	INNER JOIN vWS_deptEmployeeReceptionServices as dERP ON dERP.serviceCode = e.serviceCode AND dERP.receptionID = dER.receptionID        
	LEFT  JOIN DeptEmployeeReceptionRemarks as derr ON dER.receptionID = derr.EmployeeReceptionID
	WHERE e.EmployeeID = @doctorPhysicianID 
		AND GETDATE() BETWEEN ISNULL(derr.validFrom, '1900-01-01') AND ISNULL(derr.validTo, '2079-01-01') 
	--order by e.deptCode, e.serviceCode, der.receptionDay, der.openingHour, der.closingHour

	if @clinicCodesConsider = 1
	begin
		SELECT *       
		FROM  #doctorServ d
		WHERE EXISTS ( SELECT 1 FROM @clinicCodes as t WHERE d.deptCode = t.IntVal) 
	end
	else
	begin
		SELECT * FROM  #doctorServ d
	end
END
go
