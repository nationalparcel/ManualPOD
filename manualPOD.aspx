<%@ Page language="C#" MasterPageFile="~masterurl/default.master"    Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage,Microsoft.SharePoint,Version=12.0.0.0,Culture=neutral,PublicKeyToken=71e9bce111e9429c" meta:progid="SharePoint.WebPartPage.Document" meta:webpartpageexpansion="full" %>
<%@ Assembly Name="HubKey.SharePoint, Version=1.0.0.0, Culture=neutral, PublicKeyToken=f06f494d9d4406b0" %>
<%@ Import Namespace="Microsoft.SharePoint" %>
<%@ Import Namespace="Microsoft.SharePoint.Workflow" %>
<%@ Import Namespace="Microsoft.SharePoint.WebControls" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
<%@ Import Namespace="Microsoft.SharePoint.Utilities" %>
<%@ Import Namespace="Microsoft.SharePoint.Workflow" %>
<%@ Import Namespace="HubKey.SharePoint" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="HubKey.SharePoint.Mapping" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Collections.Specialized" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register tagprefix="roxority_FilterZen" namespace="roxority_FilterZen" assembly="roxority_FilterZen, Version=1.0.0.0, Culture=neutral, PublicKeyToken=68349fdcd3484f01" %>
<%@ Register tagprefix="WebPartPages" namespace="Microsoft.SharePoint.WebPartPages" assembly="Microsoft.SharePoint, Version=12.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register tagprefix="SharePoint" namespace="Microsoft.SharePoint.WebControls" assembly="Microsoft.SharePoint, Version=12.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content ID="Content1" ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<asp:Literal runat="server" ID="literal2">Manual POD</asp:Literal><br /><br />
    <script src="//nplweb.net/nplweb/Scripts/jquery-ui-1.8rc3.custom/js/jquery-1.4.2.min.js" type="text/javascript"></script>
    <script src="//nplweb.net/nplweb/Scripts/jquery.SPServices-0.7.2.min.js" type="text/javascript"></script>
    <asp:Literal runat="server" ID="proNumberLabel">Enter Pro Number</asp:Literal>
	<asp:TextBox CssClass="ms-input" runat="server" ID="proNumberTextBox"></asp:TextBox>
	<asp:Button runat="server" OnClick="restartWorkflow" Text="POD" id="Button1"/>
    
    <script type="text/c#" runat="server">
			public void restartWorkflow(object sender, System.EventArgs e)
			{
				SPSecurity.RunWithElevatedPrivileges(delegate()
				{
					SPContext context = SPContext.GetContext(this.Context);
					SPWeb web = context.Web;
					SPSite site = web.Site;
					SPList list = web.Lists["Shipments"];
					SPQuery query = new SPQuery();
					
					string proNumber = proNumberTextBox.Text;
					query.Query = string.Format( "<Where><Eq><FieldRef Name=\"Pro_x0020_Number\" /><Value Type=\"Text\">{0}</Value></Eq></Where>", proNumber);
					SPListItemCollection searchResaults = list.GetItems(query);
					SPListItem listItem = null;
					SPWorkflowManager manager = site.WorkflowManager;
					foreach( SPListItem item in searchResaults )
					{
						int ID = Convert.ToInt32( item["ID"] );
						listItem = list.GetItemById(ID);
					}
					
					foreach (SPWorkflow workflow in manager.GetItemActiveWorkflows(listItem))
					{
						foreach (SPWorkflowTask t in workflow.Tasks)
						{
							t["Status"] = "Canceled";
							t.Update();
						}
						SPWorkflowManager.CancelWorkflow(workflow);
					
						Guid baseId = new Guid("{FCFFD6D5-F122-429A-87E1-CDAB54E648B5}");
						SPWorkflowAssociation associationTemplate= list.WorkflowAssociations.GetAssociationByBaseID(baseId);
						site.WorkflowManager.StartWorkflow(listItem, associationTemplate, "<root />");
					}
				});	
			}
    </script>
</asp:Content>