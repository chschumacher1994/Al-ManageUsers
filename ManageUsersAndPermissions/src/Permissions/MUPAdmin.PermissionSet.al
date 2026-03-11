permissionset 50040 "MUP - ADMIN"
{
  Assignable = true;
  Caption = 'MUP - Admin', Locked = false;
  Permissions =
    tabledata "Permission Search Buffer" = RIMD,
    tabledata "User Obj. Access Buffer" = RIMD,
    codeunit "Perm. Set Rename Mgt." = X,
    codeunit "Perm. Set Exclusion Mgt." = X,
    codeunit "Permission Analysis Mgt." = X,
    codeunit "Permission Search Mgt." = X,
    page "Perm. Set Rename Wizard" = X,
    page "Perm. Set Exclusion Wizard" = X,
    page "Perm. Set Exclusion Src. List" = X,
    page "Permission Search" = X,
    page "User Obj. Access Overview" = X,
    page "User Obj. Access User List" = X,
    page "User Obj. Access Perm. Sets" = X,
    report "User Permission Overview" = X,
    report "Permission Set Usage" = X,
    report "Permission Search" = X;
}
