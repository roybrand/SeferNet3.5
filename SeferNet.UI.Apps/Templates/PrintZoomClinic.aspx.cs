using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SeferNet.BusinessLayer.BusinessObject;
using SeferNet.FacadeLayer;
using System.Data;
using System.Configuration;
using SeferNet.DataLayer;
using Clalit.SeferNet.EntitiesBL;
using Clalit.SeferNet.EntitiesDal;

public partial class PrintZoomClinic : System.Web.UI.Page
{
    DataSet dsDept;

    protected void Page_Load(object sender, EventArgs e)
    {
        //View_DeptDetailsBL view_DeptDetailsBL = new View_DeptDetailsBL();
        //List<vAllDeptDetails> lst = view_DeptDetailsBL.Get_vAllDeptDetailsList("בדיקה 8", null);

        //vAllDeptDetails single = view_DeptDetailsBL.Get_vAllDeptDetails_ByDeptCode(43300);
        //single.managerNameFormatted

        int deptCode = 43300;
        MenusDB menusDB = new MenusDB(ConnectionHandler.ResolveConnStrByLang());
        dsDept = menusDB.GetZoomClinicTemplate(deptCode);

        BindData();
    }
    private void BindData()
    {
        string innerHTML = string.Empty;
        dsDept.Tables[0].TableName = "deptDetails";
        dsDept.Tables[1].TableName = "deptUpdateDate";
        dsDept.Tables[2].TableName = "deptRemarks";
        dsDept.Tables[3].TableName = "clinicReceptionHours";
        dsDept.Tables[4].TableName = "employeeReception_doctors";
        dsDept.Tables[5].TableName = "employeeReception_paraMedics";
        dsDept.Tables[6].TableName = "employeeReception_geriatrics";
        dsDept.Tables[7].TableName = "employeeReception_managers";

        DataRow drDept = dsDept.Tables["deptDetails"].Rows[0];
        DataRow drDeptUpdateDate = dsDept.Tables["deptUpdateDate"].Rows[0];

        //deptDetails
        spDeptName.InnerHtml = drDept["deptName"].ToString();
        tdUnitTypeName.InnerHtml = drDept["UnitTypeName"].ToString();
        tdSubUnitTypeName.InnerHtml = drDept["subUnitTypeName"].ToString();
        tdDeptCode.InnerHtml = drDept["deptCode"].ToString();
        tdSimul228.InnerHtml = drDept["Simul228"].ToString();

        tdDeptUpdateDate.InnerHtml = drDeptUpdateDate[0].ToString(); //deptUpdateDate

        tdSimpleAddress.InnerHtml = drDept["simpleAddress"].ToString();
        tdCityName.InnerHtml = drDept["cityName"].ToString();
        tdAddressComment.InnerHtml = drDept["addressComment"].ToString();
        tdPhones.InnerHtml = drDept["phones"].ToString();
        tdFaxes.InnerHtml = drDept["faxes"].ToString();

        tdEmail.InnerHtml = drDept["email"].ToString();
        tdTransportation.InnerHtml = drDept["transportation"].ToString();
        tdHandicappedFacilities.InnerHtml = drDept["handicappedFacilities"].ToString();

        tdDistrictName.InnerHtml = drDept["districtName"].ToString();
        tdAdministrationName.InnerHtml = drDept["AdministrationName"].ToString();
        tdSubAdministrationName.InnerHtml = drDept["subAdministrationName"].ToString();
        tdPopulationSectorDescription.InnerHtml = drDept["PopulationSectorDescription"].ToString();

        tdManagerName.InnerHtml = drDept["managerName"].ToString();
        tdAdministrativeManagerName.InnerHtml = drDept["administrativeManagerName"].ToString();
        tdGeriatricsManagerName.InnerHtml = drDept["geriatricsManagerName"].ToString();
        tdPharmacologyManagerName.InnerHtml = drDept["pharmacologyManagerName"].ToString();

        innerHTML =
            "<br/><table cellpadding='0' cellspacing='0' class='tblOuter_2' style='width:100%'>" +
            "<tr><td class='tdHeader_b' align='center' colspan='8'>שעות פעילות</td>";
        innerHTML +=
                "<tr><td align='center' style='width:13%' class='tdSubHeader_b'>א'</td>" +
                    "<td align='center' style='width:13%' class='tdSubHeader_b'>ב'</td>" +
                    "<td align='center' style='width:13%' class='tdSubHeader_b'>ג'</td>" +
                    "<td align='center' style='width:13%' class='tdSubHeader_b'>ד'</td>" +
                    "<td align='center' style='width:13%' class='tdSubHeader_b'>ה'</td>" +
                    "<td align='center' style='width:13%' class='tdSubHeader_b'>ו'</td>" +
                    "<td align='center' style='width:11%' class='tdSubHeader_b'>חוה''מ</td>" +
                    "<td align='center' style='width:11%' class='tdSubHeader_b'>ערב חג</td></tr>";

        for (int i = 0; i < dsDept.Tables["clinicReceptionHours"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["1"] + "</td>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["2"] + "</td>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["3"] + "</td>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["4"] + "</td>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["5"] + "</td>" +
                    "<td align='center' style='width:13%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["6"] + "</td>" +
                    "<td align='center' style='width:11%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["8"] + "</td>" +
                    "<td align='center' style='width:11%' class='tdLable_b'>" + dsDept.Tables["clinicReceptionHours"].Rows[i]["9"] + "</td>" +
               "</tr>";
        }
        innerHTML += "</table>";
        tdClinicReceptionHours.InnerHtml = innerHTML;

        //deptRemarks
        innerHTML = "<table cellpadding='0' cellspacing='0' style='width:100%'>";
        for (int i = 0; i < dsDept.Tables["deptRemarks"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td style='width:7%' class='tdLable_b_rem'>הערות</td>" +
                    "<td style='width:68%' class='tdLable_b_rem'>" + dsDept.Tables["deptRemarks"].Rows[i]["RemarkText"] + "</td>" +
                    "<td style='width:8%' class='tdLable_b_rem'>תוקף</td>" +
                    "<td style='width:17%; padding-right:5px' >" + dsDept.Tables["deptRemarks"].Rows[i]["validFrom"] + "&nbsp;&nbsp;" + dsDept.Tables["deptRemarks"].Rows[i]["validTo"] + "</td>" +
                "</tr>";
        }
        innerHTML += "</table>";
        tdDeptRemarks.InnerHtml = innerHTML;

        // doctors
        innerHTML =
            "<br/><table cellpadding='0' cellspacing='0' class='tblOuter_2' style='width:100%'>" +
                "<tr><td class='tdHeader_b' align='center' colspan='9'>רופאים</td></tr>";

        innerHTML += "<tr><td align='right' style='width:13%' class='tdSubHeader_b'>תחומ שירות</td>" +
                    "<td align='right' style='width:20%' class='tdSubHeader_b'>שם</td>" +
                    "<td align='right' style='width:13%' class='tdSubHeader_b'>אופן זימון</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>א'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ב'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ג'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ד'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ה'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>'ו</td></tr>";

        for (int i = 0; i < dsDept.Tables["employeeReception_doctors"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["ServicesField"] + "</td>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["DoctorsName"] + "</td>" +
                    "<td align='right' class='tdLable_b'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["QueueOrderDescriptions"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day1"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day2"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day3"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day4"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day5"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["day6"] + "</td>" +
               "</tr>";
            innerHTML += "<tr><td colspan='9' align='right' class='tdLable_b_dotted'>" + dsDept.Tables["employeeReception_doctors"].Rows[i]["remarks"] + "</td></tr>";
        }
        innerHTML += "</table>";
        tdDoctorReceptionHours.InnerHtml = innerHTML;

    //employeeReception_paraMedics
        innerHTML =
            "<br/><table cellpadding='0' cellspacing='0' class='tblOuter_2' style='width:100%'>" +
                "<tr><td class='tdHeader_b' align='center' colspan='9'>פארא-רפואה</td></tr>";

        innerHTML += "<tr><td align='right' style='width:13%' class='tdSubHeader_b'>תחומ שירות</td>" +
                    "<td align='right' style='width:20%' class='tdSubHeader_b'>שם</td>" +
                    "<td align='right' style='width:13%' class='tdSubHeader_b'>אופן זימון</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>א'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ב'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ג'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ד'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ה'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>'ו</td></tr>";

        for (int i = 0; i < dsDept.Tables["employeeReception_paraMedics"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["ServicesField"] + "</td>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["DoctorsName"] + "</td>" +
                    "<td align='right' class='tdLable_b'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["QueueOrderDescriptions"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day1"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day2"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day3"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day4"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day5"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["day6"] + "</td>" +
               "</tr>";
            innerHTML += "<tr><td colspan='9' align='right' class='tdLable_b_dotted'>" + dsDept.Tables["employeeReception_paraMedics"].Rows[i]["remarks"] + "</td></tr>";
        }
        innerHTML += "</table>";
        tdParaMedicReceptionHours.InnerHtml = innerHTML;

        //employeeReception_Geriatrics
        innerHTML =
            "<br/><table cellpadding='0' cellspacing='0' class='tblOuter_2' style='width:100%'>" +
                "<tr><td class='tdHeader_b' align='center' colspan='9'>סיעוד</td></tr>";

        innerHTML += "<tr><td align='right' style='width:13%' class='tdSubHeader_b'>תחומ שירות</td>" +
                    "<td align='right' style='width:20%' class='tdSubHeader_b'>שם</td>" +
                    "<td align='right' style='width:13%' class='tdSubHeader_b'>אופן זימון</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>א'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ב'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ג'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ד'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ה'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>'ו</td></tr>";

        for (int i = 0; i < dsDept.Tables["employeeReception_geriatrics"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["ServicesField"] + "</td>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["DoctorsName"] + "</td>" +
                    "<td align='right' class='tdLable_b'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["QueueOrderDescriptions"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day1"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day2"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day3"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day4"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day5"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["day6"] + "</td>" +
               "</tr>";
            innerHTML += "<tr><td colspan='9' align='right' class='tdLable_b_dotted'>" + dsDept.Tables["employeeReception_geriatrics"].Rows[i]["remarks"] + "</td></tr>";
        }
        innerHTML += "</table>";
        tdGeriatricsReceptionHours.InnerHtml = innerHTML;

        //employeeReception_Managers
        innerHTML =
            "<br/><table cellpadding='0' cellspacing='0' class='tblOuter_2' style='width:100%'>" +
                "<tr><td class='tdHeader_b' align='center' colspan='9'>מנהל</td></tr>";

        innerHTML += "<tr><td align='right' style='width:13%' class='tdSubHeader_b'>תחומ שירות</td>" +
                    "<td align='right' style='width:20%' class='tdSubHeader_b'>שם</td>" +
                    "<td align='right' style='width:13%' class='tdSubHeader_b'>אופן זימון</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>א'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ב'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ג'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ד'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>ה'</td>" +
                    "<td align='right' style='width:9%' class='tdSubHeader_b'>'ו</td></tr>";

        for (int i = 0; i < dsDept.Tables["employeeReception_managers"].Rows.Count; i++)
        {
            innerHTML +=
                "<tr>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["ServicesField"] + "</td>" +
                    "<td align='right' class='tdValue_b'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["DoctorsName"] + "</td>" +
                    "<td align='right' class='tdLable_b'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["QueueOrderDescriptions"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day1"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day2"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day3"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day4"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day5"] + "</td>" +
                    "<td align='center' class='tdLable_b_np'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["day6"] + "</td>" +
               "</tr>";
            innerHTML += "<tr><td colspan='9' align='right' class='tdLable_b_dotted'>" + dsDept.Tables["employeeReception_managers"].Rows[i]["remarks"] + "</td></tr>";
        }
        innerHTML += "</table>";
        tdManagersReceptionHours.InnerHtml = innerHTML;
    }
}
