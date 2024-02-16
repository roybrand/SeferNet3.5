using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Matrix.ExceptionHandling;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Exceptions.ExceptionData;
using MapsManager;
using Clalit.SeferNet.EntitiesBL;
using Clalit.SeferNet.GeneratedEnums.DBMetadata;
using System.Web.UI.HtmlControls;
using Clalit.SeferNet.Entities;

public partial class UserControls_DeptMapUC : System.Web.UI.UserControl, ICallbackEventHandler
{
    public string ControlIdsUpdatingControl { get; set; }

    public string hdnClinicJsonClientId
    {
        get
        {
            return hdnClinicJson.ClientID;
        }
    }
    public string BtnTriggerPostBack
    {
        get
        {
            return btnTriggerPostBack.ClientID;
        }
    }    

    #region ViewState Props

    public List<View_DeptDetails> View_DeptDetailsList
    {
        get
        {
            return ViewState[typeof(View_DeptDetails).Name] as List<View_DeptDetails>;
        }
        set
        {
            ViewState[typeof(View_DeptDetails).Name] = value;
        }
    }

    private double? CoordX;

    private double? CoordY;   

    private int? FocusedDeptCode;
   

    public Dictionary<int, List<int>> AllDeptCodes;
 
    public bool IsSetzIndexOfPopups
    {
        get
        {
            return chkIsSetzIndexOfPopups.Checked;
        }
        set
        {
            chkIsSetzIndexOfPopups.Checked = value;
        }
    }   

    MapCoordinatesClient.XYSearchAccuracyMode _XYSearchAccuracyState = MapCoordinatesClient.XYSearchAccuracyMode.FindClosest;
    public MapCoordinatesClient.XYSearchAccuracyMode XYSearchAccuracyState
    {
        get
        {
            return _XYSearchAccuracyState;
        }
        set
        {
            _XYSearchAccuracyState = value;
        }
    }

    #endregion
    
    static Dictionary<string, List<string>> _CallbackFunctionsDictionary = new Dictionary<string, List<string>>();

    static UserControls_DeptMapUC()
    {
       // _CallbackFunctionsDictionary.Add("OnMapClosed", new List<string> { });
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        mapClient = new MapCoordinatesClient(MapHelper.GetMapApplicationEnvironmentController());
        mapClient.XYSearchAccuracyState = _XYSearchAccuracyState;

        if (IsPostBack == false)
        {
            hdnFrameSrc.Value = mapClient.ApplicationEnvironmentController.ClientServerMapURL;
            RegisterScripts();
        }

     
        chkIsSetzIndexOfPopups.Style.Add("display", "none");

        //add button clicks that will trigger the update panel to be refreshed
        //we do it because we want the hdnClinicJson to be refreshed so later we can access it from the js 
        // and refresh the map according to it 
        if (string.IsNullOrEmpty(ControlIdsUpdatingControl) == false)
        {
          string[] controlsTriggerUpdatePanel =  ControlIdsUpdatingControl.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);

          foreach (string controlId in controlsTriggerUpdatePanel)
          {
              AsyncPostBackTrigger trigger = new AsyncPostBackTrigger();
              trigger.EventName = "Click";
              trigger.ControlID = controlId;             
              UpdatePanelClinicJson.Triggers.Add(trigger);
          }          
        }
         //<Triggers>
         //                                   <asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />
         //                               </Triggers>
         //                           </asp:UpdatePanel>


    }

    private void RegisterScripts()
    {
        string sendCommandJSContent =
       @"
        function sendCommand(Command, data, rowIndex) {    
            
            " + frameMap.ClientID + @".location = '" +
             mapClient.ApplicationEnvironmentController.ClientServerMapURL + @"#' + Command + '=' + data;
            if(rowIndex)
            {
                mapRowChosenIndex = rowIndex;
                
            }
        }
        ";

        Page.ClientScript.RegisterStartupScript(typeof(string), "sendCommandJSContent", sendCommandJSContent, true);
        //Page.ClientScript.RegisterStartupScript(typeof(string), "sendCommandJSContent", sendCommandJSContent, true);

        string populateFrameWithHdnIfEmptyJSContent = @"
                function populateFrameWithHdnIfEmpty() {

 
            var hdnIsInitialized = document.getElementById('" + hdnIsInitialized.ClientID + @"');
            //instead use this
            if (hdnIsInitialized.value == false.toString()) {
                var hdn = document.getElementById('" + hdnFrameSrc.ClientID + @"');
                " + frameMap.ClientID + @".location = hdn.value;
                hdnIsInitialized.value = true.toString();
            }
        }
";

        Page.ClientScript.RegisterStartupScript(typeof(string), "populateFrameWithHdnIfEmptyJSContent", populateFrameWithHdnIfEmptyJSContent, true);
        //Page.ClientScript.RegisterStartupScript(typeof(string), "populateFrameWithHdnIfEmptyJSContent", populateFrameWithHdnIfEmptyJSContent, true);


    }

    /// <summary>
    /// There are situations that we need to populate the iframe with the map statically ( when page loads first time )
    /// </summary>
    public void InitMapFrameOnStartup()
    {
        Page.ClientScript.RegisterStartupScript(typeof(string), "InitMapFrameOnStartup", "populateFrameWithHdnIfEmpty();", true);

    }

    MapCoordinatesClient mapClient = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        // AsyncCallbackHelper asyncCallbackHelper = new AsyncCallbackHelper(this, _CallbackFunctionsDictionary);
        UpdatePanelClinicJson.Attributes.Add("style", "height:0px"); 
        try
        {
            
            
            if (IsPostBack)
            {
                HandleRowMapImageClick_NonClosestPointSearch();                
            }
        }
        catch (Exception ex)
        {
          
        }
        //makes sure the auto complete popups if exists on the page will always be on top of the map
    }

    public event RowMapImageClick_NonClosestPointSearch_OccuredDelegate RowMapImageClick_NonClosestPointSearch_Occured;
    public event EventHandler BtnTriggerPostBackClicked;
    //(object sender, EventArgs e)
    public void HandleRowMapImageClick_NonClosestPointSearch()
    {
        string btnTriggerPostBackId = btnTriggerPostBack.ClientID;
        //this occurs when we click on a grid row map image
        // it suppose to focus on the address  in the map of the clicked address
        if (HttpContext.Current.Request["__EVENTTARGET"] == btnTriggerPostBackId && string.IsNullOrEmpty(HttpContext.Current.Request["__EVENTARGUMENT"]) == false)
        {
            //allow showing the map
            //master.IsAllowShowMap_PageCondition = true;

            //example for __EVENTARGUMENT is - '1234,2' - first is the dept code, second is the rowindex 
            string args = HttpContext.Current.Request["__EVENTARGUMENT"];
            string[] argsArray = args.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);

            int focusedDeptCodeInMap = Convert.ToInt32(argsArray[0]);
            int rowIndex = Convert.ToInt32(argsArray[1]);

            if (RowMapImageClick_NonClosestPointSearch_Occured != null)
            {
                RowMapImageClick_NonClosestPointSearch_Occured(this, rowIndex);
            }

            //this event is for the sake of refreshing any parent that has update panel in it and wants 
            // to refresh it's content (the parent will have to register a trigger like so ( like in SearchMasterPage  for example)
             //<Triggers>
             //     <asp:AsyncPostBackTrigger ControlID="DeptMapControl" EventName="BtnTriggerPostBackClicked" />
             // </Triggers>
            if (BtnTriggerPostBackClicked != null)
            {
                BtnTriggerPostBackClicked(this,new EventArgs());
            }
              
            //highlight on the clicked row
            //gv.SelectedIndex = Convert.ToInt32(argsArray[1]);
            //there are 2 modes
            //1. find the closest depts to a given x,y coordinates
            //2. find one given dept

            Dictionary<int, List<int>> deptCodes = new Dictionary<int, List<int>>();
            deptCodes.Add(focusedDeptCodeInMap, new List<int> { 1 });
            RefreshMapDepts(deptCodes, -1, -1, null);
        }
    }

    #region Initialization & population methods - to be called only when page loaded (not on postback)

    public void RefreshMapDepts(Dictionary<int, List<int>> allDeptCodes, double? coordX, double? coordY, int? focusedDeptCode)
    {
        RefreshMapDepts(allDeptCodes, coordX, coordY, focusedDeptCode, true,true);
    }

    /// <summary>
    /// this HAS TO BE CALLED BEFORE the UserControls_DeptMapUC event is loaded, 
    /// because in the loaded event it to prepares the map and populates it.
    /// </summary>
    /// <param name="allDeptCodes"></param>
    /// <param name="coordX"></param>
    /// <param name="coordY"></param>
    /// <param name="focusedDeptCode"></param>
    public void RefreshMapDepts(Dictionary<int, List<int>> allDeptCodes , double? coordX, double? coordY, int? focusedDeptCode,bool isNewLoad,bool isAddClinicsToMap)
    {
        //TO DO
        //add sub numbers for each dept - so 1 dept can have several numbers -
        //for exampe 1-3 doctor can be in 1 dept 4-5 can be in another dept and so on
        //

        CoordX = coordX;
        CoordY = coordY;
        FocusedDeptCode = focusedDeptCode;

        if (isNewLoad == true || View_DeptDetailsList == null)
        {
            AllDeptCodes = allDeptCodes;
            ReloadDeptDetails();
        }

        //test
       // gvClinicsList.DataSource = View_DeptDetailsList;
       // gvClinicsList.DataBind();

        try
        {

            //argument from the client to be processed by server

            List<ClinicAddressInfo> clinicInfoList = new List<ClinicAddressInfo>();

            foreach (View_DeptDetails item in View_DeptDetailsList)
            {
                foreach (int orderNumber in AllDeptCodes[item.deptCode])
                {
                    if (item.xcoord != null && item.ycoord != null)  // it shouldn't happen!!!
                    {
                        ClinicAddressInfo clinicInfo = new ClinicAddressInfo();
                        clinicInfo.Address = new AddressLiteralInfo(item.cityName, item.street, item.house);
                        clinicInfo.DisplayOrder = orderNumber;
                        clinicInfo.ClinicId = item.deptCode;
                        clinicInfo.Title = item.deptName;
                        clinicInfo.Coords = new CoordInfo(item.xcoord.Value, item.ycoord.Value, item.XLongitude.Value, item.YLatitude.Value); 
                        clinicInfoList.Add(clinicInfo);
                    }
                }
            }

            // the coordinates that the current user is at
            CoordInfo coordInfoCurrentUserLocation = null;

            if (CoordX != null && CoordY != null)
            {
                coordInfoCurrentUserLocation = new CoordInfo(CoordX.Value, CoordY.Value, 0, 0);
            }

            if (clinicInfoList != null && clinicInfoList.Count > 0)//&& isAddClinicsToMap == true)
            {
                //TEST
                hdnClinicJson.Value = mapClient.GetClinicListJsonString(clinicInfoList, coordInfoCurrentUserLocation);
                //  mapClient.AddClinicsToMap();
            }
        }
        catch (Exception)
        {


        }      
        // later on go the DB and pull all the depts by all the keys ( in AllDepts key )          
    }

    private void ReloadDeptDetails()
    {
        View_DeptDetailsBL bl = new View_DeptDetailsBL();

        View_DeptDetailsList = bl.GetByValues(eDeptEnum.deptCode.ToString(), AllDeptCodes.Keys.ToList());
        SortListByDeptCodesOrder();
    
    }

    private void SortListByDeptCodesOrder()
    {
        List<int> keys = AllDeptCodes.Keys.ToList();
       
        for (int i = 0; i < keys.Count; i++)
       // for (int i = 0; i < AllDeptCodes.Count; i++)
        {
            int code = keys[i];//AllDeptCodes[keys[i]]
            View_DeptDetails foundItem = View_DeptDetailsList.Find(delegate(View_DeptDetails itemToSearch)
            {
                return itemToSearch.deptCode == code;
            });

            foundItem.DisplayOrder = i + 1;
        }

        View_DeptDetailsList.Sort(delegate(View_DeptDetails item1, View_DeptDetails item2)
        {
            if (item1.DisplayOrder > item2.DisplayOrder) return 1;
            if (item2.DisplayOrder > item1.DisplayOrder) return -1;
            return 0;
        });
    }

    #endregion

    #region ICallbackEventHandler Members

    public string GetCallbackResult()
    {
        return true.ToString();
        //return to the client - true/false
        //throw new NotImplementedException();
    }

    public void RaiseCallbackEvent(string eventArgument)
    {
        //MapCoordinatesClient currentMapCoordinatesClient = MapCoordinatesClientManager.Instance.GetItem(MapSessionID);

        string[] arr = eventArgument.Split(new char[] { ';' });

        //clean the session when form is closed
        if (arr[0] == "OnMapClosed")
        {
           // MapCoordinatesClientManager.Instance.RemoveItem(MapSessionID);
        }
      
        //if (arr[0] == "OnFocusOnDept")
        //{
        //    currentMapCoordinatesClient.FocusOnClinicId(Convert.ToInt32(arr[1]));
        //}
    }

    #endregion
}
