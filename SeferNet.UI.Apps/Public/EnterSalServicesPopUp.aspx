<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EnterSalServicesPopUp.aspx.cs" Inherits="SeferNet.UI.Apps.Public.EnterSalServicesPopUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>&nbsp;</title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
</head>
<body>
    <form id="formEnterSalServicesPopUp" runat="server">
    <div dir="rtl" class="LabelBoldDirtyBlue" style="padding:10px;">

    עובדים יקרים,<br/><br/>
    אנו גאים להציג בפניכם את מערכת סל השירותים החדשה, לפי ספר השירות.<br/>
    מערכת זו פתוחה ללא סיסמה לכלל עובדי כללית.<br/>
    לרשותכם לומדה שתסייע לכם להכיר את המערכת החדשה. 
    <a href="http://homenew.clalit.org.il/sites/Communities/masabey enosh/hathum/lemida/DocLib1/סל השירותים/story.html" onclick="self.close();" class="LabelCaptionBlueBold_12" >ללומדה</a><br/>
    נשמח לעמוד לרשותכם בכל שאלה<br/><br/>

    מחלקת סל השירותים

    </div>
    <div dir="rtl" align="center">
        <table cellpadding="0" cellspacing="0">
            <tr>
                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                    background-position: bottom left;">
                    &nbsp;
                </td>
                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                    background-repeat: repeat-x; background-position: bottom;">
                    <asp:Button ID="btnCancel" Width="50px" runat="server" Text="סגירה" OnClientClick="self.close(); return false;"
                        CssClass="RegularUpdateButton">
                    </asp:Button>
                </td>
                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                    background-repeat: no-repeat;">
                    &nbsp;
                </td>
            </tr>
        </table>
    </div>
    </form>

</body>
</html>
