unit gdcAutoTask;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcAutoTask = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAutoTaskLog = class(TgdcBase)
  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetSubSetList: String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gd_AutoTaskThread, gdc_frmAutoTask_unit, gdc_dlgAutoTask_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAutoTask, TgdcAutoTaskLog]);
end;

{ TgdcAutoTask }

class function TgdcAutoTask.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAutoTask';
end;

class function TgdcAutoTask.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAutoTask';
end;

class function TgdcAutoTask.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_AUTOTASK';
end;

class function TgdcAutoTask.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

{ TgdcAutoTaskLog }

class function TgdcAutoTaskLog.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_AUTOTASK_LOG';
end;

class function TgdcAutoTaskLog.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcAutoTaskLog.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAutoTask;';
end;

procedure TgdcAutoTaskLog.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByAutoTask') then
    S.Add('Z.AUTOTASKKEY = :AUTOTASKKEY');
end;

function TgdcAutoTaskLog.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCAUTOTASKLOG', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASKLOG', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASKLOG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASKLOG',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASKLOG' then
  {M}        begin
  {M}          Result := inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet('ByAutoTask') then
    Result := ' ORDER BY z.creationdate DESC ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASKLOG', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASKLOG', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGDCClass(TgdcAutoTask);
  RegisterGDCClass(TgdcAutoTaskLog);

finalization
  UnregisterGdcClass(TgdcAutoTask);
  UnRegisterGDCClass(TgdcAutoTaskLog);
end.
