
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEvent')
	BEGIN
		DROP  Procedure  rpc_insertDeptEvent
	END

GO

CREATE Procedure dbo.rpc_insertDeptEvent
	(
		@DeptCode int, 
		@DeptEventID int, -- not in use but don't remove
		@EventCode int, 
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
		@UpdateUser	varchar(50),
		@cascadePhonesFromDept BIT,
		@DeptEventIDInserted int OUTPUT
	)

AS

IF @FromDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @FromDate=null
	END		
IF @ToDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ToDate=null
	END		

BEGIN 

	INSERT INTO DeptEvent
	(deptCode, EventCode, EventDescription, MeetingsNumber, FromDate, ToDate, RegistrationStatus,
	PayOrder, CommonPrice, MemberPrice, FullMemberPrice, TargetPopulation, Remark, displayInInternet, UpdateUser, CascadeUpdatePhonesFromClinic)
	VALUES
	(@DeptCode, @EventCode, @EventDescription, @meetingsNumber, @FromDate, @ToDate, @RegistrationStatus,
	@PayOrder, @CommonPrice, @MemberPrice, @FullMemberPrice, @TargetPopulation, @Remark, @displayInInternet, @UpdateUser, @cascadePhonesFromDept)

	SET @DeptEventIDInserted = @@IDENTITY 
		
END 


GO

GRANT EXEC ON rpc_insertDeptEvent TO PUBLIC

GO