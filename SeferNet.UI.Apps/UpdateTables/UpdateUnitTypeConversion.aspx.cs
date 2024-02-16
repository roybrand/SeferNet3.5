using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.FacadeLayer;
using System.Data;

public partial class UpdateUnitTypeConversion : System.Web.UI.Page
{
    private string _item = String.Empty;
    DataSet dsUnitTypesConvert;
    int gvUnitTypeConversion_SelectedIndex = -1;
    static string sortDirectionASC = "ASC";
    static string sortDirectionDESC = "DESC";
    string sortByDefault = "SugSimul";
    string sortDirectionDefaul = sortDirectionASC;
    string unitTypesSortDirection = "UnitTypesSortDirection";
    string unitTypesSortBY = "UnitTypesSortBY";
    string dtUnitTypesConvert = "dtUnitTypesConvert";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ViewState[unitTypesSortDirection] = sortDirectionDefaul;
            ViewState[unitTypesSortBY] = sortByDefault;

            gvUnitTypeConversion.DataSource = GetDVUnitTypesConvert(ViewState[unitTypesSortBY].ToString(), ViewState[unitTypesSortDirection].ToString());
            gvUnitTypeConversion.DataBind();
        }

        if (!ClientScript.IsStartupScriptRegistered("ScrollDivToSelected"))
        {
            ClientScript.RegisterStartupScript(typeof(string), "ScrollDivToSelected", "ScrollDivToSelected();", true);
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (gvUnitTypeConversion_SelectedIndex != -1)
            gvUnitTypeConversion.SelectedIndex = gvUnitTypeConversion_SelectedIndex;

    }

    protected DataView GetDVUnitTypesConvert(string sorting, string sortDirection)
    { 
        if (ViewState[dtUnitTypesConvert] == null)
        {
            Facade applicFacade = Facade.getFacadeObject();
            dsUnitTypesConvert = applicFacade.GetUnitTypeConvertSimul(-1);
            if (dsUnitTypesConvert != null && dsUnitTypesConvert.Tables[0].Rows.Count > 0)
            {
                ViewState[dtUnitTypesConvert] = dsUnitTypesConvert.Tables[0];
            }
        }

        sorting = sorting + " " + sortDirection;

        DataView dvUnitTypesConvert = new DataView((DataTable)ViewState[dtUnitTypesConvert], "", sorting, DataViewRowState.OriginalRows);
        return dvUnitTypesConvert;
    }

    protected void BindGridView()
    {
        DataView dvUnitTypesConvert;
        if (ViewState[dtUnitTypesConvert] == null)
        {
            Facade applicFacade = Facade.getFacadeObject();
            dsUnitTypesConvert = applicFacade.GetUnitTypeConvertSimul(-1);
            if (dsUnitTypesConvert != null && dsUnitTypesConvert.Tables[0].Rows.Count > 0)
            {
                dvUnitTypesConvert = new DataView(dsUnitTypesConvert.Tables[0], "", "SugSimul", DataViewRowState.OriginalRows);
                gvUnitTypeConversion.DataSource = dvUnitTypesConvert;
                gvUnitTypeConversion.DataBind();
            }
        }
    }

    protected void gvUnitTypeConversion_Sorting(object sender, GridViewSortEventArgs e)
    {
        int convertId = -1;

        if (gvUnitTypeConversion.SelectedIndex != -1)
        {
            Label lblConvertId = gvUnitTypeConversion.Rows[gvUnitTypeConversion.SelectedIndex].FindControl("lblConvertId") as Label;
            if (lblConvertId != null)
                convertId = Convert.ToInt32(lblConvertId.Text);
        }

        if (ViewState[unitTypesSortBY].ToString() == e.SortExpression)
        {
            if (ViewState[unitTypesSortDirection].ToString() == sortDirectionASC)
            {
                e.SortDirection = SortDirection.Descending;
                ViewState[unitTypesSortDirection] = sortDirectionDESC;
            }
            else
            {
                e.SortDirection = SortDirection.Ascending;
                ViewState[unitTypesSortDirection] = sortDirectionASC;
            }
        }
        else
        {
            ViewState[unitTypesSortBY] = e.SortExpression;
            e.SortDirection = SortDirection.Ascending;
            ViewState[unitTypesSortDirection] = sortDirectionASC;
        }

        ViewState[dtUnitTypesConvert] = null;

        gvUnitTypeConversion.DataSource = GetDVUnitTypesConvert(e.SortExpression, ViewState[unitTypesSortDirection].ToString());
        gvUnitTypeConversion.DataBind();

        if (convertId != -1)
        {
            Label lblConvertId;
            for(int i=0; i < gvUnitTypeConversion.Rows.Count; i++)
            {
                lblConvertId = gvUnitTypeConversion.Rows[i].FindControl("lblConvertId") as Label;
                if (Convert.ToInt32(lblConvertId.Text) == convertId)
                {
                    gvUnitTypeConversion.SelectedIndex = i;
                }
            }
        }
    }

    protected void gvUnitTypeConversion_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dvRowView = e.Row.DataItem as DataRowView;

            string key_TypUnit = dvRowView["key_TypUnit"].ToString();
            string PopSectorID = dvRowView["PopSectorID"].ToString();

            DropDownList ddlUnitType = e.Row.FindControl("ddlUnitType") as DropDownList;
            if (ddlUnitType != null)
            {
                UIHelper.BindDropDownToCachedTable(ddlUnitType, "View_UnitType", "UnitTypeName");
                ddlUnitType.SelectedValue = key_TypUnit;
            }
            DropDownList ddlPopulationSector = e.Row.FindControl("ddlPopulationSector") as DropDownList;
            if (ddlPopulationSector != null)
            {
                ListItem listItem = new ListItem("בחר", "-1");
                ddlPopulationSector.Items.Add(listItem);

                UIHelper.BindDropDownToCachedTable(ddlPopulationSector, "PopulationSectors", "PopulationSectorDescription");

                ddlPopulationSector.SelectedValue = PopSectorID;
            }
        }
    }

    protected void imgUpdate_Click(object sender, ImageClickEventArgs e)
    {
        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        if (row != null)
        {
            gvUnitTypeConversion.EditIndex = row.RowIndex;

            //ViewState[unitTypesSortDirection] = sortDirectionDefaul;
            //ViewState[unitTypesSortBY] = sortByDefault;

            gvUnitTypeConversion.DataSource = GetDVUnitTypesConvert(ViewState[unitTypesSortBY].ToString(), ViewState[unitTypesSortDirection].ToString());
            gvUnitTypeConversion.DataBind();
        }
    }

    protected void imgSave_Click(object sender, ImageClickEventArgs e)
    {
        bool result;

        GridViewRow row = ((System.Web.UI.WebControls.ImageButton)(sender)).Parent.Parent as GridViewRow;
        //DataRowView dvRowView = row.DataItem as DataRowView;

        Label lblConvertId = row.FindControl("lblConvertId") as Label;
        int ConvertId = Convert.ToInt32(lblConvertId.Text);

        CheckBox cbActive = row.FindControl("cbActive") as CheckBox;
        int Active;
        if (cbActive.Checked)
            Active = 1;
        else
            Active = 0;

        DropDownList ddlUnitType = row.FindControl("ddlUnitType") as DropDownList;
        int key_TypUnit = Convert.ToInt32(ddlUnitType.SelectedValue);

        DropDownList ddlPopulationSector = row.FindControl("ddlPopulationSector") as DropDownList;
        int PopSectorID = Convert.ToInt32(ddlPopulationSector.SelectedValue);

        Facade applicFacade = Facade.getFacadeObject();
        result = applicFacade.UpdateUnitTypeConvertSimul(ConvertId, Active, key_TypUnit, PopSectorID);
        if (result)
        {
            gvUnitTypeConversion.EditIndex = -1;

            //ViewState[unitTypesSortDirection] = sortDirectionDefaul;
            //ViewState[unitTypesSortBY] = sortByDefault;

            ViewState[dtUnitTypesConvert] = null;

            gvUnitTypeConversion.DataSource = GetDVUnitTypesConvert(ViewState[unitTypesSortBY].ToString(), ViewState[unitTypesSortDirection].ToString());
            gvUnitTypeConversion.DataBind();
        }
    }

    protected void imgCancel_Click(object sender, ImageClickEventArgs e)
    {
        gvUnitTypeConversion.EditIndex = -1;

        //ViewState[unitTypesSortDirection] = sortDirectionDefaul;
        //ViewState[unitTypesSortBY] = sortByDefault;

        gvUnitTypeConversion.DataSource = GetDVUnitTypesConvert(ViewState[unitTypesSortBY].ToString(), ViewState[unitTypesSortDirection].ToString());
        gvUnitTypeConversion.DataBind();
    }

}
