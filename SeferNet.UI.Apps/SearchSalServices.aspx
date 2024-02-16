<%@ Page Language="C#" 
    MasterPageFile="~/SeferMasterPageIEWide.master" 
    AutoEventWireup="true" 
    Inherits="SearchSalServices" 
    Title="חיפוש לפי סל שירותים" 
    Codebehind="SearchSalServices.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/DeptMapUC.ascx" TagName="DeptMapUC" TagPrefix="uc2" %>
<%@ Register Src="~/UserControls/SortableColumnHeader.ascx" TagName="sortableColumnHeader" TagPrefix="uc1" %>
<%@ Register Src="~/UserControls/SearchModeSelector.ascx" TagName="ModeSelector" TagPrefix="uc1" %>
<%@ Register Src="~/UserControls/SortableColumnHeader.ascx" TagName="SortableColumn" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <script type="text/javascript">

        var divSearchParametersClientID = '<%=divSearchParameters.ClientID %>';
        var btnShowSearchResultClientID = '<%=btnShowSearchResult.ClientID %>';
        var cbNotShowSearchParametersClientID = '<%=cbNotShowSearchParameters.ClientID %>';

        var txtServiceCodeClientID = '<% = txtClalitServiceCode.ClientID %>';
        var txtServiceDescClientID = '<% = txtClalitServiceDesc.ClientID %>';
        var txtServiceDest_ToCompareClientID = '<% = txtClalitServiceDesc_ToCompare.ClientID %>';

        var txtHealthOfficeCodeClientID = '<% = txtHealthOfficeCode.ClientID %>';
        var txtHealthOfficeDescClientID = '<% = txtHealthOfficeDesc.ClientID %>';
        var txtHealthOfficeDest_ToCompareClientID = '<% = txtHealthOfficeDesc_ToCompare.ClientID %>';

        var txtGroupCodeClientID = '<%= txtGroupCode.ClientID %>';
        var txtGroupsListCodesClientID = '<% = txtGroupsListCodes.ClientID %>';
        var txtGroupsListClientID = '<% = txtGroupsList.ClientID %>';
        var txtGroupsList_ToCompareClientID = '<% = txtGroupsList_ToCompare.ClientID %>';

        var txtProfessionCodeClientID = '<% = txtProfessionCode.ClientID %>';
        var txtProfessionsListCodesClientID = '<% = txtProfessionsListCodes.ClientID %>';
        var txtProfessionsListClientID = '<% = txtProfessionsList.ClientID %>';
        var txtProfessionsList_ToCompareClientID = '<% = txtProfessionsList_ToCompare.ClientID %>';

        var txtOmriCodeClientID = '<% = txtOmriCode.ClientID %>';
        var txtOmriCodeListClientID = '<% = txtOmriCodeList.ClientID %>';
        var txtOmriDescListClientID = '<% = txtOmriDescList.ClientID %>';
        var txtOmriDestList_ToCompareClientID = '<% = txtOmriDescList_ToCompare.ClientID %>';

        var txtICD9CodeClientID = '<% = txtICD9Code.ClientID %>';
        var txtICD9DescClientID = '<% = txtICD9Desc.ClientID %>';
        var txtICD9Desc_ToCompareClientID = '<% = txtICD9Desc_ToCompare.ClientID %>';

        var txtPopulationsListCodesClientID = '<% = txtPopulationsListCodes.ClientID %>';
        var txtPopulationsListClientID = '<% = txtPopulationsList.ClientID %>';
        var txtPopulationsList_ToCompareClientID = '<% = txtPopulationsList_ToCompare.ClientID %>';

        function CommonClientPopulated(source, eventArgs) {
            if (source._currentPrefix != null) {
                var list = source.get_completionList();
                var search = source._currentPrefix.toLowerCase();
                for (var i = 0; i < list.childNodes.length; i++) {
                    var text = list.childNodes[i].innerHTML;
                    var index = text.toLowerCase().indexOf(search);
                    if (index != -1) {
                        var value = text.substring(0, index);
                        value += '<span class="AutoComplete_ListItemHiliteText">';
                        value += text.substr(index, search.length);
                        value += '</span>';
                        value += text.substring(index + search.length);
                        list.childNodes[i].innerHTML = value;
                    }
                }
            }
        }

        function setAgreemenTypesForAutoCompleteContextKeys(autoCompleteID) {

            var context = $find(autoCompleteID)._contextKey;
            $find(autoCompleteID).set_contextKey(context);
        }

        function ShowSearchParameters() {
            var btnShowSearchResult = document.getElementById(btnShowSearchResultClientID);
            var cbNotShowSearchParameters = document.getElementById(cbNotShowSearchParametersClientID);

            var divSearchParameters = document.getElementById(divSearchParametersClientID);

            //also has height that we want to show/hide
            if (cbNotShowSearchParameters.checked == true) {
                //showing parameters div and shrinking grid
                cbNotShowSearchParameters.checked = false;
                btnShowSearchResult.src = "Images/btn_ShowSearchResultOpened.png";
                divSearchParameters.style.display = "inline";
            }
            else {
                //hiding parameters div and extending grid
                cbNotShowSearchParameters.checked = true;
                btnShowSearchResult.src = "Images/btn_ShowSearchResultClosed.png";
                divSearchParameters.style.display = "none";
            }

            AdjustGridsHieght();
        }

        function featuresForPopUp() {
            var topi = 50;
            var lefti = 100;
            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:400px; dialogheight:600px; help:no; status:no;";
            return features;
        }

        function SelectProfessions() {
            var url = "Public/SelectPopUp.aspx";

            var txtProfessionsListCodes = document.getElementById('<% = txtProfessionsListCodes.ClientID %>');
            var txtProfessionsList = document.getElementById('<%= txtProfessionsList.ClientID %>');
            var txtProfessionsList_ToCompare = document.getElementById(txtProfessionsList_ToCompareClientID);

            var SelectedProfessionsList = txtProfessionsListCodes.innerText;

//////////////////////////////
            //var txtQueueOrderCodes = document.getElementById(txtQueueOrderCodesClientID);
            //var txtQueueOrderCodes = document.getElementById(txtQueueOrderCodesClientID);
            //var SelectedCodesList = txtQueueOrderCodes.innerText;

            var url = "Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + txtProfessionsListCodes.value;
            url += "&popupType=20";
            url += "&returnValuesTo=txtProfessionsListCodes";
            url += "&returnTextTo=txtProfessionsList,txtProfessionsList_ToCompare";
            url += "&functionToExecute=SetProfessionCode";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר מקצוע";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetProfessionCode() {
            var txtProfessionCode = document.getElementById(txtProfessionCodeClientID);
            var txtProfessionsListCodes = document.getElementById('<% = txtProfessionsListCodes.ClientID %>');

            if (txtProfessionsListCodes.value.indexOf(',') > -1) {
                txtProfessionCode.value = '';
            }
            else {
                txtProfessionCode.value = txtProfessionsListCodes.value;
            }

            if (txtProfessionsListCodes.value != '') {
                DoSubmit();
            }
        }
        
        function SelectPopulations() {
            var txtPopulationsListCodes = document.getElementById('<% = txtPopulationsListCodes.ClientID %>');
            var txtPopulationsList = document.getElementById('<%= txtPopulationsList.ClientID %>');

            var url = "Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + txtPopulationsListCodes.value;
            url += "&popupType=22";
            url += "&returnValuesTo=txtPopulationsListCodes";
            url += "&txtPopulationsList";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר קבוצה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetOmriCodes() {
            var txtOmriCode = document.getElementById(txtOmriCodeClientID);
            var txtOmriCodeList = document.getElementById('<% = txtOmriCodeList.ClientID %>');

            if (txtOmriCodeList.value.indexOf(',') > -1) {
                txtOmriCode.value = '';
            }
            else {
                txtOmriCode.value = txtOmriCodeList.value;
            }

            if (txtOmriCodeList.value != '') {
                DoSubmit();
            }
        }

        function SelectOmriCodes() {

            var txtOmriCodeList = document.getElementById('<% = txtOmriCodeList.ClientID %>');
            var txtOmriDescList = document.getElementById('<%= txtOmriDescList.ClientID %>');
            var txtOmriDestList_ToCompare = document.getElementById(txtOmriDestList_ToCompareClientID);

            var url = "Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + txtOmriCodeList.value;
            url += "&popupType=23";
            url += "&returnValuesTo=txtOmriCodeList";
            url += "&returnTextTo=txtOmriDescList,txtOmriDestList_ToCompare";
            url += "&functionToExecute=SetOmriCodes";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר קוד החזר עומרי";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetICD9Codes() {
            var txtICD9Code = document.getElementById(txtICD9CodeClientID);
            var txtICD9CodeList = document.getElementById('<% = txtICD9CodeList.ClientID %>');

            if (txtICD9CodeList.value.indexOf(',') > -1) {
                txtICD9Code.value = '';
            }
            else {
                txtICD9Code.value = txtICD9CodeList.value;
            }

            if (txtICD9CodeList.value != '') {
                DoSubmit();
            }
        }

        function SelectICD9Codes() {

            var txtICD9CodeList = document.getElementById('<% = txtICD9CodeList.ClientID %>');
            var txtICD9DescList = document.getElementById(txtICD9DescClientID);
            var txtICD9Desc_ToCompare = document.getElementById(txtICD9Desc_ToCompareClientID);

            var url = "Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + txtICD9CodeList.value;
            url += "&popupType=26";//!!!!!!!!
            url += "&returnValuesTo=txtICD9CodeList";
            url += "&returnTextTo=txtICD9DescList,txtICD9Desc_ToCompare";
            url += "&functionToExecute=SetICD9Codes";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר קוד החזר ICD9";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectGroups() {
            var txtGroupsListCodes = document.getElementById(txtGroupsListCodesClientID);

            var url = "Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + txtGroupsListCodes.value;
            url += "&popupType=21";
            url += "&returnValuesTo=txtGroupsListCodes";
            url += "&returnTextTo=txtGroupsList,txtGroupsList_ToCompare";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "ניתן לבחור קבוצה אחת או יותר מהרשימה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function setSelectedHealthOfficeDesc(source, eventArgs) {
            var txtHealthOfficeDesc = document.getElementById('<% = txtHealthOfficeDesc.ClientID %>');
            var txtHealthOfficeCode = document.getElementById('<% = txtHealthOfficeCode.ClientID %>');
            var txtHealthOfficeDesc_ToCompare = document.getElementById('<% = txtHealthOfficeDesc_ToCompare.ClientID %>');

            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(";");

            txtHealthOfficeCode.value = valuesArr[0];
            txtHealthOfficeDesc.value = valuesArr[1];
            txtHealthOfficeDesc_ToCompare.value = valuesArr[1];
        }

        function setSelectedGroupDesc(source, eventArgs) {
            var txtGroupCode = document.getElementById('<% = txtGroupCode.ClientID %>');
            var txtGroupsList = document.getElementById('<% = txtGroupsList.ClientID %>');
            var txtGroupsListCodes = document.getElementById('<% = txtGroupsListCodes.ClientID %>');
            var txtGroupsList_ToCompare = document.getElementById('<% = txtGroupsList_ToCompare.ClientID %>');

            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(";");

            txtGroupsList.value = valuesArr[0];
            txtGroupsList_ToCompare.value = valuesArr[0];

            txtGroupCode.value = valuesArr[1];
            txtGroupsListCodes.value = "";
        }

        function setSelectedProfessionDesc(source, eventArgs) {
            var txtProfessionCode = document.getElementById('<% = txtProfessionCode.ClientID %>');
            var txtProfessionsList = document.getElementById('<% = txtProfessionsList.ClientID %>');
            var txtProfessionsListCodes = document.getElementById('<% = txtProfessionsListCodes.ClientID %>');
            var txtProfessionsList_ToCompare = document.getElementById('<% = txtProfessionsList_ToCompare.ClientID %>');

            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(";");

            txtProfessionsList.value = valuesArr[0];
            txtProfessionsList_ToCompare.value = valuesArr[0];

            txtProfessionCode.value = valuesArr[1];
            txtProfessionsListCodes.value = "";
        }

        function setSelectedOmriDesc(source, eventArgs) {
            var txtOmriCode = document.getElementById('<% = txtOmriCode.ClientID %>');
            var txtOmriCodeList = document.getElementById('<% = txtOmriCodeList.ClientID %>');
            var txtOmriDescList = document.getElementById('<% = txtOmriDescList.ClientID %>');
            var txtOmriDescList_ToCompare = document.getElementById('<% = txtOmriDescList_ToCompare.ClientID %>');

            var values = eventArgs.get_value();
            if (values == null) return;

            var valuesArr = values.split(";");

            txtOmriDescList.value = valuesArr[0];
            txtOmriDescList_ToCompare.value = valuesArr[0];

            txtOmriCode.value = valuesArr[1];
            txtOmriCodeList.value = "";
        }

        function setSelectedICD9Desc(source, eventArgs) {
            var txtICD9Desc = document.getElementById(txtICD9DescClientID);
            var txtICD9Code = document.getElementById(txtICD9CodeClientID);

            var values = eventArgs.get_value();
            if (values == null) return;

            var valuesArr = values.split(";");

            txtICD9Code.value = valuesArr[0];
            txtICD9Desc.value = valuesArr[1];
        }

        function setSelectedClalitServiceDesc(source, eventArgs) {
            var txtClalitServiceCode = document.getElementById('<% = txtClalitServiceCode.ClientID %>');
            var txtClalitServiceDesc = document.getElementById('<% = txtClalitServiceDesc.ClientID %>');
            var txtClalitServiceDesc_ToCompare = document.getElementById('<% = txtClalitServiceDesc_ToCompare.ClientID %>');

            var values = eventArgs.get_value();
            if (values == null) return;
            var valuesArr = values.split(",");

            var text = eventArgs.get_text();

            txtClalitServiceCode.value = valuesArr[0];
            txtClalitServiceDesc.value = valuesArr[1];
            txtClalitServiceDesc_ToCompare.value = valuesArr[1];
        }

        function SetDateControls() {
            var checkedValue = $('#<%=rbConditions.ClientID %> input[type=radio]:checked').val();
            var txtFromDate = document.getElementById('<% = txtFromDate.ClientID %>');
            var txtToDate = document.getElementById('<% = txtToDate.ClientID %>');

            var btnRunCalendar_FromDate = document.getElementById('<% = btnRunCalendar_FromDate.ClientID %>');
            var btnRunCalendar_ToDate = document.getElementById('<% = btnRunCalendar_ToDate.ClientID %>');

            if (checkedValue == 'CurrentDay') {

                txtFromDate.disabled = true;
                txtFromDate.value = '';
                txtToDate.disabled = true;
                txtToDate.value = '';

                btnRunCalendar_FromDate.disabled = true;
                btnRunCalendar_ToDate.disabled = true;

                //btnRunCalendar_FromDate.style.display = "none";

            }
            else {
                txtFromDate.disabled = false;
                txtToDate.disabled = false;
                btnRunCalendar_FromDate.disabled = false;
                btnRunCalendar_ToDate.disabled = false;

                // btnRunCalendar_FromDate.style.display = "block";                                         
            }

        }

        function ClearClalitServiceDesc() {
            if (document.getElementById(txtServiceDest_ToCompareClientID).value != document.getElementById(txtServiceDescClientID).value) {
                document.getElementById(txtServiceDest_ToCompareClientID).value = "";
                document.getElementById(txtServiceDescClientID).value = "";
                document.getElementById(txtServiceCodeClientID).value = "";
            }
        }

        function ClearHealthOffice() {
            if (document.getElementById(txtHealthOfficeDest_ToCompareClientID).value != document.getElementById(txtHealthOfficeDescClientID).value) {
                document.getElementById(txtHealthOfficeDest_ToCompareClientID).value = "";
                document.getElementById(txtHealthOfficeDescClientID).value = "";
                document.getElementById(txtHealthOfficeCodeClientID).value = "";
            }
        }

        function ClearICD9() {
            if (document.getElementById(txtICD9Desc_ToCompareClientID).value != document.getElementById(txtICD9DescClientID).value) {
                document.getElementById(txtICD9Desc_ToCompareClientID).value = "";
                document.getElementById(txtICD9DescClientID).value = "";
                document.getElementById(txtICD9CodeClientID).value = "";
            }
        }

        // "Groups" management functions
        function ClearGroupList() {
            if (document.getElementById(txtGroupsList_ToCompareClientID).value != document.getElementById(txtGroupsListClientID).value) {
                document.getElementById(txtGroupsList_ToCompareClientID).value = "";
                document.getElementById(txtGroupsListClientID).value = "";
                document.getElementById(txtGroupsListCodesClientID).value = "";
                document.getElementById(txtGroupCodeClientID).value = "";
            }
        }

        function SyncronizeGroupList() {
            document.getElementById(txtGroupsList_ToCompareClientID).value = document.getElementById(txtGroupsListClientID).value;
        }

        // "Professions" management functions
        function ClearProfessionsList() {
            if (document.getElementById(txtProfessionsList_ToCompareClientID).value != document.getElementById(txtProfessionsListClientID).value) {
                document.getElementById(txtProfessionsList_ToCompareClientID).value = "";
                document.getElementById(txtProfessionsListClientID).value = "";
                document.getElementById(txtProfessionCodeClientID).value = "";
                document.getElementById(txtProfessionsListCodesClientID).value = "";
            }
        }

        function SyncronizeProfessionsList() {
            document.getElementById(txtProfessionsList_ToCompareClientID).value = document.getElementById(txtProfessionsListClientID).value;
        }

        // "Omri" management functions
        function ClearOmriList() {
            if (document.getElementById(txtOmriDestList_ToCompareClientID).value != document.getElementById(txtOmriDescListClientID).value) {
                document.getElementById(txtOmriDestList_ToCompareClientID).value = "";
                document.getElementById(txtOmriDescListClientID).value = "";
                document.getElementById(txtOmriCodeListClientID).value = "";
                document.getElementById(txtOmriCodeClientID).value = "";
            }
        }

        function SyncronizeOmriList() {
            document.getElementById(txtOmriDestList_ToCompareClientID).value = document.getElementById(txtOmriDescListClientID).value;
        }

        // "Populations" management functions
        function ClearPopulationsList() {
            if (document.getElementById(txtPopulationsList_ToCompareClientID).value != document.getElementById(txtPopulationsListClientID).value) {
                document.getElementById(txtPopulationsList_ToCompareClientID).value = "";
                document.getElementById(txtPopulationsListClientID).value = "";
                document.getElementById(txtPopulationsListCodesClientID).value = "";
            }
        }

        function SyncronizePopulationsList() {
            document.getElementById(txtPopulationsList_ToCompareClientID).value = document.getElementById(txtPopulationsListClientID).value;
        }

        function GridsTabClick() {

        }

        function showProgressBar() {
            document.getElementById("divProgressBar").style.visibility = "visible";
        }

        function hideProgressBar() {
            document.getElementById("divProgressBar").style.visibility = "hidden";
        }

        function refreshPage() {
            var loc = document.location.href.split("?")[0];
            document.location.href = loc;
        }

        // Global timer settings
        var AutoCompleteTimer = 700;

        /***** ClalitServiceCode AutoComplete service settings - Start *****/
        var wasKeyPressed_ClalitServiceCode = false;

        function ClalitServiceCode_AutoCompleteService() {
            if (wasKeyPressed_ClalitServiceCode == true) {
                wasKeyPressed_ClalitServiceCode = false;
                setTimeout('ClalitServiceCode_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('ClalitServiceCode_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('ClalitServiceCode_AutoCompleteService()', AutoCompleteTimer);

        function ClalitServiceCode_AutoComplete() {
            if (wasKeyPressed_ClalitServiceCode == true) {
                // From the last request a new text change has been made to clalit service code textbox - retry to autocomplete the description again in 1 sec.
                wasKeyPressed_ClalitServiceCode = false;
            }

            // Do the autocomplete here!
            var serviceCode = document.getElementById(txtServiceCodeClientID).value;
            PageMethods.ClalitServiceCode_AutoComplete(serviceCode, OnSucceeded_ClalitServiceCode, OnFailed);
        }

        function OnSucceeded_ClalitServiceCode(result, userContext, methodName) {
            if (result != '') {
                document.getElementById(txtServiceDescClientID).value = result;
                document.getElementById(txtServiceDest_ToCompareClientID).value = result;
            }
            else {
                document.getElementById(txtServiceDescClientID).value = '';
                document.getElementById(txtServiceDest_ToCompareClientID).value = '';
            }
        }

        /***** ClalitServiceCode AutoComplete service settings - End *****/

        /***** HealthOfficeCode AutoComplete service settings - Start *****/
        var wasKeyPressed_HealthOfficeCode = false;

        function HealthOfficeCode_AutoCompleteService() {
            if (wasKeyPressed_HealthOfficeCode == true) {
                wasKeyPressed_HealthOfficeCode = false;
                setTimeout('HealthOfficeCode_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('HealthOfficeCode_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('HealthOfficeCode_AutoCompleteService()', AutoCompleteTimer);

        function HealthOfficeCode_AutoComplete() {
            if (wasKeyPressed_HealthOfficeCode == true) {
                // From the last request a new text change has been made to the health office code textbox - retry to autocomplete the description again in 1 sec.
                wasKeyPressed_HealthOfficeCode = false;
            }

            // Do the autocomplete here!
            var healthOfficeCode = document.getElementById(txtHealthOfficeCodeClientID).value;
            PageMethods.HealthOfficeCode_AutoComplete(healthOfficeCode, OnSucceeded_HealthOfficeCode, OnFailed);
        }

        function OnSucceeded_HealthOfficeCode(result, userContext, methodName) {
            if (result != '') {
                document.getElementById(txtHealthOfficeDescClientID).value = result;
                document.getElementById(txtHealthOfficeDest_ToCompareClientID).value = result;
            }
            else {
                document.getElementById(txtHealthOfficeDescClientID).value = '';
                document.getElementById(txtHealthOfficeDest_ToCompareClientID).value = '';
            }
        }

        /***** HealthOfficeCode AutoComplete service settings - End *****/

        /***** GroupCode AutoComplete service settings - Start *****/
        var wasKeyPressed_GroupCode = false;

        function GroupCode_AutoCompleteService() {
            if (wasKeyPressed_GroupCode == true) {
                wasKeyPressed_GroupCode = false;
                setTimeout('GroupCode_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('GroupCode_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('GroupCode_AutoCompleteService()', AutoCompleteTimer);

        function GroupCode_AutoComplete() {
            if (wasKeyPressed_GroupCode == true) {
                // From the last request a new text change has been made to the group code textbox - retry to autocomplete the description again in <AutoCompleteTimer> mili seconds.
                wasKeyPressed_GroupCode = false;
            }

            // Do the autocomplete here!
            var groupCode = document.getElementById(txtGroupCodeClientID).value;
            PageMethods.GroupCode_AutoComplete(groupCode, OnSucceeded_GroupCode, OnFailed);
        }

        function OnSucceeded_GroupCode(result, userContext, methodName) {
            var groupCode = document.getElementById(txtGroupCodeClientID).value;

            if (result != '') {
                // The result is not empty therefore the autocomplete request passed successfully.
                document.getElementById(txtGroupsListClientID).value = result;
                document.getElementById(txtGroupsList_ToCompareClientID).value = result;
                document.getElementById(txtGroupsListCodesClientID).value = groupCode;
            }
            else {
                document.getElementById(txtGroupsListClientID).value = '';
                document.getElementById(txtGroupsList_ToCompareClientID).value = '';
                document.getElementById(txtGroupsListCodesClientID).value = '';
            }
        }

        /***** GroupCode AutoComplete service settings - End *****/

        /***** ProfessionCode AutoComplete service settings - Start *****/
        var wasKeyPressed_ProfessionCode = false;

        function ProfessionCode_AutoCompleteService() {
            if (wasKeyPressed_ProfessionCode == true) {
                wasKeyPressed_ProfessionCode = false;
                setTimeout('ProfessionCode_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('ProfessionCode_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('ProfessionCode_AutoCompleteService()', AutoCompleteTimer);

        function ProfessionCode_AutoComplete() {
            if (wasKeyPressed_ProfessionCode == true) {
                // From the last request a new text change has been made to the profession code textbox - retry to autocomplete the description again in <AutoCompleteTimer> mili seconds.
                wasKeyPressed_ProfessionCode = false;
            }

            // Do the autocomplete here!
            var professionCode = document.getElementById(txtProfessionCodeClientID).value;
            PageMethods.ProfessionCode_AutoComplete(professionCode, OnSucceeded_ProfessionCode, OnFailed);
        }

        function OnSucceeded_ProfessionCode(result, userContext, methodName) {
            var professionCode = document.getElementById(txtProfessionCodeClientID).value;

            if (result != '') {
                // The result is not empty therefore the autocomplete request passed successfully.
                document.getElementById(txtProfessionsListClientID).value = result;
                document.getElementById(txtProfessionsList_ToCompareClientID).value = result;
                document.getElementById(txtProfessionsListCodesClientID).value = professionCode;
            }
            else {
                document.getElementById(txtProfessionsListClientID).value = '';
                document.getElementById(txtProfessionsList_ToCompareClientID).value = '';
                document.getElementById(txtProfessionsListCodesClientID).value = '';
            }
        }

        /***** ProfessionCode AutoComplete service settings - End *****/

        /***** OmriCode AutoComplete service settings - Start *****/
        var wasKeyPressed_OmriCode = false;

        function OmriCode_AutoCompleteService() {
            if (wasKeyPressed_OmriCode == true) {
                wasKeyPressed_OmriCode = false;
                setTimeout('OmriCode_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('OmriCode_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('OmriCode_AutoCompleteService()', AutoCompleteTimer);

        function OmriCode_AutoComplete() {
            if (wasKeyPressed_OmriCode == true) {
                // From the last request a new text change has been made to the omri code textbox - retry to autocomplete the description again in <AutoCompleteTimer> mili seconds.
                wasKeyPressed_OmriCode = false;
            }

            // Do the autocomplete here!
            var omriCode = document.getElementById(txtOmriCodeClientID).value;
            PageMethods.OmriCode_AutoComplete(omriCode, OnSucceeded_OmriCode, OnFailed);
        }

        function OnSucceeded_OmriCode(result, userContext, methodName) {
            var omriCode = document.getElementById(txtOmriCodeClientID).value;

            if (result != '') {
                // The result is not empty therefore the autocomplete request passed successfully.
                document.getElementById(txtOmriDescListClientID).value = result;
                document.getElementById(txtOmriDestList_ToCompareClientID).value = result;
                document.getElementById(txtOmriCodeListClientID).value = omriCode;
            }
            else {
                document.getElementById(txtOmriDescListClientID).value = '';
                document.getElementById(txtOmriDestList_ToCompareClientID).value = '';
                document.getElementById(txtOmriCodeListClientID).value = '';
            }
        }

        /***** OmriCode AutoComplete service settings - End *****/

        /***** ICD9Code AutoComplete service settings - Start *****/
        var wasKeyPressed_ICD9Code = false;

        function ICD9Code_AutoCompleteService() {
            if (wasKeyPressed_ICD9Code == true) {
                wasKeyPressed_ICD9Code = false;
                setTimeout('ICD9Code_AutoComplete()', AutoCompleteTimer);
            }

            setTimeout('ICD9Code_AutoCompleteService()', AutoCompleteTimer);
        }

        setTimeout('ICD9Code_AutoCompleteService()', AutoCompleteTimer);

        function ICD9Code_AutoComplete() {
            if (wasKeyPressed_ICD9Code == true) {
                // From the last request a new text change has been made to the icd9 code textbox - retry to autocomplete the description again in 1 sec.
                wasKeyPressed_ICD9Code = false;
            }

            // Do the autocomplete here!
            var icd9Code = document.getElementById(txtICD9CodeClientID).value;
            PageMethods.ICD9Code_AutoComplete(icd9Code, OnSucceeded_ICD9Code, OnFailed);
        }

        function OnSucceeded_ICD9Code(result, userContext, methodName) {
            if (result != '') {
                document.getElementById(txtICD9DescClientID).value = result;
                document.getElementById(txtICD9Desc_ToCompareClientID).value = result;
            }
            else {
                document.getElementById(txtICD9DescClientID).value = '';
                document.getElementById(txtICD9Desc_ToCompareClientID).value = '';
            }
        }

        /***** ICD9Code AutoComplete service settings - End *****/

        function OnFailed(error, userContext, methodName) {
            if (error !== null) {
                alert("An error occurred: " + error.get_message());
            }
        }

        var idOfdivGridServices = '<%= pServicesGrid.ClientID %>';
        var idOfdivGridPopulations = '<%= pPopulationsGrid.ClientID %>';
        var idOfdivGridPopulationsHeaderGrid = '<%= pPopulationsHeaderGrid.ClientID %>';

        function AdjustGridsHieght() {
            if (document.getElementById(idOfdivGridServices)) {
                setTimeout('StretchElementHeightToBottomAccordingToScreenCommon(idOfdivGridServices)', 500);
            }

            if (document.getElementById(idOfdivGridPopulations)) {
                setTimeout('StretchElementHeightToBottomAccordingToScreenCommon(idOfdivGridPopulations)', 500);
            }

        }

        function StretchElementHeightToBottomAccordingToScreenCommon(elemId) {
            var elem = document.getElementById(elemId);
            var dynamicTopHeight = 50;

            /* Changing acording to the screen resolution */
            if (window.screen.height == 600)
                dynamicTopHeight = 65;
            if (elem != null) {
                var hi = window.screen.availHeight - getElementPosition(elemId).top - window.screenTop - dynamicTopHeight; //hard coded - the bottom tool bar ( I don't know how to find its height programmatically )

                var newHeight = hi.toString() + 'px';
                if (newHeight != elem.style.height) {
                    if (elemId.indexOf('population') > -1) {
                        document.getElementById(idOfdivGridPopulationsHeaderGrid).style.paddingTop = '20px';
                    }

                    elem.style.height = newHeight;
                }
            }
        }

        function getElementPosition(elemID) {
            var offsetTrail = document.getElementById(elemID);
            var offsetLeft = 0;
            var offsetTop = 0;
            while (offsetTrail) {
                offsetLeft += offsetTrail.offsetLeft;
                offsetTop += offsetTrail.offsetTop;
                offsetTrail = offsetTrail.offsetParent;
            }
            if (navigator.userAgent.indexOf('Mac') != -1 && typeof document.body.leftMargin != 'undefined') {
                offsetLeft += document.body.leftMargin;
                offsetTop += document.body.topMargin;
            }
            return { left: offsetLeft, top: offsetTop };
        }

        function ValidateNumericPress(evt) {
            var theEvent = evt || window.event;
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode(key);
            var regex = /[0-9]|\./;
            if (!regex.test(key)) {
                theEvent.returnValue = false;
                if (theEvent.preventDefault) theEvent.preventDefault();
            }
        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">
    <div style="width: 980px; background: url('Images/GradientVerticalBlueAndWhite.jpg');
        background-repeat: repeat-x">
        <%-- BEGIN all  Search buttons clinic,doctors,events and buttons to show hide parts in the page --%>
        <cc1:ModalPopupExtender ID="modalPopupGrayScreen" runat="server" TargetControlID="btnOpenModalPopup"
            PopupControlID="divGrayScreen" BackgroundCssClass="divPopup">
        </cc1:ModalPopupExtender>
        <div style="display: none;">
            <asp:Button ID="btnOpenModalPopup" runat="server" />
        </div>
        <div id="divGrayScreen" runat="server" style="position: absolute; display: none;
            width: 100%; height: 100%; z-index: 15000">
        </div>
        <%-- BEGIN all  Search buttons clinic,doctors,events and buttons to show hide parts in the page --%>
        <asp:Panel ID="pnlMain" runat="server" DefaultButton="btnSubmit">
            <table dir="rtl" cellpadding="0" cellspacing="0" style="background-image: url('Images/GradientVerticalBlueAndWhite.jpg');background-repeat: repeat-x;">
                <%-- BEGIN all  Search buttons clinic,doctors,events and buttons to show hide parts in the page --%>
                <tr>
                    <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
                        <table cellpadding="0" cellspacing="0" width="1200px">
                            <tr>
                                <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; background-image: url('Images/GradientVerticalWhiteBlueBottomBorder.jpg');
                                    background-position: bottom; background-repeat: repeat-x;">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td style="width: 10px; height: 25px; background-image: url('Images/GradientVerticalWhiteBlueBottomBorder.jpg');
                                                background-position: bottom; background-repeat: repeat-x;">
                                            </td>
                                            <td id="tdClinicTab" runat="server" valign="bottom" align="center">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td runat="server" id="tdClinicInnerTdRight">
                                                        </td>
                                                        <td valign="top" runat="server" id="tdClinicInnerTdMiddle">
                                                            <a id="aSearchClinics" runat="server" target="_parent" href="SearchClinics.aspx">חיפוש
                                                                יחידות ושירותים</a>
                                                        </td>
                                                        <td runat="server" id="tdClinicInnerTdLeft">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td id="tdDoctorTab" runat="server" valign="bottom" align="center">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td runat="server" id="tdDoctorInnerTdRight">
                                                        </td>
                                                        <td valign="top" runat="server" id="tdDoctorInnerTdMiddle">
                                                            <a id="aSearchDoctors" runat="server" href="SearchDoctors.aspx" target="_parent">חיפוש
                                                                נותני שירות</a>
                                                        </td>
                                                        <td runat="server" id="tdDoctorInnerTdLeft">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td id="tdSalServiceTab" runat="server" valign="bottom" align="center">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td runat="server" id="tdSalServicesInnerTdRight">
                                                        </td>
                                                        <td valign="top" runat="server" id="tdSalServicesInnerTdMiddle">
                                                            <a id="aSearchSalServices" runat="server" href="SearchSalServices.aspx" target="_parent">
                                                                חיפוש לפי סל שירותים</a>
                                                        </td>
                                                        <td runat="server" id="tdSalServicesInnerTdLeft">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                <%--<uc1:ModeSelector ID="lstSearchModes" runat="server" />--%>
                                            </td>
                                            <td>
                                                <input id="txtInputSearchModeValues" style="width: 50px" runat="server" class="DisplayNone" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td id="tdShowSearchResultButton" runat="server" align="left" style="background-image: url('Images/GradientVerticalWhiteBlueBottomBorder.jpg');
                                    background-position: bottom; background-repeat: repeat-x;">
                                    <asp:Image ID="btnShowSearchResult" runat="server" Style="cursor: pointer;" onclick="ShowSearchParameters();  return false;"
                                        src="Images/btn_ShowSearchResultOpened.png" />
                                    <asp:CheckBox ID="cbNotShowSearchParameters" runat="server" CssClass="DisplayNone"
                                        EnableTheming="false" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%-- END all  Search buttons clinic,doctors,events and buttons to show hide parts in the page --%>
                <%-- BEGIN  parameters panel - contains the parameter place holder and the reception time area --%>
                <tr>
                    <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
                        <table cellpadding="0" cellspacing="0" style="width: 1040px;">
                            <tr>
                                <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
                                    <asp:UpdatePanel ID="UpdatePanelTop" UpdateMode="Always" runat="server">
                                        <ContentTemplate>
                                            <asp:Button ID="btnPostUpdatePanelTop" runat="server" Text="Button" CssClass="DisplayNone" />
                                            <div id="divSearchParameters" runat="server" style="padding-top: 6px">
                                                <table id="tblSearchParameters" cellpadding="0" cellspacing="0" style="width:100%">
                                                    <tr>
                                                        <td style="white-space: nowrap; padding-right: 10px" align="right" dir="rtl" colspan="2">
                                                            <asp:Label ID="lblSalIncluded" runat="server" Text="בסל "></asp:Label>
                                                                <asp:DropDownList ID="ddlSalIncluded" runat="server">
                                                                    <asp:ListItem Text="הכל" Value="4" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="בסל" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="בסל + בסל מוגבל" Value="2"></asp:ListItem>
                                                                    <asp:ListItem Text="בסל מוגבל" Value="3"></asp:ListItem>
                                                                    <asp:ListItem Text="לא בסל" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="lblCommon" runat="server" Text=" שכיח "></asp:Label><asp:DropDownList 
                                                                runat="server" ID="ddlCommon">
                                                                    <asp:ListItem Text="הכל" Value="3" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList><%--<asp:Label ID="lblLimiter" runat="server" Text="הערות הגבלה " Width="42px" style="white-space:normal !important;position:relative;top:6px;padding-right:4px" ToolTip="הערות הגבלה"></asp:Label>
                                                                <asp:DropDownList ID="ddlLimiter" runat="server" ToolTip="הערות הגבלה">
                                                                    <asp:ListItem Text="הכל" Value="3" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>--%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="lblInternet" runat="server" Text="אינטרנט " ToolTip="אינטרנט" style="padding-right:4px"></asp:Label>
                                                                <asp:DropDownList ID="ddlInternet" runat="server" ToolTip="אינטרנט">
                                                                    <asp:ListItem Text="הכל" Value="3" Selected="True"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>
                                                                <div style="overflow: hidden; width: 105px; height: 20px; float: left;">
                                                                    <a href="http://homenew.clalit.org.il/sites/Communities/masabey enosh/hathum/lemida/DocLib1/סל השירותים/story.html"  target="_blank"><img src="Images/btn_InstructionalVideo.png" border="none" style="padding:0px 0px 0px 0px" /></a>
                                                                </div>
                                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="lblIsActive" runat="server" Text="מבוטל " ToolTip="פעיל" style="padding-right:4px"></asp:Label>
                                                                <asp:DropDownList ID="ddlIsActive" runat="server" ToolTip="מבוטל">
                                                                    <asp:ListItem Text="הכל" Value="3"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="0"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="1" Selected="True"></asp:ListItem>
                                                                </asp:DropDownList>

                                                        </td>
                                                        <td rowspan="9" valign="top" style="padding-right: 2px;" align="left">
                                                            <div style="padding: 5px 5px 5px 5px; border: 1px solid #888888;text-align:right; width: 170px">
                                                                <div style="float: right; padding: 0px 0px 0px 0px; width: 175px;">
                                                                    <asp:RadioButtonList ID="rbConditions" runat="server" CssClass="RegularLabel" EnableTheming="false" onclick="SetDateControls()"></asp:RadioButtonList>
                                                                </div>
                                                                <div style="float: right; padding: 0px 0px 0px 0px; width: 172px; display:none">
                                                                    <asp:CheckBox ID="cbCurrentDay" CssClass="RegularLabel" runat="server" Text="נכון להיום"
                                                                        Checked="true" onclick="cbCurrentDayClick(this)" />
                                                                    <div style="display: inline; padding-left: 20px">
                                                                        <asp:CheckBox ID="cbAll" CssClass="RegularLabel" runat="server" Text="בחר הכל" onclick="cbShowAllClick(this)" />
                                                                    </div>
                                                                </div>
                                                                <div style="width:172px">
                                                                    <asp:Label ID="lblFrom" runat="server" Text="מ" Width="15px"></asp:Label>
                                                                    <asp:TextBox ID="txtFromDate" runat="server" Width="80px"></asp:TextBox>
                                                                    <asp:ImageButton ID="btnRunCalendar_FromDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                        meta:resourcekey="btnRunCalendarResource2" />
                                                                    <cc1:MaskedEditValidator ID="FromDateValidator" runat="server" ControlExtender="FromDateExtender"
                                                                        ControlToValidate="txtFromDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                                                        InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" ValidationGroup="vldGrAdd" />
                                                                    <cc1:CalendarExtender ID="calExtFromDate" runat="server" Enabled="True"
                                                                        FirstDayOfWeek="Sunday" Format="dd/MM/yyyy" PopupButtonID="btnRunCalendar_FromDate" 
                                                                        PopupPosition="BottomRight" TargetControlID="txtFromDate">
                                                                    </cc1:CalendarExtender>
                                                                    <cc1:MaskedEditExtender ID="FromDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                                                        Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="txtFromDate">
                                                                    </cc1:MaskedEditExtender>
                                                                </div>
                                                                <div>
                                                                    <asp:Label ID="lblUntil" runat="server" Text="עד" Width="15px"></asp:Label>
                                                                    <asp:TextBox ID="txtToDate" runat="server" Width="80px"></asp:TextBox>
                                                                    <asp:ImageButton ID="btnRunCalendar_ToDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                        meta:resourcekey="btnRunCalendarResource2" />
                                                                    <cc1:MaskedEditValidator ID="ToDateValidator" runat="server" ControlExtender="ToDateExtender"
                                                                        ControlToValidate="txtToDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                                                        InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" ValidationGroup="vldGrAdd" />
                                                                    <cc1:CalendarExtender ID="calExtToDate" runat="server" Enabled="True" FirstDayOfWeek="Sunday"
                                                                        Format="dd/MM/yyyy" PopupButtonID="btnRunCalendar_ToDate"
                                                                        PopupPosition="BottomRight" TargetControlID="txtToDate">
                                                                    </cc1:CalendarExtender>
                                                                    <cc1:MaskedEditExtender ID="ToDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                                                        Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="txtToDate">
                                                                    </cc1:MaskedEditExtender>
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="height: 5px;">
                                                        </td>
                                                        <td style="height: 5px; width: 420px">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div style="float: right; margin-right: 10px; width: 112px;">
                                                                <asp:Label ID="lblAdvanceSearch" runat="server" Text="חיפוש מורחב"></asp:Label></div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="206px" Height="20px" ID="txtExtendedSearch" runat="server"></asp:TextBox></div>
                                                        </td>
                                                        <td style="width: 420px">
                                                            <div style="float: right; margin-right: 30px; width: 60px;">
                                                                <asp:Label ID="lblProffession" runat="server" Text="מקצוע"></asp:Label>
                                                            </div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="50px" Height="20px" ID="txtProfessionCode" runat="server" onkeydown="wasKeyPressed_ProfessionCode=true;"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; margin-right: 1px;">
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtProfessionsList" runat="server" 
                                                                    onfocus="SyncronizeProfessionsList();setAgreemenTypesForAutoCompleteContextKeys('acProfessionDesc');" onchange="ClearProfessionsList();"></asp:TextBox>
                                                                <cc1:AutoCompleteExtender runat="server" ID="AutoProfessionDesc" TargetControlID="txtProfessionsList"
                                                                    BehaviorID="acProfessionDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                                    ServiceMethod="GetProfessionsByName" MinimumPrefixLength="2" CompletionInterval="500"
                                                                    CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedProfessionDesc"
                                                                    OnClientPopulated="CommonClientPopulated" />
                                                                <asp:TextBox ID="txtProfessionsList_ToCompare" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                <asp:TextBox ID="txtProfessionsListCodes" runat="server" Style="display: none"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; padding-top:2px">
                                                                <asp:ImageButton ID="ibPrefessionDesc" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                                                    OnClientClick="SelectProfessions();" Visible="true" style="position:relative;left:-4px" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="height: 4px;">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div style="float: right; width: 112px; margin-right: 10px;">
                                                                <asp:Label ID="Label7" runat="server" Text="שירות משה''ב"></asp:Label>
                                                            </div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="50px" Height="20px" ID="txtHealthOfficeCode" MaxLength="5" onkeydown="wasKeyPressed_HealthOfficeCode=true;" runat="server"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; margin-right: 1px;">
                                                                <asp:TextBox Height="20px" Width="150px" ID="txtHealthOfficeDesc" runat="server"
                                                                    onfocus="setAgreemenTypesForAutoCompleteContextKeys('acHealthOfficeDesc');" onchange="ClearHealthOffice();"></asp:TextBox>
                                                                <cc1:AutoCompleteExtender runat="server" ID="AutoHealthOfficeDesc" TargetControlID="txtHealthOfficeDesc"
                                                                    BehaviorID="acHealthOfficeDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                                    ServiceMethod="GetHealthOfficeDesc" MinimumPrefixLength="2" CompletionInterval="500"
                                                                    CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedHealthOfficeDesc"
                                                                    OnClientPopulated="CommonClientPopulated" />
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtHealthOfficeDesc_ToCompare" runat="server" style="display:none"></asp:TextBox>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div style="float: right; margin-right: 30px; width: 60px;">
                                                                <asp:Label ID="lblOmriCodeText" Style="line-height: 8px;" runat="server" Text="עומרי החזר"></asp:Label>
                                                            </div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="50px" Height="20px" ID="txtOmriCode" runat="server" onkeydown="wasKeyPressed_OmriCode=true;"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; margin-right: 1px;">
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtOmriDescList"
                                                                    onfocus="SyncronizeOmriList();setAgreemenTypesForAutoCompleteContextKeys('acOmriDesc');" onchange="ClearOmriList();" runat="server"></asp:TextBox>
                                                                <cc1:AutoCompleteExtender runat="server" ID="AutoOmriDesc" TargetControlID="txtOmriDescList"
                                                                    BehaviorID="acOmriDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                                    ServiceMethod="GetOmriCodesByName" MinimumPrefixLength="2" CompletionInterval="500"
                                                                    CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedOmriDesc"
                                                                    OnClientPopulated="CommonClientPopulated" />
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtOmriDescList_ToCompare" runat="server" style="display:none"></asp:TextBox>
                                                                <asp:TextBox ID="txtOmriCodeList" runat="server" Style="display: none"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; padding-top:2px;">
                                                                <asp:ImageButton ID="ibOmriCode" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                                                    OnClientClick="SelectOmriCodes();" style="position:relative;left:-4px" Visible="true" />
                                                            </div>
                                                            
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="height: 4px;">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div style="float: right; width: 112px; margin-right: 10px;">
                                                                <asp:Label ID="Label5" runat="server" Text="שירות כללית"></asp:Label>
                                                            </div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="50px" Height="20px" ID="txtClalitServiceCode" onkeydown="wasKeyPressed_ClalitServiceCode=true;" onkeypress='ValidateNumericPress(event)' MaxLength="5" runat="server"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; margin-right: 1px;">
                                                                <asp:TextBox Height="20px" Width="150px" ID="txtClalitServiceDesc" runat="server"
                                                                    onfocus="setAgreemenTypesForAutoCompleteContextKeys('acClalitServiceDesc');" onchange="ClearClalitServiceDesc();" ></asp:TextBox>
                                                                <cc1:AutoCompleteExtender runat="server" ID="AutoClalitServiceDesc" TargetControlID="txtClalitServiceDesc"
                                                                    BehaviorID="acClalitServiceDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                                    ServiceMethod="GetServiceCodesForSalServices" MinimumPrefixLength="2" CompletionInterval="500"
                                                                    CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedClalitServiceDesc"
                                                                    OnClientPopulated="CommonClientPopulated" />
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtClalitServiceDesc_ToCompare" runat="server" style="display:none"></asp:TextBox>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div style="float: right; margin-right: 30px; width: 60px;">
                                                                <asp:Label ID="Label8" runat="server" Text="ICD9"></asp:Label>
                                                            </div>
                                                            <div style="float: right;">
                                                                <asp:TextBox Width="50px" Height="20px" ID="txtICD9Code" runat="server" onkeydown="wasKeyPressed_ICD9Code=true;" ></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; margin-right: 1px;">
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtICD9Desc" runat="server" onchange="ClearICD9();" onfocus="setAgreemenTypesForAutoCompleteContextKeys('acICD9Desc');"></asp:TextBox>
                                                                <cc1:AutoCompleteExtender runat="server" ID="AutoICD9Desc" TargetControlID="txtICD9Desc"
                                                                    BehaviorID="acICD9Desc" ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetICD9Desc"
                                                                    MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle2"
                                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle2"
                                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyleWidth278" OnClientItemSelected="setSelectedICD9Desc"
                                                                    OnClientPopulated="CommonClientPopulated" />
                                                                <asp:TextBox Height="20px" Width="220px" ID="txtICD9Desc_ToCompare" runat="server" style="display:none"></asp:TextBox>
                                                                <asp:TextBox ID="txtICD9CodeList" runat="server" Style="display: none"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; padding-top:2px;">
                                                                <asp:ImageButton ID="ibICD9Codes" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                                                    OnClientClick="SelectICD9Codes();" style="position:relative;left:-4px" Visible="true" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="height: 4px;">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding:0px; margin:0px">
                                                        <table>
                                                            <tr>
                                                                <td style="padding:0px; margin:0px">
                                                                <asp:PlaceHolder runat="server" ID="phInternetDetails1" Visible="false">
                                                                    <div style="float: right; width: 112px; margin-right: 10px;">
                                                                        <asp:Label ID="lblSalCategory" runat="server" Text="תחום"></asp:Label>
                                                                    </div>
                                                                    <div style="float: right;">
                                                                        <asp:DropDownList Width="150px" runat="server" ID="ddlSalCategory" DataTextField="SalCategoryDescription" DataValueField="SalCategoryID"></asp:DropDownList>
                                                                    </div>
                                                                </asp:PlaceHolder>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="padding:0px; margin:0px">
                                                                <asp:PlaceHolder runat="server" ID="phInternetDetails2" Visible="false">
                                                                    <div style="float: right; width: 112px; margin-right: 10px;">
                                                                        <asp:Label ID="lblBodyOrgan" runat="server" Text="איבר בגוף"></asp:Label>
                                                                    </div>
                                                                    <div style="float: right; margin-top:3px">
                                                                        <asp:DropDownList Width="150px" runat="server" ID="ddlBodyOrgan" DataTextField="OrganName" DataValueField="SalOrganCode"></asp:DropDownList>
                                                                    </div>
                                                                </asp:PlaceHolder>
                                                                </td>
                                                            </tr>
                                                        </table>


                                                        </td>
                                                        <td style="vertical-align:top;display:none">
                                                                <div style="float: right; margin-right: 30px; width: 60px;"">
                                                                    <asp:Label ID="lblGroupName" runat="server" Text="קבוצה"></asp:Label>
                                                                </div>
                                                                <div style="float: right;">
                                                                    <asp:TextBox Width="50px" Height="20px" ID="txtGroupCode" runat="server" onkeydown="wasKeyPressed_GroupCode=true;"></asp:TextBox>
                                                                </div>
                                                                <div style="float: right; margin-right: 1px;">
                                                                    <asp:TextBox Height="20px" Width="220px" ID="txtGroupsList" runat="server" 
                                                                        onfocus="SyncronizeGroupList();setAgreemenTypesForAutoCompleteContextKeys('acGroupDesc');" onchange="ClearGroupList();"></asp:TextBox>
                                                                    <cc1:AutoCompleteExtender runat="server" ID="AutoGroupDesc" TargetControlID="txtGroupsList"
                                                                        BehaviorID="acGroupDesc" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                                        ServiceMethod="GetGroupsByName" MinimumPrefixLength="2" CompletionInterval="500"
                                                                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                        CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="setSelectedGroupDesc"
                                                                        OnClientPopulated="CommonClientPopulated" />
                                                                    <asp:TextBox ID="txtGroupsList_ToCompare" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                    <asp:TextBox ID="txtGroupsListCodes" runat="server" Style="display: none"></asp:TextBox>
                                                                </div>
                                                                <div style="float: right; padding-top:2px;">
                                                                    <asp:ImageButton ID="btnGroupsListPopUp" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                                                        OnClientClick="SelectGroups();return false;" style="position:relative;left:-4px" Visible="true" />
                                                                </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px" valign="top">
                                                            <div style="float: right; margin-right: 30px; width: 60px;visibility:hidden">
                                                                <asp:Label ID="lblPopulation" runat="server" Text="אוכלוסיה"></asp:Label>
                                                            </div>
                                                            <div style="float: right;visibility:hidden">
                                                                <asp:TextBox Width="276px" Height="20px" ID="txtPopulationsList" runat="server" onfocus="SyncronizePopulationsList();" onchange="ClearPopulationsList();"></asp:TextBox>
                                                                <asp:TextBox ID="txtPopulationsList_ToCompare" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                <asp:TextBox ID="txtPopulationsListCodes" runat="server" Style="display: none"></asp:TextBox>
                                                            </div>
                                                            <div style="float: right; padding-top:2px;visibility:hidden">
                                                                <asp:ImageButton ID="ibPopulations" runat="server" ImageUrl="~/Images/Applic/icon_magnify.gif"
                                                                    OnClientClick="SelectPopulations();return false;" style="position:relative;left:-4px" Visible="true" />
                                                            </div>
                                                        </td>
                                                        <td style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px" valign="top">
                                                        </td>
                                                        <td valign="top" align="left">
                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td style="background-image: url(Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                        background-position: bottom left;">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td style="vertical-align: bottom; background-image: url(Images/Applic/regButtonBG_Middle.gif);
                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                        <asp:Button ID="btnSubmit" Width="45px" CssClass="RegularUpdateButton" Text="חיפוש"
                                                                            runat="server" ValidationGroup="vldGrSearch" 
                                                                            OnClientClick="showProgressBar();" onclick="btnSubmit_Click">
                                                                        </asp:Button>
                                                                    </td>
                                                                    <td style="background-position: right bottom; background-image: url(Images/Applic/regButtonBG_Left.gif);
                                                                        background-repeat: no-repeat;">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td style="background-image: url(Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                        background-position: bottom left;">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td style="vertical-align: bottom; background-image: url(Images/Applic/regButtonBG_Middle.gif);
                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                        <input type="button" value="ניקוי" onclick="refreshPage();" style="width: 45px;"
                                                                            class="RegularUpdateButton" />
                                                                    </td>
                                                                    <td style="background-position: right bottom; background-image: url(Images/Applic/regButtonBG_Left.gif);
                                                                        background-repeat: no-repeat;">
                                                                        &nbsp;
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%-- END  parameters panel - contains the parameter place holder and the reception time area --%>
                <%-- BEGIN content between the parameters panel and the result panel (the grid panel) --%>
                <tr>
                    <td align="right">
                        <div style="width: 980px;">
                            <div id="divProgressBar" style="margin-top:5px;visibility:hidden;position:fixed;background:url('Images/Applic/progressBar.gif') center no-repeat;width:100%;height:32px;"></div>
                            <asp:UpdatePanel runat="server" ID="upSearchResult">
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnSubmit" />
                                    <asp:PostBackTrigger ControlID="bExportToExcel" />
                                </Triggers>
                                <ContentTemplate>

                                    <asp:Panel runat="server" ID="pAdminComments" Width="100%">
                                           <br />
                                           <div style="width:100%; margin-right:200px;">
                                           <div class="RegularLabel" id="divResolutionRemark" runat="server" style="width: 580px; border: solid 2px #bcd9ee; background-color: #f6f6f6;display:block;" align="center">
                                           <asp:Repeater ID="rAdminComments" runat="server">
                                                <HeaderTemplate>
                                                    <table cellpadding="2" cellspacing="2" border="0" width="100%">
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <tr>
                                                        <td style="width:200px" align="right" valign="top">
                                                            <%# Eval("Title") %>
                                                        </td>
                                                        <td align="right" valign="top">
                                                            <%# Eval("Comment") %>
                                                        </td>
                                                    </tr>
                                                </ItemTemplate>
                                                <SeparatorTemplate>
                                                <tr><td colspan="2"><hr width="100%" style="height:1px" color="#bcd9ee" /></td></tr>
                                                </SeparatorTemplate>
                                                <FooterTemplate>
                                                    </table>
                                                </FooterTemplate>
                                           </asp:Repeater>
                                           </div>
                                            </div>
                                           <%--<br /><br />
                                            צפייה מיטבית במערכת תתאפשר ברזולוציית מסך של 1024*768<br>
                                            להצגת הסבר על אופן שינוי הרזולוציה במסך <a onclick="javascript:OpenResolutionRemark();"
                                                class="LooksLikeHRef">לחץ כאן</a><br>
                                            לשינוי <u>קבוע</u> של רזולוציית המסך במחשב יש לפנות ליחידת המחשוב--%>
                                    </asp:Panel>

                                    <asp:Panel ID="pnlTabs" runat="server" Visible="false">
                                        <div style="background-image: url('Images/Applic/tab_WhiteBlueBackGround.jpg'); height: 30px;
                                            margin: 0px; padding-bottom: 1px; width: 1180px; background-repeat: repeat-x;"
                                            dir="rtl">
                                            <div style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; background-image: url('Images/Applic/tab_WhiteBlueBackGround.jpg');
                                                background-position: bottom; background-repeat: repeat-x; width: 15px; float: right;
                                                height: 32px">
                                            </div>
                                            <div id="tabServices" runat="server">
                                                <div runat="server" id="tabServices_RightTab" class="divRightTabNotSelected">
                                                </div>
                                                <div runat="server" id="tabServices_CenterTab" class="divCenterTabNotSelected">
                                                    <asp:LinkButton ID="lbServicesTab" runat="server" Width="56px" Font-Bold="true" Font-Underline="false" EnableTheming="false" Text="שירותים"
                                                        CssClass="TDNotHighlightedSearchTab" CommandArgument="SalServices" OnClick="lbSalServicesTab_Click" OnClientClick="showProgressBar();"></asp:LinkButton>
                                                </div>
                                                <div runat="server" id="tabServices_LeftTab" class="divLeftTabNotSelected">
                                                </div>
                                            </div>
                                            <div id="tabPopulations" runat="server">
                                                <div runat="server" id="tabPopulations_RightTab" class="divRightTabNotSelected">
                                                </div>
                                                <div runat="server" id="tabPopulations_CenterTab" class="divCenterTabNotSelected">
                                                    <asp:LinkButton ID="lbPopulationsTab" runat="server" Font-Bold="true" Font-Underline="false" Width="58px" EnableTheming="false" Text="תעריפים"
                                                        CssClass="TDNotHighlightedSearchTab" CommandArgument="Populations" OnClick="lbSalServicesTab_Click" OnClientClick="showProgressBar();"></asp:LinkButton>
                                                </div>
                                                <div runat="server" id="tabPopulations_LeftTab" class="divLeftTabNotSelected">
                                                </div>
                                            </div>

                                            <div id="tabNewTests" runat="server" style="display:none;padding-right:17px">
                                                <div runat="server" id="tabNewTests_RightTab" class="divRightTabNotSelected">
                                                </div>
                                                <div runat="server" id="tabNewTests_CenterTab" class="divCenterTabNotSelected">
                                                    <asp:LinkButton ID="lbNewTestsTab" runat="server" Font-Bold="true" Width="210px" Font-Underline="false" EnableTheming="false" 
                                                        Text="מידע על פעולות ובדיקות חדשות" CommandArgument="NewTests" CssClass="TDNotHighlightedSearchTab" OnClick="lbSalServicesTab_Click" OnClientClick="showProgressBar();"></asp:LinkButton>
                                                </div>
                                                <div runat="server" id="tabNewTests_LeftTab" class="divLeftTabNotSelected">
                                                </div>
                                            </div>

                                        </div>
                                    </asp:Panel>
                                    <div id="divSalServicesSearchResults" runat="server" style="width: 1180px; overflow-y: hidden;overflow-x: auto;padding-bottom:14px;display: none">
                                        <table id="tblSalServicesGridControls" cellpadding="0" cellspacing="0" align="right" style="width:1180px">
                                            <tr id="trSalServicesPagingButtons" runat="server" style="margin-left: 5px">
                                                <td style="background-color: #f9f9f9; border-top: 1px solid #e3e3e3; border-bottom: 1px solid #e3e3e3;">
                                                    <table cellpadding="0" cellspacing="0" width="963" style="min-height:30px">
                                                        <tr>
                                                            <td style="text-align: right; width: 400px;">
                                                                <asp:Label ID="lblTotalRecords" runat="server" Text="נמצא 750 רשומות"></asp:Label>&nbsp;
                                                                <asp:Label ID="lblPageFromPages" runat="server" Text=" עמוד 5 מתוך 15 "></asp:Label>
                                                                
                                                                <asp:PlaceHolder runat="server" ID="phExportToExcel" Visible="false">
                                                                    
                                                                            <table cellpadding="0" cellspacing="0" border="0" style="width:120px;display:inline;">
                                                                            <tr>
                                                                                <td style="background-image: url(Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                    background-position: bottom left;">
                                                                                    &nbsp;
                                                                                </td>
                                                                                <td align="center" style="vertical-align: bottom; background-image: url(Images/Applic/regButtonBG_Middle.gif);
                                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                                    <asp:Button runat="server" ID="bExportToExcel" Text="ייצוא לאקסל" CssClass="RegularUpdateButton" OnClick="bExportToExcel_Click" CausesValidation="false" />
                                                                                </td>
                                                                                <td style="background-position: right bottom; background-image: url(Images/Applic/regButtonBG_Left.gif);
                                                                                    background-repeat: no-repeat;">
                                                                                    &nbsp;
                                                                                </td>
                                                                            </tr>
                                                                            </table>
                                                                        
                                                                </asp:PlaceHolder>
                                                            </td>
                                                            <td style="width: 80px;">
                                                                &nbsp;
                                                            </td>
                                                            <td align="left" style="padding-left: 5px">
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
                                            <tr>
                                                <td style="text-align: right;">
                                                    <asp:Panel runat="server" ID="pServicesHeaderGrid" Visible="false">
                                                        <table cellpadding="0" border="0" cellspacing="0" style="text-align: right;width:1180px;vertical-align: middle;" align="right">
                                                            <tr>
                                                                <!-- Scroll Column -->
                                                                <td style="width: 14px;background-color:#f0f0f0">&nbsp;</td>
                                                                <td style="width: 26px;background-color:#f0f0f0">&nbsp;</td>
                                                                <td style="width: 26px;background-color:#f0f0f0">&nbsp;</td>
                                                                <td style="width: 26px;background-color:#f0f0f0">&nbsp;</td>
                                                                <td style="width: 26px;background-color:#f0f0f0">&nbsp;</td>
                                                                <!-- Service Code - Header Cell -->
                                                                <td style="width: 60px;" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableServiceCode" runat="server" Text="כללית" ColumnIdentifier="ServiceCode"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Service Name - Header Cell -->
                                                                <td style="width:300px" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableServiceName" runat="server" Text="תיאור" ColumnIdentifier="ServiceName"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Health Office Detail - Header Cell -->
                                                                <td style="width: 72px;" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableMIN_CODE" runat="server" Text="קוד מ.ש." ColumnIdentifier="MIN_CODE"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Profession Details - Header Cell -->
                                                                <td style="width: 120px;" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableProfessionDesc" runat="server" Text="מקצוע ראשי" ColumnIdentifier="ProfessionDesc"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Budget Card Details - Header Cell -->
                                                                <td style="width: 100px;" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableBudgetCard" runat="server" Text="כרטיס תקציב" ColumnIdentifier="BudgetCard"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Eshkol Details - Header Cell -->
                                                                <td style="width: 104px;" class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortableEshkolDesc" runat="server" Text="אשכול" ColumnIdentifier="EshkolDesc"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Payment Rules Details - Header Cell -->
                                                                <td class="ColumnHeader_SS">
                                                                    <cc1:SortableColumn ID="SortablePaymentRules" runat="server" Text="כללי חיוב" ColumnIdentifier="PaymentRules"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                    <asp:Panel ID="pServicesGrid" runat="server" Visible="false" Width="100%" style="height: 345px; overflow-y: scroll; direction: ltr">
                                                        <div style="direction: rtl;">
                                                            <table cellpadding="0" cellspacing="0" border="0" style="width:1180px;border-bottom:1px solid #dbdbda">
                                                                <asp:Repeater ID="repServicesList" runat="server" EnableViewState="true" OnItemDataBound="repServicesList_ItemDataBound">
                                                                    <ItemTemplate>
                                                                        <tr runat="server" id="rowServiceDetails" class="trPlain">
                                                                            <%--<td style="width: 24px;" class="ColumnItem_SS"><a target="_blank" href='<%# Eval("ServiceCode" , "http://home.clalit.org.il/sites/clalit/hozerSherut/lists/{0}/viewTarifon.aspx")  %>'><img src="Images/HozreiSherut.png" width="18" height="18" border="0" alt="חוזרי שירות" title="חוזרי שירות" /></a></td>--%>
                                                                            <%-- IncludeInBasket - Image --%>
                                                                            <td style="width: 24px;" class="ColumnItem_SS" align="center"><asp:PlaceHolder runat="server" ID="pIncludeInBasket_0" Visible="false"><img src="Images/IncludeInBasket-False.jpg" width="18" height="18" border="0" /></asp:PlaceHolder><asp:PlaceHolder runat="server" ID="pIncludeInBasket_1" Visible="false"><img src="Images/IncludeInBasket-True.png" width="18" height="18" border="0" title="כלול בסל" /></asp:PlaceHolder><asp:PlaceHolder runat="server" ID="pIncludeInBasket_2" Visible="false"><img src="Images/IncludeInBasket-Warning2.gif" width="18" height="18" border="0" title="בסל מוגבל" /></asp:PlaceHolder>&nbsp;</td>
                                                                            <%-- Limiter - Image --%>
                                                                            <td style="width: 24px;" class="ColumnItem_SS" align="center"><asp:PlaceHolder runat="server" ID="pLimiter_0" Visible="false"><img src="Images/Limiter-False.jpg" width="18" height="18" border="0" /></asp:PlaceHolder><asp:PlaceHolder runat="server" ID="pLimiter_1" Visible="false"><img src="Images/Limiter-True.gif" width="18" height="18" border="0" title="קיימות הגבלות" /></asp:PlaceHolder>&nbsp;</td>
                                                                            <%-- Common - Image --%>
                                                                            <td style="width: 24px;" class="ColumnItem_SS" align="center"><asp:PlaceHolder runat="server" ID="pHasComments_0" Visible="false"><img src="Images/HasComments-False.jpg" width="18" height="18" border="0" /></asp:PlaceHolder><asp:PlaceHolder runat="server" ID="pHasComments_1" Visible="false"><img src="Images/HozreiSherut.png" width="18" height="18" border="0" title="קיימות הנחיות" /></asp:PlaceHolder>&nbsp;</td>
                                                                            <%-- Common - Image --%>
                                                                            <td style="width: 24px;" class="ColumnItem_SS" align="center"><asp:PlaceHolder runat="server" ID="pShowServiceInInternet_Complete0" Visible="false"><img src="Images/ShowInternetComplete0.png" title="באינטרנט, לא בוצע סיום טיפול" width="18" height="18" border="0" /></asp:PlaceHolder><asp:PlaceHolder runat="server" ID="pShowServiceInInternet_Complete1" Visible="false"><img src="Images/ShowInternetComplete1.png" title="באינטרנט, בוצע סיום טיפול" width="18" height="18" border="0" /></asp:PlaceHolder>&nbsp;</td>
                                                                            <%-- Service Code - Header Cell --%>
                                                                            <td style="width: 60px;" class="ColumnItem_SS">
                                                                                <asp:Panel ID="pnlLink" runat="server">
                                                                                    <asp:HyperLink runat="server" ID="lnkToSalService1" style="font-weight:normal" Text='<%# Eval("ServiceCode") %>'></asp:HyperLink>
                                                                                </asp:Panel>
                                                                            </td>
                                                                            <%-- Service Name - Header Cell --%>
                                                                            <td style="width:300px" class="ColumnItem_SS"><asp:HyperLink runat="server" ID="lnkToSalService2" style="font-weight:normal" Text='<%# Eval("ServiceName") %>'></asp:HyperLink></td>
                                                                            <%-- Health Office Detail - Header Cell --%>
                                                                            <td style="width: 70px;" class="ColumnItem_SS"><%# Eval("MIN_CODE")%></td>
                                                                            <%-- Profession Details - Header Cell --%>
                                                                            <td style="width: 120px;" class="ColumnItem_SS"><%# Eval("ProfessionDesc") %>&nbsp;</td>
                                                                            <%-- Budget Card Details - Header Cell --%>
                                                                            <td style="width: 100px;" class="ColumnItem_SS"><%# Eval("BudgetCard") %>&nbsp;</td>
                                                                            <%-- Eshkol Details - Header Cell --%>
                                                                            <td style="width: 100px;" class="ColumnItem_SS"><%# Eval("EshkolDesc") %>&nbsp;</td>
                                                                            <%-- Payment Rules Details - Header Cell --%>
                                                                            <td class="ColumnItem_SS"><%# Eval("PaymentRules") %>&nbsp;</td>
                                                                        </tr>
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </table>
                                                        </div>
                                                    </asp:Panel>
                                                    <asp:Panel runat="server" ID="pPopulationsHeaderGrid" Width="1816px" Visible="false">
                                                        <table cellpadding="0" border="0" cellspacing="0" style="text-align: right;vertical-align: middle;width:1180px" align="right">
                                                            <tr>
                                                                <!-- Scroll Column -->
                                                                <td style="width: 14px;background-color:#f0f0f0">&nbsp;</td>
                                                                <!-- Service Code - Header Cell -->
                                                                <td runat="server" id="tdPopulationsServiceCode" style="width: 70px;" class="ColumnHeader_SS_Small">
                                                                    <cc1:SortableColumn ID="scServiceCode" runat="server" Text="קוד שרות" ColumnIdentifier="ServiceCode"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Min Code - Header Cell -->
                                                                <td runat="server" id="tdPopulationsMinCode" style="width:70px" class="ColumnHeader_SS_Small">
                                                                    <cc1:SortableColumn ID="scMIN_CODE" runat="server" Text="קוד מ.ב." ColumnIdentifier="MIN_CODE"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <!-- Service Name - Header Cell -->
                                                                <td runat="server" id="tdPopulationsServiceName" style="width: 150px;" class="ColumnHeader_SS_Small">
                                                                    <cc1:SortableColumn ID="scServiceName" runat="server" Text="תיאור עברי/אנגלי" ColumnIdentifier="ServiceName"
                                                                        OnSortClick="btnSort_Click" />
                                                                </td>
                                                                <% if ( this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) { %>
                                                                <!-- 1. Ithashbenut Pnimit - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>התחשבנות<br />פנימית</span>
                                                                </td>
                                                                <% } %>
                                                                <!-- 2. Ishtatfut Azmit - Header Cell -->
                                                                <td runat="server" id="tdPopulationsIshtatfutAzmit" style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>השתתפות<br />עצמית</span>
                                                                </td>
                                                                <!-- 3. TaarifZiburiBet - Header Cell -->
                                                                <td runat="server" id="tdPopulationsTaarifZiburiBet" style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריף<br />ציבורי ב'</span>
                                                                </td>
                                                                <% if ( this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) { %>
                                                                <!-- 4. TeunotDrahim - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תאונות<br />דרכים</span>
                                                                </td>
                                                                <!-- 5. TaarifMale - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריף<br />מלא</span>
                                                                </td>
                                                                <!-- 7. KatsatPnimi - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>קצ''ת<br />פנימי</span>
                                                                </td>
                                                                <!-- 8. KlalitMushlam - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>כללית<br />מושלם</span>
                                                                </td>
                                                                <!-- 9. KatsatHizoni - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>קצ''ת<br />חיצוני</span>
                                                                </td>
                                                                <% } %>
                                                                <!-- 10. MimunEtzLemecutah - Header Cell -->
                                                                <td runat="server" id="tdPopulationsMimunEtzLemecutah" style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>מימון עצ<br />למבוטח</span>
                                                                </td>
                                                                <% if ( this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) { %>
                                                                <!-- 11. OvdimZarim - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>עובדים<br />זרים</span>
                                                                </td>
                                                                <% } %>
                                                                <!-- 12. Hechzerim - Header Cell -->
                                                                <td runat="server" id="tdPopulationsHechzerim" style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>החזרים</span>
                                                                </td>
                                                                <% if ( this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) { %>
                                                                <!-- 13. BituahOhMeyuhad - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>ביטוח<br />אוכ<br />מיוחד</span>
                                                                </td>
                                                                <!-- 14. MimunEtzLeMushlam - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>מימון עצ<br />מושלם</span>
                                                                </td>
                                                                <!-- 15. TaarifeyShuk - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריפי<br />שוק</span>
                                                                </td>
                                                                <!-- 16. TikzuvBetHolim - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תקצוב<br />בתי''ח</span>
                                                                </td>
                                                                <!-- 17. TaarifAlef - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריף א'</span>
                                                                </td>
                                                                <!-- 18. TaarifZiburiZam - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריף<br />ציבורי זמ</span>
                                                                </td>
                                                                <!-- 19. TaarifZiburiGemel - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>תעריף<br />ציבורי<br />ג'</span>
                                                                </td>
                                                                <!-- 20. ZahalBeklalitHova - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>צהל<br />בכללית<br />חובה</span>
                                                                </td>
                                                                <!-- 21. ZahalBeklalitKeva - Header Cell -->
                                                                <td style="width: 70px;text-align:center" class="ColumnHeader_SS_Small">
                                                                    <span>צהל<br />בכללית<br />קבע</span>
                                                                </td>
                                                                <!-- 33. TaarifZiburiEskemim - Header Cell -->
                                                                <td style="text-align:center" class="ColumnHeader_SS_Small"> 
                                                                    <span>תעריף<br />ציבורי<br />הסכמים</span>
                                                                </td>
                                                                <% } %>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                    <asp:Panel ID="pPopulationsGrid" runat="server" Visible="false" style="overflow-y: scroll;overflow-x:hidden; direction: ltr; height: 345px;">
                                                        <div style="direction: rtl;">
                                                            <asp:Repeater ID="repPopulationsList" runat="server" EnableViewState="true" OnItemDataBound="repPopulationsList_ItemDataBound">
                                                                <HeaderTemplate>
                                                                <table cellpadding="0" cellspacing="0" style="width:1180px" border="0">
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr runat="server" id="rowServiceTarifonDetails" class="trPlain">
                                                                        <%-- Cell 0: Service Code - Header Cell --%>
                                                                        <td runat="server" style="width: 80px;" class="ColumnItem_SS_Small">
                                                                            <asp:Panel ID="pnlLink" runat="server">
                                                                                <asp:HyperLink runat="server" ID="lnkToSalService1" style="font-weight:normal" Text='<%# Eval("ServiceCode") %>'></asp:HyperLink>
                                                                            </asp:Panel>
                                                                        </td>
                                                                        <%-- Cell 1: Min Code - Header Cell --%>
                                                                        <td runat="server" style="width:75px" class="ColumnItem_SS_Small"><%# Eval("MIN_CODE") %></td>
                                                                        <%-- Cell 2: Service Name - Header Cell --%>
                                                                        <td runat="server" style="width: 350px;" class="ColumnItem_SS_Small"><asp:HyperLink runat="server" style="font-weight:normal" ID="lnkToSalService2" Text='<%# Eval("ServiceName") %>'></asp:HyperLink></td>
                                                                        <%-- Cell 3: 1. Ithashbenut Pnimit - Header Cell --%>
                                                                        <td runat="server" style="width: 80px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("IthashbenutPnimit" , "{0:,0.00}") %>&nbsp;</td>
                                                                        <%-- Cell 4: 2. Ishtatfut Azmit - Header Cell --%>
                                                                        <td runat="server" style="width: 80px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("IshtatfutAzmit", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 5: 3. TaarifZiburiBet - Header Cell --%>
                                                                        <td runat="server" style="width: 80px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifZiburiBet", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 6: 4. TeunotDrahim - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TeunotDrahim", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 7: 5. TaarifMale - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifMale", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 8: 7. KatsatPnimi - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("KatsatPnimi", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 9: 8. KlalitMushlam - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("KlalitMushlam", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 10: 9. KatsatHizoni - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("KatsatHizoni", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 11: 10. MimunEtzLemecutah - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("MimunEtzLemecutah", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 12: 11. OvdimZarim - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("OvdimZarim", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 13: 12. Hechzerim - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("Hechzerim", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 14: 13. BituahOhMeyuhad - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("BituahOhMeyuhad", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 15: 14. MimunEtzLeMushlam - Header Cell --%>
                                                                        <td runat="server" style="width: 67px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("MimunEtzLeMushlam", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 16: 15. TaarifeyShuk - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifeyShuk", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 17: 16. TikzuvBetHolim - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TikzuvBetHolim", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 18: 17. TaarifAlef - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifAlef", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 19: 18. TaarifZiburiZam - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifZiburiZam", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 20: 19. TaarifZiburiGemel - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifZiburiGemel", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 21: 20. ZahalBeklalitHova - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("ZahalBeklalitHova", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 22: 21. ZahalBeklalitKeva - Header Cell --%>
                                                                        <td runat="server" style="width: 70px;text-align:right" class="ColumnItem_SS_Small"><%# Eval("ZahalBeklalitKeva", "{0:,0.00}")%>&nbsp;</td>
                                                                        <%-- Cell 23: 33. TaarifZiburiEskemim - Header Cell --%>
                                                                        <td runat="server" style="text-align:right" class="ColumnItem_SS_Small"><%# Eval("TaarifZiburiEskemim", "{0:,0.00}")%>&nbsp;</td>
                                                                        <td style="width: 300px;">&nbsp;</td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                </table>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </div>
                                                    </asp:Panel>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </td>
                </tr>
            </table>
        </asp:Panel>
    </div>
</asp:Content>