<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_MultiDDlSelectUC" Codebehind="MultiDDlSelectUC.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
<script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>
<script type="text/javascript">

    // register to clear event from parent control 
    OnClearData = ClearData;

    function btnOpenClose_Click(ctrl) {

        pnl = document.getElementById(ctrl);
        
        var div = $('#' + pnl.id);

        if (div.is(':visible')) {
            div.hide();
        }
        else {
            div.show();
        }
    }

    function ClosePanel(ctrl) {
        var div = $('#' + ctrl.id).closest("div");
        div.hide();

        parent.validateTime(null, ctrl);
    }


    $(document).click(function (e) {
        if ($(e.target).closest("[id$='divUC']").length == 0)
            $('.MddlDay').hide();
    });

    function ClearData() {        
        $("*[id$=tblMultiDDL]").find("input:checkbox").each(function () {
            $(this).attr("checked", false);
        });
    }



    function setSelectItems(ctrlID) {

        var selectedValues = '';
        checkboxes = $('#' + ctrlID).find("input:checkbox");

        for (i = 0; i < checkboxes.length; i++) {

            if (checkboxes[i].checked) {
                selectedValues += checkboxes[i].nextSibling.innerHTML + ',';
            }
        }

        if (selectedValues.length > 0) {
            selectedValues = selectedValues.substring(0, selectedValues.length - 1);
        }


        txtItems = $('#' + ctrlID).closest("[id$='divUC']").find("input:text[id$='txtItems']");


        if (txtItems != null)
        { txtItems.val(selectedValues); }

        return false;
    }

    
</script>
<div id="divUC" dir="rtl">
    <asp:HiddenField runat="server" ID="hdnFlg" Value="1" />
    <table id="tblMain" runat="server" cellpadding="0" cellspacing="0">
        <tr>
            <td style="padding-right: 0px; padding-left: 0px;">
                <asp:TextBox ID="txtItems" runat="server" Width="50px" />
            </td>
            <td valign="top" >
                <asp:Image id="btnOpenClose" runat="server" src="../Images/DDImageDown.bmp" />
            </td>
        </tr>
        <tr>
            <td colspan="2" align="right" style="padding-top: 1px">
                <div style="margin-top:-4px;" id="<%= "pnlData_" + this.ClientID %>" class="MddlDay DisplayNone" onblur="ClosePanel(this);">
                    <table border="0">
                        <tr>
                            <td style="text-align: right; vertical-align: top;">
                                <table id="tblMultiDDL" runat="server">
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top" align="center">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td class="buttonRightCorner">
                                            &nbsp;
                                        </td>
                                        <td class="buttonCenterBackground" align="center">
                                            <asp:Button ID="btnClose" Text="אישור" runat="server" CssClass="RegularUpdateButton"
                                                EnableTheming="false" OnClientClick="return ClosePanel(this);" CausesValidation="false"
                                                UseSubmitBehavior="false" />
                                        </td>
                                        <td class="buttonLeftCorner">
                                            &nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
</div>
