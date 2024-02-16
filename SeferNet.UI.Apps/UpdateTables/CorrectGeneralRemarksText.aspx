
<%@ Page Title="" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master" AutoEventWireup="true" CodeBehind="CorrectGeneralRemarksText.aspx.cs" Inherits="SeferNet.UI.Apps.UpdateTables.CorrectGeneralRemarksText" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />
    <script type="text/javascript">

<%--        function ClearAddSection() {
            document.getElementById('<%= ddlNewSalCategory.ClientID %>').value = '';
            document.getElementById('<%= ddlNewProfession.ClientID %>').value = '';
        }

        function clearSearchFeilds() {
            $("#<%=ddlSalCategory.ClientID %>").selectedIndex = 0;
            $("#<%=ddlProfession.ClientID %>").selectedIndex = 0;
        }--%>

        function addNewSalProfessionToCategory() {
            alert("hey");
            var tWidth = 340; // 335;
            var tHeight = 170; //165;

            var tmpHref = "#TB_inline?inlineId=divAddNewSalProfessionToCategory&modal=true&height=" + tHeight + "&width=" + tWidth;

            $("#aTBOpenPopup_inline").attr("href", tmpHref);
            $("#aTBOpenPopup_inline").click();
        }

        function ShowUpdateRemarkBox() {
            $("#fade").show();
            $("#divWhiteContent").show();
        }

        function HideUpdateRemarkBox() {
            $("#fade").hide();
            $("#divWhiteContent").hide();
        }

<%--        function doPostBack() {
            var salCategoryID = $("#<%=ddlNewSalCategory.ClientID %>").val();
            var professionCode = $("#<%=ddlNewProfession.ClientID %>").val();

            $("#<%=hdNewSalCategoryID.ClientID %>").val(salCategoryID);
            $("#<%=hdNewProfessionCode.ClientID %>").val(professionCode);

            setTimeout('__doPostBack(\'btnAddSalProfessionToCategory\',\'\')', 0);
        }
--%>
        function SetScrollPosition() {
            var divGridView = document.getElementById('divGridView');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPosition.ClientID %>');
            if (hdnScrollPosition.value != "") {
                divGridView.scrollTop = hdnScrollPosition.value;
            }
        }
        function GetScrollPosition() {
            var divGridView = document.getElementById('divGridView');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPosition.ClientID %>');
            hdnScrollPosition.value = divGridView.scrollTop;
        }

        function SetRemarkOnUpdateRemarkBox(oldRemarkTxt, newRemarkText, remarkID) {
            alert("Hi");
            var txtSelectedRemarkID = document.getElementById('<% = txtSelectedRemarkID.ClientID %>');
            var txtRemarkTextNew = document.getElementById('<% = txtRemarkTextNew.ClientID %>');
            var lblRemarkTextOld = document.getElementById('<% = lblRemarkTextOld.ClientID %>');

            txtSelectedRemarkID.value = remarkID;
            lblRemarkTextOld.innerText = oldRemarkTxt;
            txtRemarkTextNew.value = newRemarkText;
        }

    </script>
    <style type="text/css">
        .mrgTop
        {
            margin-top: 2px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="server">

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0" dir="rtl">
                <tr id="trError" runat="server">
                    <td>
                        <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" dir="rtl" width="990px">
                <tr id="BlueBarTop">
                    <td style="padding-right: 10px">
                        <!-- Upper Blue Bar -->
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
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7"
                            width="100%">
                            <tr id="BorderTop1">
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
                                <td align="right">
                                    <div>
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr style="height: 25px">
                                                <td valign="top" >
                                                    <asp:Label ID="lblFilter" runat="server" Width="40px" Text="טקסט חופשי:" ></asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <%--style="padding-top: 8px;"--%>
                                                    <asp:TextBox ID="txtFilterRemarks" runat="server" Width="140px"></asp:TextBox>
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblDistrict" runat="server" Width="40px" Text="סוג הערה:"></asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkType" runat="server" Height="24px" Width="120px" DataTextField="Remark" />
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblRemarkCategory" runat="server" Text="קטגוריה:"> </asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkCategory" runat="server" Height="24px" Width="135px">
                                                    </asp:DropDownList>
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblStatus" runat="server" Text="סטטוס:"> </asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRemarkStatus" runat="server" Height="24px" Width="70px">
                                                    </asp:DropDownList>
                                                </td>
                                                <td valign="top" style="padding-right: 10px">
                                                    <asp:Label ID="lblToBeApproved" runat="server" Width="40px" Text="דורשים אישור:"> </asp:Label>
                                                </td>
                                                <td valign="middle">
                                                    <asp:DropDownList ID="ddlRequireApproval" runat="server" Height="24px" Width="50px">
                                                    </asp:DropDownList>
                                                </td>

                                                <td align="right" style="padding-right: 4px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: top; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                    OnClick="btnSearch_Click"></asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="padding-right: 5px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSendMail" runat="server" Text="שליחת מייל לאישור" CssClass="RegularUpdateButton" 
                                                                    ToolTip = "בקשת אישור לשינוי ממנהל המערכת" EnableTheming="false"
                                                                    ValidationGroup="vgrFirstSectionValidation" Width="110px" OnClick="btnSendMail_Click" OnClientClick="showProgressBarGeneral('0')">
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
                                        </table>
                                    </div>
                                </td>
                                <td style="border-left: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                            </tr>
                            <tr id="BoprderBottom1" style="height: 10px">
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
                <tr>
                    <td style="padding-right: 10px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7"
                            width="100%">
                            <tr id="BorderTop2">
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
                                <td align="right">
                                    <div style="width: 100%" dir="rtl">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr id="GridViewHeaders" runat="server">
                                                <td style="padding-right: 10px">
                                                    <table width="100%">
                                                        <tr>
                                                            <td width="9%">
                                                                <uc1:sortableColumn ID="hdrRemarkID" runat="server" ColumnIdentifier="remarkID" OnSortClick="btnSort_Click"
                                                                    Text="קוד הערה" />
                                                            </td>
                                                            <td width="62%">
                                                                <uc1:sortableColumn ID="hdrRemark" runat="server" ColumnIdentifier="remark" OnSortClick="btnSort_Click"
                                                                    Text="הערה" />
                                                            </td>
                                                            <td width="6%">
                                                                <asp:Label ID="lblHeaderlblActiveremarksInUse" runat="server" EnableTheming="false"  CssClass="LabelCaptionGreenBold_12" Text="מספר הערות בתוקף" /></asp:Label>
                                                            </td>
                                                            <td width="23%">
                                                                <asp:Label ID="lblHeaderUpdateDate" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12" Text="תאריך עדכון"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr id="trNoDataFound" runat="server" style="display: none">
                                                <td style="padding-top: 30px; background-color: #F7F7F7" align="center">
                                                    <asp:Label ID="lblNoDataFound" runat="server" Text="אין מידע"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr id="trGridView">
                                                <td width="975px" style="padding-right: 0px; padding-left: 0px;">
                                                    <div id="divGridView" class="ScrollBarDiv" style="overflow-y: scroll; direction: ltr;
                                                        width: 100%; height: 350px;">
                                                        <div style="direction: rtl;">
                                                            <asp:GridView ID="gvRemarks" runat="server" AutoGenerateColumns="false" HorizontalAlign="Right"
                                                                OnRowDataBound="gvRemarks_RowDataBound" ShowFooter="false" ShowHeader="false"
                                                                SkinID="GridViewForSearchResults">
                                                                <RowStyle CssClass="choiseField" />
                                                                <Columns>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblRemarkID" runat="server" Text='<%#Eval("remarkID") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Center" Width="9%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <table>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblRemarkText" runat="server" Text='<%#Eval("remark") %>'></asp:Label>
                                                                                    </td>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblRemarkTextToCorrect" runat="server" Text='<%#Eval("remarkToCorrect") %>' EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:ImageButton ID="btnDeleteRemark" EnableTheming="false" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                        RemarkID='<%# Eval("remarkID")%>' OnClick="btnDeleteNewRemarkText_Click" OnClientClick="showProgressBarGeneral('0')"></asp:ImageButton>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>

                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="580px" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblActiveremarksInUse" runat="server" Text='<%#Eval("InUseActiveremarksCount") %>'></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="6%" />
                                                                    </asp:TemplateField>

                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblremarkToCorrect_UpdateDate" runat="server" Text='<%#Eval("remarkToCorrect_UpdateDate") %>'
                                                                                EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="8%" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <table id="tbEditRemark" cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button runat="server" ID="btnEditRemark" RemarkID='<%# Eval("remarkID")%>' 
                                                                                            RemarkText='<%# Eval("remark")%>'  RemarkTextToCorrect='<%# Eval("remarkToCorrect")%>' Width="35px"
                                                                                            CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditRemark_Click"  
                                                                                            OnClientClick="GetScrollPosition(); showProgressBarGeneral('0')" />
                                       
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="60px" />
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField>
                                                                        <ItemTemplate>
                                                                            <table id="tbApproveRemark" runat="server" cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button runat="server" ID="btnApproveRemark" RemarkID='<%# Eval("remarkID")%>' RemarkTextToCorrect='<%# Eval("remarkToCorrect")%>' Width="35px" CssClass="RegularUpdateButton" Text="אישור" OnClick="btnApproveRemark_Click" OnClientClick="showProgressBarGeneral('0')" />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </ItemTemplate>
                                                                        <ItemStyle HorizontalAlign="Right" Width="50px" />
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                                <SelectedRowStyle ForeColor="#FF99CC" />
                                                            </asp:GridView>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                                <td style="border-left: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                            </tr>
                            <tr id="BorderBottom2" style="height: 10px">
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
                <tr id="BlueBarBottom">
                    <td style="padding-right: 10px">
                        <!-- Lower Blue Bar -->
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

            <div id="divWhiteContent" class="white_content" style="display:none; width:640px; height:140px;">
                <table style="width:100%; height:100%">
                    <tr>
                        <td>
                            <asp:Label runat="server" ID="lblRemarkTextOld" Width="100%" ></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:TextBox runat="server" ID="txtRemarkTextNew" Width="100%" TextMode="MultiLine"></asp:TextBox>
                        </td>
                    </tr>
                    <tr><td><asp:TextBox runat="server" ID="txtSelectedRemarkID" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox></td></tr>
                    <tr><td><asp:Label ID="lblValidateNewTextMessage" runat="server" CssClass="LabelBoldRed12" EnableTheming="false"></asp:Label></td></tr>
                    <tr>
                        <td>
                            <table cellpadding="0" cellspacing="0" style="float: left; margin-left: 5px;">
                                <tr>
                                    <td class="buttonRightCorner">
                                        &nbsp;
                                    </td>
                                    <td class="buttonCenterBackground">
                                        <asp:Button ID="btnSaveNewRemarkText" Width="70px" runat="server" Text="שמירה"
                                            CssClass="RegularUpdateButton" OnClick="btnSaveNewRemarkText_Click" OnClientClick="showProgressBarGeneral('0')"></asp:Button>
                                    </td>
                                    <td class="buttonLeftCorner">
                                        &nbsp;
                                    </td>

                                    <td class="buttonRightCorner">
                                        &nbsp;
                                    </td>
                                    <td class="buttonCenterBackground">
                                        <input type="button" value="סגירה" class="RegularUpdateButton" onclick="HideUpdateRemarkBox(); SetScrollPosition();" style="width: 45px;" />
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
            <div id="fade" class="black_overlay"></div>
            <asp:HiddenField ID="hdnScrollPosition" runat="server" />   
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
