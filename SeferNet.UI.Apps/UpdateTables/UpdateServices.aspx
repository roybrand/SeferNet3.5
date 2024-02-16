<%@ Page Title="עדכון תחומי שירות" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" Inherits="UpdateTables_UpdateServices" Codebehind="UpdateServices.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <script language="javascript" type="text/javascript">

        function SaveSelectedCategory(source, eventArgs) {
            document.getElementById('<%= hdnSelectedServiceCategory.ClientID %>').value = eventArgs.get_value();
            document.getElementById('<%= txtServiceCode.ClientID %>').value = '';
            document.getElementById('<%= hdnSelectedServiceCode.ClientID %>').value = '';
        }

        function SaveSelectedService(source, eventArgs) {
            document.getElementById('<%= hdnSelectedServiceCode.ClientID %>').value = eventArgs.get_value();
            document.getElementById('<%= txtServiceCode.ClientID %>').value = '';
            document.getElementById('<%= hdnSelectedServiceCategory.ClientID %>').value = '';
        }
        function RedirectToUpdatePage(servCode) {
            location.href = "../UpdateTables/UpdateSpecificService.aspx?ServiceCode=" + servCode;
        }

        function CreateExcelReport() {
            var url = "../Reports/Reports_CreateExcel.aspx?ReportForUpdatePages=1";
            window.open(url, "CreateExcel", "height=800, width=1000, top=50, left=100");
            return false;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">

    <table cellspacing="0" cellpadding="0" dir="rtl">
        <tr>
            <td style="padding-right: 10px">
                <!-- Upper Blue Bar -->
                <table cellpadding="0" cellspacing="0" style="width: 100%">
                    <tr>
                        <td style="background-color: #298AE5; height: 23px;" align="left" valign="middle">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button runat="server" ID="btnAdd" CssClass="RegularUpdateButton" Text="הוספה"
                                            OnClick="btnAdd_click" />
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-right: 5px; padding-top: 5px">
                            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                <tr>
                                    <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                        &nbsp;
                                    </td>
                                    <td>
                                        <%-- search controls --%>
                                        <div style="width: 950px;">
                                            <table cellpadding="0" cellspacing="6" border="0">
                                                <tr>
                                                    <td>
                                                        <table>
                                                            <tr>
                                                                <td align="right">
                                                                    <asp:Label ID="lblDistricts" runat="server" Text="קוד תחום"></asp:Label>
                                                                    <asp:TextBox ID="txtServiceCode" runat="server" Width="50px"></asp:TextBox>
                                                                    <asp:CompareValidator runat="server" Operator="GreaterThan" ControlToValidate="txtServiceCode"
                                                                        Type="Integer" ValueToCompare="0"></asp:CompareValidator>
                                                                </td>
                                                                <td align="right" style="padding-right: 20px">
                                                                    <asp:Label ID="lblAdministrations" runat="server" Text="תיאור תחום"></asp:Label>
                                                                    <asp:TextBox ID="txtService" runat="server" Width="150px"></asp:TextBox>
                                                                    <ajaxToolkit:AutoCompleteExtender ID="acService" runat="server" TargetControlID="txtService"
                                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAllServices"
                                                                        MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                                        UseContextKey="true" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                        CompletionListCssClass="CopmletionListStyle" ContextKey="true" OnClientItemSelected="SaveSelectedService" />
                                                                </td>
                                                                <td align="right" style="padding-right: 20px">
                                                                    <asp:Label ID="lblServiceCategories" runat="server" Text="תחום ראשי"></asp:Label>
                                                                    <asp:TextBox ID="txtServiceCategory" runat="server" Width="150px"></asp:TextBox>
                                                                    <ajaxToolkit:AutoCompleteExtender ID="acServiceCategories" runat="server" TargetControlID="txtServiceCategory"
                                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAllServiceCategories"
                                                                        MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                                        UseContextKey="true" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                        CompletionListCssClass="CopmletionListStyle" ContextKey="true" OnClientItemSelected="SaveSelectedCategory" />
                                                                </td>
                                                                <td align="right" style="padding-right: 20px; padding-left: 20px">
                                                                    <asp:Label ID="Label1" runat="server" Text="סקטור"></asp:Label>
                                                                    <asp:DropDownList ID="ddlSector" runat="server" Width="85px" DataValueField="EmployeeSectorCode"
                                                                        DataTextField="EmployeeSectorDescription">
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" colspan="2" style="padding-top: 10px">
                                                                    <asp:Label ID="Label2" runat="server" Text="סוג תחום:"></asp:Label>
                                                                    <asp:CheckBox ID="chkCommunity" CssClass="RegularLabel" runat="server" Text="קהילה"
                                                                        Checked="true" />
                                                                    <asp:CheckBox ID="chkMushlam" CssClass="RegularLabel" runat="server" Text="מושלם" />
                                                                    <asp:CheckBox ID="chkHospitals" CssClass="RegularLabel" runat="server" Text="בתי חולים" />
                                                                </td>
                                                                <td align="right" colspan="2" style="padding-top: 10px; padding-right: 25px">
                                                                    <asp:Label ID="lblRequireQueueOrder" runat="server" Text="דורש זימון"></asp:Label>
                                                                    <asp:DropDownList ID="ddlRequireQueueOrder" runat="server" Width="50px" DataValueField="RequireQueueOrderCode"
                                                                        DataTextField="RequireQueueOrderDescription">
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td valign="top">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                    background-position: bottom left;">
                                                                    &nbsp;
                                                                </td>
                                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                    <asp:Button ID="btnSearch" runat="server" CssClass="RegularUpdateButton" OnClick="btnSearch_click"
                                                                        Text="חיפוש" />
                                                                </td>
                                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                    background-repeat: no-repeat;">
                                                                    &nbsp;
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td valign="top">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                    background-position: bottom left;">
                                                                    &nbsp;
                                                                </td>
                                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                    <asp:Button ID="btnClear" runat="server" CssClass="RegularUpdateButton" OnClick="btnClear_click"
                                                                        Text="ניקוי" />
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
                                    <td style="border-left: solid 2px #909090; width: 6px">
                                        &nbsp;
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
                                <tr>
                                    <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                        &nbsp;
                                    </td>
                                    <td id="tdColumnsContainer" runat="server">
                                        <table>
                                            <tr>
                                                <td style="padding-right: 25px; width: 50px">
                                                    <uc1:sortableColumn runat="server" Text="טבלת מקור" ColumnIdentifier="SourceTable"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 50px">
                                                    <uc1:sortableColumn runat="server" Text="קוד" ColumnIdentifier="ServiceCode" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 285px">
                                                    <uc1:sortableColumn runat="server" Text="שם תחום" ColumnIdentifier="ServiceDescription"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 110px">
                                                    <%--<asp:Label ID="lblServiceCategories2" runat="server" Text="תחום ראשי"></asp:Label>--%>
                                                    <uc1:sortableColumn runat="server" Text="תחום ראשי" ColumnIdentifier="ServiceCategoryDescription" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 100px">
                                                    <%--<asp:Label ID="lblExpert" runat="server" Text="מומחה ב-"></asp:Label>--%>
                                                    <uc1:sortableColumn runat="server" Text="מומחה ב-" ColumnIdentifier="Expert" OnSortClick="Sort_click" />

                                                </td>
                                                <td style="width: 60px">
                                                    <uc1:sortableColumn runat="server" Text="שירות / מקצוע" ColumnIdentifier="isProfession" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 60px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="שירות" ColumnIdentifier="isService" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 70px">
                                                    <uc1:sortableColumn runat="server" Text="סקטור" ColumnIdentifier="Sector" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 60px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="קהילה" ColumnIdentifier="IsInCommunity"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 60px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="מושלם" ColumnIdentifier="IsInMushlam" OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 50px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="בתי חולים" ColumnIdentifier="IsInHospitals"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 70px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="לתצוגה באינטרנט" ColumnIdentifier="displayInInternet"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 50px; display: none">
                                                    <uc1:sortableColumn runat="server" Text="דורש זימון" ColumnIdentifier="RequiresQueueOrder"
                                                        OnSortClick="Sort_click" />
                                                </td>
                                                <td style="width: 30px">
                                                    <asp:ImageButton ID="imgCreateExcelReport" runat="server" ImageUrl="~/Images/Applic/Excel_Button.png" CausesValidation="False" OnClick="imgCreateExcelReport_Click"  />                                                
                                                </td>
                                            </tr>
                                        </table>
                                        <div style="height: 360px; padding-right: 10px; padding-bottom: 10px; overflow-y: scroll;
                                            direction: ltr;">
                                            <div style="direction: rtl;">
                                                <asp:GridView ID="gvResults" runat="server" SkinID="GridViewForSearchResults" ShowHeader="false"
                                                    AutoGenerateColumns="false" OnRowDataBound="gvResults_rowDataBound">
                                                    <Columns>
                                                     
                                                        <asp:BoundField ItemStyle-CssClass="RegularLabel" DataField="SourceTable" ItemStyle-Width="50px" />
                                                        <asp:BoundField ItemStyle-CssClass="RegularLabel" DataField="ServiceCode" ItemStyle-Width="55px" />
                                                        <asp:BoundField ItemStyle-CssClass="RegularLabel" DataField="ServiceDescription" ItemStyle-Width="280px" />
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label Width="110px" runat="server" Text='<%# Eval("ServiceCategoryDescription") %>'></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>  
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label Width="110px" runat="server" Text='<%# Eval("Expert") %>'></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>                                                        
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblIsProfession" runat="server" Width="70px"></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-CssClass="DisplayNone">
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblIsService" runat="server" Width="60px" ></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label Width="70px" runat="server" Text='<%# Eval("Sector") %>'></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <%--<asp:BoundField DataField="Sector" ItemStyle-CssClass="RegularLabel" ItemStyle-Width="65px"   />--%>
                                                        <asp:TemplateField ItemStyle-Width="30px" >
                                                            <ItemTemplate>
                                                                <asp:Image ID="imgIsCommunity" runat="server" ImageUrl = "~/Images/Applic/attr_Community.png" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:Image ID="imgIsMushlam" runat="server" ImageUrl = "~/Images/Applic/attr_Mushlam.png" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:Image ID="imgIsHospital" runat="server" ImageUrl = "~/Images/Applic/attr_hospitals.png" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="30px">
                                                            <ItemTemplate>
                                                                <asp:Image ID="imgDisplayInInternet" runat="server" ImageUrl = "~/Images/Applic/pic_NotShowInInternet.png" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-CssClass="DisplayNone">
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblRequiresQueueOrder" runat="server" Width="60px"></asp:Label>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-Width="35px">
                                                            <ItemTemplate >
                                                                <asp:LinkButton runat="server" CommandArgument='<%# Eval("ServiceCode") %>' OnClick="linkEdit_click"
                                                                    Text="עדכון" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>                                                       </Columns>
                                                </asp:GridView>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="border-left: solid 2px #909090; width: 6px">
                                        &nbsp;
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
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="hdnSelectedServiceCategory" runat="server" />
    <asp:HiddenField ID="hdnSelectedServiceCode" runat="server" />
</asp:Content>
