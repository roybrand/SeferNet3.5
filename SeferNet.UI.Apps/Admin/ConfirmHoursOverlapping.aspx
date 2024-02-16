<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ConfirmHoursOverlapping.aspx.cs" Inherits="SeferNet.UI.Apps.Admin.ConfirmHoursOverlapping" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="STYLESHEET" href="CSS/General/general.css" type="text/css" />
    <title></title>
    <style type="text/css">
        .RegularUpdateButton {
            margin-right: 0px;
        }
        .LabelRed_14
        {
            font-family: arial;
     
            font-size: 14px;
            color: Red;
        }
        .LabelBlack_14
        {
            font-family: arial;

            font-size: 14px;
            color: black;
        }

    </style>
    <script type="text/javascript">
        function Go() {
            var obj = new Object();
            obj.Continue = true;
            window.returnValue = obj;
            self.close();
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
                            <td dir="ltr" colspan="2" align="center">
                                <asp:Label ID="lblText" runat="server" Text="! קיימות שעות חופפות לשירות באותה היחידה " CssClass="LabelRed_14" EnableTheming="false"></asp:Label>
                                    <br /> <br />

                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td><asp:Label ID="lblText3" runat="server" CssClass="LabelBlack_14" Text="?" EnableTheming="false" Width="12px"></asp:Label></td>
                            <td>
                                <asp:Label ID="lblText2" runat="server" CssClass="LabelBlack_14" Width="280px" EnableTheming="false" Text="האם לשנות את שעות הקבלה בהתאם לעדכון החדש"></asp:Label>
                            </td>

                        </tr>
                        <tr>
                            <td align="center" style="padding-top:35px;" colspan="2">
                                <table cellpadding="0" cellspacing="0" dir="rtl">
                                    <tr>

                                        <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                            <asp:Button id="btnCancel" Width="70px" runat="server" Text="Cancel" cssClass="RegularUpdateButton" 
                                                OnClientClick="self.close(); return false" ></asp:Button>
                                        </td>

                                        <td>&nbsp;&nbsp;&nbsp;
                                        </td>

                                        <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                            <asp:Button id="btnGo" Width="70px" runat="server" Text="OK" cssClass="RegularUpdateButton" 
                                                OnClientClick="Go(); return false" ></asp:Button>
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
