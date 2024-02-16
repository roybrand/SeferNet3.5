function SetTxtAgreementType() {
    var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);
    var txtAgreementType = document.getElementById(txtAgreementTypeClientID);
    txtAgreementType.value = ddlAgreementType.value;
}





function UpdateAutoCompleteName(LoggedinUser, otherNameID, acExtenderID) {

    var otherName = document.getElementById(otherNameID).value;

    var membershipValues = GetSelectedValues();

    var ddlSector = document.getElementById(ddlEmployeeSectorCodeClientID);
    var sector = ddlSector.options[ddlSector.selectedIndex].value;

    var newContext = LoggedinUser + '~' + otherName + '~' + sector + '~' + membershipValues;
    $find(acExtenderID).set_contextKey(newContext);
}

function SetDefaultValue(selectedValues) {
    var arr = selectedValues.split(',');
    var txtAgreementType = document.getElementById(txtAgreementTypeClientID);
    var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);

    if (arr.length == 1 && arr[0] == "Mushlam") {
        txtAgreementType.value = arr[0];
        ddlAgreementType.value = txtAgreementType.value;
    }
    else {
        txtAgreementType.value = "-1";
        ddlAgreementType.value = "-1";
    }
}

// "Languages" management functions
function getSelectedLanguagesCode(source, eventArgs) {
    document.getElementById(txtLanguageListCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtLanguageListClientID).value = eventArgs.get_text();
    document.getElementById(btnProfessionListPopUpClientID).focus();
}

function getSelectedProfessionCode(source, eventArgs) {
    document.getElementById(txtProfessionListCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtProfessionList_ToCompareClientID).value = eventArgs.get_text();
    document.getElementById(txtProfessionListClientID).value = eventArgs.get_text();

    var ServicesToReceiveGuests = document.getElementById(txtProfessionsRelevantForReceivigGuestsClientID).value
    var relevantServices = ServicesToReceiveGuests.split(",");
    var selectedServices = eventArgs.get_value().split(",");

    for (i = 0; i < relevantServices.length; i++) {
        for (ii = 0; ii < selectedServices.length; ii++) {
            if (relevantServices[i] == selectedServices[ii]) {
                document.getElementById(divReceiveGuestsClientID).disabled = false;
            }
        }
    }

    document.getElementById(btnProfessionListPopUpClientID).focus();
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

function ItemNeedToBeDisplayed(itemValue, selectedValues) {
    var arr = selectedValues.split(',');

    for (var i = 0; i < arr.length; i++) {
        if (itemValue.toLowerCase().indexOf(arr[i].toLowerCase()) > -1 || selectedValues == '' || itemValue == -1)
            return true;
    }
    return false;
}

function SetDdlAgreementTypeFromTxtAgreementType() {
    var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);
    var txtAgreementType = document.getElementById(txtAgreementTypeClientID);
    if (txtAgreementType.value != "") {
        ddlAgreementType.value = txtAgreementType.value;
    }
}

function ActionOnSearchModeChanged_Refresh() {

    var ddlAgreementTypeClone = document.getElementById(ddlAgreementTypeCloneClientID);
    var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);
    if (ddlAgreementTypeClone == null
        || ddlAgreementType == null) {
        return;
    }

    var copiedCtrlID = ddlAgreementTypeClone.id;
    var ctrlID = ddlAgreementType.id;

    selectedValues = GetSelectedValues();
    var fullArr = new Array();

    $('#' + ctrlID).empty();

    $('#' + copiedCtrlID + ' option').each(function () {
        text = $(this).text();
        value = $(this).val();
        if (ItemNeedToBeDisplayed(value, selectedValues)) {
            $('#' + ctrlID).append('<option value="' + value + '">' + text + '</option>');
        }
    });

    SetDdlAgreementTypeFromTxtAgreementType();
    MarkCelectedCheckboxes();
}

function ActionOnSearchModeChanged() {
    var ddlAgreementTypeClone = document.getElementById(ddlAgreementTypeCloneClientID);
    var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);
    if (ddlAgreementTypeClone == null
        || ddlAgreementType == null) {
        return;
    }

    var allItem = false;
    var agreeTypeList = "";

    var selectedValues = GetSelectedIndexes();
    var tmpSplit = selectedValues.split(",");
    if (isSearchModeChecked("All")) {
        agreeTypeList += GetListByID("all");
        allItem = true;
    }
    else {

        $.each(tmpSplit, function () {

            if (agreeTypeList == "") {
                agreeTypeList = GetListByID(this);
            }
            else
                agreeTypeList += "#" + GetListByID(this);


        });


    }



    var copiedCtrlID = ddlAgreementTypeClone.id;
    var ctrlID = ddlAgreementType.id;


    var fullArr = new Array();

    $('#' + ctrlID).empty();




    var tmpText;
    var tmpValue;
    var all = false;
    var splitList = "";
    var communityChecked = 0;

    splitList = agreeTypeList.split("#");

    if (allItem) {
        $('#' + ctrlID).append('<option value="-1" selected="selected">הכל</option>');
    }
    else {
        $('#' + ctrlID).append('<option value="-1">הכל</option>');
    }

    jQuery.each(splitList, function () {
        tmpText = this.split("!")[0];
        tmpValue = this.split("!")[1];

        if (tmpValue == "Community")
            communityChecked = 1;

        var tmpSelected = "";

        if (this.split("!")[2] == 1 && !allItem && communityChecked != 1) {
            tmpSelected = ' selected="selected"';
        }

        $('#' + ctrlID).append('<option value="' + tmpValue + '"' + tmpSelected + '>' + tmpText + '</option>');


    });

    SetDdlAgreementTypeFromTxtAgreementType();

    //setHospitalFlag(checkboxes[3]);
}





function InitPage() {

    ActionOnSearchModeChanged_Refresh();
    OnSearchModeChanged = ActionOnSearchModeChanged;
    OnSearchModeChanged();
}


function ToggleQueueOrderPhonesAndHours(elemName) {
    RaiseOnToggleQueueOrderPhonesAndHours(elemName);
}

function OnCloseQueueOrderPhonesAndHoursPopUp() {
    RaiseOnCloseQueueOrderPhonesAndHoursPopUp();
}

function OpenReceptionWindow(deptEmployeeID) {

    var dialogWidth = 650;
    var dialogHeight = 640;
    var title = "שעות קבלה של יחידה";

    var url = "public/DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&expirationDate=''";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
}

function OpenReceptionWindowDialog(deptCode, ServiceCodes) {
    var dialogWidth = 845;
    var dialogHeight = 640;
    var title = "שעות קבלה לנותן שירות ביחידה";

    var url = "Public/DeptReceptionPopUp.aspx?deptCode=" + deptCode + "&ServiceCodes=" + ServiceCodes;

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
}


function CheckFirstNameLength(val, args) {
    var firstName = document.getElementById(txtFirstNameClientID).value;
    if (firstName != "") {
        if (firstName.length <= 50)
            args.IsValid = true;
        else
            args.IsValid = false;
    }
}


function SelectLanguage() {

    var txtLanguageListCodes = document.getElementById(txtLanguageListCodesClientID);
    var SelectedLanguageList = txtLanguageListCodes.innerText;

    var url = "Public/SelectPopUp.aspx";
    url += "?SelectedValuesList=" + SelectedLanguageList;
    url += "&popupType=4";
    url += "&returnValuesTo='txtLanguageListCodes'";
    url += "&returnTextTo='txtLanguageList'";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר שפה";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}


function SelectProfession() {
    var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
    var SelectedProfessionList = txtProfessionListCodes.innerText;
    ddlSector = document.getElementById(ddlEmployeeSectorCodeClientID);

    var url = "Public/SelectPopUp.aspx";
    url += "?SelectedValuesList=" + SelectedProfessionList;
    url += "&popupType=15&sectorType=" + ddlSector.options[ddlSector.selectedIndex].value;
    url += "&AgreementTypes= " + GetSelectedValues();
    url += getOrganizationParams();
    url += "&returnValuesTo='txtProfessionListCodes'";
    url += "&returnTextTo='txtProfessionList'";
    url += "&functionToExecute=" + "AfterProfessionSelected";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "שעות קבלה לנותן שירות ביחידה";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}

function AfterProfessionSelected() {
    var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);

    document.getElementById(cbNotReceiveGuestsClientID).checked = false;
    document.getElementById(divReceiveGuestsClientID).disabled = true;

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
        document.getElementById(cbNotReceiveGuestsClientID).checked = false;
        document.getElementById(divReceiveGuestsClientID).disabled = true;
    }
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

// "Profession" management functions
function ClearProfessionList() {
    document.getElementById(cbNotReceiveGuestsClientID).checked = false;
    document.getElementById(divReceiveGuestsClientID).disabled = true;

    if (document.getElementById(txtProfessionList_ToCompareClientID).value != document.getElementById(txtProfessionListClientID).value) {
        document.getElementById(txtProfessionList_ToCompareClientID).value = "";
        document.getElementById(txtProfessionListClientID).value = "";
        document.getElementById(txtProfessionListCodesClientID).value = "";
    }
}

function ClearLanguages(source, eventArgs) {
    document.getElementById(txtLanguageListCodesClientID).value = "";
    document.getElementById(txtLanguageListClientID).value = "";
}

// "HandicappedFacilities" management functions
function ClearHandicappedFacilitiesList() {
    if (document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value != document.getElementById(txtHandicappedFacilitiesListClientID).value) {
        document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = "";
        document.getElementById(txtHandicappedFacilitiesListClientID).value = "";
        document.getElementById(txtHandicappedFacilitiesCodesClientID).value = "";
    }
}

function UpdateAutoCompleteProfessions() {
    var membershipValues = GetSelectedValues();

    var ddlSector = document.getElementById(ddlEmployeeSectorCodeClientID);
    var sector = ddlSector.options[ddlSector.selectedIndex].value;

    var comp_ACProfessions = Sys.Application._components[AutoCompleteProfessionsClientID];

    var params = sector + "~" + membershipValues;
    comp_ACProfessions.set_contextKey(params);
}

function SyncronizeProfessionList() {
    document.getElementById(txtProfessionList_ToCompareClientID).value = document.getElementById(txtProfessionListClientID).value;
}

function SyncronizeHandicappedFacilitiesList() {
    document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = document.getElementById(txtHandicappedFacilitiesListClientID).value;
}