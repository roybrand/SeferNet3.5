<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_PhonesGridUC" Codebehind="PhonesGridUC.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<script type="text/javascript">

    function intOnly(i) {
        if (i.value.length > 0) {
            i.value = i.value.replace(/[^\d]+/g, '');
        }
    }

    function ValidateAllPhoneControls(val, args) {        

        var txtPhone = null;
        var ddlPrefixPhone = null;
        var ddlPrePrefixPhone = null;  
        var txtExtension = null;              

        phoneNum = $('#' + val.id).closest("tr").find("input:text[id$='txtPhone']").val();
        prefix = $('#' + val.id).closest("tr").find("select[id$='ddlPrefixPhone']").val();
        prePrefix = $('#' + val.id).closest("tr").find("select[id$='ddlPrePrefixPhone']").val();

        if (phoneNum != null && prefix != null && prePrefix != null ) {
            
            args.IsValid = true;   
            
            if (prefix == -1 && prePrefix == -1 && phoneNum != "")
                args.IsValid = false; 

            if (phoneNum == "" && (prefix != -1 || prePrefix != -1))
                args.IsValid = false;

            prefix = $('#' + val.id).closest("tr").find("select[id$='ddlPrefixPhone'] :selected");
            prefixDisabled = $('#' + val.id).closest("tr").find("select[id$='ddlPrefixPhone']").attr("disabled");

            if (!prefixDisabled && prefix.text().length < 3 && prePrefix != -1)                 
                args.IsValid = false;            
            
        }
        else
            args.IsValid = true;
    }
</script>

<asp:UpdatePanel runat="server" ID="UpdPanel" UpdateMode="Conditional">
    <ContentTemplate>
        <table border="0" style="vertical-align: top">
            <tr valign="top">
                <td valign="top" style="padding-top:2px">
                    <asp:ImageButton runat="server" CausesValidation="true" ID="btnAdd" ImageUrl="~/Images/btn_add.gif"
                        ValidationGroup="phone" OnClick="btnAdd_Click" Visible='<%# _enableAdding %>' />
                </td>
                <td valign="top">
                    <asp:GridView ID="gvPhones" UseAccessibleHeader="false" runat="server" dir="rtl"
                        valign="top" AutoGenerateColumns="False" BorderWidth="0px" GridLines="None" AllowSorting="false"
                        AllowPaging="false" PagerSettings-Visible="false" ShowHeader="false" ShowFooter="false"
                        EnableTheming="False" OnRowDataBound="gvPhones_RowDataBound">
                        <Columns>
                            <asp:TemplateField Visible="false">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblPhoneOrder" Text='<%# Eval("phoneOrder") %>'></asp:Label>
                                    <asp:Label runat="server" ID="lblPhoneID" Text='<%# Eval("phoneID") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>                            
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:TextBox runat="server" Width="80px" ID="txtPhone" Text='<%# Eval("phone") %>'
                                        onKeyPress="javascript:intOnly(this);" CausesValidation="true" ValidationGroup="phone"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:UpdatePanel runat="server" ID="UpdatePanelPrefixPhone" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:DropDownList ID="ddlPrefixPhone" runat="server" CausesValidation="false" 
                                                DataValueField="prefixCode" dir="rtl" DataTextField="prefixValue" >
                                            </asp:DropDownList>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:DropDownList ID="ddlPrePrefixPhone" runat="server" dir="rtl" AutoPostBack="true"
                                        CausesValidation="false" OnSelectedIndexChanged="ddlPrePrefixPhone_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblExtension" CssClass="RegularLabelNormal" Width="40px"> שלוחה:</asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                   <asp:TextBox runat="server" ID="txtExtension" CausesValidation="false"
                                    Width="30px" Text='<%# Eval("extension") %>' ></asp:TextBox>                                       
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblRemark" CssClass="RegularLabelNormal"> &nbsp;הערה:</asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtRemark" CausesValidation="false" Visible="true" 
                                    Width="200px" Text="" ></asp:TextBox>                                       
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:ImageButton runat="server" ID="btnDelete" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                        CausesValidation="false" OnClick="btnDelete_Click" Visible="false" />
                                    <asp:LinkButton runat="server" ID="lnkDelete" Text="" OnClick="lnkDelete_Click" Visible="true"
                                        CausesValidation="false">
                                <asp:Image ID="Image1" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif" AlternateText="" />
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div style="width:20px">
                                    <asp:RequiredFieldValidator ID="RFV1" Display="Dynamic"  Enabled="<%# !EnableBlankData  %>" 
                                        ControlToValidate="txtPhone" runat="server" ErrorMessage="שדה חובה"  Text="*"></asp:RequiredFieldValidator>
                                   <asp:RegularExpressionValidator ID="REV1" runat="server" ControlToValidate="txtPhone"
                                        Display="Dynamic" ErrorMessage="מספר ספרות אינו חוקי" Text="*"
                                        ValidationExpression="\d{7}"></asp:RegularExpressionValidator>
                                    <asp:CompareValidator ID="vldPhone" runat="server" ControlToValidate="txtPhone" Operator="DataTypeCheck"
                                       Display="Dynamic" Type="Integer" Text="*" ErrorMessage="המספר חייב להכיל ספרות בלבד" ></asp:CompareValidator>
                                    <asp:CompareValidator ID="vldExtension" runat="server" ControlToValidate="txtExtension"
                                       Display="Dynamic" Operator="DataTypeCheck" Type="Integer" Text="*" ErrorMessage="שלוחה אינה חוקית" ></asp:CompareValidator>
                                    <asp:CustomValidator ID="vldAllPhoneControls" ClientValidationFunction="ValidateAllPhoneControls"
                                       runat="server" Text="*" Display="Dynamic" ErrorMessage="קידומת אינה חוקית"></asp:CustomValidator>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
                <td style="width:600px;vertical-align:top;">
                    <asp:Label runat="server" CssClass="LabelBoldDirtyBlue" ID="lblTitle"></asp:Label>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
