<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="ניהול טבלת הערות סגורות" MasterPageFile="~/seferMasterPageIE.master" Inherits="ManageGeneralRemarksDictionary"
    meta:resourcekey="PageResource1" Codebehind="ManageGeneralRemarksDictionary.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    
    <script type="text/javascript">
        function AreYourSure(text) {
            var query = escape(text);
            var url = "../Admin/ConfirmPopUp.aspx?NoticeText=" + query;

            var dialogWidth = 420;
            var dialogHeight = 380;
            var title = "Confirm";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetRemarkIDtoBeDeleted(remarkID) {
            document.getElementById('<% =txtRemarkIDtoBeDeleted.ClientID%>').innerText = remarkID;
            document.getElementById('<% =txtRemarkIDtoBeDeleted.ClientID%>').value = remarkID;
        }

        function FunctionToExecuteAfterConfirm() {
            document.getElementById('<% =btnDeleteSelectedRemarkAfterConfirm.ClientID%>').click();
        }

        function CreateExcelReport() {
            var url = "../Reports/Reports_CreateExcel.aspx?ReportForUpdatePages=1";
            window.open(url, "CreateExcel", "height=800, width=1000, top=50, left=100");
            return false;
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
            <table cellspacing="0" cellpadding="0" dir="rtl" width="990px">
                <tr id="BlueBarTop">
                    <td style="padding-right: 10px">
                        <!-- Upper Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="background-color: #298AE5; height: 18px;">
                                    &nbsp;
                                    <asp:Button ID="btnDeleteSelectedRemarkAfterConfirm" runat="server" OnClick="btnDeleteSelectedRemarkAfterConfirm_Click" EnableTheming="false" CssClass="DisplayNone"/>
                                    <asp:TextBox ID="txtRemarkIDtoBeDeleted" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7"
                            width="100%">
                            <tr id="BorderTop1">
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
                                    <div>
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr style="height: 25px">
                                                <td valign="top" >
                                                    <asp:Label ID="lblFilter" runat="server" Text="טקסט חופשי:" ></asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <%--style="padding-top: 8px;"--%>
                                                    <asp:TextBox ID="txtFilterRemarks" runat="server" Width="140px"></asp:TextBox>
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblDistrict" runat="server" Text="סוג הערה:"></asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkType" runat="server" Height="24px" Width="140px" DataTextField="Remark" />
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblRemarkCategory" runat="server" Text="קטגוריה:"> </asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkCategory" runat="server" Height="24px" Width="135px">
                                                    </asp:DropDownList>
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblStatus" runat="server" Text="סטטוס:"> </asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkStatus" runat="server" Height="24px" Width="100px">
                                                    </asp:DropDownList>
                                                </td>
                                                <td align="right" style="padding-right: 4px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: top; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                    OnClick="btnSearch_Click"></asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="padding-right: 5px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnAddRemark" runat="server" Text="הוספת הערות" CssClass="RegularUpdateButton"
                                                                    ValidationGroup="vgrFirstSectionValidation" Width="90px" OnClick="btnAddRemark_Click">
                                                                </asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
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
                            <tr id="BoprderBottom1" style="height: 10px">
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
                                                            <td width="9%">
                                                                <uc1:sortableColumn ID="hdrRemarkID" runat="server" ColumnIdentifier="remarkID" OnSortClick="btnSort_Click"
                                                                    Text="קוד הערה" />
                                                            </td>
                                                            <td width="65%">
                                                                <uc1:sortableColumn ID="hdrRemark" runat="server" ColumnIdentifier="remark" OnSortClick="btnSort_Click"
                                                                    Text="הערה" />
                                                            </td>
                                                            <td width="8%">
                                                                <uc1:sortableColumn ID="hdrRemarkCategory" runat="server" ColumnIdentifier="RemarkCategoryName"
                                                                    OnSortClick="btnSort_Click" Text="קטגוריה" ToolTip="סינון לפי קטגוריה" />
                                                            </td>
                                                            <td width="25%">
                                                                <uc1:sortableColumn ID="hdrRemarkStatus" runat="server" ColumnIdentifier="active"
                                                                    OnSortClick="btnSort_Click" Text="סטטוס" />
                                                            </td>
                                                            <td>
                                                                <asp:ImageButton ID="imgCreateExcelReport" runat="server" ImageUrl="~/Images/Applic/Excel_Button.png" CausesValidation="False" OnClick="imgCreateExcelReport_Click"  />
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
                                                <td width="975px" style="padding-right: 0px; padding-left: 0px;">
                                                    <div id="Div1" runat="server" class="ScrollBarDiv" style="overflow-y: scroll; direction: ltr;
                                                        width: 100%; height: 350px;">
                                                        <div style="direction: rtl;">
                                                            <asp:GridView ID="gvRemarks" runat="server" AutoGenerateColumns="false" HorizontalAlign="Right"
                                                                OnRowDataBound="gvRemarks_RowDataBound" ShowFooter="false" ShowHeader="false"
                                                                SkinID="GridViewForSearchResults">
                                                                <RowStyle CssClass="choiseField" />
                                                                <Columns>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblRemarkID" runat="server" Text='<%#Eval("remarkID") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Center" Width="9%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblRemarkText" runat="server" Text='<%#Eval("remark") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="65%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblCategoryName" runat="server" Text='<%#Eval("RemarkCategoryName") %>'></asp:Label>
                                                                            <asp:HiddenField ID="hidRemarkCategoryID" runat="server" Visible="False" Value='<%#Eval("RemarkCategoryID") %>' />
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="8%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:CheckBox ID="chRemarkStatus" runat="server" Enabled="false" Checked='<%#Eval("active") %>'>
                                                                            </asp:CheckBox>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="7%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <table id="tbEditRemark" cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button runat="server" ID="btnEditRemark" RemarkID='<%# Eval("remarkID")%>' Width="35px"
                                                                                            CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditRemark_Click" />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="60px" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:ImageButton ID="btnDeleteRemark" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                RemarkID='<%# Eval("remarkID")%>' OnClick="btnDeleteRemark_Click">
                                                                            </asp:ImageButton>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="40px" />
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                                <SelectedRowStyle ForeColor="#FF99CC" />
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
                <tr id="BlueBarBottom">
                    <td style="padding-right: 10px">
                        <!-- Lower Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="background-color: #298AE5; height: 18px;">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
