// ShlTanya, 27.02.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    rp_BaseReport_unit.pas

  Abstract

    Gedemin project. Basic classes for REPORT SYSTEM.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    ~01.05.01    JKL        Initial version.

--}

unit rp_BaseReport_unit;

interface

uses
  Classes, IBDatabase, DB, Windows, SysUtils, Contnrs, IBQuery,
  gd_SetDatabase, rp_report_const, gd_MultiStringList, prm_ParamFunctions_unit,
  gd_KeyAssoc, Gedemin_TLB, DBClient, gdcBaseInterface;

const
  MDPrefix = 'MDP';
  IndexPrefix = 'INP';

const
  LocFilterFolderName = 'Filter\FilterParams\';

type
  TVarArByte = array[0..15] of Byte;

type
  TVarStream = class
  private
    FStream: TStream;
    function GetSize: Integer;
    function GetPosition: Integer;
    procedure SetPosition(const AnPos: Integer);
    function GetDataSize(const AnVarType: Integer): Integer;
  public
    constructor Create(SourceStream: TStream);
    property Size: Integer read GetSize;
    property Position: Integer read GetPosition write SetPosition;
    function Read(var Buffer: Variant): Integer;
    function Write(const Buffer: Variant): Integer;
  end;

type
  TrpCustomFunction = class
  private
    FFunctionKey: TID;
    FName: String;
    FComment: String;
    FScript: TStrings;
    FModule: String;
    FLanguage: String;
    FModifyDate: TDateTime;
    FEnteredParams: TgsParamList;
    FBreakPointsPrepared: Boolean;
    FBreakPoints: TStream;
    FIncludingList: TgdKeyIntAssoc;
    FModuleCode: TID;
    FOnBreakPointsPrepared: TNotifyEvent;

    procedure SetComment(const Value: String);
    procedure SetModifyDate(const Value: TDateTime);
    procedure SetModuleCode(const Value: TID);
    procedure SetOnBreakPointsPrepared(const Value: TNotifyEvent);
    function GetBreakPoints: TStream;
    function GetBreakPointsSize: Integer;

  protected
    FExternalUsedCounter: Integer;

    procedure SetBreakPointsPrepared(const Value: Boolean);

  public

    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TrpCustomFunction);
    procedure ReadFromDataSet(const DataSet: TDataSet);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    //Добаляет в скрипт все инклюд-фунуции
    procedure PrepareScript(Transaction: TIBTransaction);

    property FunctionKey: TID read FFunctionKey write FFunctionKey;
    property Name: String read FName write FName;
    property Comment: String read FComment write SetComment;
    property Script: TStrings read FScript write FScript;
    property Module: String read FModule write FModule;
    property ModuleCode: TID read FModuleCode write SetModuleCode;
    property Language: String read FLanguage write FLanguage;
    property ModifyDate: TDateTime read FModifyDate write SetModifyDate;
    property EnteredParams: TgsParamList read FEnteredParams;
    property IncludingList: TgdKeyIntAssoc read FIncludingList;
    property BreakPoints: TStream read GetBreakPoints;
    property BreakPointsSize: Integer read GetBreakPointsSize;
    property BreakPointsPrepared: Boolean read FBreakPointsPrepared write SetBreakPointsPrepared;

    property OnBreakPointsPrepared: TNotifyEvent read FOnBreakPointsPrepared write SetOnBreakPointsPrepared;
  end;

type
  TReportResult = class(TStringList)
  private
    FMasterDetail: TFourStringList;
    FTempStream: TMemoryStream;
    FIsStreamData: Boolean;
    FBaseQueryList: IgsQueryList;
    
    function GetDataSet(const AnIndex: Integer): TDataSet;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ViewResult;

    property DataSet[const AnIndex: Integer]: TDataSet read GetDataSet;
    function DataSetByName(const AnName: String): TDataSet;
    property TempStream: TMemoryStream read FTempStream;
    property IsStreamData: Boolean read FIsStreamData write FIsStreamData;

    procedure Assign(const AnReportResult: TReportResult); reintroduce;
    procedure AssignTempStream(const AnStream: TStream);
    procedure Clear; override;

    function AddDataSet(const AnName: String): Integer; overload; virtual;
    function AddDataSet(const AnName: String; const AnDataSet: TDataSet): Integer; overload; virtual;
    procedure AddDataSetList(const AnBaseQueryList: Variant); virtual;
    procedure DeleteDataSet(const AnIndex: Integer); virtual;
    procedure AddMasterDetail(const AnMasterTable, AnMasterField, AnDetailTable,
     AnDetailField: String);

    procedure LoadFromStream(AnStream: TStream); reintroduce; virtual;
    procedure SaveToStream(AnStream: TStream); reintroduce;

    procedure LoadFromFile(AnFileName: String); reintroduce;
    procedure SaveToFile(AnFileName: String); reintroduce;

    property _MasterDetail: TFourStringList read FMasterDetail;
    property QueryList: IgsQueryList read FBaseQueryList write FBaseQueryList;
  end;

  TrpResultStructure = class
  private
    FReportResult: TReportResult;
    FExecuteTime: TDateTime;
    FCreateDate: TDateTime;
    FLastUseDate: TDateTime;
    FParams: Variant;
    FCRCParam: Integer;
    FParamOrder: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TrpResultStructure);
    procedure ReadFromDataSet(const AnDataSet: TDataSet);

    property ReportResult: TReportResult read FReportResult;
    property ExecuteTime: TDateTime read FExecuteTime write FExecuteTime;
    property CreateDate: TDateTime read FCreateDate write FCreateDate;
    property LastUseDate: TDateTime read FLastUseDate write FLastUseDate;
    property Params: Variant read FParams write FParams;
    property ParamOrder: Integer read FParamOrder write FParamOrder;
    property CRCParam: Integer read FCRCParam write FCRCParam;
  end;

  TrpResultList = class(TObjectList)
  private
    function GetReportResult(const AnIndex: Integer): TrpResultStructure;
    procedure SetReportResult(const AnIndex: Integer; const AnValue: TrpResultStructure);
  public
    procedure ReadFromDataSet(const AnDataSet: TDataSet);
    function AddReportResult(const AnReportResult: TrpResultStructure): Integer;
    property ResultStructure[const AnIndex: Integer]: TrpResultStructure read GetReportResult write SetReportResult;
    procedure DeleteResult(const AnIndex: Integer);
    procedure Assign(Source: TrpResultList);
  end;

  TReportTemplate = class(TMemoryStream)
  public
    procedure Assign(const AnReportTemplate: TReportTemplate);
  end;

  TTemplateStructure = class
  private
    FTemplateKey: TID;
    FName: String;
    FDescription: String;
    FReportTemplate: TReportTemplate;
    FTemplateType: String;
    FTemplateDelphiType: TTemplateType;
    FAFull, FAChag, FAView: Integer;

    procedure SetReportTemplate(AnValue: TReportTemplate);
    procedure SetTemplateType(AnValue: String);
    procedure SetTemplateDelphiType(AnValue: TTemplateType);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(AnSource: TTemplateStructure);
    procedure ReadFromDataSet(const AnDataSet: TDataSet);
    procedure Reset;
    procedure SaveToStream(AnStream: TStream);
    procedure LoadFromStream(AnStream: TStream);

    property TemplateKey: TID read FTemplateKey write FTemplateKey;
    property Name: String read FName write FName;
    property Description: String read FDescription write FDescription;
    property ReportTemplate: TReportTemplate read FReportTemplate write SetReportTemplate;
    property TemplateType: String read FTemplateType write SetTemplateType;
    property RealTemplateType: TTemplateType read FTemplateDelphiType write SetTemplateDelphiType;
    property AFull: Integer read FAFull;
    property AChag: Integer read FAChag;
    property AView: Integer read FAView;
  end;

  TCustomReport = class
  protected
    FReportKey: TID;
    FReportName: String;
    FReportDescription: String;

    FParamFunction: TrpCustomFunction;
    FMainFunction: TrpCustomFunction;
    FEventFunction: TrpCustomFunction;

    FReportResult: TrpResultList;
    FTemplateStructure: TTemplateStructure;

    FFrqRefresh: Integer;	        // Частота обновления
    FIsRebuild: Boolean;             // Необходимость сохранять результат
    FIsLocalExecute: Boolean;
    FPreview: Boolean;
    FModalPreview: Boolean;
    FReportGroupKey: TID;

    FAFull, FAChag, FAView: Integer;

    FServerKey: TID;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(AnSource: TCustomReport);
    procedure ReadFromDataSet(const AnDataSet: TDataSet; const AnReadTemplate: Boolean = True);

    property ReportKey: TID read FReportKey;
    property ReportName: String read FReportName;
    property Description: String read FReportDescription;
    property ParamFunction: TrpCustomFunction read FParamFunction;
    property MainFunction: TrpCustomFunction read FMainFunction;
    property EventFunction: TrpCustomFunction read FEventFunction;
    property ReportResultList: TrpResultList read FReportResult;
    property TemplateStructure: TTemplateStructure read FTemplateStructure;
    property FrqRefresh: Integer read FFrqRefresh write FFrqRefresh;
    property IsRebuild: Boolean read FIsRebuild;
    property ServerKey: TID read FServerKey;
    property IsLocalExecute: Boolean read FIsLocalExecute;
    property Preview: Boolean read FPreview;
    property ModalPreview: Boolean read FModalPreview;
    property ReportGroupKey: TID read FReportGroupKey;
    property AFull: Integer read FAFull;
    property AChag: Integer read FAChag;
    property AView: Integer read FAView;
  end;

  TReportGroup = class(TObjectList)
  private
    FParentBranch: TReportGroup;
    FGroupKey: TID;
    FName: String;
    FReportList: TDnIntArray;

    function GetReportCount: Integer;
    function GetGroupCount: Integer;
    function GetGroup(const Index: Integer): TReportGroup;
  public
    constructor Create;
    destructor Destroy; override;

    function AddGroup: Integer; overload;
    function AddGroup(const AnGroupKey: TID; const AnName: String): TReportGroup; overload;
    procedure DeleteGroup(const AnIndex: Integer);
    property Groups[const Index: Integer]: TReportGroup read GetGroup;

    procedure ReadData(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);

    property GroupKey: TID read FGroupKey;
    property GroupName: String read FName write FName;
    property ReportCount: Integer read GetReportCount;
    property GroupCount: Integer read GetGroupCount;
    property ParentBranch: TReportGroup read FParentBranch;
    property ReportList: TDnIntArray read FReportList;
  end;

  TReportList = class(TObjectList)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    procedure SetReport(const AnIndex: Integer; const AnReport: TCustomReport);
    function GetReport(const AnIndex: Integer): TCustomReport;
    procedure SetDatabase(const AnValue: TIBDatabase);
    function GetDatabase: TIBDatabase;
    procedure SetTransaction(const AnValue: TIBTransaction);
    function GetTransaction: TIBTransaction;
  protected

  public
    constructor Create;
    destructor Destroy; override;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

    procedure ReadFromDataSet(const AnDataSet: TDataSet);
    procedure Refresh;
    procedure Assign(AnSource: TReportList);
    function AddReport: Integer; overload;
    function AddReport(const AnSource: TCustomReport): Integer; overload;
    procedure DeleteReport(const AnIndex: Integer);
    // Поиск отчета в списке отчетов
    function FindReport(const AnReportKey: TID): TCustomReport;
    property Reports[const AnIndex: Integer]: TCustomReport read GetReport write SetReport;
    function ReportByKey(const AnReportKey: TID): TCustomReport;
  end;

type
  TBuildReport = procedure(const AnReportKey: TID; const AnIsRebuild: Boolean) of object;
  TExecuteReport = function(const AnReport: TCustomReport; const AnResult: TReportResult;
   out AnErrorMessage: String; const AnIsResult: Boolean): Boolean of object;
  TExecuteFunction = function(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
     var AnParamAndResult: Variant): Boolean of object;
  TViewReport = procedure(const AnReport: TCustomReport; const AnReportResult: TReportResult;
   const AnParam: Variant; const AnBuildDate: TDateTime) of object;
  TRefreshReportData = procedure of object;
  TLoadReportFile = function(const AnGroupKey: TID; const AnFileName: String): Boolean of object;
  TSaveReportFile = procedure(const AnReportKey: TID;
     const AnFileName: String) of object;

  function GetParamCRC(const AnParam: Variant): Integer;
  function CheckParamCRC(const AnParam: Variant; const OldCrc: Cardinal): Boolean;
  function CompareParams(const AnFirstParam, AnSecondParam: Variant): Boolean;

implementation

uses
  {$IFDEF GEDEMIN}
   rp_dlgViewResult_unit,
   {$ENDIF}
   jclMath, IBSQL, IBCustomDataSet,
   scr_i_FunctionList, gs_Exception, ZLib
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
   ;

var
  {При добавлении в скрипт-функцию других функций по комманде include,
  возможна циклическая ссылка, когда функция А ссылается на функцию Б
  каторая в свою очередь ссылается на А. Для исключения зацикливания
  программы, будем регистрировать в списке уже добавленные функции}
  FunctionList: TObjectList;

  {$IFDEF DEBUG}
  FTotalCount, FAllocatedCount: Integer;
  {$ENDIF}

const
  // признак начала записи потока TrpCustomFunction
  rpBF = 'BF';
  // признак окончания записи потока TrpCustomFunction
  rpEF = 'EF';

type
  TStreamInt = Longint;
  TStreamDate = TDateTime;

type
  TFunctionName = class
  private
    FName: String;
  public
    property Name: String read FName write FName;
  end;

function GetParamCRC(const AnParam: Variant): Integer;
var
  Str: TMemoryStream;
  VarStr: TVarStream;
  ArBt: TDnByteArray;
begin
  Str := TMemoryStream.Create;
  try
    VarStr := TVarStream.Create(Str);
    try
      VarStr.Write(AnParam);
    finally
      VarStr.Free;
    end;
    SetLength(ArBt, Str.Size);
    Str.Position := 0;
    Str.ReadBuffer(ArBt[0], Str.Size);
    Result := Crc32(ArBt, Length(ArBt), 0);
  finally
    Str.Free;
  end;
end;

function CheckParamCRC(const AnParam: Variant; const OldCrc: Cardinal): Boolean;
var
  Str: TMemoryStream;
  VarStr: TVarStream;
  ArBt: TDnByteArray;
begin
  Str := TMemoryStream.Create;
  try
    VarStr := TVarStream.Create(Str);
    try
      VarStr.Write(AnParam);
    finally
      VarStr.Free;
    end;
    SetLength(ArBt, Str.Size);
    Str.Position := 0;
    Str.ReadBuffer(ArBt[0], Str.Size);
    Result := CheckCrc32(ArBt, Length(ArBt), OldCrc) = 0;
  finally
    Str.Free;
  end;
end;

function CompareParams(const AnFirstParam, AnSecondParam: Variant): Boolean;
var
  BufType, LocType: Integer;
  I: Integer;
  LowB, HighB: Integer;
begin
  Result := VarType(AnFirstParam) = VarType(AnSecondParam);
  if not Result then
    Exit;
  BufType := VarType(AnFirstParam);
  LocType := BufType and $F000;
  if LocType = 0 then
    LocType := BufType;
  case LocType of
    varSmallint, varInteger, varSingle, varDouble, varCurrency, varDate,
    varError, varBoolean, varByte, varString, varOleStr:
      Result := AnFirstParam = AnSecondParam;

    varArray:
    begin
      Result := (VarArrayLowBound(AnFirstParam, 1) = VarArrayLowBound(AnSecondParam, 1))
       and (VarArrayHighBound(AnFirstParam, 1) = VarArrayHighBound(AnSecondParam, 1));
      if not Result then
        Exit;
      LowB := VarArrayLowBound(AnFirstParam, 1);
      HighB := VarArrayHighBound(AnFirstParam, 1);
      for I := LowB to HighB do
        Result := Result and CompareParams(AnFirstParam[I], AnSecondParam[I]);
    end;

    varEmpty, varDispatch:
      Result := VarType(AnFirstParam) = VarType(AnSecondParam);

  else
    raise Exception.Create('varDispatch, varAny, varByRef not supported');
  end;
end;

// TVarStream

constructor TVarStream.Create(SourceStream: TStream);
begin
  Assert(SourceStream <> nil);
  FStream := SourceStream;
end;

function TVarStream.GetSize: Integer;
begin
  Result := FStream.Size;
end;

function TVarStream.GetPosition: Integer;
begin
  Result := FStream.Position;
end;

procedure TVarStream.SetPosition(const AnPos: Integer);
begin
  FStream.Position := AnPos;
end;

function TVarStream.GetDataSize(const AnVarType: Integer): Integer;
begin
  Result := 0;
  case AnVarType of
    varSmallint: Result := SizeOf(Smallint);
    varInteger:  Result := SizeOf(Integer);
    varSingle:   Result := SizeOf(Single);
    varDouble:   Result := SizeOf(Double);
    varCurrency: Result := SizeOf(Currency);
    varDate:     Result := SizeOf(Double);
    varError:    Result := SizeOf(Longword);
    varBoolean:  Result := SizeOf(WordBool);
    varByte:     Result := SizeOf(Byte);
    varOleStr, varDispatch, varUnknown, varString,
     varAny, varArray, varByRef:
      Result := SizeOf(Pointer);
  end;
end;

function TVarStream.Read(var Buffer: Variant): Integer;
var
  TempStr: String;
  StartPos: Integer;

  function LoadElement: Variant;
  var
    S: String;
    BufType, LocType: Integer;
    I: Integer;
    LowB, HighB: Integer;
  begin
    FStream.ReadBuffer(BufType, SizeOf(BufType));
    LocType := BufType and $F000;
    if LocType = 0 then
      LocType := BufType;
    case LocType of
      varSmallint, varInteger, varSingle, varDouble, varCurrency, varDate,
      varError, varBoolean, varByte:
      begin
        Result := VarAsType(0, BufType);
        //Integer((@AnElement)^) := BufType;
        FStream.ReadBuffer(I, SizeOf(I));
        if I <= SizeOf(Double) then
          FStream.ReadBuffer(TVarArByte((@Result)^)[SizeOf(Word) * 4], I)
        else
          FStream.Seek(I, soFromCurrent);
      end;

      varArray:
      begin
        FStream.ReadBuffer(LowB, SizeOf(LowB));
        FStream.ReadBuffer(HighB, SizeOf(HighB));
        Result := VarArrayCreate([LowB, HighB], BufType and $FF);
        for I := LowB to HighB do
        begin
          //LoadElement(TempVar);
          Result[I] := LoadElement;
        end;
      end;

      varString, varOleStr:
      begin
        FStream.ReadBuffer(LowB, SizeOf(LowB));
        if LowB > 0 then
        begin
          SetLength(S, LowB);
          FStream.ReadBuffer(S[1], LowB);
          Result := S;
          SetLength(S, 0);
        end else
          Result := VarAsType('', varString);
      end;

      varEmpty, varDispatch, varNull:
      begin
        Result := Unassigned;
      end;
    else
      raise Exception.Create('varUnknown, varAny not supported');
    end;
  end;
begin
  if FStream.Position = FStream.Size then
  begin
    Result := 0;
    Buffer := Unassigned;
    Exit;
  end;

  StartPos := FStream.Position;

  SetLength(TempStr, Length(VarBegin));
  FStream.ReadBuffer(TempStr[1], Length(VarBegin) * SizeOf(Char));
  Assert(TempStr = VarBegin);

  Buffer := LoadElement;

  SetLength(TempStr, Length(VarEnd));
  FStream.ReadBuffer(TempStr[1], Length(VarEnd) * SizeOf(Char));
  Assert(TempStr = VarEnd);

  Result := FStream.Position - StartPos;
end;

function TVarStream.Write(const Buffer: Variant): Integer;
var
  StartPos: Integer;

  procedure SaveElement(const AnElement: Variant);
  var
    S: String;
    BufType, LocType: Integer;
    I: Integer;
    LowB, HighB: Integer;
  begin
    BufType := VarType(AnElement);
    LocType := BufType and $F000;
    if LocType = 0 then
      LocType := BufType;
    FStream.Write(BufType, SizeOf(BufType));
    case LocType of
      varSmallint, varInteger, varSingle, varDouble, varCurrency, varDate,
      varError, varBoolean, varByte:
      begin
        I := GetDataSize(VarType(AnElement));
        FStream.Write(I, SizeOf(I));
        FStream.Write(TVarArByte((@AnElement)^)[SizeOf(Word) * 4], I);
      end;

      varArray:
      begin
        LowB := VarArrayLowBound(AnElement, 1);
        FStream.Write(LowB, SizeOf(LowB));
        HighB := VarArrayHighBound(AnElement, 1);
        FStream.Write(HighB, SizeOf(HighB));
        for I := VarArrayLowBound(AnElement, 1) to VarArrayHighBound(AnElement, 1) do
          SaveElement(AnElement[I]);
      end;

      varString, varOleStr:
      begin
        S := VarAsType(AnElement, varString);
        LowB := Length(S);
        FStream.Write(LowB, SizeOf(LowB));
        FStream.Write(S[1], LowB);
      end;

      varEmpty, varDispatch, varNull:
      begin
        // Для "No Query" параметров сохраняется только инф. о типе,
        // как о ссылке
      end;
    else
      raise Exception.Create('varUnknown, varAny, varByRef not supported');
    end;
  end;
begin
  StartPos := FStream.Position;
  FStream.Write(VarBegin, Length(VarBegin) * SizeOf(Char));
  SaveElement(Buffer);
  FStream.Write(VarEnd, Length(VarEnd) * SizeOf(Char));
  Result := FStream.Position - StartPos;
end;

// TrpCustomFunction

constructor TrpCustomFunction.Create;
begin
  inherited Create;

  FScript := TStringList.Create;
  FEnteredParams := TgsParamList.Create;
  FIncludingList := TgdKeyIntAssoc.Create;
  FBreakPoints := nil;
  FExternalUsedCounter := 0;

  {$IFDEF DEBUG}
  Inc(FTotalCount);
  {$ENDIF}
end;

destructor TrpCustomFunction.Destroy;
begin
  FEnteredParams.Free;
  FScript.Free;
  FIncludingList.Free;
  FreeAndNil(FBreakPoints);
  
  inherited Destroy;
end;

procedure TrpCustomFunction.Assign(Source: TrpCustomFunction);
begin
  ModuleCode := Source.ModuleCode;
  FFunctionKey := Source.FunctionKey;
  FName := Source.Name;
  FComment := Source.Comment;
  FScript.Text := Source.FScript.Text;
//  FDisplayScript.Assign(Source.FDisplayScript);
  FModule := Source.Module;
  FLanguage := Source.Language;
  FModifyDate := Source.ModifyDate;
//  FAdditionalFunctions.Assign(Source.AdditionalFunctions);
  FEnteredParams.Assign(Source.EnteredParams);
//  FAFull := Source.AFull;
//  FAChag := Source.AChag;
//  FAView := Source.AView;
  FIncludingList.Clear;
  FIncludingList.Assign(Source.IncludingList);

  if Source.BreakPointsSize = 0 then
    FreeAndNil(FBreakPoints)
  else
  begin
    BreakPoints.Size:= 0; // обращение к свойству, а не к полю создаст объект, если его нет
    Source.BreakPoints.Position := 0;
    FBreakPoints.CopyFrom(Source.BreakPoints, Source.BreakPoints.Size);
    FBreakPoints.Position := 0;
  end;

  FBreakPointsPrepared := Source.FBreakPointsPrepared;
end;

procedure TrpCustomFunction.ReadFromDataSet(const DataSet: TDataSet);
var
  BStr: TStream;
begin
  Assert(DataSet is TIBCustomDataSet);

  if DataSet.Active and (not DataSet.EOF) then
  begin
    FFunctionKey := GetTID(DataSet.FieldByName('id'));
    ModuleCode := GetTID(DataSet.FieldByName('modulecode'));
    FName := DataSet.FieldByName('name').AsString;
    FComment := DataSet.FieldByName('comment').AsString;
    FScript.Text := DataSet.FieldByName('script').AsString;
    FModule := DataSet.FieldByName('module').AsString;
    FLanguage := DataSet.FieldByName('language').AsString;
    FModifyDate := DataSet.FieldByName('editiondate').AsDateTime;
    FEnteredParams.Clear;
    if not DataSet.FieldByName('enteredparams').IsNull then
    begin
      try
        BStr := DataSet.CreateBlobStream(DataSet.FieldByName('enteredparams'), DB.bmRead);
        try
          FEnteredParams.LoadFromStream(BStr);
        finally
          BStr.Free;
        end;
      except
        FEnteredParams.Clear;
      end;
    end;
  end else
  begin
    FFunctionKey := 0;
    ModuleCode := 0;
    FName := '';
    FComment := '';
    FScript.Text := '';
    FModule := '';
    FLanguage := '';
    FModifyDate := 0;
    FEnteredParams.Clear;
  end;

  PrepareScript((DataSet as TIBCustomDataSet).Transaction);
  FBreakPointsPrepared := False;
end;

procedure TrpCustomFunction.LoadFromStream(Stream: TStream);
var
  TempStr: String;
  Len: TStreamInt;
  Size, LenID: Integer;
begin
  // проверяем признак начала записи потока
  Len := Length(rpBF);
  SetLength(TempStr, Len);
  Stream.ReadBuffer(PChar(TempStr)^, Len);
  if TempStr <> rpBF then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data'));
  {метка сохранения ID в Int64}
  LenID := GetLenIDinStream(@Stream);
  Stream.ReadBuffer(FFunctionKey, LenID);

//  Stream.ReadBuffer(Len, SizeOf(Len));
//  SetLength(FName, Len);
//  Stream.ReadBuffer(FName[1], Len);
  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(TempStr, Len);
  Stream.ReadBuffer(TempStr[1], Len);
  FName := ZDecompressStr(TempStr);

//  Stream.ReadBuffer(Len, SizeOf(Len));
//  SetLength(FComment, Len);
//  Stream.ReadBuffer(FComment[1], Len);
  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(TempStr, Len);
  Stream.ReadBuffer(TempStr[1], Len);
  FComment := ZDecompressStr(TempStr);

  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(TempStr, Len);
  Stream.ReadBuffer(TempStr[1], Len);
  FScript.Text := ZDecompressStr(TempStr);

//  Stream.ReadBuffer(Len, SizeOf(Len));
//  SetLength(FModule, Len);
//  Stream.ReadBuffer(FModule[1], Len);
  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(TempStr, Len);
  Stream.ReadBuffer(TempStr[1], Len);
  FModule := ZDecompressStr(TempStr);

  Stream.ReadBuffer(FModuleCode, LenID);

//  Stream.ReadBuffer(Len, SizeOf(Len));
//  SetLength(FLanguage, Len);
//  Stream.ReadBuffer(FLanguage[1], Len);
  Stream.ReadBuffer(Len, SizeOf(Len));
  SetLength(TempStr, Len);
  Stream.ReadBuffer(TempStr[1], Len);
  FLanguage := ZDecompressStr(TempStr);

  Stream.ReadBuffer(FModifyDate, SizeOf(FModifyDate));

  FEnteredParams.LoadFromStream(Stream);

  FIncludingList.Clear;
  FIncludingList.LoadFromStream(Stream);

  Stream.ReadBuffer(FBreakPointsPrepared, SizeOf(FBreakPointsPrepared));

  if FBreakPointsPrepared then
  begin
    Stream.ReadBuffer(Size, SizeOf(Size));
    if Size = 0 then
      FreeAndNil(FBreakPoints)
    else
    begin
      BreakPoints.Size := 0; // обязательно обращение к свойству!
      FBreakPoints.CopyFrom(Stream, Size);
      FBreakPoints.Position := 0;
    end;
  end;

  // проверяем признак окончания записи потока
  Len := Length(rpEF);
  Tempstr := '';
  SetLength(TempStr, Len);
  Stream.ReadBuffer(PChar(TempStr)^, Len);
  if TempStr <> rpEF then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data'));
end;

procedure TrpCustomFunction.SaveToStream(Stream: TStream);
var
  Len: TStreamInt;
  Str: String;
  Size, LenID: Integer;
begin
  // признак начала записи потока
  Stream.Write(PChar(rpBF)^, Length(rpBF));
  {метка сохранения ID в Int64}
  LenID := SetLenIDinStream(@Stream);

  Stream.Write(FFunctionKey, LenID);

  Str := ZCompressStr(FName);
  Len := Length(Str);
  Stream.Write(Len, SizeOf(Len));
  Stream.Write(Str[1], Len);
//  Len := Length(FName);
//  Stream.Write(Len, SizeOf(Len));
//  Stream.Write(FName[1], Len);

  Str := ZCompressStr(FComment);
  Len := Length(Str);
  Stream.Write(Len, SizeOf(Len));
  Stream.Write(Str[1], Len);
//  Len := Length(FComment);
//  Stream.Write(Len, SizeOf(Len));
//  Stream.Write(FComment[1], Len);

  Str := ZCompressStr(FScript.Text);
  Len := Length(Str);
  Stream.Write(Len, SizeOf(Len));
  Stream.Write(Str[1], Len);
//  Len := Length(FScript.Text);
//  Stream.Write(Len, SizeOf(Len));
//  Stream.Write(FScript.Text[1], Len);

  Str := ZCompressStr(FModule);
  Len := Length(Str);
  Stream.Write(Len, SizeOf(Len));
  Stream.Write(Str[1], Len);
//  Len := Length(FModule);
//  Stream.Write(Len, SizeOf(Len));
//  Stream.Write(FModule[1], Len);

  Stream.Write(FModuleCode, LenId);

  Str := ZCompressStr(FLanguage);
  Len := Length(Str);
  Stream.Write(Len, SizeOf(Len));
  Stream.Write(Str[1], Len);
//  Len := Length(FLanguage);
//  Stream.Write(Len, SizeOf(Len));
//  Stream.Write(FLanguage[1], Len);

  Stream.Write(FModifyDate, SizeOf(FModifyDate));

  FEnteredParams.SaveToStream(Stream);
  FIncludingList.SaveToStream(Stream);

  Stream.Write(FBreakPointsPrepared, SizeOf(FBreakPointsPrepared));

  if FBreakPointsPrepared then
  begin
    Size := BreakPointsSize;
    Stream.Write(Size, SizeOf(Size));

    if Size > 0 then
    begin
      FBreakPoints.Position := 0;
      Stream.CopyFrom(FBreakPoints, Size);
    end;
  end;
  // признак окончания записи потока
  Stream.Write(rpEF, Length(rpEF));
end;

procedure TrpCustomFunction.PrepareScript(Transaction: TIBTransaction);
var
  LocSQL: TIBSQL;
  InTran: Boolean;
  CommentSymbol: string;

  {Мы должны знать в какой момент необходимо высвободить список
  имен функции. Т.к данная функция рекурсивная то в функции в
  которой создан список будем устанавливать в True этот флаг}
  ObjectCreate: Boolean;

  //Функция проверяет есть ли функция в списке функция уже
  //включенных в скрипт
  function IsAlReadyAdd(Name: String): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to FunctionList.Count -1 do
    begin
      if UpperCase(Name) = UpperCase((TObject(FunctionList[I]) as TFunctionName).Name) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

begin
  if FFunctionKey > 0 then
  begin
    ObjectCreate := False;
    if not Assigned(FunctionList) then
    begin
      FunctionList := TObjectList.Create(True);
      ObjectCreate := True;
    end;

    FunctionList.Add(TFunctionName.Create);
    TFunctionName(FunctionList.Last).Name := Self.Name;

    if UpperCase(FLanguage) = UpperCase('VBScript') then
      CommentSymbol := ''''
    else
      CommentSymbol := '//';

  //  if Script <> nil then
    begin
      LocSQL := TIBSQL.Create(nil);
      try
        InTran := Transaction.InTransaction;
        if not InTran then
          Transaction.StartTransaction;
        try
          LocSQL.Transaction := Transaction;
          LocSQL.SQL.Text :=
           'SELECT fc.id, fc.modulecode FROM gd_function fc, rp_additionalfunction af ' +
           'WHERE fc.id = af.addfunctionkey AND af.mainfunctionkey = :MFK';
          SetTID(LocSQL.ParamByName('MFK'), FFunctionKey);
          LocSQL.ExecQuery;
          FIncludingList.Clear;
          while not LocSQL.Eof do
          begin
            FIncludingList.ValuesByIndex[FIncludingList.Add(GetTID(LocSQL.Fields[0]))] :=
              GetTID(LocSQL.Fields[1]);

            {$IFNDEF LOADMODULE}
              if Assigned(glbFunctionList) then
                glbFunctionList.FindFunction(GetTID(LocSQL.Fields[0]));
            {$ENDIF}
            LocSQL.Next;
          end;
          LocSQL.Close;
        finally
          if not InTran then
          begin
            try
              Transaction.Commit;
            except
              Transaction.Rollback;
            end;
          end;
        end;
      finally
        LocSQL.Free;
      end;
    end;

    if ObjectCreate then
    begin
      FunctionList.Free;
      FunctionList := nil;
    end;
  end else
  begin
    FIncludingList.Clear;
  end;
end;


procedure TrpCustomFunction.SetBreakPointsPrepared(const Value: Boolean);
begin
  if FBreakPointsPrepared and Value then
    raise Exception.Create('Скрипт-функция уже подготовлена.');

  FBreakPointsPrepared := Value;
  if Value and Assigned(FOnBreakPointsPrepared) then
    FOnBreakPointsPrepared(Self);
end;

procedure TrpCustomFunction.SetComment(const Value: String);
begin
  FComment := Value;
end;

procedure TrpCustomFunction.SetModifyDate(const Value: TDateTime);
begin
  FModifyDate := Value;
end;

procedure TrpCustomFunction.SetModuleCode(const Value: TID);
begin
  FModuleCode := Value;
end;

procedure TrpCustomFunction.SetOnBreakPointsPrepared(const Value: TNotifyEvent);
begin
  FOnBreakPointsPrepared := Value;
end;

function TrpCustomFunction.GetBreakPoints: TStream;
begin
  if FBreakPoints = nil then
  begin
    {$IFDEF DEBUG}
    Inc(FAllocatedCount);
    {$ENDIF}

    FBreakPoints := TMemoryStream.Create;
  end;
  Result := FBreakPoints;
end;

function TrpCustomFunction.GetBreakPointsSize: Integer;
begin
  if FBreakPoints = nil then
    Result := 0
  else
    Result := FBreakPoints.Size;  
end;

// TReportResult

constructor TReportResult.Create;
begin
  inherited Create;

  Sorted := True;
  FIsStreamData := False;
  FMasterDetail := TFourStringList.Create;
  FTempStream := TMemoryStream.Create;
end;

destructor TReportResult.Destroy;
begin
  Clear;
  FreeAndNil(FMasterDetail);
  FreeAndNil(FTempStream);
  if Assigned(FBaseQueryList) then
    FBaseQueryList.Clear;

  inherited Destroy;
end;

function TReportResult.AddDataSet(const AnName: String): Integer;
begin
  Result := AddObject(AnsiUpperCase(AnName), TClientDataSet.Create(nil));
  DataSet[Result].Name := Strings[Result];
end;

function TReportResult.DataSetByName(const AnName: String): TDataSet;
var
  I: Integer;
begin
  Result := nil;
  if Find(AnName, I) then
    Result := DataSet[I];
end;

procedure TReportResult.ViewResult;
  {$IFDEF GEDEMIN}
var
  I: Integer;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  with TdlgViewResult.Create(nil) do
  try
    for I := 0 to Count - 1 do
      AddPage(DataSet[I]);
    if PageCount > 0 then
    begin
      pcDataSet.ActivePageIndex := pcDataSet.PageCount - 1;
      ShowModal;
    end;
  finally
    Free;
  end;
  {$ENDIF}
end;

procedure TReportResult.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    DeleteDataSet(I);
  inherited;
end;

procedure TReportResult.Assign(const AnReportResult: TReportResult);
var
  MemStr: TMemoryStream;
begin
  MemStr := TMemoryStream.Create;
  try
    AnReportResult.SaveToStream(MemStr);
    MemStr.Position := 0;
    LoadFromStream(MemStr);
  finally
    MemStr.Free;
  end;
end;

procedure TReportResult.DeleteDataSet(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
//  Object free in BaseQuery
  if not Assigned(QueryList) then
  begin
    if TClientDataSet(Objects[AnIndex]).MasterSource <> nil then
    begin
      TClientDataSet(Objects[AnIndex]).MasterFields := '';
      TClientDataSet(Objects[AnIndex]).MasterSource.Free;
      TClientDataSet(Objects[AnIndex]).MasterSource := nil;
    end;
    TClientDataSet(Objects[AnIndex]).Free;
  end;
  Delete(AnIndex);
end;

function TReportResult.GetDataSet(const AnIndex: Integer): TDataSet;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  Result := TDataSet(Objects[AnIndex]);
end;

procedure TReportResult.LoadFromStream(AnStream: TStream);
var
  I, J, LocCount, LocSize: Integer;
  SName: String;
  TempStream: TMemoryStream;
  LocMasterDetail: TFourStringList;
  PrefixData: array[0..2] of Char;
  IndexSL: TStringList;
  TempDataSet: TClientDataSet;
begin
  Clear;
  AnStream.Position := 0;
  if AnStream.Position >= AnStream.Size then
    Exit;
  AnStream.ReadBuffer(LocCount, SizeOf(LocCount));
  TempStream := TMemoryStream.Create;
  try
    for I := 0 to LocCount - 1 do
    begin
      AnStream.ReadBuffer(LocSize, SizeOf(LocSize));
      SetLength(SName, LocSize);
      AnStream.ReadBuffer(SName[1], LocSize);
      J := AddDataSet(SName);
      AnStream.ReadBuffer(LocSize, SizeOf(LocSize));
      TempStream.Clear;
      TempStream.Size := LocSize;
      AnStream.ReadBuffer(TempStream.Memory^, LocSize);
      if TempStream.Size <> 0 then
        TClientDataSet(DataSet[J]).LoadFromStream(TempStream);
    end;
  finally
    TempStream.Free;
  end;

  FMasterDetail.Clear;
  if AnStream.Position < AnStream.Size then
  begin
    AnStream.ReadBuffer(PrefixData, SizeOf(MDPrefix));
    if PrefixData = MDPrefix then
    begin
      LocMasterDetail := TFourStringList.Create;
      try
        LocMasterDetail.LoadFromStream(AnStream);
        for I := 0 to LocMasterDetail.Count - 1 do
          AddMasterDetail(LocMasterDetail.MasterTable[I], LocMasterDetail.MasterField[I],
           LocMasterDetail.DetailTable[I], LocMasterDetail.DetailField[I]);
      finally
        LocMasterDetail.Free;
      end;
      if AnStream.Position < AnStream.Size then
        AnStream.ReadBuffer(PrefixData, SizeOf(IndexPrefix));
    end;

    if PrefixData = IndexPrefix then
    begin
      IndexSL := TStringList.Create;
      try
        IndexSL.LoadFromStream(AnStream);
        for I := 0 to IndexSL.Count - 1 do
        begin
          TempDataSet := (DataSetByName(IndexSL.Names[I]) as TClientDataSet);
          if TempDataSet <> nil then
            TempDataSet.IndexFieldNames := IndexSL.Values[IndexSL.Names[I]];
        end;
      finally
        IndexSL.Free;
      end;
    end;
  end;
end;

procedure TReportResult.SaveToStream(AnStream: TStream);
var
  LocSize, I: Integer;
  SName: String;
  TempStream: TMemoryStream;
  IndexSL: TStringList;
begin
  LocSize := Count;
  AnStream.Write(LocSize, SizeOf(LocSize));
  IndexSL := TStringList.Create;
  try
    TempStream := TMemoryStream.Create;
    try
      for I := 0 to Count - 1 do
      begin
        SName := Strings[I];
        LocSize := Length(SName);
        if TClientDataSet(DataSet[I]).IndexFieldNames > '' then
          IndexSL.Add(SName + '=' + TClientDataSet(DataSet[I]).IndexFieldNames);
        AnStream.Write(LocSize, SizeOf(LocSize));
        AnStream.Write(SName[1], LocSize);
        TempStream.Clear;
        TClientDataSet(DataSet[I]).SaveToStream(TempStream);
        LocSize := TempStream.Size;
        TempStream.Position := 0;
        AnStream.Write(LocSize, SizeOf(LocSize));
        if TempStream.Size <> 0 then
          AnStream.Write(TempStream.Memory^, LocSize);
      end;
    finally
      TempStream.Free;
    end;

    if FMasterDetail.Count > 0 then
    begin
      AnStream.Write(MDPrefix, SizeOf(MDPrefix));
      FMasterDetail.SaveToStream(AnStream);
    end;
    if IndexSL.Count > 0 then
    begin
      AnStream.Write(IndexPrefix, SizeOf(IndexPrefix));
      IndexSL.SaveToStream(AnStream);
    end;
  finally
    IndexSL.Free;
  end;
end;

procedure TReportResult.LoadFromFile(AnFileName: String);
var
  FStr: TFileStream;
begin
  if not FileExists(AnFileName) then
  begin
    MessageBox(0, 'Файл не найден.', 'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    Exit;
  end;

  FStr := TFileStream.Create(AnFileName, fmOpenRead);
  try
    LoadFromStream(FStr);
  finally
    FStr.Free;
  end;
end;

procedure TReportResult.SaveToFile(AnFileName: String);
var
  FStr: TFileStream;
begin
  FStr := TFileStream.Create(AnFileName, fmCreate);
  try
    SaveToStream(FStr);
  finally
    FStr.Free;
  end;
end;

procedure TReportResult.AddMasterDetail(const AnMasterTable, AnMasterField,
  AnDetailTable, AnDetailField: String);
var
  TempDs: TClientDataSet;
begin
  Assert(CheckFieldNames(DataSetByName(AnMasterTable), AnMasterField)
    and CheckFieldNames(DataSetByName(AnDetailTable), AnDetailField),
    'Some field of master - detail relation is absent.');

  TempDs := (DataSetByName(AnDetailTable) as TClientDataSet);
  if TempDs.MasterSource = nil then
    TempDs.MasterSource := TDataSource.Create(nil);
  TempDs.MasterSource.DataSet := DataSetByName(AnMasterTable);
  TempDs.IndexFieldNames := AnDetailField;
  TempDs.MasterFields := AnMasterField;

  FMasterDetail.AddRecord(AnMasterTable, AnMasterField,
    AnDetailTable, AnDetailField);
end;

procedure TReportResult.AssignTempStream(const AnStream: TStream);
begin
  FTempStream.Clear;
  AnStream.Position := 0;
  FTempStream.CopyFrom(AnStream, AnStream.Size);
end;

procedure TReportResult.AddDataSetList(const AnBaseQueryList: Variant);
var
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  J: Integer;
  DS: TDataSet;
begin
  LocDispatch := AnBaseQueryList;
  LocReportResult := LocDispatch as IgsQueryList;
  QueryList := LocReportResult;
  for J := LocReportResult.Count - 1 downto 0 do
  begin
    DS := TDataSet(LocReportResult.Query[J].Get_Self);
    AddDataSet(DS.Name, DS);
  end;
end;

function TReportResult.AddDataSet(const AnName: String;
  const AnDataSet: TDataSet): Integer;
begin
  Result := AddObject(AnsiUpperCase(AnName), AnDataSet);
  DataSet[Result].Name := Strings[Result];
end;

// TrpResultStructure
constructor TrpResultStructure.Create;
begin
  FReportResult := TReportResult.Create;
end;

destructor TrpResultStructure.Destroy;
begin
  FReportResult.Free;
end;

procedure TrpResultStructure.Assign(Source: TrpResultStructure);
begin
  Assert(Source <> nil, 'Can''t assigned NULL object.');
  FReportResult.Assign(Source.ReportResult);
  FExecuteTime := Source.ExecuteTime;
  FCreateDate := Source.CreateDate;
  FLastUseDate := Source.LastUseDate;
  FParams := Source.Params;
  FCRCParam := Source.CRCParam;
end;

procedure TrpResultStructure.ReadFromDataSet(const AnDataSet: TDataSet);
var
  Str: TStream;
  VStr: TVarStream;
begin
  Str := AnDataSet.CreateBlobStream(AnDataSet.FieldByName('resultdata'), DB.bmRead);
  try
    if FReportResult.IsStreamData then
      FReportResult.AssignTempStream(Str)
    else
      FReportResult.LoadFromStream(Str);
  finally
    Str.Free;
  end;
  Str := AnDataSet.CreateBlobStream(AnDataSet.FieldByName('paramdata'), DB.bmRead);
  try
    VStr := TVarStream.Create(Str);
    try
      VStr.Read(FParams);
    finally
      VStr.Free;
    end;
  finally
    Str.Free;
  end;
  FExecuteTime := AnDataSet.FieldByName('executetime').AsDateTime;
  FCreateDate := AnDataSet.FieldByName('createdate').AsDateTime;
  FLastUseDate := AnDataSet.FieldByName('lastusedate').AsDateTime;
  FCRCParam := AnDataSet.FieldByName('crcparam').AsInteger;
  FParamOrder := AnDataSet.FieldByName('paramorder').AsInteger;
end;

// TrpResultList

function TrpResultList.GetReportResult(const AnIndex: Integer): TrpResultStructure;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count));
  Result := TrpResultStructure(Items[AnIndex]);
end;

procedure TrpResultList.SetReportResult(const AnIndex: Integer; const AnValue: TrpResultStructure);
begin
  if Assigned(AnValue) then
    TrpResultStructure(Items[AnIndex]).Assign(AnValue);
end;

procedure TrpResultList.ReadFromDataSet(const AnDataSet: TDataSet);
var
  I: Integer;
begin
  I := 0;
  AnDataSet.First;
  while not AnDataSet.Eof do
  try
    I := AddReportResult(nil);
    ResultStructure[I].ReadFromDataSet(AnDataSet);

    AnDataSet.Next;
  except
    DeleteResult(I);
    AnDataSet.Delete;
  end;
end;

function TrpResultList.AddReportResult(const AnReportResult: TrpResultStructure): Integer;
begin
  Result := Add(TrpResultStructure.Create);
  if Assigned(AnReportResult) then
    TrpResultStructure(Items[Result]).Assign(AnReportResult);
end;

procedure TrpResultList.DeleteResult(const AnIndex: Integer);
begin
  Delete(AnIndex);
end;

procedure TrpResultList.Assign(Source: TrpResultList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to Source.Count - 1 do
    AddReportResult(Source.ResultStructure[I]);
end;

// TReportTemplate

procedure TReportTemplate.Assign(const AnReportTemplate: TReportTemplate);
var
  OldPosition: Integer;
begin
  Clear;
  OldPosition := AnReportTemplate.Position;
  LoadFromStream(AnReportTemplate);
  AnReportTemplate.Position := OldPosition;
end;

// TTemplateStructure

function GetTemplateType(AnValue: TTemplateType): String;
begin
  case AnValue of
    rp_report_const.ttNone: Result := ReportNone;
    rp_report_const.ttRTF: Result := ReportRTF;
    rp_report_const.ttFR: Result := ReportFR;
    rp_report_const.ttXFR: Result := ReportXFR;
  else
    raise Exception.Create('Template type not supported');
  end;
end;

function GetRealTemplateType(AnValue: String): TTemplateType;
begin
  if AnValue = ReportNone then
    Result := rp_report_const.ttNone
  else
    if AnValue = ReportRTF then
      Result := ttRTF
    else
      if AnValue = ReportFR then
        Result := ttFR
      else
        if AnValue = ReportXFR then
          Result := ttXFR
        else
          if AnValue = ReportGRD then
            Result := ttGRD
          {$IFDEF FR4}
          else
            if AnValue = ReportFR4 then
              Result := ttFR4
          {$ENDIF}
            else
              raise Exception.Create('Template type not supported');
end;

constructor TTemplateStructure.Create;
begin
  inherited;

  FReportTemplate := TReportTemplate.Create;
  Reset;
end;

destructor TTemplateStructure.Destroy;
begin
  Reset;
  if Assigned(FReportTemplate) then
    FreeAndNil(FReportTemplate);

  inherited Destroy;
end;

procedure TTemplateStructure.Assign(AnSource: TTemplateStructure);
begin
  FTemplateKey:= AnSource.TemplateKey;
  FName := AnSource.Name;
  FDescription := AnSource.Description;
  FReportTemplate.Assign(AnSource.ReportTemplate);
  FTemplateDelphiType := AnSource.RealTemplateType;
  FAFull := AnSource.AFull;
  FAChag := AnSource.AChag;
  FAView := AnSource.AView;
end;

procedure TTemplateStructure.Reset;
begin
  FTemplateKey:= 0;
  FName := '';
  FDescription := '';
  FReportTemplate.Clear;
  FTemplateType := ReportNone;
  FTemplateDelphiType := rp_report_const.ttNone;
end;

procedure TTemplateStructure.SetReportTemplate(AnValue: TReportTemplate);
begin
  FReportTemplate.Assign(AnValue);
end;

procedure TTemplateStructure.SetTemplateDelphiType(AnValue: TTemplateType);
begin
  FTemplateType := GetTemplateType(AnValue);
  FTemplateDelphiType := AnValue;
end;

procedure TTemplateStructure.SetTemplateType(AnValue: String);
begin
  FTemplateDelphiType := GetRealTemplateType(AnValue);
  FTemplateType := AnValue;
end;

procedure TTemplateStructure.ReadFromDataSet(const AnDataSet: TDataSet);
var
  Str: TStream;
begin
  TemplateKey := GetTID(AnDataSet.FieldByName('id'));
  Name := AnDataSet.FieldByName('name').AsString;
  Description := AnDataSet.FieldByName('description').AsString;
  FAFull := AnDataSet.FieldByName('afull').AsInteger;
  FAChag := AnDataSet.FieldByName('achag').AsInteger;
  FAView := AnDataSet.FieldByName('aview').AsInteger;
  Str := AnDataSet.CreateBlobStream(AnDataSet.FieldByName('templatedata'), DB.bmRead);
  try
    ReportTemplate.CopyFrom(Str, Str.Size);
    ReportTemplate.Position := 0;
  finally
    Str.Free;
  end;
  TemplateType := AnDataSet.FieldByName('templatetype').AsString;
end;

procedure TTemplateStructure.LoadFromStream(AnStream: TStream);
var
  TempLength, LenID: Integer;
  TempStr: String;
begin
  {метка сохранения ID в Int64}
  LenID := GetLenIDinStream(@AnStream);

  AnStream.ReadBuffer(FTemplateKey, LenID);

  AnStream.ReadBuffer(TempLength, SizeOf(TempLength));
  SetLength(FName, TempLength);
  AnStream.ReadBuffer(FName[1], TempLength);

  AnStream.ReadBuffer(TempLength, SizeOf(TempLength));
  SetLength(FDescription, TempLength);
  AnStream.ReadBuffer(FDescription[1], TempLength);

  AnStream.ReadBuffer(TempLength, SizeOf(TempLength));
  SetLength(TempStr, TempLength);
  AnStream.ReadBuffer(TempStr[1], TempLength);
  TemplateType := TempStr;

  FReportTemplate.LoadFromStream(AnStream);
end;

procedure TTemplateStructure.SaveToStream(AnStream: TStream);
var
  TempLength, LenID: Integer;
begin
  {метка сохранения ID в Int64}
  LenID := SetLenIDinStream(@AnStream);

  AnStream.Write(FTemplateKey, LenID);

  TempLength := Length(FName);
  AnStream.Write(TempLength, SizeOf(TempLength));
  AnStream.Write(FName[1], TempLength);

  TempLength := Length(FDescription);
  AnStream.Write(TempLength, SizeOf(TempLength));
  AnStream.Write(FDescription[1], TempLength);

  TempLength := Length(FTemplateType);
  AnStream.Write(TempLength, SizeOf(TempLength));
  AnStream.Write(FTemplateType[1], TempLength);

  FReportTemplate.SaveToStream(AnStream);
end;

// TCustomReport

constructor TCustomReport.Create;
begin
  inherited Create;

  FParamFunction := TrpCustomFunction.Create;
  FMainFunction := TrpCustomFunction.Create;
  FEventFunction := TrpCustomFunction.Create;
  FReportResult := TrpResultList.Create;
  FTemplateStructure := TTemplateStructure.Create;
  FServerKey := -1;
end;

destructor TCustomReport.Destroy;
begin
  FParamFunction.Free;
  FMainFunction.Free;
  FEventFunction.Free;
  FReportResult.Free;
  FTemplateStructure.Free;

  inherited Destroy;
end;

procedure TCustomReport.Assign(AnSource: TCustomReport);
begin
  if AnSource <> nil then
  begin
    FReportKey := AnSource.ReportKey;
    FReportName := AnSource.ReportName;
    FReportDescription := AnSource.Description;
    FParamFunction.Assign(AnSource.ParamFunction);
    FMainFunction.Assign(AnSource.MainFunction);
    FEventFunction.Assign(AnSource.EventFunction);
    FReportResult.Assign(AnSource.ReportResultList);
    FTemplateStructure.Assign(AnSource.FTemplateStructure);
    FFrqRefresh := AnSource.FrqRefresh;
    FIsRebuild := AnSource.IsRebuild;
    FAFull := AnSource.AFull;
    FAChag := AnSource.AChag;
    FAView := AnSource.AView;
    FReportGroupKey := AnSource.ReportGroupKey;
  end;
end;

procedure TCustomReport.ReadFromDataSet(const AnDataSet: TDataSet;
 const AnReadTemplate: Boolean = True);
var
  ibqryTemlate: TIBQuery;
begin
  FReportKey := GetTID(AnDataSet.FieldByName('id'));
  FReportName := AnDataSet.FieldByName('Name').AsString;
  FReportDescription := AnDataSet.FieldByName('Description').AsString;
  FFrqRefresh := AnDataSet.FieldByName('FrqRefresh').AsInteger;
  FIsRebuild := AnDataSet.FieldByName('IsRebuild').AsInteger <> 0;
  FIsLocalExecute := AnDataSet.FieldByName('IsLocalExecute').AsInteger <> 0;
  FServerKey := GetTID(AnDataSet.FieldByName('serverkey'));
  FPreview := AnDataSet.FieldByName('preview').AsInteger <> 0;
  FModalPreview := AnDataSet.FieldByName('modalpreview').AsInteger <> 0;
  FAFull := AnDataSet.FieldByName('afull').AsInteger;
  FAChag := AnDataSet.FieldByName('achag').AsInteger;
  FAView := AnDataSet.FieldByName('aview').AsInteger;
  FReportGroupKey := GetTID(AnDataSet.FieldByName('reportgroupkey'));
  if AnReadTemplate and not AnDataSet.FieldByName('TemplateKey').IsNull then
  begin
    ibqryTemlate := TIBQuery.Create(nil);
    try
      ibqryTemlate.Database := (AnDataSet as TIBQuery).Database;
      ibqryTemlate.Transaction := (AnDataSet as TIBQuery).Transaction;
      ibqryTemlate.SQL.Text := 'SELECT * FROM rp_reporttemplate WHERE id = ' +
       AnDataSet.FieldByName('TemplateKey').AsString;
      ibqryTemlate.Open;
      FTemplateStructure.ReadFromDataSet(ibqryTemlate);
    finally
      ibqryTemlate.Free;
    end;
  end;
end;

// TReportGroup

constructor TReportGroup.Create;
begin
  inherited Create(True);

  FParentBranch := nil;
  FGroupKey := -1;
  FName := '';
end;

destructor TReportGroup.Destroy;
begin
  Clear;

  inherited Destroy;
end;

function TReportGroup.AddGroup: Integer;
begin
  Result := Add(TReportGroup.Create);
end;

function TReportGroup.AddGroup(const AnGroupKey: TID; const AnName: String): TReportGroup;
var
  I: Integer;
begin
  I := Add(TReportGroup.Create);
  TReportGroup(Items[I]).FGroupKey := AnGroupKey;
  TReportGroup(Items[I]).FName := AnName;
  TReportGroup(Items[I]).FParentBranch := Self;
  Result := TReportGroup(Items[I]);
end;

procedure TReportGroup.DeleteGroup(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) and (AnIndex < GroupCount));
  Delete(AnIndex);
end;

procedure TReportGroup.ReadData(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
var
  ibsqlGroup: TIBSQL;
  ibsqlGetReportList: TIBSQL;
  StateDB, StateTR: Boolean;
  LocCurrentGroup: TReportGroup;

  procedure SetReportData(const AnGroupKey: TID; var AnParamArray: TDnIntArray);
  const
    MinCount = 100;
  var
    MaxCount, RealCount: Integer;
  begin
    ibsqlGetReportList.Close;
    SetTID(ibsqlGetReportList.Params[0], AnGroupKey);
    ibsqlGetReportList.ExecQuery;
    MaxCount := 0;
    RealCount := 0;
    while not ibsqlGetReportList.Eof do
    begin
      if MaxCount = RealCount then
      begin
        MaxCount := MaxCount + MinCount;
        SetLength(AnParamArray, MaxCount)
      end;
      AnParamArray[RealCount] := GetTID(ibsqlGetReportList.Fields[0]);

      Inc(RealCount);
      ibsqlGetReportList.Next;
    end;
    if MaxCount <> RealCount then
      SetLength(AnParamArray, RealCount);
  end;
begin
  Clear;
  Assert((AnDatabase <> nil) and (AnTransaction <> nil));
  StateDB := AnDatabase.Connected;
  StateTR := AnTransaction.InTransaction;
  ibsqlGroup := TIBSQL.Create(nil);
  try
    if not StateDB then
      AnDatabase.Connected := True;
    if not StateTR then
      AnTransaction.StartTransaction;
    ibsqlGroup.Database := AnDatabase;
    ibsqlGroup.Transaction := AnTransaction;
    ibsqlGroup.SQL.Text := 'SELECT * FROM rp_p_reportgrouplist(:parent)';
    SetTID(ibsqlGroup.Params[0], FGroupKey);
    ibsqlGroup.ExecQuery;
    ibsqlGetReportList := TIBSQL.Create(nil);
    try
      ibsqlGetReportList.Database := AnDatabase;
      ibsqlGetReportList.Transaction := AnTransaction;
      ibsqlGetReportList.SQL.Text := 'SELECT id FROM rp_reportlist WHERE reportgroupkey = :groupkey';
      ibsqlGetReportList.Prepare;

      LocCurrentGroup := Self;

      SetReportData(LocCurrentGroup.GroupKey, LocCurrentGroup.FReportList);
      while not ibsqlGroup.Eof do
      begin
        if GetTID(ibsqlGroup.FieldByName('parent')) <> LocCurrentGroup.GroupKey then
        begin
          while LocCurrentGroup.GroupKey <>
           GetTID(ibsqlGroup.FieldByName('parent')) do
            if LocCurrentGroup.ParentBranch <> nil then
              LocCurrentGroup := LocCurrentGroup.ParentBranch
            else
              raise Exception.Create('Неверный формат дерева.');
        end;
        LocCurrentGroup := LocCurrentGroup.AddGroup(GetTID(ibsqlGroup.FieldByName('id')),
         ibsqlGroup.FieldByName('name').AsString);

        SetReportData(LocCurrentGroup.GroupKey, LocCurrentGroup.FReportList);

        ibsqlGroup.Next;
      end;
    finally
      ibsqlGetReportList.Free;
    end;
  finally
    ibsqlGroup.Free;
    if not StateTR and AnTransaction.InTransaction then
      AnTransaction.Commit;
    if not StateDB then
      AnDatabase.Connected := False;
  end;
end;

function TReportGroup.GetGroup(const Index: Integer): TReportGroup;
begin
  Assert((Index >= 0) and (Index < GroupCount));
  Result := TReportGroup(Items[Index]);
end;

function TReportGroup.GetReportCount: Integer;
begin
  Result := Length(FReportList);
end;

function TReportGroup.GetGroupCount: Integer;
begin
  Result := Count;
end;

// TReportList

constructor TReportList.Create;
begin
  inherited Create(True);
end;

destructor TReportList.Destroy;
begin
  Clear;

  inherited Destroy;
end;

function TReportList.FindReport(const AnReportKey: TID): TCustomReport;
  function GetReportPosition(const ALow, AHigh, AValue: TID): TCustomReport;
  var
    B, R: Integer;
  begin
    if ALow <= AHigh then
    begin
      B := (ALow + AHigh) div 2;
      R := Reports[B].ReportKey - AValue;
      if R > 0 then
        Result := GetReportPosition(ALow, B - 1, AValue)
      else if R < 0 then
        Result := GetReportPosition(B + 1, AHigh, AValue)
      else
        Result := Reports[B];
    end else
      Result := nil;
  end;
begin
  Result := GetReportPosition(0, Count - 1, AnReportKey);
end;

procedure TReportList.SetReport(const AnIndex: Integer; const AnReport: TCustomReport);
begin
  Assert((AnIndex >= 0) or (AnIndex < Count), 'Индекс вне диапозона');
  TCustomReport(Items[AnIndex]).Assign(AnReport);
end;

function TReportList.GetReport(const AnIndex: Integer): TCustomReport;
begin
  Assert((AnIndex >= 0) or (AnIndex < Count), 'Индекс вне диапозона');
  Result := TCustomReport(Items[AnIndex]);
end;

procedure TReportList.SetDatabase(const AnValue: TIBDatabase);
begin
  FDatabase := AnValue;
end;

function TReportList.GetDatabase: TIBDatabase;
begin
  Result := FDatabase;
end;

procedure TReportList.SetTransaction(const AnValue: TIBTransaction);
begin
  FTransaction := AnValue;
end;

function TReportList.GetTransaction: TIBTransaction;
begin
  Result := FTransaction;
end;

function TReportList.AddReport: Integer;
begin
  Result := AddReport(nil);
end;

function TReportList.AddReport(const AnSource: TCustomReport): Integer;
begin
  Result := Add(TCustomReport.Create);
  if AnSource <> nil then
    TCustomReport(Items[Count - 1]).Assign(AnSource);
end;

procedure TReportList.DeleteReport(const AnIndex: Integer);
begin
  Assert((AnIndex >= 0) or (AnIndex < Count), 'Индекс вне диапозона');
  TCustomReport(Items[AnIndex]).Free;
  Delete(AnIndex);
end;

function TReportList.ReportByKey(const AnReportKey: TID): TCustomReport;
begin
  Result := FindReport(AnReportKey);
end;

procedure TReportList.Assign(AnSource: TReportList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to AnSource.Count - 1 do
    AddReport(AnSource.Reports[I]);
end;

procedure TReportList.ReadFromDataSet(const AnDataSet: TDataSet);
var
  ibsqlFunction, ibsqlResult: TIBQuery;
  I: Integer;
  StateTR: Boolean;
begin
  Assert(FDatabase <> nil, 'Database not assigned.');
  StateTR := FTransaction.InTransaction;
  ibsqlFunction := TIBQuery.Create(nil);
  try
    if not StateTR then
      FTransaction.StartTransaction;

    ibsqlResult := TIBQuery.Create(nil);
    try
      ibsqlFunction.Database := FDatabase;
      ibsqlFunction.Transaction := FTransaction;
      ibsqlFunction.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
      ibsqlFunction.Prepare;

{      ibsqlResult.Database := FDatabase;
      ibsqlResult.Transaction := FTransaction;
      ibsqlResult.SQL.Text := 'SELECT * FROM rp_reportresult WHERE reportkey = :id';
      ibsqlResult.Prepare;}

      Clear;
      while not AnDataSet.Eof do
      begin
        I := AddReport;
        Reports[I].ReadFromDataSet(AnDataSet);

        ibsqlFunction.Close;
        SetTID(ibsqlFunction.Params[0], AnDataSet.FieldByName('paramformulakey'));
        ibsqlFunction.Open;
        Reports[I].ParamFunction.ReadFromDataSet(ibsqlFunction);

        ibsqlFunction.Close;
        SetTID(ibsqlFunction.Params[0], AnDataSet.FieldByName('mainformulakey'));
        ibsqlFunction.Open;
        Reports[I].MainFunction.ReadFromDataSet(ibsqlFunction);

        ibsqlFunction.Close;
        SetTID(ibsqlFunction.Params[0], AnDataSet.FieldByName('eventformulakey'));
        ibsqlFunction.Open;
        Reports[I].EventFunction.ReadFromDataSet(ibsqlFunction);

        {ibsqlResult.Close;
        ibsqlResult.Params[0].AsInteger := Reports[I].ReportKey;
        ibsqlResult.Open;
        Reports[I].ReportResultList.ReadFromDataSet(ibsqlResult);}

        AnDataSet.Next;
      end;
    finally
      ibsqlResult.Close;
      FreeAndNil(ibsqlResult);
    end;
  finally
    ibsqlFunction.Close;
    FreeAndNil(ibsqlFunction);
    if not StateTR then
      FTransaction.Commit;
  end;
end;

procedure TReportList.Refresh;
var
  ibsqlWork: TIBQuery;
  StateTR: Boolean;
begin
  Assert(FDatabase <> nil, 'Database not assigned.');
  StateTR := FTransaction.InTransaction;
  ibsqlWork := TIBQuery.Create(nil);
  try
    if not StateTR then
      FTransaction.StartTransaction;

    ibsqlWork.Database := FDatabase;
    ibsqlWork.Transaction := FTransaction;
    ibsqlWork.SQL.Text := 'SELECT * FROM rp_reportlist ORDER BY id';
    ibsqlWork.Open;
    ReadFromDataSet(ibsqlWork);
    ibsqlWork.Close;
  finally
    if not StateTR then
      FTransaction.Commit;
    FreeAndNil(ibsqlWork);
  end;
end;

{$IFDEF DEBUG}
initialization
  FTotalCount := 0;
  FAllocatedCount := 0;

finalization
  OutputDebugString(PChar('Breakpoints streams allocated: ' + IntToStr(FTotalCount)
    + '-' + IntToStr(FAllocatedCount)));
{$ENDIF}
end.
