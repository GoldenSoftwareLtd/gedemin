
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    obj_QueryList_unit.pas

  Abstract

    Gedemin project. It is COM-object for Report System.
    Include List of Query (IB or ClientDataSet).
    Uses for obtaining start selection.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    ~01.03.01    JKL        Initial version.

--}

unit obj_QueryList;

interface

uses
  ComObj, ActiveX, AxCtrls, gsdbquery_TLB, StdVcl, SysUtils, Contnrs,
  Windows, Db, dbtables, DBClient, Classes{, gd_MultiStringList}, xTable, DBF;

const
  QueryNotAssigned = 'Query not assigned';
  FieldNotAssigned = 'Field not assigned';
  OnlyForIBQuery = 'Method only for Query';
  OnlyForClientDataSet = 'Method only for MemTable';

type
  TgsdbParam = class(TAutoObject, IgsdbField)
  private
    FParam: TParam;
  protected
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_FieldType: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_Required: WordBool; safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
  public
    constructor Create(AnParam: TParam);
    destructor Destroy; override;
  end;

type
  TgsdbDataSet = class(TAutoObject, IConnectionPointContainer, IgsdbQuery, IgsdbField)
  private
    FOnCalcEvent: TThreadMethod;

    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FFetchBlob: Boolean;
    FIndexFields: String;

    function GetFieldTypeFromStr(const AnTypeName: String): TFieldType;
    function GetStrFromFieldType(const AnFieldType: TFieldType): String;
    function GetQuery: TQuery;
    function GetClientDataSet: TClientDataSet;
    procedure SetDatabase(const anValue: String);
    function GetDataSet: TDataSet;
  protected
    FDataSet: TDataSet;
    FCurrentField: TField;

    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;

    function  Get_AsString: WideString; virtual; safecall;
    procedure Set_AsString(const Value: WideString); virtual; safecall;
    function  Get_AsInteger: Integer; virtual; safecall;
    procedure Set_AsInteger(Value: Integer); virtual; safecall;
    function  Get_AsFloat: Double; virtual; safecall;
    procedure Set_AsFloat(Value: Double); virtual; safecall;


    function  Get_Database: WideString; virtual; safecall;
    procedure Set_Database(const Value: WideString); virtual; safecall;

    function  Get_AsVariant: OleVariant; virtual; safecall;
    procedure Set_AsVariant(Value: OleVariant); virtual; safecall;
    function  Get_FieldType: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_Required: WordBool; safecall;

    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;


    procedure Open; virtual; safecall;
    procedure ExecSQL; virtual; safecall;
    procedure Close; virtual; safecall;
    procedure First; virtual; safecall;
    procedure Last; virtual; safecall;
    function  Eof: WordBool; virtual; safecall;
    function  Bof: WordBool; virtual; safecall;
    procedure Next; virtual; safecall;
    procedure Prior; virtual; safecall;
    procedure AddField(const FieldName: WideString; const FieldType: WideString;
                       FieldSize: Integer; Required: WordBool); virtual; safecall;
    procedure ClearFields; virtual; safecall;
    procedure Append; virtual; safecall;
    procedure Edit; virtual; safecall;
    procedure Delete; virtual; safecall;
    procedure Post; virtual; safecall;
    procedure Cancel; virtual; safecall;
    procedure Insert; safecall;

    function  Get_Fields(Index: Integer): IgsdbField; virtual; safecall;
    function  Get_FieldByName(const FieldName: WideString): IgsdbField; virtual; safecall;
    function  Get_IsResult: WordBool; virtual; safecall;
    procedure Set_IsResult(Value: WordBool); virtual; safecall;
    function  Get_SQL: WideString; virtual; safecall;
    procedure Set_SQL(const Value: WideString); virtual; safecall;
    function  Get_Params(Index: Integer): IgsdbField; virtual; safecall;
    function  Get_ParamByName(const ParamName: WideString): IgsdbField; virtual; safecall;
    function  Get_FieldCount: Integer; virtual; safecall;
    function  Get_ParamCount: Integer; virtual; safecall;
    function  Get_OnCalcField: LongWord; virtual; safecall;
    procedure Set_OnCalcField(Value: LongWord); virtual; safecall;
    function  Get_FetchBlob: WordBool; safecall;
    procedure Set_FetchBlob(Value: WordBool); safecall;
    function  Get_RecordCount: Integer; safecall;
    function  Get_Active: WordBool; safecall;
  public
    constructor Create(const AnMemTable: Integer; const AnChildClass: Boolean = False);
    destructor Destroy; override;

    procedure Initialize; override;

    property Database: String write SetDatabase;
    property DataSet: TDataSet read GetDataSet;
  end;

type
  TgsdbQueryList = class(TAutoObject, IgsdbQueryList)
  private
    FQueryList: TList;
    FCurrentField: TField;

    function GetQuery(Index: Integer): TDataSet;
    function GetCount: Integer;
    function GetIndexQueryByName(const Name: WideString): Integer;
  protected
    function  Add(const QueryName: WideString; MemQuery: Integer): Integer; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    function  Get_Query(Index: Integer): IgsdbQuery; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_QueryByName(const Name: WideString): IgsdbQuery; safecall;
    procedure DeleteByName(const AName: WideString); safecall;
    procedure MainInitialize; safecall;
    procedure Commit; safecall;

  public
    procedure Initialize; override;
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Query[Index: Integer]: TDataSet read GetQuery;

    function  AddRealQuery(const AnRealQuery: TgsdbDataSet): Integer;
    procedure ClearObjectList;
  end;

type
  TgsdbCustomValue = class(TAutoObject, IgsdbField)
  private
    FParam: Variant;
  protected
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    function  Get_FieldType: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_Required: WordBool; safecall;
  public
    constructor Create(AnParam: Variant);
  end;

implementation

uses
  ComServ, Provider, TypInfo;

type
  TFieldCracker = class(TField);

{TgsdbIBQuery}

constructor TgsdbDataSet.Create(const AnMemTable: Integer; const AnChildClass: Boolean = False);
begin
  inherited Create;

  if not AnChildClass then
  begin
    case AnMemTable of
    1:  FDataSet := TClientDataSet.Create(nil);
    0:  FDataSet := TQuery.Create(nil);
    2:  FDataSet := TxQuery.Create(nil);
    3:  FDataSet := TxTable.Create(nil);
    4:  FDataSet := TDBF.Create(nil);
    end;
    FDataSet.Tag := 0;
    FCurrentField := nil;
  end;
  FFetchBlob := False;
  FIndexFields := '';
end;

destructor TgsdbDataSet.Destroy;
begin
  FreeAndNil(FDataSet);
  inherited Destroy;
end;

function TgsdbDataSet.GetQuery: TQuery;
begin
  if not (FDataSet is TQuery) then
    raise Exception.Create(OnlyForIBQuery);
  Result := FDataSet as TQuery;
end;

function TgsdbDataSet.GetClientDataSet: TClientDataSet;
begin
  if not (FDataSet is TClientDataSet) then
    raise Exception.Create(OnlyForClientDataSet);
  Result := FDataSet as TClientDataSet;
end;

procedure TgsdbDataSet.SetDatabase(const AnValue: String);
begin
  if FDataSet is TDBF then
  begin
    (FDataSet as TDBF).FilePath := AnValue
  end
  else
  begin
    if FDataSet is TQuery then
      (FDataSet as TQuery).DatabaseName := AnValue
    else
      (FDataSet as TxTable).DatabaseName := AnValue
  end
end;

function TgsdbDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TgsdbDataSet.GetFieldTypeFromStr(const AnTypeName: String): TFieldType;
var
  I: Integer;
begin
  if AnTypeName > '' then
  begin
    I := GetEnumValue(TypeInfo(TFieldType), AnTypeName);
    if I <> -1 then
    begin
      Result := TFieldType(I);
      exit;
    end;
  end;

  raise Exception.Create('Invalid type specified.');
end;

function TgsdbDataSet.Get_AsString: WideString;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.Text;
end;

procedure TgsdbDataSet.Set_AsString(const Value: WideString);
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  FCurrentField.Text := Value;
end;

function TgsdbDataSet.Get_AsInteger: Integer;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.AsInteger;
end;

procedure TgsdbDataSet.Set_AsInteger(Value: Integer);
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  FCurrentField.AsInteger := Value;
end;

function TgsdbDataSet.Get_AsVariant: OleVariant;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.AsVariant;
end;

procedure TgsdbDataSet.Set_AsVariant(Value: OleVariant);
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  FCurrentField.AsVariant := Value;
end;

procedure TgsdbDataSet.ExecSQL;
begin
  if not (FDataSet is TQuery) then
    raise Exception.Create(OnlyForIBQuery);
  GetQuery.ExecSQL;
end;

procedure TgsdbDataSet.Open;
begin
  try
    if (FDataSet is TQuery) or (FDataSet is TxTable) or (FDataSet is TDBF) then
      FDataSet.Open
    else
      GetClientDataSet.CreateDataSet;
  except
    on E: Exception do
      raise Exception.Create(FDataSet.Name + ': ' + E.Message);
  end;
end;

procedure TgsdbDataSet.Close;
begin
  FDataSet.Close;
end;

procedure TgsdbDataSet.First;
begin
  FDataSet.First;
end;

procedure TgsdbDataSet.Last;
begin
  FDataSet.Last;
end;

function TgsdbDataSet.Eof: WordBool;
begin
  Result := FDataSet.Eof;
end;

function TgsdbDataSet.Get_Fields(Index: Integer): IgsdbField;
begin
  FCurrentField := FDataSet.Fields[Index];
  Result := Self;
end;

function TgsdbDataSet.Get_FieldByName(const FieldName: WideString): IgsdbField;
begin
  FCurrentField := FDataSet.FieldByName(FieldName);
  Result := Self;
end;

function TgsdbDataSet.Bof: WordBool;
begin
  Result := FDataSet.Bof;
end;

procedure TgsdbDataSet.Next;
begin
  FDataSet.Next;
end;

procedure TgsdbDataSet.Prior;
begin
  FDataSet.Prior;
end;

function TgsdbDataSet.Get_IsResult: WordBool;
begin
  Result := FDataSet.Tag <> 0;
end;

procedure TgsdbDataSet.Set_IsResult(Value: WordBool);
begin
  if Value then
    FDataSet.Tag := 1
  else
    FDataSet.Tag := 0;
end;

function TgsdbDataSet.Get_SQL: WideString;
begin
  Result := GeTQuery.SQL.Text;
end;

procedure TgsdbDataSet.Set_SQL(const Value: WideString);
begin
  GeTQuery.SQL.Text := Value;
end;

procedure TgsdbDataSet.AddField(const FieldName: WideString; const FieldType: WideString;
 FieldSize: Integer; Required: WordBool); safecall;
begin
  FDataSet.FieldDefs.Add(FieldName, GetFieldTypeFromStr(FieldType), FieldSize,
   Required);
end;

procedure TgsdbDataSet.ClearFields;
begin
  GetClientDataSet.Close;
  GetClientDataSet.FieldDefs.Clear;
end;

procedure TgsdbDataSet.Append;
begin
  FDataSet.Append;
end;

procedure TgsdbDataSet.Edit;
begin
  if (FDataSet is TDBF) then
    (FDataSet as TDBF).Edit
  else
  begin
    if (FDataSet is TxTable) then
      (FDataSet as TxTable).Edit
    else
      GetClientDataSet.Edit;
  end;
end;

procedure TgsdbDataSet.Delete;
begin
  if (FDataSet is TDBF) then
    (FDataSet as TDBF).Delete
  else
  begin
    if (FDataSet is TxTable) then
      (FDataSet as TxTable).Delete
    else
      GetClientDataSet.Delete;
  end;    
end;

procedure TgsdbDataSet.Post;
begin
  if (FDataSet is TDBF) then
    (FDataSet as TDBF).Post
  else
  begin
    if (FDataSet is TxTable) then
      (FDataSet as TxTable).Post
    else
      GetClientDataSet.Post;
  end;
end;

procedure TgsdbDataSet.Cancel;
begin
  GetClientDataSet.Cancel;
end;

function TgsdbDataSet.Get_FieldCount: Integer;
begin
  Result := FDataSet.FieldCount;
end;

function TgsdbDataSet.Get_ParamCount: Integer;
begin
  if FDataSet is TQuery then
    Result := GeTQuery.ParamCount
  else
    Result := GetClientDataSet.Params.Count;
end;

function TgsdbDataSet.Get_ParamByName(const ParamName: WideString): IgsdbField;
var
  LocParam: TParam;
begin
  if FDataSet is TQuery then
    LocParam := GeTQuery.ParamByName(ParamName)
  else
    LocParam := GetClientDataSet.Params.ParamByName(ParamName);

  Result := TgsdbParam.Create(LocParam);
end;

function TgsdbDataSet.Get_Params(Index: Integer): IgsdbField;
var
  LocParam: TParam;
begin
  if FDataSet is TQuery then
    LocParam := GeTQuery.Params[Index]
  else
    LocParam := GetClientDataSet.Params[Index];

  Result := TgsdbParam.Create(LocParam);
end;

procedure TgsdbDataSet.Initialize;
begin
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;
end;

procedure TgsdbDataSet.EventSinkChanged(const EventSink: IUnknown);
begin

end;

{TgsdbQueryList}

destructor TgsdbQueryList.Destroy;
begin
  ClearObjectList;
  try
    FreeAndNil(FQueryList);
  except
  end;

  inherited Destroy;
end;

function TgsdbQueryList.Add(const QueryName: WideString; MemQuery: Integer): Integer;
begin
  try
    Result := FQueryList.Add(nil);
    FQueryList.Items[Result] := TgsdbDataSet.Create(MemQuery);
    TgsdbDataSet(FQueryList.Items[Result])._AddRef;
    TgsdbDataSet(FQueryList.Items[Result]).DataSet.Name := QueryName;
    TgsdbDataSet(FQueryList.Items[Result]).Set_IsResult(True);
  except
    on E: Exception do
    begin
      Delete(Result);
      raise Exception.Create('Произошла ошибка при создании нового объекта.'#13#10 +
       E.Message);
    end;
  end;
end;

function TgsdbQueryList.Get_Query(Index: Integer): IgsdbQuery;
begin
  Result := TgsdbDataSet(FQueryList.Items[Index]);
end;

function  TgsdbQueryList.Get_Count: Integer;
begin
  Result := FQueryList.Count;
end;

procedure TgsdbQueryList.Clear;
begin
  MainInitialize;
  Commit;
end;

procedure TgsdbQueryList.Delete(Index: Integer);
begin
  TgsdbDataSet(FQueryList.Items[Index])._Release;
  FQueryList.Items[Index] := nil;
  FQueryList.Delete(Index);
end;

procedure TgsdbQueryList.ClearObjectList;
begin
  Clear;
end;

function TgsdbQueryList.Get_QueryByName(const Name: WideString): IgsdbQuery;
var
  I: Integer;
begin
  Result := nil;
  I := GetIndexQueryByName(Name);
  if I > -1 then
    Result := TgsdbDataSet(FQueryList.Items[I]);
  if Result = nil then
    raise Exception.Create('Query not found');
end;


function TgsdbQueryList.GetQuery(Index: Integer): TDataSet;
begin
  Result := TgsdbDataSet(FQueryList.Items[Index]).DataSet;
end;

function TgsdbQueryList.GetCount: Integer;
begin
  Result := FQueryList.Count;
end;

function TgsdbQueryList.GetIndexQueryByName(const Name: WideString): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FQueryList.Count - 1 do
    if AnsiUpperCase(TgsdbDataSet(FQueryList.Items[I]).DataSet.Name) = AnsiUpperCase(Name) then
    begin
      Result := I;
      Break;
    end;
end;

function TgsdbQueryList.AddRealQuery(const AnRealQuery: TgsdbDataSet): Integer;
begin
  Result := FQueryList.Add(nil);
  try
    FQueryList.Items[Result] := AnRealQuery;
    TgsdbDataSet(FQueryList.Items[Result])._AddRef;
    TgsdbDataSet(FQueryList.Items[Result]).Set_IsResult(True);
  except
    on E: Exception do
    begin
      Delete(Result);
      raise Exception.Create('Произошла ошибка при создании нового объекта.'#13#10 +
       E.Message);
    end;
  end;
end;

procedure TgsdbQueryList.DeleteByName(const AName: WideString);
begin
  Delete(GetIndexQueryByName(AName));
end;

procedure TgsdbQueryList.Commit;
begin
end;

procedure TgsdbQueryList.MainInitialize;
var
  I: Integer;
begin
  for I := 0 to FQueryList.Count - 1 do
  begin
    TgsdbDataSet(FQueryList.Items[I])._Release;
    FQueryList.Items[I] := nil;
  end;
  FQueryList.Clear;
  FCurrentField := nil;
end;

procedure TgsdbQueryList.Initialize;
begin
  inherited;
  FQueryList := TList.Create;
end;

{ TgsdbParam }

constructor TgsdbParam.Create(AnParam: TParam);
begin
  Assert(AnParam <> nil);
  inherited Create;
  FParam := AnParam;
end;

destructor TgsdbParam.Destroy;
begin
  FParam := nil;
  inherited Destroy;
end;

function TgsdbParam.Get_AsFloat: Double;
begin
  Result := FParam.AsFloat;
end;

function TgsdbParam.Get_AsInteger: Integer;
begin
  Result := FParam.AsInteger;
end;

function TgsdbParam.Get_AsString: WideString;
begin
  Result := FParam.AsString;
end;

function TgsdbParam.Get_AsVariant: OleVariant;
begin
  Result := FParam.Value;
end;

function TgsdbParam.Get_FieldName: WideString;
begin
  raise Exception.Create('ParamName Not Supported');
end;

function TgsdbParam.Get_FieldSize: Integer;
begin
  raise Exception.Create('ParamSize Not Supported');
end;

function TgsdbParam.Get_FieldType: WideString;
begin
  raise Exception.Create('ParamType Not Supported');
end;

function TgsdbParam.Get_Required: WordBool;
begin
  raise Exception.Create('ParamRequired Not Supported');
end;

procedure TgsdbParam.Set_AsFloat(Value: Double);
begin
  FParam.AsFloat := Value;
end;

procedure TgsdbParam.Set_AsInteger(Value: Integer);
begin
  FParam.AsInteger := Value;
end;

procedure TgsdbParam.Set_AsString(const Value: WideString);
begin
  FParam.AsString := Value;
end;

procedure TgsdbParam.Set_AsVariant(Value: OleVariant);
begin
  FParam.Value := Value;
end;

function TgsdbDataSet.Get_OnCalcField: LongWord;
begin
  Result := LongWord(Pointer(@FOnCalcEvent));
end;

procedure TgsdbDataSet.Set_OnCalcField(Value: LongWord);
begin
  Integer(Pointer(@FOnCalcEvent)) := Value;
end;

{ TgsdbCustomValue }

constructor TgsdbCustomValue.Create(AnParam: Variant);
begin
  inherited Create;

  FParam := AnParam;
end;

function TgsdbCustomValue.Get_AsFloat: Double;
begin
  Result := FParam;
end;

function TgsdbCustomValue.Get_AsInteger: Integer;
begin
  Result := FParam;
end;

function TgsdbCustomValue.Get_AsString: WideString;
begin
  Result := FParam;
end;

function TgsdbCustomValue.Get_AsVariant: OleVariant;
begin
  Result := FParam;
end;

function TgsdbCustomValue.Get_FieldName: WideString;
begin
  raise Exception.Create('ParamName Not Supported');
end;

function TgsdbCustomValue.Get_FieldSize: Integer;
begin
  raise Exception.Create('ParamSize Not Supported');
end;

function TgsdbCustomValue.Get_FieldType: WideString;
begin
  raise Exception.Create('ParamType Not Supported');
end;

function TgsdbCustomValue.Get_Required: WordBool;
begin
  raise Exception.Create('ParamRequired Not Supported');
end;

procedure TgsdbCustomValue.Set_AsFloat(Value: Double);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsdbCustomValue.Set_AsInteger(Value: Integer);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsdbCustomValue.Set_AsString(const Value: WideString);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsdbCustomValue.Set_AsVariant(Value: OleVariant);
begin
  raise Exception.Create('Set Value Not Supported');
end;

function TgsdbDataSet.Get_FetchBlob: WordBool;
begin
  Result := FFetchBlob;
end;

procedure TgsdbDataSet.Set_FetchBlob(Value: WordBool);
begin
  FFetchBlob := Value;
end;

function TgsdbDataSet.Get_FieldName: WideString;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.FieldName;
end;

function TgsdbDataSet.Get_FieldSize: Integer;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.Size;
end;

function TgsdbDataSet.Get_FieldType: WideString;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := GetStrFromFieldType(FCurrentField.DataType);
end;

function TgsdbDataSet.Get_Required: WordBool;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.Required;
end;

function TgsdbDataSet.GetStrFromFieldType(const AnFieldType: TFieldType): String;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Integer(AnFieldType));
end;

function TgsdbDataSet.Get_RecordCount: Integer;
begin
  Result := FDataSet.RecordCount;
end;

procedure TgsdbDataSet.Insert;
begin
  FDataSet.Insert;
end;

function TgsdbDataSet.Get_Active: WordBool;
begin
  Result := FDataSet.Active;
end;

function TgsdbDataSet.Get_Database: WideString;
begin
  if (FDataSet is TDBF) then
    Result := (FDataSet as TDBF).FilePath
  else
  begin
    if FDataSet is TQuery then
      Result := (FDataSet as TQuery).DatabaseName
    else
      Result := (FDataSet as TxTable).DatabaseName;
  end;
end;

procedure TgsdbDataSet.Set_Database(const Value: WideString);
begin
  if (FDataSet is TDBF) then
    (FDataSet as TDBF).FilePath := Value
  else
  begin
    if FDataSet is TQuery then
      (FDataSet as TQuery).DatabaseName := Value
    else
      (FDataSet as TxTable).DatabaseName := Value
  end;
end;

function TgsdbDataSet.Get_AsFloat: Double;
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  Result := FCurrentField.AsFloat;
end;

procedure TgsdbDataSet.Set_AsFloat(Value: Double);
begin
  Assert(FCurrentField <> nil, FieldNotAssigned);
  FCurrentField.AsFloat := Value;
end;

function TgsdbDataSet.Get_TableName: WideString;
begin
  if (FDataSet is TxTable) then
    Result := (FDataSet as TxTable).TableName;
  if (FDataSet is TDBF) then
    Result := (FDataSet as TDBF).TableName;
end;

procedure TgsdbDataSet.Set_TableName(const Value: WideString);
begin
  if (FDataSet is TxTable) then
    (FDataSet as TxTable).TableName := Value;
  if (FDataSet is TDBF) then
    (FDataSet as TDBF).TableName := Value;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsdbParam, CLASS_gsdb_rpParam,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsdbDataSet, CLASS_gsdb_rpQuery,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsdbQueryList, CLASS_gsdb_rpQueryList,
    ciMultiInstance, tmApartment);
end.
