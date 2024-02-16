<%@ Page Language="C#" MasterPageFile="~/MasterPages/BasicMasterPage.master" AutoEventWireup="true"
    CodeFile="ControlData.aspx.cs" Inherits="ElRte.ControlData" Title="Control Data Page"
    ValidateRequest="false" %>
<%@ Register TagName="RTECopy" TagPrefix="Matrix" Src="~/Controls/RTECopy.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="middleContent" runat="Server">

   
    <script type="text/javascript">
        function GetImagesRegular(imgURL)
        {
            /*    
            var arr = document.getElementById('ctl00_middleContent_imgReg').src.split("/");
            arr[arr.length-1] = imgURL;
            var newPath = "";
            for(i=0; i < arr.length; i++)
            {
            if(i != arr.length-1)
            newPath += arr[i] + "/";
            else
            newPath += arr[i];
            }
            */
            //alert('../<%= ResourceGalleryDir %>/' + imgURL)

            document.getElementById('<%= txtImagePath.ClientID %>').value = imgURL;
            document.getElementById('<%= imgReg.ClientID %>').style.display = 'block';
            document.getElementById('<%= imgReg.ClientID %>').src = '../<%= ResourceGalleryDir %>/' + imgURL;

        }

        function GetImagesAccessible(imgURL)
        {
            document.getElementById('<%= txtImageAccessPath.ClientID %>').value = imgURL;
            document.getElementById('<%= imgAccess.ClientID %>').style.display = 'block';
            document.getElementById('<%= imgAccess.ClientID %>').src = '../<%= ResourceGalleryDir %>/' + imgURL;
        }

        function OpenGalleryPopup()
        {
            winId = window.open("../OLContent/ImageBrowser.aspx?g=r", "ImageBrowser", "height=550,width=700,left=100,top=100,scrollbars=0;status=0,menubar=0");
        }

        function OpenAccessibleGalleryPopup()
        {
            winId = window.open("../OLContent/ImageBrowser.aspx?g=a", "ImageBrowser", "height=550,width=700,left=100,top=100,scrollbars=0;status=0,menubar=0");
        }

        //clear lblMessage.Text if error - no image path //G. A. 24/8/08
        function CheackImagePath()
        {
            var otxtImagePath = document.getElementById('<%= txtImagePath.ClientID %>');
            var olblMessage = document.getElementById('<%= lblMessage.ClientID %>');

            if (otxtImagePath != null && olblMessage != null)
            {
                if (otxtImagePath.value == "")
                {
                    olblMessage.innerHTML = "";
                }
            }
        }
       


    </script>

    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <input type="hidden" id="HDN_PageID" runat="server" />
    <input type="hidden" id="HDN_CtlID" runat="server" />
    <input type="hidden" id="HDN_CtlType" runat="server" />
    <input type="hidden" id="HDN_FormatType" runat="server" />
    <div align="right">
        <img id="imgTitle" runat="server" src="~/Images/FeedingTitle.gif" />
    </div>
    <asp:UpdatePanel ID="up1" runat="server" UpdateMode="Always">
        <ContentTemplate>
            <div align="right">
                <div dir="rtl" style="height:30px"><asp:Label ID="lblBreadcrumb" runat="server"></asp:Label></div>
                <div style="height: 30px;" dir="rtl">
                    <b>
                        <asp:Label ID="lblCtlName" runat="server" Style="color: green;"></asp:Label></b>
                    -
                    <asp:Label ID="lblCtlType" runat="server"></asp:Label></div>
                <asp:Panel ID="pnlText" runat="server" Visible="false">
                    <table border="0">
                        <tr>
                            <td align="right">
                                <b>לשון זכר</b>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:TextBox ID="txtTextData_plain" runat="server" Visible="true" Width="400" TextMode="MultiLine"></asp:TextBox>

                                <asp:RequiredFieldValidator ID="ReqTextData_plain" runat="server" ErrorMessage="לשון זכר - שדה חובה"
                                    ControlToValidate="txtTextData_plain" Display="None">!</asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <Matrix:RTECopy runat="server" ID="RTECopy1" 
                                ControlA_Name="לשון זכר" ControlB_Name="לשון נקבה" 
                                ControlA_ServerID="txtTextData_plain" 
                                ControlB_ServerID="txtTextData_plain_Female" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                <b>לשון נקבה</b>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:TextBox ID="txtTextData_plain_Female" runat="server" Visible="true" Width="400" TextMode="MultiLine"></asp:TextBox>

                                <asp:RequiredFieldValidator ID="reqTextData_plain_Female" runat="server" ErrorMessage="לשון נקבה - שדה חובה"
                                    ControlToValidate="txtTextData_plain_Female" Display="None">!</asp:RequiredFieldValidator>
                           </td>
                        </tr>
                    </table>
                   
                </asp:Panel>
                <asp:Panel ID="pnlImage" runat="server" Visible="false">
                    <div>
                        <table>
                            <tr valign="bottom">
                                <td>
                                    <img id="imgReg" runat="server" width="140" height="100" />
                                </td>
                                <td align="right" class="CommonText">
                                    תמונה<br />
                                    <asp:TextBox ID="txtImagePath" runat="server" Width="180"></asp:TextBox><input type="button"
                                        value="..." onclick="OpenGalleryPopup()" /><br />
                                    <asp:RequiredFieldValidator ID="reqTxtImagePath" runat="server" Enabled="true" ErrorMessage="תמונה - שדה חובה"
                                        ControlToValidate="txtImagePath">!</asp:RequiredFieldValidator>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <br />
                    <div>
                        <table>
                            <tr valign="bottom">
                                <td>
                                    <img id="imgAccess" runat="server" width="140" height="100" />
                                </td>
                                <td align="right" class="CommonText">
                                    תמונה נגישה<br />
                                    <asp:TextBox ID="txtImageAccessPath" runat="server" Width="180"></asp:TextBox><input
                                        type="button" value="..." onclick="OpenAccessibleGalleryPopup()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <br />
                    <div align="right" dir="rtl" class="CommonText">
                        כיתוב ALT<br />
                        <asp:TextBox ID="txtAltText" runat="server" Width="200"></asp:TextBox>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlImageLink" runat="server" Visible="false">
                    <br />
                    <div align="right" dir="rtl" class="CommonText">
                        Target<br />
                        <asp:DropDownList ID="ddlTarget" runat="server" DataSourceID="odsWinTypes" DataTextField="WinTypeName"
                            DataValueField="WinTypeId">
                        </asp:DropDownList>
                        <asp:ObjectDataSource ID="odsWinTypes" runat="server" DataObjectTypeName="ClalitCommon.BusinessObject.OnlineAdminBO.OLWinType"
                            SelectMethod="GetWinTypes" TypeName="ClalitCommon.BusinessLogic.OLBL.OLMenuManager">
                        </asp:ObjectDataSource>
                    </div>
                    <br />
                    <div align="right" dir="rtl" class="CommonText">
                        קישור<br />
                        <asp:TextBox ID="txtUrl" runat="server" Width="300"></asp:TextBox>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlHelp" runat="server" Visible="false">
                    <asp:DropDownList ID="ddlHelp" runat="server" DataSourceID="odsHelp" DataValueField="HelpID"
                        DataTextField="HelpTitle">
                    </asp:DropDownList>
                    <asp:ObjectDataSource ID="odsHelp" runat="server" TypeName="OLHelpProvider"
                        SelectMethod="GetAll" FilterExpression="ApplicationId={0}">
                        <FilterParameters>
                            <asp:Parameter Name="ApplicationId" Type="Int32" Direction="Input" />
                        </FilterParameters>
                    </asp:ObjectDataSource>
                </asp:Panel>
                <asp:Panel ID="pnlPrintAppendix" runat="server" Visible="false">
                    <asp:DropDownList ID="ddlPrintAppendix" runat="server" DataSourceID="odsPrintAppendix" DataValueField="MessageID"
                        DataTextField="MessageText">
                    </asp:DropDownList>
                    <asp:ObjectDataSource ID="odsPrintAppendix" runat="server" TypeName="ClalitCommon.BusinessLogic.OLBL.OLPrintAppendixManager"
                        SelectMethod="GetAll" >
                    </asp:ObjectDataSource>
                </asp:Panel>
                
                <asp:Panel ID="pnlValidator" runat="server" Visible="false" Style="direction: rtl;">
                    <asp:DropDownList ID="ddlValidationMessages" runat="server" AppendDataBoundItems="true">
                        <asp:ListItem Value="-1">בחר</asp:ListItem>
                    </asp:DropDownList>
                </asp:Panel>

                <asp:Panel ID="pnlHyperLink" runat="server" Visible="false">
                    <table border="0">
                    <tr>
	                    <td align="right">
		                    <b>קישור</b>
	                    </td>
                        </tr>
                        <tr>
	                        <td valign="top">
		                        <asp:TextBox ID="txtHyperLink_URL" runat="server" Visible="false" Width="400"></asp:TextBox>		                     
		                        <xRTE:xRTE ID="XRTE3" runat="server" Visible="false" EnableValidation="true"
			                        ValidatorErrorMessage="קישור - שדה חובה" ValidatorDisplay="None" DocumentCss="/css/RTEcss.css"></xRTE:xRTE>
	                        </td>
                        </tr>
                         <td align="right">
		                    <b>כותרת</b>
	                    </td>
                        </tr>
                        <tr>
	                        <td valign="top">
		                        <asp:TextBox ID="txtHyperLink_Title" runat="server" Visible="false" Width="400"></asp:TextBox>
		                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="כותרת - שדה חובה"
			                        ControlToValidate="txtHyperLink_Title" Display="None">!</asp:RequiredFieldValidator>
		                        <xRTE:xRTE ID="XRTE4" runat="server" Visible="false" EnableValidation="true"
			                        ValidatorErrorMessage="כותרת - שדה חובה" ValidatorDisplay="None" DocumentCss="/css/RTEcss.css"></xRTE:xRTE>
	                        </td>
                        </tr>
                        <tr>
                          <td align="right">
                                <strong>Target</strong>
                          </td>
                        </tr>  
                        <tr>
                          <td>
                            <div align="right" dir="rtl" class="CommonText">
                        
                                <asp:DropDownList ID="ddlTargetHyperLink" runat="server" DataSourceID="odsWinTypesHyperLink" DataTextField="WinTypeName"
                                    DataValueField="WinTypeId">
                                </asp:DropDownList>
                                <asp:ObjectDataSource ID="odsWinTypesHyperLink" runat="server" DataObjectTypeName="ClalitCommon.BusinessObject.OnlineAdminBO.OLWinType"
                                    SelectMethod="GetWinTypes" TypeName="ClalitCommon.BusinessLogic.OLBL.OLMenuManager">
                                </asp:ObjectDataSource>
                            </div>
                          </td>
                       </tr>
                        <tr>
                            <td align="right">
                                <b>לשון זכר</b>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:TextBox ID="txtHyperLinkData_plain" runat="server" Visible="false" Width="400"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="ReqHyperLinkData_plain" runat="server" ErrorMessage="לשון זכר - שדה חובה"
                                    ControlToValidate="txtHyperLinkData_plain" Display="None">!</asp:RequiredFieldValidator>
                                <xRTE:xRTE ID="XRTE1" runat="server" Visible="false" EnableValidation="true"
                                    ValidatorErrorMessage="לשון זכר - שדה חובה" ValidatorDisplay="None" DocumentCss="/css/RTEcss.css"></xRTE:xRTE>
                            </td>
                        </tr>
                        <tr>
                            
                        </tr>
                        <tr>
                            <td align="right">
                                <b>לשון נקבה</b>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:TextBox ID="txtHyperLinkData_plain_Female" runat="server" Visible="false" Width="400"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="ReqHyperLinkData_plain_Female" runat="server" ErrorMessage="לשון נקבה - שדה חובה"
                                    ControlToValidate="txtHyperLinkData_plain_Female" Display="None">!</asp:RequiredFieldValidator>
                                <xRTE:xRTE ID="XRTE2" runat="server" Visible="false" EnableValidation="true"
                                    ValidatorErrorMessage="לשון נקבה - שדה חובה" ValidatorDisplay="None" DocumentCss="/css/RTEcss.css"></xRTE:xRTE>
                            </td>
                        </tr>
                    </table>
                   
                </asp:Panel>


                <div dir="rtl" align="right">
                    <asp:ValidationSummary runat="server" ID="vldSummaryUpdate" DisplayMode="BulletList" />
                </div>
                <br />
                <asp:ImageButton ID="btnSave" runat="server" ImageUrl="~/Images/BtnSave.gif" OnClick="btnSave_Click" />&nbsp;
                <img src="~/Images/Back_Btn.gif" id="imgBack" runat="server" onclick="javascript:history.go(-1)"
                    style="cursor: hand; display: inline" />
                <asp:ImageButton ID="btnBack" runat="server" ImageUrl="~/Images/Back_Btn.gif" OnClick="btnBack_Click"
                    CausesValidation="false" Visible="false" />
                <br />
                <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
