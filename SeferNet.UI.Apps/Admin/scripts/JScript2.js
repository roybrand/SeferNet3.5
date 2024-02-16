/// <reference name="MicrosoftAjax.js"/>
function saveRowIndex(rowIndex) {
    GridTest.SimpleService.NoteChangedRows(rowIndex);
}

function changeColor(obj) {

    var rowObject = getParentRow(obj);
    var parentTable = document.getElementById("dgTables");
    var color = '';


    if (color == '') {
        color = getRowColor();
    }
    if (obj.checked) {
        rowObject.style.backgroundColor = 'Yellow';
    }
    else {
        rowObject.style.backgroundColor = color;
        color = '';
    }


    // private method
    function getRowColor() {
        if (rowObject.style.backgroundColor == '')
            return parentTable.style.backgroundColor;
        else
            return rowObject.style.backgroundColor;

    }

    function getParentRow(obj) {
        do {
            if (isFireFox()) {
                obj = obj.parentNode;
            }

            else {

                obj = obj.parentElement;
            }
        }
        while (obj.tagName != "TR")
        return obj;

    }

    function isFireFox() {
        return navigator.appName == "Netscape";
    }
}

// large GridView has low performance if it is in Update panel
//this  is solution
// $get('<%=GridViewID.ClientID%>').
var pageRequestManager = Sys.WebForms.PageRequestManager.getInstance();
pageRequestManager.add_pageLoading(onPageLoading);
function onPageLoading(sender, e) {

    var gv = $get("dgTables");
    if (gv != null)
        gv.parentNode.removeNode(gv);
}

function confirmDelete() {
    if (confirm("? האם למחוק את הנתונים "))
        return true;
    else
        return false;
}


function pageLoad() {
    //var txtNoDigits = $get('dgTables_ctl01_txtSearchName');
    //$addHandler(txtNoDigits,'keypress', txtNoDigits_keypress);
}
function pageUnload() {
    //$removeHandler($get('dgTables_ctl01_txtSearchName'), 'keypress', txtNoDigits_keypress);
}
function txtNoDigits_keypress(evt) {
    //    var code = evt.charCode;
    //    if (code == 13) 
    //    {
    //        evt.preventDefault();
    //        alert('לחץ את הכפתור ');
    //    }
}
//function setFemaleProficiency() {
//    PageMethods.OnChangeText(OnSucceeded, OnFailed);
//}

//function OnSucceeded() {
//    $get("txtProficiencyFemale").value = $get("txtProficiencyMale").value;
//}

//function OnFailed(error) {

//    alert(error.get_message());
//}







