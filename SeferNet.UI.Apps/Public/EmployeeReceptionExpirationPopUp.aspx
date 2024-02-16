<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="EmployeeReceptionExpirationPopUp" Theme="SeferGeneral" Codebehind="EmployeeReceptionExpirationPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>שעות קבלה של רופא</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="Stylesheet" href="../CSS/General/general.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <table cellpadding="0" cellspacing="0" width="100%" style="height: 100%;">
        <tr>
            <td valign="top">
                <table class="SimpleText" style="background-color: White" dir="rtl" width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td valign="top" class="BackColorBlue">
                            <table cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="width: 100%; height: 28px; padding-right: 5px">
                                        <asp:Label ID="lblName" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                        <asp:Label ID="lblExpert" runat="server" EnableTheming="false" CssClass="LabelBoldWhite"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:5px" align="right">
                            <asp:Label ID="lblExpirationDate" runat="server" Width="250px" EnableTheming="false"
                                CssClass="RemarkLabel"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid #cccccc;">
                            <div class="ScrollBarDiv" style="height: 230px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <table>
                                        <tr >
                                            <td style="border-bottom: 2px solid #BADBFC;">
                                                <table cellpadding="0" cellspacing="0" border="0">
                                                    <tr>
                                                        <td style="width: 30px" align="center">
                                                            <asp:Label ID="lblDay" runat="server" Text="יום" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                        <td style="width: 65px" align="center">
                                                            <asp:Label ID="lblFromHour" runat="server" Text="משעה" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                        <td style="width: 65px" align="right">
                                                            <asp:Label ID="lblToHour" runat="server" Text="עד שעה" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                        <td style="width: 230px" align="right">
                                                            <asp:Label ID="lblClinicName" runat="server" Text="במרפאה" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                        <td style="width: 150px" align="right">
                                                            <asp:Label ID="lblProfAndServ" runat="server" Text="תחום שירות" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                        <td style="width: 240px">
                                                            <asp:Label ID="lblRemarks" runat="server" Text="הערות" CssClass="LabelCaptionGreenBold_12"
                                                                EnableTheming="false"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:GridView ID="gvEmployeeReceptionDays_All" runat="server" AutoGenerateColumns="false"
                                                    SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvEmployeeReceptionDays_All_RowDataBound">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <table cellpadding="0" cellspacing="0" style="border-bottom: 2px solid #BADBFC;">
                                                                    <tr>
                                                                        <td style="width: 30px; background-color: #E1F0FC;" align="center">
                                                                            <asp:Label ID="lblDay" runat="server" Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                                                        </td>
                                                                        <td>
                                                                            <asp:GridView ID="gvReceptionHours_All" runat="server" AutoGenerateColumns="false"
                                                                                SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvReceptionHours_All_RowDataBound">
                                                                                <Columns>
                                                                                    <asp:TemplateField>
                                                                                        <ItemTemplate>
                                                                                            <table id="tblReceptionHours_Inner" runat="server" cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td style="width: 60px" align="center" valign="top">
                                                                                                        <asp:Label ID="lblFromHour" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                                                    </td>
                                                                                                    <td style="width: 55px" align="center" valign="top">
                                                                                                        <asp:Label ID="lblToHour" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                                                    </td>
                                                                                                    <td style="width: 230px; padding-right: 13px">
                                                                                                        <asp:Label ID="lblClinicName" runat="server" Text='<%#Bind("deptName") %>'></asp:Label>
                                                                                                    </td>
                                                                                                    <td style="width: 150px">
                                                                                                        <asp:Label ID="lblProfessions" runat="server" Text='<%#Bind("professions") %>'></asp:Label>
                                                                                                        <asp:Label ID="lblServices" runat="server" Text='<%#Bind("services") %>'></asp:Label>
                                                                                                    </td>
                                                                                                    <td style="width: 240px">
                                                                                                        <asp:Label ID="lblReceptionRemarks" runat="server" Text='<%#Bind("receptionRemarks") %>'></asp:Label>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td style="padding-left: 10px; padding-top: 10px" align="left">
                <table cellpadding="0" cellspacing="0" dir="rtl">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="Button1" runat="server" Text="סגירה" CssClass="RegularUpdateButton"
                                OnClientClick="JQueryDialogClose();"></asp:Button>
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
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</body>
</html>
