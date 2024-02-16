using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EntityFrameworkHelper;
using System.Reflection;
using System.Data.Objects;
using System.Data.Entity.Infrastructure;

namespace Clalit.SeferNet.EntitiesBL
{

    //   BL.EntityContextInfo ctxInfo = new BL.EntityContextInfo("Entities",new  DalEx.ConfirmationsEntities)
    public class SeferNetEntityContextInfo : EntityContextInfoBase
    {
        public override ObjectContext CreateContext()
        {
            return (SeferNetEntitiesFactory.GetSeferNetEntities() as IObjectContextAdapter).ObjectContext;
        }

        Assembly _EntitiesAssembly;
        public override Assembly EntitiesAssembly
        {
            get
            {
                if (_EntitiesAssembly == null)
                {
                    //_EntitiesAssembly = Assembly.Load("Entities");
                    _EntitiesAssembly = typeof(Clalit.SeferNet.Entities.vAllDeptDetails).Assembly;
                }

                return _EntitiesAssembly;
            }
        }

        public static SeferNetEntityContextInfo GetSeferNetEntityContextInfo()
        {
            return new SeferNetEntityContextInfo();
        }

    }
}
