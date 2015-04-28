
{++

  Copyright (c) 2000-2012 by Golden Software of Belarus

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

  // ����� ���������� �������, ����� �������� ���������� ���� ��������� (~10 sec)
  FMaxExecutionTime = 1 / 24 / 60 / 6;

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

    FFilterData: TFilterData;   // ��������� ��� �������� ������ �������� �������

    FNoVisibleList: TStrings;    // ������ ����� �� ������� �� ���� �������� �������
    FTableList: TStringList;  // ������������ ������� �� ������� ������������ �������
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
    FRequeryParams: Boolean;

    FOnConditionChanged: TConditionChanged;     // ������� �� ��������� �������
    FOnFilterChanged: TFilterChanged;           // ������� �� ��������� ���������� �������

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetTransaction(Value: TIBTransaction);

    procedure SetNoVisibleList(Value: TStrings);
    procedure SetTableList(Value: TStringList);

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
    function GetComponentKey: Integer;

  protected
    FOwnerName: String;         // �������� ��� ��������. � ��������� �� ��� ���������, � ������������ ����.
    FFilterBody: TdlgShowFilter;// ���������� ���� ��� ��������� ���������� �������. ��������� �����.

    function GetFilterPath: String; virtual;
    function CheckFilterVersion(AnFullName: String): Boolean; virtual;

    // ��������� ����� � ������������ ���������� ���������� �������� �������
    procedure SaveFilter;
    // �������� ���� ����������
    procedure ExtractComponentKey;

    // ������� ������� ����� ������� �� ��������
    function CreateSQLText(AFilterData: TFilterData; AnRequeryParams: Boolean;
      var AnSilentParams: Variant; const AShowDlg: Boolean = True): Boolean;

    // ��� ���� ��������� ������ � ����������. ��� ���� ��������.
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

    procedure CheckFilterBody;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // ��������� ������ �� ��� �����
    function LoadFilter(const AnFilterKey: Integer): Boolean;
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

   // �������� ���� ���������� ����������
    property ComponentKey: Integer read GetComponentKey;
    // ������ ������ ��������� �� �������
    property TableList: TStringList read FTableList write SetTableList;
    property FilterData: TFilterData read FFilterData;

  published
    property OnConditionChanged: TConditionChanged read FOnConditionChanged write FOnConditionChanged;
    property OnFilterChanged: TFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    // ������ �������������� �����
    property NoVisibleList: TStrings read FNoVisibleList write SetNoVisibleList;
    // ���� �������� ����� �� ��������� �� ����� ������������� ��� ��������� ��������
    // ���� �� ������ ��� ������
    property RequeryParams: Boolean read FRequeryParams write FRequeryParams;
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

    //FParamItemIndex: Integer;
    FRecordCount: Integer;      // ���������� ������� � �������

    FIsFirstOpen: Boolean;      // ���� ������� ��������. ��� ��������� �������� � ������ ������� ��������
    FIsSQLChanging: Boolean;      // ??? ��������� ������������� ������� ���������
    FIsLastSave: Boolean;       // ���� ��� �� �������� ��������� ������

    FLastQueriedParams: Variant;

    procedure SetQuery(Value: TIBCustomDataSet);

    procedure SelfBeforeDisconectDatabase(Sender: TObject);
    procedure SelfBeforeOpen(DataSet: TDataSet);
    procedure SelfOnShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure SeparateQuery;

    procedure DoOnUpdate(Sender: TObject);
    procedure DoOnUpdate2(Sender: TObject);
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

    // ����������� ��������������
    procedure ShowWarning;

    // ��������� ���������� �������
    function GetRecordCount: Integer;

    // ������� ����������� �������� ���� ���������� AnEnabled
    procedure SetEnabled(const AnEnabled: Boolean);

    function IsIBQuery: Boolean;

  protected
    function GetOwnerName: String; virtual;

    procedure DoOnWriteToFile(Sender: TObject);
    procedure DoOnReadFromFile(Sender: TObject);

    function GetDBVersion: String;      // �������� ������ ���� ������
    function GetCRC: Integer;           // �������� CRC �������
    // ���������� ������ ��������
    function CompareVersion(const OldCRC: Integer; const DBVersion: String; const Question: Boolean): Boolean;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure FillPopupMenu(AnSender: TObject); virtual;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property RecordCount: Integer read GetRecordCount;
    property LastQueriedParams: Variant read FLastQueriedParams;

    procedure FilterQuery(AnSilentParams: Variant; const AShowDlg: Boolean = True);      // ������������� �������
    procedure RevertQuery;      // �������� �������

    procedure CreatePopupMenu;  // ������� ����

    procedure SaveLastFilter;   // ��������� ��������� ������
    procedure LoadLastFilter;   // ��������� ��������� ������

    procedure PopupMenu(const X: Integer = -1; const Y: Integer = -1);
    procedure CheckMenuState;

    procedure CreateFilterExecute;     // �������� ������ �������
    procedure EditFilterExecute;       // ��������������
    procedure DeleteFilterExecute;     // ��������

    procedure FilterBackExecute;       // ������
    procedure ViewFilterListExecute;   // ��������� ������ ��������
    procedure ShowRecordCountExecute;      // ������ ���������� ������� � �������
    procedure RefreshExecute;          //  ���������� ����������
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

procedure ClearFltComponentCache;

implementation

uses
  gd_directories_const, flt_msgBeforeFilter_unit, Registry,
  flt_dlgFilterList_unit, jclSelected, flt_ScriptInterface,
  contnrs, IB, IBErrorCodes, gd_keyassoc, gdcBase, gdcClasses,
  flt_sqlFilterCache, IBBLOB, Inst_Const
  {$IFDEF GEDEMIN}
  , JclFileUtils, Storages, gdcBaseInterface
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
  , gd_localization_stub
  {$ENDIF}
  ;

type
  TCrackerIBXSQLDA = class(TIBXSQLDA);

var
  FltComponentCache: TgdKeyIntAssoc;

procedure ClearFltComponentCache;
begin
  if Assigned(FltComponentCache) then
  begin
    FltComponentCache.Clear;
  end;
end;

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
    if Assigned(FFilterBody) then
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

procedure TgsSQLFilter.SetTableList(Value: TStringList);
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
var
  DidActivate: Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
  begin
    Transaction.StartTransaction;
    DidActivate := True;
  end else
    DidActivate := False;
  try
    CheckFilterBody;
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
  finally
    // ��������� ����������
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;    
end;

function TgsSQLFilter.EditFilter(out AnFilterKey: Integer): Boolean;
var
  DidActivate: Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
  begin
    Transaction.StartTransaction;
    DidActivate := True;
  end else
    DidActivate := False;
  CheckFilterBody;
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
  if DidActivate and Transaction.InTransaction then
    Transaction.Commit;
end;

function TgsSQLFilter.DeleteFilter: Boolean;
var
  DidActivate: Boolean;
begin
  // �������� ����������
  if not Transaction.InTransaction then
  begin
    Transaction.StartTransaction;
    DidActivate := True;
  end else
    DidActivate := False;
  CheckFilterBody;
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
  if DidActivate and Transaction.InTransaction then
    Transaction.Commit;
end;

// ��������� ��������� �������� �������
procedure TgsSQLFilter.SaveFilter;
var
  TempSQL: TIBSQL;
  DidActivate: Boolean;
begin
  if (FCurrentFilter = 0) or (Transaction = nil)
    or (not Transaction.DefaultDatabase.Connected) then
  begin
    Exit;
  end;
  
  DidActivate := False;
  TempSQL := TIBSQL.Create(nil);
  try
    // �������� ����������
    if not Transaction.InTransaction then
    begin
      Transaction.StartTransaction;
      DidActivate := True;
    end;
    // ����������� ���������
    TempSQL.Transaction := Transaction;
    // ������ �������
    TempSQL.SQL.Text := 'UPDATE flt_savedfilter SET lastextime = :lasttime, readcount = readcount + :deltaread WHERE id = :id';
    TempSQL.ParamByName('id').AsInteger := FCurrentFilter;
    TempSQL.ParamByName('lasttime').AsDateTime := FLastExecutionTime;
    TempSQL.ParamByName('deltaread').AsInteger := FDeltaReadCount;
    try
      // �������� ���������
      TempSQL.ExecQuery;
    except
      // ��������� ������
      on E: Exception do
        MessageBox(0, @E.Message[1], '��������',
          MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
    TempSQL.Free;
    
    // ��������� ����������
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

// �������� �������
function TgsSQLFilter.LoadFilter(const AnFilterKey: Integer): Boolean;
var
  TempSQL: TIBSQL;
  bs: TIBBlobStream;
begin
  {$IFDEF GEDEMIN}
  Assert(Assigned(gdcBaseManager));
  {$ENDIF}

  Result := True;
  TempSQL := TIBSQL.Create(nil);
  try
    FFilterData.Clear;
    // ����������� ���������
    {$IFDEF GEDEMIN}
    TempSQL.Transaction := gdcBaseManager.ReadTransaction;
    {$ENDIF}
    // ����� �������
    TempSQL.SQL.Text := 'SELECT id, name, description, lastextime, data FROM flt_savedfilter WHERE id = :ID';
    TempSQL.ParamByName('id').AsInteger := AnFilterKey;
    try
      // �������� ��������� ������
      TempSQL.ExecQuery;
      // ���� ������
      if not TempSQL.Eof then
      begin
        // ��������� ��������� �������
        FCurrentFilter := TempSQL.FieldByName('id').AsInteger;
        FFilterName := TempSQL.FieldByName('name').AsString;
        FFilterComment := TempSQL.FieldByName('description').AsString;
        FLastExecutionTime := TempSQL.FieldByName('lastextime').AsDateTime;
        FDeltaReadCount := 0;

        bs := TIBBlobStream.Create;
        try
          bs.Mode := bmRead;
          bs.Database := TempSQL.Database;
          bs.Transaction := TempSQL.Transaction;
          bs.BlobID := TempSQL.FieldByName('data').AsQuad;
          FFilterData.ReadFromStream(bs);
        finally
          bs.Free;
        end;

        if Assigned(FOnFilterChanged) then
          FOnFilterChanged(Self, FCurrentFilter);
      end else
      begin
        Result := False;

        // �� ����� ������ �� �������
        // ���� ������ �� �������� � ����� � �����
        // ��������� ���� � ��������� �������
        // ����� ������ ��� ���� ��� ������ �� ����
        //raise Exception.Create('��������� ������ �� ������');
      end;
    except
      // ������������ ������
      on E: Exception do
        MessageBox(0, @E.Message[1], '��������', MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
  finally
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
  Result := FFilterData.FilterText;
  if Result > '' then
    Result := Result + #13#10#13#10;
  Result := Result + FFilterData.OrderText;
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
var
  Params: Variant;
begin
  Params := NULL;
  Result := CreateSQLText(FFilterData, FRequeryParams, Params);
end;

// ������� ��������� SQL
function TgsSQLFilter.CreateSQLText(AFilterData: TFilterData; AnRequeryParams: Boolean; var AnSilentParams: Variant;
  const AShowDlg: Boolean = True): Boolean;
var
  sFormName: string;
begin
  sFormName:= '';

  if (Owner is TgdcBase) and (Owner.Owner is TCustomForm) and
    (Owner.Owner as TCustomForm).Visible then
    sFormName:= TCustomForm(Owner.Owner).Caption
  else if (Owner is TCustomForm) and (Owner as TCustomForm).Visible then
    sFormName:= TCustomForm(Owner).Caption
  else if (Owner is TgdcBase) then
  begin
    if Owner is TgdcDocument then
      sFormName:= TgdcDocument(Owner).DocumentName
    else
      sFormName:= TgdcBase(Owner).GetDisplayName(TgdcBase(Owner).SubType);
  end;    

  Result := CreateCustomSQL(AFilterData, FSelectText, FFromText, FWhereText,
    FOtherText, FOrderText, FQueryText, FTableList, FComponentKey, FCurrentFilter,
    AnRequeryParams, AnSilentParams, AShowDlg, sFormName, FFilterName);
end;

procedure TgsSQLFilter.SetQueryText(const AnSQLText: String);
var
  SelectSQL, FromSQL, WhereSQL, OtherSQL, OrderSQL: String;
begin
  ExtractAllSQL(AnSQLText, SelectSQL, FromSQL, WhereSQL,
    OtherSQL, OrderSQL);

  FSelectText.Text := SelectSQL;
  FFromText.Text := FromSQL;
  FWhereText.Text := WhereSQL;
  FOtherText.Text := OtherSQL;
  FOrderText.Text := OrderSQL;
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

procedure TgsSQLFilter.CheckFilterBody;
begin
  if not Assigned(FFilterBody) then
    FFilterBody := TdlgShowFilter.Create(Self);
end;

function TgsSQLFilter.GetFilterPath: String;
{$IFDEF GEDEMIN}
var
  FVI: TJclFileVersionInfo;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  FVI := JclFileUtils.TJclFileVersionInfo.Create(Application.ExeName);
  try
    Result := FVI.OriginalFilename;
  finally
    FVI.Free;
  end;
  if Result = '' then
  {$ENDIF}
    Result := ExtractFileName(Application.ExeName);
  Result := AnsiUpperCase(Copy(ChangeFileExt(Result, '') + '\' +
    FOwnerName + '\' + Name, 1, 255));
end;

function TgsSQLFilter.CheckFilterVersion(AnFullName: String): Boolean;
begin
  Result := False;
end;

function TgsSQLFilter.GetComponentKey: Integer;
begin
  ExtractComponentKey;
  Result := FComponentKey;
end;

{TgsQueryFilter}

constructor TgsQueryFilter.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    FIsSQLChanging := False;
    FIsFirstOpen := False;
    FIsCompKey := False;
    FIsLastSave := False;
    FOwnerName := GetOwnerName;// ������������ ���������
    FActionList := TActionList.Create(Self);
    FActionList.Name := 'al' + Self.Name;
    FRecordCount := -1;
    FRequeryParams := True;

    CreateActions;
    if (Owner <> nil) and (Owner is TForm) then
    begin
      FOldShortCut := (Owner as TForm).OnShortCut;
      (Owner as TForm).OnShortCut := SelfOnShortCut;
    end;

    FLastQueriedParams := NULL;
  end;
end;

destructor TgsQueryFilter.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    // ��������� ��������� ������
    SaveLastFilter;
    // ����������� ������������
    if Assigned(FMessageDialog) then
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
begin
  CreateFilterExecute;
end;

procedure TgsQueryFilter.DoOnEditFilter(Sender: TObject);
begin
  EditFilterExecute;
end;

procedure TgsQueryFilter.DoOnDeleteFilter(Sender: TObject);
begin
  DeleteFilterExecute;
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
        FilterQuery(NULL);
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
  ShowRecordCountExecute;
end;

// ������� ������� ����������
procedure TgsQueryFilter.DoOnFilterBack(Sender: TObject);
begin
  FilterBackExecute;
end;

procedure TgsQueryFilter.DoOnSelectFilter(Sender: TObject);
begin
  // ������ ���������� ��������
  SetEnabled(True);
  // ���� ������ �������, �� �������
  if (Sender as TMenuItem).Tag = FCurrentFilter then
  begin
    RefreshExecute;  
    Exit;
  end;
  // ��������� �������
  SaveFilter;
  // ��������
  (Sender as TMenuItem).Checked := True;
  // ���������
  if LoadFilter((Sender as TMenuItem).Tag) then
  begin
    FSuppressWarning := True;
    try
      FilterQuery(NULL);
    finally
      FSuppressWarning := False;
    end;
  end else
    CreatePopupMenu;
end;

procedure TgsQueryFilter.DoOnViewFilterList(Sender: TObject);
begin
  ViewFilterListExecute;
end;

procedure TgsQueryFilter.FilterQuery(AnSilentParams: Variant;
  const AShowDlg: Boolean = True);
var
  Flag: Boolean;
  StartTime: TTime;
  ParamList: TStringList;
  I: Integer;
  LastTrState: Boolean;
  V: PVariant;
begin
  // ���������� ���������
  Flag := FIBDataSet.Active;

  // ���������� ��������������
  if Flag then
    ShowWarning;

  FIsSQLChanging := True;

  // ������� �����
  FIBDataSet.DisableControls;
  try
    if CreateSQLText(FFilterData, FIBDataSet.Active or FRequeryParams,
      AnSilentParams, AShowDlg) then
    begin
      FLastQueriedParams := AnSilentParams;

      ParamList := TStringList.Create;
      try
        if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
        begin
          for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
          begin
            if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
            begin
              New(V);
              V^ := TIBCustomDataSetCracker(FIBDataSet).Params[I].AsVariant;
              ParamList.AddObject(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
                TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString, Pointer(V));
            end;
          end;
        end;

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
        begin
          try
            if TCrackerIBXSQLDA(TIBCustomDataSetCracker(FIBDataSet).Params).GetXSQLVARByName(ParamList.Names[I]) <> nil then
            begin
              //TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsString := ParamList.ValuesOfIndex[I];
              TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsVariant := PVariant(ParamList.Objects[I])^;
            end;
          except
          end;
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
            if not Assigned(FMessageDialog) then
              FMessageDialog := TmsgShowMessage.Create(Self); // ������� �.�. ��������� �������

            FMessageDialog.Show;
            Application.ProcessMessages;
            if Application.Terminated then
              exit;
          end;

          try
            StartTime := Now;
            FIBDataSet.Open;
            FLastExecutionTime := Now - StartTime;
          finally
            if Assigned(FMessageDialog) then
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
        for I := 0 to ParamList.Count - 1 do
        begin
          V := PVariant(ParamList.Objects[I]);
          Dispose(V);
        end;
        ParamList.Free;
      end;
    end else
    begin
      // ���� �� ������� ������� �������
      // �� ��������� �������
      if FIBDataSet.Active then
        FIBDataSet.Close;

      // ���������� ������ � �������� ���������
      RevertQuery;

      // ��������� ���� �� ��� ������
      if Flag then
      begin
        FIBDataSet.Open;
      end;

      // ������� ������ ����
      CreatePopupMenu;
    end;
  finally
    FIBDataSet.EnableControls;
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

  FPopupMenu.HelpContext := 6;  
  MakePopupMenu(FPopupMenu);
end;

procedure TgsQueryFilter.SaveLastFilter;
begin
  if (not FIsFirstOpen) or FIsLastSave then
    exit;

  ExtractComponentKey;
  SaveFilter;

  flt_sqlFilterCache.SetLastFilterKey(FComponentKey, FCurrentFilter);

  // ������������� ���� � ���������� ���������� �������
  FIsLastSave := True;
  // ������������� ���� � ������ ��������
  FIsFirstOpen := False;
end;

// �������� ��������� ������
procedure TgsQueryFilter.LoadLastFilter;
var
  LFK: Integer;
begin
  if (GetAsyncKeyState(VK_SHIFT) shr 1) <> 0 then
    exit;

  // ���� ����������
  ExtractComponentKey;

  LFK := GetLastFilterKey(FComponentKey);
  if LFK > -1 then
  begin
    // ���� ������, �� ���������
    LoadFilter(LFK);
    {$IFDEF GEDEMIN}
    if Assigned(UserStorage) then
    begin
      FilterQuery(NULL,
        UserStorage.ReadBoolean('Options', 'FilterParams', True, False))
    end else
    {$ENDIF}
      FilterQuery(NULL, True);
  end;

  FIsLastSave := False;
end;

procedure TgsQueryFilter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FIBDataSet) then
    FIBDataSet := nil;
  if (Operation = opRemove) and Assigned(FBase) and (AComponent = DataBase) then
    FBase.DataBase := nil;
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
{var
  TempS: String;
  ArBt: TArrByte;}
begin
  {TempS := FSelectText.Text + FFromText.Text + FWhereText.Text + FOtherText.Text + FOrderText.Text;
  SetLength(ArBt, Length(TempS) * SizeOf(Char));
  ArBt := Copy(TArrByte(TempS), 0, Length(TempS) * SizeOf(Char));}
  // ���������������� �� ������ ����
{  Result := ((CheckCrc32(ArBt, Length(ArBt), Cardinal(OldCRC)) = 0)
   and (DBVersion = GetDBVersion))
   or (
     MessageBox(0,
       '������ ��������� ��� ���� ������ ���� ��������.'#13#10 +
       '�� ������ ��������� ��������� ������?',
       '��������',
       MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);}
  Result := True;
end;

// ��������� ���� ����������
procedure TgsSQLFilter.ExtractComponentKey;
var
  ibsqlComp: TIBSQL;
  FltName: String[21];
  FullFltName: String;
  DidActivate: Boolean;
  CreateNew: Boolean;
  OldOwnerForm: String;
  I: Integer;

  function GetCRC32(const Text: String): Integer;
  begin
    Result := Integer(Crc32_P(@Text[1], Length(Text), 0));
  end;

begin
  if FIsCompKey then
    exit;

  if (Database = nil) or (not Database.Connected) or (Transaction = nil) then
    exit;

  FullFltName := GetFilterPath;
  FltName := Copy(Name, 1, FIndexFieldLength);

  if Assigned(Owner) then
    OldOwnerForm := Copy(Owner.Name, 1, FIndexFieldLength)
  else
    OldOwnerForm := '';

  if (Assigned(FltComponentCache)) and (FltComponentCache.Count > 0) then
  begin
    I := FltComponentCache.IndexOf(GetCRC32(FullFltName + OldOwnerForm));
    if I >= 0 then
    begin
      FComponentKey := FltComponentCache.ValuesByIndex[I];
      FIsCompKey := True;
      exit;
    end;
  end;

  DidActivate := False;
  ibsqlComp := TIBSQL.Create(Self);
  try
    {$IFDEF GEDEMIN}
    ibsqlComp.Transaction := gdcBaseManager.ReadTransaction;
    {$ELSE}
    if not Transaction.InTransaction then
    begin
      Transaction.StartTransaction;
      DidActivate := True;
    end;
    ibsqlComp.Transaction := Transaction;
    {$ENDIF}
    ibsqlComp.SQL.Text := 'SELECT id FROM flt_componentfilter WHERE crc = :crc and ' +
      ' fullname = :fullname and formname = :fname  ';
    ibsqlComp.ParamByName('crc').AsInteger := GetCRC32(FullFltName);
    ibsqlComp.ParamByName('fullname').AsString := FullFltName;
    ibsqlComp.ParamByName('fname').AsString := OldOwnerForm;
    ibsqlComp.ExecQuery;

    if not ibsqlComp.Eof  then
      FComponentKey := ibsqlComp.Fields[0].AsInteger
    else
    begin
      ibsqlComp.Close;
      ibsqlComp.SQL.Text :=
        'SELECT * FROM flt_componentfilter WHERE formname = :FN '
        + ' AND filtername = :FLTN '
        + ' AND applicationname = :AN ';
      ibsqlComp.ParamByName('FN').AsString := OldOwnerForm;
      ibsqlComp.ParamByName('FLTN').AsString := FltName;
      ibsqlComp.ParamByName('AN').AsString := GetApplicationName;
      ibsqlComp.ExecQuery;
      CreateNew := True;
      if not ibsqlComp.Eof then
      begin
        FComponentKey := ibsqlComp.FieldByName('id').AsInteger;
        if ibsqlComp.FieldByName('fullname').IsNull or
          CheckFilterVersion(ibsqlComp.FieldByName('fullname').AsString) then
        begin
          ibsqlComp.Close;

          {$IFDEF GEDEMIN}
          if not Transaction.InTransaction then
          begin
            Transaction.StartTransaction;
            DidActivate := True;
          end;
          ibsqlComp.Transaction := Transaction;
          {$ENDIF}

          ibsqlComp.SQL.Text :=
            'UPDATE flt_componentfilter SET crc = :CRC, fullname = :FullName' +
            '  WHERE id = :ID';
          ibsqlComp.ParamByName('crc').AsInteger := GetCRC32(FullFltName);
          ibsqlComp.ParamByName('FullName').AsString := FullFltName;
          ibsqlComp.ParamByName('id').AsInteger := FComponentKey;
          ibsqlComp.ExecQuery;
          ibsqlComp.Close;
          CreateNew := False;
        end;
      end;
      if CreateNew then
      begin
        try
          {$IFDEF GEDEMIN}
          ibsqlComp.Close;
          if not Transaction.InTransaction then
          begin
            Transaction.StartTransaction;
            DidActivate := True;
          end;
          ibsqlComp.Transaction := Transaction;
          {$ENDIF}

          {$IFNDEF GEDEMIN}
          ibsqlComp.SQL.Text := 'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM rdb$database';
          ibsqlComp.ExecQuery;
          FComponentKey := ibsqlComp.Fields[0].AsInteger;
          {$ELSE}
          FComponentKey := gdcBaseManager.GetNextID;
          {$ENDIF}
          ibsqlComp.Close;
          ibsqlComp.SQL.Text :=
            'INSERT INTO flt_componentfilter (id, formname, ' +
              'filtername, applicationname, crc, fullname) ' +
            'VALUES(' + IntToStr(FComponentKey) + ',''' + OldOwnerForm + ''',''' + FltName +
            ''',''' + GetApplicationName + ''',' + IntToStr(GetCRC32(FullFltName)) +
            ',''' + FullFltName + ''')';
          ibsqlComp.ExecQuery;
        except
        end;
      end;
    end;

    if Assigned(FltComponentCache) and (FComponentKey > 0) then
    begin
      FltComponentCache.ValuesByIndex[
        FltComponentCache.Add(GetCRC32(FullFltName + OldOwnerForm))] := FComponentKey;
    end;
  finally
    FIsCompKey := True;
    ibsqlComp.Free;

    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

// ������������ ����������
function TgsSQLFilter.GetApplicationName: String;
{$IFDEF GEDEMIN}
var
  FVI: TJclFileVersionInfo;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if VersionResourceAvailable(Application.EXEName) then
  begin
    FVI := JclFileUtils.TJclFileVersionInfo.Create(Application.ExeName);
    try
      Result := FVI.OriginalFilename;
    finally
      FVI.Free;
    end;
  end else
    Result := '';
  if Result = '' then
  {$ENDIF}
    Result := ExtractFileName(Application.ExeName);
  Result := Copy(UpperCase(ChangeFileExt(Result, '')), 1, FIndexFieldLength);
end;

// ���������� ��������������
procedure TgsQueryFilter.ShowWarning;
var
  F: TmsgBeforeFilter;
  Reg: TRegistry;
begin
  if FLastExecutionTime > FMaxExecutionTime then
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cClientRegPath) then
      begin
        if Reg.ValueExists('LongFltWarn') and (Reg.GetDataType('LongFltWarn') = rdInteger)
          and (not Reg.ReadBool('LongFltWarn')) then
        begin
          Reg.CloseKey;
          exit;
        end;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    F := TmsgBeforeFilter.Create(Self);
    try
      F.ShowModal;
      if F.cbVisible.Checked then
      begin
        Reg := TRegistry.Create(KEY_WRITE);
        try
          Reg.RootKey := HKEY_CURRENT_USER;
          if Reg.OpenKey(cClientRegPath, True) then
          begin
            Reg.WriteBool('LongFltWarn', False);
            Reg.CloseKey;
          end;
        finally
          Reg.Free;
        end;
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
  ibsqlCount: TIBSQL;
  OldRecNo: Integer;
  I, J: Integer;
  ParamList: TStringList;
  Tr: TIBTransaction;
  V: PVariant;
begin
  Assert(Assigned(FIBDataSet));

  // ���� ������� ����������� �� �������, �� ���������� ������ ���
  if FIBDataSet.Filtered then
  begin
    // FetchAll ������ �� ��� ���� ��� ��������
    // ���� ������� �������
    FIBDataSet.FetchAll;
    Result := FIBDataSet.RecordCount;
    FRecordCount := -1;
    Exit;
  end;

  // ���� ���������� ������� �� ����������
  if FRecordCount = -1 then
  begin
    if FIBDataSet.Active then
    begin
      // ��������� ������ �������� �������
      OldRecNo := FIBDataSet.RecNo;
      FIBDataSet.DisableControls;
      try
        // ����������� ������� ������ ���������� ��������� �������
        FIBDataSet.RecNo := FIBDataSet.RecordCount;
        // �������� ������� ���������
        FIBDataSet.Next;
        // ���� �� ������� ������ ������� ��� ������
        if FIBDataSet.Eof then
          FRecordCount := FIBDataSet.RecordCount;
      finally
        // ��������������� �������� �������
        FIBDataSet.RecNo := OldRecNo;
        FIBDataSet.EnableControls;
      end;
    end;

    // ���� ��������� ������� �� ����� ������� ���� ������ ������������ ����������
    if FRecordCount = -1 then
    begin
      Tr := TIBTransaction.Create(nil);
      Tr.Params.Text := 'read';
      Tr.DefaultDatabase := FIBDataSet.Database;
      Tr.StartTransaction;

      ibsqlCount := TIBSQL.Create(nil);
      ibsqlCount.Database := FIBDataSet.Database;
      ibsqlCount.Transaction := Tr;

{      if (FIBDataSet.Database.IsFirebirdConnect) and (FIBDataSet.Database.ServerMajorVersion >= 2) then
      begin
        ibsqlCount.SQL.Text := 'SELECT COUNT(*) FROM ( ' + TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Text + ' ) ';
        for I := 0 to Pred(TIBCustomDataSetCracker(FIBDataSet).Params.Count) do
          ibsqlCount.Params[I].Value := TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ibsqlCount.Params[I].Name).Value;
        try
          ibsqlCount.ExecQuery;
          if ibsqlCount.Eof then
            FRecordCount := 0
          else
            FRecordCount := ibsqlCount.Fields[0].AsInteger;

        finally
          ibsqlCount.Free;
          Tr.Free;
        end;
      end else
      begin     }
        ParamList := TStringList.Create;
        try
          with ibsqlCount, TIBCustomDataSetCracker(FIBDataSet) do
          begin
            SQL.Text := 'SELECT COUNT(*)';
            SQL.Add(ExtractSQLFrom(SelectSQL.Text));
            SQL.Add(ExtractSQLWhere(SelectSQL.Text));
            SQL.Add(ExtractSQLOther(SelectSQL.Text));
            //SQL.Add(ExtractSQLOrderBy(SelectSQL.Text));
          end;

          with TIBCustomDataSetCracker(FIBDataSet) do
          begin
            for I := 0 to Params.Count - 1 do
            begin
              if (ParamList.IndexOfName(Params[I].Name) = -1) and (not Params[I].IsNull) then
              begin
                New(V);
                V^ := Params[I].AsVariant;
                ParamList.AddObject(Params[I].Name + '=' + Params[I].AsString, Pointer(V));
              end;
            end;
          end;

          // �� �� ����� ������������ ������������, � ���������
          // ����������� ������ ���������� ��� ��� ��������� ���������
          // ����� �������������� � ����� ������, ������� �� ��������
          for I := 0 to ParamList.Count - 1 do
          begin
            for J := 0 to ibsqlCount.Params.Count - 1 do
            begin
              if AnsiCompareText(ParamList.Names[I], ibsqlCount.Params[J].Name) = 0 then
              begin
                ibsqlCount.Params[J].AsVariant := PVariant(ParamList.Objects[I])^;
              end;
            end;
          end;

          try
            ibsqlCount.ExecQuery;
            ibsqlCount.Next;
            if ibsqlCount.Eof then
              // ����������� ���������� �������
              FRecordCount := ibsqlCount.Fields[0].AsInteger
            else
            begin
              while not ibsqlCount.Eof do
                ibsqlCount.Next;
              FRecordCount := ibsqlCount.RecordCount;
            end;
          except
            on E: EIBError do
            begin
              // ���� ������ � ������� �� ��� ������ ��
              // ���������� ����������. ���� ����������� ��� ��
              // �������.
              if E.IBErrorCode = isc_dsql_error then
              begin
                // ��������� ������ �������� �������
                OldRecNo := FIBDataSet.RecNo;
                FIBDataSet.DisableControls;
                try
                  FIBDataSet.Last;
                  FRecordCount := FIBDataSet.RecordCount;
                finally
                  // ��������������� �������� �������
                  FIBDataSet.RecNo := OldRecNo;
                  FIBDataSet.EnableControls;
                end;
              end else
                raise;
            end else
              raise;
          end;

          ibsqlCount.Close;
          Tr.Commit;
        finally
          for I := 0 to ParamList.Count - 1 do
          begin
            V := PVariant(ParamList.Objects[I]);
            Dispose(V);
          end;
          ParamList.Free;
          ibsqlCount.Free;
          Tr.Free;
        end;
{      end; }
    end;
  end;

  Result := FRecordCount;

end;

procedure TgsQueryFilter.CreateActions;
begin
  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������� ������...';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnCreateFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnUpdate := DoOnUpdate;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('N'), [ssCtrl]);

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ������...';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnEditFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnUpdate := DoOnUpdate2;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('E'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������� ������...';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnDeleteFilter;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnUpdate := DoOnUpdate2;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('D'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;
  {$IFDEF GEDEMIN}
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Visible := IBLogin.IsIBUserAdmin;
  {$ENDIF}

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ����������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnFilterBack;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('B'), [ssCtrl]);
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Tag := 1;

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '���������� �������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRecordCount;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('C'), [ssCtrl]);

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '������ ��������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnViewFilterList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnUpdate := DoOnUpdate;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(Word('L'), [ssCtrl]);

  with TAction.Create(FActionList) do
    ActionList := FActionList;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Caption := '�������� ������';
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).OnExecute := DoOnRefresh;
  TAction(FActionList.Actions[FActionList.ActionCount - 1]).Name := 'act' + IntToStr(FActionList.ActionCount);
  //TAction(FActionList.Actions[FActionList.ActionCount - 1]).ShortCut := ShortCut(VK_F5, [ssCtrl]);
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
  DidActivate: Boolean;
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

  DidActivate := False;
  ibsqlFilterList := TIBSQL.Create(Self);
  try
    ExtractComponentKey;

    FlagSearch := False;
    ibsqlFilterList.Database := Database;
    ibsqlFilterList.Transaction := Transaction;

    if not Transaction.InTransaction then
    begin
      Transaction.StartTransaction;
      DidActivate := True;
    end;

    // ���������� ������ ��������
    ibsqlFilterList.SQL.Text :=
      'SELECT id, name ' +
      'FROM flt_savedfilter ' +
      'WHERE ' +
      ' componentkey = :CK ' +
      ' AND (userkey = :UK OR userkey IS NULL) ' +
      'ORDER BY name';
    ibsqlFilterList.ParamByName('CK').AsInteger := FComponentKey;
    if IBLogin <> nil then
      ibsqlFilterList.ParamByName('UK').AsInteger := IBLogin.UserKey
    else
      ibsqlFilterList.ParamByName('UK').AsInteger := ADMIN_KEY;
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
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;

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
  ParamList: TStringList;
  I: Integer;
  V: PVariant;
var
  Flag: Boolean;
begin
  Assert(Assigned(FIBDataSet));

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
  FQueryText.Add(cQueryAlias);
  FQueryText.AddStrings(FSelectText);
  FQueryText.AddStrings(FFromText);
  FQueryText.AddStrings(FWhereText);
  FQueryText.AddStrings(FOtherText);
  FQueryText.AddStrings(FOrderText);

  FIBDataSet.DisableControls;
  try
    ParamList := TStringList.Create;
    try
      if TIBCustomDataSetCracker(FIBDataSet).InternalPrepared then
      begin
        for I := 0 to TIBCustomDataSetCracker(FIBDataSet).Params.Count - 1 do
        begin
          if ParamList.IndexOfName(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name) = -1 then
          begin
            New(V);
            V^ := TIBCustomDataSetCracker(FIBDataSet).Params[I].AsVariant;
            ParamList.AddObject(TIBCustomDataSetCracker(FIBDataSet).Params[I].Name + '=' +
              TIBCustomDataSetCracker(FIBDataSet).Params[I].AsString, Pointer(V));
          end;
        end;
      end;

      FIBDataSet.Close;

      // ����������� ����� �������
      if IsIBQuery then
        TIBQuery(FIBDataSet).SQL.Assign(FQueryText)
      else
        TIBCustomDataSetCracker(FIBDataSet).SelectSQL.Assign(FQueryText);

      for I := 0 to ParamList.Count - 1 do
        try
          if TCrackerIBXSQLDA(TIBCustomDataSetCracker(FIBDataSet).Params).GetXSQLVARByName(ParamList.Names[I]) <> nil then
          begin
          //if TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]) <> nil then
            TIBCustomDataSetCracker(FIBDataSet).Params.ByName(ParamList.Names[I]).AsVariant := PVariant(ParamList.Objects[I])^;
          end;
        except
        end;
    finally
      for I := 0 to ParamList.Count - 1 do
      begin
        V := PVariant(ParamList.Objects[I]);
        Dispose(V);
      end;
      ParamList.Free;
    end;

    FRecordCount := -1;
    // ��������� ���� ����
    if Flag then
    try
      try
        FIBDataSet.Open;
      except
        on E: EDatabaseError do
        begin
          FIBDataSet.Fields.Clear;
          FIBDataSet.Open;
        end else
          raise;
      end;
    except
      on E: EDatabaseError do
        MessageBox(0, PChar(
          '������� ��������� ������.'#13#10#13#10 + E.Message),
          '��������',
          MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    end;
    FIsSQLChanging := False;
  finally
    FIBDataSet.EnableControls;
  end;

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
  SL: TStrings;
  S: String;
  SelectSQL, FromSQL, WhereSQL, OtherSQL, OrderSQL: String;
begin
  FRecordCount := -1;
  SL := TIBCustomDataSetCracker(FIBDataSet).SelectSQL;

  if not FIsSQLChanging and (FIBDataSet <> nil) and (SL.Count > 0) and
   (SL.Strings[0] <> cQueryAlias) then
  begin
    S := SL.Text;
    ExtractTablesList(S, TableList);             // ������ ������
    ExtractAllSQL(S, SelectSQL, FromSQL, WhereSQL,
      OtherSQL, OrderSQL);
    FSelectText.Text := SelectSQL;     // ����� ������
    FFromText.Text := FromSQL;         // ����� ����
    FWhereText.Text := WhereSQL;       // ����� ���
    FOtherText.Text := OtherSQL;       // ���. �����
    FOrderText.Text := OrderSQL;       // ����� �����
    ExtractFieldLink(S, FLinkCondition);         // ������ ������

    FIsSQLTextChanged := False;                 // ������ �������
    FilterQuery(NULL, False);
  end;
end;

procedure TgsQueryFilter.SelfBeforeDisconectDatabase(Sender: TObject);
begin
  if Assigned(FOldBeforeDatabaseDisconect) then
    FOldBeforeDatabaseDisconect(Sender);

  if (Database <> nil) and Database.Connected then
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
    //CreatePopupMenu;
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

  CheckMenuState;

  if (X = -1) and (Y = -1) then
  begin
    GetCursorPos(Pt);
    FPopupMenu.Popup(Pt.X, Pt.Y);
  end else
    FPopupMenu.Popup(X, Y);
end;

procedure TgsQueryFilter.DoOnRefresh(Sender: TObject);
begin
  RefreshExecute;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsQueryFilter]);
end;

procedure TgsQueryFilter.CreateFilterExecute;
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
      FilterQuery(NULL);
    end;

    // ������� ����
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.DeleteFilterExecute;
begin
  // �������� ��������
  if DeleteFilter then
  begin
    RevertQuery;
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.EditFilterExecute;
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
      FilterQuery(NULL);
    end;
    // ������� ����
    CreatePopupMenu;
  end;
end;

procedure TgsQueryFilter.FilterBackExecute;
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

procedure TgsQueryFilter.ShowRecordCountExecute;
begin
  MessageBox(0, PChar('���������� ������� � ������� �������: ' + FormatFloat('#,##0', RecordCount)),
   '����������', MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure TgsQueryFilter.RefreshExecute;
begin
  FilterQuery(NULL);
end;

procedure TgsQueryFilter.ViewFilterListExecute;
var
  F: TdlgFilterList;
  I: Integer;
  Flag, DidActivate: Boolean;  // ���� �� ���������
begin
  // ������� ����
  DidActivate := False;
  F := TdlgFilterList.Create(Self);
  try
    // �������� ����������
    if not Transaction.InTransaction then
    begin
      Transaction.StartTransaction;
      DidActivate := True;
    end;

    // ����������� ���������
    F.ibsqlFilter.Database := Database;
    F.ibsqlFilter.Transaction := Transaction;

    FillPopupMenu(F.PopupMenu);

    // �������� ���� ���������� �������
    I := F.ViewFilterList(FComponentKey, Flag, FSelectText.Text + FFromText.Text +
     FWhereText.Text + FOtherText.Text + FOrderText.Text);

    // ��������� �������� ����������
    if I <> 0 then
    begin
      SaveFilter;
      LoadFilter(I);
      FilterQuery(NULL);
    end;

    if Flag then
      CreatePopupMenu;
  finally
    F.Free;

    // ��������� ����������
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

{ TODO -oJKL -cQueryFilter :
����� ��������� ������ � ����������� ������������
���� ��������� ������� �������. ������ �� � ��������. }
procedure TgsQueryFilter.CheckMenuState;
var
  I: Integer;
  TagFlag: Boolean;
begin
  if Assigned(FPopupMenu) then
  begin
    TagFlag := False;
    for I := 0 to FPopupMenu.Items.Count - 1 do
    begin
      Assert((Assigned(FPopupMenu.Items[I].Action) and
       Assigned(FPopupMenu.Items[I].Action.OnExecute)) or (FPopupMenu.Items[I].Caption = '-') or
       not (FPopupMenu.Items[I].Tag in [0, 1]),
       '�� ��������� ������� ��� ��� ���������� � ���� ��������. ���������� � ������������. ' +
       FPopupMenu.Items[I].Caption);
      TagFlag := TagFlag or (Assigned(FPopupMenu.Items[I].Action) and (FPopupMenu.Items[I].Action.Tag = 1));
    end;
    Assert(TagFlag, '�� ����� ��������� ���� ��� ���� ��������. ���������� � ������������.');
  end;
end;

procedure TgsQueryFilter.FillPopupMenu(AnSender: TObject);
begin
  Assert(Assigned(AnSender));
end;

procedure TgsQueryFilter.DoOnUpdate(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  (Sender as TAction).Enabled :=
    (GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False)
    and IBLogin.InGroup) <> 0;
  {$ENDIF}
end;

procedure TgsQueryFilter.DoOnUpdate2(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  (Sender as TAction).Enabled := (FCurrentFilter > 0) and
    ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK, False)
    and IBLogin.InGroup) <> 0);
  {$ENDIF}
end;

initialization
  FltComponentCache := TgdKeyIntAssoc.Create;

finalization
  FreeAndNil(FltComponentCache);
end.
