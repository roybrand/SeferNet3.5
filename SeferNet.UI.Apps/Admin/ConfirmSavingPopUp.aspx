<%@ Page Language="C#" AutoEventWireup="true" Inherits="ConfirmSavingPopUp" Codebehind="ConfirmSavingPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Confirm save</title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <script type="text/javascript">
        function SaveAndGo() {

            var functionToExecute = document.getElementById('<%=txtFunctionToExecute.ClientID %>').value;

            if (functionToExecute == "Check_cbSaveDataBeforeLeaveToUpdateRemarks") {
                parent.Check_cbSaveDataBeforeLeaveToUpdateRemarks(1);
            }
            else {
                parent.Check_cbSaveDataBeforeLeaveToAddRemarks(1);
            }

            SelectJQueryClose();
        }
        function JustGo() {

            var functionToExecute = document.getElementById('<%=txtFunctionToExecute.ClientID %>').value;

            if (functionToExecute == "Check_cbSaveDataBeforeLeaveToUpdateRemarks") {
                parent.Check_cbSaveDataBeforeLeaveToUpdateRemarks(0);
            }
            else {
                parent.Check_cbSaveDataBeforeLeaveToAddRemarks(0);
            }

            SelectJQueryClose();
        }
    </script>
</head>
<body>
<form id="form1" runat="server">
    <table cellpadding="0" cellspacing="0" style="width:100%">
        <tr>
            <td align="center" style="padding-top:20px;">
                <table cellpadding="0" cellspacing="0" style="width:300px">
                    <tr>
                        <td dir="rtl" style="padding-right:40px">
                            <asp:Label ID="lbl" runat="server" Text=".פעולה זו תגרום למעבר לדף אחר<br>האם ברצונך לשמור שינויים שבוצעו במסך ?"></asp:Label>
                            <asp:TextBox ID="txtFunctionToExecute" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" style="padding-top:15px;">
                            <table cellpadding="0" cellspacing="0" dir="rtl">
                                <tr>
                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                    </td>
                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                        <asp:Button id="btnSaveAndGo" Width="40px" runat="server" Text="כן" cssClass="RegularUpdateButton" 
                                            OnClientClick="SaveAndGo(); return false" ></asp:Button>
                                    </td>
                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                    </td>
                                    <td>&nbsp;&nbsp;&nbsp;
                                    </td>
                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                    </td>
                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                        <asp:Button id="btnJustGo" Width="40px" runat="server" Text="לא" cssClass="RegularUpdateButton" 
                                            OnClientClick="JustGo(); return false" ></asp:Button>
                                    </td>
                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                    </td>
                                    <td>&nbsp;&nbsp;&nbsp;
                                    </td>
                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                    </td>
                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                        <asp:Button id="btnCancel" Width="40px" runat="server" Text="בטל" cssClass="RegularUpdateButton" 
                                            OnClientClick="SelectJQueryCloseWithUncheckParent(); return false" ></asp:Button>
                                    </td>
                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</form>
<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }

    function SelectJQueryCloseWithUncheckParent() {
        window.parent.$('[id$=cbCauseUpdateRemarksClick]').prop("checked", false);
        window.parent.$('[id$=cbCauseAddRemarksClick]').prop("checked", false);
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
