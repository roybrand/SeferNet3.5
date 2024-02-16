<%@ Page Language="C#" Title="פרטי סל שירות" AutoEventWireup="true" MasterPageFile="~/SeferMasterPageIEwide.master" Theme="SeferGeneral" Inherits="ZoomSalService"
    EnableEventValidation="false" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" Codebehind="ZoomSalService.aspx.cs" ValidateRequest="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagName="ucDeptReceptionAndRemarks" TagPrefix="uc" Src="../usercontrols/DeptReceptionAndRemarks.ascx" %>
<%@ MasterType VirtualPath="~/SeferMasterPageIEwide.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>
<asp:Content ID="ContentHeader" ContentPlaceHolderID="phHead" runat="server">
    <link href="../CLEditor/jquery.cleditor.css" rel="stylesheet" type="text/css" />
    <script src="../CLEditor/jquery.cleditor.js" type="text/javascript"></script>
    <script src="../CLEditor/jquery.cleditor.min.js" type="text/javascript"></script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
     <script type="text/javascript">
         function BindEvents() {
             $(document).ready(function () {
                 $("#<%=txtServiceDetailsInternet.ClientID%>").cleditor(
            {
                controls: "bold italic underline strikethrough subscript superscript | font  size  style |"
                  + " color highlight removeformat | bullets numbering | outdent indent | "
                  + " alignleft center alignright justify | undo redo | rule link unlink |"
                  + " cut copy paste pastetext | print source"
            }
            );
             });
         }
    </script>

    <script type="text/javascript">

        function SetTabToBeShownOnLoad() {
            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            if (txtTabToBeShown.value != "") {
                var str = txtTabToBeShown.value;
                var parameters = str.split(',');
                //if (parameters.length == 3)
                //{
                SetTabToBeShown(parameters[0], parameters[1], parameters[2], parameters[2]);
                //}
            }
            else
            {
                //alert("Here");
                SetTabToBeShown('divSalServiceDetailsBut', 'trSalServiceDetails', 'tdSalServiceDetailsTab', '1');
            }
        }

        function SetTabToBeShown(btnId, sectionId, tabId, selectedTab)
        {
            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            txtTabToBeShown.value = btnId + "," + sectionId + "," + tabId;

            hideAllTabSections();
            //alert(btnId + "  " + selectedTab);
            if (selectedTab) {
                SimpleService.SetSelectedTabInSession(selectedTab);
            }

            var prefix = "ctl00_pageContent_";
            var sectionFullId = prefix + sectionId;

            var tabFullId = prefix + tabId;
            var btnFullId = prefix + btnId;
            var substitute_DIV_ID = btnFullId + "_Tab";

            var section = document.getElementById(sectionId);
            if (!section) {
                section = document.getElementById(sectionFullId);
            }
            var tab = document.getElementById(tabFullId);
            var btn = document.getElementById(btnFullId); // it's DIV now

            var substitute_DIV = document.getElementById(substitute_DIV_ID); // substitute DIV

            if (section != null && btn!=null) {
                section.style.display = "inline";
                btn.style.display = "none";
                substitute_DIV.style.display = "inline";
                //alert(substitute_DIV_ID);
            }
        }

        function ClearTxtTabToBeShown() {
            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            txtTabToBeShown.value = "";
        }

        // To show MushlamServices just remove comments in function hideAllTabSections()
        function hideAllTabSections() {
            
            var trSalServiceDetails = document.getElementById("trSalServiceDetails");
            var trSalServiceTarifon = document.getElementById("trSalServiceTarifon");
            var trSalServiceICD9 = document.getElementById("trSalServiceICD9");
            var trSalServiceInternetDetails = document.getElementById('<% = trSalServiceInternetDetails.ClientID %>');
            //var trMushlamServices = document.getElementById("trMushlamServices");

            var divSalServiceDetailsBut = document.getElementById('<%=divSalServiceDetailsBut.ClientID%>');
            var divSalServiceDetailsBut_Tab = document.getElementById('<%=divSalServiceDetailsBut_Tab.ClientID%>');

            var divSalServiceICD9But = document.getElementById('<%=divSalServiceICD9But.ClientID%>');
            var divSalServiceICD9But_Tab = document.getElementById('<%=divSalServiceICD9But_Tab.ClientID%>');

            if (trSalServiceInternetDetails) {
                var divSalServiceInternetDetailsBut = document.getElementById('<% = divSalServiceInternetDetailsBut.ClientID %>');
                var divSalServiceInternetDetailsBut_Tab = document.getElementById('<%=divSalServiceInternetDetailsBut_Tab.ClientID%>');

                trSalServiceInternetDetails.style.display = "none";
                divSalServiceInternetDetailsBut.style.display = "inline";
            }

            //var divMushlamServicesBut = document.getElementById('<%=divMushlamServicesBut.ClientID%>');
            //var divMushlamServicesBut_Tab = document.getElementById('<%=divMushlamServicesBut_Tab.ClientID%>');

            divSalServiceDetailsBut.style.display = "inline";
            divSalServiceDetailsBut_Tab.style.display = "none";

            divSalServiceICD9But.style.display = "inline";
            divSalServiceICD9But_Tab.style.display = "none";

            //divMushlamServicesBut.style.display = "inline";
            //divMushlamServicesBut_Tab.style.display = "none";

            if (divSalServiceInternetDetailsBut_Tab)
                divSalServiceInternetDetailsBut_Tab.style.display = "none";

            if (trSalServiceDetails)
                trSalServiceDetails.style.display = "none";

            if (trSalServiceTarifon) {
                var divSalServiceTarifonBut = document.getElementById('<%=divSalServiceTarifonBut.ClientID%>');
                var divSalServiceTarifonBut_Tab = document.getElementById('<%=divSalServiceTarifonBut_Tab.ClientID%>');

                divSalServiceTarifonBut.style.display = "inline";
                divSalServiceTarifonBut_Tab.style.display = "none";
                trSalServiceTarifon.style.display = "none";
            }

            if (trSalServiceICD9) {
                trSalServiceICD9.style.display = "none";
            }

            if (trMushlamServices) {
                trMushlamServices.style.display = "none";
            }

        }

        function HideShowSubTable(imagebutton) {

            if (imagebutton.src.indexOf('btn_Plus') > -1) {
                var trId = imagebutton.id.replace("imgExpandCollapse", "trPopulationHistoryTarifon");
                var lblPopulationsCode = imagebutton.id.replace("imgExpandCollapse", "lblPopulationsCode");
                var lblSubPopulationsCode = imagebutton.id.replace("imgExpandCollapse", "lblSubPopulationsCode");
                var pPopulationHistoryTarifon = imagebutton.id.replace("imgExpandCollapse", "pPopulationHistoryTarifon");

                var populationsCode = document.getElementById(lblPopulationsCode).innerText;
                var subPopulationsCode = document.getElementById(lblSubPopulationsCode).innerText;

                document.getElementById(trId).style.display = 'inline';
                imagebutton.src = '../Images/Applic/btn_Minus_Blue_12.gif';

                BindHistoryTarifon(populationsCode, subPopulationsCode, pPopulationHistoryTarifon);
            }
            else {
                var trId = imagebutton.id.replace("imgExpandCollapse", "trPopulationHistoryTarifon");
                document.getElementById(trId).style.display = 'none';
                imagebutton.src = '../Images/Applic/btn_Plus_Blue_12.gif';
            }
        }

        function ShowPopulationPopUp(imgInfo) {
            var lblPopulationsCode = imgInfo.id.replace("imgInfo", "lblPopulationsCode");
            var lblSubPopulationsCode = imgInfo.id.replace("imgInfo", "lblSubPopulationsCode");

            var populationCode = document.getElementById(lblPopulationsCode).innerText;
            var subPopulationsCode = document.getElementById(lblSubPopulationsCode).innerText;

            var url = "PopulationDetails.aspx?pCode=" + populationCode + '&pSubcode=' + subPopulationsCode;
            var dialogWidth = 500;
            var dialogHeight = 260;
            var title = "";// "השתתפות עצמית";
            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        var tempPopulationHistoryContainerPanelId = '';

        function BindHistoryTarifon(populationsCode, subPopulationsCode, pPopulationHistoryTarifon) {
            tempPopulationHistoryContainerPanelId = pPopulationHistoryTarifon;

            var serviceCode = document.getElementById('<%= lblServiceCode.ClientID %>').innerText;

            var paramData = "'serviceCode': " + serviceCode + ";'populationsCode': " + populationsCode + ";'subPopulationsCode': " + subPopulationsCode;

            PageMethods.BindHistoryTarifon(paramData, onSucess, onError);
        }

        function onSucess(result) {
            document.getElementById(tempPopulationHistoryContainerPanelId).innerHTML = result;
        }

        function onError(result) {
            alert('Error: ' + result.get_message());
        }

        function SelectedTabIsForRegesteredOnlyAlert(selectedTab) {
            alert("לא ניתן להציג את הכרטיסייה פרטי אינטרנט. צריך לוגין כדי לראות את זה");
        }

        function SelectedTabIsForPermittedOnlyAlert(){
            alert("לא ניתן להציג את הכרטיסייה פרטי אינטרנט. אין לך הרשאות לראות את זה");
        }

    </script>
    <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
        background-color: White;">
    </div>
    <!-- tab buttons -->
    <table cellpadding="0" cellspacing="0" style="background-image: url('../Images/GradientVerticalBlueAndWhite.jpg');
        background-repeat: repeat-x;" dir="rtl">
        <tr>
            <td style="width: 100%; background-image: url('../Images/Applic/tab_WhiteBlueBackGround.jpg');
                background-position: bottom; background-repeat: repeat-x; margin: 0px 0px 0px 0px;
                padding: 0px 0px 6px 0px;">
                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                    <tr>
                        <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="width: 10px; height: 30px;">
                                    </td>
                                    <%--------------- tdSalServiceDetailsTab -------------------%>
                                    <td id="tdSalServiceDetailsTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divSalServiceDetailsBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnSalServiceDetailsTab" runat="server" Height="18px" Width="110px"
                                                            Text="נתוני שירות" CssClass="TabButton_14" OnClientClick="SetTabToBeShown('divSalServiceDetailsBut','trSalServiceDetails','tdSalServiceDetailsTab','1'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divSalServiceDetailsBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x; width: 110px" class="TDpadding0">
                                                        <asp:Label ID="lblTabSalServiceDetails" runat="server" Text="נתוני שירות" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%---------------- tdSalServiceTarifonTab --------------------%>
                                    <asp:PlaceHolder runat="server" ID="phSalServiceTarifonTab">
                                    <td id="tdSalServiceTarifonTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divSalServiceTarifonBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnSalServiceTarifonTab" runat="server" Text="תעריפון" CssClass="TabButton_14"
                                                            Width="110px" Height="18px" OnClientClick="SetTabToBeShown('divSalServiceTarifonBut','trSalServiceTarifon','tdSalServiceTarifonTab','2'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divSalServiceTarifonBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x; width: 110px" class="TDpadding0">
                                                        <asp:Label ID="lblTabSalServiceTarifon" runat="server" Text="תעריפון" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    </asp:PlaceHolder>
                                    <%---------------- tdSalServiceICD9Tab --------------------%>
                                    <td id="tdSalServiceICD9Tab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divSalServiceICD9But" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnSalServiceICD9Tab" runat="server" Text="קודי ICD9" CssClass="TabButton_14"
                                                            Width="110px" Height="18px" OnClientClick="SetTabToBeShown('divSalServiceICD9But','trSalServiceICD9','tdSalServiceICD9Tab','3'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divSalServiceICD9But_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x; width: 110px" class="TDpadding0">
                                                        <asp:Label ID="lblTabSalServiceICD9" runat="server" Text="קודי ICD9" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%---------------- tdSalServiceInternetDetailsTab --------------------%>
                                    <td id="tdSalServiceInternetDetailsTab" runat="server" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divSalServiceInternetDetailsBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnSalServiceInternetDetailsTab" runat="server" Text="פרטי אינטרנט"
                                                            CssClass="TabButton_14" Width="110px" Height="18px" OnClientClick="SetTabToBeShown('divSalServiceInternetDetailsBut','trSalServiceInternetDetails','tdSalServiceInternetDetailsTab','4'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divSalServiceInternetDetailsBut_Tab" runat="server" style="display: none;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x; width: 110px" class="TDpadding0">
                                                        <asp:Label ID="lblTabSalServiceInternetDetails" runat="server" Text="פרטי אינטרנט"
                                                            EnableTheming="false" CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%---------------- tdMushlamServices --------------------%>
                                    <td id="tdMushlamServicesTab" runat="server" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divMushlamServicesBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="Button5" runat="server" CssClass="TabButton_14" Width="90px"
                                                            Height="18px"  Text="שירותי מושלם" OnClientClick="SetTabToBeShown('divMushlamServicesBut','trMushlamServices','tdMushlamServicesTab','5'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divMushlamServicesBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="Label7" runat="server" Text="שירותי מושלם" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>

                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="left">
                            <asp:TextBox ID="txtTabToBeShown" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                            <asp:ImageButton ID="btnBack" runat="server" ImageUrl="../Images/Applic/btn_back.png"
                                OnClick="btnBack_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- Sal Service details -->
        <tr id="trSalServiceDetails">
            <td style="padding-bottom: 10px;">
                
                <div style="padding:2px 4px 0px 6px">
                    <table cellpadding="1" cellspacing="1" border="0" width="100%" class="BackColorBlue">
                        <tr>
                            <td valign="middle"><asp:Image ID="imgAttributed_1" runat="server" ToolTip="שירותי בריאות כללית" CssClass="DisplayNone" /></td>    
                            <td style="width:580px;padding-left:10px" valign="middle">
                                <asp:Label ID="lblSalServiceMIN_CODE" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                <asp:Label ID="lblSalServiceCode" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                <asp:Label ID="lblSalServiceName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                            </td>
                            <td align="left" style="padding-left:20px" valign="middle">

                            </td>
                            <td style="width:144px" valign="middle">
                                <asp:Label runat="server" ID="lblUpdateDate" EnableTheming="false" CssClass="LabelBoldWhite" Text="עדכון אחרון: "></asp:Label>
                                <asp:Label runat="server" ID="lblUpdateDateFld" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                
                <table id="tblSalServiceDetails" style="width: 990px; border: solid 1px #D4EAFB;
                    background-color: White; height: 453px">
                    <tr>
                        <td valign="top" style="/*padding-top: 8px*/">
                            <asp:UpdatePanel runat="server" ID="upServiceDetails">
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="ddlSalServiceUpdateDates" />
                                </Triggers>
                                <ContentTemplate>
                                    <table border="0" cellpadding="1" cellspacing="1" width="100%" style="margin-top: 10px; border-bottom: #dddddd 1px solid;
                                        border-left: #dddddd 1px solid; background-color: #f7f7f7; width: 100%; margin-bottom: 8px;
                                        border-top: #dddddd 1px solid; border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd; width: 100px">
                                                <span class="LabelBoldDirtyBlue">קוד כללית:</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd; width: 80px">
                                                <asp:Label runat="server" ID="lblServiceCode"></asp:Label>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd; width: 100px">
                                                <span class="LabelBoldDirtyBlue">תיאור:</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <asp:Label ID="lblServiceName" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;">
                                                <span class="LabelBoldDirtyBlue">קוד משה"ב:</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <table border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <asp:PlaceHolder runat="server" ID="phGovernmentServiceCode">
                                                            <td style="padding-right: 4px">
                                                                <asp:Image runat="server" ID="imgGovernmentServiceCode" ImageUrl="~/Images/Info.gif"
                                                                    BackColor="Transparent" ToolTip="אין קוד מקורי של משרד הבריאות לפעולה זו" Height="20px"
                                                                    Width="10px" />
                                                            </td>
                                                        </asp:PlaceHolder>
                                                        <td>
                                                            <asp:Label runat="server" ID="lblMinCode"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <span class="LabelBoldDirtyBlue">תיאור באנגלית:</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <asp:Label ID="lblServiceNameEnglish" runat="server"></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 5px;">
                                                <asp:Label ID="lblUpdateDateCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                    runat="server" Text="ת. עדכון סל"></asp:Label>
                                            </td>
                                            <td valign="top" colspan="2" style="padding-top: 5px;">
                                                <asp:DropDownList runat="server" ID="ddlSalServiceUpdateDates" Width="100px" AutoPostBack="true" ToolTip="יש לבחור את תאריך העדכון שברצונך לראות"
                                                    OnSelectedIndexChanged="ddlSalServiceUpdateDates_SelectedIndexChanged" DataTextField="BasketApproveDate"
                                                    DataTextFormatString="{0:dd/MM/yyyy}" DataValueField="BasketApproveDate">
                                                </asp:DropDownList>
                                            </td>
                                            <td valign="top" style="padding-top: 0px; padding-bottom: 0px">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td id="tdIncludeInBasket" runat="server" style="padding:0px 0px 0px 0px">&nbsp;
                                                            <asp:Label ID="lblIncludeInBasket" runat="server"></asp:Label>&nbsp;
                                                        </td>
                                                        <td style="padding:0px 0px 0px 0px">
                                                            &nbsp;<asp:Label ID="lblDatefrom" runat="server"></asp:Label>&nbsp;
                                                        </td>
                                                    </tr>
                                                </table>

                                            </td>
                                        </tr>
                                    </table>
                                    <div style="position:absolute"><div style="position:absolute;left:-950px;top:-42px;" dir="ltr">
                                            <asp:HyperLink runat="server" ID="hlHozreiSherut" Target="_blank">
                                                <table><tr><td>
                                                <img src="../Images/HozreiSherutBig.png" width="30" height="30" border="0" alt="חוזרי שירות" title="חוזרי שירות" />
                                                </td>
                                                <td>
                                                <span style="font-family:arial;font-weight:bold;font-size:13px;color:#49769C;vertical-align:middle;display:inline;">:קבצים מצורפים</span>
                                                </td>
                                            </tr></table>
                                            </asp:HyperLink>
                                        </div>
                                    </div>
                                    <table runat="server" id="tblAdditionalServiceDetails" border="0" cellpadding="1"
                                        cellspacing="1" width="100%" style="margin-top: 10px; border-bottom: #dddddd 1px solid;
                                        border-left: #dddddd 1px solid; background-color: #f7f7f7; width: 100%; margin-bottom: 8px;
                                        border-top: #dddddd 1px solid; border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd; width: 120px">
                                                <asp:Label ID="lblLimiterCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                    runat="server" Text="הערת הגבלה"></asp:Label>
                                            </td>
                                            <td valign="top" colspan="3" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <asp:Label ID="lblLimitationComment" runat="server"></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd; width: 100px">
                                                <span class="LabelBoldDirtyBlue">אשכול</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:340px">
                                                <asp:Label runat="server" ID="lblEshkolDesc" CssClass="RegularLabel"></asp:Label>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;" colspan="2">
                                                <asp:Label ID="lblFormTypeCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                    runat="server" Text="סוג טופס" style="display:inline-block;width:80px"></asp:Label>
                                                <asp:Label ID="lblFormType" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <span class="LabelBoldDirtyBlue">כללי חיוב</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd">
                                                <asp:Label runat="server" ID="lblPaymentRules" CssClass="RegularLabel"></asp:Label>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd" colspan="2">
                                                <span class="LabelBoldDirtyBlue" style="display:inline-block;width:80px">סיווג תקציבי</span>
                                                <asp:Label runat="server" ID="lblBudgetDesc" CssClass="RegularLabel"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px;/* border-bottom: 1px solid #dddddd*/">
                                                <span class="LabelBoldDirtyBlue">שמות נרדפים</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px;/* border-bottom: 1px solid #dddddd*/">
                                                &nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px;/* border-bottom: 1px solid #dddddd*/">
                                                <span class="LabelBoldDirtyBlue">עומרי החזר</span>
                                            </td>
                                            <td valign="top" style="padding-top: 2px;/* border-bottom: 1px solid #dddddd*/">
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" colspan="2" style="padding-top: 2px;">
                                                <asp:Label runat="server" ID="lblSynonym" CssClass="RegularLabel"></asp:Label>&nbsp;
                                            </td>
                                            <td valign="top" colspan="2" style="padding-top: 2px;">
                                                <asp:Label runat="server" ID="lblOmriReturns" CssClass="RegularLabel" Text=""></asp:Label>&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px;">
                                                
                                            </td>
                                            <td valign="top" style="padding-top: 2px;">
                                                
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="text-align: right; background-color: #2889e4; margin-top: 10px; padding-right: 5px;">
                                        <span class="LabelBoldWhite">הנחיות מנהליות</span>
                                    </div>
                                    <table runat="server" id="tblGuidances" border="0" cellpadding="1" cellspacing="1"
                                        width="100%" style="border-bottom: #dddddd 1px solid; border-left: #dddddd 1px solid;
                                        background-color: #f7f7f7; width: 100%; margin-bottom: 8px; border-top: #dddddd 1px solid;
                                        border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; padding-right: 2px">
                                                <asp:Label runat="server" CssClass="RegularLabel" ID="lblGeneralManagementInstructions"></asp:Label>&nbsp;
                                                <br />
                                                <br />
                                                <asp:Repeater runat="server" ID="rGuidances" OnItemDataBound="rGuidances_ItemDataBound">
                                                    <HeaderTemplate>
                                                        <table cellspacing="0" cellpadding="5" border="1" bordercolor="#dddddd" bordercolorlight="#ffffff"
                                                            bordercolordark="#dddddd" borderoutercolor="red" width="100%" style="font-size: 12px">
                                                            <tr style="background: #d3e5fd">
                                                                <td align="center" nowrap="noWrap">
                                                                    <b>אבחנה</b>
                                                                </td>
                                                                <td align="center" nowrap="noWrap" style="width: 34px">
                                                                    <b>גיל</b>
                                                                </td>
                                                                <td align="center" nowrap="noWrap">
                                                                    <b>שרות כללית/ב''ח ציבורי/מכון בהסדר</b>
                                                                </td>
                                                                <td align="center" nowrap="noWrap">
                                                                    <b>טיפול</b>
                                                                </td>
                                                                <td align="center" nowrap="noWrap">
                                                                    <b>הערה</b>
                                                                </td>
                                                            </tr>
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td valign="baseline" style="border-bottom:2px solid #BBBBBB">
                                                                <asp:Label runat="server" ID="lblDiagnostics" Text='<%# Eval("Diagnostics")%>'></asp:Label>&nbsp;
                                                            </td>
                                                            <td valign="baseline" runat="server" id="tdAge" style="background-color: #f6fbff;border-bottom:2px solid #BBBBBB"
                                                                align="center">
                                                                <asp:Label runat="server" ID="lblAge" Text='<%# Eval("Age")%>'></asp:Label>&nbsp;
                                                            </td>
                                                            <td valign="baseline" style="border-bottom:2px solid #BBBBBB">
                                                                <asp:Label runat="server" ID="lblPublicFacility" Text='<%# Eval("PublicFacility")%>'></asp:Label>&nbsp;
                                                            </td>
                                                            <td valign="baseline" style="border-bottom:2px solid #BBBBBB">
                                                                <asp:Label runat="server" ID="lblTreatment" Text='<%# Eval("Treatment")%>'></asp:Label>&nbsp;
                                                            </td>
                                                            <td valign="baseline" style="border-bottom:2px solid #BBBBBB">
                                                                <asp:Label runat="server" ID="lblComment" Text='<%# Eval("Comment")%>'></asp:Label>&nbsp;
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </table>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="text-align: right; background-color: #2889e4; margin-top: 10px; padding-right: 5px;">
                                        <span class="LabelBoldWhite">הנחיות רפואיות</span>
                                    </div>
                                    <table id="tblMedicalInstructions" runat="server" border="0" cellpadding="1" cellspacing="1"
                                        width="100%" style="border-bottom: #dddddd 1px solid; border-left: #dddddd 1px solid;
                                        background-color: #f7f7f7; width: 100%; margin-bottom: 8px; border-top: #dddddd 1px solid;
                                        border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; padding-right: 2px">
                                                <asp:Label runat="server" ID="lblMedicalInstructions"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- Sal Service Tarifon -->
        <asp:PlaceHolder runat="server" ID="phSalServiceTarifon">
        <tr id="trSalServiceTarifon">
            <td style="padding-bottom: 10px;">
                <div class="BackColorBlue">
                    <div style="padding:2px 4px 0px 6px">
                        <table cellpadding="1" cellspacing="1" border="0" width="100%">
                            <tr>
                                <td style="width:30px"><asp:Image ID="imgAttributed_2" runat="server" ToolTip="שירותי בריאות כללית" CssClass="DisplayNone" /></td>    
                                <td style="width:580px;padding-left:10px">
                                    <asp:Label ID="lblSalServiceMIN_CODE2" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                    <asp:Label ID="lblSalServiceCode2" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                    <asp:Label ID="lblSalServiceName2" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                </td>
                                <td align="left" style="padding-left:20px"><asp:Label ID="lblIncludeInBasket_Tarifon" runat="server"></asp:Label><asp:Label ID="lblDatefrom_Tarifon" runat="server"></asp:Label></td>
                                <td style="width:144px">
                                    <asp:Label runat="server" ID="lblUpdateDate_Tarifon" EnableTheming="false" CssClass="LabelBoldWhite" Text="עדכון אחרון:"></asp:Label>&nbsp;
                                    <asp:Label runat="server" ID="lblUpdateDateFld_Tarifon" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                                </td>
                            </tr>
                        </table>
                     </div>
                </div>
                <table id="tblSalServiceTarifon" style="width: 990px; border: solid 1px #D4EAFB;
                    background-color: White; height: 453px">
                    <tr>
                        <td valign="top" style="padding-top: 8px">
                            <table cellpadding="0" cellspacing="0">
                                <tr style="background-color: #e8f4fd;">
                                    <td style="padding-bottom: 0px; padding-left: 0px; width: 980px; padding-right: 0px;
                                        padding-top: 0px">
                                        <table cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="padding-right: 5px; height: 25px" valign="middle" align="right">
                                                    <span class="LabelCaptionBlue_14" style="font-size: 16px;">תעריפים לפי אוכלוסיות</span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <asp:Repeater runat="server" ID="rSalServiceTarifon" OnItemDataBound="rSalServiceTarifon_ItemDataBound">
                                <HeaderTemplate>
                                    <table cellspacing="0" cellpadding="5" border="0" bordercolor="#dddddd" bordercolorlight="#ffffff"
                                        bordercolordark="#dddddd" style="width: 560px; font-size: 12px; border-top: 1px solid #ffffff">
                                        <tr style="background: #f7faff; padding-top: 2px; padding-bottom: 2px;">
                                            <td align="center" nowrap="noWrap" style="width: 40px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px">
                                                    &nbsp;</div>
                                            </td>
                                            <td align="right" nowrap="noWrap" style="width: 140px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    אוכלוסיה</div>
                                            </td>
                                            <td align="right" nowrap="noWrap" style="width: 140px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    תת אוכלוסיה</div>
                                            </td>
                                            <td align="left" nowrap="noWrap" style="width: 134px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 4px" class="ColumnHeader">
                                                    תעריף</div>
                                            </td>
                                            <td align="left" nowrap="noWrap" style="width: 90px; padding: 3px 0px 3px 7px">
                                                <div style="padding: 2px 0px 2px 2px" class="ColumnHeader">
                                                    נכונות</div>
                                            </td>
                                            <asp:PlaceHolder runat="server" Visible='<%# (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) %>'>
                                            <td align="center" nowrap="noWrap" style="width: 26px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    &nbsp;</div>
                                            </td>
                                            </asp:PlaceHolder>
                                        </tr>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr style="background: #FEFEFE;">
                                        <td align="center" valign="middle">
                                            <asp:Image runat="server" ID="imgInfo" ImageUrl="~/Images/Applic/remark_blue.gif"
                                                Height="16px" Width="16px" Style="cursor: pointer" onclick="ShowPopulationPopUp(this)" />
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="lblPopulationDesc" Text='<%# Eval("PopulationsDesc")%>'></asp:Label>&nbsp;<asp:Label
                                                runat="server" ID="lblPopulationsCode" Style="display: none" Text='<%# Eval("PopulationCode")%>'></asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="lblSubPopulationDesc" Text='<%# Eval("SubPopulationsDesc")%>'></asp:Label>&nbsp;<asp:Label
                                                runat="server" ID="lblSubPopulationsCode" Style="display: none" Text='<%# Eval("PopulationSubCode")%>'></asp:Label>
                                        </td>
                                        <td align="left">
                                            <asp:Label runat="server" ID="lblTariffNew"></asp:Label>&nbsp;
                                        </td>
                                        <td align="left" style="padding-left:6px">
                                            <asp:Label runat="server" ID="lblUpdateDate" CssClass="RegularLabel" Text='<%# Eval("UpdateDate" , "{0:dd/MM/yyyy}")%>'></asp:Label>
                                        </td>
                                        <asp:PlaceHolder runat="server" Visible='<%# (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) %>'>
                                        <td align="center" style="">
                                            <asp:Image runat="server" ID="imgExpandCollapse" ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif"
                                                Height="12px" Width="12px" Style="cursor: pointer" onclick="HideShowSubTable(this)" />
                                        </td>
                                        </asp:PlaceHolder>
                                    </tr>
                                    <tr runat="server" id="trPopulationHistoryTarifon" style="display: none; background: #FEFEFE;">
                                        <td colspan='<%# (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) ? 6 : 5 %>' align="left">
                                            <asp:Panel runat="server" ID="pPopulationHistoryTarifon">
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <AlternatingItemTemplate>
                                    <tr style="background: #F3F3F3;">
                                        <td align="center">
                                            <asp:Image runat="server" ID="imgInfo" ImageUrl="~/Images/Applic/remark_blue.gif"
                                                Height="16px" Width="16px" Style="cursor: pointer" onclick="ShowPopulationPopUp(this)" />
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="lblPopulationDesc" Text='<%# Eval("PopulationsDesc")%>'></asp:Label>&nbsp;<asp:Label
                                                runat="server" ID="lblPopulationsCode" Style="display: none" Text='<%# Eval("PopulationCode")%>'></asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="lblSubPopulationDesc" Text='<%# Eval("SubPopulationsDesc")%>'></asp:Label>&nbsp;<asp:Label
                                                runat="server" ID="lblSubPopulationsCode" Style="display: none" Text='<%# Eval("PopulationSubCode")%>'></asp:Label>
                                        </td>
                                        <td align="left">
                                            <asp:Label runat="server" ID="lblTariffNew"></asp:Label>&nbsp;
                                        </td>
                                        <td align="left" style="padding-left:6px">
                                            <asp:Label runat="server" ID="lblUpdateDate" Text='<%# Eval("UpdateDate" , "{0:dd/MM/yyyy}")%>'></asp:Label>
                                        </td>
                                        <asp:PlaceHolder runat="server" Visible='<%# (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) %>'>
                                        <td align="center" style="">
                                            <asp:Image runat="server" ID="imgExpandCollapse" ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif"
                                                Height="12px" Width="12px" Style="cursor: pointer" onclick="HideShowSubTable(this)" />
                                        </td>
                                        </asp:PlaceHolder>
                                    </tr>
                                    <tr runat="server" id="trPopulationHistoryTarifon" style="display: none; background: #FEFEFE;">
                                        <td colspan='<%# (this.CanViewTarifon || this.CanManageTarifonViews || this.IsAdministrator) ? 6 : 5 %>' align="left">
                                            <asp:Panel runat="server" ID="pPopulationHistoryTarifon">
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                </AlternatingItemTemplate>
                                <FooterTemplate>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <br />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        </asp:PlaceHolder>
        <!-- Sal Service ICD9 -->
        <tr id="trSalServiceICD9">
            <td style="padding-bottom: 10px;">
                <div class="BackColorBlue">
                    <div style="padding:2px 4px 0px 6px">
                        <table cellpadding="1" cellspacing="1" border="0" width="100%">
                            <tr>
                                <td style="width:30px"><asp:Image ID="imgAttributed_3" runat="server" ToolTip="שירותי בריאות כללית" CssClass="DisplayNone" /></td>    
                                <td style="width:580px;padding-left:10px">
                                    <asp:Label ID="lblSalServiceMIN_CODE3" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                    <asp:Label ID="lblSalServiceCode3" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                    <asp:Label ID="lblSalServiceName3" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                </td>
                                <td align="left" style="padding-left:20px"><asp:Label ID="lblIncludeInBasket_ICD9" runat="server"></asp:Label><asp:Label ID="lblDatefrom_ICD9" runat="server"></asp:Label></td>
                                <td style="width:144px" valign="middle">
                                    <asp:Label runat="server" ID="lblUpdateDate_ICD9" EnableTheming="false" CssClass="LabelBoldWhite" Text="עדכון אחרון:"></asp:Label>
                                    <asp:Label runat="server" ID="lblUpdateDateFld_ICD9" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                                </td>
                            </tr>
                        </table>
                     </div>
                </div>
                <table id="tblSalServiceICD9" style="width: 990px; border: solid 1px #D4EAFB; background-color: White;
                    height: 453px">
                    <tr>
                        <td valign="top" style="padding-top: 8px">
                            <table cellpadding="0" cellspacing="0">
                                <tr style="background-color: #e8f4fd;">
                                    <td style="padding-bottom: 0px; padding-left: 0px; width: 980px; padding-right: 0px;
                                        padding-top: 0px">
                                        <table cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="padding-right: 5px; height: 25px" valign="middle" align="right">
                                                    <asp:Label runat="server" ID="lblICD9Title" CssClass="LabelCaptionBlue_14" Style="font-size: 16px;">פרוצדורה יכולה להיות בודדה או משולבת - עם מספר קבוצה</asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <asp:Repeater runat="server" ID="rSalServiceICD9" OnItemDataBound="rSalServiceICD9_ItemDataBound">
                                <HeaderTemplate>
                                    <table cellspacing="0" cellpadding="5" border="0" bordercolor="#dddddd" bordercolorlight="#ffffff"
                                        bordercolordark="#dddddd" width="980" style="font-size: 12px; border-top: 1px solid #ffffff">
                                        <tr style="background: #f7faff; padding-top: 2px; padding-bottom: 2px;">
                                            <td align="right" nowrap="noWrap" style="width: 74px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    מס' קבוצה</div>
                                            </td>
                                            <td align="right" nowrap="noWrap" style="width: 74px; padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    ICD Code</div>
                                            </td>
                                            <td align="right" nowrap="noWrap" style="padding: 3px 0px 3px 0px">
                                                <div style="padding: 2px 0px 2px 0px" class="ColumnHeader">
                                                    ICD Name</div>
                                            </td>
                                        </tr>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr style="background: #FEFEFE;">
                                        <td runat="server" id="tdBorder1">
                                            <asp:Label runat="server" ID="lblGroupCode" Text='<%# Eval("GroupCode")%>'></asp:Label>&nbsp;
                                        </td>
                                        <td runat="server" id="tdBorder2">
                                            <asp:Label runat="server" ID="lblICDCode" Text='<%# Eval("ICDCode")%>'></asp:Label>&nbsp;
                                        </td>
                                        <td runat="server" id="tdBorder3">
                                            <asp:Label runat="server" ID="lblICDDesc" Text='<%# Eval("ICDDesc")%>'></asp:Label>&nbsp;
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <AlternatingItemTemplate>
                                    <tr style="background: #F3F3F3;">
                                        <td  runat="server" id="tdBorder1">
                                            <asp:Label runat="server" ID="lblGroupCode" Text='<%# Eval("GroupCode")%>'></asp:Label>&nbsp;
                                        </td>
                                        <td  runat="server" id="tdBorder2">
                                            <asp:Label runat="server" ID="lblICDCode" Text='<%# Eval("ICDCode")%>'></asp:Label>&nbsp;
                                        </td>
                                        <td  runat="server" id="tdBorder3">
                                            <asp:Label runat="server" ID="lblICDDesc" Text='<%# Eval("ICDDesc")%>'></asp:Label>&nbsp;
                                        </td>
                                    </tr>
                                </AlternatingItemTemplate>
                                <FooterTemplate>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <br />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- Sal Service Internet Details -->
        <tr id="trSalServiceInternetDetails" runat="server">
            <td style="padding-bottom: 10px;">
                <asp:UpdatePanel runat="server" ID="upSalServiceInternetDetails">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnUpdateSalServiceInternetDetails" />
                    </Triggers>
                    <ContentTemplate>
                     <script type="text/javascript">
                         Sys.Application.add_load(BindEvents);
                     </script>
                        <div style="height:46px;" class="BackColorBlue">

                            <div style="float: right; margin-top: 5px; margin-right: 3px;">
                                <asp:Image ID="imgAttributed_4" runat="server" ToolTip="שירותי בריאות כללית" CssClass="DisplayNone" />
                            </div>
                            <div class="BackColorBlue" style="float: right; margin-right: 10px; margin-top: 3px;">
                                <asp:Label ID="lblSalServiceMIN_CODE4" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                <asp:Label ID="lblSalServiceCode4" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                                <asp:Label ID="lblSalServiceName4" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                            </div>
                            <div style="float: left; margin-top: 4px; margin-left: 2px;">
                                <asp:PlaceHolder runat="server" ID="phEditInternetDetails">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td class="buttonRightCorner">
                                        </td>
                                        <td class="buttonCenterBackground">
                                            <asp:Button ID="btnUpdateSalServiceInternetDetails" Width="145px" runat="server"
                                                CssClass="RegularUpdateButton" Text="עדכון פרטי אינטרנט" OnClick="btnUpdateSalServiceInternetDetails_Click" />
                                        </td>
                                        <td class="buttonLeftCorner">
                                        </td>
                                    </tr>
                                </table>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" ID="phUpdateCancelInternetDetails" Visible="false">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                            background-position: bottom left;">
                                            &nbsp;
                                        </td>
                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                            background-repeat: repeat-x; background-position: bottom;">
                                            <asp:Button ID="btnSaveSalServiceInternetDetails" runat="server" Width="65px" Text="שמירה" CssClass="RegularUpdateButton"
                                               CausesValidation="true" OnClick="btnSaveSalServiceInternetDetails_Click" ValidationGroup="vgrFirstSectionValidation" ></asp:Button>
                                        </td>
                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                            background-repeat: no-repeat;">
                                            &nbsp;
                                        </td>
                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                            background-position: bottom left;">
                                            &nbsp;
                                        </td>
                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                            background-repeat: repeat-x; background-position: bottom;">
                                            <asp:Button ID="btnCancelSalServiceInternetDetails" runat="server" CssClass="RegularUpdateButton" Width="65px" Text="ביטול"
                                                CausesValidation="False" OnClick="btnCancelSalServiceInternetDetails_Click" />
                                        </td>
                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                            background-repeat: no-repeat;">
                                            &nbsp;
                                        </td>
                                    </tr>
                                </table>
                                </asp:PlaceHolder>
                            </div>
                            

                            <div style="float: left; margin-left: 10px; margin-top: 5px;">
                                
                                <span class="LabelBoldWhite">סיום טיפול:&nbsp;</span>
                                <asp:Label runat="server" ID="lblUpdateComplete_InternetDetails" Width="63px" CssClass="LabelNormalWhite" ForeColor="#ffffff" EnableTheming="false"></asp:Label><asp:DropDownList
                                                    runat="server" ID="ddlUpdateComplete_InternetDetails" Width="63px" Visible="false" EnableTheming="false">
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                </asp:DropDownList> 
                                                <br />
                                <asp:Label runat="server" ID="lblUpdateDate_InternetDetails" EnableTheming="false"
                                    CssClass="LabelBoldWhite" Text="עדכון אחרון: "></asp:Label>
                                <asp:Label runat="server" ID="lblUpdateDateFld_InternetDetails" EnableTheming="false"
                                    CssClass="LabelNormalWhite"></asp:Label>
                                    
                            </div>

                        </div>
                        <table style="width: 990px; border: solid 1px #D4EAFB;background-color: White; height: 453px">
                            <tr>
                                <td valign="top" style="padding-top: 8px">
                                    <table runat="server" id="tblSalServiceInternetDetails_ReadOnly" border="0" cellpadding="1"
                                        cellspacing="1" width="100%" style="border-bottom: #dddddd 1px solid;
                                        border-left: #dddddd 1px solid; background-color: #f7f7f7; width: 100%; margin-bottom: 8px;
                                        border-top: #dddddd 1px solid; border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd; width: 90px;padding-top:3px"><span class="LabelBoldDirtyBlue">מגיל:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd; width:90px"><asp:Label runat="server" 
                                                ID="lblFromAge_InternetDetails" CssClass="RegularLabel"></asp:Label>&nbsp;</td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd; width:96px;padding-top:3px"><span class="LabelBoldDirtyBlue">הצגה באינטרנט:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd; width:100px;"><asp:Label runat="server" ID="lblShowServiceInInternet_InternetDetails"></asp:Label><asp:DropDownList
                                                    runat="server" ID="ddlShowServiceInInternet_InternetDetails" Width="63px" Visible="false">
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                </asp:DropDownList>&nbsp;</td>
                                            <td style="width:250px;padding-left:10px;padding-right:10px;padding-top:2px" valign="top" 
                                                rowspan="4"><span class="LabelBoldDirtyBlue">מקצועות:</span><br /><asp:Label 
                                                    ID="lblProfessions_InternetDetails" runat="server" CssClass="RegularLabel"></asp:Label>
                                            </td>
                                            <td rowspan="4" style="padding-left:10px;padding-right:10px;padding-top:3px" valign="top">
                                                <span class="LabelBoldDirtyBlue">נושאים:</span><br /><asp:Label 
                                                    ID="lblSalCategories_InternetDetails" runat="server" CssClass="RegularLabel"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd;padding-top:3px"><span class="LabelBoldDirtyBlue">עד גיל:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd"><asp:Label runat="server" ID="lblToAge_InternetDetails" CssClass="RegularLabel"></asp:Label>&nbsp;</td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd;padding-top:3px"><span class="LabelBoldDirtyBlue">זימון תור:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd"><asp:Label runat="server" ID="lblQueueOrder_InternetDetails"></asp:Label><asp:DropDownList
                                                    runat="server" ID="ddlQueueOrder_InternetDetails" Width="63px" Visible="false">
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                </asp:DropDownList>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd;padding-top:3px"><span class="LabelBoldDirtyBlue">מין:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd"><asp:Label runat="server" ID="lblGenderPrivilege_InternetDetails" CssClass="RegularLabel"></asp:Label>&nbsp;</td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd;padding-top:3px"><span class="LabelBoldDirtyBlue">טיפול:</span></td>
                                            <td valign="top" style="border-bottom: 1px solid #dddddd"><asp:Label runat="server" 
                                                    ID="lblTreatment_InternetDetails"></asp:Label><asp:DropDownList runat="server" 
                                                    ID="ddlTreatment_InternetDetails" Width="63px" Visible="false">
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                </asp:DropDownList>&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top:3px"><span class="LabelBoldDirtyBlue">בדיקת זכאות:</span></td>
                                            <td valign="top"><asp:Label runat="server" ID="lblEntitlementCheck_InternetDetails" CssClass="RegularLabel"></asp:Label>&nbsp;</td>
                                            <td valign="top" style="padding-top:3px"><span class="LabelBoldDirtyBlue">אבחון:</span></td>
                                            <td valign="top"><asp:Label runat="server" 
                                                    ID="lblDiagnosis_InternetDetails"></asp:Label><asp:DropDownList runat="server" 
                                                    ID="ddlDiagnosis_InternetDetails" Width="63px" Visible="false">
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                </asp:DropDownList>&nbsp;</td>
                                        </tr>
                                    </table>
                                    <table runat="server" id="tblSalServiceInternetDetails" border="0" cellpadding="1"
                                        cellspacing="1" width="100%" style="border-left: #dddddd 1px solid; background-color: #f7f7f7; width: 100%; 
                                        border-top: #dddddd 1px solid; border-right: #dddddd 1px solid;border-bottom:none">
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:15%;white-space:nowrap">
                                                <span class="LabelBoldDirtyBlue">שם שירות לאינטרנט:</span>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:35%;">
                                                <asp:Label runat="server" ID="lblServiceNameForInternet_InternetDetails"></asp:Label><asp:TextBox
                                                    runat="server" ID="txtServiceNameForInternet_InternetDetails" Width="95%" Visible="false"></asp:TextBox>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:10%;white-space:nowrap">
                                                &nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:40%;">
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:120px;white-space:nowrap">
                                                <span class="LabelBoldDirtyBlue">מילים נרדפות:</span>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;"><asp:Label runat="server" ID="lblSynonymsForInternet_InternetDetails"></asp:Label><asp:TextBox
                                                    runat="server" ID="txtSynonymsForInternet_InternetDetails" Width="95%" Visible="false"></asp:TextBox>&nbsp;</td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;white-space:nowrap"><span class="LabelBoldDirtyBlue">שמות נרדפים:</span></td>
                                            <td style="padding-top: 2px; border-bottom: 1px solid #dddddd;text-align:right;padding-left:20px" rowspan="4" valign="top">
                                                <asp:Label runat="server" ID="lblInterDetails_Synonym" CssClass="RegularLabel"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;">
                                                <span class="LabelBoldDirtyBlue">איבר גוף:</span>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;"><asp:Label runat="server" ID="lblSalBodyOrgan_InternetDetails"></asp:Label><asp:DropDownList
                                                    runat="server" ID="ddlSalBodyOrgans_InternetDetails" DataTextField="OrganName" DataValueField="SalOrganCode" Visible="false" Width="200px"></asp:DropDownList>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;white-space:nowrap">&nbsp;</td>
                                            
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;">
                                                <span class="LabelBoldDirtyBlue">החזרים:</span>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;"><asp:Label runat="server" ID="lblRefund_InternetDetails"></asp:Label><asp:TextBox
                                                    runat="server" ID="txtRefund_InternetDetails" Width="95%" Visible="false"></asp:TextBox>&nbsp;
                                            </td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;white-space:nowrap">&nbsp;</td>
                                            
                                        </tr>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;">&nbsp;</td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;">&nbsp;</td>
                                            <td valign="top" style="padding-top: 2px; border-bottom: 1px solid #dddddd;white-space:nowrap">&nbsp;</td>
                                            
                                        </tr>
                                    </table>
                                    <table runat="server" border="0" cellpadding="1" cellspacing="1" width="100%" 
                                        style="border-bottom: #dddddd 1px solid; border-left: #dddddd 1px solid; 
                                        background-color: #f7f7f7; width: 100%; border-right: #dddddd 1px solid;">
                                        <tr>
                                            <td style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:50%"><span class="LabelBoldDirtyBlue">פירוט השירות:</span></td>
                                            <td style="padding-top: 2px; border-bottom: 1px solid #dddddd;width:50%;"><span class="LabelBoldDirtyBlue">תקציר השירות:</span></td>
                                        </tr>
                                        <tr>
                                            <td><asp:Label runat="server" ID="lblServiceDetails_InternetDetails" Text="" Width="90%"></asp:Label><asp:TextBox
                                                    runat="server" ID="txtServiceDetails_InternetDetails" TextMode="MultiLine" Width="90%" Height="180px" Visible="false"></asp:TextBox>&nbsp;</td>
                                            <td valign="top"><asp:Label runat="server" ID="lblServiceBrief_InternetDetails" Width="90%"></asp:Label><asp:TextBox
                                                    runat="server" ID="txtServiceBrief_InternetDetails" Width="90%" TextMode="MultiLine" Height="180px" Visible="false"></asp:TextBox>&nbsp;</td>
                                        </tr>
                                        <tr>
                                           <td colspan="2" style="padding-top: 2px; border-bottom: 1px solid #dddddd; border-top: 1px solid #dddddd;"><span class="LabelBoldDirtyBlue">פרטי שירות לאינטרנט:</span></td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:Label runat="server" ID="lblServiceDetailsInternet" EnableTheming="false" Width="90%"></asp:Label>
                                                <asp:TextBox runat="server" ID="txtServiceDetailsInternet" EnableTheming="false" TextMode="MultiLine" Height="180px" Visible="false"></asp:TextBox>
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                    <br />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
        <!-- Sal Mushlam Services -->
        <tr id="trMushlamServices">
            <td valign="top">
                <iframe id="frmMushlamServices" runat="server" width="990" height="400" frameborder="0" marginheight="0" marginwidth="0"
                                    scrolling="no"></iframe>
            </td>
        </tr>
    </table>
    <cc1:ModalPopupExtender ID="modalPopupGrayScreen" runat="server" TargetControlID="btnOpenModalPopup"
        PopupControlID="divGrayScreen" BackgroundCssClass="divPopup">
    </cc1:ModalPopupExtender>
    <div style="display: none;">
        <asp:Button ID="btnOpenModalPopup" runat="server" />
    </div>
    <div id="divGrayScreen" runat="server" style="position: absolute; display: none;
        width: 100%; height: 100%; z-index: 15000">
    </div>
</asp:Content>
