unit gdcBlockRule;

interface

uses
  SysUtils, Classes, gd_ClassList, gdcBase,
  gdcBaseInterface, gdcClasses;

type

  TgdcBlockRule = class(TgdcBase)
    protected
      function GetOrderClause: String; override;
    public
      class function GetListTable(const ASubType: TgdcSubType) : String;
        override;
      class function GetViewFormClassName(const ASubType: TgdcSubType) : String;
        override;
      class function GetDialogFormClassName(const ASubType: TgdcSubType) : String;
        override;
      class function GetListField(const ASubType: TgdcSubType): String; override;
      class function GetSubSetList: String; override;
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

class function TgdcBlockRule.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByOrder;';
end;

function TgdcBlockRule.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCCURRRATE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBLOCKRULE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBLOCKRULE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBLOCKRULE',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRRATE' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubset('ByOrder') then
    Result := 'ORDER BY ORDR';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBLOCKRULE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcBlockRule);

finalization
  UnRegisterGdcClass(TgdcBlockRule);

end.
