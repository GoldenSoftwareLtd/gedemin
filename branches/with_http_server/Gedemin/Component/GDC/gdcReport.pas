unit gdcReport;

interface

uses
  gdcBase, DB, gdcDelphiObject, Classes, gdcTree, gd_createable_form, gdcBaseInterface,
  gd_KeyAssoc;

type
  TgdcReportGroup = class(TgdcLBRBTree)
  protected
    // Формирование запроса
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;
    function CreateDialogForm: TCreateableForm; override;

    function CheckTheSameStatement: String; override;

    procedure DoBeforePost; override;
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;
  end;

type
  TgdcReport = class(TgdcBase)
  private
    FLastInsertID: Integer;
    FOnlyDisplaying: Boolean;

    procedure SetOnlyDisplaying(const Value: Boolean);

  protected
    // Заполнение полей при добавлении новой записи
    procedure _DoOnNewRecord; override;

    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;

    function CheckTheSameStatement: String; override;
    procedure DoBeforePost; override;

    procedure DeleteSF;
    procedure CreateSF;
    procedure CreateCommand(SFRUID: TRUID);
    procedure DeleteCommand(SFRUID: TRUID);

    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    // проверяет существование в базе макрос с таким именем
    // возвращает Истину, если есть и Ложь в противном
    // случае
    function  CheckReport(const AName: String; ReportGroupKey: Integer): Boolean;
    // Возвращает униканое имя в базе.
    //
    function GetUniqueName(PrefName, Name: string; ReportGroupKey: Integer): string;

    function EditDialog(const ADlgClassName: String = ''): Boolean; override;
    function CreateDialog(const ADlgClassName: String = ''): Boolean; override;

    property LastInsertID: Integer read FLastInsertID;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    property OnlyDisplaying: Boolean read FOnlyDisplaying write SetOnlyDisplaying default False;
  end;

const
  ssReportGroup = 'ByReportGroup';

procedure Register;
function GetObjectKeyByReportGroupID(ReportGroupId: Integer): Integer;
function GetObjectKeyByReportId(ReportId: Integer): Integer;

implementation

uses
  gd_ClassList, IBSQL, gd_SetDatabase, Sysutils, gdcConstants,
  gdcFunction, IBCustomDataSet, gdc_frmReport_unit, evt_i_Base, Forms,
  gdc_dlgReportGroup_unit, gd_directories_const, prp_dfPropertyTree_Unit,
  gd_security_operationconst, gdcExplorer, rp_report_const, gd_i_ScriptFactory;

const
  cFunctionName = 'ReportScriptFunction%s';
  cReportImage = 15;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcReportGroup]);
  RegisterComponents('gdc', [TgdcReport]);
end;

function GetObjectKeyByReportGroupID(ReportGroupId: Integer): Integer;
var
  SQL: TIBSQL;
  RootGroupKey: Integer;
  UserGroupName: string;

  procedure Replace(var FullClassName: string);
  var
    L: Integer;
    I: Integer;
  begin
    L := Length(FullClassName);
    for I := 1 to L do
      if FullClassName[I] = '$' then FullClassName[I] := '_';
  end;

begin
  Result := OBJ_APPLICATION;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Text := 'SELECT g2.* FROM rp_reportgroup g1, rp_reportgroup g2 ' +
      ' where g1.id = :id and g2.lb <= g1.lb and g2.rb >= g1.rb and g2.parent is null';
    SQL.Params[0].AsInteger := ReportGroupId;
    SQL.ExecQuery;
    RootGroupKey := SQL.FieldByName('id').AsInteger;
    UserGroupName := SQL.FieldByName('usergroupname').AsString;
    SQL.Close;
    SQL.SQL.Text := 'SELECT * FROM evt_object WHERE reportgroupkey = :RGK ';
    SQL.ParamByName('RGK').AsInteger := RootGroupKey;
    SQL.ExecQuery;
    if not SQL.Eof then
      Result := SQL.FieldByName('id').AsInteger
    else
    begin
      if UserGroupName > '' then
      begin
        Replace(UserGroupName);
        SQL.Close;
        SQL.SQl.Text := 'SELECT * FROM evt_object WHERE UPPER(classname || subtype) = :UGN';
        SQL.ParamByName('UGN').AsString := UpperCase(UserGroupName);
        SQL.ExecQuery;
        if not SQL.Eof then
          Result := SQl.FieldByName('id').AsInteger;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function GetObjectKeyByReportId(ReportId: Integer): Integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Text := 'SELECT * FROM rp_reportlist WHERE id = :ID';
    SQL.ParamByName('id').AsInteger := ReportId;
    SQL.ExecQuery;
    Result := GetObjectKeyByReportGroupID(SQL.FieldByName('reportgroupkey').AsInteger);
  finally
    SQL.Free;
  end;
end;

{ TgdcReportGroup }

function TgdcReportGroup.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  LocId: Integer;
  LMaster: TDataSource;
  I: Integer;
  FromObj, ToObj: Integer;
  gdcFunction: TgdcFunction;
  SS: string;
begin
  Result := False;
  if gdcObjectList.IndexOf(CD^.Obj) = -1 then
  begin
    Result := False;
    exit;
  end;

  if (CD^.ClassName = 'TgdcReport') then
  begin
    ToObj := GetObjectKeyByReportGroupID(FieldByName('id').AsInteger);

    CD^.Obj.Close;
    SS := CD^.Obj.SubSet;
    LMaster := CD^.Obj.MasterSource;
    CD^.Obj.MasterSource := nil;
    try
      CD^.Obj.SubSet := ssById;
      for I := 0 to CD^.ObjectCount - 1 do
      begin
        FromObj := GetObjectKeyByReportId(CD^.ObjectArr[I].ID);
        CD^.Obj.ID := CD^.ObjectArr[I].ID;
        CD^.Obj.Open;
        gdcFunction := TgdcFunction.Create(nil);
        try
          LocID := FieldByName(fnId).AsInteger;
          if not CD^.Cut then
          begin
            CD^.Obj.Copy('id;name',
              VarArrayOf([GetUniqueKey(Database, Transaction),
              TgdcReport(CD^.Obj).GetUniqueName('копия', CD^.Obj.FieldByName(fnName).AsString,
                FieldByName(fnReportGroupKey).AsInteger)]));
            TgdcReport(CD^.Obj).FLastInsertID := TgdcReport(CD^.Obj).FieldByName(fnId).AsInteger;
          end;
          CD^.Obj.Edit;
          try
            if FromObj <> ToObj then
            begin
              gdcFunction.SubSet := ssById;
              gdcFunction.Id := TgdcReport(CD^.Obj).FieldByName('mainformulakey').AsInteger;
              gdcFunction.Open;
              try
                if not CD^.Cut then
                  gdcFunction.Copy('name;modulecode', VarArrayOf([gdcFunction.GetUniqueName('copy',
                    gdcFunction.FieldByName('name').AsString,
                    ToObj), ToObj]))
                else
                begin
                  gdcFunction.Edit;
                  gdcFunction.FieldByName('modulecode').AsInteger := ToObj;
                end;
                gdcFunction.Post;
              except
                gdcFunction.Cancel;
                raise;
              end;

              TgdcReport(CD^.Obj).FieldByName('mainformulakey').AsInteger :=
                gdcFunction.FieldByName('id').AsInteger;

              if not TgdcReport(CD^.Obj).FieldByName('paramformulakey').IsNull then
              begin
                gdcFunction.Id := TgdcReport(CD^.Obj).FieldByName('paramformulakey').AsInteger;
                gdcFunction.Open;
                try
                  if not CD^.Cut then
                    gdcFunction.Copy('name;modulecode', VarArrayOf([gdcFunction.GetUniqueName('copy',
                      gdcFunction.FieldByName('name').AsString,
                      ToObj), ToObj]))
                  else
                  begin
                    gdcFunction.Edit;
                    gdcFunction.FieldByName('modulecode').AsInteger := ToObj;
                  end;
                  gdcFunction.Post;
                except
                  gdcFunction.Cancel;
                  raise;
                end;

                TgdcReport(CD^.Obj).FieldByName('paramformulakey').AsInteger :=
                  gdcFunction.FieldByName('id').AsInteger;
              end;

              if not TgdcReport(CD^.Obj).FieldByName('eventformulakey').IsNull then
              begin
                gdcFunction.Id := TgdcReport(CD^.Obj).FieldByName('eventformulakey').AsInteger;
                gdcFunction.Open;
                try
                  if not CD^.Cut then
                    gdcFunction.Copy('name;modulecode', VarArrayOf([gdcFunction.GetUniqueName('copy',
                      gdcFunction.FieldByName('name').AsString,
                      ToObj), ToObj]))
                  else
                  begin
                    gdcFunction.Edit;
                    gdcFunction.FieldByName('modulecode').AsInteger := ToObj;
                  end;
                  gdcFunction.Post;
                except
                  gdcFunction.Cancel;
                  raise;
                end;

                TgdcReport(CD^.Obj).FieldByName('eventformulakey').AsInteger :=
                  gdcFunction.FieldByName('id').AsInteger;
              end;
            end;
            CD^.Obj.FieldByName(fnReportGroupKey).AsInteger := LocID;
            CD^.Obj.Post;
          except
            CD^.Obj.Cancel;
            raise;
          end;

          // Восстанавливаем связъ мастер-дитэйл
          Result := True;
        finally
          gdcFunction.Free;
        end;
      end;
    finally
      CD^.Obj.Close;
      CD^.Obj.SubSet := SS;
      CD^.Obj.MasterSource := LMaster;
      CD^.Obj.Open;
    end;
  end else if CD^.ClassName = 'TgdcReportGroup' then
  begin
    ToObj := GetObjectKeyByReportGroupID(FieldByName('id').AsInteger);
    for I := 0 to CD^.ObjectCount - 1 do
    begin
      FromObj := GetObjectKeyByReportGroupID(CD^.ObjectArr[I].ID);
      Result := FromObj = ToObj;
      if not Result then Exit;
    end;
    Result := inherited AcceptClipboard(CD)
  end;
end;

function TgdcReportGroup.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCREPORTGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  //Стандартные записи ищем по идентификатору
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(usergroupname)=''%s'' ',
      [GetKeyField(SubType), GetListTable(SubType), AnsiUpperCase(FieldByName('usergroupname').AsString)]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcReportGroup.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCREPORTGROUP', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_dlgReportGroup.Create(ParentForm);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcReportGroup.DoBeforePost;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  SQL: TIBSQL;
  N: string;
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCREPORTGROUP', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    if Transaction.InTransaction then
      SQL.Transaction := Transaction
    else
      SQl.Transaction := ReadTransaction;

    if FieldByName('parent').IsNull then
      SQL.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE name = :name AND parent IS NULL AND id <> :id'
    else
      SQL.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE name = :name AND parent = :parent AND id <> :id';
    N := FieldByName('name').AsString;
    I := 1;

    repeat
      SQl.Close;
      if not FieldByName('parent').IsNull then
        SQL.ParamByName('parent').Value := FieldByName('parent').Value;
      SQL.ParamByName('name').AsString := N;
      SQl.ParamByname('id').AsInteger := FieldByName('id').AsInteger;
      SQL.ExecQuery;
      if SQL.RecordCount > 0 then
      begin
        N := FieldByName('name').AsString + IntToStr(I);
        Inc(i)
      end else
      begin
        FieldByName('name').AsString := N;
      end;
    until SQL.RecordCount = 0;

  finally
    SQl.Free;
  end;

  if FindField('aview') <> nil then
    FieldByName('aview').AsInteger := -1;
  if FindField('achag') <> nil then
    FieldByName('achag').AsInteger := -1;
  if FindField('afull') <> nil then
    FieldByName('afull').AsInteger := -1;

  inherited DoBeforePost;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcReportGroup.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Папка отчетов';
end;

function TgdcReportGroup.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCREPORTGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not ARefresh) and HasSubSet(ssTree) then
    Result := ' FROM rp_reportgroup z, rp_reportgroup t2 '
  else
    Result := inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

{class function TgdcReportGroup.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := fnId;
end;}

class function TgdcReportGroup.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcReportGroup.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'rp_reportgroup';
end;

function TgdcReportGroup.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCREPORTGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet(ssTree) then
    Result := ' ORDER BY z.lb, z.name'
  else
    Result := inherited GetOrderClause;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcReportGroup.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCREPORTGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORTGROUP', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORTGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORTGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORTGROUP' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet(ssTree) then
    Result := 'SELECT z.*, 0 AS HASCHILDREN '
  else
    Result := 'SELECT z.*, (SELECT 1 FROM RDB$DATABASE WHERE ' +
      'EXISTS (SELECT t3.id FROM rp_reportgroup t3 WHERE t3.parent = z.id) ' +
      '  OR EXISTS (SELECT t4.id FROM rp_reportlist t4 WHERE ' +
      't4.ReportGroupKey = z.id)) AS HASCHILDREN ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORTGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORTGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcReportGroup.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ssTree + ';' + ssByParent + ';';
end;

class function TgdcReportGroup.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmReportList';
end;

procedure TgdcReportGroup.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(ssTree) then
  begin
    S.Add('t2.id = :id');
    S.Add('t2.lb <= z.lb');
    S.Add('t2.rb >= z.rb');
  end else
  if HasSubSet(ssByParent) then
  begin
    S.Add('z.parent = :parent');
  end;
end;

procedure TgdcReportGroup._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
var
  ibsql: TIBSQL;
  DelphiObject: TgdcDelphiObject;
begin
  if Assigned(ObjectSet) and (ObjectSet.Find(ID) > -1) then
    Exit;

  inherited;

  ibsql := CreateReadIBSQL;
  try
    ibsql.SQL.Text := 'SELECT * FROM evt_object WHERE reportgroupkey = :rgk';
    ibsql.ParamByName('rgk').AsInteger := ID;
    ibsql.ExecQuery;
    if (ibsql.RecordCount > 0) and
      ((not Assigned(BindedList)) or(BindedList.Find(ibsql.FieldByName('id').AsInteger) = -1)) then
    begin
      DelphiObject := TgdcDelphiObject.CreateSingularByID(nil,
        ibsql.FieldByName('id').AsInteger, '') as TgdcDelphiObject;
      try
        DelphiObject.Open;
        DelphiObject._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
      finally
        DelphiObject.Free;
      end;
    end;
  finally
    ibsql.Free;
  end;
end;

{ TgdcReport }

function TgdcReport.CheckReport(const AName: String; ReportGroupKey: Integer): Boolean;
var
  SQL: TIBSQL;
begin
  SQL := tIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    if Active then
      SQL.SQL.Text := Format('SELECT * FROM rp_reportlist WHERE Upper(Name) = ''%s'' ' +
        ' and id <> %d and reportgroupkey = %d',  [AnsiUpperCase(AName),
          FieldByName(fnId).AsInteger, ReportGroupKey])
    else
      SQL.SQL.Text := Format('SELECT * FROM rp_reportlist WHERE Upper(Name) = ''%s'' ' +
        ' and reportgroupkey = %d',  [AnsiUpperCase(AName), ReportGroupKey]);

    SQL.ExecQuery;
    Result := not SQL.Eof;
  finally
    SQL.Free;
  end;
end;

procedure TgdcReport._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCREPORT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName(fnIsLocalExecute).AsInteger := 1;
  FieldByName(fnFRQRefresh).AsInteger := 1;
  FieldByName(fnPreView).AsInteger := 1;
  FieldByName(fnIsReBuild).AsInteger := 1;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcReport.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCREPORT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (not ARefresh) and HasSubSet(ssWithSubGroup) then
    Result := ' FROM rp_reportgroup mg1 JOIN rp_reportgroup mg2 ON mg2.lb >= mg1.lb AND ' +
      ' mg2.rb <= mg1.rb JOIN rp_reportlist z ON mg2.id = z.reportgroupkey '
  else
    Result := inherited GetFromClause(ARefresh);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

{class function TgdcReport.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := fnId;
end;}

class function TgdcReport.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := fnName;
end;

class function TgdcReport.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'rp_reportlist';
end;

function TgdcReport.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCREPORT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if HasSubSet(ssWithSubGroup) then
    Result := 'ORDER BY mg2.lb, z.name'
  else
    Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

{function TgdcReport.GetSelectClause: String;
begin
  Result := 'SELECT z.* ';
end;}

class function TgdcReport.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + ';' + ssWithSubGroup + ';' +
    ssReportGroup + ';';
end;

function TgdcReport.GetUniqueName(PrefName, Name: string; ReportGroupKey: Integer): string;
var
  I: Integer;
  SQL: TIBSQL;
begin
  Result := Trim(PrefName + ' ' + Name);
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    if Active then
      SQL.SQL.Text := Format('SELECT * FROM rp_reportlist WHERE Upper(Name) = :name '+
        ' and reportgroupkey = %d and id <> %d', [ReportGroupKey, FieldByName(fnId).AsInteger])
    else
      SQL.SQL.Text := Format('SELECT * FROM rp_reportlist WHERE Upper(Name) = :name '+
        ' and reportgroupkey = %d', [ReportGroupKey]);
    SQL.Prepare;
    I := 1;
    SQL.Params[0].AsString := AnsiUpperCase(Result);
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      SQL.Close;
      Result := PrefName + ' (' + IntToStr(I) + ') ' + Name;
      SQL.Params[0].AsString := AnsiUpperCase(Result);
      SQL.ExecQuery;
      Inc(I);
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcReport.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet(ssReportGroup) then
  begin
    S.Add(' z.reportgroupkey = :reportgroupkey');
  end
  else if HasSubSet(ssWithSubGroup) then
  begin
    S.Add(' mg1.id = :id ');
  end;

  if OnlyDisplaying then
    S.Add(' z.displayinmenu = 1 ');
end;

class function TgdcReport.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmReportList';
end;

function TgdcReport.EditDialog(const ADlgClassName: String): Boolean;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_EDITDIALOG('TGDCREPORT', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYEDITDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYEDITDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
  {M}          'EDITDIALOG', KEYEDITDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'EDITDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}          Exit;
  {M}    end;
  {END MACRO}

  if ADlgClassName = 'Tgdc_dlgObjectProperties' then
    Result := inherited EditDialog(ADlgClassName)
  else
  begin
    EventControl.EditReport(FieldByName('REPORTGROUPKEY').AsInteger, ID);
    Result := True;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'EDITDIALOG', KEYEDITDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'EDITDIALOG', KEYEDITDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcReport.CreateDialog(const ADlgClassName: String): Boolean;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CREATEDIALOG('TGDCREPORT', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYCREATEDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
  {M}          'CREATEDIALOG', KEYCREATEDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CREATEDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Result := Inherited CreateDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Assert(HasSubSet(ssReportGroup), 'Невеный SubSet');
  EventControl.EditReport(ParamByName('reportgroupkey').AsInteger, 0);
  Result := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'CREATEDIALOG', KEYCREATEDIALOG);
  {M}  end;
  {END MACRO}
end;

function TgdcReport.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCREPORT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  //Стандартные записи ищем по идентификатору
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM rp_reportlist ' +
      ' WHERE UPPER(name)=''%s'' AND reportgroupkey = %d',
      [AnsiUpperCase(FieldByName('name').AsString), FieldByName('reportgroupkey').AsInteger]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcReport.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
//При загрузке из потока будем обновлять отчет
  Result := True;
end;

class function TgdcReport.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Отчет';
end;

procedure TgdcReport.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCREPORT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if sLoadFromStream in BaseState then
  begin
    if CheckReport(FieldByName(fnName).AsString,
      FieldByName(fnReportGroupKey).AsInteger) then
      FieldByName(fnName).AsString := GetUniqueName('renamed',
        FieldByName(fnName).AsString,
        FieldByName(fnReportGroupKey).AsInteger);
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcReport.SetOnlyDisplaying(const Value: Boolean);
begin
  FOnlyDisplaying := Value;
end;

procedure TgdcReport.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCREPORT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCREPORT', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCREPORT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCREPORT',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCREPORT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Process = cpDelete then
    DeleteSF
  else
    CreateSF;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCREPORT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCREPORT', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcReport.CreateCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT * FROM gd_command WHERE cmd = ''' + RUIDToStr(SFRUID) + '''';
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
      gdcExplorer.Open;
      gdcExplorer.Edit;
      try
        if FieldByName('folderkey').IsNull then
          gdcExplorer.FieldByName('parent').Clear
        else
          gdcExplorer.FieldByName('parent').AsInteger := FieldByName('folderkey').AsInteger;
        gdcExplorer.FieldByName('name').AsString := FieldByName('name').AsString;
        gdcExplorer.FieldByName('cmd').AsString := RUIDToStr(SFRUID);
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
        gdcExplorer.FieldByName('imgindex').AsInteger := cReportImage;
        gdcExplorer.Post;
      except
        gdcExplorer.Cancel;
        raise;
      end;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcReport.CreateSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
const
  cFunctionBody =
    'sub %s '#13 +
    '  System.ReportSystem.BuildReport(gdcBaseManager.GetIDByRUIDString("%s"))'#13 +
    'end sub';
begin
  if FieldByName('FOLDERKEY').IsNull then
    DeleteSF
  else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReadTransaction;
      SQL.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
        Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
      SQL.ExecQuery;
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('Id').AsInteger;
        gdcFunction.Open;
        gdcFunction.Edit;
        try
          gdcFunction.FieldByName(fnName).AsString := Format(cFunctionName, [RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnModule).AsString := scrUnkonownModule;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;

          gdcFunction.FieldByName(fnScript).AsString := Format(cFunctionBody,
            [gdcFunction.FieldByName(fnName).AsString,
            RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnLanguage).AsString := DefaultLanguage;
          gdcFunction.Post;

          if ScriptFactory <> nil then
            ScriptFactory.ReloadFunction(gdcFunction.FieldByName(fnID).AsInteger);
        except
          gdcFunction.Cancel;
          raise;
        end;
        CreateCommand(gdcFunction.GetRUID);
      finally
        gdcFunction.Free;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TgdcReport.DeleteCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT * FROM gd_command WHERE cmd = ''' + RUIDToStr(SFRUID) + '''';
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
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

procedure TgdcReport.DeleteSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQl.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
      Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
    SQL.ExecQuery;
    if SQL.FieldByName('id').AsInteger > 0 then
    begin
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('Id').AsInteger;
        gdcFunction.Open;
        DeleteCommand(gdcFunction.GetRUID);
        gdcFunction.Delete;
      finally
        gdcFunction.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

initialization
  RegisterGDCClasses([TgdcReportGroup, TgdcReport]);

finalization
  UnRegisterGDCClasses([TgdcReportGroup, TgdcReport]);
end.

