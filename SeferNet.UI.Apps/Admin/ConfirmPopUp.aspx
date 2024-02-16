<%@ Page Language="C#" AutoEventWireup="true" Inherits="ConfirmPopUp" Codebehind="ConfirmPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Confirm</title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <script type="text/javascript">
        function Go() {
            parent.FunctionToExecuteAfterConfirm();
            SelectJQueryClose();
        }

        function Go_OLD() {
            var obj = new Object();
            obj.Continue = true;
            window.returnValue = obj;
            self.close();
        }

        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
        return false;
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
                        <td>
                            <asp:Label ID="lblText" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" style="padding-top:15px;">
                            <table cellpadding="0" cellspacing="0" dir="rtl">
                                <tr>
                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                    </td>
                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                        <asp:Button id="btnCancel" Width="40px" runat="server" Text="לא" cssClass="RegularUpdateButton" 
                                            OnClientClick="SelectJQueryClose();" ></asp:Button>
                                    </td>
                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                    </td>
                                    <td>&nbsp;&nbsp;&nbsp;
                                    </td>
                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                    </td>
                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                        <asp:Button id="btnGo" Width="40px" runat="server" Text="כן" cssClass="RegularUpdateButton" 
                                            OnClientClick="Go(); return false" ></asp:Button>
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
</body>
</html>
