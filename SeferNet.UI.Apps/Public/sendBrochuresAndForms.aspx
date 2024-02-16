<%@ Page Title="שליחת טפסים וחוברות" Language="C#" MasterPageFile="~/seferMasterPageIEwide.master" AutoEventWireup="true" Inherits="Public_sendBrochuresAndForms" Codebehind="sendBrochuresAndForms.aspx.cs" %>

<%@ Register src="../UserControls/CustomPopUp.ascx" tagname="CustomPopUp" tagprefix="uc1" %>


<asp:Content ID="Content1" ContentPlaceHolderID="phHead" Runat="Server">
    <script type="text/javascript">
        var fromAddress = "<%=from %>";
        var subject = "<%=subject %>";
        var mailServerName = "<%=mailServerName %>";
        var manageType = "<%=manageType %>";
        var filesNames = "";
        var mainDirectory = document.location.toString().split(document.domain)[1].split("/")[1];
        var formsAndBrochuresPath = "<%=formsAndBrochuresPath %>";
        var selectedFaxType = "";
        
        function openFax(faxType) {
            
            var fileName = "";
            var countChecked = 0;
            var rows;

            selectedFaxType = faxType;

            if (selectedFaxType == "Brochures") {
                rows = $("#tblBrochures_1 tr");
                rows.each(function () {
                    if (this.cells[0].children[1].checked) {
                        fileName = this.cells[0].children[0].value;
                        countChecked++;
                    }
                });

                /* Check at the second table */
                if (countChecked == 0) {
                    rows = $("#tblBrochures_2 tr");
                    rows.each(function () {
                        if (this.cells[0].children[1].checked) {
                            fileName = this.cells[0].children[0].value;
                            countChecked++;
                        }
                    });
                }
            }
            else {
                rows = $("#tblForms tr");
                rows.each(function () {
                    if (this.cells[0].children[1].checked) {
                        fileName = this.cells[0].children[0].value;
                        countChecked++;
                    }
                });
            }

            if (countChecked == 0) {
                showAlert("לשליחת פקס יש לבחור קובץ", "", "", "", "", true, false);
            }
            else {
                

                if (manageType == "2") {
                    if (countChecked > 1)
                        showAlert("לשליחת פקס אין לבחור יותר מקובץ אחד", "", "", "", "", true, false);
                    else {
                        var filePath = "file:" + formsAndBrochuresPath + "\\" + fileName;
                        window.open(filePath);
                        
                    }
                }
                else {
                    openfaxDetails();
                }


            }

        }

        function sendFax(faxNumber) {
            var ajaxurl = "/" + mainDirectory + "/handlers/SendFax.ashx";
            var selectedFilesName = "";
            var allSelectedFiles = "";
            if (selectedFaxType == "Brochures") {
                
                var selectedFilesName = getSelectedFiles("tblBrochures_1");

                if (selectedFilesName != "") {
                    allSelectedFiles = selectedFilesName;
                }

                selectedFilesName = getSelectedFiles("tblBrochures_2");
                if (selectedFilesName != "") {
                    allSelectedFiles = (allSelectedFiles == "" ? selectedFilesName : allSelectedFiles + "~" + selectedFilesName);
                }
            }
            else {
                allSelectedFiles = getSelectedFiles("tblForms");
            }
            showAjaxProgressImage();
            $.post(ajaxurl, { fNames: allSelectedFiles, fNumber: faxNumber
            },
               function (data) {
                   if (data == "1") {
                       var t = setTimeout("showMessageWhenAjaxEnd('הפקס נשלח בהצלחה')", 2000);
                   }
                   else {
                       var t = setTimeout("showMessageWhenAjaxEnd('בעיה בשליחת הפקס')", 2000);
                   }
               });
        }

        

        function getSelectedFiles(tableName) {
            var rows = $("#" + tableName + " tr");
            var fileNames = "";
            rows.each(function () {
                if (this.cells[0].children[1].checked) {
                    if (fileNames == "")
                        fileNames = this.cells[0].children[0].value;
                    else
                        fileNames += "~" + this.cells[0].children[0].value;
                }
            });
            //debugger;
            return fileNames;
        }

        function getFormsForEmail() {
            var selectedForms = getSelectedFiles("tblForms");
            if (selectedForms != "") {
                filesNames = selectedForms
                openMailDetails();
            }
            else {
                showAlert("לשליחת מייל יש לבחור לפחות טופס אחד", "", "", "", "", true, false);
            }
        }

        function OpenSendMailDialog() {
            var selectedForms = getSelectedFiles("tblForms");
            //debugger;
            if (selectedForms != "") {

                var url = "SendBrochuresAndFormsByMailPopUp.aspx?fileNames=" + selectedForms;
                url = url + "&template=mushlamMail.htm";

                var dialogWidth = 400;
                var dialogHeight = 300;
                var title = "שלח מייל";
                OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            }
            else {
                alert("לשליחת מייל יש לבחור לפחות טופס אחד");
                return false;
            }
        }

        function OpenSendMailDialog_2() {
            var allFiles = "";
            var selectedFilesName = getSelectedFiles("tblBrochures_1");

            if (selectedFilesName != "") {
                allFiles = selectedFilesName;
            }

            selectedFilesName = getSelectedFiles("tblBrochures_2");
            if (selectedFilesName != "") {
                allFiles = (allFiles == "" ? selectedFilesName : allFiles + "~" + selectedFilesName);
            }

            if (allFiles != "") {
                filesNames = allFiles
            }

            if (allFiles != "") {

                var url = "SendBrochuresAndFormsByMailPopUp.aspx?fileNames=" + filesNames;
                url = url + "&template=mushlamMail.htm";

                var dialogWidth = 400;
                var dialogHeight = 300;
                var title = "שלח מייל";
                OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
            }
            else {
                alert("לשליחת מייל יש לבחור לפחות טופס אחד");
                return false;
            }
        }

        function getBrochuresForEmail() {
            var allFiles = "";
            var selectedFilesName = getSelectedFiles("tblBrochures_1");

            if (selectedFilesName != "") {
                allFiles = selectedFilesName;
            }
            
            selectedFilesName = getSelectedFiles("tblBrochures_2");
            if (selectedFilesName != "") {
                allFiles = (allFiles == "" ? selectedFilesName : allFiles + "~" + selectedFilesName);
            }
            
            
            if (allFiles != "") {
                filesNames = allFiles
                openMailDetails();
            }
            else {
                showAlert("לשליחת מייל יש לבחור לפחות חוברת שיווקית אחת", "", "", "", "", true, false);
            }
            
        }

        function confirmEmailDetails(mailDetails) {
            showAjaxProgressImage();
            var imgUrl = "/images/Applic/";
            var ajaxurl = "/" + mainDirectory + "/handlers/sendmail.ashx";
            $.post(ajaxurl, { subject: subject, to: mailDetails.mailAddress, from: fromAddress,
                emailclientname: mailDetails.mailClientName, emailRemarks: mailDetails.mailRemarks,
                filesNames: filesNames, mailServerName: mailServerName,
                template: "mushlamMail.htm", embeddeImages: "mushlamLogo:" + imgUrl + "clalit-mushlamLogo.gif~LogoClalit:" + imgUrl + "LogoClalit.gif"

            },
               function (data) {
                   if (data == "1") {
                       var t = setTimeout("showMessageWhenAjaxEnd('המייל נשלח בהצלחה')", 2000);
                   }
                   else {
                       var t = setTimeout("showMessageWhenAjaxEnd('בעיה בשליחת הנתונים')", 2000);
                   }
               });
               
        }

        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" Runat="Server">
    <div style="background-color:#eaf2f8;height:520px;margin-top:10px;">
        <!-- Brochures -->
        <div style="width:614px;margin-top:20px;margin-right:20px;float:right;">
            <div class="blueWhiteTopRightCorner"></div>
            <div style="width:600px;" class="blueWhiteTopCenter">
                <span class="LabelBoldBlack_13">שליחת חוברת שיווקית</span>
            </div>
            <div class="blueWhiteTopLeftCorner"></div>
            
            <div class="blueWhiteCenter" style="width:611px;height:430px;">
                <div style="padding-top:5px;padding-bottom:10px;text-align:center;background-color:#fff9df;width:609px;margin-top:1px;margin-right:1px;">
                    <span class="LabelBoldBlack_13" >בשליחת פקס - יש לציין בפני הלקוח כי מדובר בכמות דפים גדולה וצבעונית</span>
                </div>
                <div style="background-color:#d7e4ed;width:609px;margin-top:1px;margin-right:1px;">
                    <div style="padding-top:5px;padding-bottom:5px;float:right;width:305px;border-left:1px dotted black;_width:289px;">
                        <span class="LabelBoldBlack_13" style="float:right;margin-right:47px;">שם</span>
                        <span class="LabelBoldBlack_13" style="float:left;margin-left:40px;">שפה</span>
                        
                    </div>
                    <div style="padding-top:5px;padding-bottom:5px;float:right;width:303px;">
                        <span class="LabelBoldBlack_13" style="float:right;margin-right:33px;">שם</span>
                        <span class="LabelBoldBlack_13" style="float:left;margin-left:40px;">שפה</span>
                    </div>
                </div>
                <div class="blueWhiteCenter" style="overflow-y:scroll;direction:ltr;text-align:right;">
                    <div style="float:right;border-left:1px dotted black;width:290px;">
                        <table id="tblBrochures_1" style="direction:rtl;" cellpadding="0" cellspacing="0">
                            <asp:Repeater ID="repBrochures_1" runat="server">
                                <ItemTemplate>
                                
                                        <tr>
                                            <td style="width:30px;">
                                                <asp:HiddenField ID="hfFileName" runat="server" Value='<% #Bind("FileName") %>' />
                                                <asp:CheckBox ID="cbBrochures_1" runat="server" />
                                            </td>
                                            <td style="width:190px;">
                                                <asp:Label ID="lblFormDescription_1" runat="server"
                                                Text='<% #Bind("DisplayName") %>'></asp:Label>
                                            </td>
                                            <td>
                                                <asp:Label ID="lblLanguageDescription_1" runat="server"
                                                Text='<% #Bind("displayDescription") %>'></asp:Label>
                                            </td>
                                        </tr>
                                
                        
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                        
                    </div>
                    <div style="float:right;">
                        <table id="tblBrochures_2" style="direction:rtl;" cellpadding="0" cellspacing="0">
                            <asp:Repeater ID="repBrochures_2" runat="server">
                                <ItemTemplate>
                                
                                        <tr>
                                            <td style="width:30px;">
                                                <asp:HiddenField ID="hfFileName" runat="server" Value='<% #Bind("FileName") %>' />
                                                <asp:CheckBox ID="cbBrochures_2" runat="server" />
                                            </td>
                                            <td style="width:202px;">
                                                <asp:Label ID="lblFormDescription_2" runat="server"
                                                Text='<% #Bind("DisplayName") %>'></asp:Label>
                                            </td>
                                            <td>
                                                <asp:Label ID="lblLanguageDescription_2" runat="server"
                                                Text='<% #Bind("displayDescription") %>'></asp:Label>
                                            </td>
                                        </tr>
                                
                        
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>
                    
                </div>
            </div>

            <div class="blueWhiteBottomRightCorner"></div>
            <div class="blueWhiteBottomCenter" style="width:600px;"></div>
            <div class="blueWhiteBottomLeftCorner"></div>
            
            
            <div style="margin-top: 4px; height: 20px;width:188px;float:left;margin-left:1px;">
                <div class="button_RightCorner"></div>
                <div class="button_CenterBackground">
                    <input type="button" class="RegularUpdateButton" onclick="OpenSendMailDialog_2();" style="width:80px;" value="שליחת מייל"/>
                </div>
                <div class="button_LeftCorner"></div>

                <div class="button_RightCorner" style="margin-right:5px;"></div>
                <div class="button_CenterBackground">
                    <input type="button" class="RegularUpdateButton" onclick="openFax('Brochures');" style="width:80px;" value="שליחת פקס"/>
                </div>
                <div class="button_LeftCorner"></div>
            </div>
        </div>
        <!-- Forms -->
        <div style="width:314px;margin-top:20px;margin-right:20px;float:right;">
            <div class="blueWhiteTopRightCorner"></div>
            <div style="width:300px;" class="blueWhiteTopCenter">
                <span class="LabelBoldBlack_13">שליחת טפסים</span>
            </div>
            <div class="blueWhiteTopLeftCorner"></div>

            <div class="blueWhiteCenter" style="width:311px;height:430px;overflow-y:scroll;
                direction:ltr;text-align:right;">
                <table id="tblForms" style="direction:rtl;" cellpadding="0" cellspacing="0">
                    <asp:Repeater ID="repForms" runat="server">
                        <ItemTemplate>
                        
                                <tr>
                                    <td>
                                        <asp:HiddenField ID="hfFileName" runat="server" Value='<% #Bind("FileName") %>' />
                                        <asp:CheckBox ID="cbForms" runat="server" />
                                    </td>
                                    <td>
                                        <asp:Label ID="lblFormDescription" runat="server"
                                        Text='<% #Bind("FormDisplayName") %>'></asp:Label>
                                    </td>
                                </tr>
                        
                        
                        </ItemTemplate>
                    </asp:Repeater>
                </table>
            </div>

            <div class="blueWhiteBottomRightCorner"></div>
            <div class="blueWhiteBottomCenter" style="width:300px;"></div>
            <div class="blueWhiteBottomLeftCorner"></div>

            <div style="margin-top: 4px; height: 20px;float:left;width:84px;margin-left:1px;">
            <div class="button_RightCorner"></div>
            <div class="button_CenterBackground">
                <input type="button" class="RegularUpdateButton" onclick="openFax('Fax');" style="width:80px;" value="שליחת פקס"/>
            </div>
            <div class="button_LeftCorner"></div>
            </div>

            <div style="margin-top: 4px; height: 20px;float:left;width:84px;margin-left:5px;">
                <div class="button_RightCorner"></div>
                <div class="button_CenterBackground">
                    <input type="button" class="RegularUpdateButton" onclick="return OpenSendMailDialog()";" style="width:80px;" value="שליחת מייל"/>
                </div>
                <div class="button_LeftCorner"></div>
            </div>
        </div>
            
        
    </div>
    
    
    <div id="divAjaxProgress" style="display:none;">
        <table style="width:100%;height:100%;" cellpadding="0" cellspacing="0">
            <tr>
                <td style="width:32px;height:32px;background:url('../Images/Applic/progressBar.gif') no-repeat center center;"></td>
            </tr>
        </table>
    </div>
    
    <uc1:CustomPopUp ID="CustomPopUp1" runat="server" />
    
</asp:Content>

