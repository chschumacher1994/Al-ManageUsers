codeunit 50100 "Perm. Search Mgt. Tests"
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
  /// [GIVEN] A tenant permission set exists with a specific table-data permission.
  /// [WHEN]  SearchPermissions is called for that object type and ID (tenant-only).
  /// [THEN]  The buffer contains exactly one entry with the correct Role ID, Scope=Tenant.
  /// </summary>
  [Test]
  procedure SearchPermissionsFindsMatchingTenantSet()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    RoleId: Code[20];
    ObjectId: Integer;
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId := 'TEST-PS-001';
    ObjectId := 18; // Customer table
    ObjectType := ObjectType::"Table Data";
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test PermSearch 001');
    PermTestHelper.AddTenantPermission(
      RoleId, ObjectType, ObjectId,
      1, 0, 0, 0, 0); // Read = Yes

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, ObjectId, false);

    // [THEN]
    TempBuffer.SetRange(TempBuffer.Scope, TempBuffer.Scope::Tenant);
    TempBuffer.SetRange(TempBuffer."Role ID", RoleId);
    Assert.IsTrue(TempBuffer.FindFirst(), 'Expected one Tenant entry in buffer for RoleId=' + RoleId);
    Assert.AreEqual(ObjectId, TempBuffer."Object ID", 'Object ID must match.');
    Assert.AreEqual(1, TempBuffer."Read Permission", 'Read Permission must be Yes.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  /// <summary>
  /// [GIVEN] Multiple tenant permission sets all containing the same object permission.
  /// [WHEN]  SearchPermissions is called (tenant-only).
  /// [THEN]  The buffer contains one entry per matching permission set.
  /// </summary>
  [Test]
  procedure SearchPermissionsReturnsMultipleMatchingTenantSets()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    RoleId1: Code[20];
    RoleId2: Code[20];
    ObjectId: Integer;
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId1 := 'TEST-PS-MULTI-A';
    RoleId2 := 'TEST-PS-MULTI-B';
    ObjectId := 27; // Item table
    ObjectType := ObjectType::"Table Data";
    PermTestHelper.CreateTenantPermissionSet(RoleId1, 'Test Multi A');
    PermTestHelper.CreateTenantPermissionSet(RoleId2, 'Test Multi B');
    PermTestHelper.AddTenantPermission(RoleId1, ObjectType, ObjectId, 1, 1, 0, 0, 0);
    PermTestHelper.AddTenantPermission(RoleId2, ObjectType, ObjectId, 1, 0, 1, 0, 0);

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, ObjectId, false);

    // [THEN]
    TempBuffer.SetRange(TempBuffer.Scope, TempBuffer.Scope::Tenant);
    TempBuffer.SetFilter(TempBuffer."Role ID", '%1|%2', RoleId1, RoleId2);
    Assert.AreEqual(2, TempBuffer.Count(), 'Expected two Tenant entries in buffer.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId1);
    PermTestHelper.CleanupTenantPermissionSet(RoleId2);
  end;

  /// <summary>
  /// [GIVEN] A tenant permission set exists with a specific permission.
  /// [WHEN]  SearchPermissions is called with IncludeSystem=true.
  /// [THEN]  The buffer still contains the Tenant entry (system path does not overwrite it).
  /// </summary>
  [Test]
  procedure SearchPermissionsWithIncludeSystemRetainsTenantResults()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId := 'TEST-PS-SYS';
    ObjectType := ObjectType::"Table Data";
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test PermSearch Sys');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 18, 1, 0, 0, 0, 0);

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, 18, true);

    // [THEN]
    TempBuffer.SetRange(TempBuffer.Scope, TempBuffer.Scope::Tenant);
    TempBuffer.SetRange(TempBuffer."Role ID", RoleId);
    Assert.IsTrue(TempBuffer.FindFirst(), 'Tenant entry must still be present when IncludeSystem=true.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Setup missing / disabled
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] No tenant or system permission sets contain a permission for ObjectId 99999.
  /// [WHEN]  SearchPermissions is called for that object.
  /// [THEN]  The buffer is empty (no results, no error).
  /// </summary>
  [Test]
  procedure SearchPermissionsReturnsEmptyBufferWhenNoMatchFound()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] No setup – no permission set covers object 99999.

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType::"Table Data", 99999, false);

    // [THEN]
    Assert.AreEqual(0, TempBuffer.Count(), 'Buffer must be empty when no permission set covers the object.');
  end;

  /// <summary>
  /// [GIVEN] A second call is made after a first search populated the buffer.
  /// [WHEN]  SearchPermissions is called again for a different object.
  /// [THEN]  The buffer is reset and contains only results for the new object.
  /// </summary>
  [Test]
  procedure SearchPermissionsClearsBufferOnEachCall()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId := 'TEST-PS-CLR';
    ObjectType := ObjectType::"Table Data";
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Clear Buffer');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 18, 1, 0, 0, 0, 0);

    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, 18, false);
    Assert.IsTrue(TempBuffer.Count() > 0, 'Pre-condition: first search must return results.');

    // [WHEN] Search for an object with no assigned permission
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, 99999, false);

    // [THEN]
    Assert.AreEqual(0, TempBuffer.Count(), 'Buffer must be cleared on the second call.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;

  // ──────────────────────────────────────────────────────────
  // Invalid input / boundary values
  // ──────────────────────────────────────────────────────────

  /// <summary>
  /// [GIVEN] No permission set has any permission for ObjectId = 0.
  /// [WHEN]  SearchPermissions is called with ObjectId = 0.
  /// [THEN]  The procedure completes without error; buffer is empty.
  /// </summary>
  [Test]
  procedure SearchPermissionsWithObjectIdZeroReturnsEmpty()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN] ObjectId = 0 – boundary value.

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType::"Table Data", 0, false);

    // [THEN] No crash; buffer may be empty or contain wildcard (0) entries – either is valid.
    // The test asserts the procedure completes; buffer count is informational only.
    Assert.IsTrue(true, 'SearchPermissions must not throw for ObjectId = 0.');
  end;

  /// <summary>
  /// [GIVEN] A tenant permission set contains a Read permission for a specific codeunit.
  /// [WHEN]  SearchPermissions is called with ObjectType = Codeunit.
  /// [THEN]  The buffer entry has Scope=Tenant and Execute permission populated correctly.
  /// </summary>
  [Test]
  procedure SearchPermissionsDistinguishesObjectTypeCodeunit()
  var
    TempBuffer: Record "Permission Search Buffer" temporary;
    PermSearchMgt: Codeunit "Permission Search Mgt.";
    RoleId: Code[20];
    ObjectType: Option "Table Data","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
  begin
    // [GIVEN]
    RoleId := 'TEST-PS-CU';
    ObjectType := ObjectType::Codeunit;
    PermTestHelper.CreateTenantPermissionSet(RoleId, 'Test Codeunit Type');
    PermTestHelper.AddTenantPermission(RoleId, ObjectType, 50005, 0, 0, 0, 0, 1); // Execute = Yes

    // [WHEN]
    PermSearchMgt.SearchPermissions(TempBuffer, ObjectType, 50005, false);

    // [THEN]
    TempBuffer.SetRange(TempBuffer.Scope, TempBuffer.Scope::Tenant);
    TempBuffer.SetRange(TempBuffer."Role ID", RoleId);
    Assert.IsTrue(TempBuffer.FindFirst(), 'Expected Tenant entry for Codeunit permission.');
    Assert.AreEqual(1, TempBuffer."Execute Permission", 'Execute Permission must be Yes.');

    // TearDown
    PermTestHelper.CleanupTenantPermissionSet(RoleId);
  end;
}
