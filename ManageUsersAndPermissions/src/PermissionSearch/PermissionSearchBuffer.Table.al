table 50000 "Permission Search Buffer"
{
  Caption = 'Permission Search Buffer';
  TableType = Temporary;

  fields
  {
    field(1; Scope; Option)
    {
      Caption = 'Scope';
      ToolTip = 'Specifies whether the permission set belongs to the System or Tenant scope.';
      DataClassification = SystemMetadata;
      OptionMembers = System,Tenant;
      OptionCaption = 'System,Tenant';
    }
    field(2; "Role ID"; Code[20])
    {
      Caption = 'Permission Set';
      ToolTip = 'Specifies the ID of the permission set that contains this permission.';
      DataClassification = SystemMetadata;
    }
    field(3; "Object Type"; Option)
    {
      Caption = 'Object Type';
      ToolTip = 'Specifies the type of the object to which the permission applies.';
      DataClassification = SystemMetadata;
      OptionMembers = "Table Data",Table,,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
      OptionCaption = 'Table Data,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,,,,,,,,';
    }
    field(4; "Object ID"; Integer)
    {
      Caption = 'Object ID';
      ToolTip = 'Specifies the ID of the object to which the permission applies.';
      DataClassification = SystemMetadata;
    }
    field(5; "Role Name"; Text[30])
    {
      Caption = 'Name';
      ToolTip = 'Specifies the name of the permission set.';
      DataClassification = SystemMetadata;
    }
    field(6; "App Name"; Text[250])
    {
      Caption = 'Extension Name';
      ToolTip = 'Specifies the name of the extension that defines the permission set.';
      DataClassification = SystemMetadata;
    }
    field(7; "Object Name"; Text[249])
    {
      Caption = 'Object Name';
      ToolTip = 'Specifies the caption of the object to which the permission applies.';
      DataClassification = SystemMetadata;
    }
    field(8; "Read Permission"; Option)
    {
      Caption = 'Read Permission';
      ToolTip = 'Specifies the read access level granted by this permission.';
      DataClassification = SystemMetadata;
      OptionMembers = " ",Yes,Indirect;
      OptionCaption = ' ,Yes,Indirect';
    }
    field(9; "Insert Permission"; Option)
    {
      Caption = 'Insert Permission';
      ToolTip = 'Specifies the insert access level granted by this permission.';
      DataClassification = SystemMetadata;
      OptionMembers = " ",Yes,Indirect;
      OptionCaption = ' ,Yes,Indirect';
    }
    field(10; "Modify Permission"; Option)
    {
      Caption = 'Modify Permission';
      ToolTip = 'Specifies the modify access level granted by this permission.';
      DataClassification = SystemMetadata;
      OptionMembers = " ",Yes,Indirect;
      OptionCaption = ' ,Yes,Indirect';
    }
    field(11; "Delete Permission"; Option)
    {
      Caption = 'Delete Permission';
      ToolTip = 'Specifies the delete access level granted by this permission.';
      DataClassification = SystemMetadata;
      OptionMembers = " ",Yes,Indirect;
      OptionCaption = ' ,Yes,Indirect';
    }
    field(12; "Execute Permission"; Option)
    {
      Caption = 'Execute Permission';
      ToolTip = 'Specifies the execute access level granted by this permission.';
      DataClassification = SystemMetadata;
      OptionMembers = " ",Yes,Indirect;
      OptionCaption = ' ,Yes,Indirect';
    }
  }

  keys
  {
    key(PK; Scope, "Role ID", "Object Type", "Object ID")
    {
      Clustered = true;
    }
    key(ObjectKey; "Object Type", "Object ID") { }
    key(RoleKey; Scope, "Role ID") { }
  }
}
