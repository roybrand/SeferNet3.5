using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class Brochures
    {
        public void GetBrochures(ref DataSet p_ds, bool isCommunity, bool isMushlam)
        {
            SeferNet.DataLayer.Brochures brochures = new SeferNet.DataLayer.Brochures();

            brochures.GetBrochures(ref p_ds, isCommunity, isMushlam);
        }

        public void InsertBrochure(string displayName, string fileName, int languageCode,
            bool isCommunity, bool isMushlam)
        {
            SeferNet.DataLayer.Brochures brochures = new SeferNet.DataLayer.Brochures();

            brochures.InsertBrochure(displayName, fileName, languageCode, isCommunity, isMushlam);
        }

        public void UpdateBrochure(int brochureID, string DisplayName, string fileName, int languageCode)
        {
            SeferNet.DataLayer.Brochures brochures = new SeferNet.DataLayer.Brochures();

            brochures.UpdateBrochure(brochureID, DisplayName, fileName, languageCode);
        }

        public void DeleteBrochure(int brochureID)
        {
            SeferNet.DataLayer.Brochures brochures = new SeferNet.DataLayer.Brochures();

            brochures.DeleteBrochure(brochureID);
        }
    }
}
