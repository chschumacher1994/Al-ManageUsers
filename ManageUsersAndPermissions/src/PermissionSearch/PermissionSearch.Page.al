page 50013 "Permission Search"
{
  Caption = 'Permission Search';
  PageType = Worksheet;
  SourceTable = "Permission Search Buffer";
  SourceTableTemporary = true;
  InsertAllowed = false;
  DeleteAllowed = false;
  ModifyAllowed = false;
  UsageCategory = Administration;
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      group(Filters)
      {
        Caption = 'Filter';

        field(ObjectTypeFilter; ObjectTypeFilter)
        {
          ApplicationArea = All;
          Caption = 'Object Type';
          ToolTip = 'Specifies the type of object to search for in permission sets.';
        }
        field(ObjectIdFilter; ObjectIdFilter)
        {
          ApplicationArea = All;
          Caption = 'Object ID';
          ToolTip = 'Specifies the ID of the object to search for in permission sets.';
        }
        field(IncludeSystemFilter; IncludeSystemFilter)
        {
          ApplicationArea = All;
          Caption = 'Include System Permission Sets';
          ToolTip = 'Specifies whether to also search in system (metadata) permission sets in addition to tenant permission sets.';
        }
      }
      repeater(Results)
      {
        Caption = 'Results';

        field(Scope; Rec.Scope)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies whether the permission set belongs to the System or Tenant scope.';
        }
        field(RoleId; Rec."Role ID")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the ID of the permission set that contains this permission.';
        }
        field(RoleName; Rec."Role Name")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the name of the permission set.';
        }
        field(ObjectType; Rec."Object Type")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the type of the object to which the permission applies.';
        }
        field(ObjectName; Rec."Object Name")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the caption of the object to which the permission applies.';
        }
        field(ObjectId; Rec."Object ID")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the ID of the object to which the permission applies.';
        }
        field(ReadPermission; Rec."Read Permission")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the read access level granted by this permission.';
        }
        field(InsertPermission; Rec."Insert Permission")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the insert access level granted by this permission.';
        }
        field(ModifyPermission; Rec."Modify Permission")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the modify access level granted by this permission.';
        }
        field(DeletePermission; Rec."Delete Permission")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the delete access level granted by this permission.';
        }
        field(ExecutePermission; Rec."Execute Permission")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the execute access level granted by this permission.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(SearchPermissions)
      {
        ApplicationArea = All;
        Caption = 'Search Permissions';
        ToolTip = 'Searches all permission sets for the specified object type and ID.';
        Image = Find;
        Promoted = true;
        PromotedCategory = Process;
        PromotedIsBig = true;

        trigger OnAction()
        var
          PermissionSearchMgt: Codeunit "Permission Search Mgt.";
        begin
          PermissionSearchMgt.SearchPermissions(Rec, ObjectTypeFilter, ObjectIdFilter, IncludeSystemFilter);
          CurrPage.Update(false);
        end;
      }
    }
  }

  var
    ObjectTypeFilter: Option "Table Data",Table,,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
    ObjectIdFilter: Integer;
    IncludeSystemFilter: Boolean;
}
