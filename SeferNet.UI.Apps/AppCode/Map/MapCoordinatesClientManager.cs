using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using MapsManager;

/// <summary>
/// Summary description for MapCoordinatesClientManager
/// </summary>
public class MapCoordinatesClientManager
{

    //singletone
    static MapCoordinatesClientManager instance = null;
    static readonly object padlock = new object();

    public static MapCoordinatesClientManager Instance
    {
        get
        {
            lock (padlock)
            {
                if (instance==null)
                {
                    instance = new MapCoordinatesClientManager();
                }
                return instance;
            }
        }
    }

    //
    Dictionary<string, MapCoordinatesClient> _MapCoordinatesClientDictionary;
    Dictionary<string, string> _AppSessionIdToMapSessionIdTDictionary;
  
    private MapCoordinatesClientManager()
    {
        _MapCoordinatesClientDictionary = new Dictionary<string, MapCoordinatesClient>();
        _AppSessionIdToMapSessionIdTDictionary = new Dictionary<string, string>();
    }

    public void AddItem(string mapSessionId, MapCoordinatesClient mapCoordinatesClient)
    {
        if (_MapCoordinatesClientDictionary.ContainsKey(mapSessionId) == false)
        {
            RemovePreviousItemOfCurrentAppSession_IfRequired();

            //first time app session opens a map
            if (_AppSessionIdToMapSessionIdTDictionary.ContainsKey(HttpContext.Current.Session.SessionID) == false)
            {
                _AppSessionIdToMapSessionIdTDictionary.Add(HttpContext.Current.Session.SessionID, null);
            }

            //gets the new map session
            _AppSessionIdToMapSessionIdTDictionary[HttpContext.Current.Session.SessionID] = mapSessionId;

            _MapCoordinatesClientDictionary.Add(mapSessionId, mapCoordinatesClient);
        }
    }

    /// <summary>
    ///  it's called in order to clean the MapCoordinatesClient object of previous map usage
    ///  In session Ends or when the same app session reopens a map with a new mapsessionid
    /// </summary>
    public void RemovePreviousItemOfCurrentAppSession_IfRequired()
    {
        if (HttpContext.Current != null)
        {
            RemovePreviousItemOfAppSessionId_IfRequired(HttpContext.Current.Session.SessionID);
        }
    }

    public void RemovePreviousItemOfAppSessionId_IfRequired(string sessionId)
    {
        string previousMapSessionIdToRemove = null;
        if (_AppSessionIdToMapSessionIdTDictionary.ContainsKey(sessionId) == true)
        {
            previousMapSessionIdToRemove = _AppSessionIdToMapSessionIdTDictionary[sessionId];
            //remove previous map object if required
            if (string.IsNullOrEmpty(previousMapSessionIdToRemove) == false)
            {
                _MapCoordinatesClientDictionary.Remove(previousMapSessionIdToRemove);
            }
        }
    }

    public void RemoveItem(string mapSessionId)
    {
        if (_MapCoordinatesClientDictionary.ContainsKey(mapSessionId) == true)
        {
            _MapCoordinatesClientDictionary.Remove(mapSessionId);           
        }
    }

    public MapCoordinatesClient GetItem(string mapSessionId)
    {
        MapCoordinatesClient retVal = null;
        if (_MapCoordinatesClientDictionary.ContainsKey(mapSessionId) == true)
        {
            retVal = _MapCoordinatesClientDictionary[mapSessionId];
        }

        return retVal;
    }

    //public  class MapSessionExtraInfo
    //{
    //    public DateTime DateAdded{ get; set; }

    //}
}
