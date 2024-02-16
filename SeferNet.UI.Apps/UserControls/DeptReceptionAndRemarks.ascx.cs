using System;
using System.Data;
using System.Web;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using SeferNet.Globals;

public partial class UserControls_DeptReceptionAndRemarks : System.Web.UI.UserControl
{
    DataSet m_dsClinic;
    Facade applicFacade;
    int DeptCode;
    string ServiceCodes = null;
    bool m_futureInfoMode = false;
    DateTime expirationDate;
    bool displayNonDefaultReceptionHours = false;
    bool displayOnlyFirstTwoTables = false;
    Int64 remarkEmployeeID = 0;
    string RemarkCategoriesForClinicActivity = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForClinicActivity"].ToString();
    string RemarkCategoriesForAbsence = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();


    protected void Page_Load(object sender, EventArgs e)
    {
        applicFacade = Facade.getFacadeObject();

        DeptCode = Convert.ToInt32(Request.QueryString["deptCode"]);

        if(Request.QueryString["ServiceCodes"] != null)
            ServiceCodes = Request.QueryString["ServiceCodes"].ToString();

        SetWindowMode();
        m_dsClinic = applicFacade.getClinicReceptionAndRemarks(DeptCode, expirationDate, ServiceCodes, RemarkCategoriesForAbsence, RemarkCategoriesForClinicActivity);
        BindHours();
        BindRemarks();
    }

    public bool DisplayNonDefaultReceptionHours
    {
        set {
            displayNonDefaultReceptionHours = value;  
        }
        get {
            return displayNonDefaultReceptionHours;
        }
    }

    public bool DisplayOnlyFirstTwoTables
    {
        set {
            displayOnlyFirstTwoTables = value;
        }
        get {
            return displayOnlyFirstTwoTables;
        }
    }
    


    public string MarginRightDefaultDiv
    {
        set {
            divDefaultReceptionHours.Style.Remove("margin-right");
            divDefaultReceptionHours.Style.Add("margin-right", value);
        }
    }

    public string MarginRightOtherReceptionHoursDiv
    {
        set
        {
            divOtherReceptionHours.Style.Remove("margin-right");
            divOtherReceptionHours.Style.Add("margin-right", value);
        }
    }

    public void BindHours()
    {
        if (m_dsClinic.Tables["ReceptionDaysUnited"] != null || m_dsClinic.Tables["ReceptionDaysUnited"].Rows.Count > 0)
        {
            int countRows = 0;
            bool defaultReceptionHoursDivIsFull = false;
            DataTable dtClosestDateChanges = m_dsClinic.Tables["closestDateChanges"];
            if (m_dsClinic.Tables["ReceptionHoursType"].Rows.Count > 0)
            {
                DataTable dtDefaultReceptionHoursType = m_dsClinic.Tables["DefaultReceptionHoursType"];
                string strDefaultReceptionHoursTypeID = "1";
                string strReceptionHoursTypeDescription = "שעות קבלה";
                string strClassName = "classA" + countRows.ToString();

                if (dtDefaultReceptionHoursType.Rows.Count > 0)
                {
                    strDefaultReceptionHoursTypeID = dtDefaultReceptionHoursType.Rows[0]["DefaultReceptionHoursTypeID"].ToString();
                    strReceptionHoursTypeDescription = dtDefaultReceptionHoursType.Rows[0]["ReceptionTypeDescription"].ToString();
                }


                UserControls_GridDeptReceptionHoursByType ucGridDeptReceptionHoursByType;
                ucGridDeptReceptionHoursByType = (UserControls_GridDeptReceptionHoursByType)Page.LoadControl(Request.ApplicationPath + "/UserControls/GridDeptReceptionHoursByType.ascx");

                DataView deptReception_ForOneType = new DataView(m_dsClinic.Tables["deptReception"],
                        "ReceptionHoursTypeID = " + strDefaultReceptionHoursTypeID, "receptionDay", DataViewRowState.CurrentRows);

                if (deptReception_ForOneType.Count > 0)
                {

                    CheckIfNeedExpireMessage(dtClosestDateChanges, strDefaultReceptionHoursTypeID, divDefaultReceptionHours, strReceptionHoursTypeDescription);



                    ucGridDeptReceptionHoursByType.ClinicReseptionHours = deptReception_ForOneType.ToTable();
                    ucGridDeptReceptionHoursByType.bindData();
                    ucGridDeptReceptionHoursByType.setMainDivClass(strClassName);
                    ucGridDeptReceptionHoursByType.ReceptionHoursTitle = strReceptionHoursTypeDescription;
                    ucGridDeptReceptionHoursByType.displayOpenCloseButton = false;
                    divDefaultReceptionHours.Controls.Add(ucGridDeptReceptionHoursByType);
                    countRows++;
                    defaultReceptionHoursDivIsFull = true;
                }

                int countNoneDefaultTables = 1;
                foreach (DataRow dr in m_dsClinic.Tables["ReceptionHoursType"].Rows)
                {
                    if (dr["ReceptionHoursTypeID"].ToString() != strDefaultReceptionHoursTypeID)
                    {
                        strClassName = "class" + countRows.ToString();
                        string strReceptionHoursTypeID = dr["ReceptionHoursTypeID"].ToString();
                        strReceptionHoursTypeDescription = dr["ReceptionTypeDescription"].ToString();
                        ucGridDeptReceptionHoursByType = (UserControls_GridDeptReceptionHoursByType)Page.LoadControl(Request.ApplicationPath + "/UserControls/GridDeptReceptionHoursByType.ascx");
                        deptReception_ForOneType = new DataView(m_dsClinic.Tables["deptReception"],
                                "ReceptionHoursTypeID = " + strReceptionHoursTypeID, "receptionDay", DataViewRowState.CurrentRows);


                        ucGridDeptReceptionHoursByType.ClinicReseptionHours = deptReception_ForOneType.ToTable();
                        ucGridDeptReceptionHoursByType.bindData();
                        ucGridDeptReceptionHoursByType.setMainDivClass(strClassName);
                        ucGridDeptReceptionHoursByType.ReceptionHoursTitle = strReceptionHoursTypeDescription;

                        if (defaultReceptionHoursDivIsFull)
                        {
                            CheckIfNeedExpireMessage(dtClosestDateChanges, strReceptionHoursTypeID, divOtherReceptionHours, strReceptionHoursTypeDescription);
                            divOtherReceptionHours.Controls.Add(ucGridDeptReceptionHoursByType);
                            if (countNoneDefaultTables > 1)
                            {
                                if (!DisplayOnlyFirstTwoTables)
                                    ucGridDeptReceptionHoursByType.showReceptionHours = true;
                                else
                                    ucGridDeptReceptionHoursByType.showReceptionHours = false;
                            }
                            countNoneDefaultTables++;
                        }
                        else
                        {
                            CheckIfNeedExpireMessage(dtClosestDateChanges, strReceptionHoursTypeID, divDefaultReceptionHours, strReceptionHoursTypeDescription);
                            ucGridDeptReceptionHoursByType.showReceptionHours = true;
                            ucGridDeptReceptionHoursByType.displayOpenCloseButton = false;
                            divDefaultReceptionHours.Controls.Add(ucGridDeptReceptionHoursByType);
                            defaultReceptionHoursDivIsFull = true;
                        }

                        countRows++;
                    }
                }
            }
        }

        
    }

    public bool BindRemarks()
    {
        gvRemarks.DataSource = m_dsClinic.Tables["deptRemarks"];
        gvRemarks.DataBind();

        if (m_dsClinic.Tables["employeeAndServiceRemarks"] != null)
        {
            gvEmployeeAndServiceRemarks.DataSource = m_dsClinic.Tables["employeeAndServiceRemarks"];
            gvEmployeeAndServiceRemarks.DataBind();
        }

        return true;
    }

    protected void gvRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Label lblRemark = e.Row.FindControl("lblRemark") as Label;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == false)
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא לתצוגה באינטרנט";
            }
            else
            {
                //imgInternet.Style.Add("display", "none");
                imgInternet.Visible = false;
            }

            if (dvRowView["IsSharedRemark"] != DBNull.Value && Convert.ToBoolean(dvRowView["IsSharedRemark"]))
            {
                lblRemark.Style.Add("color", "#628e02");
                e.Row.Style.Add("color", "#628e02");
            }

            string[] RemarkCategoriesForClinicActivityArr = RemarkCategoriesForClinicActivity.Split(',');
            for (int i = 0; i < RemarkCategoriesForClinicActivityArr.Length; i++)
            {
                if (RemarkCategoriesForClinicActivityArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }
        }
    }

    private void CheckIfNeedExpireMessage(DataTable dtClosestDates, string receptionHourTypeID, HtmlGenericControl containerDiv, string receptionHoursTypeDescription)
    {
        if (!m_futureInfoMode)
        {
            foreach (DataRow dr in dtClosestDates.Rows)
            {
                if (dr["ReceptionHoursTypeID"].ToString() == receptionHourTypeID)
                {
                    DateTime dtNextChange = Convert.ToDateTime(dr["nextDateChange"]);
                    HtmlGenericControl divOfficeExpireWarning = new HtmlGenericControl("div");

                    divOfficeExpireWarning.Attributes.Add("onclick", "OpenNewHoursWindow('" + DeptCode + "','" + dtNextChange + "');");

                    HtmlGenericControl spanMessage = new HtmlGenericControl("span");
                    spanMessage.Attributes.Add("class", "LooksLikeHRefBold");
                    spanMessage.InnerHtml = string.Format(ConstsSystem.GENERAL_EXPIRE_MESSAGE, dtNextChange.ToShortDateString()) + receptionHoursTypeDescription;
                    divOfficeExpireWarning.Controls.Add(spanMessage);

                    containerDiv.Controls.Add(divOfficeExpireWarning);
                    break;
                }
            }

        }

    }

    private void SetWindowMode()
    {
        if (!string.IsNullOrEmpty(Request.QueryString["expirationDate"]))
        {
            DateTime.TryParse(Request.QueryString["expirationDate"].ToString(), out expirationDate);

            m_futureInfoMode = true;
        }
    }

    protected void gvEmployeeAndServiceRemarks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            Label lblRemark = e.Row.FindControl("lblRemark") as Label;

            Image imgInternet = e.Row.FindControl("imgInternet") as Image;
            if (Convert.ToBoolean(dvRowView["displayInInternet"]) == false)
            {
                imgInternet.Style.Add("display", "inline");
                imgInternet.ImageUrl = "../Images/Applic/pic_NotShowInInternet.gif";
                imgInternet.ToolTip = "לא לתצוגה באינטרנט";
            }
            else
            {
                imgInternet.Visible = false;
            }


            if (dvRowView["employeeID"] != DBNull.Value && (Convert.ToInt64(dvRowView["employeeID"])) == remarkEmployeeID)
            {
                Label lblEmployeeName = e.Row.FindControl("lblEmployeeName") as Label;
                lblEmployeeName.Visible = false;
            }
            else
            {
                remarkEmployeeID = Convert.ToInt64(dvRowView["employeeID"]);
            }

            string[] RemarkCategoriesForAbsenceArr = RemarkCategoriesForAbsence.Split(',');
            for (int i = 0; i < RemarkCategoriesForAbsenceArr.Length; i++)
            {
                if (RemarkCategoriesForAbsenceArr[i] == dvRowView["RemarkCategoryID"].ToString())
                {
                    lblRemark.CssClass = "LabelBoldRed_13";
                }
            }

        }
    }
}

