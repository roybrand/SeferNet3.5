using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Clalit.SeferNet.EntitiesDal;
using System.Collections;
using Clalit.SeferNet.GeneratedEnums;
using HtmlTemplateParsing;
using Clalit.SeferNet.Entities;

namespace Clalit.SeferNet.EntitiesBL
{
	/// <summary>
	/// Create html template data from given raw data from the DB, in some cases it creates lists that their field will match exactly 
	/// to the template fields,  and in some cases when possible it will use the raw data as is because it already matches to the template fields
	/// </summary>
	public class AllDeptDetailsDataTemplateInfo : IEntityTemplateInfoDataLoader
	{

		// 
		#region Lists that will populate the HTML template

		/// <summary>
		/// 
		/// </summary>
		private vAllDeptDetails _DeptDetails;

	
		List<EmployeeReceptionTimeInfoExtended> _EmployeeReceptionTimeInfo_DoctorList;
		List<EmployeeReceptionTimeInfoExtended> _EmployeeReceptionTimeInfo_ParaMedicalList;
		List<EmployeeReceptionTimeInfoExtended> _EmployeeReceptionTimeInfo_GeriatricList;
		List<EmployeeReceptionTimeInfoExtended> _EmployeeReceptionTimeInfo_ManagerList;

		List<ServiceReceptionTimeInfoExtended> _ServiceReceptionTimeInfoExtendedList;

		#endregion

		/// <summary>
		/// Prepares all the list that will populates the html template from the given deptDetails object
		/// which contains all the raw data,
		/// 
		/// </summary>
		/// <param name="deptDetails"></param>
		public AllDeptDetailsDataTemplateInfo(vAllDeptDetails deptDetails)
		{

			//***************HTML template data and lists
			_DeptDetails = deptDetails;
			
			_EmployeeReceptionTimeInfo_DoctorList = new List<EmployeeReceptionTimeInfoExtended>();
			_EmployeeReceptionTimeInfo_ParaMedicalList = new List<EmployeeReceptionTimeInfoExtended>();
			_EmployeeReceptionTimeInfo_GeriatricList = new List<EmployeeReceptionTimeInfoExtended>();
			_EmployeeReceptionTimeInfo_ManagerList = new List<EmployeeReceptionTimeInfoExtended>();

			_ServiceReceptionTimeInfoExtendedList = new List<ServiceReceptionTimeInfoExtended>();
			
            //*********************************
	
			#region Employee Professional Details

			foreach (vEmployeeProfessionalDetails item in deptDetails.vEmployeeProfessionalDetailsList)
			{
				EmployeeReceptionTimeInfoExtended rcpInfo = null;

				if (item.EmployeeSectorCode == (int)eEmployeeSector.ParaMedical)
				{
					rcpInfo = SetEmployeeProfessionInfoInList(item, _EmployeeReceptionTimeInfo_ParaMedicalList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Medical)
				{
					rcpInfo = SetEmployeeProfessionInfoInList(item, _EmployeeReceptionTimeInfo_DoctorList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Geriatrics)
				{
					rcpInfo = SetEmployeeProfessionInfoInList(item, _EmployeeReceptionTimeInfo_GeriatricList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Managers)
				{
					rcpInfo = SetEmployeeProfessionInfoInList(item, _EmployeeReceptionTimeInfo_ManagerList);
				}
			}

			#endregion

			#region Employee reception hours info
            
			//reception hours info
			foreach (vEmployeeReceptionHours item in deptDetails.vEmployeeReceptionHoursList)
			{
				EmployeeReceptionTimeInfoExtended rcpInfo = null;

				//item.OpeningHourText
				//item.receptionDay

				//???employeeName
				//???WayOfOrder
				//???ServiceType
                
                if (item.EmployeeSectorCode == (int)eEmployeeSector.ParaMedical)
                {
                    rcpInfo = GetEmployeeReceptionTimeInfo_AddToListIfRequired(item, _EmployeeReceptionTimeInfo_ParaMedicalList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Medical)
                {
                    rcpInfo = GetEmployeeReceptionTimeInfo_AddToListIfRequired(item, _EmployeeReceptionTimeInfo_DoctorList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Geriatrics)
                {
                    rcpInfo = GetEmployeeReceptionTimeInfo_AddToListIfRequired(item, _EmployeeReceptionTimeInfo_GeriatricList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Managers)
                {
                    rcpInfo = GetEmployeeReceptionTimeInfo_AddToListIfRequired(item, _EmployeeReceptionTimeInfo_ManagerList);
                }
                
               
			} 
			#endregion

			#region Employee reception hours remark text
			//reception hours text
			foreach (vEmployeeReceptionRemarks item in deptDetails.vEmployeeReceptionRemarksList)
			{
				EmployeeReceptionTimeInfoExtended rcpInfo = null;

				//item.OpeningHourText
				//item.receptionDay

				//???employeeName
				//???WayOfOrder
				//???ServiceType

				if (item.EmployeeSectorCode == (int)eEmployeeSector.ParaMedical)
				{
					rcpInfo = SetEmployeeReceptionRemarkInfoInList(item, _EmployeeReceptionTimeInfo_ParaMedicalList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Medical)
				{
					rcpInfo = SetEmployeeReceptionRemarkInfoInList(item, _EmployeeReceptionTimeInfo_DoctorList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Geriatrics)
				{
					rcpInfo = SetEmployeeReceptionRemarkInfoInList(item, _EmployeeReceptionTimeInfo_GeriatricList);
				}
				else if (item.EmployeeSectorCode == (int)eEmployeeSector.Managers)
				{
					rcpInfo = SetEmployeeReceptionRemarkInfoInList(item, _EmployeeReceptionTimeInfo_ManagerList);
				}
			} 
			#endregion

            #region Employee remarks 
            //reception hours text
            foreach (vEmployeeDeptRemarks item in deptDetails.vEmployeeDeptRemarksList)
            {
                if (item.EmployeeSectorCode == (int)eEmployeeSector.ParaMedical)
                {
                    SetEmployeeRemarkInfoInList(item, _EmployeeReceptionTimeInfo_ParaMedicalList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Medical)
                {
                    SetEmployeeRemarkInfoInList(item, _EmployeeReceptionTimeInfo_DoctorList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Geriatrics)
                {
                    SetEmployeeRemarkInfoInList(item, _EmployeeReceptionTimeInfo_GeriatricList);
                }
                else if (item.EmployeeSectorCode == (int)eEmployeeSector.Managers)
                {
                    SetEmployeeRemarkInfoInList(item, _EmployeeReceptionTimeInfo_ManagerList);
                }
            }
            #endregion


			#region Services Reception Remarks 
			
            foreach (vDeptServices item in deptDetails.vDeptServicesList)
            {
                //do we need it ?? or there is only the services are unique?
                ServiceReceptionTimeInfoExtended rcpInfo = _ServiceReceptionTimeInfoExtendedList.Find(delegate(ServiceReceptionTimeInfoExtended itemToSearch)
                {
                    return itemToSearch.ServiceCode == item.serviceCode;
                });

                //create new object if required
                if (rcpInfo == null)
                {
                    rcpInfo = new ServiceReceptionTimeInfoExtended(item.serviceCode);
                    _ServiceReceptionTimeInfoExtendedList.Add(rcpInfo);
                }
            }

            foreach (vServicesReceptionWithRemarks item in deptDetails.vServicesReceptionWithRemarksList)
			{
				//do we need it ?? or there is only the services are unique?
				ServiceReceptionTimeInfoExtended rcpInfo = _ServiceReceptionTimeInfoExtendedList.Find(delegate(ServiceReceptionTimeInfoExtended itemToSearch)
				{
					return itemToSearch.ServiceCode == item.serviceCode;
				});

                if (rcpInfo != null)
                {
                    //each ServiceReceptionTimeInfoExtended item can have multiple reception hours 
                    // the unique id it is ServiceCode
                    rcpInfo.AddReceptionHoursInfo(item);
                }
			}

            foreach (vDeptServicesRemarks item in deptDetails.vDeptServicesRemarksList)
            {
                //do we need it ?? or there is only the services are unique?
                ServiceReceptionTimeInfoExtended rcpInfo = _ServiceReceptionTimeInfoExtendedList.Find(delegate(ServiceReceptionTimeInfoExtended itemToSearch)
                {
                    return itemToSearch.ServiceCode == item.ServiceCode;
                });
                if (rcpInfo != null)
                    rcpInfo.ServiceRemarkList.Add(item);


            }

			#endregion

			#region Services Reception queue order
			foreach (vServicesAndQueueOrder item in deptDetails.vServicesAndQueueOrderList)
			{
				SetServiceOrderInfoInList(item, _ServiceReceptionTimeInfoExtendedList);
			}
			#endregion
		}

        //private static void FillReceptionTypeInfo(vAllDeptDetails deptDetails,List<vDeptReceptionHours> receptionHours, DeptReceptionTimeInfo rcpInfo)
        //{
        //    //if (deptDetails.vDeptReceptionHoursList != null)
        //    //{
        //    var result = (from r in receptionHours
        //                      where r.deptCode == deptDetails.deptCode
        //                      select new { r.ReceptionHoursTypeID, r.ReceptionTypeDescription }).Distinct();

        //        List<ReceptionHourTypeInfo> typeList = new List<ReceptionHourTypeInfo>();
        //        foreach (var itemResult in result)
        //        {
        //            typeList.Add(new ReceptionHourTypeInfo
        //            {
        //                ReceptionHoursTypeID = itemResult.ReceptionHoursTypeID.Value,
        //                ReceptionTypeDescription = itemResult.ReceptionTypeDescription,
        //                DeptCode = deptDetails.deptCode
        //            });
        //        }

        //        //reception types
        //        rcpInfo.ReceptionHourTypeInfoList = typeList;
        //    //}
        //}

		#region Sub methods - create the data for the html template from the raw data


		#region Employee information - ProfessionInfo,remarks, reception time


		private EmployeeReceptionTimeInfoExtended SetEmployeeProfessionInfoInList(vEmployeeProfessionalDetails employeeIProfItem, List<EmployeeReceptionTimeInfoExtended> list)
		{
			EmployeeReceptionTimeInfoExtended rcpInfo = list.Find(delegate(EmployeeReceptionTimeInfoExtended itemToSearch)
			{
				return itemToSearch.EmployeeId == employeeIProfItem.employeeID;
			});

			if (rcpInfo == null)
			{
				rcpInfo = new EmployeeReceptionTimeInfoExtended(employeeIProfItem.employeeID);
				list.Add(rcpInfo);
			}

			rcpInfo.SetProfessionInfo(employeeIProfItem);

			return rcpInfo;
		}

		/// <summary>
		/// add the employee EmployeeReceptionTimeInfo to the list if required and returns it
		/// </summary>
		/// <param name="employeeId"></param>
		/// <param name="list"></param>
		/// <returns></returns>
		private EmployeeReceptionTimeInfoExtended GetEmployeeReceptionTimeInfo_AddToListIfRequired(vEmployeeReceptionHours employeeItem, List<EmployeeReceptionTimeInfoExtended> list)
		{
			EmployeeReceptionTimeInfoExtended rcpInfo = list.Find(delegate(EmployeeReceptionTimeInfoExtended itemToSearch)
			{
				return itemToSearch.EmployeeId == employeeItem.EmployeeID;
			});

            if (rcpInfo != null)
                rcpInfo.AddReceptionHoursInfo(employeeItem);

			return rcpInfo;
		}

		private EmployeeReceptionTimeInfoExtended SetEmployeeReceptionRemarkInfoInList(vEmployeeReceptionRemarks employeeIRemarktem, List<EmployeeReceptionTimeInfoExtended> list)
		{
			EmployeeReceptionTimeInfoExtended rcpInfo = list.Find(delegate(EmployeeReceptionTimeInfoExtended itemToSearch)
			{
				return itemToSearch.EmployeeId == employeeIRemarktem.EmployeeID;
			});

            if (rcpInfo != null)
			    rcpInfo.AddReceptionRemarkInfo(employeeIRemarktem);

			return rcpInfo;
		}

        private EmployeeReceptionTimeInfoExtended SetEmployeeRemarkInfoInList(vEmployeeDeptRemarks employeeIRemarktem, List<EmployeeReceptionTimeInfoExtended> list)
        {
            EmployeeReceptionTimeInfoExtended rcpInfo = list.Find(delegate(EmployeeReceptionTimeInfoExtended itemToSearch)
            {
                return itemToSearch.EmployeeId == employeeIRemarktem.EmployeeID;
            });

            if (rcpInfo != null)
                rcpInfo.AddEmployeeRemarkInfo(employeeIRemarktem);

            return rcpInfo;
        }
		
		#endregion

        private ServiceReceptionTimeInfoExtended SetServiceOrderInfoInList(vServicesAndQueueOrder serviceOrderItem, List<ServiceReceptionTimeInfoExtended> list)
        {
            ServiceReceptionTimeInfoExtended rcpInfo = list.Find(delegate(ServiceReceptionTimeInfoExtended itemToSearch)
            {
                return itemToSearch.ServiceCode == serviceOrderItem.serviceCode;
            });

            if (rcpInfo != null)
                rcpInfo.SetServiceInfo(serviceOrderItem);

            return rcpInfo;
        }
		
		#endregion

		/// <summary>
		/// The HtmlTemplateParsing infrastructure ask for each template container 
		/// to assign list with data that will fill the html template field
		/// the list should have respective fields to the template field
		/// </summary>
		/// <param name="tableName"></param>
		/// <returns></returns>
        public IList GetListByKey(string tableName)
        {
            //make an enum??
            IList lst = null;
            lst = new List<object>();

            if (tableName == "singleDeptDetails")
            {
                lst = new List<vAllDeptDetails> { _DeptDetails };
            }
            else if (Enum.IsDefined(typeof(eTemplateFieldsContainer), tableName) == true)
            {
               // lst = new List<object>();
                eTemplateFieldsContainer container = (eTemplateFieldsContainer)Enum.Parse(typeof(eTemplateFieldsContainer), tableName);

                switch (container)
                {
                    case eTemplateFieldsContainer.clinicReceptionHours:
                        {
                            //TODO
                            //lst = _DeptReceptionTimeInfoList;
                        }
                        break;
                    case eTemplateFieldsContainer.deptDetails:
                        {
                            lst = new List<vAllDeptDetails> { _DeptDetails };
                        }
                        break;
                    case eTemplateFieldsContainer.deptEvents:
                        {

                            lst = _DeptDetails.vDeptEventsList;
                            //TO DO vladi
                        }
                        break;
                    case eTemplateFieldsContainer.deptRemarks:
                        {
                            lst = _DeptDetails.View_DeptRemarksList;
                        }
                        break;
                    case eTemplateFieldsContainer.deptServices:
                        {
                            //TO DO vladi
                            lst = _ServiceReceptionTimeInfoExtendedList;
                        }
                        break;
                    case eTemplateFieldsContainer.deptSubClinics:
                        {
                            lst = _DeptDetails.vSubDept_AllDeptDetailsList;
                            //_DeptDetails.vSubDept_AllDeptDetailsList;
                        }
                        break;
                    case eTemplateFieldsContainer.employeeReception:
                        {
                            //TO DO
                        }
                        break;
                    case eTemplateFieldsContainer.employeeReception_doctors:
                        {
                            lst = _EmployeeReceptionTimeInfo_DoctorList;
                        }
                        break;
                    case eTemplateFieldsContainer.employeeReception_geriatrics:
                        {
                            lst = _EmployeeReceptionTimeInfo_GeriatricList;
                        }
                        break;
                    case eTemplateFieldsContainer.employeeReception_managers:
                        {
                            lst = _EmployeeReceptionTimeInfo_ManagerList;
                        }
                        break;
                    case eTemplateFieldsContainer.employeeReception_paraMedics:
                        {
                            lst = _EmployeeReceptionTimeInfo_ParaMedicalList;
                        }
                        break;
                    case eTemplateFieldsContainer.NearbyDepts:
                        {
                            lst = _DeptDetails.vInAreaDept_AllDeptDetailsList;
                        }
                        break;
                    default:
                        break;
                }

            }
            //else
            //{
            //    throw new Exception("This table name " + tableName + " doesn't exist in the TemplateFieldsContainer table, check that the name is correct");
            //}

            return lst;
        }

        public IList GetDataTableByKeyAndParent(string tableName, object entityParent)
        {
            IList retList = null;
            if (tableName == "clinicReceptionHoursTypes")
            {
                vAllDeptDetails dept = entityParent as vAllDeptDetails;
                retList = dept.ReceptionHourTypeInfoList;               
            }
            if (tableName == "typeClinicReceptionHours")
            {
                ReceptionHourTypeInfo receptionType = entityParent as ReceptionHourTypeInfo;
                retList = new List<ReceptionHourTypeInfo> { receptionType };
            }
            if (tableName == "subclinicReceptionHoursTypes")
            {
                vAllDeptDetails dept = entityParent as vAllDeptDetails;
                retList = dept.ReceptionHourTypeInfoList;      
            }
            if (tableName == "typesubclinicReceptionHoursTypes")
            {
                ReceptionHourTypeInfo receptionType = entityParent as ReceptionHourTypeInfo;
                retList = new List<ReceptionHourTypeInfo> { receptionType };
            }
            if (tableName == "nearbyClinicReceptionHoursTypes")
            {
                vAllDeptDetails dept = entityParent as vAllDeptDetails;
                retList = dept.ReceptionHourTypeInfoList;
            }
            if (tableName == "nearbyClinicReceptionHours")
            {
                ReceptionHourTypeInfo receptionType = entityParent as ReceptionHourTypeInfo;
                retList = new List<ReceptionHourTypeInfo> { receptionType };
            }
            
            
            
            //    //type 1
            //    //type 2
            //    //type 3
            //}
            //if (tableName == "typeClinicReceptionHours")
            //{
            //    //this are the children of clinicReceptionHoursTypes
            //    ReceptionHourTypeInfo receptionType =  entityParent as ReceptionHourTypeInfo;
            //     retList = (from d in _DeptReceptionTimeInfoList
            //     where d.DeptCode == receptionType.DeptCode && 
                 
            //     (from r in d.AllReceptionHoursInfoDict
            //     where r.Value.ReceptionHoursTypeID == receptionType.ReceptionHoursTypeID
            //     select r.Key).FirstOrDefault() > 0
            //     //d.AllReceptionHoursInfoDict.ReceptionHoursTypeID == receptionType.ReceptionHoursTypeID
            //     select d
            //     ).ToList();

            //  //     receptionType.DeptCode
            //}
             
            return retList;
        }      

		/// <summary>
		/// in case the The HtmlTemplateParsing infrastructure didn't find  a respective property for the given containerName,templateFieldName
		/// it will ask what's the name of the property in the list to match the given containerName,templateFieldName
		/// </summary>
		/// <param name="containerName"></param>
		/// <param name="templateFieldName"></param>
		/// <returns></returns>
		public string GetDBFieldName(string containerName, string templateFieldName)
		{
            return string.Empty;
		}

      
    }   
}
