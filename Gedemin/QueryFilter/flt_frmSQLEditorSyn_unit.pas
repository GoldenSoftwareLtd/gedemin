
unit flt_frmSQLEditorSyn_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabaseInfo, Db, IBSQL, IBDatabase, IBCustomDataSet, IBQuery,
  ActnList, ImgList, ExtCtrls, StdCtrls, ComCtrls, Grids, DBGrids, DBCtrls,
  ToolWin, SynEdit, SynEditHighlighter, SynHighlighterSQL,
  gd_createable_form, contnrs, gsStorage, Storages, Menus, TB2Item,
  TB2Dock, TB2Toolbar, SuperPageControl, gsDBGrid, StdActns,
  gsIBLookupComboBox, TeEngine, Series, TeeProcs, Chart, TB2ExtItems,
  {$IFDEF GEDEMIN}
  gdcBase,
  {$ENDIF}
  {$IFDEF QBUILDER}
  frxIBXComponents, fqbClass,
  {$ENDIF}
  SynCompletionProposal, flt_i_SQLProposal, flt_SQLProposal, gd_keyAssoc,
  gsIBGrid, frxPreview, frxClass;

type
  TCountRead = Record
    IndReadCount: Integer;
    SeqReadCount: Integer;
    InsertCount: Integer;
    UpdateCount: Integer;
    DeleteCount: Integer;
  end;

type
  THistoryItem = class
  private
    FCaption: string;

  public
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);

    property Caption: string read FCaption write FCaption;
  end;

  THistoryList = class(TObjectList)
  private
    function GetItems(Index: Integer): THistoryItem;
    procedure SetItems(Index: Integer; const Value: THistoryItem);

  public
    function NewItem(const ACaption: String): THistoryItem; overload;
    function NewItem(AStream: TStream): THistoryItem; overload;

    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);

    function IndexOf(Text: String): Integer;
    
    property Items[Index: Integer]: THistoryItem read GetItems write SetItems; default;
  end;

type
  TfrmSQLEditorSyn = class(TCreateableForm)
    ActionList: TActionList;
    actExecute: TAction;
    actPrepare: TAction;
    actCommit: TAction;
    actRollback: TAction;
    actFind: TAction;
    actExport: TAction;
    ibtrEditor: TIBTransaction;
    ibsqlPlan: TIBSQL;
    dsResult: TDataSource;
    IBDatabaseInfo: TIBDatabaseInfo;
    imScript: TImageList;
    actOptions: TAction;
    SynSQLSyn: TSynSQLSyn;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    actReplace: TAction;
    pmHistory: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    actClearHistory: TAction;
    actDeleteHistItem: TAction;
    ActionList2: TActionList;
    pmQuery: TPopupMenu;
    actEditCopy: TEditCopy;
    actEditCut: TEditCut;
    actEditPaste: TEditPaste;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N3: TMenuItem;
    actFind1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    act1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    actOpenScript: TAction;
    actSaveScript: TAction;
    ibqryWork: TIBDataSet;
    actNew: TAction;
    N6: TMenuItem;
    N7: TMenuItem;
    actNextQuery: TAction;
    actPrevQuery: TAction;
    pnlMain: TPanel;
    pcMain: TSuperPageControl;
    tsQuery: TSuperTabSheet;
    seQuery: TSynEdit;
    tsResult: TSuperTabSheet;
    pnlNavigator: TPanel;
    dbNavigator: TDBNavigator;
    dbgResult: TgsDBGrid;
    tsHistory: TSuperTabSheet;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Label14: TLabel;
    eFilter: TEdit;
    lvHistory: TListView;
    tsStatistic: TSuperTabSheet;
    tsLog: TSuperTabSheet;
    mmLog: TMemo;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem13: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem12: TTBItem;
    TBItem11: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem10: TTBItem;
    TBItem9: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBItem5: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem4: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem2: TTBItem;
    TBItem1: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem7: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBDock2: TTBDock;
    TBDock3: TTBDock;
    TBDock4: TTBDock;
    actOk: TAction;
    actCancel: TAction;
    actEditBusinessObject: TAction;
    tbResult: TTBToolbar;
    TBItem14: TTBItem;
    actDeleteBusinessObject: TAction;
    TBItem15: TTBItem;
    TBSeparatorItem8: TTBSeparatorItem;
    iblkupTable: TgsIBLookupComboBox;
    TBControlItem1: TTBControlItem;
    TBControlItem2: TTBControlItem;
    Label13: TLabel;
    tsTransaction: TSuperTabSheet;
    mTransaction: TMemo;
    mTransactionParams: TMemo;
    Panel3: TPanel;
    actParse: TAction;
    TBItem16: TTBItem;
    tsStatisticExtra: TSuperPageControl;
    tsGraphStatistic: TSuperTabSheet;
    ChReads: TChart;
    Series1: THorizBarSeries;
    tsAdditionalStatistic: TSuperTabSheet;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel2: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblPrepare: TLabel;
    lblExecute: TLabel;
    lblFetch: TLabel;
    lblCurrent: TLabel;
    lblMax: TLabel;
    lblBuffer: TLabel;
    Label9: TLabel;
    Bevel3: TBevel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    lblRead: TLabel;
    lblWrite: TLabel;
    lblFetches: TLabel;
    lvReads: TListView;
    TBDock5: TTBDock;
    imStatistic: TTBImageList;
    tbStatistic: TTBToolbar;
    actRefreshChart: TAction;
    TBItem17: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem18: TTBItem;
    TBSeparatorItem10: TTBSeparatorItem;
    TBItem19: TTBItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBItem20: TTBItem;
    TBSeparatorItem12: TTBSeparatorItem;
    TBItem21: TTBItem;
    TBSeparatorItem13: TTBSeparatorItem;
    tbItemAllRecord: TTBItem;
    SynCompletionProposal: TSynCompletionProposal;
    actCopyAllHistory: TAction;
    N8: TMenuItem;
    N9: TMenuItem;
    Label15: TLabel;
    chbxAutoCommitDDL: TCheckBox;
    mmPlan: TMemo;
    Splitter1: TSplitter;
    pModal: TPanel;
    Button1: TButton;
    Button2: TButton;
    tsMonitor: TSuperTabSheet;
    Panel4: TPanel;
    dbnvMonitor: TDBNavigator;
    tbMonitor: TTBToolbar;
    ibgrMonitor: TgsIBGrid;
    ibdsMonitor: TIBDataSet;
    dsMonitor: TDataSource;
    actRefreshMonitor: TAction;
    TBItem22: TTBItem;
    actDeleteStatement: TAction;
    TBItem23: TTBItem;
    actShowMonitorSQL: TAction;
    TBItem24: TTBItem;
    ibtrMonitor: TIBTransaction;
    actDisconnectUser: TAction;
    TBItem25: TTBItem;
    TBSeparatorItem14: TTBSeparatorItem;
    TBSeparatorItem15: TTBSeparatorItem;
    pnlRecord: TPanel;
    TBSeparatorItem16: TTBSeparatorItem;
    actShowGrid: TAction;
    actShowRecord: TAction;
    TBItem26: TTBItem;
    TBItem27: TTBItem;
    sbRecord: TScrollBox;
    actQueryBuilder: TAction;
    TBItem28: TTBItem;
    tsReport: TSuperTabSheet;
    FfrxPreview: TfrxPreview;
    FReport: TfrxReport;
    procedure actPrepareExecute(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actRollbackExecute(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actOptionsUpdate(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvHistoryDblClick(Sender: TObject);
    procedure eFilterChange(Sender: TObject);
    procedure actClearHistoryExecute(Sender: TObject);
    procedure actDeleteHistItemUpdate(Sender: TObject);
    procedure actDeleteHistItemExecute(Sender: TObject);
    procedure actOpenScriptExecute(Sender: TObject);
    procedure actSaveScriptExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actOpenScriptUpdate(Sender: TObject);
    procedure actSaveScriptUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actNextQueryExecute(Sender: TObject);
    procedure actPrevQueryExecute(Sender: TObject);
    procedure actNextQueryUpdate(Sender: TObject);
    procedure actPrevQueryUpdate(Sender: TObject);
    procedure actExecuteUpdate(Sender: TObject);
    procedure actPrepareUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actEditBusinessObjectExecute(Sender: TObject);
    procedure actEditBusinessObjectUpdate(Sender: TObject);
    procedure dbgResultDblClick(Sender: TObject);
    procedure actDeleteBusinessObjectUpdate(Sender: TObject);
    procedure actDeleteBusinessObjectExecute(Sender: TObject);
    procedure pcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure actParseUpdate(Sender: TObject);
    procedure actParseExecute(Sender: TObject);
    procedure actRefreshChartExecute(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    procedure actCopyAllHistoryExecute(Sender: TObject);
    procedure chbxAutoCommitDDLClick(Sender: TObject);
    procedure lvHistoryInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure actRefreshMonitorExecute(Sender: TObject);
    procedure actDeleteStatementUpdate(Sender: TObject);
    procedure actDeleteStatementExecute(Sender: TObject);
    procedure actShowMonitorSQLUpdate(Sender: TObject);
    procedure actShowMonitorSQLExecute(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    procedure ibgrMonitorDblClick(Sender: TObject);
    procedure actDisconnectUserUpdate(Sender: TObject);
    procedure actDisconnectUserExecute(Sender: TObject);
    procedure actShowGridExecute(Sender: TObject);
    procedure actShowGridUpdate(Sender: TObject);
    procedure actShowRecordExecute(Sender: TObject);
    procedure ibqryWorkBeforeClose(DataSet: TDataSet);
    procedure actQueryBuilderExecute(Sender: TObject);
    procedure actQueryBuilderUpdate(Sender: TObject);
    procedure FReportBeforePrint(Sender: TfrxReportComponent);
    procedure seQueryChange(Sender: TObject);
  private
    FOldDelete, FOldInsert, FOldUpdate, FOldIndRead, FOldSeqRead: TStrings;
    FOldRead, FOldWrite, FOldFetches: Integer;
    FPrepareTime, FExecuteTime, FFetchTime: TDateTime;
    FTableArray: TgdKeyStringAssoc;
    FParams: TParams;
    FInitialSQL: String;
    FHistoryList: THistoryList;

    {$IFDEF QBUILDER}
    FEngineIBX: TfrxEngineIBX;
    FqbDialog: TfqbDialog;
    {$ENDIF}

    procedure RemoveNoChange(const Before, After: TStrings);
    function PrepareQuery: Boolean;
    procedure ShowStatistic;
    procedure SaveLastStat;
    function CreateTableList: Boolean;
    procedure AddLogRecord(const StrLog: String);
    function InputParam: Boolean;
    procedure UpdateSyncs;
    procedure UpdateHistoryList;
    procedure AddlvHistoryItem(HI: THistoryItem);
    procedure UpdateHistory;
    procedure UpdateHistoryOfForm;
    procedure SaveHistory;
    procedure LoadHistory;
    procedure DrawChart;
    {$IFDEF GEDEMIN}
    function CreateBusinessObject: TgdcBase;
    {$ENDIF}

  public
    FDatabase: TIBDatabase;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;

    function ShowSQL(const AnSQL: String; const AParams: TParams = nil;
      const AShowModal: Boolean = True): Integer;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmSQLEditorSyn: TfrmSQLEditorSyn;

implementation

uses
  flt_dlgInputParam_unit, syn_ManagerInterface_unit, prp_MessageConst,
  IB, at_Classes, IBHeader, jclStrings,
  {$IFDEF GEDEMIN}
  gdcBaseInterface, flt_sql_parser, at_sql_setup, frxCross,
  {$ENDIF}
  gd_directories_const, Clipbrd, gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cQueryHistory = 'QueryHistory';

//сохраняет строку в поток
procedure SaveStringToStream(const Str: String; Stream: TStream);
var
  L: Integer;
begin
  L := Length(Str);
  Stream.WriteBuffer(L, SizeOf(L));
  if L > 0 then
    Stream.WriteBuffer(Str[1], L);
end;

//читает строку из потока
function ReadStringFromStream(Stream: TStream): String;
var
  L: Integer;
  Str: String;
begin
  try
    Stream.ReadBuffer(L, SizeOf(L));
    SetLength(Str, L);
    if L > 0 then
      Stream.ReadBuffer(Str[1], L);
    Result := Str;
  except
    Result := '';
  end;
end;

{$R *.DFM}

function TfrmSQLEditorSyn.ShowSQL(const AnSQL: String; const AParams: TParams = nil;
  const AShowModal: Boolean = True): Integer;
var
  I: Integer;
begin
  Result := mrNone;
  FParams.Clear;
  if Assigned(AParams) then
  begin
    for I := 0 to AParams.Count - 1 do
      FParams.CreateParam(AParams[I].DataType, AParams[I].Name, AParams[I].ParamType).Value := AParams[I].Value;
    FInitialSQL := AnsiUpperCase(Trim(AnSQL));
  end;

  //Если переданныей текст пустой то выводим тот что есть
  if AnSQL <> '' then
    seQuery.Text := AnSQL;
  ibsqlPlan.Database := FDatabase;
  ibqryWork.Database := FDatabase;
  ibtrEditor.DefaultDatabase := FDatabase;
  IBDatabaseInfo.Database := FDatabase;
  tsResult.TabVisible := False;
  if not CreateTableList then
    Exit;
  if AShowModal then
  begin
    pModal.Visible := True;
    Position := poScreenCenter;
    Result := ShowModal;
  end else
    Show;
end;

function TfrmSQLEditorSyn.InputParam: Boolean;
var
  I, Index: Integer;
  P: TParam;
  S: TStringList;
begin
  with TdlgInputParam.Create(Self) do
  try
    S := TStringList.Create;
    try
      S.Text := ibqryWork.Params.Names;
      for I := 0 to FParams.Count - 1 do
      begin
        Index := S.IndexOf(FParams[i].Name);
        if Index > -1 then
        begin
          case ibqryWork.Params[Index].SQLType and (not 1) of
            SQL_TYPE_DATE:
              ibqryWork.Params.Vars[Index].AsDate := FParams[i].Value;
            SQL_TYPE_TIME:
              ibqryWork.Params.Vars[Index].AsTime := FParams[i].Value;
            SQL_TIMESTAMP:
              ibqryWork.Params.Vars[Index].AsDateTime := FParams[i].Value;
          else
            ibqryWork.Params.Vars[Index].Value := FParams[i].Value;
          end;
        end;
      end;
    finally
      S.Free;
    end;

    Result := SetParams(ibqryWork.Params);

    FParams.Clear;
    for I := 0 to ibqryWork.Params.Count - 1 do
    begin
      P := TParam.Create(FParams);
      P.Name := ibqryWork.Params[i].Name;
      P.Value := ibqryWork.Params[i].Value;
      FParams.AddParam(P);
    end;
  finally
    Free;
  end;
end;

procedure TfrmSQLEditorSyn.AddLogRecord(const StrLog: String);
begin
  mmLog.Lines.Add('');
  mmLog.Lines.Add(StrLog);
end;

function TfrmSQLEditorSyn.CreateTableList: Boolean;
var
  ibsqlTable: TIBSQL;
begin
  ibsqlTable := TIBSQL.Create(Self);
  try
    {$IFDEF GEDEMIN}
    ibsqlTable.Transaction := gdcBaseManager.ReadTransaction;
    {$ENDIF}
    ibsqlTable.SQL.Text :=
      'SELECT RDB$RELATION_ID, RDB$RELATION_NAME FROM RDB$RELATIONS ' +
      'WHERE RDB$VIEW_BLR is NULL AND RDB$RELATION_ID >= 0 ORDER BY RDB$RELATION_ID DESC';
    try
      ibsqlTable.ExecQuery;
      FTableArray.Clear;
      while not ibsqlTable.Eof do
      begin
        FTableArray.ValuesByIndex[FTableArray.Add(ibsqlTable.Fields[0].AsInteger)] :=
          ibsqlTable.Fields[1].AsString;
        ibsqlTable.Next;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle,
          'Произошла ошибка при считывании списка таблиц',
          'Ошибка',
          MB_OK or MB_ICONERROR or MB_TASKMODAL);
        Result := False;
      end;
    end;
  finally
    ibsqlTable.Free;
  end;
end;

procedure TfrmSQLEditorSyn.SaveLastStat;
begin
  FOldInsert.Assign(IBDatabaseInfo.InsertCount);
  FOldDelete.Assign(IBDatabaseInfo.DeleteCount);
  FOldUpdate.Assign(IBDatabaseInfo.UpdateCount);
  FOldIndRead.Assign(IBDatabaseInfo.ReadIdxCount);
  FOldSeqRead.Assign(IBDatabaseInfo.ReadSeqCount);
  FOldRead := IBDatabaseInfo.Reads;
  FOldWrite := IBDatabaseInfo.Writes;
  FOldFetches := IBDatabaseInfo.Fetches;
end;

procedure TfrmSQLEditorSyn.RemoveNoChange(const Before, After: TStrings);
var
  I, J: Integer;

  function ConvertStr(const Str: String): Integer;
  begin
    Result := StrToIntDef(Str, 0);
  end;

begin
  for I := 0 to Before.Count - 1 do
    for J := 0 to After.Count - 1 do
      if Before.Strings[I] = After.Strings[J] then
      begin
        After.Delete(J);
        Break;
      end;
  for I := 0 to After.Count - 1 do
  try
    After.Values[After.Names[I]] :=
      IntToStr(ConvertStr(After.Values[After.Names[I]]) - ConvertStr(Before.Values[After.Names[I]]));
  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TfrmSQLEditorSyn.ShowStatistic;
const
  MaxColCount = 5;

var
  SL: TStrings;

  procedure AddRecord(const AnSource: TStrings; const AnColIndex: Integer);
  var
    I, J: Integer;
    Flag: Boolean;
    L: TListItem;
  begin
    for I := 0 to AnSource.Count - 1 do
    begin
      Flag := False;
      for J := 0 to lvReads.Items.Count - 1 do
        if StrToInt(AnSource.Names[I]) = Integer(lvReads.Items[J].Data) then
        begin
          lvReads.Items[J].SubItems.Strings[AnColIndex] := AnSource.Values[AnSource.Names[I]];
          Flag := True;
          Break;
        end;

      if not Flag then
      begin
        L := lvReads.Items.Add;
        L.Data := Pointer(StrToInt(AnSource.Names[I]));
        if FTableArray.IndexOf(Integer(L.Data)) = -1 then
          CreateTableList;
        L.Caption := FTableArray.ValuesByKey[Integer(L.Data)];
        for J := 0 to MaxColCount - 1 do
          L.SubItems.Add('0');
        L.SubItems[AnColIndex] := AnSource.Values[AnSource.Names[I]];
      end;
    end;
  end;
begin
  SL := TStringList.Create;
  try
    lvReads.Items.Clear;
    SL.Assign(IBDatabaseInfo.ReadIdxCount);
    RemoveNoChange(FOldIndRead, SL);
    AddRecord(SL, 0);

    SL.Assign(IBDatabaseInfo.ReadSeqCount);
    RemoveNoChange(FOldSeqRead, SL);
    AddRecord(SL, 1);

    SL.Assign(IBDatabaseInfo.InsertCount);
    RemoveNoChange(FOldInsert, SL);
    AddRecord(SL, 2);

    SL.Assign(IBDatabaseInfo.UpdateCount);
    RemoveNoChange(FOldUpdate, SL);
    AddRecord(SL, 3);

    SL.Assign(IBDatabaseInfo.DeleteCount);
    RemoveNoChange(FOldDelete, SL);
    AddRecord(SL, 4);

    if tbItemAllRecord.Checked then
      tbItemAllRecord.Checked := false;
    DrawChart;

    lblCurrent.Caption := IntToStr(IBDatabaseInfo.CurrentMemory);
    lblMax.Caption := IntToStr(IBDatabaseInfo.MaxMemory);
    lblBuffer.Caption := IntToStr(IBDatabaseInfo.PageSize);

    lblRead.Caption := IntToStr(IBDatabaseInfo.Reads - FOldRead);
    lblWrite.Caption := IntToStr(IBDatabaseInfo.Writes - FOldWrite);
    lblFetches.Caption := IntToStr(IBDatabaseInfo.Fetches - FOldFetches);

    lblPrepare.Caption := IntToStr(DateTimeToTimeStamp(FPrepareTime).Time);
    lblExecute.Caption := IntToStr(DateTimeToTimeStamp(FExecuteTime).Time);
    lblFetch.Caption := IntToStr(DateTimeToTimeStamp(FFetchTime).Time);
  finally
    SL.Free;
  end;
end;

function TfrmSQLEditorSyn.PrepareQuery: Boolean;
begin
  if not ibtrEditor.InTransaction then
    ibtrEditor.StartTransaction;
  Result := False;
  ibsqlPlan.Close;
  ibsqlPlan.SQL.Text := seQuery.Text;
  try
    AddLogRecord('/*------' + DateTimeToStr(Now) + '------*/');
    AddLogRecord(seQuery.Text);
    try
      try
        ibsqlPlan.ParamCheck := True;
        ibsqlPlan.Prepare;
      except
        //если скл имеет тип DDLSQl то нужно установить paramCheck  в фолсе
        ibsqlPlan.ParamCheck := False;
        ibsqlPlan.Prepare;
      end;
      mmPlan.Text := ibsqlPlan.Plan;
    finally
      ibsqlPlan.FreeHandle;
    end;
    Result := True;
  except
    on E: Exception do
    begin
      if (E is EIBClientError) and (EIBClientError(E).SQLCode = Ord(ibxeUnknownPlan)) then
      begin
        mmPlan.Text := 'Невозможно получить план запроса.';
        AddLogRecord('Невозможно получить план запроса.');
        Result := True;
      end else
      begin
        mmPlan.Text := E.Message;
        mmPlan.Color := $AAAAFF;
        AddLogRecord(E.Message);
      end;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actPrepareExecute(Sender: TObject);
begin
  PrepareQuery;
end;

procedure TfrmSQLEditorSyn.actExecuteExecute(Sender: TObject);
var
  StartTime: TDateTime;
  I, K: Integer;
  S: String;
begin
  if PrepareQuery then
  begin
    //Добавляем в историю запросов
    K := FHistoryList.IndexOf(seQuery.Lines.Text);
    if (K = -1) or (lvHistory.Selected = nil)
      or (FHistoryList[Integer(lvHistory.Selected.Data)].Caption <> seQuery.Lines.Text) then
    begin
      FHistoryList.NewItem(seQuery.Lines.Text);
      SaveHistory;
      UpdateHistory;
      UpdateHistoryOfForm;
    end;

    ibqryWork.Close;
    ibqryWork.SelectSQL.Text := seQuery.Text;

    try
      ibqryWork.ParamCheck := True;
      ibqryWork.Prepare;
    except
      ibqryWork.ParamCheck := False;
      ibqryWork.Prepare;
    end;

    if ibqryWork.SQLType in [SQLExecProcedure, SQLInsert, SQLSelectForUpdate,
      SQLSetGenerator, SQLSelect, SQLUpdate, SQLDelete] then
    begin
      ibqryWork.ParamCheck := True;
      if not InputParam then
        exit;
    end else
    begin
      ibqryWork.ParamCheck := False;
    end;
    ibqryWork.UnPrepare;

    ibqryWork.DisableControls;
    try
      SaveLastStat;

      StartTime := Now;
      ibqryWork.Prepare;

      FPrepareTime := Now - StartTime;

      if (ibqryWork.SQLType = SQLDDL) and (UserStorage <> nil)
        and UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False) then
      begin
        actCommit.Execute;
      end;

      StartTime := Now;
      ibqryWork.Open;
      FExecuteTime := Now - StartTime;

      if ibqryWork.SQLType in [SQLExecProcedure, SQLSelect, SQLSelectForUpdate] then
      begin
        tsResult.TabVisible := True;
        pcMain.ActivePage := tsResult;

        dbgResult.Visible := True;
        pnlRecord.Visible := False;
        actShowGrid.Checked := True;
        actShowRecord.Checked := False;
      end else
      begin
        if pcMain.ActivePage = tsResult then
          pcMain.ActivePage := tsQuery;
        tsResult.TabVisible := False;
      end;

      if (ibqryWork.SQLType = SQLDDL) and (UserStorage <> nil)
        and UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False) then
      begin
        actCommit.Execute;
      end;

      StartTime := Now;
      ibqryWork.EnableControls;
      FFetchTime := Now - StartTime;

      ShowStatistic;

      if ibqryWork.QSelect.SQLType in [SQLInsert, SQLUpdate, SQLDelete, SQLExecProcedure] then
        mmPlan.Lines.Add('RowsAffected: ' + IntToStr(ibqryWork.QSelect.RowsAffected));

    except
      on E: Exception do
      begin
        mmPlan.Text := E.Message;
        mmPlan.Color := $AAAAFF;
        AddLogRecord(E.Message);
      end;
    end;
    ibqryWork.EnableControls;

    if pcMain.ActivePage = tsResult then
    begin
      dbgResult.ShowFooter := True;
      for I := 0 to dbgResult.Columns.Count - 1 do
      begin
        if (dbgResult.Columns[I] is TgsColumn)
          and (dbgResult.Columns[I].Field is TNumericField) then
        begin
          S := UpperCase(dbgResult.Columns[I].Field.FieldName);
          if Pos(S + ';', 'ID;PARENT;LB;RB;AVIEW;ACHAG;AFULL;') = 0 then
          begin
            if (Length(S) < 4) or (Copy(S, Length(S) - 3 + 1, 3) <> 'KEY') then
            begin
              TgsColumn(dbgResult.Columns[I]).TotalType := ttSum;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actCommitExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
    ibtrEditor.Commit;
  if pcMain.ActivePage = tsResult then
    pcMain.ActivePage := tsQuery;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actRollbackExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
    ibtrEditor.Rollback;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actCommitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibtrEditor.InTransaction;
end;

procedure TfrmSQLEditorSyn.FormCreate(Sender: TObject);
var
  I: Integer;
  {$IFDEF GEDEMIN}
  SL: TStringList;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  iblkupTable.Transaction := gdcBaseManager.ReadTransaction;
  {$ENDIF}

  mTransaction.Lines.Text := ibtrEditor.Params.Text;
  mTransactionParams.Lines.Clear;
  for I := Low(TPBConstantNames) to High(TPBConstantNames) do
  begin
    mTransactionParams.Lines.Add(TPBConstantNames[I]);
  end;

  actNew.ShortCut := ShortCut(Ord('N'), [ssCtrl, ssShift]);
  FOldDelete := TStringList.Create;
  FOldInsert := TStringList.Create;
  FOldUpdate := TStringList.Create;
  FOldIndRead := TStringList.Create;
  FOldSeqRead := TStringList.Create;

  {$IFDEF GEDEMIN}
  SL := TStringList.Create;
  try
    gdcBaseManager.Database.GetTableNames(SL, True);
    tsMonitor.TabVisible := SL.IndexOf('MON$STATEMENTS') <> -1;
  finally
    SL.Free;
  end;
  ibtrMonitor.DefaultDatabase := gdcBaseManager.Database;
  {$ENDIF}

  pnlRecord.Visible := False;
  dbgResult.Visible := True;
  actShowGrid.Checked := True;
  actShowRecord.Checked := False;

  pcMain.ActivePage := tsQuery;
  ActiveControl := seQuery;
  UpdateSyncs;

  if UserStorage <> nil then
    chbxAutoCommitDDL.Checked := UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False);
end;

procedure TfrmSQLEditorSyn.FormDestroy(Sender: TObject);
begin
  FOldDelete.Free;
  FOldInsert.Free;
  FOldUpdate.Free;
  FOldIndRead.Free;
  FOldSeqRead.Free;
end;

procedure TfrmSQLEditorSyn.actOptionsExecute(Sender: TObject);
begin
  if Assigned(SynManager) then
    if SynManager.ExecuteDialog then
      UpdateSyncs;
end;

procedure TfrmSQLEditorSyn.UpdateSyncs;
begin
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynSQLSyn);
    seQuery.Font.Assign(SynManager.GetHighlighterFont);
    SynManager.GetSynEditOptions(seQuery);
  end;
end;

procedure TfrmSQLEditorSyn.actOptionsUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Assigned(SynManager);
end;

constructor TfrmSQLEditorSyn.Create(AnOwner: TComponent);
begin
  inherited;
  UseDesigner := False;
  FParams := TParams.Create;
  FHistoryList := THistoryList.Create(True);
  ShowSpeedButton := True;
  FTableArray := TgdKeyStringAssoc.Create;

  {$IFDEF GEDEMIN}
  if Assigned(gdcBaseManager) then
  begin
    FDatabase := gdcBaseManager.Database;
    ibsqlPlan.Database := FDatabase;
    ibqryWork.Database := FDatabase;
    ibtrEditor.DefaultDatabase := FDatabase;
    IBDatabaseInfo.Database := FDatabase;
  end;

  if SQLProposal = nil then
    SQLProposalObject := TSQLProposal.Create(nil);

  {$IFDEF QBUILDER}
  FEngineIBX := TfrxEngineIBX.Create(nil);
  FEngineIBX.SetDatabase(FDataBase);

  FqbDialog := TfqbDialog.Create(nil);
  FqbDialog.Engine := FEngineIBX;

  actQueryBuilder.Visible := True;

  FReport.EngineOptions.DestroyForms := False;
  FReport.Preview := FfrxPreview;
  
  {$ELSE}
  actQueryBuilder.Visible := False;
  {$ENDIF}

  {$ENDIF}
end;

destructor TfrmSQLEditorSyn.Destroy;
begin
  FParams.Free;
  FHistoryList.Free;
  FTableArray.Free;
  {$IFDEF QBUILDER}
  FEngineIBX.Free;
  FqbDialog.Free;
  {$ENDIF}
  inherited;
end;


procedure TfrmSQLEditorSyn.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if seQuery.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TfrmSQLEditorSyn.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if seQuery.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    if seQuery.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_REPLACE),
       MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actFindExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsQuery then
  begin
    if seQuery.SelAvail then
      FindDialog1.FindText := seQuery.SelText
    else
      FindDialog1.FindText := seQuery.WordAtCursor;
    FindDialog1.Execute;
  end else
  begin
    dbgResult.FindInGrid;
  end;
end;

procedure TfrmSQLEditorSyn.actReplaceExecute(Sender: TObject);
begin
  if seQuery.SelAvail then
    ReplaceDialog1.FindText := seQuery.SelText
  else
    ReplaceDialog1.FindText := seQuery.WordAtCursor;
  ReplaceDialog1.Execute;
end;

procedure TfrmSQLEditorSyn.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  ShiftDown: Boolean;
begin
  ShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  if (Action = caHide) and ShiftDown then
    Action := caFree;
end;

procedure TfrmSQLEditorSyn.lvHistoryDblClick(Sender: TObject);
begin
  if lvHistory.Selected <> nil then
  begin
    seQuery.Lines.Text := FHistoryList[Integer(lvHistory.Selected.Data)].Caption;
    seQuery.Show;
  end;
end;

procedure TfrmSQLEditorSyn.UpdateHistoryList;
var
  I: Integer;
begin
  lvHistory.Items.BeginUpdate;
  try
    lvHistory.Items.Clear;
    for I := 0 to FHistoryList.Count - 1 do
    begin
      if (eFilter.Text = '') or (StrIPos(eFilter.Text, FHistoryList[I].Caption) > 0) then
        AddlvHistoryItem(FHistoryList[I]);
    end;
  finally
    lvHistory.Items.EndUpdate;
  end;
  if lvHistory.Items.Count > 0 then
  begin
    lvHistory.Items[lvHistory.Items.Count - 1].Selected := True;
    lvHistory.Items[lvHistory.Items.Count - 1].MakeVisible(False);
  end;
end;

{ THistoryList }

function THistoryList.GetItems(Index: Integer): THistoryItem;
begin
  Result := THistoryItem(inherited Items[Index]);
end;

function THistoryList.IndexOf(Text: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if AnsiCompareText(Items[I].Caption, Text) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure THistoryList.LoadFromStream(Stream: TStream);
var
  I: Integer;
  C: Integer;
begin
  Clear;
  if Assigned(Stream) then
  begin
    if Stream.Read(C, SizeOf(C)) = SizeOf(C) then
    begin
      for I := 0 to C - 1 do
      begin
        if Stream.Position >= Stream.Size then
          break;

        NewItem(Stream);
      end;
    end;
  end;
end;

function THistoryList.NewItem(const ACaption: String): THistoryItem;
begin
  Result := THistoryItem.Create;
  Result.Caption := ACaption;
  Add(Result);
end;

function THistoryList.NewItem(AStream: TStream): THistoryItem;
begin
  Result := THistoryItem.Create;
  Result.LoadFromStream(AStream);
  Add(Result);
end;

procedure THistoryList.SaveToStream(Stream: TStream);
const
  MaxItemsCount = 120;
var
  I, J: Integer;
begin
  if Stream <> nil then
  begin
    I := Count - 1;
    while I >= 0 do
    begin
      J := I - 1;
      while J >= 0 do
      begin
        if Items[I].Caption = Items[J].Caption then
        begin
          Delete(J);
          Dec(I);
        end;
        Dec(J);
      end;

      Dec(I);
    end;

    for I := 1 to (Count - MaxItemsCount) do
      Delete(0);

    Stream.WriteBuffer(Count, SizeOf(Count));
    for I := 0 to Count - 1 do
      Items[I].SaveToStream(Stream);
  end;
end;

procedure THistoryList.SetItems(Index: Integer; const Value: THistoryItem);
begin
  inherited Items[Index] := Value;
end;

procedure TfrmSQLEditorSyn.AddlvHistoryItem(HI: THistoryItem);
var
  LI: TListItem;
  I: Integer;
  S: String;
begin
  LI := lvHistory.Items.Add;
  LI.Caption := IntToStr(lvHistory.Items.Count - 1);
  S := HI.Caption;
  for I := 1 to Length(S) do
  begin
    if S[I] in [#10, #13] then
      S[I] := ' '
  end;
  LI.Data := Pointer(TObjectList(FHistoryList).IndexOf(HI));
  LI.SubItems.Add(S);
  LI.Selected := True;
  LI.MakeVisible(False);
end;

procedure TfrmSQLEditorSyn.eFilterChange(Sender: TObject);
begin
  UpdateHistoryList;
end;

{ THistoryItem }

procedure THistoryItem.LoadFromStream(Stream: TStream);
begin
  if Assigned(Stream) then
    FCaption := ReadStringFromStream(Stream);
end;

procedure THistoryItem.SaveToStream(Stream: TStream);
begin
  if Stream <> nil then
    SaveStringToStream(FCaption, Stream)
end;

procedure TfrmSQLEditorSyn.UpdateHistoryOfForm;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    if (Screen.Forms[I] is TfrmSQLEditorSyn) and
      (Screen.Forms[I] <> Self) then
      TfrmSQLEditorSyn(Screen.Forms[I]).UpdateHistory;
  end;
end;

procedure TfrmSQLEditorSyn.UpdateHistory;
begin
  LoadHistory;
  UpdateHistoryList;
end;

procedure TfrmSQLEditorSyn.SaveHistory;
var
  Path: String;
  F: TgsStorageFolder;
  M: TMemoryStream;
begin
  Path := Name;
  F := UserStorage.OpenFolder(Path, True, False);
  if F <> nil then
  begin
    M := TMemoryStream.Create;
    try
      FHistoryList.SaveToStream(M);
      F.WriteStream(cQueryHistory, M);
    finally
      M.Free;
    end;
    UserStorage.CloseFolder(F, False);
  end;
end;

procedure TfrmSQLEditorSyn.LoadHistory;
var
  Path: String;
  F: TgsStorageFolder;
  M: TMemoryStream;
begin
  Path := Name;
  F := UserStorage.OpenFolder(Path, False);
  if F <> nil then
  begin
    M := TMemoryStream.Create;
    try
      F.ReadStream(cQueryHistory, M);
      FHistoryList.LoadFromStream(M);
    finally
      M.Free;
    end;
    UserStorage.CloseFolder(F, False);
  end;
end;

procedure TfrmSQLEditorSyn.LoadSettings;
begin
  inherited;
  UpdateHistory;
  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TfrmSQLEditorSyn.SaveSettings;
begin
  inherited;
  SaveHistory;
  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TfrmSQLEditorSyn.actClearHistoryExecute(Sender: TObject);
begin
  FHistoryList.Clear;
  SaveHistory;
  UpdateHistoryList;
  UpdateHistoryOfForm;
end;

procedure TfrmSQLEditorSyn.actDeleteHistItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvHistory.Selected <> nil;
end;

procedure TfrmSQLEditorSyn.actDeleteHistItemExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := Integer(lvHistory.Selected.Data);
  FHistoryList.Delete(Index);
  SaveHistory;
  UpdateHistory;
  UpdateHistoryOfForm;
end;

class function TfrmSQLEditorSyn.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmSQLEditorSyn) then
    frmSQLEditorSyn := TfrmSQLEditorSyn.Create(AnOwner);
  Result := frmSQLEditorSyn;
end;

procedure TfrmSQLEditorSyn.actOpenScriptExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
    seQuery.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TfrmSQLEditorSyn.actSaveScriptExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
    seQuery.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TfrmSQLEditorSyn.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (pcMain.ActivePage = tsQuery) or
    (pcMain.ActivePage = tsResult);
end;

procedure TfrmSQLEditorSyn.actOpenScriptUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actSaveScriptUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actNewExecute(Sender: TObject);
begin
  seQuery.Text := '';
  pcMain.ActivePage := tsQuery;
end;

procedure TfrmSQLEditorSyn.actNextQueryExecute(Sender: TObject);
var
  LI: TListItem;
begin
  if lvHistory.Selected = nil then
  begin
    if lvHistory.Items.Count > 0 then
    begin
      lvHistory.Selected := lvHistory.Items[lvHistory.Items.Count - 1];
    end;
  end;

  if lvHistory.Selected <> nil then
  begin
    LI := lvHistory.GetNextItem(lvHistory.Selected, sdBelow, [isNone]);

    if (LI <> nil) then
    begin
      lvHistory.Selected := LI;
      if pcMain.ActivePage = tsQuery then
      begin
        seQuery.Lines.Text := FHistoryList[Integer(lvHistory.Selected.Data)].Caption;
        seQuery.Show;
      end;  
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actPrevQueryExecute(Sender: TObject);
var
  LI: TListItem;
begin
  if lvHistory.Selected = nil then
  begin
    if lvHistory.Items.Count > 0 then
    begin
      lvHistory.Selected := lvHistory.Items[0];
    end;
  end;

  if lvHistory.Selected <> nil then
  begin
    LI := lvHistory.GetNextItem(lvHistory.Selected, sdAbove, [isNone]);

    if (LI <> nil) then
    begin
      lvHistory.Selected := LI;
      if pcMain.ActivePage = tsQuery then
      begin
        seQuery.Lines.Text := FHistoryList[Integer(lvHistory.Selected.Data)].Caption;
        seQuery.Show;
      end;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actNextQueryUpdate(Sender: TObject);
begin
  actNextQuery.Enabled := (pcMain.ActivePage = tsQuery) or (pcMain.ActivePage = tsHistory);
end;

procedure TfrmSQLEditorSyn.actPrevQueryUpdate(Sender: TObject);
begin
  actPrevQuery.Enabled := (pcMain.ActivePage = tsQuery) or (pcMain.ActivePage = tsHistory);
end;

procedure TfrmSQLEditorSyn.actExecuteUpdate(Sender: TObject);
begin
  actExecute.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actPrepareUpdate(Sender: TObject);
begin
  actPrepare.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.LoadSettingsAfterCreate;
begin
  inherited;

  if lvHistory.Items.Count > 0 then
  begin
    lvHistory.Selected := lvHistory.Items[lvHistory.Items.Count - 1];
    if lvHistory.Selected <> nil then
    begin
      seQuery.Lines.Text := FHistoryList[lvHistory.Selected.Index].Caption;
    end;  
  end;
end;

procedure TfrmSQLEditorSyn.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfrmSQLEditorSyn.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel
end;

{$IFDEF GEDEMIN}
function TfrmSQLEditorSyn.CreateBusinessObject: TgdcBase;
var
  SL: TStringList;
  C: TgdcFullClass;
  RN, FN, Org: String;
  Obj: TgdcBase;
  R: TatRelation;
  I: Integer;
begin
  Result := nil;
  SL := TStringList.Create;
  try
    ExtractTablesList(ibqryWork.QSelect.SQL.Text, SL, False, True);
    if SL.Count > 0 then
    begin
      if (SL.Count > 1) and (SL.IndexOfName('z') > -1) then
        RN := Sl.Values['z']
      else
        RN := SL.Values[SL.Names[0]];

      C := GetBaseClassForRelation(RN);
      if C.gdClass <> nil then
      begin
        Obj := C.gdClass.CreateSubType(Application, C.SubType, 'ByID');
        try
          R := atDatabase.Relations.ByRelationName(RN);
          if (R <> nil)
            and (R.PrimaryKey <> nil)
            and (R.PrimaryKey.ConstraintFields.Count = 1) then
          begin
            FN := R.PrimaryKey.ConstraintFields[0].FieldName;
          end else
            FN := 'id';

          Org := '"' + RN + '"."' + FN + '"';

          for I := 0 to ibqryWork.Fields.Count - 1 do
          begin
            if (AnsiCompareText(ibqryWork.Fields[I].Origin, Org) = 0) and
              (ibqryWork.Fields[I] is TIntegerField) then
            begin
              Obj.ID := ibqryWork.Fields[I].AsInteger;
              Obj.Open;
              if not Obj.EOF then
              begin
                C := Obj.GetCurrRecordClass;
                if (C.gdClass <> nil) and
                  ((Obj.ClassType <> C.gdClass) or (Obj.SubType <> C.SubType)) then
                begin
                  Obj.Free;
                  Obj := C.gdClass.CreateSubType(Application, C.SubType, 'ByID');
                  Obj.ID := ibqryWork.Fields[I].AsInteger;
                  Obj.Open;
                  if Obj.EOF then
                    FreeAndNil(Obj);
                end;

                Result := Obj;
                Obj := nil;
              end;
              break;
            end;
          end;
        finally
          Obj.Free;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;
{$ENDIF}

procedure TfrmSQLEditorSyn.actEditBusinessObjectExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
begin
  Obj := CreateBusinessObject;
  try
    if Obj <> nil then
      Obj.EditDialog('');
  finally
    Obj.Free;
  end;
{$ELSE}
begin
{$ENDIF}  
end;

procedure TfrmSQLEditorSyn.actEditBusinessObjectUpdate(Sender: TObject);
begin
  actEditBusinessObject.Enabled := ibqryWork.Active and
    (not ibqryWork.IsEmpty);
end;

procedure TfrmSQLEditorSyn.dbgResultDblClick(Sender: TObject);
begin
  actEditBusinessObject.Execute;
end;

procedure TfrmSQLEditorSyn.actDeleteBusinessObjectUpdate(Sender: TObject);
begin
  actDeleteBusinessObject.Enabled := ibqryWork.Active and
    (not ibqryWork.IsEmpty);
end;

procedure TfrmSQLEditorSyn.actDeleteBusinessObjectExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
begin
  Obj := CreateBusinessObject;
  try
    if Obj <> nil then
    begin
      if MessageBox(Handle,
        'Удалить выбранный объект?',
        'Внимание',
        MB_ICONEXCLAMATION or MB_YESNO) = IDYES then
      begin
        Obj.Delete;
      end;
    end;
  finally
    Obj.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TfrmSQLEditorSyn.pcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (pcMain.ActivePage = tsTransaction)
    and (ibtrEditor <> nil) then
  begin
    if ibtrEditor.InTransaction then
      ibtrEditor.Commit;
    ibtrEditor.Params.Text := mTransaction.Lines.Text;
    try
      ibtrEditor.StartTransaction;
      AllowChange := True;
    except
      MessageBox(Handle,
        'Задан неверный параметр транзакции.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      AllowChange := False;
    end;
  end
  else if (pcMain.ActivePage = tsMonitor)
    and (ibdsMonitor <> nil) then
  begin
    ibdsMonitor.Close;
    if ibtrMonitor.InTransaction then
      ibtrMonitor.Commit;
  end;
end;

procedure TfrmSQLEditorSyn.actParseUpdate(Sender: TObject);
begin
  actParse.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actParseExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  with TatSQLSetup.Create(nil) do
  try
    seQuery.Text := PrepareSQL(gdcBaseManager.ProcessSQL(seQuery.Text));
  finally
    Free;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actRefreshChartExecute(Sender: TObject);
begin
  TTBItem(Sender).Checked := not TTBItem(Sender).Checked;
  DrawChart;
end;

procedure TfrmSQLEditorSyn.DrawChart;
{$IFDEF GEDEMIN}
const
  MaxColCount = 5;
var
  I, J: Integer;
  FIBSQL: TIBSQL;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  with ChReads.SeriesList.Items[0] do
  //with ChReads.SeriesList.Series[0] do
  begin
    Clear;
    for I := 0 to lvReads.Items.Count - 1 do
    begin
      for J := 0 to MaxColCount - 1 do
      begin
        case J of
          0:
          begin
            if (tbStatistic.Items[J].Checked) and (StrToInt(lvReads.Items[I].SubItems[J]) > 0) then
              Add(StrToInt(lvReads.Items[I].SubItems[J]), Trim(lvReads.Items[I].Caption), clBlue);
          end;
          1:
          begin
            if (tbStatistic.Items[J+1].Checked) and (StrToInt(lvReads.Items[I].SubItems[J]) > 0) then
              Add(StrToInt(lvReads.Items[I].SubItems[J]), Trim(lvReads.Items[I].Caption), clRed);
          end;
          2:
          begin
            if (tbStatistic.Items[J+2].Checked) and (StrToInt(lvReads.Items[I].SubItems[J]) > 0) then
              Add(StrToInt(lvReads.Items[I].SubItems[J]), Trim(lvReads.Items[I].Caption), clTeal);
          end;
          3:
          begin
            if (tbStatistic.Items[J+3].Checked) and (StrToInt(lvReads.Items[I].SubItems[J]) > 0) then
              Add(StrToInt(lvReads.Items[I].SubItems[J]), Trim(lvReads.Items[I].Caption), clGreen);
          end;
          4:
          begin
            if (tbStatistic.Items[J+4].Checked) and (StrToInt(lvReads.Items[I].SubItems[J]) > 0) then
              Add(StrToInt(lvReads.Items[I].SubItems[J]), Trim(lvReads.Items[I].Caption), clMaroon);
          end;
        end;
      end;

      //Подсчитаем кол-во всех записей
      if tbItemAllRecord.Checked then
      begin
        FIBSQL := TIBSQL.Create(nil);
        FIBSQL.Transaction := gdcBaseManager.ReadTransaction;
        try
          FIBSQL.SQL.Text :=
            'SELECT COUNT(*) FROM ' + Trim(lvReads.Items[I].Caption);
          FIBSQL.ExecQuery;
          if FIBSQL.RecordCount > 0 then
            Add(FIBSQL.FieldByName('COUNT').AsInteger, Trim(lvReads.Items[I].Caption), clYellow);
          FIBSQL.Close
        finally
          FIBSQL.Free;
        end;
      end;
    end;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.SynCompletionProposalExecute(
  Kind: SynCompletionType; Sender: TObject; var AString: String; x,
  y: Integer; var CanExecute: Boolean);
var
  str: string;
  Script: TStrings;
begin

  CanExecute := False;
  if Assigned(SQLProposal) then
  begin
    str := seQuery.LineText;
    str := SQLProposal.GetStatement(str, seQuery.CaretX);

    if str = '' then
    begin
      SynCompletionProposal.ItemList.Assign(SQLProposal.ItemList);
      SynCompletionProposal.InsertList.Assign(SQLProposal.InsertList);
      CanExecute := SynCompletionProposal.ItemList.Count > 0;
    end else
    begin
      Script := TStringList.Create;
      try
        Script.Assign(seQuery.Lines);
        SQLProposal.PrepareSQL(str, Script);
      finally
        Script.Free;
      end;
      SynCompletionProposal.ItemList.Assign(SQLProposal.FieldItemList);
      SynCompletionProposal.InsertList.Assign(SQLProposal.FieldInsertList);
      CanExecute := SynCompletionProposal.ItemList.Count > 0;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actCopyAllHistoryExecute(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  S := '';
  for I := 0 to FHistoryList.Count - 1 do
    S := S + FHistoryList[I].Caption + #13#10 + #13#10 + #13#10;
  if S > '' then
    Clipboard.AsText := S;
end;

procedure TfrmSQLEditorSyn.chbxAutoCommitDDLClick(Sender: TObject);
begin
  if UserStorage <> nil then
  begin
    if chbxAutoCommitDDL.Checked then
      UserStorage.DeleteValue('Options', 'AutoCommitDDL', False)
    else
      UserStorage.WriteBoolean('Options', 'AutoCommitDDL', False);
  end;
end;

procedure TfrmSQLEditorSyn.lvHistoryInfoTip(Sender: TObject;
  Item: TListItem; var InfoTip: String);
begin
  InfoTip := FHistoryList[Integer(Item.Data)].Caption
end;

procedure TfrmSQLEditorSyn.actRefreshMonitorExecute(Sender: TObject);
begin
  ibdsMonitor.Close;
  if ibtrMonitor.InTransaction then
    ibtrMonitor.Commit;
  ibtrMonitor.StartTransaction;
  ibdsMonitor.Open;
end;

procedure TfrmSQLEditorSyn.actDeleteStatementUpdate(Sender: TObject);
begin
  actDeleteStatement.Enabled := ibdsMonitor.Active and
    (not ibdsMonitor.IsEmpty) and
    (ibdsMonitor.FieldByName('mon$state').AsInteger = 1) and
    (IBLogin <> nil) and
    IBLogin.IsIBUserAdmin;
end;

procedure TfrmSQLEditorSyn.actDeleteStatementExecute(Sender: TObject);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    {$IFDEF GEDEMIN}
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := 'DELETE FROM mon$statements WHERE mon$statement_id = :ID';
    q.ParamByName('id').AsInteger := ibdsMonitor.FieldByName('mon$statement_id').AsInteger;
    q.ExecQuery;
    q.Close;
    Tr.Commit;
    {$ENDIF}
  finally
    q.Free;
    Tr.Free;
  end;

  actRefreshMonitor.Execute;
end;

procedure TfrmSQLEditorSyn.actShowMonitorSQLUpdate(Sender: TObject);
begin
  actShowMonitorSQL.Enabled := ibdsMonitor.Active and
    (not ibdsMonitor.IsEmpty);
end;

procedure TfrmSQLEditorSyn.actShowMonitorSQLExecute(Sender: TObject);
begin
  seQuery.Lines.Text := ibdsMonitor.FieldByName('mon$sql_text').AsString;
  seQuery.Show;
end;

procedure TfrmSQLEditorSyn.pcMainChange(Sender: TObject);
begin
  if (pcMain.ActivePage = tsMonitor)
    and (ibdsMonitor <> nil) then
  begin
    actRefreshMonitor.Execute;
  end;

  if pcMain.ActivePage = tsReport then
    FReport.ShowReport;
end;

procedure TfrmSQLEditorSyn.ibgrMonitorDblClick(Sender: TObject);
begin
  actShowMonitorSQL.Execute;
end;

procedure TfrmSQLEditorSyn.actDisconnectUserUpdate(Sender: TObject);
begin
  actDisconnectUser.Enabled := ibdsMonitor.Active and
    (not ibdsMonitor.IsEmpty) and
    (IBLogin <> nil) and
    IBLogin.IsIBUserAdmin;
end;

procedure TfrmSQLEditorSyn.actDisconnectUserExecute(Sender: TObject);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if MessageBox(Handle,
    PChar('Разорвать соединение с пользователем ' + ibdsMonitor.FieldByName('gd_user').AsString + '?'),
    'Внимание',
    MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO then
  begin
    exit;
  end;

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    {$IFDEF GEDEMIN}
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := 'DELETE FROM mon$attachments WHERE mon$attachment_id = :ID';
    q.ParamByName('id').AsInteger := ibdsMonitor.FieldByName('mon$attachment_id').AsInteger;
    q.ExecQuery;
    q.Close;
    Tr.Commit;
    {$ENDIF}
  finally
    q.Free;
    Tr.Free;
  end;

  actRefreshMonitor.Execute;
end;

procedure TfrmSQLEditorSyn.actShowGridExecute(Sender: TObject);
begin
  if not actShowGrid.Checked then
  begin
    dbgResult.Visible := True;
    pnlRecord.Visible := False;

    actShowRecord.Checked := False;
    actShowGrid.Checked := True;
  end;
end;

procedure TfrmSQLEditorSyn.actShowGridUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibqryWork.Active;
end;

procedure TfrmSQLEditorSyn.actShowRecordExecute(Sender: TObject);
var
  L: TLabel;
  E: TCustomEdit;
  I, Y: Integer;
begin
  if not actShowRecord.Checked then
  begin
    dbgResult.Visible := False;
    pnlRecord.Visible := True;

    actShowRecord.Checked := True;
    actShowGrid.Checked := False;

    if sbRecord.ComponentCount = 0 then
    begin
      Y := 6;
      for I := 0 to ibqryWork.FieldCount - 1 do
      begin
        L := TLabel.Create(sbRecord);
        L.Parent := sbRecord;
        L.Left := 6;
        L.Top := Y + 2;
        L.ParentFont := True;
        L.AutoSize := False;
        L.Width := 150;
        L.Caption := ibqryWork.Fields[I].FieldName + ':';
        L.ShowHint := True;
        L.Hint := ibqryWork.Fields[I].FieldName + #13#10 +
          //ibqryWork.Fields[I].DisplayLabel + #13#10 +
          ibqryWork.Fields[I].Origin;

        if ibqryWork.Fields[I] is TBlobField then
          E := TDBMemo.Create(sbRecord)
        else
          E := TDBEdit.Create(sbRecord);
        E.Parent := sbRecord;
        E.Left := 160;
        E.Top := Y;
        E.Height := 21;
        if (ibqryWork.Fields[I] is TNumericField) or (ibqryWork.Fields[I] is TDateTimeField) then
          E.Width := 120
        else
          E.Width := sbRecord.Width - 160 - 6 - 18;

        if E is TDBEdit then
        begin
          TDBEdit(E).DataSource := dsResult;
          TDBEdit(E).DataField := ibqryWork.Fields[I].FieldName;
        end else
        begin
          TDBMemo(E).DataSource := dsResult;
          TDBMemo(E).DataField := ibqryWork.Fields[I].FieldName;
        end;

        Inc(Y, 22);
      end;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.ibqryWorkBeforeClose(DataSet: TDataSet);
var
  I: Integer;
begin
  for I := sbRecord.ComponentCount - 1 downto 0 do
    sbRecord.Components[I].Free;
end;

procedure TfrmSQLEditorSyn.actQueryBuilderExecute(Sender: TObject);
begin
  {$IFDEF QBUILDER}
  FqbDialog.SQL := seQuery.Lines.Text;
  if FqbDialog.Execute then
  begin
    seQuery.Lines.Clear;
    seQuery.Lines.Text := FqbDialog.SQL;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actQueryBuilderUpdate(Sender: TObject);
begin
  actQueryBuilder.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.FReportBeforePrint(Sender: TfrxReportComponent);
{$IFDEF GEDEMIN}
var
  Cross: TfrxCrossView;
  i, j: Integer;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if (Sender is TfrxCrossView) and (not ibqryWork.IsEmpty) then
  begin
    Cross := TfrxCrossView(Sender);

    ibqryWork.First;
    i := 0;
    while not ibqryWork.Eof do
    begin
      for j := 0 to ibqryWork.Fields.Count - 1 do
        Cross.AddValue([i], [ibqryWork.Fields[j].DisplayLabel], [ibqryWork.Fields[j].AsString]);

      ibqryWork.Next;
      Inc(i);
    end;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.seQueryChange(Sender: TObject);
begin
  if mmPlan.Color <> clWindow then
    mmPlan.Color := clWindow;
end;

initialization
  RegisterClass(TfrmSQLEditorSyn);

finalization
  UnRegisterClass(TfrmSQLEditorSyn);
end.


