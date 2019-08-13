using System;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Fika.Web.Controllers
{
    public class SimulateController : Controller
    {
        // GET: Simulate
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult WebAffinity()
        {
            HttpContext.Response.Cookies.Append("ARRAffinity", Guid.NewGuid().ToString());
            return new RedirectResult("/");
        }

        public ActionResult FrontDoorAffinity()
        {
            HttpContext.Response.Cookies.Append("ASLBSA", Guid.NewGuid().ToString());
            return new RedirectResult("/");
        }

        public ActionResult LoginAsCustomer(string customerId)
        {
            HttpContext.Response.Cookies.Append("CustomerId", customerId);
            return new RedirectResult("/");
        }
    }
}