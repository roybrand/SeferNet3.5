using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;

/// <summary>
/// encapsulates web.config definitions
/// </summary>
public static class ConfigHelper
{

    /// <summary>
    /// Returns the path for events files, ending with '\'
    /// </summary>
    /// <returns></returns>
    public static string GetEventFilesStoragePath()
    {
        string path = ConfigurationSettings.AppSettings["EventsFilesPath"];

        if (!path.EndsWith("\\"))
        {
            path += "\\";
        }

        return path;
    }

    public static string GetWebUserName()
    {
        return ConfigurationSettings.AppSettings["WebUserName"];
    }

    public static string GetWebUserPassword()
    {
        return ConfigurationSettings.AppSettings["WebUserPwd"];
    }

    public static string GetWebUserDomain()
    {
        return ConfigurationSettings.AppSettings["WebUserDomain"];
    }

    public static string GetSmtpServer()
    {
        return ConfigurationSettings.AppSettings["smtpServer"];        
    }

    public static string GetMailSenderName()
    {
        return ConfigurationSettings.AppSettings["IncorrectDataMailSenderName"];
    }

    public static string GetFromEmailAddress()
    {
        return ConfigurationSettings.AppSettings["fromEmail"];
    }

    public static string GetDefaultFromEmailAddress()
    {
        return ConfigurationSettings.AppSettings["DefaultFromMail"];
    }
}
