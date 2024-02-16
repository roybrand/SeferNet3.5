/// <reference name="MicrosoftAjax.js"/>
function test123() { 
alert('123123')
}

function setFemaleProficiency() {
    PageMethods.OnChangeText(OnSucceeded, OnFailed);
}

function OnSucceeded() {
    $get("txtProficiencyFemale").value = $get("txtProficiencyMale").value;
}

function OnFailed(error) {

    alert(error.get_message());
}


function changeDdlCategory( category) {
    var x = document.getElementById("ddlRetrainingCategory");
       
    for (i = 0; i < x.length; i++) {
        if(x.options[i].text == category)
        {
            x.selectedIndex = i;
            return;
        }
    }
}

function warning(msg) 
{
    var txtParentCode = $get('txtParentCode');
    if (txtParentCode != null && txtParentCode.value != "") {
        var btnParentDelete = $get("btnParentDelete");
        btnParentDelete.click();
       
        var ddlRetrainingCategory = $get("ddlRetrainingCategory");
        alert(msg);
    }
}

function clearOldCode() {

//    var txtOldCode = $get('txtOldCode');
//    var txtOldDesc = $get('txtOldDesc');
//    
//    if (txtOldCode != null)
//        txtOldCode = "";

//    if (txtOldDesc != null)
    //        txtOldDesc = "";
  
    var btnDeleteOldCode = $get('btnDeleteOldCode');
    btnDeleteOldCode.click();
}


//call function when user has parent code 
//and wants to changes retrain category 
function ChangeCategory(msg)
{
    var hdnChoice = $get('hdnChoice');
    if (confirm(msg)) 
    {
        hdnChoice.value = '1';
    }
    else 
    { 
        hdnChoice.value = '2';
        var ddlRetrainingCategory = $get('ddlRetrainingCategory'); 
        if (ddlRetrainingCategory.selectedIndex == 0)
        ddlRetrainingCategory.selectedIndex = 1 ;
        else ddlRetrainingCategory.selectedIndex = 0;
    }
}
 
 
function searchOldCode() {
   
    var txtOldDesc = $get("txtOldDesc");
    if (txtOldDesc != null) {
        var ddlCategory = $get("ddlCategory");
        //var category = parseInt(ddlCategory.value) +1;

        if (txtOldDesc.value != null && txtOldDesc.value != '') {
            window.open('../Admin/ListOldOperations.aspx?oldCode=' + ddlCategory.value + '&oldCodeDesc=' + txtOldDesc.value, null,
    "width=500,resizable=yes,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes");
        }
        else
            window.open('../Admin/ListOldOperations.aspx?oldCode=' + ddlCategory.value,null,
    "width=500,resizable=yes,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes");

    }
}


function searchTableCode() {

    var url = "";
    var ddlTableCode = $get("ddlTableCode");
    var txtTblDesc = $get("txtTblDesc");
    var txtOldCode = $get("txtOldCode");
    var selectedTable = "";

    if (ddlTableCode != null) {

        if (ddlTableCode.selectedIndex == 0)
            selectedTable = "5";
        else if (ddlTableCode.selectedIndex == 1)
            selectedTable = "3";
        else if (ddlTableCode.selectedIndex == 2)
            selectedTable = "4";


        url = '../Admin/ListMFCodes.aspx?tableCode=' + selectedTable;

        if (txtTblDesc != null && txtTblDesc.value != "") {
            url += "&tableDesc=" + txtTblDesc.value;
        }
            
        if (txtOldCode != null && txtOldCode.value != "") {
            url += "&oldCode=" + txtOldCode.value;
        }
        else
            url += "&noOldCode=true" ;
        

        if (url != "")
            window.open(url, null,
    "width=500,resizable=yes,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes");
    }
}


function searchParentCode() {
    
    var txtParentDesc = $get("txtParentDesc");
    var txtTblCode = $get("txtTblCode");
    var txtNewDesc = $get("txtNewDesc");
    var ddlRetrainingCategory = $get("ddlRetrainingCategory");
    var txtOldCode = $get("txtOldCode");

    var url = "";

    if (txtParentDesc != null) {
        if (txtTblCode != null && txtTblCode.value != '') {
            url = '../Admin/ListOldOperations.aspx?childServiceID=' + txtTblCode.value;

            if (txtNewDesc != null && txtNewDesc.value != "") {
                url += "&childServiceDesc=" + txtNewDesc.value;
            }

            if (ddlRetrainingCategory != null && ddlRetrainingCategory.value != "") {

                url += "&category=" + ddlRetrainingCategory[ddlRetrainingCategory.selectedIndex].innerHTML;
            }

            if (txtOldCode != null && txtOldCode.value != "") {
                url += "&oldCode=" + txtOldCode.value;

            }

            if (txtParentDesc != null && txtParentDesc.value != "") {
                url += "&parentDesc=" + txtParentDesc.value;
            }

            window.open(url, null,
    "width=500,resizable=yes,status=yes,toolbar=no,menubar=no,location=no,scrollbars=yes");
        }
    }   
}