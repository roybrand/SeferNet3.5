<%@ Page Title="מבנה ארגוני" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" Inherits="Public_OrganizationTree" MaintainScrollPositionOnPostback="true" Codebehind="OrganizationTree.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">

    <asp:DataList ID="dtlMain" runat="server" Width="990px" OnItemCommand="button_ItemCommand"
        OnItemDataBound="dtlMain_ItemDataBound">
        <ItemStyle BackColor="#FEFEFE" />
        <AlternatingItemStyle BackColor="#F3F3F3" />
        <HeaderStyle CssClass="LabelCaptionGreenBold_12" BackColor="#F7FAFF" />
        <HeaderTemplate>
            <table width="990px">
                <tr>
                    <td style="width: 360px">
                        שם מרפאה
                    </td>
                    <td style="width: 140px">
                        סוג יחידה
                    </td>
                    <td style="width: 220px">
                        כתובת
                    </td>
                    <td style="width: 121px">
                        יישוב
                    </td>
                    <td>
                        טלפון
                    </td>
                </tr>
            </table>
        </HeaderTemplate>
        <ItemTemplate>
            <div style="padding: 5px">
                <asp:ImageButton ID="btnPlus" runat="server" CommandName="Expand" CommandArgument='<%# Eval("DeptCode") %>'
                    ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif" />
                <asp:ImageButton ID="btnMinus" runat="server" CommandName="Collapse" CommandArgument='<%# Eval("DeptCode") %>'
                    Visible="false" ImageUrl="~/Images/Applic/btn_Minus_Blue_12.gif" />
                <asp:LinkButton ID="lnkDeptName" CommandArgument='<%# Eval("DeptCode") %>' CssClass="LooksLikeHRef"
                            runat="server" OnClick="linkDeptCode_click" Text='<%# Eval("DeptName") %>' Width="343px">
                </asp:LinkButton>                                
              
                <asp:Label ID="lblUnitType" runat="server" Text='<%# Eval("UnitTypeName") %>' Width="139px"></asp:Label>
                <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>' Width="220px"></asp:Label>
                <asp:Label ID="lblCity" runat="server" Text='<%# Eval("CityName") %>' Width="120px"></asp:Label>
                <asp:Label ID="lblPhone" runat="server" Text='<%# Eval("Phone") %>'></asp:Label>
            </div>
            <asp:Panel ID="pnlChildUnits" runat="server" Visible="false" Style="padding: 0px 20px 10px 0px"
                BackColor="#FEFEFE" BorderStyle="Solid" BorderColor="Gray" BorderWidth="1px">
                <asp:DataList ID="dtlAdministrations" OnItemCommand="button_ItemCommand" runat="server"
                    OnItemDataBound="dtlAdministrations_ItemDataBound" Width="100%">
                    <ItemStyle BackColor="#FEFEFE" />
                    <AlternatingItemStyle BackColor="#F3F3F3" />
                    <ItemTemplate>
                        <div style="padding: 5px">
                            <asp:ImageButton ID="btnPlus" runat="server" CommandName="Expand" CommandArgument='<%# Eval("DeptCode") + "#" + Eval("DistrictCode") %>'
                                ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif" />
                            <asp:ImageButton ID="btnMinus" runat="server" CommandName="Collapse" CommandArgument='<%# Eval("DeptCode")%>'
                                Visible="false" ImageUrl="~/Images/Applic/btn_Minus_Blue_12.gif" />
                             <asp:LinkButton ID="lnkDeptName" CommandArgument='<%# Eval("DeptCode") %>' CssClass="LooksLikeHRef"
                                            runat="server" OnClick="linkDeptCode_click" Text='<%# Eval("DeptName") %>' Width="321px">
                            </asp:LinkButton>
                            <asp:Label ID="lblUnitType" runat="server" Text='<%# Eval("UnitTypeName") %>' Width="140px"></asp:Label>
                            <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("Address") %>' Width="220px"></asp:Label>
                            <asp:Label ID="lblCity" runat="server" Text='<%# Eval("CityName") %>' Width="120px"></asp:Label>
                            <asp:Label ID="lblPhone" runat="server" Text='<%# Eval("Phone") %>'></asp:Label>
                        </div>
                        <asp:Panel ID="pnlDepts" runat="server" Visible="false" Style="padding: 3px 20px 10px 0px"
                            BackColor="#FEFEFE">
                            <asp:DataList ID="dtlDepts" runat="server" Width="100%" OnItemDataBound="dtlDepts_ItemDataBound">
                                <ItemStyle BackColor="#FEFEFE" />
                                <AlternatingItemStyle BackColor="#F3F3F3" />
                                <ItemTemplate>
                                    <div style="padding:3px">
                                        <asp:LinkButton ID="lnkDeptName" CommandArgument='<%# Eval("DeptCode") %>' CssClass="LooksLikeHRef"
                                            runat="server" OnClick="linkDeptCode_click" Text='<%# Eval("DeptName") %>' Width="317px">
                                        </asp:LinkButton>
                                        <asp:Label ID="lblUnitType"  runat="server" Text='<%# Eval("UnitTypeName") %>' Width="140px"></asp:Label>
                                        <asp:Label ID="lblAddress"  runat="server" Text='<%# Eval("Address") %>' Width="220px"></asp:Label>
                                        <asp:Label ID="lblCity" runat="server" Text='<%# Eval("CityName") %>' Width="120px"></asp:Label>
                                        <asp:Label ID="lblPhone" runat="server" Text='<%# Eval("Phone") %>'></asp:Label>
                                        <br />
                                    </div>
                                </ItemTemplate>
                            </asp:DataList>
                        </asp:Panel>
                    </ItemTemplate>
                </asp:DataList>
            </asp:Panel>
        </ItemTemplate>
    </asp:DataList>
</asp:Content>
