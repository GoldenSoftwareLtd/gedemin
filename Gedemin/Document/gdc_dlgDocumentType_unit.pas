unit gdc_dlgDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Db, ActnList, StdCtrls, gsIBLookupComboBox,
  DBCtrls, Mask, ComCtrls, IBCustomDataSet, gdcBase, gdcClasses, TB2Item,
  TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls,
  gdcAcctTransaction, IBSQL, Menus, gdcFunction, gdcTree,
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
    dbcbIsCheckNumber: TDBCheckBox;
    Memo1: TMemo;
    lFunction: TLabel;
    dbeFunctionName: TDBEdit;
    Button1: TButton;
    actWizardHeader: TAction;
    Label4: TLabel;
    DBEdit1: TDBEdit;
    Button2: TButton;
    actWizardLine: TAction;
    gdcFunctionLine: TgdcFunction;
    DataSource1: TDataSource;
    actDeleteHeaderFunction: TAction;
    actDeleteLineFunction: TAction;
    Button3: TButton;
    Button4: TButton;
    Label5: TLabel;
    edFixLength: TDBEdit;
    chbxAutoNumeration: TCheckBox;
    actAutoNumeration: TAction;
    lblNumCompany: TLabel;
    procedure lvVariableDblClick(Sender: TObject);
    procedure dbcMaskChange(Sender: TObject);
    procedure edCurrentNumberExit(Sender: TObject);
    procedure dbeIncrementExit(Sender: TObject);
    procedure iblcHeaderTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure iblcLineTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure actOkUpdate(Sender: TObject);
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

  private
    FScriptChanged: Boolean;

  protected
    function DlgModified: Boolean; override;
    function GetRelation(isDocument: Boolean): TatRelation;

    procedure BeforePost; override;

  public
    function TestCorrect: Boolean; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;

    procedure Post; override;
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
  rp_report_const,      gdcBaseInterface,            gdcExplorer;

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
    if (gdcObject.FieldByName('id').AsInteger > cstUserIDStart) and gdcObject.FieldByName('headerrelkey').IsNull then
    begin
      gdcObject.FieldByName('headerrelkey').FocusControl;
      Result := False;
      raise EgdcIBError.Create('���������� ������� ������� ��� ����� ���������!');
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
  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.Show;
    raise EgdcIBError.Create(
      '� ������������ �� ���������� ������ ���� ������ ��������� �������');
  end;

  if gdcObject.State <> dsInsert then
    abort
  else
  begin
    if Pos(UserPrefix, UpperCase(edEnglishName.Text)) = 0 then
      edEnglishName.Text := UserPrefix + edEnglishName.Text;
    aNewObject.FieldByName('relationname').AsString := edEnglishName.Text;
    aNewObject.FieldByName('lname').AsString := edDocumentName.Text;
    aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
  end;
end;

procedure Tgdc_dlgDocumentType.iblcLineTableCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.Show;
    raise EgdcIBError.Create('� ������������ �� ���������� ������ ���� ������ ��������� �������');
  end;

  if Pos(UserPrefix, UpperCase(edEnglishName.Text)) = 0 then
    edEnglishName.Text := UserPrefix + edEnglishName.Text;
  aNewObject.FieldByName('relationname').AsString := edEnglishName.Text + 'LINE';
  aNewObject.FieldByName('lname').AsString := edDocumentName.Text + '(�������)';
  aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;

end;

procedure Tgdc_dlgDocumentType.actOkUpdate(Sender: TObject);
begin
  inherited;
  iblcHeaderTable.Enabled := edEnglishName.Text > '';
  iblcLineTable.Enabled := iblcHeaderTable.Enabled and (iblcHeaderTable.CurrentKey > '');
end;

procedure Tgdc_dlgDocumentType.edEnglishNameExit(Sender: TObject);
begin
  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.SetFocus;
    raise EgdcIBError.Create(
      '� ������������ �� ���������� ������ ���� ������ ��������� �������');
  end;
end;

function Tgdc_dlgDocumentType.DlgModified: Boolean;
begin
  Result := True;
end;

function Tgdc_dlgDocumentType.GetRelation(isDocument: Boolean): TatRelation;
var
  CurrKey: String;
begin
  if isDocument then
    CurrKey := iblcHeaderTable.CurrentKey
  else
    CurrKey := iblcLineTable.CurrentKey;

  if CurrKey > '' then
    Result := atDatabase.Relations.ByID(StrToInt(CurrKey))
  else
    Result := nil;
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

  edEnglishName.Text := '';
  edEnglishName.MaxLength := 14;

  ActivateTransaction(gdcObject.Transaction);

  List := TStringList.Create;
  ibsql := TIBSQL.Create(nil);
  try
    List.Sorted := True;
    List.Duplicates := dupIgnore;

    List.Add('"NUMBER"');
    List.Add('"DAY"-"NUMBER"');
    List.Add('"DAY"."MONTH"-"NUMBER"');

    ibsql.Database := gdcObject.Database;
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

    if not gdcObject.FieldByName('headerrelkey').IsNull then
    begin
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = ' +
        gdcObject.FieldByName('headerrelkey').AsString;
      ibsql.ExecQuery;
      edEnglishName.Text := ibsql.FieldByName('relationname').AsString;
      ibsql.Close;
    end;

  finally
    List.Free;
    ibsql.Free;
  end;

  dbcMaskChange(dbcMask);
  gdcFunctionHeader.Transaction := gdcObject.Transaction;
  gdcFunctionLine.Transaction := gdcObject.Transaction;
  
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
  D: TDataSet;
  Str, PStr: TStream;
  Params: TgsParamList;
  FunctionCreater: TNewDocumentTransactioCreater;
  FunctionKeyField, FunctionTemplateField: string;
  FunctionNameSufix: string;
  gdcFunction: TgdcFunction;
  DS: TDataSetState;
  DocumentPart: TgdcDocumentClassPart;
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

  F := TdlgFunctionWisard.Create(Application);
  try
    D := dsgdcBase.DataSet;
    if D <> nil then
    begin
      DS := gdcFunction.State;
      if not (gdcFunction.State in [dsEdit, dsInsert]) then
      begin
        if D.FieldByName(FunctionKeyField).AsInteger = 0 then
        begin
          gdcFunction.Insert;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnModule).AsString := scrEntryModuleName;
          gdcFunction.FieldByName(fnName).AsString := Format('AutoEntryScript%d_%d_%s',
            [gdcFunction.FieldByName(fnId).AsInteger, IbLogin.DBID,
            FunctionNameSufix]);
          gdcFunction.FieldByName(fnLANGUAGE).AsString := DefaultLanguage;
        end else
          gdcFunction.Edit;
      end;

      Str := D.CreateBlobStream(D.FieldByName(FunctionTemplateField), bmReadWrite);
      try
        FunctionCreater := TNewDocumentTransactioCreater.Create;
        try
          FunctionCreater.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);
          FunctionCreater.Stream := Str;
          FunctionCreater.FunctionName := gdcFunction.FieldByName(fnName).AsString;
          FunctionCreater.DocumentTypeRUID := gdcBaseManager.GetRUIDStringById(D.FieldByName(fnId).AsInteger);
          FunctionCreater.DocumentPart := DocumentPart;
          F.CreateNewFunction(FunctionCreater);
        finally
          FunctionCreater.Free;
        end;

        FScriptChanged := F.ShowModal = mrOk;
        if FScriptChanged then
        begin
          Str.size := 0;
          Str.Position := 0;
          F.SaveToStream(Str);
          gdcFunction.FieldByName(fnScript).AsString := F.Script;
          gdcFunction.FieldByName(fnName).AsString := F.MainFunctionName;
          Params := TgsParamList.Create;
          try
            Params.Assign(F.Params);
            PStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
            try
              Pstr.Size := 0;
              PStr.Position := 0;
              Params.SaveToStream(PStr);
            finally
              PStr.Free;
            end;
          finally
            Params.Free;
          end;
          D.FieldByName(functionkeyfield).AsInteger :=
            gdcFunction.FieldByName(fnid).AsInteger;
        end else
        begin
          if not (DS in [dsEdit, dsInsert]) then
            gdcFunction.Cancel;
        end;
      finally
        Str.Free;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure Tgdc_dlgDocumentType.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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

{  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Post;}

  inherited;

  if FScriptChanged then
  begin
    ScriptFactory.ReloadFunction(gdcObject.FieldByName('headerfunctionkey').AsInteger);
    ScriptFactory.ReloadFunction(gdcObject.FieldByName('linefunctionkey').AsInteger);
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
  Id: Integer;
begin
  if not gdcObject.FieldByName('headerfunctionkey').IsNull then
  begin
    if MessageDlg('�� ������������� ������ ������� �������?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Id := gdcObject.FieldByName('headerfunctionkey').AsInteger;
      if Id > 0 then
      begin
        gdcBaseManager.ExecSingleQuery('UPDATE gd_documenttype SET headerfunctionkey = NULL WHERE id = ' +
          gdcObject.FieldByName(fnID).AsString,  gdcObject.Transaction );

        if gdcFunctionHeader.Active then
          gdcFunctionHeader.Close;
        gdcFunctionHeader.Id := Id;
        gdcFunctionHeader.Open;
        try
          gdcFunctionHeader.Delete;
        except
        end;
      end;
      gdcObject.FieldByName('headerfunctionkey').Clear;
      gdcObject.FieldByName('headerfunctiontemplate').Clear;
    end;
  end;
end;

procedure Tgdc_dlgDocumentType.actDeleteLineFunctionExecute(
  Sender: TObject);
var
  Id: Integer;
begin
  if not gdcObject.FieldByName('linefunctionkey').IsNull then
  begin
    if MessageDlg('�� ������������� ������ ������� �������?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Id := gdcObject.FieldByName('linefunctionkey').AsInteger;
      if Id > 0 then
      begin
        gdcBaseManager.ExecSingleQuery('UPDATE gd_documenttype SET linefunctionkey = NULL WHERE id = ' +
          gdcObject.FieldByName(fnID).AsString,  gdcObject.Transaction );

        if gdcFunctionLine.Active then
          gdcFunctionLine.Close;
        gdcFunctionLine.Id := Id;
        gdcFunctionLine.Open;
        try
          gdcFunctionLine.Delete;
        except
        end;
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
  ibsql: TIBSQL;
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
  ActivateTransaction(gdcObject.Transaction);

  //������� �������� ����� ����� � �������������
  if (gdcObject.FieldByName('branchkey').AsInteger > 0) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := gdcBaseManager.ReadTRansaction;
      ibsql.SQL.Text := 'SELECT parent FROM gd_command WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcObject.FieldByName('branchkey').AsInteger;
      ibsql.ExecQuery;

      if (ibsql.RecordCount > 0) and (ibsql.FieldByName('parent').AsInteger > 0) then
        iblcExplorerBranch.CurrentKeyInt := ibsql.FieldByName('parent').AsInteger;
    finally
      ibsql.Free;
    end;
  end;

  //��� �������������� ���������� ����� ��������� ��������� ����� �������������
  iblcExplorerBranch.Enabled := not (sMultiple in gdcObject.BaseState);

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
var
  gdcExplorer: TgdcExplorer;

  procedure _InsertExplorer;
  begin
    gdcExplorer.Open;
    gdcExplorer.Insert;
    try
      gdcExplorer.FieldByName('parent').AsInteger := iblcExplorerBranch.CurrentKeyInt;
      gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
      gdcExplorer.FieldByName('classname').AsString :=
        (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
      gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
      gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
      gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
      gdcExplorer.Post;
      gdcObject.FieldByName('branchkey').AsInteger := gdcExplorer.ID;
    finally
      if gdcExplorer.State in dsEditModes then
        gdcExplorer.Cancel;
    end;
  end;

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
    DatabaseErrorFmt(SFieldRequired, [gdcObject.FieldByName('name').DisplayName]);
  end;

  TestCorrect;

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
        {���� � ��� �� ���� ����� � ������������� � �� �������� �� �������}
        _InsertExplorer;
      end
      else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
        (iblcExplorerBranch.CurrentKeyInt = -1)
      then
      begin
        {���� � ��� ���� ����� � ������������� � �� �������� �� �������}
        gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
        gdcExplorer.Open;
        if gdcExplorer.RecordCount > 0 then
        begin
          gdcExplorer.Delete;
        end;
        gdcObject.FieldByName('branchkey').Clear;
      end
      else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
        (iblcExplorerBranch.CurrentKeyInt > 0)
      then
      begin
        {���� � ��� ���� ����� � �������������, �������������� �� � ������� ������������, ��������}
        gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
        gdcExplorer.Open;
        if (gdcExplorer.RecordCount = 0) or
          (gdcExplorer.FieldByName('subtype').AsString <> gdcObject.FieldByName('ruid').AsString)
        then
        begin
          _InsertExplorer;
        end else
        begin
          gdcExplorer.Edit;
          gdcExplorer.FieldByName('parent').AsInteger := iblcExplorerBranch.CurrentKeyInt;
          gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
          gdcExplorer.Post;
        end;
      end;
    finally
      gdcExplorer.Free
    end;
  except
    // ����� ��� ����������. ���� �������� ���� ������, �� ���
    // ��� �� ����� �������������� � ���� � �� ������ ����������
    // ������������� ����� ������.
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

    lblNumCompany.Caption := ' ��������� ������������� ���������� ��� ����������� "' +
      IBLogin.CompanyName + '".';
  end;
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
  (Sender as TAction).Enabled := IBLogin.IsIBUserAdmin;
end;

procedure Tgdc_dlgDocumentType.actWizardLineUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IBLogin.IsIBUserAdmin;
end;

initialization
  RegisterFrmClass(Tgdc_dlgDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_dlgDocumentType);
end.
