using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using MapsManager;
using SeferNet.BusinessLayer.WorkFlow;

public partial class UserControls_MapSearchControl : System.Web.UI.UserControl
{
    public TextBox TxtDistrictCodes
    {
        get
        {
            return txtDistrictCodes;
        }
    }

    public DropDownList DdlNumberOfRecordsToShow
    {
        get
        {

            return ddlNumberOfRecordsToShow;
        }
    }
    
    /// <summary>
    /// gets the map information from the controls
    /// </summary>
    /// <param name="isCalculateCoordinates">if yes to goes to the web service 
    /// to get the coordinates by the controls adress information </param>
    /// <returns></returns>
    public MapSearchInfo GetMapInfo(bool isCalculateCoordinates)
    {
        MapSearchInfo retVal = new MapSearchInfo();

        retVal.CityName = txtCityName.Text;
        retVal.CityNameOnly = txtCityNameOnly.Text;
        retVal.Neighborhood = txtNeighborhood.Text;
        retVal.Street = txtStreet.Text;
        retVal.Site = txtSite.Text;
        retVal.House = txtHouse.Text;
        
        if (isCalculateCoordinates == true)
        {
            CalculatedXYCoords(retVal);
        }

        return retVal;
    }

    public bool IsClosestPointsSearchMode
    {
        get
        {
            return cbShowMapSearchControls.Checked;
        }
    }

    public void CalculatedXYCoords(MapSearchInfo mapSearchInfo)
    {
        if (txtCityName.Text != string.Empty && 
                    (txtStreet.Text != string.Empty ||
                    txtNeighborhood.Text != string.Empty ||
                    txtSite.Text != string.Empty ||
                    txtHouse.Text != string.Empty ||
                    cbShowMapSearchControls.Checked == true)
            )
        {
            int number = 0;
            string city = txtCityNameOnly.Text;
            string street = txtStreet.Text;
            string region = txtNeighborhood.Text;
            string atar = txtSite.Text;
            int.TryParse(txtHouse.Text, out number);

            MapCoordinatesClient cli = new MapCoordinatesClient(MapHelper.GetMapApplicationEnvironmentController());
            CoordInfo  coordInfoToReturn = cli.GetXY(city, street, number, region, atar);
            mapSearchInfo.CoordinatX = coordInfoToReturn.X;
            mapSearchInfo.CoordinatY   = coordInfoToReturn.Y;
        }
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        //??? not sure
        Page.PreRender += new EventHandler(Page_PreRender);
    }

    
    void Page_PreRender(object sender, EventArgs e)
    {
        //SetMapSearchControlsVisibility();
    } 

    protected void Page_Load(object sender, EventArgs e)
    {       
        if (IsPostBack == false)
        {
            InitializeViewFromGlobalResources();
        }

        autoCompleteCities.ContextKey = txtDistrictCodes.Text + ";" + Session["Culture"].ToString();
        autoCompleteStreets.ContextKey = txtCityCode.Text;
        autoCompleteSite.ContextKey = txtCityCode.Text;
        autoCompleteNeighborhood.ContextKey = txtCityCode.Text;
    }


    private void InitializeViewFromGlobalResources()
    {
        string notValidChar = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "NotValidChar_ErrorMess") as string;
        string notValidWords = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "PreservedWord_ErrorMess") as string;
        string notValidInteger = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "IntegerOnly_ErrorMess") as string;

        //---- Neighborhood
        this.VldRegexNeighborhood.ErrorMessage = string.Format(notValidChar, this.lblNeighborhood.Text);
        this.VldRegexNeighborhood.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.VldPreservedWordsNeighborhood.ErrorMessage = string.Format(notValidWords, this.lblNeighborhood.Text);

        //---- Street
        this.VldRegexStreet.ErrorMessage = string.Format(notValidChar, this.lblStreet.Text);
        this.VldRegexStreet.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.VldPreservedWordsStreet.ErrorMessage = string.Format(notValidWords, this.lblStreet.Text);

        //---- Site
        this.VldRegexSite.ErrorMessage = string.Format(notValidChar, this.lblSite.Text);
        this.VldRegexSite.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsSite.ErrorMessage = string.Format(notValidWords, this.lblSite.Text);

        //---- House
        this.vldRegexHouse.ErrorMessage = string.Format(notValidChar, this.lblHome.Text);
        this.vldRegexHouse.ValidationExpression = HttpContext.GetGlobalResourceObject("ValidationErrorMessages", "RegexSiteName") as string;
        this.vldPreservedWordsHouse.ErrorMessage = string.Format(notValidWords, this.lblHome.Text);
       
        string multiLineLabelCss = "MultiLineLabel";

        this.lblCityName.CssClass = multiLineLabelCss;
        this.lblHome.CssClass = multiLineLabelCss;
        this.lblNeighborhood.CssClass = multiLineLabelCss;
        this.lblNumberOfRecordsToShow.CssClass = multiLineLabelCss;
        this.lblDistrict.CssClass = multiLineLabelCss;
        this.lblSite.CssClass = multiLineLabelCss;       
        this.lblStreet.CssClass = multiLineLabelCss;
    }

    public  void ClearFields()
    {
        txtDistrictCodes.Text = string.Empty;
        txtDistrictList.Text = string.Empty;
        txtCityName.Text = String.Empty;
        txtCityCode.Text = String.Empty;

        txtNeighborhood.Text = String.Empty;
        txtStreet.Text = String.Empty;
        txtSite.Text = String.Empty;
        txtHouse.Text = String.Empty;
    }

    public void SetMapInfoControls(SearchParametersBase clinicSearchParameters)
    {
        txtDistrictCodes.Text = clinicSearchParameters.DistrictCodes;
        txtDistrictList.Text = clinicSearchParameters.DistrictText;

        txtCityCode.Text = clinicSearchParameters.MapInfo.CityCode.ToString();
        if (clinicSearchParameters.ShowMapSearchControls == true)
            cbShowMapSearchControls.Checked = true;
        else
            cbShowMapSearchControls.Checked = false;

        txtCityName.Text = clinicSearchParameters.MapInfo.CityName;
        txtCityNameOnly.Text = clinicSearchParameters.MapInfo.CityNameOnly;
        txtNeighborhood.Text = clinicSearchParameters.MapInfo.Neighborhood;
        txtStreet.Text = clinicSearchParameters.MapInfo.Street;
        txtSite.Text = clinicSearchParameters.MapInfo.Site;
        txtHouse.Text = clinicSearchParameters.MapInfo.House;
        ddlNumberOfRecordsToShow.SelectedValue = clinicSearchParameters.NumberOfRecordsToShow.ToString();
    }

    public void SetClinicSearchParameters(SearchParametersBase clinicSearchParameters)
    {
        clinicSearchParameters.DistrictCodes = txtDistrictCodes.Text;
        //clinicSearchParameters.DistrictNames = txtDistrictList.Text;
        clinicSearchParameters.DistrictText = txtDistrictList.Text;// ???

        if (cbShowMapSearchControls.Checked == true)
        {
            clinicSearchParameters.ShowMapSearchControls = true;
            if (ddlNumberOfRecordsToShow.SelectedIndex != -1)
            {
                clinicSearchParameters.NumberOfRecordsToShow = Convert.ToInt32(ddlNumberOfRecordsToShow.SelectedValue);
            }
            else
            {
                clinicSearchParameters.NumberOfRecordsToShow = null;
            }
        }
        else
        {         
            clinicSearchParameters.ShowMapSearchControls = false;
            clinicSearchParameters.NumberOfRecordsToShow = null;
        }

        clinicSearchParameters.MapInfo = GetMapInfo(true);

        

        int cityCode = 0;
        if (int.TryParse( txtCityCode.Text.Trim(),out cityCode) == true)
        {
            clinicSearchParameters.MapInfo.CityCode = cityCode;
        }    
    }

    private void SetMapSearchControlsVisibility()
    {
        if (txtCityCode.Text != string.Empty)
        {
            if (cbShowMapSearchControls.Checked == true)
            {
                trMapSearch_1.Style.Add("display", "inline");
                trMapSearch_2.Style.Add("display", "inline");
                trMapSearch_3.Style.Add("display", "inline");

                btnShowMapSearchControls.Style.Add("display", "none");
             
                //tblMapSearchControls.Style.Add("background-color", "#E8F4FD");

                trMapSearch_1.Style.Add("background-color", "#E8F4FD");
                trMapSearch_2.Style.Add("background-color", "#E8F4FD");
                trMapSearch_3.Style.Add("background-color", "#E8F4FD");
            }
            else
            {
                trMapSearch_1.Style.Add("display", "none");
                trMapSearch_2.Style.Add("display", "none");
                trMapSearch_3.Style.Add("display", "none");


                btnShowMapSearchControls.Style.Add("display", "inline");
        
                //tblMapSearchControls.Style.Add("background-color", "#FFFFFF");

                trMapSearch_1.Style.Add("background-color", "#FFFFFF");
                trMapSearch_2.Style.Add("background-color", "#FFFFFF");
                trMapSearch_3.Style.Add("background-color", "#FFFFFF");
            }
        }
        else
        {
            trMapSearch_1.Style.Add("display", "none");
            trMapSearch_2.Style.Add("display", "none");
            trMapSearch_3.Style.Add("display", "none");

            btnShowMapSearchControls.Style.Add("display", "none");
            btnShowMapSearchControls.ImageUrl = "../Images/Applic/btn_Plus_Green.jpg";

            //tblMapSearchControls.Style.Add("background-color", "#FFFFFF");

            trMapSearch_1.Style.Add("background-color", "#FFFFFF");
            trMapSearch_2.Style.Add("background-color", "#FFFFFF");
            trMapSearch_3.Style.Add("background-color", "#FFFFFF");
        }
    }


}
