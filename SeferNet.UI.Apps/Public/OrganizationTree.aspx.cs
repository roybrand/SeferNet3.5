using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.BusinessLayer.WorkFlow;
using Clalit.SeferNet.Entities;

public partial class Public_OrganizationTree : System.Web.UI.Page
{


    // contains all the expanded units codes, and their parent units codes - if exists
    protected Dictionary<int,int?> ExpandedUnitCodes
    {
        get
        {
            if (ViewState["expandedUnitCodes"] == null)
            {
                ViewState["expandedUnitCodes"] = new Dictionary<int, int?>();
            }

            return (Dictionary<int, int?>)ViewState["expandedUnitCodes"];
        }
        set
        {
            ViewState["expandedUnitCodes"] = value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindDistricts();
        }
    }

    private void BindDistricts()
    {
        if (ViewState["DistrictsSource"] == null)
        {
            Facade facade = Facade.getFacadeObject();
            List<View_AllDeptAddressAndPhone> list = facade.GetAllDistrictsWithDetails();

            ViewState["DistrictsSource"] = list;
        }

        dtlMain.DataSource = ViewState["DistrictsSource"];
        dtlMain.DataBind();

    }


    protected void button_ItemCommand(object source, DataListCommandEventArgs e)
    {
        string commandArgument = e.CommandArgument.ToString();
        int currDeptCode;
        int? parentUnitCode = null;

        if (commandArgument.IndexOf("#") > -1)
        {
            string[] arr = commandArgument.Split('#');
            currDeptCode = Convert.ToInt32(arr[0]);
            parentUnitCode = Convert.ToInt32(arr[1]);
        }
        else
        {
            currDeptCode = Convert.ToInt32(e.CommandArgument);
        }

        switch (e.CommandName.ToLower())
        {
            case "expand":        
                ExpandedUnitCodes.Add(currDeptCode, parentUnitCode);
                break;

            case "collapse":
                ExpandedUnitCodes.Remove(currDeptCode);

                if (ExpandedUnitCodes.ContainsValue((int)currDeptCode))
                {
                    List<int> codesToRemove = new List<int>();
                    foreach (int key in ExpandedUnitCodes.Keys)
                    {
                        if (ExpandedUnitCodes[key] == currDeptCode)
                        {
                            codesToRemove.Add(key);
                        }
                    }

                    foreach (int code in codesToRemove)
                    {
                        ExpandedUnitCodes.Remove(code);
                    }
                }
                break;
        }

        BindDistricts();
    }


    protected void dtlMain_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            View_AllDeptAddressAndPhone dept = e.Item.DataItem as View_AllDeptAddressAndPhone;
            int currDeptCode = dept.deptCode;

            if (ExpandedUnitCodes.ContainsKey(currDeptCode))
            {
                e.Item.FindControl("btnMinus").Visible = true;
                e.Item.FindControl("btnPlus").Visible = false;

                List<View_AllDeptAddressAndPhone> list = Facade.getFacadeObject().GetAdminWithDetails_DistrictDepended(currDeptCode);
                DisplayAndBindChildDepts(e.Item, "pnlChildUnits", "dtlAdministrations", list);
            }

            Label lblAddress = e.Item.FindControl("lblAddress") as Label;
            if (string.IsNullOrEmpty(lblAddress.Text))
                lblAddress.Text = "&nbsp;";
        }
    }


    protected void dtlAdministrations_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        View_AllDeptAddressAndPhone currDept = e.Item.DataItem as View_AllDeptAddressAndPhone;
        int currDeptCode = currDept.deptCode;

        if (ExpandedUnitCodes.ContainsKey(currDeptCode))
        {
            e.Item.FindControl("btnMinus").Visible = true;
            e.Item.FindControl("btnPlus").Visible = false;

            List<View_AllDeptAddressAndPhone> list = Facade.getFacadeObject().GetClinicsByAdministration(currDeptCode);
            DisplayAndBindChildDepts(e.Item, "pnlDepts", "dtlDepts", list);
        }

        Label lblAddress = e.Item.FindControl("lblAddress") as Label;
        if (string.IsNullOrEmpty(lblAddress.Text))
            lblAddress.Text = "&nbsp;";
    }

    
    private void DisplayAndBindChildDepts(DataListItem item, string childPanelID, string innerDataListID, List<View_AllDeptAddressAndPhone> listSource)
    {
        Panel pnlChildUnits = item.FindControl(childPanelID) as Panel;
        pnlChildUnits.Visible = true;

        DataList dtlInner = pnlChildUnits.FindControl(innerDataListID) as DataList;


        dtlInner.DataSource = listSource;
        dtlInner.DataBind();
    }

    protected void linkDeptCode_click(object sender, EventArgs e)
    {
        LinkButton lnkDept = sender as LinkButton;

        SessionParams sessionParams = SessionParamsHandler.GetSessionParams();

        sessionParams.DeptCode = Convert.ToInt32(lnkDept.CommandArgument);

        Response.Redirect("~/public/ZoomClinic.aspx?DeptCode=" + lnkDept.CommandArgument);
    }

    protected void dtlDepts_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            Label lblAddress = e.Item.FindControl("lblAddress") as Label;

            if (string.IsNullOrEmpty(lblAddress.Text))
                lblAddress.Text = "&nbsp;";
        }
    }
}
