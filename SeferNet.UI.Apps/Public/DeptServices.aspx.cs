using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.Globals;
using SeferNet.BusinessLayer.WorkFlow;
using System.Web.UI.HtmlControls;
public partial class Public_DeptServices : System.Web.UI.Page
{
    DataSet m_dsClinic;
    Facade applicFacade = Facade.getFacadeObject();
    int m_DeptCode;
    int currentGridSelectedIndex = -1;
    SessionParams sessionParams;
    UserInfo currentUser;
    bool m_isDeptPermittedForUser;
    bool hasServiceRelevantForReceivingGuests = false;
    string RemarkCategoriesForAbsence = System.Configuration.ConfigurationManager.AppSettings["RemarkCategoriesForAbsence"].ToString();

    private DataSet DeptServices
    {
        get
        {
            if (ViewState["DeptServices"] != null)
                return ViewState["DeptServices"] as DataSet;
            else
            {
                DataSet ds = null;
                m_DeptCode = Int32.Parse(Request.QueryString["deptCode"]);
                ds = applicFacade.getClinicServices(m_DeptCode);
                ViewState["DeptServices"] = ds;
                return ds;
            }
        }
        set
        {
            ViewState["DeptServices"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        m_dsClinic = DeptServices;
        sessionParams = SessionParamsHandler.GetSessionParams();
        currentUser = Session["currentUser"] as UserInfo;
        m_isDeptPermittedForUser = applicFacade.IsDeptPermitted(m_DeptCode);

        if (!IsPostBack)
        {

            if (Request.QueryString["scrtop"] != null)
            {
                txtScrollTop_divDoctorsAndEmployees.Value = Request.QueryString["scrtop"].ToString();
            }

            setImageForDeptAttribution();
            setDeptName();


            BindDoctorsAndReceptions();

            BindDeptEvents();
            setUpdateButtons();
        }




    }







    private void setUpdateButtons()
    {
        if (currentUser != null)
        {
            if (gvEvents.Rows.Count == 0)
            {
                tblEventsHeader.Style.Add("display", "none");
                lblNoEvents.Visible = true;
                divUpdateEvents.Style.Add("display", "block");
                //spanImg.Style.Add("display", "none");
                spanImg.Visible = false;
            }

            if (m_isDeptPermittedForUser || currentUser.IsAdministrator)
            {
                divUpdateDoctors.Style.Remove("display");
                divUpdateDoctors.Style.Add("display", "inline");

                divUpdateEvents.Style.Remove("display");
                divUpdateEvents.Style.Add("display", "inline");
            }
            else
            {
                divUpdateDoctors.Style.Remove("display");
                divUpdateDoctors.Style.Add("display", "none");

                divUpdateEvents.Style.Remove("display");
                divUpdateEvents.Style.Add("display", "none");
            }
        }
        else
        {
            divUpdateDoctors.Style.Remove("display");
            divUpdateDoctors.Style.Add("display", "none");

            divUpdateEvents.Style.Add("display", "none");
            if (gvEvents.Rows.Count == 0)
            {

                lblNoEvents.Visible = true;
                tblEventsHeader.Style.Add("display", "none");
                //spanImg.Style.Add("display", "none");
                spanImg.Visible = false;
            }


        }
    }

    private void setImageForDeptAttribution()
    {
        bool isCommunity = bool.Parse(Request.QueryString["isCommunity"]);
        bool isMushlam = bool.Parse(Request.QueryString["isMushlam"]);
        bool isHospital = bool.Parse(Request.QueryString["isHospital"]);
        int subUnitTypeCode = int.Parse(Request.QueryString["subUnitTypeCode"]);
        UIHelper.SetImageForDeptAttribution(ref imgAttributed_4, isCommunity, isMushlam, isHospital, subUnitTypeCode);
    }

    private void setDeptName()
    {
        lblDeptName_Employees.Text = sessionParams.DeptName;
    }


    protected void btnDeleteDoctorInClinic_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteDoctorInClinic = sender as ImageButton;
        int deptEmployeeID = Convert.ToInt32(btnDeleteDoctorInClinic.Attributes["DeptEmployeeID"]);

        SeferNet.BusinessLayer.ObjectDataSource.DoctorsInClinicBO bo = new SeferNet.BusinessLayer.ObjectDataSource.DoctorsInClinicBO();
        
        if (m_DeptCode == 0)
        {
            m_DeptCode = Int32.Parse(Request.QueryString["deptCode"]);
        }
        
        bo.DeleteDoctorInClinic(deptEmployeeID, m_DeptCode);

        Facade.getFacadeObject().Insert_LogChange((int)Enums.ChangeType.EmployeeInClinic_Delete, currentUser.UserID, m_DeptCode, null, deptEmployeeID, null, null, null, null);            

        //DBActionNotification.RaiseOnDBAction_targeted((int)Enums.Target.EmployeeInClinic_Delete, 0, 0, 0, m_DeptCode);

        DeptServices = null;
        m_dsClinic = DeptServices;
        BindDoctorsAndReceptions();
    }

    protected void gvDoctors_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridView gvDoctors = (GridView)sender;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Image imgReceiveGuests = e.Row.FindControl("imgReceiveGuests") as Image;

            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            long currEmployeeID = Convert.ToInt64(dvRowView["EmployeeID"]);
            int currDeptEmployeeID = Convert.ToInt32(dvRowView["DeptEmployeeID"]);
            int rowID = Convert.ToInt32(dvRowView["rowID"]);

            // mark "Employee in clinic" after return from page "UpdateDeptEmployee.aspx"
            if (sessionParams.MarkEmployeeInClinicSelected == true && sessionParams.EmployeeID == currEmployeeID
                && sessionParams.RowID == rowID)
            {
                currentGridSelectedIndex = e.Row.RowIndex;
                sessionParams.MarkEmployeeInClinicSelected = false;
            }


            PlaceHolder pnlEditButton = e.Row.FindControl("pnlEditButton") as PlaceHolder;
            Enums.Status currEmployeeStatus = (Enums.Status)Enum.Parse(typeof(Enums.Status), dvRowView["Active"].ToString());
            bool displayNotActiveEmployees = currentUser != null &&
                                                                (m_isDeptPermittedForUser || currentUser.IsAdministrator);

            // if employee is not active - the default is to hide the row, unless the user is logged-in, and then we display the row
            if (currEmployeeStatus != Enums.Status.Active)
            {
                if (displayNotActiveEmployees)
                {
                    Label lblDoctorsName = e.Row.FindControl("lblDoctorsName") as Label;
                    lblDoctorsName.Style.Add("color", "red");
                }
                else
                {
                    e.Row.Visible = false;
                    return;
                }
            }

            if (currentUser != null)
            {

                if (m_isDeptPermittedForUser || currentUser.IsAdministrator)
                {
                    pnlEditButton.Visible = true;

                    e.Row.Visible = true;

                    if (currEmployeeStatus == Enums.Status.TemporaryNotActive)
                    {
                        e.Row.CssClass = "temporaryNotActive";
                    }

                    if (currEmployeeStatus == Enums.Status.NotActive)
                    {
                        e.Row.CssClass = "notActive";
                    }

                    if (currentUser.IsAdministrator)
                        {
                            ImageButton btnDeleteDoctorInClinic = e.Row.FindControl("btnDeleteDoctorInClinic") as ImageButton;
                            btnDeleteDoctorInClinic.Style.Add("display", "inline");
                        }
                    else
                    {
                        ImageButton btnDeleteDoctorInClinic = e.Row.FindControl("btnDeleteDoctorInClinic") as ImageButton;
                        btnDeleteDoctorInClinic.Style.Add("display", "none");
                    }
                }
                else
                {
                    pnlEditButton.Visible = false;
                }
            }
            else
            {
                pnlEditButton.Visible = false;
            }

            GridView gvPositions = e.Row.FindControl("gvPositions") as GridView;
            GridView gvProfessions = e.Row.FindControl("gvProfessions") as GridView;

            var positions = from pos in m_dsClinic.Tables["DeptEmployeePositions"].AsEnumerable()
                            where pos.Field<long>("DeptEmployeeID") == currDeptEmployeeID
                            orderby pos.Field<int>("positionCode")
                            select new { positionDescription = pos.Field<string>("positionDescription") };

            if (positions.Count() > 0)
            {
                gvPositions.DataSource = positions;
                gvPositions.DataBind();
            }

            string empServices = dvRowView["Services"].ToString();
            eDIC_AgreementTypes agreementTypeCondition = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes),
                                                                                dvRowView["AgreementType"].ToString());
            string agreementCondition = AgreementTypeCondition(agreementTypeCondition);

            if (!string.IsNullOrEmpty(empServices))
            {
                DataView dvProfessions = new DataView(m_dsClinic.Tables["DeptEmployeeProfessions"],
                            "DeptEmployeeID = " + dvRowView["DeptEmployeeID"] + " AND ProfessionCode IN (" + empServices + ")" + agreementCondition, //Sector = " + _currentSectorSection,  //+ " AND EmployeeServiceQueueOrderGroup LIKE '" + dvRowView["EmployeeServiceQueueOrderGroup"] + "'", 
                            "professionDescription", DataViewRowState.OriginalRows);
                gvProfessions.DataSource = dvProfessions;
                gvProfessions.DataBind();
            }

            HtmlAnchor doctorLink = e.Row.FindControl("aDoctorLink") as HtmlAnchor;
            doctorLink.Attributes.Add("onclick", "goToService('" + dvRowView["employeeID"] + "');");
            // if medical team doesn't have professions - don't show the record in the specific sector
            if ((dvRowView["IsMedicalTeam"] != DBNull.Value && Convert.ToBoolean(dvRowView["IsMedicalTeam"]) == true)
                    || (dvRowView["IsVirtualDoctor"] != DBNull.Value && Convert.ToBoolean(dvRowView["IsVirtualDoctor"]) == true))
            {
                Label lblDoctorsName = e.Row.FindControl("lblDoctorsName") as Label;

                //LinkButton doctorLink = e.Row.FindControl("doctorLink") as LinkButton;
                lblDoctorsName.Visible = true;
                doctorLink.Visible = false;
            }

            if (Convert.ToBoolean(dvRowView["IsVirtualDoctor"]) == true)
            {
                Label lblExpert = e.Row.FindControl("lblExpert") as Label;
                lblExpert.Visible = false;
            }

            if (!string.IsNullOrEmpty(empServices))
            {
                GridView gvServices = e.Row.FindControl("gvServices") as GridView;
                DataView dvServices = new DataView(m_dsClinic.Tables["DeptEmployeeServices"],
                    "DeptEmployeeID = " + dvRowView["DeptEmployeeID"] + " AND ServiceCode IN (" + empServices + ")" + agreementCondition,  //AND Sector = " + _currentSectorSection,  //+ " AND EmployeeServiceQueueOrderGroup LIKE '" + dvRowView["EmployeeServiceQueueOrderGroup"] + "'", 
                    "serviceDescription", DataViewRowState.OriginalRows);
                gvServices.DataSource = dvServices;
                gvServices.DataBind();
            }


            HtmlTableCell tdEmployeeQueueOrderMethods = e.Row.FindControl("tdEmployeeQueueOrderMethods") as HtmlTableCell;
            string queueOrderDescription = dvRowView["QueueOrderDescription"].ToString();
            DataView dvEmployeeQueueOrderMethods = new DataView();

            if (!string.IsNullOrEmpty(empServices))
            {
                dvEmployeeQueueOrderMethods = new DataView(m_dsClinic.Tables["EmployeeQueueOrderMethods"],
                    "DeptEmployeeID = " + dvRowView["DeptEmployeeID"] + " AND ServiceCode IN (" + empServices + ")",
                    "QueueOrderMethod", DataViewRowState.OriginalRows);
            }


            if (dvEmployeeQueueOrderMethods.Count == 0 && string.IsNullOrEmpty(queueOrderDescription)) // check employee in dept queue order
            {
                dvEmployeeQueueOrderMethods = new DataView(m_dsClinic.Tables["EmployeeQueueOrderMethods"],
                "DeptEmployeeID = " + dvRowView["DeptEmployeeID"] + " AND ServiceCode  = 0",
                "QueueOrderMethod", DataViewRowState.OriginalRows);
            }


            if (dvEmployeeQueueOrderMethods.Count > 0)
                tdEmployeeQueueOrderMethods.InnerHtml = UIHelper.GetInnerHTMLForQueueOrder(dvEmployeeQueueOrderMethods,
                                                                                dvRowView["ToggleID"].ToString(), "divDoctorsAndEmployees", true);
            else
                tdEmployeeQueueOrderMethods.InnerHtml = "<table cellpadding='0' cellspacing='0'><tr><td>" + queueOrderDescription +
                                                                                                                            "</td></tr></table>";


            GridView gvEmployeeQueueOrderHours = e.Row.FindControl("gvEmployeeQueueOrderHours") as GridView;
            DataView dvEmployeeQueueOrderHours = new DataView(m_dsClinic.Tables["HoursForEmployeeQueueOrder"],
                    "DeptEmployeeID = " + dvRowView["DeptEmployeeID"],
                "receptionDay", DataViewRowState.OriginalRows);
            gvEmployeeQueueOrderHours.DataSource = dvEmployeeQueueOrderHours;
            gvEmployeeQueueOrderHours.DataBind();

            Label lblEmployeeQueueOrderPhones = e.Row.FindControl("lblEmployeeQueueOrderPhones") as Label;
            lblEmployeeQueueOrderPhones.Text = dvRowView["QueueOrderPhone"].ToString();


            //DataView dvEmployeePhones = new DataView(m_dsClinic.Tables["DeptEmployeePhones"],
            //"DeptEmployeeID = " + dvRowView["DeptEmployeeID"], //+ " AND EmployeeServiceQueueOrderGroup LIKE '" + dvRowView["EmployeeServiceQueueOrderGroup"] + "'",
            //"phoneType, phoneOrder", DataViewRowState.OriginalRows);

            GridView gvEmployeePhones = e.Row.FindControl("gvEmployeePhones") as GridView;
            GridView gvEmployeeFaxes = e.Row.FindControl("gvEmployeeFaxes") as GridView;
            string[] phonesArr = dvRowView["phones"].ToString().Split(',');

            gvEmployeePhones.DataSource = phonesArr;
            gvEmployeePhones.DataBind();

            string[] faxesArr = dvRowView["faxes"].ToString().Split(',');

            gvEmployeeFaxes.DataSource = faxesArr;
            gvEmployeeFaxes.DataBind();


            DataView dvEmployeeRemark = new DataView(m_dsClinic.Tables["EmployeeRemarks"],
                "DeptEmployeeID = " + dvRowView["DeptEmployeeID"] + " AND RemarkCategoryID in (" + RemarkCategoriesForAbsence + ")",
                string.Empty, DataViewRowState.OriginalRows);

            if (dvEmployeeRemark.Count > 0)
            {
                Label lblEmployeeRemarks = e.Row.FindControl("lblEmployeeRemarks") as Label;
                string remarks = string.Empty;

                foreach (DataRowView rowView in dvEmployeeRemark)
                {
                    remarks += "&diams;&nbsp;" + rowView.Row["remark"].ToString() + "<br/>";
                }

                lblEmployeeRemarks.Text = remarks;
            }
            else
            {
                HtmlTableRow trEmployeeRemarks = e.Row.FindControl("trEmployeeRemarks") as HtmlTableRow;
                trEmployeeRemarks.Visible = false;
            }

            if (Convert.ToInt32(dvRowView["hasAnotherWorkPlace"]) == 0 ||
                        (dvRowView["IsMedicalTeam"] != DBNull.Value && Convert.ToInt32(dvRowView["IsMedicalTeam"]) == 1))
            {
                ((PlaceHolder)e.Row.FindControl("pnlHalfClock")).Controls[0].Visible = false;
                Label lbl = new Label();
                lbl.Text = "אין";
                lbl.EnableTheming = false;
                lbl.CssClass = "RegularLabel";
                ((PlaceHolder)e.Row.FindControl("pnlHalfClock")).Controls.Add(lbl);
            }

            Image imgAgreementType = e.Row.FindControl("imgAgreementType") as Image;
            if (dvRowView["AgreementType"] != DBNull.Value)
            {
                eDIC_AgreementTypes agreementType = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes),
                                                                                            dvRowView["AgreementType"].ToString());
                UIHelper.SetImageForAgreementType(agreementType, imgAgreementType);
            }

            bool doctorHasRemarks = ((int)dvRowView["HasRemarks"] > 0);
            bool doctorHasReceptionHours = (Convert.ToInt32(dvRowView["ReceptionDaysCount"]) > 0 ? true : false);
            Image imgClock = e.Row.FindControl("imgClock") as Image;

            if (Convert.ToInt32(dvRowView["IsMedicalTeam"]) == 0)
                UIHelper.setClockRemarkImage(imgClock, doctorHasReceptionHours, doctorHasRemarks, "Green", "OpenDoctorReceptionWindow(" + dvRowView["DeptEmployeeID"].ToString() + ",'" + empServices + "', null)", "", "", "");
            //UIHelper.setClockRemarkImage(imgClock, doctorHasReceptionHours, doctorHasRemarks, "Green", "OpenDoctorReceptionWindow(" + dvRowView["DeptEmployeeID"].ToString() + ", '', null)", "", "", "");
            else
                UIHelper.setClockRemarkImage(imgClock, doctorHasReceptionHours, doctorHasRemarks, "Green", "OpenDoctorReceptionWindow(" + dvRowView["DeptEmployeeID"].ToString() + ",'" + empServices + "', null)", "", "", "");

            // Bind "gvDoctorsOtherWorkPlaces"
            GridView gvDoctorsOtherWorkPlaces = e.Row.FindControl("gvDoctorsOtherWorkPlaces") as GridView;

            DataView dvEmployeeOtherPlaces = new DataView(m_dsClinic.Tables["EmployeeOtherPlaces"],
                "EmployeeID = " + currEmployeeID + " AND deptCode <> " + m_DeptCode, null, DataViewRowState.CurrentRows);

            if (!string.IsNullOrEmpty(empServices))
            {
                hasServiceRelevantForReceivingGuests = Utils.HasServiceRelevantForReceivingGuests(empServices);

                if (hasServiceRelevantForReceivingGuests)
                {
                    if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 1)
                    {
                        imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuests.png";
                        imgReceiveGuests.ToolTip = "הרופא מקבל אורחים";
                    }
                    else if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 0)
                    {
                        imgReceiveGuests.ImageUrl = "~/Images/Applic/NOTreceiveGuests.png";
                        imgReceiveGuests.ToolTip = "הרופא אינו מקבל אורחים";
                    }
                    else if (Convert.ToInt32(dvRowView["ReceiveGuests"]) == 2)
                    {
                        imgReceiveGuests.ImageUrl = "~/Images/Applic/ReceiveGuestsPartTime.png";
                        imgReceiveGuests.ToolTip = "הרופא מקבל אורחים לפעמים";
                    }
                }
                else
                {
                    imgReceiveGuests.Visible = false;
                }
            }
            else
            {
                imgReceiveGuests.Visible = false;
            }

            if (dvEmployeeOtherPlaces.Count > 0)
            {
                gvDoctorsOtherWorkPlaces.DataSource = dvEmployeeOtherPlaces;
                gvDoctorsOtherWorkPlaces.DataBind();
            }

        }
    }

    private string AgreementTypeCondition(eDIC_AgreementTypes agreementType)
    {
        string agreementCondition;

        switch (agreementType)
        {
            case eDIC_AgreementTypes.Community:
                agreementCondition = " AND IsInCommunity = 1 ";
                break;

            case eDIC_AgreementTypes.Independent_in_community:
                agreementCondition = " AND IsInCommunity = 1 ";
                break;

            case eDIC_AgreementTypes.Mushlam:
                agreementCondition = " AND IsInMushlam = 1 ";
                break;

            case eDIC_AgreementTypes.Mushlam_payback:
                agreementCondition = " AND IsInMushlam = 1 ";
                break;
            case eDIC_AgreementTypes.Hospitals:
                agreementCondition = " AND IsInHospitals = 1 ";
                break;
            case eDIC_AgreementTypes.Unknown:
            default:
                agreementCondition = "";
                break;
        }

        return agreementCondition;
    }


    //protected void btnEditDoctorInClinic_Click(object sender, EventArgs e)
    //{
    //    Button btnEditDoctorInClinic = sender as Button;
    //    int deptEmployeeID = Convert.ToInt32(btnEditDoctorInClinic.Attributes["DeptEmployeeID"]);


    //    if (txtScrollTop_divDoctorsAndEmployees.Text != string.Empty)
    //        sessionParams.ScrollPosition_DoctorsAndEmployees_ZoomClinic = Convert.ToInt32(txtScrollTop_divDoctorsAndEmployees.Text);
    //    SessionParamsHandler.SetSessionParams(sessionParams);
    //    sessionParams.CurrentTab_ZoomClinic = "divDoctorsEmployeesBut,trDoctors,tdDoctorsEmployeesTab";
    //    ClientScript.RegisterStartupScript(typeof(string), "setParentLocation", "setParentLocation('Admin/UpdateDeptEmployee.aspx?DeptEmployeeID=" + deptEmployeeID + "');", true);


    //}



    protected void gvDoctorsOtherWorkPlaces_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            long employeeID = (long)dvRowView["employeeID"];
            int deptCode = (int)dvRowView["deptCode"];

            GridView gvDoctorsOtherWorkPlacesProfessions = e.Row.FindControl("gvDoctorsOtherWorkPlacesProfessions") as GridView;
            DataTable tblEmployeeProfessionsAtOtherPlaces = m_dsClinic.Tables["EmployeeProfessionsAtOtherPlaces"];


            var otherPlacesProfessions = from otherPlaces in tblEmployeeProfessionsAtOtherPlaces.AsEnumerable()
                                         where otherPlaces.Field<long>("employeeID") == employeeID
                                         && otherPlaces.Field<int>("deptCode") == deptCode
                                         select new
                                         {
                                             professionDescription = otherPlaces.Field<string>("professionDescription")
                                         };



            gvDoctorsOtherWorkPlacesProfessions.DataSource = otherPlacesProfessions;
            gvDoctorsOtherWorkPlacesProfessions.DataBind();

            GridView gvDoctorsOtherWorkPlacesServices = e.Row.FindControl("gvDoctorsOtherWorkPlacesServices") as GridView;
            DataTable tblEmployeeServicesAtOtherPlaces = m_dsClinic.Tables["EmployeeServicesAtOtherPlaces"];


            var otherPlacesServices = from services in tblEmployeeServicesAtOtherPlaces.AsEnumerable()
                                      where services.Field<long>("employeeID") == employeeID
                                      && services.Field<int>("deptCode") == deptCode
                                      select new
                                      {
                                          serviceDescription = services.Field<string>("serviceDescription")
                                      };

            gvDoctorsOtherWorkPlacesServices.DataSource = otherPlacesServices;
            gvDoctorsOtherWorkPlacesServices.DataBind();



            Image imgAgreementType = e.Row.FindControl("imgAgreementType") as Image;
            if (dvRowView["AgreementType"] != DBNull.Value)
            {
                eDIC_AgreementTypes agreementType = (eDIC_AgreementTypes)Enum.Parse(typeof(eDIC_AgreementTypes),
                                                                                            dvRowView["AgreementType"].ToString());
                UIHelper.SetImageForAgreementType(agreementType, imgAgreementType);
            }


            #region Remarks for Reception in other places

            //EmployeeOtherPlaces
            Image imgClock = e.Row.FindControl("imgClock") as Image;
            string empServices = "-1";
            bool doctorHasRemarksInDept = Convert.ToBoolean(dvRowView["HasRemarks"]);
            bool doctorHasReceptionHours = (dvRowView["ReceptionDaysCount"] != DBNull.Value && Convert.ToInt32(dvRowView["ReceptionDaysCount"]) > 0 ? true : false);
            UIHelper.setClockRemarkImage(imgClock, doctorHasReceptionHours, doctorHasRemarksInDept, "Green", "OpenDoctorReceptionWindow(" + dvRowView["DeptEmployeeID"].ToString() + ",'" + empServices + "', null)", "", "", "");


            #endregion

        }
    }


    protected void btnAddDoctors_Click(object sender, EventArgs e)
    {

        sessionParams.CurrentTab_ZoomClinic = "divDoctorsEmployeesBut,trDoctors,tdDoctorsEmployeesTab";
        ClientScript.RegisterStartupScript(typeof(string), "setParentLocation", "setParentLocation('Admin/AddEmployeeToClinic.aspx');", true);

    }

    private string CurrentSort
    {
        get
        {
            if (ViewState["currentSort"] != null)
                return ViewState["currentSort"].ToString();
            return "ActiveForSort";
        }
        set
        {
            ViewState["currentSort"] = value;
        }
    }

    public void BindDoctorsAndReceptions()
    {
        ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
        DataTable tblEmployeeSector = cacheHandler.getCachedDataTable(eCachedTables.EmployeeSector.ToString());
        DataView dvEmployeeSector = new DataView(tblEmployeeSector, "", "OrderToShow", DataViewRowState.OriginalRows);

        ViewState["employeeSectorTable"] = dvEmployeeSector.ToTable();
        gvEmployeeSectorHeaders.DataSource = dvEmployeeSector;
        gvEmployeeSectorHeaders.DataBind();


    }

    protected void btnSort_click(object sender, EventArgs e)
    {
        SortableColumnHeader columnToSortBy = sender as SortableColumnHeader;

        foreach (Control ctrl in tdSortingButtons.Controls)
        {
            if (ctrl is SortableColumnHeader && ctrl != columnToSortBy)
            {
                ((SortableColumnHeader)ctrl).ResetSort();
            }
        }

        CurrentSort = columnToSortBy.ColumnIdentifier + " " + columnToSortBy.GetStringValueOfCurrentSort();
        DataTable dt = ViewState["employeeSectorTable"] as DataTable;
        DataView dv = dt.DefaultView;

        gvEmployeeSectorHeaders.DataSource = dv;
        gvEmployeeSectorHeaders.DataBind();
    }

    protected void gvEmployeeSectorHeaders_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;
            GridView gvDoctors = e.Row.FindControl("gvDoctors") as GridView;


            DataView dvDeptDoctors = new DataView(m_dsClinic.Tables["deptDoctors"],
                       "EmployeeSectorCode = " + dvRowView["EmployeeSectorCode"].ToString(), CurrentSort, DataViewRowState.CurrentRows);


            if (dvDeptDoctors.Count < 1)
                e.Row.Style.Add("display", "none");

            dvDeptDoctors.Sort = CurrentSort;
            gvDoctors.DataSource = dvDeptDoctors;
            gvDoctors.DataBind();

            if (currentGridSelectedIndex != -1)
            {
                gvDoctors.SelectedIndex = currentGridSelectedIndex;
                currentGridSelectedIndex = -1;
            }
        }
    }

    protected void btnDeleteEvent_Click(object sender, EventArgs e)
    {
        ImageButton btnDeleteEvent = sender as ImageButton;
        int DeptEventID = Convert.ToInt32(btnDeleteEvent.Attributes["DeptEventID"]);

        SeferNet.BusinessLayer.ObjectDataSource.DeptEventsBO bo = new SeferNet.BusinessLayer.ObjectDataSource.DeptEventsBO();
        bo.DeleteDeptEvent(DeptEventID);

        BindDoctorsAndReceptions();
    }





    protected void btnUpdateEvents_Click(object sender, EventArgs e)
    {
        sessionParams.CurrentTab_ZoomClinic = "divDoctorsEmployeesBut,trDoctors,tdDoctorsEmployeesTab";
        ClientScript.RegisterStartupScript(typeof(string), "setParentLocation", "setParentLocation('Admin/UpdateClinicEvents.aspx');", true);
    }

    public void BindDeptEvents()
    {
        if (m_dsClinic.Tables["deptEvents"].Rows.Count > 0)
        {
            gvEvents.DataSource = m_dsClinic.Tables["deptEvents"];
            gvEvents.DataBind();
        }

        DataView dvDeptEvents = new DataView(m_dsClinic.Tables["deptEvents"], "Active = 1", "", DataViewRowState.CurrentRows);
    }

    protected void gvEvents_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drowView = e.Row.DataItem as DataRowView;
            Image imgClock = e.Row.FindControl("imgClock") as Image;
            Image imgNoInternet = e.Row.FindControl("imgNoInternet") as Image;
            int eventID = Convert.ToInt32(drowView["DeptEventID"]);

            // make administration buttons visible if User is "IsDeptPermitted"
            PlaceHolder pnlEditButton = e.Row.FindControl("pnlEditButton") as PlaceHolder;
            if (currentUser != null)
            {
                if (m_isDeptPermittedForUser || currentUser.IsAdministrator)
                    pnlEditButton.Visible = true;
                else
                    pnlEditButton.Visible = false;
            }
            else
            {
                pnlEditButton.Visible = false;
            }

            bool eventHasReceptionHours = (drowView["MeetingsNumber"] != DBNull.Value && Convert.ToInt32(drowView["MeetingsNumber"]) > 0 ? true : false);
            bool eventHasRemark = (!string.IsNullOrEmpty(drowView["Remark"].ToString()) ? true : false);
            UIHelper.setClockRemarkImage(imgClock, eventHasReceptionHours, eventHasRemark, "Green", "OpenEventsWindow(" + eventID.ToString() + ");", "", "", "");

            if (imgNoInternet != null)
            {
                if (Convert.ToBoolean(drowView["displayInInternet"]) == true)
                {
                    imgNoInternet.Visible = false;
                }
                else
                {
                    imgNoInternet.Visible = true;

                }
            }

            GridView gvEventPhones = e.Row.FindControl("gvEventPhones") as GridView;

            if (drowView["ShowPhonesFromDept"] != DBNull.Value && Convert.ToBoolean(drowView["ShowPhonesFromDept"]))
            {
                BindDeptPhones(gvEventPhones);
            }
            else
            {
                Label lblPhonesNotDefined = e.Row.FindControl("lblPhonesNotDefined") as Label;

                var deptEventPhones = from phones in m_dsClinic.Tables["deptEventPhones"].AsEnumerable()
                                      where phones.Field<int>("deptEventID") == eventID
                                      select new
                                      {
                                          shortPhoneTypeName = phones.Field<string>("shortPhoneTypeName"),
                                          phone = phones.Field<string>("phone")
                                      };

                gvEventPhones.DataSource = deptEventPhones;
                gvEventPhones.DataBind();
            }


            if (sessionParams.ServiceCode == eventID)
            {
                e.Row.BackColor = System.Drawing.Color.FromArgb(180, 207, 249);
                sessionParams.ServiceCode = null;
            }

            Enums.Status eventStatus = (Enums.Status)Enum.Parse(typeof(Enums.Status), drowView["Active"].ToString());

            if (eventStatus == Enums.Status.NotActive)
            {
                if (currentUser != null)
                {
                    //e.Row.CssClass = eventStatus.ToString();
                    e.Row.CssClass = "notActive";
                }
                else
                {
                    e.Row.Visible = false;
                }
            }
        }
    }

    private void BindDeptPhones(GridView gvPhones)
    {
        gvPhones.DataSource = m_dsClinic.Tables["DeptPhones"];
        gvPhones.DataBind();
    }
}