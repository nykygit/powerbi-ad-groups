# POWERBI AD GROUPS
Automatically create and maintain AD Groups for all Objects in Power BI Report Server.  AD Groups Names will mirror the unique GUIDs found in the Power BI database.  Groups will be assigned permissions to all Power BI Objects that have no inheritance.


## About

Using AD Groups to provide Power BI Report Server Access to view Reports is unavoidable if the users also need to be granted access to SQL DataSources.  A single AD Group can serve as access to the report and the associated datasources, which otherwise would require  duplicate permissions - one list of users explicitly in Power BI Security Tab + one list of users explicity inside SQL Server.  Managing duplicate permissions is simply out of the question.  Duplicate permissions isn't a problem for reports that use a saved credential to access data, but that could change in future so you might as well centralize access control to one system.  It's not like you're going to create a credential for every single report that exists (which would be necessary for Least Privelege best practice), or a master credential which doesn't work in the case of Context Sensitive Queries / Row Based Security.  Long story short, I've managed SSRS, Power BI and SQL Server for long enough to know that AD Security Groups are essential.  With a growing number of reports and developers comes the need for automation.

## Tips on Power BI Report Server Access Control / Governance

Power BI Permissions are often a mix of Inherited vs Broken Inheritance.  This leads to 2 major UX problems:

1. Users ask why they cannot browse visually to a report they have access to.
2. Report Developers ask why they cannot browse to the path to save the report from Power BI Desktop.

Why does this happen?  Well, just because you have access to a Report 3 folders deep, doesn't mean you have access to Folder Level 1 and 2 to navigate there.  Windows File Server Admins have to deal with the exact same issue when it comes to File Shares.  Without going into the details, the solution is simple.  Flatten the hierarchy, create a new folder, name it good, and set permission on the Folder Level.

Another major Access Control issue that is quite bothersome is the fact that adding users to AD Groups requires a reboot.  This is just the way the Windows Session Token works - groups are stored in your session token.  This means every time you grant access via an AD Group you have to ask the user to reboot.  The only solution is to establish pre-existing groups (eg: Department Name or Job Function), and then use Nested Groups when object access is required.  Permissions will effect immediately.  It requires process and coordination.

## How to implement POWERBI-AD-GROUPS?

Here is a basic overview of the process:

1. Create an AD OU that will host the AD Security Groups
2. Create a Managed Service Account and register it on the Server that will run the PowerShell Script via Windows Task Scheduler.
3. Delegate OU access to the Managed Service Account so it can Create Update Delete Security Groups within the OU.
3. Copy the PowerShell file to a local folder on that server and modify the connection string to point to the POWERBI ReportServer database.
4. Configure Windows Task Scheduler to run the PowerShell script as the Managed Service Account.
