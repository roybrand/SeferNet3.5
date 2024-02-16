<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SelectEmployeePopUp.aspx.cs" Inherits="SeferNet.UI.Apps.Public.SelectEmployeePopUp" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self"/>
    <title></title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
    <script type="text/javascript">
        function LightOnMouseOver(obj) {
            obj.style.background = "#B0CEE6";
            obj.style.cursor = "hand";
        }

        function LightOffOnMouseOver(obj) {
            obj.style.background = "transparent";
        }

        function SelectEmployee() {
            var selectedEmployeeID = document.getElementById('<%=txtSelectedEmployeeID.ClientID %>').value;
            var selectedEmployeeName = document.getElementById('<%=txtSelectedEmployeeName.ClientID %>').value;

            window.parent.$("[id$=txtEmployeeCodes]").val(selectedEmployeeID);
            window.parent.$("[id$=txtEmployee]").val(selectedEmployeeName);

            SelectJQueryClose();
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

                if (txtFirstName.value == "" && txtLastName.value == "" && txtEmployeeID.value == "" && txtLicenseNumber.value == "")
                    args.IsValid = false;
                else
                    args.IsValid = true;
        }

        function UpdateAutoCompleteName(otherNameID, acExtenderID) {

            var otherName = document.getElementById(otherNameID).value;

            var membershipValues = "Community";

            var newContext = otherName + '~' + membershipValues;
            $find(acExtenderID).set_contextKey(newContext);
        }
</script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true" EnablePageMethods="true">
        <Services>
            <asp:ServiceReference Path="~/AjaxWebServices/AutoComplete.asmx" />
        </Services>
    </asp:ScriptManager>
    <div style="display:none">
        <asp:TextBox ID="txtSelectedEmployeeID" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtSelectedEmployeeName" runat="server"></asp:TextBox>
    </div>
    <div id="divAddEmployeeToClinicLB" runat="server">  
        <table cellpadding="0" cellspacing="0" width="100%" dir="rtl">
            <tr>
                <td align="center" style="width:100%; padding: 10px 0px 0px 0px">
		            <table width="500px" cellpadding="0" cellspacing="0" style="background-color:White; border:solid 1px #CBCBCB">
		                <tr>
		                    <td align="right" style="padding-right:5px">
		                        <asp:Label ID="lblError" runat="server" EnableTheming="false" CssClass="ErrorMessage"></asp:Label>
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
		                    <td align="right" style="width:100%; padding:10px 10px 0px 0px">
		                        <table cellpadding="0" cellspacing="0" border="0">
		                            <tr>
		                                <td style="padding-left:5px">
                                            <asp:Label runat="server" ID="lblFirstNameCaption" Text="שם פרטי" 
                                                EnableTheming="false"  CssClass="MultiLineLabel"></asp:Label>
		                                </td>
		                                <td width="120px">
                                            <asp:TextBox ID="txtFirstName" Width="100px" runat="server" AutoPostBack="true"></asp:TextBox>
                                             <ajaxToolkit:AutoCompleteExtender
                                                runat="server"
                                                ID="AutoCompleteFirstName"
                                                BehaviorID="AutoCompleteFirstName" 
                                                TargetControlID="txtFirstName"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                                ServiceMethod="getDoctorActiveByFirstName"
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
		                                <td style="padding-left:5px; padding-right:0px">
                                            <asp:Label runat="server" ID="lblLastNameCaption" Text="שם משפחה" 
                                                EnableTheming="false" CssClass="MultiLineLabel"></asp:Label>
		                                </td>
		                                <td>
                                            <asp:TextBox ID="txtLastName" Width="100px" runat="server" AutoPostBack="true"></asp:TextBox>
                                             <ajaxToolkit:AutoCompleteExtender
                                                runat="server" 
                                                ID="AutoCompleteLastName" 
                                                BehaviorID="AutoCompleteLastName"
                                                TargetControlID="txtLastName"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                                ServiceMethod="getDoctorActiveByLastName"
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
		                                <td>

		                                </td>
		                            </tr>
		                            <tr>
		                                <td  style="padding-left:5px">
                                            <asp:Label ID="lblEmployeeID" Width="60px" runat="server" Text="מספר ת.ז. (עם ס.פ.)" 
                                                EnableTheming="false"  CssClass="RegularLabel"></asp:Label>
		                                </td>
		                                <td style="padding-top: 5px">
                                            <asp:TextBox ID="txtEmployeeID" Width="100px" runat="server"></asp:TextBox>
                                            <asp:CompareValidator ID="vldEmployeeID" runat="server" Text="*" ValidationGroup="grSearchParameters" 
                                                ErrorMessage="מספר ת.ז. אמור להיות מספרי" ControlToValidate="txtEmployeeID" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
		                                </td>
		                                <td  style="padding-left:5px; padding-right:0px">
                                            <asp:Label ID="lblLicenseNumber" runat="server" Text="מספר רשיון" 
                                                EnableTheming="false"  CssClass="MultiLineLabel"></asp:Label>
		                                </td>
		                                <td style="padding-top: 5px">
                                            <asp:TextBox ID="txtLicenseNumber" Width="100px" runat="server"></asp:TextBox>
                                            <asp:CompareValidator ID="vldLicenseNumber" runat="server" Text="*" ValidationGroup="grSearchParameters" 
                                                ErrorMessage="מספר רשיון אמור להיות מספרי" ControlToValidate="txtLicenseNumber" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
		                                </td>
		                                <td style="padding:0px 0px 0px 0px">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;</td>
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
		            </table>
		        </td>
		    </tr>
            <tr style="padding-right:10px">
                <td style="padding:5px 10px 5px 0px" id="tdMainHeader" runat="server" align="right">
                    <asp:Label ID="lblSelectIfMoreThenOne" EnableTheming="false" CssClass="LabelBoldBlack_14" runat="server" 
                        Text="במידה ונמצאו מספר תוצאות, יש לבחור אחת ע&quot;י לחיצה על השורה המתאימה:" ></asp:Label>
                </td>
		    </tr>
            <tr>
                <td align="right" style="padding-right:10px">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td align="right" style="padding:0px 15px 0px 0px">
                                <table cellpadding="0" cellspacing="0" style="background-color:Gray">
                                    <tr>
                                        <td style="padding-right:5px; width:88px">
                                            <asp:Label ID="lblSectorHeader" runat="server" Text="סקטור" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                        <td style="width:48px">
                                            <asp:Label ID="lblDegreeHeader" runat="server" Text="תואר" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                        <td style="width:80px">
                                            <asp:Label ID="lblFirstNameHeader" runat="server" Text="שם פרטי" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                        <td style="width:90px">
                                            <asp:Label ID="lblLastNameHeader" runat="server" Text="שם משפחה" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                        <td style="width:70px">
                                            <asp:Label ID="lblEmployeeIDHeader" runat="server" Text="מספר ת.ז." CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                        <td style="width:70px">
                                            <asp:Label ID="lblLicenseNumberHeader" runat="server" Text="מספר רישיון" CssClass="LabelBoldWhite_13" EnableTheming="false"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" style="padding: 0px 0px 0px 0px">
                                <div style="height:250px; overflow:auto;direction:ltr"   >
                                    <div style="direction:rtl">
                                            <asp:GridView ID="gvEmployeeList" runat="server"
                                        SkinID="GridViewForSearchResults" EnableTheming="True" 
                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0" onclick="GetEmployeeID('<%#Eval("employeeID") %>');" onmouseover="LightOnMouseOver(this)" onmouseout="LightOffOnMouseOver(this)">
                                                        <tr>
                                                            <td style="width:90px">
                                                                <asp:Label ID="lblEmployeeSectorDescription" CssClass="RegularLabel" EnableTheming="false" runat="server" Text='<%#Bind("EmployeeSectorDescription") %>'></asp:Label>
                                                            </td>
                                                            <td style="width:50px">
                                                                <asp:Label ID="lblDegreeName" runat="server" Text='<%#Bind("DegreeName") %>'></asp:Label>
                                                            </td>
                                                            <td style="width:80px">
                                                                <asp:Label ID="lblFirstName" runat="server" Text='<%#Bind("firstName") %>'></asp:Label>
                                                            </td>
                                                            <td style="width:90px">
                                                                <asp:Label ID="lblLastName" runat="server" Text='<%#Bind("lastName") %>'></asp:Label>
                                                            </td>
                                                            <td style="width:70px">
                                                                <asp:Label ID="lblEmployeeID" runat="server" Text='<%#Bind("employeeID") %>'></asp:Label>
                                                            </td>
                                                            <td style="width:70px">
                                                                <asp:Label ID="lblLicenseNumber" runat="server" Text='<%#Bind("licenseNumber") %>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
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
            <tr>
                <td style="padding-top:15px; padding-left:30px; padding-bottom:10px" align="left">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                            </td>
                            <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                <asp:Button id="btnCancel" runat="server" Text="ביטול" cssClass="RegularUpdateButton" 
                                    OnClientClick="SelectJQueryClose();"></asp:Button>
                            </td>
                            <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
