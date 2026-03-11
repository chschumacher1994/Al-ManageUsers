codeunit 50004 "Permission Analysis Mgt."
{
  Access = Internal;

  var
    UserNotFoundTelemetryLbl: Label 'PermissionAnalysisMgt: User not found for Security ID %1.', Locked = true;

  /// <summary>
  /// Populates the temporary UserAccessBuffer with all enabled users that have
  /// direct permission-set assignments covering the specified object type and ID.
  /// Only direct Access Control assignments are evaluated (Security Group support is Phase 2).
  /// </summary>
  /// <param name="UserAccessBuffer">Temporary buffer to receive the analysis results.</param>
  /// <param name="ObjectType">The permission object type (matches Tenant/Metadata Permission "Object Type" option).</param>
  /// <param name="ObjectId">The object ID to analyse.</param>
  /// <param name="CompanyFilter">Optional company name filter; pass empty string to include all companies.</param>
  procedure AnalyzeObjectAccess(
    var UserAccessBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option;
    ObjectId: Integer;
    CompanyFilter: Text)
  begin
    UserAccessBuffer.Reset();
    UserAccessBuffer.DeleteAll();

    CollectTenantPermissionAccess(UserAccessBuffer, ObjectType, ObjectId, CompanyFilter);
    CollectSystemPermissionAccess(UserAccessBuffer, ObjectType, ObjectId, CompanyFilter);

    OnAfterAnalyzeObjectAccess(UserAccessBuffer, ObjectType, ObjectId);
  end;

  local procedure CollectTenantPermissionAccess(
    var UserAccessBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option;
    ObjectId: Integer;
    CompanyFilter: Text)
  var
    TenantPermission: Record "Tenant Permission";
    AccessControl: Record "Access Control";
  begin
    TenantPermission.SetRange("Object Type", ObjectType);
    TenantPermission.SetRange("Object ID", ObjectId);
    TenantPermission.SetLoadFields("App ID", "Role ID", "Read Permission", "Insert Permission",
      "Modify Permission", "Delete Permission", "Execute Permission");
    if not TenantPermission.FindSet() then
      exit;

    repeat
      AccessControl.SetRange("Role ID", TenantPermission."Role ID");
      AccessControl.SetRange("App ID", TenantPermission."App ID");
      AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
      if CompanyFilter <> '' then
        AccessControl.SetRange("Company Name", CompanyFilter);
      AccessControl.SetLoadFields("User Security ID", "Role ID", "Company Name", Scope, "App ID");
      if AccessControl.FindSet() then
        repeat
          FillBufferFromAccessControl(
            UserAccessBuffer,
            AccessControl,
            TenantPermission."Read Permission",
            TenantPermission."Insert Permission",
            TenantPermission."Modify Permission",
            TenantPermission."Delete Permission",
            TenantPermission."Execute Permission");
        until AccessControl.Next() = 0;
    until TenantPermission.Next() = 0;
  end;

  local procedure CollectSystemPermissionAccess(
    var UserAccessBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option;
    ObjectId: Integer;
    CompanyFilter: Text)
  var
    MetadataPermission: Record "Metadata Permission";
    AccessControl: Record "Access Control";
    RoleIdCode20: Code[20];
  begin
    MetadataPermission.SetRange("Object Type", ObjectType);
    MetadataPermission.SetRange("Object ID", ObjectId);
    MetadataPermission.SetLoadFields("App ID", "Role ID", "Read Permission", "Insert Permission",
      "Modify Permission", "Delete Permission", "Execute Permission");
    if not MetadataPermission.FindSet() then
      exit;

    repeat
      // Metadata Permission Role ID is Code[30]; Access Control Role ID is Code[20].
      // Truncation is safe because system permission sets shipped by Microsoft stay within 20 chars.
      RoleIdCode20 := CopyStr(MetadataPermission."Role ID", 1, MaxStrLen(RoleIdCode20));

      AccessControl.SetRange("Role ID", RoleIdCode20);
      AccessControl.SetRange("App ID", MetadataPermission."App ID");
      AccessControl.SetRange(Scope, AccessControl.Scope::System);
      if CompanyFilter <> '' then
        AccessControl.SetRange("Company Name", CompanyFilter);
      AccessControl.SetLoadFields("User Security ID", "Role ID", "Company Name", Scope, "App ID");
      if AccessControl.FindSet() then
        repeat
          FillBufferFromAccessControl(
            UserAccessBuffer,
            AccessControl,
            MetadataPermission."Read Permission",
            MetadataPermission."Insert Permission",
            MetadataPermission."Modify Permission",
            MetadataPermission."Delete Permission",
            MetadataPermission."Execute Permission");
        until AccessControl.Next() = 0;
    until MetadataPermission.Next() = 0;
  end;

  local procedure FillBufferFromAccessControl(
    var UserAccessBuffer: Record "User Obj. Access Buffer" temporary;
    AccessControl: Record "Access Control";
    ReadPermission: Option;
    InsertPermission: Option;
    ModifyPermission: Option;
    DeletePermission: Option;
    ExecutePermission: Option)
  var
    UserRec: Record User;
  begin
    UserRec.SetLoadFields("User Security ID", "User Name", "Full Name", State);
    if not UserRec.Get(AccessControl."User Security ID") then begin
      Session.LogMessage('0000MUA-01', StrSubstNo(UserNotFoundTelemetryLbl, AccessControl."User Security ID"),
        Verbosity::Warning, DataClassification::EndUserPseudonymousIdentifiers,
        TelemetryScope::ExtensionPublisher, 'Category', 'PermissionAnalysis');
      exit;
    end;

    if UserRec.State = UserRec.State::Disabled then
      exit;

    if UserAccessBuffer.Get(AccessControl."User Security ID") then begin
      UserAccessBuffer."Permission Set Count" += 1;
      UserAccessBuffer."Has Direct Permission" := true;
      UserAccessBuffer.Modify();
    end else begin
      UserAccessBuffer.Init();
      UserAccessBuffer."User Security ID" := UserRec."User Security ID";
      UserAccessBuffer."User Name" := UserRec."User Name";
      UserAccessBuffer."Full Name" := UserRec."Full Name";
      UserAccessBuffer.State := UserAccessBuffer.State::Enabled;
      UserAccessBuffer."Permission Set Count" := 1;
      UserAccessBuffer."Has Direct Permission" := true;
      UserAccessBuffer.Insert();
    end;
  end;

  [IntegrationEvent(false, false)]
  local procedure OnAfterAnalyzeObjectAccess(
    var UserAccessBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option;
    ObjectId: Integer)
  begin
  end;
}
