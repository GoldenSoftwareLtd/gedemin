
{++

  Copyright (c) 2001-2017 by Golden Software of Belarus, Ltd

  Module

    gdcCustomFunction.pas

  Abstract

    Business classes. Base function class which support compale.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    03.03.2003   DAlex        Initial version.
--}

unit gdcCustomFunction;

interface

uses
  Classes, Db, gdcBase, gdcBaseInterface, contnrs,
  IBSQL, gd_KeyAssoc, IBDatabase, gd_i_ScriptFactory;

type
  TVBCompileType = (vbcError, vbcHint);

  TgdcCustomFunction = class;

  TgsVBCompiler = class(TObject)
  private
    FIBSQL: TIBSQL;
    FModuleList: TgdKeyObjectAssoc;
    FCreateWithError: Boolean;
    FErrorList: TObjectList;
    FHintList: TObjectList;
    FPredefinedNames: TStringList;

    function  AddModule(const ModuleCode: Integer): TStringList;
    // для сортированного списка с Duplicates = dupAccept возвращает первое
    // вхождение строки равной StrList[CurrentIndex]
    function  GetFirstItems(
      const StrList: TStringList; const CurrrentIndex: Integer): Integer;

    // Добавляет в список итем
    function AddErrorOrHint(const CompileType: TVBCompileType): TgdCompileItem;
    // Создает список всех имен СФ и модулей
    procedure CreateScriptNameList;

    procedure SetErrorList(const Value: TObjectList);
    procedure SetHintList(const Value: TObjectList);
  protected
    procedure AddNameList(const ModuleCode: Integer; NameList: TStrings);

  public
    constructor Create;
    destructor Destroy; override;

    // Проверка имени на невхождение в стандартные
    function  CheckNameInVB(const Name: String): String;
    // Компиляция одного скрипта
    function  CompileScript(gdcFunction: TgdcCustomFunction;
      const CheckUniname: Boolean; TestScriptSyntax: Boolean): Boolean;

    function  CheckName(const Name: String; const ModuleCode: Integer): Boolean;

    // Очистка всех списков
    procedure ClearList;
    procedure CompileVBProject;

    // Добавляет инф. о ф-ции
    procedure  AddFuncInfo(const gdcFunction: TgdcCustomFunction);
    // Удаляет инф. о ф-ции из списка
    // DeletteeList - содержит список удаленных имен
    procedure DeleteFuncInfo(const ModuleCode: Integer; const FunctionKey: Integer;
      const DeletteeList: TStrings = nil);

    property  ErrorList: TObjectList read FErrorList write SetErrorList;
    property  HintList: TObjectList read FHintList write SetHintList;
  end;

  TgdcCustomFunction = class(TgdcBase)
  private
    FCompileScript: Boolean;
    FDelFunctionKey: Integer;
    FDelModuleCode: Integer;

    procedure SetCompileScript(const Value: Boolean);
  protected
    FInternalSciptNameList: TStrings;

    procedure DoAfterDelete; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;

    procedure DoAfterPost; override;
    procedure DoBeforePost; override;

    function CheckDataset(q: TIBSQL): Boolean;
    function ObjectChanged: Boolean; virtual;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Post; override;
    class function IsAbstractClass: Boolean; override;

    property  CompileScript: Boolean read FCompileScript write SetCompileScript default False;
  end;

  procedure ReadAddFunction(const FunctionKey: Integer; SL: TStrings;
    AnScript: String; const ModuleCode: Integer; const Transaction: TIBTransaction);
  function TestCyclicRef(const FunctionKey: Integer; SL: TStrings;
    ErrorList: TObjectList): Boolean;
  function VBCompiler: TgsVBCompiler;

implementation

uses
  gd_security_operationconst, Windows, sysutils, gd_ClassList, gd_security,
  prp_frmGedeminProperty_Unit, prp_MessageConst, gd_ScriptCompiler, gdcConstants,
  forms, scr_i_FunctionList, rp_BaseReport_unit, IBQuery, IBIntf
  {$IFDEF WITH_INDY}
    , gdccClient_unit, gdccConst
  {$ENDIF}
  ;

type
  TAddType = (atAddInfo, atChangeInfo, atIgnore);

var
  _VBCompiler: TgsVBCompiler;

function VBCompiler: TgsVBCompiler;
begin
  if _VBCompiler = nil then
    _VBCompiler := TgsVBCompiler.Create;
  Result := _VBCompiler;
end;

function TestCyclicRef(const FunctionKey: Integer; SL: TStrings;
  ErrorList: TObjectList): Boolean;
var
  ibsqlCyclic: TIBSQL;
  i: Integer;
  CompileItem: TgdCompileItem;
  AlreadyTestedList: TgdKeyArray;
  SFIDList: TList;

  procedure TestSingleSF(const SingleSFID: Integer);
  var
    AddSFID: Integer;
  begin
    if ibsqlCyclic.Open then
      ibsqlCyclic.Close;
    ibsqlCyclic.Params[0].AsInteger := SingleSFID;
    ibsqlCyclic.ExecQuery;
    while not ibsqlCyclic.Eof do
    begin
      if ibsqlCyclic.Fields[0].AsInteger = FunctionKey then
      begin
        Result := False;
        CompileItem := TgdCompileItem.Create;
        CompileItem.AutoClear := True;
        CompileItem.ReferenceToSF := SingleSFID;
        CompileItem.Line := 0;
        CompileItem.Msg := Format(MSG_ERROR_CYCLICREF,
          [ibsqlCyclic.Fields[1].AsString, CompileItem.ReferenceToSF]);
        CompileItem.SFID := FunctionKey;
        ErrorList.Add(CompileItem);
      end;
      AddSFID := ibsqlCyclic.Fields[2].AsInteger;
      if (AlreadyTestedList.IndexOf(AddSFID) = -1) then
      begin
        SFIDList.Add(Pointer(AddSFID));
        AlreadyTestedList.Add(AddSFID);
      end;

      ibsqlCyclic.Next;
    end;
  end;

begin
  Result := True;
  if SL.Count = 0 then
    Exit;

  SFIDList := TList.Create;
  try
    AlreadyTestedList := TgdKeyArray.Create;
    try
      AlreadyTestedList.Add(FunctionKey);
      ibsqlCyclic := TIBSQL.Create(nil);
      try
        ibsqlCyclic.Transaction := gdcBaseManager.ReadTransaction;
        ibsqlCyclic.SQL.Text :=
          'SELECT af.addfunctionkey, f.name, af.addfunctionkey FROM rp_additionalfunction af ' +
          'LEFT JOIN gd_function f ON f.id = af.mainfunctionkey ' +
          'WHERE af.mainfunctionkey = :includeSFID';

        for i := 0 to SL.Count - 1 do
        begin
          if SL.Objects[i] <> nil then
          begin
            SFIDList.Add(SL.Objects[i]);
            AlreadyTestedList.Add(Integer(SL.Objects[i]));
          end;
        end;
        while SFIDList.Count > 0 do
        begin
          TestSingleSF(Integer(SFIDList[0]));
          SFIDList.Delete(0);
        end;
      finally
        ibsqlCyclic.Free;
      end;
    finally
      AlreadyTestedList.Free;
    end;
  finally
    SFIDList.Free;
  end;
end;

procedure ReadAddFunction(const FunctionKey: Integer; SL: TStrings;
  AnScript: String; const ModuleCode: Integer; const Transaction: TIBTransaction);
const
  IncludePrefix = '#INCLUDE ';
  ReplacePrefix = '_________';
  LengthInc = Length(IncludePrefix);
  LimitChar = [' ', ',', ';', #13, #10];
var
  TempStr, Msg: String;
  I, J, StartIndex: Integer;
  ibsqlWork: TIBSQL;
  ObjectId: Integer;

  procedure FindDouble;
  var
    K: Integer;
  begin
    for K := 0 to SL.Count - 2 do
      if SL.Strings[K] = SL.Strings[SL.Count - 1] then
      begin
        SL.Delete(SL.Count - 1);
        Break;
      end;
  end;

  procedure SetID(LocStartInd, LocKey: Integer; LocName: String);
  var
    K: Integer;
  begin
    for K := LocStartInd to SL.Count - 1 do
      if LocName = SL.Strings[K] then
      begin
        SL.Objects[K] := Pointer(LocKey);
        Break;
      end;
  end;

  function GetParentObjectID(ID: Integer): Integer;
  var
    ibsqlObject: TIBSQL;
  begin
    ibsqlObject := TIBSQL.Create(nil);
    try
      ibsqlObject.Transaction := Transaction;
      ibsqlObject.SQL.Text := 'SELECT parent FROM evt_object WHERE id = :P';
      ibsqlObject.ParamByName('P').AsInteger := ID;
      ibsqlObject.ExecQuery;
      Result := ibsqlObject.FieldByName(fnParent).AsInteger;
      if (Result = 0) and (Id <> OBJ_APPLICATION) then
        Result := OBJ_APPLICATION;
    finally
      ibsqlObject.Free;
    end;
  end;

begin
  TempStr := AnsiUpperCase(AnScript);
  I := Pos(IncludePrefix, TempStr);
  StartIndex := SL.Count;
  while I <> 0 do
  begin
    TempStr[I] := '_';
    I := I + LengthInc;
    while (I <= Length(TempStr)) and (TempStr[I] in LimitChar) do
      Inc(I);

    J := SL.Add('');
    while (I <= Length(TempStr)) and not (TempStr[I] in LimitChar) do
    begin
      SL.Strings[J] := SL.Strings[J] + TempStr[I];
      Inc(I);
    end;
    FindDouble;

    I := Pos(IncludePrefix, TempStr);
  end;

  if StartIndex <= (SL.Count - 1) then
  begin
    ibsqlWork := TIBSQL.Create(nil);
    try
      ibsqlWork.Transaction := Transaction;
      ibsqlWork.SQL.Text :=
        'SELECT modulecode, id, name FROM gd_function WHERE (UPPER(name) = :N) ' +
        '  AND (modulecode = :modulecode)';
      I := StartIndex;
      while  I < SL.Count do
      begin
        ibsqlWork.ParamByName('N').AsString := SL.Strings[I];
        ObjectId := ModuleCode;
        while ObjectId > 0 do
        begin
          ibsqlWork.ParamByName('modulecode').AsInteger := ObjectId;
          ibsqlWork.ExecQuery;
          if not ibsqlWork.Eof then
          begin
            while not ibsqlWork.Eof do
            begin
              SetID(StartIndex, ibsqlWork.FieldByName('id').AsInteger,
                AnsiUpperCase(ibsqlWork.FieldByName('name').AsString));

              ibsqlWork.Next;
            end;
            Break;
          end;
          ibsqlWork.Close;
          ObjectId := GetParentObjectID(ObjectId);
        end;
        if ObjectId = 0 then
        begin
          Msg := 'Функция "' + Trim(SL.Strings[I]) + '" не найдена.';
          {$IFDEF WITH_INDY}
          if Global_LoadingNamespace then
          begin
            if gdccClient <> nil then
            begin
              gdccClient.AddLogRecord('ns', Msg, gdcc_lt_Warning, True);
            end;
          end else
          {$ENDIF}
            MessageBox(Application.Handle, PChar(Msg), 'Внимание',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

          SL.Delete(I);
          Dec(I);
        end;
        if ibsqlWork.Open then
          ibsqlWork.Close;
        Inc(I);
      end;
    finally
      ibsqlWork.Free;
    end;
  end;
end;

{ TgdcCustomFunction }

function TgdcCustomFunction.CheckDataset(q: TIBSQL): Boolean;
begin
  if FieldByName('id').AsInteger <> ID then
    raise Exception.Create('Не совпадает ключ записи');
  Result :=
    (FieldByName('editiondate').AsDateTime = q.FieldByName('editiondate').AsDateTime) and
    (Trim(FieldByName('script').AsString) = Trim(q.FieldByName('script').AsString));
end;

constructor TgdcCustomFunction.Create(AnOwner: TComponent);
begin
  inherited;
  FInternalSciptNameList := TStringList.Create;
end;

destructor TgdcCustomFunction.Destroy;
begin
  FInternalSciptNameList.Free;
  inherited;
end;

procedure TgdcCustomFunction.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCUSTOMFUNCTION', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCUSTOMFUNCTION', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCUSTOMFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCUSTOMFUNCTION',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCUSTOMFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  // Удаляем инф. о ф-ции из списка
  VBCompiler.DeleteFuncInfo(FDelModuleCode, FDelFunctionKey);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCUSTOMFUNCTION', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCUSTOMFUNCTION', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCustomFunction.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCUSTOMFUNCTION', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCUSTOMFUNCTION', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCUSTOMFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCUSTOMFUNCTION',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCUSTOMFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCUSTOMFUNCTION', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCUSTOMFUNCTION', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCustomFunction.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCUSTOMFUNCTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCUSTOMFUNCTION', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCUSTOMFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCUSTOMFUNCTION',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCUSTOMFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  // сохраняем ключ и код модуля удаляемой ф-ции
  FDelFunctionKey := FieldByName('id').AsInteger;
  FDelModuleCode := FieldByName('modulecode').AsInteger;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCUSTOMFUNCTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCUSTOMFUNCTION', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCustomFunction.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCUSTOMFUNCTION', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCUSTOMFUNCTION', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCUSTOMFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCUSTOMFUNCTION',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCUSTOMFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  // сохраняем ключ и код модуля редактируемой ф-ции
  FDelFunctionKey := FieldByName('id').AsInteger;
  FDelModuleCode := FieldByName('modulecode').AsInteger;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCUSTOMFUNCTION', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCUSTOMFUNCTION', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcCustomFunction.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCCUSTOMFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCCUSTOMFUNCTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCCUSTOMFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCCUSTOMFUNCTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCCUSTOMFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCCUSTOMFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCCUSTOMFUNCTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcCustomFunction.IsAbstractClass: Boolean;
begin
  Result := True;
end;

function TgdcCustomFunction.ObjectChanged: Boolean;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    q.SQL.Text :=
      'SELECT id, editiondate, script FROM gd_function WHERE id = :id';
    q.ParamByName('id').AsInteger := ID;
    q.ExecQuery;
    Result := not (q.EOF or CheckDataSet(q));
  finally
    q.Free;
  end;
end;

procedure TgdcCustomFunction.Post;
var
  AddType: TAddType;
  DeletteeList: TStrings;
  SL: TStrings;
  LErrorList: TObjectList;
  ErrCount: Integer;
  tmpFunction: TrpCustomFunction;

  procedure AddIncludeRef;
  var
    LocSQL: TIBSQL;
    I: Integer;
    DidActivate: Boolean;
  begin
    DidActivate := False;
    LocSQL := TIBSQL.Create(nil);
    try
      LocSQL.Transaction := Transaction;
      DidActivate := ActivateTransaction;
      LocSQL.SQL.Text := 'DELETE FROM rp_additionalfunction WHERE mainfunctionkey = ' +
       FieldByName('id').AsString;
      LocSQL.ExecQuery;
      LocSQL.Close;
      LocSQL.SQL.Text := 'INSERT INTO rp_additionalfunction (mainfunctionkey, addfunctionkey) ' +
       'VALUES(' + FieldByName('id').AsString + ', :id)';
      LocSQL.Prepare;
      for I := 1 to SL.Count - 1 do
      begin
        LocSQL.Close;
        LocSQL.Params[0].AsInteger := Integer(SL.Objects[I]);
        LocSQL.ExecQuery;
      end;
    finally
      if DidActivate then
        Transaction.Commit;
      LocSQL.Free;
    end;
  end;

begin
  LErrorList := nil;
  try
    if FCompileScript then
    begin
      LErrorList := TObjectList.Create(False);
      InternalScriptList(FieldByName('Script').AsString, FInternalSciptNameList,
        LErrorList, ID)
    end else
      InternalScriptList(FieldByName('Script').AsString, FInternalSciptNameList);

    FieldByName('displayscript').AsString := FInternalSciptNameList.Text;

    SL := TStringList.Create;
    try
      SL.Add(AnsiUpperCase(FieldByName('name').AsString));
      ReadAddFunction(ID, SL, FieldByName('script').AsString,
        FieldByName('modulecode').AsInteger, ReadTransaction);

      DeletteeList := nil;
      try
        case State of
          dsInsert: AddType := atAddInfo;
          dsEdit:
          begin
            DeletteeList := TStringList.Create;
            VBCompiler.DeleteFuncInfo(FDelModuleCode, FDelFunctionKey, DeletteeList);
            AddType := atChangeInfo;
          end;
        else
          AddType := atIgnore;
        end;

        try
          if Assigned(frmGedeminProperty) and FCompileScript then
          begin
            frmGedeminProperty.ClearErrorResult;
            try
              VBCompiler.CompileScript(Self, True, True);
              TestCyclicRef(ID, SL, VBCompiler.ErrorList);

              for ErrCount := 0 to LErrorList.Count - 1 do
                VBCompiler.ErrorList.Add(LErrorList[ErrCount]);

              if VBCompiler.ErrorList.Count > 0 then
              begin
                frmGedeminProperty.Show;
                raise Exception.Create('Ошибка компиляции. Смотрите список ошибок.');
              end;
            finally
              if (VBCompiler.ErrorList.Count > 0) or (VBCompiler.HintList.Count > 0) then
              begin
                frmGedeminProperty.ClearErrorList;
                frmGedeminProperty.ShowErrorList(VBCompiler.ErrorList);
                frmGedeminProperty.ShowErrorList(VBCompiler.HintList);
              end;
            end;
          end;

          inherited;
        except
          if DeletteeList <> nil then
            VBCompiler.AddNameList(FDelModuleCode, DeletteeList);
          raise;
        end;
      finally
        if DeletteeList <> nil then
          DeletteeList.Free;
      end;

      if AddType in [atAddInfo, atChangeInfo] then
        VBCompiler.AddFuncInfo(Self);

      AddIncludeRef;
    finally
      SL.Free;
    end;
  finally
    if LErrorList <> nil then
      LErrorList.Free;
  end;
  if glbFunctionList <> nil then
  begin
    tmpFunction := glbFunctionList.FindFunctionWithoutDB(ID);
    if tmpFunction <> nil then
    begin
      tmpFunction.ReadFromDataSet(Self);
      glbFunctionList.ReleaseFunction(tmpFunction);
    end;
  end;
end;

procedure TgdcCustomFunction.SetCompileScript(const Value: Boolean);
begin
  FCompileScript := Value;
end;

{ TgsVBCompiler }

procedure TgsVBCompiler.ClearList;
begin
  FModuleList.Clear;
  FErrorList.Clear;
  FHintList.Clear;
end;

procedure TgsVBCompiler.CompileVBProject;
var
  LastModuleCode, I, Index, LID: Integer;
  LNameList, LApplNameList, LtmpStrings: TStringList;
  ErrorItem: TgdCompileItem;
begin
  ClearList;

  FCreateWithError := False;
  try
    FModuleList.Clear;

    FIBSQL.Transaction := gdcBaseManager.ReadTransaction;
    FIBSQL.SQL.Text :=
      'SELECT id, displayscript, name FROM gd_function ' +
      'WHERE modulecode = ' + IntToStr(OBJ_APPLICATION);
    FIBSQL.ExecQuery;

    // Добавляем в список модуль
    LApplNameList := AddModule(OBJ_APPLICATION);
    LtmpStrings := TStringList.Create;
    try
      while not FIBSQL.Eof do
      begin
        LID := FIBSQL.FieldByName('id').AsInteger;
        LtmpStrings.Text := FIBSQL.FieldByName('displayscript').AsString;
        if LtmpStrings.IndexOf(FIBSQL.FieldByName('name').AsString) = -1 then
          LtmpStrings.Add(FIBSQL.FieldByName('name').AsString);

        // Добавляем имена ф-ций
        for I := 0 to LtmpStrings.Count - 1 do
        begin
          // Добавляем имя ф-ции
          Index := LApplNameList.IndexOf(LtmpStrings[I]);
          if Index = -1 then
            LApplNameList.AddObject(LtmpStrings[I], TObject(LID))
          else
          begin
            ErrorItem := AddErrorOrHint(vbcError);

            ErrorItem.Msg := Format(MSG_ERROR_UNINAME,
              [LtmpStrings[I], Integer(LApplNameList.Objects[Index])]);

            // Добавить поиск строки
            ErrorItem.Line := 0;

            ErrorItem.SFID := LID;
            ErrorItem.ReferenceToSF := Integer(LApplNameList.Objects[Index]);
          end;
        end;

        FIBSQL.Next;
      end;

      FIBSQL.Close;
      FIBSQL.SQL.Text :=
        'SELECT modulecode, id, displayscript, name FROM gd_function ' +
        'WHERE modulecode <> ' + IntToStr(OBJ_APPLICATION) + ' ' +
        'ORDER BY modulecode';
      FIBSQL.ExecQuery;

      LNameList := nil;
      LastModuleCode := -1;

      while not FIBSQL.Eof do
      begin
        // Добавляем в список модуль
        if LastModuleCode <> FIBSQL.FieldByName('modulecode').AsInteger then
        begin
          LastModuleCode := FIBSQL.FieldByName('modulecode').AsInteger;
          LNameList := AddModule(LastModuleCode);
        end;
        if LNameList = nil then
        begin
          FIBSQL.Next;
          Continue;
        end;

        LID := FIBSQL.FieldByName('id').AsInteger;
        LtmpStrings.Text := FIBSQL.FieldByName('displayscript').AsString;
        if LtmpStrings.IndexOf(FIBSQL.FieldByName('name').AsString) = -1 then
          LtmpStrings.Add(FIBSQL.FieldByName('name').AsString);

        // Добавляем имена ф-ций
        for I := 0 to LtmpStrings.Count - 1 do
        begin
          // Добавляем имя ф-ции
          Index := LNameList.IndexOf(LtmpStrings[I]);
          if Index = -1 then
            LNameList.AddObject(LtmpStrings[I], TObject(LID))
          else
          begin
            ErrorItem := AddErrorOrHint(vbcError);

            ErrorItem.Msg := Format(MSG_ERROR_UNINAME,
              [LtmpStrings[I], Integer(LNameList.Objects[Index])]);

            // Добавить поиск строки
            ErrorItem.Line := 0;

            ErrorItem.SFID := LID;
            ErrorItem.ReferenceToSF := Integer(LNameList.Objects[Index]);
          end;

          Index := LApplNameList.IndexOf(LtmpStrings[I]);
          if Index > -1 then
          begin
            ErrorItem := AddErrorOrHint(vbcHint);

            ErrorItem.Msg := Format(MSG_HINT,
              [LtmpStrings[I], Integer(LApplNameList.Objects[Index])]);

            // Добавить поиск строки
            ErrorItem.Line := 0;

            ErrorItem.SFID := LID;
            ErrorItem.ReferenceToSF := Integer(LApplNameList.Objects[Index]);
          end;
        end;

        FIBSQL.Next;
      end;

    finally
      LtmpStrings.Free;
    end;

    FIBSQL.Close;
  except
    FIBSQL.Close;
    FCreateWithError := True;
    raise;
  end;
end;

constructor TgsVBCompiler.Create;
begin
  FIBSQL := TIBSQL.Create(nil);
  FModuleList := TgdKeyObjectAssoc.Create(True);
  FCreateWithError := False;

  FErrorList := TObjectList.Create(True);
  FHintList := TObjectList.Create(True);

  FPredefinedNames := TStringList.Create;
  FPredefinedNames.Sorted := True;
  FPredefinedNames.Text := PredefinedNames;

end;

procedure TgsVBCompiler.CreateScriptNameList;
var
  LastModuleCode, I, LID: Integer;
  LNameList, LtmpStrings: TStringList;
begin
  if (FModuleList.Count > 0) and (not FCreateWithError) then
    Exit;

  LNameList := nil;
  FCreateWithError := False;
  try
    FModuleList.Clear;

    FIBSQL.Transaction := gdcBaseManager.ReadTransaction;
    FIBSQL.SQL.Text :=
      'SELECT modulecode, id, displayscript  FROM gd_function ' +
      '  ORDER BY modulecode';
    FIBSQL.ExecQuery;

    LastModuleCode := -1;
    LtmpStrings := TStringList.Create;
    try
      while not FIBSQL.Eof do
      begin
        // Добавляем в список модуль
        if LastModuleCode <> FIBSQL.FieldByName('modulecode').AsInteger then
        begin
          LastModuleCode := FIBSQL.FieldByName('modulecode').AsInteger;
          LNameList := AddModule(LastModuleCode);
        end;
        LID := FIBSQL.FieldByName('id').AsInteger;

        LtmpStrings.Text := FIBSQL.FieldByName('displayscript').AsString;

        // Добавляем имена внутренних ф-ций
        for I := 0 to LtmpStrings.Count - 1 do
        try
          LNameList.AddObject(LtmpStrings[I], Pointer(LID));
        except
          // Может быть, что уже есть повторяющиеся имена,
          // продолжаем запись имен и ставим флаг, что список создан с ошибкой
          FCreateWithError := True;
        end;
        FIBSQL.Next;
      end;
    finally
      LtmpStrings.Free;
    end;

    FIBSQL.Close;
  except
    FIBSQL.Close;
    FCreateWithError := True;
    raise;
  end;
end;

destructor TgsVBCompiler.Destroy;
begin
  if _VBCompiler = Self then
    _VBCompiler := nil;

  FIBSQL.Free;
  FModuleList.Free;
  FErrorList.Free;
  FHintList.Free;
  FPredefinedNames.Free;

  inherited;
end;

function TgsVBCompiler.CompileScript(gdcFunction: TgdcCustomFunction;
  const CheckUniname: Boolean; TestScriptSyntax: Boolean): Boolean;
var
  NameIndex, I: Integer;
  LNameInModuleList: TStringList;
  LNameInFuncList: TStrings;
  LSFModule, LSFID: Integer;
  ErrorItem: TgdCompileItem;

  procedure  NotUniqueExcept(const CheckID: Integer; CompileType: TVBCompileType;
    const ErrorName: String; const LineNum: Integer);
  var
    NErrorItem: TgdCompileItem;
  begin
    if CheckID <> LSFID then
    begin
      NErrorItem := AddErrorOrHint(CompileType);
      NErrorItem.AutoClear := True;
      case CompileType of
        vbcError:
          NErrorItem.Msg := Format(MSG_ERROR_UNINAME, [ErrorName, CheckID]);
        vbcHint:
          NErrorItem.Msg := Format(MSG_HINT,  [ErrorName, CheckID]);
      end;
      NErrorItem.Line := LineNum;
      NErrorItem.SFID := LSFID;
      NErrorItem.ReferenceToSF := CheckID;
    end;
  end;

  procedure CompileInModule(const ModuleCode: Integer; CompileType: TVBCompileType);
  var
    CI: Integer;
  begin
    LNameInModuleList := nil;
    with gdcFunction do
    begin
      NameIndex := FModuleList.IndexOf(ModuleCode);
      if NameIndex = -1 then
        Exit;

      LNameInModuleList := TStringList(FModuleList.ObjectByIndex[NameIndex]);

      if Assigned(LNameInModuleList) then
      begin
        for CI := 0 to LNameInFuncList.Count - 1 do
        begin
          NameIndex := LNameInModuleList.IndexOf(LNameInFuncList[CI]);
          if NameIndex > -1 then
          begin
            NameIndex := GetFirstItems(LNameInModuleList, NameIndex);
            while (NameIndex < LNameInModuleList.Count) and
              (AnsiUpperCase(LNameInModuleList[NameIndex]) = LNameInFuncList[CI]) do
            begin
              NotUniqueExcept(Integer(LNameInModuleList.Objects[NameIndex]),
                CompileType, LNameInFuncList[CI], Integer(LNameInFuncList.Objects[CI]));
              Inc(NameIndex);
            end;
          end;
        end;
      end;
    end;
  end;

begin
  CreateScriptNameList;
  FErrorList.Clear;
  FHintList.Clear;

  with gdcFunction do
  begin
    LSFID := FieldByName('id').AsInteger;
    for I := 0 to FInternalSciptNameList.Count - 1 do
    begin
      if FPredefinedNames.IndexOf(FInternalSciptNameList[I]) > -1 then
      begin
        ErrorItem := AddErrorOrHint(vbcError);
        ErrorItem.AutoClear := True;
        ErrorItem.Msg := Format(MSG_ERROR_PREDEFINED, [FInternalSciptNameList[I]]);
        ErrorItem.Line := Integer(FInternalSciptNameList.Objects[I]);
        ErrorItem.SFID := LSFID;
        ErrorItem.ReferenceToSF := -1;
      end;
    end;

    LSFModule := FieldByName('modulecode').AsInteger;
    LNameInFuncList := FInternalSciptNameList;
    if LSFModule <> OBJ_APPLICATION then
    begin
      CompileInModule(LSFModule, vbcError);
      CompileInModule(OBJ_APPLICATION, vbcHint);
    end else
      begin
        CompileInModule(OBJ_APPLICATION, vbcError);
        for I := 0 to FModuleList.Count - 1 do
        begin
          if FModuleList.Keys[I] <> OBJ_APPLICATION then
            CompileInModule(FModuleList.Keys[I], vbcHint);
        end;
      end;
  end;

  Result := FErrorList.Count = 0;
end;

procedure TgsVBCompiler.SetErrorList(const Value: TObjectList);
begin
  FErrorList := Value;
end;

procedure TgsVBCompiler.SetHintList(const Value: TObjectList);
begin
  FHintList := Value;
end;

function TgsVBCompiler.AddErrorOrHint(
  const CompileType: TVBCompileType): TgdCompileItem;

begin
  Result := nil;
  case CompileType of
    vbcError:
    begin
      Result := TgdCompileItem.Create;
      FErrorList.Add(Result);
    end;
    vbcHint:
    begin
      Result := TgdCompileItem.Create;
      FHintList.Add(Result);
    end;
  end;
end;

function TgsVBCompiler.GetFirstItems(const StrList: TStringList;
  const CurrrentIndex: Integer): Integer;
begin
  Result := CurrrentIndex;
  while (Result > 0) do
  begin
    if AnsiUpperCase(StrList[Result - 1]) = AnsiUpperCase(StrList[Result]) then
      Dec(Result)
    else
      Break;
  end;
end;

function  TgsVBCompiler.AddModule(const ModuleCode: Integer): TStringList;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupAccept;
  FModuleList.AddObject(ModuleCode, Result);
end;

procedure TgsVBCompiler.DeleteFuncInfo(const ModuleCode: Integer;
  const FunctionKey: Integer; const DeletteeList: TStrings);
var
  I: Integer;
  ModuleNameList: TStringList;
begin
  I := FModuleList.IndexOf(ModuleCode);
  if I = -1 then
    Exit;

  ModuleNameList := TStringList(FModuleList.ObjectByIndex[I]);

  // Удаляем все имена, ссылающиеся на данную ф-цию
  I := 0;
  while I < ModuleNameList.Count do
  begin
    if Integer(ModuleNameList.Objects[I]) = FunctionKey then
    begin
      if DeletteeList <> nil then
        DeletteeList.AddObject(ModuleNameList[I], ModuleNameList.Objects[I]);
      ModuleNameList.Delete(I);
    end else
      Inc(I);
  end;
end;

procedure TgsVBCompiler.AddFuncInfo(const gdcFunction: TgdcCustomFunction);
var
  I, SFID, ModuleCode: Integer;
  ModuleNameList: TStringList;
  NameList: TStrings;
begin
  if gdcFunction = nil then
    Exit;

  with gdcFunction do
  begin
    // получаем список имен
    ModuleCode := FieldByName('modulecode').AsInteger;
    I := FModuleList.IndexOf(ModuleCode);
    if I = -1 then
      ModuleNameList := AddModule(ModuleCode)
    else
      ModuleNameList := TStringList(FModuleList.ObjectByIndex[I]);

    // добавляем имена
    SFID := FieldByName('id').AsInteger;
    if Length(Trim(FieldByName('displayscript').AsString)) > 0 then
    begin
      NameList := TStringList.Create;
      try
        NameList.Text := FieldByName('displayscript').AsString;
        for I := 0 to NameList.Count - 1 do
          ModuleNameList.AddObject(NameList[I], TObject(SFID));
      finally
        NameList.Free;
      end;
    end;
  end;
end;

procedure TgsVBCompiler.AddNameList(const ModuleCode: Integer;
  NameList: TStrings);
var
  I: Integer;
  ModuleNameList: TStringList;
begin
  if NameList = nil then
    Exit;

  I := FModuleList.IndexOf(ModuleCode);
  if I = -1 then
    ModuleNameList := AddModule(ModuleCode)
  else
    ModuleNameList := TStringList(FModuleList.ObjectByIndex[I]);

  ModuleNameList.AddStrings(NameList);
end;

function TgsVBCompiler.CheckNameInVB(const Name: String): String;
begin
  Result := '';
  if FPredefinedNames.IndexOf(Name) > -1 then
    Result := Format(MSG_ERROR_PREDEFINED, [Name]);
end;

function TgsVBCompiler.CheckName(const Name: String;
  const ModuleCode: Integer): Boolean;
var
  NameIndex: Integer;
begin
  Result := True;
  CreateScriptNameList;

  NameIndex := FModuleList.IndexOf(ModuleCode);
  if NameIndex = -1 then
    Exit;

  Result :=
    TStringList(FModuleList.ObjectByIndex[NameIndex]).IndexOf(Name) = -1;
end;

initialization
  _VBCompiler := nil;
  RegisterGdcClass(TgdcCustomFunction);

finalization
  UnregisterGdcClass(TgdcCustomFunction);
  FreeAndNil(_VBCompiler);
end.

