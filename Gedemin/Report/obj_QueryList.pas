
{++

  Copyright (c) 2001 - 2010 by Golden Software of Belarus

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
  ComObj, ActiveX, AxCtrls, Gedemin_TLB, StdVcl, IBDatabase, SysUtils, Contnrs,
  IBQuery, Windows, Db, Classes, gd_MultiStringList, IBCustomDataSet, DBClient;

const
  QueryNotAssigned = 'Query not assigned';
  FieldNotAssigned = 'Field not assigned';
  OnlyForIBQuery = 'Method only for Query';
  OnlyForClientDataSet = 'Method only for MemTable';

type
  TgsParam = class(TAutoObject, IgsParam)
  private
    FParam: TParam;
  protected
    // IgsObject
    function  Get_Self: Integer; safecall;
    function  Get_DelphiObject: Integer; safecall;
    function  ClassName: WideString; safecall;
    function  ClassParent: WideString; safecall;
    function  InheritsFrom(const AClass: WideString): WordBool; safecall;
    // IgsPersistent
    procedure Assign_(const Source: IgsPersistent); safecall;
    // IgsCollectionItem
    function  Get_Collection: IgsCollection; safecall;
    procedure Set_Collection(const Value: IgsCollection); safecall;
    function  Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function  Get_ID: Integer; safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Index(Value: Integer); safecall;
    function  GetNamePath: WideString; safecall;
    // IgsParam
    function  Get_Bound: WordBool; safecall;
    procedure Set_Bound(Value: WordBool); safecall;
    function  Get_DataType: TgsFieldType; safecall;
    procedure Set_DataType(Value: TgsFieldType); safecall;
    function  Get_IsNull: WordBool; safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    procedure AssignField(const Field: IgsFieldComponent); safecall;
    procedure AssignFieldValue(const Field: IgsFieldComponent; Value: OleVariant); safecall;
    procedure Clear; safecall;
    function  GetDataSize: Integer; safecall;
    function  Get_AsBCD: Currency; safecall;
    procedure Set_AsBCD(Value: Currency); safecall;
    function  Get_AsBlob: WideString; safecall;
    procedure Set_AsBlob(const Value: WideString); safecall;
    function  Get_AsBoolean: WordBool; safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsDate: TDateTime; safecall;
    procedure Set_AsDate(Value: TDateTime); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsMemo: WideString; safecall;
    procedure Set_AsMemo(const Value: WideString); safecall;
    function  Get_AsSmallInt: Integer; safecall;
    procedure Set_AsSmallInt(Value: Integer); safecall;
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsTime: TDateTime; safecall;
    procedure Set_AsTime(Value: TDateTime); safecall;
    function  Get_AsWord: Integer; safecall;
    procedure Set_AsWord(Value: Integer); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_NativeStr: WideString; safecall;
    procedure Set_NativeStr(const Value: WideString); safecall;
    function  Get_ParamType: TgsParamType; safecall;
    procedure Set_ParamType(Value: TgsParamType); safecall;
  public
    constructor Create(AnParam: TParam);
    destructor Destroy; override;

    procedure DestroyObject; safecall;
  end;

type
  TgsDataSet = class(TAutoObject, {IConnectionPointContainer, }IgsQuery)
  private
    FOnCalcEvent: TThreadMethod;

{    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: IgsQueryEvents;}
    FFetchBlob: Boolean;
    FIndexFields: String;

    function GetIBQuery: TIBQuery;
    function GetClientDataSet: TClientDataSet;
    procedure SetDatabase(const AnValue: TIBDatabase);
    procedure SetTransaction(const AnValue: TIBTransaction);
    function GetDataSet: TDataSet;

  protected
    function GetStrFromFieldType(const AnFieldType: TFieldType): String;
  protected
    FDataSet: TDataSet;
    FCurrentField: TField;

{    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;}

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
    procedure AssignFields(const ADataSet: IgsQuery); safecall;
    procedure CopyRecord(const ADataSet: IgsQuery); safecall;
    procedure ClearFields; virtual; safecall;
    procedure Append; virtual; safecall;
    procedure Edit; virtual; safecall;
    procedure Delete; virtual; safecall;
    procedure Post; virtual; safecall;
    procedure Cancel; virtual; safecall;
    procedure Insert; safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;

    function  Get_Fields(Index: Integer): IgsFieldComponent; virtual; safecall;
    function  Get_FieldByName(const FieldName: WideString): IgsFieldComponent; virtual; safecall;
    function  Get_IsResult: WordBool; virtual; safecall;
    procedure Set_IsResult(Value: WordBool); virtual; safecall;
    function  Get_SQL: WideString; virtual; safecall;
    procedure Set_SQL(const Value: WideString); virtual; safecall;
    function  Get_Params(Index: Integer): IgsParam; virtual; safecall;
    function  Get_ParamByName(const ParamName: WideString): IgsParam; virtual; safecall;
    function  Get_FieldCount: Integer; virtual; safecall;
    function  Get_ParamCount: Integer; virtual; safecall;
    function  Get_OnCalcField: LongWord; virtual; safecall;
    procedure Set_OnCalcField(Value: LongWord); virtual; safecall;
    function  Get_FetchBlob: WordBool; safecall;
    procedure Set_FetchBlob(Value: WordBool); safecall;
    function  Get_IndexFields: WideString; safecall;
    procedure Set_IndexFields(const Value: WideString); safecall;
    function  Get_RecordCount: Integer; safecall;
    function  Get_Active: WordBool; safecall;
    function  CreateBlobStream(const Field: IgsFieldComponent; Mode: TgsBlobStreamMode): IgsStream; safecall;
    function  Locate(const KeyFields: WideString; KeyValues: OleVariant; CaseIns: WordBool;
                     PartialKey: WordBool): WordBool; safecall;
    function  Get_Self: Integer; safecall;
  public
    constructor Create(const AnMemTable: Boolean; const AnChildClass: Boolean = False);
    destructor Destroy; override;

    procedure Initialize; override;

    property Database: TIBDatabase write SetDatabase;
    property Transaction: TIBTransaction write SetTransaction;
    property DataSet: TDataSet read GetDataSet;
  end;

type
  TgsQueryList = class(TAutoObject, IgsQueryList)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FQueryList: TList;
    FCurrentField: TField;
    FMasterDetail: TFourStringList;
    FTempMasterDetail: TFourStringList;
    FWasCreateTransaction: Boolean;
    FDataSourceList: TObjectList;

    function GetQuery(Index: Integer): TDataSet;
    function GetCount: Integer;
    function GetIndexQueryByName(const Name: WideString): Integer;
  protected
    function  Add(const QueryName: WideString; MemQuery: WordBool): Integer; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    function  Get_Query(Index: Integer): IgsQuery; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_QueryByName(const Name: WideString): IgsQuery; safecall;
    function  ResultStream: OleVariant; safecall;
    procedure AddMasterDetail(const MasterTable: WideString; const MasterField: WideString;
                              const DetailTable: WideString; const DetailField: WideString); safecall;
    procedure ResultMasterDetail; safecall;
    procedure DeleteByName(const AName: WideString); safecall;
    procedure MainInitialize; safecall;
    procedure Commit; safecall;
    function Get_Self: Integer; safecall;
  public
    constructor Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction;
     const AnIsRealList: Boolean = False);
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Query[Index: Integer]: TDataSet read GetQuery;

    function  AddRealQuery(const AnRealQuery: TgsDataSet): Integer;
    procedure ClearObjectList;
  end;

type
  TgsRealDataSet = class(TgsDataSet)
  private
    function GetDataSet: TDataSet;
    function IsQuery: Boolean;
  protected
    procedure Open; override;
    procedure ExecSQL; override;
    procedure Close; override;
    procedure First; override;
    procedure Last; override;
    function  Eof: WordBool; override;
    function  Bof: WordBool; override;
    procedure Next; override;
    procedure Prior; override;
    procedure AddField(const FieldName: WideString; const FieldType: WideString;
                       FieldSize: Integer; Required: WordBool); override;
    procedure ClearFields; override;
    procedure Append; override;
    procedure Edit; override;
    procedure Delete; override;
    procedure Post; override;
    procedure Cancel; override;

    function  Get_SQL: WideString; override;
    procedure Set_SQL(const Value: WideString); override;
    function  Get_Params(Index: Integer): IgsParam; override;
    function  Get_ParamByName(const ParamName: WideString): IgsParam; override;
    function  Get_ParamCount: Integer; override;
    function  Get_OnCalcField: LongWord; override;
    procedure Set_OnCalcField(Value: LongWord); override;
  public
    constructor Create(const AnIBDataSet: TIBCustomDataSet);
    destructor Destroy; override;

    property DataSet: TDataSet read GetDataSet;
  end;

type
  TgsCustomValue = class(TAutoObject, IgsParam)
  private
    FParam: Variant;
  protected
    // IgsObject
    function  Get_Self: Integer; safecall;
    function  Get_DelphiObject: Integer; safecall;
    function  ClassName: WideString; safecall;
    function  ClassParent: WideString; safecall;
    function  InheritsFrom(const AClass: WideString): WordBool; safecall;
    // IgsPersistent
    procedure Assign_(const Source: IgsPersistent); safecall;
    // IgsCollectionItem
    function  Get_Collection: IgsCollection; safecall;
    procedure Set_Collection(const Value: IgsCollection); safecall;
    function  Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function  Get_ID: Integer; safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Index(Value: Integer); safecall;
    function  GetNamePath: WideString; safecall;
    // IgsParam
    function  Get_Bound: WordBool; safecall;
    procedure Set_Bound(Value: WordBool); safecall;
    function  Get_DataType: TgsFieldType; safecall;
    procedure Set_DataType(Value: TgsFieldType); safecall;
    function  Get_IsNull: WordBool; safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    procedure AssignField(const Field: IgsFieldComponent); safecall;
    procedure AssignFieldValue(const Field: IgsFieldComponent; Value: OleVariant); safecall;
    procedure Clear; safecall;
    function  GetDataSize: Integer; safecall;
    function  Get_AsBCD: Currency; safecall;
    procedure Set_AsBCD(Value: Currency); safecall;
    function  Get_AsBlob: WideString; safecall;
    procedure Set_AsBlob(const Value: WideString); safecall;
    function  Get_AsBoolean: WordBool; safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsDate: TDateTime; safecall;
    procedure Set_AsDate(Value: TDateTime); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    function  Get_AsInteger: Integer; safecall;
    procedure Set_AsInteger(Value: Integer); safecall;
    function  Get_AsMemo: WideString; safecall;
    procedure Set_AsMemo(const Value: WideString); safecall;
    function  Get_AsSmallInt: Integer; safecall;
    procedure Set_AsSmallInt(Value: Integer); safecall;
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsTime: TDateTime; safecall;
    procedure Set_AsTime(Value: TDateTime); safecall;
    function  Get_AsWord: Integer; safecall;
    procedure Set_AsWord(Value: Integer); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_NativeStr: WideString; safecall;
    procedure Set_NativeStr(const Value: WideString); safecall;
    function  Get_ParamType: TgsParamType; safecall;
    procedure Set_ParamType(Value: TgsParamType); safecall;
  public
    constructor Create(AnParam: Variant);

    procedure DestroyObject; safecall;
  end;

procedure CompliteDataSetStream(const AnStream: TStream;
  const AnDataSet: TDataSet; const AnFetchBlob: Boolean = False);
function GetFieldTypeFromStr(const AnTypeName: String): TFieldType;

implementation

uses
  ComServ, rp_BaseReport_unit, Provider, IBSQL, IBTable, gd_SetDatabase,
  gdcOLEClassList, prp_Methods, obj_WrapperIBXClasses, TypInfo, IB;

type
  TFieldCracker = class(TField);
  TCrackIBCustomDataSet = class(TIBCustomDataSet);


constructor TgsDataSet.Create(const AnMemTable: Boolean; const AnChildClass: Boolean = False);
begin
  inherited Create;

  if not AnChildClass then
  begin
    if AnMemTable then
      FDataSet := TClientDataSet.Create(nil)
    else
      FDataSet := TIBQuery.Create(nil);
    FDataSet.Tag := 0;
    FCurrentField := nil;
  end;
  FFetchBlob := False;
  FIndexFields := '';
end;

destructor TgsDataSet.Destroy;
begin
  if Assigned(FDataSet) then
  begin
    FDataSet.Close;
    FreeAndNil(FDataSet);
  end;

  inherited Destroy;
end;

function TgsDataSet.GetIBQuery: TIBQuery;
begin
  if not (FDataSet is TIBQuery) then
    raise Exception.Create(OnlyForIBQuery);
  Result := FDataSet as TIBQuery;
end;

function TgsDataSet.GetClientDataSet: TClientDataSet;
begin
  if not (FDataSet is TClientDataSet) then
    raise Exception.Create(OnlyForClientDataSet);
  Result := FDataSet as TClientDataSet;
end;

procedure TgsDataSet.SetDatabase(const AnValue: TIBDatabase);
begin
  GetIBQuery.Database := AnValue;
end;

procedure TgsDataSet.SetTransaction(const AnValue: TIBTransaction);
begin
  GetIBQuery.Transaction := AnValue;
end;

function TgsDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

function GetFieldTypeFromStr(const AnTypeName: String): TFieldType;
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

procedure TgsDataSet.ExecSQL;
begin
  if not (FDataSet is TIBQuery) then
    raise Exception.Create(OnlyForIBQuery);
  GetIBQuery.ExecSQL;
end;

procedure TgsDataSet.Open;
begin
  try
    if FDataSet is TIBQuery then
      FDataSet.Open
    else
      GetClientDataSet.CreateDataSet;
  except
    on E: Exception do
      raise Exception.Create(FDataSet.Name + ': ' + E.Message);
  end;
end;

procedure TgsDataSet.Close;
begin
  FDataSet.Close;
end;

procedure TgsDataSet.First;
begin
  FDataSet.First;
end;

procedure TgsDataSet.Last;
begin
  FDataSet.Last;
end;

function TgsDataSet.Eof: WordBool;
begin
  Result := FDataSet.Eof;
end;

function TgsDataSet.Get_Fields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(FDataSet.Fields[Index]) as IgsFieldComponent;
end;

function TgsDataSet.Get_FieldByName(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(FDataSet.FieldByName(FieldName)) as IgsFieldComponent;
end;

function TgsDataSet.Bof: WordBool;
begin
  Result := FDataSet.Bof;
end;

procedure TgsDataSet.Next;
begin
  FDataSet.Next;
end;

procedure TgsDataSet.Prior;
begin
  FDataSet.Prior;
end;

function TgsDataSet.Get_IsResult: WordBool;
begin
  Result := FDataSet.Tag <> 0;
end;

procedure TgsDataSet.Set_IsResult(Value: WordBool);
begin
  if Value then
    FDataSet.Tag := 1
  else
    FDataSet.Tag := 0;
end;

function TgsDataSet.Get_SQL: WideString;
begin
  Result := GetIBQuery.SQL.Text;
end;

procedure TgsDataSet.Set_SQL(const Value: WideString);
begin
  GetIBQuery.SQL.Text := Value;
end;

procedure TgsDataSet.AddField(const FieldName: WideString; const FieldType: WideString;
  FieldSize: Integer; Required: WordBool); safecall;
begin
  if FDataSet is TClientDataSet then
    FDataSet.FieldDefs.Add(FieldName, GetFieldTypeFromStr(FieldType), FieldSize,
      Required)
end;

procedure TgsDataSet.ClearFields;
begin
  GetClientDataSet.Close;
  GetClientDataSet.FieldDefs.Clear;
end;

procedure TgsDataSet.Append;
begin
  GetClientDataSet.Append;
end;

procedure TgsDataSet.Edit;
begin
  GetClientDataSet.Edit;
end;

procedure TgsDataSet.Delete;
begin
  GetClientDataSet.Delete;
end;

procedure TgsDataSet.Post;
begin
  GetClientDataSet.Post;
end;

procedure TgsDataSet.Cancel;
begin
  GetClientDataSet.Cancel;
end;

function TgsDataSet.Get_FieldCount: Integer;
begin
  Result := FDataSet.FieldCount;
end;

function TgsDataSet.Get_ParamCount: Integer;
begin
  if FDataSet is TIBQuery then
    Result := GetIBQuery.ParamCount
  else
    Result := GetClientDataSet.Params.Count;
end;

function TgsDataSet.Get_ParamByName(const ParamName: WideString): IgsParam;
var
  LocParam: TParam;
begin
  if FDataSet is TIBQuery then
    LocParam := GetIBQuery.ParamByName(ParamName)
  else
    LocParam := GetClientDataSet.Params.ParamByName(ParamName);

  Result := TgsParam.Create(LocParam) as IgsParam;
end;

function TgsDataSet.Get_Params(Index: Integer): IgsParam;
var
  LocParam: TParam;
begin
  if FDataSet is TIBQuery then
    LocParam := GetIBQuery.Params[Index]
  else
    LocParam := GetClientDataSet.Params[Index];

  Result := TgsParam.Create(LocParam) as IgsParam;
end;

procedure TgsDataSet.Initialize;
begin
  inherited Initialize;
end;

{TgsQueryList}

constructor TgsQueryList.Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction;
 const AnIsRealList: Boolean = False);
var
  InternalTransaction: TIBTransaction;
begin
  inherited Create;

  if not AnIsRealList and ((AnTransaction = nil) or (AnDatabase = nil)) then
    raise Exception.Create('Database or Transaction not assigned');
  FDatabase := AnDatabase;
  if Assigned(AnTransaction) then
  begin
    FTransaction := AnTransaction;
    FWasCreateTransaction := False;
  end
  else
  begin
    InternalTransaction := TIBTransaction.Create(nil);
    InternalTransaction.DefaultDatabase :=  FDatabase;
    InternalTransaction.Params.Add('read_committed');
    InternalTransaction.Params.Add('rec_version');
    InternalTransaction.Params.Add('nowait');
    FTransaction := InternalTransaction;
    FWasCreateTransaction := True;
  end;
  FQueryList := TList.Create;
  FMasterDetail := TFourStringList.Create;
  FTempMasterDetail := TFourStringList.Create;
  FDataSourceList := TObjectList.Create;
end;

destructor TgsQueryList.Destroy;
begin
  ClearObjectList;
  if FWasCreateTransaction then
    FTransaction.Free;
  try
    FreeAndNil(FQueryList);
  except
  end;
  FreeAndNil(FMasterDetail);
  FreeAndNil(FTempMasterDetail);
  FreeAndNil(FDataSourceList);

  inherited Destroy;
end;

function TgsQueryList.Add(const QueryName: WideString; MemQuery: WordBool): Integer;
var
  Index: Integer;
begin
  Index := GetIndexQueryByName(QueryName);
  if Index = - 1 then
  try
    Result := FQueryList.Add(nil);
    FQueryList.Items[Result] := TgsDataSet.Create(MemQuery);
    TgsDataSet(FQueryList.Items[Result])._AddRef;
    TgsDataSet(FQueryList.Items[Result]).DataSet.Name := QueryName;
    TgsDataSet(FQueryList.Items[Result]).Set_IsResult(True);
    if not MemQuery then
    begin
      TgsDataSet(FQueryList.Items[Result]).Database := FDatabase;
      TgsDataSet(FQueryList.Items[Result]).Transaction := FTransaction;
    end;
  except
    on E: Exception do
    begin
      Delete(Result);
      Result := -1;
      raise Exception.Create('Произошла ошибка при создании нового объекта.'#13#10 +
        E.Message);
    end;
  end
  else
    raise Exception.Create(Format('Объект с именем "%s" уже имеется в списке', [QueryName]));
end;

function TgsQueryList.Get_Query(Index: Integer): IgsQuery;
begin
  Result := TgsDataSet(FQueryList.Items[Index]);
end;

function  TgsQueryList.Get_Count: Integer;
begin
  Result := FQueryList.Count;
end;

procedure TgsQueryList.Clear;
begin
  MainInitialize;
  Commit;
end;

procedure TgsQueryList.Delete(Index: Integer);
begin
  TgsDataSet(FQueryList.Items[Index])._Release;
  FQueryList.Items[Index] := nil;
  FQueryList.Delete(Index);
end;

procedure TgsQueryList.ClearObjectList;
begin
  Clear;
end;

function TgsQueryList.Get_QueryByName(const Name: WideString): IgsQuery;
var
  I: Integer;
begin
  Result := nil;
  I := GetIndexQueryByName(Name);
  if I > -1 then
    Result := TgsDataSet(FQueryList.Items[I]);
  if Result = nil then
    raise Exception.Create('Query not found');
end;

function TgsQueryList.ResultStream: OleVariant;
var
  J: Integer;
  LocReportResult: TReportResult;
  MStr: TMemoryStream;
  DS: TClientDataSet;
begin
  LocReportResult := TReportResult.Create;
  try
    MStr := TMemoryStream.Create;
    try
      for J := 0 to Count - 1 do
        if (Query[J].Tag <> 0) and (Query[J].Active) then
        begin
          Query[J].DisableControls;
          try
            //TClientDataSet уничтожится в LocReportResult.Free
            DS := TClientDataSet.Create(nil);
            CompliteDataSetStream(MStr, Query[J], Get_Query(J).FetchBlob);
            MStr.Position := 0;
            DS.LoadFromStream(MStr);
            LocReportResult.AddDataSet(Query[J].Name, DS);
          finally
            Query[J].EnableControls;
          end;
        end;

      for J := 0 to FMasterDetail.Count - 1 do
        LocReportResult._MasterDetail.AddRecord(FMasterDetail.MasterTable[J],
         FMasterDetail.MasterField[J], FMasterDetail.DetailTable[J],
         FMasterDetail.DetailField[J]);

      MStr.Clear;
      LocReportResult.SaveToStream(MStr);
      Result := VarArrayCreate([0, MStr.Size - 1], varByte);
      CopyMemory(VarArrayLock(Result), MStr.Memory, MStr.Size);
      VarArrayUnLock(Result);
    finally
      MStr.Free;
    end;
  finally
    LocReportResult.Free;
  end;
end;

function TgsQueryList.GetQuery(Index: Integer): TDataSet;
begin
  Result := TgsDataSet(FQueryList.Items[Index]).DataSet;
end;

function TgsQueryList.GetCount: Integer;
begin
  Result := FQueryList.Count;
end;

procedure TgsQueryList.AddMasterDetail(const MasterTable, MasterField,
  DetailTable, DetailField: WideString);
var
  I: Integer;
  TempDS: TDataSet;
begin
  I := GetIndexQueryByName(MasterTable);
  if I > -1 then
  begin
    TempDS := TgsDataSet(FQueryList.Items[I]).DataSet;
    TempDS.Active := True;
    if not CheckFieldNames(TempDS, MasterField) then
      raise Exception.Create('Specified master field not found.');
  end;

  I := GetIndexQueryByName(DetailTable);
  if I > -1 then
  begin
    TempDS := TgsDataSet(FQueryList.Items[I]).DataSet;
    TempDS.Active := True;
    if not CheckFieldNames(TempDS, DetailField) then
      raise Exception.Create('Specified detail field not found.');
  end;

  if not (TgsDataSet(FQueryList.Items[I]).DataSet is TClientDataSet) then
    FTempMasterDetail.AddRecord(MasterTable, MasterField, DetailTable, DetailField);

  FMasterDetail.AddRecord(MasterTable, MasterField, DetailTable, DetailField);
end;

function TgsQueryList.GetIndexQueryByName(const Name: WideString): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FQueryList.Count - 1 do
    if AnsiUpperCase(TgsDataSet(FQueryList.Items[I]).DataSet.Name) = AnsiUpperCase(Name) then
    begin
      Result := I;
      Break;
    end;
end;

function TgsQueryList.AddRealQuery(const AnRealQuery: TgsDataSet): Integer;
begin
  Result := FQueryList.Add(nil);
  try
    FQueryList.Items[Result] := AnRealQuery;
    TgsDataSet(FQueryList.Items[Result])._AddRef;
    TgsDataSet(FQueryList.Items[Result]).Set_IsResult(True);
  except
    on E: Exception do
    begin
      Delete(Result);
      raise Exception.Create('Произошла ошибка при создании нового объекта.'#13#10 +
       E.Message);
    end;
  end;
end;

procedure TgsQueryList.DeleteByName(const AName: WideString);
begin
  Delete(GetIndexQueryByName(AName));
end;

procedure TgsQueryList.Commit;
begin
  if (FTransaction <> nil) and FTransaction.InTransaction then
    FTransaction.Commit;
end;

procedure TgsQueryList.MainInitialize;
var
  I: Integer;
begin
  for I := 0 to FQueryList.Count - 1 do
  begin
    TgsDataSet(FQueryList.Items[I])._Release;
    FQueryList.Items[I] := nil;
  end;
  FQueryList.Clear;
  FMasterDetail.Clear;
  FTempMasterDetail.Clear;
  FDataSourceList.Clear;
  FCurrentField := nil;
end;

function TgsQueryList.Get_Self: Integer;
begin
  Result := Integer(Self);
end;

procedure TgsQueryList.ResultMasterDetail;
var
  I, J, Index: Integer;
  MemTable: TgsDataSet;
  DS: TClientDataSet;
  IsResult: WordBool;
  IndexFields: String;
  MStr: TMemoryStream;

  procedure AddMasterDetail(const AnMasterTable, AnMasterField,
    AnDetailTable, AnDetailField: String);
  var
    TempDs: TClientDataSet;
  begin
    TempDs := (TgsDataSet(FQueryList.Items[GetIndexQueryByName(AnDetailTable)]).DataSet as TClientDataSet);
    if TempDs.MasterSource = nil then
    begin
      TempDs.MasterSource := TDataSource.Create(nil);
      FDataSourceList.Add(TempDs.MasterSource);
    end;
    TempDs.MasterSource.DataSet := TgsDataSet(FQueryList.Items[GetIndexQueryByName(AnMasterTable)]).DataSet;
    TempDs.IndexFieldNames := AnDetailField;
    TempDs.MasterFields := AnMasterField;
  end;

begin
  MStr := TMemoryStream.Create;
  try
  //заменим TIBQuery на memtable при необходимости
    for J := 0 to FTempMasterDetail.Count - 1 do
    begin
      I := GetIndexQueryByName(FMasterDetail.DetailTable[J]);
      if I > -1 then
      begin
        //1. Создаем MemTable и заполняем его
        IsResult := TgsDataSet(FQueryList.Items[I]).Get_IsResult;
        IndexFields := TgsDataSet(FQueryList.Items[I]).Get_IndexFields;
        MemTable := TgsDataSet.Create(True);
        try
          DS := MemTable.GetClientDataSet;

          CompliteDataSetStream(MStr, TgsDataSet(FQueryList.Items[I]).DataSet, TgsDataSet(FQueryList.Items[I]).Get_FetchBlob);
          MStr.Position := 0;
          DS.LoadFromStream(MStr);
          MStr.Clear;
          DS.Name := TgsDataSet(FQueryList.Items[I]).DataSet.Name;
        except
          on E: Exception do
          begin
            MemTable.Free;
            raise Exception.Create('Произошла ошибка при создании нового объекта.'#13#10 +
              E.Message);
          end;
        end;
        //2. Уничтожаем исходный TIBQuery
        DeleteByName(TgsDataSet(FQueryList.Items[I]).DataSet.Name);
        //3. Добавляем MemTable в список
        Index := FQueryList.Add(nil);
        FQueryList.Items[Index] := MemTable;
        TgsDataSet(FQueryList.Items[Index])._AddRef;
        TgsDataSet(FQueryList.Items[Index]).DataSet.Name := DS.Name;
        TgsDataSet(FQueryList.Items[Index]).Set_IsResult(IsResult);
        if IndexFields <> '' then
          TgsDataSet(FQueryList.Items[Index]).Set_IndexFields(IndexFields);
      end;
    end;
  finally
    MStr.Free;
  end;

  //4. Создаем связь M-D
  for I := 0 to FMasterDetail.Count - 1 do
    AddMasterDetail(FMasterDetail.MasterTable[I], FMasterDetail.MasterField[I],
     FMasterDetail.DetailTable[I], FMasterDetail.DetailField[I]);
end;

{ TgsParam }

procedure TgsParam.AssignField(const Field: IgsFieldComponent);
begin
  FParam.AssignField(InterfaceToObject(Field) as TField);
end;

procedure TgsParam.AssignFieldValue(const Field: IgsFieldComponent;
  Value: OleVariant);
begin
  FParam.AssignFieldValue(InterfaceToObject(Field) as TField, Value);
end;

procedure TgsParam.Clear;
begin
  FParam.Clear;
end;

constructor TgsParam.Create(AnParam: TParam);
begin
  Assert(AnParam <> nil);
  inherited Create;

  FParam := AnParam;
end;

destructor TgsParam.Destroy;
begin
  FParam := nil;

  inherited Destroy;
end;

function TgsParam.Get_AsBCD: Currency;
begin
  Result := FParam.AsBCD;
end;

function TgsParam.Get_AsBlob: WideString;
begin
  Result := FParam.AsBlob;
end;

function TgsParam.Get_AsBoolean: WordBool;
begin
  Result := FParam.AsBoolean;
end;

function TgsParam.Get_AsCurrency: Currency;
begin
  Result := FParam.AsCurrency;
end;

function TgsParam.Get_AsDate: TDateTime;
begin
  Result := FParam.AsDate;
end;

function TgsParam.Get_AsDateTime: TDateTime;
begin
  Result := FParam.AsDateTime;
end;

function TgsParam.GetDataSize: Integer;
begin
  Result := FParam.GetDataSize;
end;

function TgsParam.Get_AsFloat: Double;
begin
  Result := FParam.AsFloat;
end;

function TgsParam.Get_AsInteger: Integer;
begin
  Result := FParam.AsInteger;
end;

function TgsParam.Get_AsMemo: WideString;
begin
  Result := FParam.AsMemo;
end;

function TgsParam.Get_AsSmallInt: Integer;
begin
  Result := FParam.AsSmallInt;
end;

function TgsParam.Get_AsString: WideString;
begin
  Result := FParam.AsString;
end;

function TgsParam.Get_AsTime: TDateTime;
begin
  Result := FParam.AsTime;
end;

function TgsParam.Get_AsVariant: OleVariant;
begin
  Result := FParam.Value;
end;

function TgsParam.Get_AsWord: Integer;
begin
  Result := FParam.AsWord;
end;

function TgsParam.Get_Bound: WordBool;
begin
  Result := FParam.Bound;
end;

function TgsParam.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(FParam.DataType);
end;

function TgsParam.Get_IsNull: WordBool;
begin
  Result := FParam.IsNull;
end;

function TgsParam.Get_Name: WideString;
begin
  Result := FParam.Name;
end;

function TgsParam.Get_NativeStr: WideString;
begin
  Result := FParam.NativeStr;
end;

function TgsParam.Get_ParamType: TgsParamType;
begin
  Result := TgsParamType(FParam.ParamType);
end;

function TgsParam.Get_Text: WideString;
begin
  Result := FParam.Text;
end;

function TgsParam.Get_Value: OleVariant;
begin
  Result := FParam.Value;
end;

procedure TgsParam.Set_AsBCD(Value: Currency);
begin
  FParam.AsBCD := Value;
end;

procedure TgsParam.Set_AsBlob(const Value: WideString);
begin
  FParam.AsBlob := Value;
end;

procedure TgsParam.Set_AsBoolean(Value: WordBool);
begin
  FParam.AsBoolean := Value;
end;

procedure TgsParam.Set_AsCurrency(Value: Currency);
begin
  FParam.AsCurrency := Value;
end;

procedure TgsParam.Set_AsDate(Value: TDateTime);
begin
  FParam.AsDate := Value;
end;

procedure TgsParam.Set_AsDateTime(Value: TDateTime);
begin
  FParam.AsDateTime := Value;
end;

procedure TgsParam.Set_AsFloat(Value: Double);
begin
  FParam.AsFloat := Value;
end;

procedure TgsParam.Set_AsInteger(Value: Integer);
begin
  FParam.AsInteger := Value;
end;

procedure TgsParam.Set_AsMemo(const Value: WideString);
begin
  FParam.AsMemo := Value;
end;

procedure TgsParam.Set_AsSmallInt(Value: Integer);
begin
  FParam.AsSmallInt := Value;
end;

procedure TgsParam.Set_AsString(const Value: WideString);
begin
  FParam.AsString := Value;
end;

procedure TgsParam.Set_AsTime(Value: TDateTime);
begin
  FParam.AsTime := Value;
end;

procedure TgsParam.Set_AsVariant(Value: OleVariant);
begin
  FParam.Value := Value;
end;

function TgsDataSet.Get_OnCalcField: LongWord;
begin
  Result := LongWord(Pointer(@FOnCalcEvent));
end;

procedure TgsDataSet.Set_OnCalcField(Value: LongWord);
begin
  Integer(Pointer(@FOnCalcEvent)) := Value;
end;

procedure TgsParam.Set_AsWord(Value: Integer);
begin
  FParam.AsWord := Value;
end;

procedure TgsParam.Set_Bound(Value: WordBool);
begin
  FParam.Bound := Value;
end;

procedure TgsParam.Set_DataType(Value: TgsFieldType);
begin
  FParam.DataType := TFieldType(Value);
end;

procedure TgsParam.Set_Name(const Value: WideString);
begin
  FParam.Name := Value;
end;

procedure TgsParam.Set_NativeStr(const Value: WideString);
begin
  FParam.NativeStr := Value;
end;

procedure TgsParam.Set_ParamType(Value: TgsParamType);
begin
  FParam.ParamType := TParamType(Value);
end;

procedure TgsParam.Set_Text(const Value: WideString);
begin
  FParam.Text := Value;
end;

procedure TgsParam.Set_Value(Value: OleVariant);
begin
  FParam.Value := Value;
end;

procedure TgsParam.Assign_(const Source: IgsPersistent);
begin

end;

function TgsParam.ClassName: WideString;
begin
  Result := FParam.ClassName;
end;

function TgsParam.ClassParent: WideString;
begin
  Result := '';
end;

function TgsParam.Get_Collection: IgsCollection;
begin
  Result := nil;
end;

function TgsParam.Get_DisplayName: WideString;
begin
  Result := '';
end;

function TgsParam.Get_ID: Integer;
begin
  Result := 0;
end;

function TgsParam.Get_Index: Integer;
begin
  Result := 0;
end;

function TgsParam.Get_Self: Integer;
begin
  Result := 0;
end;

function TgsParam.GetNamePath: WideString;
begin
  Result := '';
end;

function TgsParam.InheritsFrom(const AClass: WideString): WordBool;
begin
  Result := False;
end;

procedure TgsParam.Set_Collection(const Value: IgsCollection);
begin

end;

procedure TgsParam.Set_DisplayName(const Value: WideString);
begin

end;

procedure TgsParam.Set_Index(Value: Integer);
begin

end;

procedure TgsParam.DestroyObject;
begin
// Don't support
end;

function TgsParam.Get_DelphiObject: Integer;
begin
  Result := 0;
end;

{ TgsRealDataSet }

constructor TgsRealDataSet.Create(const AnIBDataSet: TIBCustomDataSet);
begin
  Assert((AnIBDataSet <> nil) and not (AnIBDataSet is TIBTable));

  inherited Create(False, True);

  FDataSet := AnIBDataSet;
end;

destructor TgsRealDataSet.Destroy;
begin
  FDataSet := nil;

  inherited Destroy;
end;

procedure TgsRealDataSet.AddField(const FieldName, FieldType: WideString;
  FieldSize: Integer; Required: WordBool);
begin
  raise Exception.Create('Method AddField not supported for real dataset.');
end;

procedure TgsRealDataSet.Append;
begin
  raise Exception.Create('Method Append not supported for real dataset.');
end;

function TgsRealDataSet.Bof: WordBool;
begin
  Result := FDataSet.Bof;
end;

procedure TgsRealDataSet.Cancel;
begin
  raise Exception.Create('Method Cancel not supported for real dataset.');
end;

procedure TgsRealDataSet.ClearFields;
begin
  raise Exception.Create('Method ClearField not supported for real dataset.');
end;

procedure TgsRealDataSet.Close;
begin
  raise Exception.Create('Method Close not supported for real dataset.');
end;

procedure TgsRealDataSet.Delete;
begin
  raise Exception.Create('Method Delete not supported for real dataset.');
end;

procedure TgsRealDataSet.Edit;
begin
  raise Exception.Create('Method Edit not supported for real dataset.');
end;

function TgsRealDataSet.Eof: WordBool;
begin
  Result := FDataSet.Eof;
end;

procedure TgsRealDataSet.ExecSQL;
begin
  raise Exception.Create('Method ExecSQL not supported for real dataset.');
end;

procedure TgsRealDataSet.First;
begin
  FDataSet.First;
end;

function TgsRealDataSet.Get_OnCalcField: LongWord;
begin
  Assert(False);
end;

function TgsRealDataSet.Get_ParamByName(const ParamName: WideString): IgsParam;
var
  LVar: Variant;
begin
  if IsQuery then
    LVar := (FDataSet as TIBQuery).ParamByName(ParamName).Value
  else
    LVar := TCrackIBCustomDataSet((FDataSet as TIBCustomDataSet)).Params.ByName(ParamName).Value;
  Result := TgsCustomValue.Create(LVar) as IgsParam;
end;

function TgsRealDataSet.Get_ParamCount: Integer;
begin
  if IsQuery then
    Result := (FDataSet as TIBQuery).ParamCount
  else
    Result := TCrackIBCustomDataSet((FDataSet as TIBCustomDataSet)).Params.Count;
end;

function TgsRealDataSet.Get_Params(Index: Integer): IgsParam;
var
  LVar: Variant;
begin
  if IsQuery then
    LVar := (FDataSet as TIBQuery).Params[Index].Value
  else
    LVar := TCrackIBCustomDataSet((FDataSet as TIBCustomDataSet)).Params[Index].Value;
  Result := TgsCustomValue.Create(LVar) as IgsParam;
end;

function TgsRealDataSet.Get_SQL: WideString;
begin
  if IsQuery then
    Result := (FDataSet as TIBQuery).SQL.Text
  else
    Result := TCrackIBCustomDataSet((FDataSet as TIBCustomDataSet)).SelectSQL.Text;
end;

function TgsRealDataSet.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

procedure TgsRealDataSet.Last;
begin
  FDataSet.Last;
end;

procedure TgsRealDataSet.Next;
begin
  FDataSet.Next;
end;

procedure TgsRealDataSet.Open;
begin
  FDataSet.Open;
end;

procedure TgsRealDataSet.Post;
begin
  raise Exception.Create('Method Post not supported for real dataset.');
end;

procedure TgsRealDataSet.Prior;
begin
  FDataSet.Prior;
end;

procedure TgsRealDataSet.Set_OnCalcField(Value: LongWord);
begin

end;

procedure TgsRealDataSet.Set_SQL(const Value: WideString);
begin
  raise Exception.Create('Method Set not supported for real dataset.');
end;

function TgsRealDataSet.IsQuery: Boolean;
begin
  Result := FDataSet is TIBQuery;
end;

{ TgsCustomValue }

procedure TgsCustomValue.Assign_(const Source: IgsPersistent);
begin

end;

procedure TgsCustomValue.AssignField(const Field: IgsFieldComponent);
begin
  raise Exception.Create('Property Not Supported');
end;

procedure TgsCustomValue.AssignFieldValue(const Field: IgsFieldComponent;
  Value: OleVariant);
begin
  raise Exception.Create('Property Not Supported');
end;

function TgsCustomValue.ClassName: WideString;
begin
  Result := '';
end;

function TgsCustomValue.ClassParent: WideString;
begin
  Result := '';
end;

procedure TgsCustomValue.Clear;
begin
  raise Exception.Create('Property Not Supported');
end;

constructor TgsCustomValue.Create(AnParam: Variant);
begin
  inherited Create;

  FParam := AnParam;
end;

function TgsCustomValue.Get_AsBCD: Currency;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsBlob: WideString;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsBoolean: WordBool;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsCurrency: Currency;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsDate: TDateTime;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsDateTime: TDateTime;
begin
  Result := FParam;
end;

function TgsCustomValue.GetDataSize: Integer;
begin
  Result := 0;
end;

function TgsCustomValue.GetNamePath: WideString;
begin
  Result := '';
end;

function TgsCustomValue.Get_AsFloat: Double;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsInteger: Integer;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsMemo: WideString;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsSmallInt: Integer;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsString: WideString;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsTime: TDateTime;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsVariant: OleVariant;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_AsWord: Integer;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_Bound: WordBool;
begin
  Result := False;
end;

function TgsCustomValue.Get_Collection: IgsCollection;
begin
  Result := nil
end;

function TgsCustomValue.Get_DataType: TgsFieldType;
begin
  Result := 0;
end;

function TgsCustomValue.Get_DisplayName: WideString;
begin
  Result := '';
end;

function TgsCustomValue.Get_ID: Integer;
begin
  Result := 0;
end;

function TgsCustomValue.Get_Index: Integer;
begin
  Result := 0;
end;

function TgsCustomValue.Get_IsNull: WordBool;
begin
  Result := VarIsNull(FParam);
end;

function TgsCustomValue.Get_Name: WideString;
begin
  Assert(False);
  Result := 'unknown';
end;

function TgsCustomValue.Get_NativeStr: WideString;
begin
  raise Exception.Create('Property Not Supported');
end;

function TgsCustomValue.Get_ParamType: TgsParamType;
begin
  raise Exception.Create('Property Not Supported');
end;

function TgsCustomValue.Get_Self: Integer;
begin
  Result := 0;
end;

function TgsCustomValue.Get_Text: WideString;
begin
  Result := FParam;
end;

function TgsCustomValue.Get_Value: OleVariant;
begin
  Result := FParam;
end;

function TgsCustomValue.InheritsFrom(const AClass: WideString): WordBool;
begin
  Result := False;
end;

procedure TgsCustomValue.Set_AsBCD(Value: Currency);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsBlob(const Value: WideString);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsBoolean(Value: WordBool);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsCurrency(Value: Currency);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsDate(Value: TDateTime);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsDateTime(Value: TDateTime);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsFloat(Value: Double);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsInteger(Value: Integer);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsMemo(const Value: WideString);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsSmallInt(Value: Integer);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsString(const Value: WideString);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsTime(Value: TDateTime);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_AsVariant(Value: OleVariant);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure CompliteDataSetStream(const AnStream: TStream;
  const AnDataSet: TDataSet; const AnFetchBlob: Boolean = False);
const
  LEmptyByte = 1;
  LEmptyFormat = SizeOf(Byte) * 8 div 2;
  SizePosition = 14;
  FreeBufferDelta = $A00000;
var
  TempClientDS: TClientDataSet;
  I, L, OldPosition: Integer;
  BArray: array of Byte;
  LBArray: Word;
  Buffer: Pointer;
  BufferSize: Integer;
  FiedNameSize: Byte;
  FRecordCount: Integer;

  // Процедура одной записи в поток данных
  procedure WriteRecord;
  var
    J, K : Integer;
    TempStr: TStream;
    TempField: TField;
  begin
    Inc(FRecordCount);
    // Заполняем структуру NULL-полей
    FillChar(BArray[0], LBArray, 0);
    for K := 0 to AnDataSet.FieldCount - 1 do
    begin
      TempField := AnDataSet.Fields[K];
      if (TempField.IsNull) or (not AnFetchBlob and
       (TempField.DataType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo])) then
      begin
        J := (K div LEmptyFormat + 1);
        BArray[J] := BArray[J] or (1 shl (K mod 4 * 2));
      end;
    end;

    // Сохраняем структуру
    AnStream.Write(BArray[0], LBArray);

    // Сохраняем данные из поля
    for K := 0 to AnDataSet.FieldCount - 1 do
    begin
      TempField := AnDataSet.Fields[K];
      if not TempField.IsNull then
        case TempField.DataType of
          ftBlob, ftMemo, ftGraphic, ftFmtMemo:
          begin
            if AnFetchBlob then
            begin
              TempStr := AnDataSet.CreateBlobStream(TempField, bmRead);
              try
                J := TempStr.Size;
                AnStream.Write(J, TempField.Tag);
                if J > 0 then
                  AnStream.CopyFrom(TempStr, J);
              finally
                TempStr.Free;
              end;
            end;
          end;
          ftBCD:
          begin
            TempClientDS.Fields[K].Assign(TempField);
            if TempField.Tag > BufferSize then
            begin
              BufferSize := TempField.Tag;
              ReallocMem(Buffer, BufferSize);
            end;
            TempClientDS.Fields[K].GetData(Buffer);
            AnStream.Write(Buffer^, TempField.Tag);
          end;
          ftWideString, ftString:
          begin
            J := Length(TempField.AsString);
            if J > BufferSize then
            begin
              BufferSize := J;
              ReallocMem(Buffer, BufferSize);
            end;
            TempField.GetData(Buffer);
            AnStream.Write(J, TempField.Tag);
            AnStream.Write(Buffer^, J);
          end
        else
          if TempField.Tag > BufferSize then
          begin
            BufferSize := TempField.Tag;
            ReallocMem(Buffer, BufferSize);
          end;
          TempField.GetData(Buffer);
          AnStream.Write(Buffer^, TempField.Tag);
        end;
    end;
  end;
begin
  AnStream.Position := 0;
  AnStream.Size := 0;
  if not AnDataSet.Active then
    Exit;

  AnDataSet.DisableControls;
  try
    // Вытягиваем все записи
    AnDataSet.Last;
    // Нужен КлиентДатаСет для создания заголовка
    TempClientDS := TClientDataSet.Create(nil);
    try
      LBArray := LEmptyByte + (AnDataSet.FieldCount - 1) div LEmptyFormat + 1;
      SetLength(BArray, LBArray);

      // Заполняем поля
      for I := 0 to AnDataSet.FieldCount - 1 do
        TempClientDS.FieldDefs.Add(AnDataSet.Fields[I].FieldName, AnDataSet.Fields[I].DataType,
         AnDataSet.Fields[I].Size, AnDataSet.Fields[I].Required);
        //TempClientDS.Fields.Add(AnDataSet.Fields[I]);

      // Создаем КлиентДатаСет и сохраняем заголовок
      TempClientDS.CreateDataSet;
      TempClientDS.SaveToStream(AnStream);

      // Выделяем память для перекачки данных из обычных полей
      BufferSize := 10000;
      if AnStream.Size > BufferSize then
        BufferSize := AnStream.Size;

      GetMem(Buffer, BufferSize);
      FillChar(Buffer^, BufferSize, 0);
      try
        // Вытягиваем размеры полей из потока. Не соответствуют данным из КлиентДатаСет.
        AnStream.Position := 0;
        AnStream.ReadBuffer(Buffer^, AnStream.Size);
        for I := 0 to AnDataSet.FieldCount - 1 do
        begin
          FiedNameSize := Length(AnDataSet.Fields[I].FieldName);
          L := Pos(Char(FiedNameSize) + AnDataSet.Fields[I].FieldName, PString(@Buffer)^);
          AnDataSet.Fields[I].Tag := SmallInt(TDnByteArray(Buffer)[L + FiedNameSize + SizeOf(FiedNameSize) - 1]);
        end;

        // Для перегонки decimal полей
        TempClientDS.Append;
        AnDataSet.First;
        FRecordCount := 0;
        // Сохраняем по одной записи
        while not AnDataSet.Eof do
        begin
          // Выделяем сразу много памяти, иначе много времени тратится.
          if AnStream.Size = AnStream.Position then
          begin
            OldPosition := AnStream.Position;
            AnStream.Size := AnStream.Size + FreeBufferDelta;
            AnStream.Position := OldPosition;
          end;
          WriteRecord;

          AnDataSet.Next;
        end;
        TempClientDS.Cancel;
        // Устанавливаем реальный размер потока
        AnStream.Size := AnStream.Position;
        // Сохраняем количество записей
        AnStream.Position := SizePosition;
        AnStream.Write(FRecordCount, SizeOf(FRecordCount));
      finally
        FreeMem(Buffer);
      end;
    finally
      TempClientDS.Close;
      TempClientDS.FieldDefs.Clear;
      {for I := 0 to AnDataSet.FieldCount - 1 do
        TempClientDS.Fields.Remove(AnDataSet.Fields[I]);{}
      TempClientDS.Free;
    end;
  finally
    AnDataSet.EnableControls;
  end;
end;

function TgsDataSet.Get_FetchBlob: WordBool;
begin
  Result := FFetchBlob;
end;

procedure TgsDataSet.Set_FetchBlob(Value: WordBool);
begin
  FFetchBlob := Value;
end;

function TgsDataSet.GetStrFromFieldType(const AnFieldType: TFieldType): String;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Integer(AnFieldType));
end;

function TgsDataSet.Get_IndexFields: WideString;
begin
  Result := FIndexFields;
end;

procedure TgsDataSet.Set_IndexFields(const Value: WideString);
begin
  if (Trim(Value) > '') and not CheckFieldNames(FDataSet, Value) then
    raise Exception.Create('Some index fields is absence');
  FIndexFields := Value;
  if FDataSet is TClientDataSet then
    GetClientDataSet.IndexFieldNames := FIndexFields;
end;

function TgsDataSet.Get_RecordCount: Integer;
begin
  Result := FDataSet.RecordCount;
end;

procedure TgsDataSet.Insert;
begin
  FDataSet.Insert;
end;

function TgsDataSet.Get_Active: WordBool;
begin
  Result := FDataSet.Active;
end;

function TgsDataSet.Get_Transaction: IgsIBTransaction;
begin
  try
    if FDataSet is TIBQuery then
      Result := GetGdcOLEObject(TIBQuery(FDataSet).Transaction) as IgsIBTransaction;
  except
    on E: Exception do
      raise Exception.Create(FDataSet.Name + ': ' + E.Message);
  end;
end;

procedure TgsDataSet.Set_Transaction(const Value: IgsIBTransaction);
begin
  try
    if FDataSet is TIBQuery then
      TIBQuery(FDataSet).Transaction := InterfaceToObject(Value) as TIBTransaction;
  except
    on E: Exception do
      raise Exception.Create(FDataSet.Name + ': ' + E.Message);
  end;
end;

procedure TgsDataSet.AssignFields(const ADataSet: IgsQuery);
var
  I: Integer;
begin
  if FDataSet is TClientDataSet then
    for I := 0 to ADataSet.FieldCount - 1 do
      AddField(ADataSet.Fields[I].FieldName, ADataSet.Fields[I].FieldType,
       ADataSet.Fields[I].FieldSize, ADataSet.Fields[I].Required)
  else
    raise Exception.Create('Method not supported for real dataset.');
end;

procedure TgsDataSet.CopyRecord(const ADataSet: IgsQuery);
var
  I: Integer;
begin
  if FDataSet is TClientDataSet then
    for I := 0 to ADataSet.FieldCount - 1 do
      FDataSet.FieldByName(ADataSet.Fields[I].FieldName).Value := ADataSet.Fields[I].Value
  else
    raise Exception.Create('Method not supported for real dataset.');
end;

procedure TgsCustomValue.Set_AsWord(Value: Integer);
begin
  raise Exception.Create('Set Value Not Supported');
end;

procedure TgsCustomValue.Set_Bound(Value: WordBool);
begin

end;

procedure TgsCustomValue.Set_Collection(const Value: IgsCollection);
begin

end;

procedure TgsCustomValue.Set_DataType(Value: TgsFieldType);
begin

end;

procedure TgsCustomValue.Set_DisplayName(const Value: WideString);
begin

end;

procedure TgsCustomValue.Set_Index(Value: Integer);
begin

end;

procedure TgsCustomValue.Set_Name(const Value: WideString);
begin
  raise Exception.Create('Property Not Supported');
end;

procedure TgsCustomValue.Set_NativeStr(const Value: WideString);
begin
  raise Exception.Create('Property Not Supported');
end;

procedure TgsCustomValue.Set_ParamType(Value: TgsParamType);
begin
  raise Exception.Create('Property Not Supported');
end;

procedure TgsCustomValue.Set_Text(const Value: WideString);
begin
  raise Exception.Create('Property Not Supported');
end;

procedure TgsCustomValue.Set_Value(Value: OleVariant);
begin
  raise Exception.Create('Property Not Supported');
end;

function TgsDataSet.CreateBlobStream(const Field: IgsFieldComponent;
  Mode: TgsBlobStreamMode): IgsStream;
begin
  Result :=
    GetGdcOLEObject(FDataSet.CreateBlobStream(InterfaceToObject(Field) as TField,
    TBlobStreamMode(Mode))) as IgsStream;
end;

procedure TgsCustomValue.DestroyObject;
begin
end;

function TgsCustomValue.Get_DelphiObject: Integer;
begin
  Result := 0;
end;

function TgsDataSet.Locate(const KeyFields: WideString;
  KeyValues: OleVariant; CaseIns, PartialKey: WordBool): WordBool;
var
  LO: TLocateOptions;
begin
  LO := [];
  if CaseIns then Include(LO, loCaseInsensitive);
  if PartialKey then Include(LO, loPartialKey);
  Result := FDataSet.Locate(KeyFields, KeyValues, LO);
end;

function TgsDataSet.Get_Self: Integer;
begin
  Result := Integer(DataSet);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsParam, CLASS_gs_rpParam,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsRealDataSet, CLASS_gs_rpQuery,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsDataSet, CLASS_gs_rpQuery,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsQueryList, CLASS_gs_rpQueryList,
    ciMultiInstance, tmApartment);
end.
