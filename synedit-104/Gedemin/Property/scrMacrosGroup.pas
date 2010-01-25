
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    scrMacrosGroup.pas

  Abstract

    Gedemin project. TscrCustomItem, TscrMacrosItem, TscrMacrosList,
      TscrMacrosGroup, TscrMacrosGroupItem.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.01.01    tiptop        Initial version.

--}

unit scrMacrosGroup;

interface

uses Classes, Db, SysUtils, IBDataBase, IBCustomDataSet,
  gd_SetDataBase, IBSQL, gdcBaseInterface;


type
  TscrItemType = (itNone, itMacros, itMacrosFolder, itReportFunction,
    itReport, itReportFolder, itReportTemplate, itScriptFunction,
    itScriptFunctionGroup, itVBClass, itVBClassGroup, itConst,
    itGlobalObject, itConstGroup, itGlobalObjectGroup);

type
  TscrCustomItem = class(TObject)
  protected
    FId: Integer;
    FName: ShortString;
    FItemType: TscrItemType;

  public
    constructor Create;
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property Name: ShortString read FName write FName;
    property ItemType: TscrItemType read FItemType;
  end;

//Класс служит для хранения данных отдельной скрипт функции
type
  TscrCustomScriptFunction = class(TscrCustomItem)
  private
    FModule: ShortString;

    procedure SetModule(const Value: ShortString);
  public
    constructor Create;

    procedure ReadFromDataSet(ADataSet: TIBCustomDataSet);
    procedure ReadFromSQL(SQL: TIBSQL);
    procedure Assign(Source: TObject);virtual;

    property Module: ShortString read FModule write SetModule;
  end;

type
  TscrScriptFunction = class(TscrCustomScriptFunction)
  end;

//Класс служит для хранения данных об описании констант
type
  TscrConst = class(TscrCustomScriptFunction)
  public
    constructor Create;
  end;

  TscrGlobalObject = class(TscrCustomScriptFunction)
  public
    constructor Create;
  end;

type
  TscrScriptFunctionGroup = class(TscrCustomItem)
  public
    constructor Create;
  end;

type
  TscrConstGroup = class(TscrCustomItem)
  public
    constructor Create;
  end;

type
  TscrGlobalObjectGroup = class(TscrCustomItem)
  public
    constructor Create;
  end;

//Класс для хранения VB класса
type
  TscrVBClassGroup = class(TscrCustomItem)
  public
    constructor Create;
  end;

  TscrVBClass = class(TscrCustomItem)
  private
    FNameClass: String;
  public
    constructor Create;

    property NameClass: String read FNameClass write FNameClass;
  end;

//Класс служит для хранения данных одного макроса.
type
  TscrMacrosItem = class(TscrCustomItem)
  private
    FFunctionKey: Integer;
    FGroupKey: Integer;
    FIsGlobal: boolean;
    FIsRebuild: Boolean;
//    FIsLocalExecute: Boolean;
    FServerKey: Integer;
    FExecuteDate: ShortString;
    FShortCut: Word;

    procedure SetIsGlobal(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromDataSet(ADataSet: TIBCustomDataSet);
    procedure ReadFromSQL(ASQL: TIBSQL);
    procedure Assign(Source: TObject);virtual;
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromStream(AStream: TStream);

    property GroupKey: Integer read FGroupKey write FGroupKey;
    property FunctionKey: Integer read FFunctionKey write FFunctionKey;
    property IsGlobal: Boolean read FIsGlobal write SetIsGlobal;
    property ServerKey: Integer read FServerKey write FServerKey;
    property IsRebuild: Boolean read FIsRebuild write FIsrebuild;
//    property IsLocalExecute: Boolean read FIsLocalExecute write FIsLocalExecute;
    property ExecuteDate: ShortString read FExecuteDate write FExecutedate;
    property ShortCut: Word read FShortCut write FShortCut;
  end;

//Класс служит для хранения данных макросов для одного объекта.
type
  TscrMacrosList = class(TObject)
  private
    FTransaction: TIBTransaction;
    FList: TList;
    FUseScriptMethod: Boolean;

    function GetMacros(Index: Integer): TscrMacrosItem;
    function GetMacrosByName(AName: ShortString): TscrMacrosItem;
    function GetCount: Integer;
    procedure SetMacros(Index: Integer; const Value: TscrMacrosItem);
    procedure SetMacrosByName(AName: ShortString; const Value: TscrMacrosItem);
    function GetMacrosByID(AId: Integer): TscrMacrosItem;
    procedure SetMacrosByID(AId: Integer; const Value: TscrMacrosItem);
  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    function IndexOfByName(AName: ShortString): Integer;
    function IndexOf(MacrosItem: TscrMacrosItem): Integer;
    function IndexOfByID(AID: Integer): Integer;
    //Запись информации в поток.
    procedure SaveToStream(AStream: Tstream);
    //Чтение информации из потока.
    procedure LoadFromStream(AStream:TStream);
    procedure Clear;
    function Add(const AMacrosItem: TscrMacrosItem): Integer;
    //Загрузка макросов из базы данных. Данные должны выбираться в зависимости от ключа объекта и значения поля MODULE = MACROS
    //Загружаются макросы хранящиеся только в группе с ID = AGroupKey
    procedure Load(const AGroupKey: Integer);
    //Загрузка макросов из базы данных. Данные должны выбираться в зависимости от ключа объекта и значения поля MODULE = MACROS
    //Загружаются макросы хранящиеся в группе с ID = AGroupKey и её подгруппах
    procedure LoadWithSubGroup(const AGroupKey: Integer);
    function Last: TscrMacrosItem;
    procedure Assign(ASource: TscrMacrosList);

    //Возвращает данные макроса по номеру
    property Macros[Index: Integer]: TscrMacrosItem read GetMacros write SetMacros; default;
    //Возвращает данные макроса по имени
    property MacrosByName[AName: ShortString]: TscrMacrosItem read GetMacrosByName write SetMacrosByName;
    property MacrosByID[AId: Integer]: TscrMacrosItem read GetMacrosByID write SetMacrosByID;
    property Transaction: TIBTransaction read FTransaction write FTransaction;
    property Count: Integer read GetCount;
  end;

//Класс служит для хранения данных одной папки.
type
  TscrMacrosGroupItem = class(TscrCustomItem)
  private
    FIsGlobal: Boolean;
    FParent: Integer;
    FIsSaved: Boolean;
    FChildIsRead: Boolean;
    FMacrosList: TscrMacrosList;

    function GetIsRoot: Boolean;
    procedure SetIsGlobal(const Value: Boolean);
    procedure SetParent(const Value: Integer);

  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    procedure Assign(Source: TscrMacrosGroupItem);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromStream(AStream: TStream);
    procedure ReadFromDataSet(ADataSet: TIBCustomDataSet);
    procedure ReadFromSQL(ASQL: TIBSQL);

    property Parent: Integer read FParent write SetParent;
    property IsGlobal: Boolean read FIsGlobal write SetIsGlobal;
    property IsRoot: Boolean read GetIsRoot;
    property IsSaved: Boolean read FIsSaved write FIsSaved;
    property ChildIsRead: Boolean read FChildIsRead write FChildIsRead;
    property MacrosList: TscrMacrosList read FMacrosList;
  end;

//Класс служит для хранения данных папок.
type
  TscrMacrosGroup = class(TObject)
  private
    FTransaction: TIBTransaction;
    FGroupItems: TList;
    FUseScriptMethod: Boolean;

    function GetCount: Integer;
    function GetGroupItems(Index: Integer): TscrMacrosGroupItem;
    procedure SetGroupItems(Index: Integer;
      const Value: TscrMacrosGroupItem);
    function GetGroupByName(AName: ShortString): TscrMacrosGroupItem;
    procedure SetGroupByName(AName: ShortString;
      const Value: TscrMacrosGroupItem);
    function GetGroupItemsByID(AID: Integer): TscrMacrosGroupItem;
    procedure SetGroupItemsByID(AID: Integer;
      const Value: TscrMacrosGroupItem);
    procedure SetTransaction(const Value: TIBTransaction);
    
  public
    constructor Create(const AnUseScriptMethod: Boolean);
    destructor Destroy; override;

    function IndexOfByName(AName: ShortString): Integer;
    function IndexOf(GroupItem: TscrMacrosGroupItem): Integer;
    function IndexOfByID(AID: Integer): Integer;
    //Запись информации в поток.
    procedure SaveToStream(AStream: Tstream);
    //Чтение информации из потока.
    procedure LoadFromStream(AStream:TStream);
    procedure Clear;
    function Add(const AGroupItem: TscrMacrosGroupItem): Integer;
    //Загрузка папки из базы данных. Данные должны выбираться в зависимости от ключа
    procedure Load(const AId: Integer; const AnUseScriptMethod: Boolean = True);
    function Last: TscrMacrosGroupItem;
    procedure Sort;

    //Возвращает данные папки по номеру
    property GroupItems[Index: Integer]: TscrMacrosGroupItem read GetGroupItems write SetGroupItems; default;
    //Возвращает данные папки по имени
    property GroupItemsByName[AName: ShortString]: TscrMacrosGroupItem read GetGroupByName write SetGroupByName;
    //Возвращает данные папки по ID
    property GroupItemsByID[AID: Integer]: TscrMacrosGroupItem read GetGroupItemsByID write SetGroupItemsByID;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property Count: Integer read GetCount;
  end;

implementation

uses
  Windows, gdcConstants, gdcMacros, rp_report_const, contnrs, gd_security;

type
  TLabelStream = array[0..3] of char;

const
  SCR_MACROS_GROUP = '^MCG';
  SCR_MACROSLIST = '^MCL';
  LblSize = SizeOf(TLabelStream);

  DB_ERROR = 'Ошибка базы данных';
  STREAM_ERROR = 'Неверный формат данных';

  DefaultFoulderName = 'Папка';
  DefaultMacrosName = 'Макрос';

  ALL_MACROS = -1;
  ALL_LOCAL_MACROS = -2;
  ALL_GLOBAL_MACROS = -3;

// Only for testing
{$IFDEF DEBUG}
var
  glbMacrosItemCount: Integer;
  glbMacrosListCount: Integer;
  glbMacrosGroupItemCount: Integer;
  glbMacrosGroupCount: Integer;
  ItemList: TObjectList;
{$ENDIF}

{ TscrMacrosItem }
procedure TscrMacrosItem.Assign(Source: TObject);
begin
  Assert(Source is TscrMacrosItem, 'Error');
  FId := TscrMacrosItem(Source).Id;
  FGroupKey := TscrMacrosItem(Source).GroupKey;
  FFunctionKey := TscrMacrosItem(Source).FunctionKey;
  FIsRebuild := TscrMacrosItem(Source).IsRebuild;
//  FIsLocalExecute := TscrMacrosItem(Source).IsLocalExecute;
  FServerKey := TscrMacrosItem(Source).ServerKey;
  FExecuteDate := TscrMacrosItem(Source).ExecuteDate;
  FName := TscrMacrosItem(Source).Name;
  FIsGlobal := TscrMacrosItem(Source).IsGlobal;
  FShortCut := TscrMacrosItem(Source).ShortCut;
end;

constructor TscrMacrosItem.Create;
begin
  inherited;

  FItemType := itMacros;
  FGroupKey := 0;
  FFunctionKey := 0;
  FName := DefaultMacrosName;
  FIsGlobal := False;
{$IFDEF DEBUG}
  Inc(glbMacrosItemCount);
{$ENDIF}
end;

destructor TscrMacrosItem.Destroy;
begin
{$IFDEF DEBUG}
  Dec(glbMacrosItemCount);
{$ENDIF}
  inherited;
end;

procedure TscrMacrosItem.ReadFromDataSet(ADataSet: TIBCustomDataSet);
begin
  try
    FId := ADataSet.FieldByName(fnId).AsInteger;
    FGroupKey := ADataSet.FieldByName(fnMacrosGroupKey).AsInteger;
    FunctionKey := ADataSet.FieldByName(fnFunctionKey).AsInteger;
    FIsRebuild := Boolean(ADataSet.FieldByName(fnIsRebuild).AsInteger);
//    FIsLocalExecute := Boolean(ADataSet.FieldByName(fnIsLocalExecute).AsInteger);
    FServerKey := ADataSet.FieldByName(fnServerKey).AsInteger;
    FExecuteDate := ADataSet.FieldByName(fnExecuteDate).AsString;
    FShortCut := ADataSet.FieldByName(fnShortCut).AsInteger;
    Name := ADataSet.FieldByName(fnName).AsString;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

procedure TscrMacrosItem.LoadFromStream(AStream: TStream);
begin
  AStream.ReadBuffer(Fid, SizeOf(FId));
  AStream.ReadBuffer(FGroupKey, SizeOf(FGroupKey));
  AStream.ReadBuffer(FName, SizeOf(FName));
  AStream.ReadBuffer(FFunctionKey, SizeOf(FFunctionKey));
  AStream.ReadBuffer(FIsGlobal, SizeOf(FIsGlobal));
  AStream.ReadBuffer(FIsRebuild, SizeOf(FIsRebuild));
//  AStream.Read(FIsLocalExecute, SizeOf(FIsLocalExecute));
  AStream.ReadBuffer(FServerKey, SizeOf(FServerKey));
  AStream.ReadBuffer(FExecuteDate, SizeOf(FExecuteDate));
  AStream.ReadBuffer(FShortCut, SizeOf(FShortCut));
end;

procedure TscrMacrosItem.SaveToStream(AStream: TStream);
begin
  AStream.Write(FId, SizeOf(FId));
  AStream.Write(FGroupKey, SizeOf(FGroupKey));
  AStream.Write(FName, SizeOf(FName));
  AStream.Write(FFunctionKey, SizeOf(FFunctionKey));
  AStream.Write(FIsGlobal, SizeOf(FIsGlobal));
  AStream.Write(FIsRebuild, SizeOf(FIsRebuild));
//  AStream.Write(FIsLocalExecute, SizeOf(FIsLocalExecute));
  AStream.Write(FServerKey, SizeOf(FServerKey));
  AStream.Write(FExecuteDate, SizeOf(FExecuteDate));
   AStream.Write(FShortCut, SizeOf(FShortCut));
end;


procedure TscrMacrosItem.SetIsGlobal(const Value: boolean);
begin
  FIsGlobal := Value;
end;


procedure TscrMacrosItem.ReadFromSQL(ASQL: TIBSQL);
begin
  try
    FId := ASQL.FieldByName(fnId).AsInteger;
    FGroupKey := ASQL.FieldByName(fnMacrosGroupKey).AsInteger;
    FunctionKey := ASQL.FieldByName(fnFunctionKey).AsInteger;
    FIsRebuild := Boolean(ASQL.FieldByName(fnIsRebuild).AsInteger);
    FServerKey := ASQL.FieldByName(fnServerKey).AsInteger;
    FExecuteDate := ASQL.FieldByName(fnExecuteDate).AsString;
    FShortCut := ASQL.FieldByName(fnShortCut).AsInteger;
    Name := ASQL.FieldByName(fnName).AsString;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

{ TscrMacrosList }

function TscrMacrosList.Add(const AMacrosItem: TscrMacrosItem): Integer;
begin
  Result := FList.Add(AMacrosItem);
end;

procedure TscrMacrosList.Assign(ASource: TscrMacrosList);
var
  I: Integer;
begin
  Clear;
  if Assigned(ASource) then
  begin
    for I := 0 to Count - 1 do
    begin
      Macros[Add(TscrMacrosItem.Create)].Assign(ASource.Macros[I]);
    end;
  end;
end;

procedure TscrMacrosList.Clear;
begin
  while FList.Count > 0 do
  begin
    Macros[0].Free;
    FList.Delete(0);
  end;
end;

constructor TscrMacrosList.Create(const AnUseScriptMethod: Boolean);
begin
  inherited Create;
  FList := TList.Create;
  FUseScriptMethod := AnUseScriptMethod;
{$IFDEF DEBUG}
  ItemList.Add(Self);
  Inc(glbMacrosListCount);
{$ENDIF}
end;


destructor TscrMacrosList.Destroy;
begin
  Clear;
  FList.Free;
{$IFDEF DEBUG}
  Dec(glbMacrosListCount);
  ItemList.Extract(Self);
{$ENDIF}  
  inherited;
end;

function TscrMacrosList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TscrMacrosList.GetMacros(Index: Integer): TscrMacrosItem;
begin
  Result := TscrMacrosItem(FList.Items[Index]);
end;

function TscrMacrosList.GetMacrosByID(AId: Integer): TscrMacrosItem;
var
  Index: Integer;
begin
  Index := IndexOfById(AID);
  if  Index = -1 then
    Result := nil
  else
    Result := Macros[Index];
end;

function TscrMacrosList.GetMacrosByName(AName: ShortString): TscrMacrosItem;
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if  Index = -1 then
    Result := nil
  else
    Result := Macros[Index];
end;

function TscrMacrosList.IndexOf(MacrosItem: TscrMacrosItem): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Macros[Result] <> MacrosItem) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrMacrosList.IndexOfByID(AID: Integer): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Macros[Result].Id <> AID) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrMacrosList.IndexOfByName(AName: ShortString): Integer;
begin
  Result := 0;
  while (Result < FList.Count) and (Macros[Result].Name <> AName) do
    Inc(Result);
  if Result = FList.Count then
    Result := -1;
end;

function TscrMacrosList.Last: TscrMacrosItem;
begin
  Result := TscrMacrosItem(FList.Last);
end;

procedure TscrMacrosList.Load(const AGroupKey: integer);
var
  gdcMacros: TgdcMacros;
  Flag: Boolean;
begin
  gdcMacros := TgdcMacros.Create(nil);
  try
    gdcMacros.UseScriptMethod := FUseScriptMethod;
    gdcMacros.QueryFiltered := False;
    if Assigned(FTransaction) then
    begin
      Flag := not FTransaction.InTransaction;
      if Flag then
        FTransaction.StartTransaction;
      gdcMacros.Transaction := FTransaction;
      gdcMacros.SubSet := ssMacrosGroup;
      gdcMacros.ParamByName('macrosgroupkey').AsInteger := AGroupKey;
      gdcMacros.OnlyDisplaying := True;
      gdcMacros.Open;
      Clear;
      while not gdcMacros.Eof do
      begin
        Macros[Add(TscrMacrosItem.Create)].ReadFromDataSet(gdcMacros);
        gdcMacros.Next;
      end;
      if Flag then
        FTransaction.Commit;
    end
    else
      raise Exception.Create(DB_ERROR);
  finally
    gdcMacros.Free;
  end;
end;

procedure TscrMacrosList.LoadFromStream(AStream: TStream);
var
  I, ItemCount: Integer;
  Lbl: TLabelStream;
begin
  AStream.ReadBuffer(Lbl, LblSize);
  if Lbl = SCR_MACROSLIST then
  begin
    Clear;
    AStream.ReadBuffer(ItemCount, SizeOf(FList.Count));
    for I := 0 to ItemCount - 1 do
      Macros[Add(TscrMacrosItem.Create)].LoadFromStream(AStream);
  end else
    raise Exception.Create(STREAM_ERROR);
end;

procedure TscrMacrosList.LoadWithSubGroup(const AGroupKey: Integer);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT z.* FROM EVT_MACROSGROUP MG1 JOIN EVT_MACROSGROUP ' +
      'MG2 ON MG1.LB  <=  MG2.LB AND MG1.RB  >=  MG2.RB JOIN EVT_MACROSLIST Z ' +
      'ON z.displayinmenu = 1 AND Z.MACROSGROUPKEY  =  MG2.ID WHERE (MG1.ID  =  :id) AND ' +
      'G_SEC_TEST(Z.AVIEW,  :ingroup)  <>  0 ORDER BY MG2.LB, Z.NAME';
    SQL.ParamByName('id').AsInteger := AGroupKey;
    SQL.ParamByName('ingroup').AsInteger := IBLogin.Ingroup;
    SQL.ExecQuery;
    Clear;
    while not SQL.Eof do
    begin
      Macros[Add(TscrMacrosItem.Create)].ReadFromSQL(SQL);
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TscrMacrosList.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  AStream.Write(SCR_MACROSLIST, LblSize);
  AStream.Write(FList.Count, SizeOf(FList.Count));
  for I := 0 to FList.Count - 1 do
    Macros[I].SaveToStream(AStream);
end;

procedure TscrMacrosList.SetMacros(Index: Integer;
  const Value: TscrMacrosItem);
begin
  TscrMacrosItem(FList.Items[Index]).Assign(Value);
end;

procedure TscrMacrosList.SetMacrosByID(AId: Integer;
  const Value: TscrMacrosItem);
var
  Index: Integer;
begin
  Index := IndexOfById(AId);
  if Index <> -1 then
    TscrMacrosItem(FList.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %d ненайдено',[AId]);
end;

procedure TscrMacrosList.SetMacrosByName(AName: ShortString;
  const Value: TscrMacrosItem);
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if Index <> -1 then
    TscrMacrosItem(FList.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %s ненайдено',[AName]);
end;

{ TscrMacrosTreeItem }
procedure TscrMacrosGroupItem.Assign(Source: TscrMacrosGroupItem);
begin
  FId := Source.Id;
  FParent := Source.Parent;
  FIsGlobal := Source.IsGlobal;
  FName := Source.Name;
end;

constructor TscrMacrosGroupItem.Create(const AnUseScriptMethod: Boolean);
begin
  inherited Create;

  FItemType := itMacrosFolder;
  FParent := 0;
  FName := DefaultFoulderName;
  FIsGlobal := False;
  FIsSaved := False;
  FChildIsRead := False;
  FMacrosList := TscrMacrosList.Create(AnUseScriptMethod);

{$IFDEF DEBUG}
  Inc(glbMacrosGroupItemCount);
{$ENDIF}  
end;

destructor TscrMacrosGroupItem.Destroy;
begin
{$IFDEF DEBUG}
  Dec(glbMacrosGroupItemCount);
{$ENDIF}
  FMacrosList.Free;
  inherited;
end;

procedure TscrMacrosGroupItem.ReadFromDataSet(ADataSet: TIBCustomDataSet);
begin
  try
    Id := ADataSet.FieldByName(fnId).AsInteger;
    Parent := ADataSet.FieldByName(fnParent).AsInteger;
    IsGlobal := Boolean(ADataSet.FieldByName(fnIsGlobal).AsInteger);
    Name := ADataSet.FieldByName(fnName).AsString;
    FIsSaved := True;
    FChildIsRead :=False;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

procedure TscrMacrosGroupItem.LoadFromStream(AStream: TStream);
begin
  AStream.ReadBuffer(Fid, SizeOf(FId));
  AStream.ReadBuffer(FParent, SizeOf(FParent));
  AStream.ReadBuffer(FName, SizeOf(FName));
  AStream.ReadBuffer(FIsGlobal, SizeOf(FIsGlobal));
end;

procedure TscrMacrosGroupItem.SaveToStream(AStream: TStream);
begin
  AStream.Write(FId, SizeOf(FId));
  AStream.Write(FParent, SizeOf(FParent));
  AStream.Write(FName, SizeOf(FName));
  AStream.Write(FIsGlobal, SizeOf(FIsGlobal));
end;

{ TscrMacrosList }

function TscrMacrosGroup.Add(const AGroupItem: TscrMacrosGroupItem): Integer;
begin
  Result := FGroupItems.Add(AGroupItem);
end;

procedure TscrMacrosGroup.Clear;
begin
  While FGroupItems.Count > 0 do
  begin
    GroupItems[0].Free;
    FGroupItems.Delete(0);
  end;
end;

constructor TscrMacrosGroup.Create(const AnUseScriptMethod: Boolean);
begin
  inherited Create;
  FGroupItems := TList.Create;
  FUseScriptMethod := AnUseScriptMethod;
{$IFDEF DEBUG}
  ItemList.Add(Self);
  Inc(glbMacrosGroupCount);
{$ENDIF}
end;

destructor TscrMacrosGroup.Destroy;
begin
  Clear;
  FGroupItems.Free;
{$IFDEF DEBUG}
  Dec(glbMacrosGroupCount);
  ItemList.Extract(Self);
{$ENDIF}  
  inherited;
end;

function TscrMacrosGroup.GetCount: Integer;
begin
  Result := FGroupItems.Count;
end;

function TscrMacrosGroup.GetGroupByName(
  AName: ShortString): TscrMacrosGroupItem;
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if  Index = -1 then
    Result := nil
  else
    Result := GroupItems[Index];
end;

function TscrMacrosGroup.GetGroupItems(
  Index: Integer): TscrMacrosGroupItem;
begin
  Result := FGroupItems[Index];
end;

function TscrMacrosGroup.GetGroupItemsByID(
  AID: Integer): TscrMacrosGroupItem;
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

function TscrMacrosGroup.IndexOf(GroupItem: TscrMacrosGroupItem): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result] <> GroupItem) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrMacrosGroup.IndexOfByID(AID: Integer): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result].Id <> AID) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrMacrosGroup.IndexOfByName(AName: ShortString): Integer;
begin
  Result := 0;
  while (Result < FGroupItems.Count) and (GroupItems[Result].Name <> AName) do
    Inc(Result);
  if Result = FGroupItems.Count then
    Result := -1;
end;

function TscrMacrosGroup.Last: TscrMacrosGroupItem;
begin
  Result := TscrMacrosGroupItem(FGroupItems.Last);
end;

procedure TscrMacrosGroup.Load(const AId: Integer; const AnUseScriptMethod: Boolean = True);
var
  SQL: TIBSQL;
  MacrosList: TscrMacrosList;
  TmpMcr: TscrMacrosItem;
  I: Integer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT z.* FROM evt_macrosgroup z JOIN evt_macrosgroup z1 ON ' +
      ' z.lb >= z1.lb and z.rb <= z1.rb WHERE z1.id = :id ' +
      ' ORDER BY Z.LB, Z.NAME ';
    SQL.ParamByName('id').AsInteger := AId;
    SQL.ExecQuery;
    Clear;
    while not SQL.Eof do
    begin
      Add(TscrMacrosGroupItem.Create(FUseScriptMethod));
      Last.ReadFromSQL(SQL);
      Last.MacrosList.Transaction := FTransaction;
      SQL.Next;
    end;
    Sort;
    MacrosList := TscrMacrosList.Create(FUseScriptMethod);
    try
      MacrosList.Transaction := FTransaction;
      MacrosList.LoadWithSubGroup(AId);
      for I := 0 to MacrosList.Count - 1 do
      begin
        TmpMcr := TscrMacrosItem.Create;
        TmpMcr.Assign(MacrosList[I]);
        GroupItemsByID[MacrosList[I].GroupKey].MacrosList.Add(TmpMcr);
      end;
    finally
      MacrosList.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TscrMacrosGroup.LoadFromStream(AStream: TStream);
var
  I, ItemCount: Integer;
  Lbl: TLabelStream;
begin
  AStream.ReadBuffer(Lbl, LblSize);
  if Lbl = SCR_MACROS_GROUP then
  begin
    Clear;
    AStream.ReadBuffer(ItemCount, SizeOf(FGroupItems.Count));
    for I := 0 to ItemCount - 1 do
      GroupItems[Add(TscrMacrosGroupItem.Create(FUseScriptMethod))].LoadFromStream(AStream);
  end else
    raise Exception.Create(STREAM_ERROR);
end;

procedure TscrMacrosGroup.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  AStream.Write(SCR_MACROS_GROUP, LblSize);
  AStream.Write(FGroupItems.Count, SizeOf(FGroupItems.Count));
  for I := 0 to FGroupItems.Count - 1 do
    GroupItems[I].SaveToStream(AStream);
end;

procedure TscrMacrosGroup.SetGroupByName(AName: ShortString;
  const Value: TscrMacrosGroupItem);
var
  Index: Integer;
begin
  Index := IndexOfByName(AName);
  if Index <> -1 then
    TscrMacrosGroupItem(FGroupItems.Items[Index]).Assign(Value)
  else
   raise Exception.CreateFmt('Значение %s ненайдено',[AName]);
end;

procedure TscrMacrosGroup.SetGroupItems(Index: Integer;
  const Value: TscrMacrosGroupItem);
begin
  TscrMacrosGroupItem(FGroupItems.Items[Index]).Assign(Value);
end;

function SortCompare(Item1, Item2: Pointer): Integer;
var
  S1, S2: string;
begin
  Result := TscrMacrosGroupItem(Item1).Parent - TscrMacrosGroupItem(Item2).Parent;
  if Result = 0 then
  begin
    S1 := TscrMacrosGroupItem(Item1).Name;
    S2 := TscrMacrosGroupItem(Item2).Name;
    Result := StrComp(PChar(S1), PChar(S2));
  end;
end;

procedure TscrMacrosGroup.SetGroupItemsByID(AID: Integer;
  const Value: TscrMacrosGroupItem);
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

procedure TscrMacrosGroup.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

procedure TscrMacrosGroup.Sort;
begin
  FGroupItems.Sort(SortCompare);
end;

function TscrMacrosGroupItem.GetIsRoot: Boolean;
begin
  Result := FParent = -1;
end;

procedure TscrMacrosGroupItem.SetIsGlobal(const Value: Boolean);
begin
  FIsGlobal := Value;
  FIsSaved := False;
end;

procedure TscrMacrosGroupItem.SetParent(const Value: Integer);
begin
  FParent := Value;
  FIsSaved := False;
end;

{ TscrCustomItem }

constructor TscrCustomItem.Create;
begin
  inherited;
  FId := 0;
  FName := '';
  FItemType := itNone;
{$IFDEF DEBUG}
  ItemList.Add(Self);
{$ENDIF}
end;

destructor TscrCustomItem.Destroy;
begin
{$IFDEF DEBUG}
  ItemList.Remove(Self);
{$ENDIF}
  inherited;
end;

{ TscrScriptFunction }

procedure TscrCustomScriptFunction.Assign(Source: TObject);
begin
  Assert(Source is TscrScriptFunction, 'Error');
  FId := TscrScriptFunction(Source).Id;
  FName := TscrScriptFunction(Source).Name;
  FModule := TscrScriptFunction(Source).Module;
end;

constructor TscrCustomScriptFunction.Create;
begin
  inherited;

  FItemType := itScriptFunction;
  Module := scrUnkonownModule;
end;


procedure TscrCustomScriptFunction.ReadFromDataSet(ADataSet: TIBCustomDataSet);
begin
  FId := ADataSet.FieldByName(fnId).AsInteger;
  Name := ADataSet.FieldByName(fnName).AsString;
  Module := ADataSet.FieldByName('module').AsString;
end;


procedure TscrCustomScriptFunction.ReadFromSQL(SQL: TIBSQL);
begin
  FId := SQL.FieldByName(fnId).AsInteger;
  Name := SQL.FieldByName(fnName).AsString;
  Module := SQL.FieldByName('module').AsString;
end;

procedure TscrCustomScriptFunction.SetModule(const Value: ShortString);
begin
  FModule := Value;
end;

{ TscrScriptFunctionGroup }

constructor TscrScriptFunctionGroup.Create;
begin
  inherited;

  FItemType := itScriptFunctionGroup;
end;

{ TscrVBClass }

constructor TscrVBClass.Create;
begin
  inherited;

  FItemType := itVBClassGroup;
end;

{ TscrVBClassGroup }

constructor TscrVBClassGroup.Create;
begin
  inherited;

  FItemType := itVBClassGroup;
end;

{ TscrConst }

constructor TscrConst.Create;
begin
  inherited;

  FItemType := itConst;
  Module := scrConst;
end;

{ TscrGlobalObject }

constructor TscrGlobalObject.Create;
begin
  inherited;

  FItemType := itGlobalObject;
  Module := scrGlobalObject;
end;

{ TscrConstGroup }

constructor TscrConstGroup.Create;
begin
  inherited;

  FItemType := itConstGroup;
end;

{ TscrGlobalObjectGroup }

constructor TscrGlobalObjectGroup.Create;
begin
  inherited;

  FItemType := itGlobalObjectGroup;
end;

procedure TscrMacrosGroupItem.ReadFromSQL(ASQL: TIBSQL);
begin
  try
    Id := ASQL.FieldByName(fnId).AsInteger;
    Parent := ASQL.FieldByName(fnParent).AsInteger;
    IsGlobal := Boolean(ASQL.FieldByName(fnIsGlobal).AsInteger);
    Name := ASQL.FieldByName(fnName).AsString;
    FIsSaved := True;
    FChildIsRead :=False;
  except
    raise Exception.Create(DB_ERROR);
  end;
end;

initialization
{$IFDEF DEBUG}
  glbMacrosItemCount := 0;
  glbMacrosListCount := 0;
  glbMacrosGroupItemCount := 0;
  glbMacrosGroupCount := 0;
  ItemList := TObjectList.Create(False);
{$ENDIF}
finalization
{$IFDEF DEBUG}
  {ItemList.Pack;
  if ItemList.Count > 0 then
  begin
    Msg := 'Неосвобождены: ';
    for I := 0 to ItemList.Count - 1 do
      Msg := Msg + #13#10 + TscrCustomItem(ItemList[I]).Name;
    MessageBox(0, PChar(Msg), 'Error', MB_OK);
  end;}
  ItemList.Free;
{$ENDIF}
end.
