<%@ Page Language="C#" ContentType="text/plain" %>
<%
Response.ContentType = "text/plain";

string host = Request.Url.Host.ToLowerInvariant();
if (host == "profiles-dev.umassmed.edu" || host == "profiles-uat.umassmed.edu" || host == "localhost")
{
    // Block all bots from indexing (if they respect robots.txt) for lower envs.  
    Response.Write("User-Agent: *" + Environment.NewLine);
    Response.Write("Disallow: /" + Environment.NewLine);
}
else
{
    // All other envs (including prod) use the original logic added by UCSF.  
    Response.Write("User-Agent: *" + Environment.NewLine);
    Response.Write("Disallow: /shindigorng/" + Environment.NewLine);
    Response.Write("Disallow: /sparql/" + Environment.NewLine);
    Response.Write("Sitemap: " + Profiles.Framework.Utilities.Root.Domain + "/sitemap.xml" + Environment.NewLine);
    Response.Write("Crawl-Delay: 10" + Environment.NewLine);
}
%>
