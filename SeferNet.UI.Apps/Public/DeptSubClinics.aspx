<%@ Page Language="C#" AutoEventWireup="true" Inherits="Public_DeptSubClinics" Codebehind="DeptSubClinics.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link type="text/css" rel="Stylesheet" href="~/css/general/general.css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>
    <script type="text/javascript">
        function OpenMapWindow(url, deptCode) {
            var deptCodeKey = '<%=GlobalConst.QueryVariable.Pages.DeptsMapProperties.FocusedDeptCode%>';

            var winChild = window.open('DeptMap.aspx?' + deptCodeKey + '=' + deptCode, 'מפה', 'toolbar=no,scrollbars=no,status=no,location=false,width=620,height=620; center:yes;');
            winChild.focus();
        }
        

        function goToSubClinic(DeptCode) {
            var mainDirectory = document.location.toString().split(document.domain)[1].split("/")[1];
            window.parent.location.href = "/" + mainDirectory + "/public/ZoomClinic.aspx?DeptCode=" + DeptCode;
        }

        function OpenReceptionWindowDialog(deptCode) {
            var dialogWidth = 845;
            var dialogHeight = 640;
            var title = "שעות קבלה של יחידה";

            var url = "DeptReceptionPopUp.aspx?deptCode=" + deptCode;

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="BackColorBlue" style="height: 29px;">
        <div style="float: right; margin-top: 5px; margin-right: 3px;">
            <asp:Image ID="imgAttributed_6" runat="server" ToolTip="שירותי בריאות כללית" />
        </div>
        <div style="float: right; margin-right: 10px; margin-top: 3px;">
            <asp:Label ID="lblDeptName_SubClinics" EnableTheming="false" CssClass="LabelBoldWhite_18"
                runat="server" Text=""></asp:Label>
        </div>
    </div>
    <table id="tbSubClinics" style="width: 990px; border: solid 1px #D4EAFB; background-color: White;
        height: 377px;direction:rtl;">
        <tr>
            <td style="background-color: #F7FAFF">
                <table cellpadding="0" cellspacing="0" style="border-bottom: 1px solid #B0CEE6">
                    <tr>
                        <td align="center" valign="top" style="padding-right: 35px">
                            <div style="width: 80px">
                                <asp:Label ID="Label1" EnableTheming="false" CssClass="ColumnHeader" Width="30px" Height="30px"
                                    runat="server" Text="שעות קבלה"></asp:Label>
                            </div>
                        </td>
                        <td align="right" valign="top">
                            <div style="width: 265px">
                                <asp:Label ID="Label2" EnableTheming="false" CssClass="ColumnHeader" runat="server" Text="שם מרפאה"></asp:Label>
                            </div>
                        </td>
                        <td align="right" valign="top" style="width: 120px">
                            <asp:Label ID="Label3" EnableTheming="false" CssClass="ColumnHeader" runat="server"
                                Text="סוג יחידה"></asp:Label>
                        </td>
                        <td align="right" valign="top">
                            <div style="width: 200px">
                                <asp:Label ID="lblAddress_SubClinics" EnableTheming="false" CssClass="ColumnHeader"
                                    runat="server" Text="כתובת"></asp:Label>
                            </div>
                        </td>
                        <td align="right" valign="top">
                            <div style="width: 115px">
                                <asp:Label ID="lblCityName_SubClinics" EnableTheming="false" CssClass="ColumnHeader"
                                    runat="server" Text="ישוב"></asp:Label>
                            </div>
                        </td>
                        <td align="right" valign="top">
                            <div style="width: 110px">
                                <asp:Label ID="lblPhone_SubClinics" EnableTheming="false" CssClass="ColumnHeader"
                                    runat="server" Text="טלפון"></asp:Label>
                            </div>
                        </td>
                        <td valign="top" style="width: 52px;">
                            <asp:Label ID="lblAttributed_SubClinics" EnableTheming="false" CssClass="ColumnHeader"
                                runat="server" Text="שיוך"></asp:Label>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <div dir="ltr">
                    <div id="divGvSubClinics" runat="server" style="height: 377px; overflow-y: scroll"
                        class="ScrollBarDiv">
                        <div dir="rtl">
                            <asp:GridView ID="gvSubClinics" runat="server" AutoGenerateColumns="False" OnRowDataBound="gvSubClinics_RowDataBound"
                                HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults" >
                                <Columns>
                                    <asp:TemplateField HeaderText="מפה" ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Image ID="imgMap" runat="server" Style="cursor: hand" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="שעות" ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:Image ID="imgRecepAndComment" runat="server" AlternateText="שעות פעילות" Style="cursor: hand" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="20px" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Image ID="imgServiceLevel" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="265px" HeaderText="שם המרפאה">
                                        <ItemTemplate>
                                            <div onclick="goToSubClinic('<%# Eval("deptCode") %>');" style="padding-right: 5px">
                                                <asp:Label ID="lblSubClinicName" runat="server" CssClass="LooksLikeHRef" EnableTheming="False"
                                                    Text='<%# Eval("deptName") %>'></asp:Label>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="UnitTypeName" ItemStyle-Width="120px" HeaderText="סוג יחידה"
                                        ItemStyle-CssClass="RegularLabel" />
                                    <asp:TemplateField ItemStyle-Width="195px" HeaderText="כתובת">
                                        <ItemTemplate>
                                            <div style="margin-left: 15px">
                                                <asp:Label ID="lblAddress" runat="server" Text='<%# Eval("address") %>' EnableTheming="False"
                                                    CssClass="RegularLabel"></asp:Label>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="cityName" ItemStyle-Width="115px" HeaderText="יישוב" ItemStyle-CssClass="RegularLabel" />
                                    <asp:TemplateField HeaderText="טלפון" ItemStyle-Width="110px">
                                        <ItemTemplate>
                                            <asp:Label ID="lblPhone" runat="server" Text='<%# Eval("phone") %>' EnableTheming="False"
                                                CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="50px">
                                        <ItemTemplate>
                                            <asp:Image ID="imgAttributed" runat="server" />
                                        </ItemTemplate>
                                        <HeaderStyle CssClass="DisplayNone" />
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
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
</body>
</html>
