
{
  Sub - registration of xTools components: xWage collection
  Copyright (c) 1997 - 98 by Golden Software
}

unit xWage;

interface

  procedure Register;

implementation

{$R xWG_PROV.DCR}

uses
  XWG_PROV,
  xAccount,
  xAcc1;

procedure Register;
begin
  XWG_PROV.Register;
  xaccount.Register;
  xacc1.Register;
end;

end.
