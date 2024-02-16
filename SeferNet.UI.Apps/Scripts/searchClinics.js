function ToggleQueueOrderPhonesAndHours(elemName) {
    RaiseOnToggleQueueOrderPhonesAndHours(elemName);
}

function OnCloseQueueOrderPhonesAndHoursPopUp() {
    RaiseOnCloseQueueOrderPhonesAndHoursPopUp();
}

function ClientPopulated(source, eventArgs) {
    CommonClientPopulated(source, eventArgs);
}

function SelectServicesAndEvents() {
    var url = "Public/SelectPopUp.aspx";
    var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
    var txtProfessionList = document.getElementById(txtProfessionListClientID);
    var SelectedProfessionList = txtProfessionListCodes.innerText;
    url = url + "?SelectedValuesList=" + SelectedProfessionList;
    url = url + "&popupType=12";
    url += "&AgreementTypes= " + GetSelectedValues();
    url += getOrganizationParams();
    url += "&returnValuesTo='txtProfessionListCodes'";
    url += "&returnTextTo='txtProfessionList'";
    url += "&functionToExecute=" + "SetReceiveGuestsAccordingToSelectedProfessions";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר שירות או פעילות";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}

function SetReceiveGuestsAccordingToSelectedProfessions() {
    document.getElementById(divReceiveGuestsClientID).disabled = true;
    document.getElementById(cbNotReceiveGuestsClientID).checked = false;

    var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);

    if (txtProfessionListCodes.innerText != "") {
        var ServicesToReceiveGuests = document.getElementById(txtProfessionsRelevantForReceivigGuestsClientID).value
        var relevantServices = ServicesToReceiveGuests.split(",");
        var selectedServices = txtProfessionListCodes.innerText.split(",");

        for (i = 0; i < relevantServices.length; i++) {
            for (ii = 0; ii < selectedServices.length; ii++) {
                if (relevantServices[i] == selectedServices[ii]) {
                    document.getElementById(divReceiveGuestsClientID).disabled = false;
                }
            }
        }
    }
    else {
        document.getElementById(divReceiveGuestsClientID).disabled = true;
        document.getElementById(cbNotReceiveGuestsClientID).checked = false;
    }
}

function OpenEventsWindow(ServiceOrEventCode) {
    var url = "Public/DeptEventPopUp.aspx?EventCode=" + ServiceOrEventCode;

    var dialogWidth = 670;
    var dialogHeight = 590;
    var title = "פעילות של מרפאה";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
}

function SelectQueueOrder() {
    var txtQueueOrderCodes = document.getElementById(txtQueueOrderCodesClientID);
    var SelectedCodesList = txtQueueOrderCodes.innerText;

    var url = "Public/SelectPopUp.aspx";
    url = url + "?SelectedValuesList=" + SelectedCodesList;
    url = url + "&popupType=29";
    url += "&returnValuesTo='txtQueueOrderCodes'";
    url += "&returnTextTo='txtQueueOrder'";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר אופן זימון";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}

function OpenEventWindow(ServiceOrEventCode) {
    var url = "Public/DeptEventPopUp.aspx?EventCode=" + ServiceOrEventCode;

    var dialogWidth = 670;
    var dialogHeight = 590;
    var title = "פעילות של מרפאה";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
}

function SetUnitType() {
    var cbHandleSubUnitTypes = document.getElementById(cbHandleSubUnitTypesClientID);
    cbHandleSubUnitTypes.checked = true;
    DoSubmit();
}

function SelectUnitType() {
    var url = "Public/SelectPopUp.aspx";
    var txtUnitTypeListCodes = document.getElementById(txtUnitTypeListCodesClientID);
    var txtUnitTypeList = document.getElementById(txtUnitTypeListClientID);
    var SelectedUnitTypeList = txtUnitTypeListCodes.innerText;
    url += "?SelectedValuesList=" + SelectedUnitTypeList;
    url += "&popupType=6";
    url += "&membershipValues=" + GetSelectedValues();
    url += "&returnValuesTo='txtUnitTypeListCodes'";
    url += "&returnTextTo='txtUnitTypeList'";
    url += "&functionToExecute=" + "SetUnitType";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר סוג יחידה";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}

function setSelectedClinicName(source, eventArgs) {

    var txtClinicName = document.getElementById(txtClinicNameClientID);
    var values = eventArgs.get_value();
    if (values == null) return;
    var valuesArr = values.split(",");

    var text = eventArgs.get_text();
    txtClinicName.value = valuesArr[1];
}

// "HandicappedFacilities" management functions
function ClearHandicappedFacilitiesList() {
    if (document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value != document.getElementById(txtHandicappedFacilitiesListClientID).value) {
        document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = "";
        document.getElementById(txtHandicappedFacilitiesListClientID).value = "";
        document.getElementById(txtHandicappedFacilitiesCodesClientID).value = "";
    }
}
function SyncronizeHandicappedFacilitiesList() {
    document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = document.getElementById(txtHandicappedFacilitiesListClientID).value;
}



function getSelectedHandicappedFacilityCode(source, eventArgs) {
    
    document.getElementById(txtHandicappedFacilitiesCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = eventArgs.get_text();
    document.getElementById(txtHandicappedFacilitiesListClientID).value = eventArgs.get_text();

    document.getElementById("btnHandicappedFacilitiesPopUp").focus();
}

function geSelectedtQueueOrderMethods(source, eventArgs) {

    document.getElementById(txtQueueOrderCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtQueueOrderClientID).value = eventArgs.get_text();

    document.getElementById("btnQueueOrderPopUp").focus();
}

function ClearQueueOrderMethodsList() {
    document.getElementById(txtQueueOrderCodesClientID).value = '';
    document.getElementById(txtQueueOrderClientID).value = '';
}

// "Profession" management functions
function ClearProfessionList() {

    var extendedSearchEnabled = $("body").find("[id*='btnProfessionListPopUp']")[0].disabled;

    document.getElementById(cbNotReceiveGuestsClientID).checked = false;
    document.getElementById(divReceiveGuestsClientID).disabled = true;

    if (!extendedSearchEnabled) {
        if (document.getElementById(txtProfessionList_ToCompareClientID).value != document.getElementById(txtProfessionListClientID).value) {
            document.getElementById(txtProfessionList_ToCompareClientID).value = "";
            document.getElementById(txtProfessionListClientID).value = "";
            document.getElementById(txtProfessionListCodesClientID).value = "";
        }
    }
}
function SyncronizeProfessionList() {
    document.getElementById(txtProfessionList_ToCompareClientID).value = document.getElementById(txtProfessionListClientID).value;
}
function getSelectedProfessionCode(source, eventArgs) {
 
    document.getElementById(txtProfessionListCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtProfessionList_ToCompareClientID).value = eventArgs.get_text();
    document.getElementById(txtProfessionListClientID).value = eventArgs.get_text();
    var ServicesToReceiveGuests = document.getElementById(txtProfessionsRelevantForReceivigGuestsClientID).value 
    var relevantServices = ServicesToReceiveGuests.split(",");
    var selectedServices = eventArgs.get_value().split(",");

    for (i = 0; i < relevantServices.length; i++){
         for (ii = 0; ii < selectedServices.length; ii++) {
            if (relevantServices[i] == selectedServices[ii])  {
                document.getElementById(divReceiveGuestsClientID).disabled = false;
            }
        }
    }
  
    $("body").find("[id*='btnProfessionListPopUp']")[0].focus();
}

// "UnitTypes" management functions
function ClearUnitTypeList() {

    if (document.getElementById(txtUnitTypeList_ToCompareClientID).value != document.getElementById(txtUnitTypeListClientID).value) {
        document.getElementById(txtUnitTypeList_ToCompareClientID).value = "";
        document.getElementById(txtUnitTypeListClientID).value = "";
        document.getElementById(txtUnitTypeListCodesClientID).value = "";

        var ddlSubUnitType = document.getElementById(ddlSubUnitTypeClientID);
        ddlSubUnitType.selectedIndex = 0;
        ddlSubUnitType.style.display = "none";
        var lblSubUnitType = document.getElementById(lblSubUnitTypeClientID);
        lblSubUnitType.style.display = "none";

        document.getElementById(cbHandleSubUnitTypesClientID).checked = true;
    }
}

function SyncronizeUnitTypeList() {
    document.getElementById(txtUnitTypeList_ToCompareClientID).value = document.getElementById(txtUnitTypeListClientID).value;
}
function getSelectedUnitTypeCode(source, eventArgs) {
    document.getElementById(txtUnitTypeListCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtUnitTypeList_ToCompareClientID).value = eventArgs.get_text();
    document.getElementById(txtUnitTypeListClientID).value = eventArgs.get_text();

    if (document.getElementById(txtUnitTypeListCodesClientID).value != "") {
        document.getElementById(cbHandleSubUnitTypesClientID).checked = true;

        raisePanelTopPostBackFromMaster();

    }
}

function OpenResolutionRemark() {

    var txtURLforResolutionSetUp = document.getElementById(txtURLforResolutionSetUpClientID);
    var url = txtURLforResolutionSetUp.value;
    var newWindow = window.open(url, "newWindow", "resizable=yes,scrollbars=yes,menubar=yes,toolbar=yes");
    newWindow.focus();
}

function ActionOnDistrictCodeChanged(newDistrictCodes) {
    var txtClinicName = document.getElementById(txtClinicNameClientID);

    txtClinicName.value = "";

    context = $find('acClinicName')._contextKey;
    contextArr = context.split('~');
    newContext = newDistrictCodes + '~' + contextArr[1] + '~' + contextArr[2];
    $find('acClinicName').set_contextKey(newContext);
}


function InitPage() {
    
    OnDistrictCodeChanged = ActionOnDistrictCodeChanged;
    OnSearchModeChanged = ActionOnSearchModeChanged;
    MarkCelectedCheckboxes();
    ActionOnSearchModeChanged();
}

function ActionOnSearchModeChanged() {
    if(isSearchModeChecked("Mushlam"))
        $("[id*='divExtendedSearch']")[0].style.display = "block";
                
    else {
        $("[id*='divExtendedSearch']")[0].style.display = "none";
        $("[id*='chkExtendedSearch']")[0].checked = false;
        ToggleProfessions(true, $("body").find("[id*='btnProfessionListPopUp']")[0]);
    }

    if (isSearchModeChecked("Hospitals")) {
        $("[id*='trMedicalAspect']")[0].style.display = "";

        $("[id*='tblClalitService']")[0].style.display = "";        
    }
    else {
        $("[id*='txtMedicalAspectCode']")[0].value = "";
        $("[id*='txtMedicalAspectDescription']")[0].value = "";

        $("[id*='trMedicalAspect']")[0].style.display = "none";

        $("[id*='tblClalitService']")[0].style.display = "none";
        $("[id*='txtClalitServiceCode']")[0].value = "";
        $("[id*='txtClalitServiceDesc']")[0].value = "";
    }
    //setAutoCompletesContextKeys();
    //setHospitalFlag(checkboxes[3]);
}

function OpenReceptionWindowDialog(deptCode, ServiceCodes) {
    var dialogWidth = 880;
    var dialogHeight = 700;
    var title = "שעות קבלה של יחידה";

    var url = "Public/DeptReceptionPopUp.aspx?deptCode=" + deptCode + "&ServiceCodes=" + ServiceCodes;

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title, "right");
}

function ExtendedSearchClicked() {

    var button = $("body").find("[id*='btnProfessionListPopUp']")[0];
    var currExtendedSearchEnabled = button.disabled;

    if (currExtendedSearchEnabled) {
        ToggleProfessions(true, button);
        
        // clear free text - if doesn't exists on list
        if (document.getElementById(txtProfessionList_ToCompareClientID).value != document.getElementById(txtProfessionListClientID).value) {
            document.getElementById(txtProfessionList_ToCompareClientID).value = "";
            document.getElementById(txtProfessionListClientID).value = "";
            document.getElementById(txtProfessionListCodesClientID).value = "";
        }
    }
    else {
        ToggleProfessions(false, button);
    }
}

function ToggleProfessions(needToEnableProfessionButton, button) {
    
    if (needToEnableProfessionButton) {
        button.disabled = false;
        button.src = 'Images/Applic/icon_magnify.gif';
        try {
            $find('acProfessions')._servicePath = 'AjaxWebServices/AutoComplete.asmx';
        }
        catch (ex) { }
    }
    else {
        button.disabled = true;
        button.src = 'Images/Applic/magnifying-glass-disable.gif';
        try
        {
            $find('acProfessions')._servicePath = '';
        }
        catch (ex) { }
    }
}


function DisplayDeptsTab(button) {
    $('#' + button).find("[id*='tabDeptsNotSelected']").hide();
    $('#' + button).find("[id*='tabDeptsSelected']").show();
    
    $('#' + button).find("[id*='tabMushlamServicesSelected']").hide();
    $('#' + button).find("[id*='tabMushlamServicesNotSelected']").show();

    $('#' + button).parent().find("[id*='divDeptSearchResults']").show();
    $('#' + button).parent().find("[id*='divMushlamServicesResults']").hide();
    //$('#' + button).parent().find("[id*='hdnMushlamTabDisplayed']").val('');
}


function DisplaySelectedTab(tabSelected, tabNotSelected, panel) {
    $('#tabsContainer').find("[id$='NotSelected']").css('display','inline');
    $('#tabsContainer').find("[id$='IsSelected']").hide();

    $('#tabsContainer').find("[id$='" + tabSelected + "']").css('display', 'inline');
    $('#tabsContainer').find("[id$='" + tabNotSelected + "']").hide();

    $('#tabsContainer').find("[id^='pnl']").hide();
    $('#tabsContainer').find("[id$='" + panel + "']").show();
}

function GetMushlamScrollPosition() {
    $("body").find("[id$='ScrollTop']").val($('#divMushlamServices')[0].scrollTop);
}

function ScrollToLastPosition() {
    $('#divMushlamServices')[0].scrollTop = $("body").find("[id$='ScrollTop']").val();
}

