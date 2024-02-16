<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="ניהול טבלת קטגוריות של הערות " MasterPageFile="~/seferMasterPage.master" Inherits="ManageRemarkCategory"
    meta:resourcekey="PageResource1" Codebehind="ManageRemarkCategory.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    
    <script type="text/javascript">
        function ClearGridHeaderRow() {

            var txtCategoryNameH = document.getElementById('txtCategoryNameH');
            txtCategoryNameH.value = "";
        }
    </script>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0" dir="rtl">
                <tr id="trError" runat="server">
                    <td>
                        <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" dir="rtl" width="900px">
                <tr id="BlueBarTop">
                    <td style="padding-right: 10px" >
                        <!-- Lower Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 18px;"
                            width="100%">
                            <tr>
                                <td >
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7"
                            width="100%">
                            <tr id="BorderTop2">
                                <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                    background-repeat: no-repeat; background-position: top right">
                                </td>
                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                    background-position: top">
                                </td>
                                <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                                    background-position: top left">
                                </td>
                            </tr>
                            <tr>
                                <td style="border-right: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                                <td align="right">
                                    <div style="width: 100%" dir="rtl">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr id="GridViewHeaders" runat="server">
                                                <td style="padding-right: 10px">
                                                    <table width="100%">
                                                        <tr>
                                                            <td width="11%">
                                                                <uc1:sortableColumn ID="hdrRemarkID" runat="server" ColumnIdentifier="RemarkCategoryID"
                                                                    OnSortClick="btnSort_Click" Text="קוד קטגוריה" ToolTip="סינון לפי קוד קטגוריה" />
                                                            </td>
                                                            <td width="89%">
                                                                <uc1:sortableColumn ID="hdrRemarkName" runat="server" ColumnIdentifier="RemarkCategoryName"
                                                                    OnSortClick="btnSort_Click" Text="קטגוריה" ToolTip="סינון לפי קטגוריה" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="trNoDataFound" runat="server" style="display: none">
                                                <td style="padding-top: 30px; background-color: #F7F7F7" align="center">
                                                    <asp:Label ID="lblNoDataFound" runat="server" Text="אין מידע"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr id="trGridView">
                                                <td width="870px" style="padding-right: 0px; padding-left: 0px;">
                                                    <div id="Div1" runat="server" class="ScrollBarDiv" style="overflow-y: scroll; direction: ltr;
                                                        width: 100%; height: 350px;">
                                                        <div style="direction: rtl;">
                                                            <asp:GridView ID="gvRemarkCategories" runat="server" AutoGenerateColumns="false" HorizontalAlign="Right"
                                                                OnRowDataBound="gvRemarks_RowDataBound" ShowFooter="false" 
                                                                EnableTheming="True" ><%--SkinID="GridViewForSearchResults"--%>
                                                                <RowStyle CssClass="choiseField" />
                                                                <Columns>
                                                                    <asp:TemplateField>
                                                                        <HeaderTemplate>
                                                                            <asp:Label ID="lblCategoryID" runat="server" Text='<%#Eval("RemarkCategoryID") %>'></asp:Label>
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblCategoryID" runat="server" Text='<%#Eval("RemarkCategoryID") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:Label ID="lblCategoryID" runat="server" Text='<%#Eval("RemarkCategoryID") %>'></asp:Label>
                                                                        </EditItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Center" Width="13%" />
                                                                        <HeaderStyle HorizontalAlign="Center" Width="13%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <HeaderTemplate>
                                                                            <asp:TextBox ID="txtCategoryNameH" runat="server" Text='<%#Eval("RemarkCategoryName") %>'>
                                                                            </asp:TextBox>
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblCategoryName" runat="server" Text='<%#Eval("RemarkCategoryName") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:TextBox ID="txtCategoryNameE" runat="server" Text='<%#Eval("RemarkCategoryName") %>'>
                                                                            </asp:TextBox>
                                                                        </EditItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="71%" />
                                                                        <HeaderStyle HorizontalAlign="Right" Width="71%" />
                                                                    </asp:TemplateField>
                                                                    <%--Update column--%>
                                                                    <asp:TemplateField>
                                                                        <HeaderTemplate>
                                                                            <table border="0px" style="margin-left: 10px">
                                                                                <tr>
                                                                                    <td style="padding-top: 5px">
                                                                                        <asp:ImageButton runat="server" ID="btnAdd" CommandName="add" ValidationGroup="vldGrAdd"
                                                                                            OnClick="btnAdd_Click" ImageUrl="~/Images/btn_add.gif" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr valign="middle">
                                                                                    <td valign="middle">
                                                                                        <asp:ImageButton runat="server" ID="imgClear" CausesValidation="false" CommandName="clear"
                                                                                            OnClientClick="ClearGridHeaderRow()"  ImageUrl="~/Images/btn_clear.gif" /><%--OnClick="imgClear_Click"--%>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <div style="margin-right: 3px">
                                                                                <asp:ImageButton ID="btnEdit" RemarkCategoryID='<%#Eval("RemarkCategoryID") %>' runat="server" OnClick="btnEdit_Click"
                                                                                    ImageUrl="~/Images/btn_edit.gif" ValidationGroup="vldGrReceptionHours" />
                                                                            </div>
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <table>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:ImageButton ID="btnCancelEditRow" runat="server" CommandName="canel" CausesValidation="False"
                                                                                            OnClick="btnCancelUdateRow_Click" ImageUrl="~/Images/btn_cancel.gif" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:ImageButton ID="btnSaveEditRow" runat="server" CommandName="save" ValidationGroup="vldGrEdit"
                                                                                            OnClick="btnSaveUpdateRow_Click" ImageUrl="~/Images/btn_approve.gif" />
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </EditItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="60px" />
                                                                        <HeaderStyle HorizontalAlign="Right" Width="60px" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:ImageButton ID="btnDelete" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                RemarkCategoryID='<%# Eval("RemarkCategoryID")%>' OnClick="btnDelete_Click" OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את ההערה')">
                                                                            </asp:ImageButton>
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate></EditItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="40px" />
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                               <%-- <SelectedRowStyle ForeColor="GhostWhite" />--%>
                                                               <%-- <HeaderStyle BackColor="#F3EBE0" CssClass="SimpleBold" />--%>
                                                               <%--<SelectedRowStyle ForeColor="#FF99CC" />--%>
                                                            </asp:GridView>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                                <td style="border-left: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                            </tr>
                            <tr id="BorderBottom2" style="height: 10px">
                                <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                                    background-position: bottom right">
                                </td>
                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                    background-position: bottom">
                                </td>
                                <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                                    background-position: bottom left">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="BlueBarBotton">
                    <td style="padding-right: 10px" >
                        <!-- Lower Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 18px;"
                            width="100%">
                            <tr>
                                <td >
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" runat="server" ContentPlaceHolderID="phHead">
    <%--contains the script of the override page --%>
    <style type="text/css">
        .style1
        {
            height: 28px;
        }
    </style>
</asp:Content>
