/// <reference name="MicrosoftAjax.js"/>
function ScrollDivToSelected(obj, txtClientID) {
    
    if (document.getElementById(obj) != null) {
        var pnlGrid = document.getElementById(obj);

        if ( document.getElementById(txtClientID) != null) {
            var scrollPosition = document.getElementById(txtClientID).value;
           
            if (pnlGrid!= null &&  scrollPosition != null) {
                pnlGrid.scrollTop = scrollPosition;
                
            }
    }
    }       
}

function GetScrollPosition(obj, txtClientID) {

    if (document.getElementById(obj) != null) {
        var pnlGrid = document.getElementById(obj);

        if (document.getElementById(txtClientID) != null && pnlGrid.scrollTop != null)
        document.getElementById(txtClientID).value = pnlGrid.scrollTop;
    }
  
}