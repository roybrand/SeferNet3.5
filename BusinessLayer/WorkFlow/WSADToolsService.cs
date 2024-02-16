using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


#pragma warning disable 1591

namespace ClalitUserManagement.Proxies
{
    using System;
    using System.Web.Services;
    using System.Diagnostics;
    using System.Web.Services.Protocols;
    using System.ComponentModel;
    using System.Xml.Serialization;
    using System.Configuration;
    using OnlineCommon.Proxies;




    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Web.Services.WebServiceBindingAttribute(Name = "WSADToolsServiceSoap", Namespace = "http://tempuri.org/")]
    public partial class AdTools : BaseProxy
    {
        public const string AD_TOOLS_WS = "AdToolsWS_URL";
        private System.Threading.SendOrPostCallback checkGroupMemberOperationCompleted;

        private System.Threading.SendOrPostCallback UserLoginStatusOperationCompleted;

        private System.Threading.SendOrPostCallback GetUserPropertiesOperationCompleted;

        private bool useDefaultCredentialsSetExplicitly;

        /// <remarks/>
        public AdTools()
        {


            if (ConfigurationManager.AppSettings[AD_TOOLS_WS] != null)
            {
                this.Url = ConfigurationManager.AppSettings[AD_TOOLS_WS].ToString();
            }
            else
            {
                throw new ConfigurationErrorsException("AD_TOOLS_WS key not found");
            }

            if ((this.IsLocalFileSystemWebService(this.Url) == true))
            {
                this.UseDefaultCredentials = true;
                this.useDefaultCredentialsSetExplicitly = false;
            }
            else
            {
                this.useDefaultCredentialsSetExplicitly = true;
            }

            SetWSCertificate();
        }

        public new string Url
        {
            get
            {
                return base.Url;
            }
            set
            {
                if ((((this.IsLocalFileSystemWebService(base.Url) == true)
                            && (this.useDefaultCredentialsSetExplicitly == false))
                            && (this.IsLocalFileSystemWebService(value) == false)))
                {
                    base.UseDefaultCredentials = false;
                }
                base.Url = value;
            }
        }

        public new bool UseDefaultCredentials
        {
            get
            {
                return base.UseDefaultCredentials;
            }
            set
            {
                base.UseDefaultCredentials = value;
                this.useDefaultCredentialsSetExplicitly = true;
            }
        }

        /// <remarks/>
        public event checkGroupMemberCompletedEventHandler checkGroupMemberCompleted;

        /// <remarks/>
        public event UserLoginStatusCompletedEventHandler UserLoginStatusCompleted;

        /// <remarks/>
        public event GetUserPropertiesCompletedEventHandler GetUserPropertiesCompleted;

        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/checkGroupMember", RequestNamespace = "http://tempuri.org/", ResponseNamespace = "http://tempuri.org/", Use = System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle = System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public bool checkGroupMember(string m_sAMAccountName, string m_Domain, string m_groupAccountName, string m_GroupDomain, bool m_bCheckSecondLevel)
        {
            object[] results = this.Invoke("checkGroupMember", new object[] {
                        m_sAMAccountName,
                        m_Domain,
                        m_groupAccountName,
                        m_GroupDomain,
                        m_bCheckSecondLevel});
            return ((bool)(results[0]));
        }

        /// <remarks/>
        public void checkGroupMemberAsync(string m_sAMAccountName, string m_Domain, string m_groupAccountName, string m_GroupDomain, bool m_bCheckSecondLevel)
        {
            this.checkGroupMemberAsync(m_sAMAccountName, m_Domain, m_groupAccountName, m_GroupDomain, m_bCheckSecondLevel, null);
        }

        /// <remarks/>
        public void checkGroupMemberAsync(string m_sAMAccountName, string m_Domain, string m_groupAccountName, string m_GroupDomain, bool m_bCheckSecondLevel, object userState)
        {
            if ((this.checkGroupMemberOperationCompleted == null))
            {
                this.checkGroupMemberOperationCompleted = new System.Threading.SendOrPostCallback(this.OncheckGroupMemberOperationCompleted);
            }
            this.InvokeAsync("checkGroupMember", new object[] {
                        m_sAMAccountName,
                        m_Domain,
                        m_groupAccountName,
                        m_GroupDomain,
                        m_bCheckSecondLevel}, this.checkGroupMemberOperationCompleted, userState);
        }

        private void OncheckGroupMemberOperationCompleted(object arg)
        {
            if ((this.checkGroupMemberCompleted != null))
            {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.checkGroupMemberCompleted(this, new checkGroupMemberCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }

        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/UserLoginStatus", RequestNamespace = "http://tempuri.org/", ResponseNamespace = "http://tempuri.org/", Use = System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle = System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public bool UserLoginStatus(string m_sAMAccountName, string m_Domain, string m_Password)
        {
            object[] results = this.Invoke("UserLoginStatus", new object[] {
                        m_sAMAccountName,
                        m_Domain,
                        m_Password});
            return ((bool)(results[0]));
        }

        /// <remarks/>
        public void UserLoginStatusAsync(string m_sAMAccountName, string m_Domain, string m_Password)
        {
            this.UserLoginStatusAsync(m_sAMAccountName, m_Domain, m_Password, null);
        }

        /// <remarks/>
        public void UserLoginStatusAsync(string m_sAMAccountName, string m_Domain, string m_Password, object userState)
        {
            if ((this.UserLoginStatusOperationCompleted == null))
            {
                this.UserLoginStatusOperationCompleted = new System.Threading.SendOrPostCallback(this.OnUserLoginStatusOperationCompleted);
            }
            this.InvokeAsync("UserLoginStatus", new object[] {
                        m_sAMAccountName,
                        m_Domain,
                        m_Password}, this.UserLoginStatusOperationCompleted, userState);
        }

        private void OnUserLoginStatusOperationCompleted(object arg)
        {
            if ((this.UserLoginStatusCompleted != null))
            {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.UserLoginStatusCompleted(this, new UserLoginStatusCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }

        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/GetUserProperties", RequestNamespace = "http://tempuri.org/", ResponseNamespace = "http://tempuri.org/", Use = System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle = System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        [return: System.Xml.Serialization.XmlArrayItemAttribute(IsNullable = false)]
        public UserProperty[] GetUserProperties(string m_userAccountName, string m_domain, object[] m_arrPropNames)
        {
            object[] results = this.Invoke("GetUserProperties", new object[] {
                        m_userAccountName,
                        m_domain,
                        m_arrPropNames});
            return ((UserProperty[])(results[0]));
        }

        /// <remarks/>
        public void GetUserPropertiesAsync(string m_userAccountName, string m_domain, object[] m_arrPropNames)
        {
            this.GetUserPropertiesAsync(m_userAccountName, m_domain, m_arrPropNames, null);
        }

        /// <remarks/>
        public void GetUserPropertiesAsync(string m_userAccountName, string m_domain, object[] m_arrPropNames, object userState)
        {
            if ((this.GetUserPropertiesOperationCompleted == null))
            {
                this.GetUserPropertiesOperationCompleted = new System.Threading.SendOrPostCallback(this.OnGetUserPropertiesOperationCompleted);
            }
            this.InvokeAsync("GetUserProperties", new object[] {
                        m_userAccountName,
                        m_domain,
                        m_arrPropNames}, this.GetUserPropertiesOperationCompleted, userState);
        }

        private void OnGetUserPropertiesOperationCompleted(object arg)
        {
            if ((this.GetUserPropertiesCompleted != null))
            {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.GetUserPropertiesCompleted(this, new GetUserPropertiesCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }

        /// <remarks/>
        public new void CancelAsync(object userState)
        {
            base.CancelAsync(userState);
        }

        private bool IsLocalFileSystemWebService(string url)
        {
            if (((url == null)
                        || (url == string.Empty)))
            {
                return false;
            }
            System.Uri wsUri = new System.Uri(url);
            if (((wsUri.Port >= 1024)
                        && (string.Compare(wsUri.Host, "localHost", System.StringComparison.OrdinalIgnoreCase) == 0)))
            {
                return true;
            }
            return false;
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Xml", "4.0.30319.1")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace = "http://tempuri.org/")]
    public partial class UserProperty
    {

        private string propNameField;

        private string propValueField;

        private string isfoundField;

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string propName
        {
            get
            {
                return this.propNameField;
            }
            set
            {
                this.propNameField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string propValue
        {
            get
            {
                return this.propValueField;
            }
            set
            {
                this.propValueField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlAttributeAttribute()]
        public string isfound
        {
            get
            {
                return this.isfoundField;
            }
            set
            {
                this.isfoundField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    public delegate void checkGroupMemberCompletedEventHandler(object sender, checkGroupMemberCompletedEventArgs e);

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class checkGroupMemberCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs
    {

        private object[] results;

        internal checkGroupMemberCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) :
            base(exception, cancelled, userState)
        {
            this.results = results;
        }

        /// <remarks/>
        public bool Result
        {
            get
            {
                this.RaiseExceptionIfNecessary();
                return ((bool)(this.results[0]));
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    public delegate void UserLoginStatusCompletedEventHandler(object sender, UserLoginStatusCompletedEventArgs e);

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class UserLoginStatusCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs
    {

        private object[] results;

        internal UserLoginStatusCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) :
            base(exception, cancelled, userState)
        {
            this.results = results;
        }

        /// <remarks/>
        public bool Result
        {
            get
            {
                this.RaiseExceptionIfNecessary();
                return ((bool)(this.results[0]));
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    public delegate void GetUserPropertiesCompletedEventHandler(object sender, GetUserPropertiesCompletedEventArgs e);

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.0.30319.1")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class GetUserPropertiesCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs
    {

        private object[] results;

        internal GetUserPropertiesCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) :
            base(exception, cancelled, userState)
        {
            this.results = results;
        }

        /// <remarks/>
        public UserProperty[] Result
        {
            get
            {
                this.RaiseExceptionIfNecessary();
                return ((UserProperty[])(this.results[0]));
            }
        }
    }
}

#pragma warning restore 1591