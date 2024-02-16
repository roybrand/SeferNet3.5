<%@ Page Language="C#" AutoEventWireup="true" Title="חיפוש נותני שירות"
    Inherits="Public_SearchDoctors" MasterPageFile="~/SearchMasterPage.master"   Codebehind="SearchDoctors.aspx.cs" %>

<%@ MasterType VirtualPath="~/SearchMasterPage.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<asp:Content ID="Content1" runat="server" ContentPlaceHolderID="phScriptHead">

    <script language="javascript" src="Scripts/ValidationMethods/Validation1.js" type="text/javascript" ></script>
    <script type="text/javascript" src="Scripts/searchDoctors.js"></script>
    <script type="text/javascript">
        var txtHandicappedFacilitiesCodesClientID = '<%=txtHandicappedFacilitiesCodes.ClientID %>';
        var txtHandicappedFacilitiesListClientID = '<%=txtHandicappedFacilitiesList.ClientID %>';
        var txtFirstNameClientID = '<%=txtFirstName.ClientID %>';
        var txtLanguageListCodesClientID = '<%=txtLanguageListCodes.ClientID %>';
        var txtLanguageListClientID = '<%=txtLanguageList.ClientID %>';
        var txtProfessionListCodesClientID = '<%=txtProfessionListCodes.ClientID %>';
        var ddlEmployeeSectorCodeClientID = '<%= ddlEmployeeSectorCode.ClientID %>';
        var txtProfessionListClientID = '<%=txtProfessionList.ClientID %>';
        var txtProfessionList_ToCompareClientID = '<%=txtProfessionList_ToCompare.ClientID %>';
        var txtHandicappedFacilitiesList_ToCompareClientID = '<%=txtHandicappedFacilitiesList_ToCompare.ClientID %>';
        var ddlEmployeeSectorCodeClientID = '<%=ddlEmployeeSectorCode.ClientID %>';
        var AutoCompleteProfessionsClientID = '<%=AutoCompleteProfessions.ClientID %>';
        var ddlAgreementTypeClientID = '<%= ddlAgreementType.ClientID %>';
        var txtAgreementTypeClientID = '<%= txtAgreementType.ClientID %>';
        var ddlAgreementTypeCloneClientID = '<%= ddlAgreementTypeClone.ClientID %>';
        var MasterGetModalPopupGrayScreenClientID = '<%=Master.GetModalPopupGrayScreen().ClientID%>';
        var btnProfessionListPopUpClientID = '<%=btnProfessionListPopUp.ClientID %>';
        var divReceiveGuestsClientID = '<%=divReceiveGuests.ClientID%>';
        var cbNotReceiveGuestsClientID = '<%=cbNotReceiveGuests.ClientID%>';
        var txtProfessionsRelevantForReceivigGuestsClientID = '<%=txtProfessionsRelevantForReceivigGuests.ClientID%>';


        var idOfdivGrid = "<%=divGvDoctorsList.ClientID %>";
        var idOfCurrentGrid = "<%=repDoctorList.ClientID %>";

        var txtQueueOrderClientID = '<%=txtQueueOrder.ClientID %>';
        var txtQueueOrderCodesClientID = '<%=txtQueueOrderCodes.ClientID %>';

    </script>
</asp:Content>

<asp:Content ID="Content2" runat="server" ContentPlaceHolderID="phSearchParameterFirstAndSecondColumns">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <%--BEGIN personal details of doctor   --%>
                        <table cellpadding="0" cellspacing="0" style="width: 170px">
                            <tr>
                                <td style="width: 60px">
                                    <asp:Label runat="server" ID="lblEmployeeSectorCode" Text="סקטור"></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlEmployeeSectorCode" runat="server" Width="194px" AppendDataBoundItems="true"
                                        DataTextField="EmployeeSectorDescription" DataValueField="EmployeeSectorCode" AutoPostBack="true" 
                                        OnSelectedIndexChanged="ddlEmployeeSectorCode_SelectedIndexChanged">
                                        
                                        <asp:ListItem Value="-1" Text="כל הסקטורים"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div style="width: 40px">
                                        &nbsp;</div>
                                </td>
                                <td>
                                    <div style="width: 60px; height: 25px;">
                                        <asp:Label runat="server" ID="lblProfessionCaption" Text="תחום שירות"></asp:Label>
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtProfessionList" onfocus="SyncronizeProfessionList(); UpdateAutoCompleteProfessions();"
                                        onchange="ClearProfessionList();" ReadOnly="false" runat="server" Width="150px"
                                        TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                    <asp:TextBox ID="txtProfessionList_ToCompare" runat="server" CssClass="DisplayNone"
                                        EnableTheming="false">
                                    </asp:TextBox>
                                    <cc1:AutoCompleteExtender runat="server" ID="AutoCompleteProfessions" TargetControlID="txtProfessionList"
                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetServicesByNameAndSector"
                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                        CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedProfessionCode" />
                                    <asp:TextBox ID="txtProfessionListCodes" runat="server" CssClass="DisplayNone" TextMode="multiLine"
                                        EnableTheming="false"></asp:TextBox>
                                </td>
                                <td>
                                    <div style="width: 40px;">
                                        <input type="image" id="btnProfessionListPopUp" runat="server" style="cursor: pointer;"
                                            src="Images/Applic/icon_magnify.gif" onclick="SelectProfession(); return false;" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>                                                    
                                    <div style="width: 60px;">
                                        <asp:Label runat="server" Width="60px" ID="lblLastNameCaption" Text="שם משפחה"></asp:Label>
                                    </div>                                    
                                </td>                                
                                <td>                                                   
                                    <asp:TextBox ID="txtLastName" Width="190px" runat="server" Height="20px" />
                                    <cc1:AutoCompleteExtender runat="server" ID="acLastName" BehaviorID="acLastName" 
                                        TargetControlID="txtLastName" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                        ServiceMethod="getDoctorByLastNameAndSector" MinimumPrefixLength="1" CompletionInterval="300"
                                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                        CompletionListCssClass="CopmletionListStyle" />
                                </td>
                                <td>                                 
                                    <asp:RegularExpressionValidator ID="VldRegexLastName" runat="server" ControlToValidate="txtLastName"
                                        ValidationGroup="vldGrSearch" Text="!">
                                    </asp:RegularExpressionValidator>
                                    <asp:CustomValidator ID="vldPreservedWordsLastName" runat="server" ClientValidationFunction="CheckPreservedWords"
                                        ValidationGroup="vldGrSearch" ControlToValidate="txtLastName" Text="!">
                                    </asp:CustomValidator>
                                </td>                                
                                <td>                                
                                </td>
                                <td>
                                    <div id="divReceiveGuests" runat="server" disabled="true">
                                        <asp:CheckBox ID="cbNotReceiveGuests" runat="server" EnableTheming="false" Text="מקבל אורחים" CssClass="RegularCheckBoxList" />                                
                                    </div>
                                    <asp:TextBox ID="txtProfessionsRelevantForReceivigGuests" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div style="width: 60px;">
                                        <asp:Label runat="server" ID="lblFirstNameCaption" Text="שם&nbsp;פרטי"></asp:Label>
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtFirstName" Width="190px" runat="server" Height="20px">
                                    </asp:TextBox>
                                    <cc1:AutoCompleteExtender runat="server" ID="acFirstName" BehaviorID="acFirstName"
                                        TargetControlID="txtFirstName" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                        ServiceMethod="getDoctorByFirstNameAndSector" MinimumPrefixLength="1" CompletionInterval="500"
                                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                        CompletionListCssClass="CopmletionListStyle" />
                                </td>
                                <td>
                                    <asp:RegularExpressionValidator ID="VldRegexFistName" runat="server" ControlToValidate="txtFirstName"
                                        ValidationGroup="vldGrSearch" Text="!">
                                    </asp:RegularExpressionValidator>
                                    <asp:CustomValidator ID="vldPreservedWordsFistName" runat="server" ClientValidationFunction="CheckPreservedWords"
                                        ValidationGroup="vldGrSearch" ControlToValidate="txtFirstName" Text="!">
                                    </asp:CustomValidator>
                                </td>
                                <td>
                                    <div id="tdSpecialityLabel" runat="server" style="width: 60px;">
                                        <asp:Label ID="lblExpert" runat="server" Text="מומחיות"></asp:Label>
                                    </div>
                                </td>
                                <td>
                                    <div id="tdSpeciality" runat="server">
                                        <asp:DropDownList ID="ddlExpert" runat="server" Width="154px">
                                        <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                        <asp:ListItem Text="מומחה" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="לא מומחה" Value="0"></asp:ListItem>
                                    </asp:DropDownList></div>
                                </td>
                                <td></td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <%--END personal details of doctor     --%>
            </td>
            <td valign="top">
            </td>
            <td valign="top">
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content3" runat="server" ContentPlaceHolderID="phMapSearchControls_HoleRow1">
<table cellpadding="0" cellspacing="0">
    <tr>
        <td style="padding:0px 0px 0px 0xp; margin:0px 0px 0px 0px">
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td valign="middle">
                        <div style="width: 60px;">
                            <asp:Label ID="lblLicenseNumber" runat="server" Text="מס` רשיון"></asp:Label>
                        </div>
                    </td>
                    <td valign="top">
                        <div>
                            <asp:TextBox ID="txtLicenseNumber" Width="60px" runat="server" Height="20px"></asp:TextBox>
                        </div>
                    </td>
                    <td>
                        <asp:CompareValidator ID="vldIntLicenseNumber" ControlToValidate="txtLicenseNumber"
                            Operator="LessThan" Type="Integer" ValueToCompare="2147483647" runat="server"
                            ValidationGroup="vldGrSearch" Text="!"></asp:CompareValidator>
                    </td>

                </tr>
            </table>
        </td>
        <td style="padding:0px 0px 0px 0xp; margin:0px 0px 0px 0px">
            <table cellpadding="0" cellspacing="0" border="0" style="background-color:White;">
                <tr id="trEmployeeID" runat="server">
                    <td valign="middle">
                        <div style="width: 25px;">
                            <asp:Label ID="lblEmployeeID" runat="server" Text="ת.ז."></asp:Label>
                        </div>
                    </td>
                    <td valign="top">
                        <div>
                            <asp:TextBox ID="txtEmployeeID" Width="70px" runat="server" MaxLength="10" Height="20px"></asp:TextBox>
                        </div>
                    </td>
                    <td>
                        <asp:CompareValidator ID="vldIntEmployeeIDCompare" runat="server" ControlToValidate="txtEmployeeID"
                            Type="Integer" Operator="LessThan" Text="!" ValidationGroup="vldGrSearch" ValueToCompare="2147483647"></asp:CompareValidator>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

</table>

</asp:Content>
<asp:Content ID="Content4" runat="server" ContentPlaceHolderID="phMapSearchControls_HoleRow2">

</asp:Content>
<asp:Content ID="Content5" runat="server" ContentPlaceHolderID="phSearchParameterThirdColumn">
    <%--BEGIN ,מומחיות,שפות,מגדר,עצמאי,סטטוס,הערכות לנכים  --%>
    <table cellpadding="0" cellspacing="0" border="0">
        <tr>
            <td style="width: 80px;padding: 0px 0px 0px 0px">
                <asp:Label ID="lblSex" runat="server" Text="מגדר"></asp:Label>
            </td>
            <td style="padding: 0px 0px 0px 0px">
                <asp:DropDownList ID="ddlSex" runat="server" AppendDataBoundItems="true" Width="124px"
                    DataTextField="sexDescription" DataValueField="sex">
                    <asp:ListItem Value="-1" Text="הכל"></asp:ListItem>
                </asp:DropDownList>
            </td>
            <td style="width: 40px">
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label runat="server" ID="lblLanguageCaption" Text="שפות"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtLanguageList" ReadOnly="false" onchange="ClearLanguages();" runat="server"
                    Width="119px" TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine"
                    EnableTheming="false">
                </asp:TextBox>
                <asp:TextBox ID="txtLanguageListCodes" runat="server" CssClass="DisplayNone" EnableTheming="false"
                    TextMode="multiLine"></asp:TextBox>
                <cc1:AutoCompleteExtender runat="server" ID="AutoCompleteLanguages" TargetControlID="txtLanguageList"
                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getLanguagesByName"
                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedLanguagesCode" />
            </td>
            <td>
                <input type="image" id="imgLanguagesListPopUp" style="cursor: pointer;" src="Images/Applic/icon_magnify.gif"
                    onclick="SelectLanguage(); return false;" />
            </td>
        </tr>
        
        <tr>
            <td>
                <asp:Label ID="lblAgreementType" runat="server" Text="סוג הסכם"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlAgreementType" runat="server" Width="124px" AppendDataBoundItems="true"
                    DataTextField="AgreementTypeDescription" DataValueField="EnumName">
                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                </asp:DropDownList>
                <asp:DropDownList ID="ddlAgreementTypeClone" runat="server" Width="124px" AppendDataBoundItems="true"
                    DataTextField="AgreementTypeDescription" DataValueField="EnumName" Style="display: none">
                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                </asp:DropDownList>
            </td>
            <td>
                <asp:TextBox ID="txtAgreementType" runat="server" Width="17px" EnableTheming="false"
                    CssClass="DisplayNone"></asp:TextBox>
                <%--<asp:Button ID="ToDo_Submeet" runat="server" Width = "17px" Text = "Do" />--%>
            </td>
        </tr>
        <tr>
            <td>
                <div style="width: 60px;">
                    <asp:Label ID="lblPosition" runat="server" Text="תפקיד"></asp:Label>
                </div>
            </td>
            <td colspan="2" style="padding:0px 1px 0px 0px"><!-- cbReceiveGuests -->
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlPosition" runat="server" Width="124px" AppendDataBoundItems="true"
                        DataTextField="positionDescription" DataValueField="positionCode">
                        <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                    </asp:DropDownList>
                </ContentTemplate>
                </asp:UpdatePanel>
             </td>        
        </tr>
        <tr>
            <td style="width: 78px">
                <asp:Label ID="lblStatusCaption" runat="server" Text="סטטוס"></asp:Label>
            </td>
            <td colspan="2">
                <asp:DropDownList ID="ddlStatus" Width="124px" runat="server" DataTextField="statusDescription"
                    DataValueField="status" />
            </td>
        </tr>
        <tr>
            <td align="right" style="padding:0px 1px 0px 0px">
                <asp:Label ID="lblHandicappedFacilities" runat="server" Text="הערכות לנכים"></asp:Label>
            </td>
            <td style="padding:0px 2px 0px 0px">
                <asp:TextBox ID="txtHandicappedFacilitiesList" onfocus="SyncronizeHandicappedFacilitiesList();"
                    onchange="ClearHandicappedFacilitiesList();" ReadOnly="false" runat="server"
                    Width="119px" TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine"
                    EnableTheming="false"></asp:TextBox>
                <asp:TextBox ID="txtHandicappedFacilitiesList_ToCompare" runat="server" CssClass="DisplayNone"
                    EnableTheming="false"></asp:TextBox>
                <cc1:AutoCompleteExtender runat="server" ID="autoCompleteHandicappedFacilities" TargetControlID="txtHandicappedFacilitiesList"
                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetHandicappedFacilitiesByName"
                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                    EnableCaching="true" OnClientItemSelected="getSelectedHandicappedFacilityCode"
                    CompletionSetCount="12" DelimiterCharacters="" Enabled="True" CompletionListCssClass="CopmletionListStyle" />
                <asp:TextBox ID="txtHandicappedFacilitiesCodes" runat="server" CssClass="DisplayNone"
                    EnableTheming="false" TextMode="multiLine"></asp:TextBox>
            </td>
            <td>
                <input type="image" id="btnHandicappedFacilitiesPopUp" style="cursor: pointer;" onclick="SelectHandicappedFacilities(); return false;"
                    src="Images/Applic/icon_magnify.gif" />
            </td>
        </tr>

        <tr>
            <td colspan="3">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <div style="width: 78px;">
                                <asp:Label ID="lblQueueOrderTitle" runat="server" Text="אופן הזימון"></asp:Label>
                            </div>
                        </td>
                        <td>
                            <asp:TextBox ID="txtQueueOrder" runat="server" Width="118px" onchange="ClearQueueOrderMethodsList();"
                                TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ID="autoGetQueueOrderMethodsAndOptions" TargetControlID="txtQueueOrder"
                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetQueueOrderMethodsAndOptions"
                                MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="true" OnClientItemSelected="geSelectedtQueueOrderMethods"
                                CompletionSetCount="12" DelimiterCharacters="" Enabled="True" CompletionListCssClass="CopmletionListStyle" />                            
                            <asp:TextBox ID="TextBox1" TextMode="MultiLine" runat="server" CssClass="DisplayNone"  EnableTheming="false"></asp:TextBox>
                            <asp:TextBox ID="txtQueueOrderCodes" TextMode="MultiLine" runat="server" CssClass="DisplayNone"  EnableTheming="false"></asp:TextBox>
                        </td>
                        <td>
                            <div style="width: 37px;margin-top:2px;">
                                <input type="image" id="btnQueueOrderPopUp" style="cursor: pointer;" src="Images/Applic/icon_magnify.gif" onclick="SelectQueueOrder(); return false;" />
                            </div>                    
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

    </table>
    <%--END ,מומחיות,שפות,מגדר,עצמאי,סטטוס,הערכות לנכים  --%>
</asp:Content>
<asp:Content ID="Content6" runat="server" ContentPlaceHolderID="phBetweenParamsToResults">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:ValidationSummary ID="vldSummarySearch" runat="server" ValidationGroup="vldGrSearch" />
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content7" runat="server" ContentPlaceHolderID="phGrid">
    <table cellpadding="0" cellspacing="0" style="float:right; width:100%">
        <tr>
            <td>
                <asp:Label ID="lblFromHour_ToHour_search_alert" style="color:#e75c00;" Visible="false" runat="server">שים לב, יופיעו גם יחידות/רופאים הפעילים רק בחלק מטווח הזמן שהוזן</asp:Label>
                <asp:Label ID="lblReceptionParameters_With_FromHour_search_alert" style="color:#e75c00;" Visible="false" runat="server">שם לב, יופיעו גם יחידות/רופאים שלא מצויין עבורם שאינם פעילים בטווח המבוקש או הפעילים רק בחלק מטווח הזמן המבוקש</asp:Label>
                <asp:Label ID="lblReceptionParameters_WithNO_FromHour_search_alert" style="color:#e75c00;" Visible="false" runat="server">שימו לב, יתכן ויופיעו בתחתית הרשימה  נותני שירות/יחידות ללא שעות פעילות. לברור שעות הפעילות שלהם, יש לפנות ליחידה</asp:Label>
            </td>
        </tr>
        <tr id="trPagingButtons" runat="server" style="display: none">
            <td id="tdPagingButtons" runat="server" style="background-color:#f9f9f9;
                border-top:1px solid #e3e3e3;border-bottom:1px solid #e3e3e3;">
                <table cellpadding="0" cellspacing="0" width="1200px">
                    <tr>
                        <td style="text-align:right;width: 210px;">
                            <asp:Label ID="lblTotalRecords" runat="server" Text="נמצא 750 רשומות"></asp:Label>
                            <asp:Label ID="lblPageFromPages" runat="server" Text=" עמוד 5 מתוך 15 "></asp:Label>
                        </td>
                        <td style="width:63px;">
                            <asp:PlaceHolder ID="phButtonsShowHideMap" runat="server"></asp:PlaceHolder>
                        </td>
                        <td align="left" style="padding-left: 5px">
                            <asp:ImageButton ID="imgGetSearchResultReport" runat="server" ImageUrl="~/Images/Applic/Excel_Button.png" OnClientClick="OpenSearchResultReport(100,'rprt_DeptEmployees_SearchResult'); return false;" />
                            <asp:LinkButton ID="btnFirstPage" runat="server" Text="<< הראשון" CssClass="LinkButtonBoldForPaging"
                                OnClick="btnFirstPage_Click"></asp:LinkButton>&nbsp;
                            <asp:LinkButton ID="btnPreviousPage" runat="server" Text="< הקודם" CssClass="LinkButtonBoldForPaging"
                                OnClick="btnPreviousPage_Click"></asp:LinkButton>&nbsp;
                            <asp:DropDownList ID="ddlCarrentPage" runat="server" Width="50px" AppendDataBoundItems="true"
                                AutoPostBack="True" OnSelectedIndexChanged="ddlCarrentPage_SelectedIndexChanged">
                            </asp:DropDownList>
                            &nbsp;
                            <asp:LinkButton ID="btnNextPage" runat="server" Text="הבא >" CssClass="LinkButtonBoldForPaging"
                                OnClick="btnNextPage_Click"></asp:LinkButton>&nbsp;
                            <asp:LinkButton ID="btnLastPage" runat="server" Text="האחרון >>" CssClass="LinkButtonBoldForPaging"
                                OnClick="btnLastPage_Click"></asp:LinkButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="trSortingButtons" runat="server" style="display: none">
            <td id="tdSortingButtons" valign="top" runat="server" style="background-color:#f0f0f0;
                text-align:right;">
                <table cellpadding="0" cellspacing="0" style="height: 20px;text-align:right;border:none;">
                    <tr>
                        <td style="width:15px;"></td>
                        <td id="tdMapHeader" runat="server" style="text-align:center;" class="ColumnHeader"></td>
                        <td style="width:20px;padding-right:3px;">
                            <uc1:sortableColumn ID="columnAgreementType" runat="server" Text="" ColumnIdentifier="AgreementType"
                                OnSortClick="btnSort_Click" />
                        </td>
                        <td style="width: 26px;text-align:center;" class="ColumnHeader"></td>
                        <td id="tdDocNameHeader" runat="server" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnDoctorName" runat="server" Text="שם" ColumnIdentifier="lastName"
                                OnSortClick="btnSort_Click" />
                        </td>
                        <td style="width: 138px;" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnProfessions" runat="server" Text="תחומי שירות" ColumnIdentifier="Professions"
                                    OnSortClick="btnSort_Click" />
                            
                        </td>
                        <td style="width: 125px; padding-top:0px;" class="PaddingRight5">
                            <asp:Label ID="lblQueueOrder" runat="server" Text="אופן זימון" EnableTheming="false" CssClass="ColumnHeader"></asp:Label>
                        </td>
                        <td style="width: 230px;" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnClinicName" runat="server" Text="שם יחידה" ColumnIdentifier="deptName"
                                    OnSortClick="btnSort_Click" />
                            
                        </td>
                        <td style="width: 30px;" class="PaddingRight5">
                        </td>
                        <td style="width: 165px;" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnAddress" runat="server" Text="כתובת" ColumnIdentifier="address"
                                OnSortClick="btnSort_Click" />
                        </td>
                        <td style="width: 105px;" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnCity" runat="server" Text="ישוב" ColumnIdentifier="cityName"
                                OnSortClick="btnSort_Click" />
                        </td>
                        <td style="width: 61px;" class="PaddingRight5">
                            <uc1:sortableColumn ID="columnPhone" runat="server" Text="טלפון" ColumnIdentifier="phone"
                                OnSortClick="btnSort_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-top: 0px" align="right">
                <table cellpadding="0" cellspacing="0">
                    <tr id="trSearchResults" runat="server" style="display: none">
                        <td dir="ltr">
                            <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                            <div id="divGvDoctorsList" runat="server" class="ScrollBarDiv" style="height: 295px;
                                overflow-y: scroll;">
                                <div style="direction:rtl;">
                                    <table id="tblResults" cellpadding="0" cellspacing="0">
                                    <asp:Repeater ID="repDoctorList" runat="server" EnableViewState="false" 
                                    onitemdatabound="repDoctorList_ItemDataBound">
                                        <ItemTemplate>
                                            <tr class="trPlain" id="trDoctor" runat="server">
                                                <td id="tdMapOrder" runat="server" class="blueTD" style="width:10px;display:none;text-align:center;">
                                                    <div class="divImage">
                                                        <asp:Label runat="server" ID="MapOrderNumber" CssClass="RegularLabel"></asp:Label>
                                                    </div>
                                                </td>
                                                <td id="tdMap" runat="server" class="greenTD" style="width:25px;text-align:center;"><!-- מפה -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgMap" runat="server" Style="cursor: pointer" />
                                                    </div>
                                                </td>
                                                <td class="greenTD" style="width:24px;text-align:center;"><!-- שיוך -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgAgreementType" runat="server" />
                                                    </div>
                                                </td>

                                                <td class="greenTD" style="width:27px;text-align:center;"><!-- שעות  -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgReception" runat="server" Style="cursor: pointer" />
                                                    </div>
                                                </td>
                                                <td id="tdDocName" runat="server" class="greenTD" style="width:165px;"><!-- שם רופא -->
                                                    <div>
                                                        <table cellpadding="0" cellspacing="0" style="border:none;">
                                                        <tr>
                                                            <td>
                                                                <asp:HyperLink ID="lnkEmployeeName" runat="server" Text='<%#Eval("EmployeeName")%>'>
                                                                </asp:HyperLink>
                                                                <asp:Label ID="lblEmployeeName" runat="server" Text='<% #Bind("EmployeeName") %>'
                                                                    Visible="false"></asp:Label>
                                                                <asp:Label ID="lblTemporarilyInactive" runat="server" Text="(לא&nbsp;פעיל&nbsp;זמנית)" CssClass="LabelBoldRed12"  EnableTheming="false"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblExpert" runat="server" Text='<% #Bind("expert") %>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblPositions" runat="server" Text='<% #Bind("positions") %>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    </div>
                                                </td>
                                                <td class="greenTD" style="padding:0px; margin:0px; width:220px">
                                                    <asp:GridView HeaderStyle-CssClass="DisplayNone" ID="gvQueueOrderCombinations" runat="server" OnRowDataBound="gvQueueOrderCombinations_RowDataBound" 
                                                        AutoGenerateColumns="false" EnableTheming="false" GridLines="None" CellPadding="0" CellSpacing="0">
                                                        <Columns>
                                                            <asp:BoundField DataField="Marker" ItemStyle-CssClass="DisplayNone">
                                                                <HeaderStyle CssClass="DisplayNone" />
                                                            </asp:BoundField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <table cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td id="tdProfessions" runat="server" style="border-left:1px solid #cfe9bd;"><!-- תחומי שירות -->
                                                                                <div style="width:120px">
                                                                                    <asp:GridView ID="gvProfessions" runat="server" OnRowDataBound="gvProfessions_RowDataBound" AutoGenerateColumns="false" EnableTheming="false" GridLines="None">
                                                                                    <Columns>
                                                                                        <asp:BoundField DataField="ServiceDescription" ItemStyle-CssClass="RegularLabel">
                                                                                            <HeaderStyle CssClass="DisplayNone" />
                                                                                        </asp:BoundField>
                                                                                    </Columns>
                                                                                    </asp:GridView>
                                                                                </div>
                                                                            </td>
                                                                            <td id="tdQueueOrder" runat="server"><!-- אופן זימון -->
                                                                                <div style="width:85px">
                                                                                    <asp:Label ID="lblQueueOrder" runat="server" EnableTheming="false" CssClass="QueueOrderText"
                                                                                            Visible="false"></asp:Label>
                                                                                    <asp:Literal ID="litQueueOrder" runat="server"></asp:Literal>
                                                                                    <table id='tblQueueOrderPhonesAndHours<%# Eval("RowNumber") %>_<%# Eval("marker") %>' style="display: none;
                                                                                    z-index: 900" cellpadding="0" cellspacing="0">
                                                                                    <tr>
                                                                                        <td dir="ltr" align="right">
                                                                                            <asp:Label ID="lblDeptEmployeeQueueOrderPhones" runat="server" CssClass="RegularLabel"></asp:Label>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:GridView ID="gvDeptEmployeeQueueOrderHours" runat="server" EnableTheming="false"
                                                                                                GridLines="None" AutoGenerateColumns="false" HeaderStyle-CssClass="HeaderStyleBlueBold">
                                                                                                <Columns>
                                                                                                    <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC"
                                                                                                        ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
                                                                                                    <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                                                        <ItemTemplate>
                                                                                                            <table cellpadding="0" cellspacing="0" style="width: 100%; border-top: 1px solid #BADBFC;">
                                                                                                                <tr>
                                                                                                                    <td align="center">
                                                                                                                        <asp:Label ID="lblQueueOrderHours_From" CssClass="RegularLabel" runat="server" Text='<%#Eval("FromHour") %>'></asp:Label>
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                    <asp:TemplateField HeaderText="עד שעה" ItemStyle-Width="45px">
                                                                                                        <ItemTemplate>
                                                                                                            <table cellpadding="0" cellspacing="0" style="width: 100%; border-top: 1px solid #BADBFC;">
                                                                                                                <tr>
                                                                                                                    <td align="center">
                                                                                                                        <asp:Label ID="lblQueueOrderHours_To" CssClass="RegularLabel" runat="server" Text='<%#Eval("ToHour") %>'></asp:Label>
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                </Columns>
                                                                                            </asp:GridView>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td align="left" style="padding-left: 5px; padding-top: 5px; border-top: 1px solid #BADBFC;">
                                                                                            <img style='cursor: hand' src='Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:OnCloseQueueOrderPhonesAndHoursPopUp()' />
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                    </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </td>
                                                <td class="greenTD" style="width:30px;text-align:center;"><!-- רופא מקבל אורחים -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgReceiveGuests" runat="server" />
                                                    </div>
                                                </td>
                                                <td class="blueTD" style="width: 24px; text-align: center;">
                                                <!--היחידה  שיוך  -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgAttributed" runat="server" ToolTip="שירותי בריאות כללית" />
                                                    </div>
                                                </td>
                                                <td class="blueTD" style="width:27px;"><!-- שעות קבלה יחידה -->
                                                    <div class="divImage">
                                                        <asp:Image ID="imgRecepAndComment" AlternateText="הקש להצגת שעות המשרד" runat="server"
                                                            Style="cursor: pointer" />
                                                    </div>
                                                </td>
                                                <td class="blueTD" style="width:240px;"><!-- שם יחידה -->
                                                    <div>
                                                        <asp:Panel ID="pnlLink" runat="server">
                                                            <asp:HyperLink ID="lnkDeptCode" runat="server" Text='<%#Eval("deptName")%>'></asp:HyperLink>
                                                        </asp:Panel>
                                                    </div>
                                                </td>
                                                    
                                                    
                                                    
                                                    
                                                <td class="spaceTD"></td>
                                                <td class="grayTD" style="width:175px;"><!-- כתובת -->
                                                    <div>
                                                        <asp:Label runat="server" ID="lblAddress" Text='<%#Eval("address")%>' CssClass="RegularLabel"></asp:Label>
                                                    </div>
                                                </td>
                                                <td class="grayTD" style="width:110px;"><!-- ישוב -->
                                                    <div>
                                                        <asp:Label ID="lblCityName" runat="server" Text='<%# Eval("CityName") %>' CssClass="RegularLabel"></asp:Label>
                                                    </div>
                                                </td>
                                                <td class="grayTD" style="width:85px;"><!-- טלפון -->
                                                    <div>
                                                        <asp:Label ID="lblPhone" runat="server" Text='<%#Eval("phone")%>' CssClass="RegularLabel"></asp:Label>
                                                        <asp:Image ID="imgPhoneRemark" runat="server" />
                                                    </div>
                                                </td>
                                                <td class="spaceTD"></td>
                                                    
                                            </tr>
                                            <tr>
                                                <td style="height:1px;font-size:0;">&nbsp;</td>
                                            </tr>
                                            
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    </table>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="hfRowStatus" runat="server" Value="" />
</asp:Content>
