unit rp_dlgEditFunction_unit;

interface

uses
  Windows, IBDatabase, Dialogs, ImgList, Controls, Classes, ActnList, Db,
  IBCustomDataSet, ComCtrls, ToolWin, StdCtrls, DBCtrls, Mask, OleCtrls,
  MSScriptControl_TLB, ExtCtrls, Forms, rp_BaseReport_unit,
  SysUtils, FrmPlSvr, Grids, Contnrs, prm_ParamFunctions_unit,
  SynHighlighterVBScript, SynEditHighlighter, SynHighlighterJScript,
  SynEdit, SynDBEdit, SynCompletionProposal, SynMemo;

type
  TdlgEditFunction = class(TForm)
    pcFunction: TPageControl;
    tsMain: TTabSheet;
    tsFormula: TTabSheet;
    ibdsFunction: TIBDataSet;
    dbeName: TDBEdit;
    dsFunction: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ToolBar1: TToolBar;
    tbtnOpen: TToolButton;
    tbtnSave: TToolButton;
    ToolButton3: TToolButton;
    tbtnCompile: TToolButton;
    ActionList1: TActionList;
    actLoadFromFile: TAction;
    actSaveToFile: TAction;
    actCompile: TAction;
    actSQLEditor: TAction;
    ImageList1: TImageList;
    ToolButton5: TToolButton;
    tbtnSQL: TToolButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    dbcbLang: TDBComboBox;
    ibtrFunction: TIBTransaction;
    actCompile2: TAction;
    actCompile3: TAction;
    dbmDescription: TDBMemo;
    FormPlaceSaver1: TFormPlaceSaver;
    tsParams: TTabSheet;
    ScrollBox1: TScrollBox;
    pnlCaption: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    dbseScript: TDBSynEdit;
    SynJScriptSyn1: TSynJScriptSyn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynCompletionProposal1: TSynCompletionProposal;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ImageList2: TImageList;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    actFind: TAction;
    actReplace: TAction;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    actCopyText: TAction;
    actPasteText: TAction;
    sbCoord: TStatusBar;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    actOptions: TAction;
    btnRigth: TButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    btnOk: TButton;
    btnCancel: TButton;
    actOk: TAction;
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actCompile3Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ibdsFunctionAfterOpen(DataSet: TDataSet);
    procedure pcFunctionChange(Sender: TObject);
    procedure pcFunctionChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actPasteTextExecute(Sender: TObject);
    procedure actCopyTextExecute(Sender: TObject);
    procedure dbseScriptClick(Sender: TObject);
    procedure dbcbLangChange(Sender: TObject);
    procedure dbseScriptKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actOptionsExecute(Sender: TObject);
    procedure actOptionsUpdate(Sender: TObject);
    procedure actPasteTextUpdate(Sender: TObject);
    procedure actCopyTextUpdate(Sender: TObject);
    procedure dbseScriptChange(Sender: TObject);
    procedure dbeNameChange(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure dsFunctionStateChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure dbmDescriptionChange(Sender: TObject);
  private
    FLastReportResult: TReportResult;
    FModuleName: String;
    FCompiled: Boolean;
    FExecuteFunction: TExecuteFunction;
    FParamLines: TObjectList;
    FFunctionParams: TgsParamList;
    FChanged: Boolean;

    // возвращает тру, если можно закрывать окно
    function  BeforeClose: Boolean;

    procedure SetChanged;
    procedure ViewParam(const AnParam: Variant);
    procedure ViewEvent;
    function CheckFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
    procedure PrepareTestResult;
    procedure ReadAddFunction(const SL: TStrings; AnScript: String);
    procedure SetAddFunction;
    procedure UpdateSyncs;
  public
    property ExecuteFunction: TExecuteFunction read FExecuteFunction write FExecuteFunction;

    function AddFunction(const AnModule: String; out AnFunctionKey: Integer): Boolean;
    function EditFunction(const AnFunctionKey: Integer): Boolean;
    function DeleteFunction(const AnFunctionKey: Integer): Boolean;
  end;

var
  dlgEditFunction: TdlgEditFunction;

implementation

uses
  {$IFDEF SYNEDIT}
  flt_frmSQLEditorSyn_unit,
  {$ELSE}
  flt_frmSQLEditor_unit,
  {$ENDIF}
  ActiveX, IBSQL,
  rp_dlgViewResult_unit, rp_report_const, rp_dlgEnterParam_unit, gd_SetDatabase,
  rp_frmParamLineSE_unit, flt_ScriptInterface, ClipBrd,
  syn_ManagerInterface_unit, gd_i_ScriptFactory;

{$R *.DFM}

type
  TCrackDBSynEdit = class(TDBSynEdit);

procedure TdlgEditFunction.ViewParam(const AnParam: Variant);
begin
  if VarIsArray(AnParam) then
  begin
    with TdlgEnterParam.Create(Self) do
    try
      ViewParam(AnParam);
    finally
      Free;
    end;
  end else
    MessageBox(Self.Handle, 'Результат функции должен быть массивом.', 'Ошибка', MB_OK or MB_ICONERROR);
end;

procedure TdlgEditFunction.ViewEvent;
begin
end;

function TdlgEditFunction.AddFunction(const AnModule: String; out AnFunctionKey: Integer): Boolean;
var
  Str: TStream;
begin
  Result := False;
  AnFunctionKey := 0;
  if not ibtrFunction.Active then
    ibtrFunction.StartTransaction;
  FModuleName := AnModule;
  ibdsFunction.Close;
  ibdsFunction.Open;
  ibdsFunction.Insert;
  ibdsFunction.FieldByName('language').AsString := DefaultLanguage;
  ibdsFunction.FieldByName('module').AsString := FModuleName;
  ibdsFunction.FieldByName('afull').AsInteger := -1;
  ibdsFunction.FieldByName('achag').AsInteger := -1;
  ibdsFunction.FieldByName('aview').AsInteger := -1;
  ibdsFunction.FieldByName('modulecode').AsInteger := 1;
  dbcbLangChange(nil);
  FCompiled := False;

  FChanged := False;
  if ShowModal = mrOk then
  begin
    try
      ibdsFunction.FieldByName('id').AsInteger := GetUniqueKey(ibdsFunction.Database,
       ibdsFunction.Transaction);
      Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('testresult'), bmWrite);
      try
        PrepareTestResult;
        FLastReportResult.SaveToStream(Str);
      finally
        Str.Free;
      end;

      if FFunctionParams.Count > 0 then
      begin
        Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('enteredparams'), bmWrite);
        try
          FFunctionParams.SaveToStream(Str);
        finally
          Str.Free;
        end;
      end else
        ibdsFunction.FieldByName('enteredparams').Clear;

      ibdsFunction.Post;
      SetAddFunction;

      Result := True;
      AnFunctionKey := ibdsFunction.FieldByName('id').AsInteger;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка ' + E.Message), 'Внимание',
         MB_OK or MB_ICONERROR);
        ibdsFunction.Cancel;
      end;
    end;
  end else
    ibdsFunction.Cancel;

  if ibtrFunction.Active then
    ibtrFunction.Commit;
end;

function TdlgEditFunction.EditFunction(const AnFunctionKey: Integer): Boolean;
var
  Str: TStream;
begin
  Result := False;
  if not ibtrFunction.Active then
    ibtrFunction.StartTransaction;
  ibdsFunction.Close;
  ibdsFunction.Params[0].AsInteger := AnFunctionKey;
  ibdsFunction.Open;
  dbcbLangChange(nil);
  if ibdsFunction.Eof then
  begin
    MessageBox(Self.Handle, 'Функция не найдена. Попробуйте обновить данные.', 'Внимание', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  FModuleName := ibdsFunction.FieldByName('module').AsString;
  ibdsFunction.Edit;

  Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('testresult'), bmRead);
  try
    FLastReportResult.LoadFromStream(Str);
  finally
    Str.Free;
  end;

  try
    if not ibdsFunction.FieldByName('enteredparams').IsNull then
    begin
      Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('enteredparams'), bmRead);
      try
        FFunctionParams.LoadFromStream(Str);
      finally
        Str.Free;
      end;
    end else
      FFunctionParams.Clear;
  except
    MessageBox(Handle, 'Данные параметров были повреждены. Их следует переопределить.',
     'Ошибка', MB_OK or MB_ICONERROR);
  end;

  FCompiled := True;

  FChanged := False;
  if ShowModal = mrOk then
  begin
    try
      Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('testresult'), bmWrite);
      try
        PrepareTestResult;
        FLastReportResult.SaveToStream(Str);
      finally
        Str.Free;
      end;

      if FFunctionParams.Count > 0 then
      begin
        Str := ibdsFunction.CreateBlobStream(ibdsFunction.FieldByName('enteredparams'), bmWrite);
        try
          FFunctionParams.SaveToStream(Str);
        finally
          Str.Free;
        end;
      end else
        ibdsFunction.FieldByName('enteredparams').Clear;

      ibdsFunction.Post;
      SetAddFunction;

      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка ' + E.Message), 'Внимание',
         MB_OK or MB_ICONERROR);
        ibdsFunction.Cancel;
      end;
    end;
  end else
    ibdsFunction.Cancel;

  if ibtrFunction.Active then
    ibtrFunction.Commit;
end;

function TdlgEditFunction.DeleteFunction(const AnFunctionKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrFunction.Active then
    ibtrFunction.StartTransaction;
  ibdsFunction.Close;
  ibdsFunction.Params[0].AsInteger := AnFunctionKey;
  ibdsFunction.Open;
  if ibdsFunction.Eof then
  begin
    MessageBox(Self.Handle, 'Функция не найдена. Попробуйте обновить данные.',
     'Внимание', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  if MessageBox(Self.Handle, 'Вы действительно хотите удалить функцию?', 'Вопрос',
   MB_YESNO or MB_ICONQUESTION) = ID_YES then
  try
    ibdsFunction.Delete;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка ' + E.Message), 'Внимание',
       MB_OK or MB_ICONERROR);
    end;
  end;
  if ibtrFunction.Active then
    ibtrFunction.Commit;
end;

procedure TdlgEditFunction.actLoadFromFileExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    dbseScript.Lines.LoadFromFile(OpenDialog1.FileName);
    TCrackDBSynEdit(dbseScript).NewOnChange(dbseScript);
  end;
end;

procedure TdlgEditFunction.actSaveToFileExecute(Sender: TObject);
begin
  if SaveDialog1.Execute then
    dbseScript.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TdlgEditFunction.actSQLEditorExecute(Sender: TObject);
begin
  {$IFDEF SYNEDIT}
  with TfrmSQLEditorSyn.Create(Self) do
  {$ELSE}
  with TfrmSQLEditor.Create(Self) do
  {$ENDIF}
  try
    FDatabase := ibdsFunction.Database;
    ShowSQL(dbseScript.SelText, nil);
  finally
    Free;
  end;
end;

function TdlgEditFunction.CheckFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
const
  LimitChar = [' ', '(', #13, #10, ';'];
var
  I: Integer;
begin
  Result := True;
  I := Pos(AnFunctionName, AnScriptText);
  if (I > 1) and (Length(AnFunctionName) + I < Length(AnScriptText)) then
    if (AnScriptText[I - 1] in LimitChar) and
     (AnScriptText[Length(AnFunctionName) + I] in LimitChar) then
      Result := False;
end;

procedure TdlgEditFunction.actCompile3Execute(Sender: TObject);
var
  CustomFunction: TrpCustomFunction;
  ParamResult: Variant;
  SError: String;
  SL: TStrings;
  LocSQL: TIBSQL;
  I: Integer;
begin
  ScriptFactory.Reset;
  btnOk.SetFocus;
  if (Trim(dbeName.Text) = '') or CheckFunctionName(dbeName.Text, dbseScript.Lines.Text) then
  begin
    MessageBox(Self.Handle,
      'Неправильно введено наименование функции.',
      'Внимание',
      MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    pcFunction.ActivePage := tsMain;
    SetFocusedControl(dbeName);
    Exit;
  end;

  CustomFunction := TrpCustomFunction.Create;
  try
    CustomFunction.ReadFromDataSet(ibdsFunction);
    CustomFunction.EnteredParams.Assign(FFunctionParams);

    SL := TStringList.Create;
    try
      SL.Add(AnsiUpperCase(ibdsFunction.FieldByName('name').AsString));
      ReadAddFunction(SL, ibdsFunction.FieldByName('script').AsString);
      LocSQL := TIBSQL.Create(nil);
      try
        LocSQL.Database := ibdsFunction.Database;
        LocSQL.Transaction := ibdsFunction.Transaction;
        LocSQL.SQL.Text := 'SELECT script FROM gd_function WHERE id in(';
        for I := 1 to SL.Count - 1 do
        begin
          LocSQL.SQL.Add(IntToStr(Integer(SL.Objects[I])));
          LocSQL.SQL.Add(',');
        end;
        LocSQL.SQL.Strings[LocSQL.SQL.Count - 1] := ')';
        if SL.Count > 1 then
          LocSQL.ExecQuery;
        while not LocSQL.Eof do
        begin
          CustomFunction.Script.Add(LocSQL.Fields[0].AsString);

          LocSQL.Next;
        end;
      finally
        LocSQL.Free;
      end;
    finally
      SL.Free;
    end;

    if Assigned(FExecuteFunction) then
    begin
      if FExecuteFunction(CustomFunction, FLastReportResult, ParamResult) then
      begin
        if FModuleName = MainModuleName then
          FLastReportResult.ViewResult
        else
          if FModuleName = ParamModuleName then
            ViewParam(ParamResult)
          else
            if FModuleName = EventModuleName then
              ViewEvent
            else
              MessageBox(Self.Handle, 'Неизвестный модуль для функции.', 'Ошибка', MB_OK or MB_ICONERROR);
        FCompiled := True;
      end else
      begin
        if VarType(ParamResult) = varString then
        begin
          SError := ParamResult;
          MessageBox(Self.Handle, PChar(SError), 'Ошибка', MB_OK or MB_ICONERROR);
        end;
      end;
    end else
      raise Exception.Create('Не задано событие для выполнения функции.');
  finally
    CustomFunction.Free;
  end;
end;

procedure TdlgEditFunction.FormCreate(Sender: TObject);
begin
  FFunctionParams := TgsParamList.Create;
  FLastReportResult := TReportResult.Create;
  FParamLines := TObjectList.Create;
  pcFunction.ActivePage := tsFormula;
  tsParams.TabVisible := Assigned(ParamGlobalDlg);
  UpdateSyncs;
end;

procedure TdlgEditFunction.FormDestroy(Sender: TObject);
begin
{  if not FCompiled and
   (MessageBox(Handle, 'Текст запроса не откомпилирован.'#13#10 +
   'Хотите сохранить его?', 'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO) then
  begin
    pcFunction.ActivePage := tsFormula;
    SetFocusedControl(tbtnCompile.Parent);
    Exit;
  end;
 }
  FFunctionParams.Free;
  FParamLines.Free;
  FLastReportResult.Free;
end;

procedure TdlgEditFunction.PrepareTestResult;
var
  I: Integer;
begin
  for I := 0 to FLastReportResult.Count - 1 do
    if FLastReportResult.DataSet[I].RecordCount > 100 then
    begin
      FLastReportResult.DataSet[I].Last;
      while FLastReportResult.DataSet[I].RecNo > 100 do
        FLastReportResult.DataSet[I].Delete;
    end;
end;

procedure TdlgEditFunction.ReadAddFunction(const SL: TStrings; AnScript: String);
const
  IncludePrefix = '#INCLUDE ';
  ReplacePrefix = '_________';
  LengthInc = Length(IncludePrefix);
  LimitChar = [' ', ',', ';', #13, #10];
var
  TempStr: String;
  I, J, StartIndex: Integer;
  ibsqlWork: TIBSQL;

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
      ibsqlWork.Database := ibdsFunction.Database;
      ibsqlWork.Transaction := ibdsFunction.Transaction;
      ibsqlWork.SQL.Text := 'SELECT id, name FROM gd_function WHERE UPPER(name) IN (';
      for I := StartIndex to SL.Count - 1 do
      begin
        ibsqlWork.SQL.Add(' ''' + SL.Strings[I] + '''');
        ibsqlWork.SQL.Add(',');
      end;
      ibsqlWork.SQL.Strings[ibsqlWork.SQL.Count - 1] := ')';
      ibsqlWork.ExecQuery;
      while not ibsqlWork.Eof do
      begin
        SetID(StartIndex, ibsqlWork.FieldByName('id').AsInteger,
         AnsiUpperCase(ibsqlWork.FieldByName('name').AsString));

        ibsqlWork.Next;
      end;
    finally
      ibsqlWork.Free;
    end;
  end;
end;

procedure TdlgEditFunction.SetAddFunction;
var
  LocSQL: TIBSQL;
  SL: TStrings;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Add(AnsiUpperCase(ibdsFunction.FieldByName('name').AsString));
    ReadAddFunction(SL, ibdsFunction.FieldByName('script').AsString);
    LocSQL := TIBSQL.Create(nil);
    try
      LocSQL.Database := ibdsFunction.Database;
      LocSQL.Transaction := ibdsFunction.Transaction;
      LocSQL.SQL.Text := 'DELETE FROM rp_additionalfunction WHERE mainfunctionkey = ' +
       ibdsFunction.FieldByName('id').AsString;
      LocSQL.ExecQuery;
      LocSQL.Close;
      LocSQL.SQL.Text := 'INSERT INTO rp_additionalfunction (mainfunctionkey, addfunctionkey) ' +
       'VALUES(' + ibdsFunction.FieldByName('id').AsString + ', :id)';
      LocSQL.Prepare;
      for I := 1 to SL.Count - 1 do
      begin
        LocSQL.Close;
        LocSQL.Params[0].AsInteger := Integer(SL.Objects[I]);
        LocSQL.ExecQuery;
      end;
    finally
      LocSQL.Free;
    end;
  finally
    SL.Free;
  end;
end;

procedure TdlgEditFunction.ibdsFunctionAfterOpen(DataSet: TDataSet);
begin
  ibdsFunction.FieldByName('PUBLICFUNCTION').Required := False;
end;

procedure TdlgEditFunction.pcFunctionChange(Sender: TObject);
var
  ParamDlg: TgsParamList;
  I, J: Integer;
  LocParamLine: TfrmParamLineSE;
begin
  if pcFunction.ActivePage = tsParams then
  begin
    ScrollBox1.Visible := False;
    try
      ParamDlg := TgsParamList.Create;
      try
        GetParamsFromText(ParamDlg, dbeName.Text, dbseScript.Text);
        pnlCaption.Visible := ParamDlg.Count <> 0;

        FParamLines.Clear;
        for I := 0 to ParamDlg.Count - 1 do
        begin
          for J := 0 to FFunctionParams.Count - 1 do
            if FFunctionParams.Params[J].RealName = ParamDlg.Params[I].RealName then
            begin
              ParamDlg.Params[I].Assign(FFunctionParams.Params[J]);
              Break;
            end;
          LocParamLine := TfrmParamLineSE.Create(nil);
          LocParamLine.Top := FParamLines.Count * LocParamLine.Height;
          LocParamLine.Parent := ScrollBox1;
          LocParamLine.SetParam(ParamDlg.Params[I]);
          FParamLines.Add(LocParamLine);
        end;
      finally
        ParamDlg.Free;
      end;
    finally
      ScrollBox1.Visible := True;
    end;
  end;
end;

procedure TdlgEditFunction.pcFunctionChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  I: Integer;
begin
  AllowChange := True;
  if pcFunction.ActivePage = tsParams then
  begin
    FFunctionParams.Clear;
    for I := 0 to FParamLines.Count - 1 do
    begin
      FFunctionParams.AddParam('', '', prmInteger, '');
      AllowChange := AllowChange and TfrmParamLineSE(FParamLines.Items[I]).GetParam(FFunctionParams.Params[I]);
    end;
  end;
  if AllowChange then
    ScrollBox1.Visible := False;
end;

procedure TdlgEditFunction.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if not BeforeClose then
    exit;

  if ModalResult = mrOk then
  begin
    pcFunctionChanging(nil, CanClose);

    if Trim(ibdsFunction.FieldByName('name').AsString) = '' then
    begin
      MessageBox(Handle, 'Не введено наименование функции',
       'Внимание', MB_OK or MB_ICONWARNING);
      CanClose := False;
      pcFunction.ActivePage := tsMain;
      FocusControl(dbeName);
      Exit;
    end;
  end;
end;

procedure TdlgEditFunction.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, 'Нельзя искать пустую строку!', 'Внимание',
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if dbseScript.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      MessageBox(Handle, PChar('Искомый текст ''' + sSearch + ''' не найден!'), 'Внимание',
       MB_OK or MB_ICONWARNING);
    end;
  end;
end;

procedure TdlgEditFunction.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, 'Нельзя заменить пустую строку!', 'Внимание',
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if dbseScript.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Handle, PChar('Искомый текст ''' + sSearch + ''' не может быть заменен!'),
       'Внимание', MB_OK or MB_ICONWARNING);
    end;
  end;
end;

procedure TdlgEditFunction.actFindExecute(Sender: TObject);
begin
  FindDialog1.Execute;
end;

procedure TdlgEditFunction.actReplaceExecute(Sender: TObject);
begin
  ReplaceDialog1.Execute;
end;

procedure TdlgEditFunction.actPasteTextExecute(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
  TempStr: String;
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Clipboard.AsText;
      TempStr := Clipboard.AsText;
      for I := 0 to SL.Count - 1 do
      begin
        if I <> SL.Count -1 then
          SL[I] := '  " ' + Trim(SL[I]) + ' " + _'
        else
          SL[I] := '  " ' + Trim(SL[I]) + ' "'
      end;

      Clipboard.AsText := SL.Text;
    finally
      SL.Free;
    end;

    dbseScript.PasteFromClipboard;
    Clipboard.AsText := TempStr;
  end;
end;

procedure TdlgEditFunction.actCopyTextExecute(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.BeginUpdate;
    SL.Text := dbseScript.SelText;
    for I := 0 to SL.Count - 1 do
    begin
      while (SL[I] > '') and (SL[I][1] <> '"') do
        SL[I] := Copy(SL[I], 2, Length(SL[I]));
      if SL[I] > '' then SL[I] := Copy(SL[I], 2, Length(SL[I]));
      while (SL[I] > '') and (SL[I][Length(SL[I])] <> '"') do
        SL[I] := Copy(SL[I], 1, Length(SL[I]) - 1);
      if SL[I] > '' then SL[I] := Copy(SL[I], 1, Length(SL[I]) - 1);
    end;

    SL.Text := SL.Text + #0;
    SL.EndUpdate;

    Clipboard.SetTextBuf(PChar(@SL.Text[1]));
  finally
    SL.Free;
  end;
end;

procedure TdlgEditFunction.dbseScriptClick(Sender: TObject);
begin
  sbCoord.Panels[0].Text := 'X: ' + IntToStr(dbseScript.CaretX) +
   ';   Y: ' + IntToStr(dbseScript.CaretY) + ';';
end;

procedure TdlgEditFunction.dbcbLangChange(Sender: TObject);
begin
  FCompiled := False;
  SetChanged;
  if dbcbLang.Text = DefaultLanguage then
    dbseScript.Highlighter := SynVBScriptSyn1
  else
    dbseScript.Highlighter := SynJScriptSyn1;
end;

procedure TdlgEditFunction.dbseScriptKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  dbseScriptClick(nil);
end;

procedure TdlgEditFunction.UpdateSyncs;
begin
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynJScriptSyn1);
    SynManager.GetHighlighterOptions(SynVBScriptSyn1);
    dbseScript.Font.Assign(SynManager.GetHighlighterFont);
  end;
end;

procedure TdlgEditFunction.actOptionsExecute(Sender: TObject);
begin
  if Assigned(SynManager) then
    if SynManager.ExecuteDialog then
      UpdateSyncs;
end;

procedure TdlgEditFunction.actOptionsUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(SynManager);
end;

procedure TdlgEditFunction.actPasteTextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Clipboard.HasFormat(CF_TEXT);
end;

procedure TdlgEditFunction.actCopyTextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := dbseScript.SelText > '';
end;

procedure TdlgEditFunction.dbseScriptChange(Sender: TObject);
begin
  FCompiled := False;
  SetChanged;
end;

procedure TdlgEditFunction.dbeNameChange(Sender: TObject);
begin
  FCompiled := False;
  SetChanged;
end;

procedure TdlgEditFunction.actOkExecute(Sender: TObject);
begin
  {
  Закоментировал andreik
  Смысла в этом вопросе большого нет, так как
  в 99% случаев программист всегда отвечает Да
  и только теряет время.

  if not FCompiled and
   (MessageBox(Handle, 'Текст запроса не откомпилирован.'#13#10 +
   'Хотите сохранить его?', 'Внимание', MB_YESNO or MB_ICONQUESTION) = IDNO) then
  begin
    pcFunction.ActivePage := tsFormula;
    SetFocusedControl(tbtnCompile.Parent);
    Exit;
  end;
  }
  // При изменении скрипт-функции очищаем все скрипт-кантролы
  ScriptFactory.Reset;

  ModalResult := mrOk;
end;

function TdlgEditFunction.BeforeClose: Boolean;
{var
  ChildForm: TComponent;}
begin
  Result := True;
  if (FindDialog1.Handle <> 0) or (ReplaceDialog1.Handle <> 0) then
  begin
    FindDialog1.CloseDialog;
    ReplaceDialog1.CloseDialog;
    Exit;
  end;

  if (ModalResult = mrCancel) and FChanged then
    case MessageBox(Handle, 'Изменения в макросе не сохранены.'#13#10 +
         'Сохранить?', 'Внимание', MB_YESNOCANCEL or MB_ICONQUESTION) of
      IDYES:
      begin
        ModalResult := mrOk;
      end;
      IDNO:
        ModalResult := mrCancel;
      IDCANCEL:
      begin
        ModalResult := mrNone;
        Result := False;
      end;
    end;
end;

procedure TdlgEditFunction.dsFunctionStateChange(Sender: TObject);
begin
  if ibdsFunction.Active and (not ibdsFunction.IsEmpty) then
    Caption := 'Функция - ' + ibdsFunction.FieldByName('name').AsString;
end;

procedure TdlgEditFunction.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 18 then;
end;

procedure TdlgEditFunction.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '' then;
end;

procedure TdlgEditFunction.SetChanged;
begin
  FChanged := True;
end;

procedure TdlgEditFunction.dbmDescriptionChange(Sender: TObject);
begin
  SetChanged;
end;

end.

