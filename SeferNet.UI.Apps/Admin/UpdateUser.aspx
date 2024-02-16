<%@ Page Language="C#" AutoEventWireup="true" Inherits="UpdateUser"  Culture="auto" UICulture="auto" Codebehind="UpdateUser.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <base target="_self" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>
    <title>עדכון פרטי משתמש</title>
    <script type="text/javascript" language="javascript">
        function MinheletSelected(source, eventArgs) {
            //alert( " Key : "+ eventArgs.get_text() +"  Value :  "+eventArgs.get_value());
            //debugger;
            var values = eventArgs.get_value();
            var text = eventArgs.get_text();
            if (values == null) return;

            document.getElementById('<%= hdnMinheletValue.ClientID %>').value = values;
            document.getElementById('<%= hdnMinheletText.ClientID %>').value = text;
        }
        
        function DeptSelected(source, eventArgs) {

            var values = eventArgs.get_value();
            var text = eventArgs.get_text();
            if (values == null) return;
            document.getElementById('<%= hdnDeptCode.ClientID %>').value = values;
            document.getElementById('<%= hdnDeptText.ClientID %>').value = text;
        }

        function CleanUserPermission() {
            document.getElementById('<%= ddlDistricts.ClientID %>').value =  '<%= DefaultDistrict %>';            
            document.getElementById('<%= cbErrorReport.ClientID %>').checked = false;
            document.getElementById('<%= ddlPermissionType.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= txtMinhelet.ClientID %>').value = "";
            document.getElementById('<%= hdnMinheletValue.ClientID %>').value = "";
            document.getElementById('<%= txtDept.ClientID %>').value = "";
            document.getElementById('<%= hdnDeptCode.ClientID %>').value = "";
            return false;
        }
        function ClearMinheletAndDept() {
            var hdnMinheletText = document.getElementById('<%= hdnMinheletText.ClientID %>').value;
            var txtMinhelet = document.getElementById('<%= txtMinhelet.ClientID %>').value;

            if (txtMinhelet != hdnMinheletText) {
                document.getElementById('<%= txtMinhelet.ClientID %>').value = "";
                document.getElementById('<%= hdnMinheletValue.ClientID %>').value = "";
                document.getElementById('<%= hdnMinheletText.ClientID %>').value = "";
                document.getElementById('<%= txtDept.ClientID %>').value = "";
                document.getElementById('<%= hdnDeptCode.ClientID %>').value = "";
                document.getElementById('<%= hdnDeptText.ClientID %>').value = "";
            }
        }
        
        function ClearDept() {
            var txtDept = document.getElementById('<%= txtDept.ClientID %>').value;
            var hdnDeptText = document.getElementById('<%= hdnDeptText.ClientID %>').value;

            if (txtDept != hdnDeptText) {
                document.getElementById('<%= txtDept.ClientID %>').value = "";
                document.getElementById('<%= hdnDeptCode.ClientID %>').value = "";
                document.getElementById('<%= hdnDeptText.ClientID %>').value = "";
            }
        }

        function ValidateConsistency(val, args) {

            var hdnDeptCode = document.getElementById('<%= hdnDeptCode.ClientID %>').value;
            var hdnMinheletValue = document.getElementById('<%= hdnMinheletValue.ClientID %>').value;
            var hdnMinheletValue = document.getElementById('<%= hdnMinheletValue.ClientID %>').value;

            var ddlDistricts = document.getElementById('<%= ddlDistricts.ClientID %>');
            var district = ddlDistricts.options[ddlDistricts.selectedIndex].value;

            var ddlPermissionType = document.getElementById('<%= ddlPermissionType.ClientID %>');
            var permissionType = ddlPermissionType.options[ddlPermissionType.selectedIndex].value;

            var checkResult = false;

            if (permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.District %>' && ddlDistricts != "-1") // district
                checkResult = true;
            
            if (permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.AdminClinic %>' && hdnMinheletValue != "") // Minhelet
                checkResult = true;

            if (permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.Clinic %>' && hdnDeptCode != "") // clinic
                checkResult = true;

            if (permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.ViewHiddenAndReports %>' && ddlDistricts != "-1")
                checkResult = true;

            if (    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.ViewHiddenDetails %>' ||
                    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.Administrator %>' ||
                    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.ManageTarifonViews %>' ||
                    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.ViewTarifon %>' ||
                    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.ManageInternetSalServices %>' ||
                    permissionType == '<%= (int)SeferNet.Globals.Enums.UserPermissionType.LanguageManagement %>'
            )
                checkResult = true;

            if (checkResult)
                args.IsValid = true;
            else {
                args.IsValid = false;
            }
        }

        function ValidateUserID(val, args)
        {
            var userID = document.getElementById('<%= txtUserID.ClientID %>').value;
            if (userID.length > 0 && IsNumeric(userID) == true && userID > 0 && userID < 9223372036854775807)
                args.IsValid = true;
            else
                args.IsValid = false;
        }
        
        function IsNumeric(sText) {
            var ValidChars = "0123456789";
            var IsNumber = true;
            var Char;

            for (i = 0; i < sText.length && IsNumber == true; i++) {
                Char = sText.charAt(i);
                if (ValidChars.indexOf(Char) == -1) {
                    IsNumber = false;
                }
            }
            return IsNumber;
        }
        
        function selfClose(refreshOpener) {
            if (refreshOpener) {
                parent.document.forms[0].submit();
                //JQueryDialogClose();
            }
        }

        function CheckPermissionsSaving() {
            var warnMessage = "!" + "שים לב" + "\n\r";
            warnMessage += "!" + "הרשאות אחרונות לא הוספו למערכת ולא ישמרו" + "\n\r";
            warnMessage += "." + "על מנת להוסיף יש לבטל את הפעולה וללחוץ על הוספה" + "\n\r";;
            //warnMessage += " \" " + "הוספה" + " \" " + "\n\r";
            warnMessage += "?" + "האם ברצונך להמשיך";
            
            var selectedIndex = document.getElementById('<%= ddlPermissionType.ClientID %>').selectedIndex;
            if (selectedIndex != 0) {
                return confirm(warnMessage);
            }
            return true;
        }

    </script>

</head>

<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" />
        
    <table cellpadding="0" cellspacing="0" style="direction: rtl; width: 100%; background-color: White;">
        <tr>
            <td align="right" style="background-color: #298AE5; padding-right: 5px; height: 24px">
                <asp:Label ID="lblTitle" EnableTheming="false" CssClass="LabelBoldWhite_18"
                    runat="server" Text="עדכון פרטי משתמש"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ValidationSummary ID="vldSumUserDetails" runat="server" ValidationGroup="grGetUserFromAD" />
            </td>
        </tr>
    </table>        
    <table cellpadding="0" cellspacing="0" dir="rtl" width="100%" border="0">
        <!-- users details -->
        <tr>
            <td style="padding-top:5px; padding-right:10px" align="right">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: top">
                        </td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td align="right" valign="top">
                            <table cellpadding="0" cellspacing="0" width="520px" >
                                <tr>
                                    <td align="right" style="padding: 0px 5px 5px 0px; margin: 0px 0px 0px 0px">
                                        <asp:Label ID="lblUserDetailesCap" runat="server" Text="פרטי משתמש" EnableTheming="false"
                                            CssClass="LabelCaptionBlueBold_14"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblError" runat="server" EnableTheming="false" CssClass="LabelBoldRed12"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <table cellpadding="0" cellspacing="0" style="border-bottom: solid 1px #BEBCB7; border-top: solid 1px #BEBCB7;">
                                <tr>
                                    <td style="border-bottom: solid 1px #BEBCB7;">
                                        <asp:Label ID="lblDomain" runat="server" Text="domain"></asp:Label>
                                    </td>
                                    <td style="border-bottom: solid 1px #BEBCB7;">&nbsp;</td>
                                    <td style="padding-right:10px;border-bottom: solid 1px #BEBCB7;">
                                        <asp:Label ID="lblUserAD" runat="server" Text="שם משתמש"></asp:Label>
                                    </td>
                                    <td style="border-bottom: solid 1px #BEBCB7;">&nbsp;</td>
                                    <td style="padding-right:10px;border-bottom: solid 1px #BEBCB7;">
                                        <asp:Label ID="lblDefinedInAD" Width="70px" runat="server" Text="מוגדר ב AD"></asp:Label>
                                    </td>
                                    <td style="border-bottom: solid 1px #BEBCB7;">&nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-top:4px">
                                        <asp:DropDownList Width="150px" ID="ddlUserDomain" runat="server" DataTextField="DomainName" DataValueField="DomainName" AppendDataBoundItems="True">
                                            <asp:ListItem Text="הכל" Value=""></asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td align="right" style="width:25px; padding:0px 3px 0px 0px;">
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserDomain" ValidationGroup="gvAddPermission" runat="server" ControlToValidate="ddlUserDomain" Text="*"></asp:RequiredFieldValidator>
                                        </div>
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserDomainToConfirm" ValidationGroup="grConfirm" runat="server" ControlToValidate="ddlUserDomain" Text="*"></asp:RequiredFieldValidator>
                                        </div>
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserDomainFromAD" ValidationGroup="grGetUserFromAD" runat="server" ControlToValidate="ddlUserDomain" Text="*"></asp:RequiredFieldValidator>
                                        </div>
                                    </td>
                                    <td style="padding-right:0px;padding-top:4px">
                                        <asp:TextBox ID="txtUserName" Width="130px" runat="server"></asp:TextBox>
                                    </td>
                                    <td align="right" style="width:30px; padding:0px 3px 0px 0px;">
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserName" runat="server" ControlToValidate="txtUserName" Text="*" ErrorMessage="חובה להזין שם משתמש" ValidationGroup="grSaveUser"></asp:RequiredFieldValidator>
                                        </div>
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserNameForUserPermission" runat="server" ControlToValidate="txtUserName" Text="*" ValidationGroup="gvAddPermission"></asp:RequiredFieldValidator>
                                        </div>                                        
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserNameForConfirm" runat="server" ControlToValidate="txtUserName" Text="*" ValidationGroup="grConfirm"></asp:RequiredFieldValidator>
                                        </div>                                        
                                        <div style="height:8px; overflow: hidden;">
                                        <asp:RequiredFieldValidator ID="vldUserNameFromAD" runat="server" ControlToValidate="txtUserName" Text="*" ValidationGroup="grGetUserFromAD"></asp:RequiredFieldValidator>
                                        </div>
                                    </td>
                                    <td style="padding-right:0px;padding-top:4px">
                                        <asp:CheckBox ID="cbDefinedInAD" runat="server" AutoPostBack="true" OnCheckedChanged="cbDefinedInAD_CheckedChanged" />
                                    </td>
                                    <td style="padding-right:0px;padding-top:4px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                    background-position: bottom left;">
                                                    &nbsp;
                                                </td>
                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                    background-repeat: repeat-x; background-position: bottom;">
                                                    <asp:Button ID="btnGetUserFromAD" Width="80px" runat="server" Text="הבאת נתונים"
                                                        CssClass="RegularUpdateButton" OnClick="btnGetUserFromAD_Click" ValidationGroup="grGetUserFromAD">
                                                    </asp:Button>
                                                </td>
                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                    background-repeat: no-repeat;">
                                                    &nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4" style="height:4px"></td>
                                </tr>
                            </table>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr><td colspan="4" style="height:10px"></td></tr>
                                <tr>
                                    <td style="padding-left:5px">
                                        <asp:Label ID="lblUserID" Width="70px" runat="server" Text="תעודת זהות"></asp:Label>
                                    </td>
                                    <td style="padding-left:10px;">
                                        <asp:TextBox ID="txtUserID" runat="server" ></asp:TextBox>
                                        <asp:CustomValidator ID="vldUserID" ClientValidationFunction="ValidateUserID" Text="*" runat="server" ValidationGroup="grSaveUser"></asp:CustomValidator>
                                        <asp:CustomValidator ID="vldUserIDForUserPermission" runat="server" ClientValidationFunction="ValidateUserID" Text="*" ValidationGroup="gvAddPermission"></asp:CustomValidator>
                                        <asp:CustomValidator ID="vldUserIDForConfirm" runat="server" ClientValidationFunction="ValidateUserID" Text="*" ValidationGroup="grConfirm"></asp:CustomValidator>
                                    </td>
                                    <td style="padding-left:5px">
                                        <asp:Label ID="lblUserPhone" Width="80px" runat="server" Text="מספר טלפון"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtUserPhone" Width="160px" runat="server" ReadOnly="true"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblFirstName" runat="server" Text="שם פרטי"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtFirstName" runat="server" ReadOnly="true"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblUserMail" runat="server" Text="email"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtUserMail" Width="160px" runat="server" ReadOnly="true"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblLastName" runat="server" Text="שם משפחה"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtLastName" runat="server" ReadOnly="true"></asp:TextBox>
                                    </td>
                                    <td style="padding-left:5px">
                                        <asp:Label ID="lblUserDescription" runat="server" Text="פרטים נוספים"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtUserDescription" Width="160px" runat="server" ></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td colspan="3" style="padding:3px 0px 0px 0px;">
                                        <table id="tblBtnConfirm" cellpadding="0" cellspacing="0" runat="server">
                                            <tr>
                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                    background-position: bottom left;">
                                                    &nbsp;
                                                </td>
                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                    background-repeat: repeat-x; background-position: bottom;">
                                                    <asp:Button ID="btnConfirm" Width="115px" runat="server" Text="וודא פרטי משתמש"
                                                        CssClass="RegularUpdateButton" ValidationGroup="grConfirm" 
                                                        OnClick="btnConfirm_Click">
                                                    </asp:Button>
                                                </td>
                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                    background-repeat: no-repeat;">
                                                    &nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- user permissions list -->
        <tr>
            <td style="padding-top:5px; padding-right:10px" align="right">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: top">
                        </td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td align="right" valign="top" style="width: 537px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="padding-right: 5px; padding-bottom: 5px; border-bottom: solid 1px #BEBCB7;">
                                        <asp:Label ID="lblUserPermissionsCaption" runat="server" Text="רשימת כל ההרשאות של המשתמש"
                                            EnableTheming="false" CssClass="LabelCaptionBlueBold_14"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-top:10px; padding-bottom:7px; border-bottom: solid 1px #BEBCB7;"">
                                        <table style="width:520px" cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td style="width:70px;padding-top:5px;" rowspan="3" valign="top">
                                                    <asp:Label ID="lblPermissionType" runat="server" Text="סוג הרשאה"></asp:Label>
                                                </td>
                                                <td style="width:200px;padding-top:5px;" rowspan="3" valign="top">
                                                    <asp:DropDownList ID="ddlPermissionType" Width="180px" OnSelectedIndexChanged="ddlPermissionType_SelectedIndexChanged"
                                                        AutoPostBack="true" runat="server" AppendDataBoundItems="True"
                                                        DataTextField="permissionDescription" DataValueField="permissionCode">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:CompareValidator ID="vldPermission" runat="server" ValidationGroup="gvAddPermission" ErrorMessage="*"
                                                            ControlToValidate="ddlPermissionType" ValueToCompare="-1" Operator="NotEqual"></asp:CompareValidator>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="cbErrorReport" runat="server" Enabled="false" />
                                                </td>
                                                <td style="width:140px">
                                                    <asp:Label ID="lblErrorReport" runat="server" Text="דיוח פרטים שגוים"></asp:Label>
                                                </td>
                                                <td style="padding-left:5px;padding-top:5px;" rowspan="2" valign="top">
                                                    <asp:ImageButton ID="imgBtnAddPermission" ValidationGroup="gvAddPermission" 
                                                        ToolTip="הוספה" runat="server" ImageUrl="../Images/btn_add.gif" 
                                                        onclick="imgBtnAddPermission_Click" />
                                                </td>
                                                <td style="padding-left:5px;padding-top:5px;" rowspan="3" valign="top">
                                                    <asp:ImageButton ID="imgBtnClean" ToolTip="ניקוי" runat="server" ImageUrl="../Images/btn_clear.gif" OnClientClick="return CleanUserPermission();" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-bottom:5px;">
                                                    <asp:CheckBox ID="cbTrackingNewClinic" runat="server" Enabled="false" />
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblTrackingNewClinic" runat="server" Text="הודעה על פתיחת יחידה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-bottom:5px;">
                                                    <asp:CheckBox ID="cbTrackingFreeRemark" runat="server" Enabled="false" />
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblTrackingFreeRemark" runat="server" Text="הודעה על הוספת הערה ליחידה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr id="trDdlDistricts" runat="server">
                                                <td>
                                                    <asp:Label ID="lblDistricts" runat="server" Text="מחוז"></asp:Label>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlDistricts" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDistricts_selectedChanged"
                                                        DataTextField="districtName" DataValueField="districtCode" Width="323px" AppendDataBoundItems="true">
                                                        <asp:ListItem Text="" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:CompareValidator runat="server" ValidationGroup="gvAddPermission" ID="vldDdlDistricts" ControlToValidate="ddlDistricts" Operator="NotEqual" ValueToCompare="-10" Text="*1" ></asp:CompareValidator>
                                                    <asp:CustomValidator ID="valCstConsistency" ValidationGroup="gvAddPermission" runat="server" ClientValidationFunction="ValidateConsistency" Text="*2"></asp:CustomValidator>
                                                </td>
                                                <td colspan="2"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblMinhelet" runat="server" Text="מנהלת"></asp:Label>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtMinhelet" runat="server" Width="320px" Enabled="false" AutoPostBack="true"
                                                        OnTextChanged="TxtMinhelet_Changed" onblur="ClearMinheletAndDept();"></asp:TextBox>
                                                    <cc1:AutoCompleteExtender ID="acMinhelet" runat="server" TargetControlID="txtMinhelet"
                                                        FirstRowSelected="true" ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAdminByName_DistrictDepended"
                                                        CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" MinimumPrefixLength="1" CompletionSetCount="12" DelimiterCharacters=""
                                                        Enabled="true" OnClientItemSelected="MinheletSelected" CompletionListCssClass="CopmletionListStyle">
                                                    </cc1:AutoCompleteExtender>
                                                </td>
                                                <td colspan="2">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDept" runat="server" Text="מרפאה"></asp:Label>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtDept" runat="server" Width="320px" onblur="ClearDept();" Enabled="false"></asp:TextBox>
                                                    <cc1:AutoCompleteExtender ID="acDept" runat="server" TargetControlID="txtDept" FirstRowSelected="true"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetClinicByName_DeptCodePrefixed_DistrictDepended"
                                                        CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="false" MinimumPrefixLength="1" CompletionSetCount="12" DelimiterCharacters=""
                                                        Enabled="true" OnClientItemSelected="DeptSelected" CompletionListCssClass="CopmletionListStyle">
                                                    </cc1:AutoCompleteExtender>
                                                </td>
                                                <td colspan="2">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" id="tblGvUserPermissions" runat="server" style="width: 475px">
                                            <tr>
                                                <td valign="top" style="border-bottom: solid 1px #BEBCB7;">
                                                    <div id="divPermissions" runat="server" style="direction:ltr; height: 115px; width: 515px; overflow-y: scroll"
                                                        class="ScrollBarDiv">
                                                        <div style="direction:rtl">
                                                            <asp:GridView ID="gvUserPermissions" runat="server" AutoGenerateColumns="False"
                                                            Width="495px" SkinID="GridViewForSearchResults" HeaderStyle-CssClass="LabelBoldDirtyBlue">
                                                            <Columns>
                                                                <asp:BoundField DataField="permissionDescription" ItemStyle-Width="90px"  HeaderText="סוג הרשאה" />
                                                                <asp:BoundField DataField="deptCode" HeaderText="קוד יחידה" ItemStyle-Width="60px" ItemStyle-CssClass="ltr" ItemStyle-HorizontalAlign="Right"/>
                                                                <asp:BoundField DataField="deptName" HeaderText="שם יחידה" ItemStyle-Width="175px" />
                                                                <asp:BoundField DataField="ErrorReportDescription" ItemStyle-Width="70px" ItemStyle-CssClass="RegularLabel" HeaderText="דיוח פרטים שגוים" />
                                                                <asp:BoundField DataField="TrackingNewCliniDescription" ItemStyle-Width="70px" ItemStyle-CssClass="RegularLabel" HeaderText="הודעה על פתיחת יחידה" />
                                                                <asp:BoundField DataField="TrackingRemarkChangesDescription" ItemStyle-Width="70px" ItemStyle-CssClass="RegularLabel" HeaderText="הודעה על הוספת הערה ליחידה" />
                                                                <asp:TemplateField ItemStyle-Width="25px">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnDeletePermission" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                            UserID='<%# Eval("UserID")%>' deptCode='<%# Eval("deptCode")%>' PermissionType='<%# Eval("PermissionType")%>'
                                                                            OnClick="btnDeletePermission_Click" ToolTip="מחיקה" OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את ההרשאה')">
                                                                        </asp:ImageButton>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div style="height:10px; overflow: hidden;">
    <asp:CheckBox ID="cbNewUser" runat="server" CssClass="DisplayNone"/>
    <asp:TextBox ID="hdnDeptCode" runat="server" Width="40px" EnableTheming="false" CssClass="DisplayNone"/>
    <asp:TextBox ID="hdnDeptText" runat="server" EnableTheming="false" CssClass="DisplayNone"/>
    <asp:TextBox ID="hdnMinheletValue" runat="server" Width="40px" EnableTheming="false" CssClass="DisplayNone"/>
    <asp:TextBox ID="hdnMinheletText" runat="server" Width="40px"  EnableTheming="false" CssClass="DisplayNone"/>
    <asp:TextBox ID="hdnInitialUserID" runat="server" Width="40px"  EnableTheming="false" CssClass="DisplayNone" />
    <asp:TextBox ID="hdnUserNameFromQueryString" runat="server" Width="40px"  EnableTheming="false" CssClass="DisplayNone" />
    <asp:TextBox ID="hdnDomainFromQueryString" runat="server" Width="40px"  EnableTheming="false" CssClass="DisplayNone" />
    </div>
    <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="right">
                <table cellpadding="0" cellspacing="0" dir="rtl">
                    <tr>
                        <td style="padding-right:65px;padding-left:10px;">
                            <asp:Label ID="lblRemainder" EnableTheming="false" CssClass="LabelWarningOrange" runat="server" Text="שימו לב יש ללחוץ על כפתור שמירה לאחר עדכון הרשאות"></asp:Label>
                        </td>
                        <td>
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnSave" Width="60px" runat="server" Text="שמירה"
                                            CssClass="RegularUpdateButton" onclick="btnSave_Click"  ValidationGroup="grSaveUser" OnClientClick="return CheckPermissionsSaving();">
                                        </asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnCancel" Width="60px" runat="server" Text="ביטול"
                                            CssClass="RegularUpdateButton" OnClientClick="JQueryDialogClose(); return false;" onclick="btnCancel_Click">
                                        </asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div id="dialog-modal-inner" title="Modal Dialog Select" style="display:none; vertical-align:top; width:100%;">
        <iframe id="modalSelectIFrameInner" style="width:100%; height:100%; background-color:white;" title="Dialog Title">
    </iframe>
    </div>    
    </form>
    <script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>

    <script type="text/javascript">
        function OpenJQueryDialog_INNER(url, dialogWidth, dialogHeight, Title) {
            $('#dialog-modal-inner').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-inner').dialog("option", "width", dialogWidth);
            $('#dialog-modal-inner').dialog("option", "height", dialogHeight);
            $('#dialog-modal-inner').dialog("option", "title", Title);
            $('#dialog-modal-inner').dialog('open');
            $('#dialog-modal-inner').parent().appendTo($("form:first"));
            $("#modalSelectIFrameInner").attr('src', url);

            return false;
        }
    </script>
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</body>
</html>
