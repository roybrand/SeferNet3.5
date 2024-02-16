<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_PopupYesNo" Codebehind="PopupYesNo.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <link rel="Stylesheet" type="text/css" href="../CSS/General/general.css" />
    <title>שים לב</title>

    <script language="javascript" type="text/javascript">

        function SetText() {

            params = window.dialogArguments;

            
            document.getElementById('lblMessage').innerHTML = params.Message;
            document.getElementById('btnNo').value = params.NoButtonText;
            document.getElementById('btnYes').value = params.YesButtonText;

            // minimum width
            if (params.NoButtonText.length < 3)
                document.getElementById('btnNo').style.width = "40px";
                
            if (params.YesButtonText.length < 3)
                document.getElementById('btnYes').style.width = "40px";                
            
            document.getElementById('btnNo').focus();
            
        }

        function ReturnValues(answer) {

            window.returnValue = answer;
            self.close();
        }
    </script>

</head>
<body dir="rtl" onload="SetText();" >
    <form id="form1" runat="server" defaultbutton="btnNo">
    <table cellpadding="0" cellspacing="0" border="0" style="margin: 5px 5px 5px 5px">
        <tr>
            <td style="padding-bottom: 20px" class="LabelBoldRed_13">
               <asp:label id="lblMessage" runat="server" EnableTheming="false"></asp:label>
            </td>
        </tr>
        <tr>
            <td align="left">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;" align="center">
                            <asp:Button  ID="btnYes" runat="server" CssClass="RegularUpdateButton" OnClientClick="ReturnValues(true);">
                            </asp:Button>
                        </td>
                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                            background-repeat: no-repeat;">
                            &nbsp;&nbsp;&nbsp;
                        </td>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;" align="center">
                            <asp:Button  ID="btnNo" runat="server"  CssClass="RegularUpdateButton" OnClientClick="ReturnValues(false);">
                            </asp:Button>
                        </td>
                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                            background-repeat: no-repeat;">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
