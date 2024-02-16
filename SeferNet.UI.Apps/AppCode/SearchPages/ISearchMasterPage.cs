using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;

/// <summary>
/// Used for calling the master page in a generic way, for example if we want to access the master page from 1 
/// central place in a helper class, instead of from each search page, it can be done with interface
/// </summary>
public interface ISearchMasterPage
{
     bool IsClosestPointsSearchMode { get; }
     void RefreshMap(int? focusedDeptCode, DataTable dtResult, double? coordinateX, double? coordinateY, bool isNewLoad);
     //void RefreshMapOnRepeatSearch_IfRequired(int? focusedDeptCode, DataTable dtResult, double? coordinateX, double? coordinateY, bool isNewLoad);
     bool IsAllowShowMap_PageCondition { get; set; }    
}
