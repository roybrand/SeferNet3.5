/// <reference name="MicrosoftAjax.js"/>
function check(val, args) {
    //debugger;

    var isNew = '<%= isNew %>';
    var count = 0;

   
    var cbEnableOverlappingHours = document.getElementById('dvGeneralRemarks_cbEnableOverlappingHours');
    if (cbEnableOverlappingHours != null && cbEnableOverlappingHours.checked == true) {

        count++;
        saveSelectedValues('cbEnableOverlappingHours');
    }

    var cblinkedToDept = document.getElementById('dvGeneralRemarks_cblinkedToDept');
    if (cblinkedToDept != null && cblinkedToDept.checked == true) {

        count++;
        saveSelectedValues('cblinkedToDept');
    }

    var cbActive = document.getElementById('dvGeneralRemarks_cbActive');
    if (cbActive != null && cbActive.checked == true) {

        saveSelectedValues('cbActive');
       // count++;
    }

    var cblinkedToDoctor = document.getElementById('dvGeneralRemarks_cblinkedToDoctor');
    if (cblinkedToDoctor != null && cblinkedToDoctor.checked == true) {

        count++;
        saveSelectedValues('cblinkedToDoctor');
    }

    var cblinkedToServiceInClinic = document.getElementById('dvGeneralRemarks_cblinkedToServiceInClinic');
    if (cblinkedToServiceInClinic != null && cblinkedToServiceInClinic.checked == true) {

        count++;
        saveSelectedValues('cblinkedToServiceInClinic');
    }

    var cblinkedToReceptionHours = document.getElementById('dvGeneralRemarks_cblinkedToReceptionHours');
    if (cblinkedToReceptionHours != null && cblinkedToReceptionHours.checked == true) {

        count++;
        saveSelectedValues('cblinkedToReceptionHours');
    }

    if (count > 0)
        args.IsValid = true;
    else
        args.IsValid = false;

    //}
}


function saveSelectedValues(checkBox) {
    var hdn_cbActive = null;
           
    switch(checkBox)
    {
        case 'cbEnableOverlappingHours':
            hdn = $get('hdn_cbEnableOverlappingHours')
            hdn.value = "1";      
        break;    
        case 'cblinkedToDept':
                hdn = $get('hdn_cblinkedToDept')
                hdn.value = "1";      
            break;    
         case 'cbActive':
                hdn = $get('hdn_cbActive')
                hdn.value = "1";      
            break;    
        case 'cblinkedToDoctor':
            hdn = $get('hdn_cblinkedToDoctor')
            hdn.value = "1";      
        break;    
         case 'cblinkedToServiceInClinic':
            hdn = $get('hdn_cblinkedToServiceInClinic')
            hdn.value = "1";      
        break;       
         case 'cblinkedToReceptionHours':
            hdn = $get('hdn_cblinkedToReceptionHours')
            hdn.value = "1";      
        break; 
    
    }
}


function test() {

    var hdn = $get('hdn_cbEnableOverlappingHours')
  hdn.style.display = "inline";
}