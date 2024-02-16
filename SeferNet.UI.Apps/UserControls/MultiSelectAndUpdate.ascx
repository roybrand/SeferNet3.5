<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_MultiSelectAndUpdate" Codebehind="MultiSelectAndUpdate.ascx.cs" %>
<link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />


<%--<script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>--%>
    <%--<script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>--%>
    <%--<script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>--%>  

<script type="text/javascript">
    //String Extention for contains
    if (String.prototype.contains == null) String.prototype.contains = function (p_string) {
        var contain;
        try {
            var index = this.indexOf(p_string, 0);
            contain = index > -1;
        }
        catch (ex) {
            contain = false;
        }
        return contain;
    }

    
    //jQuery Extentions
    $.extend($.expr[':'], {
        css: function (selector, index, metadata) {
            var arguments = metadata[3].split(",");
            var cssProperty = $.trim(arguments[0]);
            var cssValue = $.trim(arguments[1]);
            return $(selector).css(cssProperty).contains(cssValue);
        }
    });
    
</script>

<script language="javascript" type="text/javascript">
    var selectedValue = '';
    var selectedText = '';
    var timeOut = null;

    function SearchString(showAll) {
        if (timeOut == null) {
            timeOut = setTimeout("FilterList(" + showAll + ");", 350);
            setTimeout("timeOut = null;", 351);
        }
    }

    function SearchStringForCities(showAll) {
        if (timeOut == null) {
            //alert(showAll);
            timeOut = setTimeout("FilterListForCities(" + showAll + ");", 350);

            setTimeout("timeOut = null;", 351);
        }
    }
    
    //-----------new function --------------------------
    /*
    The control ItemNameNoQuotes is for the search function, it does not hold a quotes(")
    characters and it does not display.
    When the search function is called, all the qoutes characters of the wanted text are replaced 
    with "#@#" and the search process is looking for the text at ItemNameNoQuotes controll.
    This is happening because jquery have problem with qoutes when we use the filter function.
    */
    
    function FilterList(showAll) {
        //---- start Timer
        //var start = new Date().getTime();

        
        var searchedText = document.getElementById('<%=txtSearch.ClientID %>').value.toUpperCase();
        searchedText = searchedText.replace("\"", "#@#");
        
        var allCheckBoxes = $("div.ScrollBarDiv").find('input:checkbox');

        //------- If no filter - Show all items
        if (showAll || searchedText == '') {
            allCheckBoxes.closest('tr').show();
            return;
        }

        //------- Hide all items
        
        allCheckBoxes.closest('tr').hide();
        
        var allParentCheckBoxs = allCheckBoxes.filter(':not([ParentItemCode])');
        var allParentNames = allParentCheckBoxs.next().next().next(); 	//  !!!
        
        
        //------ find parent items contains Searched Text 
        // and Show parent and all it children.
        var count = 0;

        allParentNames                                 // parent Names 
        .filter(":contains(" + searchedText + ")")   //  parent ItemName contains Searched Text
        .each
        (

         function () {
            count = count + 1;
             var thisObj = $(this)
             // show parent 
             thisObj.closest("tr").show();

             //  show all children
             var parentCode = thisObj.next().attr('value');
             allCheckBoxes.filter("[ParentItemCode = " + parentCode + "]").closest("tr").show();
         }
        );
         
         //------ find parent items don't contains Searched Text but it children contains.
         // and Show parent and it matches children .
         allParentNames                                     // parent Names 
         .filter(":not(:contains(" + searchedText + "))")  // parent ItemName don't contains Searched Text
        .each
        (
         function () {
             var thisObj = $(this)

             var parentCode = thisObj.next().attr('value');

             var children = allCheckBoxes.filter("[ParentItemCode = " + parentCode + "]")  // children chkItems
             .next().next().next(":contains(" + searchedText + ")");                  // child ItemName contains Searched Text    !!!


             if (children.length > 0) {
                 // show parent 
                 thisObj.closest("tr").show();

                 // show match children 
                 children.closest("tr").show();
             }
         }
        );

         //------ Case one-level-Tree:  find children items with parentCode =-10 and contains Searched Text  
         allCheckBoxes.filter('[ParentItemCode=-10]')               //child chkItem  
        .next().next().next(":contains(" + searchedText + ")")                  // child ItemName contains Searched Text

        .closest("tr").show();

         
    }
    //
    function FilterListForCities(showAll) {
        //---- start Timer
        //var start = new Date().getTime();


        var searchedText = document.getElementById('<%=txtSearch.ClientID %>').value.toUpperCase();
            searchedText = searchedText.replace("\"", "#@#");

            var allCheckBoxes = $("div.ScrollBarDiv").find('input:checkbox');

            //------- If no filter - Show all items
            if (showAll || searchedText == '') {
                allCheckBoxes.closest('tr').show();
                return;
            }

            //------- Hide all items

            allCheckBoxes.closest('tr').hide();

            var allParentCheckBoxs = allCheckBoxes.filter(':not([ParentItemCode])');
            var allParentNames = allParentCheckBoxs.next().next().next(); 	//  !!!


            //------ find parent items contains Searched Text 
            // and Show parent and all it children.
            var count = 0;

            //allParentNames                                 // parent Names 
            //    .filter(":contains(" + searchedText + ")")   //  parent ItemName contains Searched Text
            //    .each
            //    (

            //        function () {
            //            count = count + 1;
            //            var thisObj = $(this)
            //            // show parent 
            //            thisObj.closest("tr").show();

            //            //  show all children
            //            var parentCode = thisObj.next().attr('value');
            //            allCheckBoxes.filter("[ParentItemCode = " + parentCode + "]").closest("tr").show();
            //        }
            //    );

            //------ find parent items don't contains Searched Text but it children contains.
            // and Show parent and it matches children .
            allParentNames                                     // parent Names 
                //.filter(":not(:contains(" + searchedText + "))")  // parent ItemName don't contains Searched Text
                .each
                (
                    function () {
                        var thisObj = $(this)

                        var parentCode = thisObj.next().attr('value');

                        var children = allCheckBoxes.filter("[ParentItemCode = " + parentCode + "]")  // children chkItems
                            .next().next().next(":contains(" + searchedText + ")");                  // child ItemName contains Searched Text    !!!


                        if (children.length > 0) {
                            // show parent 
                            thisObj.closest("tr").show();

                            // show match children 
                            children.closest("tr").show();
                        }
                    }
                );

            //------ Case one-level-Tree:  find children items with parentCode =-10 and contains Searched Text  
            allCheckBoxes.filter('[ParentItemCode=-10]')               //child chkItem  
                .next().next().next(":contains(" + searchedText + ")")                  // child ItemName contains Searched Text

                .closest("tr").show();


        }
    //

    function SelectAll(showAll) {
        if (timeOut == null) {
            timeOut = setTimeout("FilterList(" + showAll + ");", 350);
            setTimeout("timeOut = null;", 351);
        }
    }
    
    //-----------new function --------------------------
    /*
    The control ItemNameNoQuotes is for the search function, it does not hold a quotes(")
    characters and it does not display.
    When the search function is called, all the qoutes characters of the wanted text are replaced 
    with "#@#" and the search process is looking for the text at ItemNameNoQuotes controll.
    This is happening because jquery have problem with qoutes when we use the filter function.
    */
    
    function CheckAll() {
       
        var allCheckBoxes = $("div.ScrollBarDiv").find('input:checkbox');
        var maxSelectedElements = document.getElementById('<%= hdnSelectedElementsMaxNumber.ClientID %>').value;
        var SelectedElementsName = document.getElementById('<%= hdnSelectedElementsHebrewName.ClientID %>').value;

        var checkBoxesToBeChecked = allCheckBoxes.filter(":visible").filter(":enabled");
        if (maxSelectedElements != -1 && checkBoxesToBeChecked.length > maxSelectedElements)

        {
            alert("\t ! שים לב \n לא ניתן לבחור יותר מ" + maxSelectedElements + " " + SelectedElementsName);
            return;
        }

        ClearCheckBoxes();

        allCheckBoxes.filter(":visible").filter(":enabled").attr('checked', true);

        BuildCheckedNamesAndCodes();
        CheckIfToEnableConfirm();

        if (document.getElementById('<%= btnOk.ClientID %>').enabled) {
            document.getElementById('<%= btnOk.ClientID %>').focus();
        }
      
    }


    function BuildCheckedNamesAndCodes() {
        //---------- find all checked items Codes and buils selectedValue 
        
        var selNames = "";
        var selCodes = "";
       
        var allChildCheckedCheckBoxes = $("div.ScrollBarDiv").find("input:checkbox[checked='true'][ParentItemCode]");

        allChildCheckedCheckBoxes
        .next().next().next().next().each             //item Code    !!!
        (
         function () {
             var regExp = new RegExp("\\b" + this.value + "\\b", "i");

             if (selCodes.match(regExp) == null) {

                 selCodes = selCodes + this.value + ",";
                 selNames = selNames + $(this).prev().prev().text() + ",";
             }
         }
        );
        selectedValue = selCodes;
        selectedText = selNames;
        //alert(selCodes);

        document.getElementById('<%= txtSelectedValues.ClientID %>').value = selectedValue;
        document.getElementById('<%= txtSelected.ClientID %>').value = selectedText;
    }


    function OnCheckBoxClick(chkItemClientID) {
        var ItemCode = document.getElementById(chkItemClientID.replace('chkItem', 'ItemCode'));
        var currValue = ItemCode.value;     
       
        var chkItem = document.getElementById(chkItemClientID);
        var checked = chkItem.checked;

        var allCheckBoxes = $("div.ScrollBarDiv").find('input:checkbox');
        
        //---- if IsSingleSelectMode
        if ('<%=IsSingleSelectMode %>' == 'True') {
            
            if (checked == true) {
                //-- uncheck all checked CheckBoxes
                allCheckBoxes.filter("[checked = 'true']")
            .attr('checked', false);

                //-- retrieve last checked chkItem
                chkItem.checked = checked;
            }
        }
        //----- MultiSelect mode
        else {
            // --- If current item is parent  --  check/uncheck all it visible child items.
            if (chkItem.attributes["ParentItemCode"] == null) {
                allCheckBoxes.filter("[ParentItemCode = " + currValue + "]")
            .filter(":visible").filter(":enabled")
            .attr('checked', checked);
            }
        }

        BuildCheckedNamesAndCodes();
        CheckIfToEnableConfirm();
        
        if (document.getElementById('<%= btnOk.ClientID %>').enabled) {
            document.getElementById('<%= btnOk.ClientID %>').focus();
        }
    }

    function ClearCheckBoxes() {
        inputs = document.getElementsByTagName('input');
        disabledValues = '';

        for (i = 0; i < inputs.length; i++) {
            if (inputs[i].checked && !inputs[i].disabled) {
                inputs[i].checked = false;
            }
        }
        selectedText = document.getElementById('<%= txtSelected.ClientID %>').value = '<%= DisabledItemsText %>';
        selectedValue = '<%= DisabledItemsValues %>';

        document.getElementById('<%=txtSearch.ClientID %>').focus();

        CheckIfToEnableConfirm();
    }


    function CheckIfToEnableConfirm() {
        // if needed - don't permit to confirm without items checked
        document.getElementById('<%= btnOk.ClientID %>').disabled = (selectedText == '' && '<%= ValuesMustBeChosen %>' == 'True');
    }

    function GetValues(popupType) {

        if (selectedText != "") {

            selectedText = selectedText.substring(0, selectedText.length - 1);
        }

        if (selectedValue != "") {
            selectedValue = selectedValue.substring(0, selectedValue.length - 1);
        }

        var whereToPutValues = $("[id$='txtWhereToReturnSelectedValues']").val();

        var whereToPutText = $("[id$='txtWhereToReturnSelectedText']").val();

        var whereToPutValuesArray = whereToPutValues.split(',');
        var whereToPutTextArray = whereToPutText.split(',');

        for (let i = 0; i < whereToPutValuesArray.length; i++) {

            if (whereToPutValuesArray[i].length > 0) {
                window.parent.$("[id$=" + whereToPutValuesArray[i] + "]").val(selectedValue);
            }
        }

        for (let i = 0; i < whereToPutTextArray.length; i++) {
            
            if (whereToPutTextArray[i].length > 0) {
                window.parent.$("[id$=" + whereToPutTextArray[i] + "]").val(selectedText);
            }
        }

        var functionToExecute = $("[id$='txtFunctionToBeExecutedOnParent']").val();

        if (functionToExecute != "") {
            switch (functionToExecute) {
                case "SetReceiveGuestsAccordingToSelectedProfessions":
                    parent.SetReceiveGuestsAccordingToSelectedProfessions();
                    break;
                case "SetUnitType":
                    window.parent.SetUnitType();
                    break;
                case "AfterDistrictsSelected":
                    parent.AfterDistrictsSelected();
                    break;
                case "AfterProfessionSelected":
                    parent.AfterProfessionSelected();
                    break;
                case "SetProfessionCode":
                    parent.SetProfessionCode();
                    break;
                case "SetOmriCodes":
                    parent.SetOmriCodes();
                    break;
                case "SetICD9Codes":
                    parent.SetICD9Codes();
                    break;
                case "RefreshParent":
                    parent.RefreshParent();
                    break;
                case "AfterDistrictsSelectedOnSweepingRemarks":
                    parent.AfterDistrictsSelectedOnSweepingRemarks();
                    break;
                case "setSubmiButtonsEnabled":
                    parent.setSubmiButtonsEnabled();
                    break;
                case "setSubmiButtonsEnabled_OpenUpdateExpertPopUp":
                    parent.setSubmiButtonsEnabled_OpenUpdateExpertPopUp();
                    break;
                case "CauseUpdateAndRebindServices":
                    parent.CauseUpdateAndRebindServices();
                    break;
                case "setFocusOnAdminClinic":
                    parent.setFocusOnAdminClinic();
                    break;
                case "CleartNewServiceCodeAndNewServiceName":
                    parent.CleartNewServiceCodeAndNewServiceName();
                    break;
                case "ClearExcludedDeptCodes":
                    parent.ClearExcludedDeptCodes();
                    break;
                case "PopulationSectorsChanged":
                    parent.PopulationSectorsChanged();
                    break;

                default:
                    alert('"functionToExecute" not defined');
            }
        }

        if (popupType != 5) {
            SelectJQueryClose();
        }
    }

    function GetValues_old() {

        if (selectedText != "") {
            selectedText = selectedText.substring(0, selectedText.length - 1);
        }

        if (selectedValue != "") {
            selectedValue = selectedValue.substring(0, selectedValue.length - 1);
        }
        var obj = new Object();
        obj.Text = selectedText;
        obj.Value = selectedValue;
        document.getElementById('<%= SelectedCodes.ClientID %>').value = selectedValue;
            window.returnValue = obj;
        }

    function Close() {
        self.close();
    }


    function Clear() {

        document.getElementById('<%= txtSearch.ClientID %>').value = '';
        document.getElementById('<%= divResults.ClientID %>').style.display = 'block';
        document.getElementById('<%= divNoResults.ClientID %>').style.display = 'none';
        document.getElementById('<%=txtSearch.ClientID %>').focus();
        FilterList(true);
    }

    
</script>


<input type="hidden" id="SelectedCodes" runat="server"/>
<input type="hidden" id="hdnSelectedElementsMaxNumber" runat="server" />
<input type="hidden" id="hdnSelectedElementsHebrewName" runat="server" />
<asp:TextBox ID="txtSelectedValues" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
<table cellpadding="0" cellspacing="0" style="margin-right: 5px; margin-bottom: 2px;">
    <tr><td>
        <asp:TextBox ID="txtWhereToReturnSelectedValues" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
        <asp:TextBox ID="txtWhereToReturnSelectedText" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
        <asp:TextBox ID="txtFunctionToBeExecutedOnParent" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style ="padding-right:8px;width:130px">
            <asp:TextBox ID="txtSearch" onkeyup="SearchString(false);" runat="server" Width="120px"></asp:TextBox>
        </td>
        <td style="width:100px">
            <table cellpadding="0" cellspacing="0" style="display: inline;">
                <tr>
                    <td class="buttonRightCorner">
                        &nbsp;
                    </td>
                    <td class="buttonCenterBackground">
                        <asp:Button ID="btnClearText" Text="ניקוי" runat="server" CssClass="RegularUpdateButton"
                            OnClientClick="Clear();return false;" />
                    </td>
                    <td class="buttonLeftCorner">
                        &nbsp;
                    </td>
                </tr>
            </table>
        </td>
        <td style="padding-left: 5px; text-align:left" >
            <table id="tblBtnCheckAll" runat="server" cellpadding="0" cellspacing="0" style="display: inline;">
                <tr>
                    <td class="buttonRightCorner">
                        &nbsp;
                    </td>
                    <td class="buttonCenterBackground">
                        <asp:Button ID="btnCheckAll" Text="הכל" runat="server" CssClass="RegularUpdateButton" 
                            OnClientClick="CheckAll();return false;" />
                    </td>
                    <td class="buttonLeftCorner">
                        &nbsp;
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="3" style="padding-right: 6px;padding-top:8px;">
            <div id="divResults" runat="server" class="ScrollBarDiv" style="overflow-y: auto;
                height: 350px; width: 355px; border: 1px solid black;">
                
                <asp:Repeater ID="rptItems" runat="server" OnItemDataBound="rptItems_ItemDataBound">
                    <HeaderTemplate>
                        <table style="margin-right: 0px" cellpadding="0" cellspacing="0">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td id="tdFirst" runat="server" dir="rtl" style="padding-top: 3px;padding-right:0px;">
                                
                                <asp:Image ID="imgServiceOrProf" runat="server"  ImageAlign="Bottom" />  
                                <input type ="checkbox" ID="chkItem" runat="server" />
                                <asp:Image ID="imgAgreementType" runat="server"  ImageAlign="Bottom" />
                                <asp:Label ID="ItemName" runat="server" ></asp:Label>
                                <asp:Label ID="ItemNameNoQuotes" runat="server"></asp:Label>
                                <input type="hidden" id="ItemCode" runat="server"/>
                                <input type="hidden" id="ParentItemCode" runat="server" />
                                
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                
            </div>
            
            <div id="divNoResults" runat="server" style="height: 350px; display: none; text-align: center;
                vertical-align: middle;">
                <asp:Label ID="lblNoResults" Style="line-height: 350px" runat="server">לא נמצאו שיוכים לעובד</asp:Label>
            </div>
            <div style="padding-top: 5px; padding-bottom: 5px; padding-right: 1px">
                <asp:TextBox ID="txtSelected" CssClass="TextBoxMultiLine" ReadOnly="true" TextMode="MultiLine"
                    Height="100px" runat="server" Width="350px"></asp:TextBox>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="3" align="center" style="padding-bottom:7px">
            <div id="divButtonAdd" runat="server">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="buttonRightCorner">
                            &nbsp;
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnAddProfessions" runat="server" OnClick="btnAddProfessions_Click"
                                CssClass="RegularUpdateButton" />
                        </td>
                        <td class="buttonLeftCorner">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
    <tr>
        <td colspan="3" style="padding-right:100px">
    <table cellpadding="2" cellspacing="0">
        <tr>
            <td class="buttonRightCorner">
                &nbsp;
            </td>
            <td class="buttonCenterBackground">
                <asp:Button ID="btnClear" runat="server" Text="ניקוי סימונים" OnClientClick="ClearCheckBoxes();return false;"
                    CssClass="RegularUpdateButton" />
            </td>
            <td class="buttonLeftCorner">
                &nbsp;
            </td>
            <td class="buttonRightCorner">
                &nbsp;
            </td>
            <td class="buttonCenterBackground">
                <asp:Button ID="btnOk" runat="server" Text="אישור" OnClick="btnOk_Click" CssClass="RegularUpdateButton" />
            </td>
            <td class="buttonLeftCorner">
                <input type="text" style="display: none" />
                &nbsp;
            </td>            
            <td class="buttonRightCorner">
                &nbsp;
            </td>
            <td class="buttonCenterBackground">
                <asp:Button ID="btnCancel" runat="server" Text="ביטול" 
                    CssClass="RegularUpdateButton" />
            </td>
            <td class="buttonLeftCorner">
                &nbsp;
            </td>
        </tr>
    </table>
        </td>
    </tr>
</table>
<div style="position:absolute; bottom:20px; left:9px;text-align:right; float:right;">

</div>
