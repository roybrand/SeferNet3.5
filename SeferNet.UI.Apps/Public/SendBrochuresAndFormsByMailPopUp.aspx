<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendBrochuresAndFormsByMailPopUp.aspx.cs" Inherits="SeferNet.UI.Apps.Public.SendBrochuresAndFormsByMailPopUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
</head>
<script type="text/javascript" >

function hideProgressBar() {
    document.getElementById("divProgressBar").style.visibility = "hidden"
}

function showProgressBar(validation_group) {
    var isValid = Page_ClientValidate(validation_group);
    if (isValid) {
        document.getElementById("divProgressBar").style.visibility = "visible";
    }
}

</script>
<script type="text/javascript">
    function JQueryDialogClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
<body>
    <form id="form1" runat="server">
            <div id="divProgressBar" style="margin-top:5px;visibility:hidden;position:fixed;background:url('../Images/Applic/progressBar.gif') center no-repeat;width:100%;height:100px;"></div>
            <table cellpadding="0" cellspacing="0" border="0"  dir="rtl">
                <tr style="height:10px"><td></td></tr>
                <tr>
                    <td style="width:75px; padding-right:10px">
                        <asp:Label ID="lblTo" runat="server" Text="כתובת"></asp:Label>
                    </td> 
                    <td colspan="2"  style="width:220px">
                        <asp:TextBox ID="txtTo" Width="220px" runat="server"></asp:TextBox>
                        <asp:RegularExpressionValidator ValidationGroup="SendMail" ID="validateEmailRegular" runat="server" ControlToValidate="txtTo" 
                            ErrorMessage="***" ValidationExpression="^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$">
                        </asp:RegularExpressionValidator>
                        <asp:RequiredFieldValidator ID="validateEmailRequire" runat="server" ValidationGroup="SendMail" ControlToValidate="txtTo" 
                            ErrorMessage="**" ></asp:RequiredFieldValidator>
                    </td>
                    <td style="width:35px">&nbsp;
                    </td>
                </tr>
                <tr style="height:10px"><td></td></tr>
                <tr>
                    <td style="padding-right:10px">
                        <asp:Label ID="lblname" runat="server" Text="שם הלקוח"></asp:Label>
                    </td>
                    <td colspan="2">
                        <asp:TextBox ID="txtClientName" Width="220px" runat="server"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr style="height:10px"><td></td></tr>
                <tr> 
                    <td style="padding-right:10px">
                        <asp:Label ID="lblRemark" runat="server" Text="הערות"></asp:Label>
                    </td>                      
                    <td colspan="2">
                        <asp:TextBox ID="txtRemark" TextMode="MultiLine" runat="server" Width="220px" Height="80px"></asp:TextBox>
                    </td>
                    <td>&nbsp;</td>                    
                </tr>
                <tr style="height:10px"><td></td></tr>
                <tr> 
                     <td>
                    </td>                   
                    <td>
                        <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                    background-position: bottom left;">
                                    &nbsp;
                                </td>
                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                    background-repeat: repeat-x; background-position: bottom;">
                                    <asp:Button ID="btnSend" CssClass="RegularUpdateButton" runat="server" Text="  אשור  " OnClick="btnSend_Click" OnClientClick="showProgressBar('SendMail');"
                                        ValidationGroup="SendMail" ></asp:Button>

                                </td>
                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                    background-repeat: no-repeat;">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td align="left">
                         <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                    background-position: bottom left;">
                                    &nbsp;
                                </td>
                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                    background-repeat: repeat-x; background-position: bottom;">
                                    <asp:Button ID="btnClose" CssClass="RegularUpdateButton" runat="server" Text="  ביטול  " OnClientClick="JQueryDialogClose();"/>
                                </td>
                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                    background-repeat: no-repeat;">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>                       
                    </td>
                    <td>&nbsp</td>                    
                </tr>
            </table>
    </form>

</body>
</html>
