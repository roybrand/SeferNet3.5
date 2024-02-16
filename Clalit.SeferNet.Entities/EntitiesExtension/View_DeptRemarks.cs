using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.Entities
{
	public partial class View_DeptRemarks
	{
		public string RemarkTextHtmlRow
		{
			get
			{
				string validToStr = string.Empty;
                if (validTo != null)
                {
                    validToStr = validTo.Value.ToString("dd/MM/yyyy");
                    return string.Format("<tr><td style='width:10%' class='tdLable_b_rem'>{0}</td><td style='width:75%' class='tdLable_b_rem' colspan='4'>{1}</td><td style='width:15%;padding-right:5px;' class='tdLable_b_rem_end'>{2}</td></tr>",
                        "הערות", this.RemarkText, " תוקף: &nbsp;&nbsp;" + validToStr);
                }
                else
                { 
                     validToStr = "&nbsp;";
                     return string.Format("<tr><td style='width:10%' class='tdLable_b_rem'>{0}</td><td style='width:75%' class='tdLable_b_rem' colspan='4'>{1}</td><td style='width:15%' class='tdLable_b_rem_end'>{2}</td></tr>",
                        "הערות", this.RemarkText, "&nbsp;");
                }
			}
		}
	}
}
