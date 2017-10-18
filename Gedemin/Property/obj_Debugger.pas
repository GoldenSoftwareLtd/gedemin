{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    Debugger.pas

  Abstract

    Gedemin project. TDebugger, TVBDebugParser.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.04.02    tiptop        Initial version.
    1.01    29.07.02    tiptop        Add VBDebugParser
            08.08.02    tiptop        Final version
            17.08.02    tiptop        Добавлено сохранение ИД для обработки
                                      ошибки
    1.02    18.06.03    DAlex         Добавлена поддержка обработки исключений (инструкция Except)
    1.03    08.08.03    DAlex         Исправления работы окон в режиме остановки
--}
{ TODO : Объединить аргументы и переменные }
unit obj_Debugger;

{$I SynEdit.inc}

interface

uses
  Windows, Classes, ComObj, ActiveX, AxCtrls, Gedemin_TLB, StdVcl, Messages,
  MSScriptControl_TLB, SynEdit, VBParser, Sysutils, Forms, obj_i_Debugger,
  rp_BaseReport_unit, scr_i_FunctionList, evt_i_Base, gd_i_ScriptFactory;

const
  sfRunTimeSciptMsg = 'ИД: %d; Время: %g c; СФ: %s';

type
  TDebugger = class;
  TFinallyVarList = class;

  TVBDebugParser = class(TVBParser)
  private
    FScriptLine: Integer;
    FScriptLineAdd: Integer;
    FExecutable: Boolean;
    FId: Integer;
  protected
    //Устанавливает флаг выполняемости строки (для дебагера)
    procedure SetExecutable; override;
    procedure DoBeforeStatament; override;
    procedure DoAfterStatament;  override;
    function GetPrepareStr: String; override;
    procedure DoProcBegin; override;
    procedure DoProcEnd; override;
    procedure DoExit(P: Integer); override;
    function TestCorrect(Script: string): Boolean;
    procedure RemoveComent;
  public
    procedure PrepareScript(const SF: TrpCustomFunction); reintroduce;
    procedure LightPrepareScript(const SF: TrpCustomFunction);
  end;

  TtkTokenKind = (tkComment, tkIdentifier, tkKey, tkNull, tkNumber, tkSpace,
    tkString, tkSymbol, tkUnknown, tkRelOp, tkAddOp, tkMulOp);

  TParserState = (psStatament, psDesignator, psFunction, psClass, psExpression,
    psEnd, psSelect, psCase, psDo, psLoop, psExit, psFor, psModificator,
    psParam, psProperty, psSetVar, psApostrophe, psNoChangeVarName, psForEach);
  TParserStates = set of TParserState;

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

  TDebuggerParser = class
  private
    FId: Integer;
    FProcedureId: Integer;
    FLineNumber: Integer;
    FAddLine: Integer;
    FProcTable: array[#0..#255] of TProcTableProc;
    FRun: LongInt;
    FStringLen: Integer;
    FToIdent: PChar;
    FTokenPos: Integer;
    FTokenID: TtkTokenKind;
    FInClass, FInFunction: Boolean;
    FIdentFuncTable: array[0..133] of TIdentFuncTableFunc;
    FScript: PChar;
    FScriptSize: Integer;
    FParserStates: TParserStates;
    FClassName, FFunctionName: String;
    FFieldsList: TStrings;
    FParamList: TStrings;
    FVarName: String;
    FSC: TScriptControl;
    FExecutable: Boolean;
    FBreakPointAdded: Boolean;
    FProcType: string;
    FScriptPrepared: Boolean;
    FEvaluate: Boolean;
    FDebugger: TDebugger;
    FLocalVarList: TStrings;

    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;
    function Func15: TtkTokenKind;
    function Func17: TtkTokenKind;
    function Func19: TtkTokenKind;
    function Func23: TtkTokenKind;
    function Func26: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func29: TtkTokenKind;
    function Func32: TtkTokenKind;
    function Func33: TtkTokenKind;
    function Func35: TtkTokenKind;
    function Func36: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func42: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func46: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func48: TtkTokenKind;
    function Func49: TtkTokenKind;
    function Func54: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func58: TtkTokenKind;
    function Func60: TtkTokenKind;
    function Func62: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func74: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func89: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func98: TtkTokenKind;
    procedure _DoFunction;
    function Func102: TtkTokenKind;
    function Func105: TtkTokenKind;
    function Func133: TtkTokenKind;
    procedure ApostropheProc;
    procedure ComentProc;
    procedure CRProc;
    procedure DateProc;
    procedure GreaterProc;
    procedure StatamentProc;
    procedure LFProc;
    procedure LowerProc;
    procedure NullProc;
    procedure NumberProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
    procedure RavnoProc;
    procedure AddOpProc;
    procedure MulOpProc;
    procedure SetScript(const Value: string);
    function GetScript: string;
    //Процедура обработки простого оператора
    procedure SimpleStmtProc;
    //роцедура оюработки отределения
    procedure DesignatorProc; virtual;
    procedure ListExprList;
    procedure TrimSpace;
    procedure ExprListProc;
    procedure ExpressionProc;
    procedure SimpleExpressionProc;
    procedure TermProc;
    procedure FactorProc;
    procedure FormalParamsProc;
    procedure FormalParamProc;
    procedure ObjDeclStmt;
    function CurrentWord: string;
    function TestCorrect: Boolean;
    procedure SetID(const Value: Integer);
    procedure CheckBufSize(L: Integer);
    procedure SetDebugger(const Value: TDebugger);
  protected
    function AltFunc: TtkTokenKind;
    procedure InitIdent; virtual;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure Next; virtual;
    procedure NextStmt; virtual;

    procedure DoAfterStatament;
    procedure DoProcBegin;
    procedure DoProcEnd;
    procedure Insert(Str: string; Index: Integer);
    procedure Delete(Index, Count: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure PrepareScript;
    procedure LightPrepareScript;
    function Eval: Variant;

    property Script: string read GetScript write SetScript;
    property ID: Integer read FID write SetID;
    property Debugger: TDebugger read FDebugger write SetDebugger;
  end;

  TDebugger = class(TAutoObject, IgsDebugger, IDebugger)
  private
    fDebuggerState: TDebuggerState;
    fLineToStop: integer;
    fWantedState: TDebuggerState;
    fOnBreakpointChange: TBreakpointChangeEvent;
    fOnCurrentLineChange: TNotifyEvent;
    fOnStateChange: TDebuggerStateChangeEvent;
    fOnYield: TNotifyEvent;

    FDebugLines: TDebugLines;
    FExecuteDebugLines: TDebugLines;

    FParser: TVBDebugParser;
    FParser1: TDebuggerParser;
//    FOnScriptInvalidate: TNotifyEvent;
//    FProcedureId: Integer;
    FExecuteScriptFunction: Integer{TrpCustomFunction};
    FExecuteScriptModule: string;
    FInDebugger: Boolean;
    //Стек переменных
    FDebugVars: TDebugVars;
    //Список имен вызванных функций
    FCallNames: TStrings;
    //Строка вызова функции
    FCallLine: Integer;
    FFunctionRun: Boolean;
    //Список вызываемых скрипт-функций
    FScriptFunctionList: TList;
    FFinallyVarList: TFinallyVarList;
//    FLastScriptFunction: Integer;
    FRuntimeList: TRuntimeList;
    FResultRuntimeList: TRuntimeList;
    //
    FEnabled: Boolean;
    //Список отключенных окон
    FEnabledList: TList;
    FStopFunctionId: Integer;
//    FStopProcId: Integer;
    FOnEndScript: TEndScriptEvent;

    FCanSaveRunTime: Boolean;
    FRuntimeStream: TFileStream;
    FOnStateChanged: TnotifyEvent;

    FStepOverCount: Integer;
    FCurrentKeyIndex: Integer;
    FLastActiveWindow: HWND;

    //Функции интерфейса IgsDebugger
    function  BreakPoint(Sfid: Integer; ProcId: Integer;
      Line: Integer): WordBool; safecall;
    procedure ProcBegin(sfid: Integer; const FunctionName: WideString); safecall;
    procedure SetVariable(const VarName: WideString; Value: OleVariant); safecall;
    function  GetVariable(const VarName: WideString): OleVariant; safecall;
    procedure SetArgument(const VarName: WideString; Value: OleVariant); safecall;
    procedure ProcEnd; safecall;
    procedure BeginTime(FunctionKey: Integer; var FunctionName: WideString); safecall;
    procedure EndTime(FunctionKey: Integer); safecall;
    //Возвращает значение переменной
    function VaribleExists(Name: WideString): Boolean;
    //вычисляет значение выражения
    //Если Extend = False то проверяются значения в стеке переменных
    function Eval(Str: String; Extend: Boolean = True): Variant;
    function  Get_Self: TObject;
    procedure DoOnBreakpointChanged(ALine: integer);
    procedure DoCurrentLineChanged;
    procedure DoStateChange;
    procedure DoStopAndReset;
    procedure ClearLastFinallyParams;
    procedure ClearDebugVars(Index: Integer);
    function GetCurrentLine: integer;
    function GetDebugLines: TDebugLines;
    function GetOnBreakpointChange: TBreakpointChangeEvent;
    function GetOnCurrentLineChange: TNotifyEvent;
    function GetOnStateChange: TDebuggerStateChangeEvent;
    function GetOnYield: TNotifyEvent;
    function GetParser: TVBDebugParser;
    procedure SetOnBreakpointChange(const Value: TBreakpointChangeEvent);
    procedure SetOnCurrentLineChange(const Value: TNotifyEvent);
    procedure SetOnStateChange(const Value: TDebuggerStateChangeEvent);
    procedure SetOnYield(const Value: TNotifyEvent);
    procedure SetCurrentLine(const Value: Integer);
    function GetExecuteDebugLines: TDebugLines;
    function GetExecuteScriptFunction: Integer;
    procedure SetInDebugger(const Value: Boolean);
    function GetInDebugger: Boolean;
    procedure SetFunctionRun(const Value: Boolean);
    function GetFunctionRun: Boolean;
    function GetLastScriptFunction: Integer;
    function GetFinallyParams(const Index: Integer): TFinallyRec;
    function GetCurrentFinallyParams: TFinallyRec;
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure GetCallStack(const S: TStrings; out IdList: TList);
    procedure SetOnEndScript(const Value: TEndScriptEvent);
    function  CheckRunTimeFile: Boolean;
    procedure SaveScriptRuntime(const RuntimeRec: TRuntimeRec);
    function GetResultRuntimeList: TRuntimeList;
    function GetOnEndScript: TEndScriptEvent;
    procedure SetOnStateChanged(const Value: TnotifyEvent);
    function GetOnStateChanged: TnotifyEvent;
    procedure DecKeyIndex;
    function  GetCurrentKey: Integer;
    function  GetCurrentKeyIndex: Integer;
    function GetLastFinallyParams: TFinallyRec;
    procedure SetLastFinallyParams(const AParamArray: OleVariant;
      const AFinallyScript: WideString; const ALine: Integer);
  public
    procedure Initialize; override;
    destructor Destroy; override;

    //Cybvftn vtnre dlErrorLine
    procedure ClearErrorLine;
    function CanGotoCursor(ALine: integer): boolean;
    function CanPause: boolean;
    function CanRun: boolean;
    function CanStep: boolean;
    function CanStop: boolean;
    procedure ClearAllBreakpoints;
    function GetLineInfos(ALine: integer): TDebuggerLineInfos;
    procedure GotoCursor(ALine: integer);
    function HasBreakpoints: boolean;
    function IsBreakpointLine(ALine: Integer): Boolean;
    function IsExecutableLine(ALine: integer): boolean;
    function CurrentLineIsBreakpoint: boolean;
    function  IsRunning: WordBool;
    function IsStoped: WordBool;
    function IsPaused: WordBool;
    function IsStep: WordBool;
    function IsStepOver: WordBool;
    function IsReseted: WordBool;
    function CurrentState: TDebuggerState;

    procedure Pause;
    procedure Run;
    procedure Step;
    procedure StepOver;
    procedure Stop;
    procedure Reset;
    procedure WantPause;
    procedure GotoToLine(SFID, Line: Integer);
    procedure ToggleBreakPoint(ALine: Integer; DL: TDebugLines); overload;
    procedure ToggleExecuteBreakpoint(ALine: Integer);
    procedure SetErrorLine(Line: Integer); overload;
    procedure SetErrorLine(Line: Integer; DL: TDebugLines); overload;
    procedure PrepareScript(Sf: TrpCustomFunction);
    //Раставляет метки начала и конца фукции
    procedure LightPrepareScript(Sf: TrpCustomFunction);
    procedure PrepareExecuteScript(Sf: TrpCustomFunction);
    //Процедура инициализации
    //Передаётся кол-во строк
    procedure Init(Count: Integer); overload;
    procedure Init(Count: Integer; DL: TDebugLines); overload;
    procedure InitExecute(Count: Integer);
    //Процедура удаления точек останова
    procedure RemoveBreakPoints(SF: TrpCustomFunction);
    procedure ClearVars;

    property CurrentLine: Integer read GetCurrentLine write SetCurrentLine;
    property DebugLines: TDebugLines read GetDebugLines;
    property ExecuteDebugLines: TDebugLines read GetExecuteDebugLines;
    property Parser: TVBDebugParser read GetParser;
    property ExecuteScriptFunction: Integer read GetExecuteScriptFunction;
    //Указывает на то что сейчас идет обработка точки прерывания
    property InDebugger: Boolean read GetInDebugger write SetInDebugger;
    //Указывает на то что скрипт-контрол запустил функцию на выполнение
    property FunctionRun: Boolean read GetFunctionRun write SetFunctionRun;
    //Ид последней скрипт-функции. Используется при возникновении ошибки
    property LastScriptFunction: Integer read GetLastScriptFunction;
    //Финалли-скрипт последней скрипт-функции.
    property LastFinallyParams: TFinallyRec read GetLastFinallyParams;
    //На время загрузки окна троперти необходимо отключать дебагер
    property Enabled: Boolean read GetEnabled write SetEnabled;

    property OnBreakpointChange: TBreakpointChangeEvent read GetOnBreakpointChange
      write SetOnBreakpointChange;
    property OnCurrentLineChange: TNotifyEvent read GetOnCurrentLineChange
      write SetOnCurrentLineChange;
    property OnStateChange: TDebuggerStateChangeEvent read GetOnStateChange
      write SetOnStateChange;
    property OnYield: TNotifyEvent read GetOnYield write SetOnYield;
    property OnEndScript: TEndScriptEvent read GetOnEndScript write SetOnEndScript;
    property OnStateChanged: TnotifyEvent read GetOnStateChanged write SetOnStateChanged;
  end;

  PFinallyRec = ^TFinallyRec;

  TFinallyVarList = class(TObject)
  private
    FVarList: TList;
    function GetCount: Integer;
    function GetValue(Index: Integer): TFinallyRec;
  public
    constructor Create;
    destructor  Destroy; override;

    function  Add: Integer;
    procedure Clear;
    procedure ClearValue(Index: Integer);
    procedure Delete(Index: Integer);

    procedure SetValue(Index: Integer; const ParamArray: OleVariant;
      const FinallyScript: WideString; const Line: Integer);

    property  Count: Integer read GetCount;
    property  Value[Index: Integer]: TFinallyRec read GetValue;// write SetValue;
  end;

type
  TSampleExecutableLine = record
    Line: integer;
    Delta: integer; // to change the array index
  end;

implementation

uses
  ComServ, gd_security, prp_PropertySettings,
  prp_DOCKFORM_unit, prp_MessageConst,
  prp_frmClassesInspector_unit, JclStrings, controls
  {$IFDEF WITH_INDY}
    , gdccClient_unit
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  Identifiers: array[#0..#255] of ByteBool;
  //Хранит значения каждого символа для вычисления
  //хэш значения
  mHashTable: array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpCase(I);
    Case I in['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else
      mHashTable[I] := 0;
    end;
  end;
end;

const
//  cBreakPoint = 'if Debugger.BreakPoint(%d, %d, %d) Then Debugger.ProcEnd: Exit %s End If';
  cBreakPoint = 'if Debugger.BreakPoint(%d, %d, %d) Then Debugger.ProcEnd: On Error Goto 0: call Exception.Raise("Exception", "Выполнение прервано пользователем"): Exit %s End If';
  cProcBegin = 'Call Debugger.ProcBegin(%d, "%s")';
  cSetVariable = 'Call Debugger.SetVariable(%s, %s)';
  cSetArgument = 'Call Debugger.SetArgument(%s, %s)';
  cProcEnd = 'Debugger.ProcEnd: ';
  cBeginTime = 'Call Debugger.BeginTime(%d, "%s")';
  cEndTime = 'Call Debugger.EndTime(%d)';

{ TDebugger }


destructor TDebugger.Destroy;
begin
  FreeAndNil(FDebugVars);
  FreeAndNil(FCallNames);
  FreeAndNil(FEnabledList);
  FreeAndNil(FDebugLines);
  FreeAndNil(FExecuteDebugLines);
  FreeAndNil(FParser);
  FreeAndNil(FScriptFunctionList);
  FreeAndNil(FFinallyVarList);

  FreeAndNil(FRuntimeList);
  FreeAndNil(FResultRuntimeList);
  if Assigned(FRuntimeStream) then
    FreeAndNil(FRuntimeStream);

  FParser1.Free;

  if BreakPointList <> nil then
    BreakPointList.Free;

  inherited Destroy;
end;

function TDebugger.CanGotoCursor(ALine: integer): boolean;
begin
  Result := (fDebuggerState <> dsRunning) and IsExecutableLine(ALine);
end;

function TDebugger.CanPause: boolean;
begin
  Result := fDebuggerState = dsRunning;
end;

function TDebugger.CanRun: boolean;
begin
  Result := fDebuggerState <> dsRunning;
end;

function TDebugger.CanStep: boolean;
begin
  Result := fDebuggerState <> dsRunning;
end;

function TDebugger.CanStop: boolean;
begin
  Result := fDebuggerState <> dsStopped;
end;

function TDebugger.CurrentLineIsBreakpoint: boolean;
begin
  Result := (CurrentLine = fLineToStop)
    or (IsBreakpointLine(CurrentLine));
end;

procedure TDebugger.DoOnBreakpointChanged(ALine: integer);
begin
  if Assigned(fOnBreakpointChange) then
    fOnBreakpointChange(Self, ALine);
end;

procedure TDebugger.DoCurrentLineChanged;
begin
  if Assigned(fOnCurrentLineChange) then
    fOnCurrentLineChange(Self);
end;

procedure TDebugger.DoStateChange;
var
  WindowList: Pointer;
  I: Integer;
  LinkFormHandle: HWND;
begin
  if fDebuggerState <> fWantedState then
  begin
    if fWantedState in [dsStopped{, dsReset}] then
      DoStopAndReset;
    if Assigned(fOnStateChange) then
      fOnStateChange(Self, fDebuggerState, fWantedState);
    fDebuggerState := fWantedState;
    if fDebuggerState = dsStepOver then
      FStepOverCount := 0;
    if Assigned(FOnStateChanged) then
      FOnStateChanged(Self);
    if fWantedState <> dsRunning then
      fLineToStop := -1;
    DoCurrentLineChanged;
    if fDebuggerState = dsPaused then
    begin
      //Отключаем все окна
      if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
      EventControl.PrepareSOEditorForModal;
      WindowList := DisableTaskWindows(EventControl.GetPropertyHanlde);
      LinkFormHandle := 0;
      try
        //ф. DisableTaskWindows делает недоступным и редактор хотя ей передается
        //хэндл редактора, чтбы она оставила его доступным. Поэтому
        //делаем редактор доступным ручками. Автоматом становятся
        //доступными и все док. формы
        //Делаем доступными все докируемые формы окна
        for I := 0 to Screen.FormCount - 1 do
        begin
          if ((Screen.Forms[I] is TDockableForm) and
            (Screen.Forms[I].HostDockSite = nil)) or
             (Screen.Forms[I] is TfrmClassesInspector)then
            EnableWindow(Screen.Forms[I].Handle, True);
//            SendMessage(Screen.Forms[I].Handle, CM_ACTIVATE, 0, 0);
        end;
        EnableWindow(EventControl.GetPropertyHanlde, True);

        if _DebugLinkList <> nil then
        begin
          for I := 0 to _DebugLinkList.Count - 1 do
          begin
            if (_DebugLinkList[I] as TCustomDebugLink).Form <> nil then
            begin
              if not IsWindowEnabled((_DebugLinkList[I] as TCustomDebugLink).Form.Handle) then
              begin
                EnableWindow((_DebugLinkList[I] as TCustomDebugLink).Form.Handle, True);
                LinkFormHandle := (_DebugLinkList[I] as TCustomDebugLink).Form.Handle;
              end;
            end;
          end;
        end;

        //Входим в цикл ожидания изменения статуса
        while not Application.Terminated and (fDebuggerState = dsPaused) do
        begin
          Application.HandleMessage;
        end;
      finally
      //Подключаем ранее отключенные окна
        if LinkFormHandle <> 0 then
          EnableWindow(LinkFormHandle, True);

        EnableTaskWindows(WindowList);
        //Если не решим пошагового выполнения, то возвращаем активное окно
        if (FLastActiveWindow <> 0) and (not (fDebuggerState in [dsStep, dsStepOver])) then
        begin
          for I := 0 to Screen.FormCount - 1 do
          begin
            if Screen.Forms[i].Handle = FLastActiveWindow then
            begin
              SetForegroundWindow(EventControl.GetPropertyHanlde);
              SetActiveWindow(FLastActiveWindow);
              Break;
            end;
          end;
          FLastActiveWindow := 0;
        end;
      end;
    end;
  end;
end;


procedure TDebugger.ClearAllBreakpoints;
begin
{  if fBreakpoints.Count > 0 then begin
    fBreakpoints.Clear;
    DoOnBreakpointChanged(-1);
  end;}
end;

function TDebugger.GetLineInfos(ALine: integer): TDebuggerLineInfos;
begin
{  Result := [];
  if (ALine >= 0) and (ALine < FDisplayDebugLines.Count) then
  begin
    Result := FDisplayDebugLines[ALine];
  end;}
end;

procedure TDebugger.GotoCursor(ALine: integer);
begin
  fLineToStop := ALine;
  Run;
end;

function TDebugger.HasBreakpoints: boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FExecuteDebugLines.Count - 1 do
  begin
    Result := dlBreakpointLine in FExecuteDebugLines.DebugLines[I];
    if Result then Break;
  end;
end;

function TDebugger.IsBreakpointLine(ALine: Integer): Boolean;
begin
  Result := (ALine > 0) and (FExecuteDebugLines.Count > ALine) and 
    (dlBreakpointLine in FExecuteDebugLines.DebugLines[ALine]);
end;

function TDebugger.IsExecutableLine(ALine: Integer): Boolean;
begin
  Result := (FExecuteDebugLines.Count > 0) and
    (dlExecutableLine in FExecuteDebugLines.DebugLines[ALine]);
end;

function TDebugger.IsRunning: WordBool;
begin
  Result := fDebuggerState = dsRunning;
end;

procedure TDebugger.Pause;
begin
//  if fDebuggerState in [dsRunning, dsStep, dsStepOver] then
  if not (fDebuggerState in [dsPaused]) then
  begin
    if IBLogin.Database.Connected then
    begin
      fWantedState := dsPaused;
      DoStateChange;
    end;  
  end;  
end;

procedure TDebugger.Run;
begin
  fWantedState := dsRunning;
  CurrentLine := - 1;
  DoStateChange;
  fLineToStop := -1;
end;

procedure TDebugger.Step;
begin
  if fDebuggerState <> dsStep then
  begin
    fWantedState := dsStep;
    CurrentLine := - 1;
    DoStateChange;
  end;
end;

procedure TDebugger.Stop;
begin
  fWantedState := dsStopped;
  DoStateChange;
end;

procedure TDebugger.SetErrorLine(Line: Integer);
begin
{  if (Line > -1) and (Line < FDisplayDebugLines.Count) then
    FDisplayDebugLines[Line] := FDisplayDebugLines[Line] + [dlErrorLine];}
end;

procedure TDebugger.Init(Count: Integer);
var
  I: Integer;
begin
  for I:= 0 to Count - 1 do
    if I < DebugLines.Count - 1 then
    begin
      if dlBreakpointLine in DebugLines[I] then
        DebugLines[I] := [dlBreakpointLine]
      else
        FDebugLines[I] := [];
    end else
      DebugLines.Add([]);
end;

procedure TDebugger.ClearErrorLine;
begin
end;

function  TDebugger.BreakPoint(Sfid: Integer; ProcId: Integer;
  Line: Integer): WordBool;
var
  Sf: TrpCustomFunction;
  B: Boolean;
  BreakPoint: TBreakPoint;
  E: string;
begin
  try
    //Если не установлен флаг использования отл. информации то выходим.
    //Данная ситуация возможна при отключени данного флага во время выполнения
    //какого нибудь макроса. Поэтому скрипт контрол еще не сброшен и
    //поэтому в него загружен скрипт подготовленный для отладки
    if not PropertySettings.DebugSet.UseDebugInfo then
    begin
      FExecuteScriptFunction := SfId;
      Exit;
    end;

    //Сохраняем строку как будущую строку вызова функции
    //используется в стеке вызовов
    if FCallNames.Count > 0 then
      FCallNames.Objects[FCallNames.Count - 1] := Pointer(Line);

    //Вызов дебагера когда он находится в режиме паузы возможен например
    //когда перекрыто событие OnPaint и происходит перерисовка окна.
    //Поэтому игнорируем данныцй вызов дебагера
    if not (fDebuggerState  in [dsReset, dsPaused]) and FEnabled then
    begin
      FInDebugger := True;

      BreakPoint := BreakPointList.BreakPoint(SFID, Line + 1);
      B := False;
      if BreakPoint <> nil then
      begin
        if BreakPoint.Enabled then
        begin
          if BreakPoint.Condition <> '' then
          begin
            E := Eval(BreakPoint.Condition, True);
            if (E <> 'True') and (E <> 'False') and (E <> 'Empty') then
            begin
              B := True;
              MessageBox(Application.Handle, 'Ошибка при вычислении условия точки остановки',
                MSG_ERROR, MB_OK or MB_TASKMODAL or MB_ICONERROR);
            end else
            begin
              if E = 'True' then
              begin
                B := BreakPoint.PassCount = BreakPoint.ValidPassCount;
                BreakPoint.IncPass;
              end;
            end;
          end else
          begin
            B := BreakPoint.PassCount = BreakPoint.ValidPassCount;
            BreakPoint.IncPass;
          end;
        end;
        if B then
          BreakPoint.Reset;
      end;

      //Здесь идет обработка команды StepOver.
      //Идея заключается в следующем: когда пользователь вызывает команду
      //StepOver FStepOverCount устанавливается в 0. В бегинпрок и эндпрок
      //происходит соответственное увеличение и уменьшение счетчика.
      //поэтому пока счетчик > 0 выходим
      if IsStepOver and (FStepOverCount > 0) and not (fWantedState = dsPaused) and
        not B then
        Exit;
      //В последующем коде проверяется загрузка нобходимой функции
      //и если нет то она загружается и при необходимости подготавливается
      if SFId <> FExecuteScriptFunction then
      begin
        if glbFunctionList <> nil then
        begin
          Sf := glbFunctionList.FindFunction(SFId);
          if Sf <> nil then
          begin
            try
              if not Sf.BreakPointsPrepared then
                PrepareExecuteScript(Sf)
              else
              begin
                FExecuteScriptFunction := Sf.FunctionKey;
                FExecuteScriptModule := Sf.Module;
                if Sf.BreakPoints.Size > 0 then
                begin
                  Sf.BreakPoints.Position := 0;
                  FExecuteDebugLines.CheckSize(Sf.Script.Count);
                  FExecuteDebugLines.ReadFromStream(Sf.BreakPoints);
                end;
              end;
            finally
              glbFunctionList.ReleaseFunction(Sf);
            end;
          end else
            Exit;
        end else
          Exit;
      end;
      //Проверяем является ли строка кторокой остановки
      if ((Line = fLineToStop) and (FStopFunctionId = SFID)) or
        B or (fDebuggerState in [dsStep, dsStepOver]) or
        (fWantedState = dsPaused) then
      begin
        //Если да то останавливаемся
        CurrentLine := Line;
//        FProcedureId := ProcId;
        if Assigned(EventControl) then
        begin
          try
            //Отключаем дебаггер
            FEnabled := False;
            // Запоминаем последние активное окно
            if GetActiveWindow <> EventControl.GetPropertyHanlde then
              FLastActiveWindow := GetActiveWindow;
            //Отключаем очистку списка ошибок
            EventControl.DebugScriptFunction(SFID, FExecuteScriptModule,
              Line);
          finally
            //подключаем дебаггер
            FEnabled := True;
          end;
        end;
        //Устанавливаем режим паузы
        Pause;
      end;
    end;
  finally
    //При fDebuggerState = dsReset необходимо вернуть тру чтобы
    //код скрипта начал выход из тела скритта
    Result := fDebuggerState = dsReset;
  end;
end;

procedure TDebugger.SetFunctionRun(const Value: Boolean);
begin
  FFunctionRun := Value;
  FExecuteScriptFunction := 0;
  FCallLine := 0;
  BreakPointList.Reset;
end;

function TDebugger.GetFunctionRun: Boolean;
begin
  Result := FFunctionRun;
end;

procedure TDebugger.DoStopAndReset;
begin
  CurrentLine := -1;
  FDebugVars.Clear;
  FCallNames.Clear;
  FScriptFunctionList.Clear;
  FFinallyVarList.Clear;

  FCurrentKeyIndex := -1;
end;

function TDebugger.GetLastScriptFunction: Integer;
begin
  if FScriptFunctionList.Count > 0 then
//    Result := FLastScriptFunction;
    Result := Integer(FScriptFunctionList[FScriptFunctionList.Count - 1])
  else
    Result := 0;
end;

procedure TDebugger.LightPrepareScript(Sf: TrpCustomFunction);
begin
  if Assigned(Sf) and not Sf.BreakPointsPrepared then
  begin
    FParser.LightPrepareScript(Sf);
    Sf.BreakPointsPrepared := True;
  end;
end;

procedure TDebugger.ClearVars;
begin
  FDebugVars.Clear;
end;

procedure TDebugger.ToggleBreakpoint(ALine: Integer; DL: TDebugLines);
begin
  Dl.Checksize(ALine + 1);
  if  dlBreakpointLine in DL.DebugLines[ALine] then
    DL.DebugLines[ALine] := DL.DebugLines[ALine] - [dlBreakpointLine]
  else
    DL.DebugLines[ALine] := DL.DebugLines[ALine] + [dlBreakpointLine];
end;

procedure TDebugger.Init(Count: Integer; DL: TDebugLines);
var
  I: Integer;
begin
  for I := 0 to DL.Count - 1 do
    if I < DL.Count - 1 then
    begin
      if dlBreakpointLine in DL[I] then
        DL[I] := [dlBreakpointLine]
      else
        DL[I] := [];
    end else
      DL.Add([]);
end;

function TDebugger.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

procedure TDebugger.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TDebugger.SetErrorLine(Line: Integer; DL: TDebugLines);
begin
  if (Line > -1) and (Line < DL.Count) then
    DL[Line] := DL[Line] + [dlErrorLine];
end;

procedure TDebugger.SetArgument(const VarName: WideString;
  Value: OleVariant);
begin
  if FEnabled then
    FDebugVars.SetVariable(VarName, Value, True);
end;

procedure TDebugger.GetCallStack(const S: TStrings; out IdList: TList);
var
  I, J: Integer;
  C, A: String;
  V: Variant;
  P: TDebugProcVars;
begin
  S.Clear;
  for I := 0 to FCallNames.Count - 1 do
  begin
    //Имя функции
    C := FCallNames[I];
    A := '';
    P := FDebugVars.Procs[I];

    for J := 0 to P.Count - 1 do
    begin
      if P.DebugVars[J].ItIsArgument then
      begin
        //Значения аргументов
        V := P.DebugVars[J].Value;
        if VarIsArray(V) then
        begin
          V := VarArrayToStr(V);
        end else
        case VarType(V) of
          varDispatch: V := VarDispatchToStr(V);
          varArray: V := VarArrayToStr(V);
          varEmpty: V := VarEmptyToStr(V);
          varNull: V := VarNullToStr(V);
          varString, varOleStr, varStrArg: V := '"' + V + '"';
          varBoolean: V := VarBooleanToStr(V);
        end;
        A := A + ', ' + VarToStr(V);
      end;
    end;
    if A <> '' then
    begin
      Delete(A, 1, 2);
      A := '(' + A + ')';
      C := C + A;
    end;
    S.AddObject(C, FCallNames.Objects[I]);
  end;
  IdList := FScriptFunctionList;
end;

procedure TDebugger.BeginTime(FunctionKey: Integer;
  var FunctionName: WideString);
var
  LRuntimeRec: TRuntimeRec;
begin
  try
    LRuntimeRec.FunctionName := FunctionName;
    LRuntimeRec.FunctionKey := FunctionKey;
    LRuntimeRec.RuntimeTicks := GetTickCount;
    LRuntimeRec.BeginTime := Now;
    {$IFDEF WITH_INDY}
    LRuntimeRec.PerfCounter := gdccClient.StartPerfCounter('vbs', FunctionName);
    {$ELSE}
    LRuntimeRec.PerfCounter := -1;
    {$ENDIF}
    FRuntimeList.Add(LRuntimeRec);
  except
    {$IFDEF DEBUG}
    MessageBox(0, 'X', 'X', MB_OK);
    {$ENDIF}
  end;
end;

procedure TDebugger.EndTime(FunctionKey: Integer);
var
  LRuntimeRec: TRuntimeRec;
begin
  if FRuntimeList.LastRec.FunctionKey = FunctionKey then
  begin
    LRuntimeRec := FRuntimeList.LastRec;
    LRuntimeRec.RuntimeTicks := GetTickCount - FRuntimeList.LastRec.RuntimeTicks;
    {$IFDEF WITH_INDY}
    gdccClient.StopPerfCounter(LRuntimeRec.PerfCounter);
    LRuntimeRec.PerfCounter := -1;
    {$ENDIF}
    FResultRuntimeList.Add(LRuntimeRec);
    if Assigned(FOnEndScript) then
      FOnEndScript(Self, LRuntimeRec);
    try
      SaveScriptRuntime(LRuntimeRec);
    finally
      FRuntimeList.DeleteLast;
    end;
  end else
    FRuntimeList.Clear;
end;

procedure TDebugger.SetOnEndScript(const Value: TEndScriptEvent);
begin
  FOnEndScript := Value;
end;

procedure TDebugger.SaveScriptRuntime(const RuntimeRec: TRuntimeRec);
var
  Str: String;
begin
  if CheckRunTimeFile then
  begin
    Str := Format(sfRunTimeSciptMsg,
      [RuntimeRec.FunctionKey, RuntimeRec.RuntimeTicks / 1000, RuntimeRec.FunctionName]);
    FRuntimeStream.WriteBuffer(Str[1], Length(Str));
    FRuntimeStream.WriteBuffer(#13#10, 2);
  end;
end;

function TDebugger.CheckRunTimeFile: Boolean;
var
  Str: String;
begin
  Result := Assigned(FRuntimeStream);
  if PropertySettings.DebugSet.RuntimeSave and (not Result) and FCanSaveRunTime then
  begin
    // если есть файл с таким именем, то пытаемся его удалить
    if FileExists(ExtractFilePath(Application.ExeName) + 'ScriptRuntime.log') then
    try
      DeleteFile(ExtractFilePath(Application.ExeName) + 'ScriptRuntime.log')
    except
    end;

    try
      FRuntimeStream := TFileStream.Create(ExtractFilePath(Application.ExeName) + 'ScriptRuntime.log',
        fmCreate or fmShareExclusive);
    except
      FCanSaveRunTime := False;
      FRuntimeStream := nil;
    end;

    Str := 'База данных: ' + IBLogin.DatabaseName + #13#10 +
      'Имя пользователя: ' + IBLogin.UserName + #13#10 +
      'Дата и время запуска: ' + DateTimeToStr(Now) + #13#10 +
      '-----------------------------------------------'#13#10;
    if Assigned(FRuntimeStream) then
    begin
      FRuntimeStream.WriteBuffer(Str[1], Length(Str));
      Result := True;
      FCanSaveRunTime := True;
    end;
  end;
end;

function TDebugger.GetResultRuntimeList: TRuntimeList;
begin
  Result := FResultRuntimeList;
end;

function TDebugger.GetOnEndScript: TEndScriptEvent;
begin
  Result := FOnEndScript;
end;

function TDebugger.VaribleExists(Name: WideString): Boolean;
var
  I: Integer;
  P: TDebugProcVars;
begin

  Result := False;
  if FDebugVars.Count > 0 then
  begin
    P := FDebugVars.Procs[ FDebugVars.Count - 1];
    I := P.IndexOfVariable(Name);
    Result := I > - 1;

    if Result and (VarType(P.DebugVars[I].Value) = varDispatch) then
      Result := IDispatch(P.DebugVars[I].Value) <> nil;
  end;
end;

procedure TDebugger.SetOnStateChanged(const Value: TnotifyEvent);
begin
  FOnStateChanged := Value;
end;

function TDebugger.GetOnStateChanged: TnotifyEvent;
begin
  Result := FOnStateChanged;
end;

procedure TDebugger.DecKeyIndex;
begin
  if (FFinallyVarList.Count > FCurrentKeyIndex) and (FCurrentKeyIndex > -1) then
    FFinallyVarList.ClearValue(FCurrentKeyIndex);
  if (FScriptFunctionList.Count > FCurrentKeyIndex) and (FCurrentKeyIndex > -1) then
    FScriptFunctionList.Delete(FCurrentKeyIndex);
  Dec(FCurrentKeyIndex);
end;

function TDebugger.GetCurrentKeyIndex: Integer;
begin
  Result := FCurrentKeyIndex;
end;

function TDebugger.GetLastFinallyParams: TFinallyRec;
begin
  Result := FFinallyVarList.GetValue(FFinallyVarList.Count - 1);
end;

function TDebugger.GetFinallyParams(const Index: Integer): TFinallyRec;
begin
  Result := FFinallyVarList.Value[Index];
  FFinallyVarList.ClearValue(Index);
end;

procedure TDebugger.ClearLastFinallyParams;
begin
  FFinallyVarList.ClearValue(FFinallyVarList.Count - 1);
end;

procedure TDebugger.ClearDebugVars(Index: Integer);
begin
  if PropertySettings.DebugSet.UseDebugInfo then
  begin
    if Index < FDebugVars.Count then
    begin
      FDebugVars.Procs[Index].Clear;
      if FCallNames.Count > Index then
        FCallNames.Delete(Index);
    end;
  end;
end;

function TDebugger.GetCurrentFinallyParams: TFinallyRec;
begin
  Result := FFinallyVarList.Value[FCurrentKeyIndex];
  FFinallyVarList.Delete(FCurrentKeyIndex);
end;

function TDebugger.GetCurrentKey: Integer;
begin
  if FCurrentKeyIndex > -1 then
    Result := Integer(FScriptFunctionList[FCurrentKeyIndex])
  else
    Result := 0;
end;

function TDebugger.CurrentState: TDebuggerState;
begin
  Result := fDebuggerState;
end;

procedure TDebugger.SetLastFinallyParams(const AParamArray: OleVariant;
  const AFinallyScript: WideString; const ALine: Integer);
begin
  FFinallyVarList.SetValue(FFinallyVarList.Count - 1, AParamArray, AFinallyScript, ALine);
end;

{ TVBDebugParser }
procedure TVBDebugParser.DoAfterStatament;
begin
  inherited;

  if FExecutable then
  begin
    if FInFunction then
      FScript[FCurrentLine] := Format(StringOfChar(' ', FParagraph) +
        cBreakPoint, [FId, FProcedureId, FCurrentLine, FSubFunction]) + ': ' +
        FScript[FCurrentLine];
    if FDesignator <> '' then
    begin
      FScript[FCurrentLine + FLineAdd - 1] := FScript[FCurrentLine + FLineAdd - 1] +
        ': ' + Format(cSetVariable, ['"' + FDesignator + '"', FDesignator]);
      FDesignator := '';
    end;
  end;
end;

procedure TVBDebugParser.DoBeforeStatament;
begin
  inherited;
  FExecutable := False;
end;

procedure TVBDebugParser.DoExit(P: Integer);
var
  Str: string;
begin
  Str := FStr;
  if PropertySettings.DebugSet.RuntimeSave then
    Insert(' ' + Format(cEndTime, [FId]) + ': ' + cProcEnd + ': ', Str, P)
  else
    Insert(' ' + cProcEnd + ': ', Str, P);
  FScript[FCurrentLine] := Str;
end;

procedure TVBDebugParser.DoProcBegin;
var
  I: Integer;
  S: String;
begin
  if FInClass then
    S := FClassName + '.' + FFunctionName
  else
    S := FFunctionName;

  if PropertySettings.DebugSet.RuntimeSave then
  begin
    FScript[FCurrentLine + FLineAdd - 1] := FScript[FCurrentLine + FLineAdd - 1] +
      ': ' + Format(cProcBegin, [FId, S]) +
      ': '+ Format(cBeginTime, [FId, S]);
  end else
    FScript[FCurrentLine + FLineAdd - 1] := FScript[FCurrentLine + FLineAdd - 1] +
      ': ' + Format(cProcBegin, [FId, S]);
  //Добавляем Self-указатель на класс
  if FInClass then
    for I := 0 to FFieldsList.Count - 1 do
    begin
      FScript[FCurrentLine + FLineAdd - 1] := FScript[FCurrentLine + FLineAdd - 1] +
        ': ' + Format(cSetVariable, ['"' + FFieldsList[I] + '"', FFieldsList[I]]);
    end;
  //Добавляем аргументы
  for I := 0 to FArgumentList.Count - 1 do
    FScript[FCurrentLine + FLineAdd - 1] := FScript[FCurrentLine + FLineAdd - 1] +
      ': ' + Format(cSetArgument, ['"' + FArgumentList[I] + '"', FArgumentList[I]]);
end;

procedure TVBDebugParser.DoProcEnd;
begin
  if PropertySettings.DebugSet.RuntimeSave then
    FScript[FCurrentLine] := Format(cEndTime, [FId]) + ': ' +
      cProcEnd + ': ' + FScript[FCurrentLine]
  else
    FScript[FCurrentLine] := cProcEnd + ': ' + FScript[FCurrentLine];
end;

function TVBDebugParser.GetPrepareStr: String;
begin
  FScriptLine := FScriptLine + FScriptLineAdd;

  if FCurrentLine < FScript.Count then
  begin
    FLineAdd:= 1;
    Result := Trim(FScript[FCurrentLine]);
    //Пропускаем пустые строки
    while (Result = '') and (FCurrentLine < FScript.Count) do
    begin
      Inc(FCurrentLine, FLineAdd);
      Inc(FScriptLine);
      if FCurrentLine < FScript.Count then
        Result := Trim(FScript[FCurrentLine]);
    end;
    //Если строка состоит из нескольких то сшиваем их
    FScriptLineAdd := 1;
    while (Result <> '') and (Result[Length(Result)] = '_') and
      (FCurrentLine + FLineAdd < FScript.Count) do
    begin
      Delete(Result, Length(Result), 1);
      Result := Result + ' ' + Trim(FScript[FCurrentLine + FLineAdd]);
      Inc(FLineAdd);
      Inc(FScriptLineAdd);
    end;
    Result := UpperCase(Result);
    FCursorPos := 1;
  end else
    Result := '';
end;

procedure TVBDebugParser.LightPrepareScript(const SF: TrpCustomFunction);
var
  CurrentWord: String;
  P: Integer;
  InsertStr: string;

  procedure FindEndLine;
  var
    B: Boolean;
  begin
    B := False;
    while (FCursorPos < Length(FStr)) and
      (not (FStr[FCursorPos] in [#10, #13, ':', ''''])) do
    begin
      if FStr[FCursorPos] = '"' then
        B := not B;
      if (FStr[FCursorPos] = '_') and
        not (FStr[FCursorPos - 1] in ['A'..'Z', 'a'..'z', '0'..'9']) and
        not (FStr[FCursorPos + 1] in ['A'..'Z', 'a'..'z', '0'..'9']) then
      begin
        repeat
          Inc(FCursorPos);
        until (FStr[FCursorPos] in [#10, #13]) or (FCursorPos >= Length(FStr));
        if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] <> '''') then
        begin
          if FStr[FCursorPos] = #13 then
            Inc(FCursorPos);
          if FStr[FCursorPos] = #10 then
            Inc(FCursorPos);
        end;
        Continue;
      end;
      Inc(FCursorPos);
      if (FStr[FCursorPos] in [':', '''']) and B then
         Inc(FCursorPos);
    end;
  end;

  procedure BP(const ScriptName: String);
  var
    InsertStr: string;
  begin
    if FCursorPos < Length(FStr) then
    begin
      InsertStr := ': ' + Format(cProcBegin, [FId, '']);
      if PropertySettings.DebugSet.RuntimeSave then
        InsertStr := InsertStr + ': '+ Format(cBeginTime, [FId, ScriptName]);

      FindEndLine;
      Insert(InsertStr, FStr, FCursorPos);
      FCursorPos := FCursorPos + Length(InsertStr);
    end;
  end;

  procedure StringProc;
  begin
    repeat
      if (FStr[FCursorPos] in [#10, #13]) or (FCursorPos >= Length(FStr)) then  break;

      inc(FCursorPos);
      if (FStr[FCursorPos] = #34) and (FStr[FCursorPos + 1] = #34) then inc(FCursorPos, 2);
    until FStr[FCursorPos] = #34;
    if FStr[FCursorPos] = #34 then inc(FCursorPos);
  end;

  procedure NextStmt;
{  var
    B: Boolean;}
  begin
//    B := False;
    while (not (FStr[FCursorPos] in [#10, #13, ':', ''''])) and (FCursorPos <= Length(FStr)) do
    begin
      if FStr[FCursorPos] = '"' then
      begin
        StringProc;
        Continue;
      end;
      if (FStr[FCursorPos] = '_') and
        not (FStr[FCursorPos - 1] in ['A'..'Z', 'a'..'z', '0'..'9']) and
        not (FStr[FCursorPos + 1] in ['A'..'Z', 'a'..'z', '0'..'9']) then
      begin
        repeat
          Inc(FCursorPos);
        until (FStr[FCursorPos] in [#10, #13]) and (FCursorPos <= Length(FStr));
        if not (FStr[FCursorPos] in [#0, '''']) then
        begin
          if FStr[FCursorPos] = #13 then
            Inc(FCursorPos);
          if FStr[FCursorPos] = #10 then
            Inc(FCursorPos);
        end;
        Continue;
      end;
      Inc(FCursorPos);
    end;
  end;


begin
  if not Assigned(Sf) then Exit;
  if not TestCorrect(Sf.Script.Text) then Exit;

  FScript.Assign(Sf.Script);
  RemoveComent;
  FStr := FScript.Text;
  Fid := Sf.FunctionKey;
  FCursorPos := 1;
  FFunctionName := '';
  try
    while (FCursorPos <= Length(FStr)) and (FCursorPos <> - 1) do
    begin
      TrimSpace;
      if FStr[FCursorPos] = ':' then
      begin
        Inc(FCursorPos);
        TrimSpace;
      end;
      if FStr[FCursorPos] = '"' then  StringProc;
      if FStr[FCursorPos] = '''' then
      begin
        Inc(FCursorPos);
        FindEndLine;
      end;

      CurrentWord := UpperCase(GetCurrentWord);
      if (CurrentWord = 'PUBLIC') or (CurrentWord = 'PRIVATE') then
      begin
        FCursorPos := NextWord;
        CurrentWord := UpperCase(GetCurrentWord);
        if CurrentWord = 'DEFAULT' then
        begin
          FCursorPos := NextWord;
          CurrentWord := UpperCase(GetCurrentWord);
        end;
        if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') then
        begin
          FCursorPos := NextWord;
          BP(GetCurrentWord);
          NextStmt;
        end;
      end else
      if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') then
      begin
        FCursorPos := NextWord;
        BP(GetCurrentWord);
        NextStmt;
      end else
      if CurrentWord = 'PROPERTY' then
      begin
        FCursorPos := NextWord;
        CurrentWord := UpperCase(GetCurrentWord);
        if (CurrentWord = 'GET') or (CurrentWord = 'LET') or
           (CurrentWord = 'SET') then
        begin
          FCursorPos := NextWord;
          BP(GetCurrentWord);
          NextStmt;
        end;
      end else
      if (CurrentWord = 'END') or (CurrentWord = 'EXIT') then
      begin
        P := FCursorPos;
        FCursorPos := NextWord;
        CurrentWord := UpperCase(GetCurrentWord);
        if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') or
          (CurrentWord = 'PROPERTY') then
        begin
          InsertStr := cProcEnd;
//          InsertStr := cProcEnd + ': ';
          if PropertySettings.DebugSet.RuntimeSave then
            InsertStr := InsertStr + Format(cEndTime, [FId]) + ': ';
          Insert(InsertStr, FStr, P);
          FCursorPos := FCursorPos + Length(InsertStr);
          NextStmt;
        end;
      end else
//        NextStmt;
      if CurrentWord <> '_' then
        FCursorPos := NextWord
      else begin
        Inc(FCursorPos);
        TrimSpace;
      end;
    end;
    Sf.Script.Text := FStr;
  except
  end;
end;

procedure TVBDebugParser.PrepareScript(const SF: TrpCustomFunction);
begin
  if not Assigned(Sf) then Exit;
  if not TestCorrect(Sf.Script.Text) then Exit;

  FScript.Assign(Sf.Script);
  RemoveComent;
  FInFunction := False;
  FScriptName := SF.Name;
  FAtLine := - 1;
  FScriptLine := 0;
  FScriptLineAdd := 0;
  FCurrentLine := 0;
  FId := Sf.FunctionKey;
  FProcedureId := 0;
  FInClass := False;

  try
    while FCurrentLine < FScript.Count do
    begin
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
      Statament;
    end;
    SF.Script.Assign(FScript);
  except
  end;
end;

procedure TVBDebugParser.RemoveComent;
var
  I, J: Integer;
  L: Integer;
  S: Pointer;
  IsString: Boolean;
begin
  for I := 0 to FScript.Count - 1 do
  begin
    L := Length(FScript[I]);
    IsString := False;
    for J := 1 to L do
    begin
      if FScript[I][J] = '"' then
        IsString := not IsString
      else
      if FScript[I][J] = '''' then
      begin
        if IsString then
          Continue
        else
        begin
          if Pos('''#include', FScript[I]) <> 1 then
          begin
            S := @FScript[I][J];
            FillChar(S^, L - J + 1, Byte(' '));
            Break;
          end;
        end;
      end
    end;
  end;
end;

procedure TVBDebugParser.SetExecutable;
begin
  if Assigned(Debugger) then
    Debugger.DebugLines[FScriptLine] :=
      Debugger.DebugLines[FScriptLine] + [dlExecutableLine];

  FExecutable := True;
end;

procedure TDebugger.PrepareScript(Sf: TrpCustomFunction);
var
  I, K, J: Integer;
  tmpStr, ExcParamStr: String;

const
  cFinallyObjectDecl = '  call FinallyObject.Declaration(Array(%s), "%s", %d)';
  cDontFindExceptFunction = ' call Exception.Raise("Exception", "Не обнаружена функция обработки исключения после инструкции Except.")';
  cExceptFunctionWithoutParams = ' call Exception.Raise("Exception", "Функция инструкции Except должна иметь параметры.")';
begin
  // Формирование строк обработки исключения инструкции Except
  I := 0;
  while I < Sf.Script.Count do
  begin
    tmpStr := Trim(Sf.Script[I]);
    if
      (AnsiUpperCase(Copy(tmpStr, Length(tmpStr) - Length('EXCEPT') + 1, Length(tmpStr))) = 'EXCEPT') and
      (AnsiUpperCase(Copy(tmpStr, 1, 3)) = 'END') and
      (Length(Trim(Copy(tmpStr, 4, Length(tmpStr) - Length('EXCEPT') - 4 + 1))) = 0)
    then
      Sf.Script[I] := '  FinallyObject.Clear'
    else begin
      ExcParamStr := '';

      if (Length(tmpStr) > 5) and
        (AnsiUpperCase(tmpStr[1]) = 'E') and
        (AnsiUpperCase(tmpStr[2]) = 'X') and
        (AnsiUpperCase(tmpStr[3]) = 'C') and
        (AnsiUpperCase(tmpStr[4]) = 'E') and
        (AnsiUpperCase(tmpStr[5]) = 'P') and
        (AnsiUpperCase(tmpStr[6]) = 'T')
      then
      begin
//        (AnsiUpperCase(tmpStr[6]) = 'T') and
//        (AnsiUpperCase(tmpStr[7]) = ' ')
//      then begin
        if (Length(tmpStr) > 6) and (AnsiUpperCase(tmpStr[7]) = ' ') then
        begin
          K := Pos('(',tmpStr);
          J := StrLastPos(')', tmpStr);
          ExcParamStr := Trim(Copy(tmpStr, K + 1, J - K - 1));
          if Length(ExcParamStr) > 0 then
          begin
            // Выделяем вызов функции
            tmpStr := Copy(tmpStr, 8, Length(tmpStr));
            // Выделяем наименование функции
            tmpStr := Trim(Copy(tmpStr, 1, Pos('(', tmpStr) - 1));
            if Length(tmpStr) = 0 then
              Sf.Script[I] := cDontFindExceptFunction
            else
              Sf.Script[I] := Format(cFinallyObjectDecl, [ExcParamStr, tmpStr, I]);
          end else
            Sf.Script[I] := cExceptFunctionWithoutParams;
        end else
          if Length(tmpStr) = 6 then Sf.Script[I] := cDontFindExceptFunction;
      end;
    end;
    Inc(I);
  end;

  if Assigned(IbLogin) and IBLogin.IsUserAdmin and
    PropertySettings.DebugSet.UseDebugInfo then
  begin
    if Assigned(Sf) then
    begin
      FDebugLines.Clear;
      FDebugLines.CheckSize(Sf.Script.Count);

      if Sf.BreakPointsSize > 0 then
      begin
        Sf.BreakPoints.Position := 0;
        if SF.BreakPointsPrepared then
          FDebugLines.ReadFromStream(Sf.BreakPoints)
        else
          FDebugLines.ReadBPFromStream(Sf.BreakPoints);
      end;

      if not Sf.BreakPointsPrepared then
      begin
        FParser1.Script := Sf.Script.Text;
        FParser1.Id := Sf.FunctionKey;
        FParser1.PrepareScript;
        Sf.Script.Text := FParser1.Script;
        SF.BreakPoints.Size := 0;
        FDebugLines.SaveToStream(Sf.BreakPoints);
        SF.BreakPointsPrepared := True;
      end;
    end;
  end else
    LightPrepareScript(Sf);
end;


procedure TDebugger.Initialize;
begin
  if not Assigned(Debugger) then
  begin
    inherited;

    FLastActiveWindow := 0;
    FCurrentKeyIndex := -1;
    FDebugVars := TDebugVars.Create;
    FCallNames := TStringList.Create;
    FEnabledList := TList.Create;
    FDebugLines := TDebugLines.Create;
    FExecuteDebugLines := TDebugLines.Create;
    FParser := TVBDebugParser.Create(nil);
    FParser1 := TDebuggerParser.Create;
    FParser1.Debugger := Self;
    FScriptFunctionList := TList.Create;
    FFinallyVarList := TFinallyVarList.Create;
    fDebuggerState := dsStopped;
    FInDebugger := False;
    FEnabled := True;
    FRuntimeList := TRuntimeList.Create;
    FResultRuntimeList := TRuntimeList.Create;
    FCanSaveRunTime := True;

    Debugger := Self;
    if BreakPointList = nil then
      BreakPointList := TBreakPointList.Create;
  end else
    raise Exception.Create('Должен быть один экземпляр данного класса');
end;

procedure TDebugger.RemoveBreakPoints(SF: TrpCustomFunction);
var
  I: Integer;
  DP, P: Integer;
  Str: String;
begin
  if Assigned(Sf) then
  begin
    for I := Sf.Script.Count - 1 downto 0 do
    begin
      DP := Pos('Debugger.BreakPoint', Sf.Script[I]);
      P := Pos(':', Sf.Script[I]);
      if (DP > 0) and (P > DP) then
      begin
        Str := Sf.Script[I];
        Delete(Str, 1, P);
        Sf.Script[I] := Str;
      end
    end;
    Sf.BreakPointsPrepared := False;
  end;
end;

function TDebugger.Get_Self: TObject;
begin
  Result := Self;
end;

function TDebugger.GetCurrentLine: integer;
begin
  Result := FExecuteDebugLines.CurrentLine;
end;

function TDebugger.GetDebugLines: TDebugLines;
begin
  Result := FDebugLines;
end;

function TDebugger.GetOnBreakpointChange: TBreakpointChangeEvent;
begin
  Result := FOnBreakPointChange;
end;

function TDebugger.GetOnCurrentLineChange: TNotifyEvent;
begin
  Result := FOnCurrentLineChange;
end;

function TDebugger.GetOnStateChange: TDebuggerStateChangeEvent;
begin
  Result := FOnStateChange;
end;

function TDebugger.GetOnYield: TNotifyEvent;
begin
  Result := FOnYield;
end;

function TDebugger.GetParser: TVBDebugParser;
begin
  Result := FParser;
end;

procedure TDebugger.SetOnBreakpointChange(
  const Value: TBreakpointChangeEvent);
begin
  FOnBreakPointChange := Value;
end;

procedure TDebugger.SetOnCurrentLineChange(const Value: TNotifyEvent);
begin
  FOnCurrentLineChange := Value;
end;

procedure TDebugger.SetOnStateChange(
  const Value: TDebuggerStateChangeEvent);
begin
  FOnStateChange := Value;
end;

procedure TDebugger.SetOnYield(const Value: TNotifyEvent);
begin
  FOnYield := Value;
end;

function TDebugger.IsStoped: WordBool;
begin
  Result := fDebuggerState = dsStopped;
end;

function TDebugger.IsPaused: WordBool;
begin
  Result := fDebuggerState = dsPaused;
end;

procedure TDebugger.SetCurrentLine(const Value: Integer);
begin
  FExecuteDebugLines.CurrentLine := Value;
  FDebugLines.CurrentLine := Value;
end;

procedure TDebugger.GotoToLine(SFID, Line: Integer);
begin
  fWantedState := dsRunning;
  CurrentLine := - 1;
  DoStateChange;
  FStopFunctionId := SFID;
  FLineToStop := Line;
end;

procedure TDebugger.StepOver;
begin
  if fDebuggerState <> dsStepOver then
  begin
    fWantedState := dsStepOver;
    CurrentLine := - 1;
    DoStateChange;
//    FStopFunctionId := FExecuteScriptFunction;
//    FStopProcId := FProcedureId;
  end;
end;

function TDebugger.IsStepOver: WordBool;
begin
  Result := fDebuggerState = dsStepOver;
end;

function TDebugger.IsStep: WordBool;
begin
  Result := fDebuggerState = dsStep;
end;

procedure TDebugger.PrepareExecuteScript(Sf: TrpCustomFunction);
begin
  PrepareScript(Sf);
  FExecuteScriptFunction{.FunctionKey} := Sf.FunctionKey;
//  FExecuteScriptFunction.BreakPointsPrepared := Sf.BreakPointsPrepared;
  FExecuteScriptModule := Sf.Module;
  FExecuteDebugLines.Assign(FDebugLines);
end;

procedure TDebugger.InitExecute(Count: Integer);
var
  I: Integer;
begin
  for I:= 0 to Count - 1 do
    if I < FExecuteDebugLines.Count - 1 then
    begin
      if dlBreakpointLine in FExecuteDebugLines[I] then
        FExecuteDebugLines[I] := [dlBreakpointLine]
      else
        FExecuteDebugLines[I] := [];
    end else
      FExecuteDebugLines.Add([]);
//  Init(Count);    
end;

function TDebugger.GetExecuteDebugLines: TDebugLines;
begin
  Result := FExecuteDebugLines;
end;

function TDebugger.GetExecuteScriptFunction: Integer;
begin
  Result := FExecuteScriptFunction;
end;

procedure TDebugger.ToggleExecuteBreakpoint(ALine: Integer);
begin
  ToggleBreakPoint(ALine, FExecuteDebugLines);
  DoOnBreakpointChanged(ALine);
end;

procedure TDebugger.SetInDebugger(const Value: Boolean);
begin
  FInDebugger := Value;
end;

function TDebugger.GetInDebugger: Boolean;
begin
  Result := FInDebugger;
end;

procedure TDebugger.Reset;
begin
//  if fDebuggerState <> dsPaused then Exit;
  if FDebuggerState = dsReset then Exit;

  fWantedState := dsReset;
  CurrentLine := - 1;
  DoStateChange;
end;

procedure TDebugger.WantPause;
begin
  fWantedState := dsPaused;
end;

function TDebugger.IsReseted: WordBool;
begin
  Result := fDebuggerState = dsReset;
end;

procedure TDebugger.ProcEnd;
begin
  if FEnabled then
  begin
    if PropertySettings.DebugSet.UseDebugInfo then
    begin
      FDebugVars.ProcEnd;
      if FCallNames.Count > 0 then
        FCallNames.Delete(FCallNames.Count - 1);
    end;
    FCurrentKeyIndex := FScriptFunctionList.Count - 1;
    if FCurrentKeyIndex > -1 then
    begin
      FScriptFunctionList.Delete(FCurrentKeyIndex);
      FFinallyVarList.Delete(FCurrentKeyIndex);

      Dec(FCurrentKeyIndex) {:= FScriptFunctionList.Count - 1};
    end;
{    if FCurrentKeyIndex > - 1 then
      FLastScriptFunction := Integer(FScriptFunctionList[FCurrentKeyIndex])
    else
      FLastScriptFunction := 0;}
    FInDebugger := False;
    if (fDebuggerState = dsStepOver) and (FStepOverCount > 0) then
      Dec(FStepOverCount);
  end;
end;

procedure TDebugger.ProcBegin(sfid: Integer; const FunctionName: WideString);
begin
  if FEnabled then
  begin
    if PropertySettings.DebugSet.UseDebugInfo then
    begin
      //Устанавливаем метку начала функции в списках переменных
      FDebugVars.ProcBegin;
      //сохраняем имя функции для стека вызовов
      FCallNames.Add(FunctionName);
      if fDebuggerState = dsStepOver then
        Inc(FStepOverCount);
    end;
    //сохраняем ид функции для правильной обработки ошибок
    FScriptFunctionList.Add(Pointer(SFID));
    FFinallyVarList.Add;
//    FLastScriptFunction := SFID;
    FCurrentKeyIndex := FScriptFunctionList.Count - 1;
  end;
end;

procedure TDebugger.SetVariable(const VarName: WideString;
  Value: OleVariant);
begin
  if FEnabled then
    FDebugVars.SetVariable(VarName, Value, False);
end;

function TDebugger.GetVariable(const VarName: WideString): OleVariant; safecall;
begin
  Result := FDebugVars.GetVariable(VarName);
end;

function TDebugger.Eval(Str: String; Extend: Boolean = True): Variant;
var
  Designator: string;
  Language: String;
  I: Integer;
begin
  Result := Unassigned;
  if (Str = '') or not Assigned(ScriptFactory) then
    Exit;

  Language := 'VBScript';


  if Extend then
  begin
    FParser1.Script := Str;
    Result := FParser1.Eval;
  end else
  begin
    Str := UpperCase(Str);
    Designator := '';
    for I := 1 to Length(Str) do
    begin
      if Pos(Str[I], '([.') = 0 then
        Designator := Designator + Str[I]
      else
        Break;
    end;

    Result := FDebugVars.GetVariable(Designator);
    if (VarType(Result) = varDispatch) and (IDispatch(Result) = nil) then
      Result := Unassigned;
  end;
  
  if Extend or not VarIsEmpty(Result)  then
  begin
    if VarIsArray(Result) then
    begin
      Result := VarArrayToStr(Result);
    end else
      case VarType(Result) of
        varDispatch:
          Result := VarDispatchToStr(Result);
        varArray: Result := VarArrayToStr(Result);
        varEmpty: Result := VarEmptyToStr(Result);
        varNull: Result := VarNullToStr(Result);
        varString, varOleStr, varStrArg: Result := '"' +
          Result + '"';
        varBoolean: Result := VarBooleanToStr(Result);
      end;
  end;
end;

function TVBDebugParser.TestCorrect(Script: string): Boolean;
var
  SC: TScriptControl;
begin
  SC := TScriptControl.Create(nil);
  try
    SC.Language := 'VBScript';
    SC.TimeOut := -1;
    try
      SC.AddCode(Script);
      Result := True;
    except
      Result := False;
    end;
  finally
    SC.Free;
  end;
end;

{ TDebuggerParser }

function TDebuggerParser.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
  SimpleStmtProc;
end;

procedure TDebuggerParser.ApostropheProc;
begin
  fTokenID := tkComment;
  Include(FParserStates, psApostrophe);
  Exclude(FParserStates, psStatament);
  DoAfterStatament;
end;

constructor TDebuggerParser.Create;
begin
  InitIdent;
  MakeMethodTables;
  FParamList := TStringList.Create;
  FFieldsList := TStringList.Create;
  FSC := TScriptControl.Create(nil);
  FSC.Language := 'VBScript';
  FSC.TimeOut := -1;
  FLocalVarList := TStringList.Create;
end;

procedure TDebuggerParser.CRProc;
begin
  fTokenID := tkSpace;
  DoAfterStatament;
  inc(FRun);
  if FScript[FRun] = #10 then inc(FRun);
  Inc(FAddLine);
  FParserStates := [];
end;

procedure TDebuggerParser.DateProc;
begin
  fTokenID := tkString;
  repeat
    case FScript[FRun] of
      #0, #10, #13: break;
    end;
    inc(FRun);
  until FScript[FRun] = '#';
  if FScript[FRun] <> #0 then inc(FRun);
end;

procedure TDebuggerParser.DesignatorProc;
begin
  if psSetVar in FParserStates then
  begin
    FVarName := CurrentWord;
    Exclude(FParserStates, psSetVar);
    if FLocalVarList.IndexOf(FVarName) > - 1 then
      Include(FParserStates, psNoChangeVarName);
  end;
  Inc(FRun, FStringLen);
  TrimSpace;
  if FScript[FRun] = '.' then
  begin
    Inc(FRun);
    if not (psNoChangeVarName in FParserStates) then
      FVarName := '';
    CurrentWord;
    DesignatorProc;
  end
  else if FScript[FRun] = '(' then
  begin
    if not (psNoChangeVarName in FParserStates) then
      FVarName := '';
    ListExprList;
    if FScript[FRun] = '.' then
    begin
      Inc(FRun);
      CurrentWord;
      DesignatorProc;
    end
  end;
  TrimSpace;
end;

procedure TDebuggerParser.ExpressionProc;
  function IsRelOp: boolean;
  var
    S: string;
  begin
    Result := False;
    if FScript[FRun] = '=' then
    begin
      Inc(FRun);
      Result := True;
    end else
    if FScript[FRun] = '>' then
    begin
      Inc(FRun);
      if FScript[FRun] = '=' then
        Inc(FRun);
      Result := True;
    end else
    if FScript[FRun] = '<' then
    begin
      Inc(FRun);
      if FScript[FRun] in ['=', '>'] then
        Inc(FRun);
      Result := True;
    end else
    begin
      S := UpperCase(CurrentWord);
      if (S = 'IS') or (S = 'EQV') or (S = 'IMP') then
      begin
        Inc(FRun, FStringLen);
        Result := True;
      end;
    end;
  end;
begin
  SimpleExpressionProc;
  if IsRelOp then
  begin
    TrimSpace;
    ExpressionProc;
  end;
end;

procedure TDebuggerParser.ExprListProc;
begin
  ExpressionProc;
  if FScript[FRun] = ',' then
  begin
    while FScript[FRun] = ',' do
    begin
      Inc(FRun);
      TrimSpace;
    end;
    ExprListProc;
  end;
  TrimSpace;
  Exclude(FParserStates, psExpression);
end;

procedure TDebuggerParser.FactorProc;
var
  BeginPos: Integer;
  Str: string;
  B: Boolean;
  L: Integer;
begin
  if FScript[FRun] = '(' then
  begin
    Inc(FRun);
    TrimSpace;
    ExpressionProc;
    TrimSpace;
    if FScript[FRun] = ')' then
      Inc(FRun);
  end else
  begin
    Include(FParserStates, psDesignator);
    if FEvaluate then
    begin
      BeginPos := FRun;
      Str := UpperCase(CurrentWord);
      B := (FDebugger <> nil) and (FDebugger.VaribleExists(Str));
      FProcTable[FScript[FRun]];

      if B then
      begin
        L := Length(Str);
        Delete(BeginPos, L);
        FRun := FRun - L;
        Str := Format(' Debugger.GetVariable("%s")',[Str]);
        Insert(Str, BeginPos);
        FRun := FRun + Length(Str);
      end;
    end else
      FProcTable[FScript[FRun]];
    Exclude(FParserStates, psDesignator);
  end;
  TrimSpace;
end;

function TDebuggerParser.Func102: TtkTokenKind;
begin
  if KeyComp('Function') then
  begin
     Result := tkKey;
    _DoFunction
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func105: TtkTokenKind;
begin
  if KeyComp('Randomize') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func133: TtkTokenKind;
begin
  if KeyComp('property') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psEnd in FParserStates then
    begin
      Exclude(FParserStates, psEnd);
      FInFunction := False;
      FExecutable := True;
      DoProcEnd;
      DoAfterStatament;
      FExecutable := False;
    end else
    begin
      Include(FParserStates, psProperty);
      FProcType := 'property';
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func15: TtkTokenKind;
begin
  if KeyComp('If') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if not (psEnd in FParserStates) then
    begin
      ExpressionProc;
      FExecutable := True;
    end else
    begin
      Exclude(FParserStates, psEnd);
      FExecutable := False;
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func17: TtkTokenKind;
begin
  if KeyComp('Each') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    if not (psExit in FParserStates) then
    begin
      if psFor in FParserStates then
        Exclude(FParserStates, psFor);
      Include(FParserStates, psForEach);
    end else
      Exclude(FParserStates, psExit);
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func19: TtkTokenKind;
begin
  if KeyComp('Do') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psExit in FParserStates then
      Exclude(FParserStates, psExit)
    else
      Include(FParserStates, psDo);
    FExecutable := True;
  end else
  if KeyComp('And') then
  begin
    Result := tkMulOp;
    Inc(FRun, FStringLen);
    TrimSpace;
    TermProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func23: TtkTokenKind;
begin
  if KeyComp('End') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    Include(FParserStates, psEnd);
  end else
  if KeyComp('In') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func26: TtkTokenKind;

  procedure VarNameList;
  var
    Str: String;
  begin
    Str := CurrentWord;
    if FLocalVarList.IndexOf(Str) = - 1 then
      FLocalVarList.Add(Str);

    Inc(FRun, FStringLen);
    TrimSpace;
    if FScript[FRun] = '(' then
    begin
      while FScript[FRun] <>')' do
        Inc(FRun);
      Inc(FRun);
      TrimSpace;
    end;
    if FScript[Frun] = ',' then
    begin
      Inc(FRun);
      TrimSpace;
      VarNameList;
    end;
  end;

begin
  if KeyComp('Dim') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    VarNameList;
    { TODO : Добавить разбор }
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func28: TtkTokenKind;
var
  S: string;
begin
  if KeyComp('Case') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psSelect in FParserStates then
    begin
      ExpressionProc;
      Exclude(FParserStates, psSelect);
    end else
    begin
      S := UpperCase(CurrentWord);
      if S = 'ELSE' then
      begin
        Inc(FRun, FStringLen);
        TrimSpace;
      end else
        ExprListProc;
      FParserStates := [];
//      Include(FParserStates, psCase);
    end;
  end else
  if KeyComp('Call') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    FExecutable := True;
  end else
  if KeyComp('Is') then
  begin
    Result := tkRelOp;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    ExpressionProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func29: TtkTokenKind;
begin
  if KeyComp('On') then
  begin
    Result := tkKey;
    NextStmt;
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func32: TtkTokenKind;
begin
  if KeyComp('Mod') then
  begin
    Result := tkMulOp;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    TermProc;
  end else
  if KeyComp('Get') then
  begin
    Result := tkKey;
    if psProperty in FParserStates then
    begin
      _DoFunction
    end else
    begin
      Inc(FRun, FStringLen);
      TrimSpace;
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func33: TtkTokenKind;
begin
  if KeyComp('Or') then
  begin
    Result := tkAddOp;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    SimpleExpressionProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func36: TtkTokenKind;
begin
  if KeyComp('Rem') then
  begin
    //!!!
    Result := tkComment;
    Inc(FRun, FStringLen);
    TrimSpace;
    ApostropheProc;
    FExecutable := False;
    //!!!
  end
  else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func37: TtkTokenKind;
begin
  if KeyComp('Let') then
  begin
    Result := tkKey;
    if psProperty in FParserStates then
    begin
      _DoFunction
    end else
    begin
      Inc(FRun, FStringLen);
      TrimSpace;
      FExecutable := True;      
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func38: TtkTokenKind;
begin
  if KeyComp('Imp') then
  begin
    Result := tkRelOp;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    ExpressionProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func39: TtkTokenKind;
begin
  if KeyComp('For Each') then begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if not (psExit in FParserStates) then
    begin
      Include(FParserStates, psSetVar);
      Include(FParserStates, psForEach);
    end else
      Exclude(FParserStates, psExit);
    FExecutable := True;
  end
  else if KeyComp('For') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if not (psExit in FParserStates) then
    begin
      Include(FParserStates, psSetVar);
      Include(FParserStates, psFor);
    end else
      Exclude(FParserStates, psExit);
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func41: TtkTokenKind;
begin
  if KeyComp('Else') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func42: TtkTokenKind;
begin
  if KeyComp('Sub') then
  begin
     Result := tkKey;
    _DoFunction
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func44: TtkTokenKind;
begin
  if KeyComp('Eqv') then
  begin
    Result := tkRelOp;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    ExpressionProc;
  end else
  if KeyComp('Set') then
  begin
    Result := tkKey;
    if psProperty in FParserStates then
    begin

      _DoFunction
    end else
    begin
      Inc(FRun, FStringLen);
      TrimSpace;
      Include(FParserStates, psSetVar);
      DesignatorProc;
      Exclude(FParserStates, psSetVar);
      TrimSpace;
      if FScript[FRun] = '=' then
      begin
        Inc(FRun);
        TrimSpace;
        ObjDeclStmt;
      end;
      FExecutable := True;
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func46: TtkTokenKind;
begin
  if KeyComp('Wend') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    FExecutable := False;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func47: TtkTokenKind;
begin
  if KeyComp('Then') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    FVarName := '';
    DoAfterStatament;
    FParserStates := [];
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func48: TtkTokenKind;
begin
  if KeyComp('Erase') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    DesignatorProc;
    FExecutable := True;    
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func49: TtkTokenKind;
begin
  if KeyComp('ReDim') then
  begin
    Result := tkKey;
    NextStmt;
    { TODO : Добавить разбор }
    FExecutable := True;
  end else
  if KeyComp('Not') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
//    if psExpression in FParserStates then
    FactorProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func54: TtkTokenKind;
begin
  if KeyComp('Class') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psEnd in FParserStates then
    begin
      Exclude(FParserStates, psEnd);
      FInClass := False;
    end else
    begin
      FFieldsList.Clear;
      FInClass := True;
      Include(FParserStates, psClass);
      FClassName := CurrentWord;
      Inc(FRun, FStringLen);
      TrimSpace;
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func56: TtkTokenKind;
begin
  if KeyComp('Byref') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    Include(FParserStates, psModificator);
  end else
  if KeyComp('ElseIf') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    ExpressionProc;
    FExecutable := False;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func57: TtkTokenKind;
begin
  if KeyComp('Xor') then
  begin
    Result := tkAddOp;
//    if psExpression in FParserStates then
//    begin
    Inc(FRun, FStringLen);
    TrimSpace;
    SimpleExpressionProc;
//    end;
  end else
  if KeyComp('While') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    ExpressionProc;
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func58: TtkTokenKind;
begin
  if KeyComp('Loop') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    Include(FParserStates, psLoop);
    TrimSpace;
    FExecutable := True;
  end else
  if KeyComp('Exit') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    Include(FParserStates, psExit);
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func62: TtkTokenKind;
begin
  if KeyComp('Byval') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    Include(FParserStates, psModificator);
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func63: TtkTokenKind;
begin
  if KeyComp('Next') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    FExecutable := True;
  end else
  if KeyComp('Public') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func64: TtkTokenKind;
begin
  if KeyComp('Select') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psEnd in FParserStates then
    begin
      Exclude(FParserStates, psEnd);
      FExecutable := False;
    end else
    begin
      Include(FParserStates, psSelect);
      FExecutable := True;
    end;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func71: TtkTokenKind;
begin
  if KeyComp('Const') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    Inc(FRun); //Обрабатываем знак равно
    TrimSpace;
    ExpressionProc;
    FExecutable := False;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func74: TtkTokenKind;
begin
  Result := tkIdentifier;
  SimpleStmtProc;
end;

function TDebuggerParser.Func89: TtkTokenKind;
begin
  if KeyComp('Option') then
  begin
    Result := tkKey;
    NextStmt;
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func91: TtkTokenKind;
begin
  if KeyComp('Private') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func98: TtkTokenKind;
begin
  if KeyComp('Explicit') then
  begin
    Result := tkKey;
    NextStmt;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.GetScript: string;
begin
  SetLength(Result, Length(FScript));
  MoveMemory(@Result[1], FScript, Length(FScript));
end;

procedure TDebuggerParser.GreaterProc;
begin
  fTokenID := tkRelOp;
  Inc(FRun);
  if FScript[FRun + 1] = '=' then
    Inc(FRun);
  TrimSpace;
  ExpressionProc;
end;

function TDebuggerParser.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  //Получаем хэш значение идентификатора
  HashKey := KeyHash(MayBe);
  //если хэш значение меньше размера хэш-таблицы
  //то вызываем соответ. обработкик идентификатора
  if HashKey < 134 then
    Result := fIdentFuncTable[HashKey]
  else
  begin
  //иначе мы имеем дело с простым идентификатором
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

procedure TDebuggerParser.StatamentProc;
begin
  //Обработка индентифкатора
  //Определяется тип идентификаторф
  fTokenID := IdentKind((FScript + FRun));
end;

procedure TDebuggerParser.InitIdent;
var
  I: Integer;
  pF: PIdentFuncTableFunc;
begin
  pF := PIdentFuncTableFunc(@fIdentFuncTable);
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do
  begin
    pF^ := AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[15] := Func15;
  fIdentFuncTable[17] := Func17;
  fIdentFuncTable[19] := Func19;
  fIdentFuncTable[23] := Func23;
  fIdentFuncTable[26] := Func26;
  fIdentFuncTable[28] := Func28;
  fIdentFuncTable[29] := Func29;
  fIdentFuncTable[32] := Func32;
  fIdentFuncTable[33] := Func33;
  fIdentFuncTable[35] := Func35;
  fIdentFuncTable[36] := Func36;
  fIdentFuncTable[37] := Func37;
  fIdentFuncTable[38] := Func38;
  fIdentFuncTable[39] := Func39;
  fIdentFuncTable[41] := Func41;
  fIdentFuncTable[42] := Func42;
  fIdentFuncTable[44] := Func44;
  fIdentFuncTable[46] := Func46;
  fIdentFuncTable[47] := Func47;
  fIdentFuncTable[48] := Func48;
  fIdentFuncTable[49] := Func49;
  fIdentFuncTable[54] := Func54;
  fIdentFuncTable[56] := Func56;
  fIdentFuncTable[57] := Func57;
  fIdentFuncTable[58] := Func58;
  fIdentFuncTable[60] := Func60;
  fIdentFuncTable[62] := Func62;
  fIdentFuncTable[63] := Func63;
  fIdentFuncTable[64] := Func64;
  fIdentFuncTable[71] := Func71;
  fIdentFuncTable[74] := Func74;
  fIdentFuncTable[76] := Func76;
  fIdentFuncTable[89] := Func89;
  fIdentFuncTable[91] := Func91;
  fIdentFuncTable[98] := Func98;
  fIdentFuncTable[102] := Func102;
  fIdentFuncTable[105] := Func105;
  fIdentFuncTable[133] := Func133;
end;

function TDebuggerParser.KeyComp(const aKey: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end; { KeyComp }

function TDebuggerParser.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - FToIdent;
end;

procedure TDebuggerParser.LFProc;
begin
  fTokenID := tkSpace;
  inc(FRun);
  FBreakPointAdded := False;
  Inc(FAddLine);
end;

procedure TDebuggerParser.LowerProc;
begin
  fTokenID := tkRelOp;
  Inc(FRun);
  if FScript[FRun] in ['=', '>'] then
    Inc(FRun);
  TrimSpace;
  ExpressionProc;
end;

procedure TDebuggerParser.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #39: fProcTable[I] := ApostropheProc;
      #13: fProcTable[I] := CRProc;
      '#': fProcTable[I] := DateProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z'{, '_'}: fProcTable[I] := StatamentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      #34: fProcTable[I] := StringProc;
      '{', '}', ':', ',', '.', '(', ')', ';' , '_': fProcTable[I] := SymbolProc;
      '=': fProcTable[I] := RavnoProc;
      '+', '-', '&': fProcTable[I] := AddOpProc;
      '/', '*', '\', '^': fProcTable[I] := MulOpProc;
    else
      fProcTable[I] := UnknownProc;
    end;
end;

procedure TDebuggerParser.Next;
begin
  FProcTable[FScript[FRun]];
end;

procedure TDebuggerParser.NullProc;
begin
  FTokenID := tkNull;
  Exclude(FParserStates, psStatament);
end;

procedure TDebuggerParser.NumberProc;
begin
  inc(FRun);
  fTokenID := tkNumber;
  while FScript[FRun] in ['0'..'9', '.', 'e', 'E'] do inc(FRun);
end;

procedure TDebuggerParser.PrepareScript;
begin
  if FScriptPrepared then Exit;
  if TestCorrect then
  begin
    FRun := 0;
    FLineNumber := 0;
    FAddLine := 0;
    FParserStates := [];
    FProcedureId := 0;
    FInClass := False;
    FInFunction := False;
    FEvaluate := False;
    while FRun < Length(FScript) do
    begin
      Include(FParserStates, psStatament);
      FTokenPos := FRun;
      FExecutable := False;
      FBreakPointAdded := False;
      FVarName := '';
      FAddLine := 0;
      while psStatament in FParserStates do
        Next;
      if psApostrophe in FParserStates then
      begin
        ComentProc;
        Exclude(FParserStates, psApostrophe)
      end;
      Inc(FLineNumber, FAddLine);
    end;
    FScriptPrepared := True;
  end;
end;

procedure TDebuggerParser.SetScript(const Value: string);
var
  L: Integer;
begin
  L := Length(Value);
  CheckBufSize(3 * L);
  FScript[L] := #0;
  MoveMemory(FScript, @Value[1], L);
  FRun := 0;
  FScriptPrepared := False;
end;

procedure TDebuggerParser.SimpleExpressionProc;
  function IsAddOp: Boolean;
  var
    S: String;
  begin
    Result := False;
    if FScript[FRun] in ['+', '-', '&'] then
    begin
      Inc(FRun);
      Result := True;
    end else
    begin
      S := UpperCase(CurrentWord);
      if (S = 'OR') or (S = 'XOR') then
      begin
        Inc(FRun, FStringLen);
        Result := True;
      end;
    end;
  end;
begin
  if FScript[FRun] in ['+', '-'] then
  begin
    Inc(FRun);
    TrimSpace;
  end;
  TermProc;
  TrimSpace;
  if IsAddOp then
  begin
    TrimSpace;
    SimpleExpressionProc;
  end;
end;

procedure TDebuggerParser.SimpleStmtProc;
begin
  if psDesignator in FParserStates then
  begin
    DesignatorProc;
  end else
  if psCase in FParserStates then
  begin
    ExprListProc;
    FParserStates := [];
  end else
  if psFor in FParserStates then
  begin
    FVarName := CurrentWord;
    Include(FParserStates, psNoChangeVarName);
    Inc(FRun, FStringLen);
    TrimSpace;
    Inc(FRun); //Обработка знака =
    TrimSpace;
    Exclude(FParserStates, psSetVar);
    ExpressionProc;
  end else
  if psForEach in FParserStates then
  begin
    FVarName := CurrentWord;
    Include(FParserStates, psNoChangeVarName);
    Inc(FRun, FStringLen);
    TrimSpace;
    Exclude(FParserStates, psSetVar);
    Inc(FRun, 2); //Обработка in
    TrimSpace;
    CurrentWord;
    Inc(FRun, FStringLen);
  end else
  if psParam in FParserStates then
  begin
    FParamList.Add(CurrentWord);
    Inc(FRun, FStringLen);
    TrimSpace;
  end else
  begin
    FExecutable := True;
    if (FVarName = '') then
    begin
      Include(FParserStates, psSetVar);
//      Include(FParserStates, psNoChangeVarName);
    end;
    DesignatorProc;
    TrimSpace;
    Exclude(FParserStates, psSetVar);
    if FScript[FRun] = '=' then
    begin
      Inc(FRun);
      TrimSpace;
      Include(FParserStates, psNoChangeVarName);
      ExpressionProc;
    end else
      if not (psNoChangeVarName in FParserStates) and
        not (FInClass and not FInFunction)then
        FVarName := '';
  end;
end;

procedure TDebuggerParser.SpaceProc;
begin
  inc(FRun);
  fTokenID := tkSpace;
  while FScript[FRun] in [#1..#9, #11, #12, #14..#32] do inc(FRun);
end;

procedure TDebuggerParser.StringProc;
begin
  fTokenID := tkString;
  repeat
    case FScript[FRun] of
      #0, #10, #13: break;
    end;
    inc(FRun);
    if (FScript[FRun] = #34) and (FScript[FRun + 1] = #34) then inc(FRun, 2);
  until FScript[FRun] = #34;
  if FScript[FRun] = #34 then inc(FRun);
end;

procedure TDebuggerParser.SymbolProc;
begin
  if FScript[FRun] = '(' then
  begin
    Inc(FRun);
    ExprListProc;
  end else
  if FScript[FRun] = ')' then
  begin
    Inc(FRun);
    TrimSpace;
  end else
  if FScript[FRun] in ['+', '-', '&'] then
  begin
    Inc(FRun);
    TrimSpace;
    SimpleExpressionProc;
  end else
  if FScript[FRun] in ['/', '\', '*', '^'] then
  begin
    Inc(FRun);
    TrimSpace;
    TermProc;
  end else
  if FScript[FRun] = ',' then
  begin
    Inc(FRun);
    TrimSpace;
//    ExprListProc;
  end else
  if FScript[FRun] = '_' then
  begin
    Inc(FRun);
    TrimSpace;
  end else
  if FScript[FRun] = ':' then
  begin
    DoAfterStatament;
    Inc(FRun);
    FParserStates := [];
  end else
  begin
    inc(FRun);
    fTokenID := tkSymbol;
  end;
end;

procedure TDebuggerParser.TermProc;
  function IsMulOp: Boolean;
  var
    S: String;
  begin
    Result := False;
    if FScript[FRun] in ['/', '\', '*', '^'] then
    begin
      Inc(FRun);
      Result := True;
    end else
    begin
      S := UpperCase(CurrentWord);
      if (S = 'MOD') or (S = 'AND') then
      begin
        Inc(FRun, FStringLen);
        Result := True;
      end;
    end;
  end;
begin
  FactorProc;
  TrimSpace;
  if IsMulOp then
  begin
    TrimSpace;
    TermProc;
  end;
end;

procedure TDebuggerParser.TrimSpace;
begin
  while FScript[FRun] in [#1..#9, #11, #12, #14..#32] do
    Inc(FRun);
  if FScript[FRun] = '_' then
  begin
    repeat
      Inc(FRun);
    until FScript[FRun] in [#0, #10, #13];
    if FScript[FRun] <> #0 then
    begin
      if FScript[FRun] = #13 then
        Inc(FRun);
      if FScript[FRun] = #10 then
        Inc(FRun);
      Inc(FAddLine);
      TrimSpace;
    end
  end;
end;

procedure TDebuggerParser.UnknownProc;
begin
  inc(FRun);
  fTokenID := tkIdentifier;
end;

function TDebuggerParser.Func35: TtkTokenKind;
begin
  if KeyComp('To') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    ExpressionProc;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func76: TtkTokenKind;
begin
  if KeyComp('Until') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    ExpressionProc;
    FExecutable := True;
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

function TDebuggerParser.Func60: TtkTokenKind;
begin
  if KeyComp('Step') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    ExpressionProc;
  end else
  if KeyComp('With') then
  begin
    Result := tkKey;
    Inc(FRun, FStringLen);
    TrimSpace;
    if psEnd in FParserStates then
      Exclude(FParserStates, psEnd);
    FExecutable := True;  
  end else
  begin
    Result := tkIdentifier;
    SimpleStmtProc;
  end;
end;

procedure TDebuggerParser.NextStmt;
begin
  while not (FScript[FRun] in [#0, #10, #13, ':', '''']) do
  begin
    if FScript[FRun] = '"' then
    begin
      StringProc;
      Continue;
    end;

    if (FScript[FRun] = '_') and
      not (FScript[FRun - 1] in ['A'..'Z', 'a'..'z', '0'..'9']) and
      not (FScript[FRun + 1] in ['A'..'Z', 'a'..'z', '0'..'9']) then
    begin
      repeat
        Inc(FRun);
      until FScript[FRun] in [#0, #10, #13];
      if not (FScript[FRun] in [#0, '''']) then
      begin
        if FScript[FRun] = #13 then
          Inc(FRun);
        if FScript[FRun] = #10 then
          Inc(FRun);
        Inc(FAddLine);
      end;
      Continue;
    end;
    Inc(FRun);
  end;
end;

function TDebuggerParser.CurrentWord: string;
begin
  Result := '';
  FStringLen := 0;
  while FScript[FRun + FStringLen] in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
    Inc(FStringLen);
  Result := Copy(FScript, FRun + 1, FStringLen);
end;

procedure TDebuggerParser.FormalParamsProc;
begin
  FormalParamProc;
  if FScript[FRun] = ',' then
  begin
    Inc(FRun);
    TrimSpace;
    FormalParamsProc;
  end;
end;

procedure TDebuggerParser.FormalParamProc;
begin
  Include(FParserStates, psParam);
  Exclude(FParserStates, psModificator);
  Next;
  TrimSpace;
  if psModificator in FParserStates then
  begin
    Next;
    TrimSpace;
  end;
  Exclude(FParserStates, psParam);
end;

destructor TDebuggerParser.Destroy;
begin
  FParamList.Free;
  FFieldsList.Free;
  FSC.Free;
  if FScript <> nil then
    FreeMem(FScript);
  FLocalVarList.Free;  
  inherited;
end;

procedure TDebuggerParser._DoFunction;
begin
  if psProperty in FParserStates then
    Exclude(FParserStates, psProperty)
  else
    FProcType := CurrentWord;
  Inc(FRun, FStringLen);
  TrimSpace;
  if (psEnd in FParserStates) or (psExit in FParserStates) then
  begin
    FExecutable := True;
    DoProcEnd;
    DoAfterStatament;
    FExecutable := False;
    if psExit in FParserStates then
      Exclude(FParserStates, psExit)
    else
    begin
      Exclude(FParserStates, psEnd);
      FInFunction := False;
    end;
  end else
  begin
    FExecutable := False;
    FInFunction := True;
    Include(FParserStates, psFunction);
    FFunctionName := CurrentWord;
    Inc(FRun, FStringLen);
    Inc(FProcedureId);
    TrimSpace;
    FParamList.Clear;
    FLocalVarList.Clear;
    if FScript[FRun] = '(' then
    begin
      Inc(FRun);
      TrimSpace;
      if FScript[FRun] <> ')' then
      begin
        FormalParamsProc;
        TrimSpace;
      end;
      if FScript[FRun] = ')' then
      begin
        Inc(FRun);
        TrimSpace;
      end;
    end;
    DoProcBegin;
    Exclude(FParserStates, psFunction);
  end;
end;

procedure TDebuggerParser.ObjDeclStmt;
begin
  NextStmt;
  { TODO : Добавить разбор }
end;

function TDebuggerParser.TestCorrect: Boolean;
begin
  try
    FSC.Reset;
    FSC.AddCode(FScript);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TDebuggerParser.DoAfterStatament;
var
  Str: string;
  L: Integer;
begin
  if FExecutable then
  begin
    if FInFunction then
    begin
      if not FBreakPointAdded then
      begin
        Str := Format(cBreakPoint, [FId, FProcedureId, FLineNumber,
          FProcType]) + ': ';
        Insert(Str, FTokenPos);
        L := Length(Str);
        Inc(FTokenPos, L);
        Inc(FRun, L);
        FBreakPointAdded := True;
      end;
    end;
    if FVarName <> '' then
    begin
      if FInClass and not FInFunction then
        FFieldsList.Add(FVarName)
      else begin
        if FInFunction then
        begin
          Str := ': ' + Format(cSetVariable, ['"' + UpperCase(FVarName) + '"', FVarName]);
          L := Length(Str);
          Insert(Str, FRun);
          Inc(FRun, L);
          FVarName := '';
        end;
      end;
    end;
    if Assigned(Debugger) then
      Debugger.DebugLines[FLineNumber] :=
        Debugger.DebugLines[FLineNumber] + [dlExecutableLine];
  end;
end;

procedure TDebuggerParser.DoProcBegin;
var
  I: Integer;
  S: String;
  Str: string;
begin
  if FInClass then
    S := FClassName + '.' + FFunctionName
  else
    S := FFunctionName;

  if PropertySettings.DebugSet.RuntimeSave then
  begin
    Str := ': ' + Format(cProcBegin, [FId, S]) +
      ': '+ Format(cBeginTime, [FId, S]);
  end else
    Str := ': ' + Format(cProcBegin, [FId, S]);

  Insert(Str, FRun);
  Inc(FRun, Length(Str));
  //Добавляем свойства класса
  if FInClass then
    for I := 0 to FFieldsList.Count - 1 do
    begin
      Str := ': ' + Format(cSetVariable, ['"' + UpperCase(FFieldsList[I]) + '"', FFieldsList[I]]);
      Insert(Str, FRun);
      Inc(FRun, Length(Str));
    end;
  //Добавляем аргументы
  for I := 0 to FParamList.Count - 1 do
  begin
    Str := ': ' + Format(cSetArgument, ['"' + UpperCase(FParamList[I]) + '"',
      FParamList[I]]);
    Insert(Str, FRun);
    Inc(FRun, Length(Str));
  end;
end;

procedure TDebuggerParser.DoProcEnd;
var
  Str: String;
begin
  if PropertySettings.DebugSet.RuntimeSave then
    Str := Format(cEndTime, [FId]) + ': ' + cProcEnd
  else
    Str := cProcEnd;
    Insert(Str, FTokenPos);
//  Inc(FTokenPos, Length(cProcEnd));
  Inc(FRun, Length(Str));
end;

procedure TDebuggerParser.ComentProc;
begin
  fTokenID := tkComment;
  repeat
    inc(FRun);
  until FScript[FRun] in [#0, #10, #13];
end;

procedure TDebuggerParser.Insert(Str: string; Index: Integer);
var
  L, L1: Integer;
begin
  L := Length(Str);
  L1 := Length(FScript);
  if L > 0 then
  begin
    CheckBufSize(L1 + L + 1);
    FScript[L + L1] := #0;
    MoveMemory(FScript +Index + L, FScript + Index, L1 - Index);
    MoveMemory(FScript + Index, @Str[1], L);
  end;
end;

procedure TDebuggerParser.RavnoProc;
begin
  fTokenID := tkRelOp;
  FStringLen := 1;
  Inc(FRun);
  ExpressionProc;
end;

procedure TDebuggerParser.AddOpProc;
begin
  fTokenID := tkAddOp;
  Inc(FRun);
  FStringLen := 1;
  TrimSpace;
  SimpleExpressionProc;
end;

procedure TDebuggerParser.MulOpProc;
begin
  fTokenID := tkMulOp;
  Inc(FRun);
  FStringLen := 1;
  TrimSpace;
  TermProc;
end;

procedure TDebuggerParser.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TDebuggerParser.CheckBufSize(L: Integer);
var
  P: Pointer;
begin
  if FScriptSize < L then
  begin
    GetMem(P, L + 1);
    if FScript <> nil then
    begin
      MoveMemory(P, FScript, FScriptSize);
      FreeMem(FScript);
    end;
    FScript := P;
    FscriptSize := L + 1;
  end;
end;

procedure TDebuggerParser.LightPrepareScript;
begin
  if FscriptPrepared then Exit;
end;

{ TEvaluator }


procedure TDebuggerParser.ListExprList;
var
  P: Integer;
  A: Integer;
begin
  if FScript[FRun] = '(' then
  begin
    Include(FParserStates, psNoChangeVarName);
    Inc(FRun);
    TrimSpace;
    if FScript[FRun] <> ')' then // возможно закрывающая ковычка
    begin
      ExprListProc;
      TrimSpace;
    end;
    Inc(FRun); //закрывающаяся ковычка
    TrimSpace;
    if FScript[FRun] = ',' then
    begin
      P := FRun;
      A := FAddLine;
      Inc(FRun);
      TrimSpace;
      if FScript[FRun] = '(' then
        ListExprList
      else
      begin
        FRun := P;
        FAddLine := A;
      end;
    end;
  end
end;

function TDebuggerParser.Eval: Variant;
var
  Str: String;
begin
  FRun := 0;
  FLineNumber := 0;
  FAddLine := 0;
  FParserStates := [];
  FEvaluate := True;

  ExpressionProc;
  Str := Copy(FScript, 0, Length(FScript));
  try
    Result := ScriptFactory.Eval(Str);
  except
    on E: Exception do
//      Result := E.Message;
      Result := 'Ошибка при вычислении';
  end;
end;

procedure TDebuggerParser.Delete(Index, Count: Integer);
begin
  MoveMemory(FScript + Index, FScript + Index + Count, Length(FScript) - Index - Count + 1);
end;

procedure TDebuggerParser.SetDebugger(const Value: TDebugger);
begin
  FDebugger := Value;
end;

{ TFinallyVarList }

function TFinallyVarList.Add: Integer;
begin
  Result := FVarList.Add(nil);
end;

procedure TFinallyVarList.Clear;
var
  I: Integer;
  P: PFinallyRec;
begin
  for I := 0 to FVarList.Count - 1 do
  begin
    P := PFinallyRec(FVarList[I]);
    if P <> nil then
      Dispose(P);
  end;
  FVarList.Clear;
end;

procedure TFinallyVarList.ClearValue(Index: Integer);
var
  P: PFinallyRec;
begin
  P := PFinallyRec(FVarList[Index]);
  if P <> nil then
    Dispose(P);

  FVarList[Index] := nil;
end;

constructor TFinallyVarList.Create;
begin
  FVarList := TList.Create;
end;

procedure TFinallyVarList.Delete(Index: Integer);
begin
  ClearValue(Index);
  FVarList.Delete(Index);
end;

destructor TFinallyVarList.Destroy;
begin
  FVarList.Free;
  inherited;
end;

function TFinallyVarList.GetCount: Integer;
begin
  Result := FVarList.Count;
end;

function TFinallyVarList.GetValue(Index: Integer): TFinallyRec;
var
  P: PFinallyRec;
begin
  P := PFinallyRec(FVarList[Index]);
  if P <> nil then
    Result := P^
  else
    with Result do
    begin
      ParamArray := Unassigned;
      Line := 0;
      FinallyScript := '';
    end;
end;

procedure TFinallyVarList.SetValue(Index: Integer; const ParamArray: OleVariant;
  const FinallyScript: WideString; const Line: Integer);
var
  P: PFinallyRec;
begin
  P := FVarList[Index];
  if P = nil then
  begin
    New(P);
    FVarList[Index] := P;
  end;
  P^.ParamArray := ParamArray;
  P^.FinallyScript := FinallyScript;
  P^.Line := Line;
end;

initialization
  MakeIdentTable;
  TAutoObjectFactory.Create(ComServer, TDebugger, CLASS_gsDebugger,
    ciMultiInstance, tmApartment);
end.

