codeunit 50005 "Permission Search Mgt."
{
  Caption = 'Permission Search Management';
  Permissions =
    tabledata "Tenant Permission" = r,
    tabledata "Metadata Permission" = r,
    tabledata "Tenant Permission Set" = r,
    tabledata "Metadata Permission Set" = r;

  var
    NoObjectNameFoundTelemetryLbl: Label 'Object name not found for Object Type %1, Object ID %2.', Locked = true;

  /// <summary>
  /// Searches for permission sets that contain a specific object permission.
  /// Fills the provided temporary buffer with results from Tenant and optionally System scope.
  /// </summary>
  /// <param name="PermSearchBuffer">Temporary record buffer to receive search results.</param>
  /// <param name="ObjectType">The object type to search for (matches Tenant Permission Object Type option).</param>
  /// <param name="ObjectId">The object ID to search for.</param>
  /// <param name="IncludeSystem">When true, also searches system (metadata) permission sets.</param>
  procedure SearchPermissions(var PermSearchBuffer: Record "Permission Search Buffer" temporary; ObjectType: Option; ObjectId: Integer; IncludeSystem: Boolean)
  var
    Handled: Boolean;
  begin
    OnBeforeSearchPermissions(PermSearchBuffer, ObjectType, ObjectId, IncludeSystem, Handled);
    if Handled then
      exit;

    PermSearchBuffer.Reset();
    PermSearchBuffer.DeleteAll();

    SearchTenantPermissions(PermSearchBuffer, ObjectType, ObjectId);
    if IncludeSystem then
      SearchSystemPermissions(PermSearchBuffer, ObjectType, ObjectId);

    OnAfterSearchPermissions(PermSearchBuffer, ObjectType, ObjectId, IncludeSystem);
  end;

  local procedure SearchTenantPermissions(var PermSearchBuffer: Record "Permission Search Buffer" temporary; ObjectType: Option; ObjectId: Integer)
  var
    TenantPermission: Record "Tenant Permission";
    TenantPermissionSet: Record "Tenant Permission Set";
    ObjectName: Text[249];
  begin
    TenantPermission.SetLoadFields("App ID", "Role ID", "Object Type", "Object ID", "Read Permission", "Insert Permission", "Modify Permission", "Delete Permission", "Execute Permission");
    TenantPermission.SetRange("Object Type", ObjectType);
    TenantPermission.SetRange("Object ID", ObjectId);
    if not TenantPermission.FindSet() then
      exit;

    repeat
      ObjectName := GetObjectName(TenantPermission."Object Type", TenantPermission."Object ID");

      TenantPermissionSet.SetLoadFields("App ID", "Role ID", Name);
      if TenantPermissionSet.Get(TenantPermission."App ID", TenantPermission."Role ID") then;

      PermSearchBuffer.Init();
      PermSearchBuffer.Scope := PermSearchBuffer.Scope::Tenant;
      PermSearchBuffer."Role ID" := TenantPermission."Role ID";
      PermSearchBuffer."Role Name" := TenantPermissionSet.Name;
      PermSearchBuffer."Object Type" := TenantPermission."Object Type";
      PermSearchBuffer."Object ID" := TenantPermission."Object ID";
      PermSearchBuffer."Object Name" := ObjectName;
      PermSearchBuffer."Read Permission" := TenantPermission."Read Permission";
      PermSearchBuffer."Insert Permission" := TenantPermission."Insert Permission";
      PermSearchBuffer."Modify Permission" := TenantPermission."Modify Permission";
      PermSearchBuffer."Delete Permission" := TenantPermission."Delete Permission";
      PermSearchBuffer."Execute Permission" := TenantPermission."Execute Permission";
      if PermSearchBuffer.Insert() then;
    until TenantPermission.Next() = 0;
  end;

  local procedure SearchSystemPermissions(var PermSearchBuffer: Record "Permission Search Buffer" temporary; ObjectType: Option; ObjectId: Integer)
  var
    MetadataPermission: Record "Metadata Permission";
    MetadataPermissionSet: Record "Metadata Permission Set";
    ObjectName: Text[249];
    TruncatedRoleId: Code[20];
  begin
    MetadataPermission.SetLoadFields("App ID", "Role ID", "Object Type", "Object ID", "Read Permission", "Insert Permission", "Modify Permission", "Delete Permission", "Execute Permission");
    MetadataPermission.SetRange("Object Type", ObjectType);
    MetadataPermission.SetRange("Object ID", ObjectId);
    if not MetadataPermission.FindSet() then
      exit;

    repeat
      ObjectName := GetObjectName(MetadataPermission."Object Type", MetadataPermission."Object ID");
      TruncatedRoleId := CopyStr(MetadataPermission."Role ID", 1, MaxStrLen(TruncatedRoleId));

      MetadataPermissionSet.SetLoadFields("App ID", "Role ID", Name);
      if MetadataPermissionSet.Get(MetadataPermission."App ID", MetadataPermission."Role ID") then;

      PermSearchBuffer.Init();
      PermSearchBuffer.Scope := PermSearchBuffer.Scope::System;
      PermSearchBuffer."Role ID" := TruncatedRoleId;
      PermSearchBuffer."Role Name" := MetadataPermissionSet.Name;
      PermSearchBuffer."Object Type" := MetadataPermission."Object Type";
      PermSearchBuffer."Object ID" := MetadataPermission."Object ID";
      PermSearchBuffer."Object Name" := ObjectName;
      PermSearchBuffer."Read Permission" := MetadataPermission."Read Permission";
      PermSearchBuffer."Insert Permission" := MetadataPermission."Insert Permission";
      PermSearchBuffer."Modify Permission" := MetadataPermission."Modify Permission";
      PermSearchBuffer."Delete Permission" := MetadataPermission."Delete Permission";
      PermSearchBuffer."Execute Permission" := MetadataPermission."Execute Permission";
      if PermSearchBuffer.Insert() then;
    until MetadataPermission.Next() = 0;
  end;

  local procedure GetObjectName(ObjectType: Option; ObjectId: Integer): Text[249]
  var
    AllObjWithCaption: Record AllObjWithCaption;
  begin
    AllObjWithCaption.SetLoadFields("Object Type", "Object ID", "Object Caption");
    if AllObjWithCaption.Get(ObjectType, ObjectId) then
      exit(AllObjWithCaption."Object Caption");

    Session.LogMessage('0000PS1', StrSubstNo(NoObjectNameFoundTelemetryLbl, ObjectType, ObjectId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'PermissionSearch');
    exit('');
  end;

  [IntegrationEvent(false, false)]
  local procedure OnBeforeSearchPermissions(var PermSearchBuffer: Record "Permission Search Buffer" temporary; ObjectType: Option; ObjectId: Integer; IncludeSystem: Boolean; var Handled: Boolean)
  begin
  end;

  [IntegrationEvent(false, false)]
  local procedure OnAfterSearchPermissions(var PermSearchBuffer: Record "Permission Search Buffer" temporary; ObjectType: Option; ObjectId: Integer; IncludeSystem: Boolean)
  begin
  end;
}
