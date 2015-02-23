{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    scrReportGroup.pas

  Abstract

    Gedemin project. TscrReportGroup, TscrReportGroupItem.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.01.01    tiptop        Initial version.

--}

unit scrReportGroup;

interface

uses Classes, Db, SysUtils, IBQuery, IBDataBase, IBCustomDataSet,
  gd_SetDataBase, scrMacrosGroup;

type
  TscrReportFncType = (rfMainFnc, rfParamFnc, rfEventFnc);
//Класс служит для хранения данных функции рапорта
type
  TscrReportFunction = class(TscrCustomItem)
  private
    FFncType: TscrReportFncType;
    procedure SetFncType(const Value: TscrReportFncType);
    function GetModuleName: string;
  public
    constructor Create;

    property FncType: TscrReportFncType read FFncType write SetFncType;
    property ModuleName: string read GetModuleName;
  end;

type
  TscrReportTemplate = class(TscrCustomItem)
  public
    constructor Create;
  end;

//Класс служит для хранения данных одного отчёта.
type
  TscrReportItem = class(TscrCustomItem)
  private
    FPreview: Boolean;
    FIsLocalExecute: Boolean;
    FGlobalReportKey: Boolean;
    FAChag: Integer;
    FFRQRefresh: Integer;
    FReportGroupKey: Integer;
    FTemplateKey: Integer;
    FIsRebuild: Integer;
    FServerKey: Integer;
    FMainFormulaKey: Integer;
    FAFull: Integer;
    FEventFormulaKey: Integer;
    FAView: Integer;
    FParamFormulaKey: Integer;
    FDescription: ShortString;
    procedure SetAChag(const Value: Integer);
    procedure SetAFull(const Value: Integer);
    procedure SetAView(const Value: Integer);
    procedure SetDescription(const Value: ShortString);
    procedure SetEventFormulaKey(const Value: Integer);
    procedure SetFRQRefresh(const Value: Integer);
    procedure SetGlobalReportKey(const Value: Boolean);
    procedure SetIsLocalExecute(const Value: Boolean);
    procedure SetIsRebuild(const Value: Integer);
    procedure SetMainFormulaKey(const Value: Integer);
    procedure SetParamFormulaKey(const Value: Integer);
    procedure SetPreview(const Value: Boolean);
    procedure SetReportGroupKey(const Value: Integer);
    procedure SetServerKey(const Value: Integer);
    procedure SetTemplateKey(const Value: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromDataSet(ADataSet: TIBCustomDataSet);
    procedure Assign(Source: TscrReportItem);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromStream(AStream: TStream);

    property Description: ShortString read FDescription write SetDescription;
    property FRQRefresh: Integer read FFRQRefresh write SetFRQRefresh;
    property ReportGroupKey: Integer read FReportGroupKey write SetReportGroupKey;
    property ParamFormulaKey: Integer read FParamFormulaKey write SetParamFormulaKey;
    property MainFormulaKey: Integer read FMainFormulaKey write SetMainFormulaKey;
    property EventFormulaKey: Integer read FEventFormulaKey write SetEventFormulaKey;
    property TemplateKey: Integer read FTemplateKey write SetTemplateKey;
    property IsRebuild: Integer read FIsRebuild write SetIsRebuild;
    property AFull: Integer read FAFull write SetAFull;
    property AChag: Integer read FAChag write SetAChag;
    property AView: Integer read FAView write SetAView;
    property ServerKey: Integer read FServerKey write SetServerKey;
    property IsLocalExecute: Boolean read FIsLocalExecute write SetIsLocalExecute;
    property Preview: Boolean read FPreview write SetPreview;
    property GlobalReportKey: Boolean read FGlobalReportKey write SetGlobalReportKey;
  end;

//Класс служит для хранения данных рапортов для одного объекта.
type
  TscrReportList = class(TObject)
  private
    FTransaction: TIBTransaction;
    FList: TList;
    FUseScriptMethod: Boolean;

    function GetReport(Index: Integer): TscrReportItem;
    function GetReportByName(AName: ShortString): TscrReportItem;
    function GetCount: Integer;
    procedure SetReport(Index: Integer; const Value: TscrReportItem);
    procedure SetReportByName(AName: ShortString; const Value: TscrReportItem);
    function GetReportByID(AId: Integer): TscrReportItem;
    procedure SetReportByID(AId: Integer; const Value: TscrReportItem);
  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    function IndexOfByName(AName: ShortString): Integer;
    function IndexOf(ReportItem: TscrReportItem): Integer;
    function IndexOfByID(AID: Integer): Integer;
    //Запись информации в поток.
    procedure SaveToStream(AStream: Tstream);
    //Чтение информации из потока.
    procedure LoadFromStream(AStream:TStream);
    procedure Clear;
    function Add(const AReportItem: TscrReportItem): Integer;
    //Загрузка макросов из базы данных. Данные должны выбираться в зависимости от ключа объекта и значения поля MODULE = Report
    procedure Load(const AGroupKey: integer);
    //Загрузка макросов из базы данных. Данные должны выбираться в зависимости от ключа объекта и значения поля MODULE = MACROS
    //Загружаются макросы хранящиеся в группе с ID = AGroupKey и её подгруппах
    procedure LoadWithSubGroup(const AGroupKey: Integer);

    function Last: TscrReportItem;
    procedure Assign(ASource: TscrReportList);

    //Возвращает данные макроса по номеру
    property Report[Index: Integer]: TscrReportItem read GetReport write SetReport; default;
    //Возвращает данные макроса по имени
    property ReportByName[AName: ShortString]: TscrReportItem read GetReportByName write SetReportByName;
    property ReportByID[AId: Integer]: TscrReportItem read GetReportByID write SetReportByID;
    property Transaction: TIBTransaction read FTransaction write FTransaction;
    property Count: Integer read GetCount;
  end;

//Класс служит для хранения данных одной ReportGroup.
type
  TscrReportGroupItem = class(TscrCustomItem)
  private
    FChildIsRead: Boolean;
    FParent: Integer;
    FDescription: ShortString;
    FUserGroupName: ShortString;
    FReportList: TscrReportList;

    procedure SetDescription(const Value: ShortString);
    procedure SetParent(const Value: Integer);
    procedure SetUserGroupName(const Value: ShortString);

  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    procedure Assign(Source: TscrReportGroupItem);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromStream(AStream: TStream);
    procedure ReadFromDataSet(ADataSet: TIBCustomDataSet);

    property Parent: Integer read FParent write SetParent;
    property Description: ShortString read FDescription write SetDescription;
    property UserGroupName: ShortString read FUserGroupName write SetUserGroupName;

    property ChildIsRead: Boolean read FChildIsRead write FChildIsRead;
    property ReportList: TscrReportList read FReportList;
  end;

//Класс служит для хранения данных папок.
type
  TscrReportGroup = class(TObject)
  private
    FTransaction: TIBTransaction;
    FGroupItems: TList;
    FUseScriptMethod: Boolean;

    function GetCount: Integer;
    function GetGroupItems(Index: Integer): TscrReportGroupItem;
    procedure SetGroupItems(Index: Integer;
      const Value: TscrReportGroupItem);
    function GetGroupByName(AName: ShortString): TscrReportGroupItem;
    procedure SetGroupByName(AName: ShortString;
      const Value: TscrReportGroupItem);
    function GetGroupItemsByID(AID: Integer): TscrReportGroupItem;
    procedure SetGroupItemsByID(AID: Integer;
      const Value: TscrReportGroupItem);
  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    function IndexOfByName(AName: ShortString): Integer;
    function IndexOf(GroupItem: TscrReportGroupItem): Integer;
    function IndexOfByID(AID: Integer): Integer;
    //Запись информации в поток.
    procedure SaveToStream(AStream: Tstream);
    //Чтение информации из потока.
    procedure LoadFromStream(AStream:TStream);
    procedure Clear;
    function Add(const AGroupItem: TscrReportGroupItem): Integer;
    //Загрузка папки из базы данных. Данные должны выбираться в зависимости от ключа
    procedure Load(const AId: Integer);

    function Last: TscrReportGroupItem;
    procedure Sort;

    //Возвращает данные папки по номеру
    property GroupItems[Index: Integer]: TscrReportGroupItem read GetGroupItems write SetGroupItems; default;
    //Возвращает данные папки по имени
    property GroupItemsByName[AName: ShortString]: TscrReportGroupItem read GetGroupByName write SetGroupByName;
    //Возвращает данные папки по ID
    property GroupItemsByID[AID: Integer]: TscrReportGroupItem read GetGroupItemsByID write SetGroupItemsByID;
    property Transaction: TIBTransaction read FTransaction write FTransaction;
    property Count: Integer read GetCount;
  end;

implementation

uses IBSQL, Windows, rp_report_const, gdcConstants, gdcReport;

type
  TLabelStream = array[0..3] of char;

const
  SCR_REPORT_GROUP = '^RPG';
  SCR_REPORT_LIST = '^RPL';
  LblSize = SizeOf(TLabelStream);

  DB_ERROR = 'Ошибка базы данных';
  STREAM_ERROR = 'Неверный формат данных';

  DefaultReportName = 'Рапорт';
  DefaultRaportGroupName = 'Макрос';
  DefaultReportTemplateName = 'Template';

  ALL_Report = -1;
  ALL_LOCAL_Report = -2;
  ALL_GLOBAL_Report = -3;

// Only for testing
{$IFDEF DEBUG}
var
  glbReportItemCount: Integer;
  glbReportListCount: Integer;
{$ENDIF}

{ TscrReportItem }
procedure TscrReportItem.Assign(Source: TscrReportItem);
begin
    FId := Source.Id;
    FName := Source.Name;
    FPreview := Source.Preview;
    FIsLocalExecute := Source.IsLocalExecute;
    FGlobalReportKey := Source.GlobalReportKey;
    FAChag := Source.AChag;
    FFRQRefresh := Source.FRQRefresh;
    FReportGroupKey := Source.ReportGroupKey;
    FTemplateKey := Source.TemplateKey;
    FIsRebuild := Source.IsRebuild;
    FServerKey := Source.ServerKey;
    FMainFormulaKey := Source.MainFormulaKey;
    FAFull := Source.AFull;
    FEventFormulaKey := Source.EventFormulaKey;
    FAView := Source.aview;
    FParamFormulaKey := Source.ParamFormulaKey;
    FDescription := Source.Description;
end;

constructor TscrReportItem.Create;
begin
  inherited;

  FItemType := itReport;
  FName := DefaultReportName;
  FDescription := '';
  FPreview := False;
  FIsLocalExecute := False;
  FGlobalReportKey := False;
  FAChag := -1;
  FFRQRefresh := -1;
  FReportGroupKey := 0;
  FTemplateKey := 0;
  FIsRebuild := 0;
  FServerKey := 0;
  FMainFormulaKey := 0;
  FAFull := -1;
  FEventFormulaKey := 0;
  FAView := -1;
  FParamFormulaKey := 0;

{$IFDEF DEBUG}
  Inc(glbReportItemCount);
{$ENDIF}  
end;

destructor TscrReportItem.Destroy;
begin
{$IFDEF DEBUG}
  Dec(glbReportItemCount);
{$ENDIF}
  inherited;
end;

procedure TscrReportItem.ReadFromDataSet(ADataSet: TIBCustomDataSet);
begin
  try
    FId := ADataSet.FieldByName('id').AsInteger;
    FName := ADataSet.FieldByName('name').AsString;
    FPreview := ADataSet.FieldByName('preview').AsInteger > 0;
    FIsLocalExecute := ADataSet.FieldByName('islocalexecute').AsInteger > 0;
    FGlobalReportKey := ADataSet.FieldByName('globalreportkey').AsInteger > 0;
    FAChag := ADataSet.FieldByName('achag').AsInteger;
    FFRQRefresh := ADataSet.FieldByName('frqrefresh').AsInteger;
    FReportGroupKey := ADataSet.FieldByName('reportgroupkey').AsInteger;
    FTemplateKey := ADataSet.FieldByName('templatekey').AsInteger;
    FIsRebuild := ADataSet.FieldByName('IsRebuild').AsInteger;
    FServerKey := ADataSet.FieldByName('serverkey').AsInteger;
    FMainFormulaKey := ADataSet.FieldByName('mainformulakey').AsInteger;
    FAFull := ADataSet.FieldByName('afull').AsInteger;
    FEventFormulaKey := ADataSet.FieldByName('eventformulakey').AsInteger;
    FAView := ADataSet.FieldByName('aview').AsInteger;
    FParamFormulaKey := ADataSet.FieldByName('paramformulakey').AsInteger;
    FDescription := ADataSet.FieldByName('description').AsString;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

procedure TscrReportItem.LoadFromStream(AStream: TStream);
begin
  AStream.ReadBuffer(FId, SizeOf(Fid));
  AStream.ReadBuffer(FName, SizeOf(FName));
  AStream.ReadBuffer(FPreview, SizeOf(FPreview));
  AStream.ReadBuffer(FIsLocalExecute, SizeOf(FIsLocalExecute));
  AStream.ReadBuffer(FGlobalReportKey, SizeOf(FGlobalReportKey));
  AStream.ReadBuffer(FAChag, SizeOf(FAChag));
  AStream.ReadBuffer(FFRQRefresh, SizeOf(FFRQRefresh));
  AStream.ReadBuffer(FReportGroupKey, SizeOf(FReportGroupKey));
  AStream.ReadBuffer(FTemplateKey, SizeOf(FTemplateKey));
  AStream.ReadBuffer(FIsRebuild, SizeOf(FIsRebuild));
  AStream.ReadBuffer(FServerKey, SizeOf(FServerKey));
  AStream.ReadBuffer(FMainFormulaKey, SizeOf(FMainFormulaKey));
  AStream.ReadBuffer(FAFull, SizeOf(FAFull));
  AStream.ReadBuffer(FEventFormulaKey, SizeOf(FEventFormulaKey));
  AStream.ReadBuffer(FAView, SizeOf(FAView));
  AStream.ReadBuffer(FParamFormulaKey, SizeOf(FParamFormulaKey));
  AStream.ReadBuffer(FDescription, SizeOf(FDescription));
end;

procedure TscrReportItem.SaveToStream(AStream: TStream);
begin
  AStream.Write(FId, SizeOf(Fid));
  AStream.Write(FName, SizeOf(FName));
  AStream.Write(FPreview, SizeOf(FPreview));
  AStream.Write(FIsLocalExecute, SizeOf(FIsLocalExecute));
  AStream.Write(FGlobalReportKey, SizeOf(FGlobalReportKey));
  AStream.Write(FAChag, SizeOf(FAChag));
  AStream.Write(FFRQRefresh, SizeOf(FFRQRefresh));
  AStream.Write(FReportGroupKey, SizeOf(FReportGroupKey));
  AStream.Write(FTemplateKey, SizeOf(FTemplateKey));
  AStream.Write(FIsRebuild, SizeOf(FIsRebuild));
  AStream.Write(FServerKey, SizeOf(FServerKey));
  AStream.Write(FMainFormulaKey, SizeOf(FMainFormulaKey));
  AStream.Write(FAFull, SizeOf(FAFull));
  AStream.Write(FEventFormulaKey, SizeOf(FEventFormulaKey));
  AStream.Write(FAView, SizeOf(FAView));
  AStream.Write(FParamFormulaKey, SizeOf(FParamFormulaKey));
  AStream.Write(FDescription, SizeOf(FDescription));
end;

{ TscrReportList }

function TscrReportList.Add(const AReportItem: TscrReportItem): Integer;
begin
  Result := FList.Add(AReportItem);
end;

procedure TscrReportList.Assign(ASource: TscrReportList);
var
  I: Integer;
begin
  Clear;
  if Assigned(ASource) then
  begin
    for I := 0 to Count do
    begin
      Report[Add(TscrReportItem.Create)].Assign(ASource.Report[I]);
    end;
  end;
end;

procedure TscrReportList.Clear;
begin
  While FList.Count > 0 do
  begin
    Report[0].Free;
    FList.Delete(0);
  end;
end;

constructor TscrReportList.Create(const AnUseScriptMethod: Boolean);
begin
  FList := TList.Create;
  FUseScriptMethod := AnUseScriptMethod;
{$IFDEF DEBUG}
  Inc(glbReportListCount);
{$ENDIF}  
end;

destructor TscrReportList.Destroy;
begin
  Clear;
  FList.Free;
{$IFDEF DEBUG}
  Dec(glbReportListCount);
{$ENDIF}
  inherited;
end;

function TscrReportList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TscrReportList.GetReport(Index: Integer): TscrReportItem;
begin
  Result := TscrReportItem(FList.Items[Index]);
end;

function TscrReportList.GetReportByID(AId: Integer): TscrReportItem;
var
  Index: Integer;
begin
  Index := IndexOfById(AID);
  if  Index = -1 then
    Result := nil
  else
    Result := Report[Index];
end;

function TscrReportList.GetReportByName(AName: ShortString): TscrReportItem;
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if  Index = -1 then
    Result := nil
  else
    Result := Report[Index];
end;

function TscrReportList.IndexOf(ReportItem: TscrReportItem): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Report[Result] <> ReportItem) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrReportList.IndexOfByID(AID: Integer): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Report[Result].Id <> AID) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrReportList.IndexOfByName(AName: ShortString): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Report[Result].Name <> AName) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrReportList.Last: TscrReportItem;
begin
  Result := TscrReportItem(FList.Last);
end;

procedure TscrReportList.Load(const AGroupKey: integer);
var
  gdcReport: TgdcReport;
  Flag: Boolean;
begin
  gdcReport := TgdcReport.Create(nil);
  try
    gdcReport.UseScriptMethod := FUseScriptMethod;
    gdcReport.QueryFiltered := False;
    if Assigned(FTransaction) then
    begin
      Flag := not FTransaction.InTransaction;
      if Flag then
        FTransaction.StartTransaction;
      gdcReport.Transaction := FTransaction;
      gdcReport.SubSet := ssReportGroup;
      gdcReport.ParamByName('reportgroupkey').AsInteger := AGroupKey;
      gdcReport.OnlyDisplaying := True;
      gdcReport.Open;
      Clear;
      while not gdcReport.Eof do
      begin
        Report[Add(TscrReportItem.Create)].ReadFromDataSet(gdcReport);
        gdcReport.Next;
      end;
      if Flag then
        FTransaction.Commit;
    end
    else
      raise Exception.Create(DB_ERROR);
  finally
    gdcReport.Free;
  end;
end;

procedure TscrReportList.LoadFromStream(AStream: TStream);
var
  I, ItemCount: Integer;
  Lbl: TLabelStream;
begin
  AStream.ReadBuffer(Lbl, LblSize);
  if Lbl = SCR_REPORT_LIST then
  begin
    Clear;
    AStream.ReadBuffer(ItemCount, SizeOf(FList.Count));
    for I := 0 to ItemCount - 1 do
      Report[Add(TscrReportItem.Create)].LoadFromStream(AStream);
  end else
    raise Exception.Create(STREAM_ERROR);
end;

procedure TscrReportList.LoadWithSubGroup(const AGroupKey: Integer);
var
  gdcReport: TgdcReport;
  Flag: Boolean;
begin
  gdcReport := TgdcReport.Create(nil);
  try
    gdcReport.UseScriptMethod := FUseScriptMethod;
    gdcReport.OnlyDisplaying := True;
    { И на фига это?????
    gdcReport.QueryFiltered := True;}
    gdcReport.QueryFiltered := False;
    if Assigned(FTransaction) then
    begin
      Flag := not FTransaction.InTransaction;
      if Flag then
        FTransaction.StartTransaction;
      try
        gdcReport.Transaction := FTransaction;
        if AGroupKey > 0 then
        begin
          gdcReport.SubSet := ssWithSubGroup;
          gdcReport.ParamByName('id').AsInteger := AGroupKey;
        end else
          gdcReport.SubSet := ssAll;

        gdcReport.Open;
        Clear;
        while not gdcReport.Eof do
        begin
          Report[Add(TscrReportItem.Create)].ReadFromDataSet(gdcReport);
          gdcReport.Next;
        end;
      finally
        if Flag then
          FTransaction.Commit;
      end;
    end
    else
      raise Exception.Create(DB_ERROR);
  finally
    gdcReport.Free;
  end;
end;

procedure TscrReportList.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  AStream.Write(SCR_REPORT_LIST, LblSize);
  AStream.Write(FList.Count, SizeOf(FList.Count));
  for I := 0 to FList.Count - 1 do
    Report[I].SaveToStream(AStream);
end;

procedure TscrReportList.SetReport(Index: Integer;
  const Value: TscrReportItem);
begin
  TscrReportItem(FList.Items[Index]).Assign(Value);
end;

procedure TscrReportList.SetReportByID(AId: Integer;
  const Value: TscrReportItem);
var
  Index: Integer;
begin
  Index := IndexOfById(AId);
  if Index <> -1 then
    TscrReportItem(FList.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %s ненайдено',[AId]);
end;

procedure TscrReportList.SetReportByName(AName: ShortString;
  const Value: TscrReportItem);
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if Index <> -1 then
    TscrReportItem(FList.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %s ненайдено',[AName]);
end;

{ TscrReportTreeItem }
procedure TscrReportGroupItem.Assign(Source: TscrReportGroupItem);
begin
  FParent := Source.Parent;
  FId := Source.Id;
  FDescription := Source.Description;
  FName := Source.Name;
  FUserGroupName := Source.UserGroupName;
  ChildIsRead := False;
end;

constructor TscrReportGroupItem.Create(const AnUseScriptMethod: Boolean);
begin
  inherited Create;

  FItemType := itReportFolder;
  FParent := 0;
  FParent := 0;
  FDescription := '';
  FChildIsRead := False;

  FReportList := TscrReportList.Create(AnUseScriptMethod);
{$IFDEF DEBUG}
  Inc(glbReportItemCount);
{$ENDIF}
end;

destructor TscrReportGroupItem.Destroy;
begin
{$IFDEF DEBUG}
  Dec(glbReportItemCount);
{$ENDIF}
  FReportList.Free;
  inherited;
end;

procedure TscrReportGroupItem.ReadFromDataSet(ADataSet: TIBCustomDataSet);
begin
  try
    FParent := ADataSet.FieldByName('Parent').AsInteger;
    FId := ADataSet.FieldByName('Id').AsInteger;
    FDescription := ADataSet.FieldByName('Description').AsString;
    FName := ADataSet.FieldByName('Name').AsString;
    FUserGroupName := ADataSet.FieldByName('UserGroupName').AsString;
    ChildIsRead := False;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

procedure TscrReportGroupItem.LoadFromStream(AStream: TStream);
var
  Dummy: Integer;
begin
  AStream.ReadBuffer(Dummy, SizeOf(Dummy));
  AStream.ReadBuffer(FParent, SizeOf(FParent));
  AStream.ReadBuffer(FId, SizeOf(FId));
  AStream.ReadBuffer(Dummy, SizeOf(Dummy));
  AStream.ReadBuffer(Dummy, SizeOf(Dummy));
  AStream.ReadBuffer(FDescription, SizeOf(FDescription));
  AStream.ReadBuffer(FName, SizeOf(FName));
  AStream.ReadBuffer(FUserGroupName, SizeOf(FUserGroupName));
  FChildIsRead := False;
end;

procedure TscrReportGroupItem.SaveToStream(AStream: TStream);
var
  Dummy: Integer;
begin
  Dummy := 0;
  AStream.Write(Dummy, SizeOf(Dummy));
  AStream.Write(FParent, SizeOf(FParent));
  AStream.Write(FId, SizeOf(FId));
  AStream.Write(Dummy, SizeOf(Dummy));
  AStream.Write(Dummy, SizeOf(Dummy));
  AStream.Write(FDescription, SizeOf(FDescription));
  AStream.Write(FName, SizeOf(FName));
  AStream.Write(FUserGroupName, SizeOf(FUserGroupName));
end;

{ TscrReportList }

function TscrReportGroup.Add(const AGroupItem: TscrReportGroupItem): Integer;
begin
  Result := FGroupItems.Add(AGroupItem);
end;

procedure TscrReportGroup.Clear;
begin
  While FGroupItems.Count > 0 do
  begin
    GroupItems[0].Free;
    FGroupItems.Delete(0);
  end;
end;

constructor TscrReportGroup.Create(const AnUseScriptMethod: Boolean);
begin
  inherited Create;
  FGroupItems := TList.Create;
  FUseScriptMethod := AnUseScriptMethod;
{$IFDEF DEBUG}
  Inc(glbReportListCount);
{$ENDIF}  
end;

destructor TscrReportGroup.Destroy;
begin
  Clear;
  FGroupItems.Free;
{$IFDEF DEBUG}
  Dec(glbReportListCount);
{$ENDIF}
  inherited;
end;

function TscrReportGroup.GetCount: Integer;
begin
  Result := FGroupItems.Count;
end;

function TscrReportGroup.GetGroupByName(
  AName: ShortString): TscrReportGroupItem;
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if  Index = -1 then
    Result := nil
  else
    Result := GroupItems[Index];
end;

function TscrReportGroup.GetGroupItems(
  Index: Integer): TscrReportGroupItem;
begin
  Result := FGroupItems[Index];
end;

function TscrReportGroup.GetGroupItemsByID(
  AID: Integer): TscrReportGroupItem;
var
  Index: Integer;
begin
  Result := nil;
  Index := IndexOfByID(AID);
  if Index > -1 then
  begin
    Result := GroupItems[Index];
  end
end;

function TscrReportGroup.IndexOf(GroupItem: TscrReportGroupItem): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result] <> GroupItem) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrReportGroup.IndexOfByID(AID: Integer): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result].Id <> AID) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrReportGroup.IndexOfByName(AName: ShortString): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result].Name <> AName) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrReportGroup.Last: TscrReportGroupItem;
begin
  Result := TscrReportGroupItem(FGroupItems.Last);
end;

procedure TscrReportGroup.Load(const AId: integer);
var
  DataSet: TgdcReportGroup;
  Flag: Boolean;
  ReportList: TscrReportList;
  TmpRp: TscrReportItem;
  I: Integer;
begin
  Clear;
  if AID > 0 then
  begin
    DataSet := TgdcReportGroup.Create(nil);
    try
      DataSet.UseScriptMethod := FUseScriptMethod;
      DataSet.QueryFiltered := False;
      if Assigned(FTransaction) then
      begin
        Flag := not FTransaction.InTransaction;
        if Flag then
          FTransaction.StartTransaction;
        try
          DataSet.Transaction := FTransaction;
  //        if AId > 0 then
  //        begin
            DataSet.SubSet := ssTree;
            DataSet.ParamByName(fnId).AsInteger := AId;
  //        end else
  //          DataSet.SubSet := ssAll;

          DataSet.Open;
//          Clear;
          while not DataSet.Eof do
          begin
            Add(TscrReportGroupItem.Create(FUseScriptMethod));
            Last.ReadFromDataSet(DataSet);
            Last.ReportList.Transaction := FTransaction;
            DataSet.Next;
          end;
          Sort;
          ReportList := TscrReportList.Create(FUseScriptMethod);
          try
            ReportList.Transaction := FTransaction;
            ReportList.LoadWithSubGroup(AId);
            for I := 0 to ReportList.Count - 1 do
            begin
              if GroupItemsByID[ReportList[I].ReportGroupKey] <> nil then
              begin
                TmpRp := TscrReportItem.Create;
                TmpRp.Assign(ReportList[I]);

                GroupItemsByID[ReportList[I].ReportGroupKey].ReportList.Add(TmpRp);
              end;
            end;
          finally
            ReportList.Free;
          end;
        finally
          if Flag then
            FTransaction.Commit;
        end;
      end
      else
        raise Exception.Create(DB_ERROR);
    finally
      DataSet.Free;
    end;
  end;  
end;

procedure TscrReportGroup.LoadFromStream(AStream: TStream);
var
  I, ItemCount: Integer;
  Lbl: TLabelStream;
begin
  AStream.ReadBuffer(Lbl, LblSize);
  if Lbl = SCR_REPORT_GROUP then
  begin
    Clear;
    AStream.ReadBuffer(ItemCount, SizeOf(FGroupItems.Count));
    for I := 0 to ItemCount - 1 do
      GroupItems[Add(TscrReportGroupItem.Create(FUseScriptMethod))].LoadFromStream(AStream);
  end else
    raise Exception.Create(STREAM_ERROR);
end;

procedure TscrReportGroup.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  AStream.Write(SCR_REPORT_GROUP, LblSize);
  AStream.Write(FGroupItems.Count, SizeOf(FGroupItems.Count));
  for I := 0 to FGroupItems.Count - 1 do
    GroupItems[I].SaveToStream(AStream);
end;

procedure TscrReportGroup.SetGroupByName(AName: ShortString;
  const Value: TscrReportGroupItem);
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if Index <> -1 then
    TscrReportGroupItem(FGroupItems.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %s ненайдено',[AName]);
end;

procedure TscrReportGroup.SetGroupItems(Index: Integer;
  const Value: TscrReportGroupItem);
begin
  TscrReportGroupItem(FGroupItems.Items[Index]).Assign(Value);
end;

function SortCompare(Item1, Item2: Pointer): Integer;
var
  S1, S2: string;
begin
  Result := TscrReportGroupItem(Item1).Parent - TscrReportGroupItem(Item2).Parent;
  if Result = 0 then
  begin
    S1 := TscrReportGroupItem(Item1).Name;
    S2 := TscrReportGroupItem(Item2).Name;
    Result := StrComp(PChar(S1), PChar(S2));
  end;
end;

procedure TscrReportGroup.SetGroupItemsByID(AID: Integer;
  const Value: TscrReportGroupItem);
var
  Index: Integer;
begin
  Index := IndexOfByID(AID);
  if Index > -1 then
  begin
    GroupItems[Index].Assign(Value);
  end
  else
    raise Exception.Create('Значение ID ненайдено');
end;

procedure TscrReportGroup.Sort;
begin
  FGroupItems.Sort(SortCompare);
end;

procedure TscrReportItem.SetAChag(const Value: Integer);
begin
  FAChag := Value;
end;

procedure TscrReportItem.SetAFull(const Value: Integer);
begin
  FAFull := Value;
end;

procedure TscrReportItem.SetAView(const Value: Integer);
begin
  FAView := Value;
end;

procedure TscrReportItem.SetDescription(const Value: ShortString);
begin
  FDescription := Value;
end;

procedure TscrReportItem.SetEventFormulaKey(const Value: Integer);
begin
  FEventFormulaKey := Value;
end;

procedure TscrReportItem.SetFRQRefresh(const Value: Integer);
begin
  FFRQRefresh := Value;
end;

procedure TscrReportItem.SetGlobalReportKey(const Value: Boolean);
begin
  FGlobalReportKey := Value;
end;

procedure TscrReportItem.SetIsLocalExecute(const Value: Boolean);
begin
  FIsLocalExecute := Value;
end;

procedure TscrReportItem.SetIsRebuild(const Value: Integer);
begin
  FIsRebuild := Value;
end;

procedure TscrReportItem.SetMainFormulaKey(const Value: Integer);
begin
  FMainFormulaKey := Value;
end;

procedure TscrReportItem.SetParamFormulaKey(const Value: Integer);
begin
  FParamFormulaKey := Value;
end;

procedure TscrReportItem.SetPreview(const Value: Boolean);
begin
  FPreview := Value;
end;

procedure TscrReportItem.SetReportGroupKey(const Value: Integer);
begin
  FReportGroupKey := Value;
end;

procedure TscrReportItem.SetServerKey(const Value: Integer);
begin
  FServerKey := Value;
end;

procedure TscrReportItem.SetTemplateKey(const Value: Integer);
begin
  FTemplateKey := Value;
end;

procedure TscrReportGroupItem.SetDescription(const Value: ShortString);
begin
  FDescription := Value;
end;

procedure TscrReportGroupItem.SetParent(const Value: Integer);
begin
  FParent := Value;
end;

procedure TscrReportGroupItem.SetUserGroupName(const Value: ShortString);
begin
  FUserGroupName := Value;
end;

{ TscrReportFunction }

constructor TscrReportFunction.Create;
begin
  inherited;

  FItemType := itReportFunction;
end;

function TscrReportFunction.GetModuleName: string;
begin
  case FFncType of
    rfMainFnc: Result := MainModuleName;
    rfParamFnc: Result := ParamModuleName;
    rfEventFnc: Result := EventModuleName;
  end;
end;

procedure TscrReportFunction.SetFncType(const Value: TscrReportFncType);
begin
  FFncType := Value;
end;

{ TscrReportTemplate }

constructor TscrReportTemplate.Create;
begin
  FItemType := itReportTemplate;
  FName := DefaultReportTemplateName;
end;

initialization
{$IFDEF DEBUG}
  glbReportItemCount := 0;
  glbReportListCount := 0;
{$ENDIF}
finalization
{$IFDEF DEBUG}
  Assert(glbReportItemCount = 0, 'Освобождены не все итемы');
  Assert(glbReportListCount = 0, 'Освобождены не все списки');
{$ENDIF}
end.
