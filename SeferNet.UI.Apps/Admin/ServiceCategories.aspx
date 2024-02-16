<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page Language="C#" AutoEventWireup="true" Title="ניהול תחומי שירות ראשי" MasterPageFile="~/seferMasterPageIE.master" Inherits="ServiceCategories" EnableEventValidation="false" Codebehind="ServiceCategories.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
  
 
    <script type="text/javascript">
    
        function MinheletSelected(source, eventArgs) {
            //alert( " Key : "+ eventArgs.get_text() +"  Value :  "+eventArgs.get_value());
            //debugger;
            var values = eventArgs.get_value();
            if (values == null) return;

            document.getElementById('<%= hdnMinheletValue.ClientID %>').value = values;
        }

        function DeptSelected(source, eventArgs) {

            var values = eventArgs.get_value();
            if (values == null) return;
            document.getElementById('<%= hdnDeptCode.ClientID %>').value = values;

        }

        function selectRowOnLoad(rowPrefix, rowInd) {
            rowInd = rowInd + 2;
            if (rowInd < 10)
                rowInd = "0" + rowInd;
            var newIndex = parseInt(rowInd, 10) + 5;
            if (newIndex < 10) {
                newIndex = "0" + newIndex;
            }
            else {
                newIndex = newIndex + "";
            }
            var newClientIdPrefix = rowPrefix.replace(rowInd, newIndex);

            var row = document.getElementById(newClientIdPrefix + "_btnUpdateUser");
            if (row == null)
                row = document.getElementById(rowPrefix + "_btnUpdateUser");
            //ctl00_pageContent_gvUsers_ctl02_btnUpdateUser
            if (row != null)
                row.focus();
        }

        function SelectUser(userName) {
            var txtSelectedUserName = document.getElementById('<% //=txtSelectedUserName.ClientID%>');
            var btnDoPostBack = document.getElementById('<% //=btnDoPostBack.ClientID%>');
            txtSelectedUserName.value = userName;
            //alert(userName);
            //document.forms[0].submit();
            btnDoPostBack.click();
        }       

        function AreYourSure(text) {

            var query = escape(text);
            var url = "../Admin/ConfirmPopUp.aspx?NoticeText=" + query;

            var dialogWidth = 360;
            var dialogHeight = 220;
            var title = "Confirm";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetServiceCategoryIDtoBeDeleted(ServiceCategoryID) {
            document.getElementById('<% =txtServiceCategoryIDtoBeDeleted.ClientID%>').innerText = ServiceCategoryID;
            document.getElementById('<% =txtServiceCategoryIDtoBeDeleted.ClientID%>').value = ServiceCategoryID;
        }

        function FunctionToExecuteAfterConfirm() {
            document.getElementById('<% =btnDeleteServiceCategoryAfterConfirm.ClientID%>').click();
        }

        function SaveScrollPosition() {
            var hdnScrollPosition = document.getElementById('<% =hdnScrollPosition.ClientID%>');
            var pnlGvUsers = document.getElementById('<% =pnlGvUsers.ClientID%>');
            //alert(pnlGvUsers.scrollTop);
            hdnScrollPosition.value = pnlGvUsers.scrollTop;
        }

        function SetScrollPosition() {
            var hdnScrollPosition = document.getElementById('<% =hdnScrollPosition.ClientID%>');
            var pnlGvUsers = document.getElementById('<% =pnlGvUsers.ClientID%>');
            //alert(pnlGvUsers.scrollTop);
            pnlGvUsers.scrollTop = hdnScrollPosition.value;
        }
        
    </script>

            <div id="progress" style="position: absolute; top: 300px; left: 500px">
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </div>
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td style="padding-right: 8px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
                                <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                    background-repeat: no-repeat; background-position: top right">
                                </td>
                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                    background-position: top">
                                    <asp:Button ID="btnDeleteServiceCategoryAfterConfirm" runat="server" EnableTheming="false" OnClick="btnDeleteServiceCategoryAfterConfirm_Click" CssClass="DisplayNone" />
                                    <asp:TextBox ID="txtServiceCategoryIDtoBeDeleted" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
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
                                    <div style="width: 960px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="padding-right: 10px; padding-left: 5px;" valign="middle">
                                                    <asp:Label ID="lblServiceCategoryID" runat="server" Text="קוד תחום ראשי"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtServiceCategoryID" runat="server" Width="100px"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:RegularExpressionValidator ID="vldServiceCategoryID" ControlToValidate="txtServiceCategoryID" ValidationExpression="^\d+$" ValidationGroup="vgrSearch" runat="server" Text="*"></asp:RegularExpressionValidator>
                                                </td>
                                                <td style="padding-right: 20px; padding-left: 5px;" align="left">
                                                    <asp:Label ID="lblServiceCategoryDescription" runat="server" Text="שם תחום ראשי"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtServiceCategoryDescription" runat="server" Width="200px"></asp:TextBox>
                                                    <cc1:AutoCompleteExtender runat="server" ID="AutoCompleteServiceCategoryDescription" TargetControlID="txtServiceCategoryDescription"
                                                        BehaviorID="acClinicName" ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                                        ServiceMethod="GetServiceCategories"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyleWidth" />
                                                </td>
                                                <td>
                                                    &nbsp;</td>
                                                <td style="padding-right: 10px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                    OnClick="btnSearch_Click" ValidationGroup="vgrSearch"></asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td  style="padding-right: 220px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnAddServiceCategory" runat="server" Text="הוספת תחום" 
                                                                    CssClass="RegularUpdateButton" Width="100px" OnClientClick="SaveScrollPosition()"
                                                                     onclick="btnAddServiceCategory_Click"></asp:Button>
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
                            <tr style="height: 10px">
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
            </table>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server" >
        <ContentTemplate>

            <table cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td valign="top" style="padding-right: 8px; padding-top: 8px">
                        <!-- users list -->
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
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
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td id="tdSortingButtons" runat="server" style="height: 10px;">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="width: 25px">
                                                            &nbsp;
                                                        </td>
                                                        <td style="width: 60px">
                                                            <uc1:SortableColumnHeader ID="columnServiceCategoryID" runat="server" OnSortClick="btnSort_click"
                                                                Text="קוד" ColumnIdentifier="ServiceCategoryID" />
                                                        </td>
                                                        <td style="width: 330px">
                                                            <uc1:SortableColumnHeader ID="columnServiceCategoryDescription" runat="server" OnSortClick="btnSort_click"
                                                                Text="שם תחום" ColumnIdentifier="ServiceCategoryDescription" />
                                                        </td>
                                                        <td style="width: 120px" align="right">
                                                            <uc1:SortableColumnHeader ID="columnSubCodeFromTableMF51" runat="server" OnSortClick="btnSort_click"
                                                                Text="קוד אב ב51" ColumnIdentifier="SubCategoryCodeFromTableMF51" />
                                                        </td>
                                                        <td style="width: 120px" align="right">
                                                            <uc1:SortableColumnHeader ID="columnSubCategoryFromTableMF51" runat="server" OnSortClick="btnSort_click"
                                                                Text="תיאור אב ב51" ColumnIdentifier="SubCategoryFromTableMF51" />
                                                        </td>
                                                     </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td dir="ltr" style="border-top: solid 1px #BEBCB7;">
                                                <div id="pnlGvUsers" runat="server" style="height: 400px; width: 958px; overflow-y: scroll"
                                                    class="ScrollBarDiv">
                                                    <div dir="rtl">
                                                        <asp:GridView Width="930px" ID="gvServiceCategories" runat="server" 
                                                            AllowSorting="True" HeaderStyle-CssClass="DisplayNone"
                                                            AutoGenerateColumns="False" 
                                                             SkinID="GridViewForSearchResults" 
                                                            onrowdatabound="gvServiceCategories_RowDataBound">
                                                            <Columns>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0" style="cursor: pointer" onclick="SelectUser('<%# Eval("ServiceCategoryID")%>')" >
                                                                            <tr>
                                                                                <td style="width: 10px" align="center">
                                                                                 </td>
                                                                                <td style="width: 60px;">
                                                                                    <asp:Label ID="lblServiceCategoryID" runat="server" Text='<%#Bind("ServiceCategoryID") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 350px">
                                                                                    <asp:Label ID="lblServiceCategoryDescription" runat="server" Text='<%#Bind("ServiceCategoryDescription") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 100px">
                                                                                    <asp:Label ID="lblparent51Code" runat="server" Text='<%#Bind("SubCategoryCodeFromTableMF51") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 300px">
                                                                                    <asp:Label ID="lblSubCategoryFromTableMF51" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("SubCategoryFromTableMF51") %>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="55px" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnUpdateServiceCategory" runat="server" ImageUrl="../Images/btn_edit.gif" ToolTip="עדכון"
                                                                            ServiceCategoryID='<%# Eval("ServiceCategoryID")%>' OnClick="btnUpdateServiceCategory_Click" OnClientClick="SaveScrollPosition()" />
                                                                        <asp:Label ID="lblCurrentRowIndex" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:Label>
                                                                        <asp:Label ID="lblHasAttributedServices" runat="server" Text='<%# Eval("HasAttributedServices")%>' EnableTheming="false" CssClass="DisplayNone"></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="25px" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnDeleteServiceCategory" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                            ServiceCategoryID='<%# Eval("ServiceCategoryID")%>' OnClick="btnDeleteServiceCategory_Click" ToolTip="מחיקה"
                                                                            ></asp:ImageButton>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                            <SelectedRowStyle BackColor="#9FD5F9" />
                                                        </asp:GridView>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="border-left: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                            </tr>
                            <tr style="height: 10px">
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
            </table>
            <asp:Button ID="btnDoPostBack" runat="server" CssClass="DisplayNone" />
            <asp:HiddenField ID="hdnDeptCode" runat="server" />
            <asp:HiddenField ID="hdnMinheletValue" runat="server" />
            <asp:HiddenField ID="hdnScrollPosition" runat="server" />        
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
        </Triggers>
        
    </asp:UpdatePanel>
    
</asp:Content>
