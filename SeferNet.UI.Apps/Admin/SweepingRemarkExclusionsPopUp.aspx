<%@ Page Language="C#" ResponseEncoding="utf-8" Culture="he-il" AutoEventWireup="true"
    UICulture="he-il" Inherits="SweepingRemarkExclusionsPopUp" Codebehind="SweepingRemarkExclusionsPopUp.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>הערה גורפת יחידות לא כלולות</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <link rel="STYLESHEET" href="../CSS/General/StyleGuide.css" type="text/css" />
    <link rel="SHORTCUT ICON" type="image/x-icon" href="../Images/Applic/favicon.ico" />
</head>
<body dir="rtl">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True">
        <Scripts>
            <asp:ScriptReference Path="~/Admin/scripts/RemarksPopUp.js" />
        </Scripts>
    </asp:ScriptManager>
    <asp:UpdatePanel runat="server" ID="UpdatePanel1">
        <ContentTemplate>
            <table border="0" dir="rtl" width="100%" cellpadding="0" cellspacing="0" 
                style="height: 100%">
                <tr style="background-color: #298AE5; height: 25px;">
                    <td colspan="2" valign="middle" class="LabelBoldWhite_18" style="padding-right: 5px;
                        padding-top: 3px; padding-bottom: 3px">
                        <asp:Label ID="lblCaption" runat="server" EnableTheming="false" Text="הערה גורפת יחידות לא כלולות"></asp:Label>
                    </td>
                </tr>
                <tr style="background-color: white; height: 25px;">
                    <td style="width: 25%; padding-right: 20px" align="right">
                        <asp:Label ID="lblDeptCode_Header" EnableTheming="False" CssClass="LabelCaptionBlueBold_13"
                            runat="server" Text="קוד יחידה"></asp:Label>
                    </td>
                    <td style="width: 75%; padding-right: 10px" align="right">
                        <asp:Label ID="lblDeptName_Header" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"
                            runat="server" Text="שם יחידה"></asp:Label>
                    </td>
                </tr>
                <tr >
                    <td dir="rtl" colspan="2" align="right" 
                        style="border: 1px solid #cccccc; background-color: white; " valign="top"><%--height: 100%;--%>
                        <div class="ScrollBarDiv" style= " height:110px;  overflow-x: hidden; overflow-y: scroll;" 
                            dir="ltr">
                            <div dir="rtl">
                                <asp:GridView ID="gvDepts" runat="server" SkinID="SimpleGridView" AutoGenerateColumns="False"
                                    EnableTheming="False" ShowHeader="False" Width="100%" RowStyle-VerticalAlign="Top">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Name" >
                                            <ItemTemplate>
                                                <table style="width: 100%;" cellpadding="0" cellspacing="0">
                                                    <tr valign="top">
                                                        <td valign="top" width="25%" style="padding-right: 5px" height="5px">
                                                            <asp:Label runat="server" ID="lblRemarkText" Text='<%# Eval("ExcludedDeptCode") %>'
                                                                CssClass="RegularLabel" ></asp:Label>
                                                        </td>
                                                        <td valign="top" width="75%" >
                                                            <asp:Label runat="server" ID="lblRemarkID" Text='<%# Eval("ExcludedDeptName") %>'
                                                                CssClass="RegularLabel"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ItemTemplate>
                                            <ItemStyle />
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr style="height: 25px">
                    <td align="left" colspan="2" valign="bottom">
                        <table style="margin-left: 10px; margin-top: 10px; margin-bottom: 10px">
                            <tr>
                                <td>
                                    <table cellpadding="0" cellspacing="0">
                                        <tr align="left">
                                            <td class="buttonRightCorner">
                                                &nbsp;
                                            </td>
                                            <td class="buttonCenterBackground">
                                                <asp:Button ID="btnCancel" runat="server" Text="סגירה" OnClientClick="SelectJQueryClose();"
                                                    CssClass="RegularUpdateButton" />
                                            </td>
                                            <td class="buttonLeftCorner">
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
