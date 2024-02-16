alter  procedure spGetDoctorData
	@doctorPhysicianID  bigint
AS
BEGIN
	SELECT     
		[employeeID] as DoctorID          
		,[badgeID] as EmployeeCode          
		,[licenseNumber] as DoctorLicenseNo          
		,[lastName] as DoctorLastName          
		,[firstName] as DoctorFirstName          
		,[degreeCode] as DoctorTitleCode          
		,[Email] as DoctorEmail          
		,[sex] as DoctorGenderCode        
		,[showEmailInInternet] as EmailIsUnlisted        
	FROM  dbo.vWS_Employee     
	WHERE employeeID = @doctorPhysicianID

END
go