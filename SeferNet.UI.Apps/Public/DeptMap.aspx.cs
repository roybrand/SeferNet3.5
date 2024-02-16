using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Public_DeptMap : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DeptMapUC1.IsSetzIndexOfPopups = false;
        DeptMapUC1.Load += new EventHandler(DeptMapUC1_Load);
      
    }

    void DeptMapUC1_Load(object sender, EventArgs e)
    {
        string focusedDeptCode = Request[GlobalConst.QueryVariable.Pages.DeptsMapProperties.FocusedDeptCode];
        if (string.IsNullOrEmpty(focusedDeptCode) == false)
        {
            //   DeptMapUC1.RefreshMapDepts(

            DeptMapPopulateInfo deptMapInfo = SearchPageHelper.GetDeptMapPopulateInfo(Convert.ToInt32(focusedDeptCode), null, -1, -1);
            DeptMapUC1.RefreshMapDepts(deptMapInfo.AllDeptCodes, deptMapInfo.CoordX, deptMapInfo.CoordY, deptMapInfo.FocusedDeptCode, true,false);

        }
    }
}