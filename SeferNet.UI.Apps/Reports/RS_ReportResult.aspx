<%@ Page Language="C#" AutoEventWireup="true" Inherits="Reports_RS_ReportResult"
    MasterPageFile="~/SeferMasterPage.master" CodeBehind="RS_ReportResult.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<%@ PreviousPageType VirtualPath="~/Reports/ReportsParameters.aspx" %>

<asp:Content ID="Content2" ContentPlaceHolderID="phHead" runat="server">
    <style type="text/css">
        .cssRTLBeKoah, .cssRTLBeKoah div, .cssRTLBeKoah td, .cssRTLBeKoah table
        {
            direction: rtl !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="postBackPageContent" runat="server">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                background-position: bottom left;">
                &nbsp;
            </td>
            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                background-repeat: repeat-x; background-position: bottom;">
                <asp:Image ID="imgExcel" ImageUrl="~/Images/btnExcel.gif" runat="server" />
                <asp:Button ID="btnExcel2" Width="80px" runat="server" CssClass="RegularUpdateButton"
                    Text="Excel מורחב " CausesValidation="False" OnClick="btnExcel_Click" />
            </td>
            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                background-repeat: no-repeat;">
                &nbsp;
            </td>
            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                background-position: bottom left;">
                &nbsp;
            </td>
            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                background-repeat: repeat-x; background-position: bottom;">
                <asp:Button ID="btnBack" Width="80px" runat="server" CssClass="RegularUpdateButton"
                    Text="חזרה " CausesValidation="False" OnClick="btnBack_Click" />
            </td>
            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                background-repeat: no-repeat;">
                &nbsp;
            </td>
        </tr>
    </table>
    <table style="width: 980px">
        <tr>
            <td>
            </td>
            <td>
                <rsweb:ReportViewer ID="rpvMain" runat="server" Style="height: 500px; width: 980px;overflow-x:auto !important;"
                    SizeToReportContent="false" ShowParameterPrompts="False" AsyncRendering="true"
                    CssClass="cssRTLBeKoah">
                </rsweb:ReportViewer>
            </td>
            <td>
            </td>
        </tr>
    </table>
    <script type="text/javascript" language="javascript">

        function ExportExtended() {
            document.getElementById('<% = btnExcel.ClientID %>').click();
        }

    </script>
</asp:Content>
<asp:Content ID="cPostBackContent" ContentPlaceHolderID="postBackContent" runat="server">
    <asp:Button ID="btnExcel" Width="80px" runat="server" CssClass="DisplayNone" Text="Excel מורחב "
        CausesValidation="False" OnClick="btnExcel_Click" />
</asp:Content>
