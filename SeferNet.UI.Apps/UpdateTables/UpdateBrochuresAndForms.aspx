<%@ Page Title="ניהול טפסים וחוברות" Language="C#" MasterPageFile="~/SeferMasterPage.master" 
AutoEventWireup="true" 
Inherits="UpdateTables_UpdateBrochuresAndForms" EnableEventValidation="false" Codebehind="UpdateBrochuresAndForms.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phHead" Runat="Server">
    <style type="text/css">
    ul li
    {
        float:right;
        background-color:#d7e4ed;            
        height:20px;
    }
    
    .divForm
    {
        float:right;
        margin-top:10px;    
    }
</style>
<script type="text/javascript">

    var hebCurrentActionDescription = "";

    function showFile(fileName) {
        var formsAndBrochuresPath = "<%=formsAndBrochuresPath %>";
        var filePath = "file:" + formsAndBrochuresPath + "\\" + fileName;
        window.open(filePath);
    }

    function newBrochure() {
        setManageType("insert",'הוסף');
        
        clearBrochuresFields();

        openBrochurePopup();
    }

    function newForm() {
        setManageType("insert", 'הוסף');
        
        clearFormFields();

        openFormPopup();
    }

    function openBrochurePopup() {
        setManageTable("brochures");
        ValidationGroupEnable('brochureFields', false);
        ValidationGroupEnable('formFields', false);

        $("#<%=btnAddNewBrochure.ClientID %>").val(hebCurrentActionDescription); 
        
        var tmpHref = "#TB_inline?inlineId=divNewBrochure&modal=true&height=190&width=365";
        $("#aTB_inline").attr("href", tmpHref);
        $("#aTB_inline").click();
        $("#TB_ajaxContent").css("padding-bottom", "5px");
    }

    
    function updateBrochure(selectedID, fileName, brochureDisplayName, langCode) {
        setManageType("update",'עדכן');
        $("#<%=hfSelectedID.ClientID %>").val(selectedID);
        $("#<%=txtNewBrochureFileName.ClientID %>").val(fileName);
        $("#<%=txtBrochureName.ClientID %>").val(brochureDisplayName);
        setSelectedLanguage(langCode);

        clearFileUpload("<%= fuNewBrochureFile.ClientID %>");
        
        openBrochurePopup();
    }

    function clearBrochuresFields() {
        $("#<%=txtNewBrochureFileName.ClientID %>").val("");
        $("#<%=txtBrochureName.ClientID %>").val("");
        setSelectedLanguage(18); //18 for Hebrew
        clearFileUpload("<%= fuNewBrochureFile.ClientID %>");
    }

    function clearFileUpload(fID) {
        var fu1 = $("#" + fID)[0];
        fu1.value = "";
        var fu2 = fu1.cloneNode(false);
        fu2.onchange = fu1.onchange;
        fu1.parentNode.replaceChild(fu2, fu1);
    }

    function setSelectedLanguage(langCode) {
        $("#<%=ddlLanguages.ClientID %>").val(langCode);
    }

    function updateForm(selectedID, fileName, formDisplayName) {
        setManageType("update", 'עדכן');
        
        $("#<%=hfSelectedID.ClientID %>").val(selectedID);
        $("#<%=txtNewFileName.ClientID %>").val(fileName);
        $("#<%=txtFormName.ClientID %>").val(formDisplayName);

        clearFileUpload("<%= fuNewFormFile.ClientID %>");

        openFormPopup();
    }

    function openFormPopup() {
        setManageTable("forms");
        ValidationGroupEnable('brochureFields', false);
        ValidationGroupEnable('formFields', false);

        $("#<%=btnAddNewForm.ClientID %>").val(hebCurrentActionDescription); 
        
        var tmpHref = "#TB_inline?inlineId=divNewForm&modal=true&height=156&width=355";
        $("#aTB_inline").attr("href", tmpHref);
        $("#aTB_inline").click();
        $("#TB_ajaxContent").css("padding-bottom", "5px");
    }

    
    function ValidationGroupEnable(validationGroupName, isEnable) {
        for (i = 0; i < Page_Validators.length; i++) {
            if (Page_Validators[i].validationGroup == validationGroupName) {
                ValidatorEnable(Page_Validators[i], isEnable);
            }
        }
    }

    

    function clearFormFields() {
        $("#<%=txtNewFileName.ClientID %>").val("");
        $("#<%=txtFormName.ClientID %>").val("");
        clearFileUpload("<%= fuNewFormFile.ClientID %>");
    }

    function deleteItem(selectedID, mTable) {
        setManageType("delete",'מחק');
        setManageTable(mTable);
        $("#<%=hfSelectedID.ClientID %>").val(selectedID);
    }

    function setManageTable(mTable) {
        $("#<%=hfManageTable.ClientID %>").val(mTable);
    }
    
    function setManageType(action, hebActionDescription) {
        $("#<%=hfAction.ClientID %>").val(action);
        hebCurrentActionDescription = hebActionDescription;
    }

    function doPostBack(btnID, validGroup) {
        ValidationGroupEnable(validGroup, true);
        Page_ClientValidate();
        if (Page_IsValid) {
            tb_remove();
            setTimeout('__doPostBack(\'' + btnID + '\',\'\')', 500);
        }
    }

</script>
<link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />    
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" Runat="Server">
    <div style="margin-top:5px;float:right;" class="roundFrame">
        <div class="rightCornerTop"></div>
        <div style="width:970px;" class="frameTop"></div>            
        <div class="leftCornerTop"></div>
    
    
        <div style="width:986px;float:right;" class="frameMiddle">
            <div style="float:right;margin-right:10px;">
                <asp:Label runat="server" Text="סוג"></asp:Label>
                <asp:DropDownList ID="ddlType" runat="server" AutoPostBack="true"
                    onselectedindexchanged="ddlType_SelectedIndexChanged">
                    <asp:ListItem Text="מושלם" Value="2"></asp:ListItem>
                    <asp:ListItem Text="קהילה" Value="1"></asp:ListItem>
                </asp:DropDownList>
            </div>

            
            
        </div>            
    
    
        <div class="rightCornerBottom"></div>
        <div style="width:970px;" class="frameBottom"></div>            
        <div class="leftCornerBottom"></div>
    </div>

    <div style="margin-top:10px;float:right;" class="roundFrame">
        <div class="rightCornerTop"></div>
        <div style="width:970px;" class="frameTop"></div>            
        <div class="leftCornerTop"></div>
    
    
        <div style="width:986px;float:right;" class="frameMiddle">
            <ul style="margin-right:30px;_margin-right:40px;list-style:none;">
                <li style="width:350px;">
                    <span class="LabelBoldBlack_13">שם חוברת</span>    
                </li>
                <li style="width:210px;">
                    <span class="LabelBoldBlack_13">שפה</span>    
                </li>
                <li style="width:300px;">
                    <span class="LabelBoldBlack_13">קובץ</span>    
                </li>
                <li>
                    <div style="margin-left:20px;_margin-left:0px;" class="button_LeftCornerFL"></div>
                    <div class="button_CenterBackgroundFL">
                        <input type="button" style="width:70px;" value="הוספה"
                            class="RegularUpdateButton"  onclick="newBrochure();" />
                    </div>
                    <div class="button_RightCornerFL"></div>
                </li>
            </ul>
            <div style="clear:both;float:right;margin-right:10px;margin-top:5px;
                overflow-y:scroll;overflow-x:hidden;direction:ltr;height:195px;">
                <div style="direction:rtl;margin-right:20px;">
                <asp:GridView ID="gvBrochures" runat="server" SkinID="GridViewForSearchResults" 
                    RowStyle-CssClass="RegularLabel" OnRowDataBound="gvBrochures_RowDataBound"
                    EnableTheming="true"
                    RowStyle-HorizontalAlign="Right"
                    AutoGenerateColumns="false" 
                            ShowHeader="false">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="350px">
                            <ItemTemplate>
                                <span style="text-decoration:underline;cursor:pointer;" onclick="showFile('<%# Eval("FileName")%>')" class="RegularLabel"><%# Eval("DisplayName")%></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:BoundField ItemStyle-Width="210px" DataField="displayDescription" />
                        <asp:BoundField ItemStyle-Width="300px" DataField="FileName" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <input type="button" onclick="updateBrochure('<%# Eval("BrochureID")%>','<%# Eval("FileName")%>','<%# Eval("DisplayName") %>','<%# Eval("languageCode") %>');" class="btnEdit" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:ImageButton ID="btnDelete" runat="server"
                                    ImageUrl="~/Images/Applic/btn_X_red.gif"  
                                    CausesValidation="false" ToolTip="מחיקה" CommandArgument='<%# Eval("BrochureID")%>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                </div>
            </div>
            
            <ul style="clear:right;margin-right:30px;_margin-right:40px;list-style:none;margin-bottom:0px;">
                <li style="width:352px;margin-top:20px;">
                    <span class="LabelBoldBlack_13">שם טופס</span>    
                </li>
                
                <li style="margin-top:20px;width:508px;">
                    <span class="LabelBoldBlack_13">קובץ</span>    
                </li>
                <li style="margin-top:20px;">
                    <div style="margin-left:20px;_margin-left:0px;" class="button_LeftCornerFL"></div>
                    <div class="button_CenterBackgroundFL">
                        <input type="button" style="width:70px;" value="הוספה"
                            class="RegularUpdateButton" onclick="newForm();" />
                    </div>
                    <div class="button_RightCornerFL"></div>
                </li>
            </ul>
            
            <div style="clear:both;float:right;margin-right:10px;height:195px;margin-top:5px;
                overflow-y:scroll;overflow-x:hidden;direction:ltr;">
                <div style="direction:rtl;margin-right:20px;">
                <asp:GridView ID="gvForms" runat="server" SkinID="GridViewForSearchResults" 
                    RowStyle-CssClass="RegularLabel"
                    EnableTheming="true"
                    RowStyle-HorizontalAlign="Right"
                    AutoGenerateColumns="false" 
                            ShowHeader="false" onrowdatabound="gvForms_RowDataBound">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="350px">
                            <ItemTemplate>
                                <span style="text-decoration:underline;cursor:pointer;" onclick="showFile('<%# Eval("FileName")%>')" class="RegularLabel"><%# Eval("FormDisplayName")%></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField ItemStyle-Width="510px" DataField="FileName" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <input type="button" onclick="updateForm('<%# Eval("FormID")%>','<%# Eval("FileName")%>','<%# Eval("FormDisplayName") %>');" class="btnEdit" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:ImageButton ID="btnDelete" runat="server"
                                    ImageUrl="~/Images/Applic/btn_X_red.gif" 
                                    CausesValidation="false" ToolTip="מחיקה" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                </div>
            </div>
            
        </div>          
    
    
        <div class="rightCornerBottom"></div>
        <div style="width:970px;" class="frameBottom"></div>            
        <div class="leftCornerBottom"></div>
    </div>
    <a id="aTB_inline" style="display:none;" href="" class="thickbox">Show hidden modal content.</a>
    
    
    <div style="display:none;" id="divNewForm">
        <div style="text-align:right;direction:rtl;">
            <div class="divForm" style="width:110px;">
                <span class="RegularLabel">בחר קובץ:</span>
            </div>
            <div class="divForm">
                <asp:FileUpload ID="fuNewFormFile" runat="server" />
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidator1"  runat="server" 
                        ControlToValidate="fuNewFormFile" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="formFields" />
            </div>
            <div class="divForm" style="width:110px;">
                <span class="RegularLabel">שם הטופס בתצוגה:</span>
            </div>
            <div class="divForm">
                <asp:TextBox ID="txtFormName" style="width:233px;" runat="server"></asp:TextBox>
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2"  runat="server" 
                        ControlToValidate="txtFormName" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="formFields" />
            </div>
            <div class="divForm" style="width:110px;">
                <span class="RegularLabel">שם הקובץ החדש:</span>
            </div>
            <div class="divForm">
                <asp:TextBox ID="txtNewFileName" style="width:233px;" runat="server"></asp:TextBox>
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidator3"  runat="server" 
                        ControlToValidate="txtNewFileName" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="formFields" />
            </div>
            <div style="clear:both;margin-top:20px;">
                <div class="button_LeftCornerFL" style="margin-left:10px;_margin-left:5px;"></div>
                <div class="button_CenterBackgroundFL">
                    <asp:Button ID="btnAddNewForm" runat="server" Text="הוספה" ValidationGroup="formFields"
                        class="RegularUpdateButton" Width="70px" 
                        OnClientClick="doPostBack('btnAddNewForm','formFields');" />
                </div>
                <div class="button_RightCornerFL"></div>

                <div class="button_RightCorner"></div>
                <div class="button_CenterBackground">
                    <input type="button" style="width:70px;" value="ביטול"
                        class="RegularUpdateButton" onclick="javascript:tb_remove();" />
                </div>
                <div style="margin-left:10px;_margin-left:0px;" class="button_LeftCorner"></div>
            </div>
        </div>
    </div>

    <div style="display:none;" id="divNewBrochure">
        <div style="text-align:right;direction:rtl;">
            <div class="divForm" style="width:120px;">
                <span class="RegularLabel">בחר קובץ:</span>
            </div>
            <div class="divForm">
                <asp:FileUpload ID="fuNewBrochureFile" runat="server" />
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorBrochure1"  runat="server" 
                        ControlToValidate="fuNewBrochureFile" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="brochureFields" />
            </div>

            <div class="divForm" style="width:120px;">
                <span class="RegularLabel">שפה:</span>
            </div>
            <div class="divForm">
                <asp:DropDownList ID="ddlLanguages" style="width:233px;" runat="server"></asp:DropDownList>
            </div>
            
            
            <div class="divForm" style="width:120px;">
                <span class="RegularLabel">שם החוברת בתצוגה:</span>
            </div>
            <div class="divForm">
                <asp:TextBox ID="txtBrochureName" style="width:233px;" runat="server"></asp:TextBox>
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorBrochure2"  runat="server" 
                        ControlToValidate="txtBrochureName" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="brochureFields" />
            </div>
            <div class="divForm" style="width:120px;">
                <span class="RegularLabel">שם הקובץ החדש:</span>
            </div>
            <div class="divForm">
                <asp:TextBox ID="txtNewBrochureFileName" style="width:233px;" runat="server"></asp:TextBox>
            </div>
            <div style="margin-right:5px;" class="divForm">
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorBrochure3"  runat="server" 
                        ControlToValidate="txtNewBrochureFileName" Display="Dynamic"
                        ErrorMessage="שדה חובה" ValidationGroup="brochureFields" />
            </div>
            <div style="clear:both;margin-top:20px;">
                <div class="button_LeftCornerFL" style="margin-left:10px;_margin-left:5px;"></div>
                <div class="button_CenterBackgroundFL">
                    <asp:Button ID="btnAddNewBrochure" runat="server" Text="הוספה" ValidationGroup="brochureFields"
                        class="RegularUpdateButton" Width="70px" 
                        OnClientClick="doPostBack('btnAddNewBrochure','brochureFields');" />
                </div>
                <div class="button_RightCornerFL"></div>

                <div class="button_RightCorner"></div>
                <div class="button_CenterBackground">
                    <input type="button" style="width:70px;" value="ביטול"
                        class="RegularUpdateButton" onclick="javascript:tb_remove();" />
                </div>
                <div style="margin-left:10px;_margin-left:0px;" class="button_LeftCorner"></div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hfAction" runat="server" />
    <asp:HiddenField ID="hfSelectedID" runat="server" />
    <asp:HiddenField ID="hfManageTable" runat="server" />    
    <script type="text/javascript" src="../Scripts/srcScripts/Thickbox.js"></script>
</asp:Content>

