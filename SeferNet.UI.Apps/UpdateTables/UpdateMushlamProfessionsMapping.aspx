<%@ Page Title="עדכון טבלת קשר למושלם" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master"
    AutoEventWireup="true"
    Inherits="Admin_UpdateMushlamProfessionsMapping" EnableEventValidation="false" Codebehind="UpdateMushlamProfessionsMapping.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="~/UserControls/SortableColumnHeader.ascx" TagName="SortableColumn" TagPrefix="uc1"  %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <script language="javascript" type="text/javascript">

        function getSelectedServiceCode(source, eventArgs) {            
            document.getElementById('<%= hdnServiceCode.ClientID %>').value = eventArgs.get_value();
        }

        function SaveScrollPosition(obj) {
            document.getElementById('<%= hdnScroll.ClientID %>').value = obj.scrollTop;
        }

        function clearSearchFeilds() {
            $("#<%=txtSeferServiceName.ClientID %>").val("");
            $("#<%=txtMushlamServiceName.ClientID %>").val("");
        }

        function openNewMappingWindow(resetWindow) {
            if (resetWindow) {
                resetAddNewWindow();
                $("#<%=ddlNewTable.ClientID %>").removeAttr("disabled");
                $(".divUpdate").css("display","none");
                $(".divAdd").css("display", "inline");
                
            }
            else {
                $(".divUpdate").css("display","inline");
                $(".divAdd").css("display","none");
            }
                
            OpenLoginJQueryDialogInside(350, 250, "");
        }

        function resetAddNewWindow() {
            var ddl = $("#<%=ddlNewTable.ClientID %>").children("option");
            $.each(ddl, function () {
                if (this.value == "-1")
                    this.selected = "selected";
            });

            $("#<%=hdnMushlamServiceCode.ClientID %>").val("");
            $("#<%=ddlTreatmentTypes.ClientID %>").val("");
            $("#<%=txtNewMushlamParentCode.ClientID %>").val("");
            
            $("#<%=hdnNewMushlamParentCode.ClientID %>").val("");

            $("#<%=txtNewMushlamSubSpecialityCode.ClientID %>").val("");
            $("#<%=txtNewMushlamSubSpecialityParent.ClientID %>").val("");
            $("#<%=txtNewSeferCode_Speciality.ClientID %>").val("");
            $("#<%=txtNewSeferCode_NewService.ClientID %>").val("");


            $("#<%=hdnMappingType.ClientID %>").val("");

            $("#<%=txtNewGroupCode.ClientID %>").val("");
            $("#<%=hdnNewGroupCode.ClientID %>").val("");
            $("#<%=txtNewSubGroupCode.ClientID %>").val("");
            $("#<%=hdnNewSubGroupCode.ClientID %>").val("");

            $("#<%=txtNewMushlamSpecialityCode.ClientID %>").val("");
            $("#<%=hdnNewMushlamSpecialityCode.ClientID %>").val("");
            $("#<%=txtNewSeferCode_SubSpeciality.ClientID %>").val("");
            
            hideAllTables();
        }

        function setNewWindowParams(tableID, rowID, mushlamServiceCode, subGroupCode, parentCode, seferServiceCode) {
            switch (tableID) {
                case "15":
                    setDropDownSelectedValue("<%=ddlTreatmentTypes.ClientID %>", mushlamServiceCode);
                    $("#<%=txtNewMushlamParentCode.ClientID %>").val(parentCode);
                    $("#<%=txtNewSeferCode_Treatment.ClientID %>").val(seferServiceCode);
                    $("#<%=hdnServiceCode.ClientID %>").val(seferServiceCode);
                    break;
                case "17":
                    $("#<%=txtNewMushlamSubSpecialityCode.ClientID %>").val(subGroupCode);
                    $("#<%=txtNewMushlamSubSpecialityParent.ClientID %>").val(parentCode);
                    $("#<%=txtNewSeferCode_SubSpeciality.ClientID %>").val(seferServiceCode);
                    $("#<%=hdnServiceCode.ClientID %>").val(seferServiceCode);
                    break;
                case "18":
                    $("#<%=txtNewGroupCode.ClientID %>").val(mushlamServiceCode);
                    $("#<%=txtNewSubGroupCode.ClientID %>").val(subGroupCode);
                    $("#<%=txtNewSeferCode_NewService.ClientID %>").val(seferServiceCode);
                    $("#<%=hdnServiceCode.ClientID %>").val(seferServiceCode);
                    break;
                case "51":
                    $("#<%=txtNewMushlamSpecialityCode.ClientID %>").val(mushlamServiceCode);
                    $("#<%=txtNewSeferCode_Speciality.ClientID %>").val(seferServiceCode);
                    $("#<%=hdnServiceCode.ClientID %>").val(seferServiceCode);
                    break;
            }
            
            $("#<%=hdnID.ClientID %>").val(rowID);

            setDropDownSelectedValue("<%=ddlNewTable.ClientID %>", tableID);
            $("#<%=ddlNewTable.ClientID %>").attr('disabled', 'disabled');
            showSelectedTable(tableID);
            openNewMappingWindow(false);
        }

        function setDropDownSelectedValue(dropDownID, val) {
            var dropDownObj = $("#" + dropDownID).children("option");
            $.each(dropDownObj, function () {
                if (this.value == val)
                    this.selected = "selected";

            });
        }
        
        function mappMushlamToSefer(btnID, mappingType) {

            var mapID = $("#<%=ddlNewTable.ClientID %>").val();
            $("#<%=hdnTableCode.ClientID %>").val(mapID);
            
            switch (mapID) {
                case "15":
                    var treatmentType = $("#<%=ddlTreatmentTypes.ClientID %>").val();
                    var newMushlamParentCode = $("#<%=txtNewMushlamParentCode.ClientID %>").val();
                    $("#<%=hdnMushlamServiceCode.ClientID %>").val(treatmentType);
                    $("#<%=hdnNewMushlamParentCode.ClientID %>").val(newMushlamParentCode);
                    break;
                case "17":
                    var subSpeciality = $("#<%=txtNewMushlamSubSpecialityCode.ClientID %>").val();
                    var specialityCodeForSub = $("#<%=txtNewMushlamSubSpecialityParent.ClientID %>").val();
                    $("#<%=hdnMushlamServiceCode.ClientID %>").val(subSpeciality);
                    $("#<%=hdnNewMushlamParentCode.ClientID %>").val(specialityCodeForSub);
                    break;
                case "18":
                    var group = $("#<%=txtNewGroupCode.ClientID %>").val();
                    $("#<%=hdnNewGroupCode.ClientID %>").val(group);
                    var subGroup = $("#<%=txtNewSubGroupCode.ClientID %>").val();
                    $("#<%=hdnNewSubGroupCode.ClientID %>").val(subGroup);
                    break; 
                case "51":
                    var speciality = $("#<%=txtNewMushlamSpecialityCode.ClientID %>").val();
                    $("#<%=hdnMushlamServiceCode.ClientID %>").val(speciality);
                    break;
            }
            
            $("#<%=hdnMappingType.ClientID %>").val(mappingType);

            doPostBack(btnID);
        }

        function doPostBack(btnID) {
            setTimeout('__doPostBack(\'' + btnID + '\',\'\')', 0);
        }

        function showSelectedTable(val) {
            hideAllTables();
            switch (val) {
                case "15":
                    $("#tblNewTreatment").show();
                    break;
                case "17":
                    $("#tblNewSubSpeciality").show();
                    break;
                case "18":
                    $("#tblNewService").show();
                    break;
                case "51":
                    $("#tblNewSpeciality").show();
                    break;
            }

            
            
        }

        function hideAllTables() {
            $("#tblNewService").hide();
            $("#tblNewTreatment").hide();
            $("#tblNewSubSpeciality").hide();
            $("#tblNewSpeciality").hide();
        }

    </script>
    
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="postBackContent" runat="Server">

    <table cellpadding="0" cellspacing="0" border="0" style="margin-top:5px;background-color: #F7F7F7">
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
                &nbsp;
            </td>
            <td align="right">
                        
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Label runat="server" Text="טבלה"></asp:Label>
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlSearchTableNumber" runat="server"></asp:DropDownList>
                        </td>
                        <td style="width:20px;"></td>
                        <td style="width:90px;">
                            <asp:Label runat="server" Text="שם שירות בספר"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtSeferServiceName" runat="server" Width="151px"></asp:TextBox>
                        </td>
                        <td style="width:20px;"></td>
                        <td style="width:105px;">
                            <asp:Label runat="server" Text="שם שירות במושלם"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtMushlamServiceName" runat="server" Width="151px"></asp:TextBox>
                        </td>
                        <td style="width:15px;"></td>
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
                                    <td style="width:88px;"></td>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <input type="button" style="width:70px;" value="הוספה"
                                            class="RegularUpdateButton"  onclick="openNewMappingWindow(true);" />
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
        <tr style="height: 8px">
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
    <br/>
    <table id="tblRes" runat="server" cellpadding="0" cellspacing="0" border="0"
        style="display:none;background-color: #F7F7F7;margin-top:10px;"> 
        <tr>
            <td style="width:8px;height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
            <div id="divHeaders" runat="server">
                <table cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td style="width:60px">
                        <uc1:SortableColumn ID="columnTableNumber" runat="server" 
                        Text="מספר טבלה" Width="30px" ColumnIdentifier="MushlamTableCode" OnSortClick="columnSort_clicked" />
                    </td>
                    <td style="width:70px">
                        <uc1:SortableColumn ID="SortableColumn1" runat="server" 
                        Text="שם טבלה" Width="30px" ColumnIdentifier="TableName" OnSortClick="columnSort_clicked" />
                    </td>
                    <td style="width:100px">
                        <uc1:SortableColumn ID="colMushlamServiceCode" runat="server" 
                        Text="קוד התמחות/<br />טיפול/קבוצה" ColumnIdentifier="MushlamCode" OnSortClick="columnSort_clicked"/>
                    </td>
                    <td style="width:110px">
                        <uc1:SortableColumn ID="SortableColumn4" runat="server" 
                        Text="קוד תת<br /> התמחות/קבוצה" ColumnIdentifier="SubCode" OnSortClick="columnSort_clicked"/>
                    </td>
                    <td style="width:130px">
                        <uc1:SortableColumn ID="colParentCode" runat="server" 
                        Text="תיאור מושלם" ColumnIdentifier="MushlamDescription" OnSortClick="columnSort_clicked"/>
                    </td>
                    <td style="width:60px">
                        <uc1:SortableColumn ID="colSeferServiceCode" runat="server" 
                        Text="קוד אב" Width="20px" ColumnIdentifier="ParentCode" OnSortClick="columnSort_clicked"  />
                    </td>
                    <td style="width:100px">
                        <uc1:SortableColumn ID="SortableColumn5" runat="server" 
                        Text="תיאור קוד אב" Width="40px" ColumnIdentifier="ParentDescription" OnSortClick="columnSort_clicked"  />
                    </td>
                    <td style="width:70px">
                        <uc1:SortableColumn ID="SortableColumn2" runat="server" 
                        Text="קוד ספר<br /> שירות" ColumnIdentifier="SeferServiceCode" OnSortClick="columnSort_clicked"  />
                    </td>
                    <td style="width:149px">
                        <uc1:SortableColumn ID="SortableColumn3" runat="server" 
                        Text="תיאור ספר שירות" Width="110px" ColumnIdentifier="SeferServiceDescription" OnSortClick="columnSort_clicked"  />
                    </td>
                </tr>
            </table>
            </div>
            <div id="divServices" style="height: 410px;width:995px; overflow-y:scroll; 
            direction: ltr; " onscroll="SaveScrollPosition(this);">
                <div style="direction:rtl;">
                    <asp:GridView ID="gvProfessions" runat="server" SkinID="GridViewForSearchResults" 
                RowStyle-CssClass="RegularLabel"
                EnableTheming="true"
                RowStyle-HorizontalAlign="Right"
                AutoGenerateColumns="false" 
                        ShowHeader="false" onrowdatabound="gvProfessions_RowDataBound" >
               <Columns>
                    
                    <asp:BoundField DataField="MushlamTableCode" ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Right" />
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:Label ID="lblID" runat="server" Text='<%# Eval("ID") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="TableName" ItemStyle-Width="100px" />

                    <asp:TemplateField ItemStyle-Width="75px">
                        <ItemTemplate>
                            <asp:Label ID="lblMushlamServiceCode" runat="server" Text='<%# Eval("MushlamCode")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-Width="110px">
                        <ItemTemplate>
                            <asp:Label ID="lblsubCode" runat="server" Text='<%# Eval("subCode")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="MushlamDescription" ItemStyle-Width="130px" />
                    
                    <asp:TemplateField ItemStyle-Width="60px">
                        <ItemTemplate>
                            <asp:Label ID="lblParentCode" runat="server" Text='<%# Eval("ParentCode")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="ParentDescription" ItemStyle-Width="100px" />
                    

                    <asp:TemplateField HeaderText="קוד בספר שירות" ItemStyle-Width="72px">
                        <ItemTemplate>
                            <asp:Label ID="lblSeferServiceCode" runat="server" Text='<%# Eval("SeferServiceCode")%>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSeferCode" 
                                ErrorMessage="שדה חובה" Text="*" Display="Dynamic" />
                            <asp:TextBox ID="txtSeferCode" runat="server" Width="50px" 
                                            Text='<%# Eval("SeferServiceCode") %>'></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>    
                    
                    <asp:BoundField DataField="SeferServiceDescription" ItemStyle-Width="170px" />                                    
                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Left">
                        <ItemTemplate>
                            <asp:ImageButton ID="ibEdit" runat="server" ImageUrl="~/Images/btn_edit.gif" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:ImageButton ID="btnDelete" runat="server"
                                ImageUrl="~/Images/Applic/btn_X_red.gif" OnClick="btnDelete_SubSpeciality_Click" 
                                CausesValidation="false" ToolTip="מחיקה" CommandArgument='<%# Eval("ID") + "_" + Eval("MushlamTableCode")%>' />
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
    <div id="dialog-modal-inside" title="Modal Dialog Title" style="display:none; overflow: hidden;">  
    <div id="divNewMapping">
        <div style="text-align:right;direction:rtl;">
            <div id="divSelectTable" style="margin-bottom:15px;float:right;">
                <span class="RegularLabel">טבלה:</span>
                <asp:DropDownList ID="ddlNewTable" AutoPostBack="false" runat="server"
                onchange="showSelectedTable(this.value);"></asp:DropDownList>
                
            </div>
            <div style="float:left;margin-left:15px;">
                <table style="float:left;" cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="buttonRightCorner">
                            &nbsp;
                        </td>
                        <td class="buttonCenterBackground">
                            <input type="button" value="ביטול" class="RegularUpdateButton"
                                onclick="SelectJQueryClose();" />
                        </td>
                        <td class="buttonLeftCorner">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </div>

            <!-- שירותי מושלם -->
            <table style="display:none;" id="tblNewService" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label5" runat="server">קוד קבוצה:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewGroupCode" runat="server"></asp:TextBox>                   
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" 
                    ControlToValidate="txtNewGroupCode" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="NewService" />
                    <asp:CompareValidator ID="CompareValidator4" runat="server" ValidationGroup="NewService" Operator="DataTypeCheck"
                    Type="Integer" ControlToValidate="txtNewGroupCode" Display="Dynamic"
                    ErrorMessage="שדה מספרי"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label6" runat="server">קוד תת קבוצה:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewSubGroupCode" runat="server"></asp:TextBox>                   
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" 
                    ControlToValidate="txtNewSubGroupCode" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="NewService" />
                    <asp:CompareValidator ID="CompareValidator5" runat="server" ValidationGroup="NewService" Operator="DataTypeCheck"
                    Type="Integer" ControlToValidate="txtNewSubGroupCode" Display="Dynamic"
                    ErrorMessage="שדה מספרי"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label9" runat="server">קוד בספר שירות:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewSeferCode_NewService" runat="server"></asp:TextBox>                   
                    <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender3" runat="server" 
                        TargetControlID="txtNewSeferCode_NewService"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                        ServiceMethod="GetAllServices"
                        MinimumPrefixLength="2" CompletionInterval="500"                                                        
                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="true" 
                        CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" 
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" 
                        Enabled="True" CompletionListCssClass="CopmletionListStyle"
                        OnClientItemSelected="getSelectedServiceCode"/>
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator10"  runat="server" 
                    ControlToValidate="txtNewSeferCode_NewService" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="NewService" />
                    
                </td>
            </tr>
            <tr>
                <td colspan="3" style="text-align:left;padding-top: 10px;padding-left:18px">
                    <div class="divAdd" style="float:left;">
                        <asp:ImageButton ID="btnAddNew_NewService" ImageUrl="~/Images/btn_add.gif" CausesValidation="true"
                            runat="server" OnClientClick="mappMushlamToSefer('btnAddNew_NewService','add');" ValidationGroup="NewService" />
                    </div>
                    <div class="divUpdate" style="float:left;">
                        <asp:ImageButton ID="btnEdit_NewService" ImageUrl="~/Images/btn_edit.gif" CausesValidation="true"
                            runat="server" OnClientClick="mappMushlamToSefer('btnEdit_NewService','edit');" ValidationGroup="NewService" />
                    </div>
                </td>
            </tr>

        </table>
        
            <!-- סוג טיפול -->
            <table style="display:none;" id="tblNewTreatment" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <span class="RegularLabel">סוג טיפול:</span>
                </td>
                <td>
                    <asp:DropDownList ID="ddlTreatmentTypes" runat="server"></asp:DropDownList>
                </td>
                
            </tr>
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label4" runat="server">קוד אב:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewMushlamParentCode" runat="server"></asp:TextBox>                   
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" 
                    ControlToValidate="txtNewMushlamParentCode" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="Treatment" />
                    <asp:CompareValidator ID="CompareValidator3" runat="server" ValidationGroup="Treatment" Operator="DataTypeCheck"
                    Type="Integer" ControlToValidate="txtNewMushlamParentCode" Display="Dynamic"
                    ErrorMessage="שדה מספרי"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label8" runat="server">קוד בספר שירות:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewSeferCode_Treatment" runat="server"></asp:TextBox>                   
                    <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender2" runat="server" 
                        TargetControlID="txtNewSeferCode_Treatment"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                        ServiceMethod="GetAllServices"
                        MinimumPrefixLength="2" CompletionInterval="500"                                                        
                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="true" 
                        CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" 
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" 
                        Enabled="True" CompletionListCssClass="CopmletionListStyle"
                        OnClientItemSelected="getSelectedServiceCode"/>
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator9"  runat="server" 
                    ControlToValidate="txtNewSeferCode_Treatment" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="Treatment" />
                    
                </td>
            </tr>
            <tr>
                <td colspan="3" style="text-align:left;padding-top: 10px;padding-left:18px">
                    <div class="divAdd" style="float:left;">
                        <asp:ImageButton ID="btnAddNew_Treatment" ImageUrl="~/Images/btn_add.gif" CausesValidation="true"
                            runat="server" OnClientClick="mappMushlamToSefer('btnAddNew_Treatment','add');" ValidationGroup="Treatment" />
                    </div>
                    <div class="divUpdate" style="float:left;">
                        <asp:ImageButton ID="btnEdit_Treatment" ImageUrl="~/Images/btn_edit.gif" CausesValidation="true"
                            runat="server" OnClientClick="mappMushlamToSefer('btnEdit_Treatment','edit');" ValidationGroup="Treatment" />
                    </div>
                </td>
            </tr>
        </table>
        
            <!-- תת התמחות -->
            <table style="display:none;" id="tblNewSubSpeciality" cellpadding="0" cellspacing="0">
            
            <tr>
                
                <td style="width:104px;">
                    <asp:Label ID="Label2" runat="server">קוד תת התמחות:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewMushlamSubSpecialityCode" runat="server"></asp:TextBox>                   
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" 
                    ControlToValidate="txtNewMushlamSubSpecialityCode" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="SubSpeciality" />
                    <asp:CompareValidator ID="CompareValidator2" runat="server" ValidationGroup="SubSpeciality" Operator="DataTypeCheck"
                    Type="Integer" ControlToValidate="txtNewMushlamSubSpecialityCode" Display="Dynamic"
                    ErrorMessage="שדה מספרי"></asp:CompareValidator>
                </td>
            </tr>
            <tr>
                
                <td style="width:104px;">
                    <asp:Label ID="Label1" runat="server">קוד אב:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewMushlamSubSpecialityParent" runat="server"></asp:TextBox>                   
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" 
                    ControlToValidate="txtNewMushlamSubSpecialityParent" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="SubSpeciality" />
                    <asp:CompareValidator ID="CompareValidator1" runat="server" ValidationGroup="SubSpeciality" Operator="DataTypeCheck"
                    Type="Integer" ControlToValidate="txtNewMushlamSubSpecialityParent" Display="Dynamic"
                    ErrorMessage="שדה מספרי"></asp:CompareValidator>
                </td>
                
            </tr>
            <tr>
                <td style="width:104px;">
                    
                    <asp:Label ID="Label7" runat="server">קוד בספר שירות:</asp:Label>
                </td>
                <td>
                    <asp:TextBox Width="167px" ID="txtNewSeferCode_SubSpeciality" runat="server"></asp:TextBox>                   
                    <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" 
                        TargetControlID="txtNewSeferCode_SubSpeciality"
                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                        ServiceMethod="GetAllServices"
                        MinimumPrefixLength="2" CompletionInterval="500"                                                        
                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="true" 
                        CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" 
                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" 
                        Enabled="True" CompletionListCssClass="CopmletionListStyle"
                        OnClientItemSelected="getSelectedServiceCode"/>
                </td>
                <td style="width:15px;">
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator8"  runat="server" 
                    ControlToValidate="txtNewSeferCode_SubSpeciality" Display="Dynamic"
                    ErrorMessage="שדה חובה" ValidationGroup="SubSpeciality" />
                    
                </td>
            </tr>
            <tr>
                <td colspan="3" style="text-align:left;padding-top: 10px;padding-left:18px">
                    <div class="divAdd" style="float:left;">
                        <asp:ImageButton ID="btnAddNew_SubSpeciality" ImageUrl="~/Images/btn_add.gif" CausesValidation="true"
                            runat="server" OnClientClick="mappMushlamToSefer('btnAddNew_SubSpeciality','add');" ValidationGroup="SubSpeciality" />
                    </div>
                    <div class="divUpdate" style="float:left;">
                        <asp:ImageButton ID="btnEdit_SubSpeciality" ImageUrl="~/Images/btn_edit.gif" CausesValidation="true"
                            runat="server" 
                            OnClientClick="mappMushlamToSefer('btnEdit_SubSpeciality','edit');" 
                            ValidationGroup="SubSpeciality" />
                    </div>
                </td>
            </tr>
        </table>
        
            <!-- התמחות -->
            <table style="display:none;" id="tblNewSpeciality" cellpadding="0" cellspacing="0">
                <tr>
                    <td style="width:104px;">
                        <asp:Label runat="server">קוד התמחות רופא:</asp:Label>
                    </td>
                    <td>
                        <asp:TextBox Width="167px" ID="txtNewMushlamSpecialityCode" runat="server"></asp:TextBox>                   
                    </td>
                    <td style="width:15px;">
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" 
                        ControlToValidate="txtNewMushlamSpecialityCode" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="Speciality" />
                        <asp:CompareValidator ID="CompareValidator6" runat="server" ValidationGroup="Speciality" Operator="DataTypeCheck"
                        Type="Integer" ControlToValidate="txtNewMushlamSpecialityCode" Display="Dynamic"
                        ErrorMessage="שדה מספרי"></asp:CompareValidator>
                    </td>
                </tr>
                <tr>
                    <td style="width:104px;">
                    
                        <asp:Label ID="Label3" runat="server">קוד בספר שירות:</asp:Label>
                    </td>
                    <td>
                       <asp:TextBox Width="167px" ID="txtNewSeferCode_Speciality" runat="server"></asp:TextBox>                   
                       <ajaxToolkit:AutoCompleteExtender ID="acService" runat="server" 
                            TargetControlID="txtNewSeferCode_Speciality"
                            ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                            ServiceMethod="GetAllServices"
                            MinimumPrefixLength="2" CompletionInterval="500"                                                        
                            CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="true" 
                            CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" 
                            EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" 
                            Enabled="True" CompletionListCssClass="CopmletionListStyle"
                            OnClientItemSelected="getSelectedServiceCode"/>
                    </td>
                    <td style="width:15px;">
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1"  runat="server" 
                        ControlToValidate="txtNewSeferCode_Speciality" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="Speciality" />
                    
                    </td>
                </tr>
                <tr>
                    <td colspan="3" style="text-align:left;padding-top: 10px;padding-left:18px;">
                        <div class="divAdd" style="float:left;">
                            <asp:ImageButton ID="btnAddNew_Speciality" ImageUrl="~/Images/btn_add.gif" CausesValidation="true"
                                runat="server" OnClientClick="mappMushlamToSefer('btnAddNew_Speciality','add');" ValidationGroup="Speciality" />
                        </div>
                        <div class="divUpdate" style="float:left;">
                            <asp:ImageButton ID="btnEdit_Speciality" ImageUrl="~/Images/btn_edit.gif" CausesValidation="true"
                                runat="server" OnClientClick="mappMushlamToSefer('btnEdit_Speciality','edit');" ValidationGroup="Speciality" />
                        </div>
                    </td>
                </tr>
            </table>
        
            
        </div>
    </div>
     </div>
    <asp:HiddenField ID="hdnTableCode" runat="server" />
    <asp:HiddenField ID="hdnServiceCode" runat="server" />
    <asp:HiddenField ID="hdnScroll" runat="server" />
    <asp:HiddenField ID="hdnNewMushlamSpecialityCode" runat="server" />
    
    
    <asp:HiddenField ID="hdnID" runat="server" />
    <asp:HiddenField ID="hdnNewMushlamParentCode" runat="server" />
    <asp:HiddenField ID="hdnNewGroupCode" runat="server" />
    <asp:HiddenField ID="hdnNewSubGroupCode" runat="server" />
    <asp:HiddenField ID="hdnMappingType" runat="server" />
    <asp:HiddenField ID="hdnMushlamServiceCode" runat="server" />

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
</asp:Content>
