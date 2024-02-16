<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_GridTreeView" Codebehind="GridTreeView.ascx.cs" %>
<link href="../CSS/General/general.css" type="text/css" rel="STYLESHEET" />
<asp:GridView ID="dgMain" SkinID="GridViewTree" runat="server" HeaderStyle-CssClass="RegularLabel" RowStyle-CssClass="RegularLabel" AlternatingRowStyle-CssClass="RegularLabel" OnRowCreated="dgMain_RowCreated"
    OnRowDataBound="dgMain_RowDataBound" OnRowCommand="dgMain_RowCommand" OnSorting="dgMain_Sorting"
    meta:resourcekey="GridView1Resource1">
    <Columns>
        <asp:TemplateField HeaderText="Root" SortExpression="Root">
            <ItemTemplate>
                <asp:ImageButton ID="btnPlus" runat="server" Visible="False" Height="16px" CommandName="_Show"
                    ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif" />
                <asp:ImageButton ID="btnMinus" runat="server" Height="16px" CommandName="_Hide" ImageUrl="~/Images/Applic/btn_Minus_Blue_12.gif"
                    meta:resourcekey="btnMinusResource1" />
            </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="ParentCode" ControlStyle-CssClass="RegularLabel" HeaderText="Parent Id"
            SortExpression="ParentCode" />
        <asp:BoundField DataField="ChildCode" ControlStyle-CssClass="RegularLabel" HeaderText="Child Id"
            SortExpression="ChildCode" />
        <asp:BoundField DataField="GroupByParent" ControlStyle-CssClass="RegularLabel" HeaderText="GroupByParent"
            Visible="false" />
        <asp:BoundField DataField="Code" ControlStyle-CssClass="RegularLabel" HeaderText="Code"
            SortExpression="Code" />
        <asp:BoundField DataField="Name" ControlStyle-CssClass="RegularLabel" HeaderText="Name"
            SortExpression="Name" />
        <asp:BoundField DataField="ShowExpert" ControlStyle-CssClass="RegularLabel" HeaderText="ShowExpert" />
        <asp:BoundField DataField="SectorDescription" ControlStyle-CssClass="RegularLabel"
            HeaderText="SectorDescription" />
        <asp:TemplateField HeaderText="edit">
            <ItemTemplate>
                <asp:LinkButton runat="server" ID="lnkEdit" CssClass="RegularLabel" Text="edit" PostBackUrl="#"
                    OnCommand="lnkEdit_Click" meta:resourcekey="lnkEditResource1"></asp:LinkButton>
            </ItemTemplate>
            <ItemStyle Width="45px" />
        </asp:TemplateField>
        <asp:BoundField DataField="isSingle" ControlStyle-CssClass="RegularLabel" HeaderText="isSingle"
            Visible="false" />
    </Columns>
</asp:GridView>
<asp:HiddenField ID="hdnSortOrder" runat="server" />
