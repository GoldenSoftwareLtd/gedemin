
unit gdcSQLHistory;

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, Controls, DB,
  gdcBaseInterface, IBDataBase, IBSQL;

type
  TgdcSQLHistory = class(TgdcBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function EncodeParamsText(Params: TIBXSQLDA): String;

    procedure DeleteTraceLog;
    procedure DeleteHistory;
  end;

procedure Register;

implementation

uses
  SysUtils, IBHeader,
  flt_SafeConversion_unit,
  gdc_dlgSQLHistory_unit,
  gdc_frmSQLHistory_unit,
  IBSQLMonitor_Gedemin,
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcSQLHistory]);
end;

{ TgdcSQLHistory ------------------------------------------------}

class function TgdcSQLHistory.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'CREATIONDATE';
end;

class function TgdcSQLHistory.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_SQL_HISTORY';
end;

class function TgdcSQLHistory.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmSQLHistory';
end;

class function TgdcSQLHistory.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgSQLHistory';
end;

function TgdcSQLHistory.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCSQLHISTORY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSQLHISTORY', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSQLHISTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSQLHISTORY',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCSQLHISTORY(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSQLHISTORY' then
  {M}        begin
  {M}          Result := inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'ORDER BY z.editiondate DESC, z.id DESC ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSQLHISTORY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSQLHISTORY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcSQLHistory.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCSQLHISTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSQLHISTORY', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSQLHISTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSQLHISTORY',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCSQLHISTORY(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSQLHISTORY' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Format('FROM %s %s JOIN gd_contact c ON %s.creatorkey = c.id',
    [GetListTable(SubType), GetListTableAlias, GetListTableAlias]);
  SQLSetup.Ignores.AddAliasName('c');
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSQLHISTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSQLHISTORY', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcSQLHistory.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCSQLHISTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSQLHISTORY', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSQLHISTORY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSQLHISTORY',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCSQLHISTORY(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSQLHISTORY' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Format('SELECT %s.*, c.name AS creator ', [GetListTableAlias]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSQLHISTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSQLHISTORY', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcSQLHistory.EncodeParamsText(Params: TIBXSQLDA): String;
var
  K: Integer;
  js: TStrings;
  S: String;
begin
  if Params.Count > 0 then
  begin
    js := TStringList.Create;
    try
      for K := 0 to Params.Count - 1 do
      begin
        if js.IndexOfName(Params[K].Name) = -1 then
        begin
          if not Params[K].IsNull then
          begin
            case Params[K].SQLType of
              SQL_TIMESTAMP, SQL_TYPE_DATE, SQL_TYPE_TIME:
                S := SafeDateTimeToStr(Params[K].AsDateTime);
              SQL_SHORT, SQL_LONG, SQL_INT64, SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
                S := SafeFloatToStr(Params[K].AsDouble);
            else
              S := '"' + ConvertSysChars(Params[K].AsString) + '"';
            end;
          end else
            S := '<NULL>';
          js.Add(Params[K].Name + '=' + S);
        end;
      end;
      Result := Trim(js.Text);
    finally
      js.Free;
    end;
  end else
    Result := '';
end;

procedure TgdcSQLHistory.DeleteTraceLog;
var
  OldEnabled: Boolean;
begin
  OldEnabled := MonitorHook.Enabled;
  try
    MonitorHook.Enabled := False;
    ExecSingleQuery('DELETE FROM gd_sql_history WHERE bookmark = ''M'' ');
    CloseOpen;
  finally
    MonitorHook.Enabled := OldEnabled;
  end;
end;

procedure TgdcSQLHistory.DeleteHistory;
var
  OldEnabled: Boolean;
begin
  OldEnabled := MonitorHook.Enabled;
  try
    MonitorHook.Enabled := False;
    ExecSingleQuery('DELETE FROM gd_sql_history WHERE COALESCE(bookmark, '' '') <> ''M'' ');
    CloseOpen;
  finally
    MonitorHook.Enabled := OldEnabled;
  end;
end;

initialization
  RegisterGdcClass(TgdcSQLHistory);

finalization
  UnRegisterGdcClass(TgdcSQLHistory);
end.
