using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.EntitiesBL
{
	public  class GetAllDeptDetailsForTemplatesParameters
	{
		public int DeptCode { get; set; }
		public bool IsInternal { get; set; } 
		public string DeptCodesInArea { get; set; } 
	}
}
