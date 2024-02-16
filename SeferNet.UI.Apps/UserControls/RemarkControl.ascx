<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="RemarkControl.ascx.cs" Inherits="SeferNet.UI.Apps.UserControls.RemarkControl" %>
<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelectUC.ascx" %>
<%@ Register TagPrefix="ServContr" TagName="ServicesControl" Src="~/UserControls/ServicesControl.ascx" %>
<%@ Register TagPrefix="GetClinicByName" TagName="GetClinicByName" Src="~/UserControls/GetClinicByName.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxtoolkitRC" %>
<script type="text/javascript" defer="defer">
    // Client functions for all controls being dynamically added to RemarkControl
    // ( dynamically added control doesn't see it's own client script )

    // function SelectServicesAndEvents_ForRemark is for "ServicesControl"
    function SelectServicesAndEvents_ForRemark(txtProfessionListCodesID) {
        //alert(txtProfessionListCodesID);
        var SelectedProfessionList = "";
        //ControlsValue = $(this).find("input[name*='txtProfessionListCodesID']").val();
        //ControlsValue = $('[id*='txtProfessionListCodesID']').val();

        SelectedProfessionList = $('[id*="txtProfessionListCodes"]').val();

            var url = "../Public/SelectPopUp.aspx";

            //var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
            //var txtProfessionList = document.getElementById(txtProfessionListClientID);
            //var selectedCodes = txtProfessionListCodes.value;
            //var SelectedProfessionList = txtProfessionListCodes.value;

            url = url + "?SelectedValuesList=" + SelectedProfessionList;
            url = url + "&popupType=12";
            url += "&AgreementTypes=Community";
            url += "&isInCommunity=true";
            url += "&returnValuesTo='txtProfessionListCodes'";
            url += "&returnTextTo='txtProfessionList'";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר שירות או פעילות";
            //return false;
            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
    }

    function SelectClinic_ForRemark_test(txtDeptCodeID, txtDeptNameID) {
        alert("Here");

    }

    function SelectClinic_ForRemark(txtDeptCodeID, txtDeptNameID) {
        var SelectedClinicCode = "";
        var SelectedClinicName = ""; // Not in use now. Just in case...

        SelectedClinicCode = $('[id*="txtDeptCode"]').val();
        SelectedClinicName = $('[id*="txtDeptName"]').val();

        var url = "../Public/SelectPopUp.aspx";
        //url = url + "?SelectedValuesList=" + SelectedClinicCode;
        url = url + "?SelectedValuesList=" + ";;" + SelectedClinicCode + ";;;";
        url = url + "&popupType=25";
        url = url + "&IsSingleSelectMode=true";
        url += "&returnValuesTo=txtDeptCode";
        url += "&returnTextTo=txtDeptName";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר יחידות לא כלולות";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }


    // END OF Client functions for all controls being dynamically added to RemarkControl

    function GetRemarkControlData() {
        //alert("GetRemarkControlData");
        var ListOfControlsValue = "";// list of all control's value to be saved
        var ControlsValue = "";

        //$("input[name*='txtRemarkSelectedValues']").val("has man in it!");
        //$("input[name*='txtItems']").val("has man in it!");
        //$("input[name*='uc_TextBox']").val("calendar!");


        //$("input[name*='divRemarkElement_']").each(function () {
        //$(this).datepicker({ dateFormat: "yy-mm-dd" });
        //fieldid = jQuery(this).attr("id").toString();
        //alert(fieldid);
        //alert("Loop");
        //});
        $("div[id*='divRemarkElement_']").each(function () {

            var self = $(this);
            var attrID = self.attr("id");

            // days' control
            if ($(this).find("input[name*='txtItems']").length) 
            {
                alert("days control found");
                //ControlsValue = $("input[name*='txtItems']").val();
                ControlsValue = $(this).find("input[name*='txtItems']").val();
                if (ControlsValue == "") {
                    $(this).find("input[name*='txtItems']").val("Is Emty");
                    ControlsValue = "Is Emty";
                }

                ListOfControlsValue = ListOfControlsValue + ";" + ControlsValue;
            }

            // date control
            if ($(this).find("input[name*='ControlDate_']").length) 
            {
                alert("date control found");
                ControlsValue = $(this).find("input[name*='ControlDate_']").val();

                if (ControlsValue == "") {
                    ControlsValue = "ControlDate Is Emty";
                }

                ListOfControlsValue = ListOfControlsValue + ";" + ControlsValue;
            }

            // Hour control
            if ($(this).find("input[name*='ControlHour_']").length) 
            {
                alert("hour control found");
                //ControlsValue = $("input[name*='ControlHour_']").val();
                ControlsValue = $(this).find("input[name*='ControlHour_']").val();
                if (ControlsValue == "") {
                    ControlsValue = "ControlHour Is Emty";
                }

                ListOfControlsValue = ListOfControlsValue + ";" + ControlsValue;
            }

            // Services control
            if ($(this).find("[id*='txtProfessionListCodes']").length) 
            {
                alert("Services control found");
                ControlsValue = $(this).find("[id*='txtProfessionListCodes']").val();
                if (ControlsValue == "") {
                    ControlsValue = "ControlHour Is Emty";
                }

                ListOfControlsValue = ListOfControlsValue + ";" + ControlsValue;
            }

            // Clinic by name control
            if ($(this).find("[id*='txtClinicName']").length) 
            {
                alert("Clinic by name control found");
                ControlsValue = $(this).find("[id*='txtClinicName']").val();
                if (ControlsValue == "") {
                    ControlsValue = "ControlHour Is Emty";
                }

                ListOfControlsValue = ListOfControlsValue + ";" + ControlsValue;
            }

            if ($(this).find("[id*='uc_Label_']").length) // Lable control
            {
                //alert("label control found");
            }
            //else {
            //    alert("label control NOT found");
            //}

        });

        //var controlsValue = "123";
        //alert("Before = " + controlsValue);
        //$("input[name*='uc_TextBox']").each(function () {
        //    //this.value = "strVal";
        //    //controlsValue = controlsValue + this.val() + ";";
        //    //controlsValue = controlsValue + this.val() + ";";
        //    controlsValue = controlsValue + ";" + "more data";
        //    alert("After = " + controlsValue);
        //    //this.val()
        //});


        $("input[name*='txtRemarkSelectedValues']").val(ListOfControlsValue);

        return false;
    }

</script>
<table>
    <tr>
        <td>
            <asp:TextBox ID="txtGenaralRemarkID" runat="server"></asp:TextBox>
            <asp:TextBox ID="txtGenaralRemarkText" runat="server"></asp:TextBox>
            <asp:TextBox ID="txtRemarkSelectedValues" runat="server"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td style="border:1px dashed red;">
            <asp:Panel id="divRemarkBuilder" HorizontalAlign="Right" runat="server" style="text-align:right;" >
            </asp:Panel>
        </td>
    </tr>
    <tr>
        <td>
            <asp:Button ID="btnGetRemarkControlData" runat="server" Text="Get Remark Control Data" OnClientClick="GetRemarkControlData()" />
        </td>
        <td>
                <%--<input type="image" id="btnQueueOrderPopUp_3" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif" onclick="SelectQueueOrder(); return false;" />--%>
        </td>
        <td>
            <%--<ServContr:ServicesControl id="uc_Service" runat="server" />--%>
        </td>
    </tr>


</table>
