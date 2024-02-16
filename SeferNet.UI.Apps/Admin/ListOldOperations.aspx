<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_ListOldOperations" UICulture="he-il" meta:resourcekey="PageResource3" Codebehind="ListOldOperations.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
</head>
<body >
<%--    <form id="form1" runat="server">
    <div>
        <table border="0px" align="right">
            <tr>
                <td colspan="6">
                    <asp:ScriptManager ID="ScriptManager1" runat="server">
                    </asp:ScriptManager>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                </td>
                <td colspan="4" align="right" dir="rtl">
                    <asp:Label ID="lblCaption" runat="server" Text="Label" meta:resourcekey="lblCaptionResource2"></asp:Label><hr />
                    <br />
                </td>
            </tr>
            <tr align="right">
                <td style="width: auto">
                    <asp:Button ID="btnClose" runat="server" Text="סגור" OnClientClick="javascript:window.close()"
                        meta:resourcekey="btnCloseResource1" />
                    <asp:Button ID="btnGetSelected" runat="server" OnClick="btnGetSelected_Click" meta:resourcekey="btnGetSelectedResource1" />
                </td>
                <td style="width: 18px">
                    <asp:ImageButton ID="imgRefresh" runat="server" ImageUrl="~/Images/arrow_refresh.png"
                        OnClick="imgRefresh_Click" meta:resourcekey="imgRefreshResource1" />
                </td>
                <td style="width: 18px">
                    <asp:ImageButton runat="server" ID="imgClearOldDesc" ImageUrl="~/Images/action_stop.gif"
                        meta:resourcekey="imgClearOldDescResource1" OnClick="imgClearOldDesc_Click" />
                </td>
                <td style="width: 16px">
                    <asp:ImageButton runat="server" ID="imgOldDesc" ImageUrl="~/Images/search.jpg" CommandArgument="oldDesc"
                        meta:resourcekey="imgOldDescResource1" OnClick="imgOldDesc_Click" />
                </td>
                <td align="right" style="width: 70px">
                    <asp:TextBox runat="server" dir="rtl" ID="txtSearchOldDesc" meta:resourcekey="txtSearchOldDescResource1"></asp:TextBox>
                    <cc1:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="txtSearchOldDesc"
                        UseContextKey="True" DelimiterCharacters="" Enabled="True" CompletionSetCount="100"
                        CompletionListCssClass="flyout-background" CompletionListItemCssClass="flyout-item"
                        CompletionListHighlightedItemCssClass="flyout-item-hover" MinimumPrefixLength="1"
                        ServiceMethod="GetAutoComplite" CompletionInterval="100" ServicePath="">
                    </cc1:AutoCompleteExtender>
                </td>
                <td style="width: 50px">
                    <asp:Label ID="lblFind" runat="server" meta:resourcekey="lblFindResource1"></asp:Label>
                </td>
            </tr>
            <tr>
                <td colspan="6" align="right">
                    <asp:GridView ID="dgItems" runat="server" AllowSorting="True" AutoGenerateColumns="False"
                        DataKeyNames="Code" OnRowCreated="dgItems_RowCreated" OnRowDataBound="dgItems_RowDataBound" 
                        EnableTheming="False" meta:resourcekey="dgItemsResource2" CssClass="MainClass2">
                        <Columns>
                         
                            <asp:TemplateField HeaderText="Selected" meta:resourcekey="TemplateFieldResource4">
                                <ItemTemplate>
                                    <asp:Literal runat="server"  ID="RadioButtonMarkup" meta:resourcekey="RadioButtonMarkupResource2" ></asp:Literal>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Name" meta:resourcekey="TemplateFieldResource5">
                                <HeaderTemplate>
                                    <table style=" height: 50px;">
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblSortName" Width="20px" CssClass="LinkButtonWebdings" EnableTheming="false"
                                                    Text="5" meta:resourcekey="lblSortNameResource1"></asp:Label>
                                                <asp:LinkButton ID="lnkName" runat="server" OnClick="lnkName_Click" 
                                                    meta:resourcekey="lnkNameResource1"></asp:LinkButton>
                                            </td>
                                        </tr>
                                    </table>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblName" Text='<%# Eval("Name") %>' meta:resourcekey="lblNameResource2"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Code" meta:resourcekey="TemplateFieldResource6">
                                <HeaderTemplate>
                                    <table style="width: 50px; height: 50px;">
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblSortCode" Width="20px" CssClass="LinkButtonWebdings" EnableTheming="false"
                                                    meta:resourcekey="lblSortCodeResource1" ></asp:Label>
                                                <asp:LinkButton ID="lnkCode" runat="server" OnClick="lnkCode_Click" meta:resourcekey="lnkCodeResource1"></asp:LinkButton>
                                            </td>
                                        </tr>
                                    </table>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblCode" Text='<%# Eval("Code") %>' meta:resourcekey="lblCodeResource2"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Category" Visible="False" meta:resourcekey="TemplateFieldResource7">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblCategory" Text='<%# Eval("Linked") %>' meta:resourcekey="lblCategoryResource2"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField Visible="false" meta:resourcekey="TemplateFieldResource8">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblTableName" Text='<%# Eval("TableName") %>' meta:resourcekey="lblTableNameResource1"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                           
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
            <tr>
                <td colspan="6" align="right">
                    <asp:Label runat="server" ID="lblMessage" meta:resourcekey="lblMessageResource1"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
    <div id="hdnDiv">
        <asp:HiddenField runat="server" ID="hdnKind" />
    </div>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server"></asp:SqlDataSource>
    </form>--%>
</body>
</html>


