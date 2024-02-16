<%@ Page Language="C#" AutoEventWireup="true" Title="בחירת יחידות" Inherits="SelectDepts" Codebehind="SelectDepts.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<base target="_self"/>
<link href="~/CSS/General/general.css" type="text/css" rel="Stylesheet" />
<title>בחירת יחידות</title>
<script type="text/javascript">
function SetTitle(){
     document.title = "בחירת יחידות";
}
</script>
<script type="text/javascript" language="javascript">

    function SelectCity(source, eventArgs) {
        values = eventArgs.get_value();
        hdnCityCode = document.getElementById('hdnSelectedCityCode');

        hdnCityCode.value = values;
    }

    function SelectUnitType(source, eventArgs) {
        values = eventArgs.get_value();
        hdnUnitTypeCode = document.getElementById('hdnSelectedUnitTypeCode');

        hdnUnitTypeCode.value = values;
    }

    function SelectDept(source, eventArgs) {
        values = eventArgs.get_value();
        //hdnDeptCode = document.getElementById('hdnSelectedDeptCode');

        //hdnDeptCode.value = values;
    }

    function OnLoad() {
        document.getElementById('btnSearch').focus();
    }

    function ReturnSelectedDept(deptCode) {
        var obj = new Object();
        obj.Value = deptCode; 
        //alert(obj.Value);
        window.returnValue = obj;
        self.close();
    }

    function ReturnSelectedDeptsMulty_OLD() {
        var elLength = document.form1.elements.length;
        var deptCodes = "";

        for (i = 0; i < elLength; i++) {
            var type = form1.elements[i].type;
            if (type == "checkbox" && form1.elements[i].checked) {
                if (deptCodes != "")
                    deptCodes = deptCodes + ",";
                deptCodes = deptCodes + form1.elements[i].name;
            }
            else {
            }
        }

        var obj = new Object();

        obj.Value = deptCodes;

        var currentDeptCode = document.getElementById('hdnSelectedDeptCode').value;

        obj.Url = "../Templates/FrmSelectTemplate.aspx?Template=PrintZoomClinicOuter&NearestDepts=" + deptCodes + "&CurrentDeptCode=" + currentDeptCode;

        window.returnValue = obj;
        self.close();

        return false;
    }

    function ReturnSelectedDeptsMulty() {
        var elLength = document.form1.elements.length;
        var deptCodes = "";

        for (i = 0; i < elLength; i++) {
            var type = form1.elements[i].type;
            if (type == "checkbox" && form1.elements[i].checked) {
                if (deptCodes != "")
                    deptCodes = deptCodes + ",";
                deptCodes = deptCodes + form1.elements[i].name;
            }
            else {
            }
        }

        var currentDeptCode = document.getElementById('hdnSelectedDeptCode').value;
        //debugger;
        //window.parent.$("#txtDeptsToBeAdded").val(currentDeptCode);
        //$("[id$=txtSelectedDeptCodes]").val(deptCodes);
        document.getElementById('<%= txtSelectedDeptCodes.ClientID %>').value = deptCodes;
        //parent.$("[id$=txtDeptsToBeAdded]").val(deptCodes);
 
        //parent.Open_FrmSelectTemplate(deptCodes,currentDeptCode);
        //SelectJQueryClose();

        return true;
    }

    function Close() {
        var currentDeptCode = document.getElementById('hdnSelectedDeptCode').value;

        parent.Open_FrmSelectTemplate('',currentDeptCode);
        SelectJQueryClose();
    }

    function Close_OLD() {
        var obj = new Object();
        var currentDeptCode = document.getElementById('hdnSelectedDeptCode').value;
        obj.Url = "../Templates/FrmSelectTemplate.aspx?Template=PrintZoomClinicOuter&NearestDepts=" + "&CurrentDeptCode=" + currentDeptCode;
        window.returnValue = obj;

        self.close();
    }
    function Clean() {
        document.getElementById('txtDeptCode').value = '';
    }      
</script>
</head>
<body onload="SetTitle()">
    <form id="form1" runat="server" dir="rtl">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <div style="height: 20px; background-color: #2889E4; padding-right: 10px; 
        vertical-align: top">
        <asp:Label ID="lblAddClinic" runat="server" CssClass="LabelBoldWhite_18" EnableTheming="false">בחירת יחידות</asp:Label>
    </div>
    <div>
        <table style="margin-top: 10px; margin-right: 5px" border="0">
            <tr>
                <td>
                    <asp:Label ID="lblDept" runat="server" EnableTheming="false" CssClass="RegularLabel" Text="שם יחידה"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDeptName" Width="200px" runat="server" CssClass="TextBoxRegular"></asp:TextBox>
                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acDeptName" TargetControlID="txtDeptName"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetClinicByName_DistrictDepended"
                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                        CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="SelectDept" />
                </td>
                <td style="padding-right: 15px">
                    <asp:Label ID="Label1" runat="server" CssClass="RegularLabel">סוג יחידה</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtUnitType" Width="200px" runat="server" CssClass="TextBoxRegular" Visible="true"></asp:TextBox>
                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtUnitType"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getUnitTypesByName"
                        MinimumPrefixLength="1" CompletionInterval="800" CompletionListItemCssClass="CompletionListItemStyle"
                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="true"
                        CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="SelectUnitType" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblDistrict" runat="server" CssClass="RegularLabel">מחוז</asp:Label>
                </td>
                <td>
                    <asp:DropDownList ID="ddlDistrict" runat="server" Width="203px" AutoPostBack="true" 
                      OnSelectedIndexChanged="ddlDistricts_selectedIndexChanged">
                    </asp:DropDownList>
                </td>
                <td style="padding-right: 15px">
                    <asp:Label ID="lblDeptCode" runat="server" CssClass="RegularLabel">קוד סימול</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDeptCode" Width="200px" runat="server" CssClass="TextBoxRegular"></asp:TextBox>
                    <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="txtDeptCode" Type="Integer" Operator="GreaterThan" ValueToCompare="0" ErrorMessage="*" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblCity" runat="server" CssClass="RegularLabel">ישוב</asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtCityName" Width="200px" runat="server" CssClass="TextBoxRegular"></asp:TextBox>
                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acCities" TargetControlID="txtCityName"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetCitiesAndDistricts"
                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="true"
                        OnClientItemSelected="SelectCity" CompletionListCssClass="CopmletionListStyle" />
                </td>
                <td colspan="2" align="left" style="padding-left:10px">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="buttonRightCorner">&nbsp;</td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">
                                <asp:Button ID="btnSearch" runat="server" OnClick="BtnSearch_OnClick" Text="חיפוש"
                                    CssClass="RegularUpdateButton" />
                            </td>
                            <td class="buttonLeftCorner">&nbsp;&nbsp;&nbsp;&nbsp;</td>
                            <td class="buttonRightCorner">&nbsp;</td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">
                                <asp:Button ID="btnClear" runat="server" Text="ניקוי" CssClass="RegularUpdateButton"
                                    OnClick="btnClear_OnClick" CausesValidation="false" />
                            </td>
                            <td class="buttonLeftCorner">&nbsp;</td>
                            <td class="buttonRightCorner">&nbsp;</td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">
                                <asp:Button ID="btnCancel" runat="server" Text="ביטול" CssClass="RegularUpdateButton"/>
                            </td>
                            <td class="buttonLeftCorner">&nbsp;</td>

                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td colspan="4"><asp:TextBox ID="txtSelectedDeptCodes" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox></td></tr>
        </table>
        <asp:Panel ID="pnlResults" runat="server" Visible="false">
            <table style="background-color: #F7FAFF; margin-top: 20px"  width="548px">
                <tr>
                    <td id="tdCbHeader" runat="server" style="width: 20px">&nbsp;</td>
                    <td style="width: 248px; padding-right: 20px;">
                        <asp:ImageButton ID="btnClinicName" runat="server" ImageUrl="~/Images/Applic/searchResultGrid_btnUnitNameTwoArr.jpg" />
                    </td>
                    <td style="width: 130px">
                        <asp:ImageButton ID="btnAddress" runat="server" ImageUrl="~/Images/Applic/searchResultGrid_btnAddressTwoArr.jpg" />
                    </td>
                    <td style="width: 113px">
                        <asp:ImageButton ID="btnCity" runat="server" ImageUrl="~/Images/Applic/searchResultGrid_btnCityTwoArr.jpg" />
                    </td>
                </tr>
            </table>
            <div id="Div1" runat="server" style="overflow-y: scroll; height: 300px; direction: ltr; width: 548px;">
                <asp:GridView ID="gvDepts" runat="server" ShowHeader="false" Width="530px" dir="rtl"
                    AutoGenerateColumns="false" SkinID="GridViewForSearchResults" 
                    onrowdatabound="gvDepts_RowDataBound">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <input type="checkbox" name='<%# Eval("DeptCode")%>'  />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <div style="padding-top: 4px; padding-bottom: 4px; padding-right: 5px">
                                    <asp:LinkButton ID="lnkDeptName" runat="server" Width="250px"  
                                        EnableTheming="false" Text='<%# Eval("DeptName")%>' ></asp:LinkButton>                                   
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>                       
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Label ID="lblDeptStreet" runat="server" Width="130px" Text='<%# Eval("StreetName")  %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Label ID="lblDeptCity" runat="server" Width="110px" Text='<%# Eval("CityName")  %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
            <div id="divBtnSelect" runat="server" style="width: 548px;">
                <table cellpadding="0" cellspacing="0" style="width:100%" >
                    <tr>
                        <td style="width:100%; padding-top:10px" align="left">
                            <table cellpadding="0" cellspacing="0" >
                                <tr>
                                    <td class="buttonRightCorner">&nbsp;</td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnSelect" runat="server" Text="הוספה" CssClass="RegularUpdateButton" />
                                    </td>
                                    <td class="buttonLeftCorner">&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
       </asp:Panel>
        <div style="padding-top: 20px; padding-right: 10px">
            <asp:Label ID="lblNoResults" runat="server" Visible="false">אין תוצאות לחיפוש המבוקש</asp:Label>
        </div>
        <table width="100%">
            <tr>
                <td align="right" style="width:100%; padding-right:10px; padding-top:30px">
                    <div class="RegularLabel" id="divExplanationForUser" runat="server" visible="false" style="width: 500px; border: solid 1px #bcd9ee; background-color: #f6f6f6; padding: 10px 10px 10px 10px" >
                    באפשרותך לבחור יחידות נוספות (כמו: מוקדי חירום, בתי מרקחת וכו') להצגת פרטיהם בדף ההדפסה ללקוח.
                    <br />יש לאתר את המרפאות באמצעות שדות הבחירה, לסמן אותן וללחוץ על הוספה.
                    <br />אם אין ברצונך להציג יחידות נוספות, אלא להדפיס מידע על המרפאה בלבד, לחץ על המשך.
                    </div>
                </td>
            </tr>
        </table>
        <asp:HiddenField ID="hdnSelectedUnitTypeCode" runat="server" />
        <asp:HiddenField ID="hdnSelectedCityCode" runat="server" />
        <asp:HiddenField ID="hdnSelectedDeptCode" runat="server" />
    </div>
    </form>
    <script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
