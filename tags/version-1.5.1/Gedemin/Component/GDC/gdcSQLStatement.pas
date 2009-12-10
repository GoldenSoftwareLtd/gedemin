
unit gdcSQLStatement;

interface

uses
  Classes, gdcBase, gdcBaseInterface;

type
  TgdcSQLStatement = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    function GetCanCreate: Boolean; override;
    function GetCanEdit: Boolean; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList, gdc_frmSQLStatement_unit, gdc_dlgSQLStatement_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcSQLStatement]);
end;

{ TgdcSQLStatement }

function TgdcSQLStatement.GetCanCreate: Boolean;
begin
  Result := False;
end;

function TgdcSQLStatement.GetCanEdit: Boolean;
begin
  Result := False;
end;

class function TgdcSQLStatement.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgSQLStatement';
end;

class function TgdcSQLStatement.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcSQLStatement.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'GD_SQL_STATEMENT';
end;

class function TgdcSQLStatement.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmSQLStatement';
end;

initialization
  RegisterGDCClasses([TgdcSQLStatement]);

finalization
  UnRegisterGDCClasses([TgdcSQLStatement]);
end.
 