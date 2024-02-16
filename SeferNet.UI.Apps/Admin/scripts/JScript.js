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
    gv.parentNode.removeNode(gv);
}
