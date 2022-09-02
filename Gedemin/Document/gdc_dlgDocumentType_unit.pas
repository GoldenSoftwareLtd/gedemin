// ShlTanya, 24.02.2019

unit gdc_dlgDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Db, ActnList, StdCtrls, gsIBLookupComboBox,
  DBCtrls, Mask, ComCtrls, IBCustomDataSet, gdcBase, gdcClasses_interface,
  gdcClasses, TB2Item, TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ExtCtrls, gdcAcctTransaction, IBSQL, Menus, gdcFunction, gdcTree,
  gdcDelphiObject, gdcEvent, at_Classes, gdcCustomFunction, dbConsts;

type
  Tgdc_dlgDocumentType = class(Tgdc_dlgTR)
    gdcFunctionHeader: TgdcFunction;
    dsFunction: TDataSource;
    actCreateEvent: TAction;
    actModifyEvent: TAction;
    actDeleteEvent: TAction;
    pcMain: TPageControl;
    tsCommon: TTabSheet;
    lblDocumentName: TLabel;
    lblComment: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edDocumentName: TDBEdit;
    edDescription: TDBMemo;
    iblcExplorerBranch: TgsIBLookupComboBox;
    iblcHeaderTable: TgsIBLookupComboBox;
    iblcLineTable: TgsIBLookupComboBox;
    edEnglishName: TEdit;
    tsNumerator: TTabSheet;
    gbNumber: TGroupBox;
    lblCurrentNumber: TLabel;
    lblIncrement: TLabel;
    edCurrentNumber: TDBEdit;
    dbeIncrement: TDBEdit;
    gbMask: TGroupBox;
    lblMask: TLabel;
    lblExample: TLabel;
    lvVariable: TListView;
    dbcMask: TDBComboBox;
    edExample: TEdit;
    dbcbIsCommon: TDBCheckBox;
    Memo1: TMemo;
    lFunction: TLabel;
    dbeFunctionName: TDBEdit;
    btnConstr1: TButton;
    actWizardHeader: TAction;
    Label4: TLabel;
    DBEdit1: TDBEdit;
    btnConstr2: TButton;
    actWizardLine: TAction;
    gdcFunctionLine: TgdcFunction;
    DataSource1: TDataSource;
    actDeleteHeaderFunction: TAction;
    actDeleteLineFunction: TAction;
    btnDel1: TButton;
    btnDel2: TButton;
    Label5: TLabel;
    edFixLength: TDBEdit;
    chbxAutoNumeration: TCheckBox;
    actAutoNumeration: TAction;
    lblNumCompany: TLabel;
    dbrgIsCheckNumber: TDBRadioGroup;
    edParentName: TEdit;
    lblParent: TLabel;
    procedure lvVariableDblClick(Sender: TObject);
    procedure dbcMaskChange(Sender: TObject);
    procedure edCurrentNumberExit(Sender: TObject);
    procedure dbeIncrementExit(Sender: TObject);
    procedure iblcHeaderTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure iblcLineTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure edEnglishNameExit(Sender: TObject);
    procedure actWizardHeaderExecute(Sender: TObject);
    procedure actDeleteHeaderFunctionExecute(Sender: TObject);
    procedure actDeleteLineFunctionExecute(Sender: TObject);
    procedure actDeleteHeaderFunctionUpdate(Sender: TObject);
    procedure actDeleteLineFunctionUpdate(Sender: TObject);
    procedure edFixLengthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actAutoNumerationExecute(Sender: TObject);
    procedure actWizardHeaderUpdate(Sender: TObject);
    procedure actWizardLineUpdate(Sender: TObject);
    procedure iblcHeaderTableChange(Sender: TObject);

  private
    FScriptChanged: Boolean;

  protected
    function DlgModified: Boolean; override;
    procedure BeforePost; override;
    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure Post; override;
    function GetRelation(const ADocHeaderRelation: Boolean): TatRelation;
  end;

var
  gdc_dlgDocumentType: Tgdc_dlgDocumentType;

implementation
{$R *.DFM}

uses
  Storages,             gdc_frmG_unit,               gd_createable_form,
  gd_ClassList,         gd_directories_const,        gd_strings,
  wiz_Main_Unit,        gd_security_operationconst,  gd_security,
  gd_i_ScriptFactory,   prm_ParamFunctions_unit,     gdcConstants,
  rp_report_const,      gdcBaseInterface,            gdcExplorer,
  jclStrings;

{ Tgdc_dlgDocumentType }

function Tgdc_dlgDocumentType.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGDOCUMENTTYPE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGDOCUMENTTYPE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDOCUMENTTYPE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDOCUMENTTYPE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDOCUMENTTYPE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result then
  begin
    if not CheckEnName(edEnglishName.Text) then
    begin
      edEnglishName.SetFocus;
      raise EgdcIBError.Create(
        '¬ наименовании на английском должны быть только латинские символы');
    end;

    if (gdcObject.ID >= cstUserIDStart) and gdcObject.FieldByName('headerrelkey').IsNull then
    begin
      gdcObject.FieldByName('headerrelkey').FocusControl;
      Result := False;
      raise EgdcIBError.Create('Ќеобходимо выбрать таблицу дл€ шапки документа!');
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDOCUMENTTYPE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDOCUMENTTYPE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDocumentType.lvVariableDblClick(Sender: TObject);
begin
  if Assigned(lvVariable.Selected) then
  begin
    if not (dbcMask.Field.Dataset.State in [dsInsert, dsEdit]) then
      dbcMask.Field.Dataset.Edit;

    dbcMask.Field.AsString :=
      dbcMask.Field.AsString +
      '"' +
      Copy(
        lvVariable.Selected.Caption,
        1,
        AnsiPos(' - ', lvVariable.Selected.Caption) - 1
      ) +
      '"';

    dbcMaskChange(dbcMask);
  end;
end;

procedure Tgdc_dlgDocumentType.dbcMaskChange(Sender: TObject);
begin
  if gdcObject.State in dsEditModes then
  begin
    dbcMask.OnChange := nil;
    try
      gdcObject.FieldByName('mask').AsString := dbcMask.Text;
      edExample.Text := EncodeNumber(dbcMask.Text,
        gdcObject.FieldByName('lastnumber').AsInteger, SysUtils.Now,
        gdcObject.FieldByName('fixlength').AsInteger);
    finally
      dbcMask.OnChange := dbcMaskChange;
    end;
  end;
end;

procedure Tgdc_dlgDocumentType.edCurrentNumberExit(Sender: TObject);
begin
  dbcMaskChange(dbcMask);
end;

procedure Tgdc_dlgDocumentType.dbeIncrementExit(Sender: TObject);
begin
  dbcMaskChange(dbcMask);
end;


procedure Tgdc_dlgDocumentType.iblcHeaderTableCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if atDatabase.Relations.ByRelationName(edEnglishName.Text) = nil then
    aNewObject.FieldByName('relationname').AsString := edEnglishName.Text;
  aNewObject.FieldByName('lname').AsString := edDocumentName.Text;
  aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
end;

procedure Tgdc_dlgDocumentType.iblcLineTableCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
var
  S: String;
begin
  S := edEnglishName.Text + 'LINE';
  if atDatabase.Relations.ByRelationName(S) = nil then
    aNewObject.FieldByName('relationname').AsString := S;
  aNewObject.FieldByName('lname').AsString := edDocumentName.Text + '(позици€)';
  aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
end;

procedure Tgdc_dlgDocumentType.edEnglishNameExit(Sender: TObject);
begin
  Assert(atDatabase <> nil);

  edEnglishName.Text := StringReplace(edEnglishName.Text, ' ', '', [rfReplaceAll]);

  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.SetFocus;
    MessageBox(Handle,
      '¬ наименовании таблицы допускаютс€ только латинские символы.',
      '¬нимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    Abort;
  end;

  if (StrIPos(UserPrefix, edEnglishName.Text) <> 1) and
    (edEnglishName.Text > '') and
    (atDatabase.Relations.ByRelationName(edEnglishName.Text) = nil)
  then
    edEnglishName.Text := UserPrefix + edEnglishName.Text;

  if (iblcHeaderTable.CurrentKeyInt > 0) and
      ((atDatabase.Relations.ByRelationName(edEnglishName.Text) = nil)
      or (atDatabase.Relations.ByRelationName(edEnglishName.Text).ID <> iblcHeaderTable.CurrentKeyInt)) then
  begin
    iblcHeaderTable.CurrentKeyInt := -1;
    iblcLineTable.CurrentKeyInt := -1;
  end;
end;

function Tgdc_dlgDocumentType.DlgModified: Boolean;
begin
  Result := True;
end;

function Tgdc_dlgDocumentType.GetRelation(const ADocHeaderRelation: Boolean): TatRelation;
begin
  Assert(atDatabase <> nil);
  if ADocHeaderRelation then
    Result := atDatabase.Relations.ByID(iblcHeaderTable.CurrentKeyInt)
  else
    Result := atDatabase.Relations.ByID(iblcLineTable.CurrentKeyInt);
end;

procedure Tgdc_dlgDocumentType.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  List: TStringList;
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDOCUMENTTYPE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDOCUMENTTYPE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDOCUMENTTYPE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  ActivateTransaction(gdcObject.Transaction);

  gdcFunctionHeader.Transaction := gdcObject.Transaction;
  gdcFunctionLine.Transaction := gdcObject.Transaction;

  List := TStringList.Create;
  ibsql := TIBSQL.Create(nil);
  try
    List.Sorted := True;
    List.Duplicates := dupIgnore;

    List.Add('"NUMBER"');
    List.Add('"DAY"-"NUMBER"');
    List.Add('"DAY"."MONTH"-"NUMBER"');

    ibsql.Transaction := gdcObject.ReadTransaction;

    ibsql.SQL.Text := 'SELECT DISTINCT mask FROM gd_lastnumber';
    ibsql.ExecQuery;

    while not ibsql.EOF do
    begin
      if ibsql.FieldByName('mask').AsString > '' then
        List.Add(ibsql.FieldByName('mask').AsString);

      ibsql.Next;
    end;

    dbcMask.Items.Assign(List);
  finally
    List.Free;
    ibsql.Free;
  end;

  edEnglishName.MaxLength := 14;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDOCUMENTTYPE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDOCUMENTTYPE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDocumentType.actWizardHeaderExecute(Sender: TObject);
var
  F: TdlgFunctionWisard;
  Str, PStr: TStream;
  Params: TgsParamList;
  FunctionCreater: TNewDocumentTransactioCreater;
  FunctionKeyField, FunctionTemplateField: string;
  FunctionNameSufix: string;
  gdcFunction: TgdcFunction;
  DS: TDataSetState;
  DocumentPart: TgdcDocumentClassPart;
  ibsql: TIBSQL;
  ParentFunctionName: String;
  DE: TgdDocumentEntry;
begin
  if Sender = actWizardHeader then
  begin
    FunctionKeyField := 'headerfunctionkey';
    FunctionTemplateField := 'headerfunctiontemplate';
    gdcFunction := gdcFunctionHeader;
    FunctionNameSufix := 'header';
    DocumentPart := dcpHeader;
  end else
  begin
    FunctionKeyField := 'linefunctionkey';
    FunctionTemplateField := 'linefunctiontemplate';
    gdcFunction := gdcFunctionLine;
    FunctionNameSufix := 'line';
    DocumentPart := dcpLine;
  end;

  Str := nil;
  F := TdlgFunctionWisard.Create(Application);
  try
    DS := gdcFunction.State;

    if not (DS in [dsEdit, dsInsert]) then
    begin
      if gdcObject.FieldByName(FunctionKeyField).IsNull then
      begin
        gdcFunction.Insert;
        gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
        gdcFunction.FieldByName(fnModule).AsString := scrEntryModuleName;
        gdcFunction.FieldByName(fnName).AsString := Format('AutoEntryScript%d_%d_%s',
          [TID264(gdcFunction.ID), IbLogin.DBID, FunctionNameSufix]);
        gdcFunction.FieldByName(fnLANGUAGE).AsString := DefaultLanguage;
      end else
        gdcFunction.Edit;
    end;

    Str := gdcObject.CreateBlobStream(gdcObject.FieldByName(FunctionTemplateField), bmRead);
    ParentFunctionName := '';

    if gdcObject.FieldByName(FunctionTemplateField).IsNull then
    begin
      DE := gdClassList.FindDocByTypeID(GetTID(gdcObject.FieldByName('parent')), dcpHeader, True);
      while (DE <> nil) and (ParentFunctionName = '') do
      begin
        ibsql := TIBSQL.Create(nil);
        try
          ibsql.Transaction := gdcObject.ReadTransaction;
            ibsql.SQL.Text :=
              'SELECT '#13#10 +
              '  d.' + FunctionTemplateField + ',' + #13#10 +
              '  f.Name '#13#10 +
              'FROM gd_documenttype d '#13#10 +
              'LEFT JOIN gd_function f '#13#10 +
              '  ON d.' + FunctionKeyField + ' = f.id '#13#10 +
              'WHERE '#13#10 +
              '  d.id = :id '#13#10 +
              '  AND d.documenttype = ''D'' '#13#10 +
              '  AND d.' + FunctionTemplateField + ' IS NOT NULL';
          SetTID(ibsql.ParamByName('id'), DE.TypeID);
          ibsql.ExecQuery;
          if (not ibsql.Eof) and (not ibsql.FieldByName(FunctionTemplateField).IsNull) then
          begin
            Str.Free;
            Str := TStringStream.Create(ibsql.FieldByName(FunctionTemplateField).AsString);
            ParentFunctionName := ibsql.FieldByName(fnName).AsString;
            break;
          end;
        finally
          ibsql.Free;
        end;

        if DE = DE.GetRootSubType then
          break;

        DE := TgdDocumentEntry(DE.Parent);
      end;
    end;

    FunctionCreater := TNewDocumentTransactioCreater.Create;
    try
      FunctionCreater.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);
      FunctionCreater.Stream := Str;
      FunctionCreater.FunctionName := gdcFunction.FieldByName(fnName).AsString;
      FunctionCreater.ParentFunctionName := ParentFunctionName;
      FunctionCreater.DocumentTypeRUID := gdcBaseManager.GetRUIDStringById(gdcObject.ID);
      FunctionCreater.DocumentPart := DocumentPart;
      F.CreateNewFunction(FunctionCreater);
    finally
      FunctionCreater.Free;
    end;

    FScriptChanged := F.ShowModal = mrOk;

    if FScriptChanged then
    begin
      Str.Free;
      Str := gdcObject.CreateBlobStream(gdcObject.FieldByName(FunctionTemplateField), DB.bmReadWrite);
      Str.Size := 0;
      Str.Position := 0;
      F.SaveToStream(Str);
      gdcFunction.FieldByName(fnScript).AsString := F.Script;
      gdcFunction.FieldByName(fnName).AsString := F.MainFunctionName;
      Params := TgsParamList.Create;
      try
        Params.Assign(F.Params);
        PStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
        try
          PStr.Size := 0;
          PStr.Position := 0;
          Params.SaveToStream(PStr);
        finally
          PStr.Free;
        end;
      finally
        Params.Free;
      end;

      SetTID(gdcObject.FieldByName(functionkeyfield), gdcFunction.FieldByName(fnid));
    end else
    begin
      if not (DS in [dsEdit, dsInsert]) then
        gdcFunction.Cancel;
    end;
  finally
    Str.Free;
    F.Free;
  end;
end;

procedure Tgdc_dlgDocumentType.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  gdcExplorer: TgdcExplorer;

  procedure _InsertExplorer;
  begin
    gdcExplorer.Open;
    gdcExplorer.Insert;
    try
      SetTID(gdcExplorer.FieldByName('parent'), iblcExplorerBranch.CurrentKeyInt);
      gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
      gdcExplorer.FieldByName('classname').AsString :=
        (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
      gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
      gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
      gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
      gdcExplorer.Post;
      SetTID(gdcObject.FieldByName('branchkey'), gdcExplorer.ID);
    finally
      if gdcExplorer.State in dsEditModes then
        gdcExplorer.Cancel;
    end;
  end;

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDOCUMENTTYPE', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDOCUMENTTYPE', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDOCUMENTTYPE',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;

  {END MACRO}
 if iblcExplorerBranch.Enabled then
  try
    gdcExplorer := TgdcExplorer.CreateSubType(nil, '', 'ByID');
    try
      gdcExplorer.Transaction := gdcObject.Transaction;
      gdcExplorer.ReadTransaction := gdcObject.ReadTransaction;
      if (gdcObject.FieldByName('branchkey').IsNull) and
        (iblcExplorerBranch.CurrentKeyInt > 0)
      then
      begin
        {если у нас не было ветки в исследователе и мы захотели ее создать}
        _InsertExplorer;
      end
      else if (GetTID(gdcObject.FieldByName('branchkey')) > 0) and
        (iblcExplorerBranch.CurrentKeyInt = -1)
      then
      begin
        {если у нас была ветка в исследователе и мы захотели ее удалить}
        gdcExplorer.ID := GetTID(gdcObject.FieldByName('branchkey'));
        gdcExplorer.Open;
        if not gdcExplorer.EOF then
        begin
          gdcExplorer.Delete;
        end;
        gdcObject.FieldByName('branchkey').Clear;
      end
      else if (GetTID(gdcObject.FieldByName('branchkey')) > 0) and
        (iblcExplorerBranch.CurrentKeyInt > 0)
      then
      begin
        {если у нас была ветка в исследователе, подредактируем ее и заменим наименование, родител€}
        gdcExplorer.ID := GetTID(gdcObject.FieldByName('branchkey'));
        gdcExplorer.Open;
        if gdcExplorer.EOF or
          (gdcExplorer.FieldByName('subtype').AsString <> gdcObject.FieldByName('ruid').AsString)
        then
        begin
          _InsertExplorer;
        end else
        begin
          gdcExplorer.Edit;
          SetTID(gdcExplorer.FieldByName('parent'), iblcExplorerBranch.CurrentKeyInt);
          gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
          gdcExplorer.Post;
        end;
      end;
    finally
      gdcExplorer.Free
    end;
  except
    // гасим все исключени€. если добавили поле ссылку, то оно
    // еще не будет присутствовать в базе и на стадии обновлени€
    // исследовател€ кинет ошибку.
  end;

  inherited;

  if FScriptChanged then
  begin
    ScriptFactory.ReloadFunction(GetTID(gdcObject.FieldByName('headerfunctionkey')));
    ScriptFactory.ReloadFunction(GetTID(gdcObject.FieldByName('linefunctionkey')));
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDOCUMENTTYPE', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDOCUMENTTYPE', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDocumentType.actDeleteHeaderFunctionExecute(
  Sender: TObject);
var
  Id: TID;
begin
  if not gdcObject.FieldByName('headerfunctionkey').IsNull then
  begin
    if MessageDlg('¬ы действительно хотите удалить функцию?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Id := GetTID(gdcObject.FieldByName('headerfunctionkey'));
      gdcBaseManager.ExecSingleQuery('UPDATE gd_documenttype SET headerfunctionkey = NULL WHERE id = :id',
        TID2V(gdcObject.ID), gdcObject.Transaction);
      if gdcFunctionHeader.Active then
        gdcFunctionHeader.Close;
      gdcFunctionHeader.Id := Id;
      gdcFunctionHeader.Open;
      try
        if not gdcFunctionHeader.EOF then
          gdcFunctionHeader.Delete;
      except
      end;
      gdcObject.FieldByName('headerfunctionkey').Clear;
      gdcObject.FieldByName('headerfunctiontemplate').Clear;
    end;
  end;
end;

procedure Tgdc_dlgDocumentType.actDeleteLineFunctionExecute(
  Sender: TObject);
var
  Id: TID;
begin
  if not gdcObject.FieldByName('linefunctionkey').IsNull then
  begin
    if MessageDlg('¬ы действительно хотите удалить функцию?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Id := GetTID(gdcObject.FieldByName('linefunctionkey'));
      gdcBaseManager.ExecSingleQuery('UPDATE gd_documenttype SET linefunctionkey = NULL WHERE id = :id',
        TID2V(gdcObject.ID), gdcObject.Transaction);
      if gdcFunctionLine.Active then
        gdcFunctionLine.Close;
      gdcFunctionLine.Id := Id;
      gdcFunctionLine.Open;
      try
        if not gdcFunctionLine.EOF then
          gdcFunctionLine.Delete;
      except
      end;
      gdcObject.FieldByName('linefunctionkey').Clear;
      gdcObject.FieldByName('linefunctiontemplate').Clear;
    end;
  end;
end;

procedure Tgdc_dlgDocumentType.actDeleteHeaderFunctionUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(gdcObject)
    and gdcObject.Active
    and not gdcObject.FieldByName('headerfunctionkey').IsNull
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgDocumentType.actDeleteLineFunctionUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(gdcObject)
    and gdcObject.Active
    and not gdcObject.FieldByName('linefunctionkey').IsNull
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgDocumentType.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  DE, DEParent: TgdDocumentEntry;
  R: OleVariant;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDOCUMENTTYPE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDOCUMENTTYPE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDOCUMENTTYPE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  DE := gdClassList.FindDocByTypeID(gdcObject.ID, dcpHeader, True);
  DEParent := gdClassList.FindDocByTypeID(GetTID(gdcObject.FieldByName('parent')), dcpHeader, True);

  if (DE <> nil) and (DEParent <> nil) and (DE.Parent <> DEParent) then
    raise Exception.Create('Internal consistency check');

  if DE <> nil then
    edEnglishName.Text := DE.HeaderRelName
  else if DEParent <> nil then
    edEnglishName.Text := DEParent.HeaderRelName
  else
    edEnglishName.Text := '';

  if DEParent <> nil then
  begin
    edParentName.Text := DEParent.Caption;
    iblcHeaderTable.gdClassName := 'TgdcInheritedDocumentTable';
    iblcLineTable.gdClassName := 'TgdcInheritedDocumentTable';
    iblcLineTable.Enabled := DEParent.LineRelKey > 0;
  end else
  begin
    edParentName.Text := '';
    iblcHeaderTable.gdClassName := 'TgdcDocumentTable';
    iblcLineTable.gdClassName := 'TgdcDocumentLineTable';
    iblcLineTable.Enabled := True;
  end;

  //¬ыведем родител€ нашей ветки в исследователе
  if gdcBaseManager.ExecSingleQueryResult('SELECT parent FROM gd_command WHERE id = :id AND parent IS NOT NULL',
    TID2V(gdcObject.FieldByName('branchkey')), R) then
  begin
    iblcExplorerBranch.CurrentKeyInt := GetTID(R[0, 0]);
  end;

  //ƒл€ редактировани€ нескольких веток запрещаем изменении ветки исследовател€
  iblcExplorerBranch.Enabled := not (sMultiple in gdcObject.BaseState);

  dbcMaskChange(dbcMask);

  //
  chbxAutoNumeration.Checked := gdcObject.FieldByName('MASK').AsString = '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDOCUMENTTYPE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDOCUMENTTYPE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDocumentType.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDOCUMENTTYPE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDOCUMENTTYPE', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDOCUMENTTYPE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDOCUMENTTYPE',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDOCUMENTTYPE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.FieldByName('name').IsNull then
  begin
    gdcObject.FieldByName('name').FocusControl;
    raise EgdcIBError.Create('”кажите наименование типового документа!');
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDOCUMENTTYPE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDOCUMENTTYPE', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDocumentType.edFixLengthChange(Sender: TObject);
begin
  edExample.Text := EncodeNumber(dbcMask.Text,
    gdcObject.FieldByName('lastnumber').AsInteger, SysUtils.Now,
    StrToIntDef(edFixLength.Text, 0));
end;

procedure Tgdc_dlgDocumentType.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  inherited;

  if IBLogin <> nil then
  begin
    if not IBLogin.IsUserAdmin then
      for I := pcMain.PageCount - 1 downto 0 do
        pcMain.Pages[I].TabVisible := pcMain.Pages[I] = tsNumerator;

    lblNumCompany.Caption := ' ѕараметры автонумерации документов дл€ организации "' +
      IBLogin.CompanyName + '".';
  end;

  if tsCommon.TabVisible then
    pcMain.ActivePage := tsCommon;
end;

procedure Tgdc_dlgDocumentType.actAutoNumerationExecute(Sender: TObject);
begin
  if chbxAutoNumeration.Checked then
  begin
    gdcObject.FieldByName('MASK').AsString := '';
    gbMask.Visible := False;
    gbNumber.Visible := False;
  end else
  begin
    gbMask.Visible := True;
    gbNumber.Visible := True;
    gdcObject.FieldByName('MASK').AsString := '"NUMBER"';
  end;
end;

procedure Tgdc_dlgDocumentType.actWizardHeaderUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IBLogin.IsIBUserAdmin and (gdcObject <> nil);
end;

procedure Tgdc_dlgDocumentType.actWizardLineUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IBLogin.IsIBUserAdmin and (gdcObject <> nil);
end;

procedure Tgdc_dlgDocumentType.iblcHeaderTableChange(Sender: TObject);
var
  R: TatRelation;
begin
  Assert(atDatabase <> nil);

  if iblcHeaderTable.CurrentKeyInt > -1 then
  begin
    R := atDatabase.Relations.ByID(iblcHeaderTable.CurrentKeyInt);
    if (R <> nil) and (edEnglishName.Text <> R.RelationName) then
      edEnglishName.Text := R.RelationName;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_dlgDocumentType);
end.
