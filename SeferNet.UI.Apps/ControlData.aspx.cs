using System;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClalitCommon;
using ClalitCommon.Exceptions;
using ClalitCommon.BusinessLogic.OLBL;
using System.Text;

namespace ElRte
{
    public partial class ControlData : OnlineBasePage
    {
        public string ResourceGalleryDir
        {
            get { return ConfigurationManager.AppSettings[CommonConsts.RESOURCE_GALLERY_DIR]; }
        }

        private int _controlId;
        private int _pageId;

        private DataRow item = null;

        #region Event handlers
        protected void Page_Load(object sender, EventArgs e)
        {
            Initialize();
        }

        /// <summary>
        /// Initializes this instance.
        /// </summary>
        private void Initialize()
        {
            //Get controlId
            if (!Int32.TryParse( Request.QueryString["ctlID"], out _controlId) ) return;

            //Set page constants
//            if (Int32.TryParse(HDN_PageID.Value, out _pageId))
//            {
//                rteTextData_html.ConstantsCollection = GetConstantsByPage(_pageId);
//                rteTextData_html_Female.ConstantsCollection = GetConstantsByPage(_pageId);
//            }
      
            if (!IsPostBack) ShowInputControls(_controlId);
        }

        private string GetErrValidationForConstsRelatedToPage()
        {
            var strErr = new StringBuilder();

            if (!ValidConstantsByPage(_pageId, txtTextData_plain.Text))
                {
                    strErr.Append(CommonConsts.CONST_NOT_EXIST_IN_LIST_MALE);
                    strErr.Append("<br>");
                }

            if (!ValidConstantsByPage(_pageId, txtTextData_plain.Text))
                {
                    strErr.Append(CommonConsts.CONST_NOT_EXIST_IN_LIST_FEMALE);
                    strErr.Append("<br>");
                }
            return strErr.ToString();
        }

        protected void btnSave_Click(object sender, ImageClickEventArgs e)
        {
            //bool blnRteOK = true; //check reach text editor - text i(if in use)

            try
            {
                string HasValidationErr = String.Empty;
                CommonEnums.OnlineControlsTypes CtlType = (CommonEnums.OnlineControlsTypes)Convert.ToInt32(HDN_CtlType.Value);

                switch (CtlType)
                {
                    case CommonEnums.OnlineControlsTypes.Text:
                        var CtlData =  txtTextData_plain.Text;
                        var CtlData_Female = txtTextData_plain_Female.Text;
                        string CtlDataMobile = txtTextData_plain.Text;  //Todo...
                        string CtlDataMobile_Female = txtTextData_plain_Female.Text;//Todo...
                   
                        HasValidationErr = (HDN_FormatType.Value == "text") ? String.Empty : GetErrValidationForConstsRelatedToPage();

                        if (HasValidationErr != String.Empty)
                        {
                            ShowMessage(HasValidationErr, Color.Red);
                            return;
                        }

                        OLPageControlsManager.UpdateData_Text(Convert.ToInt32(CommonEnums.LanguageState.Hebrew), _controlId, CtlData, CtlData_Female, CtlDataMobile, CtlDataMobile_Female);           
                        break;
                    case CommonEnums.OnlineControlsTypes.Image:
                        if (txtImagePath.Text != string.Empty)
                        {
                            OLPageControlsManager.UpdateData_Image(Convert.ToInt32(CommonEnums.LanguageState.Hebrew),
                                _controlId
                                , txtImagePath.Text
                                , txtImageAccessPath.Text
                                , txtAltText.Text);
                        }
                        else
                        {
                            lblMessage.Text = "";
                            this.Validate();
                            return;
                        }
                        break;
                    case CommonEnums.OnlineControlsTypes.Link:
                        OLPageControlsManager.UpdateData_Link(Convert.ToInt32(CommonEnums.LanguageState.Hebrew),
                            _controlId
                            , txtImagePath.Text
                            , txtImageAccessPath.Text
                            , txtAltText.Text
                            , Convert.ToInt32(ddlTarget.SelectedItem.Value)
                            , txtUrl.Text);
                        break;
                    case CommonEnums.OnlineControlsTypes.Help:
                        OLPageControlsManager.UpdateData_Help(
                            _controlId
                            , Convert.ToInt32(ddlHelp.SelectedItem.Value));
                        break;
                    case CommonEnums.OnlineControlsTypes.Validator:
                        OLPageControlsManager.UpdateData_Validator(
                            _controlId
                            , Convert.ToInt32(ddlValidationMessages.SelectedValue));
                        break;
                    case CommonEnums.OnlineControlsTypes.PrintAppendix:
                        OLPageControlsManager.UpdateData_PrintAppendix(
                            _controlId
                            , Convert.ToInt32(ddlPrintAppendix.SelectedValue));
                        break;
                    case CommonEnums.OnlineControlsTypes.HyperLink:
                        OLPageControlsManager.UpdateData_HyperLink(Convert.ToInt32(CommonEnums.LanguageState.Hebrew),
                            _controlId
                            , txtHyperLink_URL.Text
                            , txtHyperLink_Title.Text
                            , Convert.ToInt32(ddlTargetHyperLink.SelectedItem.Value)
                            , txtHyperLinkData_plain.Text
                            , txtHyperLinkData_plain_Female.Text                       
                            );
                    

                        break;
                }

                
                ShowMessage(CommonConsts.UPDATE_SUCCESS, Color.Green);
                ShowInputControls(_controlId);
            }
            catch (Exception ex)
            {
                ShowMessage( CommonConsts.UPDATE_FAILURE, Color.Red);
            }
        }

        private void ShowMessage( string message, Color color)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = color;
        }

        protected void btnBack_Click(object sender, ImageClickEventArgs e)
        {
            Response.Redirect("PageData.aspx?pageID=" + HDN_PageID.Value);
        }

        #endregion

        #region Private functions

        /// <summary>
        /// Get input controls by entry type
        /// </summary>
        /// <param name="ctlID">Control ID</param>
        private void ShowInputControls(int ctlID)
        {
            var dt = OLPageControlsManager.GetByID(ctlID);
            item = null;
            
            //
            if (dt.Rows.Count <= 0) return;


            item = dt.Rows[0];
            CommonEnums.OnlineControlsTypes ctlType = (CommonEnums.OnlineControlsTypes)Convert.ToInt32(dt.Rows[0]["CtlTypeID"]);

            HDN_CtlType.Value = dt.Rows[0]["CtlTypeID"].ToString();
            HDN_PageID.Value = dt.Rows[0]["PageID"].ToString();
            string  myReferrer = (Request.UrlReferrer == null) ? String.Empty : Request.UrlReferrer.OriginalString;

            lblBreadcrumb.Text = Request.QueryString["path"];
            
            if (myReferrer.IndexOf("Help.aspx", StringComparison.OrdinalIgnoreCase) < 0)
            {
                lblBreadcrumb.Text = Session["path"] as string;
                Session["path"] = String.Empty;
            }
            
            lblCtlName.Text = dt.Rows[0]["CtlClientID"] as string;

            switch (ctlType)
            {
                case CommonEnums.OnlineControlsTypes.Text:
                    pnlText.Visible = true;
                    lblCtlType.Text = "פקד טקסט";
                    HDN_FormatType.Value = dt.Rows[0]["Format"] as string;


                    
                    txtTextData_plain.Text = dt.Rows[0]["CtlData"] as string;
                    txtTextData_plain_Female.Text = dt.Rows[0]["CtlData_Female"] as string;                    

                    var isHtml = HDN_FormatType.Value == "html";
                    var cssClass = isHtml ? "ui-html-field" : "ui-text-field";
                    RTECopy1.Visible = isHtml;
                
                    //Turn on/off html editor by css class
                    txtTextData_plain.CssClass = cssClass;
                    txtTextData_plain_Female.CssClass = cssClass;


                    if (String.IsNullOrEmpty(txtTextData_plain.Text))
                        txtTextData_plain.Text = "<p>&nbsp;<p>";

                    if (String.IsNullOrEmpty(txtTextData_plain_Female.Text))
                        txtTextData_plain_Female.Text = "<p>&nbsp;<p>";

                    break;

                
                case CommonEnums.OnlineControlsTypes.Image:
                    pnlImage.Visible = true;
                    lblCtlType.Text = "פקד תמונה";
                    txtImagePath.Text = dt.Rows[0]["ImageUrl"].ToString();
                    txtImageAccessPath.Text = dt.Rows[0]["ImageUrlAccessible"].ToString();
                    txtAltText.Text = dt.Rows[0]["AltText"].ToString();

                    if (dt.Rows[0]["ImageUrl"].ToString() != string.Empty)
                        imgReg.Src = "~/" + ResourceGalleryDir + "/" + dt.Rows[0]["ImageUrl"].ToString();
                    else
                        imgReg.Attributes.Add("style", "display:none");

                    if (dt.Rows[0]["ImageUrlAccessible"].ToString() != string.Empty)
                        imgAccess.Src = "~/" + ResourceGalleryDir + "/" + dt.Rows[0]["ImageUrlAccessible"].ToString();
                    else
                        imgAccess.Attributes.Add("style", "display:none");
                    break;
                case CommonEnums.OnlineControlsTypes.Link:
                    pnlImage.Visible = true;
                    lblCtlType.Text = "פקד תמונה עם קישור";
                    pnlImageLink.Visible = true;
                    txtImagePath.Text = dt.Rows[0]["ImageUrl"].ToString();
                    txtImageAccessPath.Text = dt.Rows[0]["ImageUrlAccessible"].ToString();
                    txtAltText.Text = dt.Rows[0]["AltText"].ToString();

                    if (dt.Rows[0]["ImageUrl"].ToString() != string.Empty)
                        imgReg.Src = "~/" + ResourceGalleryDir + "/" + dt.Rows[0]["ImageUrl"].ToString();
                    else
                        imgReg.Attributes.Add("style", "display:none");

                    if (dt.Rows[0]["ImageUrlAccessible"].ToString() != string.Empty)
                        imgAccess.Src = "~/" + ResourceGalleryDir + "/" + dt.Rows[0]["ImageUrlAccessible"].ToString();
                    else
                        imgAccess.Attributes.Add("style", "display:none");

                    txtUrl.Text = dt.Rows[0]["Url"].ToString();
                    ddlTarget.DataBind();

                    if (dt.Rows[0]["WinTypeID"].ToString() != string.Empty)
                        ddlTarget.Items.FindByValue(dt.Rows[0]["WinTypeID"].ToString()).Selected = true;
                    break;
                case CommonEnums.OnlineControlsTypes.Help:
                    pnlHelp.Visible = true;
                    lblCtlType.Text = "פקד עזרה";
                    // ddlHelp.DataBind();

                    if (dt.Rows[0]["HelpID"].ToString() != string.Empty)
                    {
                        try
                        {
                            // DataTable dtHelp = OLHelpManager.GetByID(Convert.ToInt32(dt.Rows[0]["HelpID"].ToString()));
                            int appId = Convert.ToInt32(dt.Rows[0]["ApplicationID"].ToString());
                            // odsHelp.FilterParameters[0].DefaultValue = appId.ToString();
                            ddlHelp.DataBind();
                        }
                        catch (Exception ex1)
                        {

                            ClalitException ex = new ClalitException(ExceptionType.GENERAL, SeverityLevel.Error, ActionType.OnlineAdmin,
                                                                     "ShowInputControls   CtlID=" + ctlID.ToString(),
                                                                     ex1, this.GetType().Name);
                            ex.SendLog();
                        }
                        try
                        {
                            ddlHelp.Items.FindByValue(dt.Rows[0]["HelpID"].ToString()).Selected = true;
                        }
                        catch (Exception ex1)
                        {

                            ClalitException ex = new ClalitException(ExceptionType.GENERAL, SeverityLevel.Error, ActionType.OnlineAdmin,
                                                                     "ShowInputControls   CtlID=" + ctlID.ToString(),
                                                                     ex1, this.GetType().Name);
                            ex.SendLog();
                        }
                    }
                    break;
                case CommonEnums.OnlineControlsTypes.PrintAppendix:
                    pnlPrintAppendix.Visible = true;
                    lblCtlType.Text = "פקד נספח הדפסה";
      
                    if (dt.Rows[0]["MessageID"].ToString() != string.Empty)
                    {
                        try
                        {
                            int MessageId = Convert.ToInt32(dt.Rows[0]["MessageID"].ToString());
                            ddlPrintAppendix.DataBind();
                        }
                        catch (Exception ex1)
                        {

                            ClalitException ex = new ClalitException(ExceptionType.GENERAL, SeverityLevel.Error, ActionType.OnlineAdmin,
                                                                     "ShowInputControls   CtlID=" + ctlID.ToString(),
                                                                     ex1, this.GetType().Name);
                            ex.SendLog();
                        }
                        try
                        {
                            ddlPrintAppendix.Items.FindByValue(dt.Rows[0]["MessageID"].ToString()).Selected = true;
                        }
                        catch (Exception ex1)
                        {

                            ClalitException ex = new ClalitException(ExceptionType.GENERAL, SeverityLevel.Error, ActionType.OnlineAdmin,
                                                                     "ShowInputControls   CtlID=" + ctlID.ToString(),
                                                                     ex1, this.GetType().Name);
                            ex.SendLog();
                        }
                    }
                    break;
                case CommonEnums.OnlineControlsTypes.Validator:
                    pnlValidator.Visible = true;
                    lblCtlType.Text = "Validator פקד";
                    int MessageID = -1;
                    if(dt.Rows[0]["MessageID"] != DBNull.Value)
                        MessageID = Convert.ToInt32(dt.Rows[0]["MessageID"]);

                    PopulateValidationMessagesDDL(MessageID);
                    break;
                case CommonEnums.OnlineControlsTypes.HyperLink:
                    pnlHyperLink.Visible = true;
                    lblCtlType.Text = "פקד קישור";
                    txtHyperLink_URL.Visible = true;
                    txtHyperLink_URL.Enabled = true;
                    txtHyperLink_URL.Text = dt.Rows[0]["HPL_Url"].ToString();

                    txtHyperLink_Title.Visible = true;
                    txtHyperLink_Title.Enabled = true;
                    txtHyperLink_Title.Text = dt.Rows[0]["HPL_Title"].ToString();

                    ddlTargetHyperLink.DataBind();
                    if (dt.Rows[0]["HPL_WinTypeID"].ToString() != string.Empty)
                        ddlTargetHyperLink.Items.FindByValue(dt.Rows[0]["HPL_WinTypeID"].ToString()).Selected = true;
                    
                    ReqHyperLinkData_plain.Enabled = true;
                    ReqHyperLinkData_plain_Female.Enabled = true;
                    txtHyperLinkData_plain.Visible = true;
                    txtHyperLinkData_plain.Text = dt.Rows[0]["HPL_Data"].ToString();
                    txtHyperLinkData_plain_Female.Visible = true;
                    txtHyperLinkData_plain_Female.Text = dt.Rows[0]["HPL_Data_Female"].ToString();
                    RTECopy1.Visible = false;
                    
                    HDN_FormatType.Value = "text";// dt.Rows[0]["Format"].ToString();

                    break;


                default:
                    break;
            }
        }

        private void PopulateValidationMessagesDDL(int ItemMessageID)
        {
            int SectionID = -1;
            if (Request.QueryString["sectionID"] != null)
                SectionID = Convert.ToInt32(Request.QueryString["sectionID"]);

            DataTable dtValidators = OLMessagesManager.Filter(-1, SectionID, Convert.ToInt32(Enums.MessageTypes.Validator), string.Empty);
            if (dtValidators.Rows.Count > 0)
            {
                for (int i = 0; i < dtValidators.Rows.Count; i++)
                {
                    ListItem liValidator = new ListItem(dtValidators.Rows[i]["MessageKey"].ToString() +
                                                        " - " + dtValidators.Rows[i]["MessageDescription"].ToString(), dtValidators.Rows[i]["MessageID"].ToString());
                    ddlValidationMessages.Items.Add(liValidator);
                }
            }

            if (ItemMessageID != -1)
            {
                try
                {
                    ddlValidationMessages.Items.FindByValue(ItemMessageID.ToString()).Selected = true;
                }
                catch { };
            }

        }

        #endregion
    }
}
