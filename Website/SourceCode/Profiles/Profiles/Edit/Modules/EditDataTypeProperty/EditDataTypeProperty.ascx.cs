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
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Xsl;
using Profiles.Framework.Utilities;
using Profiles.Profile.Utilities;
using System.Globalization;
using Profiles.Edit.Utilities;
using System.Web.UI.HtmlControls;
using System.Configuration;

namespace Profiles.Edit.Modules.EditDataTypeProperty
{
    public partial class EditDataTypeProperty : BaseModule
    {
        Edit.Utilities.DataIO data;
        Profiles.Profile.Utilities.DataIO propdata;

        private const string RICHTEXTEDITOR_EDITHTMLSOURCE_ENABLE_SETTING = "RichTextEditor.EditHTMLSource.Enable";

        protected void Page_Load(object sender, EventArgs e)
        {
            this.FillPropertyGrid(false);
            if (!IsPostBack)
            {
                Session["pnlInsertProperty.Visible"] = null;
            }

            /* Add TinyMCE Editor */
            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Root.Domain + "/scripts/tinymce/tinymce.min.js");
            Page.Header.Controls.Add(jsscript);

            /* Add client side before postback code to save the editor contents on submit.  */
            if (!ScriptManager.GetCurrent(Page).IsInAsyncPostBack)
            {
                ScriptManager.RegisterOnSubmitStatement(this, this.GetType(), "beforePostback", "beforePostback()");
            } 


        }

        public EditDataTypeProperty() { }
        public EditDataTypeProperty(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            propdata = new Profiles.Profile.Utilities.DataIO();
            data = new Profiles.Edit.Utilities.DataIO();
            string predicateuri = Request.QueryString["predicateuri"].Replace("!", "#");
            this.PropertyListXML = propdata.GetPropertyList(this.BaseData, base.PresentationXML, predicateuri, false, true, false);
            PropertyLabel = this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value;

            if (Request.QueryString["subject"] != null)
                this.SubjectID = Convert.ToInt64(Request.QueryString["subject"]);
            else if (base.GetRawQueryStringItem("subject") != null)
                this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));
            else
                Response.Redirect("~/search");

            litBackLink.Text = "<a href='" + Root.Domain + "/edit/" + this.SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";

            litEditProperty.Text = "Add " + PropertyLabel;

            this.PropertyListXML = propdata.GetPropertyList(this.BaseData, base.PresentationXML, predicateuri, false, true, false);
            this.MaxCardinality = this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@MaxCardinality").Value;
            this.MinCardinality = this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@MinCardinality").Value;

            securityOptions.Subject = this.SubjectID;
            securityOptions.PredicateURI = predicateuri;
            securityOptions.PrivacyCode = Convert.ToInt32(this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDataDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);


        }

        #region Property

        protected void btnEditProperty_OnClick(object sender, EventArgs e)
        {



            if (Session["pnlInsertProperty.Visible"] != null)
            {

                btnInsertCancel_OnClick(sender, e);
                imbAddArror.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session["pnlInsertProperty.Visible"] = null;
            }
            else
            {
                pnlInsertProperty.Visible = true;
                imbAddArror.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";
                Session["pnlInsertProperty.Visible"] = true;

            }
            upnlEditSection.Update();
        }

        protected void GridViewProperty_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            var literalstate = (LiteralState)e.Row.DataItem;
            var ibUp = (ImageButton)e.Row.FindControl("ibUp");
            var ibDown = (ImageButton)e.Row.FindControl("ibDown");
            var lblLabel = (Label)e.Row.FindControl("lblLabel");

            if (e.Row.RowType == DataControlRowType.Header)
            {
                e.Row.Cells[0].Text = PropertyLabel;
            }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                var lnkEdit = (ImageButton)e.Row.Cells[1].FindControl("lnkEdit");
                var lnkDelete = (ImageButton)e.Row.Cells[1].FindControl("lnkDelete");

                if (literalstate.EditDelete == false)
                    lnkDelete.Visible = false;
                if (literalstate.EditExisting == false)
                {
                    lnkEdit.Visible = false;
                }
                else
                {
                    if (ibUp != null)
                        ibUp.CommandArgument = literalstate.Subject.ToString();
                }

                if (lnkDelete != null)
                    lnkDelete.OnClientClick = "Javascript:return confirm('Are you sure you want to delete this " + PropertyLabel + "?');";

                if(lblLabel!=null)
                lblLabel.Text = literalstate.Literal.Replace("\n", "");
            }

            if (e.Row.RowType == DataControlRowType.DataRow && (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
            {
                var editableLiteral = (Literal)e.Row.Cells[0].FindControl("editableLiteral");
                editableLiteral.Text = literalstate.Literal.Trim();
            }
        }

        protected void GridViewProperty_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewProperty.EditIndex = e.NewEditIndex;
            this.FillPropertyGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewProperty_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

            var oldContent = (HiddenField)GridViewProperty.Rows[e.RowIndex].FindControl("oldContentHidden");
            var newContent = (HiddenField)GridViewProperty.Rows[e.RowIndex].FindControl("editNewContentHidden"); 

            data.UpdateLiteral(this.SubjectID, this.PredicateID, data.GetStoreNode(oldContent.Value), data.GetStoreNode(newContent.Value.Replace("\n", "").Trim()), this.PropertyListXML);
            GridViewProperty.EditIndex = -1;
            this.FillPropertyGrid(true);
            upnlEditSection.Update();
        }

        protected void GridViewProperty_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            this.FillPropertyGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewProperty_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewProperty.EditIndex = -1;

            this.FillPropertyGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewProperty_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            Int64 subject = Convert.ToInt64(GridViewProperty.DataKeys[e.RowIndex].Values[0].ToString());
            Int64 predicate = Convert.ToInt64(GridViewProperty.DataKeys[e.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewProperty.DataKeys[e.RowIndex].Values[2].ToString());

            data.DeleteTriple(subject, predicate, _object);

            this.FillPropertyGrid(true);
            upnlEditSection.Update();
        }

        protected void btnInsertCancel_OnClick(object sender, EventArgs e)
        {
            insertNewContentHidden.Value = string.Empty;
            pnlInsertProperty.Visible = false;
            upnlEditSection.Update();
        }

        protected void btnInsert_OnClick(object sender, EventArgs e)
        {
            if (Session["pnlInsertProperty.Visible"] != null)
            {
                data.AddLiteral(this.SubjectID, this.PredicateID, data.GetStoreNode(insertNewContentHidden.Value.Replace("\n", "").Trim()), this.PropertyListXML);

                this.FillPropertyGrid(true);
                pnlInsertProperty.Visible = false;
                Session["pnlInsertProperty.Visible"] = null;
                btnEditProperty_OnClick(sender, e);
                upnlEditSection.Update();
            }
        }

        protected void btnInsertClose_OnClick(object sender, EventArgs e)
        {
            if (Session["pnlInsertProperty.Visible"] != null)
            {
                data.AddLiteral(this.SubjectID, this.PredicateID, data.GetStoreNode(insertNewContentHidden.Value.Replace("\n", "").Trim()), this.PropertyListXML);
                this.FillPropertyGrid(true);
                Session["pnlInsertProperty.Visible"] = null;
                btnInsertCancel_OnClick(sender, e);
            }
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;
            GridViewProperty.EditIndex = -1;

            if (GridViewProperty.Rows.Count > 1)
            {
                Int64 subject = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[0].ToString());
                Int64 predicate = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[1].ToString());
                Int64 _object = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[2].ToString());


                data.MoveTripleDown(subject, predicate, _object);

                this.FillPropertyGrid(true);
            }
            upnlEditSection.Update();


        }

        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;
            GridViewProperty.EditIndex = -1;
            if (GridViewProperty.Rows.Count > 1)
            {
                Int64 subject = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[0].ToString());
                Int64 predicate = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[1].ToString());
                Int64 _object = Convert.ToInt64(GridViewProperty.DataKeys[row.RowIndex].Values[2].ToString());

                data.MoveTripleUp(subject, predicate, _object);
            }
            this.FillPropertyGrid(true);
            upnlEditSection.Update();

        }
        protected void FillPropertyGrid(bool refresh)
        {
            if (refresh)
            {
                base.GetSubjectProfile();
                this.PropertyListXML = propdata.GetPropertyList(this.BaseData, base.PresentationXML, this.PredicateURI, false, true, false);
            }

            List<LiteralState> literalstate = new List<LiteralState>();

            bool editexisting = false;
            bool editaddnew = false;
            bool editdelete = false;

            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditExisting").Value.ToLower() == "true" ||
             this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editexisting = true;

            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditAddNew").Value.ToLower() == "true" ||
                this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editaddnew = true;

            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditDelete").Value.ToLower() == "true" ||
                this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editdelete = true;

            if (!editaddnew)
            {
                btnEditProperty.Visible = false;
                imbAddArror.Visible = false;
            }

            this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));


            this.PredicateURI = Server.UrlDecode(base.GetRawQueryStringItem("predicateuri").Replace("!", "#"));
            this.PredicateID = data.GetStoreNode(this.PredicateURI);

            foreach (XmlNode property in this.PropertyListXML.SelectNodes("PropertyList/PropertyGroup/Property/Network/Connection"))
            {
                literalstate.Add(new LiteralState(this.SubjectID, this.PredicateID, data.GetStoreNode(property.InnerText.Trim()), property.InnerText.Trim(), editexisting, editdelete));
            }

            if (literalstate.Count > 0)
            {

                GridViewProperty.DataSource = literalstate;
                GridViewProperty.DataBind();
                lblNoItems.Visible = false;
                GridViewProperty.Visible = true;


                if (MaxCardinality == literalstate.Count.ToString())
                {
                    imbAddArror.Visible = false;
                    btnEditProperty.Visible = false;
                    btnInsertProperty.Visible = false;                    
                }



            }
            else
            {
                lblNoItems.Visible = true;
                GridViewProperty.Visible = false;
                imbAddArror.Visible = true;
                btnEditProperty.Visible = true;
                if (MaxCardinality == "1")
                { 
                    
                    
                    
                    btnInsertProperty.Visible = false;
                }
                upnlEditSection.Update();
            }


        }
        #endregion

        /// <summary>
        /// Gets the rich text editor toolbar options that are enabled / disabled through configuration.  
        /// </summary>
        /// <returns>Text to append to the toolbar setting in the tinymce editor.</returns>
        public string getHTMLEditorConfigurableToolbarOptions()
        {
            /* Determine whether the code view in the editor should be enabled or disabled. */
            string richTextEditHtmlSourceEnable = ConfigurationManager.AppSettings[RICHTEXTEDITOR_EDITHTMLSOURCE_ENABLE_SETTING];
            if (!string.IsNullOrEmpty(richTextEditHtmlSourceEnable) && richTextEditHtmlSourceEnable.ToLower().Equals("true"))
            {
                return " | code";
            }
            else
            {
                return string.Empty;
            }
        }

        /// <summary>
        /// Get the rich text edtior plugins that are enabled / disabled through configuration.
        /// </summary>
        /// <returns>Text to append to the plugins setting in the tinymce editor.</returns>
        public string getHTMLEditorConfigurablePluginsOptions()
        {
            /* Determine whether the code plugin should be enabled or disabled.  */
            string richTextEditHtmlSourceEnable = ConfigurationManager.AppSettings[RICHTEXTEDITOR_EDITHTMLSOURCE_ENABLE_SETTING];
            if (!string.IsNullOrEmpty(richTextEditHtmlSourceEnable) && richTextEditHtmlSourceEnable.ToLower().Equals("true"))
            {
                return " code";
            }
            else
            {
                return string.Empty;
            }
        }

        public string getConfigSetting(string name)
        {
            return ConfigurationManager.AppSettings[name];
        }

        protected Int64 SubjectID { get; set; }
        private Int64 PredicateID { get; set; }
        private string PredicateURI { get; set; }

        private XmlDocument XMLData { get; set; }

        private XmlDocument PropertyListXML { get; set; }
        private string PropertyLabel { get; set; }
        private string MaxCardinality { get; set; }
        private string MinCardinality { get; set; }


    }
}