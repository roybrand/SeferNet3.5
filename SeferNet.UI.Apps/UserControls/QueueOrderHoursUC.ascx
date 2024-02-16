<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_QueueOrderHoursUC" Codebehind="QueueOrderHoursUC.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelectUC.ascx" %>
<script language="javascript" type="text/javascript">


    // large GridView has low performance if it is in Update panel
    //this  is solution

    function validateHours(openingTime, closingTime) {


        //var openingTime = $('#' + val.id).closest("table").find("input:text[id$=txtFromHour]").val();
        var openingTimeArr = openingTime.split(':');
        var FromHour = openingTimeArr[0];
        var FromMinute = openingTimeArr[1];
        

        //var closingTime = $('#' + val.id).closest("table").find("input:text[id$=txtToHour]").val();
        var closingTimeArr = closingTime.split(':');
        var ToHour = closingTimeArr[0];
        if (ToHour == "00")
            ToHour = "24";
        var ToMinute = closingTimeArr[1];


        var FromHourInt = parseInt(FromHour, 10);
        var ToHourInt = parseInt(ToHour, 10);

        var FromMinuteInt = parseInt(FromMinute, 10);
        var ToMinuteInt = parseInt(ToMinute, 10);

        var receptionDateFrom = new Date();
        receptionDateFrom.setHours(FromHourInt, FromMinute, 0, 0);

        var receptionDateTo = new Date();
        receptionDateTo.setHours(ToHourInt, ToMinute, 0, 0);



        if (receptionDateFrom < receptionDateTo)
        //args.IsValid = true;
            return true;
        else
        //args.IsValid = false;
            return false;
    }

    function validateAddHours(source, args) {

        var openHour = $("*[id$=txtFromHour]").val();
        var closeHour = $("*[id$=txtToHour]").val();

        args.IsValid = validateHours(openHour, closeHour);
    }


    function validateEditHours(source, args) {
        
        var openHour = $("*[id$=txtFromHourEdit]").val();
        var closeHour = $("*[id$=txtToHourEdit]").val();

        args.IsValid = validateHours(openHour, closeHour);
    }

    function ClearFields() {
        $("*[id$=txtFromHour]").val("");
        $("*[id$=txtToHour]").val("");

        if (OnClearData != null) {
            OnClearData();
        }
    }
    
</script>
<asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="UpdPanel1">
    <ContentTemplate>
        <asp:GridView ID="dgOrderHours" runat="server" dir="rtl" AutoGenerateColumns="False"
            AllowSorting="True" EnableTheming="True" BorderWidth="1px" OnRowDataBound="dgOrderHours_RowDataBound"
            OnRowDeleting="dgOrderHours_RowDeleting" OnRowCancelingEdit="dgOrderHours_RowCancelingEdit"
            OnRowEditing="dgOrderHours_RowEditing"
            Width="330px">
            <Columns>
                <asp:TemplateField Visible="False">
                    <ItemTemplate>
                        <asp:Label ID="lblDays2" runat="server" Text='<%# Eval("Days") %>'></asp:Label>
                        <asp:Label ID="lblID" runat="server" Text='<%# Eval("ID") %>'></asp:Label>
                        <asp:Label ID="lblAdd_ID" runat="server" Text='<%# Eval("Add_ID") %>'></asp:Label>
                        <asp:Label ID="lblReceptionIds" runat="server" Text='<%# Eval("QueueOrderHoursID") %>'></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td align="right" valign="bottom">
                                    <asp:Label ID="Label1" runat="server" Text="ימים:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="MultiDDlSelect_Days"
                                        Width="40px" />
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Label runat="server" ID="lblDays" Text='<%# Eval("Days") %>'></asp:Label>
                    </ItemTemplate>
                    <ItemStyle />
                    <EditItemTemplate>
                        <div style="padding-right: 3px">
                            <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="mltDdlDayE" Width="40px" />
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Label ID="Label2" runat="server" Text="משעה:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtFromHour" runat="server" Width="40px"></asp:TextBox>
                                    <cc1:MaskedEditExtender ID="FromHourExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99:99" MaskType="Time" TargetControlID="txtFromHour" Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    <cc1:MaskedEditValidator ID="FromHourValidator" runat="server" ControlExtender="FromHourExtender"
                                        ControlToValidate="txtFromHour" InvalidValueMessage="שעת הפתיחה אינה תקינה" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" Text="*" ErrorMessage="שעת הפתיחה אינה תקינה" />
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Label runat="server" ID="lblOpeningHour" Text='<%# Eval("openingHour") %>'></asp:Label>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div>
                            <asp:TextBox ID="txtFromHourEdit" runat="server" Width="40px" Text='<%# Eval("openingHour") %>'></asp:TextBox>
                            <cc1:MaskedEditExtender ID="FromHourExtender" runat="server" ErrorTooltipEnabled="True"
                                Mask="99:99" MaskType="Time" TargetControlID="txtFromHourEdit" CultureAMPMPlaceholder=""
                                CultureCurrencySymbolPlaceholder="" CultureDateFormat="" CultureDatePlaceholder=""
                                CultureDecimalPlaceholder="" CultureThousandsPlaceholder="" CultureTimePlaceholder=""
                                Enabled="True">
                            </cc1:MaskedEditExtender>
                            <cc1:MaskedEditValidator ID="FromHourValidator" runat="server" ControlExtender="FromHourExtender"
                                ControlToValidate="txtFromHourEdit" InvalidValueMessage="השעת פתיחה אינה תקינה" Display="Dynamic"
                                InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="FromHourValidator" />
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Label ID="Label3" runat="server" Text="עד שעה:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtToHour" runat="server" Width="40px"></asp:TextBox>
                                    <cc1:MaskedEditExtender ID="ClosingHourExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99:99" MaskType="Time" TargetControlID="txtToHour" Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    <cc1:MaskedEditValidator ID="ClosingHourValidator" runat="server" ControlExtender="ClosingHourExtender"
                                        ControlToValidate="txtToHour" InvalidValueMessage="השעת סגירה אינה תקינה" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ErrorMessage="ClosingHourValidator" ValidationGroup="vldGrAdd" />
                                    <asp:CustomValidator ControlToValidate="txtToHour" ClientValidationFunction="validateAddHours"
                                        ErrorMessage="השעות אינן תקינות" Text="*" ID="vldCheckHours" runat="server" ValidationGroup="vldGrAdd"></asp:CustomValidator>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Label runat="server" ID="lblClosingHour" Text='<%# Eval("closingHour") %>'></asp:Label>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtToHourEdit" runat="server" Width="40px" Text='<%# Eval("closingHour") %>'></asp:TextBox>
                        <cc1:MaskedEditExtender ID="ClosingHourExtender" runat="server" ErrorTooltipEnabled="True"
                            Mask="99:99" MaskType="Time" TargetControlID="txtToHourEdit" Enabled="True">
                        </cc1:MaskedEditExtender>
                        <cc1:MaskedEditValidator ID="ClosingHourValidator" runat="server" ControlExtender="ClosingHourExtender"
                            ControlToValidate="txtToHourEdit" InvalidValueMessage="השעת סגירה אינה תקינה" Display="Dynamic"
                            InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="ClosingHourValidator" />
                        <asp:CustomValidator ControlToValidate="txtToHourEdit" ClientValidationFunction="validateEditHours"
                            ErrorMessage="השעות אינן תקינות" Text="*" ID="vldCheckHours" runat="server" ValidationGroup="vldGrEdit"></asp:CustomValidator>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <div style="padding-top: 20px">
                            <asp:ImageButton runat="server" ID="imgClear" CausesValidation="false" CommandName="clear"
                                OnClientClick="ClearFields(this); return false;" ImageUrl="~/Images/btn_clear.gif" />
                        </div>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:ImageButton ID="imgDelete" runat="server" CommandName="delete" OnClick="imgDelete_Click"
                            CausesValidation="false" ImageUrl="~/Images/Applic/btn_X_red.gif" />
                    </ItemTemplate>
                    <ItemStyle VerticalAlign="Middle" />
                    <EditItemTemplate>
                        <asp:ImageButton ID="imgCancel" runat="server" CausesValidation="False" OnClick="imgCancel_Click"
                            ImageUrl="~/Images/btn_cancel.gif" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <div style="padding-top: 20px; padding-right: 4px">
                            <asp:ImageButton runat="server" ID="imgAdd" OnClick="imgAdd_Click" ImageUrl="~/Images/btn_add.gif"
                                ValidationGroup="vldGrAdd" />
                        </div>
                    </HeaderTemplate>
                    <HeaderStyle VerticalAlign="Middle" />
                    <EditItemTemplate>
                    </EditItemTemplate>
                    <ItemTemplate>
                        <asp:ImageButton ID="imgUpdate" runat="server" CommandName="Edit" 
                        ImageUrl="~/Images/btn_edit.gif" CausesValidation="false" />
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Center" VerticalAlign="Middle" />
                    <EditItemTemplate>
                        <asp:ImageButton ID="imgSave" runat="server" ValidationGroup="vldGrEdit" CommandName="save"
                            OnClick="imgSave_Click" ImageUrl="~/Images/btn_approve.gif" />
                    </EditItemTemplate>
                </asp:TemplateField>
            </Columns>
            <SelectedRowStyle ForeColor="GhostWhite" />
            <HeaderStyle BackColor="#F3EBE0" Font-Bold="True" />
        </asp:GridView>
        <div id="hdnDiv">
            <asp:HiddenField ID="hdnHeaderFromHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderToHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidFromClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidToClientID" runat="server" />
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
