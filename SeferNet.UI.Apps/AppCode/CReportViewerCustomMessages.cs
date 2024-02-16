using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Reporting.WebForms;

namespace Eternity.Astra
{
    public class CReportViewerCustomMessages : IReportViewerMessages
    {
        #region IReportViewerMessages Members

        public string BackButtonToolTip
        {
            get { return ("חזור"); }
        }

        public string ChangeCredentialsText
        {
            get { return ("NNN"); }
        }

        public string ChangeCredentialsToolTip
        {
            get { return ("MMM"); }
        }

        public string CurrentPageTextBoxToolTip
        {
            get { return ("הדוח הנוכחי"); }
        }

        public string DocumentMap
        {
            get { return ("LLL"); }
        }

        public string DocumentMapButtonToolTip
        {
            get { return ("KKK"); }
        }

        public string ExportButtonText
        {
            get { return ("קובץ"); }
        }

        public string ExportButtonToolTip
        {
            get { return ("בחר סוג קובץ"); }
        }

        public string ExportFormatsToolTip
        {
            get { return ("בחר סוג קובץ"); }
        }

        public string FalseValueText
        {
            get { return ("JJJ"); }
        }

        public string FindButtonText
        {
            get { return ("חפש"); }
        }

        public string FindButtonToolTip
        {
            get { return ("חפש"); }
        }

        public string FindNextButtonText
        {
            get { return ("הבא"); }
        }

        public string FindNextButtonToolTip
        {
            get { return ("חפש הבא."); }
        }

        public string FirstPageButtonToolTip
        {
            get { return ("עבור לדוח הראשון"); }
        }

        public string InvalidPageNumber
        {
            get { return ("III"); }
        }

        public string LastPageButtonToolTip
        {
            get { return ("עבור לדוח האחרון"); }
        }

        public string NextPageButtonToolTip
        {
            get { return ("עבור לדוח הבא"); }
        }

        public string NoMoreMatches
        {
            get { return ("HHH"); }
        }

        public string NullCheckBoxText
        {
            get { return ("GGG"); }
        }

        public string NullValueText
        {
            get { return ("FFF"); }
        }

        public string PageOf
        {
            get { return ("מתוך"); }
        }

        public string ParameterAreaButtonToolTip
        {
            get { return ("בחר ערך"); }
        }

        public string PasswordPrompt
        {
            get { return ("DDD"); }
        }

        public string PreviousPageButtonToolTip
        {
            get { return ("עבור לדוח הקודם"); }
        }

        public string PrintButtonToolTip
        {
            get { return ("הדפסה"); }
        }

        public string ProgressText
        {
            get { return ("אנא המתן בסבלנות  הדוח בטעינה"); }
        }

        public string RefreshButtonToolTip
        {
            get { return ("רענן"); }
        }

        public string SearchTextBoxToolTip
        {
            get { return ("חפש"); }
        }

        public string SelectAValue
        {
            get { return ("בחר ערך"); }
        }

        public string SelectAll
        {
            get { return ("הכל"); }
        }

        public string SelectFormat
        {
            get { return ("בחר סוג קובץ"); }
        }

        public string TextNotFound
        {
            get { return ("הדוח לא נמצא"); }
        }

        public string TodayIs
        {
            get { return ("CCC"); }
        }

        public string TrueValueText
        {
            get { return ("BBB"); }
        }

        public string UserNamePrompt
        {
            get { return ("AAA"); }
        }

        public string ViewReportButtonText
        {
            get { return ("הצג דוח"); }
        }

        public string ZoomControlToolTip
        {
            get { return ("זום."); }
        }

        public string ZoomToPageWidth
        {
            get { return ("זום."); }
        }

        public string ZoomToWholePage
        {
            get { return ("זום."); }
        }

        #endregion
    }
}