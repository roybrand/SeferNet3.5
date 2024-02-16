using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.Globals;
using SeferNet.BusinessLayer.BusinessObject;
using System.ComponentModel;
using System.Data;
using SeferNet.FacadeLayer;

public partial class UserControls_SearchModeSelector : System.Web.UI.UserControl
{

    private bool _allModesSelected;
    private bool _communitySelected;
    private bool _mushlamSelected;
    private bool _hospitalsSelected;
    private List<Enums.SearchMode> list = new List<Enums.SearchMode>();


    #region Properties

    public bool IsHiddenMode
    {
        set
        {
            if (value == true)
                lstModes.Style.Add("display", "none");
            else
                lstModes.Style.Add("display", "inline");
        }
    }

    public bool IsHospitalsHidden
    {
        set
        {
            if (value == true)
                lstModes.Items.Remove(lstModes.Items.FindByValue(Enums.SearchMode.Hospitals.ToString()));
        }
    }

    /// <summary>
    /// return selected values (All, Community,	Mushlam, Hospitals) in comma delimited string
    /// </summary>    
    public string SelectedValues
    {
        get
        {
            string retVals = string.Empty;
            foreach (ListItem item in lstModes.Items)
            {
                if (item.Selected)
                {
                    retVals += item.Value + ",";
                }
            }

            return retVals.Substring(0, retVals.Length);
        }

        set
        {
            string[] valuesArr = value.Split(new char[] { ',', ';' });
            foreach (ListItem item in lstModes.Items)
            {
                if (value.IndexOf(item.Value) >= 0)
                {
                    item.Selected = true;
                }
                else
                {
                    item.Selected = false;
                }
            }
        }
    }

    /// <summary>
    /// return selected Codes (-1, 1, 2, 3) in comma delimited string
    /// </summary>   
    public string SelectedCodes
    {
        get
        {
            string retVals = string.Empty;
            foreach (ListItem item in lstModes.Items)
            {
                if (item.Selected)
                {
                    //int(Enums.SearchMode.Community)
                    Enums.SearchMode code = (Enums.SearchMode)Enum.Parse(typeof(Enums.SearchMode), item.Value);
                    retVals += (int)code + ",";
                }
            }

            return retVals.Substring(0, retVals.Length);
        }

        set
        {
            string[] codesArr = value.Split(new char[] { ',', ';' });
            foreach (ListItem item in lstModes.Items)
            {
                Enums.SearchMode code = (Enums.SearchMode)Enum.Parse(typeof(Enums.SearchMode), item.Value);
                string codeStr = ((int)code).ToString();
                if (value.IndexOf(codeStr) >= 0)
                {
                    item.Selected = true;
                }
                else
                {
                    item.Selected = false;
                }
            }
        }
    }

    public List<Enums.SearchMode> SelectedSearchModes
    {
        get
        {
            list = new List<Enums.SearchMode>();
            foreach (ListItem item in lstModes.Items)
            {
                if (item.Selected)
                {
                    list.Add((Enums.SearchMode)Enum.Parse(typeof(Enums.SearchMode), item.Value));
                }
            }
            return list;
        }
    }

    public bool AllModesSelected
    {
        get
        {
            return SelectedSearchModes.Exists(item => item == Enums.SearchMode.All);
        }

        set
        {
            _allModesSelected = value;
            lstModes.Items.FindByValue(Enums.SearchMode.All.ToString()).Selected = value;

            if (lstModes.Items.FindByValue(Enums.SearchMode.All.ToString()).Selected == true)
            {
                lstModes.Items.FindByValue(Enums.SearchMode.Community.ToString()).Selected = true;
                lstModes.Items.FindByValue(Enums.SearchMode.Mushlam.ToString()).Selected = true;
            }
        }
    }

    public bool IsMushlamModeSelected
    {
        get
        {
            return SelectedSearchModes.Exists(item => item == Enums.SearchMode.Mushlam);
        }
        set
        {
            _mushlamSelected = value;
            lstModes.Items.FindByValue(Enums.SearchMode.Mushlam.ToString()).Selected = value;
        }
    }

    public bool IsCommunityModeSelected
    {
        get
        {
            return SelectedSearchModes.Exists(item => item == Enums.SearchMode.Community);
        }
        set
        {
            _communitySelected = value;
            lstModes.Items.FindByValue(Enums.SearchMode.Community.ToString()).Selected = value;
        }
    }

    public bool IsHospitalsModeSelected
    {
        get
        {
            return SelectedSearchModes.Exists(item => item == Enums.SearchMode.Hospitals);
        }
        set
        {
            _hospitalsSelected = value;
            lstModes.Items.FindByValue(Enums.SearchMode.Hospitals.ToString()).Selected = value;
        }
    }

    public SearchModeInfo SearchMode
    {
        set
        {
            if (value.AllModesSelected != null)
            {
                if ((bool)value.AllModesSelected)
                {
                    this.AllModesSelected = true;
                    this.IsCommunityModeSelected = true;
                    this.IsMushlamModeSelected = true;
                    this.IsHospitalsModeSelected = true;
                }
            }
            else
            {
                this.IsCommunityModeSelected = (value.IsCommunitySelected != null) ? (bool)value.IsCommunitySelected : false;
                this.IsMushlamModeSelected = (value.IsMushlamSelected != null) ? (bool)value.IsMushlamSelected : false;
                this.IsHospitalsModeSelected = (value.IsHospitalsSelected != null) ? (bool)value.IsHospitalsSelected : false;
            }
        }
    }

    public event EventHandler SelectedIndexChanged;

    //public event EventHandler SelectedIndexChanged
    //{
    //    add
    //    {
    //        this.lstModes.AutoPostBack = true;
    //        this.lstModes.SelectedIndexChanged += value;
    //    }
    //    remove
    //    {
    //        this.lstModes.SelectedIndexChanged -= value;
    //    }
    //}

    [Browsable(true)]
    public bool AutoPostBack
    {
        set
        {
            this.lstModes.AutoPostBack = value;
        }
        get
        {
            return this.lstModes.AutoPostBack;
        }
    }

    #endregion


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        BindValues();  // we put it here so that on Page_Load we can get the control items on master page
    }

    protected void Page_Load(object sender, EventArgs e)
    {


        //this.lstModes.AutoPostBack = true;
        this.lstModes.SelectedIndexChanged += new EventHandler(lstModes_SelectedIndexChanged);


    }

    private void lstModes_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (this.SelectedIndexChanged != null)
        {
            this.SelectedIndexChanged(this, e);
        }
    }

    private void setStrAgreementTypes()
    {
        Facade applicFacade = Facade.getFacadeObject();
        DataTable dt = applicFacade.GetAgreementTypes();
        Dictionary<int, String> dicAgreements = new Dictionary<int, String>();


        foreach (DataRow dr in dt.Rows)
        {
            int orgID = int.Parse(dr["OrganizationSectorID"].ToString());
            if (dicAgreements.ContainsKey(orgID))
            {
                dicAgreements[orgID] += "#";
            }
            else
            {
                dicAgreements.Add(orgID, "");
            }
            dicAgreements[orgID] += dr["AgreementTypeDescription"].ToString();
            dicAgreements[orgID] += "!" + dr["EnumName"].ToString() + "!" + ((bool)dr["IsDefault"] ? 1 : 0);

        }

        // Create the lists for the client
        String listID = "agreementType_";
        String scriptStrs = "<script type=\"text/javascript\">";
        int tmpCount = 1;
        foreach (KeyValuePair<int, String> pair in dicAgreements)
        {
            scriptStrs += "var agreementType_" + pair.Key + " = '" + pair.Value + "';";

            listID += pair.Key.ToString();
            if (tmpCount < dicAgreements.Count)
            {
                listID += "#agreementType_";
            }

            tmpCount++;

        }

        scriptStrs += "var  listID='" + listID + "';";
        scriptStrs += @"</script>";
        Page.ClientScript.RegisterStartupScript(GetType(), "scriptstrs", scriptStrs);
    }

    public CheckBoxList LstModes
    {
        get
        {
            return lstModes;
        }
    }

    private void BindValues()
    {

        setStrAgreementTypes();
        lstModes.Items.Add(new ListItem("הכל", Enums.SearchMode.All.ToString()));
        lstModes.Items.Add(new ListItem("קהילה", Enums.SearchMode.Community.ToString()));
        lstModes.Items.Add(new ListItem("מושלם", Enums.SearchMode.Mushlam.ToString()));
        lstModes.Items.Add(new ListItem("בתי חולים", Enums.SearchMode.Hospitals.ToString()));

        // add attribute to be able to get it on client
        foreach (ListItem item in lstModes.Items)
        {
            item.Attributes.Add("itemValue", item.Value);

        }

        string cID = lstModes.ClientID;
        lstModes.Items.FindByValue(Enums.SearchMode.All.ToString()).Attributes.Add("onclick", "EnableBySelection('" + cID + "_0',true);");
        lstModes.Items.FindByValue(Enums.SearchMode.Community.ToString()).Attributes.Add("onclick", "EnableBySelection('" + cID + "_1',false);");
        lstModes.Items.FindByValue(Enums.SearchMode.Mushlam.ToString()).Attributes.Add("onclick", "EnableBySelection('" + cID + "_2',false);");
        lstModes.Items.FindByValue(Enums.SearchMode.Hospitals.ToString()).Attributes.Add("onclick", "EnableBySelection('" + cID + "_3',false);");


        // default selection
        lstModes.Items.FindByValue(Enums.SearchMode.Community.ToString()).Selected = true;
        lstModes.Items.FindByValue(Enums.SearchMode.Community.ToString()).Attributes.Add("class", "selected");
    }
}