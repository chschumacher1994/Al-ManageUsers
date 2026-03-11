report 50031 "Permission Set Usage"
{
  Caption = 'Permission Set Usage';
  UsageCategory = ReportsAndAnalysis;
  ApplicationArea = All;
  Permissions =
    tabledata "Aggregate Permission Set" = r,
    tabledata "Access Control" = r,
    tabledata "User" = r;

  dataset
  {
    dataitem(AggregatePermSetDataItem; "Aggregate Permission Set")
    {
      DataItemTableView = sorting(Scope, "App ID", "Role ID");
      RequestFilterFields = Scope, "Role ID";

      column(PermSetScope; Scope)
      {
        Caption = 'Scope';
        ToolTip = 'Specifies whether the permission set is a system or tenant permission set.';
        IncludeCaption = true;
      }
      column(PermSetAppID; "App ID")
      {
        Caption = 'App ID';
        ToolTip = 'Specifies the application ID of the extension that owns this permission set.';
        IncludeCaption = true;
      }
      column(PermSetRoleID; "Role ID")
      {
        Caption = 'Permission Set';
        ToolTip = 'Specifies the ID of the permission set.';
        IncludeCaption = true;
      }
      column(PermSetName; Name)
      {
        Caption = 'Permission Set Name';
        ToolTip = 'Specifies the display name of the permission set.';
        IncludeCaption = true;
      }

      dataitem(AccessControlDataItem; "Access Control")
      {
        DataItemLink = "Role ID" = FIELD("Role ID"), Scope = FIELD(Scope), "App ID" = FIELD("App ID");
        DataItemTableView = sorting("User Security ID", "Role ID");

        column(UserSecurityID; "User Security ID")
        {
          Caption = 'User Security ID';
          ToolTip = 'Specifies the unique security ID of the user.';
          IncludeCaption = true;
        }
        column(UserName; UserNameText)
        {
          Caption = 'User Name';
          ToolTip = 'Specifies the logon name of the user.';
        }
        column(AccessCompanyName; "Company Name")
        {
          Caption = 'Company Name';
          ToolTip = 'Specifies the company for which the permission set is assigned, or blank for all companies.';
          IncludeCaption = true;
        }

        trigger OnAfterGetRecord()
        begin
          UserNameText := GetUserName("User Security ID");
        end;
      }
    }
  }

  var
    UserNameText: Text[50];

  local procedure GetUserName(UserSecurityID: Guid): Text[50]
  var
    UserRec: Record "User";
  begin
    UserRec.SetLoadFields("User Name");
    if UserRec.Get(UserSecurityID) then
      exit(UserRec."User Name");
    exit('');
  end;

  labels
  {
    ReportTitleLbl = 'Permission Set Usage';
    PermSetSectionLbl = 'Permission Set';
    UsersSectionLbl = 'Assigned Users';
  }
}
