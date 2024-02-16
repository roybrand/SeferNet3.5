using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MapsManager;
using System.Configuration;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using System.Data;
using System.Web.UI.WebControls;

public delegate void RowMapImageClick_NonClosestPointSearch_OccuredDelegate(object sender,int rowIndex);
/// <summary>
/// Summary description for MapApplicationEnvironmentController
/// </summary>
public class MapHelper
{
    const string MapClientServerURLKey = "MapClientServerURL";
    const string MapClientUsernameKey = "MapClientUsername";
    const string MapClientPasswordKey = "MapClientPassword";

    static string MapClientServerURL = null;
    static string MapClientUsername = null;
    static string MapClientPassword = null;

    static MapHelper()
    {
        //initalization from config

        MapClientServerURL =  ConfigurationManager.AppSettings[MapClientServerURLKey];
        MapClientUsername = ConfigurationManager.AppSettings[MapClientUsernameKey];
        MapClientPassword = ConfigurationManager.AppSettings[MapClientPasswordKey];

        //default values if required
        if (string.IsNullOrEmpty(MapClientServerURL) == true)
        {
            MapClientServerURL = "http://mkweb022/mapguide/clalit/index.aspx";
        }
        if (string.IsNullOrEmpty(MapClientUsername) == true)
        {
            MapClientUsername = "Administrator";
        }
        if (string.IsNullOrEmpty(MapClientPassword) == true)
        {
            MapClientPassword = "admin";
        }
    }

    static ApplicationEnvironmentController _MapApplicationEnvironmentController;
    public static ApplicationEnvironmentController GetMapApplicationEnvironmentController()
    {
        if (_MapApplicationEnvironmentController == null && ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"] != null)
        {
            _MapApplicationEnvironmentController = new ApplicationEnvironmentController(ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString);
            //singleton
            _MapApplicationEnvironmentController.ClientServerMapURL = MapClientServerURL;
            _MapApplicationEnvironmentController.CityTableInfo = new CityTableInfo("Cities", eCitiesEnum.cityCode.ToString(), eCitiesEnum.cityName.ToString(), eCitiesEnum.X.ToString(), eCitiesEnum.Y.ToString());
            _MapApplicationEnvironmentController.StreetTableInfo = new StreetTableInfo("Streets", eStreetsEnum.CityCode.ToString(), eStreetsEnum.Name.ToString(),eStreetsEnum.StreetCode.ToString(), eStreetsEnum.X.ToString(), eStreetsEnum.Y.ToString());
            _MapApplicationEnvironmentController.NeighbourhoodTableInfo = new NeighbourhoodTableInfo("Neighbourhoods", eNeighbourhoodsEnum.CityCode.ToString(), eNeighbourhoodsEnum.NybName.ToString(),eNeighbourhoodsEnum.NeighbourhoodCode.ToString(), eNeighbourhoodsEnum.X.ToString(), eNeighbourhoodsEnum.Y.ToString());
            _MapApplicationEnvironmentController.InstituteTableInfo = new InstituteTableInfo("Atarim", eAtarimEnum.CityCode.ToString(), eAtarimEnum.InstituteName.ToString(),eAtarimEnum.InstituteCode.ToString(), eAtarimEnum.X.ToString(), eAtarimEnum.Y.ToString());
            //
        }

        //_MapApplicationEnvironmentController.CallBackServerURL = HttpContext.Current.Server.MapPath("/MapService/MapNotificationService.asmx");

        return _MapApplicationEnvironmentController;
    }

    //TEMP!!!
    static string DeptMapPage = "DeptsMapEx.aspx";
    public static void PrepareGridRowMapData(DataRow currentRow, Image imgMap, int maxNumberOfRecords, DataTable dtWithDepts, double? coordinateX, double? coordinateY)
    {
        string mapURL = string.Empty;
        if (ConfigurationManager.AppSettings["mapServerIP"] != null)
        {
            string paramsMap = string.Empty;
            if (coordinateX == null)
            {
                paramsMap = string.Format("{0}={1}&{2}={1}",
                    GlobalConst.QueryVariable.Pages.DeptsMapProperties.AllDepts,
                    currentRow[eDeptEnum.deptCode.ToString()].ToString(),
                    GlobalConst.QueryVariable.Pages.DeptsMapProperties.FocusedDeptCode
                  );

                mapURL = string.Format("{1}?{0}",
                   paramsMap, DeptMapPage);
                //url example
                //"DeptsMap.aspx?deptCode=23370&AllDepts=23370"
            }
            else
            {
                for (int i = 0; i < dtWithDepts.Rows.Count; i++)
                {
                    if (currentRow[eDeptEnum.deptCode.ToString()] != dtWithDepts.Rows[i][eDeptEnum.deptCode.ToString()])
                    {
                        paramsMap += i == 0 ? string.Empty : ",";
                        paramsMap += dtWithDepts.Rows[i][eDeptEnum.deptCode.ToString()].ToString();
                    }
                }
                paramsMap = string.Format("{0}={1}&{2}={3}&{4}={5}", GlobalConst.QueryVariable.Pages.DeptsMapProperties.AllDepts, paramsMap,
                    GlobalConst.QueryVariable.Pages.DeptsMapProperties.CoordX, coordinateX, GlobalConst.QueryVariable.Pages.DeptsMapProperties.CoordY, coordinateY);

                mapURL = string.Format("{3}?{0}={1}&{2}", GlobalConst.QueryVariable.Pages.DeptsMapProperties.FocusedDeptCode, currentRow[eDeptEnum.deptCode.ToString()].ToString(), paramsMap, DeptMapPage);
                //url example
                //"DeptsMap.aspx?deptCode=23370&AllDepts=23370,980204,23250,23251,23280&CoordX=128.508&CoordY=162.557" 
            }

            imgMap.Attributes.Add("onClick", "OpenMapWindow('" + mapURL + "')");
            imgMap.Attributes.Add("alt", "הקש להצגת חלון מפה");
            imgMap.ImageUrl = "~/Images/Applic/searchResultGrid_btnMap.gif";
        }
    }

}

public class DeptMapPopulateInfo
{
    public double? CoordX
    {
        get; set;        
    }

    public double? CoordY
    {
        get;
        set;
    }

    public int? FocusedDeptCode
    {
        get;
        set;
    }


    public Dictionary<int,List<int>> AllDeptCodes
    {
        get;
        set;
    }


    public DeptMapPopulateInfo()
    {
        AllDeptCodes = new Dictionary<int, List<int>>();
    }
}
