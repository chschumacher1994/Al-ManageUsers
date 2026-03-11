report 50030 "User Permission Overview"
{
  Caption = 'User Permission Overview';
  UsageCategory = ReportsAndAnalysis;
  ApplicationArea = All;
  Permissions =
    tabledata "User" = r,
    tabledata "Access Control" = r;

  dataset
  {
    dataitem(UserDataItem; "User")
    {
      DataItemTableView = sorting("User Security ID");
      RequestFilterFields = "User Name", State;

      column(UserSecurityID; "User Security ID")
      {
        Caption = 'User Security ID';
        ToolTip = 'Specifies the unique security ID of the user.';
        IncludeCaption = true;
      }
      column(UserName; "User Name")
      {
        Caption = 'User Name';
        ToolTip = 'Specifies the logon name of the user.';
        IncludeCaption = true;
      }
      column(FullName; "Full Name")
      {
        Caption = 'Full Name';
        ToolTip = 'Specifies the full name of the user.';
        IncludeCaption = true;
      }
      column(State; State)
      {
        Caption = 'State';
        ToolTip = 'Specifies whether the user account is enabled or disabled.';
        IncludeCaption = true;
      }

      dataitem(AccessControlDataItem; "Access Control")
      {
        DataItemLink = "User Security ID" = FIELD("User Security ID");
        DataItemTableView = sorting("User Security ID", "Role ID");

        column(RoleID; "Role ID")
        {
          Caption = 'Permission Set';
          ToolTip = 'Specifies the ID of the permission set assigned to the user.';
          IncludeCaption = true;
        }
        column(RoleName; "Role Name")
        {
          Caption = 'Permission Set Name';
          ToolTip = 'Specifies the display name of the permission set.';
          IncludeCaption = true;
        }
        column(CompanyName; "Company Name")
        {
          Caption = 'Company Name';
          ToolTip = 'Specifies the company for which the permission set is assigned, or blank for all companies.';
          IncludeCaption = true;
        }
        column(Scope; Scope)
        {
          Caption = 'Scope';
          ToolTip = 'Specifies whether the permission set is a system or tenant permission set.';
          IncludeCaption = true;
        }

        trigger OnAfterGetRecord()
        begin
          CalcFields("Role Name");
        end;
      }

      trigger OnPreDataItem()
      begin
        SetLoadFields("User Security ID", "User Name", "Full Name", State);
      end;
    }
  }

  labels
  {
    ReportTitleLbl = 'User Permission Overview';
    UserSectionLbl = 'User';
    PermissionsSectionLbl = 'Permission Sets';
  }
}
