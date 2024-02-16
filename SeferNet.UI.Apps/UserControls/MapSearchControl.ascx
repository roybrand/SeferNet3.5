<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_MapSearchControl" Codebehind="MapSearchControl.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc11" %>
<asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server">
</asp:ScriptManagerProxy>

<script type="text/javascript">

    //consts colors
    var whiteColor = "White";
    var showControlsColor = "E8F4FD";

    function btnShowMapSearchControlsClicked() {
        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');
        cbShowMapSearchControls.checked = !cbShowMapSearchControls.checked;
        SetSearchControlsVisibility();
    }
    
    function ClearCityCode() {

        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
        var txtCityNameOnly = document.getElementById('<%=txtCityNameOnly.ClientID %>');
        var txtNeighborhood = document.getElementById('<%=txtNeighborhood.ClientID %>');
        var txtSite = document.getElementById('<%=txtSite.ClientID %>');
        var txtStreet = document.getElementById('<%=txtStreet.ClientID %>');
        var txtHouse = document.getElementById('<%=txtHouse.ClientID %>');
        //var ddlNumberOfRecordsToShow = document.getElementById('<%=ddlNumberOfRecordsToShow.ClientID %>');
        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');

        txtCityCode.value = "";
        txtCityName.value = "";
        txtCityNameOnly.value = "";
        txtNeighborhood.value = "";
        txtSite.value = "";
        txtStreet.value = "";
        txtHouse.value = "";
        cbShowMapSearchControls.checked = false;

        // If CityCode is NOT selected then controls for MapSearch are NOT to be in use
        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');
        cbShowMapSearchControls.checked = false;

        SetSearchControlsVisibility();
    }
    
    function OnDDCityCodeSelected(source, eventArgs) {
        // alert( " Key : "+ eventArgs.get_text() +"  Value :  "+eventArgs.get_value());
        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCityNameOnly = document.getElementById('<%=txtCityNameOnly.ClientID %>');

        var value = eventArgs.get_value();
        var valueArray = value.split("~");
        //cityCodeTextBox.value = eventArgs.get_value();
        txtCityCode.value = valueArray[0];
        txtCityNameOnly.value = valueArray[1];

        var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
        txtCityName.value = eventArgs.get_text();

        // If CityCode is selected then controls for MapSearch are to be in use


        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');
        cbShowMapSearchControls.checked = false;

        SetSearchControlsVisibility();
        
        //raise event instead???
        var btn = document.getElementById('<%=btnMapSearchControls.ClientID %>');
        btn.click();

    
    }

    function SetSearchControlsVisibility() {
        var trMapSearch_1 = document.getElementById('<%=trMapSearch_1.ClientID %>');
        var trMapSearch_2 = document.getElementById('<%=trMapSearch_2.ClientID %>');
        var trMapSearch_3 = document.getElementById('<%=trMapSearch_3.ClientID %>');
        var trMapSearch_4 = document.getElementById('<%=trMapSearch_3.ClientID %>');
        var trMapSearch_City = document.getElementById('<%=trMapSearch_City.ClientID %>');
        
        var btnShowMapSearchControls = document.getElementById('<%=btnShowMapSearchControls.ClientID %>');
        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');

        if (txtCityCode.value == "")
            cbShowMapSearchControls.checked = false;

        // Close
        if (cbShowMapSearchControls.checked == false) {
            trMapSearch_1.style.display = "none";
            trMapSearch_2.style.display = "none";
            trMapSearch_3.style.display = "none";
            trMapSearch_4.style.display = "none";

            trMapSearch_1.style.backgroundColor = whiteColor;
            trMapSearch_2.style.backgroundColor = whiteColor;
            trMapSearch_3.style.backgroundColor = whiteColor;
            trMapSearch_4.style.backgroundColor = whiteColor;
            trMapSearch_City.style.backgroundColor = whiteColor;

            if (OnMapSearchControlsCollapsed && OnMapSearchControlsCollapsed != null) {
                OnMapSearchControlsCollapsed();
            }
        }

        //Open
        else {


            trMapSearch_1.style.display = "inline";
            trMapSearch_2.style.display = "inline";
            trMapSearch_3.style.display = "inline";
            trMapSearch_4.style.display = "inline";

            trMapSearch_1.style.backgroundColor = showControlsColor;
            trMapSearch_2.style.backgroundColor = showControlsColor;
            trMapSearch_3.style.backgroundColor = showControlsColor;
            trMapSearch_4.style.backgroundColor = showControlsColor;
            trMapSearch_City.style.backgroundColor = showControlsColor;

            if (OnMapSearchControlsExpanded && OnMapSearchControlsExpanded != null) {
                OnMapSearchControlsExpanded();
            }
        }

        if (txtCityCode.value == "") {
            btnShowMapSearchControls.style.display = "none";
        }
        else {
            btnShowMapSearchControls.style.display = "inline";
            if (cbShowMapSearchControls.checked == false) {
              
                btnShowMapSearchControls.src = "Images/Applic/btn_Plus_Green.jpg";
            }
            else {
               
                btnShowMapSearchControls.src = "Images/Applic/btn_Cross_Blue.jpg";
            }
        }
    }

//    function txtCityName_onKeyPress(sender, e) {
//        //debugger;
//        var evt = window.event ? window.event : e; //distinguish between IE's explicit event object (window.event) and Firefox's implicit.
//        var keyCode = evt.charCode ? evt.charCode : evt.keyCode;
//        if (keyCode == 13)//Enter
//        {
//            // document.getElementById('btnSubmit.ClientID').focus();
//        }
//    }



    var OnDistrictCodeChanged = null;
    var OnMapSearchControlsExpanded = null;
    var OnMapSearchControlsCollapsed = null;

    function getDistrictCode(source, eventArgs) {
        document.getElementById('<%=txtDistrictCodes.ClientID %>').value = eventArgs.get_value();
        document.getElementById('<%=txtDistrictList.ClientID %>').value = eventArgs.get_text();

        document.getElementById("btnDistrictsPopUp").focus();


        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
        var txtCityNameOnly = document.getElementById('<%=txtCityNameOnly.ClientID %>');

        txtCityCode.value = "";
        txtCityName.value = "";
        txtCityNameOnly.value = "";
        ClearCityCode();


        if (OnDistrictCodeChanged && OnDistrictCodeChanged != null) {
            OnDistrictCodeChanged();

            //handle on the subscriber
            //raisePanelTopPostBackFromMaster();
        }
    }

    function SelectDistricts() {
        var url = "SelectPopUp.aspx";

        var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');
        var txtDistrictList = document.getElementById('<%=txtDistrictList.ClientID %>');
        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
        var txtCityNameOnly = document.getElementById('<%=txtCityNameOnly.ClientID %>');
        var btnShowMapSearchControls = document.getElementById('<%=btnShowMapSearchControls.ClientID %>');
        var cbShowMapSearchControls = document.getElementById('<%=cbShowMapSearchControls.ClientID %>');

        var SelectedDistrictsList = txtDistrictCodes.innerText;
        url = url + "?SelectedValuesList=" + SelectedDistrictsList;
        url = url + "&popupType=7";
        var features = featuresForPopUp();

        var obj = window.showModalDialog(url, "SelectDistricts", features);

        if (obj != null) {
            txtDistrictCodes.innerText = obj.Value;
            txtDistrictList.innerText = obj.Text;
            txtCityCode.value = "";
            txtCityName.value = "";
            txtCityNameOnly.value = "";
            ClearCityCode();

            if (OnDistrictCodeChanged && OnDistrictCodeChanged != null) {
                OnDistrictCodeChanged();
            }
            
            return true;
        }
        else {
            return false;
        }

    }

    function ClearDistricts() {
        document.getElementById('<%=txtDistrictCodes.ClientID %>').value = "";
        document.getElementById('<%=txtDistrictList.ClientID %>').value = "";
        document.getElementById("btnDistrictsPopUp").focus();

        var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
        var txtCityNameOnly = document.getElementById('<%=txtCityNameOnly.ClientID %>');

        txtCityCode.value = "";
        txtCityName.value = "";
        txtCityNameOnly.value = "";
        ClearCityCode();

        if (OnDistrictCodeChanged && OnDistrictCodeChanged != null) {
            OnDistrictCodeChanged();

            //handle on the subscriber
            //raisePanelTopPostBackFromMaster();
        }
    }

    //register events on window load
    if (window.addEventListener) {
        window.addEventListener('load', OnWindowLoaded, false); //W3C
    }
    else {
        window.attachEvent('onload', OnWindowLoaded); //IE    
    }

    function OnWindowLoaded() {
        SetSearchControlsVisibility();
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(endAjaxPostback);
        //alert(' i was loaded');
    }


    function endAjaxPostback(sender, e) {
        SetSearchControlsVisibility();


    }

</script>

<table dir="rtl" id="tblMapSearchControls" width="520px" runat="server" cellpadding="0"
    cellspacing="0">
    <tr>
        <td id="tdMapSearchControls" runat="server" valign="top" 
        style="background-repeat: no-repeat;   background-position: right;   padding:0px; margin:0px;">
            <asp:UpdatePanel ID="updMapSearchControls" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Button ID="btnMapSearchControls" runat="server" Text="Button" CssClass="DisplayNone" />
                    <table id="tblBottomRight" cellpadding="0" cellspacing="0">
                        <tr id="trDistricts">
                            <td valign="top" style="width: 60px">
                                  <asp:Label ID="lblDistrict" runat="server" Text="מחוז"></asp:Label>
                              </td>
                            <td style="padding-right: 4px">
                                            <asp:TextBox ID="txtDistrictList" runat="server" onchange="ClearDistricts();" Width="150px"
                                                ReadOnly="false" TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine"
                                                EnableTheming="false"></asp:TextBox>
                                            <cc11:AutoCompleteExtender runat="server" ID="autoCompleteDistricts" TargetControlID="txtDistrictList"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getDistricts"
                                                MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getDistrictCode" />
                                        </td>
                            <td valign="top">
                                        <div style="width:40px; height:0px;"></div>                       
                                        <input type="image" id="btnDistrictsPopUp" style="cursor: hand;" src="Images/Applic/icon_magnify.gif"
                                                onclick="return SelectDistricts()" />
                                                 <span style="display: none;">
                                            <asp:TextBox ID="txtDistrictCodes" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        </span> 
                                        </td>
                            <td colspan="2">
                            <div style="position:absolute; z-index:-1; width:100%; height:1px; border:2; background-color:Transparent;"></div>
                            </td>
                         </tr>
                        <tr id="trMapSearch_City" runat="server">
                            <td style="width: 57px">
                                <asp:Label ID="lblCityName" runat="server" Text="ישוב"></asp:Label>
                            </td>
                            <td style="padding-right: 4px">
                                <asp:TextBox ID="txtCityName" Width="150px" runat="server" onchange="ClearCityCode();"></asp:TextBox>
                                <asp:TextBox ID="txtCityNameOnly" Width="100px" runat="server" EnableTheming="false"
                                    CssClass="DisplayNone"></asp:TextBox>
                                <asp:TextBox runat="server" ID="txtCityCode" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                <cc11:AutoCompleteExtender runat="server" ID="autoCompleteCities" TargetControlID="txtCityName"
                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetCitiesAndDistricts_MultipleDistricts"
                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                    UseContextKey="True" OnClientItemSelected="OnDDCityCodeSelected" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                    CompletionListCssClass="CopmletionListStyle" />
                            </td>
                            <td>
                                <div style="width: 40px">
                                    <asp:Image type="image" ID="btnShowMapSearchControls" runat="server" Style="cursor: hand;
                                        display: none;" src="Images/Applic/btn_Plus_Green.jpg" onclick="btnShowMapSearchControlsClicked(); return false;" />
                                    <asp:CheckBox ID="cbShowMapSearchControls" runat="server" EnableTheming="false" CssClass="DisplayNone" />
                                </div>
                            </td>
                                                  
                        </tr>
                        <tr id="trMapSearch_1" runat="server" style="display: none">
                            <td>
                                <div id="divNeighborhood" runat="server">
                                    <asp:Label ID="lblNeighborhood" runat="server" Text="שכונה"></asp:Label>
                                </div>
                            </td>
                            <td style="padding-right: 4px">
                                <asp:TextBox ID="txtNeighborhood" runat="server" Width="150px"></asp:TextBox>
                                <cc11:AutoCompleteExtender runat="server" ID="autoCompleteNeighborhood" TargetControlID="txtNeighborhood"
                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetNeighbourhoodsByCityCode"
                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                    CompletionListCssClass="CopmletionListStyle" />
                            </td>
                            <td>
                                <asp:RegularExpressionValidator ID="VldRegexNeighborhood" runat="server" ControlToValidate="txtNeighborhood"
                                    ValidationGroup="vldGrSearch" Text="!">
                                </asp:RegularExpressionValidator>
                                <asp:CustomValidator ID="VldPreservedWordsNeighborhood" runat="server" ControlToValidate="txtNeighborhood"
                                    ClientValidationFunction="CheckPreservedWords" ValidationGroup="vldGrSearch"
                                    Text="!">
                                </asp:CustomValidator>
                            </td>
                            <td align="right" >
                                <asp:Label ID="lblSite" runat="server" Text="אתר"></asp:Label>
                                <div style="width: 60px; height:0px;">
                            </td>
                            <td>
                                <asp:TextBox ID="txtSite" runat="server" Width="150px"></asp:TextBox>
                                <cc11:AutoCompleteExtender runat="server" ID="autoCompleteSite" TargetControlID="txtSite"
                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetSitesByCityCode"
                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                    CompletionListCssClass="CopmletionListStyle" />
                                <asp:RegularExpressionValidator ID="VldRegexSite" runat="server" ControlToValidate="txtSite"
                                    ValidationGroup="vldGrSearch" Text="!">
                                </asp:RegularExpressionValidator>
                                <asp:CustomValidator ID="vldPreservedWordsSite" runat="server" ClientValidationFunction="CheckPreservedWords"
                                    ValidationGroup="vldGrSearch" ControlToValidate="txtSite" Text="!">
                                </asp:CustomValidator>
                            </td>
                        </tr>
                        <tr id="trMapSearch_2" runat="server" style="display: none">
                            <td>
                                <asp:Label ID="lblStreet" runat="server" Text="רחוב"></asp:Label>
                            </td>
                            <td style="padding-right: 4px">
                                <asp:TextBox ID="txtStreet" runat="server" Width="150px"></asp:TextBox>
                                <cc11:AutoCompleteExtender runat="server" ID="autoCompleteStreets" TargetControlID="txtStreet"
                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetStreetsByCityCode"
                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                    CompletionListCssClass="CopmletionListStyle" />
                            </td>
                            <td>
                                <asp:RegularExpressionValidator ID="VldRegexStreet" runat="server" ControlToValidate="txtStreet"
                                    ValidationGroup="vldGrSearch" Text="!">
                                </asp:RegularExpressionValidator>
                                <asp:CustomValidator ID="VldPreservedWordsStreet" runat="server" ClientValidationFunction="CheckPreservedWords"
                                    ValidationGroup="vldGrSearch" ControlToValidate="txtStreet" Text="!">
                                </asp:CustomValidator>
                            </td>
                            <td >
                                <asp:Label ID="lblHome" runat="server" Text="בית"></asp:Label>
                                <div style="width: 60px; height:0px;">                            
                            </td>
                            <td>
                                <asp:TextBox ID="txtHouse" runat="server" Width="150px"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="vldRegexHouse" runat="server" ControlToValidate="txtHouse"
                                    ValidationGroup="vldGrSearch" Text="!">
                                </asp:RegularExpressionValidator>
                                <asp:CustomValidator ID="vldPreservedWordsHouse" runat="server" ClientValidationFunction="CheckPreservedWords"
                                    ValidationGroup="vldGrSearch" ControlToValidate="txtHouse" Text="!">
                                </asp:CustomValidator>
                            </td>
                        </tr>
                        <tr id="trMapSearch_3" runat="server" style="display: none;">
                            <td colspan="5">
                                <asp:Label ID="lblNumberOfRecordsToShow" runat="server" Text="מס` תוצאות"></asp:Label>                           
                                <asp:Label ID="Label1" runat="server">יוצגו</asp:Label>
                                <asp:DropDownList ID="ddlNumberOfRecordsToShow" runat="server" Width="60px">
                                    <asp:ListItem Text="5" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="10" Value="10"></asp:ListItem>
                                    <asp:ListItem Text="15" Value="15"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:Label ID="Label2" runat="server">היחידות הקרובות ביותר לכתובת שהזנת</asp:Label>
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </td>
    </tr>
</table>
