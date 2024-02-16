using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;
using SeferNet.BusinessLayer.ObjectDataSource;
using SeferNet.FacadeLayer;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;

public partial class Admin_EditRemarkByselectedType : System.Web.UI.Page
{   
	private Facade applicFacade;
    private UserManager userManager = new UserManager();

    #region ----------- Properties

    private DataTable TableRemarks
	{
		get
		{
			if (ViewState["TableRemarks"] != null)
			{
				return (DataTable)ViewState["TableRemarks"];
			}
			else
			{
				return null;
			}
		}
		set
		{
			ViewState["TableRemarks"] = value;
		}
	}

	private int remarkID
	{
		get
		{
			if (ViewState["remarkID"] != null)
			{
				return (int)ViewState["remarkID"];
			}
			else
			{
				return 0;
			}
		}
		set
		{
			ViewState["remarkID"] = value;
		}
	}

	private string remarkType
	{
		get
		{
			if (ViewState["remarkType"] != null)
			{
				return (string)ViewState["remarkType"];
			}
			else
			{
				return "-1";
			}
		}
		set
		{
			ViewState["remarkType"] = value;
		}
	}

	#endregion

	#region ---------- Binding

	protected void dvGeneralRemarks_DataBound(object sender, EventArgs e)
	{
		Enums.remarkType selRemType = (Enums.remarkType)Enum.Parse(typeof(Enums.remarkType), this.remarkType);
		CheckBox chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
			
		//---  add new remark mode
		if (this.remarkID == 0)
		{
			this.dvGeneralRemarks.Fields[0].Visible = false;
		}
		//--- update remark mode
		else
		{
			this.dvGeneralRemarks.Fields[0].Visible = true;

			//if (chk != null)
			//{
			//    //chk.Attributes.Add("onchange", "linkedToReceptionHours_CheckedChanged(this)");
			//    chk.Attributes.Add("onchange", "alert('checkBox Changed'); ");
			//    chk.Attributes.Add("onclick", "linkedToReceptionHours_CheckedChanged(this)");
			//}

		}
		//this.linkedToReceptionHours_CheckedChanged(this, null);
	}

	private void BindDvGeneralRemarks()
	{
		DataSet data = this.applicFacade.GetGeneralRemarkByRemarkID(this.remarkID);
		if (data.Tables.Count == 0)
			return;
		// --- insert new remark mode
		if (data.Tables[0].Rows.Count == 0)
		{
			DataRow newRow = data.Tables[0].NewRow();
			newRow["remarkID"] = 0;
			newRow["remark"] = string.Empty;
			newRow["active"] = true;
			newRow["RemarkCategoryID"] = 1;
			newRow["linkedToDept"] = false;
			newRow["linkedToDoctor"] = false;
			newRow["linkedToServiceInClinic"] = false;
			newRow["linkedToReceptionHours"] = false;
			newRow["EnableOverlappingHours"] = false;
			newRow["Factor"] = 1;
			newRow["OpenNow"] = true;
			newRow["ShowForPreviousDays"] = 10;

			Enums.remarkType selRemType = (Enums.remarkType)Enum.Parse(typeof(Enums.remarkType), this.remarkType);

			switch (selRemType)
			{
				case Enums.remarkType.Clinic:
					newRow["linkedToDept"] = true;
					newRow["linkedToReceptionHours"] = true;
					break;
				case Enums.remarkType.Doctor:
				case Enums.remarkType.DoctorInClinic:
					newRow["linkedToDoctor"] = true;
					break;
				case Enums.remarkType.ServiceInClinic:
					newRow["linkedToServiceInClinic"] = true;
					break;
				case Enums.remarkType.ReceptionHours:
					newRow["linkedToReceptionHours"] = true;
					break;

				default:
					newRow["linkedToDept"] = true;
					break;
			}
			data.Tables[0].Rows.Add(newRow);
		}
		//--- update remark mode
		else
		{
            //if (data.Tables[0].Rows[0]["linkedToDept"] as bool? == true)
            //{
            //    data.Tables[0].Rows[0]["linkedToReceptionHours"] = true;
            //}
		}

		this.TableRemarks = data.Tables[0];
		this.dvGeneralRemarks.DataSource = data.Tables[0];
		this.dvGeneralRemarks.DataBind();

        Set_btnSaveAndRenewRemarks();
    }

    private void Set_btnSaveAndRenewRemarks()
    {
        bool remarkIsSimple = false;
        if (remarkID != 0)
        {
            string remarkText = TableRemarks.Rows[0]["remark"].ToString();
            if (remarkText.IndexOf('#') < 0)
            {
                remarkIsSimple = true;
            }
        }

        if (userManager.UserIsAdministrator() && remarkID != 0 && remarkIsSimple)
        {
            btnSaveAndRenewRemarks.Enabled = true;
        }
        else
        {
            btnSaveAndRenewRemarks.Enabled = false;
        }

    }


    private void BindDdlRemarkCategories()
	{
		DropDownList ddlRemarkCategory = this.dvGeneralRemarks.FindControl("ddlRemarkCategory") as DropDownList;
		ddlRemarkCategory.DataValueField = "RemarkCategoryID";
		ddlRemarkCategory.DataTextField = "RemarkCategoryName";
		ddlRemarkCategory.Items.Clear();

		UIHelper.BindDropDownToCachedTable(ddlRemarkCategory, "DIC_RemarkCategory", "RemarkCategoryName");

		//-- select default item
		//--- update remark mode
		if (this.remarkID != 0)
		{
			ddlRemarkCategory.SelectedValue = this.TableRemarks.Rows[0]["RemarkCategoryID"].ToString();
		}
		else //--- Insert new remark mode
		{
			ddlRemarkCategory.SelectedValue = "1";
		}
	}

    private void BindDdlRemarkFactor()
	{
		DropDownList ddlRemarkFactor = this.dvGeneralRemarks.FindControl("ddlRemarkFactor") as DropDownList;
        ddlRemarkFactor.DataValueField = "FactorValue";
        ddlRemarkFactor.DataTextField = "FactorDescription";
        ddlRemarkFactor.Items.Clear();

		UIHelper.BindDropDownToCachedTable(ddlRemarkFactor, "WeeklyHoursFactors", "FactorValue DESC");

		//-- select default item
		//--- update remark mode
		if (this.remarkID != 0)
		{
            ddlRemarkFactor.SelectedValue = this.TableRemarks.Rows[0]["Factor"].ToString();
		}
		else //--- Insert new remark mode
		{
            ddlRemarkFactor.SelectedValue = "1";
		}
	}

	
	#endregion

	#region ------------ Events handlers
	
	protected void Page_Load(object sender, EventArgs e)
	{
		this.applicFacade = Facade.getFacadeObject();
		if (!Page.IsPostBack)
		{
			this.SavePrevPageToViewState();
			this.remarkID = this.GetSelectedRemarkID_fromRequest();
			this.remarkType = this.GetRemarkType_fromRequest();

			this.BindDvGeneralRemarks();
			this.BindDdlRemarkCategories();
			this.BindDdlRemarkFactor();
		}
	}
	
	protected void btnSave_Click(object sender, EventArgs e)
	{
        SaveRemark();

        this.MoveToPrevPage();
	}

	protected void btnSaveAndRenewRemarks_Click(object sender, EventArgs e)
	{
        SaveRemark();

        RenewRemarks();

        this.MoveToPrevPage();
	}

    private void RenewRemarks()
    {
        this.applicFacade.RenewRemarks(remarkID, userManager.GetUserNameForLog());
    }

    private void SaveRemark()
    {
        TextBox tbRemark = this.dvGeneralRemarks.FindControl("txtRemark") as TextBox;
        string remarkText = string.Empty;
        if (tbRemark != null && tbRemark.Text != string.Empty)
        {
            //remarkText = Server.HtmlEncode(tbRemark.Text);
            remarkText = tbRemark.Text;
        }

        int remarkCategory = int.Parse((this.dvGeneralRemarks.FindControl("ddlRemarkCategory") as DropDownList).SelectedValue);

        bool active = (this.dvGeneralRemarks.FindControl("cbActive") as CheckBox).Checked;

        bool linkedToDept = (this.dvGeneralRemarks.FindControl("cblinkedToDept") as CheckBox).Checked;
        bool linkedToDoctor = (this.dvGeneralRemarks.FindControl("cblinkedToDoctor") as CheckBox).Checked;
        bool linkedToServiceInClinic = (this.dvGeneralRemarks.FindControl("cblinkedToServiceInClinic") as CheckBox).Checked;
        bool linkedToReceptionHours = (this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox).Checked;
        bool enableOverlappingHours = (this.dvGeneralRemarks.FindControl("cbEnableOverlappingHours") as CheckBox).Checked;
        float factor = float.Parse((this.dvGeneralRemarks.FindControl("ddlRemarkFactor") as DropDownList).SelectedValue);
		bool openNow = (this.dvGeneralRemarks.FindControl("cbOpenNow") as CheckBox).Checked;

		string showForPreviousDays_str = (this.dvGeneralRemarks.FindControl("txtShowForPreviousDays") as TextBox).Text;
		int showForPreviousDays;
		if (showForPreviousDays_str.Trim() == string.Empty)
		{
			showForPreviousDays = 0;
		}
		else
		{
			showForPreviousDays = Convert.ToInt32(showForPreviousDays_str);
		}

		// insert new remark
		if (this.remarkID == 0)
        {
            this.applicFacade.InsertDicGeneralRemark(
                remarkText,
                remarkCategory,
                active,
                linkedToDept,
                linkedToDoctor,
                false,
                linkedToServiceInClinic,
                linkedToReceptionHours,
                enableOverlappingHours,
                factor,
				openNow,
				showForPreviousDays,
				userManager.GetUserNameForLog()
                );
        }
        // update remark
        else
        {
            this.applicFacade.UpdateDicGeneralRemark(
                this.remarkID,
                remarkText,
                remarkCategory,
                active,
                linkedToDept,
                linkedToDoctor,
                false,
                linkedToServiceInClinic,
                linkedToReceptionHours,
                enableOverlappingHours,
                factor,
				openNow,
				showForPreviousDays,
				userManager.GetUserNameForLog()
                );
        }
    }

	protected void btnCancel_Click(object sender, EventArgs e)
	{
		this.MoveToPrevPage();
	}

	//protected void linkedToReceptionHours_CheckedChanged(object sender, EventArgs e)
	//{
	//	CheckBox chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
 //       HtmlTable tbl = this.dvGeneralRemarks.FindControl("tblRemarkFactor") as HtmlTable;

	//	if (chk != null)
	//	{
	//		if (chk.Checked)
	//		{
	//			this.dvGeneralRemarks.Fields[8].Visible = true;
 //               tbl.Visible = true;
 //           }
	//		else
	//		{
	//			this.dvGeneralRemarks.Fields[8].Visible = false;
 //               tbl.Visible = false;
	//		}
	//	}
	//}
        
    #endregion

	#region ------------ Private Methods --------------

	private void SavePrevPageToViewState()
	{
		ViewState["PrevPage"] = this.GetPrevPage_fromRequest(); ;
	}

	private void MoveToPrevPage()
	{
		if (ViewState["PrevPage"] != null)
		{
			Response.Redirect(ViewState["PrevPage"].ToString());
		}
	}

	#endregion 

	#region ------------ Get Request Variables

	private int GetSelectedRemarkID_fromRequest()
	{
		if (this.Request["selectedRemarkID"] != null
			&& !string.IsNullOrEmpty(this.Request["selectedRemarkID"]))
		{
			int id = 0;
			int.TryParse(this.Request["selectedRemarkID"], out id);
			return id;
		}
		else
			return 0;
	}

	private string GetPrevPage_fromRequest()
	{
		if (Request["PrevPage"] != null && Request["PrevPage"].ToString() != String.Empty)
		{
			return Request["PrevPage"].ToString();
		}
		else
			return string.Empty;
	}

	private string GetRemarkType_fromRequest()
	{
		if (Request["remarkType"] != null && Request["remarkType"].ToString() != String.Empty)
		{
			return Request["remarkType"].ToString();
		}
		else
			return string.Empty;
	}

	#endregion
 
	//private void BindCbLinkedTo(string remarkType)
	//{
	//    CheckBox chk = null;

	//        switch (this.remarkType) 
	//        {
	//            case "5":
	//                chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
	//                break;
	//            case "1":
	//                chk = this.dvGeneralRemarks.FindControl("cblinkedToDept") as CheckBox;
	//                break;
	//            case "2":
	//                chk = this.dvGeneralRemarks.FindControl("cblinkedToDoctor") as CheckBox;
	//                break;
	//            case "4":
	//                chk = this.dvGeneralRemarks.FindControl("cblinkedToServiceInClinic") as CheckBox;
	//                break;
	//        }

	//        if (chk != null)
	//        {
	//            chk.Checked = true;
	//        }

	//        chk = this.dvGeneralRemarks.FindControl("cbActive") as CheckBox;
	//        if (chk != null)
	//        {
	//            chk.Checked = true;
	//        }

	//        TextBox txt = this.dvGeneralRemarks.FindControl("txtRemark") as TextBox;
	//        if (txt != null && txt.Text != String.Empty)
	//        {
	//            string remark = txt.Text;
	//            //remark = remark.Replace("&#34;", "\"");
	//            //remark = remark.Replace("&lt;", "\'");
	//            //remark = remark.Replace("&acute;", "<");
	//            //remark = remark.Replace("&gt;", ">");
	//            txt.Text = Server.HtmlEncode(remark);
	//        }
	//}

	
	//protected void dvGeneralRemarks_ModeChanged(object sender, EventArgs e)
	//{
	//    if (this.dvGeneralRemarks.CurrentMode == DetailsViewMode.ReadOnly)
	//    {
	//        trDvDetailesView.Style.Add("display", "none");
	//    }

	//    if (this.dvGeneralRemarks.CurrentMode == DetailsViewMode.ReadOnly)
	//    {
	//        this.MoveToPrevPage();
	//        //String scriptString = "<script language=\"JavaScript\">window.close();</script>";
	//        //ClientScript.RegisterClientScriptBlock(this.GetType(), "clientScript", scriptString);
	//    }
	//}


  
	//     //CheckBox chk = null;
                 
	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
	//        if( chk.Checked == true)
	//           hdn_cblinkedToReceptionHours.Value = "1";
                  
	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToDept") as CheckBox;
	//        if(chk.Checked == true)
	//            hdn_cblinkedToDept.Value = "1";
                 
	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToDoctor") as CheckBox;
	//        if(chk.Checked == true)
	//            hdn_cblinkedToDoctor.Value = "1";
                   
	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToServiceInClinic") as CheckBox;
	//        if(chk.Checked == true)
	//            hdn_cblinkedToServiceInClinic.Value = "1";                                        

	//        chk = this.dvGeneralRemarks.FindControl("cbActive") as CheckBox;
	//        if (chk.Checked == true)
	//            hdn_cbActive.Value = "1";

	//   TextBox t =  this.dvGeneralRemarks.FindControl("txtRemark") as TextBox;
	//   if (t != null && t.Text != string.Empty)
	//   {
	//       string remark = Request.Form[4].ToString();
	//       remark = Server.HtmlEncode(remark);
	//       ViewState["remark"] = t.Text;
	//   }
	//}
	//private void SelectRemarkType()
	//{
	//    CheckBox chk = null;
	//    try
	//    {

	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToReceptionHours") as CheckBox;
	//        if(chk != null &&  hdn_cblinkedToReceptionHours.Value == "1")
	//            chk.Checked = true;

	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToDept") as CheckBox;
	//        if (chk != null && hdn_cblinkedToDept.Value == "1")
	//            chk.Checked = true;

	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToDoctor") as CheckBox;
	//        if (chk != null && hdn_cblinkedToDoctor.Value == "1")
	//            chk.Checked = true;

	//        chk = this.dvGeneralRemarks.FindControl("cblinkedToServiceInClinic") as CheckBox;
	//        if (chk != null && hdn_cblinkedToServiceInClinic.Value == "1")
	//            chk.Checked = true;                                        

	//        chk = this.dvGeneralRemarks.FindControl("cbActive") as CheckBox;
	//        if (chk != null && hdn_cbActive.Value == "1")
	//            chk.Checked = true;
	//        TextBox txt = this.dvGeneralRemarks.FindControl("txtRemark") as TextBox;
	//        if (txt != null)
	//        {
	//            string remark = String.Empty;
	//            if (ViewState["remark"] != null)
	//            {
	//                remark = ViewState["remark"].ToString();
	//            }
	//            else if (txt.Text != String.Empty)
	//            {
	//                remark = txt.Text;
	//            }

	//            //remark = remark.Replace("&#34;", "\"");
	//            //remark = remark.Replace("&acute;", "\'");
	//            //remark = remark.Replace("&lt;", "<");
	//            //remark = remark.Replace("&gt;", ">");
	//            //txt.Text = Server.HtmlEncode(remark);
	//            txt.Text = Server.HtmlDecode(remark);

	//        }                 
	//    }
	//    catch (Exception ex)
	//    {
	//        throw new Exception(ex.Message);
	//    }

	//}

	//protected void odsForDv_Inserted(object sender, ObjectDataSourceStatusEventArgs e)
	//{
	//    if (e.Exception != null)
	//    {
	//        SqlException ex = e.Exception.InnerException as SqlException;
	//        if (ex != null)
	//        {
	//            Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalUpdateError") as string;
	//        }
	//        trDvDetailesView.Style.Add("display", "inline");
	//        e.ExceptionHandled = true;
	//    }
	//    else
	//    {
	//        this.MoveToPrevPage();
	//    }
	//}

	//protected void odsForDv_Selecting(object sender, ObjectDataSourceSelectingEventArgs e)
	//{
	//    try
	//    {
	//        if (GetSelectedRemarkID_fromRequest() != String.Empty)
	//            e.InputParameters.Add("remarkID", GetSelectedRemarkID_fromRequest());
	//        else
	//            e.InputParameters.Add("remarkID", 0);

	//    }
	//    catch (Exception)
	//    {
	//        throw;
	//    }
	//}

	//protected void odsForDv_Updating(object sender, ObjectDataSourceMethodEventArgs e)
	//{
	//    try
	//    {
	//        if (GetSelectedRemarkID_fromRequest() != String.Empty)
	//            e.InputParameters.Add("remarkID", int.Parse(GetSelectedRemarkID_fromRequest()));
	//    }
	//    catch (Exception)
	//    {
	//        throw;
	//    }
	//}
	//protected void odsForDv_Inserting(object sender, ObjectDataSourceMethodEventArgs e)
	//{

	//    if (e.InputParameters["remark"] != null)
	//    {
	//        string remark = e.InputParameters["remark"].ToString();           
	//        e.InputParameters["remark"] = Server.HtmlEncode(remark);
	//    }
	//    else
	//    {
	//        string remark = Request.Form[4].ToString();

	//        e.InputParameters["remark"] = Server.HtmlEncode(remark);

	//        e.InputParameters["active"] = Convert.ToBoolean( Convert.ToInt32( hdn_cbActive.Value)) ;
	//        e.InputParameters["EnableOverlappingHours"] = Convert.ToBoolean( Convert.ToInt32(  hdn_cbEnableOverlappingHours.Value));
	//        e.InputParameters["linkedToDept"] = Convert.ToBoolean( Convert.ToInt32(  hdn_cblinkedToDept.Value));
	//        e.InputParameters["linkedToDoctor"] = Convert.ToBoolean( Convert.ToInt32( hdn_cblinkedToDoctor.Value));          
	//        e.InputParameters["linkedToServiceInClinic"] = Convert.ToBoolean( Convert.ToInt32( hdn_cblinkedToServiceInClinic.Value));
	//        e.InputParameters["linkedToReceptionHours"] = Convert.ToBoolean(Convert.ToInt32(hdn_cblinkedToReceptionHours.Value));              

	//    }        
	//}

	//protected void odsForDv_Updated(object sender, ObjectDataSourceStatusEventArgs e)
	//{

	//    if (e.Exception != null)
	//    {
	//        SqlException ex = e.Exception.InnerException as SqlException;
	//        if (ex != null)
	//        {
	//            Session["ErrorMessage"] = HttpContext.GetGlobalResourceObject("ErrorResource", "generalUpdateError") as string;
	//        }
	//        trDvDetailesView.Style.Add("display", "inline");
	//        e.ExceptionHandled = true;
	//    }
	//    else
	//    {
	//        this.MoveToPrevPage();
	//        //if (!ClientScript.IsClientScriptBlockRegistered("clientScript"))
	//        //{
	//        //    // Form the script that is to be registered at client side.
	//        //    String scriptString = "<script language=\"JavaScript\">window.close();</script>";
	//        //    ClientScript.RegisterClientScriptBlock(this.GetType(), "clientScript", scriptString);
	//        //}
	//    }
	//}
	
}
