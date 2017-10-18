unit gdc_dlgGMetaData_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls;

type
  Tgdc_dlgGMetaData = class(Tgdc_dlgG)

  protected
    FErrorLine: Integer;
    procedure ExtractErrorLine(const S: String);
    procedure InvalidateForm; virtual;
    procedure ClearError;
    
  public
    constructor Create(AnOwner: TComponent); override;
  end;

var
  gdc_dlgGMetaData: Tgdc_dlgGMetaData;

implementation

uses
  gd_ClassList, at_frmSQLProcess, jclStrings;

{$R *.DFM}

procedure Tgdc_dlgGMetaData.ExtractErrorLine(const S: String);
const
  LineLabel = ' line ';
var
  B: Integer;
  N: String;
begin
  B := StrIPos(LineLabel, S);
  if B > 0 then
  begin
    N := '';
    Inc(B, Length(LineLabel));
    while (B <= Length(S)) and (S[B] in ['0'..'9']) do
    begin
      N := N + S[B];
      Inc(B);
    end;
    FErrorLine := StrToIntDef(N, 1);
  end else
    FErrorLine := 1;
  InvalidateForm;
end;

procedure Tgdc_dlgGMetaData.InvalidateForm;
begin
//
end;

procedure Tgdc_dlgGMetaData.ClearError;
begin
  FErrorLine := -1;
  InvalidateForm;
end;

constructor Tgdc_dlgGMetaData.Create(AnOwner: TComponent);
begin
  inherited;
  FErrorLine := -1;
end;

initialization
  RegisterFrmClass(Tgdc_dlgGMetaData);

finalization
  UnRegisterFrmClass(Tgdc_dlgGMetaData);
end.
