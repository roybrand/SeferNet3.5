<%@ Page Language="C#" AutoEventWireup="true" Inherits="PrintPopUp" Codebehind="PrintPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="STYLESHEET" href="~/CSS/General/general.css" type="text/css" />
    <link href="~/CSS/SearchApplies.css" rel="STYLESHEET" type="text/Css" />
    <script type="text/javascript">
        function OpenPrintWindow() {
            var result = window.print();
            alert("result=" + result);
            self.close();
        }
    </script>
</head>

<body onload="window.print();">
    <form id="form1" runat="server">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td style="width:100%">
                <table cellpadding="0" cellspacing="0" style="width:100%" >
                    <tr>
                        <td style="width:33%" align="left">
                            <asp:Label ID="lblPrintDate" runat="server" Text=""></asp:Label>
                            <asp:Label ID="lblPrintDateCaption" EnableTheming="false" CssClass="RegularLabelNormal" runat="server" Text=" :תאריך הדפסה"></asp:Label>
                        </td>
                        <td style="width:33%" align="center">
                            <asp:Label ID="lblPrintTitle" EnableTheming="false" CssClass="LabelBoldBlack_14" runat="server" Text="מערכת ספר שרות כללית"></asp:Label>
                        </td>
                        <td style="width:33%" align="right">
                            <asp:Image ID="imgLogo" runat="server" ImageUrl="~/Images/logo.jpg" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="trDoctorsList" runat="server" dir="rtl" style="display:none">
            <td>
                <div id="divGvDoctorsList" runat="server"
                    style="height: 295px;">
                    <asp:GridView ID="gvDoctorsList" runat="server" EnableViewState="true" AutoGenerateColumns="False"
                            SkinID="GridViewForSearchResults">
                            <RowStyle VerticalAlign="Top" />
                            <Columns>
                                <asp:TemplateField HeaderText="שם מרפאה" ItemStyle-Width="210px">
                                    <ItemTemplate>
                                        <asp:Label ID="lbldeptName" runat="server" Text='<%#Eval("deptName")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="שם רופא" ItemStyle-Width="150px" SortExpression="lastName">
                                    <ItemTemplate>
                                        <table cellpadding="0" cellspacing="0" style="margin-right: 5px">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblEmployeeName" runat="server" Text='<% #Bind("EmployeeName") %>'></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblExpert" EnableTheming="false" CssClass="RegularLabelNormal" runat="server" Text='<% #Bind("expert") %>'></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblPositions" EnableTheming="false" CssClass="RegularLabelNormal" runat="server" Text='<% #Bind("positions") %>'></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="תחומי שירות" ItemStyle-Width="105px">
                                    <ItemTemplate>
                                        <asp:GridView ID="gvProfessions" runat="server" AutoGenerateColumns="false" SkinID="SimpleGridViewNoEmtyDataText">
                                            <Columns>
                                                <asp:BoundField DataField="profession" ItemStyle-CssClass="RegularLabel">
                                                    <HeaderStyle CssClass="DisplayNone" />
                                                </asp:BoundField>
                                            </Columns>
                                        </asp:GridView>
                                        <asp:GridView ID="gvServices" runat="server" AutoGenerateColumns="false" SkinID="SimpleGridViewNoEmtyDataText">
                                            <Columns>
                                                <asp:BoundField DataField="service" ItemStyle-CssClass="RegularLabel">
                                                    <HeaderStyle CssClass="DisplayNone" />
                                                </asp:BoundField>
                                            </Columns>
                                        </asp:GridView>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                
                                <asp:TemplateField HeaderText="כתובת" ItemStyle-Width="175px">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lblAddress" Text='<%#Eval("address")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-Width="85px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCityName" runat="server" Text='<%# Eval("CityName") %>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="טלפון" ItemStyle-Width="90px">
                                    <ItemTemplate>
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td dir="ltr">
                                                    <asp:Label ID="lblPhone" runat="server" Text='<%#Eval("phone")%>'></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQueueOrder" runat="server" Text='<%#Eval("QueueOrderDescription")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                </div>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
