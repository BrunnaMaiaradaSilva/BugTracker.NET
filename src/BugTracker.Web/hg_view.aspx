<%@ Page language="C#" CodeBehind="hg_view.aspx.cs" Inherits="btnet.hg_view" AutoEventWireup="True" %>
<!-- #include file = "inc.aspx" -->
<script language="C#" runat="server">


// *****>>>>>> Intentionally not putting copyright in HTML comment, because of text/plain content type.
//Copyright 2002-2011 Corey Trager
//Distributed under the terms of the GNU General Public License


///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{
	Util.do_not_cache(Response);
	Response.ContentType = "text/plain";
	
	var sql = new SQLString(@"
select hgrev_revision, hgrev_bug, hgrev_repository, hgap_path 
from hg_revisions
inner join hg_affected_paths on hgap_hgrev_id = hgrev_id
where hgap_id = @id");

    int hgap_id = Convert.ToInt32(Util.sanitize_integer(Request["revpathid"]));
	sql = sql.AddParameterWithValue("id", Convert.ToString(hgap_id));

	DataRow dr = btnet.DbUtil.get_datarow(sql);

	// check if user has permission for this bug
    int permission_level = Bug.get_bug_permission_level((int)dr["hgrev_bug"], User.Identity);
	if (permission_level ==PermissionLevel.None) {
		Response.Write("You are not allowed to view this item");
		Response.End();
	}
	
	string repo = (string) dr["hgrev_repository"];
	string path = (string) dr["hgap_path"];
	string revision = Request["rev"];
	
    string text = VersionControl.hg_get_file_contents(repo, revision, path);

	Response.Write(text);
}


</script>

