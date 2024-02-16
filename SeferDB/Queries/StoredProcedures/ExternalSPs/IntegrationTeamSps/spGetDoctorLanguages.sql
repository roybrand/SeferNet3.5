alter  procedure spGetDoctorLanguages
	@doctorPhysicianID  bigint
AS
BEGIN
	--Return Doctor Languages             
	SELECT      
		[employeeID] as DoctorID,          
		[l].languageCode as LanguageCode,          
		[languageDescription] as LanguageName          
	FROM dbo.vWS_EmployeeLanguages as el        
	INNER JOIN dbo.vWS_languages l on el.languageCode = l.languageCode        
	WHERE employeeID = @doctorPhysicianID

END
go
