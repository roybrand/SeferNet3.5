using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;
using System.Configuration;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;

/// <summary>
/// Summary description for SearchPageHelper
/// </summary>
public class SearchPageHelper
{
    public SearchPageHelper()
    { 
        //
        // TODO: Add constructor logic here
        //
    }


    public static void PrepareGridRowMapData(DataRowView currentRow, int rowIndex, Image imgMap, double? coordinateX,
                                                                                                double? coordinateY, string gridClientID, bool isClosestPointsSearch)
    {
        if (ConfigurationManager.AppSettings["mapServerIP"] != null)
        {
            double rowCoordX = 0;
            double rowCoordY = 0;
            
            if (currentRow[ex_dept_XYEnum.xcoord.ToString()] != DBNull.Value &&
                double.TryParse(currentRow[ex_dept_XYEnum.xcoord.ToString()].ToString(), out rowCoordX) == true)
            {
                double.TryParse(currentRow[ex_dept_XYEnum.ycoord.ToString()].ToString(), out rowCoordY);
            }
           
            if (rowCoordX > 0)
            {

                //forces the map to be shown, and do post back in order to send request to focues on dept
                imgMap.Attributes["onClick"] = " if (window.focusOnCoord) { window.focusOnCoord(" + rowCoordX + "," + rowCoordY + "," + rowIndex +"); } ";

                if (isClosestPointsSearch == false)
                {
                    string postbackArgs = GetMapClickPostBackArgumentsFormat(currentRow[eDeptEnum.deptCode.ToString()].ToString(), rowIndex);
                    imgMap.Attributes["onClick"] += "PopulateMapFrameIfRequired(); window.mapImageClicked();  mapImageClickedNonClosestSearch(" + postbackArgs + ");";
                }
                else
                {
                    imgMap.Attributes["onClick"] += "window.mapImageClicked(); RefreshbtnShowHideMapText();";
                }

                imgMap.Attributes["onClick"] += "setRowColor(" + rowIndex + ");";
                imgMap.Attributes.Add("alt", "הקש להצגת חלון מפה");
                imgMap.ImageUrl = "~/Images/Applic/searchResultGrid_btnMap.gif";
            }
            else
            {
                imgMap.Visible = false;
            }
        }
    }


    public static DeptMapPopulateInfo GetDeptMapPopulateInfo(int? currentDeptCode,
       DataTable dtWithDepts, double? coordinateX, double? coordinateY)
    {
        return GetDeptMapPopulateInfo(currentDeptCode, dtWithDepts, coordinateX, coordinateY, true);
    }

    public static DeptMapPopulateInfo GetDeptMapPopulateInfo(int? currentDeptCode,
        DataTable dtWithDepts, double? coordinateX, double? coordinateY,
        bool isClosestDeptsSearch)
    {
        DeptMapPopulateInfo retInfo = new DeptMapPopulateInfo();

        string mapURL = string.Empty;
        if (ConfigurationManager.AppSettings["mapServerIP"] != null)
        {
            //focusedDept
            retInfo.FocusedDeptCode = currentDeptCode;
            retInfo.CoordX = coordinateX;
            retInfo.CoordY = coordinateY;

           

            // dtWithDepts[eDeptEnum.deptCode.ToString()]
            //deptCodes
            if (dtWithDepts != null && dtWithDepts.Rows.Count > 0)
            {
                //we collect all the table rows that are in the same coordinates
                List<int> deptCodeList = 
                (from row in dtWithDepts.AsEnumerable()
                                select Convert.ToInt32( row[eDeptEnum.deptCode.ToString()])                                
                                ).Distinct().ToList();

                foreach (int  deptCode in deptCodeList)
                {
                    retInfo.AllDeptCodes.Add(deptCode, new List<int>());
                }

                for (int i = 0; i < dtWithDepts.Rows.Count; i++)
                {
                    int loopedDeptCode = Convert.ToInt32(dtWithDepts.Rows[i][eDeptEnum.deptCode.ToString()]);
                    retInfo.AllDeptCodes[loopedDeptCode].Add(i + 1);
                }
            }
            else
            {
                if (currentDeptCode != null)
                {
                    retInfo.AllDeptCodes.Add(currentDeptCode.Value, new List<int>());
                    retInfo.AllDeptCodes[currentDeptCode.Value].Add(1);
                }
            }
        }

        return retInfo;
    }

  
    /// <summary>
    /// the arguments for the map image click post back - example of arguments format '1234,2' - first is the dept code, second is the rowindex 
    /// </summary>
    /// <param name="deptCode"></param>
    /// <param name="rowIndex"></param>
    /// <returns></returns>
    static string GetMapClickPostBackArgumentsFormat(string deptCode,int rowIndex)
    {
        return string.Format("'{0};{1}'",deptCode,rowIndex);
    }
}
