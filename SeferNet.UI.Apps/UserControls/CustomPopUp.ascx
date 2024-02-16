<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_CustomPopUp" Codebehind="CustomPopUp.ascx.cs" %>
<script type="text/javascript" src="<%=mainDirectory %>/Scripts/LoadJqueryIfNeeded.js"></script>
<script type="text/javascript" src="<%=mainDirectory %>/Scripts/srcScripts/Thickbox.js"></script>
<link rel="stylesheet" href="<%=mainDirectory %>/css/General/thickbox.css" type="text/css" media="screen" />
<script type="text/javascript">

    /* 
    This user control implement an alert message and form with email details.
    The alert message have 2 buttons - confirm or cancel.
    The function "showAlert" opens the alert message and it gets parameters for
    the message text, the buttons text, the width and height of the alert, and if to
    hide one of the buttons.
    After the user selected yes or no, the event "alertClickEvent" is fireing
    and it need to be implement at the main page.
    The varient "alertReturnValue" will keep the result -
    0 for no
    1 for yes
        
    To open the form of the mail use the function "openMailDetails".
    after confirmation the function "confirmEmailDetails" is fireing,
    it returns an object with the mail details.

    */



    var alertReturnValue = "";
    function showAlert(alertMessage, alertConfirmText, alertCancelText, alertHeight, alertWidth,
         displayConfirm, displayCancel) {

        if (typeof (alertMessage) != "undefined" && alertMessage != "")
            $("#divMsgAlert").html(alertMessage);

        if (typeof (alertConfirmText) != "undefined" && alertConfirmText != "")
            $("#btnAlertConfirm").val(alertConfirmText);

        if (typeof (alertCancelText) != "undefined" && alertCancelText != "")
            $("#btnAlertCancel").val(alertCancelText);

        var tmpHref = "#TB_inline?inlineId=divContainer&modal=true";
        if (typeof (alertHeight) != "undefined" && alertHeight != "")
            tmpHref += "&height=" + alertHeight;
        else
            tmpHref += "&height=80";

        if (typeof (alertWidth) != "undefined" && alertWidth != "")
            tmpHref += "&width=" + alertWidth;
        else
            tmpHref += "&width=250";

        if (typeof (displayConfirm) != "undefined")
            $("#divConfirm")[0].style.display = (displayConfirm ? "inline" : "none");

        if (typeof (displayCancel) != "undefined")
            $("#divCancel")[0].style.display = (displayCancel ? "inline" : "none");

        $("#divMailForm").hide();
        $("#divFaxForm").hide();
        $("#divProgressBar2").hide();
        $("#hiddenAlert").show();
        $("#hiddenAlert").css("margin-top", "0");
        $("#fade").show();

    }


    function closeAlert(result) {
        alertReturnValue = result;
        //tb_remove();
        restore();
        if (typeof (alertClickEvent) == "function")
            alertClickEvent();
    }



    /* Fax script */
    function openfaxDetails() {
        $("#txtFaxNumber").val("");

        $("#txtFaxNumber").css("border", "1px solid #404040");
        $("#divFaxForm").show();
        $("#divMailForm").hide();
        $("#divProgressBar2").hide();
        $("#hiddenAlert").hide();

        $("html").css("overflow", "hidden");
        $("#fade").show();
        $("#txtAddress").focus();

    }

    function closefaxDetailsWindow(confirmCancel) {

        if (confirmCancel) {
            if (checkFaxValidation()) {
                //tb_remove();
                restore();
                if (typeof (sendFax) == "function") {
                    var faxNumber = $("#txtFaxNumber").val();
                    sendFax(faxNumber);
                }
            }
        }
        else {
            //tb_remove();
            restore();
        }
    }


    function checkFaxValidation() {
        var res = true;

        var faxExp = /^0[23489]{1}(\-)?[^0\D]{1}\d{6}$$/;
        var faxNum = $("#txtFaxNumber").val();
        if (faxExp.test(faxNum)) {
            $("#txtFaxNumber").css("border", "1px solid #404040");
        }
        else {
            $("#txtFaxNumber").css("border", "1px solid red");
            res = false;
        }

        return res;
    }


    /* Mail script */
    function mailObject() {
        this.mailAddress = "";
        this.mailRemarks = "";
        this.mailClientName = "";
    }

    function openMailDetails() {
        $("#txtName").val("");
        $("#txtAddress").val("");

        $("#txtRemarks").val("");
        $("#txtAddress").css("border", "1px solid #404040");
        $("#divMailForm").show();
        $("#divFaxForm").hide();
        $("#divProgressBar2").hide();
        $("#hiddenAlert").hide();

        $("html").css("overflow", "hidden");
        $("#fade").show();

        $("#txtAddress").focus();

    }




    function closeMailDetails(confirmCancel) {
        if (confirmCancel) {
            var mailDetails = new mailObject();

            mailDetails.mailClientName = $("#txtName").val();
            mailDetails.mailAddress = $("#txtAddress").val();
            mailDetails.mailRemarks = $("#txtRemarks").val();
            if (checkEmailValidation()) {
                //tb_remove();
                restore();
                if (typeof (confirmEmailDetails) == "function")
                    confirmEmailDetails(mailDetails);
            }

        }
        else {
            //tb_remove();
            restore();
        }

    }

    function checkEmailValidation() {
        var res = true;
        var emailExp = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        var emailAdd = $("#txtAddress").val();
        if (emailExp.test(emailAdd)) {
            $("#txtAddress").css("border", "1px solid #404040");
        }
        else {
            $("#txtAddress").css("border", "1px solid red");
            res = false;
        }

        return res;
    }

    function showAjaxProgressImage() {
        $("#divMailForm").hide();
        $("#divFaxForm").hide();
        $("#divProgressBar2").show();
        $("#fade").show();
    }

    function showMessageWhenAjaxEnd(msg) {
        $("#divMsgAlert").html(msg);
        $("#divCancel")[0].style.display = "none";

        $("#divMailForm").hide();
        $("#divFaxForm").hide();
        $("#divProgressBar2").hide();
        $("#hiddenAlert").css("margin-top", "30px");
        $("#hiddenAlert").show();
    }
    function restore() {
        if (typeof document.body.style.maxHeight == "undefined") {//if IE 6
            $("body", "html").css({ height: "auto", width: "auto" });
            $("html").css("overflow", "");
        }
        $("#fade").hide();
        $("#divMailForm").hide();
        $("#hiddenAlert").hide();
    }
</script>


<div id="fade" class="black_overlay"></div>
<!-- Mail details form -->
    <div id="divMailForm" class="white_content" style="display:none; width:300px; height:209px" >
        <div style="float:right;width:60px;text-align:right;" class="LabelBoldBlack_13">כתובת</div>
        <input type="text" id="txtAddress" style="text-align:right;float:right;border:1px solid #404040;" />
        <div style="float:right;width:60px;text-align:right;clear:both;margin-top:10px;" class="LabelBoldBlack_13">שם הלקוח</div>
        <input type="text" id="txtName" style="text-align:right;float:right;margin-top:10px;border:1px solid #404040;" />
        <div style="float:right;width:60px;text-align:right;clear:both;margin-top:10px;" class="LabelBoldBlack_13">הערות</div>
        <textarea style="text-align:right;float:right;margin-top:10px;border:1px solid #404040;" rows="5" cols="25" id="txtRemarks" ></textarea>
        <div style="float:right;height:10px;width:100px"></div>
        <div style="clear:both;margin-top:20px;">
            <div class="button_RightCorner" style="margin-right:60px;_margin-right:30px;"></div>
            <div class="button_CenterBackground">
                <input type="button" class="RegularUpdateButton" onclick="closeMailDetails(1);" style="width:60px;" value="אישור"/>
            </div>
            <div class="button_LeftCorner"></div>

            <div class="button_RightCorner" style="margin-right:90px;"></div>
            <div class="button_CenterBackground">
                <input type="button" class="RegularUpdateButton" onclick="closeMailDetails(0);" style="width:60px;" value="ביטול"/>
            </div>
            <div class="button_LeftCorner"></div>
        </div>
    </div>

    <div id="divFaxForm" class="white_content" style="display:none;width:250px;height:85px;">
        <div style="float:right;width:60px;text-align:right;" class="LabelBoldBlack_13">מספר פקס</div>
        <input type="text" id="txtFaxNumber" style="text-align:right;float:right;border:1px solid #404040;" />
        <div style="clear:both;margin-top:20px;">
            <div class="button_RightCorner" style="margin-right:60px;_margin-right:30px;"></div>
            <div class="button_CenterBackground">
                <input type="button" class="RegularUpdateButton" onclick="closefaxDetailsWindow(true);" style="width:60px;" value="אישור"/>
            </div>
            <div class="button_LeftCorner"></div>

            <div class="button_RightCorner" style="margin-right:22px;"></div>
            <div class="button_CenterBackground">
                <input type="button" class="RegularUpdateButton" onclick="closefaxDetailsWindow(false);" style="width:60px;" value="ביטול"/>
            </div>
            <div class="button_LeftCorner"></div>
        </div>
    </div>

    <!-- Progress image -->
    <div id="divProgressBar2" class="white_content" style="display:none;width:200px;height:30px;">
        <table id="tblProgressBar" style="width:100%;height:100%;" cellpadding="0" cellspacing="0">
            <tr>
                <td style="background:url('../Images/Applic/progressBar.gif') no-repeat center center;"></td>
            </tr>
        </table>
    </div>


    <!-- Alert -->
    <div id="hiddenAlert" class="white_content" style="display:none;width:250px;">
        <table id="tblAlertForm" cellpadding="0" cellspacing="0" style="width:100%;">
            <tr>
                <td>
                    <div id="divMsgAlert" style="text-align:right;"></div>        
                </td>
            </tr>
            <tr>
                <td style="height:20px;"></td>
            </tr>
            <tr>
                <td>
                    <div id="divConfirm" style="display:inline;">
                        <div class="button_RightCorner"></div>
                        <div class="button_CenterBackground">
                            <input style="margin-left:10px;margin-right:10px;" id="btnAlertConfirm" onclick="closeAlert(1);" type="button" class="RegularUpdateButton" value="אישור" />
                        </div>
                        <div class="button_LeftCorner"></div>
                    </div>
                      
                    <div id="divCancel" style="display:inline;">     
                        <div style="float:left;" class="button_LeftCorner"></div>
                        <div style="float:left;" class="button_CenterBackground">
                            <input style="margin-left:10px;margin-right:10px;" id="btnAlertCancel" onclick="closeAlert(0);" type="button" class="RegularUpdateButton" value="ביטול" />
                        </div>
                        <div style="float:left;" class="button_RightCorner"></div>
                    </div>    
                
                </td>        
            </tr>
        </table>    
    </div>



<a id="aTB_inline" style="display:none;" href="" class="thickbox">Show hidden modal content.</a>


