﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.18444
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace SeferNet.BusinessLayer.Properties {
    
    
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.Editors.SettingsDesigner.SettingsSingleFileGenerator", "12.0.0.0")]
    internal sealed partial class Settings : global::System.Configuration.ApplicationSettingsBase {
        
        private static Settings defaultInstance = ((Settings)(global::System.Configuration.ApplicationSettingsBase.Synchronized(new Settings())));
        
        public static Settings Default {
            get {
                return defaultInstance;
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.DefaultSettingValueAttribute("http://localhost/SeferServices/DoctorService.asmx")]
        public string BusinessLayer_doctorsSrv_DoctorService {
            get {
                return ((string)(this["BusinessLayer_doctorsSrv_DoctorService"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.WebServiceUrl)]
        [global::System.Configuration.DefaultSettingValueAttribute("https://wsadmin.clalit.org.il/ADservice/ADservice.asmx")]
        public string BusinessLayer_ADClalit_Service1 {
            get {
                return ((string)(this["BusinessLayer_ADClalit_Service1"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.ConnectionString)]
        [global::System.Configuration.DefaultSettingValueAttribute("Data Source=mksql025\\instance01;Initial Catalog=SeferNetQA;Integrated Security=Tr" +
            "ue")]
        public string SeferNetConnectionString {
            get {
                return ((string)(this["SeferNetConnectionString"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.WebServiceUrl)]
        [global::System.Configuration.DefaultSettingValueAttribute("http://online.clalit.org.il/ClalitCustomersForSuppliers/ClalitCustomersForSupplie" +
            "rs.asmx")]
        public string BusinessLayer_demography_ClalitCustomersForSuppliers {
            get {
                return ((string)(this["BusinessLayer_demography_ClalitCustomersForSuppliers"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.WebServiceUrl)]
        [global::System.Configuration.DefaultSettingValueAttribute("http://online.clalit.org.il:8199/Clalit.ClalitCustomers/ClalitOnLine.asmx")]
        public string BusinessLayer_ClalitOnlineWS_ClalitOnLine {
            get {
                return ((string)(this["BusinessLayer_ClalitOnlineWS_ClalitOnLine"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.WebServiceUrl)]
        [global::System.Configuration.DefaultSettingValueAttribute("http://mkweb111/WSSendFaxes/WSSendFax.asmx")]
        public string BusinessLayer_WSSendMessages_WSFaxSender {
            get {
                return ((string)(this["BusinessLayer_WSSendMessages_WSFaxSender"]));
            }
        }
        
        [global::System.Configuration.ApplicationScopedSettingAttribute()]
        [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [global::System.Configuration.SpecialSettingAttribute(global::System.Configuration.SpecialSetting.WebServiceUrl)]
        [global::System.Configuration.DefaultSettingValueAttribute("http://onlinedemog.clalit.org.il:8199/Clalit.ClalitCustomers/ClalitCustomersServi" +
            "ce.asmx")]
        public string BusinessLayer_il_org_clalit_onlinedemog_ClalitCustomersService {
            get {
                return ((string)(this["BusinessLayer_il_org_clalit_onlinedemog_ClalitCustomersService"]));
            }
        }
    }
}
