using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.EntitiesDal;
using Clalit.SeferNet.GeneratedEnums;
using SeferNet.Globals;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.EntitiesBL
{
    public class View_DeptAddressAndPhonesBL
    {

        #region Properties

        public static string DeptCodeColumnName
        {
            get { return "DeptCode"; }
        }

        public static string DeptNameColumnName
        {
            get { return "DeptName"; }
        }

        #endregion


        public List<View_AllDeptAddressAndPhone> GetAllDistrictsWithDetails()
        {
            SeferNetEntities ent = SeferNetEntitiesFactory.GetSeferNetEntities();

            int? district = (int?)eUnitType.Mahoz;
            short? active = (short?)Enums.Status.Active;

            var res = from v in ent.View_AllDeptAddressAndPhone
                      where v.typeUnitCode == district
                      && v.status == active
                      orderby v.deptName
                      select v;
                      

            return res.ToList();
        } 

        public List<View_AllDeptAddressAndPhone> GetAdministrationsByDistrict(int districtCode)
        {
            SeferNetEntities ent = SeferNetEntitiesFactory.GetSeferNetEntities();

            int? administration = (int?)eDIC_DeptTypes.Administration;
            short? active = (short?)Enums.Status.Active;

            var res = from v in ent.View_AllDeptAddressAndPhone
                      where v.districtCode == districtCode
                      && v.deptType == administration
                      && v.status == active
                      orderby v.deptName
                      select v;


            return res.ToList();
        }

        public List<View_AllDeptAddressAndPhone> GetClinicsByAdministration(int administrationCode)
        {
            SeferNetEntities ent = SeferNetEntitiesFactory.GetSeferNetEntities();

            short? active = (short?)Enums.Status.Active;

            var res = from v in ent.View_AllDeptAddressAndPhone
                      where v.administrationCode == administrationCode
                      && v.status == active
                      && v.deptCode != administrationCode
                      orderby v.deptName
                      select v;


            return res.ToList();
        }
    }
}
