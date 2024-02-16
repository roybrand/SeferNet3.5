using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class WS_Dept
    {
        public WS_Dept()
    {
        
    }
    [XmlElement]
    public int deptCode;

    [XmlElement]
    public string deptName;

    [XmlElement]
    public int deptType;

    [XmlElement]
    public int deptLevel;

    [XmlElement]
    public string deptTypeDescription;

    [XmlElement]
    public int typeUnitCode;

    [XmlElement]
    public string UnitTypeName;

    [XmlElement]
    public int cityCode;

    [XmlElement]
    public string cityName;

    [XmlElement]
    public string street;

    [XmlElement]
    public string  house;

    [XmlElement]
    public string flat;

    [XmlElement]
    public string entrance;

    [XmlElement]
    public int zipCode;

    [XmlElement]
    public string pob;

    [XmlElement]
    public string DoarNa;

    [XmlElement]
    public string addressComment;

    [XmlElement]
    public int prePrefix;

    [XmlElement]
    public int prefix;

    [XmlElement]
    public int phone;

    [XmlElement]
    public string remark;
    
    }
}
