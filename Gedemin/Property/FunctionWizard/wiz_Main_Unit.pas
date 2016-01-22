
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module


  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}

unit wiz_Main_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB2Item, TB2Dock, TB2Toolbar, ComCtrls, wiz_FunctionBlock_unit,
  SynEditHighlighter, SynHighlighterVBScript, SynEdit, ExtCtrls, ActnList,
  StdCtrls, TB2ToolWindow, wiz_FunctionsParams_unit, SuperPageControl,
  prp_frmGedeminProperty_Unit, gd_security_operationconst, gdcBaseInterface,
  obj_i_Debugger, prp_PropertySettings, SynDBEdit, gsFunctionSyncEdit,
  wiz_Strings_unit, gdcClasses_interface, gdcClasses, clipbrd, prp_MessageConst,
  ContNrs, gsSearchReplaceHelper;

type
  TdlgFunctionWisard = class;

  TWizardDebugLink = class(TCustomDebugLink)
  protected
    procedure DoRun; override;
  public
    procedure ShowForm; override;
    procedure GotoCursor(Y: Integer); override;
    procedure FormInvalidate; override;
  end; 

  TCustomNewFunctionCreater = class
  private
    FFunctionName: string;
    FParentFunctionName: string;
    FCardOfAccountRUID: string;
    FStream: TStream;
    FFunctionRUID: String;
    FFunction: TFunctionBlock;
    procedure SetFunctionName(const Value: string);
    procedure SetParentFunctionName(const Value: string);
    procedure SetCardOfAccountRUID(const Value: string);
    procedure SetStream(const Value: TStream);
    procedure LoadFromStream(Owner: TComponent; Stream: TStream);
    procedure SetFunctionRUID(const Value: String);
  protected
    procedure InitAfterAll; virtual;
    procedure InitFunction(F: TFunctionBlock); virtual;
  public
    class function FunctionClass: TFunctionBlockClass; virtual;

    procedure CreateFunction(Owner: TComponent); virtual;
    procedure InitComponentPallete(Form: TdlgFunctionWisard); virtual;

    property FunctionName: string read FFunctionName write SetFunctionName;
    property ParentFunctionName: string read FParentFunctionName write SetParentFunctionName;
    property CardOfAccountRUID: string read FCardOfAccountRUID write SetCardOfAccountRUID;
    property Stream: TStream read FStream write SetStream;
    property FunctionRUID: String read FFunctionRUID write SetFunctionRUID;
  end;

  TNewEntryFunctionCreater = class(TCustomNewFunctionCreater)
  private
    FTransactionRUID: string;
    FTrRecordRUID: string;
    procedure SetTransactionRUID(const Value: string);
    procedure SetTrRecordRUID(const Value: string);
  protected
    procedure InitAfterAll; override;
  public
    class function FunctionClass: TFunctionBlockClass; override;
    procedure InitFunction(F: TFunctionBlock); override;

    property TransactionRUID: string read FTransactionRUID write SetTransactionRUID;
    property TrRecordRUID: string read FTrRecordRUID write SetTrRecordRUID;
  end;

  TNewTaxFunctionCreater = class(TNewEntryFunctionCreater)
  private
    FTaxNameRuid: string;
    FTaxActualRuid: string;
    procedure SetTaxActualRuid(const Value: string);
    procedure SetTaxNameRuid(const Value: string);
  protected
    procedure InitAfterAll; override;
  public
    class function FunctionClass: TFunctionBlockClass; override;
    procedure InitFunction(F: TFunctionBlock); override;
    procedure InitComponentPallete(Form: TdlgFunctionWisard); override;

    property TaxActualRuid: string read FTaxActualRuid write SetTaxActualRuid;
    property TaxNameRuid: string read FTaxNameRuid write SetTaxNameRuid;
  end;

  TNewTrEntryFunctionCreater = class(TNewEntryFunctionCreater)
  private
    FDocumentRUID: string;
    FDocumentPart: TgdcDocumentClassPart;
    FSaveEmpty: boolean;
    procedure SetDocumentRUID(const Value: string);
    procedure SetDocumentPart(const Value: TgdcDocumentClassPart);
    procedure SetSaveEmpty(const Value: boolean);
  protected
    procedure InitAfterAll; override;
  public
    class function FunctionClass: TFunctionBlockClass; override;
    procedure InitFunction(F: TFunctionBlock); override;
    procedure InitComponentPallete(Form: TdlgFunctionWisard); override;

    property DocumentRUID: string read FDocumentRUID write SetDocumentRUID;
    property DocumentPart: TgdcDocumentClassPart read FDocumentPart write SetDocumentPart;
    property SaveEmpty: boolean read FSaveEmpty write SetSaveEmpty;
  end;

  TNewDocumentTransactioCreater = class(TCustomNewFunctionCreater)
  private
    FDocumentTypeRUID: string;
    FDocumentPart: TgdcDocumentClassPart;
    procedure SetDocumentTypeRUID(const Value: string);
    procedure SetDocumentPart(const Value: TgdcDocumentClassPart);
  protected
    procedure InitAfterAll; override;
    procedure InitFunction(F: TFunctionBlock); override;
  public
   class function FunctionClass: TFunctionBlockClass; override;
   procedure InitComponentPallete(Form: TdlgFunctionWisard); override;

   property DocumentTypeRUID: string read FDocumentTypeRUID write SetDocumentTypeRUID;
   property DocumentPart: TgdcDocumentClassPart read FDocumentPart write SetDocumentPart;
  end;

  TdlgFunctionWisard = class(TForm)
    TBDock1: TTBDock;
    SynVBScriptSyn: TSynVBScriptSyn;
    ActionList: TActionList;
    actGenerate: TAction;
    actOk: TAction;
    actCancel: TAction;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    TBToolWindow1: TTBToolWindow;
    PageControl: TSuperPageControl;
    tsStandart: TSuperTabSheet;
    tsAdditional: TSuperTabSheet;
    tbtStandart: TTBToolbar;
    TBItem3: TTBItem;
    TBItem6: TTBItem;
    TBItem5: TTBItem;
    TBItem7: TTBItem;
    Panel3: TPanel;
    TBDock2: TTBDock;
    TBToolbar2: TTBToolbar;
    TBItem8: TTBItem;
    tbtAdditional: TTBToolbar;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    TBItem4: TTBItem;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    actArrow: TAction;
    actSub: TAction;
    actVar: TAction;
    actIf: TAction;
    actElse: TAction;
    actAccountCicle: TAction;
    actEntry: TAction;
    actUser: TAction;
    actHelp: TAction;
    actEntryCycle: TAction;
    TBItem11: TTBItem;
    Panel4: TPanel;
    Button2: TButton;
    Button1: TButton;
    actTaxExpr: TAction;
    actRun: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem14: TTBItem;
    actStep: TAction;
    TBItem15: TTBItem;
    actStepOver: TAction;
    actRunToCursor: TAction;
    TBItem16: TTBItem;
    TBItem17: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem18: TTBItem;
    actReset: TAction;
    actEval: TAction;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem19: TTBItem;
    actToggleBreakPoint: TAction;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem20: TTBItem;
    TBItem21: TTBItem;
    TBItem12: TTBItem;
    actTrEntryPosition: TAction;
    TBItem13: TTBItem;
    actTrEntry: TAction;
    Panel5: TPanel;
    ScrollBox1: TScrollBox;
    seScript: TSynEdit;
    actWhileCycle: TAction;
    TBItem22: TTBItem;
    actForCycle: TAction;
    TBItem23: TTBItem;
    actSelect: TAction;
    TBItem24: TTBItem;
    actCase: TAction;
    TBItem25: TTBItem;
    actTransaction: TAction;
    TBItem26: TTBItem;
    actSQLCycle: TAction;
    TBItem27: TTBItem;
    TBItem28: TTBItem;
    actBalanceOffTrPos: TAction;
    TBItem29: TTBItem;
    actSQL: TAction;
    TBToolbar1: TTBToolbar;
    TBSubmenuItem1: TTBSubmenuItem;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem30: TTBItem;
    TBItem31: TTBItem;
    TBItem32: TTBItem;
    TBItem33: TTBItem;
    TBItem34: TTBItem;
    TBItem35: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem36: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem38: TTBItem;
    TBItem39: TTBItem;
    TBItem40: TTBItem;
    actCopy: TAction;
    actCut: TAction;
    actPast: TAction;
    TBSubmenuItem3: TTBSubmenuItem;
    TBItem37: TTBItem;
    actProperty: TAction;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem41: TTBItem;
    actDelete: TAction;
    TBSeparatorItem10: TTBSeparatorItem;
    TBItem42: TTBItem;
    actFind: TAction;
    TBSeparatorItem8: TTBSeparatorItem;
    TBItem43: TTBItem;
    actCaseElse: TAction;
    TBItem44: TTBItem;
    actFindNext: TAction;
    actSelectAll: TAction;
    TBItem45: TTBItem;
    procedure TBItem1Click(Sender: TObject);
    procedure actGenerateExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actArrowUpdate(Sender: TObject);
    procedure actSubUpdate(Sender: TObject);
    procedure actSubExecute(Sender: TObject);
    procedure actVarUpdate(Sender: TObject);
    procedure actVarExecute(Sender: TObject);
    procedure actIfUpdate(Sender: TObject);
    procedure actIfExecute(Sender: TObject);
    procedure actElseUpdate(Sender: TObject);
    procedure actElseExecute(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure actAccountCicleUpdate(Sender: TObject);
    procedure actAccountCicleExecute(Sender: TObject);
    procedure actEntryUpdate(Sender: TObject);
    procedure actEntryExecute(Sender: TObject);
    procedure actUserUpdate(Sender: TObject);
    procedure actUserExecute(Sender: TObject);
    procedure actArrowExecute(Sender: TObject);
    procedure actGenerateUpdate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actEntryCycleUpdate(Sender: TObject);
    procedure actEntryCycleExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure seScriptPaintTransient(Sender: TObject; Canvas: TCanvas;
      TransientType: TTransientType);
    procedure actTaxExprExecute(Sender: TObject);
    procedure actTaxExprUpdate(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actStepExecute(Sender: TObject);
    procedure actStepOverExecute(Sender: TObject);
    procedure seScriptSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure actRunToCursorExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actEvalExecute(Sender: TObject);
    procedure seScriptGutterClick(Sender: TObject; X, Y, Line: Integer;
      mark: TSynEditMark);
    procedure actToggleBreakPointExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure actTrEntryPositionExecute(Sender: TObject);
    procedure actTrEntryPositionUpdate(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure actTrEntryExecute(Sender: TObject);
    procedure actTrEntryUpdate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actWhileCycleUpdate(Sender: TObject);
    procedure actWhileCycleExecute(Sender: TObject);
    procedure actForCycleUpdate(Sender: TObject);
    procedure actForCycleExecute(Sender: TObject);
    procedure actSelectUpdate(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure actCaseUpdate(Sender: TObject);
    procedure actCaseExecute(Sender: TObject);
    procedure actTransactionUpdate(Sender: TObject);
    procedure actTransactionExecute(Sender: TObject);
    procedure actSQLCycleUpdate(Sender: TObject);
    procedure actSQLCycleExecute(Sender: TObject);
    procedure actBalanceOffTrPosUpdate(Sender: TObject);
    procedure actBalanceOffTrPosExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
    procedure actSQLUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPastUpdate(Sender: TObject);
    procedure actPastExecute(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actCaseElseExecute(Sender: TObject);
    procedure actCaseElseUpdate(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
  private
    FSelectedBlock: TVisualBlock;
    FDebugLink: TWizardDebugLink;
    FDebugLines: TDebugLines;
    // Вспомогательный объект для поиска по полю ввода
    FSearchReplaceHelper: TgsSearchReplaceHelper;

    function GetScript: string;
    function GetMainFunctionName: string;
    function GetParams: TwizParamList;
    function GetScrollBoxWidth: Integer;
    procedure SetFunctionRUID(const Value: string);
    procedure _OnBlockSelect(Sender: TObject);
    procedure _OnBlockUnSelect(Sender: TObject);
    procedure CheckLink;
    procedure SetMainFunctionName(const Value: String);

  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure Generate;

    procedure CreateNewFunction(FunctionCreater: TCustomNewFunctionCreater);overload;
    property Script: string read GetScript;
    property MainFunctionName: string read GetMainFunctionName write SetmainFunctionName;
    property Params: TwizParamList read GetParams;
    property FunctionRUID: string write SetFunctionRUID;
  end;

var
  dlgFunctionWisard: TdlgFunctionWisard;

implementation

uses
  prm_ParamFunctions_unit,
  syn_ManagerInterface_unit,
  dmImages_unit,
  gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TdlgFunctionWisard.TBItem1Click(Sender: TObject);
begin
  NeedCreate := nil;
end;

procedure TdlgFunctionWisard.actGenerateExecute(Sender: TObject);
var
  I:  Integer;
  S: TStringList;
begin

  S := TStringList.Create;
  try
    for I := 0 to ScrollBox1.ControlCount - 1 do
    begin
      TVisualBlock(ScrollBox1.Controls[I]).Generate(S, 0);
    end;

    seScript.Lines.Text := S.text;
  finally
    S.Free;
  end;
  if FSelectedBlock <> nil then _OnBlockSelect(FselectedBlock); 
end;

procedure TdlgFunctionWisard.LoadFromStream(Stream: TStream);
var
  I: Integer;
  LCount: Integer;
begin
  Scrollbox1.HandleNeeded;

  if Stream = nil then raise Exception.Create(cLoadStreamError);

  CheckLabel(cWizLb, Stream, cLoadStreamError);

  Stream.ReadBuffer(LCount, SizeOf(LCount));

  for I := 0 to LCount - 1 do
  begin
    TVisualBlock.LoadFromStream(Stream, Self, ScrollBox1);
  end;

  actGenerate.Execute; 
end;

procedure TdlgFunctionWisard.SaveToStream(Stream: TStream);
var
  I: Integer;
  LCount: Integer;
begin
  if Stream = nil then raise Exception.Create(cSaveStreamError);

  SaveLabelToStream(cWizLb, Stream);

  LCount := ScrollBox1.ControlCount;
  Stream.Write(LCount, SizeOf(LCount));

  for I := 0 to ScrollBox1.ControlCount - 1 do
  begin
    TVisualBlock(ScrollBox1.Controls[I]).SaveToStream(Stream);
  end;
end;

procedure TdlgFunctionWisard.actOkExecute(Sender: TObject);
begin
  if (MainFunction <> nil) then
  begin
    if MainFunction.CanSave then
      ModalResult := mrOk
    else
      ModalResult := mrNone;
  end else
    ModalResult := mrOk;
end;

procedure TdlgFunctionWisard.actCancelExecute(Sender: TObject);
begin
  Modalresult := mrCancel;
end;

procedure TdlgFunctionWisard.FormCreate(Sender: TObject);
begin
  if Assigned(SynManager) then
    SynManager.GetHighlighterOptions(SynVBScriptSyn);
  OnBlockSelect := _OnBlockSelect;
  OnBlockUnSelect := _OnBlockUnSelect;
  SelBlockList := TObjectList.Create;
  CopiedBlockList := TObjectList.Create;
end;

procedure TdlgFunctionWisard.actArrowUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = nil;
end;

procedure TdlgFunctionWisard.actSubUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TFunctionBlock;
end;

procedure TdlgFunctionWisard.actSubExecute(Sender: TObject);
begin
  NeedCreate := TFunctionBlock;
end;

procedure TdlgFunctionWisard.actVarUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TVarBlock;
end;

procedure TdlgFunctionWisard.actVarExecute(Sender: TObject);
begin
  NeedCreate := TVarBlock;
end;

procedure TdlgFunctionWisard.actIfUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TIfBlock;
end;

procedure TdlgFunctionWisard.actIfExecute(Sender: TObject);
begin
  NeedCreate := TIfBlock;
end;

procedure TdlgFunctionWisard.actElseUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TElseBlock;
end;

procedure TdlgFunctionWisard.actElseExecute(Sender: TObject);
begin
  NeedCreate := TElseBlock;
end;

procedure TdlgFunctionWisard.PageControlChange(Sender: TObject);
begin
  NeedCreate := nil;
end;

procedure TdlgFunctionWisard.actAccountCicleUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TAccountCycleBlock;
end;

procedure TdlgFunctionWisard.actAccountCicleExecute(Sender: TObject);
begin
  NeedCreate := TAccountCycleBlock;
end;

procedure TdlgFunctionWisard.actEntryUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TEntryBlock;
end;

procedure TdlgFunctionWisard.actEntryExecute(Sender: TObject);
begin
  NeedCreate := TEntryBlock
end;

procedure TdlgFunctionWisard.actUserUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TUserBlock;
end;

procedure TdlgFunctionWisard.actUserExecute(Sender: TObject);
begin
  NeedCreate := TUserBlock;
end;

procedure TdlgFunctionWisard.actArrowExecute(Sender: TObject);
begin
  NeedCreate := nil;
end;

procedure TdlgFunctionWisard.actGenerateUpdate(Sender: TObject);
begin
  if ReGenerate then
  begin
    actGenerateExecute(nil);

    if FDebugLines <> nil then FDebugLines.Clear;
    CheckLink;
    FDebugLink.Script.Script.Text := seScript.Text;
    FDebugLink.Script.BreakPointsPrepared := False;
    if MainFunction <> nil then
      FDebugLink.Script.EnteredParams.Assign((MainFunction as TFunctionBlock).FunctionParams);

    ReGenerate := False;
  end;
end;

function TdlgFunctionWisard.GetScript: string;
begin
  actGenerateExecute(nil);
  Result := seScript.Lines.Text;
end;

function TdlgFunctionWisard.GetScrollBoxWidth: Integer;
var
  VB: TVisualBlock;
  I: Integer;
begin
  Result := 0;
  
  if ScrollBox1.ControlCount > 0 then
  begin
    if ScrollBox1.Controls[0] is TVisualBlock then
    begin
      VB := ScrollBox1.Controls[0] as TVisualBlock;
      for I := 0 to VB.ControlCount - 1 do
      begin
        if VB.Controls[I] is TVisualBlock
          and ((VB.Controls[I] as TVisualBlock).Width > Result)
        then
          Result := (VB.Controls[I] as TVisualBlock).Width +
            (VB.Controls[I] as TVisualBlock).Left + GetSystemMetrics(SM_CXVSCROLL);
      end;
    end;
  end;

  if Result < Panel5.ClientWidth then
    Result := Panel5.ClientWidth;
end;

function TdlgFunctionWisard.GetMainFunctionName: string;
begin
  Result := '';
  if MainFunction <> nil then
    Result := MainFunction.BlockName;
end;

procedure TdlgFunctionWisard.SetMainFunctionName(const Value: String);
begin
  if MainFunction <> nil then
    MainFunction.BlockName := Value;
end;

function TdlgFunctionWisard.GetParams: TwizParamList;
begin
  Result := nil;
  if MainFunction <> nil then
    Result := TFunctionBlock(MainFunction).FunctionParams;
end;  

procedure TdlgFunctionWisard.SetFunctionRUID(const Value: string);
begin
  wiz_FunctionBlock_unit.FunctionRUID := Value;
end;

procedure TdlgFunctionWisard.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgFunctionWisard.actEntryCycleUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TEntryCycleBlock;
end;

procedure TdlgFunctionWisard.actEntryCycleExecute(Sender: TObject);
begin
  NeedCreate := TEntryCycleBlock
end;

procedure TdlgFunctionWisard._OnBlockSelect(Sender: TObject);
var
  V: TVisualBlock;
begin
  V := Sender as TVisualBlock;
  FSelectedBlock := V;
  seScript.TopLine := V.BeginScriptLine - 1;
  seScript.Repaint;
end;

procedure TdlgFunctionWisard.FormDestroy(Sender: TObject);
begin
  OnBlockSelect := nil;
  OnBlockUnSelect := nil;
  FDebugLink.Free;
  FDebugLines.Free;
  if SelBlockList <> nil then
    SelBlockList.OwnsObjects:= False;
  FreeAndNil(SelBlockList);
  CopiedBlockList.Free;
end;

procedure TdlgFunctionWisard._OnBlockUnSelect(Sender: TObject);
begin
  FSelectedBlock := nil;
end;

procedure TdlgFunctionWisard.seScriptPaintTransient(Sender: TObject;
  Canvas: TCanvas; TransientType: TTransientType);
var
  TopLine, BottomLine: Integer;
  I, Ind: Integer;
  R: TRect;
  FirstLine, LastLine: Integer;
  LI: TDebuggerLineInfos;
  LH, X, Y: integer;
  ImgIndex: integer;
  BreakPoint: TBreakPoint;
  CurVB: TVisualBlock;
begin
  if SelBlockList = nil then
    exit;

  for Ind:= 0 to SelBlockList.Count - 1 do begin
    CurVB:= TVisualBlock(SelBlockList[Ind]);

//    if (FSelectedBlock <> nil) and (TransientType = ttAfter) then
    if (CurVB <> nil) and (TransientType = ttAfter) then
    begin
      TopLine := seScript.TopLine;
      BottomLine := TopLine + seScript.LinesInWindow;
      for I := TopLine to BottomLine do
      begin
{        if (I >= FSelectedBlock.BeginScriptLine) and
          (I <= FSelectedBlock.EndScriptLine) then}
        if (I >= CurVB.BeginScriptLine - 1) and
          (I <= CurVB.EndScriptLine - 1) then
        begin
          R.TopLeft := seScript.RowColumnToPixels(Point(0, I));
          R.Bottom := R.Top + seScript.LineHeight;
          R.Top := R.Top - 1;
          R.Right := seScript.Gutter.Width;
          R.Left := R.Right - 5;
          with Canvas do
          begin
//           Brush.Color := FSelectedBlock.Color;
           Brush.Color := CurVB.Color;
           FillRect(R);
          end;
        end;
      end;
    end;
    //Рисуем гуттер
    if TransientType = ttAfter then
    begin
      FirstLine := seScript.TopLine;
      Lastline := FirstLine + seScript.LinesInWindow - 1;
      if Lastline > seScript.Lines.Count then
        LastLine := seScript.Lines.Count;
      if not (Assigned(Debugger) and (seScript.Highlighter is
        TSynVBScriptSyn)) then Exit;
      //Проверяем размер. На всякий случай
      if FDebugLines = nil then
        FDebugLines := TDebugLines.Create;

      CheckLink;

      if FDebugLink.IsExecuteScript then
        FDebugLines.Assign(Debugger.ExecuteDebugLines);

      FDebugLines.CheckSize(seScript.Lines.Count);

      if (FDebugLines.Count >= seScript.Lines.Count) and (FDebugLines.Count > 0) then
      begin
        X := 14;
        LH := seScript.LineHeight;
        Y := (LH - dmImages.imglGutterGlyphs.Height) div 2
          + LH * (FirstLine - seScript.TopLine);
        while FirstLine <= LastLine do
        begin
          LI := FDebugLines[FirstLine - 1];
          if (Debugger.CurrentLine = FirstLine - 1) and
            FDebugLink.IsExecuteScript then
          begin
            BreakPoint := BreakpointList.BreakPoint(FDebugLink.FunctionKey,
              FirstLine);
            if BreakPoint <> nil then
              ImgIndex := 2
            else
              ImgIndex := 1;
          end else
          if dlExecutableLine in LI then
          begin
            BreakPoint := BreakpointList.BreakPoint(FDebugLink.FunctionKey,
              FirstLine);
            if BreakPoint <> nil then
              if (PropertySettings.DebugSet.UseDebugInfo) and
                BreakPoint.Enabled then
                ImgIndex := 3
              else
                ImgIndex := 5
            else
              ImgIndex := 0;
            if FDebugLines.ErrorLine = FirstLine - 1 then
              ImgIndex := 0;
          end else
          begin
            BreakPoint := BreakpointList.BreakPoint(FDebugLink.FunctionKey,
              FirstLine);
            if BreakPoint <> nil then
            begin
              if (PropertySettings.DebugSet.UseDebugInfo) and BreakPoint.Enabled then
              begin
                if not FDebugLink.IsExecuteScript then
                  ImgIndex := 3
                else
                  ImgIndex := 4
              end else
                ImgIndex := 5
            end else
              ImgIndex := -1;
          end;
          if ImgIndex >= 0 then
            dmImages.imglGutterGlyphs.Draw(seScript.Canvas, X, Y, ImgIndex);
          Inc(FirstLine);
          Inc(Y, LH);
        end;
      end;
    end;
  end;
end;

procedure TdlgFunctionWisard.actTaxExprExecute(Sender: TObject);
begin
  NeedCreate := TTaxVarBlock;
end;

procedure TdlgFunctionWisard.actTaxExprUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TTaxVarBlock;
end;

{ TCustomNewFunctionCreater }

procedure TCustomNewFunctionCreater.CreateFunction(Owner: TComponent);
var
  F: TFunctionBlock;
  S: TScriptBlock;
begin
  if (FStream <> nil) and (FStream.Size > 0) then
  begin
    LoadFromStream(Owner, Stream);
  end else
  begin
    TwinControl(Owner).HandleNeeded;

    S := TScriptBlock.Create(Owner);
    S.Parent := TWinControl(Owner);
    F := FunctionClass.Create(Owner);
    F.Parent := S;
    F.UnWrap := True;
    F.SetBounds(10, 10, 250, 100);
    F.CannotDelete := True;
    InitFunction(F);
    MainFunction := F;
    FFunction := F;
  end;
  InitAfterAll;
  ReGenerate := True;
end;

class function TCustomNewFunctionCreater.FunctionClass: TFunctionBlockClass;
begin
  Result := TFunctionBlock;
end;

procedure TCustomNewFunctionCreater.InitAfterAll;
begin
  wiz_FunctionBlock_unit.FunctionRUID := FFunctionRUID;
  FFunction.CardOfAccountsRUID := FCardOfAccountRUID;
end;

procedure TCustomNewFunctionCreater.InitComponentPallete(
  Form: TdlgFunctionWisard);
begin

end;

procedure TCustomNewFunctionCreater.InitFunction(F: TFunctionBlock);
begin
  if F <> nil then
  begin
    F.BlockName := FunctionName;
    F.FunctionParams.Clear;
    f.FunctionParams.AddParam(ENG_BEGINDATE, RUS_BEGINDATE, prmDate, RUS_BEGINDATE);
    f.FunctionParams.AddParam(ENG_ENDDATE, RUS_ENDDATE, prmDate, RUS_ENDDATE);
  end;
end;

procedure TCustomNewFunctionCreater.LoadFromStream(Owner: TComponent; Stream: TStream);
var
  I: Integer;
  LCount: Integer;
begin
  TWinControl(Owner).HandleNeeded;

  if Stream = nil then raise Exception.Create(cLoadStreamError);

  CheckLabel(cWizLb, Stream, cLoadStreamError);

  Stream.ReadBuffer(LCount, SizeOf(LCount));

  for I := 0 to LCount - 1 do
  begin
    TVisualBlock.LoadFromStream(Stream, Owner, TWinControl(Owner), FunctionName, ParentFunctionName);
  end;

  FFunction := MainFunction
end;

procedure TCustomNewFunctionCreater.SetCardOfAccountRUID(
  const Value: string);
begin
  FCardOfAccountRUID := Value;
end;

procedure TCustomNewFunctionCreater.SetFunctionName(const Value: string);
begin
  FFunctionName := Value;
end;

procedure TCustomNewFunctionCreater.SetParentFunctionName(const Value: string);
begin
  FParentFunctionName := Value;
end;

procedure TCustomNewFunctionCreater.SetFunctionRUID(const Value: String);
begin
  FFunctionRUID := Value;
end;

procedure TCustomNewFunctionCreater.SetStream(const Value: TStream);
begin
  FStream := Value;
end;

{ TNewEntryFunctionCreater }

class function TNewEntryFunctionCreater.FunctionClass: TFunctionBlockClass;
begin
  Result := TEntryFunctionBlock;
end;

procedure TNewEntryFunctionCreater.InitAfterAll;
begin
  inherited;
  TEntryFunctionBlock(FFunction).TransactionRUID := FTransactionRUID;
  TEntryFunctionBlock(FFunction).TrRecordRUID := FTrRecordRUID;
end;

procedure TNewEntryFunctionCreater.InitFunction(F: TFunctionBlock);
begin
  inherited;
  if (F <> nil) and (F is TEntryFunctionBlock) then
  begin
    f.FunctionParams.AddParam(ENG_ENTRYDATE, RUS_ENTRYDATE, prmDate, RUS_ENTRYDATE);
  end;
end;

procedure TdlgFunctionWisard.CreateNewFunction(
  FunctionCreater: TCustomNewFunctionCreater);   
begin
  FunctionCreater.CreateFunction(ScrollBox1);
  FunctionCreater.InitComponentPallete(Self);
  Modified := False;

  Panel5.Width := GetScrollBoxWidth;
end;

procedure TNewEntryFunctionCreater.SetTransactionRUID(const Value: string);
begin
  FTransactionRUID := Value;
end;

procedure TNewEntryFunctionCreater.SetTrRecordRUID(const Value: string);
begin
  FTrRecordRUID := Value;
end;

{ TNewTaxFunctionCreater }

class function TNewTaxFunctionCreater.FunctionClass: TFunctionBlockClass;
begin
  Result := TTaxFunctionBlock;
end;

procedure TNewTaxFunctionCreater.InitAfterAll;
begin
  inherited;
  with FFunction as TTaxFunctionBlock do
  begin
    TaxActualRuid := Self.FTaxActualRuid;
    TaxNameRuid := Self.FTaxNameRuid;
  end;
end;

procedure TNewTaxFunctionCreater.InitComponentPallete(
  Form: TdlgFunctionWisard);
begin
  inherited;
  Form.TBItem21.Visible := True;
end;

procedure TNewTaxFunctionCreater.InitFunction(F: TFunctionBlock);
begin
  inherited;
  F.FunctionParams.Clear;
  f.FunctionParams.AddParam(ENG_BEGINDATE, RUS_BEGINDATE, prmDate, RUS_BEGINDATE);
  f.FunctionParams.AddParam(ENG_ENDDATE, RUS_ENDDATE, prmDate, RUS_ENDDATE);
end;

procedure TNewTaxFunctionCreater.SetTaxActualRuid(const Value: string);
begin
  FTaxActualRuid := Value;
end;

procedure TNewTaxFunctionCreater.SetTaxNameRuid(const Value: string);
begin
  FTaxNameRuid := Value;
end;

procedure TdlgFunctionWisard.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDebugLink = AComponent) then
    FDebugLink := nil;
end;

procedure TdlgFunctionWisard.CheckLink;
begin
  if FDebugLink = nil then
  begin
    FDebugLink := TWizardDebugLink.Create(nil);
    FDebugLink.Form := Self;

    with FDebugLink.Script do
    begin
      Language := 'VBScript';
      ModuleCode := OBJ_APPLICATION;
      FunctionKey := gdcBaseManager.GetIdByRUIDString(wiz_FunctionBlock_unit.FunctionRUID);
      Name := MainFunction.BlockName;
      Script.Text := seScript.Text;
    end;
  end;
end;

procedure TdlgFunctionWisard.actRunExecute(Sender: TObject);
begin
  CheckLink;
  FDebugLink.Run;
end;

procedure TdlgFunctionWisard.actStepExecute(Sender: TObject);
begin
  CheckLink;
  FDebugLink.Step
end;

procedure TdlgFunctionWisard.actStepOverExecute(Sender: TObject);
begin
  CheckLink;
  FDebugLink.StepOver;
end;

procedure TdlgFunctionWisard.seScriptSpecialLineColors(Sender: TObject;
  Line: Integer; var Special: Boolean; var FG, BG: TColor);
var
  LI: TDebuggerLineInfos;
  BreakPoint: TBreakPoint;
begin
  if not (Assigned(Debugger) and (seScript.Highlighter is
    TSynVBScriptSyn)) then Exit;

  if FDebugLines = nil then
    FDebugLines := TDebugLines.Create;

  CheckLink;

  if FDebugLink.IsExecuteScript then
    FDebugLines.Assign(Debugger.ExecuteDebugLines);

  FDebugLines.CheckSize(seScript.Lines.Count);

  LI := FDebugLines[Line - 1];
  BreakPoint := BreakPointList.BreakPoint(FDebugLink.FunctionKey,
    Line);
  if (Debugger.CurrentLine = Line - 1) and FDebugLink.IsExecuteScript then
  begin
    Special := TRUE;
    FG := TSynVBScriptSyn(seScript.Highlighter).ExecutionPointAttri.Foreground;
    BG := TSynVBScriptSyn(seScript.Highlighter).ExecutionPointAttri.Background;
  end else
  if BreakPoint <> nil then
  begin
    Special := TRUE;
    if (PropertySettings.DebugSet.UseDebugInfo) and (BreakPoint.Enabled) then
    begin
      if (dlExecutableLine in LI) or not FDebugLink.IsExecuteScript then
      begin
        FG := TSynVBScriptSyn(seScript.Highlighter).EnableBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(seScript.Highlighter).EnableBreakPointAttri.Background;
      end else
      begin
        FG := TSynVBScriptSyn(seScript.Highlighter).InvalidBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(seScript.Highlighter).InvalidBreakPointAttri.Background;
      end
    end else
    begin
      BG := clLime;
      FG := clRed;
    end;
  end;
  (*if FDebugLines.ErrorLine = Line - 1{dlErrorLine in LI} then
  begin
    Special := True;
    FG := TSynVBScriptSyn(seScript.Highlighter).ErrorLineAttri.Foreground;
    BG := TSynVBScriptSyn(seScript.Highlighter).ErrorLineAttri.Background;
  end;*)
end;

{ TWizardDebugLink }

procedure TWizardDebugLink.DoRun;
begin
  Running := true;
  try
    inherited;
  finally
    Running := False;
  end;
end;

procedure TWizardDebugLink.FormInvalidate;
begin
  inherited;
  if Form <> nil then
  begin
    with Form as TdlgFunctionWisard do
    begin
      seScript.Invalidate;
    end;
  end;
end;

procedure TWizardDebugLink.GotoCursor(Y: Integer);
begin
  inherited;
end;

procedure TWizardDebugLink.ShowForm;
var
  Y: Integer;
begin
  inherited;
  if Form <> nil then
  begin
    with Form as TdlgFunctionWisard do
    begin
      Y := Debugger.CurrentLine + 1;
      if (Y > 0) and (Y <= seScript.Lines.Count) then
      begin
        seScript.CaretX := 0;
        seScript.CaretY := Y;
        seScript.EnsureCursorPosVisibleEx(True);
        seScript.InvalidateLine(Y);
      end;
      if seScript.CanFocus then
        seScript.SetFocus;

      seScript.Invalidate;
    end;
  end;  
end;

procedure TdlgFunctionWisard.actRunToCursorExecute(Sender: TObject);
begin
  CheckLink;
  FDebugLink.GotoCursor(seScript.CaretXY.y);
end;

procedure TdlgFunctionWisard.actResetExecute(Sender: TObject);
begin
  CheckLink;
  FdebugLink.Reset;
end;

procedure TdlgFunctionWisard.actEvalExecute(Sender: TObject);
var
  Text: String;
  I: Integer;
begin
  if seScript.SelAvail then
    Text := seScript.SelText
  else
    Text := seScript.WordAtCursor;

  for I := Length(Text) downto 1 do
  begin
    if Text[I] < ' ' then
      Text[I] := ' ';
  end;
  CheckLink;
  FDebugLink.Evaluate(Text);
end;

procedure TdlgFunctionWisard.seScriptGutterClick(Sender: TObject; X, Y,
  Line: Integer; mark: TSynEditMark);
begin
  CheckLink;
  FdebugLink.ToggleBreakPoint(Line)
end;

procedure TdlgFunctionWisard.actToggleBreakPointExecute(Sender: TObject);
begin
  CheckLink;
  FdebugLink.ToggleBreakPoint(seScript.CaretY);
end;

procedure TdlgFunctionWisard.actCancelUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FDebugLink <> nil) and not FDebugLink.IsRuning
end;

{ TNewTrEntryFunctionCreater }

class function TNewTrEntryFunctionCreater.FunctionClass: TFunctionBlockClass;
begin
  Result := TTrEntryFunctionBlock
end;

procedure TNewTrEntryFunctionCreater.InitAfterAll;
begin
  inherited;
  {$IFDEF GEDEMIN}
  if FFunction is TTrEntryFunctionBlock then
  begin
    TTrEntryFunctionBlock(FFunction).DocumentRUID := DocumentRUID;
    TTrEntryFunctionBlock(FFunction).DocumentPart := FDocumentPart;
    TTrEntryFunctionBlock(FFunction).SaveEmpty := FSaveEmpty;
  end;
  {$ENDIF}
end;

procedure TNewTrEntryFunctionCreater.InitComponentPallete(
  Form: TdlgFunctionWisard);
begin
  inherited;
  Form.TBItem12.Visible := True;
  Form.TBItem13.Visible := True;
  Form.TBItem10.Visible := False;
  Form.TBItem28.Visible := True;
end;

procedure TNewTrEntryFunctionCreater.InitFunction(F: TFunctionBlock);
begin
  inherited;
  F.FunctionParams.Clear;
  f.FunctionParams.AddParam(ENG_GDCENTRY, RUS_DONOTDELETE, prmInteger, RUS_GDCENTRY);
  f.FunctionParams.AddParam(ENG_GDCDOCUMENT, RUS_DONOTDELETE, prmInteger, RUS_GDCDOCUMENT);
end;

procedure TNewTrEntryFunctionCreater.SetDocumentPart(
  const Value: TgdcDocumentClassPart);
begin
  FDocumentPart := Value;
end;

procedure TNewTrEntryFunctionCreater.SetDocumentRUID(const Value: string);
begin
  FDocumentRUID := Value;
end;

procedure TdlgFunctionWisard.actTrEntryPositionExecute(Sender: TObject);
begin
  NeedCreate := TTrEntryPositionBlock;
end;

procedure TdlgFunctionWisard.actTrEntryPositionUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TTrEntryPositionBlock
end;

procedure TdlgFunctionWisard.Generate;
begin
  actGenerate.Execute;
end;

procedure TdlgFunctionWisard.actRunUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (MainFunction <> nil) and (MainFunction.CanRun)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TdlgFunctionWisard.actTrEntryExecute(Sender: TObject);
begin
  NeedCreate := TTrEntryBlock;
end;

procedure TdlgFunctionWisard.actTrEntryUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TTrEntryBlock;
end;

procedure TNewTrEntryFunctionCreater.SetSaveEmpty(const Value: boolean);
begin
  FSaveEmpty := Value;
end;

procedure TdlgFunctionWisard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (ModalResult <> mrOk) and Modified then
  begin
    case Application.MessageBox(RUS_SAVECHANGES, PChar(RUS_QUESTION), MB_YESNOCANCEL or MB_ICONQUESTION) of
      IDYES: ModalResult := mrOk;
      IDNO: ModalResult := mrCancel;
      IDCANCEL:
      begin
        ModalResult := mrNone;
        Action := caNone;
      end;
    end;
  end;
end;

procedure TdlgFunctionWisard.actWhileCycleUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TWhileCycleBlock
end;

procedure TdlgFunctionWisard.actWhileCycleExecute(Sender: TObject);
begin
  NeedCreate := TWhileCycleBlock
end;

procedure TdlgFunctionWisard.actForCycleUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TForCycleBlock;
end;

procedure TdlgFunctionWisard.actForCycleExecute(Sender: TObject);
begin
  NeedCreate := TForCycleBlock
end;

procedure TdlgFunctionWisard.actSelectUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TSelectBlock
end;

procedure TdlgFunctionWisard.actSelectExecute(Sender: TObject);
begin
  NeedCreate := TSelectBlock
end;

procedure TdlgFunctionWisard.actCaseUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TCaseBlock
end;

procedure TdlgFunctionWisard.actCaseExecute(Sender: TObject);
begin
  NeedCreate := TCaseBlock
end;

{ TNewDocumentTransactioCreater }

class function TNewDocumentTransactioCreater.FunctionClass: TFunctionBlockClass;
begin
  Result := TDocumentTransactionFunction
end;

procedure TNewDocumentTransactioCreater.InitAfterAll;
begin
  inherited;
  {$IFDEF GEDEMIN}
  if FFunction is TDocumentTransactionFunction then
  begin
    TDocumentTransactionFunction(FFunction).DocumentTypeRUID := FDocumentTypeRUID;
    TDocumentTransactionFunction(FFunction).DocumentPart := FDocumentPart;
  end;
  {$ENDIF}
end;

procedure TNewDocumentTransactioCreater.InitComponentPallete(
  Form: TdlgFunctionWisard);
begin
  inherited;
  Form.TBItem9.Visible := False;
  Form.TBItem11.Visible := False;
  Form.TBItem10.Visible := False;
  Form.TBItem26.Visible := True;
end;

procedure TNewDocumentTransactioCreater.InitFunction(F: TFunctionBlock);
begin
  if F <> nil then
  begin
    F.BlockName := FunctionName;
    F.FunctionParams.Clear;
    f.FunctionParams.AddParam(ENG_GDCDOCUMENT, RUS_GDCENTRY, prmInteger, RUS_GDCENTRY);
  end;
end;

procedure TNewDocumentTransactioCreater.SetDocumentPart(
  const Value: TgdcDocumentClassPart);
begin
  FDocumentPart := Value;
end;

procedure TNewDocumentTransactioCreater.SetDocumentTypeRUID(
  const Value: string);
begin
  FDocumentTypeRUID := Value;
end;

constructor TdlgFunctionWisard.Create(AnOwner: TComponent);
begin
  inherited;
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(seScript);   
end;

destructor TdlgFunctionWisard.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  inherited;
end;

procedure TdlgFunctionWisard.actTransactionUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TTransactionBlock
end;

procedure TdlgFunctionWisard.actTransactionExecute(Sender: TObject);
begin
  NeedCreate := TTransactionBlock
end;

procedure TdlgFunctionWisard.actSQLCycleUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := (NeedCreate = TSQLCycleBlock)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TdlgFunctionWisard.actSQLCycleExecute(Sender: TObject);
begin
  NeedCreate := TSQLCycleBlock;
end;

procedure TdlgFunctionWisard.actBalanceOffTrPosUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TBalanceOffTrEntryPositionBlock;
end;

procedure TdlgFunctionWisard.actBalanceOffTrPosExecute(Sender: TObject);
begin
  NeedCreate := TBalanceOffTrEntryPositionBlock;
end;

procedure TdlgFunctionWisard.actSQLExecute(Sender: TObject);
begin
  NeedCreate := TSQLBlock
end;

procedure TdlgFunctionWisard.actSQLUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := (NeedCreate = TSQLBlock)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TdlgFunctionWisard.actCopyExecute(Sender: TObject);
begin
  FSelectedBlock.Copy;
end;

procedure TdlgFunctionWisard.actCopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil) and (FSelectedBlock.CanCopy)
end;

procedure TdlgFunctionWisard.actCutExecute(Sender: TObject);
begin
  FSelectedBlock.Cut
end;

procedure TdlgFunctionWisard.actPastUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil) and FSelectedBlock.CanPast;
end;

procedure TdlgFunctionWisard.actPastExecute(Sender: TObject);
begin
  FSelectedBlock.Paste;
end;

procedure TdlgFunctionWisard.actCutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil) and FSelectedBlock.CanCut;
end;

procedure TdlgFunctionWisard.actPropertyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil) and
    (FSelectedBlock.CanEdit)
end;

procedure TdlgFunctionWisard.actPropertyExecute(Sender: TObject);
begin
  FSelectedBlock.EditDialog;
end;

procedure TdlgFunctionWisard.actDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil) and
    (FSelectedBlock.CanEdit) and not FSelectedBlock.CannotDelete;
end;

procedure TdlgFunctionWisard.actDeleteExecute(Sender: TObject);
begin
  FSelectedBlock.Delete;
end;

procedure TdlgFunctionWisard.actFindExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Search;
end;

procedure TdlgFunctionWisard.actFindNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure TdlgFunctionWisard.actCaseElseExecute(Sender: TObject);
begin
  NeedCreate := TCaseElseBlock
end;

procedure TdlgFunctionWisard.actCaseElseUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := NeedCreate = TCaseElseBlock;
end;  

procedure TdlgFunctionWisard.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FDebugLink <> nil) and (not FDebugLink.IsRuning)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TdlgFunctionWisard.actSelectAllExecute(Sender: TObject);
begin
  if (FSelectedBlock <> nil) and (FSelectedBlock.Parent is TVisualBlock) then
    (FSelectedBlock.Parent as TVisualBlock).SelectAll;
end;

procedure TdlgFunctionWisard.actSelectAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FSelectedBlock <> nil)
    and (FSelectedBlock.Parent is TVisualBlock)
    and (FSelectedBlock.Parent.ControlCount > 1);
end;

initialization
  ClipboardFormat := RegisterClipboardFormat(ClipboardFormatName);
end.
