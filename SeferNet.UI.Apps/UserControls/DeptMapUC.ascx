
<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_DeptMapUC" Codebehind="DeptMapUC.ascx.cs" %>


<script type="text/javascript">
<!--
    function CheckzIndexIfRequired() {
        if (document.getElementById('<%=chkIsSetzIndexOfPopups.ClientID %>').checked == true) {
            Sys.Application.add_load(function () {

                //makes sure the auto complete popups if exists on the page will always be on top of the map
                if (Sys.Application != null && Sys.Application._createdComponents != null) {

                    for (var i = 0; i < Sys.Application._createdComponents.length; i++) {
                        if (Sys.Application._createdComponents[i]._name == 'PopupBehavior')
                            Sys.Application._createdComponents[i]._element.style.zIndex = 100000;
                        //!important";
                    }
                }
            }
    );
        }

    }

function StretchMapToBottom()
{
    StretchElementHeightToBottomAccordingToScreenCommon('<%=frameMap.ClientID %>');
}

//**********this code is for cleaning the session every time the window is closed or back\forward pressed



//register events on window load
if (window.addEventListener) {
    window.addEventListener('load',
             function () {
                 
                 //instead of onload we will do it on demend ( when the search window asks from it )
                 
                 CheckzIndexIfRequired();
             }
             , false);    //W3C
}
else {          //IE
    window.attachEvent('onload',
            function() {
                //instead of onload we will do it on demend ( when the search window asks from it )
                CheckzIndexIfRequired();

            });

    
}




function focusOnCoord(x, y) {
    var data = getDataFormattedForFocus(x, y);
    sendCommand('focus', data);
}

function getDataFormattedForFocus(x, y) {
    
    return '{"focus":{"X":"' + x + '","Y":"'+ y +'"}}';
}

function clearMap() {
    var hdnIsInitialized = document.getElementById('<%=hdnIsInitialized.ClientID %>');

    //instead use this
    if (hdnIsInitialized.value == true.toString()) {
        var hdnClinicJson = document.getElementById('<%=hdnClinicJson.ClientID %>');
        hdnClinicJson.value = '';
       sendCommand('clear', '');
   }
}

function mapImageClickedNonClosestSearch(recordCode) {
    __doPostBack('<%=btnTriggerPostBack.ClientID %>', recordCode);
}

// -->

</script>


        <iframe runat="server" id="frameMap" scrolling="no" style="height: 600px; width: 694px;" />
        <asp:HiddenField ID="hdnFrameSrc" runat="server" />
        <asp:CheckBox ID="chkIsSetzIndexOfPopups" runat="server" Checked="true" />
        
        <asp:UpdatePanel ID="UpdatePanelClinicJson" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <div style="display:none">
                     <asp:HiddenField ID="hdnClinicJson" runat="server" />
                    <asp:Button ID="btnTriggerPostBack" runat="server" Text="Button" />
                     <asp:HiddenField ID="hdnIsInitialized" runat="server" Value="false" />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
