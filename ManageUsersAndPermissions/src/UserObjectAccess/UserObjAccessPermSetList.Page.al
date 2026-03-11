page 50016 "User Obj. Access Perm. Sets"
{
  Caption = 'Assigned Permission Sets';
  PageType = ListPart;
  SourceTable = "Access Control";
  InsertAllowed = false;
  ModifyAllowed = false;
  DeleteAllowed = false;
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(PermissionSetList)
      {
        field(UserSecurityId; Rec."User Security ID")
        {
          ApplicationArea = All;
          Caption = 'User Security ID';
          ToolTip = 'Specifies the unique security identifier of the user this permission set is assigned to.';
          Visible = false;
        }
        field(RoleId; Rec."Role ID")
        {
          ApplicationArea = All;
          Caption = 'Permission Set';
          ToolTip = 'Specifies the ID of the permission set assigned to the user.';
        }
        field(RoleName; Rec."Role Name")
        {
          ApplicationArea = All;
          Caption = 'Permission Set Name';
          ToolTip = 'Specifies the display name of the permission set.';
        }
        field(CompanyName; Rec."Company Name")
        {
          ApplicationArea = All;
          Caption = 'Company';
          ToolTip = 'Specifies the company this permission set assignment is limited to. Empty means all companies.';
        }
        field(Scope; Rec.Scope)
        {
          ApplicationArea = All;
          Caption = 'Scope';
          ToolTip = 'Specifies whether the permission set belongs to the System or Tenant scope.';
        }
      }
    }
  }

  /// <summary>
  /// Filters the Access Control list to show only permission sets assigned to the specified user.
  /// </summary>
  /// <param name="UserSecurityId">The security ID of the user whose permission sets should be shown.</param>
  procedure SetUserFilter(UserSecurityId: Guid)
  begin
    Rec.SetLoadFields("User Security ID", "Role ID", "Company Name", Scope, "App ID");
    if IsNullGuid(UserSecurityId) then
      Rec.SetRange("User Security ID")
    else
      Rec.SetRange("User Security ID", UserSecurityId);
    CurrPage.Update(false);
  end;
}
