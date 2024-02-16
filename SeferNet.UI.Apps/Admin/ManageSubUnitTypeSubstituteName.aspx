<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="ניהול טבלת שם השיוך לפי סוג היחידה " MasterPageFile="~/seferMasterPage.master" Inherits="ManageSubUnitTypeSubstituteName"
    meta:resourcekey="PageResource1" Codebehind="ManageSubUnitTypeSubstituteName.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    
    <script type="text/javascript">

        function GetDivScrollPosition() {
            var scrollPosition = document.getElementById('<%=divSubUnitTypes.ClientID %>').scrollTop;
            var txtDivSubUnitTypes_ScrollPosition = document.getElementById('<%=txtDivSubUnitTypes_ScrollPosition.ClientID %>');
            txtDivSubUnitTypes_ScrollPosition.value = scrollPosition;
        }

        function SetDivScrollPosition() {
            var divSubUnitTypes = document.getElementById('<%=divSubUnitTypes.ClientID %>');
            var txtDivSubUnitTypes_ScrollPosition = document.getElementById('<%=txtDivSubUnitTypes_ScrollPosition.ClientID %>');
            divSubUnitTypes.scrollTop = txtDivSubUnitTypes_ScrollPosition.value;
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
            <table cellspacing="0" cellpadding="0" dir="rtl" width="930px">
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
                                                    <table border="0">
                                                        <tr>
                                                            <td width="60px" align="right">
                                                                <uc1:sortableColumn ID="hdrRemarkID" runat="server" ColumnIdentifier="UnitTypeCode"
                                                                    OnSortClick="btnSort_Click" Text="קוד קטגוריה" ToolTip="סינון לפי קוד קטגוריה" />
                                                            </td>
                                                            <td style="width:12px">&nbsp;</td>
                                                            <td width="220px" align="right">
                                                                <uc1:sortableColumn ID="hdrRemarkName" runat="server" ColumnIdentifier="UnitTypeName"
                                                                    OnSortClick="btnSort_Click" Text="קטגוריה" ToolTip="סינון לפי קטגוריה" />
                                                            </td>
                                                            <td width="50px">
                                                                <asp:Label ID="hdrSubUnitTypeCode" runat="server" Width="30px" EnableTheming="false" CssClass="ColumnHeader" Text="קוד שיוך" ></asp:Label>
                                                            </td>
                                                            <td width="200px">
                                                                <asp:Label ID="hdrSubUnitTypeName" runat="server" EnableTheming="false" CssClass="ColumnHeader" Text="שיוך" ></asp:Label>
                                                            </td>
                                                            <td width="250px">
                                                                <asp:Label ID="hdrSubUnitTypeCode2" runat="server" EnableTheming="false" CssClass="ColumnHeader" Text="שם השיוך" ></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtDivSubUnitTypes_ScrollPosition" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
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
                                                <td width="950px" style="padding-right: 0px; padding-left: 0px;">
                                                    <div id="divSubUnitTypes" runat="server" class="ScrollBarDiv" style="overflow-y: scroll; direction: ltr;
                                                        width: 100%; height: 450px;" onscroll="GetDivScrollPosition()">
                                                        <div style="direction: rtl;">
                                                            <asp:GridView ID="gvSubUnitTypeSubstituteName" runat="server" AutoGenerateColumns="false" HorizontalAlign="Right"
                                                                OnRowDataBound="gvSubUnitTypeSubstituteName_RowDataBound" ShowFooter="false" ShowHeader="false" 
                                                                EnableTheming="True" SkinID="SimpleGridView" >
                                                                <RowStyle CssClass="choiseField" />
                                                                <Columns>
                                                                <asp:TemplateField ControlStyle-Width="20px">
                                                                    <ItemTemplate>
                                                                        &nbsp;&nbsp;&nbsp;
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="60px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblUnitTypeCode" runat="server" Text='<%#Eval("UnitTypeCode") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:Label ID="lblUnitTypeCode" runat="server" Text='<%#Eval("UnitTypeCode") %>'></asp:Label>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="230px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblUnitTypeName" runat="server" Text='<%#Eval("UnitTypeName") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:Label ID="lblUnitTypeName" runat="server" Text='<%#Eval("UnitTypeName") %>'></asp:Label>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="50px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblSubUnitTypeCode" runat="server" Text='<%#Eval("subUnitTypeCode") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:Label ID="lblSubUnitTypeCode" runat="server" Text='<%#Eval("subUnitTypeCode") %>'></asp:Label>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="200px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblSubUnitTypeName" runat="server" Text='<%#Eval("subUnitTypeName") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:Label ID="lblSubUnitTypeName" runat="server" Text='<%#Eval("subUnitTypeName") %>'></asp:Label>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="210px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblSubstituteName" runat="server" Text='<%#Eval("SubstituteName") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:TextBox ID="txtSubstituteName" runat="server" Text='<%#Eval("SubstituteName") %>'></asp:TextBox>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="52px">
                                                                    <ItemTemplate>
                                                                        <div style="margin-right: 3px">
                                                                            <asp:ImageButton ID="btnEdit" UnitTypeCode='<%#Eval("UnitTypeCode") %>' SubUnitTypeCode='<%#Eval("subUnitTypeCode") %>' runat="server" OnClick="btnEdit_Click"
                                                                                ImageUrl="~/Images/btn_edit.gif" ValidationGroup="vldGrReceptionHours" />
                                                                        </div>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
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
                                                                    <ItemStyle HorizontalAlign="Right"/>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="52px">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnDelete" EnableTheming="false" runat="server" ImageUrl="../Images/btn_clear.gif"
                                                                            UnitTypeCode='<%#Eval("UnitTypeCode") %>' SubUnitTypeCode='<%#Eval("subUnitTypeCode") %>' OnClick="btnDelete_Click" OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את השם השיןך')">
                                                                        </asp:ImageButton>
                                                                     </ItemTemplate>
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
