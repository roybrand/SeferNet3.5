
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptEvent')
	BEGIN
		DROP  Procedure  rpc_updateDeptEvent
	END

GO

CREATE Procedure dbo.rpc_updateDeptEvent
	(
		@DeptCode int, -- not in use but don't remove
		@DeptEventID int,
		@EventCode int, -- not in use but don't remove
		@EventDescription varchar(100),
		@meetingsNumber int,
		@FromDate smalldatetime,
		@ToDate smalldatetime,
		@RegistrationStatus int,
		@PayOrder int,
		@CommonPrice real,
		@MemberPrice real,
		@FullMemberPrice real,
		@TargetPopulation varchar(100),
		@Remark varchar(500),
		@displayInInternet tinyint,
		@phonesFromDept BIT,
		@UpdateUser	varchar(50)
	)

AS

IF @FromDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @FromDate = null
	END		
IF @ToDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ToDate = null
	END		

		UPDATE DeptEvent
		SET --EventCode = @EventCode,
		EventDescription = @EventDescription,
		MeetingsNumber = @meetingsNumber,
		--RepeatingEvent = @RepeatingEvent,
		FromDate = @FromDate,
		ToDate = @ToDate,
		RegistrationStatus = @RegistrationStatus,
		PayOrder = @PayOrder,
		CommonPrice = @CommonPrice,
		MemberPrice = @MemberPrice,
		FullMemberPrice = @FullMemberPrice,
		TargetPopulation = @TargetPopulation,
		Remark = @Remark,
		displayInInternet = @displayInInternet,
		CascadeUpdatePhonesFromClinic = @phonesFromDept,
		UpdateDate = getdate(),
		UpdateUser = @UpdateUser
		WHERE DeptEventID = @DeptEventID

GO

GRANT EXEC ON rpc_updateDeptEvent TO PUBLIC

GO