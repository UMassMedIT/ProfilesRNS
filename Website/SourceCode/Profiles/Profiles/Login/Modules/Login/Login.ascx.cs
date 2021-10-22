﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using System.Configuration;

using Profiles.Login.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Login.Modules.Login
{
    public partial class Login : System.Web.UI.UserControl
    {
        Framework.Utilities.SessionManagement sm;
        private bool loginDisabled = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            /* Determine if login is disabled, if so set flag.  */
            string loginDisabledString = ConfigurationManager.AppSettings["Login.Disabled"];
            loginDisabled = (!string.IsNullOrEmpty(loginDisabledString) && (loginDisabledString.ToLower().Equals("true")));
            if (loginDisabled)
            {
                this.cmdSubmit.Visible = false;
                string loginDisabledMessage = ConfigurationManager.AppSettings["Login.Disabled.Message"];
                if (!string.IsNullOrEmpty(loginDisabledMessage))
                {
                    this.lblDisabledMessage.Text = loginDisabledMessage;
                    this.lblDisabledMessage.Visible = true;
                }
                else
                {
                    this.lblDisabledMessage.Text = "Login has been temporarily been disabled during maintenance.";
                }
            }

            if (!IsPostBack)
            {

                if (Request.QueryString["method"].ToString() == "logout")
                {

                    sm.SessionLogout();
                    sm.SessionDestroy();
                    Response.Redirect(Root.Domain + "/search");
                }
                else if (Request.QueryString["method"].ToString() == "login" && sm.Session().PersonID > 0)
                {
                    if (Request.QueryString["redirectto"] == null && Request.QueryString["edit"] == "true")
                    {
                        if (Request.QueryString["editparams"] == null)
                            Response.Redirect(Root.Domain + "/edit/" + sm.Session().NodeID);
                        else
                            Response.Redirect(Root.Domain + "/edit/default.aspx?subject=" + sm.Session().NodeID + "&" + Request.QueryString["editparams"]);
                    }
                    else
                        Response.Redirect(Request.QueryString["redirectto"].ToString());
                }
                else
                {
                    this.txtUserName.Focus();
                }
            }


        }

        public Login() { }
        public Login(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
            sm = new Profiles.Framework.Utilities.SessionManagement();
            LoadAssets();
        }

        protected void cmdSubmit_Click(object sender, EventArgs e)
        {
            if (loginDisabled)
            {
                return;
            }
            Profiles.Login.Utilities.DataIO data = new Profiles.Login.Utilities.DataIO();

            if (Request.QueryString["method"].ToString() == "login")
            {
                Profiles.Login.Utilities.User user = new Profiles.Login.Utilities.User();
                user.UserName = txtUserName.Text.Trim();
                user.Password = txtPassword.Text.Trim();

                if (data.UserLogin(ref user))
                {
                    if (Request.QueryString["edit"] == "true")
                        if (Request.QueryString["editparams"] == null)
                            Response.Redirect(Root.Domain + "/edit/" + sm.Session().NodeID);
                        else
                            Response.Redirect(Root.Domain + "/edit/default.aspx?subject=" + sm.Session().NodeID + "&" + Request.QueryString["editparams"]);
                    else
                        Response.Redirect(Request.QueryString["redirectto"].ToString());

                }
                else
                {
                    lblError.Text = "Login failed, please try again";
                    txtPassword.Text = "";
                    txtPassword.Focus();
                }





            }

        }

        private void LoadAssets()
        {
            HtmlLink Searchcss = new HtmlLink();
            Searchcss.Href = Root.Domain + "/Search/CSS/search.css";
            Searchcss.Attributes["rel"] = "stylesheet";
            Searchcss.Attributes["type"] = "text/css";
            Searchcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Searchcss);

            // Inject script into HEADER
            Literal script = new Literal();
            script.Text = "<script>var _path = \"" + Root.Domain + "\";</script>";
            Page.Header.Controls.Add(script);

            //Response.Write("<script>var _path = \"" + Root.Domain + "\";</script>");


        }
        public string GetURLDomain()
        {
            return Root.Domain;
        }
    }
}