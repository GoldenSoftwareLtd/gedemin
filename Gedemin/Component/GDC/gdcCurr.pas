// ShlTanya, 10.02.2019

{

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  ������

  TgdcCurr          - ������
  TgdcCurrRate      - ����� �����

  Revisions history

    1.00    29.10.00    sai        Initial version.
            10.01.02    Julie      ��������� ����� TgdcCurrRate
}

unit gdcCurr;

interface

uses
  Classes, gdcBase, Forms, Controls, DB, gdcBaseInterface, IBDataBase;

type
  TgdcCurr = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
  end;

  TgdcCurrRate = class(TgdcBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    function GetOrderClause: String; override;

    procedure CreateFields; override;

    procedure GetWhereClauseConditions(S: TStrings);override;

  public
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
  end;

  // ���������� ���� ������
  {
  function gs_GetCurrRate(const DocumentDate: TDateTime; const CurrKey: Integer;
    Transaction: TIBTransaction): Double;
  }

  procedure Register;

implementation

uses
  IBSQL,
  IBCustomDataSet,
  SysUtils,

  AcctUtils,

  gdc_dlgCurr_unit,
  gdc_dlgCurrRate_unit,

  gdc_frmCurr_unit,
  gdc_frmCurrOnly_unit,
  gd_ClassList,
  gd_directories_const;

const
  cst_ss_ByFromCurrency = 'ByFromCurrency';
  cst_ss_ByToCurrForDate = 'ByToCurrForDate';

procedure Register;
begin
  RegisterComponents('gdc', [TgdcCurr]);
  RegisterComponents('gdc', [TgdcCurrRate]);
end;

{
function gs_GetCurrRate(const DocumentDate: TDateTime; const CurrKey: Integer;
  Transaction: TIBTransaction): Double;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    if Assigned(Transaction) and Transaction.InTransaction then
      q.Transaction := Transaction
    else
      q.Transaction := gdcBaseManager.ReadTransaction;

    q.SQL.Text :=
      'SELECT c.coeff FROM gd_currrate c WHERE ' +
      ' c.fromcurr = :currkey AND c.tocurr = :tocurrkey and ' +
      ' c.fordate = (SELECT MAX(c1.fordate) FROM gd_currrate c1 WHERE ' +
      ' c1.fromcurr = :currkey AND c1.tocurr = :tocurrkey and ' +
      ' c1.fordate <= :curdate) ';

    q.ParamByName('currkey').AsInteger := CurrKey;
    q.ParamByName('tocurrkey').AsInteger := TgdcCurr.GetNCUCurrKey;
    q.ParamByName('curdate').AsDateTime := DocumentDate;
    q.ExecQuery;

    if not q.EOF then
      Result := q.FieldByName('coeff').AsDouble
    else begin
      q.Close;
      q.ParamByName('currkey').AsInteger := TgdcCurr.GetNCUCurrKey;
      q.ParamByName('tocurrkey').AsInteger := CurrKey;
      q.ParamByName('curdate').AsDateTime := DocumentDate;
      q.ExecQuery;

      if not q.EOF then
        Result := 1 / q.FieldByName('coeff').AsDouble
      else
        Result := 0;
    end;
  finally
    q.Free;
  end;
end;
}

{ TgdcCurr ------------------------------------------------}

class function TgdcCurr.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'SHORTNAME';
end;

class function TgdcCurr.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_CURR';
end;

class function TgdcCurr.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCurrOnly';
end;

function TgdcCurr.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCURR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURR', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURR',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURR' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM gd_curr WHERE UPPER(shortname) = UPPER(:shortname) OR UPPER(name) = UPPER(:name)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := 'SELECT id FROM gd_curr WHERE UPPER(name) = UPPER(''' +
       StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]) + ''') ' +
       ' OR UPPER(shortname) = UPPER(''' +
       StringReplace(FieldByName('shortname').AsString, '''', '''''', [rfReplaceAll]) + ''') ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURR', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

{ TgdcCurrRate -------------------------------------------}

function TgdcCurrRate.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCCURRRATE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRRATE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRRATE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRRATE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT z.*, ' +
    ' cf.name as fromname, ct.name as toname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRRATE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrRate.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCCURRRATE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRRATE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRRATE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRRATE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM gd_currrate z JOIN gd_curr cf ON cf.id = z.fromcurr ' +
    ' JOIN gd_curr ct ON ct.id = z.tocurr ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRRATE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcCurrRate.GetOrderClause: String;
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
  {M}      SetFirstMethodAssoc('TGDCCURRRATE', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRRATE',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
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
  Result := 'ORDER BY Z.FORDATE DESC ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRRATE', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcCurrRate.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_CURRRATE';
end;

class function TgdcCurrRate.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'COEFF';
end;

procedure TgdcCurrRate.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(cst_ss_ByFromCurrency) then
    S.Add(' z.fromcurr = :fromcurr ');

  if HasSubSet(cst_ss_ByToCurrForDate) then
    S.Add(' z.fromcurr = :fromcurr and z.tocurr = :tocurr AND z.ForDate = ' +
    ' (SELECT MAX(cr.fordate) FROM gd_currrate cr WHERE cr.fromcurr = :fromcurr ' +
    '   and cr.tocurr = :tocurr and cr.ForDate <= :fordate) ');
end;

class function TgdcCurrRate.GetSubSetList: String;
begin
  Result := inherited GetSubSetList +
    cst_ss_ByFromCurrency + ';' + cst_ss_ByToCurrForDate + ';';
end;

function TgdcCurrRate.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCCURRRATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRRATE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRRATE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRRATE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM gd_currrate WHERE fromcurr = :fromcurr AND '+
      ' tocurr = :tocurr AND fordate = :fordate '
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM gd_currrate WHERE fromcurr = %d AND '+
      ' tocurr = %d AND fordate = ''%s'' ' ,
      [TID264(FieldByName('fromcurr')), TID264(FieldByName('tocurr')),
       FormatDateTime('dd.mm.yyyy hh:nn:ss', FieldByName('fordate').AsDateTime)]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRRATE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCurrRate.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCURRRATE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCURRRATE', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCURRRATE',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCURRRATE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  
  inherited;

  FieldByName('fromname').ReadOnly := True;
  FieldByName('toname').ReadOnly := True;

  // trigger will sync fields
  FieldByName('amount').Required := False;
  FieldByName('val').Required := False;
  FieldByName('coeff').Required := False;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCURRRATE', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCURRRATE', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcCurrRate.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmCurr';
end;

class function TgdcCurrRate.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCurrRate';
end;

class function TgdcCurr.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgCurr';
end;

initialization
  RegisterGdcClass(TgdcCurr, '������');
  RegisterGdcClass(TgdcCurrRate, '���� ������');

finalization
  UnregisterGdcClass(TgdcCurr);
  UnregisterGdcClass(TgdcCurrRate);
end.
