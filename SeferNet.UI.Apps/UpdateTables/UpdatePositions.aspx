<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>

<%@ Page Language="C#" Title="עדכון טבלת תפקידים" AutoEventWireup="true" MasterPageFile="~/seferMasterPage.master" EnableEventValidation="false" Inherits="UpdateTables_UpdatePositions"
    meta:resourcekey="PageResource1" Codebehind="UpdatePositions.aspx.cs" %>

<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelect.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="GridTreeViewTableList" TagName="TreeViewTableListItem" Src="~/UserControls/GridTreeViewTableList.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <script src="../Scripts/updateItems.js" type="text/javascript"></script>

    <table>
        <tr>
            <td dir="rtl" valign="top" align="right">             
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Panel runat="server" ID="pnlGrid" Height="500px" CssClass="ScrollBarDiv" ScrollBars="Vertical">
                                        <GridTreeViewTableList:TreeViewTableListItem ID="TreeViewItem1" runat="server"></GridTreeViewTableList:TreeViewTableListItem>
                                    </asp:Panel>
                                </td>
                                <td style="width: 50px">
                                    &nbsp;
                                </td>
                                <td valign="top">
                                    <table style="width: 100%;" id="tblAdding" runat="server">
                                        <tr>
                                            <td>
                                                <asp:Label ID="Label1" runat="server" Text="קוד"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtCode" runat="server"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ValidationGroup="grpAdd"
                                                    ControlToValidate="txtCode" runat="server" ErrorMessage="*"></asp:RequiredFieldValidator>
                                                <asp:RegularExpressionValidator ID="REV_txtCode" runat="server" ErrorMessage="*"
                                                    ControlToValidate="txtCode" ValidationGroup="grpAdd" ValidationExpression="^\d+$"></asp:RegularExpressionValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblDescription" runat="server" Text="תאור"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtDescription" runat="server"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RFV_Description" ValidationGroup="grpAdd" ControlToValidate="txtDescription"
                                                    runat="server" ErrorMessage="*"></asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right">
                                                <asp:Label ID="lblGender" runat="server" Text="מגדר"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:DropDownList  AutoPostBack="false" ID="ddlGender" runat="server" CssClass="ScrollBarDiv">
                                                    <asp:ListItem Text="זכר" Value="1" Selected="True"></asp:ListItem>
                                                    <asp:ListItem Text="נקבה" Value="2" Selected="False"></asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr id="trSector" runat="server" visible="true">
                                            <td align="right">
                                                <asp:Label ID="lblSector" runat="server" Text="סקטור"></asp:Label>
                                            </td>
                                            <td >
                                                <asp:DropDownList ID="ddlSector" runat="server" DataSourceID="SqlDataSourceSector"
                                                    DataTextField="EmployeeSectorDescription" DataValueField="EmployeeSectorCode"
                                                    AutoPostBack="true">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr id="trAllowQueueOrder" runat="server" visible="false">
                                            <td align="right">
                                                <asp:Label ID="lblAllowQueueOrder" runat="server" Text="אופן זימון"></asp:Label>
                                            </td>
                                            <td >
                                                <asp:DropDownList ID="ddlAllowQueueOrder" runat="server"  
                                                    AutoPostBack="false">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        
                                        <tr id="trIsActive" runat="server" visible="false">
                                            <td align="right">
                                                <asp:Label ID="lblIsActive" runat="server" Text="פעיל"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                                            </td>
                                        </tr>     
                                                                           
                                        <tr>
                                            <td align="right">
                                                
                                            </td>
                                            <td>
                                                <asp:ImageButton ID="btnAddNew" ImageUrl="~/Images/btn_add.gif" ValidationGroup="grpAdd" OnClick="btnAddNew_Click" CausesValidation="true" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnAddNew" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
            </td>
        </tr>
    </table>
    <asp:SqlDataSource ID="SqlDataSourceSector" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
        SelectCommand="SELECT [EmployeeSectorCode], [EmployeeSectorDescription] FROM [EmployeeSector] "
        DataSourceMode="DataReader"></asp:SqlDataSource>
    
</asp:Content>
