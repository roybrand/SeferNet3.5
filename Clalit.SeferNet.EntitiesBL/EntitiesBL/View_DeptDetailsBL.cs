using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.EntitiesDal;
using System.Data.Objects;
using EntityFrameworkHelper;
using Clalit.SeferNet.Entities;
using System.Data.Entity.Infrastructure;

namespace Clalit.SeferNet.EntitiesBL
{
    public class View_DeptDetailsBL
    {
		#region View_DeptDetails
		
		public List<View_DeptDetails> GetAll()
		{
			List<View_DeptDetails> view_DeptDetailsList = null;
			try
			{
				SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();
				//entities.View_DeptDetails.MergeOption = System.Data.Objects.MergeOption.NoTracking;
				var result = from v in entities.View_DeptDetails
							 select v;

				view_DeptDetailsList = result.ToList();

			}
			catch (Exception ex)
			{
				//publish the exception
			}

			return view_DeptDetailsList;
		}

		public List<View_DeptDetails> GetByValues(string columnName, List<int> valueList)
		{
			SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();
			//entities.View_DeptDetails.MergeOption = MergeOption.NoTracking;
            List<View_DeptDetails> view_DeptDetailsList = EntityFrameworkHelper.EntityContextInfoBase.GetListByValues<View_DeptDetails>(columnName, valueList, ((IObjectContextAdapter)entities).ObjectContext, eCreateWhereClauseOption.Normal);

			return view_DeptDetailsList;
		}

		public List<View_DeptDetails> GetByValues(string columnName, List<string> valueList)
		{
			SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();
			//entities.View_DeptDetails.MergeOption = MergeOption.NoTracking;

            List<View_DeptDetails> view_DeptDetailsList = EntityContextInfoBase.GetListByValues<View_DeptDetails>(columnName, valueList, ((IObjectContextAdapter)entities).ObjectContext, eCreateWhereClauseOption.Normal);

			return view_DeptDetailsList;
		} 

		#endregion

		public vAllDeptDetails Get_vAllDeptDetailsForTemplate(GetAllDeptDetailsForTemplatesParameters deptParams)
		{
			vAllDeptDetails vAllDeptDetails = null;

			SeferNetEntities entities = SeferNetEntitiesFactory.GetSeferNetEntities();

			vAllDeptDetails = entities.Get_vAllDeptDetailsForTemplate(deptParams.DeptCode, deptParams.IsInternal, deptParams.DeptCodesInArea);

			return vAllDeptDetails;
		}

		public AllDeptDetailsDataTemplateInfo Get_AllDeptDetailsDataTemplateInfo(GetAllDeptDetailsForTemplatesParameters deptParams)
		{
			return new AllDeptDetailsDataTemplateInfo(Get_vAllDeptDetailsForTemplate(deptParams));
		}
    }
}
