page 50011 "Perm. Set Exclusion Wizard"
{
  Caption = 'Create Exclusion Wrapper';
  PageType = NavigatePage;
  SourceTable = "Tenant Permission";
  SourceTableTemporary = true;
  InsertAllowed = true;
  DeleteAllowed = true;
  ModifyAllowed = true;

  layout
  {
    area(Content)
    {
      // Step 1 – Source Selection
      group(Step1)
      {
        Caption = 'Step 1 – Select Source Permission Set';
        Visible = CurrentStep = 1;

        group(IntroGroup)
        {
          Caption = 'About this wizard';
          InstructionalText = 'This wizard creates a new tenant permission set that includes the selected source set and excludes a small helper set. Use this approach to restrict specific permissions from an existing permission set without modifying it.';
        }
        field(SourceRoleId; SourceRoleId)
        {
          ApplicationArea = All;
          Caption = 'Source Permission Set';
          ToolTip = 'Specifies the Role ID of the permission set to use as the include source.';
          TableRelation = "Aggregate Permission Set"."Role ID";

          trigger OnValidate()
          begin
            LookupSourceRoleName();
          end;
        }
        field(SourceRoleName; SourceRoleName)
        {
          ApplicationArea = All;
          Caption = 'Source Name';
          ToolTip = 'Specifies the display name of the selected source permission set.';
          Editable = false;
        }
        part(SourceList; "Perm. Set Exclusion Src. List")
        {
          ApplicationArea = All;
          Caption = 'Available Permission Sets';
          UpdatePropagation = Both;
        }
      }

      // Step 2 – New Set Setup
      group(Step2)
      {
        Caption = 'Step 2 – Configure New Wrapper Set';
        Visible = CurrentStep = 2;

        field(NewRoleId; NewRoleId)
        {
          ApplicationArea = All;
          Caption = 'New Role ID';
          ToolTip = 'Specifies the Role ID for the new wrapper permission set. Maximum 20 characters.';

          trigger OnValidate()
          begin
            UpdateExclusionHelperRoleId();
          end;
        }
        field(NewRoleName; NewRoleName)
        {
          ApplicationArea = All;
          Caption = 'New Name';
          ToolTip = 'Specifies the display name for the new wrapper permission set.';
        }
        field(ReplaceAssignments; ReplaceAssignments)
        {
          ApplicationArea = All;
          Caption = 'Replace Assignments';
          ToolTip = 'Specifies whether existing Access Control assignments for the source set should be replaced with assignments to the new wrapper set.';
        }
        field(ExclusionHelperRoleId; ExclusionHelperRoleId)
        {
          ApplicationArea = All;
          Caption = 'Exclusion Helper Role ID';
          ToolTip = 'Specifies the automatically computed Role ID for the exclusion helper set. It is derived from the New Role ID.';
          Editable = false;
        }
        group(ExclusionPermissionsGroup)
        {
          Caption = 'Exclusion Permissions';
          repeater(ExclusionPermLines)
          {
            field("Object Type"; Rec."Object Type")
            {
              ApplicationArea = All;
              Caption = 'Object Type';
              ToolTip = 'Specifies the type of object for which the exclusion permission applies.';
            }
            field("Object ID"; Rec."Object ID")
            {
              ApplicationArea = All;
              Caption = 'Object ID';
              ToolTip = 'Specifies the ID of the object for which the exclusion permission applies.';
            }
            field("Read Permission"; Rec."Read Permission")
            {
              ApplicationArea = All;
              Caption = 'Read';
              ToolTip = 'Specifies the read permission to exclude.';
            }
            field("Insert Permission"; Rec."Insert Permission")
            {
              ApplicationArea = All;
              Caption = 'Insert';
              ToolTip = 'Specifies the insert permission to exclude.';
            }
            field("Modify Permission"; Rec."Modify Permission")
            {
              ApplicationArea = All;
              Caption = 'Modify';
              ToolTip = 'Specifies the modify permission to exclude.';
            }
            field("Delete Permission"; Rec."Delete Permission")
            {
              ApplicationArea = All;
              Caption = 'Delete';
              ToolTip = 'Specifies the delete permission to exclude.';
            }
            field("Execute Permission"; Rec."Execute Permission")
            {
              ApplicationArea = All;
              Caption = 'Execute';
              ToolTip = 'Specifies the execute permission to exclude.';
            }
          }
        }
      }

      // Step 3 – Confirm
      group(Step3)
      {
        Caption = 'Step 3 – Confirm and Create';
        Visible = CurrentStep = 3;

        group(SummaryGroup)
        {
          Caption = 'Summary';
          field(SummarySourceRoleId; SourceRoleId)
          {
            ApplicationArea = All;
            Caption = 'Source Permission Set';
            ToolTip = 'Specifies the source permission set that will be included in the wrapper.';
            Editable = false;
          }
          field(SummarySourceRoleName; SourceRoleName)
          {
            ApplicationArea = All;
            Caption = 'Source Name';
            ToolTip = 'Specifies the display name of the source permission set.';
            Editable = false;
          }
          field(SummaryNewRoleId; NewRoleId)
          {
            ApplicationArea = All;
            Caption = 'New Wrapper Role ID';
            ToolTip = 'Specifies the Role ID of the new wrapper permission set to create.';
            Editable = false;
          }
          field(SummaryNewRoleName; NewRoleName)
          {
            ApplicationArea = All;
            Caption = 'New Wrapper Name';
            ToolTip = 'Specifies the display name of the new wrapper permission set.';
            Editable = false;
          }
          field(SummaryHelperRoleId; ExclusionHelperRoleId)
          {
            ApplicationArea = All;
            Caption = 'Exclusion Helper Role ID';
            ToolTip = 'Specifies the Role ID of the exclusion helper set that will be created.';
            Editable = false;
          }
          field(SummaryExclPermCount; GetExclusionPermCount())
          {
            ApplicationArea = All;
            Caption = 'Exclusion Permissions';
            ToolTip = 'Specifies the number of permission entries that will be added to the exclusion helper set.';
            Editable = false;
          }
          field(SummaryReplaceAssignments; ReplaceAssignments)
          {
            ApplicationArea = All;
            Caption = 'Replace Assignments';
            ToolTip = 'Specifies whether Access Control assignments for the source set will be replaced.';
            Editable = false;
          }
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
        Enabled = CurrentStep > 1;
        Image = PreviousRecord;
        InFooterBar = true;
        ToolTip = 'Go back to the previous step.';

        trigger OnAction()
        begin
          CurrentStep -= 1;
        end;
      }
      action(ActionNext)
      {
        ApplicationArea = All;
        Caption = 'Next';
        Enabled = CurrentStep < 3;
        Image = NextRecord;
        InFooterBar = true;
        ToolTip = 'Proceed to the next step.';

        trigger OnAction()
        begin
          ValidateCurrentStep();
          CurrentStep += 1;
        end;
      }
      action(ActionCreate)
      {
        ApplicationArea = All;
        Caption = 'Create';
        Enabled = CurrentStep = 3;
        Image = Approve;
        InFooterBar = true;
        Style = Primary;
        ToolTip = 'Create the exclusion wrapper permission set.';

        trigger OnAction()
        begin
          PermSetExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, NewRoleName, Rec, ReplaceAssignments);
          CurrPage.Close();
        end;
      }
      action(ActionCancel)
      {
        ApplicationArea = All;
        Caption = 'Cancel';
        Image = Cancel;
        InFooterBar = true;
        ToolTip = 'Cancel the wizard and discard all changes.';

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

  var
    PermSetExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    CurrentStep: Integer;
    SourceRoleId: Code[20];
    SourceRoleName: Text[30];
    NewRoleId: Code[20];
    NewRoleName: Text[30];
    ReplaceAssignments: Boolean;
    ExclusionHelperRoleId: Code[20];
    SourceRoleIdEmptyErr: Label 'Source Permission Set must not be blank.';
    NewRoleIdEmptyValidErr: Label 'New Role ID must not be blank.';
    NewRoleNameEmptyErr: Label 'New Name must not be blank.';
    NewRoleIdSameAsSourceErr: Label 'New Role ID must be different from the source permission set Role ID.';

  local procedure LookupSourceRoleName()
  var
    AggregatePermSet: Record "Aggregate Permission Set";
  begin
    AggregatePermSet.SetLoadFields("Role ID", Name);
    AggregatePermSet.SetRange("Role ID", SourceRoleId);
    if AggregatePermSet.FindFirst() then
      SourceRoleName := AggregatePermSet.Name
    else
      SourceRoleName := '';
  end;

  local procedure UpdateExclusionHelperRoleId()
  begin
    if NewRoleId <> '' then
      ExclusionHelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18)
    else
      ExclusionHelperRoleId := '';
  end;

  local procedure ValidateCurrentStep()
  begin
    case CurrentStep of
      1:
        begin
          if SourceRoleId = '' then
            Error(SourceRoleIdEmptyErr);
        end;
      2:
        begin
          if NewRoleId = '' then
            Error(NewRoleIdEmptyValidErr);
          if NewRoleName = '' then
            Error(NewRoleNameEmptyErr);
          if NewRoleId = SourceRoleId then
            Error(NewRoleIdSameAsSourceErr);
        end;
    end;
  end;

  local procedure GetExclusionPermCount(): Integer
  var
    TempPerm: Record "Tenant Permission" temporary;
  begin
    TempPerm.Copy(Rec, true);
    exit(TempPerm.Count());
  end;
}
