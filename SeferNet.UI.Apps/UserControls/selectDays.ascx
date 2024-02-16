<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_selectDays" Codebehind="selectDays.ascx.cs" %>
<script type="text/javascript">

    /* The control is table of days - implementing checkboxes */
    /* For each checkbox click event, the function onDayClick is excute 
       and set the strSelectedDays string with the selected values, and then call selectedtDaysHasBeenSet().
       This function need to be implement if you wish to use the selected values.
    */
    
    var tblDaysIsOpen = false;
    var strSelectedDays = "";

    function onDayClick(obj) {
        
        
        var cbChecked = $("#<%=tblDays.ClientID %> input:checked");
        strSelectedDays = "";
        
        for (var i = 0; i < cbChecked.length; i++) {
            if (strSelectedDays != "") {
                strSelectedDays += "," + $("label[for='" + cbChecked[i].id + "']").text();
            }
            else {
                strSelectedDays = $("label[for='" + cbChecked[i].id + "']").text();
            }

        }

        selectedtDaysHasBeenSet();
        
    }

    

    function closeTableDays() {
        tblDaysIsOpen = false;
        $("#<%=tblDays.ClientID %>").hide();

    }

    function openTableDays(top,left) {
        if (typeof top != "undefined") {
            document.getElementById("<%=tblDays.ClientID %>").style.top = top + "px";
        }
        if (typeof left != "undefined") {
            document.getElementById("<%=tblDays.ClientID %>").style.left = (left - 120) + "px";
        }    
        
        document.getElementById("<%=tblDays.ClientID %>").style.display = "block";
        tblDaysIsOpen = true;
    }


    /* Set the check boxes acording to the values.
       The values must be seperated by ',' 
    */
    function setChecks(strValues) {

        var currentVals = strValues.split(",");
        var cbChecked = $("#<%=tblDays.ClientID %> input:checkbox");

        for (var i = 0; i < cbChecked.length; i++) {
            var cbText = $("label[for='" + cbChecked[i].id + "']").text();
            if (!valExist(currentVals,cbText)) {
                cbChecked[i].checked = false;
            }
            else {
                cbChecked[i].checked = true;
            }


        }
    }
    
    function valExist(arrStr, val) {
        var res = false;
        $.each(arrStr, function () {
            if (this == val) {
                res = true;
            }
        });
        return res;
    }

    


    

</script>

<table id="tblDays" runat="server" dir="rtl" cellpadding="0" cellspacing="3" style="position:absolute; display:none;background-color:#f7f7f7;border:1px solid black;z-index:10;"></table>


    
