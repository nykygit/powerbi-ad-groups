# powerbi-ad-groups
Automatically create and maintain AD Groups for all Power BI Objects in Power BI Report Server

======================================================================
About
======================================================================

Using AD Groups to provide Power BI Report Server Access to view Reports is unavoidable if the users also need to be granted access to SQL DataSources.  A single AD Group can serve as access to the report and the associated datasources, which otherwise would require maintaining duplicate permissions - one list explicitly in Power BI Security Tab + one list explicity inside SQL Server.  Managing duplicate permissions is illogical.  Although the duplicate permissions doesn't apply to reports that use a saved credential to access the datasource, you might as well standardize and centralize the method of access control to one system.  It's not like you're going to create a credential for every single report that exists, and a single credential while useful has its share of cons.  Long story short, I've managed SSRS and Power BI Report Server along side SQL Server for long enough to know that groups are essential, and with a growing number of reports comes the need for automation.

======================================================================
Tips on Power BI Report Server Access Control / Governance
======================================================================

Power BI Permissions are often a mix of Inherited vs Broken Inheritance.  This leads to 2 major UX problems.

1. Users ask why they cannot browse visually to a report they have access to.
2. Report Developers ask why they cannot browse to the path to save the report from Power BI Desktop.

Why does this happen?  Well, just because you have access to a Report 3 folders deep, doesn't mean you have access to Folder Level 1 and 2 to navigate there.  Yes, Windows File Server Admins have to deal with the exact same issue when it comes to File Shares.  Without going into the details, the solution is simple.  Flatten the hierarchy, create a new folder, and set permission on the Folder Level.

Another major Access Control issue that is quite bothersome is the fact that adding users to AD Groups requires a reboot / fresh Windows Login Session for the permission to take effect.  This means every time you grant access via an AD Group you have to ask the user to reboot.  The only solution to this is to establish standardized Team Based Groups based on Department or Sub Team names, and then grant that team or department group access within the Report Access Group.  This will effectively make permissions effective immediately.  This is a great solution because quite often people want to share reports with users outside their department.  What this means for governance is that you have to create a folder for them in the Root.  Fortunately this solution helps you out with the rest.

======================================================================
How it works?
======================================================================

1. We run a PS script via Windows Task Scheduler Job as a Managed Service Account that has access to edit the security groups in an AD OU.
2. We get a list of Objects from the POWER BI REPORT SERVER catalog table.
3. We Create Update Delete Matching AD Groups and Descriptions based on POWERBI object GUIDs.  The GUIDs are unique, even if the report gets moved or renamed in another folder.
4. We automatically assign any Groups to Objects where inheritance was broken.
5. We mark any AD Group Descriptions where inheritance not broken as INACTIVE - to indicate that the groups were not assigned POWERBI permissions.
6. This is all about read only access.  we can expand this to distinguish between Content Manager and Browser access.
