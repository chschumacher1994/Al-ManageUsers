# Implementation Plan: ManageUsersAndPermissions

## Status: COMPLETE
Last updated: 2026-03-11

## Feature Summary
Extension für Microsoft Dynamics 365 Business Central (BC 28, SaaS), die die Verwaltung von Benutzerkonten und Berechtigungssätzen vereinfacht. Neue Funktionen: Umbenennen von Berechtigungssätzen (Role ID-Migration), Suche welche Sätze eine bestimmte Berechtigung enthalten, Erstellen von Exclusion-Wrapper-Sätzen ohne das Original zu verändern, eine Übersichtsseite die zeigt welche Benutzer Zugriff auf ein Objekt haben und warum, sowie Berichte über Berechtigungsstrukturen.

## MCP Research Summary
BC Version: **28.0.46665** | Zielumgebung: **Cloud Sandbox (SaaS)**

| Standard-Objekt | ID | Paket | Verwendung |
|---|---|---|---|
| `Tenant Permission Set` | Table 2000000165 | System | Tenant-Sätze, PK: App ID + Role ID (Code[20]) |
| `Tenant Permission` | Table 2000000166 | System | Einzelberechtigungen, PK: App ID + Role ID + Object Type + Object ID |
| `Tenant Permission Set Rel.` | Table 2000000253 | System | Include/Exclude-Beziehungen zwischen Sätzen |
| `Access Control` | Table 2000000053 | System | Benutzerzuweisungen, Key: User Security ID + Role ID + Company + Scope + App ID |
| `Aggregate Permission Set` | Table 2000000167 | System (Virtual) | Unified-Lookup über System + Tenant |
| `Metadata Permission Set` | Table 2000000250 | System (Virtual) | Read-only Systemsätze |
| `User` | Table 2000000120 | System | Benutzerkonten |
| `Permission Set Relation` | Codeunit 9855 | System App | Public facade: CopyPermissionSet, AddNewPermissionSetRelation |
| `Permission Set Copy Impl.` | Codeunit 9863 | System App | CopyPermissionSet mit CopyType-Enum |
| `User Permissions` | Codeunit 152 | System App | IsSuper, AssignPermissionSets, GetEffectivePermission |
| `Permission Set Tree` | Page 9857 | System App | ListPart, SourceTable 9861 (Internal) |
| `Permission Sets` | Page 9802 | Base App | Haupt-Übersichtsseite, Extension-Ziel |

**Kritische Einschränkungen:**
- `Permission Set Relation Buffer` (Table 9861) hat `Access = Internal` → Page 9857 kann als SubPage eingebettet, aber nicht von außen befüllt werden. Nach Implementierung verifizieren; ggf. Fallback `PermSetHierarchy.Page.al` (Pg 50017).
- `Role ID` ist Primärschlüssel → Umbenennen = vollständige Datenmigration.
- Nur `Tenant`-Berechtigungssätze (nicht System/Extension) sind modifizierbar.

## ID-Register

| ID | Table | Codeunit | Page | PageExt | Report | PermSet |
|---|---|---|---|---|---|---|
| 50000 | PermissionSearchBuffer | – | – | – | – | – |
| 50001 | UserObjAccessBuffer | – | – | – | – | – |
| 50002 | – | PermSetRenameMgt | – | – | – | – |
| 50003 | – | PermSetExclusionMgt | – | – | – | – |
| 50004 | – | PermissionAnalysisMgt | – | – | – | – |
| 50005 | – | PermissionSearchMgt | – | – | – | – |
| 50010 | – | – | PermSetRenameWizard | – | – | – |
| 50011 | – | – | PermSetExclusionWizard | – | – | – |
| 50012 | – | – | PermSetExclusionSrcList | – | – | – |
| 50013 | – | – | PermissionSearch | – | – | – |
| 50014 | – | – | UserObjAccessOverview | – | – | – |
| 50015 | – | – | UserObjAccessUserList | – | – | – |
| 50016 | – | – | UserObjAccessPermSetList | – | – | – |
| 50017 | – | – | PermSetHierarchy (Fallback) | – | – | – |
| 50020 | – | – | – | PermissionSets | – | – |
| 50030 | – | – | – | – | UserPermission | – |
| 50031 | – | – | – | – | PermissionSetUsage | – |
| 50032 | – | – | – | – | PermissionSearch | – |
| 50040 | – | – | – | – | – | MUPAdmin |
| 50041 | – | – | – | – | – | MUPView |

---

## Implementation Steps

### Step 0: Projektbereinigung & Setup — ✅ DONE
**Files**: `app.json`, `HelloWorld.al`
**Description**: `application` auf 28.0.0.0 aktualisiert, Dependencies (System App, Base App, Business Foundation) hinzugefügt, HelloWorld-Platzhalter entfernt.
**Dependencies**: –
**Notes**: HelloWorld.al wurde durch einen leeren Kommentar ersetzt (kein Delete-Tool verfügbar). Kann später physisch gelöscht werden.

---

### Step 1: Temporäre Buffer-Tabellen — ✅ DONE
**Files**:
- `src/PermissionSearch/PermissionSearchBuffer.Table.al` (Table 50000)
- `src/UserObjectAccess/UserObjAccessBuffer.Table.al` (Table 50001)

**Description**: Zwei temporäre Buffer-Tabellen als Datenfundament für M2 (Berechtigungssuche) und M4 (Benutzerzugriffs-Übersicht). Kompilierung erfolgreich – 0 Fehler, 0 Warnungen.
**Dependencies**: Step 0
**Notes**:
- `PermissionSearchBuffer` PK = `(Scope, Role ID, Object Type, Object ID)` – composite, kein Entry No. nötig
- `Object Type` OptionMembers exakt wie `Tenant Permission` (numerische Positionen kompatibel für direkte Zuweisung)
- Permission-Optionen `(" ", Yes, Indirect)` matchen `Tenant Permission`-Werte
- User-Felder in `UserObjAccessBuffer` mit GDPR-konformer DataClassification

---

### Step 2: M2 – Berechtigungssuche (Codeunit + Page) — ✅ DONE
**Files**:
- `src/PermissionSearch/PermissionSearchMgt.Codeunit.al` (Codeunit 50005)
- `src/PermissionSearch/PermissionSearch.Page.al` (Page 50013)

**Description**: Suche welche Berechtigungssätze ein bestimmtes Objekt enthalten. Codeunit scannt `Tenant Permission` + optional `Metadata Permission Set`. Page mit Filter-FastTab (Object Type, Object ID, Include System) und Ergebnisliste.
**Dependencies**: Step 1 (Table 50000)
**Notes**:
- `Permissions` im Codeunit-Header: `tabledata "Tenant Permission" = r, tabledata "Metadata Permission Set" = r`
- Befüllung nur bei explizitem „Suchen"-Action, nicht OnAfterGetRecord (Performance)
- Object Name aus `AllObjWithCaption` im Codeunit befüllen (kein FlowField wegen Temp-Table)

---

### Step 3: M1 – Permission Set Rename (Codeunit + Wizard) — ✅ DONE
**Files**:
- `src/PermissionSetManagement/PermSetRenameMgt.Codeunit.al` (Codeunit 50002)
- `src/PermissionSetManagement/PermSetRenameWizard.Page.al` (Page 50010)

**Description**: Role ID eines Tenant-Berechtigungssatzes umbenennen inkl. Migration aller Referenzen in `Tenant Permission`, `Tenant Permission Set Rel.` und `Access Control`. 3-Schritte NavigatePage als UI.
**Dependencies**: Step 0
**Notes**:
- `Permissions`: `tabledata "Tenant Permission Set" = rimd, tabledata "Tenant Permission" = rimd, tabledata "Tenant Permission Set Rel." = rimd, tabledata "Access Control" = rimd`
- Alle 5 Migrationsschritte in einer Transaktion; TryFunction als Wrapper
- Integration Events: `OnBeforeRenamePermissionSet`, `OnAfterRenamePermissionSet`
- KEIN `Permission Set Copy Impl.CopyPermissionSet`-Aufruf (CopyType-Enum nicht verifiziert) → direkte Tabellenmanipulation
- Nur für `Type = "User-Defined"` (Tenant) erlaubt

---

### Step 4: M3 – Exclusion Wrapper (Codeunit + Wizard) — ✅ DONE
**Files**:
- `src/PermissionSetManagement/PermSetExclusionMgt.Codeunit.al` (Codeunit 50003)
- `src/PermissionSetManagement/PermSetExclusionSrcList.Page.al` (Page 50012)
- `src/PermissionSetManagement/PermSetExclusionWizard.Page.al` (Page 50011)

**Description**: Erstellt einen neuen Berechtigungssatz, der den Quellsatz per Include einbindet und einen kleinen Hilfs-Exclusion-Satz per Exclude ausschließt. Ersetzt optional alle Access Control-Zuweisungen.
**Dependencies**: Step 0, Step 3 (Muster)
**Notes**:
- Exclusion-Hilfssatz-RoleId = `'E-' + Left(NewRoleId, 18)` (max. 20 Zeichen)
- Direkte `Tenant Permission Set Rel.`-Manipulation (kein Impl.-Codeunit nötig)
- Wizard Schritt 1 bettet `PermSetExclusionSrcList` (ListPart) ein für Multi-Select
- `Permissions`: `tabledata "Tenant Permission Set" = ri, tabledata "Tenant Permission" = rim, tabledata "Tenant Permission Set Rel." = ri, tabledata "Access Control" = m`

---

### Step 5: M4 – Permission Analysis Codeunit — ✅ DONE
**Files**:
- `src/UserObjectAccess/PermissionAnalysisMgt.Codeunit.al` (Codeunit 50004)

**Description**: Logik zur Befüllung von `UserObjAccessBuffer`. Ermittelt alle Benutzer, die über irgendeine direkte Zuweisung Zugriff auf ein gefiltertes Objekt haben.
**Dependencies**: Step 1 (Table 50001)
**Notes**:
- Initiale Version: nur direkte `Access Control`-Zuweisungen (Security Groups Phase 2)
- `SetLoadFields` konsequent bei jedem `Get`/`Find`
- `Permissions`: `tabledata "Tenant Permission" = r, tabledata "Metadata Permission Set" = r, tabledata "Access Control" = r, tabledata "User" = r`

---

### Step 6: M4 – User/Object Access Overview UI — ✅ DONE
**Files**:
- `src/UserObjectAccess/UserObjAccessUserList.Page.al` (Page 50015)
- `src/UserObjectAccess/UserObjAccessPermSetList.Page.al` (Page 50016)
- `src/UserObjectAccess/UserObjAccessOverview.Page.al` (Page 50014)
- *(optional)* `src/UserObjectAccess/PermSetHierarchy.Page.al` (Page 50017)

**Description**: Worksheet-Page mit Filter-FastTab, Benutzer-ListPart (Quelle: UserObjAccessBuffer), Berechtigungssätze-ListPart (Quelle: Access Control), und Permission Set Tree (Page 9857 oder Fallback).
**Dependencies**: Step 1 (Tb 50001), Step 5 (Cu 50004)
**Notes**:
- Page 9857 als SubPage einbetten und nach Implementierung testen → falls Tree nicht befüllt wird: Fallback Page 50017 via `Tenant Permission Set Rel.` direkt
- `UpdatePropagation = Both` auf allen Parts

---

### Step 7: Extensions – Aktionen auf Standard-Pages — ✅ DONE
**Files**:
- `src/Extensions/PermissionSets.PageExt.al` (PageExt 50020)

**Description**: Erweitert Page 9802 (Permission Sets) um Aktionen für Rename, Exclusion Wrapper, Berechtigungssuche, User Access Overview und PermissionSetUsage-Report.
**Dependencies**: Steps 2, 3, 4, 6
**Notes**:
- `RenamePermissionSet.Enabled` und `CreateExclusionWrapper.Enabled` nur wenn `Rec.Type = Rec.Type::"User-Defined"`
- Alle Aktionen in einer `ActionGroup("Manage Permissions")` unter `Processing`

---

### Step 8: Reports — ✅ DONE
**Files**:
- `src/Reports/UserPermission.Report.al` (Report 50030)
- `src/Reports/PermissionSetUsage.Report.al` (Report 50031)
- `src/Reports/PermissionSearch.Report.al` (Report 50032)

**Description**: Drei Berichte: (1) Benutzer + ihre Berechtigungssätze, (2) Berechtigungssätze + zugewiesene Benutzer, (3) Suche welche Sätze ein Objekt enthalten.
**Dependencies**: Steps 2, 5
**Notes**: Report 50032 nutzt `PermissionSearchMgt` (Cu 50005) für Datenbeschaffung.

---

### Step 9: Berechtigungssätze — ✅ DONE
**Files**:
- `src/Permissions/MUPAdmin.PermissionSet.al` (PermissionSet 50040)
- `src/Permissions/MUPView.PermissionSet.al` (PermissionSet 50041)

**Description**: `MUP - ADMIN` (voller Zugriff auf alle Extension-Objekte), `MUP - VIEW` (Lesezugriff auf Analyse- und Suchseiten).
**Dependencies**: Alle vorherigen Steps (IDs müssen bekannt sein)
**Notes**: Nach finaler Kompilierung alle Objekt-IDs aus dem ID-Register eintragen.

---

## Open Questions
- **Page 9857 Einbettung**: Lässt sich der Permission Set Tree korrekt befüllen, wenn er aus Page 50016 heraus via SubPageLink eingebettet wird? Muss in Live-Umgebung verifiziert werden.
- **Security Groups**: Sollen Berechtigungssätze, die über Security Group-Mitgliedschaft zugewiesen sind, in M4 (Step 5/6) auch angezeigt werden? Aktuell: nur direkte `Access Control`-Zuweisungen. Security Groups wären Phase 2.
- ~~**HelloWorld.al**: Physisch löschen~~ → Erledigt, Datei existiert nicht mehr.

## Decisions Log
| # | Entscheidung | Begründung | Datum |
|---|---|---|---|
| 1 | `PermissionSearchBuffer` PK = composite (Scope + Role ID + Object Type + Object ID) statt Entry No. | Eindeutigkeit natürlich abgebildet, kein Counter-Management nötig, PK-Verletzung schützt vor Duplikaten | 2026-03-10 |
| 2 | Kein `Permission Set Copy Impl.CopyPermissionSet`-Aufruf in Step 3 | `PermissionSetCopyType`-Enum konnte nicht via MCP verifiziert werden; direkte Tabellenmanipulation ist sicherer und kontrollierbarer | 2026-03-10 |
| 3 | `Object Type` OptionMembers exakt wie `Tenant Permission` (20 Werte, 0–19) | Direkte Feldzuweisung `Buf."Object Type" := TenantPerm."Object Type"` ohne Konvertierung | 2026-03-10 |
| 4 | Security Groups in M4 erst Phase 2 | Initiale Komplexität begrenzen; direkte Access Control-Zuweisungen decken den Hauptanwendungsfall ab | 2026-03-10 |
| 5 | `app.json application` auf 28.0.0.0 aktualisiert (war 22.0.0.0) | Symbols sind BC 28; Mismatch hätte zu Symbol-Auflösungsfehlern geführt | 2026-03-10 |
