{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    obj_i_Debugger.pas

  Abstract

    Gedemin project. TDebuggerState, TDebuggerLineInfo, TDebuggerLineInfos,
      TBreakpointChangeEvent, TDebuggerStateChangeEvent, TDebugLines,
      IDebugger, TDebugVar, TDebugVars.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.08.02    tiptop        Initial version.
            09.08.02    tiptop        TDebugVar, TDebugVars added
    1.01    16.06.03    DAlex         Add support FinallyObject for VB-Script
            18.06.03    DAlex         Добавлена поддержка обработки исключений (инструкция Except)
--}

unit obj_i_Debugger;

interface
uses rp_BaseReport_unit, Classes, sysutils, contnrs, Forms;

type
  TRuntimeRec = record
    FunctionName: ShortString;
    FunctionKey: Integer;
    RuntimeTicks: LongWord;
    BeginTime:  TDateTime;
  end;

  TEndScriptEvent = procedure (Sender: TObject; RuntimeRec: TRuntimeRec) of object;

  TRuntimeList = class(TObject)
  private
    FList: array of TRuntimeRec;
    FCount: Integer;
    FSize: Integer;

    procedure Grow;
    function GetItem(Index: Integer): TRuntimeRec;
  public
    constructor Create;
    destructor  Destroy; override;

    function  Add(const Runtime: TRuntimeRec): Integer;
    function  LastRec: TRuntimeRec;
    procedure Clear;
    procedure DeleteLast;

    property Count: Integer read FCount;
    property Item[Index: Integer]: TRuntimeRec read GetItem;
  end;

type
  TDebuggerState = (dsStopped, dsRunning, dsPaused, dsStep, dsStepOver,
    dsReset);

  TDebuggerLineInfo = (dlCurrentLine, dlBreakpointLine, dlExecutableLine,
    dlErrorLine);
  TDebuggerLineInfos = set of TDebuggerLineInfo;

type
  TBreakpointChangeEvent = procedure(Sender: TObject; ALine: integer) of object;
  TDebuggerStateChangeEvent = procedure(Sender: TObject;
    OldState, NewState: TDebuggerState) of object;
  //Хранит  информацию о каждой строке скрипта

  TDebugLines = class(TList)
  private
    FCurrentLine: Integer;
    FErrorLine: Integer;
    FOnErrorLineChanged: TNotifyEvent;
    FOnErrorLineChanging: TNotifyEvent;
    function GetDebugLines(Index: Integer): TDebuggerLineInfos;
    procedure SetDebugLines(Index: Integer;
      const Value: TDebuggerLineInfos);
    procedure SetCurrentLine(const Value: Integer);
    procedure SetErrorLine(const Value: Integer);
    procedure SetOnErrorLineChanged(const Value: TNotifyEvent);
    procedure SetOnErrorLineChanging(const Value: TNotifyEvent);
  public
    constructor Create;
    procedure Insert(Index: Integer; Item: TDebuggerLineInfos);
    procedure Assign(Source: TDebugLines);
    function Add(Value: TDebuggerLineInfos): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
    procedure MergeBPToStream(Stream: TStream);
    procedure SaveBPToStream(Stream: TStream);
    procedure ReadBPFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);
    procedure Checksize(ACount: Integer);

    property DebugLines[Index: Integer]: TDebuggerLineInfos read GetDebugLines write SetDebugLines; default;
    property CurrentLine: Integer read FCurrentLine write SetCurrentLine;
    property ErrorLine: Integer read FErrorLine write SetErrorLine;
    property OnErrorLineChanging: TNotifyEvent read FOnErrorLineChanging write SetOnErrorLineChanging;
    property OnErrorLineChanged: TNotifyEvent read FOnErrorLineChanged write SetOnErrorLineChanged;
  end;

  //Класс хранит информицию о переменной
  TDebugVar = class
  private
    FName: WideString;
    FValue: Variant;
    FItIsArgument: Boolean;
    procedure SetName(const Value: WideString);
    procedure SetValue(const Value: Variant);
    procedure SetItIsArgument(const Value: Boolean);
  public
    procedure Assign(Source: TDebugVar);

    property Name: WideString read FName write SetName;
    property Value: Variant read FValue write SetValue;
    property ItIsArgument: Boolean read FItIsArgument write SetItIsArgument;
  end;

  //Список локальных переменных для процедуры
  TDebugProcVars = class(TObjectList)
  private
    function GetDebugVars(Index: Integer): TDebugVar;
    function GetVariables(Name: WideString): Variant;
    procedure SetDebugVars(Index: Integer; const Value: TDebugVar);
    procedure SetVariables(Name: WideString; const Value: Variant; const ItIsAgrument: Boolean);
  public
    constructor Create;
    function IndexOfVariable(Name: WideString): Integer;
    property DebugVars[Index: Integer]: TDebugVar read GetDebugVars write SetDebugVars;
    property Variables[Name: WideString]: Variant read GetVariables;
  end;

  //Стек переменных
  TDebugVars = class(TObjectList)
  private
    function GetProcs(Index: Integer): TDebugProcVars;
  public
    constructor Create;
    procedure ProcBegin;
    procedure ProcEnd;

    procedure SetVariable(Name: WideString; Value: Variant; const ItIsAgrument: Boolean);
    function GetVariable(const Name: WideString): OleVariant;

    property Procs[Index: Integer]: TDebugProcVars read GetProcs;
  end;

  //Класс точки останова
  TBreakPoint = class
  private
    FLine: Integer;
    FFunctionKey: Integer;
    FPassCount: Integer;
    FCondition: string;
    FValidPassCount: Integer;
    FEnabled: Boolean;
    procedure SetCondition(const Value: string);
    procedure SetFunctionKey(const Value: Integer);
    procedure SetLine(const Value: Integer);
    procedure SetPassCount(const Value: Integer);
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create;

    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure Reset;
    procedure IncPass;

    property FunctionKey: Integer read FFunctionKey write SetFunctionKey;
    property Line: Integer read FLine write SetLine;
    property Condition: string read FCondition write SetCondition;
    property PassCount: Integer read FPassCount write SetPassCount;
    property ValidPassCount: Integer read FValidPassCount;
    property Enabled: Boolean read FEnabled write SetEnabled;
  end;

  TBreakPointList = class(TObjectList)
  private
    {$IFDEF GEDEMIN}
    FLoaded: Boolean;
    {$ENDIF}
    function GetBreakPoints(Index: Integer): TBreakPoint;
    procedure SetBreakPoints(Index: Integer; const Value: TBreakPoint);
  public
    function IndexByIdAndLine(Id, Line: Integer): Integer;
    function BreakPoint(Id, Line: Integer): TBreakPoint;

    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);

    procedure SaveToStorage;
    procedure LoadFromStorage;

    procedure Reset;

    property BreakPoints[Index: Integer]: TBreakPoint read GetBreakPoints write SetBreakPoints; default;
  end;

  TCustomDebugLink = class(TComponent)
  private
    FForm: TForm;
    FRun: boolean;
    FScript: TrpCustomFunction;
    procedure SetForm(const Value: TForm);
    function GetScript: TrpCustomFunction;
    function GetFunctionKey: Integer;
  protected
    procedure DoRun; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Run; virtual;
    procedure Step; virtual;
    procedure StepOver; virtual;
    procedure Reset; virtual;
    procedure ShowForm; virtual;
    procedure FormInvalidate; virtual;
    procedure GotoCursor(Y: Integer); virtual;
    function IsExecuteScript: Boolean;
    procedure Evaluate(AEval: string);
    procedure ToggleBreakPoint(Line: Integer);
    procedure OnDebuggerStateChange(Sender: TObject;
      OldState, NewState: TDebuggerState);

    property FunctionKey: Integer read GetFunctionKey;
    property Form: TForm read FForm write SetForm;
    property Script: TrpCustomFunction read GetScript;
    property IsRuning: Boolean read FRun;
  end;

type
{  TFinallyRec = class
  public
    ParamArray: OleVariant;
    FinallyScript: WideString;
    Line: Integer;

    procedure Clear;
  end;}
  TFinallyRec = record
    ParamArray: OleVariant;
    FinallyScript: WideString;
    Line: Integer;
  end;

  IDebugger = interface(IDispatch)
  ['{60AE6AA4-CEC1-4D2A-BB6F-E46D2256635A}']
    function  Get_Self: TObject;
    function GetCurrentLine: Integer;
    function GetDebugLines: TDebugLines;
    function GetOnBreakpointChange: TBreakpointChangeEvent;
    function GetOnCurrentLineChange: TNotifyEvent;
    function GetOnStateChange: TDebuggerStateChangeEvent;
    function GetOnYield: TNotifyEvent;
    function GetExecuteDebugLines: TDebugLines;
    function GetExecuteScriptFunction: Integer;
    function GetInDebugger: Boolean;
    function GetFunctionRun: Boolean;
    function GetLastScriptFunction: Integer;
    function GetLastFinallyParams: TFinallyRec;//OleVariant;
    function GetFinallyParams(const Index: Integer): TFinallyRec;
    function GetCurrentFinallyParams: TFinallyRec;
    function GetEnabled: Boolean;
    function GetResultRuntimeList: TRuntimeList;
    function GetOnEndScript: TEndScriptEvent;
    function GetOnStateChanged: TNotifyEvent;

    procedure ClearLastFinallyParams;
    procedure ClearDebugVars(Index: Integer);

    procedure DecKeyIndex;
    function  GetCurrentKey: Integer;
    function  GetCurrentKeyIndex: Integer;

//    procedure SetLastFinallyParams(const Value: OleVariant);

    procedure SetEnabled(const Value: Boolean);
    procedure SetFunctionRun(const Value: Boolean);
    procedure SetOnBreakpointChange(const Value: TBreakpointChangeEvent);
    procedure SetOnCurrentLineChange(const Value: TNotifyEvent);
    procedure SetOnStateChange(const Value: TDebuggerStateChangeEvent);
    procedure SetOnYield(const Value: TNotifyEvent);
    procedure SetCurrentLine(const Value: Integer);
    procedure SetInDebugger(const Value: Boolean);
    procedure SetOnEndScript(const Value: TEndScriptEvent);
    procedure SetOnStateChanged(const Value: TNotifyEvent);

    procedure SetLastFinallyParams(const AParamArray: OleVariant;
      const AFinallyScript: WideString; const ALine: Integer);


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
    function IsRunning: WordBool;
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
    procedure GetCallStack(const S: TStrings; out IdList: TList);

    function GetVariable(const VarName: WideString): OleVariant; safecall;
    function Eval(Str: String; Extend: Boolean = True): Variant;

    procedure ProcBegin(sfid: Integer; const FunctionName: WideString); safecall;
    procedure ProcEnd; safecall;

    property DebugLines: TDebugLines read GetDebugLines;
    property ExecuteDebugLines: TDebugLines read GetExecuteDebugLines;

    property Self: TObject read Get_Self;
    property CurrentLine: Integer read GetCurrentLine write SetCurrentLine;
    property ExecuteScriptFunction: Integer read GetExecuteScriptFunction;
    //Указывает на то что сейчас идет обработка точки прерывания
    property InDebugger: Boolean read GetInDebugger write SetInDebugger;
    //Указывает на то что скрипт-контрол выполняет функцию
    //присваивается тру в момент запуска с-ф
    //присваивается фолсе в момент выхода из с-ф
    property FunctionRun: Boolean read GetFunctionRun write SetFunctionRun;
    //Ид последней скрипт-функции. Используется при возникновении ошибки
    property LastScriptFunction: Integer read GetLastScriptFunction;
    //Финалли-скрипт последней скрипт-функции.
    property LastFinallyParams: TFinallyRec read GetLastFinallyParams;

    //На время загрузки окна троперти необходимо отключать дебагер
    property Enabled: Boolean read GetEnabled write SetEnabled;

    property ResultRuntimeList: TRuntimeList read GetResultRuntimeList;


    property OnBreakpointChange: TBreakpointChangeEvent read GetOnBreakpointChange
      write SetOnBreakpointChange;
    property OnCurrentLineChange: TNotifyEvent read GetOnCurrentLineChange
      write SetOnCurrentLineChange;
    property OnStateChange: TDebuggerStateChangeEvent read GetOnStateChange
      write SetOnStateChange;
    property OnYield: TNotifyEvent read GetOnYield write SetOnYield;
    property OnEndScript: TEndScriptEvent read GetOnEndScript write SetOnEndScript;
    property OnStateChanged: TNotifyEvent read GetOnStateChanged write SetOnStateChanged;
  end;

function VarEmptyToStr(const A: Variant): String;
function VarNullToStr(const A: Variant): String;
function VarDispatchToStr(const A: Variant): String;
function PointerToHexStr(P: Pointer): String;
function HexToChar(B: Byte): Char;
//Возвращает текстовое представление вариантеого массива
function VarArrayToStr(const A: Variant): String;
function VarBooleanToStr(const A: Variant): String;

var
  Debugger: IDebugger;
  BreakPointList: TBreakPointList;

const
  sPropertyBreakPointsPath = 'Options\PropertySettings';
  //BreakPoints
  cBreakPoits = 'BreakPoints';

var
  _DebugLinkList: TObjectList;

implementation

uses prp_MessageConst, Windows, gd_i_ScriptFactory, prp_PropertySettings,
  scr_i_FunctionList, prp_dlgEvaluate_unit
  {$IFDEF GEDEMIN}
  ,Storages, gdcCustomFunction, gdcBaseInterface
  {$ENDIF}
  ;

const
  cEmpty = 'Empty';

procedure AddLink(Link: TCustomDebugLink);
begin
  if _DebugLinkList = nil then
    _DebugLinkList := TObjectList.Create;

  if _DebugLinkList.IndexOf(Link) = - 1 then
    _DebugLinkList.Add(Link);
end;

procedure ReleaseLink(Link: TCustomDebugLink);
var
  Index: Integer;
begin
  if _DebugLinkList <> nil then
  begin
    Index := _DebugLinkList.IndexOf(Link);
    if Index > - 1 then
      _DebugLinkList.Extract(Link);

    if _DebugLinkList.Count = 0 then
      FreeAndNil(_DebugLinkList);
  end;
end;

function PointerToHexStr(P: Pointer): String;
var
  I: Integer;
const
  Mask = $0F;
begin
  Result := '';
  for I := 0 to SizeOf(P) * 2 - 1 do
    Result := HexToChar((Integer(P) shr (I * 4)) and Mask) + Result;
  Result := '$' + Result;
end;

function HexToChar(B: Byte): Char;
begin
  if B < $0A then
    Result := Char(B + Ord('0'))
  else
    Result := Char(B + Ord('A') - 10);
end;

function VarBooleanToStr(const A: Variant): String;
begin
  Result := cEmpty;
  if VarType(A) = varBoolean then
  begin
    if A then
      Result := 'True'
    else
      Result := 'False'
  end;
end;

function VarNullToStr(const A: Variant): String;
begin
  Result := cEmpty;
  if VarType(A) = varNull then
    Result := 'Null';
end;

function VarEmptyToStr(const A: Variant): String;
begin
  Result := cEmpty;
  if VarType(A) = varEmpty then
    Result := 'Empty';
end;

function VarDispatchToStr(const A: Variant): String;
begin
  Result := cEmpty;
  if VarType(A) = varDispatch then
    Result := Format('Объект(%S)', [PointerToHexStr(TVarData(A).VDispatch)]);
end;

function GetVarArray(const A: Variant): PVarArray;
begin
  if TVarData(A).VType and varByRef <> 0 then
    Result := PVarArray(TVarData(A).VPointer^)
  else
    Result := TVarData(A).VArray;
end;

function VarArrayToStr(const A: Variant): String;
var
  I: Integer;
  VA: PVarArray;
  P: Pointer;
  Count: LongInt;
begin
  Result := cEmpty;
  if not VarIsArray(A) then
    Exit;

  VA := GetVarArray(A);
  if Assigned(VA) then
  begin
    P := VA^.Data;
    Result := '';
    if VA^.DimCount > 0 then
      Count := VA^.Bounds[0].ElementCount
    else
      Count := 0;
    for I := 1 to VA^.DimCount - 1 do
      Count := Count * VA^.Bounds[I].ElementCount;

    for I := 0 to Count - 1 do
    begin
      if Result > '' then
        Result := Result + ', ';
      case TVarData(P^).VType of
        varDispatch: Result := Result + VarDispatchToStr(Variant(P^));
        varArray: VarArrayToStr(Variant(P^));
        varString, varOleStr, varStrArg: Result := Result + '''' +
          Variant(P^) + '''';
        varEmpty: Result := Result + VarEmptyToStr(Variant(P^));
        varNull: Result := Result + VarNullToStr(Variant(P^));
        varBoolean: Result := Result + VarBooleanToStr(Variant(P^));
        varArray + varVariant: VarArrayToStr(Variant(P^));
      else
        Result := Result + VarToStr(Variant(P^));
      end;
      P := Pointer(Integer(P) + VA^.ElementSize);
    end;
    Result := '(' + Result + ')';
  end
end;
{ TDebugLines }

function TDebugLines.Add(Value: TDebuggerLineInfos): Integer;
var
  P: ^TDebuggerLineInfos;
begin
  New(P);
  P^ := Value;
  Result := inherited Add(P);
end;

procedure TDebugLines.Assign(Source: TDebugLines);
var
  I: Integer;
begin
  Clear;
  for I := 0 to Source.Count - 1 do
    Add(Source[I]);
end;

procedure TDebugLines.CheckSize(ACount: Integer);
var
  I: Integer;
begin
  if ACount >= Count then
    for I := Count to ACount - 1 do
      Add([]);
end;

procedure TDebugLines.Clear;
begin
  while Count > 0 do
    Delete(Count - 1);

  inherited;
end;

constructor TDebugLines.Create;
begin
  inherited;
  FErrorLine := - 1;
end;

procedure TDebugLines.Delete(Index: Integer);
begin
  FreeMem(Items[Index], SizeOf(TDebuggerLineInfos));
  
  inherited Delete(Index);
end;

function TDebugLines.GetDebugLines(Index: Integer): TDebuggerLineInfos;
begin
  Result := TDebuggerLineInfos(Items[Index]^);
end;

procedure TDebugLines.Insert(Index: Integer; Item: TDebuggerLineInfos);
var
  P: ^TDebuggerLineInfos;
begin
  New(P);
  P^ := Item;
  inherited Insert(Index, P);
end;

procedure TDebugLines.MergeBPToStream(Stream: TStream);
var
  I: Integer;
  LI: TDebuggerLineInfos;
  DL: TDebugLines;
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток не инициализирован');

  DL := TDebugLines.Create;
  try
    DL.ReadFromStream(Stream);
    Stream.Position := 0;

    Stream.WriteBuffer(DL.Count, SizeOf(DL.Count));
    for i := 0 to DL.Count - 1 do
    begin
      if I < Count then
      begin
        LI := DebugLines[I];
        if dlBreakpointLine in LI then
          LI := [dlBreakpointLine] + DL.DebugLines[I]
        else
          LI := DL.DebugLines[I] - [dlBreakpointLine];
      end else
        LI := DL.DebugLines[I];
      Stream.WriteBuffer(LI, SizeOf(LI));
    end;
  finally
    DL.Free;
  end;
end;

procedure TDebugLines.ReadBPFromStream(Stream: TStream);
var
  I: Integer;
  LI: TDebuggerLineInfos;
  lCount: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток не инициализирован');

  Stream.ReadBuffer(lCount, SizeOf(lCount));
  if Count = 0 then Checksize(lCount);
  for i := 0 to lCount - 1 do
  begin
    Stream.ReadBuffer(LI, SizeOf(LI));
    if I < Count  then
    begin
      if dlBreakpointLine in LI then
        DebugLines[I] := DebugLines[I] + [dlBreakpointLine]
      else
        DebugLines[I] := DebugLines[I] - [dlBreakpointLine];
    end else
      Break;
  end;
end;

procedure TDebugLines.ReadFromStream(Stream: TStream);
var
  I: Integer;
  LI: TDebuggerLineInfos;
  lCount: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток не инициализирован');

  Stream.Position := 0;
  Clear;
  if Stream.Size > 0 then
  begin
    Stream.ReadBuffer(lCount, SizeOf(lCount));
    for I := 0 to lCount - 1 do
    begin
      Stream.ReadBuffer(LI, SizeOf(LI));
      Add(LI);
    end;
  end;  
end;

procedure TDebugLines.SaveBPToStream(Stream: TStream);
var
  I: Integer;
  LI: TDebuggerLineInfos;
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток не инициализирован');

  Stream.WriteBuffer(Count, SizeOf(Count));
  for i := 0 to Count - 1 do
  begin
    LI := DebugLines[I];
    if dlBreakpointLine in LI then
      LI := [dlBreakpointLine]
    else
      LI := [];
    Stream.WriteBuffer(LI, SizeOf(LI))
  end;
end;

procedure TDebugLines.SaveToStream(Stream: TStream);
var
  I: Integer;
  LI: TDebuggerLineInfos;
begin
  if not Assigned(Stream) then
    raise Exception.Create('Поток не инициализирован');

  Stream.WriteBuffer(Count, SizeOf(Count));
  for i := 0 to Count - 1 do
  begin
    LI := DebugLines[I];
    Stream.WriteBuffer(LI, SizeOf(LI))
  end;
end;

procedure TDebugLines.SetCurrentLine(const Value: Integer);
begin
  if (FCurrentLine > - 1) and (FCurrentLine < Count) then
    DebugLines[FCurrentLine] := DebugLines[FCurrentLine] - [dlCurrentLine];
  FCurrentLine := Value;
  if (FCurrentLine > - 1) and (FCurrentLine < Count) then
    DebugLines[FCurrentLine] := DebugLines[FCurrentLine] + [dlCurrentLine];
end;

procedure TDebugLines.SetDebugLines(Index: Integer;
  const Value: TDebuggerLineInfos);
begin
  TDebuggerLineInfos(Items[Index]^) := Value;
end;

procedure TDebugLines.SetErrorLine(const Value: Integer);
begin
{  if (FErrorLine > - 1) and (FErrorLine < Count) then
    DebugLines[FErrorLine] := DebugLines[FErrorLine] - [dlErrorLine];
  FErrorLine := Value;
  if (FErrorLine > - 1) and (FErrorLine < Count) then
    DebugLines[FErrorLine] := DebugLines[FErrorLine] + [dlErrorLine];}
  if Assigned(FOnErrorLineChanging)  then
    FOnErrorLineChanging(Self);
  FErrorLine := Value;
  if Assigned(FOnErrorLineChanged) then
    FOnErrorLineChanged(Self);
end;

procedure TDebugLines.SetOnErrorLineChanged(const Value: TNotifyEvent);
begin
  FOnErrorLineChanged := Value;
end;

procedure TDebugLines.SetOnErrorLineChanging(const Value: TNotifyEvent);
begin
  FOnErrorLineChanging := Value;
end;

{ TDebugVar }

procedure TDebugVar.Assign(Source: TDebugVar);
begin
  FName := Source.FName;
  FValue := Source.FValue;
  FItIsArgument := Source.FItIsArgument;
end;

procedure TDebugVar.SetItIsArgument(const Value: Boolean);
begin
  FItIsArgument := Value;
end;

procedure TDebugVar.SetName(const Value: WideString);
begin
  FName := Value;
end;

procedure TDebugVar.SetValue(const Value: Variant);
begin
  FValue := Value;
end;

{ TDebugVars }

constructor TDebugVars.Create;
begin
  inherited;
  OwnsObjects := True;
end;


function TDebugVars.GetProcs(Index: Integer): TDebugProcVars;
begin
  Result :=  TDebugProcVars(Items[Index]);
end;

function TDebugVars.GetVariable(const Name: WideString): OleVariant;
begin
  Result := Unassigned;
  if Count > 0 then
    Result := Procs[Count - 1].GetVariables(Name);
end;

procedure TDebugVars.ProcBegin;
begin
  Add(TDebugProcVars.Create);
end;

procedure TDebugVars.ProcEnd;
begin
  if Count > 0 then
    Delete(Count - 1);
end;


procedure TDebugVars.SetVariable(Name: WideString; Value: Variant; const ItIsAgrument: Boolean);
begin
  if Count > 0 then
    Procs[Count - 1].SetVariables(Name, Value, ItIsAgrument);
end;


{ TRuntimeList }

function TRuntimeList.Add(const Runtime: TRuntimeRec): Integer;
begin
  if FCount = FSize then Grow;
  FList[FCount] := Runtime;
  Result := FCount;
  Inc(FCount);
end;

procedure TRuntimeList.Clear;
begin
  FCount := 0;
  FSize := 0;
  while FCount > 0 do
    DeleteLast;
  SetLength(FList, 0);
end;

constructor TRuntimeList.Create;
begin
  FCount := 0;
  FSize := 0;
  SetLength(FList, 0);
end;

procedure TRuntimeList.DeleteLast;
begin
  if FCount > 0 then
  begin
    System.Move(FList[FCount], FList[FCount - 1], SizeOf(FList[0]));
    Dec(FCount);
  end;
end;

destructor TRuntimeList.Destroy;
begin
  Clear;
  inherited;
end;

function TRuntimeList.GetItem(Index: Integer): TRuntimeRec;
begin
  if (-1 < Index) and (Index < FCount) then
    Result := FList[Index]
  else
    raise Exception.Create('Index out of bound');
end;

procedure TRuntimeList.Grow;
begin
  FSize := FSize + SizeOf(TRuntimeList);
  SetLength(FList, FSize);
end;

function TRuntimeList.LastRec: TRuntimeRec;
begin
  if FCount > 0 then
    Result := FList[FCount - 1]
  else
    begin
      Result.FunctionName := '';
      Result.FunctionKey := -1;
      Result.RuntimeTicks := 0;
    end;
end;

{ TDebugProcVars }

constructor TDebugProcVars.Create;
begin
  inherited;
  OwnsObjects := True;
end;

function TDebugProcVars.GetDebugVars(Index: Integer): TDebugVar;
begin
  Result := TDebugVar(Items[Index]);
end;

function TDebugProcVars.GetVariables(Name: WideString): Variant;
var
  Index: Integer;
begin
  Index := IndexOfVariable(Name);
  if Index > - 1 then
    Result := DebugVars[Index].Value
  else
    Result := Unassigned;
end;

function TDebugProcVars.IndexOfVariable(Name: WideString): Integer;
var
  I: Integer;
begin
  Result := - 1;
  if Count  >  0 then
  begin
    Name := UpperCase(Name);
      for I := 0 to Count - 1 do
    begin
      if Name = DebugVars[I].Name then
      begin
        Result := I;
        Break;
        end;
    end;
  end;
end;

procedure TDebugProcVars.SetDebugVars(Index: Integer;
  const Value: TDebugVar);
begin
  TDebugVar(Items[Index]).Assign(Value);
end;

procedure TDebugProcVars.SetVariables(Name: WideString;
  const Value: Variant; const ItIsAgrument: Boolean);
var
  Index: Integer;
begin
  Index := IndexOfVariable(Name);
  if Index > - 1 then
  begin
    DebugVars[Index].Value := Value;
  end else
  begin
    Index := Add(TDebugVar.Create);
    //Парсер должен сразу подставлять имена в верхнем реестре
    DebugVars[Index].Name := Name;
    DebugVars[Index].Value := Value;
    DebugVars[Index].ItIsArgument := ItIsAgrument;
  end;
end;

{ TBreakPoint }

constructor TBreakPoint.Create;
begin
  FEnabled := True;
end;

procedure TBreakPoint.IncPass;
begin
  Inc(FValidPassCount);
end;

procedure TBreakPoint.loadFromStream(Stream: TStream);
var
  L: Integer;
begin
  Stream.ReadBuffer(FEnabled, SizeOf(FEnabled));
  Stream.ReadBuffer(FLine, SizeOf(FLine));
  Stream.ReadBuffer(FFunctionKey, SizeOf(FFunctionKey));
  Stream.ReadBuffer(FPassCount, SizeOf(PassCount));
  Stream.ReadBuffer(L, sizeOf(L));
  if L > 0 then
  begin
    SetLength(FCondition, L);
    Stream.Write(FCondition[1], L);
  end else
    FCondition := '';
end;

procedure TBreakPoint.Reset;
begin
  FValidPassCount := 0;
end;

procedure TBreakPoint.SaveToStream(Stream: TStream);
var
  L: Integer;
begin
  Stream.Write(FEnabled, SizeOf(FEnabled));
  Stream.Write(FLine, SizeOf(FLine));
  Stream.write(FFunctionKey, SizeOf(FFunctionKey));
  Stream.Write(FPassCount, SizeOf(FPassCount));
  L := Length(FCondition);
  Stream.Write(L, sizeOf(L));
  if L > 0 then
    Stream.Write(FCondition[1], L);
end;

procedure TBreakPoint.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

procedure TBreakPoint.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TBreakPoint.SetFunctionKey(const Value: Integer);
begin
  FFunctionKey := Value;
end;

procedure TBreakPoint.SetLine(const Value: Integer);
begin
  FLine := Value;
end;

procedure TBreakPoint.SetPassCount(const Value: Integer);
begin
  FPassCount := Value;
end;

{ TBreakPointList }

function TBreakPointList.BreakPoint(Id, Line: Integer): TBreakPoint;
var
  I: Integer;
begin
  Result := nil;
  I := IndexByIdAndLine(Id, Line);
  if I > - 1 then
    Result := BreakPoints[I];
end;

function TBreakPointList.GetBreakPoints(Index: Integer): TBreakPoint;
begin
  LoadFromStorage;
  Result := TBreakPoint(Items[Index]);
end;

function TBreakPointList.IndexByIdAndLine(Id, Line: Integer): Integer;
var
  I: Integer;
begin
  LoadFromStorage;
  Result := -1;
  for I := 0 to count - 1 do
  begin
    if (BreakPoints[I].FFunctionKey = id) and (BreakPoints[I].FLine = Line) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TBreakPointList.LoadFromStorage;
{$IFDEF GEDEMIN}
var
  Str: TStream;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if not FLoaded then
  begin
    if not Assigned(UserStorage) then
      Exit;

    Str := TMemoryStream.Create;
    try
      UserStorage.ReadStream(sPropertyBreakPointsPath, cBreakPoits, Str);
      if Str.Size > 0 then
      begin
        Str.Position := 0;

        LoadFromStream(Str);
        FLoaded := True;
      end;
    finally
      Str.Free;
    end;
  end;
{$ENDIF}
end;

procedure TBreakPointList.LoadFromStream(Stream: TStream);
var
  LCount: Integer;
  B: TBreakPoint;
  I: Integer;
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Clear;
  Stream.ReadBuffer(LCount, SizeOf(LCount));
  for I := 0 to LCount -1 do
  begin
    B := TBreakPoint.Create;
    B.LoadFromStream(Stream);
    Add(B);
  end;
end;

procedure TBreakPointList.Reset;
var
  I: Integer;
begin
  for I := 0 to Count -1 do
    BreakPoints[I].Reset;
end;

procedure TBreakPointList.SaveToStorage;
{$IFDEF GEDEMIN}
var
  Str: TStream;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if not Assigned(UserStorage) then
    Exit;

  Str := TMemoryStream.Create;
  try
    SaveToStream(Str);
    Str.Position := 0;

    UserStorage.WriteStream(sPropertyBreakPointsPath, cBreakPoits, Str);
  finally
    Str.Free;
  end;
{$ENDIF}  
end;

procedure TBreakPointList.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  if Stream = nil then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.Write(Count, SizeOf(Count));
  for I := 0 to Count -1 do
    BreakPoints[I].SaveToStream(Stream);
end;

procedure TBreakPointList.SetBreakPoints(Index: Integer;
  const Value: TBreakPoint);
begin
  Items[Index].Free;
  Items[index] := Value;
end;

{ TCustomDebugLink }

procedure TCustomDebugLink.Reset;
begin
  if Assigned(Debugger) then
    Debugger.Reset;
end;

constructor TCustomDebugLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AddLink(Self);
end;

destructor TCustomDebugLink.Destroy;
begin
  FScript.Free;
  ReleaseLink(Self);
  if FForm <> nil then
    FreeNotification(FForm);
  FForm := nil;
  inherited;
end;

procedure TCustomDebugLink.DoRun;
var
  B: Boolean;
  Result: Variant;
  AnFunction: TrpCustomFunction;
  {$IFDEF GEDEMIN}
  SL: TStrings;
  I: Integer;
  {$ENDIF}
begin
  Result := Null;
  B := (Debugger <> nil) and not Debugger.FunctionRun;
  try
    if Assigned(ScriptFactory) then
    begin
      ScriptFactory.ReloadFunction(Script.FunctionKey);
{      if (Debugger <> nil) and (PropertySettings.DebugSet.UseDebugInfo) and
        not Script.BreakPointsPrepared then}
      Debugger.PrepareExecuteScript(Script);

      if glbFunctionList <> nil then
      begin
        AnFunction := glbFunctionList.FindFunction(Script.FunctionKey);
        if AnFunction <> nil then
        begin
          try
            AnFunction.Assign(Script);
          finally
            glbFunctionList.ReleaseFunction(AnFunction);
          end
        end else
        begin
          AnFunction := TrpCustomFunction.Create;
          AnFunction.Assign(Script);
          glbFunctionList.AddFunction(AnFunction);
        end;
        {$IFDEF GEDEMIN}
        SL := TStringList.Create;
        try
          ReadAddFunction(Script.FunctionKey, SL, Script.Script.Text,
            Script.ModuleCode, gdcBaseManager.ReadTransaction);
          Script.IncludingList.Clear;
          for I := 0 to SL.Count - 1 do
          begin
            Script.IncludingList.Add(Integer(SL.Objects[I]));
          end;
        finally
          SL.Free;
        end;
        {$ENDIF}
        ScriptFactory.AddScript(Script, AnFunction.ModuleCode, False);
      end;


      Result := VarArrayOf([]);
      Result := Script.EnteredParams.GetVariantArray;
      try
        if ScriptFactory.InputParams(Script, Result) then
        begin
          ScriptFactory.ExecuteFunction(Script, Result);
        end;
      except
         ScriptFactory.ReloadFunction(Script.FunctionKey);
         Result := Null;
      end;
    end else
      raise Exception.Create('Компонент ScriptFactory не создан.');
  finally
    //Данная остановка дебагера необходима на случай отмены при
    //запросе параметров
    if (Debugger <> nil) and B then Debugger.Stop;
  end;
end;

procedure TCustomDebugLink.Evaluate(AEval: string);
begin
  with TdlgEvaluate.Create(Self) do
  begin
    cbExpression.Text := AEval;
    ShowModal;
  end;
end;

function TCustomDebugLink.GetFunctionKey: Integer;
begin
  Result := Script.FunctionKey;
end;

function TCustomDebugLink.GetScript: TrpCustomFunction;
begin
  if FScript = nil then
    FScript := TrpCustomFunction.Create;
  Result := FScript;
end;

procedure TCustomDebugLink.GotoCursor(Y: Integer);
begin
  if not Assigned(Debugger)then
    Exit;

  if not Debugger.IsPaused then
  begin
    FRun := True;
    try
      Debugger.GotoToLine(FunctionKey, Y - 1);
      DoRun;
    finally
      FRun := False;
    end;
  end else
    Debugger.GotoToLine(FunctionKey, Y - 1);
end;

function TCustomDebugLink.IsExecuteScript: Boolean;
begin
  Result := (Debugger <> nil) and
    ((Debugger.ExecuteScriptFunction = FunctionKey) or
    (Debugger.LastScriptFunction = FunctionKey)) and not Debugger.IsStoped;
end;

procedure TCustomDebugLink.Run;
begin
  if not Assigned(Debugger) then
    Exit;

  if (not Debugger.IsPaused) and (not FRun) then
  begin
    if not FRun then
    begin
      FRun := True;
      try
        Debugger.Run;
        DoRun;
      finally
        FRun := False;
      end;
    end;
  end else
    Debugger.Run;
end;

procedure TCustomDebugLink.SetForm(const Value: TForm);
begin
  FForm := Value;
end;

procedure TCustomDebugLink.ShowForm;
begin
  if FForm <> nil then
  begin
    EnableWindow(FForm.Handle, True);

    FForm.Show;
  end;
end;

procedure TCustomDebugLink.Step;
begin
  if not Assigned(Debugger) then
    Exit;

  if (not Debugger.IsPaused) and (not FRun)  then
  begin
    FRun := True;
    try
      Debugger.Step;
      DoRun;
    finally
      FRun := False;
    end;
  end else
    Debugger.Step;
end;

procedure TCustomDebugLink.StepOver;
begin
  if not Assigned(Debugger) then
    Exit;

  if (not Debugger.IsPaused) and (not FRun) then
  begin
    FRun := True;
    try
      Debugger.Step;
      DoRun;
    finally
      FRun := False;
    end;
  end else
    Debugger.StepOver;
end;
procedure TCustomDebugLink.ToggleBreakPoint(Line: Integer);
var
  BreakPoint: TBreakPoint;
begin
  BreakPoint := BreakPointList.BreakPoint(FunctionKey,  Line);
  if BreakPoint = nil then
  begin
    BreakPoint := TBreakPoint.Create;
    BreakPoint.FunctionKey := FunctionKey;
    BreakPoint.Line := Line;
    BreakPointlist.Add(BreakPoint);
  end else
    BreakPointList.Remove(BreakPoint);
  BreakPointList.SaveToStorage;

  FormInvalidate;
end;

procedure TCustomDebugLink.FormInvalidate;
begin

end;

procedure TCustomDebugLink.OnDebuggerStateChange(Sender: TObject; OldState,
  NewState: TDebuggerState);
begin
  FormInvalidate;
end;

{ TFinallyRec }

{procedure TFinallyRec.Clear;
begin
  ParamArray := Unassigned;
  Line := 0;
  FinallyScript := '';
end;}

initialization
finalization
  FreeAndNil(_DebugLinkList);
end.
