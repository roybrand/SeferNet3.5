<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_GridDeptReceptionHoursByType" Codebehind="GridDeptReceptionHoursByType.ascx.cs" %>
<script type="text/javascript">
    function setReceptionDisplay(obj, gdClassName) {
        switch (obj.className) {
            case "btnPlus":
                obj.className = "btnMinus";
                $("." + gdClassName).show();
                $("#" + obj.id).parent().css("border-left", "1px solid #dddddd");
                break;
            case "btnMinus":
                obj.className = "btnPlus";
                $("." + gdClassName).hide();
                $("#" + obj.id).parent().css("border-left", "none");
                break;
        }
    }
</script>

<div style="width:385px;border-left:1px solid #dddddd;" id="divReceptionTitle" runat="server">
    <div id="divBtnPlusMinus" runat="server" class="btnMinus" onclick="setReceptionDisplay(this,'classA');"
     style="float:right;margin-top:5px;margin-left:5px;cursor:pointer;"></div>
    <asp:Label ID="lblOfficeReceptionCaption" CssClass="LabelCaptionDarkGreenBold_18" EnableTheming="false"
         runat="server" Text="שעות קבלה"></asp:Label>

</div>
<div id="divReceptionHoursType" runat="server" class="classA" style="margin-bottom:20px;">
    <div style="width:385px;border-left:1px solid #dddddd;border-bottom:2px solid #e1f0fc;">
        <asp:Label ID="lblDeptReceptionDay" CssClass="LabelCaptionBlueBold_13" runat="server"
            EnableTheming="false" Width="42" style="text-align:center;" Text="יום"></asp:Label>
        <asp:Label ID="lblDeptReceptionFrom" CssClass="LabelCaptionBlueBold_13" runat="server"
            EnableTheming="false" Width="46" style="text-align:center;" Text="משעה"></asp:Label>
        <asp:Label ID="lblDeptReceptionTo" CssClass="LabelCaptionBlueBold_13" runat="server"
            EnableTheming="false" Width="46" style="text-align:center;" Text="עד שעה"></asp:Label>
        <asp:Label ID="lblDeptReceptionRemarks" CssClass="LabelCaptionBlueBold_13" runat="server"
            EnableTheming="false" Width="40" style="text-align:center;" Text="הערות"></asp:Label>
    </div>
    <asp:GridView ID="gvDeptReception" runat="server" EnableTheming="false" AutoGenerateColumns="false"
        GridLines="None" EnableViewState="false" Width="387" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvDeptReception_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <table cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td style="width: 40px; background-color: #E1F0FC; border-bottom: solid 2px #BADBFC;"
                                align="center">
                                <asp:Label ID="lblDayLeft" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                    Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                            </td>
                            <td id="tdGvClinicHours" runat="server" style="border-bottom: solid 2px #BADBFC;border-left: solid 1px #dddddd;">
                                <div style="">
                                    <asp:GridView ID="gvClinicHours" runat="server" EnableTheming="false" AutoGenerateColumns="false" 
                                        GridLines="None" HeaderStyle-CssClass="DisplayNone">
                                        <EmptyDataTemplate>
                                            <div style="width:342px"></div>
                                        </EmptyDataTemplate>
                                        <Columns>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <table id="tblGvClinicHours_Item" runat="server" cellpadding="0" cellspacing="0">
                                                        
                                                        <tr>
                                                            <td style="width: 49px;" align="center">
                                                                <asp:Label ID="lblOpeningHour" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                    Text='<%#Bind("openingHour") %>'></asp:Label>
                                                            </td>
                                                            <td style="width: 49px" align="center">
                                                                <asp:Label ID="lblClosingHour" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                    Text='<%#Bind("closingHour") %>'></asp:Label>
                                                            </td>
                                                            <td align="right" style="width:244px;">
                                                                <asp:Label ID="lblHourRemarks" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                    Text='<%#Bind("remarks") %>'></asp:Label>
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
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</div>