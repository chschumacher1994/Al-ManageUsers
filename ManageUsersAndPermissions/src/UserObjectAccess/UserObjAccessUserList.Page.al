page 50015 "User Obj. Access User List"
{
  Caption = 'Users with Access';
  PageType = ListPart;
  SourceTable = "User Obj. Access Buffer";
  SourceTableTemporary = true;
  InsertAllowed = false;
  ModifyAllowed = false;
  DeleteAllowed = false;
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(UserList)
      {
        field(UserName; Rec."User Name")
        {
          ApplicationArea = All;
          Caption = 'User Name';
          ToolTip = 'Specifies the login name of the user who has access to the specified object.';
        }
        field(FullName; Rec."Full Name")
        {
          ApplicationArea = All;
          Caption = 'Full Name';
          ToolTip = 'Specifies the full display name of the user.';
        }
        field(PermissionSetCount; Rec."Permission Set Count")
        {
          ApplicationArea = All;
          Caption = 'Permission Sets';
          ToolTip = 'Specifies the number of permission sets directly assigned to this user that grant access to the specified object.';
        }
        field(HasDirectPermission; Rec."Has Direct Permission")
        {
          ApplicationArea = All;
          Caption = 'Has Direct Permission';
          ToolTip = 'Specifies whether this user has access through at least one directly assigned permission set.';
        }
      }
    }
  }

  trigger OnAfterGetCurrRecord()
  begin
    CurrUserSecurityId := Rec."User Security ID";
  end;

  /// <summary>
  /// Replaces the page's temporary buffer with the provided records and refreshes the list.
  /// </summary>
  /// <param name="NewBuffer">The populated temporary buffer to display.</param>
  procedure SetBuffer(var NewBuffer: Record "User Obj. Access Buffer" temporary)
  begin
    Rec.Reset();
    Rec.DeleteAll();
    if NewBuffer.FindSet() then
      repeat
        Rec := NewBuffer;
        Rec.Insert();
      until NewBuffer.Next() = 0;
    Rec.FindFirst();
    CurrPage.Update(false);
  end;

  /// <summary>
  /// Returns the User Security ID of the currently selected row.
  /// Used by the parent page to pass the value to the permission set list part.
  /// </summary>
  procedure GetCurrentUserSecurityId(): Guid
  begin
    exit(CurrUserSecurityId);
  end;

  var
    CurrUserSecurityId: Guid;
}
