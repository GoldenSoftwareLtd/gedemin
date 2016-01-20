
unit flt_frmSQLEditorSyn_unit;

{ TODO 5 -oandreik -cSQLHistory : Разобраться почему прибавляет _1 к имени формы }
{ TODO 5 -oandreik -cSQLHistory : Визуальные настройки таблицы с историей запросов }
{ TODO 5 -oandreik -cSQLHistory : Разобраться почему при добавлении записи в гриде старая запись остается выделенной }
{ TODO 5 -oandreik -cSQLHistory : Почему колонка BOOKMARK выводится в двойных кавычках? }
{ TODO 5 -oandreik -cSQLHistory : ДаблКлик срабатывает когда пытаемся изменить ширину колонки }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabaseInfo, Db, IBSQL, IBDatabase, IBCustomDataSet, IBQuery, CheckLst,
  ActnList, ImgList, ExtCtrls, StdCtrls, ComCtrls, Grids, DBGrids, DBCtrls,
  ToolWin, SynEdit, SynEditHighlighter, SynHighlighterSQL,
  gd_createable_form, contnrs, gsStorage, Storages, Menus, TB2Item,
  TB2Dock, TB2Toolbar, SuperPageControl, gsDBGrid, StdActns,
  gsIBLookupComboBox, TeEngine, Series, TeeProcs, Chart, TB2ExtItems,
  gdc_frmSQLHistory_unit, gd_ClassList,
  {$IFDEF GEDEMIN}
  gdcBase,
  {$ENDIF}
  SynCompletionProposal, flt_i_SQLProposal, flt_SQLProposal, gd_keyAssoc,
  gsIBGrid, gdcSQLHistory, gsSearchReplaceHelper, gsDBTreeView, SynDBEdit;

type
  TCountRead = Record
    IndReadCount: Integer;
    SeqReadCount: Integer;
    InsertCount: Integer;
    UpdateCount: Integer;
    DeleteCount: Integer;
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
    _ibtrEditor: TIBTransaction;
    ibsqlPlan: TIBSQL;
    dsResult: TDataSource;
    IBDatabaseInfo: TIBDatabaseInfo;
    imScript: TImageList;
    actOptions: TAction;
    SynSQLSyn: TSynSQLSyn;
    actReplace: TAction;
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
    Label15: TLabel;
    mmPlan: TMemo;
    splQuery: TSplitter;
    pModal: TPanel;
    Button1: TButton;
    Button2: TButton;
    tsMonitor: TSuperTabSheet;
    Panel4: TPanel;
    dbnvMonitor: TDBNavigator;
    tbMonitor: TTBToolbar;
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
    pnlTest: TPanel;
    actShowViewForm: TAction;
    TBSeparatorItem17: TTBSeparatorItem;
    TBItem28: TTBItem;
    actMakeSelect: TAction;
    TBItem29: TTBItem;
    pmSaveFieldToFile: TPopupMenu;
    actSaveFieldToFile: TAction;
    nSaveFieldToFile: TMenuItem;
    actFindNext: TAction;
    tsTrace: TSuperTabSheet;
    pnlTrace: TPanel;
    tvResult: TgsDBTreeView;
    actShowTree: TAction;
    TBItem30: TTBItem;
    pnlMonitor: TPanel;
    ibgrMonitor: TgsIBGrid;
    spMonitor: TSplitter;
    dbseSQLText: TDBSynEdit;
    chlbTransactionParams: TCheckListBox;
    actExternalEditor: TAction;
    TBItem31: TTBItem;
    tsClasses: TSuperTabSheet;
    pnlClassesToolbar: TPanel;
    lvClasses: TListView;
    tbClasses: TTBToolbar;
    actClassesShowSelectSQL: TAction;
    TBItem32: TTBItem;
    actClassesShowViewForm: TAction;
    TBItem33: TTBItem;
    lblClassesCount: TLabel;
    cbTransactions: TComboBox;
    actConvertToPas: TAction;
    N1: TMenuItem;
    PASCAL1: TMenuItem;
    actConvertToSQL: TAction;
    actConvertToSQL1: TMenuItem;
    btnSetTransactionParams: TButton;
    actSetTransactionParams: TAction;
    Label14: TLabel;
    Label16: TLabel;
    actChangeRUID: TAction;
    TBSeparatorItem18: TTBSeparatorItem;
    TBItem34: TTBItem;
    actFilter: TAction;
    tbiFilter: TTBItem;
    Label17: TLabel;
    edClassesFilter: TEdit;
    tsRelations: TSuperTabSheet;
    Panel2: TPanel;
    lvRelations: TListView;
    lblTablesCount: TLabel;
    actClassesRefresh: TAction;
    TBItem35: TTBItem;
    TBSeparatorItem19: TTBSeparatorItem;
    procedure actPrepareExecute(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actRollbackExecute(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actOptionsUpdate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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
    procedure actDeleteBusinessObjectExecute(Sender: TObject);
    procedure pcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure actParseUpdate(Sender: TObject);
    procedure actParseExecute(Sender: TObject);
    procedure actRefreshChartExecute(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
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
    procedure seQueryChange(Sender: TObject);
    procedure pnlTestResize(Sender: TObject);
    procedure actRefreshMonitorUpdate(Sender: TObject);
    procedure actShowViewFormExecute(Sender: TObject);
    procedure actMakeSelectUpdate(Sender: TObject);
    procedure actMakeSelectExecute(Sender: TObject);
    procedure actSaveFieldToFileExecute(Sender: TObject);
    procedure actSaveFieldToFileUpdate(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure pnlTraceResize(Sender: TObject);
    procedure actShowTreeUpdate(Sender: TObject);
    procedure actShowTreeExecute(Sender: TObject);
    procedure seQuerySpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure actExternalEditorExecute(Sender: TObject);
    procedure actExternalEditorUpdate(Sender: TObject);
    procedure actClassesShowSelectSQLUpdate(Sender: TObject);
    procedure actClassesShowSelectSQLExecute(Sender: TObject);
    procedure actClassesShowViewFormExecute(Sender: TObject);
    procedure actConvertToPasExecute(Sender: TObject);
    procedure actConvertToPasUpdate(Sender: TObject);
    procedure actConvertToSQLUpdate(Sender: TObject);
    procedure actConvertToSQLExecute(Sender: TObject);
    procedure actSetTransactionParamsExecute(Sender: TObject);
    procedure actSetTransactionParamsUpdate(Sender: TObject);
    procedure cbTransactionsChange(Sender: TObject);
    procedure actChangeRUIDExecute(Sender: TObject);
    procedure actFilterUpdate(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure actFindNextUpdate(Sender: TObject);
    procedure edClassesFilterChange(Sender: TObject);
    procedure actClassesRefreshExecute(Sender: TObject);

  private
    FOldDelete, FOldInsert, FOldUpdate, FOldIndRead, FOldSeqRead: TStrings;
    FOldRead, FOldWrite, FOldFetches: Integer;
    FPrepareTime, FExecuteTime, FFetchTime: TDateTime;
    FTableArray: TgdKeyStringAssoc;
    FParams: TParams;
    FRepeatQuery: Boolean;
    FErrorLine: Integer;
    {$IFDEF GEDEMIN}
    frmSQLHistory: Tgdc_frmSQLHistory;
    frmSQLTrace: Tgdc_frmSQLHistory;
    {$ENDIF}
    FSearchReplaceHelper: TgsSearchReplaceHelper;

    procedure RemoveNoChange(const Before, After: TStrings);
    function PrepareQuery: Boolean;
    procedure ShowStatistic;
    procedure SaveLastStat;
    function CreateTableList: Boolean;
    procedure AddLogRecord(const StrLog: String; const ATimeStamp: Boolean = False);
    function InputParam: Boolean;
    procedure UpdateSyncs;
    procedure UpdateHistory;
    procedure LoadHistory;
    procedure DrawChart;
    procedure FillTransactionsList;
    {$IFDEF GEDEMIN}
    function CreateBusinessObject(out Obj: TgdcBase): Boolean;
    function CreateCurrClassBusinessObject(out Obj: TgdcBase): Boolean;
    {$ENDIF}

    procedure AddSQLHistory(const AnExecute: Boolean);
    procedure UseSQLHistory(AForm: Tgdc_frmSQLHistory);
    procedure OnHistoryDblClick(Sender: TObject);
    procedure OnTraceLogDblClick(Sender: TObject);
    procedure ExtractErrorLine(const S: String);
    procedure ClearError;
    function GetTransactionParams: String;
    function ConcatErrorMessage(const M: String): String;
    procedure FillClassesList;
    procedure FillRelationsList;
    function ibtrEditor: TIBTransaction;

    function BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;

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
  IB, at_Classes, IBHeader, jclStrings, flt_SafeConversion_unit,
  {$IFDEF GEDEMIN}
  gdcBaseInterface, flt_sql_parser, flt_sqlFilter, at_sql_setup,
  {$ENDIF}
  gd_directories_const, Clipbrd, gd_security, gd_ExternalEditor,
  gd_common_functions
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cQueryHistory = 'QueryHistory';

function ReadStringFromStream(Stream: TStream): AnsiString;
var
  L: Integer;
begin
  try
    Stream.ReadBuffer(L, SizeOf(L));
    SetLength(Result, L);
    if L > 0 then
      Stream.ReadBuffer(Result[1], L);
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
  if AnSQL > '' then
  begin
    FParams.Clear;
    if Assigned(AParams) then
    begin
      for I := 0 to AParams.Count - 1 do
        FParams.CreateParam(AParams[I].DataType, AParams[I].Name, AParams[I].ParamType).Value := AParams[I].Value;
    end;

    seQuery.Text := AnSQL;
  end;
    
  _ibtrEditor.DefaultDatabase := FDatabase;
  IBDatabaseInfo.Database := FDatabase;
  tsResult.TabVisible := False;

  Result := mrNone;
  if CreateTableList then
  begin
    if AShowModal then
    begin
      pModal.Visible := True;
      Position := poScreenCenter;
      Result := ShowModal;
    end else
      Show;
  end;
end;

function TfrmSQLEditorSyn.InputParam: Boolean;
var
  I, Index: Integer;
  P: TParam;
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Text := ibqryWork.Params.Names;
    for I := 0 to FParams.Count - 1 do
    begin
      Index := S.IndexOf(FParams[i].Name);
      if Index > -1 then
      begin
        if FParams[i].IsNull then
          ibqryWork.Params.Vars[Index].Clear
        else
          try
            case ibqryWork.Params[Index].SQLType of
              SQL_TYPE_DATE:
                ibqryWork.Params.Vars[Index].AsDate := FParams[i].AsDate;
              SQL_TYPE_TIME:
                ibqryWork.Params.Vars[Index].AsTime := FParams[i].AsTime;
              SQL_TIMESTAMP:
                ibqryWork.Params.Vars[Index].AsDateTime := FParams[i].AsDateTime;
              SQL_VARYING, SQL_TEXT:
                ibqryWork.Params.Vars[Index].AsString := FParams[i].AsString;
              SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
                ibqryWork.Params.Vars[Index].AsFloat := FParams[i].AsFloat;
              SQL_LONG, SQL_SHORT, SQL_INT64:
                case ibqryWork.Params[Index].Data.SQLScale of
                  0:
                    if ibqryWork.Params[Index].SQLType = SQL_INT64 then
                      ibqryWork.Params.Vars[Index].AsInt64 := StrToInt64(FParams[i].AsString)
                    else
                      ibqryWork.Params.Vars[Index].AsInteger := FParams[i].AsInteger;
                  -4..-1:
                    ibqryWork.Params.Vars[Index].AsCurrency := FParams[i].AsCurrency;
                else
                  ibqryWork.Params.Vars[Index].AsFloat := FParams[i].AsFloat;
                end;
            else
              ibqryWork.Params.Vars[Index].Value := FParams[i].Value;
            end;
          except
            // тип параметра из запроса и тип сохраненного параметра могут не совпадать
            // если конверсия невозможна, то очистим параметр, присвоим NULL
            ibqryWork.Params.Vars[Index].Clear
          end;
      end;
    end;
  finally
    S.Free;
  end;

  with TdlgInputParam.Create(Self) do
  try
    if ibqryWork.SQLType in [SQLExecProcedure, SQLSelect, SQLSelectForUpdate] then
    begin
      chbxRepeat.Checked := False;
      chbxRepeat.Enabled := False;
    end else
    begin
      chbxRepeat.Checked := FRepeatQuery;
      chbxRepeat.Enabled := True;
    end;

    Result := SetParams(ibqryWork.Params);

    FRepeatQuery := chbxRepeat.Checked;
  finally
    Free;
  end;

  FParams.Clear;
  for I := 0 to ibqryWork.Params.Count - 1 do
  begin
    P := TParam.Create(FParams);
    P.Name := ibqryWork.Params[i].Name;
    P.Value := ibqryWork.Params[i].Value;
  end;
end;

procedure TfrmSQLEditorSyn.AddLogRecord(const StrLog: String;
  const ATimeStamp: Boolean = False);
begin
  mmLog.Lines.Add('');
  if ATimeStamp then
    mmLog.Lines.Add('/*------' + DateTimeToStr(Now) + '------*/');
  mmLog.Lines.Add(StrLog);
end;

function TfrmSQLEditorSyn.CreateTableList: Boolean;
var
  ibsqlTable: TIBSQL;
begin
  ibsqlTable := TIBSQL.Create(Self);
  try
    {$IFDEF GEDEMIN}
    Assert(gdcBaseManager <> nil);
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
          ibsqlTable.Fields[1].AsTrimString;
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
var
  OldMessage: String;
  OldGDSCode: Integer;
begin
  if not ibtrEditor.InTransaction then
    ibtrEditor.StartTransaction;
  Result := False;
  OldGDSCode := 0;
  ibsqlPlan.Close;
  ibsqlPlan.SQL.Text := seQuery.Text;
  try
    AddLogRecord(seQuery.Text, True);
    try
      try
        ibsqlPlan.ParamCheck := True;
        ibsqlPlan.Prepare;
      except
        //если скл имеет тип DDLSQl то нужно установить paramCheck  в фолсе
        on E: Exception do
        begin
          OldMessage := E.Message;

          if E is EIBError then
            OldGDSCode := EIBError(E).IBErrorCode;

          ibsqlPlan.ParamCheck := False;
          ibsqlPlan.Prepare;
        end;
      end;
      mmPlan.Text := StringReplace(ibsqlPlan.Plan, #$A, #13#10, [rfReplaceAll]);
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
        if E.Message <> OldMessage then
          E.Message := OldMessage;
        ExtractErrorLine(E.Message);
        mmPlan.Text := ConcatErrorMessage(E.Message);
        if E is EIBError then
        begin
          if OldGDSCode <> 0 then
            mmPlan.Lines.Add('GDSCode = ' + IntToStr(OldGDSCode))
          else
            mmPlan.Lines.Add('GDSCode = ' + IntToStr(EIBError(E).IBErrorCode));
        end;
        mmPlan.Color := $AAAAFF;
        mmPlan.SelStart := 0;
        mmPlan.SelLength := 0;
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
  S, TempPlan: String;
  SL: TStringList;
begin
  if PrepareQuery then
  begin
    repeat
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
          break;
      end else
      begin
        ibqryWork.ParamCheck := False;
      end;

      AddSQLHistory(True);

      ibqryWork.UnPrepare;
      ibqryWork.DisableControls;
      try
        SaveLastStat;

        StartTime := Now;
        ibqryWork.Prepare;

        FPrepareTime := Now - StartTime;

        if (ibqryWork.SQLType = SQLDDL) and (ibtrEditor = _ibtrEditor) then
          actCommit.Execute;

        tvResult.DataSource := nil;

        StartTime := Now;
        ibqryWork.Open;
        FExecuteTime := Now - StartTime;

        if ibqryWork.SQLType in [SQLExecProcedure, SQLSelect, SQLSelectForUpdate] then
        begin
          tsResult.TabVisible := True;
          pcMain.ActivePage := tsResult;

          dbgResult.Visible := True;
          tvResult.Visible := False;
          pnlRecord.Visible := False;

          actShowGrid.Checked := True;
          actShowTree.Checked := False;
          actShowRecord.Checked := False;

          FRepeatQuery := False;
        end else
        begin
          if pcMain.ActivePage = tsResult then
            pcMain.ActivePage := tsQuery;
          tsResult.TabVisible := False;
        end;

        if (ibqryWork.SQLType = SQLDDL) and (ibtrEditor = _ibtrEditor) then
          actCommit.Execute;

        StartTime := Now;
        ibqryWork.EnableControls;
        FFetchTime := Now - StartTime;

        ShowStatistic;
        ClearError;

        if (ibqryWork.QSelect.SQLType in [SQLInsert, SQLUpdate, SQLDelete, SQLExecProcedure]) then
        begin
          TempPlan := StringReplace(ibqryWork.QSelect.Plan, #$A, #13#10, [rfReplaceAll]);
          if TempPlan > '' then
            mmPlan.Text := TempPlan + #13#10#13#10
          else
            mmPlan.Clear;

          SL := TStringList.Create;
          try
            SL.Assign(IBDatabaseInfo.InsertCount);
            RemoveNoChange(FOldInsert, SL);
            if SL.Count > 0 then
            begin
              for K := 0 to SL.Count - 1 do
                mmPlan.Lines.Add('В таблицу ' + FTableArray.ValuesByKey[StrToInt(SL.Names[K])] + ' вставлено записей: ' + SL.Values[SL.Names[K]]);
            end;

            SL.Assign(IBDatabaseInfo.UpdateCount);
            RemoveNoChange(FOldUpdate, SL);
            if SL.Count > 0 then
            begin
              for K := 0 to SL.Count - 1 do
                mmPlan.Lines.Add('В таблице ' + FTableArray.ValuesByKey[StrToInt(SL.Names[K])] + ' изменено записей: ' + SL.Values[SL.Names[K]]);
            end;

            SL.Assign(IBDatabaseInfo.DeleteCount);
            RemoveNoChange(FOldDelete, SL);
            if SL.Count > 0 then
            begin
              for K := 0 to SL.Count - 1 do
                mmPlan.Lines.Add('Из таблицы ' + FTableArray.ValuesByKey[StrToInt(SL.Names[K])] + ' удалено записей: ' + SL.Values[SL.Names[K]]);
            end;    
          finally
            SL.Free;
          end;
        end;
      except
        on E: Exception do
        begin
          ExtractErrorLine(E.Message);
          mmPlan.Text := ConcatErrorMessage(E.Message);
          if E is EIBError then
            mmPlan.Lines.Add('GDSCode = ' + IntToStr(EIBError(E).IBErrorCode));
          mmPlan.Color := $AAAAFF;
          mmPlan.SelStart := 0;
          mmPlan.SelLength := 0;
          AddLogRecord(E.Message);
          FRepeatQuery := False;
          if ibqryWork.SQLType = SQLDDL then
            actRollback.Execute;
        end;
      end;
    until not FRepeatQuery;
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
  begin
    ibtrEditor.Commit;
    AddLogRecord('Коммит транзакции', True);
  end;
  if pcMain.ActivePage = tsResult then
    pcMain.ActivePage := tsQuery;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actRollbackExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
  begin
    ibtrEditor.Rollback;
    AddLogRecord('Откат транзакции', True);
  end;
  if pcMain.ActivePage = tsResult then
    pcMain.ActivePage := tsQuery;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actCommitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibtrEditor.InTransaction;
end;

procedure TfrmSQLEditorSyn.FormCreate(Sender: TObject);
{$IFDEF GEDEMIN}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  Assert(gdcBaseManager <> nil);
  iblkupTable.Transaction := gdcBaseManager.ReadTransaction;
  {$ENDIF}

  actNew.ShortCut := ShortCut(Ord('N'), [ssCtrl, ssShift]);
  FOldDelete := TStringList.Create;
  FOldInsert := TStringList.Create;
  FOldUpdate := TStringList.Create;
  FOldIndRead := TStringList.Create;
  FOldSeqRead := TStringList.Create;

  {$IFDEF GEDEMIN}
  ibtrMonitor.DefaultDatabase := gdcBaseManager.Database;
  tsMonitor.TabVisible := gdcBaseManager.Database.ODSMajorVersion >= 11; // FB 2.5

  frmSQLHistory := Tgdc_frmSQLHistory.Create(Self);
  frmSQLHistory.ShowSpeedButton := False;
  frmSQLHistory.Parent := pnlTest;
  frmSQLHistory.BorderStyle := bsNone;
  frmSQLHistory.tbMainMenu.Visible := False;
  frmSQLHistory.sbMain.Visible := False;
  frmSQLHistory.ibgrMain.OnDblClick := OnHistoryDblClick;
  frmSQLHistory.actEnableTrace.Visible := False;
  frmSQLHistory.actDeleteTraceLog.Visible := False;
  frmSQLHistory.actDeleteHistory.Visible := True;
  frmSQLHistory.gdcObject.ExtraConditions.Add('COALESCE(z.bookmark, '' '') <> ''M''');

  for I := 0 to frmSQLHistory.alMain.ActionCount - 1 do
    if frmSQLHistory.alMain.Actions[I] is TCustomAction then
      TCustomAction(frmSQLHistory.alMain.Actions[I]).ShortCut := 0;

  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('id')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('sql_text')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('sql_params')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('bookmark')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creatorkey')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creationdate')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('editorkey')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('editiondate')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creator')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('exec_count')).Visible := True;

  frmSQLHistory.Show;

  frmSQLTrace := Tgdc_frmSQLHistory.Create(Self);
  frmSQLTrace.ShowSpeedButton := False;
  frmSQLTrace.Parent := pnlTrace;
  frmSQLTrace.BorderStyle := bsNone;
  frmSQLTrace.tbMainMenu.Visible := False;
  frmSQLTrace.sbMain.Visible := False;
  frmSQLTrace.ibgrMain.OnDblClick := OnTraceLogDblClick;
  frmSQLTrace.actEnableTrace.Visible := True;
  frmSQLTrace.actDeleteTraceLog.Visible := True;
  frmSQLTrace.actDeleteHistory.Visible := False;
  frmSQLTrace.gdcObject.ExtraConditions.Add('z.bookmark = ''M''');

  for I := 0 to frmSQLTrace.alMain.ActionCount - 1 do
    if frmSQLTrace.alMain.Actions[I] is TCustomAction then
      TCustomAction(frmSQLTrace.alMain.Actions[I]).ShortCut := 0;

  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('id')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('sql_text')).Visible := True;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('sql_params')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('bookmark')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('creatorkey')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('creationdate')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('editorkey')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('editiondate')).Visible := True;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('creator')).Visible := False;
  frmSQLTrace.ibgrMain.ColumnByField(frmSQLTrace.gdcObject.FieldByName('exec_count')).Visible := False;

  frmSQLTrace.Show;
  {$ENDIF}

  dbgResult.Visible := True;
  tvResult.Visible := False;
  pnlRecord.Visible := False;

  actShowGrid.Checked := True;
  actShowTree.Checked := False;
  actShowRecord.Checked := False;

  pcMain.ActivePage := tsQuery;
  ActiveControl := seQuery;
  UpdateSyncs;
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
  if (atDatabase <> nil) and (atDatabase.Relations.ByRelationName('GD_SQL_HISTORY') = nil) then
    raise Exception.Create('Необходимо обновить структуру базы данных!');

  inherited;

  UseDesigner := False;
  FParams := TParams.Create;
  ShowSpeedButton := True;
  FTableArray := TgdKeyStringAssoc.Create;

  {$IFDEF GEDEMIN}
  if Assigned(gdcBaseManager) then
  begin
    FDatabase := gdcBaseManager.Database;
    //ibsqlPlan.Database := FDatabase;
    //ibqryWork.Database := FDatabase;
    ibtrEditor.DefaultDatabase := FDatabase;
    IBDatabaseInfo.Database := FDatabase;
  end;

  if SQLProposal = nil then
    SQLProposalObject := TSQLProposal.Create(nil);
  {$ENDIF}

  // Вспомогательный объект для поиска по полю ввода
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(seQuery);

  FErrorLine := -1;
end;

destructor TfrmSQLEditorSyn.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  FParams.Free;
  FTableArray.Free;
  inherited;
end;

procedure TfrmSQLEditorSyn.actFindExecute(Sender: TObject);
begin
  if pcMain.ActivePage = tsQuery then
    FSearchReplaceHelper.Search
  else
    dbgResult.FindInGrid;
end;

procedure TfrmSQLEditorSyn.actFindNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure TfrmSQLEditorSyn.actReplaceExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Replace;
end;

procedure TfrmSQLEditorSyn.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  ShiftDown: Boolean;
begin
  ShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  if (Action = caHide) and ShiftDown then
    Action := caFree;
  if Action = caFree then
    AddSQLHistory(False);
end;

procedure TfrmSQLEditorSyn.UpdateHistory;
begin
  LoadHistory;
end;

procedure TfrmSQLEditorSyn.LoadHistory;
{$IFDEF GEDEMIN}
var
  Path: String;
  F: TgsStorageFolder;
  M: TMemoryStream;
  Tr: TIBTransaction;
  q: TIBSQL;
  C: Integer;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  Assert(gdcBaseManager <> nil);

  if (UserStorage <> nil) and (IBLogin <> nil) then
  begin
    Path := Name;
    F := UserStorage.OpenFolder(Path, False);
    if F <> nil then
    begin
      M := TMemoryStream.Create;
      try
        F.ReadStream(cQueryHistory, M);

        Tr := TIBTransaction.Create(nil);
        try
          Tr.DefaultDatabase := gdcBaseManager.Database;
          Tr.StartTransaction;

          q := TIBSQL.Create(nil);
          try
            q.Transaction := Tr;
            q.SQL.Text :=
              'INSERT INTO gd_sql_history (sql_text, bookmark, creatorkey, creationdate, editorkey, editiondate, exec_count) ' +
              'VALUES (:S, ''H'', :K, CURRENT_TIMESTAMP, :K, CURRENT_TIMESTAMP, 0) ';

            if M.Read(C, SizeOf(C)) = SizeOf(C) then
            begin
              while (M.Position < M.Size) and (C > 0) do
              begin
                q.ParamByName('S').AsString := ReadStringFromStream(M);
                q.ParamByName('K').AsInteger := IBLogin.ContactKey;
                q.ExecQuery;
                Dec(C);
              end;
            end;
          finally
            q.Free;
          end;

          Tr.Commit;
        finally
          Tr.Free;
        end;
      finally
        M.Free;
      end;
      UserStorage.CloseFolder(F, False);

      UserStorage.DeleteFolder(Path, False);
    end;
  end;
{$ENDIF}  
end;

procedure TfrmSQLEditorSyn.LoadSettings;
begin
  inherited;
  UpdateHistory;
  //TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TfrmSQLEditorSyn.SaveSettings;
begin
  inherited;
  //TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
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
  ClearError;
  seQuery.Text := '';
  pcMain.ActivePage := tsQuery;
end;

procedure TfrmSQLEditorSyn.actNextQueryExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  AddSQLHistory(False);
  frmSQLHistory.gdcObject.Next;
  UseSQLHistory(frmSQLHistory);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actPrevQueryExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  AddSQLHistory(False);
  frmSQLHistory.gdcObject.Prior;
  UseSQLHistory(frmSQLHistory);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actNextQueryUpdate(Sender: TObject);
begin
  actNextQuery.Enabled := ((pcMain.ActivePage = tsQuery) or (pcMain.ActivePage = tsHistory))
    {$IFDEF GEDEMIN}
    and Assigned(frmSQLHistory)
    and (not frmSQLHistory.gdcObject.EOF)
    {$ENDIF}
    ;
end;

procedure TfrmSQLEditorSyn.actPrevQueryUpdate(Sender: TObject);
begin
  actPrevQuery.Enabled := ((pcMain.ActivePage = tsQuery) or (pcMain.ActivePage = tsHistory))
    {$IFDEF GEDEMIN}
    and Assigned(frmSQLHistory)
    and (not frmSQLHistory.gdcObject.BOF)
    {$ENDIF}
    ;
end;

procedure TfrmSQLEditorSyn.actExecuteUpdate(Sender: TObject);
begin
  actExecute.Enabled := (pcMain.ActivePage = tsQuery)
    and (Trim(seQuery.Text) > '')
    and (IBLogin <> nil)
    and IBLogin.IsUserAdmin;
end;

procedure TfrmSQLEditorSyn.actPrepareUpdate(Sender: TObject);
begin
  actPrepare.Enabled := (pcMain.ActivePage = tsQuery)
    and (Trim(seQuery.Text) > '');
end;

procedure TfrmSQLEditorSyn.LoadSettingsAfterCreate;
begin
  inherited;

  {$IFDEF GEDEMIN}
  if frmSQLHistory <> nil then UseSQLHistory(frmSQLHistory);
  {$ENDIF}  
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
function TfrmSQLEditorSyn.CreateBusinessObject(out Obj: TgdcBase): Boolean;
var
  C: TgdcFullClass;
  R: TatRelation;
  RF: TatRelationField;
  RelationName, FieldName: String;
begin
  Assert(not ibqryWork.EOF);
  Assert(dbgResult.Visible);
  Assert(dbgResult.SelectedField <> nil);
  Assert(not dbgResult.SelectedField.IsNull);
  Assert(dbgResult.SelectedField.Origin > '');

  Obj := nil;
  C.gdClass := nil;

  ParseFieldOrigin(dbgResult.SelectedField.Origin, RelationName, FieldName);

  R := atDatabase.Relations.ByRelationName(RelationName);
  if Assigned(R) then
  begin
    RF := R.RelationFields.ByFieldName(FieldName);
    if Assigned(RF) then
    begin
      if Assigned(RF.ForeignKey) and RF.ForeignKey.IsSimpleKey then
        C := GetBaseClassForRelation(RF.References.RelationName)
      else if Assigned(R.PrimaryKey) and (R.PrimaryKey.ConstraintFields[0] = RF) then
        C := GetBaseClassForRelation(R.RelationName);
    end;
  end;

  if C.gdClass <> nil then
  begin
    Obj := C.gdClass.Create(nil);
    Obj.SubType := C.SubType;
    Obj.SubSet := 'ByID';

    try
      Obj.ID := dbgResult.SelectedField.AsInteger;
      Obj.Open;
      if Obj.EOF then
        FreeAndNil(Obj);
    except
      FreeAndNil(Obj);
      raise;
    end;
  end;

  if Obj = nil then
    MessageBox(Handle,
      'Не удалось создать бизнес-объект для текущей записи.',
      'Информация',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

  Result := Obj <> nil;
end;
{$ENDIF}

procedure TfrmSQLEditorSyn.AddSQLHistory(const AnExecute: Boolean);
  {$IFDEF GEDEMIN}
  procedure SaveSQLParams;
  var
    S: String;
  begin
    S := TgdcSQLHistory.EncodeParamsText(ibqryWork.Params);
    if S > '' then
      frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').AsString := S
    else
      frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').Clear;
  end;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if (frmSQLHistory <> nil) and (Trim(seQuery.Text) > '') then
  try
    if frmSQLHistory.gdcObject.FieldByName('SQL_TEXT').AsString <> seQuery.Text then
    begin
      frmSQLHistory.gdcObject.First;
      frmSQLHistory.gdcObject.Insert;
      frmSQLHistory.gdcObject.FieldByName('SQL_TEXT').AsString := seQuery.Text;
    end else
    begin
      if AnExecute then
      begin
        frmSQLHistory.gdcObject.Edit;
        frmSQLHistory.gdcObject.FieldByName('editiondate').AsDateTime := Now;
      end;
    end;
    if AnExecute then
      SaveSQLParams;

    if frmSQLHistory.gdcObject.State in dsEditModes then
      frmSQLHistory.gdcObject.Post;
  except
    if frmSQLHistory.gdcObject.State in dsEditModes then
      frmSQLHistory.gdcObject.Cancel;
    raise;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.UseSQLHistory(AForm: Tgdc_frmSQLHistory);
{$IFDEF GEDEMIN}
var
  SL: TStringList;
  I: Integer;
  P: TParam;
  S: String;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if not AForm.gdcObject.IsEmpty then
  begin
    ClearError;
    seQuery.Text := AForm.gdcObject.FieldByName('SQL_TEXT').AsString;

    FParams.Clear;

    if AForm.gdcObject.FieldByName('SQL_PARAMS').AsString > '' then
    begin
      SL := TStringList.Create;
      try
        SL.Text := AForm.gdcObject.FieldByName('SQL_PARAMS').AsString;
        for I := 0 to SL.Count - 1 do
          if SL.Names[I] > '' then
          begin
            P := TParam.Create(FParams);
            P.Name := SL.Names[I];
            S := Trim(SL.Values[SL.Names[I]]);
            if Copy(S, 1, 1) = '"' then
              P.Value := RestoreSysChars(Copy(S, 2, Length(S) - 2))
            else if Pos(':', S) > 0 then
              P.Value := SafeStrToDateTime(S)
            else if Copy(S, 1, 1) = '<' then
              P.Clear
            else
              P.Value := SafeStrToFloat(S);
          end;
      finally
        SL.Free;
      end;
    end;

    seQuery.Show;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.ExtractErrorLine(const S: String);
const
  LineLabel = ' line ';
var
  B: Integer;
  N: String;
begin
  B := StrIPos(LineLabel, S);
  if B > 0 then
  begin
    N := '';
    Inc(B, Length(LineLabel));
    while (B <= Length(S)) and (S[B] in ['0'..'9']) do
    begin
      N := N + S[B];
      Inc(B);
    end;
    FErrorLine := StrToIntDef(N, 1);
  end else
    FErrorLine := 1;
  seQuery.Invalidate;
end;

procedure TfrmSQLEditorSyn.ClearError;
begin
  mmPlan.Color := clWindow;
  mmPlan.Lines.Clear;
  FErrorLine := -1;
  seQuery.Invalidate;
end;

function TfrmSQLEditorSyn.GetTransactionParams: String;
var
  I: Integer;
  S: String;
begin
  Result := '';
  for I := 0 to chlbTransactionParams.Items.Count - 1 do
  begin
    if chlbTransactionParams.Checked[I] then
    begin
      S := chlbTransactionParams.Items[I];
      if Pos(' ', S) > 0 then S := '"' + S + '"';
      Result := Result + S + ',';
    end;
  end;
  if Result > '' then
    SetLength(Result, Length(Result) - 1);
end;

function TfrmSQLEditorSyn.ConcatErrorMessage(const M: String): String;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Text := M;

    for I := 1 to 5 do
    begin
      if SL.Count > 1 then
      begin
        if Trim(SL[1]) > '' then
          SL[0] := SL[0] + '; ' + SL[1];
        SL.Delete(1);
      end;
    end;

    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

function TfrmSQLEditorSyn.ibtrEditor: TIBTransaction;
begin
  if ibqryWork.Transaction <> nil then
    Result := ibqryWork.Transaction
  else
    Result := _ibtrEditor;
end;

function TfrmSQLEditorSyn.BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
var
  LI: TListItem;
  S: String;
  Level, C, L: Integer;
  CE: TgdBaseEntry;
begin
  if ACE is TgdBaseEntry then
  begin
    CE := ACE as TgdBaseEntry;
    S := CE.TheClass.ClassName + '^'
      + CE.SubType + '^'
      + CE.gdcClass.GetDisplayName(CE.SubType) + '^'
      + CE.gdcClass.GetListTable(CE.SubType) + '^'
      + CE.DistinctRelation + '^'
      + CE.ClassName;
  end else
  begin
    CE := nil;
    S := ACE.TheClass.ClassName + ACE.SubType + ACE.Caption;
  end;

  Level := PInteger(AData1)^;
  L := Level + 1;
  C := lvClasses.Items.Count;

  gdClassList.Traverse(ACE.TheClass, ACE.SubType, BuildClassTree, @L, nil, False, True);

  if (lvClasses.Items.Count > C) or (edClassesFilter.Text = '') or (StrIPos(edClassesFilter.Text, S) > 0) then
  begin
    LI := lvClasses.Items.Insert(C);
    LI.Caption := StringOfChar(' ', Level * 2) + ACE.TheClass.ClassName;

    if CE <> nil then
    begin
      if CE.gdcClass.IsAbstractClass then
        LI.SubItems.Add('<Абстрактный базовый класс>')
      else
        LI.SubItems.Add(CE.SubType);

      LI.SubItems.Add(CE.gdcClass.GetDisplayName(CE.SubType));
      LI.SubItems.Add(CE.gdcClass.GetListTable(CE.SubType));
      LI.SubItems.Add(CE.ClassName);
      LI.SubItems.Add(CE.DistinctRelation);
    end else
    begin
      LI.SubItems.Add(ACE.SubType);
      LI.SubItems.Add(ACE.Caption);
      LI.SubItems.Add('');
      LI.SubItems.Add(ACE.ClassName);
      LI.SubItems.Add('');
    end;
  end;

  Result := True;
end;

procedure TfrmSQLEditorSyn.FillClassesList;
{$IFDEF GEDEMIN}
var
  Level: Integer;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if gdClassList <> nil then
  begin
    lvClasses.Items.BeginUpdate;
    try
      lvClasses.Items.Clear;
      Level := 0;
      BuildClassTree(gdClassList.Find('TgdcBase'), @Level, nil);
      Level := 0;
      BuildClassTree(gdClassList.Find('TgdcCreateableForm'), @Level, nil);
    finally
      lvClasses.Items.EndUpdate;
    end;
  end;
  {$ENDIF}

  lblClassesCount.Caption := 'Бизнес-классов: ' + IntToStr(lvClasses.Items.Count);
end;

procedure TfrmSQLEditorSyn.FillRelationsList;
{$IFDEF GEDEMIN}
var
  q: TIBSQL;
  LI: TListItem;
  FC: TgdcFullClass;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  lvRelations.Items.BeginUpdate;
  q := TIBSQL.Create(nil);
  try
    lvRelations.Items.Clear;
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text :=
      'SELECT rdb$relation_name ' +
      'FROM rdb$relations ' +
      'WHERE rdb$relation_type = 0 AND rdb$system_flag = 0 ' +
      'ORDER BY rdb$relation_name';
    q.ExecQuery;
    while not q.EOF do
    begin
      LI := lvRelations.Items.Add;
      LI.Caption := q.FieldByName('RDB$RELATION_NAME').AsTrimString;
      FC := GetBaseClassForRelation(LI.Caption);
      if FC.gdClass <> nil then
      begin
        LI.SubItems.Add(FC.gdClass.ClassName);
        LI.SubItems.Add(FC.SubType);
        LI.SubItems.Add(FC.gdClass.GetDisplayName(FC.SubType));
      end;
      q.Next;
    end;
  finally
    q.Free;
    lvRelations.Items.EndUpdate;
  end;
{$ENDIF}
  lblTablesCount.Caption := 'Таблиц в списке: ' + IntToStr(lvRelations.Items.Count);
end;

procedure TfrmSQLEditorSyn.OnHistoryDblClick(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  UseSQLHistory(frmSQLHistory);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.OnTraceLogDblClick(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  UseSQLHistory(frmSQLTrace);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actEditBusinessObjectExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
begin
  if CreateBusinessObject(Obj) then
  try
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
  (Sender as TAction).Enabled := ibqryWork.Active
    and (not ibqryWork.EOF)
    and dbgResult.Visible
    and (dbgResult.SelectedField is TIntegerField)
    and (dbgResult.SelectedField.AsInteger > 0)
    and (dbgResult.SelectedField.Origin > '');
end;

procedure TfrmSQLEditorSyn.dbgResultDblClick(Sender: TObject);
begin
  actEditBusinessObject.Execute;
end;

procedure TfrmSQLEditorSyn.actDeleteBusinessObjectExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
begin
  if CreateBusinessObject(Obj) then
  try
    if MessageBox(Handle,
      PChar('Удалить объект ' + Obj.GetDisplayName(Obj.SubType) + ' ' + Obj.ObjectName + '?'),
      'Внимание',
      MB_ICONEXCLAMATION or MB_YESNO) = IDYES then
    begin
      Obj.Delete;
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
  if (pcMain.ActivePage = tsMonitor)
    and (ibdsMonitor <> nil) then
  begin
    ibdsMonitor.Close;
    if ibtrMonitor.InTransaction then
      ibtrMonitor.Commit;
  end;
end;

procedure TfrmSQLEditorSyn.actParseUpdate(Sender: TObject);
begin
  actParse.Enabled := (pcMain.ActivePage = tsQuery)
    and (Trim(seQuery.Text) > '');
end;

procedure TfrmSQLEditorSyn.actParseExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  Assert(gdcBaseManager <> nil);

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
  Assert(gdcBaseManager <> nil);
  
    {$IFDEF FR4}
      {$IFDEF TeeChartPro}
        with ChReads.SeriesList.Items[0] do
      {$ELSE}
        with ChReads.SeriesList.Series[0] do
      {$ENDIF}
    {$ELSE}
      with ChReads.SeriesList.Series[0] do
    {$ENDIF}
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

procedure TfrmSQLEditorSyn.FillTransactionsList;

  function GetTrKey(ATr: TIBTRansaction): String;
  var
    S, SOwn: String;
    C: TComponent;
  begin
    if ATr.InTransaction then
      S := 'Активна: '
    else
      S := 'Не активна: ';

    if ATr.Owner is TComponent then
    begin
      C := ATr.Owner as TComponent;
      if C.Name > '' then
        SOwn := ' (' + C.Name + ', ' + C.ClassName + ')'
      else
        SOwn := ' (' + C.ClassName + ')';
    end else
      SOwn := '';

    Result := S + ATr.Name + SOwn;
  end;

var
  I: Integer;
begin
  cbTransactions.Items.Clear;

  if ibtrEditor.DefaultDatabase <> nil then
  begin
    for I := 0 to ibtrEditor.DefaultDatabase.TransactionCount - 1 do
    begin
      cbTransactions.Items.AddObject(GetTrKey(ibtrEditor.DefaultDatabase.Transactions[I]),
        ibtrEditor.DefaultDatabase.Transactions[I]);
    end;
  end;

  cbTransactions.ItemIndex := cbTransactions.Items.IndexOf(GetTrKey(ibtrEditor));

  chlbTransactionParams.Items.Clear;
  for I := Low(TPBConstantNames) to High(TPBConstantNames) do
  begin
    chlbTransactionParams.Checked[chlbTransactionParams.Items.Add(TPBConstantNames[I])] :=
      ibtrEditor.Params.IndexOf(TPBConstantNames[I]) <> -1;
  end;
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

procedure TfrmSQLEditorSyn.actRefreshMonitorExecute(Sender: TObject);
begin
  ibdsMonitor.Close;
  dsMonitor.DataSet := nil;

  if ibtrMonitor.InTransaction then
    ibtrMonitor.Commit;
  ibtrMonitor.StartTransaction;

  ibdsMonitor.Open;
  ibdsMonitor.FieldByName('state').Visible := False;
  ibdsMonitor.FieldByName('sql_text').Visible := False;
  dsMonitor.DataSet := ibdsMonitor;
end;

procedure TfrmSQLEditorSyn.actDeleteStatementUpdate(Sender: TObject);
begin
  actDeleteStatement.Enabled := ibdsMonitor.Active and
    (not ibdsMonitor.IsEmpty) and
    (ibdsMonitor.FieldByName('state').AsInteger = 1) and
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
    Assert(gdcBaseManager <> nil);
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := 'DELETE FROM mon$statements WHERE mon$statement_id = :ID';
    q.ParamByName('id').AsInteger := ibdsMonitor.FieldByName('stmt_id').AsInteger;
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
  ClearError;
  seQuery.Text := ibdsMonitor.FieldByName('sql_text').AsString;
  seQuery.Show;
end;

procedure TfrmSQLEditorSyn.pcMainChange(Sender: TObject);
begin
  if (pcMain.ActivePage = tsMonitor) and (ibdsMonitor <> nil) then
    actRefreshMonitor.Execute
  else if pcMain.ActivePage = tsHistory then
    AddSQLHistory(False)
  else if pcMain.ActivePage = tsClasses then
  begin
    if lvClasses.Items.Count = 0 then
      FillClassesList;
  end
  else if pcMain.ActivePage = tsRelations then
  begin
    if lvRelations.Items.Count = 0 then
      FillRelationsList;
  end
  else if pcMain.ActivePage = tsTransaction then
    FillTransactionsList
  else if (pcMain.ActivePage = tsResult) and (not tsResult.TabVisible) then
    pcMain.ActivePage := tsQuery;
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
    PChar('Завершить сеанс пользователя ' + ibdsMonitor.FieldByName('gd_user').AsString + '?'),
    'Внимание',
    MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDYES then
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      {$IFDEF GEDEMIN}
      Assert(gdcBaseManager <> nil);
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;
      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM mon$attachments WHERE mon$attachment_id = :ID';
      q.ParamByName('id').AsInteger := ibdsMonitor.FieldByName('att_id').AsInteger;
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
end;

procedure TfrmSQLEditorSyn.actShowGridExecute(Sender: TObject);
begin
  if not actShowGrid.Checked then
  begin
    dbgResult.Visible := True;
    tvResult.Visible := False;
    pnlRecord.Visible := False;

    actShowGrid.Checked := True;
    actShowTree.Checked := False;
    actShowRecord.Checked := False;
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
  F: TField;
begin
  if not actShowRecord.Checked then
  begin
    dbgResult.Visible := False;
    tvResult.Visible := False;
    pnlRecord.Visible := True;

    actShowGrid.Checked := False;
    actShowTree.Checked := False;
    actShowRecord.Checked := True;

    if sbRecord.ComponentCount = 0 then
    begin
      LockWindowUpdate(pnlRecord.Handle);
      try
        Y := 6;
        for I := 0 to ibqryWork.FieldCount - 1 do
        begin
          F := ibqryWork.Fields[I];

          L := TLabel.Create(sbRecord);
          L.Parent := sbRecord;
          L.Left := 6;
          L.Top := Y + 2;
          L.ParentFont := True;
          L.AutoSize := False;
          L.Width := 150;
          L.Caption := F.FieldName + ':';
          L.ShowHint := True;
          L.Hint := F.FieldName + #13#10 + F.Origin;

          if ((F is TStringField) or (F is TMemoField)) and (Length(F.AsString) > 80) then
            E := TDBMemo.Create(sbRecord)
          else
            E := TDBEdit.Create(sbRecord);
          E.Parent := sbRecord;
          E.Left := 160;
          E.Top := Y;
          if (F is TNumericField) or (F is TDateTimeField) then
            E.Width := 120
          else
            E.Width := sbRecord.Width - 160 - 6 - 18;

          if E is TDBEdit then
          begin
            TDBEdit(E).DataSource := dsResult;
            TDBEdit(E).DataField := F.FieldName;
            TDBEdit(E).PopupMenu := pmSaveFieldToFile;
            E.Height := 21;
          end else
          begin
            TDBMemo(E).DataSource := dsResult;
            TDBMemo(E).DataField := F.FieldName;
            TDBMemo(E).PopupMenu := pmSaveFieldToFile;
            TDBMemo(E).WordWrap := True;
            TDBMemo(E).ScrollBars := ssVertical;
            E.Height := 105;
          end;

          Inc(Y, E.Height + 1);
        end;
      finally
        LockWindowUpdate(0);
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

procedure TfrmSQLEditorSyn.seQueryChange(Sender: TObject);
begin
  ClearError;
end;

procedure TfrmSQLEditorSyn.pnlTestResize(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  if frmSQLHistory <> nil then
    frmSQLHistory.SetBounds(0, 0, pnlTest.Width, pnlTest.Height);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actRefreshMonitorUpdate(Sender: TObject);
begin
  actRefreshMonitor.Enabled := ibtrMonitor.DefaultDatabase <> nil;
end;

procedure TfrmSQLEditorSyn.actShowViewFormExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
  F: TCustomForm;
begin
  if CreateBusinessObject(Obj) then
  try
    F := Obj.CreateViewForm(Application.MainForm, '', Obj.SubType, True);
    if F <> nil then
    begin
      F.ShowModal;
      F.Free;
    end;
  finally
    Obj.Free;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TfrmSQLEditorSyn.actMakeSelectUpdate(Sender: TObject);
begin
  actMakeSelect.Enabled := iblkupTable.CurrentKey > '';
end;

procedure TfrmSQLEditorSyn.actMakeSelectExecute(Sender: TObject);
begin
  ClearError;
  seQuery.Text := 'SELECT * FROM ' + iblkupTable.Text + ' WHERE 1=1';
  seQuery.Show;
end;

procedure TfrmSQLEditorSyn.actSaveFieldToFileExecute(Sender: TObject);
var
  SD: TSaveDialog;
  F: TField;
  FS: TFileStream;
  SS: TStringStream;
begin
  if (pmSaveFieldToFile.PopupComponent is TDBMemo) then
    F := (pmSaveFieldToFile.PopupComponent as TDBMemo).Field
  else if (pmSaveFieldToFile.PopupComponent is TDBEdit) then
    F := (pmSaveFieldToFile.PopupComponent as TDBEdit).Field
  else
    F := nil;

  if (F <> nil) and (not F.IsNull) then
  begin
    SD := TSaveDialog.Create(Self);
    try
      SD.Title := 'Сохранить значение поля в файл';
      SD.DefaultExt := 'dat';
      SD.Filter := 'Текстовые файлы (*.txt)|*.txt|Фйлы данных(*.dat)|*.dat|Все файлы (*.*)|*.*';
      SD.FileName := F.Name + '.dat';
      SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if SD.Execute then
      begin
        if F is TBlobField then
          (F as TBlobField).SaveToFile(SD.FileName)
        else begin
          FS := TFileStream.Create(SD.FileName, fmOpenWrite);
          try
            SS := TStringStream.Create(F.AsString);
            try
              FS.CopyFrom(SS, 0);
            finally
              SS.Free;
            end;
          finally
            FS.Free;
          end;
        end;
      end;
    finally
      SD.Free;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actSaveFieldToFileUpdate(Sender: TObject);
begin
  actSaveFieldToFile.Enabled := actShowRecord.Checked and sbRecord.Visible;
end;

procedure TfrmSQLEditorSyn.pnlTraceResize(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  if frmSQLTrace <> nil then
    frmSQLTrace.SetBounds(0, 0, pnlTrace.Width, pnlTrace.Height);
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actShowTreeUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibqryWork.Active
    and (ibqryWork.FindField('parent') <> nil)
    and (ibqryWork.FindField('name') <> nil)
    and (ibqryWork.FindField('id') <> nil);
end;

procedure TfrmSQLEditorSyn.actShowTreeExecute(Sender: TObject);
begin
  if not actShowTree.Checked then
  begin
    try
      tvResult.DataSource := dsResult;
      
      dbgResult.Visible := False;
      tvResult.Visible := True;
      pnlRecord.Visible := False;

      actShowGrid.Checked := False;
      actShowTree.Checked := True;
      actShowRecord.Checked := False;
    except
      on E: Exception do
      begin
        Application.ShowException(E);
        tvResult.DataSource := nil;
      end;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.seQuerySpecialLineColors(Sender: TObject;
  Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  if Line = FErrorLine then
  begin
    Special := True;
    BG := clRed;
    FG := clWhite;
  end;
end;

procedure TfrmSQLEditorSyn.actExternalEditorExecute(Sender: TObject);
begin
  InvokeExternalEditor('sql', seQuery.Lines);
end;

procedure TfrmSQLEditorSyn.actExternalEditorUpdate(Sender: TObject);
begin
  actExternalEditor.Enabled := (pcMain.ActivePage = tsQuery)
    and (seQuery.Text > '');
end;

procedure TfrmSQLEditorSyn.actClassesShowSelectSQLUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvClasses.Selected <> nil;
end;

procedure TfrmSQLEditorSyn.actClassesShowSelectSQLExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
  Cursor: TCursor;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if CreateCurrClassBusinessObject(Obj) then
  begin
    Cursor := Screen.Cursor;
    Screen.Cursor := crSQLWait;
    try
      Obj.Open;
      ClearError;
      seQuery.Text := Obj.SelectSQL.Text;
      seQuery.Show;
    finally
      Screen.Cursor := Cursor;
      Obj.Free;
    end;
  end;
{$ENDIF}
end;

procedure TfrmSQLEditorSyn.actClassesShowViewFormExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
  F: TCustomForm;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if CreateCurrClassBusinessObject(Obj) then
  try
    F := Obj.CreateViewForm(Application.MainForm, '', Obj.SubType, True);
    if F <> nil then
    begin
      F.ShowModal;
      F.Free;
    end;
  finally
    Obj.Free;
  end;
{$ENDIF}
end;

{$IFDEF GEDEMIN}
function TfrmSQLEditorSyn.CreateCurrClassBusinessObject(out Obj: TgdcBase): Boolean;
var
  CE: TgdClassEntry;
begin
  Assert(lvClasses.Selected <> nil);

  Obj := nil;
  CE := gdClassList.Find(Trim(lvClasses.Selected.Caption),
    lvClasses.Selected.SubItems[0]);

  if (CE is TgdBaseEntry) and (TgdBaseEntry(CE).gdcClass <> nil)
    and (not TgdBaseEntry(CE).gdcClass.IsAbstractClass) then
  begin
    Obj := TgdBaseEntry(CE).gdcClass.Create(nil);
    Obj.SubType := TgdBaseEntry(CE).SubType;
  end;

  Result := Obj <> nil;
end;
{$ENDIF}

procedure TfrmSQLEditorSyn.actConvertToPasExecute(Sender: TObject);
var
  I: Integer;
begin
  seQuery.Text := Trim(StringReplace(seQuery.Text, '''', '''''', [rfReplaceAll]));
  for I := 0 to seQuery.Lines.Count - 1 do
    seQuery.Lines[I] := '''' + seQuery.Lines[I];
  for I := 0 to seQuery.Lines.Count - 2 do
    seQuery.Lines[I] := seQuery.Lines[I] + ' ''#13#10 +';
  seQuery.Text := TrimRight(seQuery.Text) + ''';';
end;

procedure TfrmSQLEditorSyn.actConvertToPasUpdate(Sender: TObject);
begin
  actConvertToPas.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actConvertToSQLUpdate(Sender: TObject);
begin
  actConvertToSQL.Enabled := pcMain.ActivePage = tsQuery;
end;

procedure TfrmSQLEditorSyn.actConvertToSQLExecute(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  for I := 0 to seQuery.Lines.Count - 1 do
  begin
    S := TrimRight(seQuery.Lines[I]);

    if Copy(S, Length(S), 1) = ';' then
      SetLength(S, Length(S) - 1);

    S := Trim(StringReplace(S, '#13#10', '', [rfReplaceAll]));
    if (S > '') and (S[1] = '''') then
      Delete(S, 1, 1);
    if (S > '') and (S[Length(S)] = '+') then
      SetLength(S, Length(S) - 1);
    S := TrimRight(StringReplace(S, '''''', '''', [rfReplaceAll]));

    if Copy(S, Length(S), 1) = '''' then
      SetLength(S, Length(S) - 1);

    seQuery.Lines[I] := TrimRight(S);
  end;
end;

procedure TfrmSQLEditorSyn.actSetTransactionParamsExecute(Sender: TObject);
var
  Tr: TIBTransaction;
begin
  Tr := TIBTransaction.Create(nil);
  try
    {$IFDEF GEDEMIN}
    Assert(gdcBaseManager <> nil);
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.Params.CommaText := GetTransactionParams;
    try
      Tr.StartTransaction;
      Tr.Commit;

      if ibtrEditor.InTransaction then
        ibtrEditor.Commit;
      ibtrEditor.Params.CommaText := GetTransactionParams;
      ibtrEditor.StartTransaction;
      tsResult.TabVisible := False;
    except
      on E: Exception do
      begin
        MessageBox(Handle,
          PChar('Задан неверный параметр транзакции.'#13#10#13#10 + E.Message),
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      end;
    end;
    {$ENDIF}
  finally
    Tr.Free;
  end;
end;

procedure TfrmSQLEditorSyn.actSetTransactionParamsUpdate(Sender: TObject);
begin
  actSetTransactionParams.Enabled := pcMain.ActivePage = tsTransaction;
end;

procedure TfrmSQLEditorSyn.cbTransactionsChange(Sender: TObject);
var
  Tr: TIBTransaction;
begin
  Tr := cbTransactions.Items.Objects[cbTransactions.ItemIndex] as TIBTransaction;

  if Tr = ibtrEditor then
    exit;

  if (ibtrEditor = _ibtrEditor) and ibtrEditor.InTransaction then
    ibtrEditor.Commit;

  ibsqlPlan.Close;
  ibsqlPlan.Transaction := Tr;

  ibqryWork.Close;
  ibqryWork.Transaction := Tr;
  ibqryWork.ReadTransaction := Tr;

  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actChangeRUIDExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  S, sOldRUID, sNewRUID: String;
  OldRUID, NewRUID: TRUID;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  sOldRUID := '';
  sNewRUID := '';

  if InputQuery(
    'Замена РУИД',
    'Заменяемый РУИД в формате XID_DBID:',
    sOldRUID) and
    InputQuery(
    'Замена РУИД',
    'Заменяющий РУИД в формате XID_DBID:',
    sNewRUID) then
  begin
    OldRUID := StrToRUID(sOldRUID);
    NewRUID := StrToRUID(sNewRUID);

    if not ibtrEditor.InTransaction then
      ibtrEditor.StartTransaction;

    gdcBaseManager.ChangeRUID(OldRUID.XID, OldRUID.DBID,
      NewRUID.XID, NewRUID.DBID, ibtrEditor);

    S := 'Произведена замена РУИД ' + sOldRUID + ' -> ' + sNewRUID;

    mmPlan.Lines.Text := S + #13#10 + 'Подтвердите транзакцию для сохранения изменений.';
    AddLogRecord(S, True);
  end;
{$ENDIF}  
end;

procedure TfrmSQLEditorSyn.actFilterUpdate(Sender: TObject);
begin
  actFilter.Enabled := (pcMain.ActivePage = tsQuery)
    and (Trim(seQuery.Text) > '');
end;

procedure TfrmSQLEditorSyn.actFilterExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  Assert(gdcBaseManager <> nil);

  with TgsSQLFilter.Create(nil) do
  try
    Database := gdcBaseManager.Database;
    SetQueryText(seQuery.Text);
    if CreateSQL then
      seQuery.Text := FilteredSQL.Text;
  finally
    Free;
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actFindNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (pcMain.ActivePage = tsQuery) or
    (pcMain.ActivePage = tsResult);
end;

procedure TfrmSQLEditorSyn.edClassesFilterChange(Sender: TObject);
begin
  FillClassesList;

  if edClassesFilter.Text > '' then
  begin
    edClassesFilter.Color := clInfoBk;
    lvClasses.Color := clInfoBk;
  end else
  begin
    edClassesFilter.Color := clWindow;
    lvClasses.Color := clWindow;
  end;
end;

procedure TfrmSQLEditorSyn.actClassesRefreshExecute(Sender: TObject);
begin
  FillClassesList;
end;

initialization
  RegisterClass(TfrmSQLEditorSyn);

finalization
  UnRegisterClass(TfrmSQLEditorSyn);
end.






