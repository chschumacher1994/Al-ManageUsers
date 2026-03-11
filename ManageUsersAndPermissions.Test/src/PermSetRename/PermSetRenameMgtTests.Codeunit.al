codeunit 50110 "Perm. Set Rename Mgt. Tests"
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
  /// [GIVEN] A user-defined tenant permission set exists with Role ID OLD-ROLE.
  /// [WHEN]  RenamePermissionSet('OLD-ROLE', 'NEW-ROLE') is called.
  /// [THEN]  The old Role ID no longer exists; the new Role ID exists with same Name.
  /// </summary>
  [Test]
  procedure RenamePermissionSetSucceedsForUserDefinedSet()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    TenantPermissionSet: Record "Tenant Permission Set";
    OldRoleId: Code[20];
    NewRoleId: Code[20];
    RoleName: Text[30];
  begin
    // [GIVEN]
    OldRoleId := 'TEST-RN-OLD';
    NewRoleId := 'TEST-RN-NEW';
    RoleName := 'Test Rename PermSet';
    PermTestHelper.CreateTenantPermissionSet(OldRoleId, RoleName);

    // [WHEN]
    RenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);

    // [THEN]
    Assert.IsFalse(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), OldRoleId),
      'Old Role ID must no longer exist after rename.');
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), NewRoleId),
      'New Role ID must exist after rename.');
    Assert.AreEqual(RoleName, TenantPermissionSet.Name, 'Name must be preserved after rename.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  /// <summary>
  /// [GIVEN] A tenant permission set with permissions assigned exists.
  /// [WHEN]  RenamePermissionSet is called.
  /// [THEN]  All Tenant Permission records are migrated to the new Role ID.
  /// </summary>
  [Test]
  procedure RenamePermissionSetMigratesPermissions()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    TenantPermission: Record "Tenant Permission";
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
    OldRoleId: Code[20];
    NewRoleId: Code[20];
  begin
    // [GIVEN]
    OldRoleId := 'TEST-RN-PERM-A';
    NewRoleId := 'TEST-RN-PERM-B';
    PermTestHelper.CreateTenantPermissionSet(OldRoleId, 'Test Migrate Perms');
    PermTestHelper.AddTenantPermission(OldRoleId, ObjectType::"Table Data", 18, 1, 1, 1, 0, 0);
    PermTestHelper.AddTenantPermission(OldRoleId, ObjectType::"Table Data", 27, 1, 0, 0, 0, 0);

    // [WHEN]
    RenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);

    // [THEN]
    TenantPermission.SetRange("App ID", PermTestHelper.NullGuid());
    TenantPermission.SetRange("Role ID", NewRoleId);
    Assert.AreEqual(2, TenantPermission.Count(), 'Both permissions must be migrated to new Role ID.');

    TenantPermission.SetRange("Role ID", OldRoleId);
    Assert.AreEqual(0, TenantPermission.Count(), 'Old Role ID must have no remaining permissions.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  /// <summary>
  /// [GIVEN] A tenant permission set is assigned to a user via Access Control.
  /// [WHEN]  RenamePermissionSet is called.
  /// [THEN]  Access Control entry is updated to the new Role ID.
  /// </summary>
  [Test]
  procedure RenamePermissionSetMigratesAccessControlEntries()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    AccessControl: Record "Access Control";
    UserSecurityId: Guid;
    OldRoleId: Code[20];
    NewRoleId: Code[20];
  begin
    // [GIVEN]
    OldRoleId := 'TEST-RN-AC-A';
    NewRoleId := 'TEST-RN-AC-B';
    UserSecurityId := CreateGuid();
    PermTestHelper.CreateTenantPermissionSet(OldRoleId, 'Test Migrate AC');
    PermTestHelper.AssignPermSetToUser(UserSecurityId, OldRoleId);

    // [WHEN]
    RenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);

    // [THEN]
    AccessControl.SetRange("Role ID", NewRoleId);
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
    Assert.IsTrue(AccessControl.FindFirst(), 'Access Control entry must exist under new Role ID.');

    AccessControl.SetRange("Role ID", OldRoleId);
    Assert.AreEqual(0, AccessControl.Count(), 'No Access Control entries must remain under old Role ID.');

    // TearDown
    AccessControl.SetRange("Role ID", NewRoleId);
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.DeleteAll();
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Setup missing / disabled
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] No tenant permission set exists with the given OldRoleId.
  /// [WHEN]  RenamePermissionSet is called.
  /// [THEN]  An error is raised containing the OldRoleId.
  /// </summary>
  [Test]
  procedure RenameFailsWhenSourcePermSetNotFound()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
  begin
    // [GIVEN] No setup – role 'MISSING-ROLE' does not exist.

    // [WHEN] / [THEN]
    asserterror RenameMgt.RenamePermissionSet('MISSING-ROLE', 'ANY-NEW-ID');
    Assert.ExpectedErrorCode('Dialog');
  end;

  // ──────────────────────────────────────────────────────────
  // Invalid input / boundary values
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] A user-defined tenant permission set exists.
  /// [WHEN]  RenamePermissionSet is called with the same OldRoleId as NewRoleId (same name).
  /// [THEN]  An error is raised because the new Role ID already exists.
  /// </summary>
  [Test]
  procedure RenameFailsWhenNewRoleIdAlreadyExists()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    RoleId: Code[20];
  begin
    // [GIVEN]
    RoleId := 'TEST-RN-DUP';
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Duplicate RoleId');

    // [WHEN] / [THEN] – renaming to same ID triggers "already exists" error
    asserterror RenameMgt.RenamePermissionSet(RoleId, RoleId);
    Assert.ExpectedErrorCode('Dialog');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  /// <summary>
  /// [GIVEN] A user-defined permission set OLD exists; NEW-ROLE already exists as a separate set.
  /// [WHEN]  RenamePermissionSet(OLD, NEW-ROLE) is called.
  /// [THEN]  An error is raised: target Role ID already exists.
  /// </summary>
  [Test]
  procedure RenameFailsWhenTargetRoleIdAlreadyExistsAsDistinctSet()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    OldRoleId: Code[20];
    NewRoleId: Code[20];
  begin
    // [GIVEN]
    OldRoleId := 'TEST-RN-SRC';
    NewRoleId := 'TEST-RN-TGT';
    PermTestHelper.CreateTenantPermissionSet(OldRoleId, 'Test Src');
    PermTestHelper.CreateTenantPermissionSet(NewRoleId, 'Test Tgt Already Exists');

    // [WHEN] / [THEN]
    asserterror RenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);
    Assert.ExpectedErrorCode('Dialog');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(OldRoleId);
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  /// <summary>
  /// [GIVEN] A permission set with the maximum allowed Role ID length (20 chars) exists.
  /// [WHEN]  RenamePermissionSet is called with a valid 20-char new Role ID.
  /// [THEN]  The rename succeeds without truncation errors.
  /// </summary>
  [Test]
  procedure RenameSucceedsWithMaxLengthRoleIds()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
    TenantPermissionSet: Record "Tenant Permission Set";
    OldRoleId: Code[20];
    NewRoleId: Code[20];
  begin
    // [GIVEN] Max 20-char Role IDs
    OldRoleId := 'TEST-MAXLEN-OLD-ROLE';  // exactly 20 chars
    NewRoleId := 'TEST-MAXLEN-NEW-ROLE';  // exactly 20 chars
    PermTestHelper.CreateTenantPermissionSet(OldRoleId, 'Test Max Len RoleId');

    // [WHEN]
    RenameMgt.RenamePermissionSet(OldRoleId, NewRoleId);

    // [THEN]
    Assert.IsTrue(
      TenantPermissionSet.Get(PermTestHelper.NullGuid(), NewRoleId),
      'Rename with max-length Role IDs must succeed.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(NewRoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Permission-relevant behavior
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] An attempt is made to rename a permission set by its OldRoleId
  ///         but only a system (Metadata) set exists with that name—not a tenant set.
  /// [WHEN]  RenamePermissionSet is called.
  /// [THEN]  An error is raised: the set is not found as a user-defined tenant set.
  /// Note: System permission sets cannot be renamed; validation uses App ID = NullGuid().
  /// </summary>
  [Test]
  procedure RenameFailsForNonTenantPermissionSet()
  var
    RenameMgt: Codeunit "Perm. Set Rename Mgt.";
  begin
    // [GIVEN] 'SUPER' is a system (metadata) permission set, not tenant-defined.

    // [WHEN] / [THEN]
    asserterror RenameMgt.RenamePermissionSet('SUPER', 'SUPER-RENAMED');
    Assert.ExpectedErrorCode('Dialog');
  end;
}
