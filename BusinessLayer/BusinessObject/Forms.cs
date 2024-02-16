using System;
using System.Collections.Generic;
using System.Data; 
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class Forms
    {
        public void GetForms(ref DataSet p_ds, bool isCommunity, bool isMushlam)
        {
            SeferNet.DataLayer.Forms forms = new SeferNet.DataLayer.Forms();

            forms.GetForms(ref p_ds, isCommunity, isMushlam);
        }

        public void InsertForm(string fileName, string formDisplayName,
            bool isCommunity, bool isMushlam)
        {
            SeferNet.DataLayer.Forms forms = new SeferNet.DataLayer.Forms();

            forms.InsertForm(fileName, formDisplayName, isCommunity, isMushlam);
        }

        public void UpdateForm(int formID, string fileName, string formDisplayName)
        {
            SeferNet.DataLayer.Forms forms = new SeferNet.DataLayer.Forms();

            forms.UpdateForm(formID, fileName, formDisplayName);
        }

        public void DeleteForm(int formID)
        {
            SeferNet.DataLayer.Forms forms = new SeferNet.DataLayer.Forms();

            forms.DeleteForm(formID);
        }
    }
}
