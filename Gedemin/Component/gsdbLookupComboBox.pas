
unit gsDBLookupComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, DB, IBHeader, IBDatabase, IBSQL, IBCustomDataSet,
  gsdbLookupComboboxInterface, gsdbLookupCombobox_dlgDropDown, DBCtrls;

type
  TgsSortOrder = (soNone, soAsc, soDesc);
  TgsViewType = (vtTree, vtGrid);

const
  DefSortOrder = soNone;
  DefStrictOnExit = True;
  DefDistinct = False;

type
  TWinControlCrack = class(TWinControl) end;
  TgsdbLookupCombobox = class;

  TgsIBLCBDataLink = class(TFieldDataLink)
  private
    //FLookupComboBox: TgsdbLookupCombobox;
    FFirstUse: Boolean;
    FCurrentValue: String;

    function GetCanModify: Boolean;

  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(F: TField); override;

  public
    constructor Create(ALookupComboBox: TgsdbLookupCombobox);
    function Edit: Boolean;
    property CanModify: Boolean read GetCanModify;
  end;

(*

  Кампанэнт дазваляе выбраць запіс з даведніка, дадзенага
  праз ListTable, ListField і запісаць у поле DataField
  з DataSource значэньне ідэнтыфікатара запісу
  з даведніка, якое бярэцца з KeyField.
*)

  TgsdbLookupCombobox = class(TCustomComboBox, IgsdbLookupComboBox)
  private
    FKeyField: String;              // поле-ключ в таблице-справочнике
    FListField: String;             // поле с наименованием объекта
    FListTable: String;             // таблица справочник
    FCondition: String;             // условие накладываемое на отбираемые записи
    FSortOrder: TgsSortOrder;       // сортировка датасета
    FNeedsRecheck: Boolean;
    FFields: String;                // список полей расширенного отображения
    FCountAddField: Integer;        // количество дополнительных полей

    FDataField: String;             // поле, куда подставлять выбранный ключ
    FDataLink: TgsIBLCBDataLink;    // куда записывать данные

    FIBBase: TIBBase;
    //FDatabase: TIBDatabase;         // база данных
    //FTransaction: TIBTransaction;   // транзакция

    Fibsql: TIBSQL;
    //FDontSync: Boolean;

    FCurrentKey: String;            // текущий ключ

    FdlgDropDown: TdbdlgDropDown;     // выпадающий дата-сет
    //FWasDropDownDialog: Boolean;
    FDropDownDialogWidth: Integer;
    FEmptyCondition: Boolean;
    FParams: TStrings;
    FStrictOnExit: Boolean;
    FDistinct: Boolean;
    FFullSearchOnExit: Boolean;
    FViewType: TgsViewType;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetDataSource(const Value: TDataSource);
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: String);

    procedure SetCurrentKey(const Value: String);
    procedure SetListTable(const Value: String);
    function GetCurrentKeyInt: Integer;
    procedure SetCurrentKeyInt(const Value: Integer);
    function GetValidObject: Boolean;
    procedure SetFields(const Value: String);
    procedure SetListField(const Value: String);
    procedure SetKeyField(const Value: String);

    procedure AssignDropDownDialogSize;
    procedure AssignDropDownDialogExpands;
    procedure SetupDropDownDialog;
    procedure ClearDataField;
    procedure AssignDataField(const AValue: String);

    {interface}
    function GetDropDownDialogWidth: Integer;
    procedure SetDropDownDialogWidth(const Value: Integer);
    function GetHandle: HWND;
    function GetField: TField;
    function GetMainTable: String;
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetCondition(const Value: String);
    procedure SetReadOnly(const Value: Boolean);
    function GetReadOnly: Boolean;

    procedure SetEditReadOnly;

    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure UpdateHint;
    function GetParams: TStrings;
    function FieldWithAlias(AFieldName: String): String;
    function GetMainTableName: String;
    procedure SetDistinct(const Value: Boolean);
    function GetDistinct: Boolean;
    function GetFullSearchOnExit: Boolean;
    procedure SetFullSearchOnExit(const Value: Boolean);

    function GetIsTree: Boolean;

  protected
    procedure DropDown; override;
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    //procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ShowDropDownDialog(const Match: String = ''; const UseExisting: Boolean = False);
    procedure DoExit; override;
    procedure CreateWnd; override;
    {$IFDEF DEBUG}
    procedure DblClick; override;
    {$ENDIF}

    function GetFullCondtion: String;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;

    property FullCondition: String read GetFullCondtion;
    property MainTable: String read GetMainTable;
    property MainTableName: String read GetMainTableName;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoLookup(const Exact: Boolean = False;
      const CreateIfNotFound: Boolean = True; const ShowDropDown: Boolean = True);

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);

    property CurrentKey: String read FCurrentKey write SetCurrentKey;
    property CurrentKeyInt: Integer read GetCurrentKeyInt write SetCurrentKeyInt;

    {interface}
    property DropDownDialogWidth: Integer read GetDropDownDialogWidth
      write SetDropDownDialogWidth;

    property _Field: TField read GetField;

    //
    property Params: TStrings read GetParams;

    procedure SyncWithDataSource;

    property IsTree: Boolean read GetIsTree;

  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataField: String read FDataField write SetDataField;
    property Fields: String read FFields write SetFields;

    property ListTable: String read FListTable write SetListTable
      stored True;
    property ListField: String read FListField write SetListField
      stored True;
    property KeyField: String read FKeyField write SetKeyField
      stored True;
    property SortOrder: TgsSortOrder read FSortOrder write FSortOrder
      default DefSortOrder;
    // показывает: выбран ли в комбо существующий в базе объект
    // или нет
    property ValidObject: Boolean read GetValidObject;

    //
    property Condition: String read FCondition write SetCondition;

    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;

    //
    property StrictOnExit: Boolean read FStrictOnExit write FStrictOnExit
      default DefStrictOnExit;

    property Distinct: Boolean read GetDistinct write SetDistinct
      default DefDistinct;

    property FullSearchOnExit: Boolean read GetFullSearchOnExit write SetFullSearchOnExit
      Default False;
      // По выходу из лукапа если True то поиск по полному совпадению
      // Если False по вхождению. По умолчанию по False

    property ViewType: TgsViewType read FViewType write FViewType default vtGrid;

  published
    property Style; {Must be published before Items}
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount default 16;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;

    property Text stored False;
    property Hint stored False;
  end;

  EgsdbLookupComboboxError = class(Exception);

procedure Register;

implementation

uses
  IB,              gd_security,             at_classes,           jclSysUtils,
  jclStrings,      gsDBGrid,                IBErrorCodes;

const
  GridRowHeight = 17;

const
  ArrRus = 'ё"№;:?йцукенгшщзхъфывапролджэячсмитьбю.ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ.';
  ArrEng = '`@#$^&qwertyuiop[]asdfghjkl;''zxcvbnm,./~QWERTYUIOP[]ASDFGHJKL;''ZXCVBNM,./';
  ArrBel = 'ё"№;:?йцукенгшўзх''фывапролджэячсмітьбю.ЁЙЦУКЕНГШЎЗХ''ФЫВАПРОЛДЖЭЯЧСМІТЬБЮ.';

{ TgsdbLookupCombobox }

procedure TgsdbLookupCombobox.Change;
begin
  if Assigned(Database) and Database.Connected then
  begin
    if (Text <> Items[0]) then
    begin
      FCurrentKey := '';
      {ClearDataField;}
    end;

    inherited Change;
  end;  
end;

constructor TgsdbLookupCombobox.Create(AnOwner: TComponent);
begin
  inherited;
  FIBBase := TIBBase.Create(Self);
  FCountAddField := 0;
  Fibsql := TIBSQL.Create(nil);
  FDataLink := TgsIBLCBDataLink.Create(Self);
  //FDontSync := False;
  FSortOrder := DefSortOrder;
  FNeedsRecheck := False;
  //FWasDropDownDialog := False;
  FdlgDropDown := nil;
  FDropDownDialogWidth := -1;
  FEmptyCondition := False;
  FParams := TStringList.Create;
  FStrictOnExit := DefStrictOnExit;
  FViewType := vtGrid;
  FDistinct := False;
  HelpContext := 1;

  ControlStyle := ControlStyle + [csReplicatable];
  DropDownCount := 16;
  UpdateHint;
end;

destructor TgsdbLookupCombobox.Destroy;
begin
  FreeAndNil(FIBSQL);
  FDataLink.Free;
  FreeAndNil(FdlgDropDown);
  FreeAndNil(FIBBase);
  FParams.Free;
  inherited;
end;

procedure TgsdbLookupCombobox.SetCurrentKey(const Value: String);
var
  Found, DidActivate: Boolean;
  OldKey: String;
  DistinctStr: String;

  procedure PrepareSQL;
  var
    I: Integer;
  begin
    if FDistinct then
      DistinctStr := 'DISTINCT'
    else
      DistinctStr := '';

    Fibsql.Close;
{      Fibsql.SQL.Text := Format('SELECT %0:s.%1:s, %0:s.%2:s FROM %3:s WHERE (%0:s.%4:s = :V) ',
      [MainTable, FListField, FKeyField, FListTable, FKeyField]);}
    Fibsql.SQL.Text := Format('SELECT %4:s %0:s, %1:s FROM %2:s WHERE (%3:s = :V) ',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
       FListTable, FieldWithAlias(FKeyField), DistinctStr]);

    if FullCondition > '' then
      Fibsql.SQL.Text := Fibsql.SQL.Text + ' AND (' + FullCondition + ') ';

    Fibsql.Prepare;
    Fibsql.ParamByName('V').AsString := Value;

    for I := 0 to Fibsql.Params.Count - 1 do
    begin
      if Fibsql.Params[I].Name <> 'V' then
      begin
        if FParams.IndexOfName(Fibsql.Params[I].Name) = -1 then
          raise Exception.Create('TgsdbLookupCombobox: Invalid param name');
        Fibsql.Params[I].AsString := FParams.Values[Fibsql.Params[I].Name];
      end;
    end;

    {for I := 0 to FParams.Count - 1 do
    begin
      try
        Fibsql.ParamByName(FParams.Names[I]).AsString := FParams.Values[FParams.Names[I]];
      except
      end;
    end;}
  end;

begin
  if Transaction <> nil then
  begin
    Found := False;
    OldKey := FCurrentKey;

    if Value > '' then
    begin
      DidActivate := not Transaction.InTransaction;
      try
        if DidActivate then
          Transaction.StartTransaction;

        PrepareSQL;

        Fibsql.ExecQuery;

        if (Fibsql.RecordCount = 0)
          and Assigned(DataSource)
          and (DataSource.DataSet is TIBCustomDataSet)
          and (TIBCustomDataSet(DataSource.DataSet).Transaction <> nil)
          and (TIBCustomDataSet(DataSource.DataSet).Transaction.InTransaction) then
        begin
          Fibsql.Close;
          Fibsql.Transaction := TIBCustomDataSet(DataSource.DataSet).Transaction;
          PrepareSQL;
          Fibsql.ExecQuery;
        end;

        if Fibsql.RecordCount = 1 then
        begin
          FCurrentKey := Value;
          Items[0] := Fibsql.Fields[0].AsTrimString;
          ItemIndex := 0;
          AssignDataField(Value);
          Found := True;
        end;

        Fibsql.Close;
      finally
        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      end;
    end;

    if not Found then
    begin
      FCurrentKey := '';
      Items[0] := '';
      ItemIndex := 0;
      ClearDataField;
    end;

    if OldKey <> FCurrentKey then
      if Assigned(OnChange) then OnChange(Self);
  end;
end;

procedure TgsdbLookupCombobox.DoLookup(const Exact: Boolean = False;
  const CreateIfNotFound: Boolean = True; const ShowDropDown: Boolean = True);
var
  S, SText: String;
  StrFields: String;
  MessageBoxResult, I, J: Integer;
  SL: TStringList;
  SelectCondition: String;
  DistinctStr: String;
begin
  {if (FListTable = '') or (FListField = '') or (FKeyField = '') then
    exit;}

  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  FCurrentKey := '';

  SetupDropDownDialog;

  SText := Text;
  while Pos('''', SText) > 0 do
    System.Delete(SText, Pos('''', SText), 1);
  Text := SText;

  if FFields > '' then
    StrFields := ', ' + FieldWithAlias(FFields)
  else
    StrFields := '';

  if IsTree then
    StrFields := StrFields + ', ' + FieldWithAlias('parent');

  if FDistinct then
    DistinctStr := 'DISTINCT'
  else
    DistinctStr := '';

(* g_s_ansiuppercase *)
  if Text > '' then
  begin

    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s WHERE',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
      StrFields, FListTable, DistinctStr]);

    if Exact then
      SelectCondition := Format(' (%0:s = ''%1:s'') ', [FieldWithAlias(FListField), Text])
    else
      SelectCondition := Format('(UPPER(%0:s) SIMILAR TO ''%%%1:s%%'') ',
        [FieldWithAlias(FListField), AnsiUpperCase(Text)]);

    if FFields > '' then
    begin
      SL := TStringList.Create;
      try
        SL.CommaText := FFields;
        for J := 0 to SL.Count - 1 do
        begin
          if Exact then
            SelectCondition := Format('%s OR (%s = ''%s'') ',
              [SelectCondition, FieldWithAlias(Trim(SL[J])), Text])
          else
            SelectCondition := Format('%s OR (UPPER(%s) SIMILAR TO ''%%%s%%'') ',
              [SelectCondition, FieldWithAlias(Trim(SL[J])), AnsiUpperCase(Text)])
        end;      
      finally
        SL.Free;
      end;
    end;
    S := Format('%s (%s)', [S, SelectCondition])
  end else
    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s ',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
       StrFields, FListTable, DistinctStr]);

  if FullCondition > '' then
    if Text > '' then
      S := S + ' AND (' + FullCondition + ') '
    else
      S := S + ' WHERE ' + FullCondition + ' ';

  if FSortOrder = soAsc then
    S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' ASC '
  else if FSortOrder = soDesc then
    S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' DESC ';

  FdlgDropDown.ibdsList.Close;
  FdlgDropDown.ibdsList.SelectSQL.Text := S;

  FdlgDropDown.ibdsList.Prepare;

  for I := 0 to FdlgDropDown.ibdsList.Params.Count - 1 do
  begin
    if FParams.IndexOfName(FdlgDropDown.ibdsList.Params[I].Name) = -1 then
      raise Exception.Create('TgsdbLookupCombobox: Invalid param name');
    FdlgDropDown.ibdsList.Params[I].AsString :=
      FParams.Values[FdlgDropDown.ibdsList.Params[I].Name];
  end;

{  for I := 0 to FParams.Count - 1 do
    try
      FdlgDropDown.ibdsList.ParamByName(FParams.Names[I]).AsString := FParams.Values[FParams.Names[I]];
    except
    end; }

  FdlgDropDown.ibdsList.Open;

  // зачем это, еще надо разобраться
  // это очень даже надо! Если не сделать хотя бы один Next
  // то свойство RecordCount будет возвращать 0, если ibsql пустой,
  // или 1 (всегда), если ibsql содержит записи
  // В данной случае (ниже) идет проверка RecordCount = 0, >1, =1
  if not FdlgDropDown.ibdsList.EOF then
    FdlgDropDown.ibdsList.Next;

  if FdlgDropDown.ibdsList.RecordCount = 0 then
  begin
    if CreateIfNotFound then
    begin
      MessageBoxResult := IDYES;
      if MessageBoxResult = IDYES then
        ShowDropDownDialog
      else begin
        Text := '';
        ClearDataField;
        SetFocus;
      end;
    end;
  end
  else if ShowDropDown or ((FdlgDropDown.ibdsList.RecordCount > 1) and CreateIfNotFound) then
  begin
    ShowDropDownDialog('', True);
  end else if (FdlgDropDown.ibdsList.RecordCount = 1) then
  begin
    Items[0] := Trim(FdlgDropDown.dsList.DataSet.Fields[0].AsString);
    ItemIndex := 0;
    FCurrentKey := FdlgDropDown.dsList.DataSet.Fields[1].AsString;
    AssignDataField(FCurrentKey);
    if Assigned(OnChange) then
      OnChange(Self);
  end;

  {
  else if (FdlgDropDown.ibdsList.RecordCount > 1) or ShowDropDown then
    ShowDropDownDialog('', True)
  else
  begin
    Items[0] := Trim(FdlgDropDown.dsList.DataSet.Fields[0].AsString);
    ItemIndex := 0;
    FCurrentKey := FdlgDropDown.dsList.DataSet.Fields[1].AsString;
    AssignDataField(FCurrentKey);
    if Assigned(OnChange) then
      OnChange(Self);
  end;
  }
end;

procedure TgsdbLookupCombobox.DropDown;
begin
  if not ((csDesigning in ComponentState){ or ReadOnly})
    and Assigned(Database)
    and Database.Connected then
  begin
//    inherited;
    if ValidObject then
      ShowDropDownDialog
    else
      DoLookup;
  end;    
end;

function TgsdbLookupCombobox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgsdbLookupCombobox.LoadFromStream(S: TStream);
var
  R: TReader;
begin
  R := TReader.Create(S, 128);
  try
    try
      if (R.NextValue <> vaInt32) or (R.ReadInteger <> $56789914) then exit;
      FDropDownDialogWidth := R.ReadInteger;
    except
      FDropDownDialogWidth := -1;
    end;
  finally
    R.Free;
  end;
end;

procedure TgsdbLookupCombobox.SaveToStream(S: TStream);
var
  W: TWriter;
begin
  W := TWriter.Create(S, 128);
  try
    W.WriteInteger($56789914);
    W.WriteInteger(FDropDownDialogWidth);
  finally
    W.Free;
  end;
end;

procedure TgsdbLookupCombobox.SetDatabase(const Value: TIBDatabase);
begin
  if Database <> Value then
  begin
    if Database <> nil then
      Database.RemoveFreeNotification(Self);
    FIBBase.Database := Value;
    Fibsql.Database := Database;
    if Assigned(Value) then
      Value.FreeNotification(Self);
  end;
  if (not Assigned(Transaction)) and Assigned(Database) then
    Transaction := Database.DefaultTransaction;
end;

procedure TgsdbLookupCombobox.SetDataField(const Value: String);
begin
  if FDataField <> Trim(Value) then
  begin
    FDataField := Trim(Value);
    FDataLink.FieldName := FDataField;
    //SyncWithDataSource;
  end;
end;

procedure TgsdbLookupCombobox.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource <> Value then
  begin
    FDataLink.DataSource := Value;
    SyncWithDataSource;
  end;
end;

procedure TgsdbLookupCombobox.SetTransaction(const Value: TIBTransaction);
begin
  if Transaction <> Value then
  begin
    if Assigned(Transaction) then
      Transaction.RemoveFreeNotification(Self);
    FIBBase.Transaction := Value;
    Fibsql.Transaction := Transaction;
    if Assigned(Value) then
    begin
      Value.FreeNotification(Self);
      if (CurrentKey > '') and (FDataLink.Field <> nil) and (not FDataLink.Field.ReadOnly) then
        SetCurrentKey(CurrentKey)
      else
        SyncWithDataSource;  
    end;
  end;
  if (not Assigned(Database)) and Assigned(Transaction) then
    Database := Transaction.DefaultDatabase;
end;

procedure TgsdbLookupCombobox.SyncWithDataSource;
var
  DidActivate: Boolean;
begin
  if ((ComponentState * [csDesigning, csLoading, csDestroying]) <> [])
    //or FDontSync
    or (Assigned(Owner) and (csLoading in Owner.ComponentState))
    or (not Assigned(Parent))
    or (not Visible) then
  begin
    exit;
  end;

  Assert(Assigned(Transaction), 'gsdbLookupCombobox: Transaction is not assigned');

  FCurrentKey := '';
  Items[0] := '';
  ItemIndex := 0;

  if (FDataField > '')
    and {FDataLink.Active} Assigned(FDataLink.DataSet) and FDataLink.DataSet.Active
    and (FListField > '')
    and (FListTable > '')
    and (FKeyField > '')
    and (FDataLink.DataSet.FindField(FDataField) <> nil)
    and (not (FDataLink.DataSet.FieldByName(FDataField).IsNull)) then
  begin
    DidActivate := not Transaction.InTransaction;
    if DidActivate then
      Transaction.StartTransaction;
    try
      Fibsql.Database := Database;
      Fibsql.Transaction := Transaction;
      Fibsql.Close;
      Fibsql.SQL.Text := Format('SELECT %0:s FROM %1:s WHERE %2:s=:V ',
        [FListField, MainTableName, FKeyField]);
      try
        Fibsql.Prepare;
      except
        { TODO :
может так случиться что при  присваивании класса
в лист фиелд будет поле от другого класса -- и будет
ошибка. пока просто пропустим ее.
может придумать что по лучше? }
        exit;
      end;
      Fibsql.ParamByName('V').AsString :=
        FDataLink.DataSet.FieldByName(FDataField).AsString;
  {    for I := 0 to FParams.Count - 1 do
        Fibsql.ParamByName(FParams.Names[I]).AsString := FParams.Values[FParams.Names[I]];}
      Fibsql.ExecQuery;

      if (Fibsql.RecordCount = 0)
        and Assigned(DataSource)
        and (DataSource.DataSet is TIBCustomDataSet)
        and (TIBCustomDataSet(DataSource.DataSet).Transaction <> nil)
        and (TIBCustomDataSet(DataSource.DataSet).Transaction.InTransaction) then
      begin
        Fibsql.Close;
        Fibsql.Transaction := TIBCustomDataSet(DataSource.DataSet).Transaction;

        try
          Fibsql.Prepare;
        except
          { TODO :
    может так случиться что при  присваивании класса
    в лист фиелд будет поле от другого класса -- и будет
    ошибка. пока просто пропустим ее.
    может придумать что по лучше? }
          exit;
        end;
        Fibsql.ParamByName('V').AsString :=
          FDataLink.DataSet.FieldByName(FDataField).AsString;
    {    for I := 0 to FParams.Count - 1 do
          Fibsql.ParamByName(FParams.Names[I]).AsString := FParams.Values[FParams.Names[I]];}
        Fibsql.ExecQuery;
      end;

      if Fibsql.RecordCount > 0 then
      begin
        FCurrentKey :=
          FDataLink.DataSet.FieldByName(FDataField).AsString;
        Items[0] := Fibsql.Fields[0].AsTrimString;
        ItemIndex := 0;
      end;

      Fibsql.Close;
    finally
      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    end;
  end;

  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TgsdbLookupCombobox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if AComponent = FDlgDropDown then
      FDlgDropDown := nil;

    if Assigned(FIBBase) and (AComponent = FIBBase.Database) then
    begin
      FIBBase.Database := nil;
    end;

    if Assigned(FIBBase) and (AComponent = FIBBase.Transaction) then
    begin
      FIBBase.Transaction := nil;
    end;

    if Assigned(FIBsql) and (AComponent = FIBsql.Database) then
    begin
      Fibsql.Database := nil;
    end;
  end;
end;

  (*
procedure TgsdbLookupCombobox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(Database)
    and Database.Connected
    and (not (csDesigning in ComponentState))
    and (Shift = []) then
  begin
    if ReadOnly then
    begin
      case Key of
        VK_F4, VK_F11:
        begin
          case Key of
            VK_F4: Edit;
            VK_F11: ObjectProperties;
          end;
          Key := 0;
        end;
      end;
    end
    else
    begin
      case Key of
        {VK_F1,} VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F11, VK_F12, VK_DOWN:
          begin
            case Key of
//              VK_F1: ShowHelp('gsdbLookupCombobox.htm');
              VK_F2: CreateNew;
              VK_F3: DoLookup(False, True, False);
              VK_F4: Edit;
              VK_F6: Reduce;
              VK_F7: DoLookup(True, True, False);
              VK_F8: Delete;
              VK_F9: ViewForm;
              VK_F11: ObjectProperties;
              VK_F12: ConvertText;
              VK_DOWN: DropDown;
            end;
            Key := 0;
          end;
      end;
    end;
  end;

  inherited;
end;
  *)

procedure TgsdbLookupCombobox.ShowDropDownDialog(const Match: String = ''; const UseExisting: Boolean = False);
var
  S, StrFields: String;
  W: TWinControl;
  I, J: Integer;
  SL: TStringList;
  SelectCondition: String;
  DistinctStr: String;
begin
  SetupDropDownDialog;
  if FdlgDropDown.dsList.DataSet <> FdlgDropDown.ibdsList then
    FdlgDropDown.dsList.DataSet := FdlgDropDown.ibdsList;
  if not UseExisting then
  begin
    if FFields > '' then
      StrFields := ', ' + FieldWithAlias(FFields)
    else
      StrFields := '';

    if IsTree then
      StrFields := StrFields + ', ' + MainTable + '.' + 'parent';

    if FDistinct then
      DistinctStr := 'DISTINCT'
    else
      DistinctStr := '';

(* g_s_ansiuppercase *)
    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s ', [FieldWithAlias(FListField),
      FieldWithAlias(FKeyField), StrFields, FListTable, DistinctStr]);

    if Match > '' then
    begin
      SelectCondition := Format(' (UPPER(%0:s) SIMILAR TO ''%%%1:s%%'') ',
        [FieldWithAlias(FListField), AnsiUpperCase(Match)]);

      if FFields > '' then
      begin
        SL := TStringList.Create;
        try
          SL.CommaText := FFields;
          for J := 0 to SL.Count - 1 do
              SelectCondition := Format('%s OR (UPPER(%s) SIMILAR TO ''%%%s%%'') ',
                [SelectCondition, FieldWithAlias(Trim(SL[J])), AnsiUpperCase(Match)])
        finally
          SL.Free;
        end;
      end;
      S := Format('%s WHERE (%s)', [S, SelectCondition])
    end;

    if FullCondition > '' then
      if Pos('WHERE ', S) = 0 then
        S := S + ' WHERE (' + FullCondition + ') '
      else
        S := S + ' AND (' + FullCondition + ') ';

    if FSortOrder = soAsc then
      S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' ASC '
    else if FSortOrder = soDesc then
      S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' DESC ';

    FdlgDropDown.ibdsList.Close;
    FdlgDropDown.ibdsList.SelectSQL.Text := S;
    FdlgDropDown.ibdsList.Prepare;

    for I := 0 to FdlgDropDown.ibdsList.Params.Count - 1 do
    begin
      if FParams.IndexOfName(FdlgDropDown.ibdsList.Params[I].Name) = -1 then
        raise Exception.Create('TgsdbLookupCombobox: Invalid param name');
      FdlgDropDown.ibdsList.Params[I].AsString :=
        FParams.Values[FdlgDropDown.ibdsList.Params[I].Name];
    end;

{    for I := 0 to FParams.Count - 1 do
      try
        FdlgDropDown.ibdsList.ParamByName(FParams.Names[I]).AsString := FParams.Values[FParams.Names[I]];
      except
      end; }
    FdlgDropDown.ibdsList.Open;
  end;

  if FdlgDropDown.ibdsList.IsEmpty then
  begin

    {$IFDEF GD_LOC_RUS}
      MessageBox(Self.Handle,
        'Список для выбора пуст.',
        'Внимание',
        MB_OK or MB_ICONINFORMATION);
    {$ELSE}
      MessageBox(Self.Handle,
        'There are no items in the list.',
        'Attention',
        MB_OK or MB_ICONINFORMATION);
    {$ENDIF}

    Items[0] := '';
    ItemIndex := 0;
    SetFocus;

  end else
  begin
    while (not FdlgDropDown.ibdsList.EOF) and (FdlgDropDown.ibdsList.RecordCount < DropDownCount) do
      FdlgDropDown.ibdsList.Next;

    AssignDropDownDialogSize;
    AssignDropDownDialogExpands;

    if ValidObject then
      FdlgDropDown.dsList.DataSet.Locate(FKeyField, FCurrentKey, [])
    else
    begin
      if (FdlgDropDown.dsList.DataSet.RecordCount >= DropDownCount)
        or (not FdlgDropDown.dsList.DataSet.Locate(FListField, Text, [loCaseInsensitive])) then
      begin
        FdlgDropDown.dsList.DataSet.First;
      end;
    end;
    FdlgDropDown.FLastKey := 0;
    if FdlgDropDown.ShowModal = mrOk then
    begin
      FCurrentKey := FdlgDropDown.dsList.DataSet.Fields[1].AsString;
      Items[0] := Trim(FdlgDropDown.dsList.DataSet.Fields[0].AsString);
      ItemIndex := 0;
      AssignDataField(FCurrentKey);

      if Assigned(OnChange) {and (FdlgDropDown.FLastKey = 0)} then
      begin
        OnChange(Self);
        Repaint;
      end;

      if FdlgDropDown.FWasTabKey and (Parent is TWinControl) then
      begin
        W := Parent;
        while W.Parent <> nil do
          W := W.Parent;

        TWinControlCrack(W).SelectNext(Self, True, True);
        {
        W := TWinControlCrack(Parent).FindNextControl(Self, True, True, True);
        if W <> nil then W.SetFocus;
        }
      end else
        SetFocus;
    end;
    if FdlgDropDown.FLastKey <> 0 then
      PostMessage(Self.Handle,  WM_KEYDOWN, FdlgDropDown.FLastKey, 0);
  end;
end;

procedure TgsdbLookupCombobox.SetListTable(const Value: String);
begin
  if FListTable <> Trim(Value) then
  begin
    FListTable := Trim(Value);
    if FDataField > '' then
      SyncWithDataSource;
  end;
end;

procedure TgsdbLookupCombobox.DoExit;
var
  Pt: TPoint;
  W: TWinControl;
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;

  // калі карыстальнік набраў нейкае значэньне -- трэба прысвоіць яго па выхаду
  if (not (csDesigning in ComponentState))
    and (
      ((Text > '') and (FCurrentKey = ''))
      or
      ((Items.Count > 0) and (Items[0] <> Text))
    )
//    and (not ReadOnly)
  then
  begin
    GetCursorPos(Pt);
    W := FindVCLWindow(Pt);
    if (W <> nil) and (W is TButton) and TButton(W).Cancel then
    begin
      if FCurrentKey = '' then
        Items[0] := '';
      ItemIndex := 0;
    end else
    begin
      if Text > '' then
        DoLookup(FFullSearchOnExit, FStrictOnExit, False)
      else
      begin
        FCurrentKey := '';
        Items[0] := '';
        ItemIndex := 0;
        ClearDataField;
      end;
    end;  
  end;

  inherited;
end;

function TgsdbLookupCombobox.GetCurrentKeyInt: Integer;
begin
  Result := StrToIntDef(FCurrentKey, -1);
end;

procedure TgsdbLookupCombobox.SetCurrentKeyInt(const Value: Integer);
begin
  CurrentKey := IntToStr(Value);
end;

function TgsdbLookupCombobox.GetValidObject: Boolean;
begin
  Result := FCurrentKey > '';
end;

function TgsdbLookupCombobox.GetFullCondtion: String;
begin
  Result := FCondition;
end;

procedure TgsdbLookupCombobox.SetFields(const Value: String);
var
  I: Integer;
begin
  if FFields <> Value then
  begin
    FFields := Trim(Value);
    FCountAddField := 0;
    if FFields > '' then
    begin
      Inc(FCountAddField);
      for I := 1 to Length(FFields) - 1 do { -1 to allow strings like aaa;bbb; }
        if FFields[i] = ';' then Inc(FCountAddField);
    end;
  end;
end;

procedure TgsdbLookupCombobox.SetListField(const Value: String);
begin
  if FListField <> Trim(Value) then
  begin
    if StrContainsChars(Value, [',', ';'], False) then
      raise EgsdbLookupComboboxError.Create('Invalid List field name specified');
    FListField := Trim(Value);
    if FDataField > '' then
    begin
      FCurrentKey := '';
      SyncWithDataSource;
    end;
  end;
end;

procedure TgsdbLookupCombobox.SetKeyField(const Value: String);
begin
  if FKeyField <> Trim(Value) then
  begin
    if StrContainsChars(Value, [',', ';'], False) then
      raise EgsdbLookupComboboxError.Create('Invalid List field name specified');
    FKeyField := Trim(Value);
    if FDataField > '' then
      SyncWithDataSource;
  end;
end;

procedure TgsdbLookupCombobox.AssignDropDownDialogSize;
var
  Hg, Rc: Integer;
begin
  if Assigned(Parent) and (Parent is TControl) then
  begin
    FdlgDropDown.Left := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).X;
    FdlgDropDown.Top := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).Y;
  end;
  if FDropDownDialogWidth = -1 then FdlgDropDown.Width := Width - 1;
  if FdlgDropDown.dsList.DataSet.RecordCount < DropDownCount then
    Rc := FdlgDropDown.dsList.DataSet.RecordCount
  else
    Rc := DropDownCount;
  { TODO : а если дерево, высота считается не правильно! }  
  Hg := Rc * GridRowHeight * (FCountAddField + 1) + 16;
  if Hg + FdlgDropDown.Top + 28 > Screen.Height then
    FdlgDropDown.Height := Screen.Height - FdlgDropDown.Top - 28
  else
    FdlgDropDown.Height := Hg;
end;

procedure TgsdbLookupCombobox.AssignDropDownDialogExpands;
var
  I: Integer;
  ColumnExpand: TColumnExpand;
  ParentField: String;
begin
  with FdlgDropDown do
  begin
    if gsDBGrid.Enabled then
    begin
      ParentField := '';

      gsDBGrid.Expands.Clear;
      for I := 0 to dsList.DataSet.Fields.Count - 1 do
      begin
        if ((AnsiCompareText(FKeyField, dsList.DataSet.Fields[I].FieldName) = 0)
            or
            (AnsiCompareText(ParentField, dsList.DataSet.Fields[I].FieldName) = 0))
           and
           (AnsiCompareText(FListField, dsList.DataSet.Fields[I].FieldName) <> 0)
        then
        begin
          gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := False;
          continue;
        end;

        if ANSICompareText(FListField, FKeyField) = 0 then
          continue;

        if (AnsiCompareText(FListField, dsList.DataSet.Fields[I].FieldName) = 0) then
        begin
          gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := True;
          continue;
        end;

        ColumnExpand := gsDBGrid.Expands.Add;
        ColumnExpand.DisplayField := dsList.DataSet.Fields[0].FieldName;
        ColumnExpand.FieldName := dsList.DataSet.Fields[I].FieldName;
        ColumnExpand.Options := [ceoAddField];
        gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := False;
      end;
      gsDBGrid.ExpandsActive := True;
    end;
  end;
end;

procedure TgsdbLookupCombobox.SetupDropDownDialog;
begin
  // выпадающее окно из соображений быстродействия создаем
  // только один раз
  if not Assigned(FdlgDropDown) then
    FdlgDropDown := TdbdlgDropDown.Create(Self);
  if IsTree
    and ((Text = '') or ValidObject) then
  begin
    FdlgDropDown.tv.KeyField := FKeyField;
    FdlgDropDown.tv.ParentField := 'parent';
    FdlgDropDown.tv.DisplayField := FListField;//gdClass.GetListField(SubType);

    FdlgDropDown.tv.Visible := True;
    FdlgDropDown.tv.Enabled := True;
    FdlgDropDown.gsDBGrid.Visible := False;
    FdlgDropDown.gsDBGrid.Enabled := False;
  end else begin
    FdlgDropDown.tv.Visible := False;
    FdlgDropDown.tv.Enabled := False;
    FdlgDropDown.gsDBGrid.Visible := True;
    FdlgDropDown.gsDBGrid.Enabled := True;
  end;
  if not FdlgDropDown.ibdsList.Active then
  begin
    FdlgDropDown.ibdsList.Database := Database;
    FdlgDropDown.ibdsList.Transaction := Transaction;
  end;
end;

procedure TgsdbLookupCombobox.ClearDataField;
begin
  {FDontSync := True;
  try}
    if FDataLink.Active and (not FDataLink.DataSet.IsEmpty)
      and FDataLink.Edit and
      (not FDataLink.DataSet.FieldByName(FDataField).IsNull) then
    begin
      FDataLink.DataSet.FieldByName(FDataField).Clear;
    end
    else if (FDataLink.Field <> nil) and (FDataLink.Field.ReadOnly)
      and (not FDataLink.Field.IsNull) then
    begin
      MessageBox(Handle,
        'Невозможно присвоить значение поля, так как оно находится в состоянии Только для чтения.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION);
    end;    
  {finally
    FDontSync := False;
  end;}
end;

procedure TgsdbLookupCombobox.AssignDataField(const AValue: String);
begin
  {FDontSync := True;
  try}
    if FDataLink.Active and FDataLink.Edit then
    begin
      {if FDataLink.DataSet.FieldByName(FDataField).AsString <> AValue then}
        FDataLink.DataSet.FieldByName(FDataField).AsString := AValue;
    end else if (FDataLink.Field <> nil) and (FDataLink.Field.ReadOnly) then
      MessageBox(Handle,
        'Невозможно присвоить значение поля, так как оно находится в состоянии Только для чтения.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION);
  {finally
    FDontSync := False;
  end;}
end;

procedure TgsdbLookupCombobox.CreateWnd;
begin
  inherited;
  Items.Add('');
end;

function TgsdbLookupCombobox.GetDropDownDialogWidth: Integer;
begin
  Result := FDropDownDialogWidth;
end;

procedure TgsdbLookupCombobox.SetDropDownDialogWidth(const Value: Integer);
begin
  FDropDownDialogWidth := Value;
end;

function TgsdbLookupCombobox.GetHandle: HWND;
begin
  Result := Handle;
end;

function TgsdbLookupCombobox.GetField: TField;
begin
  if (FDataLink.DataSet <> nil) and (FDataLink.DataSet.FindField(FDataField) <> nil) then
    Result := FDataLink.DataSet.FieldByName(FDataField)
  else
    Result := nil;
end;

function TgsdbLookupCombobox.GetMainTable: String;
const
  SacredWords = ';JOIN;LEFT;RIGHT;FULL;OUTER;INNER;,;ON;';
var
  i: Integer;
  St: String;
begin
//Попробуем вытянуть алиас главной таблицы
//главная таблица должна идти первой!!!
//Если есть несколько таблиц, то они не должны разделяться запятой!!!!
  i := Pos(' ', FListTable);
  if i = 0 then
    Result := FListTable
  else
  begin
    St := Trim(Copy(FListTable, I, Length(FListTable) - I + 1));
    if (Pos(' ', St) > 0) and (AnsiPos(';' + AnsiUpperCase(Copy(St, 1, Pos(' ', St) - 1)) + ';', SacredWords) = 0) then
      Result := Copy(St, 1, Pos(' ', St) - 1)
    else if (Pos(' ', St) = 0) and (AnsiPos(';' + AnsiUpperCase(St) + ';', SacredWords) = 0) then
      Result := St
    else
      Result := Copy(FListTable, 1, i - 1);
  end;
end;

function TgsdbLookupCombobox.GetMainTableName: String;
var
  i: Integer;
begin
  i := Pos(' ', Trim(FListTable));
  if i = 0 then
    Result := FListTable
  else
    Result := Copy(Trim(FListTable), 1, i - 1);
{$IFDEF DEBUG}
  if Pos(' ', FListTable) = 1 then
    ShowMessage(FListTable); 
{$ENDIF}
end;

function TgsdbLookupCombobox.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
  if (Result = nil) and (Transaction <> nil) then
    Result := Transaction.DefaultDatabase;
end;

function TgsdbLookupCombobox.GetTransaction: TIBTransaction;
begin
  Result := FIBBase.Transaction;
end;

procedure TgsdbLookupCombobox.SetCondition(const Value: String);
begin
  FCondition := Value;
  FEmptyCondition := (csLoading in ComponentState) and (FCondition = '');
  if (not (csLoading in ComponentState))
    and (not Assigned(DataSource) or (DataField = '')) then
  try
    SetCurrentKey(CurrentKey);
  except
    on E: EIBError do
    begin
      // пропустим ошибки, которые могут быть связаны с тем,
      // что в поле Condition находится не полное условие
      // например при пошаговом формировании Condition
      if (E.IBErrorCode <> isc_dsql_error) then
        raise;
    end else
      raise;
  end;
end;

procedure TgsdbLookupCombobox.SetReadOnly(const Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
  SetEditReadOnly;
end;

function TgsdbLookupCombobox.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TgsdbLookupCombobox.CNCommand(var Message: TWMCommand);
begin
  if not ReadOnly then
    case Message.NotifyCode of
      CBN_DROPDOWN: PostMessage(Handle, WM_KEYDOWN, VK_DOWN, 0);
      else inherited;
    end;
end;

procedure TgsdbLookupCombobox.SetEditReadOnly;
begin
  if (Style in [csDropDown, csSimple]) and HandleAllocated then
    SendMessage(EditHandle, EM_SETREADONLY, Ord(not FDataLink.CanModify), 0);
end;

procedure TgsdbLookupCombobox.UpdateHint;
begin
  Hint := 'Используйте клавишу F3 -- для поиска';
end;

function TgsdbLookupCombobox.GetParams: TStrings;
begin
  Result := FParams;
end;

{$IFDEF DEBUG}
procedure TgsdbLookupCombobox.DblClick;
begin
  inherited;

  raise Exception.Create('Test exception');
end;
{$ENDIF}

function TgsdbLookupCombobox.FieldWithAlias(AFieldName: String): String;
var
  StList: TStringList;
  I: Integer;
begin
  Result := Trim(AFieldName);

  if Pos(',', Result) = 0 then
  begin
    if Pos('.', Result) = 0 then
      Result := MainTable + '.' + Result;
  end else
  begin
    StList := TStringList.Create;
    try
      StList.CommaText := Result;
      for I := 0 to StList.Count - 1 do
      begin
        if Pos('.', StList[I]) = 0 then
          StList[I] := MainTable + '.' + StList[I];
      end;
      Result := StList.CommaText;
    finally
      StList.Free;
    end;
  end;
end;

procedure TgsdbLookupCombobox.SetDistinct(const Value: Boolean);
begin
  FDistinct := Value;
end;

function TgsdbLookupCombobox.GetDistinct: Boolean;
begin
  Result := FDistinct;
end;

function TgsdbLookupCombobox.GetFullSearchOnExit: Boolean;
begin
  Result := FFullSearchOnExit;
end;

procedure TgsdbLookupCombobox.SetFullSearchOnExit(const Value: Boolean);
begin
  FFullSearchOnExit := Value;
end;

function TgsdbLookupCombobox.GetIsTree: Boolean;
begin
  case FViewType of
    vtTree: Result := True;
  else
    Result := False;
  end;
end;

procedure TgsdbLookupCombobox.CNKeyDown(var Message: TWMKeyDown);
begin
  with Message do
  begin
    if Assigned(Database)
      and Database.Connected
      and (not (csDesigning in ComponentState))
      {and (KeyDataToShiftState(KeyData) = [])} then
    begin
      if KeyDataToShiftState(KeyData) = [] then
      begin
        case CharCode of
          VK_F3, VK_DOWN:
            begin
              case CharCode of
                VK_F3: DoLookup(False, True, False);
                VK_DOWN: DropDown;
              end;
              Result := 1;
              exit;
            end;
        end;
        {else if KeyDataToShiftState(KeyData) = [ssAlt] then
        begin
          if CharCode = VK_DOWN then
          begin
            DropDown;
            Result := 1;
            exit;
          end;
        end;}
      end;
    end;
  end;

  inherited;
end;

procedure TgsdbLookupCombobox.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

{ TgsIBLCBDataLink }

procedure TgsIBLCBDataLink.ActiveChanged;
begin
  inherited;
  (Control as TgsdbLookupCombobox).SyncWithDataSource;
end;

constructor TgsIBLCBDataLink.Create(ALookupComboBox: TgsdbLookupCombobox);
begin
  inherited Create;
  Control := ALookupComboBox;
  FFirstUse := True;
  FCurrentValue := '';
end;

function TgsIBLCBDataLink.Edit: Boolean;
begin
  if CanModify then
    Result := inherited Edit
  else
    Result := False;  
end;

function TgsIBLCBDataLink.GetCanModify: Boolean;
begin
  Result := not ReadOnly;
end;

procedure TgsIBLCBDataLink.RecordChanged(F: TField);
begin
  inherited;
  if Active and ((Control as TgsdbLookupCombobox).DataField > '') then
  begin
    if (FFirstUse
      or (DataSet.FieldByName((Control as TgsdbLookupCombobox).DataField).AsString <> FCurrentValue))
      and
      ((F = nil) or (AnsiCompareText(F.FieldName, (Control as TgsdbLookupCombobox).DataField) = 0)) then
    begin
      FCurrentValue := DataSet.FieldByName((Control as TgsdbLookupCombobox).DataField).AsString;
      FFirstUse := False;
      (Control as TgsdbLookupCombobox).SyncWithDataSource;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsdbLookupCombobox]);
end;                                          

end.
