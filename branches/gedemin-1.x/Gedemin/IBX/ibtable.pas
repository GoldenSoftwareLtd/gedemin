{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

unit IBTable;

interface

uses SysUtils, Classes, DB, IB, IBDatabase, IBCustomDataSet,
     IBHeader, IBSQL, IBUtils;
     
type

{ TIBTable }

  TIBTableType = (ttSystem, ttView);
  TIBTableTypes = set of TIBTableType;
  TIndexName = String;

  TIBTable = class;

  TIBTable = class(TIBCustomDataSet)
  private
    FSystemTable: Boolean;
    FMultiTableView: Boolean;
    FMasterLink: TMasterDataLink;
    FMasterFieldsList: TStringList;
    FDetailFieldsList: TStringList;
    FStoreDefs: Boolean;
    FIndexDefs: TIndexDefs;
    FDefaultIndex: Boolean;
    FReadOnly: Boolean;
    FFieldsIndex: Boolean;
    FTableName: String;
    FIndexName: TIndexName;
    FRegenerateSQL: Boolean;
    FNameList: TStrings;
    FSwitchingIndex: Boolean;
    FPrimaryIndexFields: string;
    FTableTypes: TIBTableTypes;
    WhereAllRefreshSQL: TStrings;
    WhereDBKeyRefreshSQL: TStrings;
    WherePrimaryRefreshSQL: TStrings;

    function GetIndexFieldCount: Integer;
    function GetIndexField(Index: Integer): TField;
    procedure MasterChanged(Sender: TObject);
    procedure MasterDisabled(Sender: TObject);
    procedure SetDataSource(Value: TDataSource);
    procedure SetIndexField(Index: Integer; Value: TField);
    procedure SetIndexFieldNames(const Value: string);
    procedure GenerateSQL;
    procedure GenerateUpdateSQL;
    procedure SwitchToIndex();
    procedure InternalTableRefresh();
    function GetTableNames: TStrings;
    procedure GetTableNamesFromServer;
    procedure SetTableTypes(const Value: TIBTableTypes);
    function InternalGotoDBKey(DBKey: TIBDBKey): Boolean;
    function FormatFieldsList(Value: string): string;
    function GetCurrentDBKey: TIBDBKey;
    function InternalGetUpdatable: Boolean;
    function GetExists: Boolean;
    procedure SetIndexDefs(Value: TIndexDefs);
    procedure ExtractLinkFields;
    function FieldDefsStored: Boolean;
    function IndexDefsStored: Boolean;
    function GetMasterFields: string;
    procedure SetMasterFields(const Value: string);
    function GetIndexFieldNames: string;
    function GetIndexName: string;
    procedure SetIndexName(const Value: string);
    procedure SetParams;
    procedure SetReadOnly(Value: Boolean);
    procedure SetTableName(Value: String);
    procedure SetIndex(const Value: string; FieldsIndex: Boolean);
    procedure ResetSQLStatements;
    procedure Reopen;
    function InternalLocate(const KeyFields: string; const KeyValues: Variant;
                            Options: TLocateOptions): Boolean;
  protected
    { IProviderSupport }
    function PSGetDefaultOrder: TIndexDef; override;
    function PSGetKeyFields: string; override;
    function PSGetTableName: string; override;
    function PSGetIndexDefs(IndexTypes: TIndexOptions): TIndexDefs; override;
    procedure PSSetCommandText(const CommandText: string); override;
    procedure PSSetParams(AParams: TParams); override;

    procedure DoOnNewRecord; override;
    procedure GetIndexParams(const IndexName: string; FieldsIndex: Boolean;
      var IndexedName: string);
    function GetCanModify: Boolean; override;
    procedure UpdateIndexDefs; override;
    procedure DataEvent(Event: TDataEvent; Info: Longint); override;
    procedure DefChanged(Sender: TObject); override;
    function GetDataSource: TDataSource; override;
    procedure InitFieldDefs; override;
    procedure InternalClose; override;
    procedure InternalOpen; override;
    procedure InternalRefresh; override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterText(const Value: string); override;
    procedure SetFilterOptions(Value: TFilterOptions); override;
    procedure InternalRefreshRow; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddIndex(const Name, Fields: string; Options: TIndexOptions;
      const DescFields: string = '');
    procedure CreateTable;
    procedure DeleteIndex(const Name: string);
    procedure DeleteTable;
    procedure EmptyTable;
    procedure GetDetailLinkFields(MasterFields, DetailFields: TList); override;
    procedure GetIndexNames(List: TStrings);
    procedure GotoCurrent(Table: TIBTable);
    function Locate(const KeyFields: string; const KeyValues: Variant;
                    Options: TLocateOptions): Boolean; override;

    property LiveMode;
    property CurrentDBKey: TIBDBKey read GetCurrentDBKey;
    property Exists: Boolean read GetExists;
    property IndexFieldCount: Integer read GetIndexFieldCount;
    property IndexFields[Index: Integer]: TField read GetIndexField write SetIndexField;
    property TableNames: TStrings read GetTableNames;

  published
    property Active;
    property BufferChunks;
    property CachedUpdates;
    property Constraints stored ConstraintsStored;
    property DefaultIndex: Boolean read FDefaultIndex write FDefaultIndex default True;
    property FieldDefs stored FieldDefsStored;
    property Filter;
    property Filtered;
    property IndexDefs: TIndexDefs read FIndexDefs write SetIndexDefs stored IndexDefsStored;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property MasterSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property StoreDefs: Boolean read FStoreDefs write FStoreDefs default False;
    property TableName: String read FTableName write SetTableName;
    property TableTypes: TIBTableTypes read FTableTypes write SetTableTypes default [];
    property UpdateObject;
    property UniDirectional;

    property BeforeDatabaseDisconnect;
    property AfterDatabaseDisconnect;
    property DatabaseFree;
    property BeforeTransactionEnd;
    property AfterTransactionEnd;
    property TransactionFree;
    property OnFilterRecord;
  end;

implementation

{ TIBTable }

constructor TIBTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNameList := TStringList.Create;
  FSwitchingIndex := False;
  FIndexDefs := TIndexDefs.Create(Self);
  WhereAllRefreshSQL := TStringList.Create;
  WhereDBKeyRefreshSQL := TStringList.Create;
  WherePrimaryRefreshSQL := TStringList.Create;
  FDefaultIndex := True;
  FRegenerateSQL := True;
  FMasterFieldsList := TStringList.Create;
  FDetailFieldsList := TStringList.Create;
  FMasterLink := TMasterDataLink.Create(Self);
  FMasterLink.OnMasterChange := MasterChanged;
  FMasterLink.OnMasterDisable := MasterDisabled;
  QRefresh.OnSQLChanging := nil;
  QDelete.OnSQLChanging := nil;
  QInsert.OnSQLChanging := nil;
  QModify.OnSQLChanging := nil;
end;

destructor TIBTable.Destroy;
begin
  FNameList.Free;
  FIndexDefs.Free;
  FMasterFieldsList.Free;
  FDetailFieldsList.Free;
  FMasterLink.Free;
  WhereAllRefreshSQL.Free;
  WhereDBKeyRefreshSQL.Free;
  WherePrimaryRefreshSQL.Free;
  inherited Destroy;
end;

procedure TIBTable.InternalClose;
begin
  DataEvent(dePropertyChange, 0);
  inherited InternalClose;
end;

procedure TIBTable.InternalOpen;
begin
  if FTableName = '' then
    IBError(ibxeNoTableName, [nil]);
  ActivateConnection;
  ActivateTransaction;
  if FRegenerateSQL then
  begin
    InternalUnprepare;
    GenerateSQL;
    FRegenerateSQL := False;
  end;
  SetParams;
  inherited InternalOpen;
end;

procedure TIBTable.InternalRefresh;
var
  DBKey: TIBDBKey;
begin
  DBKey := CurrentDBKey;
  Reopen;
  if DBKey.DBKey[0] <> 0 then
    InternalGotoDBKey(DBKey);
end;

procedure TIBTable.SetFiltered(Value: Boolean);
begin
  if(Filtered <> Value) then
  begin
    inherited SetFiltered(value);
    if Active then
      InternalTableRefresh;
  end
  else
    inherited SetFiltered(value);
end;

procedure TIBTable.SetFilterText(const Value: string);
begin
  if Filtered and (Value <> Filter) then
  begin
    inherited SetFilterText(value);
    InternalTableRefresh;
  end
  else
    inherited SetFilterText(value);
end;

procedure TIBTable.SetFilterOptions(Value: TFilterOptions);
begin
  if Value <> [] then
    IBError(ibxeNotSupported, [nil]);
end;

procedure TIBTable.InternalRefreshRow;
begin
  if CurrentDBKey.DBKey[0] <> 0 then
    QRefresh.SQL.Assign(WhereDBKeyRefreshSQL)
  else if WherePrimaryRefreshSQL.Text <> '' then
    QRefresh.SQL.Assign(WherePrimaryRefreshSQL)
  else
    QRefresh.SQL.Assign(WhereAllRefreshSQL);
  inherited InternalRefreshRow;
end;

procedure TIBTable.DefChanged(Sender: TObject);
begin
  StoreDefs := True;
end;

procedure TIBTable.InitFieldDefs;
var
  sqlscale: Integer;
  Query: TIBSQL;
begin
  if FTableName = '' then IBError(ibxeNoTableName, [nil]);
  if (InternalPrepared) then InternalInitFieldDefs else
  begin
    Database.InternalTransaction.StartTransaction;
    Query := TIBSQL.Create(self);
    try
      Query.GoToFirstRecordOnExecute := False;
      Query.Database := DataBase;
      Query.Transaction := Database.InternalTransaction;
      Query.SQL.Text := 'Select R.RDB$FIELD_NAME, R.RDB$FIELD_POSITION, ' + {do not localize}
                        'F.RDB$COMPUTED_BLR, R.RDB$DEFAULT_VALUE, ' + {do not localize}
                        'R.RDB$NULL_FLAG, ' + {do not localize}
                        'F.RDB$FIELD_LENGTH, F.RDB$FIELD_SCALE, ' + {do not localize}
                        'F.RDB$FIELD_TYPE, F.RDB$FIELD_SUB_TYPE, ' + {do not localize}
                        'F.RDB$EXTERNAL_LENGTH, F.RDB$EXTERNAL_SCALE, F.RDB$EXTERNAL_TYPE ' + {do not localize}
                        'from RDB$RELATION_FIELDS R, RDB$FIELDS F ' + {do not localize}
                        'where R.RDB$RELATION_NAME = ' + {do not localize}
                        '''' +
                        FormatIdentifierValue(Database.SQLDialect,
                          QuoteIdentifier(DataBase.SQLDialect, FTableName)) +
                        ''' ' +
                        'and R.RDB$FIELD_SOURCE = F.RDB$FIELD_NAME '+ {do not localize}
                        'order by R.RDB$FIELD_POSITION'; {do not localize}

      Query.Prepare;
      Query.ExecQuery;
      FieldDefs.BeginUpdate;
      FieldDefs.Clear;
      while (not Query.EOF) and (Query.Next <> nil) do
      begin
          with FieldDefs.AddFieldDef do
          begin
            FieldNo := Query.Current.ByName('RDB$FIELD_POSITION').AsInteger; {do not localize}
            Name := TrimRight(Query.Current.ByName('RDB$FIELD_NAME').AsString); {do not localize}
            case Query.Current.ByName('RDB$FIELD_TYPE').AsInteger of {do not localize}
              blr_varying, blr_text:
              begin
                DataType := ftString;
                Size := Query.Current.ByName('RDB$FIELD_LENGTH').AsInteger; {do not localize}
              end;
              blr_float, blr_double, blr_d_float: DataType := ftFloat;
              blr_short:
              begin
                sqlscale := Query.Current.ByName('RDB$FIELD_SCALE').AsInteger; {do not localize}
                if (sqlscale = 0) then
                  DataType := ftSmallInt
                else
                begin
                  DataType := ftBCD;
                  Precision := 4;
                  Size := -sqlscale;
                end;
              end;
              blr_long:
              begin
                sqlscale := Query.Current.ByName('RDB$FIELD_SCALE').AsInteger; {do not localize}
                if (sqlscale = 0) then
                  DataType := ftInteger
                else if (sqlscale >= (-4)) then
                begin
                  DataType := ftBCD;
                  Precision := 9;
                  Size := -sqlscale;
                end
                else
                  DataType := ftFloat;
              end;
              blr_int64:
              begin
                sqlscale := Query.Current.ByName('RDB$FIELD_SCALE').AsInteger; {do not localize}
                if (sqlscale = 0) then
                  DataType := ftLargeInt
                else if (sqlscale >= (-4)) then
                begin
                  DataType := ftBCD;
                  Precision := 18;
                  Size := -sqlscale;
                end
                else
                  DataType := ftFloat;
              end;
              blr_timestamp: DataType := ftDateTime;
              blr_sql_time: DataType := ftTime;
              blr_sql_date: DataType := ftDate;
              blr_blob:
                if (Query.Current.ByName('RDB$FIELD_SUB_TYPE').AsInteger = 1) then {do not localize}
                  DataType := ftMemo
                else
                  DataType := ftBlob;
              blr_quad:
              begin
                DataType := ftUnknown;
                Size := sizeof (TISC_QUAD);
              end;
              else
                DataType := ftUnknown;
            end;
            if not (Query.Current.ByName('RDB$COMPUTED_BLR').IsNull) then {do not localize}
            begin
              Attributes := [faReadOnly];
              InternalCalcField := True
            end
            else
              InternalCalcField := False;
            if ((not InternalCalcField) and
                 Query.Current.ByName('RDB$DEFAULT_VALUE').IsNull and {do not localize}
                 (Query.Current.ByName('RDB$NULL_FLAG').AsInteger = 1) )then {do not localize}
            begin
              Attributes := [faRequired];
              Required := True;
            end;
          end;
      end;
      FieldDefs.EndUpdate;
    finally
      Query.free;
      Database.InternalTransaction.Commit;
    end;
  end;
end;

{ Index / Ranges / Keys }

procedure TIBTable.AddIndex(const Name, Fields: string; Options: TIndexOptions;
  const DescFields: string);
var
  Query: TIBSQL;
  FieldList: string;
begin
  FieldDefs.Update;
  if Active then
  begin
    CheckBrowseMode;
    CursorPosChanged;
  end;
  Query := TIBSQL.Create(self);
  try
    Query.Database := DataBase;
    Query.Transaction := Transaction;
    FieldList := FormatFieldsList(Fields);
    if (ixPrimary in Options) then
    begin
     Query.SQL.Text := 'Alter Table ' + {do not localize}
       QuoteIdentifier(Database.SQLDialect, FTableName) +
       ' Add CONSTRAINT ' +   {do not localize}
       QuoteIdentifier(Database.SQLDialect, Name)
       + ' Primary Key (' + {do not localize}
       FormatFieldsList(Fields) +
       ')';   {do not localize}
    end
    else
    if ([ixUnique, ixDescending] * Options = [ixUnique, ixDescending]) then
      Query.SQL.Text := 'Create unique Descending Index ' + {do not localize}
                        QuoteIdentifier(Database.SQLDialect, Name) +
                        ' on ' + {do not localize}
                        QuoteIdentifier(Database.SQLDialect, FTableName) +
                        ' (' + FieldList + ')' {do not localize}
    else
      if (ixUnique in Options) then
        Query.SQL.Text := 'Create unique Index ' + {do not localize}
                          QuoteIdentifier(Database.SQLDialect, Name) +
                          ' on ' + {do not localize}
                          QuoteIdentifier(Database.SQLDialect, FTableName) +
                          ' (' + FieldList + ')' {do not localize}
      else
        if (ixDescending in Options) then
          Query.SQL.Text := 'Create Descending Index ' + {do not localize}
                            QuoteIdentifier(Database.SQLDialect, Name) +
                            ' on ' + {do not localize}
                            QuoteIdentifier(Database.SQLDialect, FTableName) +
                            ' (' + FieldList + ')'  {do not localize}
        else
          Query.SQL.Text := 'Create Index ' + {do not localize}
                            QuoteIdentifier(Database.SQLDialect, Name) +
                            ' on ' + {do not localize}
                            QuoteIdentifier(Database.SQLDialect, FTableName) +
                            ' (' + FieldList + ')'; {do not localize}
    Query.Prepare;
    Query.ExecQuery;
    IndexDefs.Updated := False;
  finally
    Query.free
  end;
end;

procedure TIBTable.DeleteIndex(const Name: string);
var
  Query: TIBSQL;

  procedure DeleteByIndex;
  begin
    Query := TIBSQL.Create(self);
    try
      Query.Database := DataBase;
      Query.Transaction := Transaction;
      Query.SQL.Text := 'Drop index ' +  {do not localize}
                         QuoteIdentifier(Database.SQLDialect, Name);
      Query.Prepare;
      Query.ExecQuery;
      IndexDefs.Updated := False;
    finally
      Query.Free;
    end;
  end;

  function DeleteByConstraint: Boolean;
  begin
    Result := False;
    Query := TIBSQL.Create(self);
    try
      Query.Database := DataBase;
      Query.Transaction := Transaction;
      Query.SQL.Text := 'Select ''foo'' from RDB$RELATION_CONSTRAINTS ' +  {do not localize}
        'where RDB$RELATION_NAME = ' +   {do not localize}
        '''' +  {do not localize}
        FormatIdentifierValue(Database.SQLDialect,
          QuoteIdentifier(DataBase.SQLDialect, FTableName)) +
        ''' ' +      {do not localize}
        ' AND RDB$CONSTRAINT_NAME = ' +  {do not localize}
        '''' +     {do not localize}
        FormatIdentifierValue(Database.SQLDialect,
          QuoteIdentifier(DataBase.SQLDialect, Name)) +
        ''' ' +    {do not localize}
        'AND RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''';   {do not localize}
      Query.Prepare;
      Query.ExecQuery;
      if not Query.EOF then
      begin
        Query.Close;
        Query.SQL.Text := 'Alter Table ' +  {do not localize}
          QuoteIdentifier(DataBase.SQLDialect, FTableName) +
          ' Drop Constraint ' +   {do not localize}
          QuoteIdentifier(DataBase.SQLDialect, Name);
        Query.Prepare;
        Query.ExecQuery;
        IndexDefs.Updated := False;
        Result := True;
      end;
    finally
      Query.Free;
    end;
  end;

  procedure DeleteByKey;
  begin
    Query := TIBSQL.Create(self);
    try
      Query.Database := DataBase;
      Query.Transaction := Transaction;
      Query.SQL.Text := 'Select RDB$CONSTRAINT_NAME from RDB$RELATION_CONSTRAINTS ' +   {do not localize}
        'where RDB$RELATION_NAME = ' +  {do not localize}
        '''' +  {do not localize}
        FormatIdentifierValue(Database.SQLDialect,
          QuoteIdentifier(DataBase.SQLDialect, FTableName)) +
        ''' ' +  {do not localize}
        'AND RDB$INDEX_NAME = ' +  {do not localize}
        '''' +  {do not localize}
        FormatIdentifierValue(Database.SQLDialect,
          QuoteIdentifier(DataBase.SQLDialect, Name)) +
        ''' ' +    {do not localize}
        'AND RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'''; {do not localize}
      Query.Prepare;
      Query.ExecQuery;
      if not Query.EOF then
      begin
        Query.Close;
        Query.SQL.Text := 'Alter Table ' +  {do not localize}
          QuoteIdentifier(DataBase.SQLDialect, FTableName) +
          ' Drop Constraint ' +  {do not localize}
          QuoteIdentifier(DataBase.SQLDialect, Query.Current.ByName('RDB$CONSTRAINT_NAME').AsString); {do not localize}
        Query.Prepare;
        Query.ExecQuery;
        IndexDefs.Updated := False;
      end;
    finally
      Query.Free;
    end;
  end;

begin
  if Active then
    CheckBrowseMode;
  IndexDefs.Update;
  if (Pos('RDB$PRIMARY', Name) <> 0 ) then {do not localize} {mbcs ok}
    DeleteByKey
  else if not DeleteByConstraint then
    DeleteByIndex;
end;

function TIBTable.GetIndexFieldNames: string;
begin
  if FFieldsIndex then Result := FIndexName else Result := '';  {do not localize}
end;

function TIBTable.GetIndexName: string;
begin
  if FFieldsIndex then Result := '' else Result := FIndexName;  {do not localize}
end;

procedure TIBTable.GetIndexNames(List: TStrings);
begin
  IndexDefs.Update;
  IndexDefs.GetItemNames(List);
end;

procedure TIBTable.GetIndexParams(const IndexName: string;
  FieldsIndex: Boolean; var IndexedName: string);
var
  IndexStr: TIndexName;
begin
  if IndexName <> '' then   {do not localize}
  begin
    IndexDefs.Update;
    IndexStr := IndexName;
    if FieldsIndex then
      IndexStr := IndexDefs.FindIndexForFields(IndexName).Name;
  end;
  IndexedName := IndexStr;
end;

procedure TIBTable.SetIndexDefs(Value: TIndexDefs);
begin
  IndexDefs.Assign(Value);
end;

procedure TIBTable.SetIndex(const Value: string; FieldsIndex: Boolean);
begin
  if Active then CheckBrowseMode;
  if (FIndexName <> Value) or (FFieldsIndex <> FieldsIndex) then
  begin
    FIndexName := Value;
    FFieldsIndex := FieldsIndex;
    if Active then
    begin
      SwitchToIndex;
    end;
  end;
end;

procedure TIBTable.SetIndexFieldNames(const Value: string);
begin
  SetIndex(Value, Value <> '');  {do not localize}
end;

procedure TIBTable.SetIndexName(const Value: string);
begin
  SetIndex(Value, False);
end;

procedure TIBTable.UpdateIndexDefs;
var
  Opts: TIndexOptions;
  Flds: string;
  Query, SubQuery: TIBSQL;
begin
  if not (csReading in ComponentState) then begin
  if not Active and not FSwitchingIndex  then
    FieldDefs.Update;
  IndexDefs.Clear;
  Database.InternalTransaction.StartTransaction;
  Query := TIBSQL.Create(self);
  try
    FPrimaryIndexFields := '';
    Query.GoToFirstRecordOnExecute := False;
    Query.Database := DataBase;
    Query.Transaction := Database.InternalTransaction;
    Query.SQL.Text :=
    'Select I.RDB$INDEX_NAME, I.RDB$UNIQUE_FLAG, I.RDB$INDEX_TYPE, ' + {do not localize}
    'I.RDB$SEGMENT_COUNT, S.RDB$FIELD_NAME from RDB$INDICES I, ' + {do not localize}
    'RDB$INDEX_SEGMENTS S where I.RDB$INDEX_NAME = S.RDB$INDEX_NAME '+ {do not localize}
    'and I.RDB$RELATION_NAME = ' + '''' + {do not localize}
     FormatIdentifierValue(Database.SQLDialect,
       QuoteIdentifier(DataBase.SQLDialect, FTableName)) + '''';
    Query.Prepare;
    Query.ExecQuery;
    while (not Query.EOF) and (Query.Next <> nil) do
    begin
      with IndexDefs.AddIndexDef do
      begin
        Name := TrimRight(Query.Current.ByName('RDB$INDEX_NAME').AsString); {do not localize}
        Opts := [];
        if Pos ('RDB$PRIMARY', Name) = 1 then Include(Opts, ixPrimary); {do not localize} {mbcs ok}
        if Query.Current.ByName('RDB$UNIQUE_FLAG').AsInteger = 1 then Include(Opts, ixUnique); {do not localize}
        if Query.Current.ByName('RDB$INDEX_TYPE').AsInteger = 1  then Include(Opts, ixDescending); {do not localize}
        Options := Opts;
        if (Query.Current.ByName('RDB$SEGMENT_COUNT').AsInteger = 1) then {do not localize}
          Fields := Trim(Query.Current.ByName('RDB$FIELD_NAME').AsString) {do not localize}
        else begin
          SubQuery := TIBSQL.Create(self);
        try
          SubQuery.GoToFirstRecordOnExecute := False;
          SubQuery.Database := DataBase;
          SubQuery.Transaction := Database.InternalTransaction;
          SubQuery.SQL.Text :=
         'Select RDB$FIELD_NAME from RDB$INDEX_SEGMENTS where RDB$INDEX_NAME = ' + {do not localize}
          '''' +  {do not localize}
          FormatIdentifierValue(Database.SQLDialect,
            QuoteIdentifier(DataBase.SQLDialect, Name)) +
          '''' + 'ORDER BY RDB$FIELD_POSITION'; {do not localize}
          SubQuery.Prepare;
          SubQuery.ExecQuery;
          Flds := '';
          while (not SubQuery.EOF) and (SubQuery.Next <> nil) do
          begin
            if (Flds = '') then
              Flds := TrimRight(SubQuery.Current.ByName('RDB$FIELD_NAME').AsString) {do not localize}
            else begin
              Query.Next;
              Flds := Flds + ';' + TrimRight(SubQuery.Current[0].AsString);
            end;
          end;
          Fields := Flds;
        finally
          SubQuery.Free;
        end;
        end;
        if (ixDescending in Opts) then
          DescFields := Fields;
        if ixPrimary in Opts then
          FPrimaryIndexFields := Fields;
      end;
    end;
  finally
    Query.Free;
    Database.InternalTransaction.Commit;
  end;
  end;
end;

function TIBTable.GetExists: Boolean;
var
  Query: TIBSQL;
begin
  Result := Active;
  if Result or (TableName = '') then Exit;
  Database.InternalTransaction.StartTransaction;
  Query := TIBSQL.Create(self);
  try
    Query.Database := DataBase;
    Query.Transaction := Database.InternalTransaction;
    Query.SQL.Text :=
    'Select USER from RDB$RELATIONS where RDB$RELATION_NAME = ' + {do not localize}
    '''' +    {do not localize}
    FormatIdentifierValue(Database.SQLDialect,
      QuoteIdentifier(DataBase.SQLDialect, FTableName)) + '''';  {do not localize}
    Query.Prepare;
    Query.ExecQuery;
    Result := not Query.EOF;
  finally
    Query.Free;
    Database.InternalTransaction.Commit;
  end;
end;

procedure TIBTable.GotoCurrent(Table: TIBTable);
begin
  CheckBrowseMode;
  Table.CheckBrowseMode;
  if (Database <> Table.Database) or
    (CompareText(TableName, Table.TableName) <> 0) then
    IBError(ibxeTableNameMismatch, [nil]);
  Table.UpdateCursorPos;
  InternalGotoDBKey(Table.CurrentDBKey);
  DoBeforeScroll;
  Resync([rmExact, rmCenter]);
  DoAfterScroll;
end;


procedure TIBTable.CreateTable;
var
  FieldList: string;

  procedure InitFieldsList;
  var
    I: Integer;
  begin
    InitFieldDefsFromFields;
    for I := 0 to FieldDefs.Count - 1 do begin
      if ( I > 0) then
        FieldList := FieldList + ', ';   {do not localize}
      with FieldDefs[I] do
      begin
        case DataType of
          ftString:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' VARCHAR(' + IntToStr(Size) + ')'; {do not localize}
          ftFixedChar:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' CHAR(' + IntToStr(Size) + ')'; {do not localize}
          ftBoolean, ftSmallint, ftWord:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' SMALLINT'; {do not localize}
          ftInteger:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' INTEGER'; {do not localize}
          ftFloat, ftCurrency:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' DOUBLE PRECISION'; {do not localize}
          ftBCD: begin
            if (Database.SQLDialect = 1) then begin
              if (Precision > 9) then
                IBError(ibxeFieldUnsupportedType,[nil]);
              if (Precision <= 4) then
                Precision := 9;
            end;
            if (Precision <= 4 ) then
              FieldList := FieldList +
                QuoteIdentifier(DataBase.SQLDialect, Name) +
                ' Numeric(18, 4)' {do not localize}
            else
              FieldList := FieldList +
                QuoteIdentifier(DataBase.SQLDialect, Name) +
                ' Numeric(' + IntToStr(Precision) + ', 4)'; {do not localize}
          end;
          ftDate:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' DATE'; {do not localize}
          ftTime:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' TIME'; {do not localize}
          ftDateTime:
            if (Database.SQLDialect = 1) then
              FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' DATE' {do not localize}
            else
              FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' TIMESTAMP'; {do not localize}
          ftLargeInt:
            if (Database.SQLDialect = 1) then
              IBError(ibxeFieldUnsupportedType,[nil])
            else
              FieldList := FieldList +
                QuoteIdentifier(DataBase.SQLDialect, Name) +
                ' Numeric(18, 0)'; {do not localize}
          ftBlob, ftMemo:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' BLOB SUB_TYPE 1'; {do not localize}
          ftBytes, ftVarBytes, ftGraphic..ftTypedBinary:
            FieldList := FieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) +
              ' BLOB SUB_TYPE 0'; {do not localize}
          ftUnknown, ftADT, ftArray, ftReference, ftDataSet,
          ftCursor, ftWideString, ftAutoInc:
            IBError(ibxeFieldUnsupportedType,[nil]);
          else
            IBError(ibxeFieldUnsupportedType,[nil]);
        end;
        if faRequired in Attributes then
          FieldList := FieldList + ' NOT NULL'; {do not localize}
      end;
    end;
  end;

  procedure InternalCreateTable;
  var
    I: Integer;
    Query: TIBSQL;
  begin
    if (FieldList = '') then
      IBError(ibxeFieldUnsupportedType,[nil]);
    Query := TIBSQL.Create(self);
    try
      Query.Database := Database;
      Query.transaction := Transaction;
      Query.SQL.Text := 'Create Table ' +    {do not localize}
        QuoteIdentifier(DataBase.SQLDialect, FTableName) +
        ' (' + FieldList; {do not localize}
      for I := 0 to IndexDefs.Count - 1 do
      with IndexDefs[I] do
        if ixPrimary in Options then
        begin
          Query.SQL.Text := Query.SQL.Text + ', CONSTRAINT ' +    {do not localize}
            QuoteIdentifier(DataBase.SQLDialect, Name) +
            ' Primary Key (' +   {do not localize}
            FormatFieldsList(Fields) +
            ')';         {do not localize}
        end;
      Query.SQL.Text := Query.SQL.Text + ')';    {do not localize}
      Query.Prepare;
      Query.ExecQuery;
    finally
      Query.Free;
    end;
  end;

  procedure InternalCreateIndex;
  var
    I: Integer;
  begin
    for I := 0 to IndexDefs.Count - 1 do
    with IndexDefs[I] do
      if not (ixPrimary in Options) then
        AddIndex(Name, Fields, Options);
  end;

begin
  CheckInactive;
  InitFieldsList;
  InternalCreateTable;
  InternalCreateIndex;
end;

procedure TIBTable.DeleteTable;
var
  Query: TIBSQL;
begin
  CheckInactive;
  Query := TIBSQL.Create(self);
  try
    Query.Database := DataBase;
    Query.Transaction := Transaction;
    Query.SQL.Text := 'drop table ' +  {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName);
    Query.Prepare;
    Query.ExecQuery;
  finally
    Query.Free;
  end;
end;

procedure TIBTable.EmptyTable;
var
  Query: TIBSQL;
begin
  if Active then
    CheckBrowseMode;
  Query := TIBSQL.Create(self);
  try
    Query.Database := DataBase;
    Query.Transaction := Transaction;
    Query.SQL.Text := 'delete from ' + {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName);
    Query.Prepare;
    Query.ExecQuery;
    if Active then
    begin
      ClearBuffers;
      DataEvent(deDataSetChange, 0);
    end;
  finally
    Query.Free;
  end;
end;

procedure TIBTable.DataEvent(Event: TDataEvent; Info: Longint);
begin
  if Event = dePropertyChange then begin
    IndexDefs.Updated := False;
    FRegenerateSQL := True;
  end;
  inherited DataEvent(Event, Info);
end;

{ Informational & Property }

function TIBTable.GetCanModify: Boolean;
begin
  Result := True;
  if (FTableName = '') or FReadOnly
    or FSystemTable or FMultiTableView then
    Result := False;
end;

function TIBTable.InternalGetUpdatable: Boolean;
var
  Query : TIBSQL;
begin
  Database.InternalTransaction.StartTransaction;
  Query := TIBSQL.Create(self);
  try
    Query.Database := DataBase;
    Query.Transaction := Database.InternalTransaction;
    Query.SQL.Text := 'Select RDB$SYSTEM_FLAG, RDB$DBKEY_LENGTH ' + {do not localize}
                    'from RDB$RELATIONS where RDB$RELATION_NAME = ' + {do not localize}
                    '''' +   {do not localize}
                    FormatIdentifierValue(Database.SQLDialect,
                      QuoteIdentifier(DataBase.SQLDialect, FTableName)) + '''';  {do not localize}
    Query.Prepare;
    Query.ExecQuery;
    if (Query.Current[0].AsInteger <> 0) or
       (Query.Current[1].AsInteger <> 8) then
      Result := False
    else
      Result := True;
  finally
    Query.Free;
    Database.InternalTransaction.Commit;
  end;
end;

function TIBTable.FieldDefsStored: Boolean;
begin
  Result := StoreDefs and (FieldDefs.Count > 0);
end;

function TIBTable.IndexDefsStored: Boolean;
begin
  Result := StoreDefs and (IndexDefs.Count > 0);
end;

procedure TIBTable.SetParams;
var
  i: Integer;
begin
  if (MasterSource = nil) or (MasterSource.DataSet = nil) or
  (not MasterSource.DataSet.Active) or (FMasterFieldsList.Count = 0) then
    exit;
  for i := 0 to FMasterFieldsList.Count - 1 do
    QSelect.Params.ByName(FMasterFieldsList.Strings[i]).Value :=
    MasterSource.DataSet.FieldByName(FMasterFieldsList.Strings[i]).Value;
end;

procedure TIBTable.MasterChanged(Sender: TObject);
begin
  CheckBrowseMode;
  SetParams;
  ReQuery;
end;

procedure TIBTable.MasterDisabled(Sender: TObject);
begin
  DataEvent(dePropertyChange, 0);
  ReQuery;
end;

function TIBTable.GetDataSource: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

procedure TIBTable.SetDataSource(Value: TDataSource);
begin
  if IsLinkedTo(Value) then IBError(ibxeCircularDataLink, [Self]);
  if FMasterLink.DataSource <> Value then
    DataEvent(dePropertyChange, 0);
  FMasterLink.DataSource := Value;
end;

function TIBTable.GetMasterFields: string;
begin
  Result := FMasterLink.FieldNames;
end;

procedure TIBTable.SetMasterFields(const Value: string);
begin
  if FMasterLink.FieldNames <> Value then
    DataEvent(dePropertyChange, 0);
  FMasterLink.FieldNames := Value;
end;

procedure TIBTable.DoOnNewRecord;
var
  I: Integer;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
    for I := 0 to FMasterLink.Fields.Count - 1 do
      IndexFields[I] := TField(FMasterLink.Fields[I]);
  inherited DoOnNewRecord;
end;

function TIBTable.FormatFieldsList(Value: String): String;
var
  FieldName: string;
  i: Integer;
begin
  if Database.SQLDialect = 1 then
  begin
    Value := QuoteIdentifier(Database.SQLDialect, Value);
    Result := StringReplace (Value, ';', ', ', [rfReplaceAll]);  {do not localize}
  end
  else
  begin
    i := 1;
    Result := '';    {do not localize}
    while i <= Length(Value) do
    begin
      FieldName := ExtractFieldName(Value, i);
      if Result = '' then   {do not localize}
        Result := QuoteIdentifier(Database.SQLDialect, FieldName)
      else
        Result := Result + ', ' + QuoteIdentifier(Database.SQLDialect, FieldName);  {do not localize}
    end;
  end;
end;

procedure TIBTable.ExtractLinkFields;
var
  i: Integer;
  DetailFieldNames: String;
begin
  FMasterFieldsList.Clear;
  FDetailFieldsList.Clear;
  i := 1;
  while i <= Length(MasterFields) do
    FMasterFieldsList.Add(ExtractFieldName(MasterFields, i));
  i := 1;
  if IndexFieldNames = '' then   {do not localize}
    DetailFieldNames := FPrimaryIndexFields
  else
    DetailFieldNames := IndexFieldNames;
  while i <= Length(DetailFieldNames) do
    FDetailFieldsList.Add(ExtractFieldName(DetailFieldNames, i));
end;

procedure TIBTable.GetDetailLinkFields(MasterFields, DetailFields: TList);
var
  i: Integer;
  Idx: TIndexDef;
begin
  MasterFields.Clear;
  DetailFields.Clear;
  if (MasterSource <> nil) and (MasterSource.DataSet <> nil) and
     (Self.MasterFields <> '') then   {do not localize}
  begin
    Idx := nil;
    MasterSource.DataSet.GetFieldList(MasterFields, Self.MasterFields);
    UpdateIndexDefs;
    if IndexName <> '' then
      Idx := IndexDefs.Find(IndexName)
    else if IndexFieldNames <> '' then  {do not localize}
      Idx := IndexDefs.GetIndexForFields(IndexFieldNames, False)
    else
      for i := 0 to IndexDefs.Count - 1 do
        if ixPrimary in IndexDefs[i].Options then
        begin
          Idx := IndexDefs[i];
          break;
        end;
    if Idx <> nil then
      GetFieldList(DetailFields, Idx.Fields);
  end;
end;

procedure TIBTable.SetReadOnly(Value: Boolean);
begin
  CheckInactive;
  FReadOnly := Value;
end;

procedure TIBTable.SetTableName(Value: String);
begin
  if not (csReading in ComponentState) then
  begin
    if Value <> FTableName then
    begin
      CheckInactive;
      ResetSQLStatements;
      FRegenerateSQL := True;
      FTableName := Value;
      IndexName := '';   {do not localize}
      IndexFieldNames := '';    {do not localize}
      FPrimaryIndexFields := '';  {do not localize}
      DataEvent(dePropertyChange, 0);
    end;
  end
  else
    if Value <> FTableName then
      FTableName := Value;
end;

function TIBTable.GetIndexField(Index: Integer): TField;
var
  I, Count: Integer;
  FieldNames, FieldName: String;
begin
  Result := nil;
  FieldName := '';  {do not localize}
  FieldNames := IndexFieldNames;
  if FieldNames = '' then   {do not localize}
  begin
    for I := 0 to IndexDefs.Count - 1 do
      if (IndexDefs[i].Name = FIndexName) then
      begin
        FieldNames := IndexDefs[i].Fields;
        break;
      end;
  end;
  for I := 0 to Index do
  begin
    Count := Pos(';', FieldNames); {mbcs OK}  {do not localize}
    if Count = 0 then
      FieldName := FieldNames
    else begin
      FieldName := Copy(FieldNames, 0, Count - 1);
      System.Delete(FieldNames, 1, Count);
    end;
  end;
  if FieldName <> '' then  {do not localize}
    Result := FieldByName(FieldName)
  else
    IBError(ibxeIndexFieldMissing, [nil]);
end;


procedure TIBTable.SetIndexField(Index: Integer; Value: TField);
begin
  GetIndexField(Index).Assign(Value);
end;

function TIBTable.GetIndexFieldCount: Integer;
var
  I, Index: Integer;
  FieldNames: String;
  done: Boolean;
begin
  FieldNames := IndexFieldNames;
  if FieldNames = '' then   {do not localize}
  begin
    for I := 0 to IndexDefs.Count - 1 do
      if (IndexDefs[i].Name = FIndexName) then
      begin
        FieldNames := IndexDefs[i].Fields;
        break;
      end;
  end;
  if FieldNames = '' then    {do not localize}
    Result := 0
  else
  begin
    done := False;
    Result := 1;
    while not done do
    begin
      Index := Pos(';', FieldNames); {mbcs ok}  {do not localize}
      if Index <> 0 then
      begin
        System.Delete(FieldNames, 1, Index);
        Inc(Result);
      end else
        done := True;
    end;
  end;
end;

function TIBTable.GetTableNames: TStrings;
begin
  FNameList.clear;
  GetTableNamesFromServer;
  Result := FNameList;
end;

procedure TIBTable.GetTableNamesFromServer;
var
  Query : TIBSQL;
begin
  if not (csReading in ComponentState) then begin
    ActivateConnection;
    Database.InternalTransaction.StartTransaction;
    Query := TIBSQL.Create(self);
    try
      Query.GoToFirstRecordOnExecute := False;
      Query.Database := DataBase;
      Query.Transaction := Database.InternalTransaction;
      if (TableTypes * [ttSystem, ttView] = [ttSystem, ttView]) then
        Query.SQL.Text := 'Select RDB$RELATION_NAME from RDB$RELATIONS' {do not localize}
      else if ttSystem in TableTypes then
        Query.SQL.Text := 'Select RDB$RELATION_NAME from RDB$RELATIONS' + {do not localize}
                          ' where RDB$VIEW_BLR is NULL' {do not localize}
      else if ttView in TableTypes then
        Query.SQL.Text := 'Select RDB$RELATION_NAME from RDB$RELATIONS' + {do not localize}
                          ' where RDB$SYSTEM_FLAG = 0' {do not localize}
      else
        Query.SQL.Text := 'Select RDB$RELATION_NAME from RDB$RELATIONS' + {do not localize}
                          ' where RDB$VIEW_BLR is NULL and RDB$SYSTEM_FLAG = 0'; {do not localize}
      Query.Prepare;
      Query.ExecQuery;
      while (not Query.EOF) and (Query.Next <> nil) do
        FNameList.Add (TrimRight(Query.Current[0].AsString));
    finally
      Query.Free;
      Database.InternalTransaction.Commit;
    end;
  end;
end;

procedure TIBTable.SwitchToIndex();
begin
  FSwitchingIndex := True;
  InternalTableRefresh;
  FSwitchingIndex := False;
end;

procedure TIBTable.InternalTableRefresh();
var
  DBKey: TIBDBKey;
begin
  CheckActive;
  DBKey := CurrentDBKey;
  FRegenerateSQL := True;
  Reopen;
  if DBKey.DBKey[0] <> 0 then
    InternalGotoDBKey(DBKey);
end;

procedure TIBTable.GenerateSQL;
var
  i: Integer;
  SQL: TStrings;
  OrderByStr: string;
  bWhereClausePresent: Boolean;
begin
  bWhereClausePresent := False;
  Database.CheckActive;
  Transaction.CheckInTransaction;
  if IndexDefs.Updated = False then
    IndexDefs.Update;
  if IndexFieldNames <> '' then
    OrderByStr := FormatFieldsList(IndexFieldNames)
  else
    if IndexName <> '' then
    begin
      OrderByStr := FormatFieldsList(IndexDefs[IndexDefs.Indexof (IndexName)].Fields);
      if ixDescending in IndexDefs[IndexDefs.Indexof (IndexName)].Options then
      begin
        StringReplace (OrderByStr, ',', ' DESC,', [rfReplaceAll]);  {do not localize}
        OrderByStr := OrderByStr + ' DESC';   {do not localize}
      end;
    end
    else
      if FDefaultIndex and (FPrimaryIndexFields <> '') then    {do not localize}
        OrderByStr := FormatFieldsList(FPrimaryIndexFields);
  SQL := TStringList.Create;
  SQL.Text := 'select ' + {do not localize}
    QuoteIdentifier(DataBase.SQLDialect, FTableName) + '.*, ' {do not localize}
    + 'RDB$DB_KEY as IBX_INTERNAL_DBKEY from ' {do not localize}
    + QuoteIdentifier(DataBase.SQLDialect, FTableName);
  if Filtered and (Filter <> '') then  {do not localize}
  begin
    SQL.Text := SQL.Text + ' where ' + Filter; {do not localize}
    bWhereClausePresent := True;
  end;
  if (MasterSource <> nil) and (MasterSource.DataSet <> nil) and (MasterFields <> '') then {do not localize}
  begin
    if bWhereClausePresent then
      SQL.Text := SQL.Text + ' AND ' {do not localize}
    else
      SQL.Text := SQL.Text + ' WHERE '; {do not localize}
    ExtractLinkfields;
    if FDetailFieldsList.Count < FMasterFieldsList.Count then
      IBError(ibxeUnknownError, [nil]);
    for i := 0 to FMasterFieldsList.Count - 1 do
    begin
      if i > 0 then
        SQL.Text := SQL.Text + 'AND ';   {do not localize}
      SQL.Text := SQL.Text +
        QuoteIdentifier(DataBase.SQLDialect, FDetailFieldsList.Strings[i]) +
        ' = :' +
        QuoteIdentifier(DataBase.SQLDialect, FMasterFieldsList.Strings[i]);
    end;
  end;
  if OrderByStr <> '' then
    SQL.Text := SQL.Text + ' order by ' + OrderByStr; {do not localize}
  SelectSQL.Assign(SQL);
  RefreshSQL.Text := 'select ' + {do not localize}
    QuoteIdentifier(DataBase.SQLDialect, FTableName) + '.*, ' {do not localize}
    + 'RDB$DB_KEY as IBX_INTERNAL_DBKEY from ' {do not localize}
    + QuoteIdentifier(DataBase.SQLDialect, FTableName) +
    ' where RDB$DB_KEY = :IBX_INTERNAL_DBKEY'; {do not localize}
  WhereDBKeyRefreshSQL.Assign(RefreshSQL);
  InternalPrepare;
  if not FReadOnly then
    GenerateUpdateSQL;
  SQL.Free;
end;

procedure TIBTable.GenerateUpdateSQL;
var
  InsertFieldList, InsertParamList, UpdateFieldList: string;
  WherePrimaryFieldList, WhereAllFieldList: string;

  procedure GenerateFieldLists;
  var
    I: Integer;
  begin
    for I := 0 to FieldDefs.Count - 1 do begin
      with FieldDefs[I] do begin
        if not (InternalCalcField or (faReadOnly in Attributes) or
          (DataType = ftUnknown)) then
        begin
          if ( InsertFieldList <> '' ) then begin
            InsertFieldList := InsertFieldList + ', ';     {do not localize}
            InsertParamList := InsertParamList + ', ';    {do not localize}
            UpdateFieldList := UpdateFieldList + ', ';     {do not localize}
            if (DataType <> ftBlob) and (DataType <>ftMemo) then
              WhereAllFieldList := WhereAllFieldList + ' AND ';  {do not localize}
          end;
          InsertFieldList := InsertFieldList +
            QuoteIdentifier(DataBase.SQLDialect, Name);
          InsertParamList := InsertParamList + ':' +  {do not localize}
            QuoteIdentifier(DataBase.SQLDialect, Name);
          UpdateFieldList := UpdateFieldList +
            QuoteIdentifier(DataBase.SQLDialect, Name) +
            ' = :' +   {do not localize}
            QuoteIdentifier(DataBase.SQLDialect, Name);
          if (DataType <> ftBlob) and (DataType <>ftMemo) then
            WhereAllFieldList := WhereAllFieldList +
              QuoteIdentifier(DataBase.SQLDialect, Name) + ' = :' +  {do not localize}
              QuoteIdentifier(DataBase.SQLDialect, Name);
        end;
      end;
    end;
  end;

  procedure GenerateWherePrimaryFieldList;
  var
    i: Integer;
    tmp: String;
  begin
    i := 1;
    while i <= Length(FPrimaryIndexFields) do
    begin
      tmp := ExtractFieldName(FPrimaryIndexFields, i);
      tmp :=
        QuoteIdentifier(DataBase.SQLDialect, tmp) +  ' = :' +   {do not localize}
        QuoteIdentifier(DataBase.SQLDialect, tmp);
      if WherePrimaryFieldList <> '' then
        WherePrimaryFieldList :=
          WherePrimaryFieldList + ' AND ' + tmp     {do not localize}
      else
        WherePrimaryFieldList := tmp;
    end;
  end;

begin
  if InternalGetUpdatable = False  then
    FReadOnly := True
  else
  begin
    DeleteSQL.Text := 'delete from ' + {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName) +
      ' where RDB$DB_KEY = ' + ':IBX_INTERNAL_DBKEY'; {do not localize}
    GenerateFieldLists;
    InsertSQL.Text := 'insert into ' + {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName) +
    ' (' + InsertFieldList + {do not localize}
      ') values (' + InsertParamList + ')'; {do not localize}
    ModifySQL.Text := 'update ' +  {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName) +
      ' set ' + UpdateFieldList + {do not localize}
      ' where RDB$DB_KEY = :IBX_INTERNAL_DBKEY'; {do not localize}
    WhereAllRefreshSQL.Text := 'select ' +  {do not localize}
      QuoteIdentifier(DataBase.SQLDialect, FTableName) + '.*, ' {do not localize}
      + 'RDB$DB_KEY as IBX_INTERNAL_DBKEY from ' {do not localize}
      + QuoteIdentifier(DataBase.SQLDialect, FTableName) +
      ' where ' + WhereAllFieldList; {do not localize}
    if FPrimaryIndexFields <> '' then
    begin
      GenerateWherePrimaryFieldList;
      WherePrimaryRefreshSQL.Text := 'select ' + {do not localize}
        QuoteIdentifier(DataBase.SQLDialect, FTableName) + '.*, ' {do not localize}
        + 'RDB$DB_KEY as IBX_INTERNAL_DBKEY from ' {do not localize}
        + QuoteIdentifier(DataBase.SQLDialect, FTableName) +
        ' where ' + WherePrimaryFieldList; {do not localize}
    end;
    try
      InternalUnprepare;
      InternalPrepare;
    except
      FReadonly := True;
    end;
  end;
end;

procedure TIBTable.ResetSQLStatements;
begin
  SelectSQL.Text := ''; {do not localize}
  DeleteSQL.Text := '';  {do not localize}
  InsertSQL.Text := '';  {do not localize}
  ModifySQL.Text := '';  {do not localize}
  RefreshSQL.Text := '';  {do not localize}
end;

procedure TIBTable.SetTableTypes(
  const Value: TIBTableTypes);
begin
  FTableTypes := Value;
end;

function TIBTable.InternalGotoDBKey(DBKey: TIBDBKey): Boolean;

  function DBKeyCompare (DBKey1, DBKey2: TIBDBKey): Boolean;
  var
  I: Integer;
  begin
    for I := 0 to 7 do
      if (DBKey1.DBKey[i] <> DBKey2.DBKey[i]) then begin
        result := False;
        exit;
      end;
    result := True;
  end;
begin
  CheckActive;
  DisableControls;
 try
    result := False;
    First;
    while ((not result) and (not EOF)) do begin
      if (DBKeyCompare (DBKey, PRecordData(GetActiveBuf)^.rdDBKey)) then
        result := True
      else
        Next;
    end;
    if not result then
      First
    else
      CursorPosChanged;
  finally
    EnableControls;
  end;
end;

function TIBTable.GetCurrentDBKey: TIBDBKey;
var
  Buf: pChar;
begin
  CheckActive;
  buf := GetActiveBuf;
  if Buf <> nil then
    Result := PRecordData(Buf)^.rdDBKey
  else
    Result.DBKey[0] := 0;
end;

procedure TIBTable.Reopen;
begin
  DisableControls;
  try
    if Active then
    begin
      SetState(dsInactive);
      CloseCursor;
      OpenCursor;
      SetState(dsBrowse);
    end;
  finally
    EnableControls;
  end;
end;

{ TIBTable IProviderSupport }

function TIBTable.PSGetDefaultOrder: TIndexDef;

  function GetIdx(IdxType: TIndexOption): TIndexDef;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to IndexDefs.Count - 1 do
      if IdxType in IndexDefs[i].Options then
      try
        Result := IndexDefs[i];
        GetFieldList(nil, Result.Fields);
        break;
      except
        Result := nil;
      end;
  end;

var
  DefIdx: TIndexDef;
begin
  DefIdx := nil;
  IndexDefs.Update;
  try
    if IndexName <> '' then
      DefIdx := IndexDefs.Find(IndexName)
    else if IndexFieldNames <> '' then
      DefIdx := IndexDefs.FindIndexForFields(IndexFieldNames);
    if Assigned(DefIdx) then
      GetFieldList(nil, DefIdx.Fields);
  except
    DefIdx := nil;
  end;
  if not Assigned(DefIdx) then
    DefIdx := GetIdx(ixPrimary);
  if not Assigned(DefIdx) then
    DefIdx := GetIdx(ixUnique);
  if Assigned(DefIdx) then
  begin
    Result := TIndexDef.Create(nil);
    Result.Assign(DefIdx);
  end else
    Result := nil;
end;

function TIBTable.PSGetIndexDefs(IndexTypes: TIndexOptions): TIndexDefs;
begin
  Result := GetIndexDefs(IndexDefs, IndexTypes);
end;

function TIBTable.PSGeTTableName: string;
begin
  Result := FTableName;
end;

procedure TIBTable.PSSetParams(AParams: TParams);
begin
  if AParams.Count > 0 then
    Open;
  PSReset;
end;

procedure TIBTable.PSSetCommandText(const CommandText: string);
begin
  if CommandText <> '' then   {do not localize}
    TableName := CommandText;
end;

function TIBTable.PSGetKeyFields: string;
var
  i, Idx: Integer;
  IndexFound: Boolean;
begin
  Result := inherited PSGetKeyFields;
  if Result = '' then
  begin
    if not Exists then Exit;
    IndexFound := False;
    IndexDefs.Update;
    FieldDefs.Update;
    for i := 0 to IndexDefs.Count - 1 do
      if ixUnique in IndexDefs[I].Options then
      begin
        Idx := 1;
        Result := IndexDefs[I].Fields;
        IndexFound := False;
        while Idx <= Length(Result) do
        begin
          IndexFound := FindField(ExtractFieldName(Result, Idx)) <> nil;
          if not IndexFound then Break;
        end;
        if IndexFound then Break;
      end;
    if not IndexFound then
      Result := '';
  end;
end;

function TIBTable.InternalLocate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  IsGood : TIBSQL;
  fl: TList;
  i, fld_cnt : Integer;
  fString, pString, eString : String;
  val : Array of Variant;
begin
  IsGood := TIBSQL.Create(Database);
  IsGood.Transaction := Transaction;
  IsGood.SQL.Text := 'select '  {do not localize}
    + 'RDB$DB_KEY as IBX_INTERNAL_DBKEY from ' {do not localize}
    + QuoteIdentifier(DataBase.SQLDialect, FTableName);
  fl := TList.Create;
  try
    GetFieldList(fl, KeyFields);
    fld_cnt := fl.Count;
    SetLength(val, fld_cnt);
    for i := 0 to fld_cnt - 1 do
      if VarIsArray(KeyValues) then
        val[i] := KeyValues[i]
      else
        val[i] := KeyValues;
    if loCaseInsensitive in Options then
    begin
      fString := 'UPPER(%:0s)';    {do not localize}
      pString := 'UPPER(:%:0s) ';   {do not localize}
    end
    else
    begin
      fString := '%:0s';     {do not localize}
      pString := ':%:0s ';   {do not localize}
    end;
    if loPartialKey in Options then
      eString := ' starting with '   {do not localize}
    else
      eString := ' = ';   {do not localize}
    for i := 0 to fld_cnt - 1 do
    begin
      if i > 0 then
      begin
        if VarIsNull(val[i]) then
          isGood.SQL.Add(Format(' and %s is null ',  {do not localize}
            [QuoteIdentifier(DataBase.SQLDialect, TField(fl[i]).FieldName)]))
        else
          isGood.SQL.Add(Format(' and ' + fString + eString + pString,   {do not localize}
            [ QuoteIdentifier(DataBase.SQLDialect, TField(fl[i]).FieldName)]));
      end
      else
      begin
        if VarIsNull(val[i]) then
          isGood.SQL.Add(Format(' Where %s is null ',    {do not localize}
            [QuoteIdentifier(DataBase.SQLDialect, TField(fl[i]).FieldName)]))
        else
          isGood.SQL.Add(Format(' Where ' + fString + eString + pString,  {do not localize }
            [ QuoteIdentifier(DataBase.SQLDialect, TField(fl[i]).FieldName)]));
      end;
    end;
    for i := 0 to fld_cnt - 1 do
      if not VarIsNull(val[i]) then
        isGood.Params.ByName(TField(fl[i]).FieldName).Value := val[i];
    IsGood.ExecQuery;
    if IsGood.Eof then
      Result := false
    else
      Result := inherited Locate(KeyFields, KeyValues, Options);
  finally
    IsGood.Free;
    fl.Free;
    val := nil;
  end;
end;

function TIBTable.Locate(const KeyFields: string; const KeyValues: Variant;
                                 Options: TLocateOptions): Boolean;
var
  CurBookmark: string;
begin
  DisableControls;
  try
    CurBookmark := Bookmark;
    First;
    result := InternalLocate(KeyFields, KeyValues, Options);
    if not result then
      Bookmark := CurBookmark;
  finally
    EnableControls;
  end;
end;

end.
