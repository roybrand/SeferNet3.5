<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="הערות גורפות" MasterPageFile="~/seferMasterPageIEwide.master" Inherits="HandleSweepingRemarks" meta:resourcekey="PageResource1" Codebehind="HandleSweepingRemarks.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPageIEwide.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

    <script type="text/javascript">
        var txtCityCodeClientID = '<%=txtCityCode.ClientID %>';
        var txtCityNameOnlyClientID = '<%=txtCityNameOnly.ClientID %>';
        var txtCityNameClientID = '<%=txtCityName.ClientID %>';
        var txtCityNameToCompareClientID = '<%=txtCityNameToCompare.ClientID %>';
        var txtProfessionListCodesClientID = '<%=txtProfessionListCodes.ClientID %>';
        var txtProfessionListClientID = '<%=txtProfessionList.ClientID %>';
        var btnProfessionListPopUpClientID = '<%=btnProfessionListPopUp.ClientID %>';
        var txtProfessionList_ToCompareClientID = '<%=txtProfessionList_ToCompare.ClientID %>';


        function OpenSweepingRemarkExclusions(RemarkID) {

            var url = "SweepingRemarkExclusionsPopUp.aspx?RemarkID=" + RemarkID;

            var dialogWidth = 460;
            var dialogHeight = 350;
            var title = "הערה גורפת יחידות לא כלולות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function ShowRemarks1() {
            var trHistoryRemarks = document.getElementById('<%=trHistoryRemarks.ClientID%>');
            var imgShowRemarks1 = document.getElementById('<%=imgShowRemarks1.ClientID%>');
            if (trHistoryRemarks.style.display == "none") {
                trHistoryRemarks.style.display = "inline";
                imgShowRemarks1.src = "../Images/Applic/btn_Minus_Blue_12.gif"
            }
            else {
                trHistoryRemarks.style.display = "none";
                imgShowRemarks1.src = "../Images/Applic/btn_Plus_Blue_12.gif"
            }
        }
        function ShowRemarks2() {
            var trCurrentRemarks = document.getElementById('<%=trCurrentRemarks.ClientID%>');
            var imgShowRemarks2 = document.getElementById('<%=imgShowRemarks2.ClientID%>');
            if (trCurrentRemarks.style.display == "none") {
                trCurrentRemarks.style.display = "inline";
                imgShowRemarks2.src = "../Images/Applic/btn_Minus_Blue_12.gif"
            }
            else {
                trCurrentRemarks.style.display = "none";
                imgShowRemarks2.src = "../Images/Applic/btn_Plus_Blue_12.gif"
            }
        }
        function ShowRemarks3() {
            var trFutureRemarks = document.getElementById('<%=trFutureRemarks.ClientID%>');
            var imgShowRemarks3 = document.getElementById('<%=imgShowRemarks3.ClientID%>');
            if (trFutureRemarks.style.display == "none") {
                trFutureRemarks.style.display = "inline";
                imgShowRemarks3.src = "../Images/Applic/btn_Minus_Blue_12.gif"
            }
            else {
                trFutureRemarks.style.display = "none";
                imgShowRemarks3.src = "../Images/Applic/btn_Plus_Blue_12.gif"
            }
        }

        // "UnitTypes" management functions
        function ClearUnitTypeList() {
            if (document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value != document.getElementById('<%=txtUnitTypeList.ClientID %>').value) {
                document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = "";
                document.getElementById('<%=txtUnitTypeList.ClientID %>').value = "";
                document.getElementById('<%=txtUnitTypeListCodes.ClientID %>').value = "";
            }
        }

        function SelectUnitType() {
            var url = "../Public/SelectPopUp.aspx";
            var txtUnitTypeListCodes = document.getElementById('<%=txtUnitTypeListCodes.ClientID %>');
            var txtUnitTypeList = document.getElementById('<%=txtUnitTypeList.ClientID %>');
            var SelectedUnitTypeList = txtUnitTypeListCodes.innerText;
            url += "?SelectedValuesList=" + SelectedUnitTypeList;
            url += "&popupType=6";
            url += "&returnValuesTo=txtUnitTypeListCodes";
            url += "&returnTextTo=txtUnitTypeList";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר סוג יחידה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return true;
        }

        function SyncronizeUnitTypeList() {
            document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = document.getElementById('<%=txtUnitTypeList.ClientID %>').value;
        }

        function getSelectedUnitTypeCode(source, eventArgs) {
            document.getElementById('<%=txtUnitTypeListCodes.ClientID %>').value = eventArgs.get_value();
            document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = eventArgs.get_text();
            document.getElementById('<%=txtUnitTypeList.ClientID %>').value = eventArgs.get_text();
            document.getElementById('<%= hdnNewUnitCodeSelected.ClientID %>').value = 'true';

            window.document.forms[0].submit();
        }

        // "Districts" management functions
        function SelectDistricts() {
            var url = "../Public/SelectPopUp.aspx";

            var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');
            var txtDistrictList = document.getElementById('<%=txtDistrictList.ClientID %>');
            var txtDistrictsPermitted = document.getElementById('<%=txtDistrictsPermitted.ClientID %>');

            var SelectedDistrictsList = txtDistrictCodes.innerText;
            url += "?SelectedValuesList=" + SelectedDistrictsList;
            url += "&popupType=7";
            url += "&PermittedDistricts=" + txtDistrictsPermitted.value;

            url += "&returnValuesTo='txtDistrictCodes'";
            url += "&returnTextTo='txtDistrictList'";
            url += "&functionToExecute=" + "AfterDistrictsSelectedOnSweepingRemarks";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר מחוז";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return true;
        }

        function AfterDistrictsSelectedOnSweepingRemarks() {

            ClearCitySearchControls();

            context = $find('acCities')._contextKey;
            contextArr = context.split(';');

            newContext = document.getElementById('<%=txtDistrictCodes.ClientID %>').innerText + ';' + contextArr[1];

            $find('acCities').set_contextKey(newContext);

            document.getElementById(txtCityNameClientID).focus();

            document.forms[0].submit();
        }

        function SelectProfession() {
            var url = "../Public/SelectPopUp.aspx";
            var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
            var txtProfessionList = document.getElementById(txtProfessionListClientID);
            var SelectedProfessionList = txtProfessionListCodes.innerText;
            url += "?SelectedValuesList=" + SelectedProfessionList;
            url += "&popupType=12";
            url += "&returnValuesTo=txtProfessionListCodes";
            url += "&returnTextTo=txtProfessionList";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר שירות או פעילות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return true;
        }

        function getDistrictCode(source, eventArgs) {
            document.getElementById('<%=txtDistrictCodes.ClientID %>').value = eventArgs.get_value();
            document.getElementById('<%=txtDistrictList.ClientID %>').value = eventArgs.get_text();
            document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
            document.getElementById('<%=txtAdminList.ClientID %>').value = "";

            document.getElementById('<%=btnDistrictsPopUp.ClientID %>').focus();

            window.document.forms(0).submit();
        }

        function ClearDistricts() {
            document.getElementById('<%=txtDistrictCodes.ClientID %>').value = "";
            document.getElementById('<%=txtDistrictList.ClientID %>').value = "";
            document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
            document.getElementById('<%=txtAdminList.ClientID %>').value = "";

            document.getElementById('<%=btnDistrictsPopUp.ClientID %>').focus();

            window.document.forms(0).submit();
        }

        // "Admins" management functions
        function getAdminCode(source, eventArgs) {
            document.getElementById('<%=txtAdminCodes.ClientID %>').value = eventArgs.get_value();
            document.getElementById('<%=txtAdminList.ClientID %>').value = eventArgs.get_text();

            document.getElementById("btnAdminPopUp").focus();
        }

        function ClearAdmin() {
            document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
            document.getElementById('<%=txtAdminList.ClientID %>').value = "";
            document.getElementById("btnAdminPopUp").focus();
        }

        function SelectAdmins() {
            var url = "../Public/SelectPopUp.aspx";

            var txtAdminCodes = document.getElementById('<%=txtAdminCodes.ClientID %>');
            var txtAdminList = document.getElementById('<%=txtAdminList.ClientID %>');
            var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');

            var SelectedValuesList = txtDistrictCodes.innerText + ';' + txtAdminCodes.innerText;
            url += "?SelectedValuesList=" + SelectedValuesList;
            url += "&popupType=10";
            url += "&returnValuesTo=txtAdminCodes";
            url += "&returnTextTo=txtAdminList";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר מנהלת";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
            return true;
        }

        function OnDDCityCodeSelected(source, eventArgs) {

            var txtCityCode = document.getElementById(txtCityCodeClientID);
            var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

            var value = eventArgs.get_value();
            var valueArray = value.split("~");

            txtCityCode.value = valueArray[0];
            txtCityNameOnly.value = valueArray[1];

            var txtCityName = document.getElementById(txtCityNameClientID);
            txtCityName.value = eventArgs.get_text();
        }

        function ClearCitySearchControls() {
            document.getElementById(txtCityCodeClientID).value = "";
            document.getElementById(txtCityNameClientID).value = "";
            document.getElementById(txtCityNameOnlyClientID).value = "";
            document.getElementById(txtCityNameToCompareClientID).value = "";
        }

        function ClearProfessionList() {
            if (document.getElementById(txtProfessionList_ToCompareClientID).value != document.getElementById(txtProfessionListClientID).value) {
                document.getElementById(txtProfessionList_ToCompareClientID).value = "";
                document.getElementById(txtProfessionListClientID).value = "";
                document.getElementById(txtProfessionListCodesClientID).value = "";
            }
        }

        function ClearCitySearchControlOnChangeCityName() {
            if (document.getElementById(txtCityNameToCompareClientID).value != document.getElementById(txtCityNameClientID).value)
            {
                ClearCitySearchControls();
            }
        }

        function CleanFreeText() {
            document.getElementById('<%=txtFreeText.ClientID %>').value = "";
        }

        function SyncronizeProfessionList() {
            document.getElementById(txtProfessionList_ToCompareClientID).value = document.getElementById(txtProfessionListClientID).value;
        }

        function getSelectedProfessionCode(source, eventArgs) {
            document.getElementById(txtProfessionListCodesClientID).value = eventArgs.get_value();
            document.getElementById(txtProfessionList_ToCompareClientID).value = eventArgs.get_text();
            document.getElementById(txtProfessionListClientID).value = eventArgs.get_text();

            document.getElementById(btnProfessionListPopUpClientID).focus();
        }

        function SelectCities() {
            var url = "../public/SelectPopUp.aspx";
            var txtCitiesListCodes = document.getElementById('<%=txtCityCode.ClientID %>');
            var txtCitiesList = document.getElementById('<%=txtCityName.ClientID %>');
            var txtCitiesListToCompare = document.getElementById('<%=txtCityNameToCompare.ClientID %>');

            var SelectedDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>').value;
            var SelectedCitiesList = txtCitiesListCodes.value;
            url += "?SelectedValuesList=" + SelectedCitiesList;
            url += "&SelectedDistrictCodes=" + SelectedDistrictCodes;
            url += "&popupType=9";

            url += "&returnValuesTo='txtCityCode'";
            url += "&returnTextTo=txtCityName,txtCityNameToCompare";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר עיר";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
            return true;
        }

        function ShowProgressBar() {
            document.getElementById("divProgressBarGeneral").style.visibility = "visible";
        }
    </script>

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0" dir="rtl">
                <tr id="trError" runat="server">
                    <td>
                        <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" dir="rtl">
                <tr>
                    <td style="padding-right: 10px">
                        <!-- Upper Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="background-color: #298AE5; height: 18px;">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
                                <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                <td align="right">
                                    <div style="width: 960px">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td align="right" style="width: 180px; padding-right: 10px;">
                                                    <asp:Label ID="lblDistricts" runat="server" Text="מחוזות"></asp:Label>
                                                    <asp:TextBox ID="txtDistrictsPermitted" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                                </td>
                                                <td>
                                                </td>
                                                <td align="right" style="width: 180px">
                                                    <asp:Label ID="lblAdministrations" runat="server" Text="מנהלות"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td align="right" style="width: 100px">
                                                    <asp:Label ID="lblSectors" runat="server" Text="מגזרים"></asp:Label>
                                                </td>
                                                <td align="right" style="padding-right: 7px">
                                                    <asp:Label ID="lblUnitTypes" runat="server" Text="סוגי יחידות"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblSubUnitType" runat="server" Text="שיוך" Visible="false"></asp:Label>
                                                </td>
                                                <td rowspan="2" valign="middle" style="padding-top: 15px">
                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                        <tr>
                                                            <td align="right" style="padding-right: 4px">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: top; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnSelect" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                                OnClick="btnSelect_Click" OnClientClick="ShowProgressBar();"></asp:Button>
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td style="padding-right: 5px">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnAddRemark" runat="server" Text="הוספת הערות" CssClass="RegularUpdateButton"
                                                                                ValidationGroup="vgrFirstSectionValidation" Width="90px" OnClick="btnAddRemark_Click">
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
                                            <tr style="height: 25px">
                                                <td valign="top" style="padding-right: 10px;">
                                                    <asp:TextBox ID="txtDistrictList" runat="server" onchange="ClearDistricts();" Width="170px"
                                                        ReadOnly="false" TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine"
                                                        EnableTheming="false"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteDistricts" TargetControlID="txtDistrictList"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getDistricts"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="getDistrictCode" />
                                                    <asp:TextBox ID="txtDistrictCodes" runat="server" TextMode="multiLine" EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                                <td valign="top" style="width: 45px;">
                                                    <input type="image" id="btnDistrictsPopUp" runat="server" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                        onclick="return SelectDistricts()" />
                                                </td>
                                                <td valign="top">
                                                    <asp:TextBox ID="txtAdminList" runat="server" onchange="ClearAdmin();" Width="170px"
                                                        TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteAdmins" TargetControlID="txtAdminList"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAdminByName_DistrictDepended"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="getAdminCode" />
                                                    <asp:TextBox ID="txtAdminCodes" runat="server" TextMode="multiLine" EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                                <td valign="top" style="width: 45px;">
                                                    <input type="image" id="btnAdminPopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                        onclick="return SelectAdmins()" />
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlPopulationSectors" runat="server" Width="80px" AppendDataBoundItems="true"
                                                        DataTextField="PopulationSectorDescription" DataValueField="PopulationSectorID">
                                                        <asp:ListItem Value="-1" Text=" "></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td valign="top" style="padding-right: 7px">
                                                    <asp:TextBox ID="txtUnitTypeList" ReadOnly="false" onfocus="SyncronizeUnitTypeList();"
                                                        onchange="ClearUnitTypeList();" runat="server" Width="150px" TextMode="MultiLine"
                                                        Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                    <asp:TextBox ID="txtUnitTypeList_ToCompare" runat="server" CssClass="DisplayNone"
                                                        EnableTheming="false"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteUnitType" TargetControlID="txtUnitTypeList"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getUnitTypesByName"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="getSelectedUnitTypeCode" />
                                                    <asp:TextBox ID="txtUnitTypeListCodes" runat="server" EnableTheming="false" CssClass="DisplayNone"
                                                        TextMode="MultiLine"></asp:TextBox>
                                                </td>
                                                <td valign="top" style="width: 45px;">
                                                    <input type="image" id="btnUnitTypeListPopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                        onclick="return SelectUnitType()" />
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlSubUnitType" runat="server" Visible="false" Width="110px"
                                                        DataTextField="subUnitTypeName" DataValueField="subUnitTypeCode" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" style="width: 180px; padding-right: 10px;">
                                                    <asp:Label ID="lblCity" runat="server" Text="ישוב"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td align="right" style="width: 180px">
                                                    <asp:Label ID="lblServices" runat="server" Text="שירות/מקצוע"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td align="right" style="width: 100px">

                                                </td>
                                                <td align="right" style="padding-right: 7px">
                                                    <asp:Label ID="lblFreeText" runat="server" Text="טקסט חופשי"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td>
                                                </td>
                                                <td colspan="2"></td>
                                            </tr>
                                            <tr>
                                                <td align="right" style="width: 180px; padding-right: 10px;">
                                                    <asp:TextBox ID="txtCityName" Width="170px" runat="server" TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" onchange="ClearCitySearchControlOnChangeCityName();"/>
                                                    <asp:TextBox ID="txtCityNameOnly" Width="100px" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox ID="txtCityNameToCompare" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox runat="server" ID="txtCityCode" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteCities" TargetControlID="txtCityName"
                                                        BehaviorID="acCities" ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetCitiesAndDistricts_MultipleDistricts"
                                                        MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" OnClientItemSelected="OnDDCityCodeSelected" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle" />
                                                </td>
                                                <td style="width: 40px;">
                                                        <input type="image" id="btnCitiesListPopUp" runat="server" style="cursor: pointer;"
                                                        src="../Images/Applic/icon_magnify.gif" onclick="SelectCities(); return false;" />
                                                </td>
                                                <td align="right" style="width: 180px">
                                                    <asp:TextBox ID="txtProfessionList" onfocus="SyncronizeProfessionList();"
                                                        onchange="ClearProfessionList();" ReadOnly="false" runat="server" Width="170px"
                                                        TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                    <asp:TextBox ID="txtProfessionList_ToCompare" runat="server" CssClass="DisplayNone"
                                                        EnableTheming="false">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    </asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteProfessions" TargetControlID="txtProfessionList"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetServicesAndEventsByName"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedProfessionCode" />
                                                    <asp:TextBox ID="txtProfessionListCodes" runat="server" CssClass="DisplayNone" TextMode="multiLine"
                                                        EnableTheming="false"></asp:TextBox>                                                    
                                                </td>
                                                <td>
                                                    <div style="width: 40px;">
                                                            <input type="image" id="btnProfessionListPopUp" runat="server" style="cursor: pointer;"
                                                            src="../Images/Applic/icon_magnify.gif" onclick="SelectProfession(); return false;" />
                                                    </div>
                                                </td>
                                                <td align="right" style="width: 100px"></td>
                                                <td align="right" style="padding-right: 7px">
                                                    <asp:TextBox ID="txtFreeText" Height="20px" runat="server" CssClass="TextBoxMultiLine" EnableTheming="false" Width="150px"></asp:TextBox>
                                                </td>
                                                <td colspan="2">
                                                    <img id="imgClearFreeText" runat="server" style="cursor: pointer" src="../Images/btn_clear.gif"
                                                                        onclick="CleanFreeText();" alt="לנקות טקסט חופשי" /> 
                                                </td>
                                                <td colspan="2"></td>
                                            </tr>
                                        </table>
                                    </div>
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
                <tr>
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
                                <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                <td align="right">
                                    <div style="width: 960px;" dir="ltr">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr id="trHeaderRemarks" runat="server">
                                                <td dir="rtl" style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; border-bottom: solid 1px #CBCBCB;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="width: 225px; padding-right: 40px">
                                                                <asp:Label ID="lblRemark_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="הערה"></asp:Label>
                                                            </td>
                                                            <td style="width: 90px;">
                                                                <asp:Label ID="lblDistrict_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="מחוז"></asp:Label>
                                                            </td>
                                                            <td style="width: 80px;">
                                                                <asp:Label ID="lblAdministration_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="מנהלת"></asp:Label>
                                                            </td>
                                                            <td style="width: 80px;">
                                                                <asp:Label ID="lblClinicType_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="סוג יחידה"></asp:Label>
                                                            </td>
                                                            <td style="width: 60px">
                                                                <asp:Label ID="lblSubUnitType_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="שיוך"></asp:Label>
                                                            </td>
                                                            <td style="width: 55px;">
                                                                <asp:Label ID="lblSector_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="מגזר"></asp:Label>
                                                            </td>
                                                            <td style="width: 70px;">
                                                                <asp:Label ID="lblCityHeader" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="ישוב"></asp:Label>
                                                            </td>
                                                            <td style="width: 100px;">
                                                                <asp:Label ID="lblServicesHeader" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="שירות"></asp:Label>
                                                            </td>
                                                            <td style="width: 60px;" align="center">
                                                                <div style="border-bottom:1px solid Gray">
                                                                <asp:Label ID="lblFromDate_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="תאריך מ"></asp:Label>
                                                                </div>
                                                                <asp:Label ID="lblToDate_Header" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    runat="server" Text="תאריך עד"></asp:Label>
                                                            </td>
                                                            <td style="width: 70px;">

                                                            </td>
                                                            <td style="width: 25px;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="divRemarkList" class="ScrollBarDiv" runat="server" style="height: 400px; width:961px; overflow-y: scroll">
                                                        <table dir="rtl" cellpadding="0" cellspacing="0" border="0" style="background-color: #FFFFFF">
                                                            <tr id="trNoDataFound" runat="server" style="display: none">
                                                                <td style="padding-top: 30px; width: 900px; background-color: #F7F7F7" align="center">
                                                                    <asp:Label ID="lblNoDataFound" runat="server" Text="אין מידע"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr id="trRemarksHeader_History" runat="server">
                                                                <td style="width: 960px; padding-right: 5px; background-color: #E9F5FE">
                                                                    <img id="imgShowRemarks1" runat="server" style="cursor: pointer" src="../Images/Applic/btn_Plus_Blue_12.gif"
                                                                        onclick="ShowRemarks1();" />
                                                                    &nbsp;
                                                                    <asp:Label runat="server" ID="lblRemarksHeader1" EnableTheming="false" CssClass="LabelCaptionBlueBold_16"
                                                                        Text="הערות היסטוריות"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr id="trHistoryRemarks" runat="server" style="display: none">
                                                                <td>
                                                                    <asp:GridView ID="gvRemarks_History" AutoGenerateColumns="false" runat="server" SkinID="SimpleGridView"
                                                                        HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvRemarks_RowDataBound">
                                                                        <Columns>
                                                                            <asp:TemplateField ItemStyle-BackColor="#F7F7F7">
                                                                                <ItemTemplate>
                                                                                    <table style="width: 795px; border-bottom: solid 1px #CBCBCB" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td align="center" valign="top">
                                                                                                <div style="width: 10px">
                                                                                                    <asp:ImageButton ID="btnExclusions" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/ExclamationMarkOrange.gif"
                                                                                                        RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' ToolTip="יחידות לא כלולות"></asp:ImageButton>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblRemrkText" Width="228px" runat="server" Text='<%#Eval("RemarkText") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView ID="gvDistricts" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                    HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <asp:Label ID="lblAdministration" Width="95px" runat="server" Text='<%#Eval("districtName") %>'></asp:Label>
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="75px" ID="gvAdministration" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="AdministrationName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="80px" ID="gvUnitType" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="UnitTypeName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblSubUnitType" runat="server" Width="55px"></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 55px">
                                                                                                    <asp:GridView ID="vgPopulationSector" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="PopulationSectorDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 70px">
                                                                                                    <asp:GridView ID="gvCities" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="cityName" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 100px">
                                                                                                    <asp:GridView ID="gvServices" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="ServiceDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                                <asp:Label ID="lblServiceDescription" Width="60px" runat="server" ></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top" align="center">
                                                                                                <div style="border-bottom:1px solid Gray">
                                                                                                <asp:Label ID="lblValidFrom" Width="70px" runat="server" Text='<%#Eval("ValidFrom","{0:d}") %>'></asp:Label>
                                                                                                </div>
                                                                                                <asp:Label ID="lblValidTo" Width="70px" runat="server" Text='<%#Eval("ValidTo","{0:d}") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                            </td>
                                                                                            <td valign="top" style="width: 25px; margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                                                                <div style="width: 25px">
                                                                                                    <asp:Image ID="imgNotShowInInternet" ToolTip="לא תוצג באינטרנט" runat="server" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif" />&nbsp;
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:PlaceHolder ID="pnlEditButton" runat="server">
                                                                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                                    <tr>
                                                                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                                            background-position: left bottom;">
                                                                                                                            &nbsp;
                                                                                                                        </td>
                                                                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                                            background-repeat: repeat-x; background-position: 50% bottom;">
                                                                                                                            <asp:Button runat="server" ID="btnEditRemark" RelatedRemarkID='<%# Eval("RelatedRemarkID")%>'
                                                                                                                                Width="35px" CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditRemark_Click" />
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
                                                                                                            <td style="padding-top:5px">&nbsp;&nbsp;
                                                                                                                <asp:ImageButton ID="btnDeleteRemark" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                                                    RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' OnClick="btnDeleteRemark_Click"
                                                                                                                    OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את ההערה')"></asp:ImageButton>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </asp:PlaceHolder>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </td>
                                                            </tr>
                                                            <tr id="trRemarksHeader_Current" runat="server">
                                                                <td style="width: 960px; padding-right: 5px; background-color: #E9F5FE">
                                                                    <img id="imgShowRemarks2" runat="server" style="cursor: pointer" src="../Images/Applic/btn_Minus_Blue_12.gif"
                                                                        onclick="ShowRemarks2();" />
                                                                    &nbsp;
                                                                    <asp:Label runat="server" ID="lblRemarksHeader2" EnableTheming="false" CssClass="LabelCaptionBlueBold_16"
                                                                        Text="הערות בתוקף"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr id="trCurrentRemarks" runat="server">
                                                                <td>
                                                                    <asp:GridView ID="gvRemarks_Current" AutoGenerateColumns="false" runat="server" SkinID="SimpleGridView"
                                                                        HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvRemarks_RowDataBound">
                                                                        <Columns>
                                                                            <asp:TemplateField ItemStyle-BackColor="#F7F7F7">
                                                                                <ItemTemplate>
                                                                                    <table style="width: 795px; border-bottom: solid 1px #CBCBCB" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td align="center" valign="top">
                                                                                                <div style="width: 10px">
                                                                                                    <asp:ImageButton ID="btnExclusions" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/ExclamationMarkOrange.gif"
                                                                                                        RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' ToolTip="יחידות לא כלולות"></asp:ImageButton>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblRemrkText" Width="228px" runat="server" Text='<%#Eval("RemarkText") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView ID="gvDistricts" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                    HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <asp:Label ID="lblAdministration" Width="95px" runat="server" Text='<%#Eval("districtName") %>'></asp:Label>
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="75px" ID="gvAdministration" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="AdministrationName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="80px" ID="gvUnitType" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="UnitTypeName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblSubUnitType" runat="server" Width="55px"></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 55px">
                                                                                                    <asp:GridView ID="vgPopulationSector" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="PopulationSectorDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 70px">
                                                                                                    <asp:GridView ID="gvCities" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="cityName" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 100px">
                                                                                                    <asp:GridView ID="gvServices" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="ServiceDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                                <asp:Label ID="lblServiceDescription" Width="60px" runat="server" ></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top" align="center">
                                                                                                <div style="border-bottom:1px solid Gray">
                                                                                                <asp:Label ID="lblValidFrom" Width="70px" runat="server" Text='<%#Eval("ValidFrom","{0:d}") %>'></asp:Label>
                                                                                                </div>
                                                                                                <asp:Label ID="lblValidTo" Width="70px" runat="server" Text='<%#Eval("ValidTo","{0:d}") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top" style="width: 25px; margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                                                                <div style="width: 25px">
                                                                                                    <asp:Image ID="imgNotShowInInternet" ToolTip="לא תוצג באינטרנט" runat="server" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif" />&nbsp;
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top" style="width:50px">

                                                                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                                    <tr>
                                                                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                                            background-position: left bottom;">
                                                                                                                            &nbsp;
                                                                                                                        </td>
                                                                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                                            background-repeat: repeat-x; background-position: 50% bottom;">
                                                                                                                            <asp:Button runat="server" ID="btnEditRemark" RelatedRemarkID='<%# Eval("RelatedRemarkID")%>'
                                                                                                                                Width="35px" CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditRemark_Click" />
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
                                                                                                            <td style="padding-top:5px">&nbsp;&nbsp;
                                                                                                                <asp:ImageButton ID="btnDeleteRemark" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                                                    RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' OnClick="btnDeleteRemark_Click"
                                                                                                                    OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את ההערה')"></asp:ImageButton>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>

                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </td>
                                                            </tr>
                                                            <tr id="trRemarksHeader_Future" runat="server">
                                                                <td style="width: 960px; padding-right: 5px; background-color: #E9F5FE">
                                                                    <img id="imgShowRemarks3" runat="server" style="cursor: hand" src="../Images/Applic/btn_Plus_Blue_12.gif"
                                                                        onclick="ShowRemarks3();" />
                                                                    &nbsp;
                                                                    <asp:Label runat="server" ID="lblRemarksHeader3" EnableTheming="false" CssClass="LabelCaptionBlueBold_16"
                                                                        Text="הערות עתידיות"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr id="trFutureRemarks" runat="server" style="display: none">
                                                                <td>
                                                                    <asp:GridView ID="gvRemarks_Future" AutoGenerateColumns="false" runat="server" SkinID="SimpleGridView"
                                                                        HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvRemarks_RowDataBound">
                                                                        <Columns>
                                                                            <asp:TemplateField ItemStyle-BackColor="#F7F7F7">
                                                                                <ItemTemplate>
                                                                                    <table style="width: 795px; border-bottom: solid 1px #CBCBCB" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td align="center" valign="top">
                                                                                                <div style="width: 10px">
                                                                                                    <asp:ImageButton ID="btnExclusions" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/ExclamationMarkOrange.gif"
                                                                                                        RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' ToolTip="יחידות לא כלולות"></asp:ImageButton>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblRemrkText" Width="228px" runat="server" Text='<%#Eval("RemarkText") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView ID="gvDistricts" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                    HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <asp:Label ID="lblAdministration" Width="95px" runat="server" Text='<%#Eval("districtName") %>'></asp:Label>
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="75px" ID="gvAdministration" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="AdministrationName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:GridView Width="80px" ID="gvUnitType" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    runat="server" HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="UnitTypeName" ItemStyle-CssClass="RegularLabel" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:Label ID="lblSubUnitType" runat="server" Width="55px"></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 55px">
                                                                                                    <asp:GridView ID="vgPopulationSector" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="PopulationSectorDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 70px">
                                                                                                    <asp:GridView ID="gvCities" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="cityName" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <div style="width: 100px">
                                                                                                    <asp:GridView ID="gvServices" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                                                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                                                                                        <Columns>
                                                                                                            <asp:BoundField DataField="ServiceDescription" ItemStyle-CssClass="RegularLabel" />
                                                                                                        </Columns>
                                                                                                    </asp:GridView>
                                                                                                </div>
                                                                                                <asp:Label ID="lblServiceDescription" Width="60px" runat="server" ></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top" align="center">
                                                                                                <div style="border-bottom:1px solid Gray">
                                                                                                <asp:Label ID="lblValidFrom" Width="70px" runat="server" Text='<%#Eval("ValidFrom","{0:d}") %>'></asp:Label>
                                                                                                </div>
                                                                                                <asp:Label ID="lblValidTo" Width="70px" runat="server" Text='<%#Eval("ValidTo","{0:d}") %>'></asp:Label>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                            </td>
                                                                                            <td valign="top" style="width: 25px; margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                                                                <div style="width: 25px">
                                                                                                    <asp:Image ID="imgNotShowInInternet" ToolTip="לא תוצג באינטרנט" runat="server" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif" />&nbsp;
                                                                                                </div>
                                                                                            </td>
                                                                                            <td valign="top">
                                                                                                <asp:PlaceHolder ID="pnlEditButton" runat="server">
                                                                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                                    <tr>
                                                                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                                            background-position: left bottom;">
                                                                                                                            &nbsp;
                                                                                                                        </td>
                                                                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                                            background-repeat: repeat-x; background-position: 50% bottom;">
                                                                                                                            <asp:Button runat="server" ID="btnEditRemark" RelatedRemarkID='<%# Eval("RelatedRemarkID")%>'
                                                                                                                                Width="35px" CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditRemark_Click" />
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
                                                                                                            <td style="padding-top:5px">&nbsp;&nbsp;
                                                                                                                <asp:ImageButton ID="btnDeleteRemark" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                                                    RelatedRemarkID='<%# Eval("RelatedRemarkID")%>' OnClick="btnDeleteRemark_Click"
                                                                                                                    OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את ההערה')"></asp:ImageButton>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </asp:PlaceHolder>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                        </Columns>
                                                                    </asp:GridView>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
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
                <tr>
                    <td dir="ltr">
                        <!-- Selected Remarks -->
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 10px">
                        <!-- Lower Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="width: 100%">
                            <tr>
                                <td style="background-color: #298AE5; height: 18px;">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <asp:HiddenField ID="hdnNewUnitCodeSelected" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
