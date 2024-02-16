using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data;

/// <summary>
/// The page that wants to use the paging abilities must implement this interface
/// </summary>
public interface ISearchPageController
{
    void LoadDataAndPopulate(bool isFromCache = false);

    
    int TotalNumberOfRecords {get;}
    

    SearchParametersBase PageSearchParameters { get; }

    DataTable DTSearchResults { get; }
}
 