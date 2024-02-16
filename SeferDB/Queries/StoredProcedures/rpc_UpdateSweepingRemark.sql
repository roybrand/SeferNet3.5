IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rpc_UpdateSweepingRemark')
	BEGIN
		DROP  Procedure  rpc_UpdateSweepingRemark
	END

GO

 
create procedure [dbo].[rpc_UpdateSweepingRemark](@RemarkID int, 
										  @RemarkText varchar(max), 
										  @ValidFrom varchar(10),
										  @ValidTo varchar(10),
										  @InternetDisplay tinyint, 
										  @UpdateUser varchar(50)) 
as 

declare @From  smalldatetime 
declare @To smalldatetime 


set @From = dbo.rfn_ConvertDate(@ValidFrom)  

if len(@ValidTo) > 0 
begin 
	set @To  = dbo.rfn_ConvertDate(@ValidTo)
end 
else 
begin 
	set @To  = null 
end 
 


Update Remarks  
set RemarkText = @RemarkText, 
ValidFrom = @From, 
ValidTo = @To, 
displayInInternet = @InternetDisplay, 
updateDate = getdate() , 
updateUser = @UpdateUser
where RelatedRemarkID = (Select RelatedRemarkID from Remarks where RemarkID = @RemarkID)

go

grant exec on dbo.rpc_UpdateSweepingRemark to public

go