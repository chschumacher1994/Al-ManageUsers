codeunit 50190 "Perm. Test Helper"
{
  /// <summary>
  /// Creates a user-defined (tenant) permission set with the given Role ID and Name.
  /// Returns the created record.
  /// </summary>
  procedure CreateTenantPermissionSet(RoleId: Code[20]; RoleName: Text[30]): Record "Tenant Permission Set"
  var
    TenantPermissionSet: Record "Tenant Permission Set";
  begin
    TenantPermissionSet.Init();
    TenantPermissionSet."App ID" := NullGuid();
    TenantPermissionSet."Role ID" := RoleId;
    TenantPermissionSet.Name := RoleName;
    TenantPermissionSet.Assignable := true;
    TenantPermissionSet.Insert(true);
    exit(TenantPermissionSet);
  end;

  /// <summary>
  /// Deletes a tenant permission set (and its permissions) identified by RoleId, if it exists.
  /// Used in TearDown to clean up test data.
  /// </summary>
  procedure CleanupTenantPermissionSet(RoleId: Code[20])
  var
    TenantPermissionSet: Record "Tenant Permission Set";
    TenantPermission: Record "Tenant Permission";
    TenantPermSetRel: Record "Tenant Permission Set Rel.";
    AccessControl: Record "Access Control";
  begin
    TenantPermission.SetRange("App ID", NullGuid());
    TenantPermission.SetRange("Role ID", RoleId);
    TenantPermission.DeleteAll();

    TenantPermSetRel.SetRange("App ID", NullGuid());
    TenantPermSetRel.SetRange("Role ID", RoleId);
    TenantPermSetRel.DeleteAll();

    TenantPermSetRel.Reset();
    TenantPermSetRel.SetRange("Related Role ID", RoleId);
    TenantPermSetRel.SetRange("Related Scope", TenantPermSetRel."Related Scope"::Tenant);
    TenantPermSetRel.DeleteAll();

    AccessControl.SetRange("Role ID", RoleId);
    AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
    AccessControl.DeleteAll();

    if TenantPermissionSet.Get(NullGuid(), RoleId) then
      TenantPermissionSet.Delete();
  end;

  /// <summary>
  /// Adds a single table-data permission entry to the given tenant permission set.
  /// </summary>
  procedure AddTenantPermission(RoleId: Code[20]; ObjectType: Option; ObjectId: Integer; Read: Option; Ins: Option; Mod: Option; Del: Option; Exe: Option)
  var
    TenantPermission: Record "Tenant Permission";
  begin
    TenantPermission.Init();
    TenantPermission."App ID" := NullGuid();
    TenantPermission."Role ID" := RoleId;
    TenantPermission."Object Type" := ObjectType;
    TenantPermission."Object ID" := ObjectId;
    TenantPermission."Read Permission" := Read;
    TenantPermission."Insert Permission" := Ins;
    TenantPermission."Modify Permission" := Mod;
    TenantPermission."Delete Permission" := Del;
    TenantPermission."Execute Permission" := Exe;
    TenantPermission.Type := TenantPermission.Type::Include;
    TenantPermission.Insert(true);
  end;

  /// <summary>
  /// Assigns a tenant permission set to a user via Access Control.
  /// </summary>
  procedure AssignPermSetToUser(UserSecurityId: Guid; RoleId: Code[20])
  var
    AccessControl: Record "Access Control";
  begin
    if AccessControl.Get(UserSecurityId, RoleId, '', AccessControl.Scope::Tenant, NullGuid()) then
      exit;
    AccessControl.Init();
    AccessControl."User Security ID" := UserSecurityId;
    AccessControl."Role ID" := RoleId;
    AccessControl."Company Name" := '';
    AccessControl.Scope := AccessControl.Scope::Tenant;
    AccessControl."App ID" := NullGuid();
    AccessControl.Insert(true);
  end;

  /// <summary>
  /// Removes a tenant permission set assignment from a user.
  /// </summary>
  procedure RemovePermSetFromUser(UserSecurityId: Guid; RoleId: Code[20])
  var
    AccessControl: Record "Access Control";
  begin
    if AccessControl.Get(UserSecurityId, RoleId, '', AccessControl.Scope::Tenant, NullGuid()) then
      AccessControl.Delete();
  end;

  /// <summary>
  /// Returns the well-known null GUID used as App ID for user-defined permission sets.
  /// </summary>
  procedure NullGuid(): Guid
  begin
    exit('00000000-0000-0000-0000-000000000000');
  end;
}
