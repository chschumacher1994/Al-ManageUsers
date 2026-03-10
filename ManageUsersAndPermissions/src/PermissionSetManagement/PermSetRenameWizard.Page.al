page 50010 "Perm. Set Rename Wizard"
{
  Caption = 'Rename Permission Set';
  PageType = NavigatePage;
  UsageCategory = None;
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      group(StepIntro)
      {
        Caption = 'Welcome';
        Visible = CurrentStep = 1;

        group(IntroDescription)
        {
          Caption = '';
          InstructionalText = 'This wizard renames a user-defined permission set. All references in permissions, permission set relations, and user access control entries will be updated. The operation runs as a single transaction and will be rolled back if any step fails.';
        }
      }

      group(StepInput)
      {
        Caption = 'Enter Details';
        Visible = CurrentStep = 2;

        field(OldRoleIdField; OldRoleId)
        {
          ApplicationArea = All;
          Caption = 'Current Role ID';
          ToolTip = 'Specifies the Role ID of the user-defined permission set you want to rename.';
          TableRelation = "Aggregate Permission Set"."Role ID" where(Scope = const(Tenant));
        }
        field(NewRoleIdField; NewRoleId)
        {
          ApplicationArea = All;
          Caption = 'New Role ID';
          ToolTip = 'Specifies the new Role ID to assign to the permission set. Must not already exist.';
        }
      }

      group(StepConfirm)
      {
        Caption = 'Confirm Rename';
        Visible = CurrentStep = 3;

        group(ConfirmSummary)
        {
          Caption = 'Summary';
          InstructionalText = 'Review the details below and click Rename to proceed. This operation cannot be undone.';

          field(ConfirmOldRoleId; OldRoleId)
          {
            ApplicationArea = All;
            Caption = 'Current Role ID';
            ToolTip = 'Specifies the current Role ID that will be renamed.';
            Editable = false;
          }
          field(ConfirmNewRoleId; NewRoleId)
          {
            ApplicationArea = All;
            Caption = 'New Role ID';
            ToolTip = 'Specifies the new Role ID that will replace the current one.';
            Editable = false;
          }
        }
        group(ConfirmWarning)
        {
          Caption = 'Warning';
          InstructionalText = 'All permission entries, permission set relations, and user access control entries referencing the current Role ID will be updated. Ensure no other process is modifying these records during the rename.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(ActionBack)
      {
        ApplicationArea = All;
        Caption = 'Back';
        ToolTip = 'Returns to the previous step.';
        Enabled = CurrentStep > 1;
        Image = PreviousRecord;
        InFooterBar = true;

        trigger OnAction()
        begin
          CurrentStep -= 1;
        end;
      }
      action(ActionNext)
      {
        ApplicationArea = All;
        Caption = 'Next';
        ToolTip = 'Proceeds to the next step.';
        Visible = CurrentStep < 3;
        Image = NextRecord;
        InFooterBar = true;

        trigger OnAction()
        begin
          if CurrentStep = 2 then
            ValidateInput();
          CurrentStep += 1;
        end;
      }
      action(ActionRename)
      {
        ApplicationArea = All;
        Caption = 'Rename';
        ToolTip = 'Renames the permission set and updates all references.';
        Visible = CurrentStep = 3;
        Image = Approve;
        InFooterBar = true;

        trigger OnAction()
        begin
          PermSetRenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);
          CurrPage.Close();
        end;
      }
      action(ActionCancel)
      {
        ApplicationArea = All;
        Caption = 'Cancel';
        ToolTip = 'Closes the wizard without making any changes.';
        Image = Cancel;
        InFooterBar = true;

        trigger OnAction()
        begin
          CurrPage.Close();
        end;
      }
    }
  }

  trigger OnOpenPage()
  begin
    CurrentStep := 1;
  end;

  local procedure ValidateInput()
  var
    OldRoleIdBlankErr: Label 'Current Role ID must not be blank.';
    NewRoleIdBlankErr: Label 'New Role ID must not be blank.';
    RoleIdsSameErr: Label 'Current Role ID and New Role ID must be different.';
  begin
    if OldRoleId = '' then
      Error(OldRoleIdBlankErr);
    if NewRoleId = '' then
      Error(NewRoleIdBlankErr);
    if OldRoleId = NewRoleId then
      Error(RoleIdsSameErr);
  end;

  var
    PermSetRenameMgt: Codeunit "Perm. Set Rename Mgt.";
    CurrentStep: Integer;
    OldRoleId: Code[20];
    NewRoleId: Code[20];
}
