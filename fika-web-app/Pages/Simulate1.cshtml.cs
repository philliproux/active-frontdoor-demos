using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Fika.Web.Pages
{
    public class SimulateModel : PageModel
    {
        public void OnGet()
        {
            HttpContext.Response.Cookies.Append("ARRAffinity", Guid.NewGuid().ToString());
        }

        public void OnGetSetAffinity()
        {
            
        }
    }
}