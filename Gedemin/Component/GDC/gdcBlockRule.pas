unit gdcBlockRule;

interface

uses
  SysUtils, Classes, gd_ClassList, gdcBase,
  gdcBaseInterface, gdcClasses;

type

  TgdcBlockRule = class(TgdcBase)
    public
      class function GetListTable(const ASubType: TgdcSubType) : String;
        override;
      class function GetViewFormClassName(const ASubType: TgdcSubType) : String;
        override;
      class function GetDialogFormClassName(const ASubType: TgdcSubType) : String;
        override;
      class function GetListField(const ASubType: TgdcSubType): String; override;
    end;

procedure Register;

implementation

uses
  gdc_frmBlockRule_unit, gdc_dlgBlockRule_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcBlockRule]);
end;

class function TgdcBlockRule.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_BLOCK_RULE';
end;

class function TgdcBlockRule.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmBlockRule';
end;

class function TgdcBlockRule.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgBlockRule';
end;

class function TgdcBlockRule.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

initialization
  RegisterGdcClass(TgdcBlockRule);

finalization
  UnRegisterGdcClass(TgdcBlockRule);

end.
