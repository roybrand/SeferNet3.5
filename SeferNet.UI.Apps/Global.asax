<%@ Application Language="C#" %>

<script runat="server">

    string IS_SERVICES_INITIALIZED_CONST = "IsServicesInitialized";
    void Application_Start(object sender, EventArgs e)
    {
        // Code that runs on application startup

        Application[IS_SERVICES_INITIALIZED_CONST] = false;

    }

    private static void InitExceptionHandling()
    {
        Matrix.ExceptionHandling.ExceptionHandlingManager.Initialize<EnvironmentInformationController>();
    }

    private static void RegisterServices()
    {
        Clalit.Infrastructure.ServicesManager.ServicesManager.RegisterService
            <Clalit.SeferNet.Services.ErrorMessageService,
            Clalit.Infrastructure.ServiceInterfaces.IErrorMessageService>();
        Clalit.Infrastructure.ServicesManager.ServicesManager.RegisterService
            <Clalit.SeferNet.Services.SaveErrorToDBService,
            Clalit.Infrastructure.ServiceInterfaces.ISaveErrorToDBService>();
        Clalit.Infrastructure.ServicesManager.ServicesManager.RegisterService
          <Clalit.SeferNet.Services.LoggedInUserService,
          Clalit.Infrastructure.ServiceInterfaces.ILoggedInUserService>();

        Clalit.Infrastructure.ServicesManager.ServicesManager.RegisterService
            <Clalit.Infrastructure.CacheManager.CacheManager,
       EntityFrameworkHelper.ICacheWithEFService>();

        //TEST!!! register 2 interfaces for the same service - it's allowed, 1 service is for normal datatables
        // the other is for entites, the cached data is from CacheManager class is static and is shared between both
        //interfaces ( it's load once in the  cacheServiceWithEF.Init call method )
        Clalit.Infrastructure.ServicesManager.ServicesManager.RegisterService
         <Clalit.Infrastructure.CacheManager.CacheManager,
    Clalit.Infrastructure.ServiceInterfaces.ICacheService>();
        //

        EntityFrameworkHelper.ICacheWithEFService cacheServiceWithEF = Clalit.Infrastructure.ServicesManager.ServicesManager.GetService<EntityFrameworkHelper.ICacheWithEFService>();

        cacheServiceWithEF.Init(ConfigurationManager.ConnectionStrings["SeferNetConnectionStringNew"].ConnectionString, Clalit.SeferNet.EntitiesBL.EntityLoadHelper.GetApplicationObjectContextList());

        CacheAction_ServerNotificationManager.ServersNotifierService.Init(cacheServiceWithEF.CacheTablesRefreshingSPDataTable);
    }


    void Application_End(object sender, EventArgs e)
    {
        //  Code that runs on application shutdown
    }

    void Application_Error(object sender, EventArgs e)
    {
        Exception ex = Server.GetLastError().GetBaseException();

        Matrix.ExceptionHandling.ExceptionHandlingManager mgr = new Matrix.ExceptionHandling.ExceptionHandlingManager();
        mgr.Publish(ex);
    }

    void Session_Start(object sender, EventArgs e)
    {
        //we initialize the services once when the first session in the app is opened
        //we DON'T do it in the Application_Start!!!because at that stage the  the user and computer is 
        //not authenticated yet and some of the services need it after ther authentication stage to run
        if (Convert.ToBoolean(Application[IS_SERVICES_INITIALIZED_CONST]) == false)
        {
            Application[IS_SERVICES_INITIALIZED_CONST] = true;

            // Code that runs when a new session is started
            LogHelper.Init();
            InitExceptionHandling();

            RegisterServices();
        }

        Session["SessionStart"] = "Session_Start";
    }

    void Session_End(object sender, EventArgs e)
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

        try
        {
            SeferNet.UI.Apps.CentralLogRegularService.CentralLogServiceClient s = new
                SeferNet.UI.Apps.CentralLogRegularService.CentralLogServiceClient();
            s.ClearSession(Session.SessionID);
        }
        catch (Exception ex)
        {
            PAB.ExceptionHandler.ExceptionLogger.WriteToLog(ex, "Failed to ClearSession with SeferNet.UI.Apps.CentralLogRegularService.CentralLogServiceClient." );
            throw;
        }


        //Session.Mode==
        //FIX
        //the session doesn't exist in this event
        MapCoordinatesClientManager.Instance.RemovePreviousItemOfAppSessionId_IfRequired(Session.SessionID);

    }

    protected void Application_PreSendRequestHeaders()
    {
        Response.Headers.Remove("Server");
        Response.Headers.Remove("X-AspNet-Version");
        Response.Headers.Remove("X-AspNetMvc-Version");
    }


</script>
