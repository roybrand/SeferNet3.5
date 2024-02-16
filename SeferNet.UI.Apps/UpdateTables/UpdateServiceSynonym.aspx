<%@ Page Title="עדכון מילים נרדפות לשירותים" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master"
    AutoEventWireup="true" Inherits="Admin_UpdateServiceSynonym" Codebehind="UpdateServiceSynonym.aspx.cs" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>


<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    
    <link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />
    
    <script type="text/javascript">



        function ServiceSelected(source, eventArgs) {
            val = eventArgs._value;
            code = val.substring(0, val.indexOf(','));
            document.getElementById('<%=txtNewServiceCode.ClientID %>').value = code;
            $("#<%=txtNewCategory.ClientID %>").val("");
            $("#<%= hdnSelectedNewServiceCategory.ClientID %>").val("");
        }

        function txtServiceNameChanged() {
            document.getElementById('<%=txtNewServiceCode.ClientID %>').value = '';
        }

        function ClearAddSection() {
            document.getElementById('<%= txtNewServiceCode.ClientID %>').value = '';
            document.getElementById('<%= txtNewServiceName.ClientID %>').value = '';
            document.getElementById('<%= txtNewSynonym.ClientID %>').value = '';
            $("#<%=txtNewCategory.ClientID %>").val("");
            $("#<%= hdnSelectedNewServiceCategory.ClientID %>").val("");
        }

        function clearSearchFeilds() {
            $("#<%=txtServiceCode.ClientID %>").val("");
            $("#<%=txtSynonymWord.ClientID %>").val("");
            $("#<%=txtServiceName.ClientID %>").val("");
            $("#<%=txtServiceCategory.ClientID %>").val("");
            $("#<%=hdnSelectedServiceCategory.ClientID %>").val("");

        }

        function checkIfValid(source, arguments) {

            if ($("#<%= hdnSelectedNewServiceCategory.ClientID %>").val() != "") {
                arguments.IsValid = true;
            } else {
                var reg = /^\s*(\+)?\d+\s*$/;
                if (reg.test(arguments.Value))
                    arguments.IsValid = true;
                else
                    arguments.IsValid = false;
            }

        }

        function SaveSelectedCategory(source, eventArgs) {
            document.getElementById('<%= hdnSelectedServiceCategory.ClientID %>').value = eventArgs.get_value();
        }

        function SaveNewSelectedCategory(source, eventArgs) {
            document.getElementById('<%= hdnSelectedNewServiceCategory.ClientID %>').value = eventArgs.get_value();
        }

        function openCategories() {
            var url = "../Public/SelectPopUp.aspx";
            url += "?popupType=12";
            url += "&returnValuesTo=hdnSelectedNewServiceCategory";
            url += "&returnTextTo=txtNewCategory";
            url += "&functionToExecute=CleartNewServiceCodeAndNewServiceName";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר שירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function CleartNewServiceCodeAndNewServiceName() {
            $("#<%=txtNewServiceCode.ClientID %>").val("");
            $("#<%=txtNewServiceName.ClientID %>").val("");
        }

        function doPostBack() {
            var syn = $("#<%=txtNewSynonym.ClientID %>").val();
            $("#<%=hdNewSynonym.ClientID %>").val(syn);

            var serCode = $("#<%=txtNewServiceCode.ClientID %>").val();
            $("#<%=hdNewServiceCode.ClientID %>").val(serCode);

            setTimeout('__doPostBack(\'btnAddServiceCategory\',\'\')', 0);
        }

        
    </script>
<style type="text/css">
    .mrgTop
    {
        margin-top:2px;    
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">
    
    <div>
        <div style="margin-top: 5px; margin-right: 10px;">
            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                <tr>
                    <td style="padding:0;height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                        background-repeat: no-repeat; background-position: top right">
                    </td>
                    <td style="padding:0;background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                        background-position: top">
                    </td>
                    <td style="padding:0;background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                        background-position: top left">
                    </td>
                </tr>
                <tr>
                    <td style="border-right: solid 2px #909090;">
                        &nbsp;
                    </td>
                    <td align="right">
                        <div style="width: 960px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <asp:Label ID="Label1" runat="server" Text="קוד שירות"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtServiceCode" runat="server" Width="60px"></asp:TextBox>
                                    </td>
                                    <td style="width:10px;"></td>
                                    <td>
                                        <asp:Label ID="Label2" runat="server" Text="שם שירות"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtServiceName" runat="server" Width="110px"></asp:TextBox>
                                    </td>
                                    <td style="width:10px;"></td>
                                    <td>
                                        <asp:Label ID="Label3" runat="server" Text="מילה נרדפת"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtSynonymWord" runat="server" Width="110px"></asp:TextBox>
                                    </td>
                                    <td style="width:10px;"></td>
                                    <td>
                                        <asp:Label ID="Label4" runat="server" Text="קטגוריה"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtServiceCategory" runat="server" Width="140px"></asp:TextBox>
                                        <ajaxToolkit:AutoCompleteExtender ID="acServiceCategories" runat="server" TargetControlID="txtServiceCategory"
                                            ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAllServiceCategories"
                                            MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                            UseContextKey="true" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                            EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                            CompletionListCssClass="CopmletionListStyle" ContextKey="true" OnClientItemSelected="SaveSelectedCategory"  />
                                        
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
                                                    <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                        ValidationGroup="vgrSearch" OnClick="btnSearch_Click"></asp:Button>
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
                                                    <input type="button" value="ניקוי" class="RegularUpdateButton" onclick="clearSearchFeilds();" />
                                                    
                                                </td>
                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                    background-repeat: no-repeat;">
                                                    &nbsp;
                                                </td>
                                                <td style="width:40px;"></td>
                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                    background-position: bottom left;">
                                                    &nbsp;
                                                </td>
                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                    background-repeat: repeat-x; background-position: bottom;">
                                                    <input type="button" style="width:80px;" value="הוספת מילה"
                                                     class="RegularUpdateButton" onclick="OpenLoginJQueryDialogInside(380,260,'הוספת מילה');" />
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
        </div>
        
        <div id="divResults" visible="false" runat="server" style="margin-top: 20px; padding-right:10px">
            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                <tr>
                    <td style="width:8px;height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                        background-repeat: no-repeat; background-position: top right">
                    </td>
                    <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                        background-position: top">
                    </td>
                    <td style="width:8px;background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                        background-position: top left;">
                    </td>
                </tr>
                <tr>
                    <td style="border-right:2px solid #949494;">&nbsp;</td>
                    <td>
                    <div id="divHeaders" runat="server" style="margin-right: 20px;">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td style="width:118px;">
                                    <uc1:sortableColumn ID="ServiceCode" runat="server" Text="קוד שירות"
                                        ColumnIdentifier="ServiceCode" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:308px;">
                                    <uc1:sortableColumn ID="ServiceDescription" runat="server" Text="תיאור שירות"
                                        ColumnIdentifier="ServiceDescription" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:170px;">
                                    <uc1:sortableColumn ID="ServiceSynonym" runat="server" Text="מילה נרדפת"
                                        ColumnIdentifier="ServiceSynonym" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:330px;">
                                    <uc1:sortableColumn ID="ServiceCategoryDescription" runat="server" Text="קטגוריה"
                                        ColumnIdentifier="ServiceCategoryDescription" OnSortClick="btnSort_Click" />
                                </td>
                            </tr>
                        </table>
                        
                        
                        
                        
                        
                    </div>
                    <div style="direction: ltr; overflow-y:scroll;
                        height: 380px;">
                        <div style="direction: rtl; margin-right: 5px;">
                            <asp:GridView ID="gvServiceResults" runat="server" Style="margin-top: 3px; direction: rtl"
                                HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults" OnRowDeleting="gvServiceResults_OnRowDeleting"
                                AutoGenerateColumns="false" 
                                onrowupdating="gvServiceResults_RowUpdating"  >
                                <EmptyDataTemplate>
                                    
                                    <asp:Label ID="lblEmptyData" runat="server" Text="אי מידע" CssClass="RegularLabel"></asp:Label>
                                </EmptyDataTemplate>
                                <Columns>
                                    <asp:BoundField DataField="SynonymID" ItemStyle-CssClass="DisplayNone" />
                            
                                    <asp:TemplateField ItemStyle-Width="120px">
                                        <ItemTemplate>
                                            <asp:Label ID="Label2" runat="server" Text='<%# Eval("ServiceCode")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                            
                            
                                    <asp:TemplateField ItemStyle-Width="310px">
                                        <ItemTemplate>
                                            <asp:Label ID="Label4" runat="server" Text='<%# Eval("ServiceDescription")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                            
                            
                                    <asp:TemplateField ItemStyle-Width="170px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Eval("ServiceSynonym")%>'></asp:Label>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:TextBox ID="txtServiceSynonym" Width="130px" EnableTheming="false" runat="server" Text='<%# Eval("ServiceSynonym")%>'></asp:TextBox>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                            
                            
                                    <asp:TemplateField ItemStyle-Width="182px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Eval("ServiceCategoryDescription")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                            
                            
                                    <asp:TemplateField ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:ImageButton CssClass="mrgTop" ID="imgUpdate" CommandArgument='<%# Eval("SynonymID")%>' runat="server"
                                             CommandName="Update" OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif" CausesValidation="false" />
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgCancel" runat="server" CausesValidation="false"
                                                            OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif" />
                                                    </td>
                                                    <td style="width:10px;"></td>
                                                    <td style="vertical-align:middle;">
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgSave" runat="server" CausesValidation="true" CommandName="Update"
                                                            ImageUrl="~/Images/btn_approve.gif" ValidationGroup="ctrl" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </EditItemTemplate>
                                
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:ImageButton CssClass="mrgTop" ID="btnDelete" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                CausesValidation="false" ToolTip="מחיקה" CommandName="Delete" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                            
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                    </td>
                    <td style="border-left:2px solid #949494;">&nbsp;</td>
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
        </div>
    </div>
    <asp:HiddenField ID="hdnSelectedServiceCategory" runat="server" />
    <asp:HiddenField ID="hdnSelectedNewServiceCategory" runat="server" />
    <asp:HiddenField ID="hdNewSynonym" runat="server" />
    <asp:HiddenField ID="hdNewServiceCode" runat="server" />
        <div id="dialog-modal-inside" title="Modal Dialog Title" style="display:none; overflow: hidden;">            
           <div id="divAddNewSynonym">
            
                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7;
                        direction:rtl;text-align:right;">
                        <tr>
                            <td style="padding:0;height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top right">
                            </td>
                            <td style="padding:0;background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: top">
                            </td>
                            <td style="padding:0;background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: top left">
                            </td>
                        </tr>
                        <tr>
                            <td style="border-right: solid 2px #909090;">
                                &nbsp;
                            </td>
                            <td>
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="width: 117px">
                                            <asp:Label ID="Label6" runat="server">קוד שירות לקישור:</asp:Label>
                                        </td>
                                        <td style="width: 200px">
                                            <asp:TextBox ID="txtNewServiceCode" MaxLength="8" runat="server" Width="60px"></asp:TextBox>
                                            <asp:CustomValidator ValidateEmptyText="true" ID="cvNewServiceCode" runat="server" ControlToValidate="txtNewServiceCode"
                                                ClientValidationFunction="checkIfValid"></asp:CustomValidator>
                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height:5px;_height:0;"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label7" runat="server">שם שירות לקישור:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNewServiceName" runat="server" Width="190px" onchange="txtServiceNameChanged();"></asp:TextBox>
                                            <ajaxToolkit:AutoCompleteExtender ID="acServices" runat="server" TargetControlID="txtNewServiceName"
                                                ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetServicesByName"
                                                MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="ServiceSelected" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height:5px;"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label8" runat="server" Text="קטגוריה:"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNewCategory" runat="server" Width="167px" 
                                                TextMode="MultiLine" Height="20px"></asp:TextBox>
                                            <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtenderNewCategory" runat="server" TargetControlID="txtNewCategory"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAllServiceCategories"
                                                    MinimumPrefixLength="2" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="true" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyle" ContextKey="true" OnClientItemSelected="SaveNewSelectedCategory"  />
                                            <input type="button" onclick="openCategories();"
                                             style="cursor:pointer;background-color:transparent;width:21px;
                                                height:21px;border:none;background:url('../Images/Applic/icon_magnify.gif');" />
                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height:5px;"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label9" runat="server">מילה נרדפת לשירות:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtNewSynonym" runat="server" Width="190px"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="txtNewSynonym" Text="שדה חובה"></asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <table cellpadding="0" cellspacing="0" style="margin-top:10px;width:100%;">
                                                <tr>
                                                    <td>
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td class="buttonRightCorner">
                                                                    &nbsp;
                                                                </td>
                                                                <td class="buttonCenterBackground">
                                                                    <asp:Button ID="btnAddServiceCategory" runat="server" Text="קישור מילה" CssClass="RegularUpdateButton"
                                                                        OnClientClick="doPostBack();"></asp:Button>
                                                                </td>
                                                                <td class="buttonLeftCorner">
                                                                    &nbsp;
                                                                </td>        
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td>
                                                        <table cellpadding="0" cellspacing="0" style="float:left;margin-left:5px;">
                                                            <tr>
                                                                <td class="buttonRightCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonCenterBackground">
                                                                <asp:Button ID="btnClearAddSection" runat="server" Text="ניקוי" CssClass="RegularUpdateButton"
                                                                    Width="45px" OnClientClick="ClearAddSection(); return false;" CausesValidation="false"></asp:Button>
                                                            </td>
                                                            <td class="buttonLeftCorner">
                                                                &nbsp;
                                                            </td> 
                                            
                                                            <td class="buttonRightCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonCenterBackground">
                                                                <input type="button" value="ביטול" class="RegularUpdateButton"
                                                                    onclick="ClearAddSection();SelectJQueryClose();" style="width:45px;" />
                                                            </td>
                                                            <td class="buttonLeftCorner">
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
                            </td>
                            <td style="border-left: solid 2px #909090;">
                                &nbsp;
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
                </div>
        </div>

    <script type="text/javascript">
        function OpenLoginJQueryDialogInside(dialogWidth, dialogHeight, Title) {
            $('#dialog-modal-inside').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-inside').dialog("option", "width", dialogWidth);
            $('#dialog-modal-inside').dialog("option", "height", dialogHeight);
            $('#dialog-modal-inside').dialog("option", "title", Title);
            $('#dialog-modal-inside').dialog('open');

            return false;
        }
        function SelectJQueryClose() {
            $("#dialog-modal-inside").dialog('close');
            return false;
        }
    </script>
    <script type="text/javascript" src="../Scripts/srcScripts/Thickbox.js"></script>
</asp:Content>
