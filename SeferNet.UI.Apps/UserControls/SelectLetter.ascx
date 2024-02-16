<%@ Control Language="C#" AutoEventWireup="true" Inherits="SelectLetter" Codebehind="SelectLetter.ascx.cs" %>
<script type="text/javascript">
function letterMouseOver()
{
    window.event.srcElement.style.backgroundColor="#D3e5fd";
    if (window.event.srcElement.parentElement!=null)
    window.event.srcElement.parentElement.style.backgroundColor="#D3e5fd";
}

function letterMouseOut()
{
    window.event.srcElement.style.backgroundColor="#ffffff";
    if (window.event.srcElement.parentElement!=null)
        window.event.srcElement.parentElement.style.backgroundColor="#ffffff";
}

</script>

<table id="tblHebLetters" cellspacing="1" cellpadding="0" width="100%" align="center" border="0"
		            runat="server">
		            </table>