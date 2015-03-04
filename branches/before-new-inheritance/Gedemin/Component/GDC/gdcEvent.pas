unit gdcEvent;

interface

uses
  Classes, gdcBase, comctrls, gdcBaseInterface;

const
  cByObjectKey = 'ByObjectKey';
  cByLBRBObject = 'ByLBRBObject';

type
  TgdcEvent = class(TgdcBase)
  protected
    procedure _DoOnNewRecord; override;

    // Формирование запроса
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function CheckTheSameStatement: String; override;
    function SaveEvent(const AnObjectNode: TTreeNode;
     const AnEventNode: TTreeNode): Boolean;
  end;

  procedure Register;

implementation

uses
  DB, SysUtils, IBSQL, evt_Base, gdc_attr_frmEvent_unit,
  gd_ClassList, gd_directories_const, gdcFunction;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcEvent]);
end;

{ TgdcEvent }

procedure TgdcEvent._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEVENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEVENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEVENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEVENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEVENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FieldByName('afull').AsInteger := -1;
  if HasSubSet(cByObjectKey) then
    FieldByName('objectkey').AsInteger := ParamByName('objectkey').AsInteger;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEVENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEVENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcEvent.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCEVENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEVENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEVENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEVENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEVENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'FROM evt_objectevent z LEFT JOIN evt_object o ON z.objectkey = o.id ' +
    ' LEFT JOIN evt_object op ON op.id = o.parent ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEVENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEVENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcEvent.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcEvent.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'EVENTNAME'
end;

class function TgdcEvent.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'EVT_OBJECTEVENT';
end;

function TgdcEvent.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCEVENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEVENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEVENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEVENT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEVENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT z.*, o.name as objectname, op.name as parentname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEVENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEVENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcEvent.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + cByObjectKey + ';' +
    cByLBRBObject + ';';
end;

procedure TgdcEvent.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(cByObjectKey) then
    S.Add('z.objectkey = :objectkey');
  if HasSubSet(cByLBRBObject) then
    S.Add('o.lb >= :LB AND o.rb <= :RB ');
end;

function TgdcEvent.SaveEvent(const AnObjectNode: TTreeNode;
  const AnEventNode: TTreeNode): Boolean;
var
  ibsqlInsertEvent, LibsqlCheck: TIBSQL;
  DidActivate: Boolean;
begin
  Result := False;
  try
    DidActivate := False;
    LibsqlCheck := TIBSQL.Create(nil);
    try
      LibsqlCheck.Database := Database;
      LibsqlCheck.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      LibsqlCheck.SQL.Text := 'SELECT * FROM evt_objectevent WHERE objectkey = ' +
       ' :objectkey AND eventname = :eventname';
      LibsqlCheck.Params[0].AsInteger :=
       (TObject(AnObjectNode.Data) as TEventObject).ObjectKey;
      LibsqlCheck.Params[1].AsString :=
       AnsiUpperCase((TObject(AnEventNode.Data) as TEventItem).Name);
      LibsqlCheck.ExecQuery;
      if not LibsqlCheck.Eof then
      begin
        Result := LibsqlCheck.FieldByName('functionkey').AsInteger =
         (TObject(AnEventNode.Data) as TEventItem).FunctionKey;
        if not Result then
        begin
          LibsqlCheck.Close;
          LibsqlCheck.SQL.Text := 'DELETE FROM evt_objectevent WHERE objectkey = ' +
           ' :objectkey AND eventname = :eventname';
          LibsqlCheck.Params[0].AsInteger :=
           (TObject(AnObjectNode.Data) as TEventObject).ObjectKey;
          LibsqlCheck.Params[1].AsString :=
           AnsiUpperCase((TObject(AnEventNode.Data) as TEventItem).Name);
          LibsqlCheck.ExecQuery;
        end else
          Exit;
      end;
    finally
      if DidActivate then
        Transaction.Commit;
      LibsqlCheck.Free;
    end;

    if (TObject(AnEventNode.Data) as TEventItem).FunctionKey <> 0 then
    begin
      ibsqlInsertEvent := TIBSQL.Create(nil);
      try
        //ibsqlInsertEvent.Close;
        ibsqlInsertEvent.Database := Database;
        ibsqlInsertEvent.Transaction := Transaction;
        DidActivate := ActivateTransaction;
        ibsqlInsertEvent.SQL.Text := 'INSERT INTO evt_objectevent(id, objectkey, functionkey, eventname) VALUES' +
         ' (:id, :objectkey, :functionkey, :eventname)';
        ibsqlInsertEvent.ParamByName('id').AsInteger := GetNextID;
        ibsqlInsertEvent.ParamByName('objectkey').AsInteger :=
         (TObject(AnObjectNode.Data) as TEventObject).ObjectKey;
        ibsqlInsertEvent.ParamByName('functionkey').AsInteger :=
         (TObject(AnEventNode.Data) as TEventItem).FunctionKey;
        ibsqlInsertEvent.ParamByName('eventname').AsString :=
         AnsiUpperCase((TObject(AnEventNode.Data) as TEventItem).Name);
       // ibsqlInsertEvent.ParamByName('afull').AsInteger := -1;
        ibsqlInsertEvent.ExecQuery;
        ibsqlInsertEvent.Close;
      finally
        if DidActivate then
          Transaction.Commit;
        ibsqlInsertEvent.Free;
      end;
    end;
    Result := True;
  except
    on E: Exception do
      {MessageBox(Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR);}
  end;
end;

class function TgdcEvent.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmEvent';
end;

function TgdcEvent.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCEVENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEVENT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEVENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEVENT',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEVENT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM evt_objectevent WHERE objectkey = :objectkey AND ' +
      'eventname = :eventname'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM evt_objectevent WHERE objectkey = %d AND ' +
      'eventname = ''%s''',
      [FieldByName('objectkey').AsInteger, FieldByName('eventname').AsString]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEVENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEVENT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcEvent.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Событие';
end;

class function TgdcEvent.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

initialization
  RegisterGdcClass(TgdcEvent);

finalization
  UnRegisterGdcClass(TgdcEvent);
end.
