<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page Language="C#" AutoEventWireup="true" Title="יחידות חדשות מסימול" MasterPageFile="~/seferMasterPageIE.master" Inherits="NewClinicsList" EnableEventValidation="false" Codebehind="NewClinicsList.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType  VirtualPath="~/seferMasterPageIE.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

<script type="text/javascript">
    function OpenClinicDetailesPopUp(deptCode) {
        var url = "NewClinicDetails.aspx?deptCode=" + deptCode;

        var dialogWidth = 450;
        var dialogHeight = 640;
        var title = "פרטי מרפאה";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
        }
</script>
<table cellpadding="0" cellspacing="0">
    <tr id="trError" runat="server">
        <td>
            <asp:Label id="lblGeneralError" runat="server" SkinID="lblError"></asp:Label> 
        </td>
    </tr>
    <tr style="display:none">
        <td>
            <asp:CheckBox ID="cbBackToZoomClinic" runat="server" />
        </td>
    </tr>
</table>
<asp:Panel ID="pnlMain" runat="server" DefaultButton="btnCatchEnter">
    <table cellspacing="0" cellpadding="0" dir="rtl">
        <tr>
            <td style="padding-right:10px"><!-- Upper Blue Bar -->
                <table cellpadding="0" cellspacing="0" style="background-color:#298AE5; height:25px;" width="980px">
                    <tr>
                        <td style=" padding-right:15px">
                            <asp:Label ID="lblInterfaceDateCaption" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text="תאריך ממשק:"></asp:Label>
                            &nbsp;
                            <asp:Label ID="lblInterfaceDate" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text=""></asp:Label>
                            <asp:TextBox ID="txtDeptCode" Width="50px" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                            <asp:Button ID="btnCatchEnter" runat="server" Width="0px" Height="0px" OnClientClick="javascript:return false;" CssClass="DisplayNone" />
                        </td>
                   </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right:10px"><!-- Upper Blue Bar -->
                <table cellpadding="0" cellspacing="0" style="height:25px;" width="980px">
                    <tr>
                        <td style=" padding-right:15px">
                            <asp:Label ID="lblNewClinicCode" runat="server" EnableTheming="false" CssClass="RegularLabel" Text="קוד סימול חדש"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtNewClinicCode" runat="server" Width="80px"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Label ID="lblClinicName" runat="server" EnableTheming="false" CssClass="RegularLabel" Text="שם יחידה"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtClinicName" runat="server" Width="200px"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Label ID="lblSimulOpenDate" runat="server" EnableTheming="false" CssClass="RegularLabel" Text="תאריך פתיחה בסימול"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtSimulOpenDate" runat="server" Width="90px"></asp:TextBox>
                        </td>
                        <td>
                            <ajaxToolkit:MaskedEditValidator ID="val_txtDeptNameToAdd_FromDate" runat="server"
                                ControlExtender="mask_txtSimulOpenDate" ControlToValidate="txtSimulOpenDate"
                                IsValidEmpty="True" InvalidValueMessage="תאריך אינו תקין" Display="Dynamic" InvalidValueBlurredMessage="*&nbsp;&nbsp;"
                                ValidationGroup="vldGrSearch" />

                            <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_SimulOpenDate"
                                runat="server" />

                            <ajaxToolkit:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                FirstDayOfWeek="Sunday" TargetControlID="txtSimulOpenDate" PopupPosition="BottomRight"
                                PopupButtonID="btnRunCalendar_SimulOpenDate">
                            </ajaxToolkit:CalendarExtender>

                            <ajaxToolkit:MaskedEditExtender ID="mask_txtSimulOpenDate" runat="server"
                                AcceptAMPM="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                TargetControlID="txtSimulOpenDate">
                            </ajaxToolkit:MaskedEditExtender>
                        </td>
                        <td>
                            <asp:Label ID="lblExistsInDept" runat="server" EnableTheming="false" CssClass="RegularLabel" Text="סטטוס קליטה"></asp:Label>
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlExistsInDept" runat="server" Width="70px">
                                <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                <asp:ListItem Text="לא נקלט" Value="0"></asp:ListItem>
                                <asp:ListItem Text="נקלט" Value="1"></asp:ListItem>
                            </asp:DropDownList>
                        </td>

                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="btnSubmit" Width="45px" CssClass="RegularUpdateButton" Text="חיפוש" 
                                runat="server" OnClick="btnSubmit_Click" ValidationGroup="vldGrSearch" OnClientClick="javascript:showProgressBarGeneral('')">
                            </asp:Button>
                        </td>
                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                            background-repeat: no-repeat;">
                            &nbsp;
                        </td>
                   </tr>
                </table>
            </td>

        </tr>
        <tr><td style="height:5px"></td></tr>
        <tr>
            <td style="padding-right:10px"><!-- Phones and QueueOrderMethods --> 
                <table cellpadding="0" cellspacing="0" border="0" style="background-color:#F7F7F7">
                    <tr>
                        <td style="height:8px; background-image:url('../Images/Applic/RTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top right">
                        </td>
                        <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: top">
                        </td>
                        <td style="background-image:url('../Images/Applic/LTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right:solid 2px #909090;">
                            <div style="width:6px;"></div>
                        </td>
                        <td>
                            <div style="width:958px;">
                                <table id="tblAddService" runat="server" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td><div style="width:35px">&nbsp;</div></td>
                                                    <td>
                                                        <asp:Label ID="lblDeptCode" Width="60px" runat="server" Text="קוד מרפאה" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblDeptName"  Width="120px" runat="server" Text="שם בסימול" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblDistrictName"  Width="80px" runat="server" Text="מחוז" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblSimulManageDescription"  Width="120px" runat="server" Text="כפיפות ניהולית בסימול" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblSugSimul"  Width="75px" runat="server" Text="סוג סימול" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblTatSugSimul"  Width="80px" runat="server" Text="תת סוג סימול" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblTatHitmahut"  Width="90px" runat="server" Text="תת התמחות" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblRamatPeilut"  Width="75px" runat="server" Text="רמת פעילות" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblOpenDateSimul"  Width="90px" runat="server" Text="ת. פתיחה בסימול" EnableTheming="false" CssClass="LabelCaptionBlueBold_13"></asp:Label>
                                                    </td>
                                                    <td><div style="width:110px"></div></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>
                                                        <div id="divGvClinicList" class="ScrollBarDiv" runat="server" >
                                                        <asp:GridView ID="gvNewClinicsList" runat="server" AutoGenerateColumns="False" 
                                                            SkinID="GridViewForSearchResults" 
                                                            onrowdatabound="gvNewClinicsList_RowDataBound" HeaderStyle-CssClass="DisplayNone" >
                                                            <Columns>
                                                                <asp:TemplateField HeaderText="" ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <asp:Image ID="imgDetailes" runat="server" ImageUrl="~/Images/Applic/bookc.gif" Style="cursor: pointer" />
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="קוד מרפאה" ItemStyle-Width="60px" HeaderStyle-HorizontalAlign="Right" >
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDeptCode" runat="server" Text='<%# Eval("DeptCode")%>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="שם בסימול" ItemStyle-Width="120px" HeaderStyle-HorizontalAlign="Right" >
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDeptName" runat="server" Text='<%# Eval("deptName")%>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="שם בסימול" ItemStyle-Width="80px" HeaderStyle-HorizontalAlign="Right" >
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDistrictName" runat="server" Text='<%# Eval("districtName")%>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="כפיפות ניהולית בסימול" ItemStyle-Width="120px" HeaderStyle-HorizontalAlign="Right" >
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblSimulManageDescription" runat="server" Text='<%# Eval("SimulManageDescription")%>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="סוג סימול" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Right">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblSugSimul501" runat="server" Text='<%# Eval("SugSimul501")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblSimulDesc" runat="server" Text='<%# Eval("SimulDesc")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="תת סוג סימול" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Right">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblTatSugSimul502" runat="server" Text='<%# Eval("TatSugSimul502")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblT502_descr" runat="server" Text='<%# Eval("t502_descr")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="תת התמחות" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Right">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblTatHitmahut503" runat="server" Text='<%# Eval("TatHitmahut503")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblT503_descr" runat="server" Text='<%# Eval("t503_descr")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="רמת פעילות" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Right">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblRamatPeilut504" runat="server" Text='<%# Eval("RamatPeilut504")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblT504_descr" runat="server" Text='<%# Eval("t504_descr")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="ת. פתיחה בסימול" HeaderStyle-HorizontalAlign="Right" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Right">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:Label ID="lblOpenDateSimul" runat="server" Text='<%# Eval("OpenDateSimul","{0:d}")%>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="center" style="width:125px">
                                                                                    <table id="tblButtons" runat="server" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                                                                            </td>
                                                                                            <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                                                                <asp:Button runat="server" ID="btnAddClinicAndUpdate" DeptCode='<%# Eval("DeptCode")%>' Width="70px" CssClass="RegularUpdateButton" Text="קלוט ועדכן" 
                                                                                                    OnClick="btnAddClinicAndUpdate_Click" />
                                                                                            </td>
                                                                                            <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                    <asp:Label ID="lblInserted" runat="server" Text="נקלט" CssClass="LabelBoldBrightBlue" EnableTheming="false"></asp:Label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:ImageButton ID="btnDeleteNewClinic" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                        DeptCode='<%# Eval("DeptCode")%>'
                                                                                        OnClick="btnDeleteNewClinic_Click" 
                                                                                        OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את היחידה מהרשימה היחידות החדשות מסימול')"></asp:ImageButton>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                        <td style="border-left:solid 2px #909090;">
                            <div style="width:6px;"></div>
                        </td>
                    </tr>
                    <tr style="height:10px">
                        <td style="background-image:url('../Images/Applic/RBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom right">
                        </td>
                        <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: bottom">
                        </td>
                        <td style="background-image:url('../Images/Applic/LBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Panel>
</asp:Content>