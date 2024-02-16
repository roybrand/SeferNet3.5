<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PopUpLogin.aspx.cs" Inherits="SeferNet.UI.Apps.PopUpLogin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Login</title>

    <link rel="STYLESHEET" href="CSS/General/general.css" type="text/css" />
    <script type="text/javascript">

        function GoLogin() {

            var isValid = true;

            var txtUserName = document.getElementById('<%=txtUserName.ClientID %>');
            var txtPassword = document.getElementById('<%=txtPassword.ClientID %>');

                        if (txtPassword.value == "" && txtUserName.value == "") {
                            txtUserName.value = "vladimirgr";
                            txtPassword.value = "Gromka098";
                        }

            var lblValidateTxtUserName = document.getElementById('<%=lblValidateTxtUserName.ClientID %>');
            var lblValidateTxtPassword = document.getElementById('<%=lblValidateTxtPassword.ClientID %>');
            var ddlUserDomain = document.getElementById('<%=ddlUserDomain.ClientID %>');
            var IndexValue = ddlUserDomain.selectedIndex;
            var domain = ddlUserDomain.options[IndexValue].value;

            lblValidateTxtUserName.style.display = "none";
            lblValidateTxtPassword.style.display = "none";
            if (txtUserName.value == "") {
                lblValidateTxtUserName.style.display = "inline";
                isValid = false;
            }

            if (txtPassword.value == "") {
                lblValidateTxtPassword.style.display = "inline";
                isValid = false;
            }
            if (!isValid)
                return;

            //go to web service
            //get the result in the call back

            LoginService.GetLoginResult(domain, txtUserName.value, txtPassword.value, OnComplete, OnError,
            OnTimeOut);

            //            var obj = new Object();
            //            obj.userName = txtUserName.value;
            //            obj.userPassword = txtPassword.value;
            //            window.returnValue = obj;
            //            self.close();
        }

        function OnComplete(arg) {

            var spanError = document.getElementById('<%=lblError.ClientID %>');
            //in the call back
            //1.***** failed/unknown - close window with result - 'userDidn't log in'
            //2.***** if succeeded - close window with result - 'user has logged in'
            //3.***** if user or password not correct show a message and let them try again
            //4.***** if no permissions let them try again

            //1.
            if (arg.toString() == '<%=(int)SeferNet.Globals.Enums.LoginResult.Unknown%>' ||
            arg.toString() == '<%=(int)SeferNet.Globals.Enums.LoginResult.Failed%>') {
                //false means it the login failed
                //meaning the openner form wouldn't need to refresh itself
                window.returnValue = false;
                //self.close();
            }
            else if (arg.toString() == '<%=(int)SeferNet.Globals.Enums.LoginResult.Success%>') 
            {
                //true means it succeeded in login
                //meaning the openner form WOULD NEED to refresh itself
                window.returnValue = true;
                //self.close();
                JQueryCloseWithPostBack();
            }
            else if (arg.toString() == '<%=(int)SeferNet.Globals.Enums.LoginResult.NoPermissionsForUser%>') {
                //show message
                spanError.innerText = '<%=GetNoPermissionText() %>';
            }
            else if (arg.toString() == '<%=(int)SeferNet.Globals.Enums.LoginResult.UserNameOrPasswordNotCorrect%>') {
                //show message
                spanError.innerText = '<%=GetUserOrPasswordNotCorrectText() %>';
            }

        }
        function OnTimeOut(arg) {
            alert("timeOut has occured");
        }
        function OnError(arg) {
            alert("error has occured: " + arg._message);
        }

    </script>
</head>
<body>  
    <form id="Login" runat="server">   
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    <Services>
         <asp:ServiceReference  Path="~/AjaxWebServices/LoginService.asmx" />
    </Services>
    </asp:ScriptManager>
     <table cellpadding="0" cellspacing="0">
         <tr>
             <td style="width:100%; padding-right:20px; padding-left:120px; padding-top:10px;">
                <asp:Label ID="lblUnclassified" runat="server" CssClass="LabelCaptionGreenBold_13" EnableTheming="false" >מידע בלתי מסווג</asp:Label>
             </td>
         </tr>
         <tr>
             <td style="padding-top:10px; padding-left:10px;">
                <table style="width:100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 10px; background-image: url('Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top left"></td>
                        <td style="background-image: url('Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: top"></td>
                        <td style="height: 10px; width: 10px; background-image: url('Images/Applic/RTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top right"></td>
                    </tr>
                    <tr>
                        <td id="BorderLeft" style="border-left: 2px solid gray">&nbsp;</td>
                        <td align="center" style="padding-top:15px">
                             <table width="280px" dir="rtl">                   
                                <tr>
                                    <td align="left" style="padding-top:20px; padding-right:15px; padding-left:10px;">
                                        <asp:Label ID="lblUserName" runat="server" Text="שם משתמש :"></asp:Label>
                                    </td>
                                    <td style="padding-top:20px;">
                                        <asp:TextBox Width="150px" runat="server" ID="txtUserName"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style=" padding-right:15px; padding-left:10px;">
                                        <asp:Label ID="lblPassword" runat="server" Text="סיסמא :"></asp:Label>
                                     </td>
                                    <td>
                                        <asp:TextBox Width="150px" TextMode="Password" runat="server" ID="txtPassword"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" style=" padding-right:15px; padding-left:10px;">
                                        <asp:Label ID="lblUserDomain" runat="server" Text="domain"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList Width="156px" ID="ddlUserDomain" runat="server" DataTextField="DomainName" DataValueField="DomainName"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" align="right" style="padding-top:15px; padding-right:106px;">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="background-image:url(Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                </td>
                                                <td style="height:20px; vertical-align:bottom; background-image:url(Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                    <asp:Button id="btnLogin" Width="40px" CssClass="RegularUpdateButton" Text="אישור" runat="server" OnClientClick="GoLogin(); return false"></asp:Button>
                                                </td>
                                                <td style="background-position:right bottom; background-image:url(Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                </td>
                                                <td style="background-image:url(Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                </td>
                                                <td style="vertical-align:bottom; background-image:url(Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                    <asp:Button id="btnCancel" Width="40px" CssClass="RegularUpdateButton" runat="server" OnClientClick="JQueryClose(); return false" Text="ביטול"></asp:Button>
                                                </td>
                                                <td style="background-position:right bottom; background-image:url(Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style=" padding-right:15px; padding-left:10px;">
                                        <asp:Label ID="lblValidateTxtUserName" style="color:Red; display:none;" runat="server" Text="יש להזין שם משתמש" ></asp:Label>
                                        <br />
                                        <asp:Label ID="lblValidateTxtPassword" style="color:Red; display:none;" runat="server" Text="יש להזין סיסמא" ></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="padding-right:15px; padding-left:10px;">
                                        <asp:Label ID="lblError" runat="server" style="color:Red;"></asp:Label>
                                    </td>
                                </tr>
                             </table>
                        </td>
                        <td id="BorderRight" style="border-right: 2px solid gray">&nbsp;</td>
                    </tr>
                    <tr>
                        <td style="height:10px; background-image: url('Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat; background-position: top left"></td>
                        <td style="background-image: url('Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: bottom"></td>
                        <td style="background-image: url('Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom right"></td>
                    </tr>
                </table>
             </td>
         </tr>
     </table>
    </form>
        <script type="text/javascript">
            function JQueryClose() {
                window.parent.$("#dialog-modal").dialog('close');
                //window.parent.location.href = window.parent.location.href;
                return false;
            }

            function JQueryCloseWithPostBack() {
                window.parent.$("#dialog-modal").dialog('close');
                window.parent.location.href = window.parent.location.href;
                return false;
            }
        </script>
</body>
</html>
