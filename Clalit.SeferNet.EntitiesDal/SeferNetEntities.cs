using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EntityFrameworkHelper;
using System.Data.SqlClient;
using System.Data.Common;
using Microsoft.Data.Extensions;
using System.Data;
using Clalit.SeferNet.Entities;
using System.Data.Entity.Infrastructure;

namespace Clalit.SeferNet.EntitiesDal
{
    public partial class SeferNetEntities
    {
        public static SeferNetEntities GetSeferNetEntitiesByConnectionString(string connectionString)
        {
            return new SeferNetEntities(DBConnectionHelper.GetConnection(connectionString,typeof(SeferNetEntities).Name));
        }

        public SeferNetEntities(DbConnection connection)
            :base(connection,true)
        {

        }
//        --****** deptUpdateDate   ********

//--*****   dept All Details  *****

//----------------------------- Dept Reception Hours 

//  FROM [SeferNet].[dbo].[vDeptReceptionHours]
  
//  --******  dept Remarks   ********

//FROM View_DeptRemarks

//------------ sub unit/dept All Details

//----- sub unit/dept Reception Hours of  

//  FROM [SeferNet].[dbo].[vDeptReceptionHours]

//-----sub depts/units remarks

//FROM View_DeptRemarks

//---------------------- Employee ReceptionHours
//      dbo.vEmployeeReceptionHours

//--employee reception hours remarks

//  FROM [dbo].[vEmployeeReceptionRemarks]

//------------------ Employee services, Experties in the given dept

//  FROM [dbo].[vEmployeeProfessionalDetails]
//  -----------------------------event details

//  FROM [dbo].[vDeptEvents]
 

//------------------------- Services Reception details and Remarks

//  FROM [dbo].[vServicesReceptionWithRemarks]
 
  
//  ------------------------------ QueueOrder - way of order

//  FROM [dbo].[vServicesAndQueueOrder]
 
		public vAllDeptDetails Get_vAllDeptDetailsForTemplate(int deptCode,bool isInternal,	string deptCodesInArea)
		{
			//test
			////bool isInternal,string deptCodesInArea;
			//bool isInternal = false;
			//string deptCodesInArea = "";

			vAllDeptDetails vDeptDetails = null;

			//@IsInternal bit, -- true internal, false external
			//@DeptCodesInArea varchar(max)
			
			SqlParameter recipeIdParameter = new SqlParameter
			{
				ParameterName = "@DeptCode",
				DbType = System.Data.DbType.Int32,
				Value = deptCode
			};

			SqlParameter IsInternalParameter = new SqlParameter
			{
				ParameterName = "@IsInternal",
				DbType = System.Data.DbType.Boolean,
				Value = isInternal
			};

			SqlParameter DeptCodesInAreaParameter = new SqlParameter
			{
				ParameterName = "@DeptCodesInArea",
				DbType = System.Data.DbType.String,
				Value = deptCodesInArea
			};

			DbCommand cmd = ((IObjectContextAdapter)this).ObjectContext.CreateStoreCommand("rpc_GetZoomClinicTemplate", CommandType.StoredProcedure, recipeIdParameter,IsInternalParameter,DeptCodesInAreaParameter);

			using (var connectionScope = cmd.Connection.CreateConnectionScope())
			{
				using (var reader = cmd.ExecuteReader())
				{
				
					//last updated ....				
				    List<vDummy_LastUpdateDateOfRemarks> vDummy_LastUpdateDateOfRemarksList = reader.Materialize<vDummy_LastUpdateDateOfRemarks>().ToList();
					reader.NextResult();
					
					// Materialize the recipe. 
					//var resultvApplyDetails = reader.Materialize<vApplyDetails>().FirstOrDefault();
					vDeptDetails = reader.Materialize<vAllDeptDetails>().FirstOrDefault();

					vDeptDetails.vDummy_LastUpdateDateOfRemarksList = vDummy_LastUpdateDateOfRemarksList;

					if (vDeptDetails != null)
					{
						#region Fills Depts data
						//vDeptReceptionHours

						//depts/units remarks -View_DeptRemarks
						reader.NextResult();
						vDeptDetails.vDeptReceptionHoursList = reader.Materialize<vDeptReceptionHours>().ToList();

						reader.NextResult();
						vDeptDetails.View_DeptRemarksList = reader.Materialize<View_DeptRemarks>().ToList();
						// Reception Hours of sub unit/dept - vDeptReceptionHours 
						#endregion

						#region Fills Sub Depts data
						reader.NextResult();
						vDeptDetails.vSubDept_AllDeptDetailsList = reader.Materialize<vAllDeptDetails>().ToList();


						reader.NextResult();
						vDeptDetails.vSubDept_vDeptReceptionHoursList = reader.Materialize<vDeptReceptionHours>().ToList();

						reader.NextResult();
						vDeptDetails.View_SubDeptRemarksList = reader.Materialize<View_DeptRemarks>().ToList();
						
						#endregion

						#region  Fills In Area Depts data

						reader.NextResult();
						vDeptDetails.vInAreaDept_AllDeptDetailsList = reader.Materialize<vAllDeptDetails>().ToList();


						reader.NextResult();
						vDeptDetails.vInAreaDept_vDeptReceptionHoursList = reader.Materialize<vDeptReceptionHours>().ToList();

						reader.NextResult();
						vDeptDetails.View_InAreaDeptRemarksList = reader.Materialize<View_DeptRemarks>().ToList();

						#endregion

						#region  Fills Employee data
						reader.NextResult();

						vDeptDetails.vEmployeeReceptionHoursList = reader.Materialize<vEmployeeReceptionHours>().ToList();

						reader.NextResult();

						vDeptDetails.vEmployeeReceptionRemarksList = reader.Materialize<vEmployeeReceptionRemarks>().ToList();

						reader.NextResult();

						vDeptDetails.vEmployeeProfessionalDetailsList = reader.Materialize<vEmployeeProfessionalDetails>().ToList();

                        reader.NextResult();

                        vDeptDetails.vEmployeeDeptRemarksList = reader.Materialize<vEmployeeDeptRemarks>().ToList();
						
						#endregion

						#region  Fills Events and Services data

						reader.NextResult();

						vDeptDetails.vDeptEventsList = reader.Materialize<vDeptEvents>().ToList();

                        reader.NextResult();

                        vDeptDetails.vDeptServicesList = reader.Materialize<vDeptServices>().ToList();

						reader.NextResult();

						vDeptDetails.vServicesReceptionWithRemarksList = reader.Materialize<vServicesReceptionWithRemarks>().ToList();

						reader.NextResult();

						vDeptDetails.vServicesAndQueueOrderList = reader.Materialize<vServicesAndQueueOrder>().ToList();

                        reader.NextResult();

                        vDeptDetails.vDeptServicesRemarksList = reader.Materialize<vDeptServicesRemarks>().ToList();

						#endregion
					}
				}
			}

			return vDeptDetails;
		}
    }
}
