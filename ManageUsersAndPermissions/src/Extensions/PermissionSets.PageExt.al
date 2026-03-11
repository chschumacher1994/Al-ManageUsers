pageextension 50020 "MUP Permission Sets" extends "Permission Sets"
{
  actions
  {
    addlast(Processing)
    {
      group(ManagePermissionsGroup)
      {
        Caption = 'Manage Permissions';
        ToolTip = 'Actions for managing and analyzing permission sets.';

        action(RenamePermissionSet)
        {
          ApplicationArea = All;
          Caption = 'Rename Permission Set';
          ToolTip = 'Opens a wizard to rename a user-defined permission set and update all references.';
          Image = Rename;
          Enabled = Rec.Type = Rec.Type::"User-Defined";

          trigger OnAction()
          var
            PermSetRenameWizard: Page "Perm. Set Rename Wizard";
          begin
            PermSetRenameWizard.RunModal();
          end;
        }

        action(CreateExclusionWrapper)
        {
          ApplicationArea = All;
          Caption = 'Create Exclusion Wrapper';
          ToolTip = 'Opens a wizard to create a new permission set that excludes specific permissions from the selected user-defined permission set.';
          Image = CreateForm;
          Enabled = Rec.Type = Rec.Type::"User-Defined";

          trigger OnAction()
          var
            PermSetExclusionWizard: Page "Perm. Set Exclusion Wizard";
          begin
            PermSetExclusionWizard.RunModal();
          end;
        }

        action(PermissionSearch)
        {
          ApplicationArea = All;
          Caption = 'Permission Search';
          ToolTip = 'Opens the permission search page to find which permission sets grant access to a specific object.';
          Image = Find;

          trigger OnAction()
          var
            PermissionSearchPage: Page "Permission Search";
          begin
            PermissionSearchPage.Run();
          end;
        }

        action(UserAccessOverview)
        {
          ApplicationArea = All;
          Caption = 'User Access Overview';
          ToolTip = 'Opens an overview of user access to objects, showing which permission sets grant access.';
          Image = Permission;

          trigger OnAction()
          var
            UserObjAccessOverview: Page "User Obj. Access Overview";
          begin
            UserObjAccessOverview.Run();
          end;
        }

        action(UserPermissionOverviewReport)
        {
          ApplicationArea = All;
          Caption = 'User Permission Overview';
          ToolTip = 'Runs a report listing all users with their assigned permission sets.';
          Image = Report;
          RunObject = report "User Permission Overview";
        }

        action(PermissionSetUsageReport)
        {
          ApplicationArea = All;
          Caption = 'Permission Set Usage';
          ToolTip = 'Runs a report listing all permission sets with their assigned users.';
          Image = Report;
          RunObject = report "Permission Set Usage";
        }

        action(PermissionSearchReport)
        {
          ApplicationArea = All;
          Caption = 'Permission Search Report';
          ToolTip = 'Runs a report showing which permission sets contain a given object permission.';
          Image = Report;
          RunObject = report "Permission Search";
        }
      }
    }
  }
}
