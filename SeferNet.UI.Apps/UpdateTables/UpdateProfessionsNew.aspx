<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>

<%@ Page Language="C#" Title="עדכון טבלת מקצועות" AutoEventWireup="true" MasterPageFile="~/seferMasterPage.master" Inherits="UpdateTables_UpdateProfessionsNew"
    meta:resourcekey="PageResource1" Codebehind="UpdateProfessionsNew.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="GridTreeView" TagName="TreeViewItem" Src="~/UserControls/GridTreeView.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <table>
        <tr>
            <td dir="rtl" valign="top" align="right">
             
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <asp:Panel runat="server" ID="pnlGrid" Height="500px" CssClass="ScrollBarDiv" ScrollBars="Vertical"
                            meta:resourcekey="pnlGridResource1">
                            <GridTreeView:TreeViewItem ID="TreeViewItem1" runat="server" EditUrl="~/UpdateTables/UpdateProfessionItem.aspx">
                            </GridTreeView:TreeViewItem>
                        </asp:Panel>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Button runat="server" ID="btnAddNew" PostBackUrl="~/UpdateTables/UpdateProfessionItem.aspx"
                    Text="Add" meta:resourcekey="btnAddNewResource1" />
            </td>
        </tr>
    </table>
</asp:Content>
