<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_DeptReceptionAndRemarks" Codebehind="DeptReceptionAndRemarks.ascx.cs" %>
<%@ Reference Control="GridDeptReceptionHoursByType.ascx" %>
<script type="text/javascript">

    function OpenNewHoursWindow(deptCode, expireDate) {
        var mainDirectory = document.location.toString().split(document.domain)[1].split("/")[1];
        var dialogWidth = 845;
        var dialogHeight = 680;
        var title = "שעות קבלה של יחידה";

        var strUrl = "/" + mainDirectory + "/Public/DeptReceptionPopUp.aspx?DeptCode=" + deptCode + "&expirationDate=" + expireDate;

        OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title,"right");
    }

    function OpenReceptionWindowDialog(deptCode, ServiceCodes) {
        var dialogWidth = 845;
        var dialogHeight = 640;
        var title = "שעות קבלה של יחידה";

        var url = "Public/DeptReceptionPopUp.aspx?deptCode=" + deptCode + "&ServiceCodes=" + ServiceCodes;

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
    }

    function closeWindow() {
        self.close()
    }
    
</script>
<div style="height: 270px; overflow-y: scroll;direction:ltr;" class="ScrollBarDiv">
    <div id="divDefaultReceptionHours" runat="server" style="direction:rtl;float:right;">
    </div>
                        
    <div id="divOtherReceptionHours" runat="server" style="direction:rtl;float:right;margin-right:7px;">
    </div>
</div>
<div style="background-color: #2889E4;text-align:right;margin-top:10px;padding-right:20px;">
    <asp:Label ID="lblClinicRemarkHeader" runat="server" Width="380px" CssClass="LabelBoldWhite" EnableTheming ="false">הערות ליחידה</asp:Label> 
    <asp:Label ID="lblServiceRemarkHeader" runat="server" Width="380px" CssClass="LabelBoldWhite" EnableTheming ="false">הערות לנותני שירות ביחידה</asp:Label> 
</div>
<div style="height: 200px; overflow-y: scroll;direction:ltr;" class="ScrollBarDiv">
    <div style="direction:rtl; float:right; width:390px; height:80px">
        <asp:GridView ID="gvRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
        EmptyDataText="אין הערות לרופא\עובד" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
        OnRowDataBound="gvRemarks_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; vertical-align:top">
                                <div style="width: 15px;">
                                    <asp:Image ID="imgInternet" runat="server" />
                                </div>
                            </td>
                            <td style="vertical-align:top">
                                &diams;&nbsp;
                            </td>
                            <td>
                                <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("RemarkText")%>'></asp:Label>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    </div>
    <div style="direction:rtl; float:right;">
        <asp:GridView ID="gvEmployeeAndServiceRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvEmployeeAndServiceRemarks_RowDataBound"
                Width="390px">
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <table style="padding:0">
                            <tr>
                                <td colspan="3">
                                    <asp:Label ID="lblEmployeeName" runat="server" Text='<% #Bind("EmployeeName")%>' CssClass="BlueBoldLabel" EnableTheming="false"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; vertical-align:top">
                                    <div style="width: 15px;">
                                        <asp:Image ID="imgInternet" runat="server" />
                                    </div>
                                </td>
                                <td style="vertical-align:top">
                                    &diams;&nbsp;
                                </td>
                                <td><div style="float:right">
                                    <asp:Label ID="lblService" runat="server" Text='<% #Bind("ServiceName")%>' CssClass="LabelCaptionGreenBold_13" EnableTheming="false"></asp:Label>
                                    </div>
                                    <div style="float:right">
                                    <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("Remark")%>'></asp:Label>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</div>
