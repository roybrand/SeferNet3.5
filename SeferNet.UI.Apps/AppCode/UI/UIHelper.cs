using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;


using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.WorkFlow; 
using SeferNet.Globals;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums;
using System.Collections.Generic; 

/// <summary>
/// Summary description for UIHelper
/// </summary>
public class UIHelper
{
    public UIHelper()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    /// </summary>
    /// <param name="p_InputText">input text to replace with html content (image TAGS)</param>
    /// <returns>returns HTML image TAGS instead of letters</returns>
    public static string GetStrbyImg(string p_InputText)
    {
        string tmpStr = "";
        StringBuilder imageString = new StringBuilder(@"<img src='../images/abc/icon.gif'>");
        char[] splitStrToChar = p_InputText.ToCharArray();
        int charValue;
        for (int i = 0; i < splitStrToChar.Length; i++)
        {
            charValue = Convert.ToInt16(splitStrToChar[i]);
            if (charValue != 32 && charValue != 92)
            {
                //1264 is because of the image name givven
                charValue -= 1264;
            }
            tmpStr = "<img src='../images/abc/" + charValue + ".gif'>";
            imageString.Append(tmpStr);
        }
        return imageString.ToString();
    }

    public static DataView sortTableByField(DataTable table, string fieldName)
    {
        if (table == null)
            return null;
        DataView dv = new DataView(table, null, fieldName, DataViewRowState.CurrentRows);
        return dv;
    }

    public static void BindDropDownToTable(DropDownList control, DataTable DataTable, string sortField)
    {
        if (DataTable == null)
            return;

        DataView dv = sortTableByField(DataTable, sortField);
        //control.Items.Clear(); 
        control.DataSource = dv;
        control.DataBind();


    }
    public static void SetDDLSelectedItem(DropDownList ddlcontrol,  string ItemValue)
    {

        int i;

        if ((ItemValue == null) || (ItemValue == string.Empty))
        {
            return; 
        }  

        for (i = 0; i < ddlcontrol.Items.Count; i++)
        {
            if (ddlcontrol.Items[i].Value == ItemValue)
            {
                ddlcontrol.SelectedIndex = i;
                break; 
            } 

        }
    }

    public static void BindDropDownToCachedTable(DropDownList control, string DataTableName, string sortField)
    {
        BindDropDownToCachedTable(control, DataTableName, string.Empty, sortField);
    } 


    /// <summary>
    /// The ddl is bound to a dataTable. We try to get the table from cache
    /// if it is not found in cache we retrieve datat from the database
    /// </summary>
    /// <param name="control"></param>
    /// <param name="DataTableName"></param>
    /// <param name="sortField"></param>
    public static void BindDropDownToCachedTable(DropDownList control, string DataTableName,  string filter, string sortField )
    {
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tbl = cacheHandler.getCachedDataTable(DataTableName);
        if (tbl == null) // if table was not found in cache we get the data from the database
        {
            Facade applicFacade = Facade.getFacadeObject();
            DataSet ds = applicFacade.getGeneralDataTable(DataTableName);
            tbl = ds.Tables[0];
            if (tbl == null)
                return;
        }

        if (tbl == null) return;
         
        DataView dv = new DataView(tbl, filter, sortField, DataViewRowState.CurrentRows);

        //DataView dv = sortTableByField(tbl, sortField);
        control.DataSource = dv;
        control.DataBind();
    }



    public static void BindHoursToControl(DropDownList ddlControl)
    {
        ListItem[] hourItemArr = new ListItem[24];
        int hour = 0;
        string hourStr;
        hourItemArr[0] = new ListItem(" ");
        for (int i = 1; i < hourItemArr.Length; i++)
        {
            hour = i ;
            hourStr = hour.ToString();
            if (hour < 10)
                hourStr = "0" + hour.ToString();
            ListItem item = new ListItem(hourStr);
            hourItemArr[i] = item;
        }

        ddlControl.Items.AddRange(hourItemArr);
        ddlControl.Items.Add("00");
    }

    public static void BindOpeninigMinutesToControl(DropDownList ddlControl)
    {
        ListItem[] MinutesItemArr = new ListItem[6];
        int hour = 0;
        string hourStr;
        MinutesItemArr[0] = new ListItem(" ");
        MinutesItemArr[1] = new ListItem("00");
        MinutesItemArr[2] = new ListItem("01");
        MinutesItemArr[3] = new ListItem("15");
        MinutesItemArr[4] = new ListItem("30");
        MinutesItemArr[5] = new ListItem("45");

        ddlControl.Items.AddRange(MinutesItemArr);
    }

    public static void BindClosingMinutesToControl(DropDownList ddlControl)
    {
        ListItem[] MinutesItemArr = new ListItem[5];
        int hour = 0;
        string hourStr;
        MinutesItemArr[0] = new ListItem(" ");
        MinutesItemArr[1] = new ListItem("00");
        MinutesItemArr[2] = new ListItem("15");
        MinutesItemArr[3] = new ListItem("30");
        MinutesItemArr[4] = new ListItem("45");

        ddlControl.Items.AddRange(MinutesItemArr);
    }

    public static Control FindControlRecursive(Control Root, string Id)
    {
        if (Root.ID == Id)

            return Root;


        foreach (Control Ctl in Root.Controls)
        {
            Control FoundCtl = FindControlRecursive(Ctl, Id);

            if (FoundCtl != null)

                return FoundCtl;

        }

        return null;
    }

    public static string getSelectedValuesFromCheckBoxList(CheckBoxList cbList)
    {
        string[] itemsArr = new string[cbList.Items.Count];
        bool flag = false;
        for (int i = 0; i < cbList.Items.Count; i++)
        {
            if (cbList.Items[i].Selected)
            {
                itemsArr[i] = cbList.Items[i].Value;
                flag = true;
            }
            else
            {
                itemsArr[i] = "empty";
            }
        }

        if (flag == false)
            return string.Empty;

        string selectedItems = String.Join(",", itemsArr);
        selectedItems = selectedItems.Replace("empty,", "");
        selectedItems = selectedItems.Replace(",empty", "");
        return selectedItems;
    }

    public static void setSelectedValuesForCheckBoxList(string strSelectedValues, CheckBoxList cbList)
    {
        string[] itemsArr = strSelectedValues.Split(',');
        for (int i = 0; i < cbList.Items.Count; i++)
        {
            for (int j = 0; j < itemsArr.Length; j++)
            {
                if (cbList.Items[i].Value == itemsArr[j])
                    cbList.Items[i].Selected = true;
            }
        }
    }

    public static string GetInnerHTMLForQueueOrder(List<int> QueueOrderMethods, string ToggleID, string divNestID, bool? showPhoneIcon)
    {
        string Image1 = string.Empty;
        string Image2 = string.Empty;
        string Image3 = string.Empty;
        string Image4 = string.Empty;
        string Image6 = string.Empty;
        string seperator = "<font color='#2889E4'>|</font>";
        string toolTip = string.Empty;

        StringBuilder imageString = new StringBuilder();

        string rootDirectory = HttpContext.Current.Request.ApplicationPath;
        foreach (int queueOrder in QueueOrderMethods)
        {
            switch (queueOrder)
            {
                case 1:
                    toolTip = " title='טלפון במרפאה'";
                    break;
                case 2:
                    toolTip = " title='טלפון מיוחד'";
                    break;
                case 3:
                    toolTip = " title='טלפון 2700*'";
                    break;
                case 4:
                    toolTip = " title='אינטרנט'";
                    break;
                case 5:
                    toolTip = " title='מרפאת אם של הלקוח'";
                    break;
                case 6:
                    toolTip = " title='ניתן להגיע ללא זימון תור'";
                    break;
                default:
                    toolTip = string.Empty;
                    break;
            }

            if (queueOrder == 1 || queueOrder == 2)
            {
                string onClick = string.Empty;
                
                if (showPhoneIcon != null)
                {
                    if ((bool)showPhoneIcon)
                        onClick = " onclick='ToggleQueueOrderPhonesAndHours(" + ToggleID + ",\"" + divNestID + "\")'";
                }
                else
                {
                    onClick = "onclick='ToggleQueueOrderPhonesAndHours(\"" + ToggleID + "\")'";
                }

                if (!string.IsNullOrEmpty(onClick))
                {
                    Image1 = "<img id='imgOrderMethod-" + ToggleID + "' style='padding-left:1px;cursor:pointer' src='" + rootDirectory + "/images/Applic/pic_OrderMethod_" + queueOrder + ".gif'" + onClick + toolTip + " />";
                }
            }

            string generalPictureString = "<img src='" + rootDirectory + "/images/Applic/pic_OrderMethod_" + queueOrder + ".gif' style='padding-right:1px;padding-left:1px'" + toolTip + " />";

            if (queueOrder == 3)
                Image2 = generalPictureString;
            if (queueOrder == 4)
                Image3 = generalPictureString;
            if (queueOrder == 5)
                Image4 = "<img src='" + rootDirectory + "/images/Applic/pic_OrderMethod_" + queueOrder + ".gif' style='padding-right:1px;padding-left:1px'" +
                                    toolTip + " />";
            if (queueOrder == 6)
                Image6 = generalPictureString;

        }

        imageString.Append("<table cellpadding='0' cellspacing='0'><tr>");

        if (Image1 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image1 + seperator + "</td>");
        }

        if (Image2 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image2 + seperator + "</td>");
        }

        if (Image3 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image3 + seperator + "</td>");
        }

        if (Image4 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image4 + seperator + "</td>");
        }

        if (Image6 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image6 + seperator + "</td>");
        }

        imageString.Append("</tr></table>");


        string strToReturn = imageString.ToString();

        if (strToReturn.LastIndexOf(seperator) > -1)
        {
            strToReturn = strToReturn.Remove(strToReturn.LastIndexOf(seperator), seperator.Length);
        }
        else
        {
            strToReturn = "&nbsp;";
        }

        return strToReturn;
    }    

    public static string GetInnerHTMLForQueueOrder(DataView dvQueueOrderMethods, string ToggleID, string divNestID, bool? showPhoneIcon)
    {
        string _imgRelativePath = "../images/Applic/";
        string suffix = string.Empty;
        string Image1 = string.Empty;
        string Image2 = string.Empty;
        string Image3 = string.Empty;
        string Image4 = string.Empty;
        string Image6 = string.Empty;
        string seperator = "<font color='#2889E4'>|</font>";
        string toolTip = string.Empty;

        StringBuilder imageString = new StringBuilder();

        for (int i = 0; i < dvQueueOrderMethods.Count; i++)
        {
            suffix = dvQueueOrderMethods[i]["QueueOrderMethod"].ToString();
            switch (Convert.ToInt32(suffix))
            {
                case 1:
                    toolTip = " title='טלפון במרפאה'";
                    break;
                case 2:
                    toolTip = " title='טלפון מיוחד'";
                    break;
                case 3:
                    toolTip = " title='טלפון 2700*'";
                    break;
                case 4:
                    toolTip = " title='אינטרנט'";
                    break;
                case 5:
                    toolTip = " title='מרפאת אם של הלקוח'";
                    break;
                case 6:
                    toolTip = " title='ניתן להגיע ללא זימון תור'";
                    break;
                default:
                    toolTip = string.Empty;
                    break;
            }

            if ((suffix == "1" || suffix == "2") && ToggleID != "")
            {
                string onClick = string.Empty;
                if (showPhoneIcon != null)
                {
                    if ((bool)showPhoneIcon)
                        onClick = " onclick='ToggleQueueOrderPhonesAndHours(" + ToggleID + ",\"" + divNestID + "\")'";
                }
                else
                {
                    onClick = "onclick='ToggleQueueOrderPhonesAndHours(\"" + ToggleID + "\")'";
                }

                if (!string.IsNullOrEmpty(onClick))
                {
                    Image1 = "<img id='imgOrderMethod-" + ToggleID + "' style='padding-left:1px;cursor:pointer' src='" + _imgRelativePath + "pic_OrderMethod_"
                                + suffix + ".gif'" + onClick + toolTip + " />";
                }
            }

            string generalPictureString = "<img src='" + _imgRelativePath + "pic_OrderMethod_" + suffix + ".gif'" + toolTip + " style='padding-right:1px;padding-left:1px' />";

            if (suffix == "3")
                Image2 = generalPictureString;
            if (suffix == "4")
                Image3 = generalPictureString;
            if (suffix == "5")
                Image4 = "<img src='" + _imgRelativePath + "pic_OrderMethod_" + suffix + ".gif' style='padding-right:1px;padding-left:1px'" + toolTip + " />"; 
            if (suffix == "6")
                Image6 = generalPictureString;
        }

        imageString.Append("<table cellpadding='0' cellspacing='0'><tr>");

        if (Image1 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image1 + seperator + "</td>");
        }

        if (Image2 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image2 + seperator + "</td>");
        }

        if (Image3 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image3 + seperator + "</td>");
        }

        if (Image4 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image4 + seperator + "</td>");
        }

        if (Image6 != string.Empty)
        {
            imageString.Append("<td style='vertical-align:bottom'>" + Image6 + seperator + "</td>");
        }

        imageString.Append("</tr></table>");


        string strToReturn = imageString.ToString();

        if (strToReturn.LastIndexOf(seperator) > -1)
        {
            strToReturn = strToReturn.Remove(strToReturn.LastIndexOf(seperator), seperator.Length);
        }
        else
        {
            strToReturn = "&nbsp;";
        }

        return strToReturn;
    }

    public static void SetImageForAgreementType(eDIC_AgreementTypes agreementType, Image img)
    {
        switch (agreementType)
        {
            case eDIC_AgreementTypes.Community:
                img.ImageUrl = "~/Images/Applic/attr_Community.png";
                img.ToolTip = "קהילה";
                break;

            case eDIC_AgreementTypes.Independent_in_community:
                img.ImageUrl = "~/Images/Applic/attr_CommunityAgreement.png";
                img.ToolTip = "עצמאי בקהילה";
                break;

            case eDIC_AgreementTypes.Mushlam:
                img.ImageUrl = "~/Images/Applic/attr_Mushlam.png";
                img.ToolTip = "מושלם";
                break;

            case eDIC_AgreementTypes.Mushlam_payback:
                img.ImageUrl = "~/Images/Applic/attr_MushlamRefund.png";
                img.ToolTip = "מושלם החזר";
                break;

            case eDIC_AgreementTypes.Hospitals:
                img.ImageUrl = "~/Images/Applic/attr_hospitals.gif";
                img.ToolTip = "בתי חולים";
                break;

            case eDIC_AgreementTypes.PaidServices_in_community:
                img.ImageUrl = "~/Images/Applic/attr_PaidServices.png";
                img.ToolTip = "מטפלים בתשלום";
                break;

            case eDIC_AgreementTypes.Unknown:
            default:
                img.ImageUrl = "~/Images/Applic/attr_Community.png";
                img.ToolTip = "קהילה";
                break;
        }
    }    

	 public static void SetImageSmallForAgreementType(eDIC_AgreementTypes agreementType, Image img)
    {
        switch (agreementType)
        {
            case eDIC_AgreementTypes.Mushlam:
                img.ImageUrl = "~/Images/Applic/Mushlam_small.PNG";
                img.ToolTip = "מושלם";                
                break;
            
            default:
                break;
        }
    }

     public static void SetImageForDeptAttribution(ref Image img, bool isCommunity, bool isMushlam, bool isHospitals, int subUnitTypeCode)
     {
         if (isCommunity && isMushlam)
         {
             img.ImageUrl = "~/Images/Applic/attr_CommunityAndMushlam.gif";
             img.ToolTip = "מושלם וקהילה";
         }
         else if (isHospitals && isCommunity)
         {
             img.ImageUrl = "~/Images/Applic/attr_hospitalsAndCommunity.gif";
             img.ToolTip = "בתי חולים וקהילה";
         }
         else if (isHospitals && isMushlam)
         {
             img.ImageUrl = "~/Images/Applic/attr_HospitalAndMushlam.gif";
             img.ToolTip = "בתי חולים ומושלם";
         }
         else if (isHospitals)
         {
             img.ImageUrl = "~/Images/Applic/attr_hospitals.gif";
             img.ToolTip = "בתי חולים";
         }
         else
         {
             switch (subUnitTypeCode)
             {
                 case 0:
                     img.ImageUrl = "~/Images/Applic/attr_Community.png";
                     img.ToolTip = "קהילה";
                     break;
                 case 1:
                     img.ImageUrl = "~/Images/Applic/attr_CommunityAgreement.png";
                     img.ToolTip = "קהילה בהסכם";
                     break;
                 case 2:
                     img.ImageUrl = "~/Images/Applic/attr_CommunityAgreement.png";
                     img.ToolTip = "קהילה בהסכם";
                     break;
                 case 3:
                     img.ImageUrl = "~/Images/Applic/attr_CommunityAgreement.png";
                     img.ToolTip = "קהילה בהסכם";
                     break;
                 case 4:
                     img.ImageUrl = "~/Images/Applic/attr_Mushlam.png";
                     img.ToolTip = "מושלם";
                     break;
                 case 5:
                     img.ImageUrl = "~/Images/Applic/attr_hospitals.gif";
                     img.ToolTip = "בתי חולים";
                     break;
                 default:
                     if (isMushlam)
                     {
                         img.ImageUrl = "~/Images/Applic/attr_Mushlam.png";
                         img.ToolTip = "מושלם";
                     }
                     else
                     {
                         img.ImageUrl = "~/Images/Applic/attr_Community.png";
                         img.ToolTip = "קהילה";
                     }
                     break;
             }
         }

     }

    public static void setClockRemarkImage(Image image ,bool hasReceptionHours, bool hasRemark, 
        string imageColor, string onClickFunction, string receptionHoursAlt, string remarksAlt,
        string receptionAndRemarksAlt)
    {
        string imageTimeName = "";
        string imageRemarkName = "";
        string imageTimeRemarkName = "";

        switch (imageColor)
        {
            case "Green":
                imageTimeName = "greenClock.gif";
                imageRemarkName = "remarkGreen.gif";
                imageTimeRemarkName = "time_remark_green.gif";
                break;
            case "Blue":
                imageTimeName = "blueClock.gif";
                imageRemarkName = "remark_blue.gif";
                imageTimeRemarkName = "time_remark_blue.gif";
                break;
            
        }
        
        if (hasReceptionHours || hasRemark)
        {
            if (hasReceptionHours && hasRemark)
            {
                image.ImageUrl = "~/Images/Applic/" + imageTimeRemarkName;
                if (receptionHoursAlt != "")
                    image.AlternateText = receptionAndRemarksAlt;
            }
            else
            {
                if (hasReceptionHours)
                {
                    image.ImageUrl = "~/Images/Applic/" + imageTimeName;
                    if (receptionHoursAlt != "")
                        image.AlternateText = receptionHoursAlt;
            
                }
                else
                {
                    image.ImageUrl = "~/Images/Applic/" + imageRemarkName;
                    if (remarksAlt != "")
                        image.AlternateText = remarksAlt;
                }
            }

            
           

            image.Attributes.Add("onClick", onClickFunction);
            image.Style.Add("cursor", "hand");
            image.Style.Add("display", "inline");
        }
        else
        {
            image.ImageUrl = "~/Images/vSign.jpg";
            //image.Style.Add("display", "none");
            image.Visible = false;
        }
        
    }

    public static string ReturnOnlyIfPositive(int number, string suffix)
    {
        if (number > 0)
        {
            return number.ToString() + " " + suffix;
        }

        return string.Empty;
    }
}
