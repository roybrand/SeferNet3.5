using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Reflection;

namespace SeferNet.Globals
{
    public delegate void OnBLGeneralActionDelegate(BLGeneralActionArg arg);

    public class BLGeneralActionNotifications
    {
        public static event OnBLGeneralActionDelegate OnBLGeneralActionEnter;
        public static event OnBLGeneralActionDelegate OnBLGeneralActionExit;

        public static void RaiseOnBLGeneralActionEnter(Type senderType, string infoMessage)
        {
            BLGeneralActionArg argToReturn = new BLGeneralActionArg();
            argToReturn.SenderType = senderType;
            argToReturn.InfoMessage = infoMessage;

            if (OnBLGeneralActionEnter != null)
            {
                //OnBLGeneralActionEnter(GetBLGeneralActionArg());
                OnBLGeneralActionEnter(argToReturn);
            }
        }

        public static void RaiseOnBLGeneralActionExit(Type senderType, string infoMessage)
        {
            BLGeneralActionArg argToReturn = new BLGeneralActionArg();
            argToReturn.SenderType = senderType;
            argToReturn.InfoMessage = infoMessage;

            if (OnBLGeneralActionExit != null)
            {
                //OnBLGeneralActionExit(GetBLGeneralActionArg());
                OnBLGeneralActionExit(argToReturn);
            }
        }

        //public static BLGeneralActionArg GetBLGeneralActionArg()
        //{
        //    BLGeneralActionArg argToReturn = new BLGeneralActionArg();
        //    StackTrace trace = new StackTrace();
        //    int index = 0;
        //    while (index < trace.FrameCount - 1)
        //    {
        //        MethodBase mb = trace.GetFrame(index).GetMethod();
        //        if (mb.DeclaringType.Assembly != typeof(BLGeneralActionNotifications).Assembly)
        //        {
        //            argToReturn.MethodName = mb.Name;
        //            argToReturn.ClassName = mb.DeclaringType.Name;
        //            break;
        //        }
        //        index++;
        //    }

        //    return argToReturn;
        //}
    }

    public class BLGeneralActionArg
    {
        public string MethodName { get; set; }
        public string ClassName { get; set; }
        public Type SenderType { get; set; }
        public string InfoMessage { get; set; }


        public BLGeneralActionArg()
        {

        }
    }
}
