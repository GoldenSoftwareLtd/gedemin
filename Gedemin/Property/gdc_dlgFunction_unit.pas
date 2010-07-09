unit gdc_dlgFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, TB2Item, TB2Dock, TB2Toolbar,
  Buttons, ComCtrls, SynEdit, ExtCtrls, SynDBEdit, DBCtrls, Mask,
  SynCompletionProposal, SynHighlighterJScript, SynEditHighlighter,
  SynHighlighterVBScript, ImgList, prm_ParamFunctions_unit, contnrs,
  prp_dlgEvaluate_unit, rp_BaseReport_unit, Menus, SuperPageControl,
  gsFunctionSyncEdit, VBParser, SynEditKeyCmds, gd_strings,
  gsSearchReplaceHelper;

type
  Tgdc_dlgFunction = class(Tgdc_dlgG)
    pcFunction: TSuperPageControl;
    tsFuncMain: TSuperTabSheet;
    Label1: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label6: TLabel;
    dbtFunctionID: TDBText;
    lFunctionID: TLabel;
    dbcbModule: TDBComboBox;
    dbcbLang: TDBComboBox;
    DBMemo1: TDBMemo;
    dbeFunctionName: TDBEdit;
    tsFuncScript: TSuperTabSheet;
    sbCoord: TStatusBar;
    dbseScript: TgsFunctionSynEdit;
    tsParams: TSuperTabSheet;
    ScrollBox1: TScrollBox;
    Label19: TLabel;
    pnlCaption: TPanel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    TBDock4: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem16: TTBItem;
    TBItem15: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem14: TTBItem;
    TBItem18: TTBItem;
    TBSeparatorItem8: TTBSeparatorItem;
    TBItem13: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem12: TTBItem;
    TBItem11: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem10: TTBItem;
    TBItem9: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem2: TTBItem;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    SynCompletionProposal: TSynCompletionProposal;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    lbOwner: TLabel;
    lLabel1: TLabel;
    lEditorName: TLabel;
    lLabel2: TLabel;
    lEditDate: TLabel;
    lOwner: TLabel;
    actPasteSQL: TAction;
    actCopySQL: TAction;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    tsHistory: TSuperTabSheet;
    actFindNext: TAction;
    procedure dbcbModuleDropDown(Sender: TObject);
    procedure pcFunctionChange(Sender: TObject);
    procedure pcFunctionChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
    // Обработчик события SynhEdit.OnParamChange
    procedure ParamChange(Sender: TObject);
    procedure SetChanged;
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actCopySQLExecute(Sender: TObject);
    procedure actPasteSQLExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actEvaluateExecute(Sender: TObject);
    procedure dbcbLangChange(Sender: TObject);
    procedure dbseScriptClick(Sender: TObject);
    procedure dbseScriptKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    procedure dbseScriptProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure actFindNextExecute(Sender: TObject);
  protected
    procedure BeforePost; override;
    procedure ParserInit; virtual;
    function GetStatament(var Str: String; Pos: Integer): String;
    function GetCompliteStatament(var Str: String; Pos: Integer;
      out BeginPos, EndPos: Integer): String;

  private
    { Private declarations }
    FFunctionParams: TgsParamList;
    FCompiled: Boolean;
    FParamLines: TObjectList;
    FChanged: Boolean;
    //Указатель на окно вычисления выражений
    FEvaluate: TdlgEvaluate;
    FLastReportResult: TReportResult;
    FVBParser: TVBParser;
    HistoryFrame: TFrame;
    // Вспомогательный объект для поиска по полю ввода
    FSearchReplaceHelper: TgsSearchReplaceHelper;

    function WarningFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
    procedure UpDateSyncs;
    procedure UpdateSelectedColor;
    procedure dbseScriptChange(Sender: TObject);
    procedure ViewParam(const AnParam: Variant);
    function CheckFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
    procedure PrepareTestResult;
    procedure UpdateEdidor;
    procedure UpdateOwner;
    procedure UpDataFunctionParams(FunctionParams: TgsParamList);
    procedure SaveFunctionParams;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function TestCorrect: Boolean; override;
    procedure SetupRecord; override;
    procedure Post; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;
  end;

var
  gdc_dlgFunction: Tgdc_dlgFunction;

implementation

uses
  IBCustomDataSet, rp_frmParamLineSE_unit, IBSQL,
  gdcConstants, gd_i_ScriptFactory, dm_i_ClientReport_unit,
  flt_frmSQLEditorSyn_unit, syn_ManagerInterface_unit,
  prp_MessageConst, rp_report_const, Gedemin_TLB, rp_dlgEnterParam_unit,
  Clipbrd, gdcDelphiObject, gdcFunction, gs_Exception, gd_ClassList,
  gdc_createable_form, scr_i_FunctionList, mtd_i_Base, prp_i_VBProposal,
  gd_createable_form, Storages, gsStorage_CompPath, prp_FunctionHistoryFrame_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

type
  TCrackDBSynEdit = class(TDBSynEdit);
  
procedure Tgdc_dlgFunction.dbcbModuleDropDown(Sender: TObject);
var
  DataSet: TIBDataSet;
begin
  inherited;
  DataSet := TIBDataSet.Create(Self);
  try
    DataSet.Transaction := (dsgdcBase.DataSet as TIBCustomDataSet).Transaction;
    DataSet.SelectSQL.Text := 'SELECT DISTINCT module FROM gd_function';
    DataSet.Open;
    if not DataSet.IsEmpty then
    begin
      dbcbModule.Items.Clear;
      while not DataSet.Eof do
      begin
        dbcbModule.Items.Add(DataSet.Fields[0].AsString);
        DataSet.Next;
      end;
    end;
  finally
    DataSet.Free;
  end;
end;

procedure Tgdc_dlgFunction.pcFunctionChange(Sender: TObject);
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
        GetParamsFromText(ParamDlg, dbeFunctionName.Text, dbseScript.Text);
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
          LocParamLine.OnParamChange := ParamChange;
          FParamLines.Add(LocParamLine);
          ScrollBox1.VertScrollBar.Increment := LocParamLine.Height;
        end;
        Label19.Visible := ParamDlg.Count = 0;
      finally
        ParamDlg.Free;
      end;
    finally
      ScrollBox1.Visible := True;
    end;
  end
  else if (pcFunction.ActivePage = tsHistory) and Assigned(gdcObject) then
    if HistoryFrame <> nil then
    begin
      Tprp_FunctionHistoryFrame(HistoryFrame).S := gdcObject.FieldByName('script').AsString;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Close;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Open;
    end else
    begin
      HistoryFrame := Tprp_FunctionHistoryFrame.Create(Self);
      HistoryFrame.Parent := tsHistory;
      Tprp_FunctionHistoryFrame(HistoryFrame).S := gdcObject.FieldByName('script').AsString;

      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.ParamByName('ID').AsInteger := gdcObject.ID;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Open;
    end;
end;

procedure Tgdc_dlgFunction.pcFunctionChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  I: Integer;
begin
  if not Assigned(FFunctionParams) then Exit;
  AllowChange := True;
  if (pcFunction.ActivePage = tsParams) then
  begin
    FFunctionParams.Clear;
    for I := 0 to FParamLines.Count - 1 do
    begin
      FFunctionParams.AddParam('', '', prmInteger, '');
      AllowChange := AllowChange and
        TfrmParamLineSE(FParamLines.Items[I]).GetParam(FFunctionParams.Params[I]);
    end;
  end;
  if AllowChange then
    ScrollBox1.Visible := False;
end;

procedure Tgdc_dlgFunction.FormCreate(Sender: TObject);
begin
  inherited;

  //Установка внешнего вида редактора
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynVBScriptSyn1);
    SynManager.GetHighlighterOptions(SynJScriptSyn1);
    dbseScript.Font.Assign(SynManager.GetHighlighterFont);
  end;
  //Установка обработчика события
  dbseScript.OnChange := dbseScriptChange;
  pcFunction.ActivePage := tsFuncScript;
end;

procedure Tgdc_dlgFunction.ParamChange(Sender: TObject);
begin
  SetChanged;
end;

procedure Tgdc_dlgFunction.SetChanged;
begin
  FChanged := True;
  FCompiled := False;
end;

procedure Tgdc_dlgFunction.actLoadFromFileExecute(Sender: TObject);
begin
  OpenDialog1.Filter := dbseScript.Highlighter.DefaultFilter;
  if OpenDialog1.Execute then
  begin
    dbseScript.Lines.LoadFromFile(OpenDialog1.FileName);
    TCrackDBSynEdit(dbseScript).NewOnChange(dbseScript);
    FChanged := True;
  end;
end;

procedure Tgdc_dlgFunction.actSaveToFileExecute(Sender: TObject);
var
  I: Integer;
begin
  SaveDialog1.Filter := dbseScript.Highlighter.DefaultFilter;
  SaveDialog1.DefaultExt := '';
  I := Length(SaveDialog1.Filter);
  while (I > 0) and (SaveDialog1.Filter[I] <> '.') do
  begin
    SaveDialog1.DefaultExt := SaveDialog1.Filter[I] + SaveDialog1.DefaultExt;
    Dec(I);
  end;

  SaveDialog1.FileName := dbeFunctionName.Text;
  if SaveDialog1.Execute then
    dbseScript.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure Tgdc_dlgFunction.actCompileExecute(Sender: TObject);
var
  CustomFunction: TrpCustomFunction;
  ParamResult: Variant;
  SError: String;
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  VarResult: Variant;
//  Script: TStrings;
//  dlgScriptView: TdlgScriptView;
begin
  // В SynDBEdit добавлен метод
  // procedure TCustomDBSynEdit.UpdateRecord;
  // begin
  //   FDataLink.UpdateRecord;
  // end;

  dbseScript.UpdateRecord;

  if not WarningFunctionName(dbeFunctionName.Text, dbseScript.Lines.Text) then
    Exit;

  // Создание тестовой функции
  CustomFunction := TrpCustomFunction.Create;
  try
    CustomFunction.ReadFromDataSet((dsgdcBase.DataSet as TIBCustomDataSet));
    CustomFunction.EnteredParams.Assign(FFunctionParams);

    if Assigned(ScriptFactory) then
    begin
      ParamResult := VarArrayOf([]);
      ParamResult := CustomFunction.EnteredParams.GetVariantArray;
      try
        if ScriptFactory.InputParams(CustomFunction, ParamResult) then
        begin
//          if ScriptFactory.ExecuteFunction(CustomFunction, ParamResult) then
          try
            ScriptFactory.ExecuteFunction(CustomFunction, ParamResult);
            if dbcbModule.Text = MainModuleName then
            begin
              if VarType(ParamResult) = varDispatch then
              begin
                LocDispatch := ParamResult;
                LocReportResult := LocDispatch as IgsQueryList;
                try
                  VarResult := LocReportResult.ResultStream;

                  FLastReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) - VarArrayLowBound(VarResult, 1) + 1;
                  CopyMemory(FLastReportResult.TempStream.Memory, VarArrayLock(VarResult), FLastReportResult.TempStream.Size);
                  VarArrayUnLock(VarResult);
                  FLastReportResult.TempStream.Position := 0;
                  if not FLastReportResult.IsStreamData then
                  begin
                    FLastReportResult.LoadFromStream(FLastReportResult.TempStream);
                    FLastReportResult.TempStream.Clear;
                  end;
                finally
                  LocReportResult.Clear;
                end;

              FLastReportResult.ViewResult;
              end;
            end else
              if dbcbModule.Text = ParamModuleName then
                ViewParam(ParamResult);
            FCompiled := True;
          except
            SError := ParamResult;
            MessageBox(Handle, PChar(SError), MSG_ERROR, MB_OK or MB_ICONERROR);
          end;
        end;
      except
        SError := ParamResult;
        MessageBox(Handle, PChar(SError), MSG_ERROR, MB_OK or MB_ICONERROR);
      end;
    end else
      raise Exception.Create(GetGsException(Self, 'Компонент ScriptFactory не создан.'));
  finally
    CustomFunction.Free;
  end;
end;

function Tgdc_dlgFunction.WarningFunctionName(const AnFunctionName,
  AnScriptText: String): Boolean;
begin
  Result := not ((Trim(dbeFunctionName.Text) = '') or
    CheckFunctionName(dbeFunctionName.Text, dbseScript.Lines.Text));
  if not Result then
  begin
    MessageBox(Self.Handle, MSG_UNKNOWN_NAME_FUNCTION,
      MSG_WARNING, MB_OK or MB_ICONWARNING);
    pcFunction.ActivePage := tsFuncMain;
    dbeFunctionName.Enabled := True;
    SetFocusedControl(dbeFunctionName);
  end;
end;

procedure Tgdc_dlgFunction.actSQLEditorExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(Self) do
  try
    FDatabase := (dsgdcBase.DataSet as TIBCustomDataSet).Database;
    ShowSQL(dbseScript.SelText, nil, True);
  finally
    Free;
  end;
end;

procedure Tgdc_dlgFunction.actFindExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Search;
end;

procedure Tgdc_dlgFunction.actFindNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure Tgdc_dlgFunction.actReplaceExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Replace;
end;

procedure Tgdc_dlgFunction.actCopySQLExecute(Sender: TObject);
begin
  gd_strings.CopySQL(dbseScript);
end;

procedure Tgdc_dlgFunction.actPasteSQLExecute(Sender: TObject);
begin
  gd_strings.PasteSQL(dbseScript);
end;

procedure Tgdc_dlgFunction.actOptionsExecute(Sender: TObject);
begin
  if Assigned(SynManager) then
    if SynManager.ExecuteDialog then
      UpdateSyncs;
end;

procedure Tgdc_dlgFunction.actEvaluateExecute(Sender: TObject);
begin
  if not Assigned(FEvaluate) then
    FEvaluate := TdlgEvaluate.Create(Self);

  if dbseScript.SelAvail then
    FEvaluate.cbExpression.Text := dbseScript.SelText
  else
    FEvaluate.cbExpression.Text := dbseScript.WordAtCursor;

  FEvaluate.ShowModal;
end;

procedure Tgdc_dlgFunction.UpDateSyncs;
begin
  if Assigned(SynManager) then
  begin
    dbseScript.BeginUpdate;
    try
      SynManager.GetHighlighterOptions(SynJScriptSyn1);
      SynManager.GetHighlighterOptions(SynVBScriptSyn1);
      dbseScript.Font.Assign(SynManager.GetHighlighterFont);
      SynManager.GetSynEditOptions(TSynEdit(dbseScript));

      UpdateSelectedColor;
    finally
      dbseScript.EndUpdate;
    end;
    dbseScript.Repaint;
  end;
end;

procedure Tgdc_dlgFunction.dbseScriptChange(Sender: TObject);
begin
  SetChanged;
end;

procedure Tgdc_dlgFunction.ViewParam(const AnParam: Variant);
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

function Tgdc_dlgFunction.CheckFunctionName(const AnFunctionName,
  AnScriptText: String): Boolean;
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

procedure Tgdc_dlgFunction.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  gdcFunction: TIBCustomDataSet;
  Str: TStream;
  DelphiObject: TgdcDelphiObject;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFUNCTION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  dbseScript.UpdateRecord;
  gdcFunction := (dsgdcBase.DataSet as TIBCustomDataSet);

  Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('testresult'), DB.bmWrite);
  try
    PrepareTestResult;
    FLastReportResult.SaveToStream(Str);
  finally
    Str.Free;
  end;

  UpDataFunctionParams(FFunctionParams);
  SaveFunctionParams;

  gdcFunction.FieldByName('publicfunction').Required := False;
  if gdcFunction.FieldByName('modulecode').IsNull then
  begin
    DelphiObject := TgdcDelphiObject.Create(Self);
    try
      DelphiObject.Transaction := gdcFunction.Transaction;
      gdcFunction.FieldByName('modulecode').AsInteger :=
        DelphiObject.AddObject(Owner);
    finally
      DelphiObject.Free;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgFunction.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGFUNCTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := WarningFunctionName(dbeFunctionName.Text, dbseScript.Lines.Text);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgFunction.PrepareTestResult;
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

procedure Tgdc_dlgFunction.dbcbLangChange(Sender: TObject);
begin
  SetChanged;
  if dbcbLang.Text = DefaultLanguage then
    dbseScript.Highlighter := SynVBScriptSyn1
  else
    dbseScript.Highlighter := SynJScriptSyn1;
end;

procedure Tgdc_dlgFunction.dbseScriptClick(Sender: TObject);
begin
  sbCoord.Panels[0].Text := 'X: ' + IntToStr(dbseScript.CaretX) +
   ';   Y: ' + IntToStr(dbseScript.CaretY) + ';';
end;

procedure Tgdc_dlgFunction.dbseScriptKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  dbseScriptClick(nil);
end;

procedure Tgdc_dlgFunction.Post;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Module: string;
  Id: Integer;
  Fnc: TrpCustomFunction;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFUNCTION', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Module := gdcObject.FieldByName(fnModule).AsString;
  Id := gdcObject.FieldByName(fnId).AsInteger;
  inherited;
  //Регестрирум функцию в глобальном списке функций
  Fnc := glbFunctionList.FindFunction(Id);
  if Fnc = nil then
  begin
    Fnc := TrpCustomFunction.Create;
    try
      Fnc.ReadFromDataSet(gdcObject);
      glbFunctionList.AddFunction(Fnc);
    finally
      Fnc.Free;
    end;
  end else
    begin
      Fnc.ReadFromDataSet(gdcObject);
      glbFunctionList.ReleaseFunction(Fnc);
    end;
  { TODO :
  Необходимо обратить внимание как данный код будет работать с
  VBClass, Const, GlobalObject т.к для них необходим сброс
  ScriptFactory }
  MethodControl.ClearMacroCache;
  if (Module = scrVBClasses) or (Module = scrConst) or
    (Module = scrGlobalObject) then
  begin
    ScriptFactory.Reset;
    dm_i_ClientReport.CreateGlobalSF;
//    dm_i_ClientReport.CreateVBConst;
//    dm_i_ClientReport.CreateVBClasses;
//    dm_i_ClientReport.CreateGlObjArray;
  end else
    begin
      ScriptFactory.ReloadFunction(Id);
    end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgFunction.UpdateEdidor;
var
  SQL: TIBSQL;
begin
  if gdcObject.State = dsEdit then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT c.name, f.editiondate FROM gd_function f LEFT JOIN ' +
        ' gd_contact c ON f.editorkey = c.id WHERE f.id = ' +
        gdcObject.FieldByName(fnID).AsString;
      SQL.ExecQuery;
      if not SQL.Eof then
      begin
        lEditorName.Caption := SQL.FieldByName(fnName).AsString;
        lEditDate.Caption := SQL.FieldByName('editiondate').AsString;
      end;
    finally
      SQL.Free;
    end;
  end else
  begin
    lEditorName.Caption := '';
    lEditDate.Caption := ''
  end;
end;

procedure Tgdc_dlgFunction.UpdateOwner;
var
  SQL: TIBSQL;
begin
  if ((gdcObject.State = dsEdit) or (gdcObject.State = dsInsert)) and (not gdcObject.FieldByName(fnModuleCode).IsNull) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT o.name FROM evt_object o ' +
        ' WHERE o.id = ' + gdcObject.FieldByName(fnModuleCode).AsString;
      SQL.ExecQuery;
      if not SQL.Eof then
        lOwner.Caption := SQL.FieldByName(fnName).AsString;
    finally
      SQL.Free;
    end;
  end else
    LOwner.Caption := '';
end;

constructor Tgdc_dlgFunction.Create(AnOwner: TComponent);
begin
  inherited;
  FFunctionParams := TgsParamList.Create;
  FParamLines := TObjectList.Create;
  FLastReportResult := TReportResult.Create;

  FVBParser := TVBParser.Create(Self);

  dbseScript.Parser := FVBParser;
  dbseScript.UseParser := True;

  UpDateSyncs;
  FEnterAsTab := 2; // отключим EnterAsTab
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(dbseScript);
end;

destructor Tgdc_dlgFunction.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  FFunctionParams.Free;
  FParamLines.Free;
  FEvaluate.Free;
  FLastReportResult.Free;
  inherited;
end;

procedure Tgdc_dlgFunction.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Str: TStream;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFUNCTION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if (gdcObject is TgdcFunction) then
  begin
    dbseScript.gdcFunction := (gdcObject as TgdcFunction);
    if (gdcObject.State = dsInsert) then
    begin
      gdcObject.FieldByName('language').AsString := DefaultLanguage;
      if gdcObject.FieldByName(fnName).IsNull then
        gdcObject.FieldByName(fnName).AsString :=
          TgdcFunction(gdcObject).GetUniqueName('ScriptFunction', '',
            gdcObject.FieldByName('ModuleCode').AsInteger);
      if gdcObject.FieldByName(fnModule).IsNull then
        gdcObject.FieldByName(fnModule).AsString := scrUnkonownModule;
      dbcbLangChange(nil);
      FCompiled := False;
      dbeFunctionName.Enabled := True;
    end else
    begin
      dbeFunctionName.Enabled := Pos('copy', gdcObject.FieldByName(fnName).AsString) > 0;
      try
        if not gdcObject.FieldByName('enteredparams').IsNull then
        begin
          Str := gdcObject.CreateBlobStream(gdcObject.FieldByName('enteredparams'), DB.bmRead);
          try
            FFunctionParams.Clear;
            FFunctionParams.LoadFromStream(Str);
          finally
            Str.Free;
          end;
        end else
          FFunctionParams.Clear;
      except
        MessageBox(Handle, 'Данные параметров были повреждены. Их следует переопределить.',
         MSG_ERROR, MB_OK or MB_ICONERROR);
      end;

      dbcbLangChange(nil);
      FCompiled := True;
    end;
    UpdateEdidor;
    UpdateOwner;
  end;


  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgFunction.UpDataFunctionParams(
  FunctionParams: TgsParamList);
var
  I, J: Integer;
  ParamDlg: TgsParamList;
begin
  //Прозиводим обнавление параметров
  if pcFunction.ActivePage = tsParams then
  begin
    FunctionParams.Clear;
    for I := 0 to FParamLines.Count - 1 do
    begin
      FunctionParams.AddParam('', '', prmInteger, '');
      TfrmParamLineSE(FParamLines.Items[I]).GetParam(FunctionParams.Params[I]);
    end;
  end else
  begin
    ParamDlg := TgsParamList.Create;
    try
      ParamDlg.Assign(FunctionParams);
      FunctionParams.Clear;
      GetParamsFromText(FunctionParams, dbeFunctionName.Text, dbseScript.Text);
      for I := 0 to FunctionParams.Count - 1 do
      begin
        for J := 0 to ParamDlg.Count - 1 do
          if FunctionParams.Params[I].RealName = ParamDlg.Params[J].RealName then
          begin
            FunctionParams.Params[I].Assign(ParamDlg.Params[J]);
            Break;
          end;
      end;
    finally
      ParamDlg.Free;
    end;
  end;
end;

procedure Tgdc_dlgFunction.SaveFunctionParams;
var
  Str: TStream;
begin
  if FFunctionParams.Count > 0 then
  begin
    Str := gdcObject.CreateBlobStream(gdcObject.FieldByName(fnEnteredParams), DB.bmWrite);
    try
      FFunctionParams.SaveToStream(Str);
    finally
      Str.Free;
    end;
  end else
    gdcObject.FieldByName(fnEnteredParams).Clear;
end;

procedure Tgdc_dlgFunction.UpdateSelectedColor;
var
  SynVBScriptSyn: TSynVBScriptSyn;
begin
  SynVBScriptSyn := TSynVBScriptSyn(dbseScript.Highlighter);
  if SynVBScriptSyn <> nil then
  begin
    dbseScript.SelectedColor.Foreground :=
      SynVBScriptSyn.MarkBlockAttri.Foreground;
    dbseScript.SelectedColor.Background :=
      SynVBScriptSyn.MarkBlockAttri.Background;
  end else
  begin
    dbseScript.SelectedColor.Foreground := clHighlightText;
    dbseScript.SelectedColor.Background := clHighlight;
  end;
end;

procedure Tgdc_dlgFunction.SynCompletionProposalExecute(
  Kind: SynCompletionType; Sender: TObject; var AString: String; x,
  y: Integer; var CanExecute: Boolean);
var
  Str: String;
  Script: TStrings;
begin
  CanExecute := False;
  if Assigned(VBProposal) then
  begin
    ParserInit;
    Str := dbseScript.LineText;
    Str := GetStatament(Str, dbseScript.CaretX);

    Script := TStringList.Create;
    try
      Script.Assign(dbseScript.Lines);
      VBProposal.PrepareScript(Str, Script, dbseScript.CaretY);
    finally
      Script.Free;
    end;
    SynCompletionProposal.ItemList.Assign(VBProposal.ItemList);
    SynCompletionProposal.InsertList.Assign(VBProposal.InsertList);
{    TStringList(SynCompletionProposal.ItemList).Sort;
    SynCompletionProposal.InsertList.Clear;

    for I := 0 to SynCompletionProposal.ItemList.Count - 1 do
    begin
      P := Pos('(', SynCompletionProposal.ItemList[I]);
      if P = 0 then
        SynCompletionProposal.InsertList.Add(SynCompletionProposal.ItemList[I])
      else
        SynCompletionProposal.InsertList.Add(
          System.Copy(SynCompletionProposal.ItemList[I], 1, P - 1))
    end;}

    CanExecute := SynCompletionProposal.ItemList.Count > 0;
  end;
end;

procedure Tgdc_dlgFunction.ParserInit;
begin
  FVBParser.IsEvent := False;
  FVBParser.Component := nil;
  FVBParser.Objects.Clear;
  if VBProposal <> nil then
    VBProposal.ClearFKObjects;
end;

function Tgdc_dlgFunction.GetCompliteStatament(var Str: String;
  Pos: Integer; out BeginPos, EndPos: Integer): String;
var
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((System.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos >= 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Inc(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

function Tgdc_dlgFunction.GetStatament(var Str: String;
  Pos: Integer): String;
var
  BeginPos, EndPos: Integer;
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((system.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos > 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Dec(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

procedure Tgdc_dlgFunction.dbseScriptProcessCommand(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
begin
  inherited;
  if Command = ecCodeComplite then ParserInit;
end;

procedure Tgdc_dlgFunction.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);

    pcFunction.ActivePageIndex := UserStorage.ReadInteger(S, 'PageIndex',
      pcFunction.ActivePageIndex);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgFunction.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGFUNCTION', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGFUNCTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGFUNCTION',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGFUNCTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);
    UserStorage.WriteInteger(S, 'PageIndex', pcFunction.ActivePageIndex);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGFUNCTION', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgFunction);

finalization
  UnRegisterFrmClass(Tgdc_dlgFunction);

end.
