using Profiles.Framework.Utilities;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
namespace Profiles.Edit.Modules.CustomEditEducationalTraining
{
    public class DataIO : Profiles.Edit.Utilities.DataIO
    {
        /// <summary>
        /// Determine if the user (determined by session) is a full proxy for the org passed.  
        /// </summary>
        /// <param name="organization">Organization to match</param>
        /// <returns>True of the user is proxy for all depts and divisions for the organization passed. Otherwise false.</returns>
        public bool IsUserDefaultProxyForOrganization(string organization)
        {
            bool returnValue = false;
            try
            {
                SessionManagement sm = new SessionManagement();

                string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;
                SqlConnection dbconnection = new SqlConnection(connstr);
                SqlCommand dbcommand = new SqlCommand("[User.Account].[Proxy.GetProxies]");

                SqlDataReader dbreader;
                dbconnection.Open();
                dbcommand.CommandType = CommandType.StoredProcedure;

                dbcommand.Parameters.Add(new SqlParameter("@Operation", "GetDefaultUsersWhoseNodesICanEdit"));
                dbcommand.Parameters.Add(new SqlParameter("@Sessionid", sm.Session().SessionID));

                dbcommand.Connection = dbconnection;
                dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

                string xmlstr = string.Empty;
                while (dbreader.Read())
                {
                    string institution = dbreader["Institution"].ToString();
                    string department = dbreader["Department"].ToString();
                    string division = dbreader["Division"].ToString();
                    int isVisible = Convert.ToInt32(dbreader["IsVisible"]);
                    if ((institution.Equals(organization)
                        && department.Equals("All") && division.Equals("All") && isVisible == 1) || institution.Equals("All"))
                    {
                        returnValue = true;
                        break;
                    }
                }
            }
            catch { }
            return returnValue;

        }
    }
}