page 50012 "Perm. Set Exclusion Src. List"
{
  Caption = 'Permission Sets';
  PageType = ListPart;
  SourceTable = "Aggregate Permission Set";
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(PermissionSets)
      {
        field("Role ID"; Rec."Role ID")
        {
          ApplicationArea = All;
          Caption = 'Role ID';
          ToolTip = 'Specifies the identifier of the permission set.';
        }
        field(Name; Rec.Name)
        {
          ApplicationArea = All;
          Caption = 'Name';
          ToolTip = 'Specifies the display name of the permission set.';
        }
        field(Scope; Rec.Scope)
        {
          ApplicationArea = All;
          Caption = 'Scope';
          ToolTip = 'Specifies whether the permission set is a system or tenant permission set.';
        }
        field("App ID"; Rec."App ID")
        {
          ApplicationArea = All;
          Caption = 'App ID';
          ToolTip = 'Specifies the application ID that the permission set belongs to.';
          Visible = false;
        }
        field("App Name"; Rec."App Name")
        {
          ApplicationArea = All;
          Caption = 'App Name';
          ToolTip = 'Specifies the name of the application that the permission set belongs to.';
        }
      }
    }
  }
}
