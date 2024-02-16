<%@ Page EnableEventValidation="false" Language="C#" AutoEventWireup="true" Inherits="Public_DeptServices" Codebehind="DeptServices.aspx.cs" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link type="text/css" rel="Stylesheet" href="~/css/general/general.css" />

    <%--<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>--%>
    <link rel="stylesheet" href="~/Scripts/jquery-ui/jquery-ui.css"/>

    <script type="text/javascript">
        var mainDirectory = document.location.toString().split(document.domain)[1].split("/")[1];

        function GetScrollPosition_DoctorsAndEmployees(obj) {
            document.getElementById('<%=txtScrollTop_divDoctorsAndEmployees.ClientID %>').value = obj.scrollTop;
        }

        function SetScrollPosition_DoctorsAndEmployees() {
            if (document.getElementById('<%=txtScrollTop_divDoctorsAndEmployees.ClientID %>').value != "") {
                var scrollPosition = document.getElementById('<%=txtScrollTop_divDoctorsAndEmployees.ClientID %>').value;
                document.getElementById("divDoctorsAndEmployees").scrollTop = scrollPosition;
            }
        }

        function OpenEventsWindow(ServiceOrEventCode) {
            var url = "Public/DeptEventPopUp.aspx?EventCode=" + ServiceOrEventCode;

            var dialogWidth = 670;
            var dialogHeight = 590;
            var title = "פעילות של מרפאה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function toggleHalfClock(itemCode, tablePrefix) {

            var tableArr = document.all.tags("table");
            var tableId;
            var partialTableId = tablePrefix + itemCode;
            var tblHours;
            var tagAid = 'ShowDoctorsOtherPlacesLink-' + itemCode;
            var tagA = document.getElementById(tagAid);

            for (var i = 0; i < tableArr.length; i++) {
                if (tableArr[i].id == null || tableArr[i].id == "")
                    continue;
                tableId = tableArr[i].id;

                if (tableId == partialTableId) {
                    tblHours = document.getElementById(tableId);

                    if (tblHours.style.display != "none") {
                        tblHours.style.display = "none";
                        tagA.innerText = "הצג";
                    }
                    else {
                        tblHours.style.display = "inline";
                        tagA.innerText = "הסתר";
                    }

                    break;
                }
            }
        }

        function ShowEmployeeSectorGridView(idSuffix) {
            var btnShowEmployeeSector = document.getElementById('imgShowEmployeeSector-' + idSuffix);
            var trEmployeeSector = document.getElementById('trEmployeeSector-' + idSuffix);
            if (trEmployeeSector.style.display != "none") {
                trEmployeeSector.style.display = "none";
                btnShowEmployeeSector.src = "../Images/Applic/btn_Plus_Blue_12.gif"

            }
            else {
                trEmployeeSector.style.display = "inline";
                btnShowEmployeeSector.src = "../Images/Applic/btn_Minus_Blue_12.gif"
            }
        }

        // ---- OpenDoctorReceptionWindow 
        function OpenDoctorReceptionWindow(deptEmployeeID, serviceCode, expirationDate) {
            if (serviceCode == -1)
                var strUrl = "DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&expirationDate=" + expirationDate;
            else
                var strUrl = "DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&serviceCode=" + serviceCode + "&expirationDate=" + expirationDate;

            var dialogWidth = 690;
            var dialogHeight = 680;
            var title = "שעות קבלה של נותן שירות ביחידה";

            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title, "right");
        }

        function goToService(employeeID) {

            window.parent.location.href = "/" + mainDirectory + "/public/zoomDoctor.aspx?employeeID=" + employeeID;
        }

        function GoToDept(deptCode) {
            window.parent.location.href = "/" + mainDirectory + "/public/ZoomClinic.aspx?deptCode=" + deptCode;
        }

        function setParentLocation(destPage, setScrollTop) {
            var qScrollTop = "";
            if (setScrollTop) {
                if (document.getElementById("<%=txtScrollTop_divDoctorsAndEmployees.ClientID %>").value != "") {
                    qScrollTop = "&scrtop=" + document.getElementById("<%=txtScrollTop_divDoctorsAndEmployees.ClientID %>").value;
                }
            }
            window.parent.location.href = "/" + mainDirectory + "/" + destPage + qScrollTop;
        }

        function ToggleQueueOrderPhonesAndHours(ToggleID, divNestID) {
            var tblID = "tblQueueOrderPhonesAndHours-" + ToggleID;
            //alert("divNestID=" + divNestID + ", ToggleID=" + ToggleID + ", tblID=" + tblID);  

            var tblQueueOrderPhonesAndHours = document.getElementById(tblID);
            var divQueueOrderPhonesAndHours = document.getElementById('divQueueOrderPhonesAndHours');
            var imgID = "imgOrderMethod-" + ToggleID;
            var closeLink = "<tr><td align='left' style='padding-left:5px'><img style='cursor:hand' src='../Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:closeQueueOrderPhonesAndHoursPopUp()' /> </td></tr>";

            var yPos = event.clientY + document.body.scrollTop; //getOBJposition(imgID, 'top');
            var xPos = event.clientX + document.body.scrollLeft - 20; //getOBJposition(imgID, 'left');

            //var divServicesAndEvents = document.getElementById("divServicesAndEvents");
            var divNest = document.getElementById(divNestID);

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
            divQueueOrderPhonesAndHours.style.left = xPos + 10;

            divQueueOrderPhonesAndHours.style.display = "inline";
        }

        function closeQueueOrderPhonesAndHoursPopUp() {
            var divPopUp = document.getElementById("divQueueOrderPhonesAndHours");

            divPopUp.style.display = "none";
        }


    </script>
</head>
<body onload="SetScrollPosition_DoctorsAndEmployees();">
    <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
        background-color: White;">
    </div>
    <form id="form1" runat="server">
    <div class="BackColorBlue" style="height: 29px;">
        <div style="float: right; margin-top: 5px; margin-right: 3px;">
            <asp:Image ID="imgAttributed_4" runat="server" ToolTip="שירותי בריאות כללית" />
        </div>
        <div style="float: right; margin-right: 10px; margin-top: 3px;">
            <asp:Label ID="lblDeptName_Employees" EnableTheming="false" CssClass="LabelBoldWhite_18"
                runat="server" Text=""></asp:Label>
        </div>
        <div style="float: left; margin-top: 4px; margin-left: 2px;" id="divUpdateDoctors"
            runat="server">
            <table cellpadding="0" cellspacing="0" style="direction:rtl;">
                <tr>
                    <td class="buttonRightCorner">
                    </td>
                    <td class="buttonCenterBackground">
                        <asp:Button ID="btnAddDoctors" CssClass="RegularUpdateButton" runat="server" OnClick="btnAddDoctors_Click"
                        Text="הוספת נותן שירות" Width="120px" />
                        
                        
                    </td>
                    <td class="buttonLeftCorner">
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <table id="tblDoctorsAndEmployees" cellpadding="0" cellspacing="0" 
        style="border: solid 1px #D4EAFB;background-color: White;width:100%;direction:rtl;">
        <tr id="trGVEmployeeHeaders">
            <td style="background-color: #F7FAFF" id="tdSortingButtons" runat="server">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 30px; padding-right: 15px; padding-left: 4px" valign="top">
                            <asp:Label ID="lblReceptionEmployeeCaption" EnableTheming="false" CssClass="ColumnHeader"
                                Width="30px" Height="35px" runat="server" Text="שעות קבלה"></asp:Label>
                        </td>
                        <td style="width: 223px; padding-right: 4px" valign="top">
                            <uc1:SortableColumnHeader ID="columnDoctorName" runat="server" OnSortClick="btnSort_click"
                                Text="שם" ColumnIdentifier="DoctorNameNoTitle" />
                        </td>
                        <td style="width: 137px" align="right" valign="top">
                            <uc1:SortableColumnHeader ID="columnProfessions" runat="server" Text="מקצועות" OnSortClick="btnSort_click"
                                ColumnIdentifier="Professions" />
                        </td>
                        <td style="width: 155px" align="right" valign="top">
                            <uc1:SortableColumnHeader ID="columnServices" runat="server" OnSortClick="btnSort_click"
                                Text="שירותים" ColumnIdentifier="ServiceDescription" />
                        </td>
                        <td style="width: 132px" align="right" valign="top">
                            <asp:Label ID="LblQueueOrder" EnableTheming="false" CssClass="ColumnHeader" runat="server"
                                Text="זימון ביקור"></asp:Label>
                        </td>
                        <td style="width: 60px; padding-top: 0px" align="right">
                            <uc1:SortableColumnHeader Width="40" ID="SortableColumnHeader1" runat="server" OnSortClick="btnSort_click"
                                Text="יחידות נוספות" ColumnIdentifier="HasAnotherWorkplace" />
                        </td>
                        <td style="width: 110px; padding-right: 3px" align="right" valign="top">
                            <uc1:SortableColumnHeader ID="columnPhone" runat="server" OnSortClick="btnSort_click"
                                Text="טלפונים" ColumnIdentifier="phones" />
                        </td>
                        <td align="right" valign="top">
                            <uc1:SortableColumnHeader ID="columnAgreementType" runat="server" OnSortClick="btnSort_click"
                                Text="סוג הסכם" ColumnIdentifier="AgreementType" />
                        </td>
                    </tr>
                </table>
                <asp:HiddenField ID="txtScrollTop_divDoctorsAndEmployees" runat="server" />
                
            </td>
        </tr>
        <tr>
            <td valign="top" dir="ltr">
                <div id="divDoctorsAndEmployees" onscroll="GetScrollPosition_DoctorsAndEmployees(this)"
                    style="height: 297px; overflow-y: scroll" class="ScrollBarDiv">
                    <div dir="rtl">
                        <table cellpadding="0" cellspacing="0" width="970px">
                            <tr>
                                <td valign="top">
                                    <asp:GridView ID="gvEmployeeSectorHeaders" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                        HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false" OnRowDataBound="gvEmployeeSectorHeaders_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr id="trEmployeeSectorCaption" style="background-color: #E8F4FD">
                                                            <td style="width: 980px; padding: 0px 0px 0px 0px">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="padding-right: 5px; height: 25px;">
                                                                            <img alt="רשימת רופאים\עובדים" id='imgShowEmployeeSector-<%#Eval("EmployeeSectorCode") %>'
                                                                                style="cursor: pointer" src="../Images/Applic/btn_Minus_Blue_12.gif" onclick="ShowEmployeeSectorGridView('<%#Eval("EmployeeSectorCode") %>');" />
                                                                        </td>
                                                                        <td style="padding-right: 5px;" align="right" valign="top">
                                                                            <asp:Label ID="lblEmployeeSectorCaption" CssClass="LabelCaptionBlue_14" EnableTheming="false"
                                                                                runat="server" Text='<%#Eval("EmployeeSectorDescriptionForCaption") %>'></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr id='trEmployeeSector-<%#Eval("EmployeeSectorCode") %>'>
                                                            <td style="padding: 0px 0px 0px 0px">
                                                                <asp:GridView ID="gvDoctors" runat="server" AutoGenerateColumns="false" OnRowDataBound="gvDoctors_RowDataBound"
                                                                    Width="100%" SkinID="GridViewForSearchResults" >
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table cellpadding="0" cellspacing="0" border="0">
                                                                                    <tr>
                                                                                        <td valign="top">
                                                                                            <div style="width: 30px; padding-right: 2px">
                                                                                                <asp:Image ID="imgClock" runat="server" ToolTip="שעות פעילות" EnableTheming="false"
                                                                                                    CssClass="DisplayNone" />
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top" style="width:222px;">
                                                                                            <div style="width: 200px; padding-right: 3px">
                                                                                                <a id="aDoctorLink"
                                                                                                    runat="server" class="LooksLikeHRef">
                                                                                                <%# Eval("DoctorName")%></a>
                                                                                                
                                                                                                <br />
                                                                                                <asp:Label ID="lblDoctorsName" runat="server" Text='<%#Eval("DoctorName")%>' Visible="false"></asp:Label>
                                                                                                <asp:Label ID="lblExpert" runat="server" Text='<%#Bind("expert")%>'></asp:Label>
                                                                                                <asp:GridView ID="gvPositions" runat="server" AutoGenerateColumns="false" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    >
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="positionDescription">
                                                                                                            <HeaderStyle CssClass="DisplayNone" />
                                                                                                        </asp:BoundField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <div style="width: 138px">
                                                                                                <asp:GridView ID="gvProfessions" runat="server" Width="138px" AutoGenerateColumns="false"
                                                                                                    HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridViewNoEmtyDataText" >
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="professionDescription" ItemStyle-CssClass="SimpleBold" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top" align="right">
                                                                                            <div style="width: 150px">
                                                                                                <asp:GridView ID="gvServices" runat="server" Width="150px" AutoGenerateColumns="false"
                                                                                                    HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridViewNoEmtyDataText" >
                                                                                                    <Columns>
                                                                                                        <asp:BoundField DataField="serviceDescription" ItemStyle-CssClass="SimpleBold" />
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <div style="width: 25px; padding-right: 2px">
                                                                                                <asp:Image ID="imgReceiveGuests" runat="server" EnableTheming="false" />
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <table id="tblEmployeeQueueOrderMethods" runat="server" width="100px">
                                                                                                <tr>
                                                                                                    <td id="tdEmployeeQueueOrderMethods" class="QueueOrderText" runat="server" valign="bottom"
                                                                                                        align="right">
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                            <table id='tblQueueOrderPhonesAndHours-<%# Eval("ToggleID") %>' style="display: none"
                                                                                                cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td dir="ltr" align="right">
                                                                                                        <asp:Label ID="lblEmployeeQueueOrderPhones" runat="server"></asp:Label>
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td dir="rtl">
                                                                                                        <asp:GridView ID="gvEmployeeQueueOrderHours" runat="server" EnableTheming="false"
                                                                                                            GridLines="None" AutoGenerateColumns="false" HeaderStyle-CssClass="HeaderStyleBlueBold"
                                                                                                            >
                                                                                                            <Columns>
                                                                                                                <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC"
                                                                                                                    ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
                                                                                                                <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                                                                    <ItemTemplate>
                                                                                                                        <div style="padding-right: 5px; border-bottom: 1px solid #BADBFC; border-top: 1px solid #BADBFC;">
                                                                                                                            <asp:Label ID="lblServiceQueueOrderHours_From" CssClass="RegularLabel" runat="server"
                                                                                                                                Text='<%#Eval("FromHour") %>'></asp:Label>
                                                                                                                        </div>
                                                                                                                    </ItemTemplate>
                                                                                                                </asp:TemplateField>
                                                                                                                <asp:TemplateField HeaderText="עד שעה" ItemStyle-Width="45px">
                                                                                                                    <ItemTemplate>
                                                                                                                        <div style="width: 100%; padding-right: 7px; border-bottom: 1px solid #BADBFC; border-top: 1px solid #BADBFC;">
                                                                                                                            <asp:Label ID="lblServiceQueueOrderHours_To" CssClass="RegularLabel" runat="server"
                                                                                                                                Text='<%#Eval("ToHour") %>'></asp:Label>
                                                                                                                        </div>
                                                                                                                    </ItemTemplate>
                                                                                                                </asp:TemplateField>
                                                                                                            </Columns>
                                                                                                        </asp:GridView>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>

                                                                                        <td valign="top" style="width: 62px; padding-right: 10px">
                                                                                            <asp:PlaceHolder ID="pnlHalfClock" runat="server"><a class="LooksLikeHRef" id='ShowDoctorsOtherPlacesLink-<%# Eval("ToggleID") %>'
                                                                                                href='javascript:toggleHalfClock(<%# Eval("ToggleID") %>,"tblDoctorsOtherPlaces-")'>
                                                                                                הצג </a></asp:PlaceHolder>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <div style="width: 140px">
                                                                                                <asp:GridView ID="gvEmployeePhones" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <div style="margin-top: 2px">
                                                                                                                    <asp:Label ID="lblPhoneTypeName" Width="25px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                                                        runat="server" Text="טל'"></asp:Label>
                                                                                                                    <asp:Label ID="lblPhone" runat="server" Text="<%# Container.DataItem %>"></asp:Label>
                                                                                                                </div>
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                                <asp:GridView ID="gvEmployeeFaxes" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <div style="margin-top: 2px">
                                                                                                                    <asp:Label ID="lblPhoneTypeName" Width="25px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                                                        runat="server" Text='פקס'></asp:Label>
                                                                                                                    <asp:Label ID="lblPhone" runat="server" Text="<%# Container.DataItem %>"></asp:Label>
                                                                                                                </div>
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <div style="width: 30px; padding-top: 3px;">
                                                                                                <asp:Image ID="imgAgreementType" runat="server" />
                                                                                            </div>
                                                                                        </td>
                                                                                        <td valign="top">
                                                                                            <asp:PlaceHolder ID="pnlEditButton" runat="server">
                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <table cellpadding="0" cellspacing="0">
                                                                                                                <tr>
                                                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                                        background-position: bottom left;">
                                                                                                                        &nbsp;
                                                                                                                    </td>
                                                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                                                        <input type="button" style="width:35px;" class="RegularUpdateButton" onclick="setParentLocation('Admin/UpdateDeptEmployee.aspx?DeptEmployeeID=<%# Eval("deptEmployeeID") + "_" + Eval("rowID")%>&seltab=tb_services',true);"
                                                                                                                        value="עדכון" />
                                                                                                                        
                                                                                                                        
                                                                                                                    </td>
                                                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                                                        background-repeat: no-repeat;">
                                                                                                                        &nbsp;
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </td>
                                                                                                        <td style="padding-top: 4px">
                                                                                                            <asp:ImageButton ID="btnDeleteDoctorInClinic" EnableTheming="false" CssClass="DisplayNone"
                                                                                                                runat="server" ImageUrl="../Images/Applic/btn_X_red.gif" DeptEmployeeID='<%# Eval("DeptEmployeeID")%>'
                                                                                                                OnClick="btnDeleteDoctorInClinic_Click" 
                                                                                                                OnClientClick="return confirm('!שים לב, הנך עומד למחוק את נותן שירות ביחידה על כל שירותיו\n\r.על מנת למחוק שירות ספציפי יש להיכנס לעדכון נותן שירות ולבצע את המחיקה משם\n\r?האם הנך בטוח שברצונך למחוק את הרופא/עובד ביחידה')">
                                                                                                            </asp:ImageButton>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </asp:PlaceHolder>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr id="trEmployeeRemarks" runat="server">
                                                                                        <td colspan="10" style="padding-right:40px; padding-bottom:15px" >
                                                                                            <asp:Label ID="lblEmployeeRemarks" runat="server" Text="Employee abcence remark Employee abcence remark" CssClass="RemarkLabel" EnableTheming="false"></asp:Label>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                                <table cellpadding="0" cellspacing="0" style="width: 100%">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <table id='tblDoctorsOtherPlaces-<%# Eval("ToggleID") %>' class="SimpleText" cellpadding="0"
                                                                                                cellspacing="0" style="display: none; color: #505050;">
                                                                                                <tr>
                                                                                                    <td align="center" style="height: 8px; width: 670px; border-bottom: 2px solid #00AAEE;">
                                                                                                        &nbsp;
                                                                                                    </td>
                                                                                                    <td valign="bottom" style="width: 12px; background-position: bottom; background-image: url('../Images/Applic/pointer_blue.gif');
                                                                                                        background-repeat: no-repeat;">
                                                                                                    </td>
                                                                                                    <td style="width: 270px; border-bottom: 2px solid #00AAEE">
                                                                                                        &nbsp;
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td colspan="3" style="background-color: White; width: 100%; border-bottom: 2px solid #00AAEE;
                                                                                                        border-left: 2px solid #00AAEE; border-right: 2px solid #00AAEE" align="center">
                                                                                                        <!-- Other work places-->
                                                                                                        <asp:GridView ID="gvDoctorsOtherWorkPlaces" runat="server" AutoGenerateColumns="false"
                                                                                                            Width="100%" OnRowDataBound="gvDoctorsOtherWorkPlaces_RowDataBound" SkinID="SimpleGridView"
                                                                                                            HeaderStyle-CssClass="DisplayNone" >
                                                                                                            <Columns>
                                                                                                                <asp:TemplateField ItemStyle-HorizontalAlign="Right">
                                                                                                                    <ItemTemplate>
                                                                                                                        <table cellpadding="0" cellspacing="0" border="0" style="border-bottom: 1px solid #cccccc">
                                                                                                                            <tr>
                                                                                                                                <td valign="top" style="width: 20px">
                                                                                                                                    <asp:Image ID="imgClock" runat="server" ToolTip="שעות פעילות" EnableTheming="false"
                                                                                                                                        CssClass="DisplayNone" />
                                                                                                                                </td>
                                                                                                                                <td valign="top" align="right" style="width: 210px;">
                                                                                                                                    <div onclick="GoToDept('<%# Eval("deptCode") %>')" style="padding-right: 10px">
                                                                                                                                        <asp:Label ID="lblSubClinicName" runat="server" CssClass="LooksLikeHRef" EnableTheming="False"
                                                                                                                                            Text='<%# Eval("deptName") %>'></asp:Label>
                                                                                                                                    </div>
                                                                                                                                </td>
                                                                                                                                <td valign="top" align="right" style="width: 130px; padding-right: 23px">
                                                                                                                                    <asp:GridView ID="gvDoctorsOtherWorkPlacesProfessions" runat="server" AutoGenerateColumns="false"
                                                                                                                                        SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" >
                                                                                                                                        <Columns>
                                                                                                                                            <asp:BoundField DataField="professionDescription">
                                                                                                                                                <ItemStyle CssClass="RegularLabel" />
                                                                                                                                            </asp:BoundField>
                                                                                                                                        </Columns>
                                                                                                                                    </asp:GridView>
                                                                                                                                </td>
                                                                                                                                <td valign="top" align="right" style="width: 160px;">
                                                                                                                                    <asp:GridView ID="gvDoctorsOtherWorkPlacesServices" runat="server" AutoGenerateColumns="false"
                                                                                                                                        SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" >
                                                                                                                                        <Columns>
                                                                                                                                            <asp:BoundField DataField="serviceDescription">
                                                                                                                                                <ItemStyle CssClass="RegularLabel" />
                                                                                                                                            </asp:BoundField>
                                                                                                                                        </Columns>
                                                                                                                                    </asp:GridView>
                                                                                                                                </td>
                                                                                                                                <td valign="top">
                                                                                                                                    <div style="padding-top: 3px; margin-right: 303px">
                                                                                                                                        <asp:Image ID="imgAgreementType" runat="server" />
                                                                                                                                    </div>
                                                                                                                                </td>
                                                                                                                            </tr>
                                                                                                                        </table>
                                                                                                                    </ItemTemplate>
                                                                                                                </asp:TemplateField>
                                                                                                                <asp:TemplateField ItemStyle-VerticalAlign="Top" HeaderText="שעות קבלה">
                                                                                                                    <ItemTemplate>
                                                                                                                        <asp:GridView ID="gvDoctorsOtherWorkPlacesHours" runat="server" SkinID="SimpleGridViewEmptyDataNotDefined"
                                                                                                                            HeaderStyle-CssClass="DisplayNone" AutoGenerateColumns="false" >
                                                                                                                            <Columns>
                                                                                                                                <asp:BoundField DataField="ReceptionDayName" ItemStyle-Width="25px" ItemStyle-CssClass="SimpleBold" />
                                                                                                                                <asp:BoundField DataField="openingHour" ItemStyle-Width="50px" />
                                                                                                                                <asp:BoundField DataField="closingHour" />
                                                                                                                            </Columns>
                                                                                                                        </asp:GridView>
                                                                                                                    </ItemTemplate>
                                                                                                                    <ItemStyle CssClass="DisplayNone" />
                                                                                                                </asp:TemplateField>
                                                                                                            </Columns>
                                                                                                        </asp:GridView>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                            <HeaderStyle CssClass="DisplayNone" />
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
                <!-- פעילויות -->
                <div id="divServicesAndEvents" runat="server" style="height: 105px; direction: ltr;
                    margin-top: 20px;">
                    <div style="direction: rtl;">
                        <div style="background-color: #e8f4fd;margin-left:2px;">
                        <table cellpadding="0" cellspacing="0" style="width: 100%; ">
                            <tr>
                                <td>
                                <div style="float:right;height:25px;padding-top:3px;">
                                    <span id="spanImg" runat="server">
                                    <img id="imgShowEmployeeSector-20" style="cursor: hand;" onclick="ShowEmployeeSectorGridView('20');" alt="פעילויות" src="../Images/Applic/btn_Minus_Blue_12.gif" />
                                    </span>
                                    <span class="LabelCaptionBlue_14">פעילויות</span>
                                </div>
                                <div style="float:left;margin-top:4px;margin-left:2px;" id="divUpdateEvents" runat="server">
		                            <table cellpadding="0" cellspacing="0">
			                            <tr>
				                            <td class="buttonRightCorner">
				                            </td>
				                            <td class="buttonCenterBackground">
					                            <asp:Button ID="btnUpdateEvents" runat="server" CssClass="RegularUpdateButton"
                                                    Width="100px" Text="הוספת פעילות" OnClick="btnUpdateEvents_Click" />
                                                
				                            </td>
				                            <td class="buttonLeftCorner">
				                            </td>
			                            </tr>
		                            </table>
	                            </div>
                                </td>
                            </tr>
                        </table>
                        </div>
                        <asp:Label ID="lblNoEvents" runat="server" Text="אין מידע" CssClass="RegularLabel" Visible="false"></asp:Label>
                        <table style="clear:both;" id="tblEvents" cellpadding="0" cellspacing="0">
                            <tr id="trEmployeeSector-20">
                                <td colspan="2">
                                    <table id="tblEventsHeader" runat="server" cellpadding="0" cellspacing="0" border="0">
                                        <tr style="background-color: #F7FaFF">
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td align="center" valign="top" style="padding-right: 45px">
                                                            <asp:Label ID="lblEventsDetailsCaption" EnableTheming="false" CssClass="ColumnHeader"
                                                                Width="52px" Height="30px" runat="server" Text="פרטי מפגשים"></asp:Label>
                                                        </td>
                                                        <td align="right" valign="top" style="padding-right: 10px">
                                                            <asp:Label ID="lblEventsNameCaption" Width="285px" EnableTheming="false" CssClass="ColumnHeader"
                                                                runat="server" Text="שם פעילות"></asp:Label>
                                                        </td>
                                                        <td align="right" valign="top">
                                                            <asp:Label ID="lblEventsDescriptionCaption" Width="303px" EnableTheming="false" CssClass="ColumnHeader"
                                                                runat="server" Text="תיאור"></asp:Label>
                                                        </td>
                                                        <td valign="top">
                                                            <asp:Label ID="lblEventsPhonesCaption" EnableTheming="false" CssClass="ColumnHeader"
                                                                runat="server" Text="טלפון לבירורים"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div style="height: 37px; overflow-y: scroll; direction: ltr" class="ScrollBarDiv">
                                                    <div dir="rtl">
                                                    <asp:GridView ID="gvEvents" runat="server" SkinID="GridViewForSearchResults" AutoGenerateColumns="false"
                                                        HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvEvents_RowDataBound" >
                                                        
                                                        <Columns>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <table cellpadding="0" cellspacing="0" border="0" dir="rtl" style="margin-right: 3px">
                                                                        <tr>
                                                                            <td>
                                                                                <div style="width: 25px">
                                                                                    <asp:Image ID="imgNoInternet" runat="server" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif"
                                                                                        Visible="false" />
                                                                                </div>
                                                                            </td>
                                                                            <td valign="top" style="padding-top: 3px;width:60px;">
                                                                                <asp:Image ID="imgClock" runat="server" style="margin-right:9px;" border="0" alt="פרטי מפגשים" />
                                                                            </td>
                                                                            <td valign="top" style="width:288px;vertical-align:top;">
                                                                                <asp:Label ID="lblEventName" runat="server" Text='<%#Bind("EventName") %>'></asp:Label>
                                                                            </td>
                                                                            <td style="width:302px;vertical-align:top;">
                                                                                <asp:Label ID="lblEventDescription" runat="server" Text='<%#Bind("EventDescription") %>'></asp:Label>
                                                                            </td>
                                                                            <td valign="top" style="width: 216px">
                                                                                <asp:GridView ID="gvEventPhones" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                    AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" Width="100%" EnableViewState="false">
                                                                                    <Columns>
                                                                                        <asp:TemplateField>
                                                                                            <ItemTemplate>
                                                                                                <asp:Label ID="lblPhoneTypeName" Width="25px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                                    runat="server" Text='<%#Eval("shortPhoneTypeName") %>'></asp:Label>
                                                                                                <asp:Label Width="115px" ID="lblPhone" runat="server" Text='<%# Eval("phone") %>'></asp:Label>
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                    </Columns>
                                                                                </asp:GridView>
                                                                            </td>
                                                                            <td valign="top" style="padding-left: 3px" align="left">
                                                                                <div style="width: 70px">
                                                                                    
                                                                                    <asp:PlaceHolder ID="pnlEditButton" runat="server">
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <table cellpadding="0" cellspacing="0">
                                                                                                        <tr>
                                                                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                                background-position: bottom left;">
                                                                                                                &nbsp;
                                                                                                            </td>
                                                                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                                                                
                                                                                                                <input type="button" style="width:35px;" class="RegularUpdateButton" value="עדכון"
                                                                                                                 onclick="setParentLocation('Admin/UpdateClinicEvents.aspx?eventID=<%# Eval("DeptEventID")%>&seltab=tb_services',false);" />
                                                                                                            </td>
                                                                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                                                background-repeat: no-repeat;">
                                                                                                                &nbsp;
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </td>
                                                                                                <td style="padding-top: 4px">
                                                                                                    <asp:ImageButton ID="btnDeleteEvent" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                                        DeptEventID='<%# Eval("DeptEventID")%>' OnClick="btnDeleteEvent_Click" ToolTip="מחיקה"
                                                                                                        OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את הפעילות ביחידה')">
                                                                                                    </asp:ImageButton>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </asp:PlaceHolder>
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
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <div id="dialog-modal-select" title="Modal Dialog Select" style="display:none; vertical-align:top; width:100%;">
        <iframe id="modalSelectIFrame" style="width:100%; height:100%; background-color:white;" title="Dialog Title">
    </iframe>
    </div>
    </form>
    <%--<script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>--%>
    <%--<script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>--%>
    <script type="text/javascript" src="../Scripts/jquery/jquery.js"></script> 
    <script type="text/javascript" src="../Scripts/jquery-ui/jquery-ui.js"></script>

    <script type="text/javascript">
        function OpenJQueryDialog(url, dialogWidth, dialogHeight, Title, alignTitle) {
            $('#dialog-modal-select').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-select').dialog("option", "width", dialogWidth);
            $('#dialog-modal-select').dialog("option", "height", dialogHeight);
            $('#dialog-modal-select').dialog("option", "title", Title);
            $('#dialog-modal-select').dialog('open');
            $('#dialog-modal-select').parent().appendTo($("form:first"));

            if (alignTitle == "right") {
                $('#dialog-modal-select').dialog("widget").find(".ui-dialog-title").css("text-align", "right");
                $('#dialog-modal-select').dialog("widget").find(".ui-dialog-title").css("right", "5px");
            }
            else {
                $('#dialog-modal-select').dialog("widget").find(".ui-dialog-title").css("text-align", "left");
                $('#dialog-modal-select').dialog("widget").find(".ui-dialog-title").css("left", "5px");
            }

            $("#modalSelectIFrame").attr('src', url);

            return false;
        }
    </script>
</body>
</html>
