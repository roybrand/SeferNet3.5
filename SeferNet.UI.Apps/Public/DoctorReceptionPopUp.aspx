<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Public_DoctorReceptionPopUp" Theme="SeferGeneral" Codebehind="DoctorReceptionPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>שעות קבלה לנותן שירות ביחידה</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="Stylesheet" href="~/CSS/General/general.css" type="text/css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>

    <script type="text/javascript">
        function closeWindow() {
            self.close()
        }

        function OpenEmployeeExpirationReceptionWindow(deptEmployeeID, serviceCode, expirationDate) {
            var strUrl = "DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&serviceCode=" + serviceCode + "&expirationDate=" + expirationDate;
            var dialogWidth = 640;
            var dialogHeight = 600;
            var title = "שעות קבלה של נותן שירות ביחידה";

            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title);
        }
    </script>

    <style type="text/css">
        .style1
        {
            height: 37px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" defaultfocus="btnClose" defaultbutton="btnClose">
    <table cellpadding="0" cellspacing="0" width="100%" style="height: 100%">
        <tr align="right">
            <td>
                <table id='tblDoctors-<%# Eval("employeeID") %>' class="SimpleText" cellpadding="0"
                    align="right" cellspacing="0" style="width: 600px; display: inline; background-color: white;"
                    dir="rtl">
                    <tr id="trEmployeeReceptionCaption">
                        <td align="right" style="height: 45px; vertical-align: middle;" class="BackColorBlue">
                            <table >
                                <tr>
                                    <td style="padding-right:2px">
                                        <asp:Label ID="lblEmployeeName_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite_18"
                                            runat="server"></asp:Label>
                                    </td>
                                    <td style="padding-right:10px;padding-left:10px;">
                                        <asp:Label ID="lblClinicName_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblPhoneCaption_EmployeeReception" EnableTheming="false" CssClass="LabelNormalWhite"
                                            runat="server" Text="טל`:"></asp:Label>
                                        <asp:Label ID="lblPhone_EmployeeReception" Width="75px" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblFaxCaption_EmployeeReception" EnableTheming="false" CssClass="LabelNormalWhite"
                                            runat="server" Text="פקס:"></asp:Label>
                                        <asp:Label ID="lblFax_EmployeeReception" Width="75px" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            
                            <%--<table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="padding-right: 5px;width:160px" valign="middle">
                                        <asp:Label ID="lblEmployeeName_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite_18"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                    <td style="padding-right: 10px;width:200px">
                                        <asp:Label ID="lblClinicName_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                    <td style="padding-right: 15px">
                                        <asp:Label ID="lblPhoneCaption_EmployeeReception" EnableTheming="false" CssClass="LabelNormalWhite"
                                            runat="server" Text="טל`:"></asp:Label>
                                    </td>
                                    <td style="padding-right: 5px;">
                                        <asp:Label ID="lblPhone_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>&nbsp
                                    </td>
                                    <td style="padding-right: 10px">
                                        <asp:Label ID="lblFaxCaption_EmployeeReception" EnableTheming="false" CssClass="LabelNormalWhite"
                                            runat="server" Text="פקס:"></asp:Label>
                                    </td>
                                    <td style="padding-left: 1px;">
                                        <asp:Label ID="lblFax_EmployeeReception" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                            </table>--%>
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid #cccccc;">
                            <div class="ScrollBarDiv" style="height: 230px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <asp:GridView ID="gvOuterForEmployeeHours" runat="server" AutoGenerateColumns="false"
                                        HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView" OnRowDataBound="gvOuterForEmployeeHours_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="height: 30px; padding-right: 5px" align="right">
                                                                <asp:Label ID="lblProfessionsAndServicesHamesCaption" runat="server" EnableTheming="false"
                                                                    CssClass="LabelCaptionGreenBold_14" Text="תחום שירות: ">
                                                                </asp:Label>
                                                                <asp:Label ID="lblProfessionsAndServicesHames" runat="server" EnableTheming="false"
                                                                    CssClass="LabelCaptionGreenBold_14" Text='<%#Bind("professionOrServiceDescription") %>'>
                                                                </asp:Label>
                                                                <asp:Label ID="lblFromExpDat" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_14"
                                                                    Text=""></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 5px; padding-bottom: 10px">
                                                                <div id="divExpire" runat="server">
                                                                    <asp:Label ID="lnkExpireWarning" runat="server" EnableTheming="false" CssClass="LooksLikeHRefBold"></asp:Label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right">
                                                                <table cellpadding="0" cellspacing="0" class="BorderBottomBlue">
                                                                    <tr>
                                                                        <td style="width: 45px" align="center">
                                                                            <asp:Label ID="lblDay" runat="server" Text="יום" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                        </td>
                                                                        <td style="width: 25px" align="center"><!-- Receive guests  -->
                                                                        </td>
                                                                        <td style="width: 60px" align="center">
                                                                            <asp:Label ID="lblFromHour" runat="server" Text="משעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                        </td>
                                                                        <td style="width: 60px" align="center">
                                                                            <asp:Label ID="lblToHour" runat="server" Text="עד שעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                        </td>
                                                                        <td style="padding: 0px 15px 0px 0px; width: 405px;" align="right">
                                                                            <asp:Label ID="lblRemarks" runat="server" Text="הערות" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView ID="gvEmployeeReceptionDays" runat="server" AutoGenerateColumns="false"
                                                                    SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvEmployeeReceptionDays_RowDataBound">
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table cellpadding="0" cellspacing="0" class="BorderBottomBlue">
                                                                                    <tr>
                                                                                        <td style="width: 45px; background-color: #E1F0FC;" align="center">
                                                                                            <asp:Label ID="lblDay" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                                Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                                                                        </td>
                                                                                        <td>
                                                                                            <asp:GridView ID="gvReceptionHours" runat="server" AutoGenerateColumns="false" OnRowDataBound="gvReceptionHours_RowDataBound"
                                                                                                SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone">
                                                                                                <Columns>
                                                                                                    <asp:TemplateField ItemStyle-Width="25px" ItemStyle-HorizontalAlign="Center">
                                                                                                        <ItemTemplate>
                                                                                                            <asp:Image ID="imgReceiveGuests" runat="server" ImageUrl="~/Images/Applic/ReceiveGuestsSmall.png" ToolTip="מקבל אורחים" ></asp:Image>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                    <asp:TemplateField ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                                                                                                        <ItemTemplate>
                                                                                                            <asp:Label ID="lblFromHour" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                    <asp:TemplateField ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                                                                                                        <ItemTemplate>
                                                                                                            <asp:Label ID="lblToHour" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                    <asp:TemplateField ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Right">
                                                                                                        <ItemTemplate>
                                                                                                            <table cellpadding="0" cellspacing="0">
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        &nbsp&nbsp&nbsp
                                                                                                                        <asp:Label ID="lblReceptionRemarks" Width="400px" runat="server" Text='<%#Bind("receptionRemarks") %>'></asp:Label>
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </ItemTemplate>
                                                                                                    </asp:TemplateField>
                                                                                                </Columns>
                                                                                            </asp:GridView>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:GridView ID="gvFutureProfessionsReceptions" runat="server" AutoGenerateColumns="false"
                                        HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView" OnRowDataBound="gvFutureProfessionsReceptions_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="height: 30px; padding-right: 5px" align="right">
                                                                <asp:Label ID="lblProfessionsAndServicesHamesCaption" runat="server" EnableTheming="false"
                                                                    CssClass="LabelCaptionGreenBold_14" Text="תחום שירות: ">
                                                                </asp:Label>
                                                                <asp:Label ID="lblProfessionsAndServicesHames" runat="server" EnableTheming="false"
                                                                    CssClass="LabelCaptionGreenBold_14" Text='<%#Bind("professionOrServiceDescription") %>'>
                                                                </asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 5px; padding-bottom: 10px">
                                                                <div id="divExpire" runat="server">
                                                                    <asp:Label ID="lnkExpireWarning" runat="server" EnableTheming="false" CssClass="LooksLikeHRefBold"></asp:Label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <!-- Remarks-->
                    <tr id="trRemarksCaption" runat="server">
                        <td class="BackColorBlue" align="right" style="height:25px;width:600px; padding-right: 5px">
                            <asp:Label ID="lblRemarksCaption_DoctorInClinic" EnableTheming="false" CssClass="LabelBoldWhite"
                                runat="server" Text="הערות"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" style="padding-right: 0px; border: 1px solid #cccccc;">
                            <div class="ScrollBarDiv" style="height: 100px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <%--style="height: 108px; border: 1px solid #cccccc"--%>
                                    <asp:GridView ID="gvDoctorRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                        EmptyDataText="אין הערות לרופא\עובד" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                        OnRowDataBound="gvDoctorRemarks_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px" valign="top">
                                                                <div style="width: 15px;">
                                                                    <asp:Image ID="imgInternet" runat="server" />
                                                                </div>
                                                            </td>
                                                            <td valign="top">
                                                                &diams;&nbsp;
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblService" runat="server" Text='<% #Bind("ServiceName")%>' CssClass="LabelCaptionGreenBold_13" EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("remark")%>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>

                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr id="trRemarksCaption2" runat="server">
                        <td class="BackColorBlue" align="right" style="height:25px;width:600px; padding-right: 5px">
                            <asp:Label ID="Label1" EnableTheming="false" CssClass="LabelBoldWhite"
                                runat="server" Text="הערות ליחידה"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" style="padding-right: 0px; border: 1px solid #cccccc;">
                            <div class="ScrollBarDiv" style="height: 100px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <asp:GridView ID="gvClinicActivityRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                        AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                        OnRowDataBound="gvClinicActivityRemarks_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px" valign="top">
                                                                <div style="width: 15px;">
                                                                    <asp:Image ID="imgInternet" runat="server" />
                                                                </div>
                                                            </td>
                                                            <td>
                                                                &diams;&nbsp;
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("RemarkText")%>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                                <div dir="rtl">
                                    <asp:GridView ID="gvClinicRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                        AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                        OnRowDataBound="gvClinicRemarks_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px" valign="top">
                                                                <div style="width: 15px;">
                                                                    <asp:Image ID="imgInternet" runat="server" />
                                                                </div>
                                                            </td>
                                                            <td>
                                                                &diams;&nbsp;
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("RemarkText")%>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding: 5px 0px 5px 10px;" align="right">
                <table cellpadding="0" cellspacing="0" dir="rtl">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="btnClose" runat="server" Text="סגירה" CssClass="RegularUpdateButton"
                                OnClientClick="JQueryDialogClose();"></asp:Button>
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
    <div id="dialog-modal-select" title="Modal Dialog Select" style="display:none; vertical-align:top; width:100%;">
        <iframe id="modalSelectIFrame" style="width:100%; height:100%; background-color:white;" title="Dialog Title">
    </iframe>
    </div>
    </form>
    <script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>

    <script type="text/javascript">
        function OpenJQueryDialog(url, dialogWidth, dialogHeight, Title) {
            $('#dialog-modal-select').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-select').dialog("option", "width", dialogWidth);
            $('#dialog-modal-select').dialog("option", "height", dialogHeight);
            $('#dialog-modal-select').dialog("option", "title", Title);
            $('#dialog-modal-select').dialog('open');
            $('#dialog-modal-select').parent().appendTo($("form:first"));
            $("#modalSelectIFrame").attr('src', url);

            return false;
        }
    </script>
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</body>
</html>
