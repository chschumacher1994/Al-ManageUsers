codeunit 50003 "Perm. Set Exclusion Mgt."
{
  Caption = 'Permission Set Exclusion Management';
  Permissions =
    tabledata "Tenant Permission Set" = ri,
    tabledata "Tenant Permission" = rim,
    tabledata "Tenant Permission Set Rel." = ri,
    tabledata "Access Control" = m;

  var
    SourceNotFoundErr: Label 'Source permission set ''%1'' not found.', Comment = '%1 = Role ID';
    WrapperAlreadyExistsErr: Label 'Permission set ''%1'' already exists.', Comment = '%1 = Role ID';
    NewRoleIdEmptyErr: Label 'New Role ID must not be blank.';
    CreateFailedErr: Label 'Creating exclusion wrapper failed. The operation has been rolled back.';
    CreateStartedTelemetryLbl: Label 'Exclusion wrapper create started: SourceRoleId=%1, NewRoleId=%2.', Locked = true;
    CreateCompletedTelemetryLbl: Label 'Exclusion wrapper create completed: SourceRoleId=%1, NewRoleId=%2.', Locked = true;

  /// <summary>
  /// Creates a new tenant permission set that includes the source set and excludes a
  /// generated helper set containing the provided exclusion permissions.
  /// Optionally replaces all existing Access Control assignments from SourceRoleId
  /// with assignments to the new wrapper set.
  /// Fires OnBeforeCreateExclusionWrapper and OnAfterCreateExclusionWrapper events.
  /// </summary>
  /// <param name="SourceRoleId">Role ID of the permission set to wrap (System or Tenant).</param>
  /// <param name="NewRoleId">Role ID for the new wrapper permission set (max 20 chars).</param>
  /// <param name="NewRoleName">Display name for the new wrapper permission set.</param>
  /// <param name="ExclusionPermissions">Temporary Tenant Permission records to insert into the exclusion helper set.</param>
  /// <param name="ReplaceAssignments">When true, replaces all Access Control entries pointing to SourceRoleId with NewRoleId.</param>
  procedure CreateExclusionWrapper(
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    NewRoleName: Text[30];
    var ExclusionPermissions: Record "Tenant Permission" temporary;
    ReplaceAssignments: Boolean)
  var
    AggregatePermSet: Record "Aggregate Permission Set";
    TenantPermissionSet: Record "Tenant Permission Set";
    Handled: Boolean;
  begin
    if NewRoleId = '' then
      Error(NewRoleIdEmptyErr);

    AggregatePermSet.SetLoadFields("Role ID", Scope, "App ID");
    AggregatePermSet.SetRange("Role ID", SourceRoleId);
    if not AggregatePermSet.FindFirst() then
      Error(SourceNotFoundErr, SourceRoleId);

    TenantPermissionSet.SetLoadFields("App ID", "Role ID");
    TenantPermissionSet.SetRange("Role ID", NewRoleId);
    TenantPermissionSet.SetRange("App ID", GetNullGuid());
    if TenantPermissionSet.FindFirst() then
      Error(WrapperAlreadyExistsErr, NewRoleId);

    Session.LogMessage('0000PE1', StrSubstNo(CreateStartedTelemetryLbl, SourceRoleId, NewRoleId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'PermSetExclusion');

    OnBeforeCreateExclusionWrapper(SourceRoleId, NewRoleId, Handled);
    if Handled then
      exit;

    if not TryCreateExclusionWrapper(SourceRoleId, NewRoleId, NewRoleName, ExclusionPermissions, ReplaceAssignments) then
      Error(CreateFailedErr);

    Session.LogMessage('0000PE2', StrSubstNo(CreateCompletedTelemetryLbl, SourceRoleId, NewRoleId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'PermSetExclusion');

    OnAfterCreateExclusionWrapper(SourceRoleId, NewRoleId);
  end;

  [TryFunction]
  local procedure TryCreateExclusionWrapper(
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    NewRoleName: Text[30];
    var ExclusionPermissions: Record "Tenant Permission" temporary;
    ReplaceAssignments: Boolean)
  var
    WrapperPermSet: Record "Tenant Permission Set";
    HelperPermSet: Record "Tenant Permission Set";
    IncludeRel: Record "Tenant Permission Set Rel.";
    ExcludeRel: Record "Tenant Permission Set Rel.";
    NewTenantPerm: Record "Tenant Permission";
    SourceAccessControl: Record "Access Control";
    NewAccessControl: Record "Access Control";
    AggregatePermSet: Record "Aggregate Permission Set";
    ExclusionHelperRoleId: Code[20];
    SourceScope: Option System,Tenant;
    SourceAppId: Guid;
  begin
    ExclusionHelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);

    AggregatePermSet.SetLoadFields("Role ID", Scope, "App ID");
    AggregatePermSet.SetRange("Role ID", SourceRoleId);
    AggregatePermSet.FindFirst();
    SourceScope := AggregatePermSet.Scope;
    SourceAppId := AggregatePermSet."App ID";

    // Step 1: Create wrapper permission set
    WrapperPermSet.Init();
    WrapperPermSet."App ID" := GetNullGuid();
    WrapperPermSet."Role ID" := NewRoleId;
    WrapperPermSet.Name := NewRoleName;
    WrapperPermSet.Assignable := true;
    WrapperPermSet.Insert();

    // Step 2: Create exclusion helper permission set
    HelperPermSet.Init();
    HelperPermSet."App ID" := GetNullGuid();
    HelperPermSet."Role ID" := ExclusionHelperRoleId;
    HelperPermSet.Name := 'Excl: ' + CopyStr(NewRoleName, 1, 24);
    HelperPermSet.Assignable := false;
    HelperPermSet.Insert();

    // Step 3: Wrapper INCLUDES Source
    IncludeRel.Init();
    IncludeRel."App ID" := GetNullGuid();
    IncludeRel."Role ID" := NewRoleId;
    if SourceScope = AggregatePermSet.Scope::System then begin
      IncludeRel."Related App ID" := SourceAppId;
      IncludeRel."Related Scope" := IncludeRel."Related Scope"::System;
    end else begin
      IncludeRel."Related App ID" := GetNullGuid();
      IncludeRel."Related Scope" := IncludeRel."Related Scope"::Tenant;
    end;
    IncludeRel."Related Role ID" := SourceRoleId;
    IncludeRel.Type := IncludeRel.Type::Include;
    IncludeRel.Insert();

    // Step 4: Wrapper EXCLUDES Helper
    ExcludeRel.Init();
    ExcludeRel."App ID" := GetNullGuid();
    ExcludeRel."Role ID" := NewRoleId;
    ExcludeRel."Related App ID" := GetNullGuid();
    ExcludeRel."Related Role ID" := ExclusionHelperRoleId;
    ExcludeRel."Related Scope" := ExcludeRel."Related Scope"::Tenant;
    ExcludeRel.Type := ExcludeRel.Type::Exclude;
    ExcludeRel.Insert();

    // Step 5: Insert exclusion permissions into helper set
    if ExclusionPermissions.FindSet() then
      repeat
        NewTenantPerm.Init();
        NewTenantPerm."App ID" := GetNullGuid();
        NewTenantPerm."Role ID" := ExclusionHelperRoleId;
        NewTenantPerm."Object Type" := ExclusionPermissions."Object Type";
        NewTenantPerm."Object ID" := ExclusionPermissions."Object ID";
        NewTenantPerm."Read Permission" := ExclusionPermissions."Read Permission";
        NewTenantPerm."Insert Permission" := ExclusionPermissions."Insert Permission";
        NewTenantPerm."Modify Permission" := ExclusionPermissions."Modify Permission";
        NewTenantPerm."Delete Permission" := ExclusionPermissions."Delete Permission";
        NewTenantPerm."Execute Permission" := ExclusionPermissions."Execute Permission";
        NewTenantPerm.Type := NewTenantPerm.Type::Include;
        NewTenantPerm.Insert();
      until ExclusionPermissions.Next() = 0;

    // Step 6: Optionally replace Access Control assignments
    if not ReplaceAssignments then
      exit;

    SourceAccessControl.SetLoadFields("User Security ID", "Role ID", "Company Name", Scope, "App ID");
    SourceAccessControl.SetRange("Role ID", SourceRoleId);
    SourceAccessControl.SetRange(Scope, SourceAccessControl.Scope::Tenant);
    if not SourceAccessControl.FindSet() then
      exit;

    repeat
      NewAccessControl.Init();
      NewAccessControl."User Security ID" := SourceAccessControl."User Security ID";
      NewAccessControl."Role ID" := NewRoleId;
      NewAccessControl."Company Name" := SourceAccessControl."Company Name";
      NewAccessControl.Scope := NewAccessControl.Scope::Tenant;
      NewAccessControl."App ID" := GetNullGuid();
      if NewAccessControl.Insert() then;
    until SourceAccessControl.Next() = 0;
  end;

  local procedure GetNullGuid(): Guid
  begin
    exit('00000000-0000-0000-0000-000000000000');
  end;

  [IntegrationEvent(false, false)]
  local procedure OnBeforeCreateExclusionWrapper(SourceRoleId: Code[20]; NewRoleId: Code[20]; var Handled: Boolean)
  begin
  end;

  [IntegrationEvent(false, false)]
  local procedure OnAfterCreateExclusionWrapper(SourceRoleId: Code[20]; NewRoleId: Code[20])
  begin
  end;
}
