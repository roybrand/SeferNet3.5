
<%@ Page language="c#" Inherits="FrmSelectTemplate" enableViewState="false" Codebehind="FrmSelectTemplate.aspx.cs" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
	<head>
		<title>מערכת ספר שירות</title>
		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR"/>
		<meta content="C#" name="CODE_LANGUAGE"/>
		<meta content="JavaScript" name="vs_defaultClientScript"/>
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"/>
		<link href="../CSS/General/general.css" type="text/css" rel="stylesheet"/>
	<%--	<script language="javascript" src="../scripts/function.js"></script>--%>
		<script type="text/javascript">
			
			function HideIcons()
			{
				document.getElementById("trIcons").style.display = 'none';
			}
			
			function ShowIcons()
			{
				document.getElementById("trIcons").style.display = 'inline';
			}

		</script>
	</head>
	<body onload="window.focus();" onafterprint="ShowIcons();" onbeforeprint="HideIcons();">
		<form id="Form1" method="post" runat="server">
			<div id="divSessionEnd"></div>
			<table width="100%" dir="rtl">
				<tr id="trIcons" dir="rtl" bgColor="#d4d0c8">
                    <td>
                        <table cellspacing="0" cellpadding="0">
                            <tr>
					            <td style="height:35px; padding-top:8px; padding-right:5px ">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td class="buttonRightCorner">&nbsp;</td>
                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);background-repeat: repeat-x; background-position: bottom;">
						                        <asp:Button id="btnPrint" Width="55px" CssClass="RegularUpdateButton" runat="server" Text="הדפסה" OnClientClick="self.print(); return false;"></asp:Button>
                                            </td>
                                            <td class="buttonLeftCorner">&nbsp;</td>
                                        </tr>
                                    </table>
					            </td>
                                <td style="padding-top:8px; padding-right:10px">
                                    <div style="width:320px">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblSendEmail" CssClass="RegularLabel" runat="server" Text="כתובת מייל"></asp:Label>&nbsp;
 						                        <asp:TextBox id="txtSendEmailTo" Width="140px" CssClass="TextBoxRegular" runat="server"></asp:TextBox>
                                            </td>
                                            <td>
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="buttonRightCorner">&nbsp;</td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);background-repeat: repeat-x; background-position: bottom;">
						                                    <asp:Button id="btnSendEmail" ValidationGroup="grSendMail" Width="70px" onclick="btnSendEmail_Click" CssClass="RegularUpdateButton" runat="server" Text="שליחת מייל" ></asp:Button>
                                                        </td>
                                                        <td class="buttonLeftCorner">&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                <asp:RequiredFieldValidator ID="vldMail2" ValidationGroup="grSendMail" runat="server" ControlToValidate="txtSendEmailTo" Text="*"></asp:RequiredFieldValidator>
                                                <asp:RegularExpressionValidator ValidationGroup="grSendMail" ID="vldMail" runat="server" ControlToValidate="txtSendEmailTo" Text="*" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ></asp:RegularExpressionValidator>
                                            </td>
                                        </tr>
                                    </table>
                                    </div>
                                </td>
                                <td style="padding-top:8px">
                                    <div style="width:290px">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblSendFax" CssClass="RegularLabel" runat="server" Text="מספר פקס"></asp:Label>
 						                        <asp:TextBox ID="txtSendToFax" Width="120px" CssClass="TextBoxRegular" tooltip="נא להזין את המספר בתבנית של #######-0##" runat="server"></asp:TextBox>
                                            </td>
                                            <td>
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="buttonRightCorner">&nbsp;</td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);background-repeat: repeat-x; background-position: bottom;">
						                                    <asp:Button id="btnSendFax" ValidationGroup="grSendToFax" Width="70px" CssClass="RegularUpdateButton" runat="server" Text="שליחת פקס" onclick="btnSendFax_Click"></asp:Button>
                                                        </td>
                                                        <td class="buttonLeftCorner">&nbsp;&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                <asp:RequiredFieldValidator ID="vldSendToFax" ValidationGroup="grSendToFax" runat="server" ControlToValidate="txtSendToFax" Text="*" ></asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                    </table>
                                    </div>
                                </td>
                                <td style="padding-top:8px">
                                    <table id="tblCloseButton" runat="server" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td class="buttonRightCorner">&nbsp;</td>
                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);background-repeat: repeat-x; background-position: bottom;">
                                                <asp:Button ID="btnOK" Text="סגירה" Width="45px" CssClass="RegularUpdateButton" runat="server" OnClientClick="self.close(); return false;" />
                                            </td>
                                            <td class="buttonLeftCorner">&nbsp;&nbsp;&nbsp;</td>
                                       </tr>
                                    </table>

                                </td>
                            </tr>
                        </table>
                    </td>
				</tr>
				<tr>
					<td id="tdContent"><asp:literal id="ltlContent" Runat="server"></asp:literal></td>
				</tr>
			</table>
 		    <div style="background-color:Blue; visibility:hidden"  >
             <asp:TextBox ID="txtNearestDepts" runat="server" />
            </div>
           
        </form>
	</body>
</html>
