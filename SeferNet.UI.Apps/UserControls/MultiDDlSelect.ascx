<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_MultiDDlSelect" Codebehind="MultiDDlSelect.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<div id="divUC" dir="rtl">
    
            <asp:HiddenField runat="server" ID="hdnFlg" Value="1" />
            <table id="tblMain" runat="server" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left">
                        <asp:TextBox ID="txtItems" Text="" runat="server" onFocus="txtItemsOnFocus(this)"
                             autocomplete="off" />
                        <asp:Panel ID="pnlItems" runat="server" ScrollBars="Vertical"
                            Height="150px" Width="200px" CssClass="Mddl" align="right">
                            <table border="0" width="85%">
                                <tr>
                                    <td style="text-align: right; height: 110px; vertical-align: top" align="right">
                                        <div id="dvCheckBoxList" style="overflow: hidden;">
                                            <asp:CheckBoxList runat="server" ID="chkLst" TextAlign="Right" dir="rtl">
                                            </asp:CheckBoxList>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="bottom" align="center">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td class="buttonRightCorner">&nbsp;
                                                </td>
                                                <td class="buttonCenterBackground" align="center">
                                                    <input type="button" id="btnPermit" runat="server" value="אישור" class="RegularUpdateButton" />
                                                </td>
                                                <td class="buttonLeftCorner">&nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                    <td align="right" valign="baseline">
                        <asp:Image id="btnOpenClose" runat="server" src="../Images/DDImageDown.bmp" />
                    </td>
                </tr>
            </table>
            
        
</div>
<script type="text/javascript">

    //Close panel on click out of the element
    document.addEventListener("click", (event) => {

        const element = event.target;

        if (event.target.id.toString().includes('txtItems') == false && event.target.id.toString().includes('btnOpenClose') == false && findElementInParent(element, 'pnlItems') == false) {
            document.getElementById('<%=this.pnlItems.ClientID %>').style.visibility = 'hidden';
        }
    });


    function findElementInParent(element, elementId) {
        let index = 100;

        while (element.parentNode != null) {

            if (element.id.toString().includes(elementId)) return true;
            else element = element.parentNode;
        }

        return false;
    }

    function txtItemsOnFocus(element) {

        element.blur();
                
        togglePanel();
    }

    function onOpenCloseClick() {

        togglePanel();
    }

    function togglePanel() {

        const isVisibility = document.getElementById('<%=this.pnlItems.ClientID %>').style.visibility == 'visible' ? true : false;

        if (isVisibility) document.getElementById('<%=this.pnlItems.ClientID %>').style.visibility = 'hidden';
        else document.getElementById('<%=this.pnlItems.ClientID %>').style.visibility = 'visible';
    }

    var checkboxesID = "<%=chkLst.ClientID %>";

    function getCheckedItems(ctrl) {
        
        var selectedValues = "";
        var selectedSectorsCount = 0;

        var checkboxes = $('#' + ctrl.id).closest("[id$='divUC']").find("input:checkbox");

        for (var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked) {
                if (selectedValues == "") {
                    selectedValues = checkboxes[i].nextSibling.innerHTML;
                }
                else {
                    selectedValues += "," + checkboxes[i].nextSibling.innerHTML;
                }

                selectedSectorsCount += 1;
            }
        }

        txtItems = $('#' + ctrl.id).closest("[id$='divUC']").find("input:text[id$='txtItems']");

        if (txtItems != null)
        { txtItems.val(selectedValues); }
        
        pnlItems = $('#' + ctrl.id).closest("[id$='divUC']").find(".Mddl");

        togglePanel();

        parent.validateTime(null, ctrl);

        return false;
    }

    function setAllToNotChecked() {
        var checkboxes = $('#' + checkboxesID).find("input");
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false ;
        }
        $("#" + "<%=txtItems.ClientID %>").val("");
    }

    function setCheckedItems(itemsText) {
        
        var splitItemsText = itemsText.split(";")
        
        $("#" + "<%=txtItems.ClientID %>").val(itemsText);
        
        var checkboxes = $('#' + checkboxesID).find("input");

        for (var j = 0; j < splitItemsText.length; j++) {
            for (var i = 0; i < checkboxes.length; i++) {
                if (splitItemsText[j].trim() == checkboxes[i].nextSibling.innerHTML.trim()) {
                    checkboxes[i].checked = true;
                    i = checkboxes.length;
                }
            }
        }
        

    }
</script>
