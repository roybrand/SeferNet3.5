<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateEmployeeExpertProfession.aspx.cs" Inherits="SeferNet.UI.Apps.Admin.UpdateEmployeeExpertProfession" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <title></title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />   
</head>
<body>
    <script type="text/javascript">
        function ValidateExpertDiplomaNumbe() {
            if (typeof (Page_ClientValidate) == 'function') { 

                if (!Page_ClientValidate()) {
                    var yesorno = confirm('יש להזין מספר התעודה לצורך שמירת הנתונים');
                    //alert(yesorno); // cancel = false - go to server and 
                    if (yesorno == false) {
                        self.close();
                    }
                    return yesorno;
                    }
                }

        }
    </script>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
    <form id="form1" runat="server">
        <div>
            <table cellpadding="0" cellspacing="0" width="100%">
                <tr style="background-color: #298AE5;">
                    <td align="center">
                        <asp:Label EnableTheming="false" ID="lblDegreeHeader" class="LabelBoldWhite_18" runat="server">הזנת מספר תעודת מומחה</asp:Label>
                    </td>
                </tr>
                <tr><td>&nbsp;
                    <%--<asp:ValidationSummary runat="server" ID="vldSummary" />--%>
                    </td></tr>
                <tr>
                    <td align="center">
                        <asp:GridView ID="gvEmployeeProfessionExpert" Width="370px" runat="server" dir="rtl" EnableViewState="true" AutoGenerateColumns="False">
                            <Columns>
                            <%--Hidden column --%>
                            <asp:TemplateField Visible="false">
                                <ItemTemplate>
                                    <asp:Label ID="lblEmployeeID" runat="server" Text='<%# Eval("EmployeeID") %>'></asp:Label>
                                    <asp:Label ID="lblserviceCode" runat="server" Text='<%# Eval("serviceCode") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--ServiceDescription--%>
                            <asp:TemplateField ItemStyle-Width="200px">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lblTitleServiceDescription" Text="מומחיות"></asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div>
                                        <asp:Label id="txtServiceDescription" runat="server" Text='<%# Eval("ServiceDescription") %>' EnableTheming="false" />                        
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--expertDiplomaNumber--%>
                            <asp:TemplateField ItemStyle-Width="100px">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lblTitleExpertDiplomaNumber" Text="מספר תעודה"></asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div>
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:TextBox id="txtExpertDiplomaNumber" Width="90px" Enabled="false" runat="server" Text='<%# Eval("expertDiplomaNumber") %>' />  
                                                </td>
                                                <td>
                                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtExpertDiplomaNumber" Text="*" ValidationGroup="vgSave"
                                                        ErrorMessage="יש להזין מספר התעודה לצורך שמירת הנתונים" />
                                                    <asp:RangeValidator runat="server" Type="Integer" MinimumValue="1" MaximumValue="200000000" ControlToValidate="txtExpertDiplomaNumber" Text="*" ValidationGroup="vgSave" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <div>
                                        <asp:TextBox id="txtExpertDiplomaNumber" Width="90px" runat="server" Text='<%# Eval("expertDiplomaNumber") %>' /> 
                                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtExpertDiplomaNumber" Text="*" ValidationGroup="vldGrEdit"
                                            ErrorMessage="יש להזין מספר התעודה לצורך שמירת הנתונים" />
                                        <asp:RangeValidator runat="server" Type="Integer" MinimumValue="1" MaximumValue="200000000" ControlToValidate="txtExpertDiplomaNumber" Text="*" ValidationGroup="vldGrEdit" />

                                    </div>
                                </EditItemTemplate>

                            </asp:TemplateField>
                            <%--Update column--%>
                            <asp:TemplateField ItemStyle-Width="100px">
                                <ItemTemplate>
                                    <div style="margin-right: 3px">
                                        <asp:ImageButton ID="imgUpdate" runat="server" CommandName="update" OnClick="imgUpdate_Click"
                                            ImageUrl="~/Images/btn_edit.gif" />
                                    </div>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:ImageButton ID="imgCancel" runat="server" CommandName="canel" CausesValidation="False"
                                                    OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif" />
                                            </td>
                                            <td>
                                                <asp:ImageButton ID="imgSave" runat="server" CommandName="save" ValidationGroup="vldGrEdit"
                                                    OnClick="imgSave_Click" ImageUrl="~/Images/btn_approve.gif" />
                                            </td>
                                        </tr>
                                    </table>
                                </EditItemTemplate>
                            </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </td>
                </tr>
                <tr><td>&nbsp;</td></tr>
                <tr>
                    <td style="padding-left:20px">
                        <table cellpadding="0" cellspacing="0" border="0" dir="rtl">
                            <tr>
                                <td class="buttonRightCorner">
                                </td>
                                <td class="buttonCenterBackground">
                                    <asp:Button ID="btnSaveBottom" runat="server" Text="אישור" CssClass="RegularUpdateButton"
                                        OnClick="btnSave_click" 
                                        OnClientClick="return ValidateExpertDiplomaNumbe();">
                                    </asp:Button>
                                </td>
                                <td class="buttonLeftCorner">
                                </td>
                                <td class="buttonRightCorner">
                                    &nbsp;
                                </td>
                                <td class="buttonCenterBackground">
                                    <asp:Button ID="btnCancel" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                        CausesValidation="False" OnClick="btnCancel_click" />
                                </td>
                                <td class="buttonLeftCorner">
                                    &nbsp;
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
