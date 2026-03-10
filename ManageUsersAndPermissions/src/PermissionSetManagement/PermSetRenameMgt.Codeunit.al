codeunit 50002 "Perm. Set Rename Mgt."
{
  Caption = 'Permission Set Rename Management';
  Permissions =
    tabledata "Tenant Permission Set" = rimd,
    tabledata "Tenant Permission" = rimd,
    tabledata "Tenant Permission Set Rel." = rimd,
    tabledata "Access Control" = rimd;

  var
    PermSetNotFoundErr: Label 'Permission set %1 not found.', Comment = '%1 = Role ID';
    PermSetNotUserDefinedErr: Label 'Permission set %1 is not user-defined and cannot be renamed.', Comment = '%1 = Role ID';
    PermSetAlreadyExistsErr: Label 'Permission set %1 already exists.', Comment = '%1 = Role ID';
    RenameFailedErr: Label 'Renaming permission set failed. The operation has been rolled back.';
    RenameStartedTelemetryLbl: Label 'Permission set rename started: OldRoleId=%1, NewRoleId=%2.', Locked = true;
    RenameCompletedTelemetryLbl: Label 'Permission set rename completed: OldRoleId=%1, NewRoleId=%2.', Locked = true;

  /// <summary>
  /// Renames a user-defined (tenant) permission set from OldRoleId to NewRoleId.
  /// Migrates all references in Tenant Permission, Tenant Permission Set Rel., and Access Control
  /// within a single transaction. Fires OnBeforeRenamePermissionSet and OnAfterRenamePermissionSet events.
  /// </summary>
  /// <param name="OldRoleId">The current Role ID of the permission set to rename.</param>
  /// <param name="NewRoleId">The new Role ID to assign to the permission set.</param>
  procedure RenamePermissionSet(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    TenantPermissionSet: Record "Tenant Permission Set";
    Handled: Boolean;
  begin
    TenantPermissionSet.SetLoadFields("App ID", "Role ID", Name, Assignable);
    TenantPermissionSet.SetRange("Role ID", OldRoleId);
    TenantPermissionSet.SetRange("App ID", GetNullGuid());
    if not TenantPermissionSet.FindFirst() then
      Error(PermSetNotFoundErr, OldRoleId);

    if not IsNullGuid(TenantPermissionSet."App ID") then
      Error(PermSetNotUserDefinedErr, OldRoleId);

    TenantPermissionSet.SetLoadFields("App ID", "Role ID");
    TenantPermissionSet.SetRange("Role ID", NewRoleId);
    TenantPermissionSet.SetRange("App ID", GetNullGuid());
    if TenantPermissionSet.FindFirst() then
      Error(PermSetAlreadyExistsErr, NewRoleId);

    Session.LogMessage('0000PR1', StrSubstNo(RenameStartedTelemetryLbl, OldRoleId, NewRoleId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'PermSetRename');

    OnBeforeRenamePermissionSet(OldRoleId, NewRoleId, Handled);
    if Handled then
      exit;

    if not TryRenamePermissionSet(OldRoleId, NewRoleId) then
      Error(RenameFailedErr);

    Session.LogMessage('0000PR2', StrSubstNo(RenameCompletedTelemetryLbl, OldRoleId, NewRoleId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'PermSetRename');

    OnAfterRenamePermissionSet(OldRoleId, NewRoleId);
  end;

  [TryFunction]
  local procedure TryRenamePermissionSet(OldRoleId: Code[20]; NewRoleId: Code[20])
  begin
    RenameTenantPermissionSet(OldRoleId, NewRoleId);
    RenameTenantPermissions(OldRoleId, NewRoleId);
    RenamePermSetRelOwnerSide(OldRoleId, NewRoleId);
    RenamePermSetRelReferenceSide(OldRoleId, NewRoleId);
    RenameAccessControlEntries(OldRoleId, NewRoleId);
  end;

  local procedure RenameTenantPermissionSet(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    OldPermSet: Record "Tenant Permission Set";
    NewPermSet: Record "Tenant Permission Set";
  begin
    OldPermSet.SetLoadFields("App ID", "Role ID", Name, Assignable);
    OldPermSet.Get(GetNullGuid(), OldRoleId);

    NewPermSet.Init();
    NewPermSet."App ID" := OldPermSet."App ID";
    NewPermSet."Role ID" := NewRoleId;
    NewPermSet.Name := OldPermSet.Name;
    NewPermSet.Assignable := OldPermSet.Assignable;
    NewPermSet.Insert();

    OldPermSet.Delete();
  end;

  local procedure RenameTenantPermissions(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    OldPermission: Record "Tenant Permission";
    NewPermission: Record "Tenant Permission";
  begin
    OldPermission.SetLoadFields("App ID", "Role ID", "Object Type", "Object ID", "Read Permission", "Insert Permission", "Modify Permission", "Delete Permission", "Execute Permission", "Security Filter", Type);
    OldPermission.SetRange("App ID", GetNullGuid());
    OldPermission.SetRange("Role ID", OldRoleId);
    if not OldPermission.FindSet() then
      exit;

    repeat
      NewPermission.Init();
      NewPermission."App ID" := OldPermission."App ID";
      NewPermission."Role ID" := NewRoleId;
      NewPermission."Object Type" := OldPermission."Object Type";
      NewPermission."Object ID" := OldPermission."Object ID";
      NewPermission."Read Permission" := OldPermission."Read Permission";
      NewPermission."Insert Permission" := OldPermission."Insert Permission";
      NewPermission."Modify Permission" := OldPermission."Modify Permission";
      NewPermission."Delete Permission" := OldPermission."Delete Permission";
      NewPermission."Execute Permission" := OldPermission."Execute Permission";
      NewPermission."Security Filter" := OldPermission."Security Filter";
      NewPermission.Type := OldPermission.Type;
      NewPermission.Insert();
    until OldPermission.Next() = 0;

    OldPermission.Reset();
    OldPermission.SetRange("App ID", GetNullGuid());
    OldPermission.SetRange("Role ID", OldRoleId);
    OldPermission.DeleteAll();
  end;

  local procedure RenamePermSetRelOwnerSide(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    OldRel: Record "Tenant Permission Set Rel.";
    NewRel: Record "Tenant Permission Set Rel.";
  begin
    OldRel.SetLoadFields("App ID", "Role ID", "Related App ID", "Related Role ID", Type, "Related Scope");
    OldRel.SetRange("App ID", GetNullGuid());
    OldRel.SetRange("Role ID", OldRoleId);
    if not OldRel.FindSet() then
      exit;

    repeat
      NewRel.Init();
      NewRel."App ID" := OldRel."App ID";
      NewRel."Role ID" := NewRoleId;
      NewRel."Related App ID" := OldRel."Related App ID";
      NewRel."Related Role ID" := OldRel."Related Role ID";
      NewRel.Type := OldRel.Type;
      NewRel."Related Scope" := OldRel."Related Scope";
      NewRel.Insert();
    until OldRel.Next() = 0;

    OldRel.Reset();
    OldRel.SetRange("App ID", GetNullGuid());
    OldRel.SetRange("Role ID", OldRoleId);
    OldRel.DeleteAll();
  end;

  local procedure RenamePermSetRelReferenceSide(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    OldRel: Record "Tenant Permission Set Rel.";
    NewRel: Record "Tenant Permission Set Rel.";
  begin
    OldRel.SetLoadFields("App ID", "Role ID", "Related App ID", "Related Role ID", Type, "Related Scope");
    OldRel.SetRange("Related Role ID", OldRoleId);
    OldRel.SetRange("Related Scope", OldRel."Related Scope"::Tenant);
    if not OldRel.FindSet() then
      exit;

    repeat
      NewRel.Init();
      NewRel."App ID" := OldRel."App ID";
      NewRel."Role ID" := OldRel."Role ID";
      NewRel."Related App ID" := OldRel."Related App ID";
      NewRel."Related Role ID" := NewRoleId;
      NewRel.Type := OldRel.Type;
      NewRel."Related Scope" := OldRel."Related Scope";
      NewRel.Insert();
    until OldRel.Next() = 0;

    OldRel.Reset();
    OldRel.SetRange("Related Role ID", OldRoleId);
    OldRel.SetRange("Related Scope", OldRel."Related Scope"::Tenant);
    OldRel.DeleteAll();
  end;

  local procedure RenameAccessControlEntries(OldRoleId: Code[20]; NewRoleId: Code[20])
  var
    OldAccessControl: Record "Access Control";
    NewAccessControl: Record "Access Control";
  begin
    OldAccessControl.SetLoadFields("User Security ID", "Role ID", "Company Name", Scope, "App ID");
    OldAccessControl.SetRange("Role ID", OldRoleId);
    OldAccessControl.SetRange(Scope, OldAccessControl.Scope::Tenant);
    if not OldAccessControl.FindSet() then
      exit;

    repeat
      NewAccessControl.Init();
      NewAccessControl."User Security ID" := OldAccessControl."User Security ID";
      NewAccessControl."Role ID" := NewRoleId;
      NewAccessControl."Company Name" := OldAccessControl."Company Name";
      NewAccessControl.Scope := OldAccessControl.Scope;
      NewAccessControl."App ID" := OldAccessControl."App ID";
      NewAccessControl.Insert();
    until OldAccessControl.Next() = 0;

    OldAccessControl.Reset();
    OldAccessControl.SetRange("Role ID", OldRoleId);
    OldAccessControl.SetRange(Scope, OldAccessControl.Scope::Tenant);
    OldAccessControl.DeleteAll();
  end;

  local procedure GetNullGuid(): Guid
  begin
    exit('00000000-0000-0000-0000-000000000000');
  end;

  [IntegrationEvent(false, false)]
  local procedure OnBeforeRenamePermissionSet(OldRoleId: Code[20]; NewRoleId: Code[20]; var Handled: Boolean)
  begin
  end;

  [IntegrationEvent(false, false)]
  local procedure OnAfterRenamePermissionSet(OldRoleId: Code[20]; NewRoleId: Code[20])
  begin
  end;
}
