/// <reference name="MicrosoftAjax.js"/>

function radioClick(e) {
   
    //var obj = eventTrigger(e);
    //var str = obj.innerHTML + "\n";
    //if (obj.tagName != 'A')
      //  obj = obj.parentNode;
    //str += obj.innerHTML;
    //alert(str);
    return false;
}

function test(code) {

    var hdnCode = $get('hdnCode');
    if (hdnCode != null) {

        hdnCode.value = code;
    }
}
