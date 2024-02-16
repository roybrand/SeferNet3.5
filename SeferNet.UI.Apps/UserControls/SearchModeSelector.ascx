<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_SearchModeSelector" Codebehind="SearchModeSelector.ascx.cs" %>

<style type="text/css">
       .selected
       {
        color: blue;
       }
</style>



<script type="text/javascript">

    function GetSelectedValues() {

        var checkboxes = $('#' + '<%= lstModes.ClientID %>').closest("tr").find("input:checkbox");

        var selectedValues = '';

        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked)
                selectedValues += $('#' + checkboxes[i].id).closest("span").attr("itemValue") + ',';
        }

        if (selectedValues.length > 0)
            selectedValues = selectedValues.substring(0, selectedValues.length - 1);
        return selectedValues;
    }

    function GetSelectedIndexes() {

        var checkboxes = $('#' + '<%= lstModes.ClientID %>').closest("tr").find("input:checkbox");

        var selectedValues = '';

        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                var tmpLength = checkboxes[i].id.split("_").length;
                selectedValues += checkboxes[i].id.split("_")[tmpLength - 1] + ',';
            }
        }

        if (selectedValues.length > 0)
            selectedValues = selectedValues.substring(0, selectedValues.length - 1);
        return selectedValues;
    }


    /* isSearchModeChecked: It get string - Community, Mushlam, Hospitals or All
       and check if it selected. */
    function isSearchModeChecked(str) {

        var checkboxes = $('#' + '<%= lstModes.ClientID %>').closest("tr").find("input:checkbox");
        var res = false;
        
        for (var i = 0; i < checkboxes.length; i++) {
            if ($('#' + checkboxes[i].id).closest("span").attr("itemValue") == str)
            {
                if (checkboxes[i].checked) {
                    res = true;
                    break;
                }
            }
        }

        return res;
    }
    

    


    function EnableBySelection(itemID, allItem) {
        
        var item = $("#" + itemID);
        var myAgreementTypeList = "";
        var checkboxes = $("#" + itemID).closest("tr").find("input:checkbox");
        if (allItem) {

            var allItemIsChecked = item[0].checked;

            // check or uncheck according to the "all" item
            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = allItemIsChecked;

                if (checkboxes[i].id != itemID) {
                    if (checkboxes[i].checked)
                        $('#' + checkboxes[i].id).closest("span").addClass('selected');
                    else
                        $('#' + checkboxes[i].id).closest("span").removeClass('selected');
                }

            }

            if (allItemIsChecked)
                myAgreementTypeList = GetListByID("all");

        }
        else { // uncheck the "all" item

            $('#' + itemID).closest("tr").find("input:checkbox")[0].checked = false;

            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    var tmpIndex = parseInt(checkboxes[i].id.split("_").length) - 1;

                    if (myAgreementTypeList != "") {
                        allItem = true;
                        myAgreementTypeList += "#" + GetListByID(checkboxes[i].id.split("_")[tmpIndex]);
                    }
                    else {
                        myAgreementTypeList = GetListByID(checkboxes[i].id.split("_")[tmpIndex]);
                    }
                }


            }


            if ($('#' + itemID)[0].checked) {

                $('#' + itemID).closest("span").addClass('selected');
            }
            else
                $('#' + itemID).closest("span").removeClass('selected');
        }

        
        if (typeof (OnSearchModeChanged) == 'function'
            && OnSearchModeChanged != null) {

            if (typeof (MoveValue) == 'function') {
                MoveValue(myAgreementTypeList);
            }

            OnSearchModeChanged();
        }
    }

    

    function GetListByID(id) {
        var tmpStr = "";
        if (id == "all") {
            for (var i = 0; i < listID.split("#").length; i++) {

                if (tmpStr != "") {
                    tmpStr += "#";
                }

                tmpStr += eval(listID.split("#")[i]);
            }
        }
        else {
            for (var i = 0; i < listID.split("#").length; i++) {
                if (listID.split("#")[i].indexOf(id) > -1) {
                    tmpStr += eval(listID.split("#")[i]);
                }

            }
        }

        return tmpStr;
    }

    function MarkCelectedCheckboxes() {
        var checkboxes = $('#' + '<%= lstModes.ClientID %>').closest("tr").find("input:checkbox");

        for (var i = 0; i < checkboxes.length; i++) {

            if (i > 0) {
                if (checkboxes[i].checked)
                    $('#' + checkboxes[i].id).closest("span").addClass('selected');
                else
                    $('#' + checkboxes[i].id).closest("span").removeClass('selected');
            }

        }
    }


    function CheckSelectedValuesNotEmpty(sender, args) {
        selectedVals = GetSelectedValues();
        args.IsValid = (selectedVals != '');

    }

    
    
</script>

<div>
    <div style="display: inline;float:right;vertical-align:bottom;margin-right:10px">
        <asp:CustomValidator ID="vldNotEmpty" runat="server" ValidationGroup="vldGrSearch"
            ErrorMessage="חובה לבחור שיוך ארגוני" Text="*" ClientValidationFunction="CheckSelectedValuesNotEmpty"
            Display="Static" />
    </div>    
        <asp:CheckBoxList ID="lstModes" runat="server" RepeatDirection="Horizontal" CssClass="RegularLabel"
            ValidationGroup="vldGrSearch" AutoPostBack="false" />    
</div>

