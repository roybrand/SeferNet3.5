<%@ Page Title="עדכון הערה לפי הסוג הנבחר" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" Inherits="Admin_EditRemarkByselectedType"
    UICulture="he-il" Codebehind="EditRemarkByselectedType.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/SeferMasterPage.master" %>
<%@ PreviousPageType VirtualPath="~/Admin/ManageGeneralRemarksDictionary.aspx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">
    
    
    <script type="text/javascript">
        function check(val, args) {
            //debugger;

            if ($("input:checkbox[id*=cblinkedTo][checked='true']").length > 0)
                args.IsValid = true;
            else
                args.IsValid = false;
        }

        //        function linkedToReceptionHours_CheckedChanged(sender) {
        //            //alert('function checked');

        //            var cbEnableOverlappingHours = $("input:checkbox[id*=cbEnableOverlappingHours]")

        //            if (sender.checked = true) {
        //                cbEnableOverlappingHours.visible = true;
        //            }
        //            else {
        //                cbEnableOverlappingHours.visible = false;
        //            }

        //        }
    </script>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <div dir="rtl">
                <table cellpadding="0" cellspacing="0" width="100%">
                    <tr id='BlueBarTop'>
                        <td style="padding-right: 10px">
                            <table cellpadding="0" cellspacing="0" style="width: 100%">
                                <tr>
                                    <td style="background-color: #298AE5; height: 18px;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-right: 10px;">
                            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                <tr id="trBorderTop">
                                    <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                        <div style="width: 6px;">
                                        </div>
                                    </td>
                                    <td>
                                        <table>
                                            <tr id="trDvDetailesView" runat="server">
                                                <%--style="padding-top: 40px;" valign="top"--%>
                                                <td align="right">
                                                    <asp:DetailsView runat="server" ID="dvGeneralRemarks" Width="100%" AutoGenerateRows="false"
                                                        SkinID="dvGeneralRemarks" OnDataBound="dvGeneralRemarks_DataBound">
                                                        <%--OnModeChanged="dvGeneralRemarks_ModeChanged" --%>
                                                        <Fields>
                                                            <asp:TemplateField ItemStyle-HorizontalAlign="Right">
                                                                <ItemTemplate>
                                                                    <table>
                                                                        <tr>
                                                                            <td width="120px" style="height:30px">
                                                                                <asp:Label ID="lblCaptionRemarkID" runat="server" Text="קוד הערה: " ></asp:Label>
                                                                            </td>
                                                                            <td>
                                                                                <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("remarkID") %>'></asp:Label>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField ItemStyle-HorizontalAlign="Right">
                                                                <ItemTemplate>
                                                                    <table>
                                                                        <tr>
                                                                            <td width="120px">
                                                                                <asp:Label ID="Label3" runat="server" Text="הערות"></asp:Label>
                                                                            </td>
                                                                            <td>
                                                                                <asp:TextBox ID="txtRemark" Width="550px" align="left" BorderColor="#CECBCE" BorderStyle="Solid"
                                                                                    BorderWidth="1px" TextMode="MultiLine" runat="server" Text='<%# Bind("remark") %>'></asp:TextBox>
                                                                            </td>
                                                                            <td>
                                                                                <asp:RequiredFieldValidator ID="rfv_txtRemark" ForeColor="Red" Text="*" ErrorMessage="שדה חובה"
                                                                                    ControlToValidate="txtRemark" runat="server"></asp:RequiredFieldValidator>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField ItemStyle-HorizontalAlign="Right">
                                                                <ItemTemplate>
                                                                    <table>
                                                                        <tr>
                                                                            <td>
                                                                                <table>
                                                                                    <tr>
                                                                                        <td width="120px" valign="top">
                                                                                            <asp:Label ID="lblRemarkCategory"  runat="server" Text="קטגוריה:"> </asp:Label>
                                                                                        </td>
                                                                                        <td  width="230px" valign="middle">
                                                                                            <asp:DropDownList ID="ddlRemarkCategory" runat="server" Height="24px" Width="200px">
                                                                                            </asp:DropDownList>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                            <td>
                                                                                <table id="tblRemarkFactor" runat="server">
                                                                                    <tr>
                                                                                        <td width="95px" valign="top" style="padding-right:25px">
                                                                                            <asp:Label ID="lblRemarkFactor"  runat="server" Text="מקדם לסכימת שעות שבועית:"> </asp:Label>
                                                                                        </td>
                                                                                        <td valign="middle">
                                                                                            <asp:DropDownList ID="ddlRemarkFactor" runat="server" Height="24px" Width="200px">
                                                                                            </asp:DropDownList>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                                        <tr>
                                                                            <td style="width:380px">
                                                                                <asp:CheckBox ID="cbActive" runat="server" Checked='<%# Bind("active")   %>' TextAlign="Left" />
                                                                                <asp:Label ID="Label1" runat="server" Text="פעיל/לא פעיל"></asp:Label>
                                                                            </td>
                                                                            <td>
                                                                                <asp:CheckBox ID="cbOpenNow" runat="server" Checked='<%# Bind("OpenNow")   %>' />
                                                                                <asp:Label ID="lblOpenNow" runat="server" Text='כאשר ההערה בתוקף - לא יוצג "פתוח כעת" באינטרנט'></asp:Label>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <table cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td style="width:380px">
                                                                                <asp:CheckBox ID="cblinkedToDept" runat="server" Checked='<%# Bind("linkedToDept") %>' />
                                                                                <asp:Label ID="Label5" runat="server" Text="קשר הערה למרפאה"></asp:Label>
                                                                            </td>
                                                                            <td>
                                                                                <asp:Label ID="lblShowForPreviousDays" Text="מספר ימים להצגה מוקדמת:" runat="server" />&nbsp;&nbsp;
                                                                                <asp:TextBox ID="txtShowForPreviousDays" runat="server" Width="30px" Text='<%# Bind("ShowForPreviousDays") %>'></asp:TextBox>
                                                                                <asp:CompareValidator ID="vldShowForPreviousDays" runat="server" ControlToValidate="txtShowForPreviousDays" Text="*"
                                                                                    ErrorMessage="מספר ימים להצגה מוקדמת אמור להיות מספרי" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="cblinkedToDoctor" runat="server" Checked='<%# Bind("linkedToDoctor") %>' />
                                                                    <asp:Label ID="Label8" runat="server" Text="קשר הערה לרופא"></asp:Label>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="cblinkedToServiceInClinic" runat="server" Checked='<%# Bind("linkedToServiceInClinic") %>' />
                                                                    <asp:Label ID="Label11" runat="server" Text="קשר הערה לשירות"></asp:Label>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="cblinkedToReceptionHours" runat="server"
                                                                        Checked='<%# Bind("linkedToReceptionHours") %>' AutoPostBack="True" />
                                                                    <asp:Label ID="Label14" runat="server" Text="קשר הערה לשעות קבלה"></asp:Label>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="cbEnableOverlappingHours" runat="server" Checked='<%# Bind("EnableOverlappingHours") %>' />
                                                                    <asp:Label ID="Label2" runat="server" Text="אפשר חפיפת שעות"></asp:Label>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>

                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Fields>
                                                        <HeaderStyle Wrap="True" />
                                                    </asp:DetailsView>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right">
                                                    <asp:CustomValidator ID="CustomValidator1" runat="server" ClientValidationFunction="check"
                                                        ErrorMessage="חובה לשייך הוגעה לקטגוריה אחת לפחות" SkinID="lblError"></asp:CustomValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:ValidationSummary ID="vldSumFirstSectionValidation" ShowSummary="true" runat="server" />
                                                </td>
                                            </tr>
                                            <tr id="trSaveAndCancelButtons" dir="rtl">
                                                <td>
                                                    <table width="960px">
                                                        <tr>
                                                            <td align="left" width="6000px" style="padding-left:40px">
                                                                <table cellpadding="0" cellspacing="0" style="margin-bottom: 5px">
                                                                    <tr>
                                                                        <td class="buttonRightCorner">
                                                                        </td>
                                                                        <td class="buttonCenterBackground">
                                                                            <asp:Button ID="btnSaveAndRenewRemarks" runat="server" CssClass="RegularUpdateButton" OnClick="btnSaveAndRenewRemarks_Click"
                                                                                Text="  שמירה ורענון  " />
                                                                        </td>
                                                                        <td class="buttonLeftCorner">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td align="left" style="padding-left:10px">
                                                                <table cellpadding="0" cellspacing="0" style="margin-bottom: 5px">
                                                                    <tr>
                                                                        <td class="buttonRightCorner">
                                                                        </td>
                                                                        <td class="buttonCenterBackground">
                                                                            <asp:Button ID="btnSave" runat="server" CssClass="RegularUpdateButton" OnClick="btnSave_Click"
                                                                                Text="שמירה" />
                                                                        </td>
                                                                        <td class="buttonLeftCorner">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td align="left" style="padding-left: 15px">
                                                                <table cellpadding="0" cellspacing="0" style="margin-bottom: 5px">
                                                                    <tr>
                                                                        <td class="buttonRightCorner">
                                                                        </td>
                                                                        <td class="buttonCenterBackground">
                                                                            <asp:Button ID="btnCancel" runat="server" CausesValidation="false" CssClass="RegularUpdateButton"
                                                                                OnClick="btnCancel_Click" Text="ביטול" />
                                                                        </td>
                                                                        <td class="buttonLeftCorner">
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
                                        <div style="width: 6px;">
                                        </div>
                                    </td>
                                </tr>
                                <tr id="BorderBotton" style="height: 10px">
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
                        </td>
                    </tr>
                    <tr id='BlueBarBotton'>
                        <td style="padding-right: 10px">
                            <table cellpadding="0" cellspacing="0" style="width: 100%">
                                <tr>
                                    <td style="background-color: #298AE5; height: 18px;">
                                        &nbsp;
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
