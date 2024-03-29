//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.18444
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Resources {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option or rebuild the Visual Studio project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.Web.Application.StronglyTypedResourceProxyBuilder", "12.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class ValidationErrorMessages {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal ValidationErrorMessages() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("Resources.ValidationErrorMessages", global::System.Reflection.Assembly.Load("App_GlobalResources"));
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to *.
        /// </summary>
        internal static string ErrorChar {
            get {
                return ResourceManager.GetString("ErrorChar", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to שדה {0} צריך להיות מספר שלם..
        /// </summary>
        internal static string IntegerOnly_ErrorMess {
            get {
                return ResourceManager.GetString("IntegerOnly_ErrorMess", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to שדה {0} אמור להיות פחות מחמישים אותיות..
        /// </summary>
        internal static string Length50 {
            get {
                return ResourceManager.GetString("Length50", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to שדה {0} מכיל סימן לא חוקי..
        /// </summary>
        internal static string NotValidChar_ErrorMess {
            get {
                return ResourceManager.GetString("NotValidChar_ErrorMess", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to שדה {0} מכיל מילה לא חוקית..
        /// </summary>
        internal static string PreservedWord_ErrorMess {
            get {
                return ResourceManager.GetString("PreservedWord_ErrorMess", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to [א-תa-zA-Z&apos;.`-´\s]*.
        /// </summary>
        internal static string RegexName {
            get {
                return ResourceManager.GetString("RegexName", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to (^(julia)).
        /// </summary>
        internal static string RegexPreservedWords {
            get {
                return ResourceManager.GetString("RegexPreservedWords", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to [א-ת\w&apos;\.&quot; `´\-+\*\(\)\\\/]*.
        /// </summary>
        internal static string RegexSiteName {
            get {
                return ResourceManager.GetString("RegexSiteName", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to [\wא-ת&apos;\.&quot; `-´\-+]*.
        /// </summary>
        internal static string RegexSiteName_old {
            get {
                return ResourceManager.GetString("RegexSiteName_old", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to {0} הוא שדה חובה.
        /// </summary>
        internal static string RequiredField {
            get {
                return ResourceManager.GetString("RequiredField", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to [א-ת\w&apos;\.&quot; `-´\-+\253\254]*.
        /// </summary>
        internal static string String_temp {
            get {
                return ResourceManager.GetString("String_temp", resourceCulture);
            }
        }
    }
}
