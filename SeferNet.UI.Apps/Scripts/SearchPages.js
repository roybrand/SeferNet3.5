
// Function to highlight typed text in auto suggest results - in auto complete text box
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

/* The funtion set the autocomplete contextKey of the districts.
60 - The autocomplete will return only districts
60,65 - The autocomplete will return both districts and hospitals
*/
function setAutoCompleteDistricts() {
    var contextKey = getContextKeyForDistrict();
    $find('autoCompleteDistricts').set_contextKey(contextKey);

}



function setAgreemenTypesForAutoCompleteContextKeys(autoCompleteID) {
    //debugger;
    var context = $find(autoCompleteID)._contextKey;
    /* The ~ seperate the parameters, the last parameter is the membership */
    var contextArr = context.split("~");
    var arrLength = contextArr.length;
    var membershipValues = GetSelectedValues();
    var newContext = context.replace(contextArr[arrLength - 1], membershipValues);
    $find(autoCompleteID).set_contextKey(newContext);

}

function setCityCode_ClinicType_Status(autoCompleteID) {
    //debugger;
    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtUnitTypeListCodes = document.getElementById(txtUnitTypeListCodesClientID);
    var ddlStatus = document.getElementById(ddlStatusClientID);
    var txtDistrictCodes = document.getElementById(txtDistrictCodesClientID);

    var selectedValues = txtCityCode.value + ";" + txtUnitTypeListCodes.value + ";" + ddlStatus.options[ddlStatus.selectedIndex].value;
    var districtCodes = txtDistrictCodes.value;

    var context = $find(autoCompleteID)._contextKey;
    var contextArr = context.split("~");
    var arrLength = contextArr.length;

    //var newContext = context.replace(contextArr[arrLength - 2], selectedValues);
    //var newContext = contextArr[0] + "~" + selectedValues + "~" + contextArr[2];
    var newContext = districtCodes + "~" + selectedValues + "~" + contextArr[2];


    $find(autoCompleteID).set_contextKey(newContext);
    //return selectedValues;
}

function OpenServiceWindow(deptCode, deptOrEmployeeCode, serviceCode, agreementType) {
    var dialogWidth = 640;
    var dialogHeight = 690;
    var title = "שעות קבלה לשירות";

    url = "Public/ServiceHoursPopUp.aspx?deptCode=" + deptCode + "&deptOrEmployeeCode=" + deptOrEmployeeCode + "&serviceCode=" + serviceCode + "&agreementType=" + agreementType;
    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
}

function OpenSearchResultReport(reportNum,reportName) {
    var dialogWidth = 500;
    var dialogHeight = 620;
    var title = "פרמטרים לדוחות";

    var url = "Public/ReportsParametersForSearchResult.aspx?reportNum=" + reportNum.toString() + "&reportName=" + reportName;
    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
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


var mapWinWidth = 810;
var mapWinHeight = 610;

function OpenMapWindow(URL) {
    //open window in center
    var centerWidth = (window.screen.width - mapWinWidth) / 2;
    var centerHeight = (window.screen.height - mapWinHeight) / 2;

    var winChild = window.open(URL, 'מפה', 'toolbar=no,scrollbars=no,status=no,location=false,width='
        + mapWinWidth +
        ',height=' + mapWinHeight +
        ',left=' + centerWidth +
        ',top=' + centerHeight);

    winChild.focus();
}



function RaiseOnToggleQueueOrderPhonesAndHours(elemName) {
    var tblQueueHours = document.getElementById(elemName);
    var divQueueHours = document.getElementById("divQueueOrderPhonesAndHours");
    divQueueHours.innerHTML =
        "<table cellpadding='0' cellspacing='0' style='padding: 6px; background-color:White; border-radius: 3px; border-top:solid 1px #555555; border-left:solid 1px #555555; border-bottom:solid 2px #888888; border-right:solid 2px #888888;'>" +
        "<tr><td>" +
        "<table width='100%'>" +
        tblQueueHours.innerHTML +
        "</table>" +
        "</td></tr>" +
        "</table>";

    divQueueHours.style.display = 'block';
    divQueueHours.style.left = (event.clientX + document.body.scrollLeft + 10).toString() + 'px';
    divQueueHours.style.top = (event.clientY + document.body.scrollTop + 10).toString() + 'px';
}


function RaiseOnCloseQueueOrderPhonesAndHoursPopUp() {
    var divQueueHours = document.getElementById("divQueueOrderPhonesAndHours");
    divQueueHours.style.display = 'none';
}


/* Imported code from searchMasterPage */

var mapRowChosenIndex = "";

function raisePanelTopPostBackFromMaster() {
    var btn = document.getElementById(btnPostUpdatePanelTopClientID);
    btn.click();
}

var OnShowSearchParameters = null;

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

    if (OnShowSearchParameters && OnShowSearchParameters != null) {
        //raise JS event to the page in case the page want to respond to it
        //for example page can adjust its height following the current function
        OnShowSearchParameters(cbNotShowSearchParameters.checked);

        //DeptMapUC.ascx function                
        StretchMapToBottom();
    }
}


function btnShowMapSearchControlsClicked() {
    PopulateMapFrameIfRequired();
    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
    cbIsClosestPointsSearchMode.checked = !cbIsClosestPointsSearchMode.checked;
    SetSearchControlsVisibility();
}

function btnShowHideMap_Clicked() {
    var chk = $get(cbShowHideMapClientID);
    chk.checked = !chk.checked;

    //refresh map visibility in master
    ChangeMapVisibility(chk.checked);

    RefreshbtnShowHideMapText();
}

function chkShowMap_Master_Clicked(chk) {
    setMapVisibility();
}

function PopulateMapFrameIfRequired() {


    if (typeof (populateFrameWithHdnIfEmpty) == 'function') {
        populateFrameWithHdnIfEmpty();
    }


}

function ClearDistricts() {

    if (document.getElementById(txtDistrictListClientID).value == "") {

        document.getElementById(txtDistrictCodesClientID).value = "";
        document.getElementById(txtDistrictListClientID).value = "";

        var txtCityCode = document.getElementById(txtCityCodeClientID);
        var txtCityName = document.getElementById(txtCityNameClientID);
        var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

        txtCityCode.value = "";
        txtCityName.value = "";
        txtCityNameOnly.value = "";

        ClearCityCode();

        // clear city context key
        contextArr = $find("acCities")._contextKey.split(';');
        $find("acCities").set_contextKey("," + contextArr[1]);
    }
}

function getContextKeyForDistrict() {
    if (isSearchModeChecked("Hospitals") && (isSearchModeChecked("Community") || isSearchModeChecked("Mushlam")))
        return "60,65"; // Districts and hospitals
    else
        if (isSearchModeChecked("Hospitals"))
            return "60"; // Hospitals only
    return "65"; // Districts only

}

function SelectDistricts() {
    var url = "Public/SelectPopUp.aspx";

    var txtDistrictCodes = document.getElementById(txtDistrictCodesClientID);
    var txtDistrictList = document.getElementById(txtDistrictListClientID);
    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtCityName = document.getElementById(txtCityNameClientID);
    var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);
    var btnShowMapSearchControls = document.getElementById(btnShowMapSearchControlsClientID);
    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
    var SelectedDistrictsList = txtDistrictCodes.innerText;
    url = url + "?SelectedValuesList=" + SelectedDistrictsList;
    url = url + "&popupType=7&unitTypeCodes=" + getContextKeyForDistrict();
    url += "&returnValuesTo='txtDistrictCodes'";
    url += "&returnTextTo='txtDistrictList'";
    url += "&functionToExecute=" + "AfterDistrictsSelected";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר מחוז";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

    return false;
}

function AfterDistrictsSelected() {
    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtCityName = document.getElementById(txtCityNameClientID);
    var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

    txtCityCode.value = "";
    txtCityName.value = "";
    txtCityNameOnly.value = "";

    ClearCityCode();

    context = $find('acCities')._contextKey;
    contextArr = context.split(';');
    //newContext = obj.Value + ';' + contextArr[1];

    newContext = document.getElementById(txtDistrictCodesClientID).innerText + ';' + contextArr[1];

    $find('acCities').set_contextKey(newContext);

    document.getElementById(txtCityNameClientID).focus();
}

function getDistrictCode(source, eventArgs) {

    document.getElementById(txtDistrictCodesClientID).value = eventArgs.get_value();
    document.getElementById(txtDistrictListClientID).value = eventArgs.get_text();

    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtCityName = document.getElementById(txtCityNameClientID);
    var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

    txtCityCode.value = "";
    txtCityName.value = "";
    txtCityNameOnly.value = "";
    ClearCityCode();

    context = $find('acCities')._contextKey;
    contextArr = context.split(';');
    newContext = eventArgs.get_value() + ';' + contextArr[1];

    $find('acCities').set_contextKey(newContext);

    if (OnDistrictCodeChanged && OnDistrictCodeChanged != null) {
        OnDistrictCodeChanged(eventArgs.get_value());
    }
}

function ClearCityCode() {

    if (document.getElementById(txtCityNameClientID).value == "") {

        Clear_Street_Nbd_Site_House_SearchControls();
        ClearCitySearchControls();

        // If CityCode is NOT selected then controls for MapSearch are NOT to be in use
        var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
        cbIsClosestPointsSearchMode.checked = false;

        SetSearchControlsVisibility();
    }
}

function ClearCitySearchControls() {
    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtCityName = document.getElementById(txtCityNameClientID);
    var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);
    txtCityCode.value = "";
    txtCityName.value = "";
    txtCityNameOnly.value = "";
}

function OnDDCityCodeSelected(source, eventArgs) {

    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

    var value = eventArgs.get_value();
    var valueArray = value.split("~");

    txtCityCode.value = valueArray[0];
    txtCityNameOnly.value = valueArray[1];

    var txtCityName = document.getElementById(txtCityNameClientID);
    txtCityName.value = eventArgs.get_text();

    // If CityCode is selected then controls for MapSearch are to be in use


    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
    cbIsClosestPointsSearchMode.checked = false;

    Clear_Street_Nbd_Site_House_SearchControls();
    SetSearchControlsVisibility();

    // change auto complete context by the selected city
    $find(autoCompleteNeighborhoodClientID).set_contextKey(txtCityCode.value);
    $find(autoCompleteStreetsClientID).set_contextKey(txtCityCode.value);
    //$find(autoCompleteSiteClientID).set_contextKey(txtCityCode.value);
}

function Clear_Street_Nbd_Site_House_SearchControls_IfRequired() {
    //clear the map search controls in case the button is closed

    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);

    //closest points search
    if (cbIsClosestPointsSearchMode.checked == false) {
        Clear_Street_Nbd_Site_House_SearchControls();
    }
}

function Clear_Street_Nbd_Site_House_SearchControls() {
    var txtNeighborhood = document.getElementById(txtNeighborhoodAndSiteID);
    var txtNeighborhoodCode = document.getElementById(txtNeighborhoodAndSiteCodeID);
    var txtIsSite = document.getElementById(txtIsSiteID);

    var txtStreet = document.getElementById(txtStreetClientID);
    var txtHouse = document.getElementById(txtHouseClientID);

    txtNeighborhood.value = "";
    txtNeighborhoodCode.value = "";
    txtIsSite.value = "";

    txtStreet.value = "";
    txtHouse.value = "";
}



function CompareHours(val, args) {
    var openingTime = document.getElementById(txtFromHourClientID).value;
    var closingTime = document.getElementById(txtToHourClientID).value;
    var inTime = document.getElementById(txtAtHourClientID).value;

    if (openingTime != "") {
        var openingTimeArr = openingTime.split(':');
        var fromHour = openingTimeArr[0];
        var fromMinute = openingTimeArr[1];
    }
    else {
        var fromHour = '00';
        var fromMinute = '00';
    }

    if (closingTime != "") {
        var closingTimeArr = closingTime.split(':');
        var toHour = closingTimeArr[0];
        var toMinute = closingTimeArr[1];
    }
    else {
        var toHour = '23';
        var toMinute = '59';
    }

    if (inTime != "") {
        var inTimeArr = inTime.split(':');
        var inHour = inTimeArr[0];
        var inMinute = inTimeArr[1];
    }
    else {
        var inHour = '00';
        var inMinute = '00';
    }

    var FromHourInt = parseInt(fromHour, 10);
    var FromMinuteInt = parseInt(fromMinute, 10);

    var ToHourInt = parseInt(toHour, 10);
    var ToMinuteInt = parseInt(toMinute, 10);

    var InHourInt = parseInt(inHour, 10);
    var InMinuteInt = parseInt(inMinute, 10);

    var receptionDateFrom = new Date();
    if (FromHourInt <= 23 && FromHourInt <= 59) // if hour or minutes are not valid - the other validator handles that
        receptionDateFrom.setHours(FromHourInt, FromMinuteInt, 0, 0);

    var receptionDateTo = new Date();
    if (ToHourInt <= 23 && ToMinuteInt <= 59) // if hour or minutes are not valid - the other validator handles that
        receptionDateTo.setHours(ToHourInt, ToMinuteInt, 0, 0);

    var receptionDateIn = new Date();
    if (InHourInt <= 23 && InMinuteInt <= 59) // if hour or minutes are not valid - the other validator handles that
        receptionDateIn.setHours(InHourInt, InMinuteInt, 0, 0);

    if (inTime == "") {
        if (receptionDateFrom < receptionDateTo)
            args.IsValid = true;
        else
            args.IsValid = false;
    }
    else {
        if ((receptionDateFrom < receptionDateTo) && (receptionDateIn <= receptionDateTo && receptionDateIn >= receptionDateFrom))
            args.IsValid = true;
        else
            args.IsValid = false;
    }
}

function Fill_Open_Close_Hours_Together(val, args) {
    var openingTime = document.getElementById(txtFromHourClientID).value;
    var closingTime = document.getElementById(txtToHourClientID).value;

    if ((openingTime != "" && closingTime != "") || (openingTime == "" && closingTime == "")) {
        args.IsValid = true;
    }
    else {
        args.IsValid = false;
    }
}

//call this on check change and when page load ( register client script)
function setMapVisibility() {


    var pnlDeptMapControl = $get(pnlDeptMapControlClientID);
    var chkShowMap_PageCondition = $get(cbAllowShowMap_PageConditionClientID);


    if ($get(cbShowHideMapClientID).checked == true) {
        //show map
        pnlDeptMapControl.style.width = "694px";
    }
    else {
        //hide map
        pnlDeptMapControl.style.width = "0px";
    }
}

function isMapVisible() {

    var pnlDeptMapControl = $get(pnlDeptMapControlClientID);
    if (pnlDeptMapControl.style.width == "0px") {
        return false;
    }
    else {
        return true;
    }
}


function mapImageClicked() {
    //that always shows the map - it sets the flag for showing the map to true

    //we check the show map checkBox in case it's not checked and we show the map

    var chkShowMap = $get(cbShowHideMapClientID);
    var chkShowMap_PageCondition = $get(cbAllowShowMap_PageConditionClientID);

    chkShowMap_PageCondition.checked = true;

    if (chkShowMap.checked == false) {
        chkShowMap.checked = true;

        setMapVisibility();
    }



}

function ChangeMapVisibility(isChecked) {
    var chkShowMap = $get(cbShowHideMapClientID);
    chkShowMap.checked = isChecked;
    setMapVisibility();
}

//****************** begin show hide map button click and visibility handling




function RefreshbtnShowHideMapText() {
    var cbClosestSearch = $get(cbIsClosestPointsSearchModeClientID);
    var divButtonsShowHideMap = $get(divButtonsShowHideMapClientID);

    var chk = $get(cbShowHideMapClientID);
    //change text
    var btnShow = $get(btnShowMapClientID);
    var btnHide = $get(btnHideMapClientID);

    if (chk.checked == true) {
        btnShow.style.display = "none";
        btnHide.style.display = "inline";
    }
    else {
        btnShow.style.display = "inline";
        btnHide.style.display = "none";
    }

    if (cbClosestSearch.checked == true || isMapVisible() == true)
        divButtonsShowHideMap.style.display = "inline";
    else
        divButtonsShowHideMap.style.display = "none";

}

//****************** END show hide map button click and visibility handling

//***************************************begin map search controls script

//consts colors
var whiteColor = "White";
var showControlsColor = "E8F4FD";








var OnDistrictCodeChanged = null;
var OnMapSearchControlsExpanded = null;
var OnMapSearchControlsCollapsed = null;




//register events on window load
if (window.addEventListener) {
    window.addEventListener('load', OnWindowLoaded, false); //W3C
}
else {
    window.attachEvent('onload', OnWindowLoaded); //IE    
}

function OnWindowLoaded() {

    InitPageCommon();

    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endAjaxPostback);
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(beginAjaxPostback);

    SetSearchControlsVisibility();
    setMapVisibility();

    //DeptMapUC.ascx function
    StretchMapToBottom();

}

function InitPageCommon() {

    OnMapSearchControlsExpanded = ActionOnMapSearchControlsExpanded;
    OnMapSearchControlsCollapsed = ActionOnMapSearchControlsCollapsed;
    OnShowSearchParameters = ActionOnShowSearchParameters;

    InitPage();
}



//This is the place for any code that wants to be called before an ajax post back
function beginAjaxPostback(sender, e) {
    if (sender._postBackSettings.sourceElement.id == btnSubmitClientID) {

    }

}

function endAjaxPostback(sender, e) {
    SetSearchControlsVisibility();

    //DeptMapUC.ascx function
    StretchMapToBottom();

    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
    var chkShowHideMap = $get(cbShowHideMapClientID);

    if (sender._postBackSettings.sourceElement == "udefined"
        || sender._postBackSettings.sourceElement == null) {
        return;
    }

    //set the visibility of the show\hide map button and also the the visibility map
    if (sender._postBackSettings.sourceElement.id == btnSubmitClientID) {
        //coming back from post back

        var chkShowMap = $get(chkShowMapClientID);


        //closest points search
        if (cbIsClosestPointsSearchMode.checked) {

            if (chkShowMap.checked) {
                chkShowHideMap.checked = true;
            }
            else {
                chkShowHideMap.checked = false;

            }
        }

        //non closest points search - always starts hidden map
        else {
            //DeptMapUC.ascx function
            if (typeof (clearMap) == 'function') {
                clearMap();
            }

            chkShowHideMap.checked = false;
        }


        setMapVisibility();

        RefreshbtnShowHideMapText();

        if (cbIsClosestPointsSearchMode.checked) {
            SpreadClosestPointsOnMap();
        }
    }


    //meaning we came back from the server after map image we clicked and
    //now we need to fill the map with 1 clinic that was clicked on
    //In non closest points search mode!!!
    else if (sender._postBackSettings.sourceElement.id.endsWith('imgMap') && cbIsClosestPointsSearchMode.checked == false) {
        SpreadClosestPointsOnMap();
        chkShowHideMap.checked = true;

        setMapVisibility();

        RefreshbtnShowHideMapText();
    }

}

function SpreadClosestPointsOnMap() {

    var hdnXML = $get(DeptMapControlhdnClinicJsonClientId);
    if (hdnXML.value != '') {
        //DeptMapControl
        sendCommand('SendData', hdnXML.value);
    }


}

function setRowColor(rowInd) {

    /* Set the last selected row to regular colors */
    $("#tblResults").find(".trPlain_marked").removeClass("trPlain_marked").addClass("trPlain");

    /* Set the selected row to marked colors */
    var selectedRow = $("#tblResults").find(".trPlain");
    selectedRow[rowInd].className = "trPlain_marked";
}

//***************************************end map search controls script

//function SetSearchControlsVisibility() {
//    var trMapSearch_1 = $("[id$='trMapSearch_1']")[0];
//    var trMapSearch_2 = $("[id$='trMapSearch_2']")[0];
//    var trMapSearch_3 = $("[id$='trMapSearch_3']")[0];
//    var trMapSearch_4 = $("[id$='trMapSearch_4']")[0];

//    var trMapSearch_City = $("[id$='trMapSearch_City']")[0];

//    var btnShowMapSearchControls = $("[id$='btnShowMapSearchControls']")[0];
//    var txtCityCode = $("[id$='txtCityCode']")[0];
//    var cbIsClosestPointsSearchMode = $("[id$='cbIsClosestPointsSearchMode']")[0];

//    if (txtCityCode.value == "")
//        cbIsClosestPointsSearchMode.checked = false;

//    // Close
//    if (cbIsClosestPointsSearchMode.checked == false) {
//        trMapSearch_1.style.display = "none";
//        trMapSearch_2.style.display = "none";
//        trMapSearch_3.style.display = "none";
//        trMapSearch_4.style.display = "none";

//        trMapSearch_1.style.backgroundColor = whiteColor;
//        trMapSearch_2.style.backgroundColor = whiteColor;
//        trMapSearch_3.style.backgroundColor = whiteColor;
//        trMapSearch_4.style.backgroundColor = whiteColor;
//        trMapSearch_City.style.backgroundColor = whiteColor;

//        if (OnMapSearchControlsCollapsed && OnMapSearchControlsCollapsed != null) {
//            OnMapSearchControlsCollapsed();
//            StretchMapToBottom();
//        }
//    }

//    //Open
//    else {
//        trMapSearch_1.style.display = "inline";
//        trMapSearch_2.style.display = "inline";
//        trMapSearch_3.style.display = "inline";
//        trMapSearch_4.style.display = "inline";


//        trMapSearch_1.style.backgroundColor = showControlsColor;
//        trMapSearch_2.style.backgroundColor = showControlsColor;
//        trMapSearch_3.style.backgroundColor = showControlsColor;
//        trMapSearch_4.style.backgroundColor = showControlsColor;
//        trMapSearch_City.style.backgroundColor = showControlsColor;

//        if (OnMapSearchControlsExpanded && OnMapSearchControlsExpanded != null) {
//            OnMapSearchControlsExpanded();

//            //DeptMapUC.ascx function
//            StretchMapToBottom();
//        }
//    }

//    if (txtCityCode.value == "") {
//        btnShowMapSearchControls.style.display = "none";
//    }
//    else {
//        btnShowMapSearchControls.style.display = "inline";
//        if (cbIsClosestPointsSearchMode.checked == false) {

//            btnShowMapSearchControls.src = "Images/Applic/btn_Plus_Green.jpg";
//        }
//        else {

//            btnShowMapSearchControls.src = "Images/Applic/btn_Cross_Blue.jpg";
//        }
//    }
//}

function SetSearchControlsVisibilityTEST() {
    //var trMapSearch_City = $("[id$='trMapSearch_City']")[0];

    //var btnShowMapSearchControls = $("[id$='btnShowMapSearchControls']")[0];
    //var txtCityCode = $("[id$='txtCityCode']")[0];
    var txtCityCode = document.getElementById(txtCityCodeClientID);
    //var cbIsClosestPointsSearchMode = $("[id$='cbIsClosestPointsSearchMode']")[0];
    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);
    alert(txtCityCode.value);
    if (txtCityCode.value == "")
        cbIsClosestPointsSearchMode.checked = false;
    else {
        cbIsClosestPointsSearchMode.checked = true;
    }
    //if (txtCityCode.value == "")
    //    checked = false;

    // Close
    if (cbIsClosestPointsSearchMode.checked == false) {
    //if (checked == false) {
        trMapSearch_1.style.display = "none";
        trMapSearch_2.style.display = "none";
        trMapSearch_3.style.display = "none";
        trMapSearch_4.style.display = "none";

        trMapSearch_1.className = "BG_Color_White";
        trMapSearch_2.className = "BG_Color_White";
        trMapSearch_3.className = "BG_Color_White";
        trMapSearch_4.className = "BG_Color_White";
        //trMapSearch_City.className = "BG_Color_White";

        //if (OnMapSearchControlsCollapsed && OnMapSearchControlsCollapsed != null) {
        //    OnMapSearchControlsCollapsed();
        //    StretchMapToBottom();
        //}
    }

    //Open
    else {
        trMapSearch_1.style.display = "";
        trMapSearch_2.style.display = "";
        trMapSearch_3.style.display = "";
        trMapSearch_4.style.display = "";


        trMapSearch_1.className = "BG_Color_LightBlue";
        trMapSearch_2.className = "BG_Color_LightBlue";
        trMapSearch_3.className = "BG_Color_LightBlue";
        trMapSearch_4.className = "BG_Color_LightBlue";
        //trMapSearch_City.className = "BG_Color_LightBlue";

        //if (OnMapSearchControlsExpanded && OnMapSearchControlsExpanded != null) {
        //    OnMapSearchControlsExpanded();

        //    StretchMapToBottom();
        //}
    }

    //if (txtCityCode.value == "") {
    //    btnShowMapSearchControls.style.display = "none";
    //}
    //else {
    //    btnShowMapSearchControls.style.display = "inline";
    //    if (cbIsClosestPointsSearchMode.checked == false) {

    //        btnShowMapSearchControls.src = "Images/Applic/btn_Plus_Green.jpg";
    //    }
    //    else {

    //        btnShowMapSearchControls.src = "Images/Applic/btn_Cross_Blue.jpg";
    //    }
    //}
}

function SetSearchControlsVisibility() {
    var trMapSearch_City = document.getElementById(trMapSearch_CityClientID);

    var btnShowMapSearchControls = document.getElementById(btnShowMapSearchControlsClientID);

    var txtCityCode = document.getElementById(txtCityCodeClientID);
    var cbIsClosestPointsSearchMode = document.getElementById(cbIsClosestPointsSearchModeClientID);

    if (txtCityCode.value == "")
        cbIsClosestPointsSearchMode.checked = false;

    // Close
    if (cbIsClosestPointsSearchMode.checked == false) {
        trMapSearch_1.style.display = "none";
        trMapSearch_2.style.display = "none";
        trMapSearch_3.style.display = "none";
        trMapSearch_4.style.display = "none";

        trMapSearch_1.className = "BG_Color_White";
        trMapSearch_2.className = "BG_Color_White";
        trMapSearch_3.className = "BG_Color_White";
        trMapSearch_4.className = "BG_Color_White";
        trMapSearch_City.className = "BG_Color_White";

        if (OnMapSearchControlsCollapsed && OnMapSearchControlsCollapsed != null) {
            OnMapSearchControlsCollapsed();
            StretchMapToBottom();
        }
    }

    //Open
    else {
        trMapSearch_1.style.display = "";
        trMapSearch_2.style.display = "";
        trMapSearch_3.style.display = "";
        trMapSearch_4.style.display = "";

        trMapSearch_1.className = "BG_Color_LightBlue";
        trMapSearch_2.className = "BG_Color_LightBlue";
        trMapSearch_3.className = "BG_Color_LightBlue";
        trMapSearch_4.className = "BG_Color_LightBlue";
        trMapSearch_City.className = "BG_Color_LightBlue";

        if (OnMapSearchControlsExpanded && OnMapSearchControlsExpanded != null) {
            OnMapSearchControlsExpanded();

            //DeptMapUC.ascx function
            StretchMapToBottom();
        }
    }

    if (txtCityCode.value == "") {
        btnShowMapSearchControls.style.display = "none";
    }
    else {
        btnShowMapSearchControls.style.display = "inline";
        if (cbIsClosestPointsSearchMode.checked == false) {

            btnShowMapSearchControls.src = "Images/Applic/btn_Plus_Green.jpg";
        }
        else {

            btnShowMapSearchControls.src = "Images/Applic/btn_Cross_Blue.jpg";
        }
    }
}






/* End imported code SearchMasterPage */

/* Imported code from search chpages */

function featuresForPopUp() {
    return FeaturesForModalDialogPopup();
}


function SelectHandicappedFacilities() {
    var url = "Public/SelectPopUp.aspx";
    var txtHandicappedFacilitiesCodes = document.getElementById(txtHandicappedFacilitiesCodesClientID);
    var txtHandicappedFacilitiesList = document.getElementById(txtHandicappedFacilitiesListClientID);
    var SelectedHandicappedFacilitiesList = txtHandicappedFacilitiesCodes.innerText;
    url = url + "?SelectedValuesList=" + SelectedHandicappedFacilitiesList;
    url = url + "&popupType=8";
    url = url + "&returnValuesTo='txtHandicappedFacilitiesCodes'";
    url = url + "&returnTextTo='txtHandicappedFacilitiesList'";

    var dialogWidth = 420;
    var dialogHeight = 660;
    var title = "בחר הערכות לנכים";

    OpenJQueryDialog(url, dialogWidth, dialogHeight, title); 
}

function ActionOnMapSearchControlsExpanded() {
    StretchElementHeightToBottomAccordingToScreenCommon(idOfdivGrid);
}

function ActionOnMapSearchControlsCollapsed() {
    StretchElementHeightToBottomAccordingToScreenCommon(idOfdivGrid);
}

function ActionOnShowSearchParameters() {
    StretchElementHeightToBottomAccordingToScreenCommon(idOfdivGrid);
}



function hideProgressBar() {
    document.getElementById("divProgressBar").style.visibility = "hidden"
}

function showProgressBar(validation_group) {
    var isValid = Page_ClientValidate(validation_group);
    if (isValid) {
        document.getElementById("divProgressBar").style.visibility = "visible";
    }


}

/* End imported code from search pages */


function getOrganizationParams() {
    var res = "";
    var selectedOrgValues = GetSelectedValues().split(",");
    $.each(selectedOrgValues, function () {
        switch (this.toString()) {
            case "Community":
                res += "&isInCommunity=true";
                break;
            case "Mushlam":
                res += "&isInMushlam=true";
                break;
            case "Hospitals":
                res += "&isInHospitals=true";
                break;
        }
    });
    return res;
}


function getSelectedNeighborhoodAndSiteCode(source, eventArgs) {

    var txtNeighborhoodAndSiteCode = document.getElementById(txtNeighborhoodAndSiteCodeID);
    var txtIsSite = document.getElementById(txtIsSiteID);
    var txtNeighborhoodAndSite = document.getElementById(txtNeighborhoodAndSiteID);
    var autocompleteValue = eventArgs.get_value().split(",");

    txtNeighborhoodAndSiteCode.value = autocompleteValue[0];
    txtIsSite.value = autocompleteValue[1];
    txtNeighborhoodAndSite.value = eventArgs.get_text();
}

function CleanNeighborhoodAndSiteCode() {
    var txtNeighborhoodAndSiteCode = document.getElementById(txtNeighborhoodAndSiteCodeID);
    var txtIsSite = document.getElementById(txtIsSiteID);
    var txtNeighborhoodAndSite = document.getElementById(txtNeighborhoodAndSiteID);

    txtNeighborhoodAndSiteCode.value = "";
    txtIsSite.value = "";
    txtNeighborhoodAndSite.value = "";
}