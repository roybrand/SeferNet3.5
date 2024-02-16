<%@ Page Language="C#" AutoEventWireup="true" Inherits="PrintZoomClinic" Codebehind="PrintZoomClinic.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="~/CSS/PrintTemplate.css" rel="STYLESHEET" type="text/Css" />
    
</head>
<body>
    <form id="form1" runat="server">
<table cellpadding="0" cellspacing="0" style="width:100%" dir="rtl">
    <tr>
        <td>
            <table cellpadding="0" cellspacing="0" style="width:100%">
                <tr>
                    <td align="center" style="padding-bottom:5px">
                        <span class="TitleNormal_14">שמ יחידה:</span>&nbsp;
                        <span class="TitleBold_14" id="spDeptName" runat="server">##deptDetails.deptName##</span>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table cellpadding="0" cellspacing="0" class="tblOuter_1" style="width:100%">
                <tr>
                    <td ><!-- 1-st quarter of "DeptName" section -->
                        <table class="tblInner_1" cellpadding="0" cellspacing="0" style="width:100%;" border="0" >
                            <tr style="border-bottom:solid 1px #aaaaaa;">
                                <td style="width:9%" class="tdLable">סוג&nbsp;יחידה:</td>
                                <td style="width:15%" class="tdValue" id="tdUnitTypeName" runat="server">##deptDetails.UnitTypeName##</td>
                                <td style="width:7%" class="tdLable">כחובת:</td>
                                <td style="width:15%" class="tdValue" id="tdSimpleAddress" runat="server">##deptDetails.simpleAddress##</td>
                                <td style="width:7%" class="tdLable">מייל:</td>
                                <td style="width:18%" class="tdValue" id="tdEmail" runat="server">##deptDetails.email##</td>
                                <td style="width:9%" class="tdLable">מחוז:</td>
                                <td style="width:20%" class="tdValue" id="tdDistrictName" runat="server">##deptDetails.districtName##</td>
                            </tr>
                            <tr>
                                <td class="tdLable">שיוך:</td>
                                <td class="tdValue" id="tdSubUnitTypeName" runat="server">##deptDetails.subUnitTypeName##</td>
                                <td class="tdLable">ישוב:</td>
                                <td class="tdValue" id="tdCityName" runat="server">##deptDetails.cityName##</td>
                                <td class="tdLable">תחבורה:</td>
                                <td class="tdValue" id="tdTransportation" runat="server">##deptDetails.transportation##</td>
                                <td class="tdLable">מנהלת:</td>
                                <td class="tdValue" id="tdAdministrationName" runat="server">##deptDetails.AdministrationName##</td>
                            </tr>
                            <tr>
                                <td class="tdLable">קוד&nbsp;סימול:</td>
                                <td class="tdValue" id="tdDeptCode" runat="server">##deptDetails.deptCode##</td>
                                <td class="tdLable">הערה לכתובת:</td>
                                <td class="tdValue" id="tdAddressComment" runat="server">##deptDetails.addressComment##</td>
                                <td class="tdLable">הערכות לנכים:</td>
                                <td class="tdValue" id="tdHandicappedFacilities" runat="server">##deptDetails.handicappedFacilities##</td>
                                <td class="tdLable">כפיפות ניהולית:</td>
                                <td class="tdValue" id="tdSubAdministrationName" runat="server">##deptDetails.subAdministrationName##</td>
                            </tr>
                            <tr>
                                <td class="tdLable">קוד&nbsp;ישן:</td>
                                <td class="tdValue" id="tdSimul228" runat="server">##deptDetails.Simul228##</td>
                                <td class="tdLable">טלפונים:</td>
                                <td class="tdValue" id="tdPhones" runat="server">##deptDetails.phones##</td>
                                <td class="tdLable">&nbsp;</td>
                                <td class="tdValue">&nbsp;</td>
                                <td class="tdLable">מגזר:</td>
                                <td class="tdValue" id="tdPopulationSectorDescription" runat="server">##deptDetails.PopulationSectorDescription##</td>
                            </tr>
                            <tr>
                                <td class="tdLable">ת.&nbsp;עדכון אחרון:</td>
                                <td class="tdValue" id="tdDeptUpdateDate" runat="server">##deptUpdateDate.LastUpdateDateOfDept##</td>
                                <td class="tdLable">פקס:</td>
                                <td class="tdValue" id="tdFaxes" runat="server">##deptDetails.faxes##</td>
                                <td class="tdLable">&nbsp;</td>
                                <td class="tdValue">&nbsp;</td>
                                <td class="tdLable">&nbsp;</td>
                                <td class="tdValue">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td><br /><!-- managers -->
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="4">הנהלה היחידה</td>
                </tr>
                <tr>
                    <td align="center" style="width:25%" class="tdLable_b">מנהל יחידה</td>
                    <td align="center" style="width:25%" class="tdLable_b">מנהלת אדמיניסטרטיבית</td>
                    <td align="center" style="width:25%" class="tdLable_b">מנהלת סיעוד</td>
                    <td align="center" style="width:25%" class="tdLable_b">רוקח אחראי</td>
               </tr>
                <tr>
                    <td id="tdManagerName" runat="server" align="center" class="tdValue_b">##deptDetails.managerName##</td>
                    <td id="tdAdministrativeManagerName" runat="server" align="center" class="tdValue_b">##deptDetails.administrativeManagerName##</td>
                    <td id="tdGeriatricsManagerName" runat="server" align="center" class="tdValue_b">##deptDetails.geriatricsManagerName##</td>
                    <td id="tdPharmacologyManagerName" runat="server" align="center" class="tdValue_b">##deptDetails.pharmacologyManagerName##</td>
               </tr>
                <tr>
                    <td id="tdDeptRemarks" runat="server" colspan="4" class="tdValue_b" style="padding:0px 0px 0px 0xp">
                        <table cellpadding="0" cellspacing="0" style="width:100%">
                           <!-- ##blockbegin--deptRemarks## -->
                            <tr>
                                <td style="width:7%" class="tdLable_b_rem">הערות</td>
                                <td style="width:68%" class="tdLable_b_rem">##deptRemarks.RemarkText##</td>
                                <td style="width:8%" class="tdLable_b_rem">תוקף</td>
                                <td style="width:17%" class="tdLable_b_rem">##deptRemarks.validFrom##&nbsp;&nbsp;##deptRemarks.validTo##</td>
                            </tr>
                           <!-- ##blockend--deptRemarks## -->
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><!-- clinic reception hours -->
        <td id="tdClinicReceptionHours" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="8">שעות פעילות</td>
                </tr>
                <tr>
                    <td align="center" style="width:13%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:13%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:13%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:13%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:13%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:13%" class="tdSubHeader_b">'ו</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">חוה''מ</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ערב חג</td>
               </tr>
               <!-- ##blockbegin--clinicReceptionHours## -->
                <tr>
                    <td id="tdClinicReceptionHours1" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.1##</td>
                    <td id="tdClinicReceptionHours2" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.2##</td>
                    <td id="tdClinicReceptionHours3" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.3##</td>
                    <td id="tdClinicReceptionHours4" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.4##</td>
                    <td id="tdClinicReceptionHours5" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.5##</td>
                    <td id="tdClinicReceptionHours6" runat="server" align="center" style="width:13%" class="tdLable_b">##clinicReceptionHours.6##</td>
                    <td id="tdClinicReceptionHours7" runat="server" align="center" style="width:11%" class="tdLable_b">##clinicReceptionHours.7##</td>
                    <td id="tdClinicReceptionHours8" runat="server" align="center" style="width:11%" class="tdLable_b">##clinicReceptionHours.8##</td>
               </tr>
               <!-- ##blockend--clinicReceptionHours## -->
            </table>
        </td>
    </tr>
    <tr><!-- doctors & reception hours & remarks-->
        <td id="tdDoctorReceptionHours" runat="server"><br />
            <table id="tblDoctorReceptionHours" runat="server" cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="9">רופאים</td>
                </tr>
                <tr>
                    <td align="right" style="width:13%" class="tdSubHeader_b">תחומ שירות</td>
                    <td align="right" style="width:20%" class="tdSubHeader_b">שם</td>
                    <td align="right" style="width:13%" class="tdSubHeader_b">אופן זימון</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--employeeInClinic_doctors## -->
                <tr>
                    <td id="tdReceptionHours_Doctors_ServicesField" runat="server" align="right" class="tdValue_b">##employeeReception_doctors.ServicesField##</td>
                    <td id="tdReceptionHours_Doctors_DoctorsName" runat="server"  align="right" class="tdValue_b">##employeeReception_doctors.DoctorsName##</td>
                    <td id="tdReceptionHours_Doctors_QueueOrderDescriptions" runat="server"  align="right" class="tdLable_b">##employeeReception_doctors.QueueOrderDescriptions##</td>
                    <td id="tdReceptionHours_Doctors_day1" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day1##</td>
                    <td id="tdReceptionHours_Doctors_day2" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day2##</td>
                    <td id="tdReceptionHours_Doctors_day3" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day3##</td>
                    <td id="tdReceptionHours_Doctors_day4" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day4##</td>
                    <td id="tdReceptionHours_Doctors_day5" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day5##</td>
                    <td id="tdReceptionHours_Doctors_day6" runat="server"  align="center" class="tdLable_b_np">##employeeReception_doctors.day6##</td>
                </tr>
                <!-- ##IF employeeReception_doctors.remarks## -->
                <tr>
                    <td colspan="9" id="tdReceptionHours_Doctors_remarks" runat="server"  align="center" class="tdLable_b_dotted">##employeeReception_doctors.remarks##</td>
                </tr>
                <!-- ##ENDIF employeeReception_doctors.remarks## -->
               
               <!-- ##blockend--employeeInClinic_doctors## -->
            </table>
        </td>
    </tr>
    <tr><!-- paraMedic & reception hours & remarks-->
        <td id="tdParaMedicReceptionHours" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="9">פארא-רפואה</td>
                </tr>
                <tr>
                    <td align="right" style="width:13%" class="tdSubHeader_b">תחומ שירות</td>
                    <td align="right" style="width:20%" class="tdSubHeader_b">שם</td>
                    <td align="right" style="width:13%" class="tdSubHeader_b">אופן זימון</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--employeeReception_paraMedics## -->
                <tr>
                    <td align="right" class="tdValue_b">##employeeReception_paraMedics.ServicesField##</td>
                    <td align="right" class="tdValue_b">##employeeReception_paraMedics.DoctorsName##</td>
                    <td align="right" class="tdLable_b">##employeeReception_paraMedics.QueueOrderDescriptions##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day1##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day2##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day3##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day4##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day5##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_paraMedics.day6##</td>
                </tr>
                <tr>
                    <td colspan="9" align="center" class="tdLable_b_dotted">##employeeReception_paraMedics.remarks##</td>
                </tr>
               <!-- ##blockend--employeeInClinic_doctors## -->
            </table>
        </td>
    </tr>
    <tr><!-- geriatrics & reception hours & remarks-->
        <td id="tdGeriatricsReceptionHours" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="9">סיעוד</td>
                </tr>
                <tr>
                    <td align="right" style="width:13%" class="tdSubHeader_b">תחומ שירות</td>
                    <td align="right" style="width:20%" class="tdSubHeader_b">שם</td>
                    <td align="right" style="width:13%" class="tdSubHeader_b">אופן זימון</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--employeeReception_paraMedics## -->
                <tr>
                    <td align="right" class="tdValue_b">##employeeReception_geriatrics.ServicesField##</td>
                    <td align="right" class="tdValue_b">##employeeReception_geriatrics.DoctorsName##</td>
                    <td align="right" class="tdLable_b">##employeeReception_geriatrics.QueueOrderDescriptions##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day1##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day2##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day3##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day4##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day5##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_geriatrics.day6##</td>
                </tr>
                <tr>
                    <td colspan="9" align="center" class="tdLable_b_dotted">##employeeReception_geriatrics.remarks##</td>
                </tr>
               <!-- ##blockend--employeeInClinic_doctors## -->
            </table>
        </td>
    </tr>

    <tr><!-- mangers & reception hours & remarks-->
        <td id="tdManagersReceptionHours" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="9">מנהל</td>
                </tr>
                <tr>
                    <td align="right" style="width:13%" class="tdSubHeader_b">תחומ שירות</td>
                    <td align="right" style="width:20%" class="tdSubHeader_b">שם</td>
                    <td align="right" style="width:13%" class="tdSubHeader_b">אופן זימון</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:9%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--employeeReception_paraMedics## -->
                <tr>
                    <td align="right" class="tdValue_b">##employeeReception_managers.ServicesField##</td>
                    <td align="right" class="tdValue_b">##employeeReception_managers.DoctorsName##</td>
                    <td align="right" class="tdLable_b">##employeeReception_managers.QueueOrderDescriptions##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day1##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day2##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day3##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day4##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day5##</td>
                    <td align="center" class="tdLable_b_np">##employeeReception_managers.day6##</td>
                </tr>
                <tr>
                    <td colspan="9" align="center" class="tdLable_b_dotted">##employeeReception_managers.remarks##</td>
                </tr>
               <!-- ##blockend--employeeReception_paraMedics## -->
            </table>
        </td>
    </tr>
    <tr><!-- services & events -->
        <td id="tdServicesAndEvents" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="8">שירותים ופעילויות</td>
                </tr>
                <tr>
                    <td align="right" style="width:20%" class="tdSubHeader_b">תחום שירות</td>
                    <td align="right" style="width:14%" class="tdSubHeader_b">אופן זימון</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--services## -->
                <tr>
                    <td align="right" class="tdValue_b">##services.ServiceName##</td>
                    <td align="right" class="tdLable_b">##services.QueueOrderDescriptions##</td>
                    <td align="center" class="tdLable_b_np">##services.day1##</td>
                    <td align="center" class="tdLable_b_np">##services.day2##</td>
                    <td align="center" class="tdLable_b_np">##services.day3##</td>
                    <td align="center" class="tdLable_b_np">##services.day4##</td>
                    <td align="center" class="tdLable_b_np">##services.day5##</td>
                    <td align="center" class="tdLable_b_np">##services.day6##</td>
                </tr>
               <!-- ##blockend--services## -->                
               <!-- ##blockbegin--events## -->
               <tr>
                    <td align="right" class="tdValue_b">##events.EventName##</td>
                    <td colspan="7" align="right" class="tdValue_b">
                       הרשמה:&nbsp;##events.registrationStatusDescription##&nbsp;
                       מס` מפגשים:&nbsp;##events.MeetingsNumber##&nbsp;
                       תאריך מפגש ראשון:&nbsp;##events.FirstEventDate##
                    </td>
                </tr>
               <!-- ##blockend--events## -->            
            </table>
        </td>
    </tr>
    <tr><!-- subClinics -->
         <td id="tdSubClinics" runat="server"><br />
            <table cellpadding="0" cellspacing="0" class="tblOuter_2" style="width:100%">
                <tr>
                    <td class="tdHeader_b" align="center" colspan="8">יחידות כפופות</td>
                </tr>
                <tr>
                    <td align="right" style="width:20%" class="tdSubHeader_b">שם יחידה</td>
                    <td align="right" style="width:14%" class="tdSubHeader_b">סוג יחידה</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">א'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ב'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ג'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ד'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">ה'</td>
                    <td align="center" style="width:11%" class="tdSubHeader_b">'ו</td>
               </tr>
               <!-- ##blockbegin--subClinics## -->
                <tr>
                    <td align="right" class="tdValue_b">##deptDetails.deptName##</td>
                    <td align="right" class="tdLable_b">##deptDetails.UnitTypeName##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                    <td align="center" class="tdLable_b_np">##clinicReceptionHours.1##</td>
                </tr>
               <!-- ##blockend--subClinics## -->                
                <tr>
                    <td id="td1" runat="server" colspan="8" class="tdValue_b" style="padding:0px 0px 0px 0xp">
                        <table cellpadding="0" cellspacing="0" style="width:100%">
                           <!-- ##blockbegin--deptRemarks## -->
                            <tr>
                                <td style="width:20%" class="tdLable_b_rem">הערות</td>
                                <td style="width:66%" class="tdLable_b_rem">##deptRemarks.RemarkText##</td>
                                <td style="width:11%" class="tdLable_b_rem">תוקף</td>
                                <td style="width:11%" class="tdLable_b_rem">##deptRemarks.validFrom##&nbsp;&nbsp;##deptRemarks.validTo##</td>
                            </tr>
                           <!-- ##blockend--deptRemarks## -->
                        </table>
                    </td>
                </tr>

            </table>
         </td>   
    </tr>
</table>
    </form>
</body>
</html>
