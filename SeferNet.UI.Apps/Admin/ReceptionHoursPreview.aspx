<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_ReceptionHoursPreview" Codebehind="ReceptionHoursPreview.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="Stylesheet" type="text/css" href="../CSS/General/general.css" />
    <base target="_self" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <title>תצוגה מקדימה</title>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
        return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" dir="rtl">
    <div id="divEmployeeReceptionPerUnit" runat="server" style="width: 100%;
        border: solid 1px #777777; direction: ltr" visible="false">
        <table id="tblDoctors" class="SimpleText" dir="rtl" cellpadding="0" cellspacing="0"
            style="color: #505050; background-color: white;" width="100%">
            <tr>
                <td>
                    <table cellpadding="0" border="0" cellspacing="0" style="background-color: #2889E4;
                        margin-top: 1px" width="100%">
                        <tr>
                            <td style="padding-right: 5px" width="130px">
                                <asp:Label ID="lblEmployeeName" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                            </td>
                            <td style="padding-right: 5px">
                                <asp:Label ID="lblEmployeeProfessions" EnableTheming="false" CssClass="LabelBoldWhite"
                                    runat="server" Text=""></asp:Label>
                            </td>
                            <td style="padding-right: 5px; padding-left: 5px">
                                <asp:Label ID="lblClinicName" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                            </td>
                            <td style="padding-right: 5px" align="left">
                                <asp:Label ID="lblPhoneCaption" EnableTheming="false" CssClass="LabelNormalWhite"
                                    runat="server" Text="טל':"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="lblPhone" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                            </td>
                            <td style="padding-right: 5px" align="left">
                                <asp:Label ID="lblFaxCaption" EnableTheming="false" CssClass="LabelNormalWhite" runat="server"
                                    Text="פקס:"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="lblFaxs" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="border-bottom:3px solid #cccccc; width: 100%; direction:ltr; text-align: right; height: 250px; overflow: auto;" class="ScrollBarDiv" >
                        <asp:GridView ID="gvOuterForEmployeeHours" runat="server" AutoGenerateColumns="false"
                             HorizontalAlign="Right" HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView" 
                            OnRowDataBound="gvOuterForEmployeeHours_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <table cellpadding="0" cellspacing="0" dir="rtl"
                                              style="border: 1px solid #cccccc;margin-top: 12px;margin-right:10px;margin-bottom:10px">
                                            <tr>
                                                <td style="padding: 5px 5px 5px 0px" colspan="2">
                                                    <asp:Label ID="lblProfessionsAndServicesHamesCaption" runat="server" EnableTheming="false"
                                                        CssClass="LabelCaptionGreenBold_14" Text="תחום שירות: ">
                                                    </asp:Label>
                                                    <asp:Label ID="lblProfessionsAndServicesName" runat="server" CssClass="LabelCaptionGreenBold_14"
                                                        EnableTheming="false"><%# Eval("Desc") %></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table cellpadding="0" cellspacing="0" style="border-bottom: solid 2px #BADBFC;">
                                                        <tr>
                                                            <td style="width: 20px" align="center">
                                                                <asp:Label ID="lblDay" runat="server" Text="יום" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                            </td>
                                                            <td style="width: 50px; padding-right: 15px" align="right">
                                                                <asp:Label ID="lblFromHour" runat="server" Text="משעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                            </td>
                                                            <td style="width: 100px" align="right">
                                                                <asp:Label ID="lblToHour" runat="server" Text="עד שעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                            </td>
                                                            <td style="width: 350px" align="right">
                                                                <asp:Label ID="lblRemarks" runat="server" Text="הערות" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:GridView ID="gvReceptionDays" runat="server" AutoGenerateColumns="false" Width="100%"
                                                        HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView" OnRowDataBound="gvReceptionDays_RowDataBound">
                                                        <Columns>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <table>
                                                                        <tr>
                                                                            <td style="width: 25px; background-color: #E1F0FC;" align="center">
                                                                                <asp:Label ID="Label1" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                    Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                                                            </td>
                                                                            <td>
                                                                                <asp:GridView ID="gvReceptionHours" runat="server" AutoGenerateColumns="false" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                    HeaderStyle-CssClass="DisplayNone">
                                                                                    <Columns>
                                                                                        <asp:TemplateField>
                                                                                            <ItemTemplate>
                                                                                                &nbsp;&nbsp;&nbsp;<asp:Label ID="lblFromHour" Width="50px" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:TemplateField ItemStyle-Width="100px">
                                                                                            <ItemTemplate>
                                                                                                <asp:Label ID="lblToHour" Width="100px" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:TemplateField>
                                                                                            <ItemTemplate>
                                                                                                <asp:Label ID="lblReceptionRemarks" Width="350px" runat="server" Text='<%#Bind("receptionRemarks") %>'></asp:Label>
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
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="background-color: #2889E4;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                        <tr>
                            <td style="width: 100%; padding-right: 5px">
                                <asp:Label ID="lblRemarksCaption_Reception" EnableTheming="false" CssClass="LabelNormalWhite"
                                    runat="server" Text="הערות ליחידה"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding-right: 5px">
                    <asp:Label ID="lblRemarks_Reception" runat="server" EnableTheming="false" CssClass="RegularLabel"></asp:Label>&nbsp;&nbsp;
                </td>
            </tr>
        </table>
    </div>
    
    <div id="divEmployeeReceptionForAllUnits" runat="server">
        <table style="width: 100%; border: solid 1px #D4EAFB; background-color: White" dir="rtl">
            <tr>
                <td style="border-bottom: 2px solid #BADBFC;padding-right:13px">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="width: 32px" align="center">
                                <asp:Label ID="lblDay" runat="server" Text="יום" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                            <td style="width: 40px" align="left">
                                <asp:Label ID="lblFromHour" runat="server" Text="משעה" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                            <td style="width: 65px" align="center">
                                <asp:Label ID="lblToHour" runat="server" Text="עד שעה" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                            <td style="width: 157px" align="right">
                                <asp:Label ID="Label2" runat="server" Text="במרפאה" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                            <td style="width: 110px">
                                <asp:Label ID="lblProfAndServ" runat="server" Text="תחום שירות" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="lblRemarks" runat="server" Text="הערות" CssClass="LabelCaptionGreenBold_12"
                                    EnableTheming="false"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="height: 250px;overflow-y:scroll;text-align:right;width:97%;" class="ScrollBarDiv" dir="ltr">
                        <asp:GridView ID="gvEmployeeReceptionDays_All" runat="server" AutoGenerateColumns="false"
                        SkinID="SimpleGridViewNoEmtyDataText"  HeaderStyle-CssClass="DisplayNone" Width="97%"
                        OnRowDataBound="gvEmployeeReceptionDays_All_RowDataBound">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <table cellpadding="0" cellspacing="0" style="border-bottom: 2px solid #BADBFC" dir="rtl" width="100%">
                                        <tr>
                                            <td style="width: 25px; background-color: #E1F0FC;" align="center">
                                                <asp:Label ID="lblDay" runat="server" Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                            </td>
                                            <td>
                                                <asp:GridView ID="gvReceptionHours_All" runat="server" AutoGenerateColumns="false"
                                                    SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" Width="100%"
                                                    OnRowDataBound="gvReceptionHours_All_RowDataBound" >
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="100%">
                                                            <ItemTemplate>
                                                                <table id="tblReceptionHours_Inner" border="0" runat="server" width="100%" cellpadding="0"
                                                                    cellspacing="0">
                                                                    <tr>
                                                                        <td style="width: 40px" align="left" valign="top">
                                                                            <asp:Label ID="lblFromHour" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                        </td>
                                                                        <td style="width: 65px" align="center" valign="top">
                                                                            <asp:Label ID="lblToHour" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                        </td>
                                                                        <td style="width: 160px" valign="top">
                                                                            <asp:Label ID="lblClinicName" runat="server" Text='<%#Bind("deptName") %>'></asp:Label>
                                                                        </td>
                                                                        <td style="width: 110px" valign="top">
                                                                            <asp:Label ID="lblProfessions" runat="server" Text='<%#Bind("ItemDesc") %>'></asp:Label>
                                                                        </td>
                                                                        <td valign="top">
                                                                            <asp:Label ID="lblReceptionRemarks" runat="server"></asp:Label>
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
                    </div>
                </td>
            </tr>
        </table>
    </div>
    
    <div id="divDeptReception" runat="server" style="width: 100%;border: solid 1px #777777; direction: ltr">
        <table id="tblGvDeptReception" runat="server" cellpadding="0" border="0" cellspacing="0"
            dir="rtl" width="100%">
            <tr>
                <td style="border-bottom: solid 2px #BADBFC; border-top: solid 1px #DDDDDD; border-left: solid 1px #DDDDDD;
                    border-right: solid 1px #DDDDDD;">
                       <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td colspan="4" style="padding-right: 5px;" align="right">
                                <table cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td align="right" style="padding: 5px 0px 5px 0px">
                                            <asp:Label ID="lblDeptReceptionCaption" CssClass="LabelCaptionGreenBold_18" EnableTheming="false"
                                                runat="server" Text="שעות קבלה למרפאה"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 30px;padding-right:15px" align="center">
                                <asp:Label ID="lblDeptReceptionDay" CssClass="LabelCaptionBlueBold_13" runat="server"
                                    EnableTheming="false" Text="יום"></asp:Label>
                            </td>
                            <td style="width: 45px" align="center">
                                <asp:Label ID="lblDeptReceptionFrom" CssClass="LabelCaptionBlueBold_13" runat="server"
                                    EnableTheming="false" Text="משעה"></asp:Label>
                            </td>
                            <td style="width: 50px" align="center">
                                <asp:Label ID="lblDeptReceptionTo" CssClass="LabelCaptionBlueBold_13" runat="server"
                                    EnableTheming="false" Text="עד שעה"></asp:Label>
                            </td>
                            <td style="width: 365px; padding-right: 10px" align="right">
                                <asp:Label ID="lblDeptReceptionRemarks" CssClass="LabelCaptionBlueBold_13" runat="server"
                                    EnableTheming="false" Text="הערות"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: solid 1px #DDDDDD; border-left: solid 1px #DDDDDD; border-right: solid 1px #DDDDDD;">
                    <div style="height:250px;overflow-y:scroll;width:100%;text-align:right;" class="ScrollBarDiv" dir="ltr" >
                        <asp:GridView ID="gvDeptReception" runat="server" EnableTheming="false" AutoGenerateColumns="false"
                        GridLines="None" ShowHeader="false" OnRowDataBound="gvDeptReception_RowDataBound">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <table cellpadding="0" cellspacing="0" dir="rtl">
                                        <tr>
                                            <td style="width: 40px; background-color: #E1F0FC; border-bottom: solid 2px #BADBFC;"
                                                align="center">
                                                <asp:Label ID="lblDayLeft" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                    Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                            </td>
                                            <td id="tdGvClinicHours" runat="server" style="border-bottom: solid 2px #BADBFC;
                                                border-left: solid 1px #DDDDDD;">
                                                <asp:GridView ID="gvDeptHours" runat="server" EnableTheming="false" AutoGenerateColumns="false"
                                                    GridLines="None" HeaderStyle-CssClass="DisplayNone">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <table id="tblGvClinicHours_Item" runat="server" cellpadding="0" cellspacing="0"
                                                                    border="0">
                                                                    <tr>
                                                                        <td style="width: 45px" align="center">
                                                                            <asp:Label ID="lblOpeningHour" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                        </td>
                                                                        <td style="width: 50px" align="center">
                                                                            <asp:Label ID="lblClosingHour" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                        </td>
                                                                        <td align="right" style="padding-right: 10px; width: 540px">
                                                                            <asp:Label ID="lblHourRemarks" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                Text='<%#Bind("remarkText") %>'></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </td>
                                            <td style="width: 10px">
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    
    
    <div style="text-align: left;position:absolute;right:15px;bottom:15px;">
        <table cellpadding="0" cellspacing="0">
            <tr>
                <td class="buttonRightCorner">
                    &nbsp;
                </td>
                <td class="buttonCenterBackground">
                    <asp:Button ID="btnClosePopup" Text="סגירה" runat="server" CssClass="RegularUpdateButton"
                        OnClientClick="SelectJQueryClose();" />
                </td>
                <td class="buttonLeftCorner">
                    &nbsp;
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
