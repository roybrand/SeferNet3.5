<%@ Page Language="C#" AutoEventWireup="true" Inherits="Public_PopulationDetails" Codebehind="PopulationDetails.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html dir="rtl" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="Stylesheet" href="../CSS/General/general.css" type="text/css" />
    <script language="javascript" type="text/javascript">

        function CloseWindow() {
            window.close();
        }

    </script>
</head>
<body dir="rtl">
    <form id="form1" runat="server">
        <div style="padding:10px 10px 10px 10px">
            
            <asp:Image runat="server" ID="imgPopulationsImageTitle" Width="161px" Height="19px" AlternateText="תיאור אוכלוסיות" ToolTip="תיאור אוכלוסיות" ImageUrl="../Images/PopulationTitle.gif" Visible="false" />
            <div style="text-align: right; background-color: #2889e4; line-height:30px; padding-right: 5px;vertical-align:middle;padding-top:3px">
                <asp:Label runat="server" CssClass="LabelBoldWhite" style="color:#ffffff;font-size:16px" ID="lblPopulationsDesc"></asp:Label>
            </div>
            <br />
            <div style="padding-right:5px;">
            <asp:Label runat="server" ID="lblSettingsDesc"></asp:Label>
            <br />
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td style="position: absolute; bottom: 15px; left: 15px;" align="left">
                        <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                    background-position: bottom left;">
                                    &nbsp;
                                </td>
                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                    background-repeat: repeat-x; background-position: bottom;">
                                    <asp:Button ID="btnClose" runat="server" Text="סגירה" CssClass="RegularUpdateButton"
                                        OnClientClick="SelectJQueryClose(); return false;"></asp:Button>
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
            </div>
        </div>
    </form>
<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
