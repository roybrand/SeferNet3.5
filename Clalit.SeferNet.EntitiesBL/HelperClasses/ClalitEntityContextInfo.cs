using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using EntityFrameworkHelper;
using System.Reflection;
using System.Data.Objects;

namespace Clalit.SeferNet.EntitiesBL
{

    //   BL.EntityContextInfo ctxInfo = new BL.EntityContextInfo("Entities",new  DalEx.ConfirmationsEntities)
    public class ClalitEntityContextInfo : EntityContextInfoBase
    {
        public override ObjectContext CreateContext()
        {
            return (ClalitEntitiesFactory.GetClalitEntities() as System.Data.Entity.Infrastructure.IObjectContextAdapter).ObjectContext;
        }

        Assembly _EntitiesAssembly;
        public override Assembly EntitiesAssembly
        {
            get
            {
                if (_EntitiesAssembly == null)
                {
                    //_EntitiesAssembly = Assembly.Load("Entities");
                    _EntitiesAssembly = typeof(Clalit.Global.Entities.DIC_MessageInfo).Assembly;
                }

                return _EntitiesAssembly;
            }
        }

    }
}
