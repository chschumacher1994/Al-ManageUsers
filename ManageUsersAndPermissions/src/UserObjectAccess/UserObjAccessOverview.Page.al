page 50014 "User Obj. Access Overview"
{
  Caption = 'User Object Access Overview';
  PageType = Worksheet;
  UsageCategory = Administration;
  ApplicationArea = All;
  InsertAllowed = false;
  DeleteAllowed = false;
  ModifyAllowed = false;

  permissions = tabledata "Access Control" = r,
                tabledata "User" = r;

  layout
  {
    area(Content)
    {
      group(Filters)
      {
        Caption = 'Filter';

        field(ObjectTypeFilter; ObjectTypeFilter)
        {
          ApplicationArea = All;
          Caption = 'Object Type';
          ToolTip = 'Specifies the type of AL object to analyze user access for.';
        }
        field(ObjectIdFilter; ObjectIdFilter)
        {
          ApplicationArea = All;
          Caption = 'Object ID';
          ToolTip = 'Specifies the ID of the object to analyze user access for.';
        }
        field(CompanyFilterField; CompanyFilter)
        {
          ApplicationArea = All;
          Caption = 'Company Filter';
          ToolTip = 'Specifies an optional company name to restrict the analysis. Leave blank to include all companies.';
          TableRelation = Company.Name;
        }
      }
      part(UserListPart; "User Obj. Access User List")
      {
        ApplicationArea = All;
        Caption = 'Users with Access';
        UpdatePropagation = Both;
      }
      part(PermSetListPart; "User Obj. Access Perm. Sets")
      {
        ApplicationArea = All;
        Caption = 'Assigned Permission Sets';
        UpdatePropagation = Both;
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(Analyze)
      {
        ApplicationArea = All;
        Caption = 'Analyze Access';
        ToolTip = 'Analyzes which enabled users have access to the specified object through their directly assigned permission sets.';
        Image = Find;
        Promoted = true;
        PromotedCategory = Process;
        PromotedIsBig = true;

        trigger OnAction()
        begin
          RunAnalysis();
        end;
      }
    }
  }

  trigger OnAfterGetCurrRecord()
  begin
    RefreshPermSetFilter();
  end;

  local procedure RunAnalysis()
  var
    PermissionAnalysisMgt: Codeunit "Permission Analysis Mgt.";
  begin
    PermissionAnalysisMgt.AnalyzeObjectAccess(TempUserObjAccessBuffer, ObjectTypeFilter, ObjectIdFilter, CompanyFilter);
    CurrPage.UserListPart.Page.SetBuffer(TempUserObjAccessBuffer);
    RefreshPermSetFilter();
  end;

  local procedure RefreshPermSetFilter()
  var
    CurrentUserId: Guid;
  begin
    CurrentUserId := CurrPage.UserListPart.Page.GetCurrentUserSecurityId();
    CurrPage.PermSetListPart.Page.SetUserFilter(CurrentUserId);
  end;

  var
    TempUserObjAccessBuffer: Record "User Obj. Access Buffer" temporary;
    ObjectTypeFilter: Option "Table Data",Table,,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System",,,,,,,,;
    ObjectIdFilter: Integer;
    CompanyFilter: Text[30];
}
