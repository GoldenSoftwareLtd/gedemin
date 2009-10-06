
unit flt_frmSQLEditorSyn_unit;

{ TODO 5 -oandreik -cSQLHistory : Разобраться почему прибавляет _1 к имени формы }
{ TODO 5 -oandreik -cSQLHistory : Визуальные настройки таблицы с историей запросов }
{ TODO 5 -oandreik -cSQLHistory : Разобраться почему при добавлении записи в гриде старая запись остается выделенной }
{ TODO 5 -oandreik -cSQLHistory : Почему колонка BOOKMARK выводится в двойных кавычках? }
{ TODO 5 -oandreik -cSQLHistory : ДаблКлик срабатывает когда пытаемся изменить ширину колонки }

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
  gdcBase, gdc_frmSQLHistory_unit,
  {$ENDIF}
  SynCompletionProposal, flt_i_SQLProposal, flt_SQLProposal, gd_keyAssoc,
  gsIBGrid, gdcSQLHistory;

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
    pnlTest: TPanel;
    actShowViewForm: TAction;
    TBSeparatorItem17: TTBSeparatorItem;
    TBItem28: TTBItem;
    actMakeSelect: TAction;
    TBItem29: TTBItem;
    pmSaveFieldToFile: TPopupMenu;
    actSaveFieldToFile: TAction;
    nSaveFieldToFile: TMenuItem;
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
    procedure chbxAutoCommitDDLClick(Sender: TObject);
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
    procedure actShowViewFormUpdate(Sender: TObject);
    procedure actShowViewFormExecute(Sender: TObject);
    procedure actMakeSelectUpdate(Sender: TObject);
    procedure actMakeSelectExecute(Sender: TObject);
    procedure actSaveFieldToFileExecute(Sender: TObject);
    procedure actSaveFieldToFileUpdate(Sender: TObject);
  private
    FOldDelete, FOldInsert, FOldUpdate, FOldIndRead, FOldSeqRead: TStrings;
    FOldRead, FOldWrite, FOldFetches: Integer;
    FPrepareTime, FExecuteTime, FFetchTime: TDateTime;
    FTableArray: TgdKeyStringAssoc;
    FParams: TParams;
    FRepeatQuery: Boolean;
    FTop, FLeft: Integer;
    {$IFDEF GEDEMIN}
    frmSQLHistory: Tgdc_frmSQLHistory;
    {$ENDIF}

    procedure RemoveNoChange(const Before, After: TStrings);
    function PrepareQuery: Boolean;
    procedure ShowStatistic;
    procedure SaveLastStat;
    function CreateTableList: Boolean;
    procedure AddLogRecord(const StrLog: String);
    function InputParam: Boolean;
    procedure UpdateSyncs;
    procedure UpdateHistory;
    procedure LoadHistory;
    procedure DrawChart;
    {$IFDEF GEDEMIN}
    function CreateBusinessObject: TgdcBase;
    {$ENDIF}

    procedure AddSQLHistory(const AnExecute: Boolean);
    procedure UseSQLHistory;
    procedure OnHistoryDblClick(Sender: TObject);

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
  gdcBaseInterface, flt_sql_parser, at_sql_setup,
  {$ENDIF}
  gd_directories_const, Clipbrd, gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cQueryHistory = 'QueryHistory';

function ReadStringFromStream(Stream: TStream): String;
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
    
  ibsqlPlan.Database := FDatabase;
  ibqryWork.Database := FDatabase;
  ibtrEditor.DefaultDatabase := FDatabase;
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
    if FLeft > 0 then Left := FLeft;
    if FTop > 0 then Top := FTop;

    Result := SetParams(ibqryWork.Params);

    FRepeatQuery := chbxRepeat.Checked;
    FLeft := Left;
    FTop := Top;
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
var
  OldMessage: String;
  OldSQLCode, OldGDSCode: Integer;
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
        on E: Exception do
        begin
          OldMessage := E.Message;

          if E is EIBError then
          begin
            OldSQLCode := EIBError(E).SQLCode;
            OldGDSCode := EIBError(E).IBErrorCode;
          end else
          begin
            OldSQLCode := 0;
            OldGDSCode := 0;
          end;

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
        mmPlan.Text := E.Message;
        if E is EIBError then
        begin
          if (OldGDSCode <> 0) or (OldSQLCode <> 0) then
            mmPlan.Lines.Add('SQLCode: ' + IntToStr(OldSQLCode) +
              '; GDSCode: ' + IntToStr(OldGDSCode))
          else
            mmPlan.Lines.Add('SQLCode: ' + IntToStr(EIBError(E).SQLCode) +
              '; GDSCode: ' + IntToStr(EIBError(E).IBErrorCode));
        end;
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
  I: Integer;
  S: String;
begin
  if PrepareQuery then
  begin
    ibqryWork.Close;
    ibqryWork.SelectSQL.Text := seQuery.Text;

    try
      ibqryWork.ParamCheck := True;
      ibqryWork.Prepare;
    except
      ibqryWork.ParamCheck := False;
      ibqryWork.Prepare;
    end;

    repeat
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

      AddSQLHistory(True);

      ibqryWork.UnPrepare;
      ibqryWork.DisableControls;
      try
        SaveLastStat;

        StartTime := Now;
        ibqryWork.Prepare;

        FPrepareTime := Now - StartTime;

        if (ibqryWork.SQLType = SQLDDL) {and (UserStorage <> nil)
          and UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False)} then
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
          FRepeatQuery := False;
        end else
        begin
          if pcMain.ActivePage = tsResult then
            pcMain.ActivePage := tsQuery;
          tsResult.TabVisible := False;
        end;

        if (ibqryWork.SQLType = SQLDDL) {and (UserStorage <> nil)
          and UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False)} then
        begin
          actCommit.Execute;
        end;

        StartTime := Now;
        ibqryWork.EnableControls;
        FFetchTime := Now - StartTime;

        ShowStatistic;

        if ibqryWork.QSelect.SQLType in [SQLInsert, SQLUpdate, SQLDelete, SQLExecProcedure] then
          mmPlan.Lines.Add('RowsAffected: ' + IntToStr(ibqryWork.QSelect.RowsAffected));

        if mmPlan.Color <> clWindow then
          mmPlan.Color := clWindow;
      except
        on E: Exception do
        begin
          mmPlan.Text := E.Message;
          if E is EIBError then
            mmPlan.Lines.Add('SQLCode: ' + IntToStr(EIBError(E).SQLCode) +
              '; GDSCode: ' + IntToStr(EIBError(E).IBErrorCode));
          mmPlan.Color := $AAAAFF;
          AddLogRecord(E.Message);
          FRepeatQuery := False;
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
    ibtrEditor.Commit;
  if pcMain.ActivePage = tsResult then
    pcMain.ActivePage := tsQuery;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actRollbackExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
    ibtrEditor.Rollback;
  if pcMain.ActivePage = tsResult then
    pcMain.ActivePage := tsQuery;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditorSyn.actCommitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibtrEditor.InTransaction;
end;

procedure TfrmSQLEditorSyn.FormCreate(Sender: TObject);
var
  I: Integer;
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
  ibtrMonitor.DefaultDatabase := gdcBaseManager.Database;
  tsMonitor.TabVisible := gdcBaseManager.Database.ODSMajorVersion >= 11; // FB 2.5

  frmSQLHistory := Tgdc_frmSQLHistory.Create(Self);
  frmSQLHistory.ShowSpeedButton := False;
  frmSQLHistory.Parent := pnlTest;
  frmSQLHistory.BorderStyle := bsNone;
  frmSQLHistory.tbMainMenu.Visible := False;
  frmSQLHistory.sbMain.Visible := False;
  frmSQLHistory.ibgrMain.OnDblClick := OnHistoryDblClick;

  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('id')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('sql_text')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('sql_params')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('bookmark')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creatorkey')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creationdate')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('editorkey')).Visible := False;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('editiondate')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('creator')).Visible := True;
  frmSQLHistory.ibgrMain.ColumnByField(frmSQLHistory.gdcObject.FieldByName('exec_count')).Visible := True;

  frmSQLHistory.Show;
  {$ENDIF}

  pnlRecord.Visible := False;
  dbgResult.Visible := True;
  actShowGrid.Checked := True;
  actShowRecord.Checked := False;

  pcMain.ActivePage := tsQuery;
  ActiveControl := seQuery;
  UpdateSyncs;

  {if UserStorage <> nil then
    chbxAutoCommitDDL.Checked := UserStorage.ReadBoolean('Options', 'AutoCommitDDL', True, False);}
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
    ibsqlPlan.Database := FDatabase;
    ibqryWork.Database := FDatabase;
    ibtrEditor.DefaultDatabase := FDatabase;
    IBDatabaseInfo.Database := FDatabase;
  end;

  if SQLProposal = nil then
    SQLProposalObject := TSQLProposal.Create(nil);
  {$ENDIF}
end;

destructor TfrmSQLEditorSyn.Destroy;
begin
  FParams.Free;
  FTableArray.Free;
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
  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TfrmSQLEditorSyn.SaveSettings;
begin
  inherited;
  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
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
begin
  {$IFDEF GEDEMIN}
  frmSQLHistory.gdcObject.Next;
  UseSQLHistory;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.actPrevQueryExecute(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  frmSQLHistory.gdcObject.Prior;
  UseSQLHistory;
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
    and (Trim(seQuery.Text) > '');
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
  if frmSQLHistory <> nil then UseSQLHistory;
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
          if ibqryWork.IsEmpty then
          begin
            Obj.Open;
            Result := Obj;
            Obj := nil;
          end else
          begin
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

procedure TfrmSQLEditorSyn.AddSQLHistory(const AnExecute: Boolean);
  {$IFDEF GEDEMIN}
  procedure SaveSQLParams;
  var
    K: Integer;
    js: TStrings;
    S: String;
  begin
    if ibqryWork.ParamCheck and (ibqryWork.Params.Count > 0) then
    begin
      js := TStringList.Create;
      try
        for K := 0 to ibqryWork.Params.Count - 1 do
        begin
          if js.IndexOfName(ibqryWork.Params[K].Name) = -1 then
          begin
            if not ibqryWork.Params[K].IsNull then
            begin
              case ibqryWork.Params[K].SQLType of
                SQL_TIMESTAMP, SQL_TYPE_DATE, SQL_TYPE_TIME:
                  S := SafeDateTimeToStr(ibqryWork.Params[K].AsDateTime);
                SQL_SHORT, SQL_LONG, SQL_INT64, SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
                  S := SafeFloatToStr(ibqryWork.Params[K].AsDouble);
              else
                S := '"' + ConvertSysChars(ibqryWork.Params[K].AsString) + '"';
              end;
            end else
              S := '<NULL>';
            js.Add(ibqryWork.Params[K].Name + '=' + S);
          end;
        end;
        frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').AsString := js.Text;
      finally
        js.Free;
      end;
    end else
      frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').Clear;
  end;
  {$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if (frmSQLHistory <> nil) then
  begin
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
  end;
  {$ENDIF}
end;

procedure TfrmSQLEditorSyn.UseSQLHistory;
{$IFDEF GEDEMIN}
var
  SL: TStringList;
  I: Integer;
  P: TParam;
  S: String;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if not frmSQLHistory.gdcObject.IsEmpty then
  begin
    seQuery.Text := frmSQLHistory.gdcObject.FieldByName('SQL_TEXT').AsString;

    FParams.Clear;

    if frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').AsString > '' then
    begin
      SL := TStringList.Create;
      try
        SL.Text := frmSQLHistory.gdcObject.FieldByName('SQL_PARAMS').AsString;
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

procedure TfrmSQLEditorSyn.OnHistoryDblClick(Sender: TObject);
begin
  UseSQLHistory;
end;

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
  actEditBusinessObject.Enabled := ibqryWork.Active {and
    (not ibqryWork.IsEmpty)};
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
var
  Tr: TIBTransaction;
begin
  if (pcMain.ActivePage = tsTransaction)
    and (ibtrEditor <> nil)
    and (ibtrEditor.Params.Text <> mTransaction.Lines.Text) then
  begin
    Tr := TIBTransaction.Create(nil);
    try
      {$IFDEF GEDEMIN}
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.Params.Text := mTransaction.Lines.Text;
      try
        Tr.StartTransaction;

        if ibtrEditor.InTransaction then
          ibtrEditor.Commit;
        ibtrEditor.Params.Text := mTransaction.Lines.Text;
        ibtrEditor.StartTransaction;
        tsResult.TabVisible := False;
        AllowChange := True;
      except
        MessageBox(Handle,
          'Задан неверный параметр транзакции.',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        AllowChange := False;
      end;
      {$ENDIF}
    finally
      Tr.Free;
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
  actParse.Enabled := (pcMain.ActivePage = tsQuery)
    and (Trim(seQuery.Text) > '');
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
  {$IFDEF FR4}
  with ChReads.SeriesList.Series[0] do
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

procedure TfrmSQLEditorSyn.chbxAutoCommitDDLClick(Sender: TObject);
begin
  {if UserStorage <> nil then
  begin
    if chbxAutoCommitDDL.Checked then
      UserStorage.DeleteValue('Options', 'AutoCommitDDL', False)
    else
      UserStorage.WriteBoolean('Options', 'AutoCommitDDL', False);
  end;}
end;

procedure TfrmSQLEditorSyn.actRefreshMonitorExecute(Sender: TObject);
begin
  ibdsMonitor.Close;
  ibdsMonitor.Open;
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
  seQuery.Text := ibdsMonitor.FieldByName('sql_text').AsString;
  seQuery.Show;
end;

procedure TfrmSQLEditorSyn.pcMainChange(Sender: TObject);
begin
  if (pcMain.ActivePage = tsMonitor) and (ibdsMonitor <> nil) then
  begin
    actRefreshMonitor.Execute;
  end else if (pcMain.ActivePage = tsResult) and (not tsResult.TabVisible) then
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
      LockWindowUpdate(pnlRecord.Handle);
      try
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
            TDBMemo(E).PopupMenu := pmSaveFieldToFile;
          end;

          Inc(Y, 22);
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
  if mmPlan.Color <> clWindow then
    mmPlan.Color := clWindow;
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

procedure TfrmSQLEditorSyn.actShowViewFormUpdate(Sender: TObject);
begin
  actShowViewForm.Enabled := ibqryWork.Active;
end;

procedure TfrmSQLEditorSyn.actShowViewFormExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Obj: TgdcBase;
  F: TCustomForm;
begin
  Obj := CreateBusinessObject;
  try
    if Obj <> nil then
    begin
      F := Obj.CreateViewForm(Application.MainForm, '', Obj.SubType, True);
      if F <> nil then
      begin
        F.ShowModal;
        F.Free;
      end;
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
  seQuery.Text := 'SELECT * FROM ' + iblkupTable.Text + ' WHERE 1=1';
  seQuery.Show;
end;

procedure TfrmSQLEditorSyn.actSaveFieldToFileExecute(Sender: TObject);
var
  SD: TSaveDialog;
begin
  if (pmSaveFieldToFile.PopupComponent is TDBMemo)
    and ((pmSaveFieldToFile.PopupComponent as TDBMemo).Field is TBlobField) then
  begin
    SD := TSaveDialog.Create(Self);
    try
      SD.Title := 'Сохранить значение поля в файл';
      SD.DefaultExt := 'dat';
      SD.Filter := 'Текстовые файлы (*.txt)|*.txt|Фйлы данных(*.dat)|*.dat|Все файлы (*.*)|*.*';
      SD.FileName := (pmSaveFieldToFile.PopupComponent as TDBMemo).Field.Name + '.dat';
      SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if SD.Execute then
        ((pmSaveFieldToFile.PopupComponent as TDBMemo).Field as TBlobField).SaveToFile(SD.FileName);
    finally
      SD.Free;
    end;
  end;
end;

procedure TfrmSQLEditorSyn.actSaveFieldToFileUpdate(Sender: TObject);
begin
  actSaveFieldToFile.Enabled := actShowRecord.Checked and sbRecord.Visible;
end;

initialization
  RegisterClass(TfrmSQLEditorSyn);

finalization
  UnRegisterClass(TfrmSQLEditorSyn);
end.

