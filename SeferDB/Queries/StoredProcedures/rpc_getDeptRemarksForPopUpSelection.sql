IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptRemarksForPopUpSelection')
	BEGIN
		DROP  Procedure  rpc_getDeptRemarksForPopUpSelection
	END

GO

CREATE Procedure rpc_getDeptRemarksForPopUpSelection
(
	@LinkedToDept bit,
	@LinkedToDoctor bit,
	@LinkedToDoctorInClinic bit,
	@LinkedToServiceInClinic bit,
	@LinkedToReceptionHours bit,
	@EnableOverlappingHours bit
)

as

Select
	remarkID,
	remark
from 
	DIC_GeneralRemarks
where
	active = 1
	--and linkedToDept = 1
AND (@LinkedToDept is NULL or linkedToDept = @LinkedToDept)
AND (@LinkedToDoctor is NULL or linkedToDoctor = @LinkedToDoctor)
AND (@LinkedToDoctorInClinic is NULL or linkedToDoctorInClinic = @LinkedToDoctorInClinic)
AND (@LinkedToServiceInClinic is NULL or linkedToServiceInClinic = @LinkedToServiceInClinic)
AND (@LinkedToReceptionHours is NULL or linkedToReceptionHours = @LinkedToReceptionHours)
AND (@EnableOverlappingHours is NULL or EnableOverlappingHours = @EnableOverlappingHours)

order by remark

GO

GRANT EXEC ON rpc_getDeptRemarksForPopUpSelection TO PUBLIC

GO


