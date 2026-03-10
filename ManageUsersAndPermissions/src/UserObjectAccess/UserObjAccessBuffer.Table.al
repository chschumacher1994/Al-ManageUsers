table 50001 "User Obj. Access Buffer"
{
  Caption = 'User Object Access Buffer';
  TableType = Temporary;

  fields
  {
    field(1; "User Security ID"; Guid)
    {
      Caption = 'User Security ID';
      ToolTip = 'Specifies the unique security identifier of the user.';
      DataClassification = EndUserPseudonymousIdentifiers;
    }
    field(2; "User Name"; Code[50])
    {
      Caption = 'User Name';
      ToolTip = 'Specifies the login name of the user.';
      DataClassification = EndUserIdentifiableInformation;
    }
    field(3; "Full Name"; Text[80])
    {
      Caption = 'Full Name';
      ToolTip = 'Specifies the full display name of the user.';
      DataClassification = EndUserIdentifiableInformation;
    }
    field(4; State; Option)
    {
      Caption = 'Status';
      ToolTip = 'Specifies whether the user account is currently enabled or disabled.';
      DataClassification = SystemMetadata;
      OptionMembers = Enabled,Disabled;
      OptionCaption = 'Enabled,Disabled';
    }
    field(5; "Permission Set Count"; Integer)
    {
      Caption = 'Permission Sets';
      ToolTip = 'Specifies the number of permission sets directly assigned to this user that contain the searched permission.';
      DataClassification = SystemMetadata;
    }
    field(6; "Has Direct Permission"; Boolean)
    {
      Caption = 'Has Direct Permission';
      ToolTip = 'Specifies whether this user has the permission assigned through at least one directly assigned permission set.';
      DataClassification = SystemMetadata;
    }
  }

  keys
  {
    key(PK; "User Security ID")
    {
      Clustered = true;
    }
    key(UserNameKey; "User Name") { }
    key(StateKey; State, "User Name") { }
  }
}
