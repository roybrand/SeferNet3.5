<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="ServiceHoursPopUp" Theme="SeferGeneral" Codebehind="ServiceHoursPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>שעות קבלה לשירות</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="~/CSS/General/general.css" type="text/css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>

    <script type="text/javascript">
        function OpenServiceExpirationWindow(deptCode, deptOrEmployeeCode, serviceCode,agreementType, viaPerson, expirationDate) {

            var strUrl = "ServiceHoursPopUp.aspx?deptCode=" + deptCode +
                "&deptOrEmployeeCode=" + deptOrEmployeeCode +
                "&serviceCode=" + serviceCode +
                "&agreementType=" + agreementType +
                "&viaPerson=" + viaPerson +
                "&expirationDate=" + expirationDate;
            var dialogWidth = 600;
            var dialogHeight = 620;
            var title = "שעות קבלה לשירות";

            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title);
        }

        function closeQueueOrderPhonesAndHoursPopUp() {
            document.getElementById("divQueueOrderPhonesAndHours").style.display = "none";
        }

        function ToggleQueueOrderPhonesAndHours(ToggleID) {
            
            var tblID = "tblQueueOrderPhonesAndHours";

            var tblQueueOrderPhonesAndHours = document.getElementById(tblID);
            var divQueueOrderPhonesAndHours = document.getElementById('divQueueOrderPhonesAndHours');
            var imgID = "imgOrderMethod-" + ToggleID;
            var shiftY = 15;
            var closeLink = "<tr><td align='left' style='padding-left:5px'><img style='cursor:hand' src='../Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:closeQueueOrderPhonesAndHoursPopUp()' /> </td></tr>";

            var yPos = event.clientY + document.body.scrollTop;
            var xPos = event.clientX + document.body.scrollLeft - 20;


            divQueueOrderPhonesAndHours.innerHTML =
            "<table cellpadding='0' cellspacing='0' style='background-color:White; border-top:solid 1px #555555; border-left:solid 1px #555555; border-bottom:solid 2px #888888; border-right:solid 2px #888888;'>" +
                "<tr><td>" +
                    "<table width='100%'>" +
                        tblQueueOrderPhonesAndHours.innerHTML +
                    "</table>" +
                "</td></tr>" +
                closeLink +
            "</table>";

            divQueueOrderPhonesAndHours.style.top = yPos + 10;
            divQueueOrderPhonesAndHours.style.left = xPos + 20;


            divQueueOrderPhonesAndHours.style.display = "inline";
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    
    <table cellpadding="0" cellspacing="0" width="100%" style="height: 100%">
        <tr align="right">
            <td style="height: 100%">
                <table dir="rtl" id="tblServiceHours" width="100%" class="SimpleText" cellpadding="0" cellspacing="0"
                    style="background-color: white;">
                    <tr align="right" id="ServiceHoursCaption">
                        <td align="right" style="height: 37px;padding-right:15px; vertical-align: middle;" class="BackColorBlue">
                            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                <tr>
                                    <td style="padding-right: 5px;width:63%;" valign="middle">
                                        <asp:Label ID="lblEmployeeName" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                        &nbsp;
                                        <asp:Label ID="lblDeptName_ServiceHours" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                    <td rowspan="2" style="vertical-align:top;">
                                        <div class="LabelBoldWhite" lang="he" runat="server" style="margin-top:4px;text-align:left;margin-left:5px;" id="divDeptPhones_ServiceHours"></div>
                                    </td>
                                    
                                </tr>
                                <tr>
                                    <td style="padding-right:5px">
                                        <asp:Label ID="lblDeptAddress_ServiceHours" EnableTheming="false" CssClass="LabelBoldWhite"
                                            runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr align="right">
                        <td style="border: 1px solid #cccccc; width:100%" align="center">
                            <div class="ScrollBarDiv" style="height: 250px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td colspan="2" style="height: 30px; padding-right: 5px;text-align:right;">
                                                <asp:Label ID="lblServiceName" runat="server" EnableTheming="false" CssClass="LabelCaptionDarkGreenBold_14"
                                                    Text="שעות קבלה ל - "></asp:Label>
                                                <asp:Label ID="lblFromExpDate" runat="server" EnableTheming="false" CssClass="LabelCaptionDarkGreenBold_14"
                                                    Text=""></asp:Label>
                                                
                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="text-align:right;padding-right: 5px;">
                                                <div id="divServicePhoneAndFaces" lang="he" runat="server" class="LabelCaptionGreenBold_13"></div>
                                            </td>
                                            <td style="text-align:left;">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="vertical-align:top; padding-left:10px">
                                                            <span id="spanQueueOrderCaption" runat="server" class="LabelCaptionGreenBold_13" style="float:left;display:none;">ניתן לזמן ב:&nbsp;</span>        
                                                        </td>
                                                        
                                                        <td style="vertical-align:middle;">
                                                            <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
                                                                background-color: White;">
                                                            </div>
                                                
                                                            <div style="float:left;">
                                                    
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td id="tdEmployeeQueueOrderMethods" class="QueueOrderText" runat="server" valign="bottom"
                                                                            align="right">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                                <table id='tblQueueOrderPhonesAndHours' style="display: none;"
                                                                    cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td dir="ltr" align="right">
                                                                            <asp:Label ID="lblQueueOrderPhones" Width="80px" runat="server"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:GridView ID="gvQueueOrderHours" runat="server" EnableTheming="false" GridLines="None"
                                                                                AutoGenerateColumns="false" HeaderStyle-CssClass="LabelCaptionBlueBold_12" BorderWidth="1px"
                                                                                BorderStyle="Solid" BorderColor="#BADBFC">
                                                                                <Columns>
                                                                                    <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC"
                                                                                        ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
                                                                                    <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                                        <ItemTemplate>
                                                                                            <table cellpadding="0" cellspacing="0" style="width: 45px; border-bottom: 1px solid #BADBFC;
                                                                                                border-top: 1px solid #BADBFC;">
                                                                                                <tr>
                                                                                                    <td align="center">
                                                                                                        <asp:Label ID="lblServiceQueueOrderHours_From" CssClass="RegularLabel" runat="server"
                                                                                                            Text='<%#Eval("FromHour") %>'></asp:Label>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField HeaderText="עד שעה" ItemStyle-Width="45px">
                                                                                        <ItemTemplate>
                                                                                            <table cellpadding="0" cellspacing="0" style="width: 45px; border-bottom: 1px solid #BADBFC;
                                                                                                border-top: 1px solid #BADBFC;">
                                                                                                <tr>
                                                                                                    <td align="center">
                                                                                                        <asp:Label ID="lblServiceQueueOrderHours_To" CssClass="RegularLabel" runat="server"
                                                                                                            Text='<%#Eval("ToHour") %>'></asp:Label>
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
                                                            </div>        
                                                        </td>
                                                        
                                                    </tr>
                                                </table>
                                                
                                                
                                            </td>
                                        </tr>
                                        
                                        <tr>
                                            <td colspan="2" style="padding-right:5px;">
                                                <div id="divExpirationAlert" runat="server" visible="false">
                                                    <asp:Label ID="lblExpirationAlert" runat="server"  EnableTheming="false" CssClass="LooksLikeHRefBold" />&nbsp;                                                                                                
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="right" style="vertical-align:top;border-top:1px solid #B5D9FD;">
                                                <table cellpadding="0" cellspacing="0" border="0" style="margin-top:6px;">
                                                    <tr>
                                                        <td style="width: 32px" align="center">
                                                            <asp:Label ID="lblDay" runat="server" Text="יום" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                        </td>
                                                        <td style="width: 25px" align="center"><!-- Receive guests  -->
                                                        </td>
                                                        <td style="width: 63px" align="center">
                                                            <asp:Label ID="lblFromHour" runat="server" Text="משעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                        </td>
                                                        <td style="width: 75px" align="center">
                                                            <asp:Label ID="lblToHour" runat="server" Text="עד שעה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                        </td>
                                                        <td style="width: 380px;" align="right">
                                                            <asp:Label ID="lblRemarks" runat="server" Text="הערות" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div style="background-color:#B5D9FD;font-size:1px;height:2px;margin-right:2px;margin-top:5px;"></div>
                                                <asp:GridView ID="gvServiceReceptionDays" runat="server" AutoGenerateColumns="false"
                                                    SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvServiceReceptionDays_RowDataBound">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <table cellpadding="0" cellspacing="0" class="BorderBottomBlue">
                                                                    <tr>
                                                                        <td style="width: 32px; background-color: #E1F0FC;" align="center">
                                                                            <asp:Label ID="lblDay" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                                                        </td>
                                                                        <td>
                                                                            <asp:GridView ID="gvReceptionHours" runat="server" AutoGenerateColumns="false" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvReceptionHours_RowDataBound">
                                                                                <Columns>
                                                                                    <asp:TemplateField ItemStyle-Width="25px" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:Image ID="imgReceiveGuests" runat="server" ImageUrl="~/Images/Applic/ReceiveGuestsSmall.png" ToolTip="מקבל אורחים" ></asp:Image>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField ItemStyle-Width="60px" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:Label ID="lblFromHour" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                    <asp:TemplateField ItemStyle-Width="75px" ItemStyle-HorizontalAlign="Center">
                                                                                        <ItemTemplate>
                                                                                            <asp:Label ID="lblToHour" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>

                                                                                    <asp:TemplateField ItemStyle-Width="400px" ItemStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Middle">
                                                                                        <ItemTemplate>                                                                                           
                                                                                            <asp:Label ID="lblReceptionRemarks" Width="300px" runat="server" Text='<%#Bind("receptionRemarks") %>'></asp:Label>
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
                                </div>
                            </div>
                        </td>
                    </tr>
                    <!-- Remarks-->
                    <tr>
                        <td>
                            <div style="background-color: #2889E4;text-align:right;margin-top:10px;padding-right:20px;">
                                <asp:Label ID="lblRemarksCaption" EnableTheming="false" CssClass="LabelBoldWhite"
                                    runat="server" Text="הערות"></asp:Label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" style="width:100%; border: 1px solid #cccccc;">
                            <div class="ScrollBarDiv" style="height: 100px; padding-right:10px; overflow-x: hidden; overflow-y: scroll;"
                                dir="ltr">
                                <div dir="rtl">
                                    <%--style="height: 108px; border: 1px solid #cccccc"--%>
                                    <asp:GridView ID="gvRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                        EmptyDataText="אין הערות לשרות" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                        OnRowDataBound="gvRemarks_RowDataBound">
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
                    <tr>
                        <td>
                            <div style="background-color: #2889E4;text-align:right;margin-top:10px;padding-right:20px;">
                                <asp:Label ID="lblClinicRemarkHeader" runat="server" Width="380px" CssClass="LabelBoldWhite" EnableTheming ="false">הערות ליחידה</asp:Label> 
                            </div>
                            <div style="height: 110px; overflow-y: scroll;direction:ltr;" class="ScrollBarDiv">
                                <div style="direction:rtl; float:right; width:390px;">
                                    <asp:GridView ID="gvClinicRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                    EmptyDataText="אין הערות לרופא\עובד" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                    OnRowDataBound="gvClinicRemarks_RowDataBound" Width="390px">
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
                                                        <td style="vertical-align:top">
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
        <tr align="left">
            <td style="padding: 5px 0px 5px 20px;" align="left">
                <table cellpadding="0" cellspacing="0" dir="rtl">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="Button1" runat="server" Text="סגירה" CssClass="RegularUpdateButton"
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
