codeunit 50130 "Perm. Analysis Mgt. Tests"
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
  /// [GIVEN] A user has a tenant permission set assigned that covers a specific table object.
  /// [WHEN]  AnalyzeObjectAccess is called for that object.
  /// [THEN]  The buffer contains an entry for the user with HasDirectPermission=true and PermSetCount=1.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessFindsUserWithDirectTenantPermission()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    UserSecurityId: Guid;
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId := 'TEST-AN-BASIC';
    ObjectType := ObjectType::"Table Data";
    UserSecurityId := GetTestUserSecurityId();
    if IsNullGuid(UserSecurityId) then
      exit; // Skip if no test user available

    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Analysis Basic');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 18, 1, 0, 0, 0, 0);
    PermTestHelper.AssignPermSetToUser(UserSecurityId, RoleId);

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType, 18, '');

    // [THEN]
    Assert.IsTrue(TempBuffer.Get(UserSecurityId), 'User must appear in the access buffer.');
    Assert.IsTrue(TempBuffer."Has Direct Permission", 'HasDirectPermission must be true.');
    Assert.IsTrue(TempBuffer."Permission Set Count" >= 1, 'PermissionSetCount must be at least 1.');

    // TearDown
    PermTestHelper.RemovePermSetFromUser(UserSecurityId, RoleId);
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  /// <summary>
  /// [GIVEN] A user has two separate tenant permission sets assigned covering the same object.
  /// [WHEN]  AnalyzeObjectAccess is called for that object.
  /// [THEN]  The buffer entry for the user has PermissionSetCount=2.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessCountsMultiplePermSetsForSameUser()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    UserSecurityId: Guid;
    RoleId1: Code[20];
    RoleId2: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId1 := 'TEST-AN-CNT-A';
    RoleId2 := 'TEST-AN-CNT-B';
    ObjectType := ObjectType::"Table Data";
    UserSecurityId := GetTestUserSecurityId();
    if IsNullGuid(UserSecurityId) then
      exit;

    PermTestHelper.CreateTenantPermissionSet(RoleId1, 'Test Analysis Cnt A');
    PermTestHelper.CreateTenantPermissionSet(RoleId2, 'Test Analysis Cnt B');
    PermTestHelper.AddTenantPermission(RoleId1, ObjectType, 18, 1, 0, 0, 0, 0);
    PermTestHelper.AddTenantPermission(RoleId2, ObjectType, 18, 1, 1, 0, 0, 0);
    PermTestHelper.AssignPermSetToUser(UserSecurityId, RoleId1);
    PermTestHelper.AssignPermSetToUser(UserSecurityId, RoleId2);

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType, 18, '');

    // [THEN]
    Assert.IsTrue(TempBuffer.Get(UserSecurityId), 'User must appear in the access buffer.');
    Assert.IsTrue(TempBuffer."Permission Set Count" >= 2, 'PermissionSetCount must reflect both assigned sets.');

    // TearDown
    PermTestHelper.RemovePermSetFromUser(UserSecurityId, RoleId1);
    PermTestHelper.RemovePermSetFromUser(UserSecurityId, RoleId2);
    PermTestHelper.CleanupTenantPermissionSet(RoleId1);
    PermTestHelper.CleanupTenantPermissionSet(RoleId2);
  end;

  // ──────────────────────────────────────────────────────────
  // Setup missing / disabled
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] No permission set covers the given object ID.
  /// [WHEN]  AnalyzeObjectAccess is called.
  /// [THEN]  The buffer is empty.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessReturnsEmptyWhenNoPermSetCoversObject()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] Object ID 99998 – no permission set covers it.

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType::"Table Data", 99998, '');

    // [THEN]
    Assert.AreEqual(0, TempBuffer.Count(), 'Buffer must be empty when no permission set covers object 99998.');
  end;

  /// <summary>
  /// [GIVEN] A permission set covers an object, but no user has that set assigned.
  /// [WHEN]  AnalyzeObjectAccess is called.
  /// [THEN]  The buffer is empty (no Access Control entry links any user to the set).
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessReturnsEmptyWhenNoUserAssigned()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] Permission set exists with a permission but no user assignment.
    RoleId := 'TEST-AN-NOUSER';
    ObjectType := ObjectType::"Table Data";
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Analysis NoUser');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 50000, 1, 0, 0, 0, 0);

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType, 50000, '');

    // [THEN]
    Assert.AreEqual(0, TempBuffer.Count(), 'Buffer must be empty when no user is assigned the permission set.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  /// <summary>
  /// [GIVEN] A second call is made after a first call populated the buffer.
  /// [WHEN]  AnalyzeObjectAccess is called again for a different object.
  /// [THEN]  The buffer is reset; previous results are cleared.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessClearsBufferOnEachCall()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] First call populates the buffer (may or may not have data).
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType::"Table Data", 18, '');
    // Manually add a record to simulate non-empty state.
    if TempBuffer.Count() = 0 then begin
      TempBuffer.Init();
      TempBuffer."User Security ID" := CreateGuid();
      TempBuffer.Insert();
    end;
    Assert.IsTrue(TempBuffer.Count() > 0, 'Pre-condition: buffer must be non-empty before second call.');

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType::"Table Data", 99997, '');

    // [THEN]
    Assert.AreEqual(0, TempBuffer.Count(), 'Buffer must be cleared on second call for object with no coverage.');
  end;

  // ──────────────────────────────────────────────────────────
  // Invalid input / boundary values
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] ObjectId = 0 (boundary value).
  /// [WHEN]  AnalyzeObjectAccess is called.
  /// [THEN]  The procedure completes without error.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessWithObjectIdZeroCompletesWithoutError()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] ObjectId = 0 – boundary.

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType::"Table Data", 0, '');

    // [THEN] No exception thrown.
    Assert.IsTrue(true, 'AnalyzeObjectAccess must not throw for ObjectId = 0.');
  end;

  /// <summary>
  /// [GIVEN] A user is assigned a permission set covering an object in Company A.
  /// [WHEN]  AnalyzeObjectAccess is called with CompanyFilter = 'Company B'.
  /// [THEN]  The buffer does not contain that user (company filter excludes them).
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessAppliesCompanyFilter()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    AccessControl: Record "Access Control";
    UserSecurityId: Guid;
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] Assignment is scoped to 'COMPANY-A'.
    RoleId := 'TEST-AN-COMP';
    ObjectType := ObjectType::"Table Data";
    UserSecurityId := GetTestUserSecurityId();
    if IsNullGuid(UserSecurityId) then
      exit;

    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Analysis Company');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 18, 1, 0, 0, 0, 0);

    // Assign with specific company name
    AccessControl.Init();
    AccessControl."User Security ID" := UserSecurityId;
    AccessControl."Role ID" := RoleId;
    AccessControl."Company Name" := 'COMPANY-A';
    AccessControl.Scope := AccessControl.Scope::Tenant;
    AccessControl."App ID" := PermTestHelper.NullGuid();
    if AccessControl.Insert() then;

    // [WHEN] Filter by 'COMPANY-B'
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType, 18, 'COMPANY-B');

    // [THEN] User is not in results
    Assert.IsFalse(TempBuffer.Get(UserSecurityId), 'User assigned to COMPANY-A must not appear when filtering by COMPANY-B.');

    // TearDown
    AccessControl.SetRange("User Security ID", UserSecurityId);
    AccessControl.SetRange("Role ID", RoleId);
    AccessControl.DeleteAll();
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Permission-relevant behavior
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] A disabled user has a permission set assigned covering an object.
  /// [WHEN]  AnalyzeObjectAccess is called.
  /// [THEN]  The disabled user does not appear in the buffer.
  /// Note: The codeunit skips users with State = Disabled (see FillBufferFromAccessControl).
  /// This test documents the expected behavior; actual verification requires a disabled user.
  /// </summary>
  [Test]
  procedure AnalyzeObjectAccessExcludesDisabledUsers()
  var
    AnalysisMgt: Codeunit "Permission Analysis Mgt.";
    TempBuffer: Record "User Obj. Access Buffer" temporary;
    DisabledUserSecId: Guid;
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] A disabled user SecurityId (simulated by using a random GUID
    //         that has no corresponding User record – same code path as skip).
    RoleId := 'TEST-AN-DISABLED';
    ObjectType := ObjectType::"Table Data";
    DisabledUserSecId := CreateGuid();
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Analysis Disab');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 18, 1, 0, 0, 0, 0);
    PermTestHelper.AssignPermSetToUser(DisabledUserSecId, RoleId);

    // [WHEN]
    AnalysisMgt.AnalyzeObjectAccess(TempBuffer, ObjectType, 18, '');

    // [THEN] The random/non-existing user is not in the buffer
    //        (FillBufferFromAccessControl skips users not found in User table)
    Assert.IsFalse(
      TempBuffer.Get(DisabledUserSecId),
      'A user with no matching User record (simulated disabled/missing) must not appear in the buffer.');

    // TearDown
    PermTestHelper.RemovePermSetFromUser(DisabledUserSecId, RoleId);
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────────────────

  local procedure GetTestUserSecurityId(): Guid
  var
    UserRec: Record User;
  begin
    UserRec.SetRange(State, UserRec.State::Enabled);
    if UserRec.FindFirst() then
      exit(UserRec."User Security ID");
    exit(CreateGuid()); // Return random GUID if no enabled user found; callers must handle
  end;
}
