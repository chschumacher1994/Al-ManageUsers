permissionset 50041 "MUP - VIEW"
{
  Assignable = true;
  Caption = 'MUP - View', Locked = false;
  Permissions =
    tabledata "Permission Search Buffer" = R,
    tabledata "User Obj. Access Buffer" = R,
    codeunit "Permission Analysis Mgt." = X,
    codeunit "Permission Search Mgt." = X,
    page "Permission Search" = X,
    page "User Obj. Access Overview" = X,
    page "User Obj. Access User List" = X,
    page "User Obj. Access Perm. Sets" = X,
    report "User Permission Overview" = X,
    report "Permission Set Usage" = X,
    report "Permission Search" = X;
}
