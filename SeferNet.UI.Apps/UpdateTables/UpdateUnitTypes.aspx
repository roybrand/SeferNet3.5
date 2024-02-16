 
<%@ Page Title="ניהול סוגי יחידות" Language="C#" MasterPageFile="~/SeferMasterPage.master" AutoEventWireup="true" Inherits="UpdateTables_UpdateUnitTypes" Codebehind="UpdateUnitTypes.aspx.cs" %>

<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelect.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="ucGridUnitTypes" TagName="GridUnitTypes" Src="~/UserControls/GridUnitTypes.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <script src="../Scripts/updateItems.js" type="text/javascript"></script>
    <script src="../Scripts/srcScripts/Thickbox.js" type="text/javascript"></script>
    <script src="../Scripts/Applic/general.js" type="text/javascript"></script>
    <link rel="Stylesheet" type="text/css" href="../css/General/thickbox.css" />
    
    <script type="text/javascript">
        var ddlInternetDisplayID = "<%=ddlInternetDisplay.ClientID %>";
        var ddlAllowQueueOrderID = "<%=ddlAllowQueueOrder.ClientID %>";
        var chkIsActiveID = "<%=chkIsActive.ClientID %>";
        var ddlDefaultSubUnitTypeID = "<%=ddlDefaultSubUnitType.ClientID %>";
        var ddlCategoryID = "<%=ddlCategory.ClientID %>";
        var isUpdate = false;

        function clearPopUp() {

            $("#txtCode").val("");
            $("#txtDescription").val("");
            $("#txtCode").attr("disabled", "");
            setAllToNotChecked();
            selectByVal("#" + ddlInternetDisplayID, "1");
            selectByVal("#" + ddlAllowQueueOrderID, "1");
            $("#" + chkIsActiveID).attr("disabled", "disabled");
            $("#" + chkIsActiveID).attr("checked", "checked");
            $("#" + ddlDefaultSubUnitTypeID)[0][0].selected = true;
            $("#" + ddlCategoryID)[0][0].selected = true;
            $("#spanValidCode").hide();
            $("#spanValidDescription").hide();
            isUpdate = false;
        }

        function setPopupParams(pCode, pDescription, pInternetDisplay, pAllowQueueOrder, pActive, pDefualtSubUnit, pCategory, pRelated) {
            $("#txtCode").val(pCode);
            $("#txtDescription").val(pDescription);
            $("#txtCode").attr("disabled", "disabled");
            setAllToNotChecked();
            setCheckedItems(pRelated);

            if (pInternetDisplay == "True") {
                selectByVal("#" + ddlInternetDisplayID, "1");
            }
            else {
                selectByVal("#" + ddlInternetDisplayID, "2");
            }

            if (pAllowQueueOrder == "True") {
                selectByVal("#" + ddlAllowQueueOrderID, "1");
            }
            else {
                selectByVal("#" + ddlAllowQueueOrderID, "2");
            }


            $("#" + chkIsActiveID).attr("disabled", "");
            if (pActive == "True") {
                $("#" + chkIsActiveID).attr("checked", "checked");
            }
            else {
                $("#" + chkIsActiveID).attr("checked", "");
            }


            selectByText("#" + ddlDefaultSubUnitTypeID, pDefualtSubUnit);
            selectByText("#" + ddlCategoryID, pCategory);
            isUpdate = true;
        }

        var selectByVal = function (dropdown, selectedValue) {
            var options = $(dropdown).find("option");
            var matches = $.grep(options,
        function (n) {
            return $(n).val() == selectedValue;
        });

            $(matches).attr("selected", "selected");
        };

        var selectByText = function (dropdown, selectedValue) {
            var options = $(dropdown).find("option");
            var matches = $.grep(options,
        function (n) {
            return $(n).text().trim() == selectedValue.trim();
        });

            $(matches).attr("selected", "selected");
        };

        function setPostValues() {
            
            
            var selectedValues = "";
                        
            var checkboxes = $('#' + checkboxesID).find("input:checkbox");

            for (i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    if (selectedValues == "") {
                        selectedValues = HashTableSubUnits.getItem(checkboxes[i].nextSibling.innerHTML);
                    }
                    else {
                        selectedValues += "," + HashTableSubUnits.getItem(checkboxes[i].nextSibling.innerHTML);
                    }

                }
            }
            
            $("#" + "<%=hfDefaultSubUnitType.ClientID %>").val($("#" + "<%=ddlDefaultSubUnitType.ClientID %>").val());
            $("#" + "<%=hfRelatedValues.ClientID %>").val(selectedValues);
            $("#" + "<%=hfInternetDisplay.ClientID %>").val($("#" + "<%=ddlInternetDisplay.ClientID %>").val());
            $("#" + "<%=hfAllowQueueOrder.ClientID %>").val($("#" + "<%=ddlAllowQueueOrder.ClientID %>").val());
            $("#" + "<%=hfCategory.ClientID %>").val($("#" + "<%=ddlCategory.ClientID %>").val());
            $("#" + "<%=hfIsActive.ClientID %>").val($("#" + "<%=chkIsActive.ClientID %>").attr("checked"));
            $("#" + "<%=hfUpdateFlag.ClientID %>").val(isUpdate);
        }

        function checkIfValid() {
            var countValids = 0;
            var myCode = $("#txtCode").val();
            var myDescription = $("#txtDescription").val();
            
            if (myCode.match(/^\d+$/)) {
                $("#spanValidCode").hide();
                countValids++;
            }
            else {
                $("#spanValidCode").show();

            }

            if (myDescription != "") {
                $("#spanValidDescription").hide();
                countValids++;
            }
            else {
                $("#spanValidDescription").show();
            }

            if (countValids == 2) {
                $("#" + "<%=hfCode.ClientID %>").val(myCode)
                $("#" + "<%=hfDescription.ClientID %>").val(myDescription)
                tb_remove();
                setPostValues();
                document.getElementById("<%=btnSave.ClientID %>").click();
            }

            
        }
    </script>
    
    <table>
        <tr>
            <td dir="rtl" valign="top" align="right">             
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Panel runat="server" ID="pnlGrid" Width="980px">
                                        <ucGridUnitTypes:GridUnitTypes ID="grUnitList" runat="server"></ucGridUnitTypes:GridUnitTypes>
                                    </asp:Panel>
                                </td>
                                
                            </tr>
                        </table>
                        
                    </ContentTemplate>
                    
                    
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
            </td>
        </tr>
    </table>
    <div id="hiddenModalContent" style="display:none;">
        <div style="text-align:right;margin-top:7px;">
            <span id="spanValidCode" style="color:Red;display:none;">*</span>
            <input type="text" id="txtCode" style="border:1px solid #cecbce;text-align:right;width:170px" />
            
            <asp:Label Width="65px" ID="Label1" runat="server" Text="קוד"></asp:Label>
        </div>
        <div style="text-align:right;margin-top:7px;">
            <span id="spanValidDescription" style="color:Red;display:none;">*</span>
            <input type="text" id="txtDescription" style="border:1px solid #cecbce;text-align:right;width:170px" />
            <asp:Label Width="65px" ID="lblDescription" runat="server" Text="תאור"></asp:Label>
        </div>
        <div style="text-align:right;margin-top:7px;">
            <asp:DropDownList style="direction:rtl;" AutoPostBack="false" ID="ddlInternetDisplay" runat="server" CssClass="ScrollBarDiv">
                <asp:ListItem Text="כן" Value="1" Selected="True"></asp:ListItem>
                <asp:ListItem Text="לא" Value="2" Selected="False"></asp:ListItem>
            </asp:DropDownList>
            <asp:Label Width="65px" ID="lblGender" runat="server" Text="האם להציג"></asp:Label>
        </div>
        
        <div style="text-align:right;margin-top:7px;">
            <asp:DropDownList ID="ddlAllowQueueOrder" runat="server"  
                AutoPostBack="false" style="direction:rtl;">
                <asp:ListItem Text="כן" Value="1" Selected="True"></asp:ListItem>
                <asp:ListItem Text="לא" Value="2" Selected="False"></asp:ListItem>
            </asp:DropDownList>
            <asp:Label Width="65px" ID="lblAllowQueueOrder" runat="server" Text="אופן זימון"></asp:Label>
        </div>
        <div style="text-align:right;margin-top:7px;">
            <div style="float:right;">
                <asp:Label Width="65px" ID="Label2" runat="server" Text="שיוכים"></asp:Label>
            </div>
            <div style="float:right;margin-right:3px;">
            <MultiDDlSelect_UC:MultiDDlSelect_UCItem id="MultiDDlSelect_SubUnitTypes" runat="server" Width="150px">
            </MultiDDlSelect_UC:MultiDDlSelect_UCItem>
            </div>
        </div>
        <div style="text-align:right;margin-top:7px;clear:both;">
            <asp:CheckBox ID="chkIsActive" runat="server" Checked="true"  />
            <asp:Label Width="65px" ID="lblIsActive" runat="server" Text="פעיל"></asp:Label>
        </div>
        <div style="text-align:right;margin-top:7px;">
            <asp:DropDownList ID="ddlDefaultSubUnitType" style="direction:rtl;" runat="server" DataTextField="SubUnitTypeName" 
               DataValueField="SubUnitTypeCode"></asp:DropDownList>
            <asp:Label Width="65px" ID="lblDefaultSubUnit" runat="server">שיוך ברירת מחדל</asp:Label>
        </div>
        <div style="text-align:right;margin-top:7px;">
            <asp:DropDownList DataSourceID="SqlDataSourceCategories" DataValueField="CategoryID" DataTextField="CategoryName" ID="ddlCategory" style="direction:rtl;" runat="server"></asp:DropDownList>
            <asp:Label Width="65px" ID="Label3" runat="server">קטגוריה</asp:Label>
        </div>
        <div style="text-align:right;margin-top:20px;">
            <div onclick="clearPopUp();tb_remove();" style="float:right;cursor:pointer;border:none;width:44px;height:19px;background:url('../Images/btn_cancel.gif');"></div>
            <div style="float:left;margin-left:25px;background:url('../Images/btn_approve.gif');cursor:pointer;width:44px;height:19px;border:none;" onclick="checkIfValid();"></div>
        </div>
        
        
    </div>
    <asp:HiddenField ID="hfCode" runat="server" />
    <asp:HiddenField ID="hfDescription" runat="server" />
    <asp:HiddenField ID="hfRelatedValues" runat="server" />
    <asp:HiddenField ID="hfDefaultSubUnitType" runat="server" />
    <asp:HiddenField ID="hfInternetDisplay" runat="server" />
    <asp:HiddenField ID="hfAllowQueueOrder" runat="server" />
    <asp:HiddenField ID="hfCategory" runat="server" />
    <asp:HiddenField ID="hfIsActive" runat="server" />
    <asp:HiddenField ID="hfUpdateFlag" runat="server" />
    <asp:HiddenField ID="hfListOfTextsAndValues" runat="server" />
    
    <div style="display:none;">
        <asp:Button ID="btnSave" runat="server" OnClick="btnSave_Click" />
    </div>
    <asp:SqlDataSource ID="SqlDataSourceSector" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
        SelectCommand="SELECT [EmployeeSectorCode], [EmployeeSectorDescription] FROM [EmployeeSector] "
        DataSourceMode="DataReader"></asp:SqlDataSource>
    
    <asp:SqlDataSource ID="SqlDataSourceCategories" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
        SelectCommand="rpc_GetDeptCategory" SelectCommandType="StoredProcedure">
    </asp:SqlDataSource>
    
    <script type="text/javascript">
        var HashTableSubUnits = new Hash();
        SetHashTable();
        function SetHashTable() {
            var listOfItems = $("#<%=hfListOfTextsAndValues.ClientID %>").val().split("!#!");
            $.each(listOfItems, function () {
                var splitItem = this.split("~");
                HashTableSubUnits.setItem(splitItem[0], splitItem[1]);
                
            });

        }

        $("#" + chkIsActiveID).attr("disabled", "disabled");
        $("#" + chkIsActiveID).attr("checked", "checked");
        $("#<%=panelID %>").css({"margin-top":"-4px","margin-right":"4px"});

        
    </script>
    
</asp:Content>

