<%@ Page Language="C#" AutoEventWireup="true" Title="חיפוש יחידות ושירותים"
    Inherits="Public_SearchClinics" MasterPageFile="~/SearchMasterPage.master" 
    meta:resourcekey="PageResource1" Codebehind="SearchClinics.aspx.cs" %>
<%-- This is just a mark to follow changes V.G. 23 05 2022 --%>
<%@ MasterType VirtualPath="~/SearchMasterPage.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="~/UserControls/SortableColumnHeader.ascx" TagName="SortableColumn"
    TagPrefix="cc1" %>
<asp:Content ID="Content1" runat="server" ContentPlaceHolderID="phScriptHead">
    <script type="text/javascript" src="Scripts/ValidationMethods/Validation1.js" defer="defer"></script>
    <script type="text/javascript" src="Scripts/searchClinics.js" defer="defer"></script>
    <script type="text/javascript" defer="defer">
        var txtProfessionListCodesClientID = '<%=txtProfessionListCodes.ClientID %>';
        var txtProfessionListClientID = '<%=txtProfessionList.ClientID %>';
        var txtHandicappedFacilitiesCodesClientID = '<%=txtHandicappedFacilitiesCodes.ClientID %>';
        var txtHandicappedFacilitiesListClientID = '<%=txtHandicappedFacilitiesList.ClientID %>';
        var txtClinicNameClientID = '<%=txtClinicName.ClientID %>';
        var txtHandicappedFacilitiesList_ToCompareClientID = '<%=txtHandicappedFacilitiesList_ToCompare.ClientID %>';
        var AutoCompleteProfessionsClientID = '<%=AutoCompleteProfessions.ClientID %>';
        var txtProfessionList_ToCompareClientID = '<%=txtProfessionList_ToCompare.ClientID %>';
        var txtUnitTypeList_ToCompareClientID = '<%=txtUnitTypeList_ToCompare.ClientID %>';
        var txtUnitTypeListClientID = '<%=txtUnitTypeList.ClientID %>';
        var txtUnitTypeListCodesClientID = '<%=txtUnitTypeListCodes.ClientID %>';
        var ddlSubUnitTypeClientID = '<%=ddlSubUnitType.ClientID %>';
        var lblSubUnitTypeClientID = '<%=lblSubUnitType.ClientID %>';
        var cbHandleSubUnitTypesClientID = '<%=cbHandleSubUnitTypes.ClientID %>';
        var txtURLforResolutionSetUpClientID = '<%=txtURLforResolutionSetUp.ClientID %>';
        var MasterGetModalPopupGrayScreenClientID = '<%=Master.GetModalPopupGrayScreen().ClientID%>';
        var divReceiveGuestsClientID = '<%=divReceiveGuests.ClientID%>';
        var cbNotReceiveGuestsClientID = '<%=cbNotReceiveGuests.ClientID%>';
        var txtProfessionsRelevantForReceivigGuestsClientID = '<%=txtProfessionsRelevantForReceivigGuests.ClientID%>';
        
        var idOfdivGrid = '<%= divGvClinicList.ClientID %>';
        var idOfCurrentGrid = "<%=repClinicsList.ClientID %>";
        var pnlTabsID = "<%=pnlTabs.ClientID %>";
        var ddlStatusClientID = "<%=ddlStatus.ClientID %>";

        var txtQueueOrderClientID = '<%=txtQueueOrder.ClientID %>';
        var txtQueueOrderCodesClientID = '<%=txtQueueOrderCodes.ClientID %>';
        
    </script>
    <script type="text/javascript">

        function setSelectedClalitServiceDesc(source, eventArgs) {
            var txtClalitServiceDesc = document.getElementById('<% = txtClalitServiceDesc.ClientID %>');
            var txtClalitServiceCode = document.getElementById('<% = txtClalitServiceCode.ClientID %>');
            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(";");
            txtClalitServiceCode.value = valuesArr[0];
            txtClalitServiceDesc.value = valuesArr[1];
        }

        function setSelectedMedicalAspectDescription(source, eventArgs) {
            var txtMedicalAspectDescription = document.getElementById('<% = txtMedicalAspectDescription.ClientID %>');
            var txtMedicalAspectCode = document.getElementById('<% = txtMedicalAspectCode.ClientID %>');
            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(";");
            txtMedicalAspectCode.value = valuesArr[0];
            txtMedicalAspectDescription.value = valuesArr[1];
        }

        function SetScrollPosition_divMushlamServices() {
            var divMushlamServices = document.getElementById('divMushlamServices');
            var txtScrollTop = document.getElementById('<% = txtScrollTop.ClientID %>');

            if (txtScrollTop.value != "") {
                divMushlamServices.scrollTop = txtScrollTop.value;
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phSearchParameterFirstAndSecondColumns" runat="server">
    <table id="tblSearchClinicsParameters" runat="server" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td valign="top" style="width: 60px;" dir="rtl">
                            <div style="width: 60px; height: 0px;">
                                <asp:Label ID="lblClinicName" runat="server" Text="שם יחידה"></asp:Label>
                            </div>
                        </td>
                        <td valign="top" colspan="2">
                            <asp:TextBox ID="txtClinicName" 
                                onfocus="setAgreemenTypesForAutoCompleteContextKeys('acClinicName');setCityCode_ClinicType_Status('acClinicName');" 
                                Width="213px" 
                                runat="server" 
                                MaxLength="50" 
                                EnableTheming="true"
                                Height="20px"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ID="AutoCompleteClinicName" TargetControlID="txtClinicName"
                                BehaviorID="acClinicName" ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                ServiceMethod="GetClinicByName_District_City_ClinicType_Status_Depended"
                                MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedClinicName"
                                OnClientPopulated="ClientPopulated" />
                        </td>
                        <td>
                            <div>
                                <asp:RegularExpressionValidator ID="vldRegexClinicName" runat="server" ControlToValidate="txtClinicName"
                                    ValidationGroup="vldGrSearch" Text="!"> </asp:RegularExpressionValidator>
                                <asp:CustomValidator ID="vldPreservedWordsClinicName" runat="server" ControlToValidate="txtClinicName"
                                    ClientValidationFunction="CheckPreservedWords" ValidationGroup="vldGrSearch"
                                    Text="!"> </asp:CustomValidator>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <div style="width: 60px;">
                                <asp:Label ID="lblUnitType" runat="server" Text="סוג יחידה"></asp:Label>
                            </div>
                        </td>
                        <td valign="top">
                            <div>
                                <asp:TextBox ID="txtUnitTypeList" ReadOnly="false" onfocus="SyncronizeUnitTypeList();setAgreemenTypesForAutoCompleteContextKeys('aCompleteUnitType');"
                                    onchange="ClearUnitTypeList();" runat="server" Width="190px" TextMode="MultiLine"
                                    Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                            </div>
                            <asp:TextBox ID="txtUnitTypeList_ToCompare" runat="server" CssClass="DisplayNone"
                                EnableTheming="false"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ContextKey="Community" BehaviorID="aCompleteUnitType" ID="autoCompleteUnitType" TargetControlID="txtUnitTypeList"
                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getUnitTypesByName"
                                MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedUnitTypeCode" />
                        </td>
                        <td valign="top">
                            <div>
                                <input type="image" id="btnUnitTypeListPopUp" runat="server" style="cursor: pointer;"
                                    src="Images/Applic/icon_magnify.gif" onclick="SelectUnitType(); return false;" />
                            </div>
                        </td>
                        <td style="display: none;">
                            <asp:TextBox ID="txtUnitTypeListCodes" runat="server" TextMode="multiLine"></asp:TextBox>
                            <asp:CheckBox ID="cbHandleSubUnitTypes" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <div style="width: 60px;">
                                <asp:Label ID="lblSubUnitType" runat="server" Text="שיוך" Style="display: none"></asp:Label>
                            </div>
                        </td>
                        <td valign="top" colspan="2">
                            <div>
                                <asp:DropDownList ID="ddlSubUnitType" runat="server" Width="195px" AppendDataBoundItems="true"
                                    DataTextField="subUnitTypeName" DataValueField="subUnitTypeCode">
                                </asp:DropDownList>
                            </div>
                        </td>
                        <td>
                            <div style="height: 0px;">
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
            <td valign="top">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td valign="top">
                            <div style="width: 46px;padding-right:4px">
                                <asp:Label ID="lblProfession" runat="server" Text="תחום שירות"></asp:Label>
                            </div>
                        </td>
                        <td valign="top">
                            <div>
                                <asp:TextBox ID="txtProfessionList" ReadOnly="false" onfocus="SyncronizeProfessionList(); setAgreemenTypesForAutoCompleteContextKeys('acProfessions');"
                                    onchange="ClearProfessionList();" runat="server" Width="150px" TextMode="MultiLine"
                                    Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                <asp:TextBox ID="txtProfessionList_ToCompare" runat="server" CssClass="DisplayNone"
                                    EnableTheming="false"></asp:TextBox>
                                <cc1:AutoCompleteExtender runat="server" ContextKey="Community" ID="AutoCompleteProfessions" TargetControlID="txtProfessionList"
                                    BehaviorID="acProfessions" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                    ServiceMethod="GetServicesAndEventsByName" MinimumPrefixLength="1" CompletionInterval="500"
                                    CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedProfessionCode" />
                            </div>
                        </td>
                        <td valign="top">
                            <div style="width: 35px">
                                <asp:ImageButton ID="btnProfessionListPopUp" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                    OnClientClick="SelectServicesAndEvents();return false;" />
                            </div>
                        </td>
                        <td style="display: none;">
                            <asp:TextBox ID="txtProfessionListCodes" runat="server" TextMode="multiLine" EnableTheming="false"
                                CssClass="TextBoxMultiLine"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>    
                        <td colspan="4" style="padding:0px 0px 0px 0px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="padding:1px 49px 0px 0px;">
                                        <div id="divReceiveGuests" runat="server" disabled="true">
                                            <asp:CheckBox ID="cbNotReceiveGuests" runat="server" EnableTheming="false" Text="מקבל אורחים" CssClass="RegularCheckBoxList" />
                                        </div>
                                        <asp:TextBox ID="txtProfessionsRelevantForReceivigGuests" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                    </td>
                                    <td style="padding:1px 5px 0px 0px">
                                        <div id="divExtendedSearch" runat="server">
                                            <asp:CheckBox ID="chkExtendedSearch" Width="92px" runat="server" CssClass="MultiLineLabel"
                                                Text="חיפוש מורחב" onclick="ExtendedSearchClicked();" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr id="trMedicalAspect" runat="server">
                        <td style="padding-right:4px">
                            <asp:Label ID="lblMedicalAspect" Width="46px" runat="server" Text="היבט"></asp:Label>
                        </td>
                        <td colspan="3">
                            <div style="float: right;">
                                <asp:TextBox Width="60px" Height="20px" ID="txtMedicalAspectCode" AutoPostBack="true"
                                    runat="server" OnTextChanged="txtMedicalAspectCode_TextChanged"></asp:TextBox>
                            </div>
                            <div style="float: right; margin-right: 1px;">
                                <asp:UpdatePanel runat="server" ID="upMedicalAspect">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="txtMedicalAspectCode" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <asp:TextBox Height="20px" Width="107px" ID="txtMedicalAspectDescription" runat="server"></asp:TextBox>
                                        <cc1:AutoCompleteExtender runat="server" ID="AutoMedicalAspectDescription" TargetControlID="txtMedicalAspectDescription"
                                            BehaviorID="acMedicalAspectDescription" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                            ServiceMethod="GetMedicalAspects" MinimumPrefixLength="1" CompletionInterval="500"
                                            CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="false" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                            EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                            CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedMedicalAspectDescription"
                                            OnClientPopulated="CommonClientPopulated" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </td>
                    </tr>

                </table>            
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content3" runat="server" ContentPlaceHolderID="phSearchParameterThirdColumn">
    <table>
        <tr>
            <td valign="top" style="width: 65px; padding-top: 0px; padding-right: 5px">
                <asp:Label ID="lblHandicappedFacilities" runat="server" Text="הערכות לנכים"></asp:Label>
            </td>
            <td valign="top">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:TextBox ID="txtHandicappedFacilitiesList" ReadOnly="false" onfocus="SyncronizeHandicappedFacilitiesList();"
                                onchange="ClearHandicappedFacilitiesList();" runat="server" Width="150px" TextMode="MultiLine"
                                Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                            <asp:TextBox ID="txtHandicappedFacilitiesList_ToCompare" runat="server" CssClass="DisplayNone"
                                EnableTheming="false"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ID="autoCompleteHandicappedFacilities" TargetControlID="txtHandicappedFacilitiesList"
                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetHandicappedFacilitiesByName"
                                MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="true" OnClientItemSelected="getSelectedHandicappedFacilityCode"
                                CompletionSetCount="12" DelimiterCharacters="" Enabled="True" CompletionListCssClass="CopmletionListStyle" />
                        </td>
                        <td valign="top">
                            <input type="image" id="btnHandicappedFacilitiesPopUp" style="cursor: pointer;" src="Images/Applic/icon_magnify.gif"
                                onclick="SelectHandicappedFacilities(); return false;" />
                        </td>
                        <td style="display: none;">
                            <asp:TextBox ID="txtHandicappedFacilitiesCodes" runat="server" TextMode="multiLine"
                                EnableTheming="false"></asp:TextBox>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

        <tr>
            <td valign="top" style="padding-right: 5px">
                <asp:Label ID="lblPopulationSectors" runat="server" Text="מגזר"></asp:Label>
            </td>
            <td valign="top">
                <asp:DropDownList ID="ddlPopulationSectors" runat="server" Width="154px" AppendDataBoundItems="true"
                    DataTextField="PopulationSectorDescription" DataValueField="PopulationSectorID">
                    <asp:ListItem Value="-1" Text=" "></asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td valign="top" style="width: 65px; padding-right: 5px">
                <asp:Label ID="lblClinicCode" runat="server" Text="קוד סימול"></asp:Label>
            </td>
            <td valign="top">
                <asp:TextBox ID="txtClinicCode" Width="150px" runat="server" MaxLength="20"></asp:TextBox>
                <asp:CompareValidator runat="server" Text="!" ControlToValidate="txtClinicCode" Type="Integer"
                    Operator="DataTypeCheck" ID="VldTypeCheckClinicKod" ValidationGroup="vldGrSearch"></asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td valign="top" style="padding-right: 5px;">
                <asp:Label ID="lblStatus" runat="server" Text="סטטוס"></asp:Label>
            </td>
            <td valign="top">
                <asp:DropDownList ID="ddlStatus" Width="154px" AppendDataBoundItems="True" runat="server"
                    DataTextField="statusDescription" DataValueField="status">
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 70px; padding-top: 0px; padding-right: 5px">

                                <asp:Label ID="lblQueueOrderTitle" runat="server" Text="אופן הזימון"></asp:Label>

                        </td>
                        <td>
                            <asp:TextBox ID="txtQueueOrder" runat="server" Width="150px" onchange="ClearQueueOrderMethodsList();"
                                TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ID="autoGetQueueOrderMethodsAndOptions" TargetControlID="txtQueueOrder"
                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetQueueOrderMethodsAndOptions"
                                MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="true" OnClientItemSelected="geSelectedtQueueOrderMethods"
                                CompletionSetCount="12" DelimiterCharacters="" Enabled="True" CompletionListCssClass="CopmletionListStyle" />                            
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
        <tr>
            <td></td>
            <td>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content4" runat="server" ContentPlaceHolderID="phMapSearchControls_HoleRow1">
    <table id="tblClalitService" runat="server" cellpadding="0" cellspacing="0">
        <tr>                        
            <td>
                <asp:Label ID="lblClalitService" Width="46px" runat="server" Text="קוד שירות"></asp:Label>
            </td>
            <td colspan="3">
                <div style="float: right;">
                    <asp:TextBox Width="60px" Height="20px" ID="txtClalitServiceCode" AutoPostBack="true"
                        runat="server" OnTextChanged="txtClalitServiceCode_TextChanged"></asp:TextBox>
                </div>
                <div style="float: right; margin-right: 1px;">
                    <asp:UpdatePanel runat="server" ID="upClalitServiceDesc">
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="txtClalitServiceCode" />
                        </Triggers>
                        <ContentTemplate>
                            <asp:TextBox Height="20px" Width="107px" ID="txtClalitServiceDesc" runat="server"></asp:TextBox>
                            <cc1:AutoCompleteExtender runat="server" ID="AutoClalitServiceDesc" TargetControlID="txtClalitServiceDesc"
                                BehaviorID="acClalitServiceDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                ServiceMethod="GetClalitServices" MinimumPrefixLength="1" CompletionInterval="500"
                                CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="false" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedClalitServiceDesc"
                                OnClientPopulated="CommonClientPopulated" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </td>                    
        </tr>

    </table>
</asp:Content>
<asp:Content ID="Content5" runat="server" ContentPlaceHolderID="phMapSearchControls_HoleRow2">
    <table cellpadding="0" cellspacing="0" border="0">

    </table>
</asp:Content>
<asp:Content ID="Content6" ContentPlaceHolderID="phBetweenParamsToResults" runat="server">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:ValidationSummary ID="vldSummarySearch" runat="server" ValidationGroup="vldGrSearch" />
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content7" ContentPlaceHolderID="phGrid" runat="server">
    <asp:Panel ID="pnlTabs" runat="server" Visible="false">
        <div style="background-image: url('Images/Applic/tab_WhiteBlueBackGround.jpg'); height: 30px;
            margin: 0px; width: 1200px; background-repeat: repeat-x;"
            dir="rtl">
            <div style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; background-image: url('Images/Applic/tab_WhiteBlueBackGround.jpg');
                background-position: bottom; background-repeat: repeat-x; width: 15px; float: right;
                height: 32px">
            </div>
            <div id="tabDeptsSelected" runat="server" style="float: right; width: 77px">
                <div class="divRightTabSelected">
                </div>
                <div class="divCenterTabSelected">
                    <asp:Label ID="Label1" runat="server" Width="60px" EnableTheming="false" Text="יחידות"
                        CssClass="SelectedTabButton"></asp:Label>
                </div>
                <div class="divLeftTabSelected">
                </div>
            </div>
            <div id="tabDeptsNotSelected" runat="server" class="tabNotSelected DisplayNone" style="float: right;
                width: 82px">
                <div class="divRightTabNotSelected">
                </div>
                <div class="divCenterTabNotSelected">
                    <asp:Button ID="btnShowDepts" runat="server" Width="60px" Text="יחידות" CssClass="TabButton_14"
                        OnClick="btnShowDepts_Clicked" OnClientClick="showProgressBar();" />
                </div>
                <div class="divLeftTabNotSelected">
                </div>
            </div>
            <div id="tabMushlamServicesSelected" runat="server">
                <div class="divRightTabSelected">
                </div>
                <div class="divCenterTabSelected">
                    <asp:Label ID="Label2" runat="server" EnableTheming="false" Text="פירוט שירותי מושלם"
                        CssClass="SelectedTabButton"></asp:Label>
                </div>
                <div class="divLeftTabSelected">
                </div>
            </div>
            <div id="tabMushlamServicesNotSelected" runat="server" class="tabNotSelected DisplayNone">
                <div class="divRightTabNotSelected">
                </div>
                <div class="divCenterTabNotSelected">
                    <asp:Button ID="btnShowMushlamServices" runat="server" Text="פירוט שירותי מושלם" CssClass="TabButton_14"
                        OnClick="btnShowMushlamServices_click" OnClientClick="showProgressBar();" />
                </div>
                <div class="divLeftTabNotSelected">
                </div>
            </div>
        </div>
        <div id="divMushlamServicesSuppliersOnly" runat="server" align="right" style="background-color: #EBF6FE; margin: 0px; width: 957px; padding-right:28px;">
            <asp:Label ID="lblMushlamServicesSuppliersOnly" EnableTheming="false" CssClass="LabelCaptionBlueBold_14" runat="server" Text="תוצאות חיפוש עבור שירות מושלם: "></asp:Label>
        </div>
    </asp:Panel>
    <div id="divDeptSearchResults" runat="server" style="width: 100%; height: 100%; display: none">
        <table id="tblClinicGridControls" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <asp:Label ID="lblFromHour_ToHour_search_alert" style="color:#e75c00" runat="server">שים לב, יופיעו גם יחידות/רופאים הפעילים רק בחלק מטווח הזמן שהוזן. חובה למלא את שני השדות</asp:Label>
                    <asp:Label ID="lblReceptionParameters_With_FromHour_search_alert" style="color:#e75c00;" Visible="false" runat="server">שם לב, יופיעו גם יחידות/רופאים שלא מצויין עבורם שאינם פעילים בטווח המבוקש או הפעילים רק בחלק מטווח הזמן המבוקש</asp:Label>
                    <asp:Label ID="lblReceptionParameters_WithNO_FromHour_search_alert" style="color:#e75c00;" Visible="false" runat="server">שימו לב, יתכן ויופיעו בתחתית הרשימה  נותני שירות/יחידות ללא שעות פעילות. לברור שעות הפעילות שלהם, יש לפנות ליחידה</asp:Label>
                    <div id="div_health_gov_il" runat="server" class="LabelBoldBlack_14" style="color:#e75c00">
                        לאיתור תחנות טיפת חלב של משרד הבריאות לחץ 
                        <a target="_blank" href="https://www.health.gov.il/Subjects/pregnancy/health_centers/Pages/Vaccination_centers.aspx">כאן</a>
                        <br />לידיעה, תחנות טיפת חלב של משרד הבריאות מספקות שירות לכל הפונים, ללא תלות בהשתייכות לקופת חולים
                    </div>
                </td>
            </tr>
            <tr id="trPagingButtons" runat="server" style="display: none; margin-left: 5px">
                <td style="background-color: #f9f9f9; border-top: 1px solid #e3e3e3; border-bottom: 1px solid #e3e3e3;">
                    <table cellpadding="0" cellspacing="0" width="1200px">
                        <tr>
                            <td style="text-align: right; width: 210px;">
                                <asp:Label ID="lblTotalRecords" runat="server" Text="נמצא 750 רשומות"></asp:Label>
                                <asp:Label ID="lblPageFromPages" runat="server" Text=" עמוד 5 מתוך 15 "></asp:Label>
                            </td>
                            <td style="width: 80px;">
                                <asp:PlaceHolder ID="phButtonsShowHideMap" runat="server"></asp:PlaceHolder>
                            </td>
                            <td align="left" style="padding-left: 5px;">
                                <asp:ImageButton ID="imgGetSearchResultReport" runat="server" ImageUrl="~/Images/Applic/Excel_Button.png" OnClientClick="OpenSearchResultReport(101,'rprt_DeptEmployeesClinics_SearchResult'); return false;" />
                                <asp:LinkButton ID="btnFirstPage" runat="server" Text="<< הראשון" CssClass="LinkButtonBoldForPaging"
                                    OnClick="btnFirstPage_Click"></asp:LinkButton>
                                &nbsp;
                                <asp:LinkButton ID="btnPreviousPage" runat="server" Text="< הקודם" CssClass="LinkButtonBoldForPaging"
                                    OnClick="btnPreviousPage_Click"></asp:LinkButton>
                                &nbsp;
                                <asp:DropDownList ID="ddlCarrentPage" runat="server" Width="40px" AppendDataBoundItems="true"
                                    AutoPostBack="True" OnSelectedIndexChanged="ddlCarrentPage_SelectedIndexChanged">
                                </asp:DropDownList>
                                &nbsp;
                                <asp:LinkButton ID="btnNextPage" runat="server" Text="הבא >" CssClass="LinkButtonBoldForPaging"
                                    OnClick="btnNextPage_Click"></asp:LinkButton>
                                &nbsp;
                                <asp:LinkButton ID="btnLastPage" runat="server" Text="האחרון >>" CssClass="LinkButtonBoldForPaging"
                                    OnClick="btnLastPage_Click"></asp:LinkButton>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr id="trSortingButtons" runat="server" style="display: none">
                <td id="tdSortingButtons" runat="server" style="background-color: #f0f0f0; text-align: right;">
                    <table id="tblResultsHeader" cellpadding="0" cellspacing="0" style="text-align: right;
                        vertical-align: middle;">
                        <tr>
                            <td style="width: 17px;">
                            </td>
                            <td id="tdEmptyData" runat="server" style="text-align: center;" class="ColumnHeader">
                            </td>
                            <td style="width: 20px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnSubUnit" runat="server" Text="" ColumnIdentifier="subUnitTypeCode"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 28px; text-align: center;" class="ColumnHeader">
                            </td>
                            <td style="width: 30px;">
                                &nbsp;
                            </td>
                            <td style="width: 170px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnDeptName" runat="server" Text="שם יחידה" ColumnIdentifier="deptName"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td id="tdAddressHeader" runat="server" style="padding-right: 5px;">
                                <cc1:SortableColumn ID="columnAddress" runat="server" Text="כתובת" ColumnIdentifier="address"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 125px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnCity" runat="server" Text="ישוב" ColumnIdentifier="cityName"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 90px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnPhone" runat="server" Text="טלפון" ColumnIdentifier="phone"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 45px; text-align: center;" class="ColumnHeader">
                            </td>
                            <td style="width: 200px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnDoctorName" runat="server" Text="ניתן על ידי" ColumnIdentifier="doctorName"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 140px; padding-right: 5px;">
                                <cc1:SortableColumn ID="columnEvents" runat="server" Text="תחום שירות" ColumnIdentifier="ServiceDescription"
                                    OnSortClick="btnSort_Click" />
                            </td>
                            <td style="width: 25px;"><!-- ReceiveGuests -->
                                &nbsp;
                            </td>
                            <td style="width: 100px;"><!-- Queue order -->
                                <asp:Label ID="lblQueueOrder" runat="server" EnableTheming="false" CssClass="ColumnHeader">אופן זימון</asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="height: 5px;">
                </td>
            </tr>
            <tr id="trGvClinicList" runat="server" style="display: none">
                <td align="right">
                    <div id="divGvClinicList" runat="server" style="height: 345px; overflow-y: scroll;">
                        <div style="direction: rtl;">
                            <table id="tblResults" cellpadding="0" cellspacing="0">
                                <asp:Repeater ID="repClinicsList" runat="server" EnableViewState="true" OnItemDataBound="repClinicsList_ItemDataBound">
                                    <ItemTemplate>
                                        <tr class="trPlain" id="trClinic" runat="server">
                                            <td style="display: none;">
                                                <asp:Label ID="lblDeptCode" runat="server" Text='<% #Bind("DeptCode") %>' Visible="false"></asp:Label>
                                            </td>
                                            <td id="tdMapOrder" runat="server" class="blueTD" style="width: 10px; display: none;
                                                text-align: center;">
                                                <div style="margin-right: 0;">
                                                    <asp:Label runat="server" ID="MapOrderNumber" CssClass="RegularLabel"></asp:Label>
                                                </div>
                                            </td>
                                            <td id="tdMap" class="blueTD" style="width: 25px; text-align: center;">
                                                <!-- מפה -->
                                                <div class="divImage">
                                                    <asp:Image ID="imgMap" runat="server" Style="cursor: pointer" />
                                                </div>
                                            </td>
                                            <td class="blueTD" style="width: 24px; text-align: center;">
                                                <!-- שיוך -->
                                                <div class="divImage">
                                                    <asp:Image ID="imgAttributed" runat="server" ToolTip="שירותי בריאות כללית" />
                                                </div>
                                            </td>
                                            <td class="blueTD" style="width: 27px; text-align: center;">
                                                <!-- שעות יחידה-->
                                                <div class="divImage">
                                                    <asp:Image ID="imgRecepAndComment" AlternateText="הקש להצגת שעות המשרד" runat="server"
                                                        Style="cursor: pointer" />
                                                </div>
                                            </td>
                                            <td class="blueTD" style="width: 23px; text-align: center;">
                                                <div class="divImage">
                                                    <asp:Image ID="imgServiceLevel" runat="server" />
                                                </div>
                                            </td>
                                            <td class="blueTD" style="width: 175px;">
                                                <!-- שם יחידה -->
                                                <div>
                                                    <asp:Panel ID="pnlLink" runat="server">
                                                        <asp:HyperLink ID="lnkToDept" Text='<%#Eval("deptName")%>' runat="server"></asp:HyperLink>
                                                        <asp:Label ID="lblTemporarilyInactive" runat="server" Text="(לא פעיל זמנית)" CssClass="LabelBoldRed12"  EnableTheming="false"></asp:Label>
                                                    </asp:Panel>
                                                </div>
                                            </td>
                                            <td class="spaceTD">
                                            </td>
                                            <td id="tdAddressData" runat="server" class="grayTD">
                                                <!-- כתובת -->
                                                <div>
                                                    <asp:Label ID="lblAddress" CssClass="RegularLabel" runat="server" Text='<%#Eval("address")%>'></asp:Label>
                                                </div>
                                            </td>
                                            <td class="grayTD" style="width: 130px;">
                                                <!-- ישוב -->
                                                <div>
                                                    <asp:Label ID="lblCityName" CssClass="RegularLabel" runat="server" Text='<%#Eval("cityName")%>'></asp:Label>
                                                </div>
                                            </td>
                                            <td class="grayTD" style="width: 90px;">
                                                <!-- טלפון -->
                                                <div>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td dir="ltr">
                                                                <asp:Label ID="lblPhone" CssClass="phoneLabel" runat="server" Text='<%#Eval("phone")%>'></asp:Label>
                                                                <asp:Image ID="imgPhoneRemark" runat="server" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td> 
                                            <td class="greenTD" style="width:24px;text-align:center;"><!-- שיוך -->
                                                <div class="divImage">
                                                    <asp:Image ID="imgAgreementType" runat="server" />
                                                </div>
                                            </td>
                                            <td class="greenTD" style="width: 27px; text-align: center;">
                                                <!-- שעות שירות -->
                                                <div class="divImage">
                                                    <asp:Image ID="imgServiceRecepAndComment" runat="server" Style="cursor: pointer" />
                                                </div>
                                            </td>
                                            <td class="greenTD" style="width: 200px;">
                                                <!-- ניתן על ידי -->
                                                <div>
                                                    <asp:HyperLink ID="lnkToDoctor" Text='<%#Eval("doctorName")%>' runat="server"></asp:HyperLink>
                                                </div>
                                            </td>
                                            <td class="greenTD" style="width: 150px;">
                                                <!-- שם שירות -->
                                                <div>
                                                    <asp:HyperLink ID="lnkToService" CssClass="RegularLabel" Text='<%#Eval("ServiceDescription")%>'
                                                        runat="server"></asp:HyperLink>
                                                </div>
                                            </td>
                                            <td class="greenTD" style="width: 20px; text-align:center;">
                                                <div class="divImage">
                                                    <asp:Image ID="imgReceiveGuests" runat="server" />
                                                </div>
                                            </td>
                                            <td class="greenTD" style="width: 100px;">
                                                <!-- אופן זימון -->
                                                <div style="position: relative;">    
                                                    <asp:Label ID="lblQueueOrder" runat="server" EnableTheming="false" CssClass="QueueOrderText" Visible="false"></asp:Label>
                                                    <asp:Literal ID="litQueueOrder" runat="server"></asp:Literal>
                                                    <table id='tblQueueOrderPhonesAndHours<%# Eval("RowNumber") %>' style="display: none; direction: rtl; padding: 10px; border:1px solid #BDD7F1; border-radius: 3px; left: 50px; min-height: 60px; position: absolute; min-width: 120px; background-color: white; z-index: 900" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td dir="ltr" align="right">
                                                                <asp:Label ID="lblDeptEmployeeQueueOrderPhones" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView ID="gvDeptEmployeeQueueOrderHours" runat="server" EnableTheming="false" GridLines="None" AutoGenerateColumns="false" HeaderStyle-CssClass="HeaderStyleBlueBold">
                                                                    <Columns>
                                                                        <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
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
                                                            <td align="left" style="padding-left: 5px; padding-top: 5px; border-top: 1px solid #BADBFC; text-align: center;" >
                                                                <img alt="סגור" style='cursor: pointer; max-width: 80px' src='Images/Applic/btn_ClosePopUpBlue.gif' onclick="javascript:OnCloseQueueOrderPhonesAndHoursPopUp()" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 1px; font-size: 0;">
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </table>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:TextBox ID="txtURLforResolutionSetUp" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                </td>
            </tr>
        </table>
    </div>
    <div id="divMushlamServicesResults" runat="server" style="display: none">
        <div style="width: 980px">
            <table style="width: 985px;">
                <tr id="trNoResults" visible="false" runat="server" style="height: 20px; background-color: #F8F8F8">
                    <td align="right" style="padding-right: 6px">
                        <asp:Label ID="lblFoundResults" runat="server"></asp:Label>
                        <asp:Label ID="lblSearchedText" runat="server" CssClass="BlueBoldLabel" EnableTheming="false"></asp:Label>
                    </td>
                </tr>
                <tr id="trMushlamResults" runat="server" style="height: 20px; background-color: #F8F8F8">
                    <td>
                        <table width="100%" cellpadding="0" cellspacing="0">
                            <tr>
                                <td colspan="2" align="right" class="ColumnHeader" style="padding-right: 17px">
                                    <asp:Label ID="Label4" runat="server" Width="70px" EnableTheming="false">ספקים</asp:Label>
                                    <asp:Label ID="Label5" runat="server" EnableTheming="false">שם שירות</asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone"  EnableTheming="false"></asp:TextBox>
                                    <div id="divMushlamServices" style="width: 260px; height: 372px; direction: ltr; overflow-y: auto;" onscroll="GetMushlamScrollPosition();">
                                        <div  style="direction: rtl; height: 100%; vertical-align: top">
                                            <asp:Repeater ID="rptSearchResults" runat="server">
                                                <ItemTemplate>
                                                    <div id="divServiceRow" runat="server" class="mushlamServiceResultsRow" style="vertical-align:top">
                                                        <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblNumOfSuppliers" runat="server" Text='<%# Eval("NumberOfSuppliers") %>' Width="30px"></asp:Label>
                                                            </td>
                                                            <td>
                                                            <div style="width:35px" >
                                                                <asp:ImageButton ID="btnShowProviders" EnableTheming="false" CommandArgument='<%# Eval("ServiceCode") + "_" + Eval("GroupCode") + "_" + Eval("SubGroupCode") + "_" + Eval("ServiceName") %>' OnClick="btnShowProviders_Click" runat="server" ImageUrl="~/Images/Applic/ServiceProviders.gif" ToolTip="הצגת ספקים לשירות" />
                                                                <asp:Label ID="lblEmptyLabel" runat="server"></asp:Label>
                                                            </div>
                                                            </td>                                                        
                                                            <td>
                                                                <asp:LinkButton ID="btnServiceName" runat="server" CssClass="LinkButtonBoldForPaging"
                                                                OnClick="lnkMushlamService_clicked" OnClientClick="showProgressBar();" Text='<%# Eval("ServiceName") %>'
                                                                CommandArgument='<%# Eval("ServiceCode") + "_" + Eval("GroupCode") + "_" + Eval("SubGroupCode") %>' Width="170px" />
                                                            </td>                                                        
                                                        </tr>
                                                        </table>
                                                     </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </div>
                                    </div>
                                </td>
                                <td valign="top" style="padding-top: 1px;">
                                    <div id="tabsContainer" style="width: 100%; background-color: #E7F0F7; height: 320px;
                                        text-align: right;">
                                        <div style="height: 20px; margin-bottom: 8px; padding-bottom: 1px; width: 690px;
                                            margin-right: 18px; margin-top: 5px" dir="rtl">
                                            <div id="tabInnerServicesIsSelected" runat="server" style="float: right; width: 58px;">
                                                <div class="divRightTabSelected height22">
                                                </div>
                                                <div class="divCenterTabSelected height22" style="width:41px; text-align:center">
                                                    <asp:Label ID="Label6" runat="server" EnableTheming="false" Text="כללי" CssClass="LabelBoldBlack_14"></asp:Label>
                                                </div>
                                                <div class="divLeftTabSelected height22">
                                                </div>
                                            </div>
                                            <div id="tabInnerServicesNotSelected" runat="server" class="tabNotSelected" style="width: 58px;
                                                float: right; display: none">
                                                <div class="divRightTabNotSelected">
                                                </div>
                                                <div class="divCenterTabNotSelected" style="width:35px; text-align:center">
                                                    <asp:Button runat="server" Text="כללי" CssClass="TabButton_13" OnClick="btnShowDepts_Clicked"
                                                        OnClientClick="DisplaySelectedTab('tabInnerServicesIsSelected', 'tabInnerServicesNotSelected', 'pnlMushlamServiceDescription');return false;" />
                                                </div>
                                                <div class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div id="tabInnerAgreementMethodIsSelected" runat="server" style="float: right; width:100px;text-align:center;
                                                display: none">
                                                <div class="divRightTabSelected height22">
                                                </div>
                                                <div class="divCenterTabSelected height22" style="width:85px; text-align:center">
                                                    <asp:Label runat="server" EnableTheming="false" Text="מסלול הסדר" CssClass="LabelBoldBlack_14"></asp:Label>
                                                </div>
                                                <div class="divLeftTabSelected height22">
                                                </div>
                                            </div>
                                            <div id="tabInnerAgreementMethodNotSelected" runat="server" class="tabNotSelected"
                                                style="width: 100px; float: right">
                                                <div class="divRightTabNotSelected">
                                                </div>
                                                <div class="divCenterTabNotSelected" style="width:80px">
                                                    <asp:Button runat="server" Text="מסלול הסדר" CssClass="TabButton_13" OnClientClick="DisplaySelectedTab('tabInnerAgreementMethodIsSelected', 'tabInnerAgreementMethodNotSelected', 'pnlMushlamAgreement');return false;" />
                                                </div>
                                                <div class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div id="tabInnerRefundMethodIsSelected" runat="server" style="float: right; width:100px;
                                                display: none">
                                                <div class="divRightTabSelected height22">
                                                </div>
                                                <div class="divCenterTabSelected height22" style="width:83px; text-align:center">
                                                    <asp:Label ID="Label8" runat="server" EnableTheming="false" Text="מסלול החזר" CssClass="LabelBoldBlack_14"></asp:Label>
                                                </div>
                                                <div class="divLeftTabSelected height22">
                                                </div>
                                            </div>
                                            <div id="tabInnerRefundMethodNotSelected" runat="server" class="tabNotSelected" style="width: 100px;
                                                float: right">
                                                <div class="divRightTabNotSelected">
                                                </div>
                                                <div class="divCenterTabNotSelected">
                                                    <asp:Button ID="Button3" runat="server" Text="מסלול החזר" CssClass="TabButton_13"
                                                        OnClientClick="DisplaySelectedTab('tabInnerRefundMethodIsSelected', 'tabInnerRefundMethodNotSelected', 'pnlMushlamRefund');return false;" />
                                                </div>
                                                <div class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div id="tabInnerSalServicesIsSelected" runat="server" style="float: right; width: 135px;
                                                display: none">
                                                <div class="divRightTabSelected height22">
                                                </div>
                                                <div class="divCenterTabSelected height22" style="width:115px; text-align:center">
                                                    <asp:Label ID="Label9" runat="server" EnableTheming="false" Text="שירותי סל קשורים"
                                                        CssClass="LabelBoldBlack_14"></asp:Label>
                                                </div>
                                                <div class="divLeftTabSelected height22">
                                                </div>
                                            </div>
                                            <div id="tabInnerSalServicesNotSelected" runat="server" class="tabNotSelected" style="width: 135px;
                                                float: right">
                                                <div class="divRightTabNotSelected">
                                                </div>
                                                <div class="divCenterTabNotSelected" style="width:115px">
                                                    <asp:Button ID="Button4" runat="server" Text="שירותי סל קשורים" CssClass="TabButton_13"
                                                        OnClientClick="DisplaySelectedTab('tabInnerSalServicesIsSelected', 'tabInnerSalServicesNotSelected', 'pnlMushlamSalServices');return false;" />
                                                </div>
                                                <div class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div id="tabInnerServiceModelsIsSelected" runat="server" style="display:none; width:160px">
                                                <div class="divRightTabSelected height22">
                                                </div>
                                                <div class="divCenterTabSelected height22" style="width:130px; text-align:center">
                                                    <asp:Label runat="server" EnableTheming="false" Text="רשימת דגמים לשירות" CssClass="LabelBoldBlack_14"></asp:Label>
                                                </div>
                                                <div class="divLeftTabSelected height22">
                                                </div>
                                            </div>
                                            <div id="tabInnerServiceModelsNotSelected" runat="server" class="tabNotSelected" style="float: right; width: 160px">
                                                <div class="divRightTabNotSelected">
                                                </div>
                                                <div class="divCenterTabNotSelected" style="width:130px; text-align:center;">
                                                    <asp:Button ID="btnShowModelsForService" runat="server" Text="רשימת דגמים לשירות" Width="125px"
                                                        CssClass="TabButton_13" OnClientClick="DisplaySelectedTab('tabInnerServiceModelsIsSelected', 'tabInnerServiceModelsNotSelected', 'pnlMushlamServiceModels');return false;" />
                                                </div>
                                                <div class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div style="background-color: #BDD7F1; margin-top: 0px; width: 100%; height: 1px">
                                            </div>
                                        </div>
                                        <div id="pnlMushlamServiceDescription">
                                            <table>
                                                <tr>
                                                    <td valign="top">
                                                        <div class="divMushlamContainer" style="padding-top:8px; height:270px">
                                                            <div class="divMushlamTopRightCorner">
                                                            </div>
                                                            <div class="divMushlamTopCenter LabelBoldBlack_13" style="line-height: 23px">
                                                                כללי</div>
                                                            <div class="divMushlamTopLeftCorner">
                                                            </div>
                                                            <div class="divMushlamInnerContainer" style="height:230px">
                                                                <div class="divMushlamMiddleRight">
                                                                </div>
                                                                <div class="divMushlamMiddleContent">
                                                                    <div style="direction: rtl">
                                                                        <asp:Label ID="lblEligibilityRemark" EnableTheming="false" CssClass="LabelBlack_14" runat="server"></asp:Label>
                                                                        <asp:Label ID="lblGeneralRemark" EnableTheming="false" CssClass="LabelBlack_14" runat="server"></asp:Label>
                                                                    </div>
                                                                </div>
                                                                <div class="divMushlamMiddleLeft">
                                                                </div>
                                                            </div>
                                                            <div class="divMushlamBottomRight">
                                                            </div>
                                                            <div class="divMushlamBottomCenter">
                                                            </div>
                                                            <div class="divMushlamBottomLeft">
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr style="visibility:hidden">
                                                    <td>
                                                        <div class="divMushlamContainer">
                                                            <div class="divMushlamTopRightCorner">
                                                            </div>
                                                            <div class="divMushlamTopCenter LabelBoldBlack_13" style="line-height: 23px">
                                                                הערות לנציג</div>
                                                            <div class="divMushlamTopLeftCorner">
                                                            </div>
                                                            <div class="divMushlamInnerContainer">
                                                                <div class="divMushlamMiddleRight">
                                                                </div>
                                                                <div class="divMushlamMiddleContent">
                                                                    <div style="direction:rtl;padding-right:2px">
                                                                        <asp:Label ID="lblRepRemark" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                                                    </div> 
                                                                </div>
                                                                <div class="divMushlamMiddleLeft">
                                                                </div>
                                                            </div>
                                                            <div class="divMushlamBottomRight">
                                                            </div>
                                                            <div class="divMushlamBottomCenter">
                                                            </div>
                                                            <div class="divMushlamBottomLeft">
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="pnlMushlamAgreement" style="display: none; padding: 10px; padding-right: 15px;">

                                                <div class="divMushlamTopRightCornerWithoutColor">
                                                </div>
                                                <div class="divMushlamTopCenterWithoutColor">
                                                </div>
                                                <div class="divMushlamTopLeftCornerWithoutColor">
                                                </div>
                                                <div class="divMushlamInnerContainerExtended">
                                                    <div class="divMushlamMiddleRight">
                                                    </div>
                                                    <div class="divMushlamMiddleContentExtended">
                                                        <div style="direction: rtl;">
                                                            <asp:Label ID="lblAgreementDetails" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                                        </div>
                                                    </div>
                                                    <div class="divMushlamMiddleLeft">
                                                    </div>
                                                </div>

                                            <div class="divMushlamBottomRight">
                                            </div>
                                            <div class="divMushlamBottomCenter">
                                            </div>
                                            <div class="divMushlamBottomLeft">
                                            </div>
                                        </div>
                                        <div id="pnlMushlamRefund" style="display: none; padding: 10px; padding-right: 15px">
                                            <asp:Panel id="pnlInnerMushlamRefund" runat="server" Visible="false" >
                                            <div style="border:1px solid #E7F0F7">
                                                <div class="divMushlamTopRightCornerWithoutColor">
                                                </div>
                                                <div class="divMushlamTopCenterWithoutColor">
                                                </div>
                                                <div class="divMushlamTopLeftCornerWithoutColor">
                                                </div>
                                                <div class="divMushlamInnerContainerExtended">
                                                    <div class="divMushlamMiddleRight">
                                                    </div>
                                                    <div class="divMushlamMiddleContentExtended">
                                                        <asp:Label ID="lblRefund" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                                    </div>
                                                    <div class="divMushlamMiddleLeft">
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="divMushlamBottomRight">
                                            </div>
                                            <div class="divMushlamBottomCenter">
                                            </div>
                                            <div class="divMushlamBottomLeft">
                                            </div>
                                        </asp:Panel>
                                        </div>
                                        <div id="pnlMushlamSalServices" style="display: none; padding-right: 5px; padding-top: 10px">
                                            <div class="divMushlamContainer" style="direction: ltr; overflow-y: auto; height: 290px;
                                                margin-right: 10px; width: 675px;">
                                                <asp:Repeater ID="rptLinkedServices" runat="server">
                                                    <HeaderTemplate>
                                                        <div style="display: inline">
                                                            <div class="divMushlamTopRightCorner">
                                                            </div>
                                                            <div class="divMushlamTopCenter LabelBoldBlack_13" style="width: 645px; float: right;
                                                                padding-right: 10px;">
                                                                <span class="marginTop3" style="width: 155px; float: right;">קוד שירות</span>
                                                                <div style="background-color: #DBDBDA; width: 2px; float: right">
                                                                    &nbsp;&nbsp;</div>
                                                                <span class="marginTop3" style="margin-right: 15px; width: 150px; float: right">שם שירות</span>
                                                            </div>
                                                            <div class="divMushlamTopLeftCorner">
                                                            </div>
                                                        </div>
                                                        <div class="divMushlamInnerContainer" style="height: 220px">
                                                            <div class="divMushlamMiddleRight">
                                                            </div>
                                                            <div class="divMushlamMiddleContent" style="height: 220px; width: 659px">
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <div style="height: 25px; border-bottom: 1px solid #E8F0F5; vertical-align: middle;
                                                            display: block">
                                                            <div style="float: right; width: 152px">
                                                                <asp:Label ID="Label3" runat="server" Width="152px" EnableTheming="false" CssClass="linkedServicesDesc SimpleText"><%# Eval("ServiceCode") %></asp:Label>
                                                            </div>
                                                            <div style="border-right: 1px solid #E8F0F5; padding-right: 15px; line-height: 24px;
                                                                vertical-align: middle; right: 180px; width: 380px">
                                                                <a href="Public/ZoomSalService.aspx?ServiceCode=<%# Eval("ServiceCode") %>"
                                                                    class="mushlamServicesText">
                                                                    <%# Eval("ServiceName") %></a>
                                                            </div>
                                                        </div>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </div>
                                                        <div class="divMushlamMiddleLeft">
                                                        </div>
                                                        </div>
                                                        <div class="divMushlamBottomRight">
                                                        </div>
                                                        <div class="divMushlamBottomCenter" style="width: 655px">
                                                        </div>
                                                        <div class="divMushlamBottomLeft">
                                                        </div>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </div>
                                        <div id="pnlMushlamServiceModels" style="display: none; margin-right: 10px; padding-top: 10px;">
                                            <div class="divMushlamContainer" style="direction: ltr; overflow-y: auto; height: 300px;
                                                margin-right: 5px; width: 675px">
                                                <asp:Repeater ID="rptModels" runat="server">
                                                    <HeaderTemplate>
                                                        <div class="divMushlamTopRightCorner">
                                                        </div>
                                                        <div class="divMushlamTopCenter LabelBoldBlack_13" style="float: right;
                                                            direction: rtl">
                                                            <table cellpadding="0" cellspacing="0" style="height: 100%">
                                                                <tr>
                                                                    <td style="padding-top: 2px; width: 239px; padding-right: 15px">
                                                                        <span style="margin-right: 15px">שם</span>
                                                                    </td>
                                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 3px; padding-left: 2px;
                                                                        width: 102px;">
                                                                        <span class="marginTop3">השתתפות עצמית</span>
                                                                    </td>
                                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 10px; width: 191px;">
                                                                        <span class="marginTop3">הערה</span>
                                                                    </td>
                                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 2px">
                                                                        <span class="marginTop3">תקופת אכשרה</span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div class="divMushlamTopLeftCorner">
                                                        </div>
                                                        <div class="divMushlamInnerContainer" style="height: 220px">
                                                            <div class="divMushlamMiddleRight">
                                                                &nbsp;</div>
                                                            <div class="divMushlamMiddleContent" style="height: 220px;">
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <div class="mushlamServicesText" style="border-bottom: 1px solid #E8F0F5; 
                                                            direction: rtl; display: block">
                                                            <div style="float: right; width: 240px;">
                                                                <span style="line-height: 20px">
                                                                    <%# Eval("ModelDescription") %></span>
                                                            </div>
                                                            <div class="borderRightOnTable" style="float: right; width: 95px; padding-right: 10px">
                                                                <span style="width: 20px; line-height: 25px">
                                                                    <%# UIHelper.ReturnOnlyIfPositive(Convert.ToInt32(Eval("ParticipationAmount")), "שקלים")  %>&nbsp;</span>
                                                            </div>
                                                            <div class="borderRightOnTable" style="float: right; width: 200px; 
                                                                padding-right: 3px;">
                                                                <span>
                                                                    <%# Eval("Remark") %>&nbsp;</span>
                                                            </div>
                                                            <div class="borderRightOnTable" style="float: right; padding-right: 10px; line-height: 25px;">
                                                                <span style="width: 20px">
                                                                    <%# UIHelper.ReturnOnlyIfPositive(Convert.ToInt32(Eval("WaitingPeriod")), "חודשים")%>
                                                                    &nbsp;</span>
                                                            </div>
                                                        </div>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </div>
                                                        <div class="divMushlamMiddleLeft">
                                                            &nbsp;
                                                        </div>
                                                        </div>
                                                        <div class="divMushlamBottomRight">
                                                        </div>
                                                        <div class="divMushlamBottomCenter">
                                                        </div>
                                                        <div class="divMushlamBottomLeft">
                                                        </div>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <asp:HiddenField ID="hdnDeptsDataRecieved" runat="server" />
    <asp:HiddenField ID="hdnMushlamDataRecieved" runat="server" />
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance().add_endRequest(SetScrollPosition_divMushlamServices);
    </script>
</asp:Content>
