using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using SeferNet.Globals;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public  class MapSearchInfo
    {
        int? m_cityCode;
        
        string m_cityName;
        string m_cityNameOnly;
        string m_neighborhood;
        string m_neighborhoodCode;
        string m_street;
        string m_site;
        string m_house;

        double? m_coordinatX;
        double? m_coordinatY;

        public string Neighborhood
        {
            get { return m_neighborhood; }
            set { m_neighborhood = value; }
        }

        public string NeighborhoodCode
        {
            get { return m_neighborhoodCode; }
            set { m_neighborhoodCode = value; }
        }

        public string Street
        {
            get { return m_street; }
            set { m_street = value; }
        }

        public string Site
        {
            get { return m_site; }
            set { m_site = value; }
        }

        public string House
        {
            get { return m_house; }
            set { m_house = value; }
        }

        public double? CoordinatX
        {
            get { return m_coordinatX; }
            set { m_coordinatX = value; }
        }

        public double? CoordinatY
        {
            get { return m_coordinatY; }
            set { m_coordinatY = value; }
        }

        public int? CityCode
        {
            get { return m_cityCode; }
            set { m_cityCode = value; }
        }

        public string CityName
        {
            get { return m_cityName; }
            set { m_cityName = value; }
        }

        public string CityNameOnly
        {
            get { return m_cityNameOnly; }
            set { m_cityNameOnly = value; }
        }

        public MapSearchInfo()
        {
          
        }

        public virtual void PrepareParametersForDBQuery()
        {
            if (m_cityCode <= 0)
            {
                m_cityCode = null;
            }

            if (m_coordinatX == 0 && m_coordinatY == 0)  {
                m_coordinatX = null;            
                m_coordinatY = null;
            }

            StringHelper.CleanStringAndSetToNullIfRequired(ref m_cityName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_cityNameOnly);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_neighborhood);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_site);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_cityName);
            StringHelper.CleanStringAndSetToNullIfRequired(ref m_house);
        }

    }
}
