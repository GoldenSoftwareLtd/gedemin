
{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

    flt_sqlFilter.pas

  Abstract

    Gedemin project. TgsQueryFilter components.

  Author

    Andrey Shadevsky

  Revisions history

    It was created in the summer begining.
    1.00    30.09.00    JKL        Initial version.
    2.00    09.11.00    JKL        Rebuild structure
    2.01    12.12.00    JKL        Add ActionList for Menu
    3.00    07.05.01    JKL        Final version. Search 'gs' in code.
    3.01    29.10.01    JKL        Entered params and script params is added.
    3.02    26.11.01    JKL        Domain condition processing for params is added.
    3.03    02.03.02    JKL        Distinct and other was added.
    3.04    18.03.02    JKL        Original order is dropped. Dlg window for long query (try finally).

--}

unit flt_sqlFilter;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  IBQuery,            IBDatabase,         flt_dlgShowFilter_unit,
  flt_sqlfilter_condition_type,           IBSQL,              IBCustomDataSet,
  DB,                 Menus,              flt_sql_parser,     gd_security,
  IBTable,            flt_msgShowMessage_unit, ActnList;

const
  UnknownDataSet = '����������� TIBCustomDataSet';
  // ������ ��������������
  FQueryAlias = '/* ����� ������� ��������� ����������� ���������� */';
  // ����� ���������� �������, ����� �������� ���������� ���� ��������� (~10 sec)
  FMaxExecutionTime = 0.0001;
  // ���� ��������� ������������ �������� ����� � ������� flt_componentfilter
  // �� ����� �������� ���������� ��� ��������� ��� ��������� ����� ����������
  FIndexFieldLength = 20;

// ��� ��������� � ��������� �����
type
  TIBCustomDataSetCracker = class(TIBCustomDataSet);

// ��������� ��� ������ ����������� ���� � ������� �����
// �������� ������� ����������
type
  TgsSQLFilter = class(TComponent)
  private
    FBase: TIBBase;

    FComponentKey: Integer;     // �������� ���� ���������� ����������
    FIsCompKey: Boolean;        // ��������� ������ ���� ��� ���
    FOwnerName: String;         // �������� ��� ��������. � ��������� �� ��� ���������, � ������������ ����.

    FFilterData: TFilterData;   // ��������� ��� �������� ������ �������� �������

    FNoVisibleList: TStrings;    // ������ ����� �� ������� �� ���� �������� �������
    FTableList: TfltStringList;  // ������������ ������� �� ������� ������������ �������
    FLinkCondition: TfltStringList; // ������ ������. ��� ����������� ������������ ������.

    FQueryText: TStrings;    // ������ ����� ��������������� �������

    FSelectText: TStrings;   // ��������� ����� ������������ �����
    FFromText: TStrings;     // ��������� ����� ������
    FWhereText: TStrings;    // ��������� ����� �������
    FOtherText: TStrings;    // ����� ����������� ����� WHERE � ORDER BY
    FOrderText: TStrings;    // ��������� ����� ����������

    FFilterName: String;        // ������������ �������
    FFilterComment: String;     // ����������� �������
    FLastExecutionTime: TTime;  // ����� ���������� ����������
    FDeltaReadCount: Integer;   // ��������� ��������� ��������� � �������
    FCurrentFilter: Integer;    // ������� ������
    FIsSQLTextChanged: Boolean; // ��������� ��� �� ������� ��������� ������ �������

    FOnConditionChanged: TConditionChanged;     // ������� �� ��������� �������
    FOnFilterChanged: TFilterChanged;           // ������� �� ��������� ���������� �������

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetTransaction(Value: TIBTransaction);

    procedure SetNoVisibleList(Value: TStrings);
    procedure SetTableList(Value: TfltStringList);

    function GetConditionCount: Integer;
    function GetOrderByCount: Integer;
    // ���������� ����� �������
    function GetFilterString: String;

    function GetCondition(const AnIndex: Integer): TFilterCondition;
    procedure SetCondition(const AnIndex: Integer; const AnFilterCondition: TFilterCondition);

    function GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
    procedure SetOrderBy(const AnIndex: Integer; const AnFilterOrderBy: TFilterOrderBy);

    // �������� ������������ ���������� ���������� �� FIndexFieldLength
    function GetApplicationName: String;

  protected
    FFilterBody: TdlgShowFilter;// ���������� ���� ��� ��������� ���������� �������. ��������� �����.

    // ��������� ����� � ������������ ���������� ���������� �������� �������
    procedure SaveFilter;
    // ��������� ������ �� ��� �����
    function LoadFilter(const AnFilterKey: Integer): Boolean;
    // �������� ���� ����������
    procedure ExtractComponentKey;

    // ������� ������� ����� ������� �� ��������
    function CreateSQLText(AFilterData: TFilterData): Boolean;

    // ��� ���� ��������� ������ � ����������. ��� ���� ��������.
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    //function ShowDialog: Boolean;

    // ������������ ������ ��� ��������� �������
    procedure SetQueryText(const AnSQLText: String);

    function CreateSQL: Boolean;
    // ������� ����� ������
    function AddFilter(out AnFilterKey: Integer): Boolean;
    // ����������� ������������ ������
    function EditFilter(out AnFilterKey: Integer): Boolean;
    // ������� ������������ ������
    function DeleteFilter: Boolean;

    // �������� ������� ����������
    function AddCondition(AFilterCondition: TFilterCondition): Integer;
    // ������� ������� ����������
    procedure DeleteCondition(const AnIndex: Integer);
    // �������� ������ ������� ����������
    procedure ClearConditions;

    // �������� ������� ����������
    function AddOrderBy(AnOrderBy: TFilterOrderBy): Integer;
    // ������� ������� ����������
    procedure DeleteOrderBy(const AnIndex: Integer);
    // �������� ������ ������� ����������
    procedure ClearOrdersBy;

    procedure ReadFromStream(S: TStream);
    procedure WriteToStream(S: TStream);

    property SelectText: TStrings read FSelectText;   // ��������� ����� ������������ �����
    property FromText: TStrings read FFromText;     // ��������� ����� ������
    property WhereText: TStrings read FWhereText;    // ��������� ����� �������
    property OtherText: TStrings read FOtherText;    // ��������� ����� �������
    property OrderText: TStrings read FOrderText;    // ��������� ����� ����������

    property FilteredSQL: TStrings read FQueryText;    // ����� ������� � ����������� ���������

    property FilterName: String read FFilterName;       // ������������ �������� �������
    property FilterComment: String read FFilterComment; // ����������� �������� �������
    property LastExecutionTime: TTime read FLastExecutionTime;  // ��������� ����� ���������� ���. �������
    property CurrentFilter: Integer read FCurrentFilter;// ���� �������� �������
    property FilterString: String read GetFilterString; // ����� ������� �������� �������

    property ConditionCount: Integer read GetConditionCount;    // ���������� ������� ����������
    property Conditions[const AnIndex: Integer]: TFilterCondition read GetCondition write SetCondition;

    property OrderByCount: Integer read GetOrderByCount;        // ���������� ������� ����������
    property OrdersBy[const AnIndex: Integer]: TFilterOrderBy read GetOrderBy write SetOrderBy;

    // ������ ������ ��������� �� �������
    property TableList: TfltStringList read FTableList write SetTableList;
    property FilterData: TFilterData read FFilterData;

  published
    property OnConditionChanged: TConditionChanged read FOnConditionChanged write FOnConditionChanged;
    property OnFilterChanged: TFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property NoVisibleList: TStrings read FNoVisibleList write SetNoVisibleList;
  end;

type
  TgsQueryFilter = class(TgsSQLFilter)
  private
    FIBDataSet: TIBCustomDataSet;         // ��������� � ������� ����� �������� ����� �������
    FPopupMenu: TPopupMenu;               // ��������� ���� ��� ���������� ��������
    FOldBeforeOpen: TDataSetNotifyEvent;        // ������ ������ ������� ����� ���������
    FOldBeforeDatabaseDisconect: TNotifyEvent;  // ������ ������ ������� ����� Disconect
    FOldShortCut: TShortCutEvent;
    FMessageDialog: TmsgShowMessage;    // ������ ���������

    FActionList: TActionList;

    FShowBeforeFilter: Boolean; // ���� ������ �������������� ����� ����������� �������� �������
    //FParamItemIndex: Integer;
    FRecordCount: Integer;      // ���������� ������� � �������

    FIsFirstOpen: Boolean;      // ���� ������� ��������. ��� ��������� �������� � ������ ������� ��������
    FIsSQLChanging: Boolean;      // ??? ��������� ������������� ������� ���������
    FIsLastSave: Boolean;       // ���� ��� �� �������� ��������� ������

    procedure SetQuery(Value: TIBCustomDataSet);

    procedure SelfBeforeDisconectDatabase(Sender: TObject);
    procedure SelfBeforeOpen(DataSet: TDataSet);
    procedure SelfOnShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure SeparateQuery;

    procedure DoOnCreateFilter(Sender: TObject);// ������� ���������� �� ���� �� �������� ������ �������
    procedure DoOnEditFilter(Sender: TObject);  // ������� ... �� ��������������
    procedure DoOnDeleteFilter(Sender: TObject);// ������� ... �� ��������

    procedure DoOnFilterBack(Sender: TObject);  // ������� ... �� ������
    procedure DoOnSelectFilter(Sender: TObject);// ������� ... �� ������ ������������ �������
    procedure DoOnViewFilterList(Sender: TObject);// ������� ... �� ��������� ������ ��������
    procedure DoOnRecordCount(Sender: TObject); // ������� ... �� ������ ���������� ������� � �������
    procedure DoOnRefresh(Sender: TObject); //  ������� ... �� ���������� ����������

    // ��������� �������� ����
    procedure MakePopupMenu(AnPopupMenu: TMenu);
    procedure CreateActions;

    // ��������� ����� ������������
    function GetUserKey: String;
    function GetISUserKey: String;

    // ����������� ��������������
    procedure ShowWarning;

    // ��������� ���������� �������
    function GetRecordCount: Integer;

    // ������� ����������� �������� ���� ���������� AnEnabled
    procedure SetEnabled(const AnEnabled: Boolean);

    function IsIBQuery: Boolean;
    function GetOwnerName: String;

  protected
    procedure DoOnWriteToFile(Sender: TObject);
    procedure DoOnReadFromFile(Sender: TObject);

    function GetDBVersion: String;      // �������� ������ ���� ������
    function GetCRC: Integer;           // �������� CRC �������
    // ���������� ������ ��������
    function CompareVersion(const OldCRC: Integer; const DBVersion: String; const Question: Boolean): Boolean;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property RecordCount: Integer read GetRecordCount;

    procedure FilterQuery;      // ������������� �������
    procedure RevertQuery;      // �������� �������

    procedure CreatePopupMenu;  // ������� ����

    procedure SaveLastFilter;   // ��������� ��������� ������
    procedure LoadLastFilter;   // ��������� ��������� ������

    procedure PopupMenu(const X: Integer = -1; const Y: Integer = -1);

    //function ShowDialogAndQuery: Boolean;
  published
    // ���������� ���� ������
    property Database;
    // ������ ��������� �����
    property NoVisibleList;
    // ���������� TIBQuery
    property IBDataSet: TIBCustomDataSet read FIBDataSet write SetQuery;
    // ������� �� ��������� �������
    property OnConditionChanged;
    // ������� �� ��������� ���. �������
    property OnFilterChanged;
  end;

type
  TCrackerFilterCondition = class(TFilterCondition);

procedure Register;

implementation

uses
   gd_directories_const, flt_msgBeforeFilter_unit, Registry,
   flt_dlgFilterList_unit, jclMath, gd_SetDatabase, flt_ScriptInterface;

{TgsSQLFilter}

constructor TgsSQLFilter.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FBase := TIBBase.Create(nil);

  FNoVisibleList := TStringList.Create;
  FTableList := TfltStringList.Create;

  if not (csDesigning in ComponentState) then
  begin
    Transaction := TIBTransaction.Create(Self);
    Transaction.Params.Clear;
    Transaction.Params.Add('read_committed');
    Transaction.Params.Add('rec_version');
    Transaction.Params.Add('nowait');
    Transaction.DefaultDatabase := Database;

    FFilterBody := TdlgShowFilter.Create(Self);
    FFilterData := TFilterData.Create;

    FLinkCondition := TfltStringList.Create;

    FQueryText := TStringList.Create;

    FSelectText := TStringList.Create;
    FFromText := TStringList.Create;
    FWhereText := TStringList.Create;
    FOtherText := TStringList.Create;
    FOrderText := TStringList.Create;
  end;
end;

destructor TgsSQLFilter.Destroy;
begin
  FreeAndNil(FTableList);
  FreeAndNil(FNoVisibleList);

  if not (csDesigning in ComponentState) then
  begin
    FFilterData.Free;
    FFilterBody.Free;
    FLinkCondition.Free;

    FQueryText.Free;

    FSelectText.Free;
    FFromText.Free;
    FWhereText.Free;
    FOtherText.Free;
    FOrderText.Free;
    if Transaction <> nil then
    begin
      Transaction.Free;
      Transaction := nil;
    end;
  end;

  FreeAndNil(FBase);

  inherited Destroy;
end;

procedure TgsSQLFilter.SetTableList(Value: TfltStringList);
begin
  FTableList.Assign(Value);
end;

procedure TgsSQLFilter.SetNoVisibleList(Value: TStrings);
begin
  FNoVisibleList.Assign(Value);
end;

function TgsSQLFilter.GetDatabase: TIBDatabase;
begin
  if FBase <> nil then
    result := FBase.Database
  else
    result := nil;
end;

function TgsSQLFilter.GetTransaction: TIBTransaction;
begin
  Result := FBase.Transaction;
end;

procedure TgsSQLFilter.SetDatabase(Value: TIBDatabase);
begin
  if FBase.Database <> Value then
  begin
    FBase.Database := Value;
    if Transaction <> nil then
      Transaction.DefaultDatabase := Value;
  end;
end;

procedure TgsSQLFilter.SetTransaction(Value: TIBTransaction);
begin
  if (FBase.Transaction <> Value) then
  begin
    FBase.Transaction := Value;
  end;
end;

function TgsSQLFilter.AddFilter(out AnFilterKey: Integer): Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // ������ ����������� ���������
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // ��������� ���� ����������
  ExtractComponentKey;
  // �������� ����� �������� ������ �������
  AnFilterKey := FFilterBody.AddFilter(FComponentKey, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged, Result);
  // ������������� ����, ��� ������ ������ �� ���
  FIsSQLTextChanged := True;
  // ���������� �������
  if (AnFilterKey <> 0) and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // ��������� ����������
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

function TgsSQLFilter.EditFilter(out AnFilterKey: Integer): Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // ����������� ���������
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // ��������� ���� ����������
  ExtractComponentKey;
  // �������� ����� ��������������
  AnFilterKey := FFilterBody.EditFilter(FCurrentFilter, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged, Result);
  // ������������� ����, ��� ������ ������ �� ���
  FIsSQLTextChanged := True;
  // ���������� �������
  if (AnFilterKey <> 0) and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // ��������� ����������
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

function TgsSQLFilter.DeleteFilter: Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  // ����������� ���������
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  // ��������� ���� ����������
  ExtractComponentKey;
  // �������� ����� ��������
  Result := FFilterBody.DeleteFilter(FCurrentFilter);
  // ���������� �������
  if Result and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  // ��������� ����������
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end;

(*function TgsSQLFilter.ShowDialog: Boolean;
begin
  if not Transaction.InTransaction then
    Transaction.StartTransaction;
  FFilterBody.Database := Database;
  FFilterBody.Transaction := Transaction;
  ExtractComponentKey;
  Result := False;
{  Result := FFilterBody.AddFilter(FComponentKey, FSelectText.Text + FFromText.Text +
   FWhereText.Text + FOtherText.Text + FOrderText.Text, FNoVisibleList, FIsSQLTextChanged) <> 0;
{  Result := FFilterBody.ShowFilter(FFilterData.ConditionList, FFilterData.OrderByList,
   FNoVisibleList, FTableList, FLinkCondition, True, FIsSQLTextChanged);}
  FIsSQLTextChanged := True;
  if Result and Assigned(FOnConditionChanged) then
    FOnConditionChanged(Self);
  if Transaction.InTransaction then
    Transaction.CommitRetaining;
end; *)

// ��������� ��������� �������� �������
procedure TgsSQLFilter.SaveFilter;
var
  TempSQL: TIBQuery;
begin
  if FCurrentFilter = 0 then
    Exit;
  TempSQL := TIBQuery.Create(Self);
  try
    // ����������� ���������
    TempSQL.Database := Database;
    TempSQL.Transaction := Transaction;
    // ������ �������
    TempSQL.SQL.Text := 'UPDATE flt_savedfilter SET lastextime = :lasttime, readcount = readcount + :deltaread WHERE id  = ' + IntToStr(FCurrentFilter);
    TempSQL.ParamByName('lasttime').AsDateTime := FLastExecutionTime;
    TempSQL.ParamByName('deltaread').AsInteger := FDeltaReadCount;
    try
      // �������� ����������
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      // �������� ���������
      TempSQL.ExecSQL;
    except
      // ��������� ������
      on E: Exception do
        MessageBox(0, @E.Message[1], '��������', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
    // ��������� ����������
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    TempSQL.Free;
  end;
end;

// �������� �������
function TgsSQLFilter.LoadFilter(const AnFilterKey: Integer): Boolean;
var
  TempSQL: TIBQuery;
  BlobStream: TIBDSBlobStream;
begin
  Result := True;
  TempSQL := TIBQuery.Create(Self);
  try
    FFilterData.Clear;
    // ����������� ���������
    TempSQL.Database := Database;
    TempSQL.Transaction := Transaction;
    // ����� �������
    TempSQL.SQL.Text := 'SELECT id, name, description, lastextime, data FROM flt_savedfilter WHERE id = :ID';
    TempSQL.ParamByName('id').AsInteger := AnFilterKey;
    try
      // �������� ����������
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      // �������� ��������� ������
      TempSQL.Open;
      // ���� ������
      if not TempSQL.Eof then
      begin
        // ��������� ��������� �������
        FCurrentFilter := TempSQL.FieldByName('id').AsInteger;
        FFilterName := TempSQL.FieldByName('name').AsString;
        FFilterComment := TempSQL.FieldByName('description').AsString;
        FLastExecutionTime := TempSQL.FieldByName('lastextime').AsDateTime;
        FDeltaReadCount := 0;

        BlobStream := TempSQL.CreateBlobStream(TempSQL.FieldByName('data'), bmRead) as TIBDSBlobStream;
        try
          FFilterData.ReadFromStream(BlobStream);
        finally
          BlobStream.Free;
        end;
        if Assigned(FOnFilterChanged) then
          FOnFilterChanged(Self, FCurrentFilter);
      end else
      begin
        Result := False;
        raise Exception.Create('��������� ������ �� ������');
      end;
    except
      // ������������ ������
      on E: Exception do
        MessageBox(0, @E.Message[1], '��������', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
    // ��������� ����������
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    TempSQL.Free;
  end;
end;

function TgsSQLFilter.GetConditionCount: Integer;
begin
  Result := FFilterData.ConditionList.Count;
end;

function TgsSQLFilter.GetOrderByCount: Integer;
begin
  Result := FFilterData.OrderByList.Count;
end;

function TgsSQLFilter.GetFilterString: String;
begin
  Result := FFilterData.FilterText + FFilterData.OrderText;
end;

function TgsSQLFilter.GetCondition(const AnIndex: Integer): TFilterCondition;
begin
  Result := FFilterData.ConditionList.Conditions[AnIndex];
end;

procedure TgsSQLFilter.SetCondition(const AnIndex: Integer; const AnFilterCondition: TFilterCondition);
begin
  if AnFilterCondition <> nil then
    FFilterData.ConditionList.Conditions[AnIndex].Assign(AnFilterCondition);
end;

function TgsSQLFilter.GetOrderBy(const AnIndex: Integer): TFilterOrderBy;
begin
  Result := FFilterData.OrderByList.OrdersBy[AnIndex];
end;

procedure TgsSQLFilter.SetOrderBy(const AnIndex: Integer; const AnFilterOrderBy: TFilterOrderBy);
begin
  if AnFilterOrderBy <> nil then
    FFilterData.OrderByList.OrdersBy[AnIndex].Assign(AnFilterOrderBy);
end;

function TgsSQLFilter.CreateSQL: Boolean;
begin
  Result := CreateSQLText(FFilterData);
end;

// ������� ��������� SQL
function TgsSQLFilter.CreateSQLText(AFilterData: TFilterData): Boolean;
const
  PrefixTbl = ' tbl';
  Sand = ' AND ';
  Sor = ' OR  ';

var
  SelectStr, FromStr, WhereStr, OrderStr, PrefixList: TStrings;
  I: Integer;
  TblN: Integer;
  S, UserSQLText: String;
  IsUserQuery, EnterResult: Boolean;

  // ���������� ������� ������� �� �� ������������
  // ��� ���� ������� ������� ������
  function FindTable(const TableName: String; const FlagAll: Boolean): String;
  begin
    // ����� ������������ �������
    Result := PrefixList.Values[TableName];
    if FlagAll and (Result = '') then
      Result := FTableList.Values[TableName];
    // ���� �� �������, ��������� �����
    if (Result = '') then
    begin
      Result := PrefixTbl + IntToStr(TblN);
      FromStr.Add(', ' + TableName + ' ' + Result);
      Result := Result + '.';
      PrefixList.Add(TableName + '=' + Result);
      Inc(TblN);
    end;
  end;

  function GetNextPrefix: String;
  begin
    Result := PrefixTbl + IntToStr(TblN);
    Inc(TblN);
  end;

  // ���������� ������� ������� �� �� ������������
  // ������ ����������� �������
  function AddTable(const TableName: String): String;
  begin
    Result := PrefixTbl + IntToStr(TblN);
    FromStr.Add(', ' + TableName + ' ' + Result);
    Result := Result + '.';
    PrefixList.Add(TableName + '=' + Result);
    Inc(TblN);
  end;

  function FindTableAll(const TableName: String): String;
  begin
    Result := FindTable(TableName, True);
  end;

  function FindTableOut(const TableName: String): String;
  begin
    Result := FindTable(TableName, False);
  end;

  function ReplaceOldSign(const AnSourceStr, AnInsStr: String): String;
  begin
    Result := Copy(AnSourceStr, 1, Length(AnSourceStr) - 5) + AnInsStr;
  end;

  // ������� ����� ������� ��� �������
  function AddSQLCondition(AnConditionData: TFilterCondition; AnPrefixName: String;
   const AnUnknownSet, AnMergeCondition: Boolean): Boolean;
  var
    J: Integer;
    CurN, NetN: String;
    FieldName: String;
    FieldType: Integer;
    FValue1, FValue2, Sign1, Sign2, SimpleField, FScriptSign: String;
    MergeSign: String[10];
    VarToPnt: Integer;

    procedure DoActuates(const AnConfluenceSign: String);
    begin
      case FieldType of
        GD_DT_REF_SET_ELEMENT, GD_DT_ATTR_SET_ELEMENT:
          // ��������� �������
          WhereStr.Add('(' + AnPrefixName + FieldName + AnConfluenceSign + S + ')' + MergeSign);
        GD_DT_REF_SET, GD_DT_CHILD_SET:
        begin
          // ������� ������� �������
          NetN := AddTable(AnConditionData.FieldData.LinkTable);
          // ��������� �������
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + NetN
           + AnConditionData.FieldData.LinkSourceField + Sand);
          WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + AnConfluenceSign
           + S + ')' + MergeSign);
        end;
        GD_DT_ATTR_SET:
        begin
          // ������� ������� �������
          NetN := AddTable('GD_ATTRVALUE');
          // ��������� �������
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + NetN + 'id' + Sand);
          WhereStr.Add(NetN + 'attrrefkey = '
           + IntToStr(AnConditionData.FieldData.AttrRefKey) + Sand);
          WhereStr.Add(NetN + 'attrsetkey ' + AnConfluenceSign + S + ')' + MergeSign);
        end;
      end;
    end;

    procedure DoIncludes;
    var
      L: Integer;
    begin
      case FieldType of
        GD_DT_REF_SET, GD_DT_CHILD_SET:
        begin
        // ��� ������� ����������� �������� ��������� ������� ����� ���������
        // �������. ������� �� ���������� FindTable
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Add('(');
          for L := 0 to AnConditionData.ValueList.Count - 1 do
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
            WhereStr.Add(AnPrefixName + FieldName + ' = '
             + NetN + AnConditionData.FieldData.LinkSourceField + Sand);
            WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' = '
             + IntToStr(Integer(AnConditionData.ValueList.Objects[L])) + Sand);
          end;
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Strings[WhereStr.Count - 1] :=
             ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
        end;

        GD_DT_ATTR_SET:
        begin
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Add('(');
          for L := 0 to AnConditionData.ValueList.Count - 1 do
          begin
            // ������� ������� �������
            NetN := AddTable('GD_ATTRVALUE');
            // ��������� �������
            WhereStr.Add(AnPrefixName + FieldName + ' = ' + NetN + 'id' + Sand);
            WhereStr.Add(NetN + 'attrrefkey = '
             + IntToStr(AnConditionData.FieldData.AttrRefKey) + Sand);
            WhereStr.Add(NetN + 'attrsetkey = '
             + IntToStr(Integer(AnConditionData.ValueList.Objects[L])) + Sand);
          end;
          if AnConditionData.ValueList.Count > 0 then
            WhereStr.Strings[WhereStr.Count - 1] :=
             ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
        end;
      end;
    end;
  begin
    if AnMergeCondition then
      MergeSign := Sand
    else
      MergeSign := Sor;

    // �������� �������� �� ��� ''�������������� ����������''
    if (AnConditionData.FieldData.FieldType = GD_DT_UNKNOWN_SET) and AnUnknownSet then
    begin
      //CurN := FindTableAll(AnConditionData.FieldData.LinkTable);
      CurN := AddTable(AnConditionData.FieldData.LinkTable);
      WhereStr.Add('(' + AnConditionData.FieldData.TableAlias + AnConditionData.FieldData.FieldName + ' = '
       + CurN + AnConditionData.FieldData.LinkSourceField + Sand);
      AddSQLCondition(AnConditionData, CurN, False, AnMergeCondition);
      WhereStr.Strings[WhereStr.Count - 1] :=
       ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')' + MergeSign);
      Result := True;

      Exit;
    end;

    // ��� ���� ������� ��� ����������� ���� ''�������������� ���������''
    {gs} // ����� ������� �������
    if AnUnknownSet then
    begin
      FieldName := AnConditionData.FieldData.FieldName;
      FieldType := AnConditionData.FieldData.FieldType;
    end else
    begin
      FieldName := AnConditionData.FieldData.LinkTargetField;
      FieldType := AnConditionData.FieldData.LinkTargetFieldType;
    end;

    case AnConditionData.ConditionType of
    GD_FC_SCRIPT:
      begin
        if FilterScript = nil then
          raise Exception.Create('��������� FilterScript �� ������.');
        FValue1 := FilterScript.GetScriptResult(AnConditionData.Value1, AnConditionData.Value2, FScriptSign);
        FValue2 := '';
      end;
    GD_FC_ENTER_PARAM:
      case FieldType of
        GD_DT_REF_SET_ELEMENT, GD_DT_REF_SET, GD_DT_CHILD_SET,
        GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:;
      else
        FValue1 := AnsiUpperCase(TCrackerFilterCondition(AnConditionData).FTempVariant);
        FValue2 := '';
        FScriptSign := AnConditionData.Value2;
        // ������ LIKE �� CONTAINING
        if (UpperCase(FScriptSign) = 'LIKE') then
          FScriptSign := 'CONTAINING';
        if (UpperCase(FScriptSign) = 'NOT LIKE') then
          FScriptSign := 'NOT CONTAINING';
      end;
    else
      FValue1 := AnConditionData.Value1;
      FValue2 := AnConditionData.Value2;
    end;
    // � ����������� �� ���� ������ �������������� ��������
    // ��� ������� ����� ���-�� ���������� ���������
    case FieldType of
      GD_DT_DIGITAL, GD_DT_BOOLEAN:
      begin
        // ������ �����������
        if FValue1 > '' then
          FValue1 := FValue1;
        if FValue2 > '' then
          FValue2 := FValue2;
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_CHAR:
      begin
        // ������� ���������
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        // ������� �������������
        SimpleField := 'UPPER(' + AnPrefixName + FieldName + ')';
      end;
      GD_DT_BLOB_TEXT:
      begin
        // ������� ���������
        FValue1 := '''' + FValue1 + '''';
        FValue2 := '''' + FValue2 + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
      GD_DT_DATE:
      begin
        // ��������� � ������ � ���������
        if (AnConditionData.ConditionType <> GD_FC_LAST_N_DAYS)
         and (AnConditionData.ConditionType <> GD_FC_TODAY) then
        begin
          if FValue1 > '' then
            FValue1 := '''' + IBDateTimeToStr(StrToDateTime(FValue1)) + '''';
          if FValue2 > '' then
            FValue2 := '''' + IBDateTimeToStr(StrToDateTime(FValue2)) + '''';
          SimpleField := AnPrefixName + FieldName;
        end;
      end;
      GD_DT_TIME:
      begin
        // ��������� � ������ � ���������
        if FValue1 > '' then
          FValue1 := '''' + IBTimeToStr(StrToTime(FValue1)) + '''';
        if FValue2 > '' then
          FValue2 := '''' + IBTimeToStr(StrToTime(FValue2)) + '''';
        SimpleField := AnPrefixName + FieldName;
      end;
    end;

    // ���������������� ��������� �������
    case AnConditionData.ConditionType of
      GD_FC_SCRIPT:
        case FieldType of
          GD_DT_REF_SET_ELEMENT,
          GD_DT_REF_SET, GD_DT_CHILD_SET:
          begin
            S := '(' + FValue1 + ')';
            DoActuates(FScriptSign);
          end;
          GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
            raise Exception.Create('GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT not supported yet.');
        else
          WhereStr.Add('(' + SimpleField + FScriptSign + FValue1 + ')' + MergeSign);
        end;

      GD_FC_ENTER_PARAM:
        case FieldType of
          GD_DT_REF_SET_ELEMENT,
          GD_DT_REF_SET, GD_DT_CHILD_SET:
          begin
            if not VarIsArray(TCrackerFilterCondition(AnConditionData).FTempVariant) or
             ((VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) -
             VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1)) < 0) then
            begin
              Result := True;
              Exit;
            end;

            if (AnsiUpperCase(AnConditionData.Value2) = GD_FC2_INCLUDE_ALIAS) then
            begin
              AnConditionData.ValueList.Clear;
              for J := VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) to
               VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) do
              begin
                VarToPnt := VarAsType(TCrackerFilterCondition(AnConditionData).FTempVariant[J], varInteger);
                AnConditionData.ValueList.AddObject('', Pointer(VarToPnt));
              end;
              DoIncludes;
            end else
            begin
              S := '(';
              for J := VarArrayLowBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) to
               VarArrayHighBound(TCrackerFilterCondition(AnConditionData).FTempVariant, 1) do
                S := S + VarAsType(TCrackerFilterCondition(AnConditionData).FTempVariant[J], varString) + ',';
              S[Length(S)] := ')';
              DoActuates(' ' + AnConditionData.Value2 + ' ');
            end;
          end;
          GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT:
            raise Exception.Create('GD_DT_ATTR_SET, GD_DT_ATTR_SET_ELEMENT not supported yet.');
        else
          WhereStr.Add('(' + SimpleField + FScriptSign + FValue1 + ')' + MergeSign);
        end;

      // ��� ����� ���������
      GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_GREATER_OR_EQUAL_TO,
      GD_FC_LESS_THAN, GD_FC_LESS_OR_EQUAL_TO, GD_FC_NOT_EQUAL_TO, {GD_FC_CONTAINS,}
      GD_FC_DOESNT_CONTAIN:
      begin
        case AnConditionData.ConditionType of
          GD_FC_EQUAL_TO:
            Sign1 := ' = ';
          GD_FC_GREATER_THAN:
            Sign1 := ' > ';
          GD_FC_GREATER_OR_EQUAL_TO:
            Sign1 := ' >= ';
          GD_FC_LESS_THAN:
            Sign1 := ' < ';
          GD_FC_LESS_OR_EQUAL_TO:
            Sign1 := ' <= ';
          GD_FC_NOT_EQUAL_TO:
            Sign1 := ' <> ';
          {GD_FC_CONTAINS:
            Sign1 := ' CONTAINING ';}
          GD_FC_DOESNT_CONTAIN:
            Sign1 := ' NOT CONTAINING ';
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + ')' + MergeSign);
      end;
      // ������� �����
      GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT:
      begin
        case AnConditionData.ConditionType of
          GD_FC_BETWEEN:
          begin
            Sign1 := ' >= ';
            Sign2 := ' <= ';
          end;
          GD_FC_BETWEEN_LIMIT:
          begin
            Sign1 := ' > ';
            Sign2 := ' < ';
          end;
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + Sand
         + SimpleField + Sign2 + FValue2 + ')' + MergeSign);
      end;
      // ������� ���
      GD_FC_OUT, GD_FC_OUT_LIMIT:
      begin
        case AnConditionData.ConditionType of
          GD_FC_OUT:
          begin
            Sign1 := ' <= ';
            Sign2 := ' >= ';
          end;
          GD_FC_OUT_LIMIT:
          begin
            Sign1 := ' < ';
            Sign2 := ' > ';
          end;
        end;
        WhereStr.Add('(' + SimpleField + Sign1 + FValue1 + Sor
         + SimpleField + Sign2 + FValue2 + ')' + MergeSign);
      end;

      // ������� ������������ ��������� ��� ����
      GD_FC_QUERY_WHERE:
        WhereStr.Add('(' + AnConditionData.Value1 + ')' + MergeSign);
      // ����������
      GD_FC_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('NOT EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add('(' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);

      // �� ����������
      GD_FC_NOT_EMPTY:
        if (FieldType = GD_DT_REF_SET) or (FieldType = GD_DT_CHILD_SET) then
          WhereStr.Add('EXISTS(SELECT * FROM ' + AnConditionData.FieldData.LinkTable
           + ' WHERE ' + AnConditionData.FieldData.LinkSourceField + ' = ' + AnPrefixName
           + FieldName + ') ' + MergeSign)
        else
          WhereStr.Add(' NOT (' + AnPrefixName + FieldName + ' IS NULL) ' + MergeSign);
      // ������������� ��
      GD_FC_ENDS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName + ') LIKE ''%'
         + AnsiUpperCase(AnConditionData.Value1) + ''')' + MergeSign);
      // ��������
      GD_FC_CONTAINS:
        if FieldType = GD_DT_BLOB_TEXT then
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnConditionData.Value1 + '%'')' + MergeSign)
        else
          WhereStr.Add('(' + SimpleField + ' LIKE ''%'
           + AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // ���������� �
      GD_FC_BEGINS_WITH:
        WhereStr.Add('(UPPER(' + AnPrefixName + FieldName
         + ') LIKE ''' +  AnsiUpperCase(AnConditionData.Value1) + '%'')' + MergeSign);
      // �� �������
      GD_FC_TODAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + IBDateToStr(Trunc(Now)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // �� ��������� ����
      GD_FC_SELDAY:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= ''' + AnConditionData.Value1 + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(StrToDate(AnConditionData.Value1) + 1) + ''')' + MergeSign);
        end;
      // �� ��������� N ����
      GD_FC_LAST_N_DAYS:
        begin
          WhereStr.Add('(' + AnPrefixName + FieldName + ' >= '''
           + IBDateToStr(Trunc(Now) - StrToInt(AnConditionData.Value1)) + '''' + Sand);
          WhereStr.Add(AnPrefixName + FieldName + ' < ''' + IBDateToStr(Trunc(Now) + 1) + ''')' + MergeSign);
        end;
      // ������
      GD_FC_TRUE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 1)' + MergeSign);
      // ����
      GD_FC_FALSE:
        WhereStr.Add('(' + AnPrefixName + FieldName + ' = 0)' + MergeSign);

      // ��������
      GD_FC_INCLUDES:
        DoIncludes;

      // �������������� ����������
      GD_FC_COMPLEXFIELD:
        if FieldType = GD_DT_REF_SET then
        begin
          CurN := AddTable(AnConditionData.FieldData.LinkTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;

      // ������� ����������
      GD_FC_CUSTOM_FILTER:
      case FieldType of
      // ����������, ���� ������� ���������
        GD_DT_REF_SET_ELEMENT:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.RefTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.RefField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;

      // ����������, ���� ���������
        GD_DT_REF_SET:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.RefTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          //NetN := FindTableAll(AnConditionData.FieldData.LinkTable);
          NetN := AddTable(AnConditionData.FieldData.LinkTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + NetN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' = '
           + CurN + AnConditionData.FieldData.RefField + Sand);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;
        // ���������� ��������� ���������
        GD_DT_CHILD_SET:
        begin
          //if AnConditionData.FieldData.RefTable = AnConditionData.FieldData.TableName then
            CurN := AddTable(AnConditionData.FieldData.LinkTable);
          //else
          //  CurN := FindTableAll(AnConditionData.FieldData.RefTable);
          WhereStr.Add('(' + AnPrefixName + FieldName + ' = '
           + CurN + AnConditionData.FieldData.LinkSourceField + Sand + '(');
          for J := 0 to AnConditionData.SubFilter.Count - 1 do
            AddSQLCondition(AnConditionData.SubFilter.Conditions[J], CurN, True,
             AnConditionData.SubFilter.IsAndCondition);
          WhereStr.Strings[WhereStr.Count - 1] :=
           ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], '))' + MergeSign);
        end;
      end;

      // �� �������� �����
      GD_FC_NOT_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // ��������� �������
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             CurN + '.' + AnConditionData.FieldData.RefField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.RefTable + ' ' +
             NetN + ', ' + AnConditionData.FieldData.RefTable + ' ' + CurN + ' WHERE ');
            NetN := NetN + '.';
            CurN := CurN + '.';
            WhereStr.Add(NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder +
             '))' + MergeSign);
          end;
          GD_DT_REF_SET:
          begin
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            FValue1 := GetNextPrefix;
            // ��������� �������
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             FValue1 + '.' + AnConditionData.FieldData.LinkSourceField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.RefTable + NetN + ', ' +
             AnConditionData.FieldData.RefTable + CurN + ', ' +
             AnConditionData.FieldData.LinkTable + FValue1);

            NetN := NetN + '.';
            CurN := CurN + '.';
            FValue1 := FValue1 + '.';

            WhereStr.Add(' WHERE ' + NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            // ��������� �������
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + FValue1 + AnConditionData.FieldData.LinkTargetField + '))' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // ������� ������� �������
            NetN := GetNextPrefix;
            CurN := GetNextPrefix;
            // ��������� �������
            WhereStr.Add('( NOT ' + AnPrefixName + FieldName + ' IN (SELECT ' +
             CurN + '.' + AnConditionData.FieldData.LinkSourceField);
            WhereStr.Add(' FROM ' + AnConditionData.FieldData.LinkTable + NetN + ', ' +
             AnConditionData.FieldData.LinkTable + CurN + ' WHERE ');
            NetN := NetN + '.';
            CurN := CurN + '.';
            WhereStr.Add(NetN + AnConditionData.FieldData.LinkTargetField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + '))' + MergeSign);
          end;
          GD_DT_ATTR_SET_ELEMENT, GD_DT_ATTR_SET:
            Assert(False, 'Not supported');
        end;
      end;

      // ���� ����� ��
      GD_FC_ACTUATES_TREE:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        case FieldType of
          GD_DT_REF_SET_ELEMENT:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // ��������� �������
            WhereStr.Add('(' + AnPrefixName + FieldName + ' = ' + CurN +
             AnConditionData.FieldData.RefField + Sand);
            WhereStr.Add(NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder +
             ')' + MergeSign);
          end;
          GD_DT_REF_SET:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.RefTable);
            CurN := AddTable(AnConditionData.FieldData.RefTable);
            // ��������� �������
            WhereStr.Add('(' + NetN + AnConditionData.FieldData.RefField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
            WhereStr.Add(CurN + AnConditionData.FieldData.RefField + ' = '
             + NetN + AnConditionData.FieldData.LinkTargetField + Sand);
            WhereStr.Add(AnPrefixName + FieldName + ' = '
             + NetN + AnConditionData.FieldData.LinkSourceField + ')' + MergeSign);
          end;
          GD_DT_CHILD_SET:
          begin
            // ������� ������� �������
            NetN := AddTable(AnConditionData.FieldData.LinkTable);
            CurN := AddTable(AnConditionData.FieldData.LinkTable);
            // ��������� �������
            WhereStr.Add('(' + NetN + AnConditionData.FieldData.LinkTargetField + ' IN ' + S + Sand);
            WhereStr.Add(NetN + fltTreeLeftBorder + ' <= ' + CurN + fltTreeLeftBorder + Sand);
            WhereStr.Add(NetN + fltTreeRightBorder + ' >= ' + CurN + fltTreeRightBorder + Sand);
            WhereStr.Add(CurN + AnConditionData.FieldData.LinkSourceField + ' = '
             + AnPrefixName + FieldName + ')' + MergeSign);
          end;
          GD_DT_ATTR_SET_ELEMENT, GD_DT_ATTR_SET:
            Assert(False, 'Not supported');
        end;
      end;

      // �� ��������
      GD_FC_NOT_ACTUATES:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        DoActuates(' NOT IN ');
      end;

      // ���� ��
      GD_FC_ACTUATES:
      begin
        S := '(';
        for J := 0 to AnConditionData.ValueList.Count - 1 do
          S := S + IntToStr(Integer(AnConditionData.ValueList.Objects[J])) + ',';
        S[Length(S)] := ')';

        DoActuates(' IN ');
      end;
    end;
    Result := True;
  end;

  // ��������� �������� �� ������� �������� ������������
  function CheckUserQuery(const AnConditionList: TFilterConditionList; out AnUserSQLText: String): Boolean;
  begin
    Result := (AnConditionList.Count = 1) and
     (AnConditionList.Conditions[0].FieldData.FieldType = GD_DT_FORMULA) and
     (AnConditionList.Conditions[0].ConditionType = GD_FC_QUERY_ALL);
    if Result then
      AnUserSQLText := AnConditionList.Conditions[0].Value1;
  end;

  // ������� ������ �������� ������� � ��������� ������ �������
  // ���������� ��� ����������� ����� ������������ ���� ������� ���������,
  // �.�. ������������ LEFT JOIN
(*  function FindMainTable(PerfixName: String): Integer;
  const
    LimitChar = [' ', #13, #10, ','];
  var
    J, SpPos: Integer;
    Flag: Boolean;
  begin
    try
      Flag := False;
      Result := -1;
      S := Trim(MainName);
      for J := 0 to TempFromText.Count - 1 do
      begin
        Flag := True;
        SpPos := Pos(S, TempFromText.Strings[J]);
        if SpPos > 0 then
        begin
          if SpPos > 1 then
            if not (TempFromText.Strings[J][SpPos - 1] in LimitChar) then
              Flag := False;
          if SpPos < Length(TempFromText.Strings[J]) - Length(S) + 1 then
            if not (TempFromText.Strings[J][SpPos + Length(S)] in LimitChar) then
              Flag := False
            else
            begin
              TempFromText.Insert(J, TempFromText.Strings[J]);
              TempFromText.Strings[J] := Copy(TempFromText.Strings[J], 1, SpPos + Length(S) - 1);
              TempFromText.Strings[J + 1] := Copy(TempFromText.Strings[J + 1],
               SpPos + Length(S), Length(TempFromText.Strings[J + 1]));
            end;
          if Flag then
          begin
            Result := J;
            Break;
          end;
        end;
      end;
      if Flag then
      begin
        if Result = TempFromText.Count - 1 then
          TempFromText.Add('');
        if Result = TempFromText.Count then
          Result := -1
        else
          Inc(Result)
      end else
        Result := -1
    except
      Result := -1;
      ShowMessage('��� ������������� ������ ������ ������� ���������� � ������������.'
       + '������� ����� ������� ����� ��� ��������������.'); {gs}
    end;
  end; (**)

  function ParamExist(AnConditionList: TFilterConditionList): Boolean;
  var
    CondCount: Integer;
  begin
    Result := False;
    for CondCount := 0 to AnConditionList.Count - 1 do
    begin
      case AnConditionList.Conditions[CondCount].ConditionType of
        GD_FC_ENTER_PARAM:
          Result := True;
        GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
          Result := ParamExist(AnConditionList.Conditions[CondCount].SubFilter);
      end;
      if Result then
        Break;
    end;
  end;

  // ������� ��������� DISTINCT � ����� �������
  function AddDistinct(const AnSQLText: String): String;
  const
    cDST = ' DISTINCT ';
    cSLT = 'SELECT';
  var
    I: Integer;
  begin
    Result := AnSQLText;
    I := Pos(cSLT, AnsiUpperCase(AnSQLText));
    if I > 0 then
      Insert(cDST, Result, I + Length(cSLT));
  end;
begin
  Result := False;
  // ������� ����������� ������
  SelectStr := TStringList.Create;
  FromStr := TStringList.Create;
  WhereStr := TStringList.Create;
  OrderStr := TStringList.Create;
  PrefixList := TStringList.Create;
  try
    // ��������� ���������
    TblN := 0;
    SelectStr.Clear;
    FromStr.Clear;
    WhereStr.Clear;
    PrefixList.Clear;

(*    // ���������� ������ �������� �������
   // MainIndex := FindMainTable;
    // ���� ���������� ������� ��������� ����� �������
   { if Trim(FFromText.Text) = '' then
    begin
      FromStr.Add('FROM ' + FFilterData.TableName + MainName);
      FTableList.Add(FFilterData.TableName);
//      FPrefixList.Add(MainName);
    end;}
    Inc(TblN);
    // ���� ���������� ������� ��������� ����� ����� ��� �����������
    {if Trim(FSelectText.Text) = '' then
      SelectStr.Add('SELECT * ');}
    (*else
      // ���� ���������� ��������� �������� ��� �����������
      if FViewAttr then
        for I := 0 to UserFields.Count - 1 do
          case Integer(UserFields.Objects[I]) of
          // ������� ����
          GD_DT_CHAR, GD_DT_DATE, GD_DT_NUMERIC:
            SelectStr.Add(', ' + MainName + '.' + UserFields.Strings[I]);
          // ������� ���������
          GD_DT_ELEMENT_OF_SET:
            if MainIndex > -1 then
            begin
              S := AnPrefixName + IntToStr(TblN);
              Inc(TblN);
              TempFromText.Insert(MainIndex, ' LEFT JOIN gd_attrset ' + S + ' ON '
               + MainName + '.' + UserFields.Strings[I] + ' = ' + S + '.id');
              SelectStr.Add(', ' + S + '.name ' + UserFields.Strings[I]);
            end else {gs}
              ShowMessage('�� ������ ������� �������� �������.');
          end;
      *)
    IsUserQuery := CheckUserQuery(FFilterData.ConditionList, UserSQLText);

    if not IsUserQuery then
    begin

      // ��������� ������� ���� �� ������ ���������
      if ParamExist(FFilterData.ConditionList) then
        if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
        begin
          QueryParamsForConditions(FComponentKey, FCurrentFilter, FFilterData.ConditionList, EnterResult);
          // ��� ����� ���������� ��� ������ ������ �������� ������!!!
          if not EnterResult then
            Exit;
        end else
          raise Exception.Create('��������� FilterDlg �� ������');

      // ������� ������ ������� ����������
      for I := 0 to FFilterData.ConditionList.Count - 1 do
      begin
        AddSQLCondition(FFilterData.ConditionList.Conditions[I],
         FFilterData.ConditionList.Conditions[I].FieldData.TableAlias, True,
         FFilterData.ConditionList.IsAndCondition);
      end;

      // ������� ������ ������� ����������
      if FFilterData.OrderByList.Count > 0 then
      begin
        // ��� ������� ��� ����, ����� ���������� �� �������� ����������
//        if Trim(FOrderText.Text) = '' then
        OrderStr.Add('ORDER BY');
//        else
//          OrderStr.Add(', ');
        for I := 0 to FFilterData.OrderByList.Count - 1 do
        begin
          if I > 0 then
            OrderStr.Add(', ');
          if FFilterData.OrderByList.OrdersBy[I].IsAscending then
            S := ' ASC'
          else
            S := ' DESC';
          OrderStr.Add(FFilterData.OrderByList.OrdersBy[I].TableAlias
           + FFilterData.OrderByList.OrdersBy[I].FieldName + S);
        end;
      end;

      // ����������� ������� ��� ���������� ����� ���������� ������� � ������ ���������
      if (FFilterData.ConditionList.Count > 0) and (WhereStr.Count > 0) then
      begin
        // ���� ���������� ������� ��������� �������
        if Trim(FWhereText.Text) = '' then
          WhereStr.Insert(0, 'WHERE (')
        else
          WhereStr.Insert(0, Sand + '(');
        // ������� ��������� AND
        WhereStr.Strings[WhereStr.Count - 1] :=
         ReplaceOldSign(WhereStr.Strings[WhereStr.Count - 1], ')');
      end;
    end;

    // ������� ����� �������
    FQueryText.Clear;
    if IsUserQuery then
    begin
      FQueryText.Text := FQueryAlias;
      FQueryText.Add(UserSQLText);
    end else
    begin
      FQueryText.Add(FQueryAlias);
      FQueryText.AddStrings(FSelectText);
      FQueryText.AddStrings(SelectStr);
      FQueryText.AddStrings(FFromText);
      FQueryText.AddStrings(FromStr);
      FQueryText.AddStrings(FWhereText);
      FQueryText.AddStrings(WhereStr);
      FQueryText.AddStrings(FOtherText);
//      FQueryText.AddStrings(FOrderText);
      FQueryText.AddStrings(OrderStr);
      if FFilterData.ConditionList.IsDistinct then
        FQueryText.Text := AddDistinct(FQueryText.Text);
    end;
    Result := True;
  finally
    // ����������� ������������ ������
    SelectStr.Free;
    FromStr.Free;
    WhereStr.Free;
    OrderStr.Free;

    PrefixList.Free;
  end; (**)
end;

procedure TgsSQLFilter.SetQueryText(const AnSQLText: String);
begin
  FSelectText.Text := ExtractSQLSelect(AnSQLText);
  FFromText.Text := ExtractSQLFrom(AnSQLText);
  FWhereText.Text := ExtractSQLWhere(AnSQLText);
  FOtherText.Text := ExtractSQLOther(AnSQLText);
  FOrderText.Text := ExtractSQLOrderBy(AnSQLText);
end;

function TgsSQLFilter.AddCondition(AFilterCondition: TFilterCondition): Integer;
begin
  if FFilterData.ConditionList.CheckCondition(AFilterCondition) then
    Result := FFilterData.ConditionList.AddCondition(AFilterCondition)
  else
    Result := -1;
end;

procedure TgsSQLFilter.DeleteCondition(const AnIndex: Integer);
begin
  Assert(((AnIndex >= 0) and (AnIndex < FFilterData.ConditionList.Count)), '������ ��� ���������');
  FFilterData.ConditionList.Delete(AnIndex);
end;

procedure TgsSQLFilter.ClearConditions;
begin
  FFilterData.ConditionList.Clear;
end;

function TgsSQLFilter.AddOrderBy(AnOrderBy: TFilterOrderBy): Integer;
begin
  Result := FFilterData.OrderByList.AddOrderBy(AnOrderBy);
end;

procedure TgsSQLFilter.DeleteOrderBy(const AnIndex: Integer);
begin
  Assert(((AnIndex >= 0) and (AnIndex < FFilterData.OrderByList.Count)), '������ ��� ���������');
  FFilterData.OrderByList.Delete(AnIndex);
end;

procedure TgsSQLFilter.ClearOrdersBy;
begin
  FFilterData.OrderByList.Clear;
end;

procedure TgsSQLFilter.ReadFromStream(S: TStream);
begin
  FFilterData.ReadFromStream(S);
end;

procedure TgsSQLFilter.WriteToStream(S: TStream);
begin
  FFilterData.WriteToStream(S);
end;

{TgsQueryFilter}

constructor TgsQueryFilter.Create(AnOwner: TComponent);
var
  Reg: TRegistry;
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    FIsSQLChanging := False;
    FIsFirstOpen := False;
    FIsCompKey := False;
    FIsLastSave := False;
    FOwnerName := GetOwnerName;// ������������ ���������
    FMessageDialog := TmsgShowMessage.Create(Self);     // ������� �.�. ��������� �������
    FActionList := TActionList.Create(Self);
    FRecordCount := -1;

    // ��������� ���� �� ���������� ��������������
    FShowBeforeFilter := False;
    try
      Reg := TRegistry.Create(KEY_READ);
      try
        Reg.RootKey := ClientRootRegistryKey;
        if Reg.OpenKeyReadOnly('Software\Golden Software\' + GetApplicationName
         + '\FilterOptions\' + FOwnerName + '\') then
          if Reg.ValueExists(Name) then
            FShowBeforeFilter := Reg.ReadBool(Name);
      finally
        Reg.CloseKey;
        Reg.Free;
      end;
    except
      // Don't show this mistake
    end;

    CreateActions;
    if (Owner <> nil) and (Owner is TForm) then
    begin
      FOldShortCut := (Owner as TForm).OnShortCut;
      (Owner as TForm).OnShortCut := SelfOnShortCut;
    end;
  end;
end;

destructor TgsQueryFilter.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    // ��������� ��������� ������
    SaveLastFilter;
    // ����������� ������������
    FMessageDialog.Free;
    FActionList.Free;
  end;

  FPopupMenu.Free;

  inherited Destroy;
end;

procedure TgsQueryFilter.SelfOnShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  Handled := Handled or ((FPopupMenu <> nil) and (FPopupMenu is TPopupMenu)
    and FActionList.IsShortCut(Msg));

  if Assigned(FOldShortCut) then
    FOldShortCut(Msg, Handled);
end;

procedure TgsQueryFilter.DoOnCreateFilter(Sender: TObject);
var
  I: Integer;
begin
  // �������� ������� �������� �������
  if AddFilter(I) then
  begin
    // ���� ������ ������ "��"
    if I <> 0 then
    begin
      // ��������� �������
      SaveFilter;

      // �������� ���������
      LoadFilter(I);

      // ���������
      FilterQuery;
    end;
    
    // ������� ����
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnEditFilter(Sender: TObject);
var
  I: Integer;
begin
  // �������� ��������������
  if EditFilter(I) then
  begin
    // ���� ������ "��"
    if I <> 0 then
    begin
      if I = FCurrentFilter then
        FLastExecutionTime := 0;
      SaveFilter;
      LoadFilter(I);
      FilterQuery;
    end;
    // ������� ����
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnDeleteFilter(Sender: TObject);
begin
  // �������� ��������
  if DeleteFilter then
  begin
    RevertQuery;
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DoOnWriteToFile(Sender: TObject);
var
  SD: TSaveDialog;
  St: TMemoryStream;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.DefaultExt := 'flt';
    SD.Filter := '�������|*.flt';
    SD.Options := SD.Options + [ofOverwritePrompt];
    if SD.Execute then
    begin
      St := TMemoryStream.Create;
      try
        FFilterData.WriteToStream(St);
        St.SaveToFile(SD.FileName);
      finally
        St.Free;
      end;
    end;
  finally
    SD.Free;
  end;
end;

procedure TgsQueryFilter.DoOnReadFromFile(Sender: TObject);
var
  LD: TOpenDialog;
  St: TMemoryStream;
begin
  LD := TOpenDialog.Create(Self);
  try
    LD.Filter := '�������|*.flt';
    if LD.Execute and ((FCurrentFilter = 0) or (MessageBox(0, '�� ������ �������� ������� ������?',
     '��������', MB_OKCANCEL or MB_ICONQUESTION or MB_TASKMODAL) = IDOK)) then
    begin
      St := TMemoryStream.Create;
      try
        St.LoadFromFile(LD.FileName);
        St.Position := 0;
        FFilterData.ReadFromStream(St);
        FLastExecutionTime := 0;
        FDeltaReadCount := 0;
        FilterQuery;
      finally
        St.Free;
      end;
    end;
  finally
    LD.Free;
  end;
end;

procedure TgsQueryFilter.DoOnRecordCount(Sender: TObject);
begin
  MessageBox(0, PChar('���������� ������� � ������� �������: ' + IntToStr(RecordCount)),
   '����������', MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

// ������� ������� ����������
procedure TgsQueryFilter.DoOnFilterBack(Sender: TObject);
var
  I: Integer;
begin
  // ������ ������������ ����������� �������� ����
  SetEnabled(False);

  // ��������� ��������� �������� �������
  SaveFilter;

  // ������� �������� Checked
  if FPopupMenu <> nil then
  begin
    for I := 0 to FPopupMenu.Items.Count - 1 do
      FPopupMenu.Items[I].Checked := False
  end;

  RevertQuery;
end;

procedure TgsQueryFilter.DoOnSelectFilter(Sender: TObject);
begin
  // ������ ���������� ��������
  SetEnabled(True);
  // ���� ������ �������, �� �������
  if (Sender as TMenuItem).Tag = FCurrentFilter then
    Exit;
  // ��������� �������
  SaveFilter;
  // ��������
  (Sender as TMenuItem).Checked := True;
  // ���������
  if LoadFilter((Sender as TMenuItem).Tag) then
    FilterQuery
  else
    CreatePopupMenu;
end;

procedure TgsQueryFilter.DoOnViewFilterList(Sender: TObject);
var
  F: TdlgFilterList;
  I: Integer;
  Flag: Boolean;  // ���� �� ���������
begin
  // ������� ����
  F := TdlgFilterList.Create(Self);
  try
    // �������� ����������
    if not Transaction.InTransaction then
      Transaction.StartTransaction;

    // ����������� ���������
    F.ibsqlFilter.Database := Database;
    F.ibsqlFilter.Transaction := Transaction;

    // �������� ���� ���������� �������
    I := F.ViewFilterList(FComponentKey, Flag, FSelectText.Text + FFromText.Text +
     FWhereText.Text + FOtherText.Text + FOrderText.Text);

    // ��������� �������� ����������
    if I <> 0 then
    begin
      SaveFilter;
      LoadFilter(I);
      FilterQuery;
    end;

    if Flag then
      CreatePopupMenu;
  finally
    // ��������� ����������
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    F.Free;
  end;
end;

procedure TgsQueryFilter.FilterQuery;
var
  Flag: Boolean;
  StartTime: TTime;
  ParamList: TfltStringList;
  I: Integer;
  LastTrState: Boolean;
begin
  // ���������� ���������
  Flag := FIBDataSet.Active;
  // ���������� ��������������
  if Flag then
    ShowWarning;
  FIsSQLChanging := True;
  // ������� �����
  if CreateSQLText(FFilterData) then
  begin
    ParamList := TfltStringList.Create;
    try
      if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
            ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
             TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

      // ��������� ������ � ����������� �����
      if FIBDataSet.Active then
        FIBDataSet.Close;
      if IsIBQuery then
        TIBQuery(FIBDataSet).SQL.Assign(FQueryText)
      else
        TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Assign(FQueryText);
      // ���������� ���������� �������
      FRecordCount := -1;
      // ����������� ���������� ���������
      Inc(FDeltaReadCount);
      // ���� ���� ��������� ��������� �� ����������� ��
      for I := 0 to ParamList.Count - 1 do
        try
          if TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]) <> nil then
            TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsString := ParamList.ValuesOfIndex[I];
        except
        end;

      LastTrState := False;
      try
        try
          if Assigned(FIBDataSet.Database) and FIBDataSet.Database.Connected and
            Assigned(FIBDataSet.Transaction) and (FIBDataSet.Transaction.DatabaseCount > 0) then
          begin
            // ��������� ��������� ����������. ���� ��� ���������� � �������, �� ������.
            LastTrState := Assigned(FIBDataSet.Transaction.DefaultDatabase) and not FIBDataSet.Transaction.InTransaction;
            TIBCustomDataSetCracker(FIBDataSet).InternalPrepare;
          end;
        except
          // ��������� ������
          on E: Exception do
          begin
            MessageBox(0, PChar('��������� ������ ��� ���������� �������.'#13#10
             + '������ ��������� � �������� ���������.'#13#10
             + E.Message), '��������', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
            // ������������ � ��������������� �������
            RevertQuery;
            CreatePopupMenu;
          end;
        end;
      finally
        // ���� ���������� ���� ������� � ��� �� ���� ��������� Query, �� ��������� ��.
        if LastTrState and (not Flag) and FIBDataSet.Transaction.InTransaction then
          //FIBDataSet.Transaction.Commit;
          FIBDataSet.Transaction.CheckAutoStop; // ���� �� ���������� ����� ������ ��������
                                                // � ������ ���� �� ��� ������
                                                // ��� ����������� ������������� �� �����
                                                // ����� ��� ����������� ���������
                                                // �� ��� �� ���������
                                                // ������ �������������� ������ CheckAutoStop
                                                // � ������ ������ ������������ ���� ���, � ��
                                                // ������� �����
      end;

      // ���� ������ ��� ������ �� ��������� ���
      if Flag then
      try
        // ���� ����� ���������� ���������� ���� ������ ����������� ������� ����
        if FLastExecutionTime > FMaxExecutionTime then
        begin
          FMessageDialog.Show;
          Application.ProcessMessages;
        end;
        try
          StartTime := Now;
          FIBDataSet.Open;
          FLastExecutionTime := Now - StartTime;
        finally
          FMessageDialog.Hide;
        end;

      except
        // ��������� ������
        on E: Exception do
        begin
          // EAbort ����������� ����� ����������
          // ������������ ��� ����, ����� ���������
          // ��� �������� ��� ��� ����������, ��
          // ������������ ������ �� ����������
          // ���� � ��� ������ EAbort ������ ������
          // ����������� ��� ���������� ������������
          // ��������, ��������, �������������� ������������
          // �� ������ ����� � ������� ��� ��� ������
          // � ������ ������ �� ����� �������� �� ����.
          // ������ ����� ������� ���� ����.
          if not (E is EAbort) then
            MessageBox(0, PChar('��������� ������ ��� ���������� �������.'#13#10
             + '������ ��������� � �������� ���������.'#13#10
             + E.Message), '��������', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
          // ������������ � ��������������� �������
          RevertQuery;
          FIBDataSet.Open;
          CreatePopupMenu;
        end;
      end;
    finally
      ParamList.Free;
    end;
  end else
  begin
    if FIBDataSet.Active then
      FIBDataSet.Close;
    if Flag then
    begin
      RevertQuery;
      FIBDataSet.Open;
      CreatePopupMenu;
    end;
  end;
  FIsSQLChanging := False;
end;

// ������� ����
procedure TgsQueryFilter.CreatePopupMenu;
begin
  if FPopupMenu = nil then
    FPopupMenu := TPopupMenu.Create(Self)
  else
    FPopupMenu.Items.Clear;

  MakePopupMenu(FPopupMenu);
end;

procedure TgsQueryFilter.SaveLastFilter;
var
  ibsqlLast: TIBSQL;
begin
  if (FBase = nil) or (Database = nil) or (not Database.Connected) or (Transaction = nil) then
    exit;

  if (not FIsFirstOpen) or FIsLastSave then
    exit;

  ibsqlLast := TIBSQL.Create(Self);
  try
    // ����������� ����������� ��������
    ibsqlLast.Database := Database;
    ibsqlLast.Transaction := Transaction;
    
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
      
    // ���������� ���� ����������
    ExtractComponentKey;
    // ��������� ������� ������
    SaveFilter;
    // ������� ��������� ������ ��� �������� ������������ � ����������
    ibsqlLast.SQL.Text := 'DELETE FROM flt_lastfilter WHERE userkey '
     + GetISUserKey + ' AND componentkey = ' + IntToStr(FComponentKey);

{ TODO -o������ -c������� : ����� ���� try except?? �����-�� ������? }
    try
      ibsqlLast.ExecQuery;
      if FCurrentFilter <> 0 then
      begin
        // ��������� ��������� ������
        ibsqlLast.SQL.Text := 'INSERT INTO flt_lastfilter (userkey, componentkey, lastfilter, crc32, dbversion) '
         + 'VALUES(' + GetUserKey + ', ' + IntToStr(FComponentKey)
         + ', ' + IntToStr(FCurrentFilter) + ', ' + IntToStr(GetCRC) + ', ''' + GetDBVersion + ''')';
        ibsqlLast.ExecQuery;
      end;
    except
    end;
  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    // ������������� ���� � ���������� ���������� �������
    FIsLastSave := True;
    // ������������� ���� � ������ ��������
    FIsFirstOpen := False;
    FreeAndNil(ibsqlLast);
  end;
end;

// �������� ��������� ������
procedure TgsQueryFilter.LoadLastFilter;
var
  ibsqlLast: TIBSQL;
begin
  if (Database = nil) or not Database.Connected or (Transaction = nil) then
    Exit;

  ibsqlLast := TIBSQL.Create(Self);
  try
    // ����������� ���������
    ibsqlLast.Database := Database;
    ibsqlLast.Transaction := Transaction;
    // ���� ����������
    ExtractComponentKey;
    // ���� �������� �������
    ibsqlLast.SQL.Text := 'SELECT * FROM flt_lastfilter WHERE userkey '
     + GetISUserKey + ' AND componentkey = ' + IntToStr(FComponentKey);
    // �������� ����������
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
    ibsqlLast.ExecQuery;
    if not ibsqlLast.Eof then
      if {not ibsqlLast.FieldByName('crc32').IsNull and}
       CompareVersion(ibsqlLast.FieldByName('crc32').AsInteger,
        ibsqlLast.FieldByName('dbversion').AsString, True) then
      begin
        // ���� ������, �� ���������
        LoadFilter(ibsqlLast.FieldByName('lastfilter').AsInteger);
        FilterQuery;
      end;
  finally
    // ��������� ����������
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    FIsLastSave := False;
    ibsqlLast.Free;
  end;
end;

procedure TgsQueryFilter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FIBDataSet) then
    FIBDataSet := nil;
  if (Operation = opRemove) and (AComponent = FDataBase) then
    FDataBase := nil;
end;

procedure TgsQueryFilter.Loaded;
begin
  inherited;
  if (Owner <> nil) and (FOwnerName <> Owner.Name) then
    FOwnerName := GetOwnerName;
end;

// ��������� ������ ��
function TgsQueryFilter.GetDBVersion: String;
begin
  if IBLogin <> nil then
    Result := Trim(IBLogin.DBVersion)
  else
    Result := '';
end;

// �������� CRC ���������� �������
function TgsQueryFilter.GetCRC: Integer;
var
  TempS: String;
  //ArBt: TArrByte;
begin
  TempS := FSelectText.Text + FFromText.Text + FWhereText.Text + FOtherText.Text + FOrderText.Text;
  {SetLength(ArBt, Length(TempS) * SizeOf(Char));
  ArBt := Copy(TArrByte(TempS), 0, Length(TempS) * SizeOf(Char));}
  Result := Integer(Crc32_P(@TempS[1], Length(TempS), 0));
end;

// ���������� ������ ��������� �������� � ��
function TgsQueryFilter.CompareVersion(const OldCRC: Integer; const DBVersion: String; const Question: Boolean): Boolean;
var
  TempS: String;
  ArBt: TArrByte;
begin
  TempS := FSelectText.Text + FFromText.Text + FWhereText.Text + FOtherText.Text + FOrderText.Text;
  SetLength(ArBt, Length(TempS) * SizeOf(Char));
  ArBt := Copy(TArrByte(TempS), 0, Length(TempS) * SizeOf(Char));
  Result := ((CheckCrc32(ArBt, Length(ArBt), Cardinal(OldCRC)) = 0)
   and (DBVersion = GetDBVersion))
   or (
     MessageBox(0,
       '������ ��������� ��� ���� ������ ���� ��������.'#13#10 +
       '�� ������ ��������� ��������� ������?',
       '��������',
       MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
end;

// ��������� ���� ����������
procedure TgsSQLFilter.ExtractComponentKey;
var
  ibsqlComp: TIBSQL;
  FltName: String[21];
begin
  if (Database = nil) or not Database.Connected or (Transaction = nil) then
    Exit;

  FltName := Copy(Name, 1, 20);
  // ���� ���� ������ �� �������
  if FIsCompKey then
    Exit;
  ibsqlComp := TIBSQL.Create(Self);
  try
    ibsqlComp.Database := Database;
    ibsqlComp.Transaction := Transaction;
    // ���� ���������� � ������ �����������
    ibsqlComp.SQL.Text := 'SELECT id FROM flt_componentfilter WHERE formname = '''
     + FOwnerName + ''' AND filtername = ''' + FltName
     + ''' AND applicationname = ''' + GetApplicationName + '''';
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
    ibsqlComp.ExecQuery;
    if not ibsqlComp.Eof then
      // ���� ����� ����������� ��������
      FComponentKey := ibsqlComp.Fields[0].AsInteger
    else
    begin
      // ���� ��� ������� �����
      try
        ibsqlComp.Close;
        ibsqlComp.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM rdb$database';
        ibsqlComp.ExecQuery;
        FComponentKey := ibsqlComp.Fields[0].AsInteger;
        ibsqlComp.Close;
        ibsqlComp.SQL.Text := 'INSERT INTO flt_componentfilter (id, formname, filtername, applicationname)'
         + ' VALUES(' + IntToStr(FComponentKey) + ',''' + FOwnerName + ''',''' + FltName
         + ''',''' + GetApplicationName + ''')';
        ibsqlComp.ExecQuery;
      except
      end;
    end;
  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;
    // ������������� ����, ��� ���� ������
    FIsCompKey := True;
    ibsqlComp.Free;
  end;
end;

// �������� ���� ������������
function TgsQueryFilter.GetUserKey: String;
begin
  if IBLogin <> nil then
    Result := IntToStr(IBLogin.UserKey)
  else
    Result := IntToStr(ADMIN_KEY); // ' NULL '
end;

function TgsQueryFilter.GetISUserKey: String;
begin
  if IBLogin <> nil then
    Result := ' = ' + IntToStr(IBLogin.UserKey)
  else
    Result := ' = ' + IntToStr(ADMIN_KEY); // ' IS NULL '
end;

// ������������ ����������
function TgsSQLFilter.GetApplicationName: String;
begin
  Result := Copy(UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), '')), 1, FIndexFieldLength);
end;

// ���������� ��������������
procedure TgsQueryFilter.ShowWarning;
var
  F: TmsgBeforeFilter;
  Reg: TRegistry;
begin
  if not FShowBeforeFilter and ((FLastExecutionTime > FMaxExecutionTime)
   {or (FLastExecutionTime = 0)}) then
  begin
    F := TmsgBeforeFilter.Create(Self);
    try
      F.ShowModal;
      if F.cbVisible.Checked then
      try
        Reg := TRegistry.Create;
        try
          FShowBeforeFilter := True;
          Reg.RootKey := ClientRootRegistryKey;
          if Reg.OpenKey('Software\Golden Software\' + GetApplicationName
           + '\FilterOptions\' + FOwnerName + '\', True) then
            Reg.WriteBool(Name, FShowBeforeFilter);
        finally
          Reg.CloseKey;
          Reg.Free;
        end;
      except
        // Don't show this mistake
      end;
    finally
      F.Free;
    end;
  end;
end;

// ��������� ����������� ��������� AnEnabled
procedure TgsQueryFilter.SetEnabled(const AnEnabled: Boolean);
var
  I: Integer;
begin
  for I := 0 to FActionList.ActionCount - 1 do
    if FActionList.Actions[I].Tag = 1 then
      TAction(FActionList.Actions[I]).Enabled := AnEnabled;
end;

// �������� ���������� ������� � �������
function TgsQueryFilter.GetRecordCount: Integer;
var
  ibsqlCount: TIBCustomDataSet;
  OldRecNo: Integer;
  I, J: Integer;
  FlagTr: Boolean;
  ParamList: TStringList;
begin
  // ���� ���������� ������� �� ����������
  if FRecordCount = -1 then
  begin
    if (FIBDataSet <> nil) and FIBDataSet.Active then
    begin
      // ��������� ������ �������� �������
      OldRecNo := FIBDataSet.RecNo;
      FIBDataSet.DisableControls;
      // ����������� ������� ������ ���������� ��������� �������
      FIBDataSet.RecNo := FIBDataSet.RecordCount;
      // �������� ������� ���������
      FIBDataSet.Next;
      // ���� �� ������� ������ ������� ��� ������
      if FIBDataSet.Eof then
        FRecordCount := FIBDataSet.RecordCount;
      // ��������������� �������� �������
      FIBDataSet.RecNo := OldRecNo;
      FIBDataSet.EnableControls;
    end;
    // ���� ��������� ������� �� ����� ������� ���� ������ ������������ ����������
    if FRecordCount = -1 then
    begin
      if (FIBDataSet is TIBQuery) then
        ibsqlCount := TIBQuery.Create(Self)
      else
        ibsqlCount := TIBDataSet.Create(Self);
      FlagTr := True;

      ParamList := TStringList.Create;
      try
        // �������� ����������
        if FIBDataSet.Transaction <> nil then
        begin
          FlagTr := FIBDataSet.Transaction.InTransaction;
          if not FlagTr then
            FIBDataSet.Transaction.StartTransaction;
          ibsqlCount.Transaction := FIBDataSet.Transaction;
        end else
        begin
          if not Transaction.InTransaction then
            Transaction.StartTransaction;
          ibsqlCount.Transaction := Transaction;
        end;
        // ����������� ���������
        ibsqlCount.Database := Database;

        if (FIBDataSet <> nil) and (FIBDataSet.Owner <> nil) then
          for I := 0 to FIBDataSet.Owner.ComponentCount - 1 do
            if FIBDataSet.Owner.Components[I] is TboAccess then
              for J := 0 to (FIBDataSet.Owner.Components[I] as TboAccess).DataSetList.Count - 1 do
                if AnsiUpperCase(Trim((FIBDataSet.Owner.Components[I] as TboAccess).DataSetList.Strings[J])) =
                 AnsiUpperCase(FIBDataSet.Name) then
                begin
                  ibsqlCount.BeforeOpen := FIBDataSet.BeforeOpen;
                  Break;
                end;

        // ������� ������
        if (FIBDataSet is TIBQuery) then
          with TIBQuery(ibsqlCount) do
          begin
            SQL.Text := 'SELECT COUNT(*)';
            SQL.Add(ExtractSQLFrom(FQueryText.Text));
            SQL.Add(ExtractSQLWhere(FQueryText.Text));
            SQL.Add(ExtractSQLOther(FQueryText.Text));
            SQL.Add(ExtractSQLOrderBy(FQueryText.Text));
          end
        else
          with TIBCustomDataSetCracker(ibsqlCount) do
          begin
            SelectSQL.Text := 'SELECT COUNT(*)';
            SelectSQL.Add(ExtractSQLFrom(FQueryText.Text));
            SelectSQL.Add(ExtractSQLWhere(FQueryText.Text));
            SelectSQL.Add(ExtractSQLOther(FQueryText.Text));
            SelectSQL.Add(ExtractSQLOrderBy(FQueryText.Text));
          end;

        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
            ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
              TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

        // ����������� ��������� ���� ��� ���� �� ������������� ����������
{        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          if (ibsqlCount is TIBQuery) then
          begin
            if TIBQuery(ibsqlCount).ParamByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) <> nil then
              TIBQuery(ibsqlCount).ParamByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name).Value := TIBCustomDataSetCracker(FIBDataSet).Params[I].Value;
          end else
            if TIBCustomDataSetCracker(ibsqlCount).Params.ByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) <> nil then
              TIBCustomDataSetCracker(ibsqlCount).Params.ByName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name).Value := TIBCustomDataSetCracker(FIBDataSet).Params[I].Value;}

        for I := 0 to ParamList.Count - 1 do
          if (FIBDataSet is TIBQuery) then
          begin
            if TIBQuery(ibsqlCount).ParamByName(ParamList.Names[I]) <> nil then
              TIBQuery(ibsqlCount).ParamByName(ParamList.Names[I]).AsString :=
                ParamList.Values[ParamList.Names[I]];
          end else
            if TIBCustomDataSetCracker(ibsqlCount).Params.ByName(ParamList.Names[I]) <> nil then
              TIBCustomDataSetCracker(ibsqlCount).Params.ByName(ParamList.Names[I]).AsString :=
                ParamList.Values[ParamList.Names[I]];

        ibsqlCount.Open;
        ibsqlCount.Next;
        if ibsqlCount.Eof then
          // ����������� ���������� �������
          FRecordCount := ibsqlCount.Fields[0].AsInteger
        else
        begin
          ibsqlCount.Last;
          FRecordCount := ibsqlCount.RecordCount;
        end;
      finally
        ParamList.Free;
        // ��������� ����������
        if FIBDataSet.Transaction <> nil then
        begin
          if not FlagTr then
            FIBDataSet.Transaction.Commit;
        end else
          if Transaction.InTransaction then
            Transaction.CommitRetaining;
        ibsqlCount.Free;
      end;
    end;
  end;
  Result := FRecordCount;
end;

procedure TgsQueryFilter.CreateActions;
begin
  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������� ������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnCreateFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('N'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnEditFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('E'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������� ������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnDeleteFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('D'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ����������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnFilterBack;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('B'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '���������� �������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRecordCount;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('C'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������ ��������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnViewFilterList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('L'), [ssCtrl]);

  with TAction.Create(Self) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRefresh;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(VK_F5, [ssCtrl]);
end;

// ������� �������� � ����
procedure TgsQueryFilter.MakePopupMenu(AnPopupMenu: TMenu);
const
  MaxFilterCount = 10;  // ������������ ��������� ������� ��������

var
  ibsqlFilterList: TIBSQL;
  I: Integer;
  FlagSearch: Boolean;
  TempPM: TMenuItem;
begin
  Assert((Database <> nil) and (Transaction <> nil),
    'TgsQueryFilter.MakePopupMenu: Database or transaction are not assigned');

  if not Database.Connected then
  begin
    MessageBox(0,
      '������ ������� ���� �������, �.�. ��� ����������� � ����.',
      '��������',
      MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    Exit;
  end;

  ibsqlFilterList := TIBSQL.Create(Self);
  try
    ExtractComponentKey;

    FlagSearch := False;
    ibsqlFilterList.Database := Database;
    ibsqlFilterList.Transaction := Transaction;

    if not Transaction.InTransaction then
      Transaction.StartTransaction;

    // ���������� ������ ��������
    ibsqlFilterList.SQL.Text := 'SELECT id, name FROM flt_savedfilter WHERE'
     + ' componentkey = ' + IntToStr(FComponentKey) + ' AND (userkey '
     + GetISUserKey + ' OR userkey IS NULL) ORDER BY readcount DESC';
    ibsqlFilterList.ExecQuery;

    TempPM := AnPopupMenu.Items;

    // ������� ����������� ���� ����
    if TempPM.Count > 0 then
    begin
      TempPM.Add(TMenuItem.Create(TempPM));
      TempPM.Items[TempPM.Count - 1].Caption := '-';
    end;

    // ������� ��������� ��������
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[0];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[1];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[2];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[3];

{    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '��������� � ����';
    TempPM.Items[TempPM.Count - 1].OnClick := DoOnWriteToFile;
    TempPM.Items[TempPM.Count - 1].ShortCut := ShortCut(Word('S'), [ssCtrl]);
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '��������� �� �����';
    TempPM.Items[TempPM.Count - 1].OnClick := DoOnReadFromFile;
    TempPM.Items[TempPM.Count - 1].ShortCut := ShortCut(Word('L'), [ssCtrl]);}

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[4];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '-';

    // ������� ������ ��������
    I := 0;
    while (not ibsqlFilterList.Eof) and ((I < MaxFilterCount) or not FlagSearch) do
    begin
      if (I < MaxFilterCount) or (FCurrentFilter = ibsqlFilterList.Fields[0].AsInteger) then
      begin
        TempPM.Add(TMenuItem.Create(TempPM));
        TempPM.Items[TempPM.Count - 1].Caption := ibsqlFilterList.Fields[1].AsString;
        TempPM.Items[TempPM.Count - 1].Tag := ibsqlFilterList.Fields[0].AsInteger;
        TempPM.Items[TempPM.Count - 1].OnClick := DoOnSelectFilter;
        TempPM.Items[TempPM.Count - 1].RadioItem := True;
      end;

      if FCurrentFilter = ibsqlFilterList.Fields[0].AsInteger then
      begin
        TempPM.Items[TempPM.Count - 1].Checked := True;
        FlagSearch := True;
      end;
      Inc(I);

      ibsqlFilterList.Next;
    end;

    // ������� �������� ��������
    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Caption := '-';

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[5];

    TempPM.Add(TMenuItem.Create(TempPM));
    TempPM.Items[TempPM.Count - 1].Action := FActionList.Actions[6];

    // ���� �� ��������� ������� �������, �� ���������� ���
    if (not FlagSearch) and (FCurrentFilter <> 0) then
      RevertQuery;

  finally
    if Transaction.InTransaction then
      Transaction.CommitRetaining;

    ibsqlFilterList.Free;
  end;

  if (FCurrentFilter = 0) then
    SetEnabled(False)
  else
    SetEnabled(True);
end;

// ���������� ������ � �������� ���������
procedure TgsQueryFilter.RevertQuery;
var
  ParamList: TfltStringList;
  I: Integer;
var
  Flag: Boolean;
begin
  FIsSQLChanging := True;
  // ������� ���������
  FFilterData.Clear;
  FCurrentFilter := 0;
  FFilterName := '';
  FFilterComment := '';
  FLastExecutionTime := 0;
  FDeltaReadCount := 0;
  // ������� ���� ���������� �������
  Flag := FIBDataSet.Active;
  FQueryText.Clear;
  FQueryText.Add(FQueryAlias);
  FQueryText.AddStrings(FSelectText);
  FQueryText.AddStrings(FFromText);
  FQueryText.AddStrings(FWhereText);
  FQueryText.AddStrings(FOtherText);
  FQueryText.AddStrings(FOrderText);
  ParamList := TfltStringList.Create;
  try
    if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
      for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
        if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
          ParamList.Add(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
            TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString);

    FIBDataSet.Close;

    // ����������� ����� �������
    if IsIBQuery then
      TIBQuery(FIBDataSet).SQL.Assign(FQueryText)
    else
      TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Assign(FQueryText);

    for I := 0 to ParamList.Count - 1 do
      try
        if TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]) <> nil then
          TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsString := ParamList.ValuesOfIndex[I];
      except
      end;
  finally
    ParamList.Free;
  end;

  FRecordCount := -1;
  // ��������� ���� ����
  if Flag then
  try
    FIBDataSet.Open;
  except
    on E: Exception do
      MessageBox(0,
       PChar('������� ��������� ������'#13#10 + E.Message),
       '��������',
       MB_OK or MB_ICONSTOP or MB_TASKMODAL);
  end;
  FIsSQLChanging := False;
  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self, 0);
end;

(*
function TgsQueryFilter.ShowDialogAndQuery: Boolean;
var
  TempFilter: TFilterData;
  LocalChange: Boolean;
begin
  TempFilter := TFilterData.Create;
  try
    LocalChange := False;
    FSavedFilter := 0;
    TempFilter.Assign(FFilterData);
    Result := ShowDialog;
    if Result then
    begin
      if FSavedFilter <> 0 then
      begin
        SaveFilter;
        if True then      {gs} // ����� ������ ��������� �������� �� ������� ������������ � ���������� �������
        begin     // ������� ���������� �����, ���� ��������������.
          FCurrentFilter := FSavedFilter;
          FLastExecutionTime := 0;
          FDeltaReadCount := 0;
          SaveFilter;
        end;
        LoadFilter(FSavedFilter);
        CreatePopupMenu;
      end else
      begin
        LocalChange := CompareFilterData(FFilterData, TempFilter);
        if not LocalChange then
        begin
          FLastExecutionTime := 0;
          FDeltaReadCount := 0;
        end;
      end;
      if not LocalChange or (MessageBox(0, '������� ������� �� ��������.'#13#10
       + '����������� ������?', '��������', MB_OKCANCEL or MB_ICONQUESTION) = IDOK) then
        FilterQuery;
    end;
    FSavedFilter := 0;
  finally
    TempFilter.Free;
  end;
end;  *)

procedure TgsQueryFilter.SetQuery(Value: TIBCustomDataSet);
begin
  Assert((Value = nil) or not (Value is TIBTable));

  if (FIBDataSet <> nil) then
    if not (csDesigning in ComponentState) then
      FIBDataSet.BeforeOpen := FOldBeforeOpen;

  if Value <> FIBDataSet then
  begin
    FIBDataSet := Value;
    if not (csDesigning in ComponentState) and (FIBDataSet <> nil) then
    begin
      FOldBeforeDatabaseDisconect := TIBCustomDataSetCracker(FIBDataSet).BeforeDatabaseDisconnect;
      TIBCustomDataSetCracker(FIBDataSet).BeforeDatabaseDisconnect := SelfBeforeDisconectDatabase;

      FOldBeforeOpen := TIBCustomDataSetCracker(FIBDataSet).BeforeOpen;
      TIBCustomDataSetCracker(FIBDataSet).BeforeOpen := SelfBeforeOpen;

      SeparateQuery;
    end;
  end;
end;

// ��������� ������
procedure TgsQueryFilter.SeparateQuery;
var
  SL: TStringList;
begin
  FRecordCount := -1;
  SL := TStringList.Create;
  try
    SL.Assign(TIBCustomDataSetCracker(FIBDataSet).SelectSQL);

    if not FIsSQLChanging and (FIBDataSet <> nil) and (SL.Count > 0) and
     (SL.Strings[0] <> FQueryAlias) then
    begin
      ExtractTablesList(SL.Text, TableList);             // ������ ������
      FSelectText.Text := ExtractSQLSelect(SL.Text);     // ����� ������
      FFromText.Text := ExtractSQLFrom(SL.Text);         // ����� ����
      FWhereText.Text := ExtractSQLWhere(SL.Text);       // ����� ���
      FOtherText.Text := ExtractSQLOther(SL.Text);       // ���. �����
      FOrderText.Text := ExtractSQLOrderBy(SL.Text);     // ����� �����
      ExtractFieldLink(SL.Text, FLinkCondition);         // ������ ������

      FIsSQLTextChanged := False;                 // ������ �������
      FilterQuery;                                // ����������� �������
    end;
  finally
    SL.Free;
  end;
end;

procedure TgsQueryFilter.SelfBeforeDisconectDatabase(Sender: TObject);
begin
  if Assigned(FOldBeforeDatabaseDisconect) then
    FOldBeforeDatabaseDisconect(Sender);

  SaveLastFilter;
end;

function TgsQueryFilter.IsIBQuery: Boolean;
begin
  Result := FIBDataSet is TIBQuery;
end;

procedure TgsQueryFilter.SelfBeforeOpen(DataSet: TDataSet);
begin
  SeparateQuery;
  if not FIsFirstOpen then
  begin
    LoadLastFilter;
    CreatePopupMenu;
    FIsFirstOpen := True;
  end;
  if Assigned(FOldBeforeOpen) then
    FOldBeforeOpen(DataSet);
end;

function TgsQueryFilter.GetOwnerName: String;
begin
  if (Owner <> nil) then
    Result := Copy(Owner.Name, 1, FIndexFieldLength)
  else
    Result := '';
end;

procedure TgsQueryFilter.PopupMenu(const X: Integer = -1; const Y: Integer = -1);
var
  Pt: TPoint;
begin
  if FPopupMenu = nil then
    CreatePopupMenu;

  if (X = -1) and (Y = -1) then
  begin
    GetCursorPos(Pt);
    FPopupMenu.Popup(Pt.X, Pt.Y);
  end else
    FPopupMenu.Popup(X, Y);
end;

procedure TgsQueryFilter.DoOnRefresh(Sender: TObject);
begin
  FilterQuery;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsQueryFilter]);
end;

end.
