report 50032 "Permission Search"
{
  Caption = 'Permission Search';
  UsageCategory = ReportsAndAnalysis;
  ApplicationArea = All;
  Permissions =
    tabledata "Tenant Permission" = r,
    tabledata "Metadata Permission Set" = r;

  dataset
  {
    dataitem(PermSearchBufferDataItem; "Permission Search Buffer")
    {
      DataItemTableView = sorting(Scope, "Role ID", "Object Type", "Object ID");

      column(Scope; Scope)
      {
        Caption = 'Scope';
        ToolTip = 'Specifies whether the permission set is a system or tenant permission set.';
        IncludeCaption = true;
      }
      column(RoleID; "Role ID")
      {
        Caption = 'Permission Set';
        ToolTip = 'Specifies the ID of the permission set that grants access to the object.';
        IncludeCaption = true;
      }
      column(RoleName; "Role Name")
      {
        Caption = 'Permission Set Name';
        ToolTip = 'Specifies the display name of the permission set.';
        IncludeCaption = true;
      }
      column(ObjectType; "Object Type")
      {
        Caption = 'Object Type';
        ToolTip = 'Specifies the type of the object for which access is granted.';
        IncludeCaption = true;
      }
      column(ObjectID; "Object ID")
      {
        Caption = 'Object ID';
        ToolTip = 'Specifies the ID of the object for which access is granted.';
        IncludeCaption = true;
      }
      column(ObjectName; "Object Name")
      {
        Caption = 'Object Name';
        ToolTip = 'Specifies the name of the object for which access is granted.';
        IncludeCaption = true;
      }
      column(ReadPermission; "Read Permission")
      {
        Caption = 'Read';
        ToolTip = 'Specifies the read access level granted by this permission set.';
        IncludeCaption = true;
      }
      column(InsertPermission; "Insert Permission")
      {
        Caption = 'Insert';
        ToolTip = 'Specifies the insert access level granted by this permission set.';
        IncludeCaption = true;
      }
      column(ModifyPermission; "Modify Permission")
      {
        Caption = 'Modify';
        ToolTip = 'Specifies the modify access level granted by this permission set.';
        IncludeCaption = true;
      }
      column(DeletePermission; "Delete Permission")
      {
        Caption = 'Delete';
        ToolTip = 'Specifies the delete access level granted by this permission set.';
        IncludeCaption = true;
      }
      column(ExecutePermission; "Execute Permission")
      {
        Caption = 'Execute';
        ToolTip = 'Specifies the execute access level granted by this permission set.';
        IncludeCaption = true;
      }
      column(AppName; "App Name")
      {
        Caption = 'Extension Name';
        ToolTip = 'Specifies the name of the extension that defines the permission set.';
        IncludeCaption = true;
      }
    }
  }

  requestpage
  {
    SaveValues = true;

    layout
    {
      area(Content)
      {
        group(SearchCriteria)
        {
          Caption = 'Search Criteria';

          field(ObjectTypeFilter; ObjectTypeFilter)
          {
            ApplicationArea = All;
            Caption = 'Object Type';
            ToolTip = 'Specifies the type of object to search for in permission sets.';
            OptionCaption = 'Table Data,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,,,,,,,,';
          }
          field(ObjectIdFilter; ObjectIdFilter)
          {
            ApplicationArea = All;
            Caption = 'Object ID';
            ToolTip = 'Specifies the ID of the object to search for in permission sets.';
          }
          field(IncludeSystem; IncludeSystem)
          {
            ApplicationArea = All;
            Caption = 'Include System Permission Sets';
            ToolTip = 'Specifies whether to include system (metadata) permission sets in the search results.';
          }
        }
      }
    }
  }

  trigger OnPreReport()
  var
    PermissionSearchMgt: Codeunit "Permission Search Mgt.";
    TempPermSearchBuffer: Record "Permission Search Buffer" temporary;
  begin
    PermissionSearchMgt.SearchPermissions(TempPermSearchBuffer, ObjectTypeFilter, ObjectIdFilter, IncludeSystem);
    if TempPermSearchBuffer.FindSet() then
      repeat
        PermSearchBufferDataItem.Init();
        PermSearchBufferDataItem.TransferFields(TempPermSearchBuffer);
        PermSearchBufferDataItem.Insert();
      until TempPermSearchBuffer.Next() = 0;
  end;

  var
    ObjectTypeFilter: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
    ObjectIdFilter: Integer;
    IncludeSystem: Boolean;

  labels
  {
    ReportTitleLbl = 'Permission Search';
    SearchCriteriaLbl = 'Search Criteria';
    ResultsLbl = 'Permission Sets Found';
  }
}
