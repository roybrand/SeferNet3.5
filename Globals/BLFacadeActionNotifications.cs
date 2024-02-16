using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.Reflection;

namespace SeferNet.Globals
{
    public delegate void OnBLFacadeActionDelegate(BLFacadeActionArg arg);

    public class BLFacadeActionNotifications
    {
        public static event OnBLFacadeActionDelegate OnBLFacadeActionEnter;
        public static event OnBLFacadeActionDelegate OnBLFacadeActionExit;

        public static void RaiseOnBLFacadeActionEnter(Type senderType)
        {
            BLFacadeActionArg argToReturn = new BLFacadeActionArg();
            argToReturn.SenderType = senderType;

            if (OnBLFacadeActionEnter != null)
            {
                //OnBLFacadeActionEnter(GetBLFacadeActionArg());
                OnBLFacadeActionEnter(argToReturn);
            }
        }

        public static void RaiseOnBLFacadeActionExit(Type senderType)
        {
            BLFacadeActionArg argToReturn = new BLFacadeActionArg();
            argToReturn.SenderType = senderType;

            if (OnBLFacadeActionExit != null)
            {
                //OnBLFacadeActionExit(GetBLFacadeActionArg());
                OnBLFacadeActionExit(argToReturn);
            }
        }

        //public static BLFacadeActionArg GetBLFacadeActionArg()
        //{
        //    BLFacadeActionArg argToReturn = new BLFacadeActionArg();
        //    StackTrace trace = new StackTrace();
        //    int index = 0;
        //    while (index < trace.FrameCount - 1)
        //    {
        //        MethodBase mb = trace.GetFrame(index).GetMethod();
        //        if (mb.DeclaringType.Assembly != typeof(BLFacadeActionNotifications).Assembly)
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

    public class BLFacadeActionArg
    {
        public string MethodName { get; set; }
        public string ClassName { get; set; }
        public Type SenderType { get; set; }

        public BLFacadeActionArg()
        {

        }
    }
}
