using SeferNet.FacadeLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SeferNet.UI.Apps.UserControls
{
    public partial class RemarkControl : System.Web.UI.UserControl
    {
        private string _formattedRemark;
        private int _generalRemarkID;
        private DataTable _generalRemarkElementsTable;
        private string[] _generalRemarkElementsString;
        Facade applicFacade;
        UserControls_MultiDDlSelectUC ucDays;
        ServicesControl servicesControl;
        GetClinicByName getClinicByName;

        HtmlGenericControl div;
        AjaxControlToolkit.CalendarExtender calendarDate;
        AjaxControlToolkit.MaskedEditExtender hourExtender;
        AjaxControlToolkit.MaskedEditValidator hourValidator;

        public string[] GeneralRemarkElementsString {
            get
            {
                applicFacade = Facade.getFacadeObject();
                DataRow remarkText = applicFacade.GetGeneralRemarkByRemarkID(GeneralRemarkID).Tables[0].Rows[0];
                string[] _generalRemarkElementsString = remarkText["remark"].ToString().Split('#');
                return _generalRemarkElementsString;
            }
        }

        public int GeneralRemarkID { 
            get
            {
                object obj = Convert.ToInt32( Session["GeneralRemarkID"]);
                if (obj != null)
                    _generalRemarkID = Convert.ToInt32(Session["GeneralRemarkID"]);
                else
                    _generalRemarkID = 0;

                return _generalRemarkID;
            }
            set 
            {
                this._generalRemarkID = value;
                Session["GeneralRemarkID"] = Convert.ToInt32(_generalRemarkID);
            }
        }


        public string FormattedRemark
        {
            get
            {
                object obj = Session["FormattedRemark"].ToString(); 

                if (obj != null)
                    _formattedRemark = Session["FormattedRemark"].ToString();
                else
                    _formattedRemark = string.Empty;

                return _formattedRemark;
            }
            set
            {
                this._formattedRemark = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

            if (_generalRemarkID != 0)
            {
                //GeneralRemarkID = Convert.ToInt32(txtGenaralRemarkID.Text);

                BuildRemarkWithControls(_generalRemarkID, _formattedRemark);

                GetRemarkDataFromRemarkControl(_generalRemarkID, _formattedRemark);

                //divRemarkBuilder.

                return;
            }

            //string ucID = "uc_Days_", ucUnicID;

            //int howManyDivs = 3;
            //for (int i = 0; i < howManyDivs; i++)
            //{
            //    div = new HtmlGenericControl("div");
            //    div.ID = "dvDays" + i;
            //    div.Attributes.CssStyle.Add("float", "right");
            //    div.Attributes.CssStyle.Add("color", "red");
            //    //div.Attributes.CssStyle.Add("font-weight", "bold");
            //    //div.Attributes.CssStyle.Add("padding-left", "5px");
            //    div.Attributes.CssStyle.Add("border", "1px dashed #51d537");
            //    div.Attributes.CssStyle.Add("padding-left", "5px");
            //    div.Attributes.CssStyle.Add("padding-right", "5px");

            //    ucDays = (UserControls_MultiDDlSelectUC)Page.LoadControl("~/UserControls/MultiDDlSelectUC.ascx");
            //    ucDays.ID = ucID + i.ToString();
            //    ucUnicID = ucDays.UniqueID;
            //    div.Controls.Add(ucDays);

            //    divRemarkBuilder.Controls.Add(div);
            //}
            //////////////////////////////////////////////////////////////////
            ////AjaxControlToolkit.CalendarExtender calendarDate; 

            //for (int i = 0; i < 2; i++)
            //{
            //    div = new HtmlGenericControl("div");
            //    div.ID = "dvCalendar" + i;
            //    div.Attributes.CssStyle.Add("float", "right");
            //    div.Attributes.CssStyle.Add("border", "1px dashed #51d537");

            //    Label label = new Label();
            //    TextBox text = new TextBox();
            //    label.Text = Convert.ToString("varName");
            //    div.Controls.Add(label);

            //    text.ID = "myId" + i;

            //    div.Controls.Add(new LiteralControl("&nbsp;"));

            //    div.Controls.Add(text);

            //    calendarDate = new AjaxControlToolkit.CalendarExtender();
            //    calendarDate.TargetControlID = text.ID;
            //    calendarDate.ID = "calendar" + i;
            //    div.Controls.Add(calendarDate);

            //    div.Controls.Add(new LiteralControl("<br />"));

            //    divRemarkBuilder.Controls.Add(div);
            //}

            /////////////  ServicesControl //////////////////////////////////////////////////// 
            //ServicesControl ucServicesControl;
            //div = new HtmlGenericControl("div");
            //div.ID = "dvServicesControl";
            //div.Attributes.CssStyle.Add("float", "right");
            //div.Attributes.CssStyle.Add("border", "1px dashed #51d537");
            //ucServicesControl = (ServicesControl)Page.LoadControl("~/UserControls/ServicesControl.ascx");

            //div.Controls.Add(ucServicesControl);

            //divRemarkBuilder.Controls.Add(div);
        }

        private void GetRemarkDataFromRemarkControl(int generalRemarkID, string generalRemarkText)
        {
            string elemetClientID = "";

            ControlCollection controlHolders = divRemarkBuilder.Controls;

            //divRemarkBuilder.
            Type controlType;
            int ii = 0; // dummy 

            int howManiDivs = controlHolders.Count;
            for (int i = 0; i < howManiDivs; i++)
            {
                elemetClientID = controlHolders[i].ClientID;

                if (controlHolders[i].Controls.Count > 0)
                { 
                    controlType = controlHolders[i].Controls[0].GetType();

                    if (controlType == typeof(Label)) // Text element. No need to get value
                    {
                        ii = i;
                    }
                    
                    if (controlType == typeof(UserControls_MultiDDlSelectUC)) // Days. Find text box "txtItems"
                    {
                        ii = i;
                        //TextBox txtItems = controlHolders[i].FindControl("txtItems") as TextBox;
                        TextBox txtItems = controlHolders[i].Controls[0].FindControl("txtItems") as TextBox;
                    }
                }



            }

        }

        private void BuildRemarkWithControls(int generalRemarkID, string generalRemarkText)
        {
            //Facade applicFacade = Facade.getFacadeObject();
            //DataSet data = applicFacade.GetGeneralRemarkByRemarkID(generalRemarkID);
            //string notFormattedRemark = data.Tables[0].Rows[0]["remark"].ToString();
            //string[] remarkElements = notFormattedRemark.Split('#');
            string typeOfControl = string.Empty;
            string segmentOfRemark = string.Empty;
            string ucID = string.Empty;

            //HtmlGenericControl div;
            string[] remarkElements = generalRemarkText.Split('#');
            int divNumber = 0;

            int indexOffirstPosition = generalRemarkText.IndexOf('#');;

            if (indexOffirstPosition == 0) // if '#' is in the beginning of string - First element require special control (not Label)
            {
                typeOfControl = "special";
            }
            else
            {
                typeOfControl = "label";
            }

            for (int i = 0; i < remarkElements.Length; i++)
            {
                // create DIV where to put control
                div = new HtmlGenericControl("div");
                divNumber = divNumber + 1;
                div.ID = "divRemarkElement_" + divNumber.ToString();
                div.Attributes.CssStyle.Add("float", "right");
                div.Attributes.CssStyle.Add("padding-left", "5px");
                //div.Attributes.CssStyle.Add("padding-right", "5px");

                if (typeOfControl == "special")
                {
                    // 30 - 31, 11 - 12 "תאריכים"
                    // 20 "ימים"
                    // 40 - 43 "שעות"
                    int codeControl = Convert.ToInt32(remarkElements[i]);

                    // "ימים"
                    if (codeControl == 20) 
                    {
                        ucID = "uc_Days";
                        ucDays = (UserControls_MultiDDlSelectUC)Page.LoadControl("~/UserControls/MultiDDlSelectUC.ascx");
                        ucDays.ID = ucID + divNumber.ToString();
                        TextBox txtValueCodes = (TextBox)ucDays.FindControl("txtItems");
                        //txtValueCodes.Attributes.Add("Name", "ControlsData_" + divNumber.ToString()); //Name = "ControlsData_" + divNumber 
                        div.Controls.Add(ucDays);
                        divRemarkBuilder.Controls.Add(div);
                    }

                    // "תאריכים"
                    if ((codeControl >= 11 && codeControl <= 12) || (codeControl >= 30 && codeControl <= 31)) 
                    {
                        TextBox text = new TextBox();
                        text.Width = 70;
                        text.ID = "ControlDate_" + divNumber.ToString();
                        div.Controls.Add(text);

                        ImageButton imgButton = new ImageButton();
                        imgButton.ID = "btnCalendar_" + divNumber.ToString();
                        imgButton.ImageUrl = "~/Images/Applic/calendarIcon.png";
                        div.Controls.Add(imgButton);

                        calendarDate = new AjaxControlToolkit.CalendarExtender();
                        calendarDate.TargetControlID = text.ID;
                        calendarDate.ID = "uc_Calendar_" + divNumber.ToString();
                        calendarDate.PopupButtonID = imgButton.ID;
                        div.Controls.Add(calendarDate);

                        divRemarkBuilder.Controls.Add(div);
                    }

                    // "שעות"
                    if ((codeControl >= 40 && codeControl <= 43))
                    {
                        TextBox text = new TextBox();
                        text.Width = 35;

                        text.ID = "ControlHour_" + divNumber.ToString();

                        div.Controls.Add(text);

                        hourExtender = new AjaxControlToolkit.MaskedEditExtender();
                        hourExtender.ID = "FromHourExtender_" + divNumber.ToString();
                        hourExtender.TargetControlID = text.ID;
                        hourExtender.Mask = "99:99";
                        hourExtender.ClearMaskOnLostFocus = false;
                        div.Controls.Add(hourExtender);

                        hourValidator = new AjaxControlToolkit.MaskedEditValidator();
                        hourValidator.ControlToValidate = text.ID;
                        hourValidator.ControlExtender = hourExtender.ID;
                        hourValidator.InvalidValueBlurredMessage = "*";
                        div.Controls.Add(hourValidator);

                        divRemarkBuilder.Controls.Add(div);
                    }
                    // "שירותים"
                    if ((codeControl >= 50 && codeControl <= 50))
                    {
                        servicesControl = (ServicesControl)Page.LoadControl("~/UserControls/ServicesControl.ascx");
                        servicesControl.ID = "uc_servicesControl" + divNumber.ToString();
                        // txtBoxes . . . ???
                        TextBox txtValueCodes = (TextBox)servicesControl.FindControl("txtProfessionListCodes");

                        ImageButton btnServicePopUp = (ImageButton)servicesControl.FindControl("btnServicePopUp");
                        //btnServicePopUp.Attributes.Add("OnClientClick", "SelectServicesAndEvents_ForRemark('40,2');return false;");
                        //btnServicePopUp.OnClientClick = "SelectServicesAndEvents_ForRemark('40,2');return false;";
                        btnServicePopUp.OnClientClick = "SelectServicesAndEvents_ForRemark('" + txtValueCodes.ID + "');return false;";

                        div.Controls.Add(servicesControl);
                        divRemarkBuilder.Controls.Add(div);
                    }  

                    // יחידות
                    if ((codeControl >= 60 && codeControl <= 60))
                    {
                        getClinicByName = (GetClinicByName)Page.LoadControl("~/UserControls/GetClinicByName.ascx");
                        getClinicByName.ID = "uc_getClinicByName" + divNumber.ToString();

                        TextBox txtDeptName = (TextBox)getClinicByName.FindControl("txtDeptName");
                        TextBox txtDeptCode = (TextBox)getClinicByName.FindControl("txtDeptCode");
                        ImageButton btnClinicPopUp = (ImageButton)getClinicByName.FindControl("btnClinicPopUp");
                        btnClinicPopUp.OnClientClick = "SelectClinic_ForRemark('" + txtDeptCode.ID + "," + txtDeptName.ID + "');return false;";

                        div.Controls.Add(getClinicByName);
                        divRemarkBuilder.Controls.Add(div);
                    } 

                }

                else
                {
                    Label label = new Label();
                    //label.Text = generalRemarkText.Substring(0, generalRemarkText.Length);
                    label.Text = remarkElements[i];
                    label.ID = "uc_Label_" + divNumber.ToString();
                    label.Attributes.Add("Name", "lblElement_" + divNumber.ToString());
                    div.Controls.Add(label);
                    divRemarkBuilder.Controls.Add(div);
                }

                // the next element will be of the oppisite type
                if (typeOfControl == "special") 
                {
                    typeOfControl = "label";
                }
                else
                {
                    typeOfControl = "special";
                }
            }


            //if (remarkElements.Length == 1) // simple text. No controls should be used
            //{
            //    // add label with text
            //    div = new HtmlGenericControl("div");
            //    divNumber = divNumber + 1;
            //    div.ID = "divRemarkElement_" + divNumber.ToString();

            //    Label label = new Label();
            //    label.Text = generalRemarkText.Substring(0, generalRemarkText.Length);
            //    label.ID = "RemarkElement_" + 1.ToString();
            //    div.Controls.Add(label);
            //    divRemarkBuilder.Controls.Add(div);
            //}
            //else // Go though elements
            //{
            //    int indexOfStartPosition = 0;
            //    int indexOfnextPosition = 0;

            //    //// make first move
            //    //indexOfnextPosition = generalRemarkText.IndexOf('#');
            //    //// The rule is: There has to be alternation - after "text" goes "control" an vice versa
            //    //if (indexOfnextPosition == 0) // if '#' is in the beginning of string - First element require special control (not Label)
            //    //{
            //    //    typeOfControl = "special";
            //    //}
            //    //else
            //    //{
            //    //    typeOfControl = "label";
            //    //}


            //    //if (indexOfnextPosition == 0) // if '#' is in the beginning of string - First element is a special control (not Label)
            //    //{
            //    //    typeOfControl = "special";


            //    //}
            //    //else // Label
            //    //{ 
            //    //    typeOfControl = "label";

            //    //    //segmentOfRemark = generalRemarkText.Substring(indexOfStartPosition, generalRemarkText.IndexOf('#', indexOfStartPosition) - indexOfStartPosition);
            //    //    segmentOfRemark = generalRemarkText.Substring(indexOfStartPosition, indexOfnextPosition - indexOfStartPosition);

            //    //    div = new HtmlGenericControl("div");
            //    //    divNumber = divNumber + 1;
            //    //    div.ID = "divRemarkElement_" + divNumber.ToString();

            //    //    Label label = new Label();
            //    //    //label.Text = generalRemarkText.Substring(0, generalRemarkText.Length);
            //    //    label.Text = segmentOfRemark;
            //    //    label.ID = "RemarkElement_" + divNumber.ToString();
            //    //    div.Controls.Add(label);
            //    //    divRemarkBuilder.Controls.Add(div);
            //    //}

            //}

        }
        /// <summary>
        /// Go through all controls in "divRemarkBuilder" in the same order as they were built,
        /// take from them data and compose whole remark
        /// </summary>
        private void GetRemarkReadyToSave()
        { 
             string clientID = "";
            foreach (Control c in divRemarkBuilder.Controls.OfType<HtmlGenericControl>())
            //foreach (Control c in divRemarkBuilder.Controls)
            {
                clientID = c.ClientID;
                //if (c is Label)
                foreach (Control ctr in c.Controls)
                { 
                    if (ctr is Label)
                    {
                        ((Label)ctr).Text = "New text";
                    }
                    // ......
                
                }


            }       
        }

        public bool BindRemark()
        {
            if (_formattedRemark.Length > 0)
            {
                return false;
            }
            else
            { 
                 return true;           
            }
        }
    }
}