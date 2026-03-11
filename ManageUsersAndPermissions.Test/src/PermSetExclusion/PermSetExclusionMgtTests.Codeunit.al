codeunit 50120 "Perm. Set Excl. Mgt. Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    PermTestHelper: Codeunit "Perm. Test Helper";
    Assert: Codeunit Assert;

  // ──────────────────────────────────────────────────────────
  // Happy path
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] A user-defined source permission set exists.
  /// [WHEN]  CreateExclusionWrapper is called with a new Role ID and exclusion permissions.
  /// [THEN]  Wrapper set, exclusion helper set, include relation, and exclude relation all exist.
  /// </summary>
  [Test]
  procedure ExclusionWrapperCreatesWrapperAndHelperPermSets()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    TenantPermissionSet: Record "Tenant Permission Set";
    TenantPermSetRel: Record "Tenant Permission Set Rel.";
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    HelperRoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-SRC';
    NewRoleId := 'TEST-EX-NEW';
    HelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);  // matches codeunit logic
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl Source');

    // Build exclusion permission temp record
    TempExclusionPerms.Init();
    TempExclusionPerms."App ID" := PermTestHelper.NullGuid();
    TempExclusionPerms."Role ID" := NewRoleId;
    TempExclusionPerms."Object Type" := ObjectType::"Table Data";
    TempExclusionPerms."Object ID" := 18;
    TempExclusionPerms."Read Permission" := 1;
    TempExclusionPerms.Insert();

    // [WHEN]
    ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Test Excl Wrapper', TempExclusionPerms, false);

    // [THEN] Wrapper permission set created
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), NewRoleId),
      'Wrapper permission set must be created.');
    Assert.IsTrue(TenantPermissionSet.Assignable, 'Wrapper set must be assignable.');

    // [THEN] Exclusion helper permission set created
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), HelperRoleId),
      'Exclusion helper permission set must be created.');
    Assert.IsFalse(TenantPermissionSet.Assignable, 'Helper set must not be assignable.');

    // [THEN] Include relation: Wrapper includes Source
    TenantPermSetRel.SetRange("App ID", PermTestHelper.NullGuid());
    TenantPermSetRel.SetRange("Role ID", NewRoleId);
    TenantPermSetRel.SetRange("Related Role ID", SourceRoleId);
    TenantPermSetRel.SetRange(Type, TenantPermSetRel.Type::Include);
    Assert.IsTrue(TenantPermSetRel.FindFirst(), 'Include relation (Wrapper->Source) must exist.');

    // [THEN] Exclude relation: Wrapper excludes Helper
    TenantPermSetRel.SetRange("Related Role ID", HelperRoleId);
    TenantPermSetRel.SetRange(Type, TenantPermSetRel.Type::Exclude);
    Assert.IsTrue(TenantPermSetRel.FindFirst(), 'Exclude relation (Wrapper->Helper) must exist.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
    PermTestHelper.CleanupTenantPermissionSet(HelperRoleId);
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;

  /// <summary>
  /// [GIVEN] A source permission set exists and exclusion permissions are provided.
  /// [WHEN]  CreateExclusionWrapper is called.
  /// [THEN]  Exclusion permissions are inserted into the helper set.
  /// </summary>
  [Test]
  procedure ExclusionWrapperInsertsExclusionPermissionsIntoHelperSet()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    TenantPermission: Record "Tenant Permission";
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    HelperRoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-PERMS-SRC';
    NewRoleId := 'TEST-EX-PERMS';
    HelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl Perms Src');

    TempExclusionPerms.Init();
    TempExclusionPerms."App ID" := PermTestHelper.NullGuid();
    TempExclusionPerms."Role ID" := NewRoleId;
    TempExclusionPerms."Object Type" := ObjectType::"Table Data";
    TempExclusionPerms."Object ID" := 18;
    TempExclusionPerms."Read Permission" := 1;
    TempExclusionPerms."Modify Permission" := 1;
    TempExclusionPerms.Insert();

    TempExclusionPerms.Init();
    TempExclusionPerms."App ID" := PermTestHelper.NullGuid();
    TempExclusionPerms."Role ID" := NewRoleId;
    TempExclusionPerms."Object Type" := ObjectType::"Table Data";
    TempExclusionPerms."Object ID" := 27;
    TempExclusionPerms."Read Permission" := 1;
    TempExclusionPerms.Insert();

    // [WHEN]
    ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Test Excl Perms', TempExclusionPerms, false);

    // [THEN]
    TenantPermission.SetRange("App ID", PermTestHelper.NullGuid());
    TenantPermission.SetRange("Role ID", HelperRoleId);
    Assert.AreEqual(2, TenantPermission.Count(), 'Both exclusion permissions must be in helper set.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
    PermTestHelper.CleanupTenantPermissionSet(HelperRoleId);
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;

  /// <summary>
  /// [GIVEN] A source permission set is assigned to a user; ReplaceAssignments = true.
  /// [WHEN]  CreateExclusionWrapper is called.
  /// [THEN]  Access Control entries for the source are copied to the new wrapper Role ID.
  /// </summary>
  [Test]
  procedure ExclusionWrapperReplacesAccessControlWhenFlagIsTrue()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    AccessControl: Record "Access Control";
    UserSecurityId: Guid;
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    HelperRoleId: Code[20];
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-AC-SRC';
    NewRoleId := 'TEST-EX-AC';
    HelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);
    UserSecurityId := CreateGuid();
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl AC Src');
    PermTestHelper.AssignPermSetToUser(UserSecurityId, SourceRoleId);

    // [WHEN]
    ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Test Excl AC', TempExclusionPerms, true);

    // [THEN] New Role ID is assigned to the user
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.SetRange("Role ID", NewRoleId);
    AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
    Assert.IsTrue(AccessControl.FindFirst(), 'Access Control entry must exist for new wrapper Role ID.');

    // TearDown
    PermTestHelper.RemovePermSetFromUser(UserSecurityId, SourceRoleId);
    AccessControl.SetRange("Role ID", NewRoleId);
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.DeleteAll();
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
    PermTestHelper.CleanupTenantPermissionSet(HelperRoleId);
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Setup missing / disabled
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] The source Role ID does not correspond to any known permission set.
  /// [WHEN]  CreateExclusionWrapper is called.
  /// [THEN]  An error is raised indicating the source was not found.
  /// </summary>
  [Test]
  procedure ExclusionWrapperFailsWhenSourceNotFound()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
  begin
    // [GIVEN] No permission set with ID 'MISSING-SRC'.

    // [WHEN] / [THEN]
    asserterror ExclusionMgt.CreateExclusionWrapper('MISSING-SRC', 'ANY-NEW', 'Any Name', TempExclusionPerms, false);
    Assert.ExpectedErrorCode('Dialog');
  end;

  /// <summary>
  /// [GIVEN] A source permission set exists but the wrapper Role ID already exists.
  /// [WHEN]  CreateExclusionWrapper is called.
  /// [THEN]  An error is raised indicating the wrapper already exists.
  /// </summary>
  [Test]
  procedure ExclusionWrapperFailsWhenWrapperRoleIdAlreadyExists()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-DUP-SRC';
    NewRoleId := 'TEST-EX-DUP';
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl Dup Src');
    PermTestHelper.CreateTenantPermissionSet(NewRoleId, 'Test Excl Dup Wrapper');

    // [WHEN] / [THEN]
    asserterror ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Any Name', TempExclusionPerms, false);
    Assert.ExpectedErrorCode('Dialog');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Invalid input / boundary values
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] A source permission set exists.
  /// [WHEN]  CreateExclusionWrapper is called with an empty NewRoleId.
  /// [THEN]  An error is raised for blank Role ID.
  /// </summary>
  [Test]
  procedure ExclusionWrapperFailsForEmptyNewRoleId()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    SourceRoleId: Code[20];
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-BLANK';
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl Blank');

    // [WHEN] / [THEN]
    asserterror ExclusionMgt.CreateExclusionWrapper(SourceRoleId, '', 'Any Name', TempExclusionPerms, false);
    Assert.ExpectedErrorCode('Dialog');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;

  /// <summary>
  /// [GIVEN] A source permission set exists and no exclusion permissions are provided.
  /// [WHEN]  CreateExclusionWrapper is called with an empty TempExclusionPerms.
  /// [THEN]  Wrapper and helper sets are created; helper set has no permission entries.
  /// </summary>
  [Test]
  procedure ExclusionWrapperWithNoExclusionPermsCreatesEmptyHelperSet()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    TenantPermission: Record "Tenant Permission";
    TenantPermissionSet: Record "Tenant Permission Set";
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    HelperRoleId: Code[20];
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-EMPTY-SRC';
    NewRoleId := 'TEST-EX-EMPTY';
    HelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl Empty Src');

    // [WHEN]
    ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Test Excl Empty', TempExclusionPerms, false);

    // [THEN]
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), NewRoleId),
      'Wrapper must be created even with no exclusion permissions.');
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), HelperRoleId),
      'Helper set must be created even with no exclusion permissions.');

    TenantPermission.SetRange("App ID", PermTestHelper.NullGuid());
    TenantPermission.SetRange("Role ID", HelperRoleId);
    Assert.AreEqual(0, TenantPermission.Count(), 'Helper set must have zero permissions when none were provided.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
    PermTestHelper.CleanupTenantPermissionSet(HelperRoleId);
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Permission-relevant behavior
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] ReplaceAssignments = false.
  /// [WHEN]  CreateExclusionWrapper is called.
  /// [THEN]  No Access Control entries are created for the new wrapper Role ID.
  /// </summary>
  [Test]
  procedure ExclusionWrapperDoesNotReplaceAccessControlWhenFlagIsFalse()
  var
    ExclusionMgt: Codeunit "Perm. Set Exclusion Mgt.";
    TempExclusionPerms: Record "Tenant Permission" temporary;
    AccessControl: Record "Access Control";
    UserSecurityId: Guid;
    SourceRoleId: Code[20];
    NewRoleId: Code[20];
    HelperRoleId: Code[20];
  begin
    // [GIVEN]
    SourceRoleId := 'TEST-EX-NOREPL-SRC';
    NewRoleId := 'TEST-EX-NOREPL';
    HelperRoleId := 'E-' + CopyStr(NewRoleId, 1, 18);
    UserSecurityId := CreateGuid();
    PermTestHelper.CreateTenantPermissionSet(SourceRoleId, 'Test Excl No Repl Src');
    PermTestHelper.AssignPermSetToUser(UserSecurityId, SourceRoleId);

    // [WHEN]
    ExclusionMgt.CreateExclusionWrapper(SourceRoleId, NewRoleId, 'Test Excl No Repl', TempExclusionPerms, false);

    // [THEN] No Access Control for the new Role ID
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.SetRange("Role ID", NewRoleId);
    Assert.AreEqual(0, AccessControl.Count(), 'Access Control must not be created when ReplaceAssignments=false.');

    // TearDown
    PermTestHelper.RemovePermSetFromUser(UserSecurityId, SourceRoleId);
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
    PermTestHelper.CleanupTenantPermissionSet(HelperRoleId);
    PermTestHelper.CleanupTenantPermissionSet(SourceRoleId);
  end;
}
