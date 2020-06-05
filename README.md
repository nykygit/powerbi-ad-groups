# powerbi-ad-groups
Automatically create and maintain AD Groups for all Objects in Power BI Report Server.  AD Groups Names will mirror the unique GUIDs found in the Power BI database.  Groups will be assigned permissions to all Power BI Objects that have no inheritance.


## About

Using AD Groups to provide Power BI Report Server Access to view Reports is unavoidable if the users also need to be granted access to SQL DataSources.  A single AD Group can serve as access to the report and the associated datasources, which otherwise would require  duplicate permissions - one list of users explicitly in Power BI Security Tab + one list of users explicity inside SQL Server.  Managing duplicate permissions is simply out of the question.  Duplicate permissions isn't a problem for reports that use a saved credential to access data, but that could change in future so you might as well centralize access control to one system.  It's not like you're going to create a credential for every single report that exists (which would be necessary for Least Privelege best practice), or a master credential which doesn't work in the case of Context Sensitive Queries / Row Based Security.  Long story short, I've managed SSRS, Power BI and SQL Server for long enough to know that AD Security Groups are essential.  With a growing number of reports and developers comes the need for automation.

## Tips on Power BI Report Server Access Control / Governance

Power BI Permissions are often a mix of Inherited vs Broken Inheritance.  This leads to 2 major UX problems.

1. Users ask why they cannot browse visually to a report they have access to.
2. Report Developers ask why they cannot browse to the path to save the report from Power BI Desktop.

Why does this happen?  Well, just because you have access to a Report 3 folders deep, doesn't mean you have access to Folder Level 1 and 2 to navigate there.  Windows File Server Admins have to deal with the exact same issue when it comes to File Shares.  Without going into the details, the solution is simple.  Flatten the hierarchy, create a new folder, name it good, and set permission on the Folder Level.

Another major Access Control issue that is quite bothersome is the fact that adding users to AD Groups requires a reboot.  This is just the way the Windows Session Token works - groups are stored in your session token.  This means every time you grant access via an AD Group you have to ask the user to reboot.  The only solution is to establish standardized Team Based Groups based on Department or Sub Team names, and then grant that team or department group access within the Report Access Group.  This will effectively make permissions effective immediately.

## How this solution works?

1. We run a PS script via Windows Task Scheduler Job as a Managed Service Account that has access to edit the security groups in an AD OU.
2. We get a list of Objects from the POWER BI REPORT SERVER catalog table.
3. We Create Update and Delete Matching AD Groups and Descriptions based on POWERBI object GUIDs.
4. We automatically Groups to Object Permissions where there is no inheritance, directly in the database.
5. We mark any AD Group Descriptions as INACTIVE if the object has inheritance - to indicate that the group is not being used.
6. This is read only access.  The other roles could be created but Read access generally is the most requested.
