<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="ClinicDetails" Codebehind="ClinicDetails.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="Stylesheet" type="text/css" href="../CSS/General/general.css" />
    <base target="_self" />
    <title>פרטים נוספים לרשומה השגויה</title>
    <script type="text/javascript" language="javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" dir="rtl">
    <table cellpadding="0" cellspacing="0" style="width:100%">
        <tr>
            <td style="background-color: #2889E4; padding-right:10px; width:100%">
                <asp:Label ID="lblRemarksCaption_Reception" EnableTheming="false" CssClass="LabelBoldWhite"
                    runat="server" Text="פרטים נוספים לרשומה השגויה"></asp:Label>
            </td>
        </tr>
    </table>
    <div style="width: 100%; height: 280px; overflow-y: scroll;
        direction: ltr" class="ScrollBarDiv" >
        <table id="tblDoctors" class="SimpleText" dir="rtl" cellpadding="0" cellspacing="0"
            style="width: 97%; color: #505050; background-color: white;">
            <tr>
                <td>
                    <asp:DetailsView ID="dvClinicDetailes" runat="server"
                        Width="100%" SkinID="dvClinicDetailes" ondatabinding="dvClinicDetailes_DataBinding"> 
                        <Fields>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <table cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="width:150px; padding-right:10px" >
                                                <asp:Label ID="lbldeptCodeCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="קוד מרפאה"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="width:200px;border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lbldeptCode" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("deptCode") %>'></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblDeptNameCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="שם מרפאה"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblDeptName" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("deptName") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblDistrictCodeCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="מחוז"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblDistrictCode" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("districtCode") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblCityCodeCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="קוד יישוב"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblCityCode" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("CityCode") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblCityNameCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="שם יישוב"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblCityName" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("cityName") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblStreetCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="רחוב"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblStreet" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("streetName") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblHouseCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="בית"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblHouse" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("house") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblEntranceCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="כניסה"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblEntrance" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("entrance") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblFlatCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="דירה"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblFlat" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("flat") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblZipCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="מיקוד"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblZip" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("zipCode") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblPhone1Caption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="טלפון 1"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblPhone1" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("phone1") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblPhone2Caption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="טלפון 2"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblPhone2" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("phone2") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblFaxCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="פקס"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblFax" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("fax") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblManagerNameCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="שם מנהל"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblManagerName" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("managerName") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" class="BorderBottomLight" style="padding-right:10px" >
                                                <asp:Label ID="lblEmailCaption" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="דוא''ל"></asp:Label>
                                            </td>
                                            <td align="right" class="BorderBottomLight" style="border-right:1px solid #dddddd;padding-right:10px">
                                                <asp:Label ID="lblEmail" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("email") %>'></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Fields>
                    </asp:DetailsView>
                </td>
            </tr>
        </table>
    </div>
    
    <div style="text-align:center;">
        <asp:ImageButton ID="btnClosePopup" OnClientClick="SelectJQueryClose();"
            runat="server" ImageUrl="../Images/Applic/btn_ClosePopUpBlue.gif" />
    </div>
    </form>
</body>
</html>
