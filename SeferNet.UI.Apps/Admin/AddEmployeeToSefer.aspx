<%@ Page Language="C#"  Title="הוספת נותני שירות"   AutoEventWireup="true" MasterPageFile="~/seferMasterPage.master" Inherits="AddEmployeeToSefer"   Codebehind="AddEmployeeToSefer.aspx.cs" %>
<%@ MasterType    VirtualPath="~/seferMasterPage.master" %>
<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="postBackPageContent" runat="server">
    <script type="text/javascript">
    var lastRowColor;
    function LightOnMouseOver(obj) {
        lastRowColor = obj.style.backgroundColor;
        
        obj.style.background = "#B0CEE6";
        obj.style.cursor = "hand";
    }
    
    function LightOffOnMouseOver(obj) {
        obj.style.background = lastRowColor;
    }
    function GetEmployeeID(emploeeID) {
        
        var txtSelectedEmployeeID = document.getElementById('<%=txtSelectedEmployeeID.ClientID %>');
        txtSelectedEmployeeID.value = emploeeID;

        document.forms[0].submit();
    }
    function ValidateParameters(val, args) {
        var txtFirstName = document.getElementById('<%=txtFirstName.ClientID %>');
        var txtLastName = document.getElementById('<%=txtLastName.ClientID %>');
        var txtEmployeeID = document.getElementById('<%=txtEmployeeID.ClientID %>');
        var txtLicenseNumber = document.getElementById('<%=txtLicenseNumber.ClientID %>');
    
        if(txtFirstName.value == "" && txtLastName.value == "" && txtEmployeeID.value == "" && txtLicenseNumber.value == "" )
            args.IsValid = false;
        else
            args.IsValid = true;
    }

    function CheckVirtual() {
        
        var txtFirstName = document.getElementById('<%=txtFirstName.ClientID %>');
        var txtLastName = document.getElementById('<%=txtLastName.ClientID %>');
        var txtEmployeeID = document.getElementById('<%=txtEmployeeID.ClientID %>');
        var txtLicenseNumber = document.getElementById('<%=txtLicenseNumber.ClientID %>');

        var cbVirtualDoctor = document.getElementById('<%=cbVirtualDoctor.ClientID %>');
        
        var ddlSector = document.getElementById('<%=ddlSector.ClientID %>');
        var trDemografia = document.getElementById('<%=trDemografia.ClientID %>');
        var tdAddVirtual = document.getElementById('<%=tdAddVirtual.ClientID %>');
        var trSelectIfMoreThenOne = document.getElementById('<%=trSelectIfMoreThenOne.ClientID %>');
        var trEmployeeList = document.getElementById('<%=trEmployeeList.ClientID %>');
        
        var trParameters = document.getElementById('<%=trParameters.ClientID %>');
        var tdDentist = document.getElementById('<%=tdDentist.ClientID %>');

        if (cbVirtualDoctor.checked) {
//            txtFirstName.value = "";
//            txtLastName.value = "";
//            txtEmployeeID.value = "";
//            txtLicenseNumber.value = "";

            ddlSector.disabled = true;

            trParameters.style.display = "none";
            trSelectIfMoreThenOne.style.display = "none";
            trEmployeeList.style.display = "none";

            tdAddVirtual.style.display = "inline";

            trDemografia.style.display = "none";

            tdDentist.style.display = "none";
        }
        else {
            ddlSector.disabled = false;

            trParameters.style.display = "inline";
            trSelectIfMoreThenOne.style.display = "inline";
            trEmployeeList.style.display = "inline";

            tdAddVirtual.style.display = "none";

            trDemografia.style.display = "none";
        
            tdDentist.style.display = "inline";
        }
    }

    function CheckDental() {

        var txtFirstName = document.getElementById('<%=txtFirstName.ClientID %>');
        var txtLastName = document.getElementById('<%=txtLastName.ClientID %>');
        var txtEmployeeID = document.getElementById('<%=txtEmployeeID.ClientID %>');
        var txtLicenseNumber = document.getElementById('<%=txtLicenseNumber.ClientID %>');

        var cbVirtualDoctor = document.getElementById('<%=cbVirtualDoctor.ClientID %>');

        var ddlSector = document.getElementById('<%=ddlSector.ClientID %>');
        var trDemografia = document.getElementById('<%=trDemografia.ClientID %>');
        var tdAddVirtual = document.getElementById('<%=tdAddVirtual.ClientID %>');
        var trSelectIfMoreThenOne = document.getElementById('<%=trSelectIfMoreThenOne.ClientID %>');
        var trEmployeeList = document.getElementById('<%=trEmployeeList.ClientID %>');

        var trParameters = document.getElementById('<%=trParameters.ClientID %>');
        var tdVirtual = document.getElementById('<%=tdVirtual.ClientID %>');
        var cbDentist = document.getElementById('<%=cbDentist.ClientID %>');

        if (cbDentist.checked) {
            //            txtFirstName.value = "";
            //            txtLastName.value = "";
            //            txtEmployeeID.value = "";
            //            txtLicenseNumber.value = "";

            ddlSector.disabled = true;

            trParameters.style.display = "none";
            trSelectIfMoreThenOne.style.display = "none";
            trEmployeeList.style.display = "none";

            tdAddVirtual.style.display = "none";
            tdVirtual.style.display = "none";

            trDemografia.style.display = "inline";
        }
        else {
            ddlSector.disabled = false;

            trParameters.style.display = "inline";
            trSelectIfMoreThenOne.style.display = "inline";
            trEmployeeList.style.display = "inline";

            tdAddVirtual.style.display = "none";
            tdVirtual.style.display = "inline";

            trDemografia.style.display = "none";
        }
    }
    // Function to highlight typed text in auto suggest results
    function ClientPopulated(source, eventArgs) {
        if (source._currentPrefix != null) {
            var list = source.get_completionList();
            var search = source._currentPrefix.toLowerCase();
            for (var i = 0; i < list.childNodes.length; i++) {
                var text = list.childNodes[i].innerHTML;
                var index = text.toLowerCase().indexOf(search);
                if (index != -1) {
                    var value = text.substring(0, index);
                    //value += '<span class="AutoComplete_ListItemHiliteText">';
                    value += '<b>';
                    value += text.substr(index, search.length);
                    //value += '</span>';
                    value += '</b>';
                    value += text.substring(index + search.length);
                    list.childNodes[i].innerHTML = value;
                }
            }
        }




    }


    
</script>

<asp:UpdatePanel ID="UpdatePanel1" runat="server">

<ContentTemplate>
<div id="progress" style="position:absolute; top: 300px; left: 500px; z-index:15000 ">
    <asp:UpdateProgress ID="UpdateProgress1" runat="server">
        <ProgressTemplate>
            <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
        </ProgressTemplate>
    </asp:UpdateProgress>
</div>              
    
    
    <div style="display:none">
        <table>
            <tr>
                <td>
                    <asp:Button ID="btnAddDoctors" runat="server" />
                    <asp:TextBox ID="txtSelectedEmployeeID" runat="server"></asp:TextBox>
                    <asp:TextBox ID="txtSelectedFirstName" runat="server"></asp:TextBox>
                    <asp:TextBox ID="txtSelectedLastName" runat="server"></asp:TextBox>
                    <asp:TextBox ID="txtGender" runat="server"></asp:TextBox>
                    <asp:TextBox ID="txtVirtualEmployeeIDreadyForInsert" runat="server"></asp:TextBox>
                </td>
            </tr>
        </table>
    </div>
    <div id="divAddEmployeeToClinicLB" runat="server">  
        <table cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td align="center" style="width:100%; padding: 10px 0px 0px 0px">
		            <table width="500px" cellpadding="0" cellspacing="0" style="background-color:White; border:solid 1px #CBCBCB">
		                <tr>
		                    <td align="right" valign="middle" style="background-color:#2889E4; height:28px; width:100%; padding-right:20px">
                                <asp:Label ID="lblCaptionLB" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server" Text="הוספת נותני שירות"></asp:Label>
		                    </td>
		                </tr>
		                <tr>
		                    <td align="right" style="padding-right:13px">
		                        <asp:Label ID="lblError" runat="server" EnableTheming="false" CssClass="LabelBoldRed12"></asp:Label>
		                    </td>
		                </tr>
		                <tr style="display:none">
		                    <td>
		                        <asp:CustomValidator ID="vldSearchParameters" runat="server" Text="*" ErrorMessage="חובה לבחור לפחות פרמטר אחד" CssClass="DisplayNone"
		                        ValidationGroup="grSearchParameters" ClientValidationFunction="ValidateParameters" ></asp:CustomValidator>
		                    </td>
		                </tr>
		                <tr>
		                    <td align="right" style="padding-right:5px">
		                        <asp:ValidationSummary ID="vldSummary" runat="server" ValidationGroup="grSearchParameters" />
		                    </td>
		                </tr>
		                <tr>
		                    <td align="right" style="padding-right:5px">
		                        <asp:ValidationSummary ID="vldSummaryVirtual" runat="server" ValidationGroup="grSearchParameters_Virtual" />
		                    </td>
		                </tr>
		                <tr>
		                    <td align="right" style="padding-right:5px">
		                        <asp:ValidationSummary ID="vldSummaryDemography" runat="server" ValidationGroup="grSearchParameters_Demografia" />
		                    </td>
		                </tr>
		                <tr>
		                    <td align="right" style="width:100%; padding:10px 10px 0px 0px">
		                        <table cellpadding="0" cellspacing="0">
		                            <tr>
		                                <td style="padding-left:5px; width:60px">
                                            <asp:Label runat="server" ID="lblSector" Text="סקטור"></asp:Label>
		                                </td>
		                                <td>
		                                    <asp:DropDownList ID="ddlSector" Width="100px" runat="server" 
		                                       DataTextField="EmployeeSectorDescription" DataValueField="EmployeeSectorCode" 
                                                AutoPostBack="True" onselectedindexchanged="ddlSector_SelectedIndexChanged" >
		                                    </asp:DropDownList>
		                                </td>
		                                <td id="tdVirtual" runat="server" style="padding-right:20px">
		                                    <asp:CheckBox ID="cbVirtualDoctor" CssClass="RegularLabel" 
                                                runat="server" Text="רופא וירטואלי" onClick="CheckVirtual()" 
                                                AutoPostBack="false" oncheckedchanged="cbVirtualDoctor_CheckedChanged" />
		                                </td>
		                                <td style="padding-right:130px; display:none" id="tdAddVirtual" runat="server">
                                            <table id="tblAddVirtual" runat="server" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                    </td>
                                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                        <asp:Button id="btnAddVirtual" runat="server" Text="הוסף" 
                                                            cssClass="RegularUpdateButton" onclick="btnAddVirtual_Click" 
                                                            ValidationGroup="grSearchParameters_Virtual"></asp:Button>
                                                    </td>
                                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                    </td>
                                                </tr>
                                            </table>
		                                </td>
                                        <td id="tdDentist" runat="server" style="padding-right:20px">    
		                                    <asp:CheckBox ID="cbDentist" CssClass="RegularLabel" 
                                                runat="server" Text="רופא שיניים" onClick="CheckDental()" 
                                                AutoPostBack="false" oncheckedchanged="cbDentist_CheckedChanged" />
                                        </td>
		                            </tr>
		                            <tr>
		                                <td style="padding-left:5px; width:60px;">
                                            <asp:Label runat="server" ID="lblDistrict" Text="מחוז"></asp:Label>
		                                </td>
		                                <td>
                                            <asp:DropDownList ID="ddlDistrict" runat="server" DataValueField="districtCode" DataTextField="districtName"
                                                Width="100px" 
                                                AppendDataBoundItems="True" >
                                            </asp:DropDownList>
		                                </td>
		                                <td>
                                           <asp:RequiredFieldValidator
                                                id="reqDistrictForVirtualDoctor"
                                                Text="*"
                                                ErrorMessage="חובה לבחור מחוז"
                                                InitialValue="-1"
                                                ControlToValidate="ddlDistrict"
                                                Runat="server" 
                                                ValidationGroup="grSearchParameters_Virtual"/>
                                           <asp:RequiredFieldValidator
                                                id="reqDistrictForDemography"
                                                Text="*"
                                                ErrorMessage="חובה לבחור מחוז"
                                                InitialValue="-1"
                                                ControlToValidate="ddlDistrict"
                                                Runat="server" 
                                                ValidationGroup="grSearchParameters_Demografia"/>
		                                </td>
		                            </tr>
		                        </table>
		                    </td>
		                </tr>
		                <tr id="trParameters" runat="server">
		                    <td align="right" style="width:100%; padding:10px 10px 0px 0px">
		                        <table cellpadding="0" cellspacing="0">
		                            <tr>
		                                <td style="padding-left:5px">
                                            <asp:Label runat="server" ID="lblFirstNameCaption" Text="שם פרטי"></asp:Label>
		                                </td>
		                                <td>
                                            <asp:TextBox ID="txtFirstName" Width="96px" runat="server" AutoPostBack="true"></asp:TextBox>&nbsp;
                                             <ajaxToolkit:AutoCompleteExtender
                                                runat="server"
                                                ID="AutoCompleteFirstName" 
                                                TargetControlID="txtFirstName"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                                ServiceMethod="GetEmployeeByFirstNameFrom226"
                                                MinimumPrefixLength="1" 
                                                CompletionInterval="500"                
                                                CompletionListItemCssClass="CompletionListItemStyle"
                                                UseContextKey="True"
                                                CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                EnableCaching="true"
                                                CompletionSetCount="12" DelimiterCharacters="" Enabled="True" 
                                                CompletionListCssClass="CopmletionListStyle"
                                            />
		                                </td>
		                                <td style="padding-left:5px; padding-right:10px">
                                            <asp:Label runat="server" ID="lblLastNameCaption" Text="שם משפחה"></asp:Label>
		                                </td>
		                                <td>
                                            <asp:TextBox ID="txtLastName" Width="100px" runat="server" AutoPostBack="true"></asp:TextBox>
                                             <ajaxToolkit:AutoCompleteExtender
                                                runat="server" 
                                                ID="AutoCompleteLastName" 
                                                TargetControlID="txtLastName"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                                ServiceMethod="GetEmployeeByLastNameFrom226"
                                                MinimumPrefixLength="1" 
                                                CompletionInterval="500"                
                                                CompletionListItemCssClass="CompletionListItemStyle"
                                                UseContextKey="True"
                                                CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                EnableCaching="true"
                                                CompletionSetCount="12" DelimiterCharacters="" Enabled="True" 
                                                CompletionListCssClass="CopmletionListStyle"
                                                BehaviorID="ACExtenderLastName"
                                                
                                            />
		                                </td>
		                            </tr>
		                            <tr>
		                                <td style="padding-left:5px" width="60px" >
                                            <asp:Label  CssClass="MultiLineLabel" EnableTheming="false" ID="lblEmployeeID" runat="server" Text="מספר&nbsp;ת.ז. (עם ס.ב.)" ></asp:Label>
		                                </td>
		                                <td>
                                            <asp:TextBox ID="txtEmployeeID" Width="96px" runat="server"></asp:TextBox>
                                            <asp:CompareValidator ID="vldEmployeeID" runat="server" Text="*" ValidationGroup="grSearchParameters" 
                                                ErrorMessage="מספר ת.ז. אמור להיות מספרי" ControlToValidate="txtEmployeeID" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
		                                </td>
		                                <td style="padding-left:5px; padding-right:10px">
                                            <asp:Label ID="lblLicenseNumber" runat="server" Text="מספר רשיון"></asp:Label>
		                                </td>
		                                <td>
                                            <asp:TextBox ID="txtLicenseNumber" Width="100px" runat="server"></asp:TextBox>
                                            <asp:CompareValidator ID="vldLicenseNumber" runat="server" Text="*" ValidationGroup="grSearchParameters" 
                                                ErrorMessage="מספר רשיון אמור להיות מספרי" ControlToValidate="txtLicenseNumber" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
		                                </td>
		                                <td style="padding:0px 0px 0px 0px">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                    </td>
                                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                        <asp:Button id="btnSelect" runat="server" Text="איתור" cssClass="RegularUpdateButton" 
                                                            onclick="btnSelect_Click" ValidationGroup="grSearchParameters"></asp:Button>
                                                    </td>
                                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                    </td>
                                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                    </td>
                                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                        <asp:Button id="btnClear" runat="server" Text="ניקוי" cssClass="RegularUpdateButton" 
                                                            onclick="btnClear_Click"></asp:Button>
                                                    </td>
                                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                    </td>
                                                </tr>
                                            </table>
		                                </td>
		                            </tr>
		                        </table>
		                    </td>
		                </tr>
                        <tr id="trSelectIfMoreThenOne" runat="server" style="padding-right:10px">
                            <td style="padding:5px 10px 5px 0px" id="tdMainHeader" runat="server" align="right">
                                <asp:Label ID="lblSelectIfMoreThenOne" EnableTheming="false" CssClass="LabelBoldBlack_14" runat="server" 
                                    Text="במידה ונמצאו מספר תוצאות, יש לבחור אחת ע&quot;י לחיצה על השורה המתאימה:" ></asp:Label>
                            </td>
		                </tr>
                        <tr id="trEmployeeList" runat="server">
                            <td align="right" style="padding-right:10px">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td align="right" style="padding:0px 0px 0px 0px">
                                            <table cellpadding="0" cellspacing="0" style="background-color:Gray">
                                                <tr>
                                                    <td style="width:127px; padding-right:6px">
                                                        <asp:Label ID="lblFirstNameHeader" runat="server" Text="שם פרטי" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                                    </td>
                                                    <td style="width:120px">
                                                        <asp:Label ID="lblLastNameHeader" runat="server" Text="שם משפחה" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                                    </td>
                                                    <td style="width:100px">
                                                        <asp:Label ID="lblEmployeeIDHeader" runat="server" Text="מספר ת.ז." CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                                    </td>
                                                    <td style="width:117px">
                                                        <asp:Label ID="lblLicenseNumberHeader" runat="server" Text="מספר רישיון" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="padding: 0px 0px 0px 0px">
                                            <div style="height:250px; overflow:auto;direction:ltr"  >
                                                <div style="direction:rtl">
                                                   <asp:GridView PageSize="10" ID="gvEmployeeList" runat="server" 
                                                    SkinID="GridViewForSearchResults" EnableTheming="True"
                                                    HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false" 
                                                        onrowdatabound="gvEmployeeList_RowDataBound">
                                                    <Columns>
                                                        <asp:BoundField DataField="firstName" ItemStyle-Width="120" />
                                                        <asp:BoundField DataField="lastName" ItemStyle-Width="120" />
                                                        <asp:BoundField DataField="employeeID" ItemStyle-Width="100" />
                                                        <asp:BoundField DataField="licenseNumber" ItemStyle-Width="113" />
                                                        <asp:BoundField DataField="Gender"/>
                                                        
                                                    </Columns>

                                                    <HeaderStyle CssClass="DisplayNone"></HeaderStyle>
                                                </asp:GridView>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="trDemografia" runat="server" style="display:none">
                            <td align="right" style="padding-right:10px">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
		                                <td style="padding-left:5px">
                                            <asp:Label ID="lblEmployeeID_Demografia" runat="server" Text="מספר ת.ז. (עם&nbsp;ס.ב.)" Width="60px"></asp:Label>
		                                </td>
                                        <td>
                                            <asp:TextBox ID="txtEmployeeID_Demografia" Width="96px" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="vldEmployeeID_Demografia_Required" runat="server" ValidationGroup="grSearchParameters_Demografia" ControlToValidate="txtEmployeeID_Demografia" Text="*" ErrorMessage="חובה להזין ת.ז."></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="rev_TxtEmployeeID_Demografia" ControlToValidate="txtEmployeeID_Demografia" ValidationGroup="grSearchParameters_Demografia" runat="server" ValidationExpression="(\d{2,9})" Text="*" ErrorMessage="מספר ת.ז. אמור להיות מספרי בין 2 ו9 ספרות" ></asp:RegularExpressionValidator>
                                        </td>
		                                <td style="padding:0px 212px 0px 0px" >
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                    </td>
                                                    <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                        <asp:Button id="btnSelect_Demografia" runat="server" Text="הוסף" cssClass="RegularUpdateButton" Width="42px" 
                                                            onclick="btnSelect_Demografia_Click" ValidationGroup="grSearchParameters_Demografia"></asp:Button>
                                                    </td>
                                                    <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-top:15px; padding-left:30px; padding-bottom:10px" align="left">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                        </td>
                                        <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                            <asp:Button id="btnCancel" runat="server" Text="ביטול" cssClass="RegularUpdateButton" 
                                                onclick="btnCancel_Click"></asp:Button>
                                        </td>
                                        <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>       
    </div>
  

   </ContentTemplate>
</asp:UpdatePanel>

</asp:Content>
