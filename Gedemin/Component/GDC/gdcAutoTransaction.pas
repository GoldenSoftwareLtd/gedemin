// ShlTanya, 09.02.2019

unit gdcAutoTransaction;

interface

uses
  gdcBase, gdcTree, gdcBaseInterface, Classes,
  SysUtils, gdcAcctTransaction, gdcConstants;

type
  //Б.к. автоматической операции
  TgdcAutoTransaction = class(TgdcBaseAcctTransaction)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoBeforePost; override;
  public
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
  end;

  //Б.к. автоматической проводки
  TgdcAutoTrRecord = class(TgdcBaseAcctTransactionEntry)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    procedure CreateCommand;
    procedure DeleteCommand;

    function FunctionRUID: string;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
  public
    constructor Create(AnOwner: TComponent); override;

    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gd_security, gdcExplorer, IBSQL, gdcFunction, IBDatabase, gd_directories_const,
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAutoTransaction, TgdcAutoTrRecord]);
end;

{ TgdcAutoTransaction }
procedure TgdcAutoTransaction.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCAUTOTRANSACTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRANSACTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRANSACTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRANSACTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRANSACTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  //Устанавливаем признак автоматической операции
  FieldByName(fnAutoTransaction).AsInteger := 1;
  inherited DoBeforePost;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRANSACTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRANSACTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcAutoTransaction.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAutoTransaction';
end;

class function TgdcAutoTransaction.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAutoTransaction';
end;

procedure TgdcAutoTransaction.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' (Z.AUTOTRANSACTION = 1) ');
end;

class function TgdcAutoTransaction.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  if CompareText(ATableName, GetListTable(ASubType)) = 0 then
    Result := ' (Z.AUTOTRANSACTION = 1) '
  else
    Result := inherited GetRestrictCondition(ATableName, ASubType)
end;

{ TgdcAutoTrRecord }

constructor TgdcAutoTrRecord.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpModify, cpDelete];
end;

procedure TgdcAutoTrRecord.CreateCommand;
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = :C';
    SQL.ParamByName('C').AsString := FunctionRUID;
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := GetTID(SQL.FieldByName(fnId));
      gdcExplorer.Open;
      gdcExplorer.Edit;
      SetTID(gdcExplorer.FieldByName(fnParent), FieldByName(fnFolderKey));
      gdcExplorer.FieldByName(fnName).AsString := FieldByName(fnDescription).AsString;
      gdcExplorer.FieldByName(fnCmd).AsString := FunctionRUID;
      gdcExplorer.FieldByName(fnCmdType).AsInteger := cst_expl_cmdtype_function;
      gdcExplorer.FieldByName(fnImgIndex).AsInteger := FieldByName(fnImageIndex).AsInteger;
      gdcExplorer.Post;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcAutoTrRecord.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  FunctionKey: TID;
  gdcFunction: TgdcFunction;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTRRECORD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  FunctionKey := GetTID(FieldByName('functionkey'));

  CustomExecQuery(
    'DELETE FROM ac_autotrrecord ' +
    'WHERE id = :OLD_ID',
    Buff
  );

  inherited;

  gdcFunction := TgdcFunction.Create(nil);
  try
    gdcFunction.SubSet := 'ByID';
    gdcFunction.Transaction := Transaction;
    gdcFunction.ReadTransaction := Transaction;

    gdcFunction.Id := FunctionKey;
    gdcFunction.Open;
    try
      gdcFunction.Delete;
    except
    end;
  finally
    gdcFunction.Free;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTrRecord.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTRRECORD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CustomExecQuery(
    'INSERT INTO ac_autotrrecord ' +
    '  (id, showinexplorer, imageindex, folderkey) ' +
    'VALUES ' +
    ' (:id, :showinexplorer, :imageindex, :folderkey)',
    Buff
  );

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTrRecord.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTRRECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  CustomExecQuery(
    'UPDATE ac_autotrrecord ' +
    'SET ' +
      'id = :id, ' +
      'showinexplorer = :showinexplorer, ' +
      'imageindex = :imageindex, ' +
      'folderkey = :folderkey ' +
    'WHERE ' +
    '  id = :OLD_ID',
    Buff
  );

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTrRecord.DeleteCommand;
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  if GetTID(FieldByName('functionkey')) > 0 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Text := 'SELECT * FROM gd_command WHERE cmd = ''' + FunctionRUID + '''';
      SQL.ExecQuery;

      gdcExplorer := TgdcExplorer.Create(nil);
      try
        gdcExplorer.Transaction := Transaction;
        gdcExplorer.ReadTransaction := ReadTransaction;
        gdcExplorer.SubSet := 'ByID';
        gdcExplorer.Id := GetTID(SQL.FieldByName(fnId));
        gdcExplorer.Open;
        if not gdcExplorer.Eof then
          gdcExplorer.Delete;
      finally
        gdcExplorer.Free;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TgdcAutoTrRecord.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCAUTOTRRECORD', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Process = cpDelete then
    DeleteCommand
  else
  begin
    if (FieldByName(fnShowInexplorer).AsInteger = 1) and
      (GetTID(FieldByName(fnFolderkey)) > 0)
    then
      CreateCommand
    else
      DeleteCommand;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcAutoTrRecord.FunctionRUID: String;
begin
  if GetTID(FieldByname(fnFunctionkey)) > 0 then
    Result := gdcBaseManager.GetRUIDStringByID(GetTID(FieldByName(fnFunctionkey)), Transaction)
  else
    Result := '';  
end;

class function TgdcAutoTrRecord.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAutoTrRecord';
end;

function TgdcAutoTrRecord.GetFromClause(const ARefresh: Boolean): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCAUTOTRRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetFromClause(ARefresh) + ' JOIN ac_autotrrecord t ON t.id = z.id ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcAutoTrRecord.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCAUTOTRRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTRRECORD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTRRECORD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTRRECORD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTRRECORD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetSelectClause + ', t.imageindex, t.showinexplorer, t.folderkey ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTRRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTRRECORD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcAutoTrRecord,    'Автоматическая проводка');
  RegisterGdcClass(TgdcAutoTransaction, 'Автоматическая операция');
  
finalization
  UnregisterGdcClass(TgdcAutoTrRecord);
  UnregisterGdcClass( TgdcAutoTransaction);
end.
