// ShlTanya, 10.03.2019

unit flt_frmSQLEditor_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabaseInfo, Db, IBSQL, IBDatabase, IBCustomDataSet, IBQuery,
  ActnList, ImgList, ExtCtrls, StdCtrls, ComCtrls, Grids, DBGrids, DBCtrls,
  ToolWin;

type
  TCountRead = Record
    IndReadCount: Integer;
    SeqReadCount: Integer;
    InsertCount: Integer;
    UpdateCount: Integer;
    DeleteCount: Integer;
  end;

type
  TfrmSQLEditor = class(TForm)
    ToolBar1: TToolBar;
    tbExecute: TToolButton;
    tbPrepare: TToolButton;
    ToolButton4: TToolButton;
    tbCommit: TToolButton;
    tbRollback: TToolButton;
    ToolButton7: TToolButton;
    tbFind: TToolButton;
    ToolButton9: TToolButton;
    tbExport: TToolButton;
    pnlPlan: TPanel;
    Splitter1: TSplitter;
    pnlMain: TPanel;
    pcMain: TPageControl;
    tsQuery: TTabSheet;
    tsResult: TTabSheet;
    tsStatistic: TTabSheet;
    mmPlan: TMemo;
    pnlNavigator: TPanel;
    DBNavigator1: TDBNavigator;
    ImageList: TImageList;
    ActionList1: TActionList;
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
    dbgResult: TDBGrid;
    lvReads: TListView;
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
    tsLog: TTabSheet;
    mmLog: TMemo;
    imScript: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    seQuery: TMemo;
    ibqryWork: TIBDataSet;
    procedure actPrepareExecute(Sender: TObject);
    procedure actExecuteExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actRollbackExecute(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FOldDelete, FOldInsert, FOldUpdate, FOldIndRead, FOldSeqRead: TStrings;
    FOldRead, FOldWrite, FOldFetches: Integer;
    FPrepareTime, FExecuteTime, FFetchTime: TDateTime;
    FTableCount: Integer;
    FTableArray: array of String[32];

    procedure RemoveNoChange(const Before, After: TStrings);
    function PrepareQuery: Boolean;
    procedure ShowStatistic;
    procedure SaveLastStat;
    function CreateTableList: Boolean;
    procedure AddLogRecord(const StrLog: String);
    function InputParam: Boolean;
  public
    FDatabase: TIBDatabase;

    procedure ShowSQL(const AnSQL: String; const AParams: TParams = nil;
      const AShowModal: Boolean = True);
  end;

var
  frmSQLEditor: TfrmSQLEditor;

implementation

uses
  flt_dlgInputParam_unit;

{$R *.DFM}

procedure TfrmSQLEditor.ShowSQL(const AnSQL: String; const AParams: TParams = nil;
  const AShowModal: Boolean = True);
begin
  seQuery.Text := AnSQL;
  ibsqlPlan.Database := FDatabase;
  ibqryWork.Database := FDatabase;
  ibtrEditor.DefaultDatabase := FDatabase;
  IBDatabaseInfo.Database := FDatabase;
  FTableCount := 0;
  tsResult.TabVisible := False;
  if not CreateTableList then
    Exit;
  if AShowModal then
    ShowModal
  else
    Show;  
end;

function TfrmSQLEditor.InputParam: Boolean;
begin
  with TdlgInputParam.Create(Self) do
  try
    Result := SetParams(ibqryWork.Params);
  finally
    Free;
  end;
end;

procedure TfrmSQLEditor.AddLogRecord(const StrLog: String);
begin
  mmLog.Lines.Add('');
  mmLog.Lines.Add(StrLog);
end;

function TfrmSQLEditor.CreateTableList: Boolean;
var
  ibsqlTable: TIBSQL;
begin
  Result := False;
  ibsqlTable := TIBSQL.Create(Self);
  try
    ibsqlTable.Database := FDatabase;
    ibsqlTable.Transaction := ibtrEditor;
    if not ibtrEditor.Active then
      ibtrEditor.StartTransaction;
    ibsqlTable.SQL.Text := 'Select RDB$RELATION_ID, RDB$RELATION_NAME from RDB$RELATIONS' +
     ' where RDB$VIEW_BLR is NULL order by RDB$RELATION_ID desc';
    try
      ibsqlTable.ExecQuery;
      if not ibsqlTable.Eof then
      begin
        FTableCount := ibsqlTable.Fields[0].AsInteger + 1;
        SetLength(FTableArray, FTableCount);
        while not ibsqlTable.Eof do
        begin
          FTableArray[ibsqlTable.Fields[0].AsInteger] := ibsqlTable.Fields[1].AsString;

          ibsqlTable.Next;
        end;
      end;
      Result := True;
    except
      on E: Exception do
        MessageBox(Self.Handle, 'Произошла ошибка при считывании списка таблиц', 'Ошибка', MB_OK or MB_ICONERROR);
    end;
  finally
    if ibtrEditor.Active then
      ibtrEditor.Commit;
    ibsqlTable.Free;
  end;
end;

procedure TfrmSQLEditor.SaveLastStat;
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

procedure TfrmSQLEditor.RemoveNoChange(const Before, After: TStrings);
var
  I, J: Integer;

  function ConvertStr(const Str: String): Integer;
  begin
    if Trim(Str) = '' then
      Result := 0
    else
    try
      Result := StrToInt(Str);
    except
      Result := 0;
    end;
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
    After.Values[After.Names[I]] := IntToStr(ConvertStr(After.Values[After.Names[I]]) - ConvertStr(Before.Values[After.Names[I]]));
  except
    on E: Exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TfrmSQLEditor.ShowStatistic;
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
        L.Caption := FTableArray[Integer(L.Data)];
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

function TfrmSQLEditor.PrepareQuery: Boolean;
begin
  if not ibtrEditor.InTransaction then
    ibtrEditor.StartTransaction;
  Result := False;
  ibsqlPlan.Close;
  ibsqlPlan.SQL.Text := seQuery.Text;
  try
    AddLogRecord('/*------' + DateTimeToStr(Now) + '------*/');
    AddLogRecord(seQuery.Text);
    ibsqlPlan.Prepare;
    mmPlan.Text := ibsqlPlan.Plan;
    Result := True;
  except
    on E: Exception do
    begin
      mmPlan.Text := E.Message;
      AddLogRecord(E.Message);
    end;
  end;
end;

procedure TfrmSQLEditor.actPrepareExecute(Sender: TObject);
begin
  PrepareQuery;
end;

procedure TfrmSQLEditor.actExecuteExecute(Sender: TObject);
var
  StartTime: TDateTime;
begin
  if PrepareQuery then
  begin
    ibqryWork.Close;
    ibqryWork.SelectSQL.Text := seQuery.Text;
    if not InputParam then
      Exit;
    ibqryWork.DisableControls;
    try
      SaveLastStat;

      StartTime := Now;
      ibqryWork.Prepare;
      FPrepareTime := Now - StartTime;

      StartTime := Now;
      ibqryWork.Open;
      FExecuteTime := Now - StartTime;

      tsResult.TabVisible := True;
      pcMain.ActivePage := tsResult;

      StartTime := Now;
      ibqryWork.EnableControls;
      FFetchTime := Now - StartTime;

      ShowStatistic;
    except
      on E: Exception do
      begin
        mmPlan.Text := E.Message;
        AddLogRecord(E.Message);
      end;
    end;
    ibqryWork.EnableControls;
  end;
end;

procedure TfrmSQLEditor.actCommitExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
    ibtrEditor.Commit;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditor.actRollbackExecute(Sender: TObject);
begin
  if ibtrEditor.InTransaction then
    ibtrEditor.Rollback;
  tsResult.TabVisible := False;
end;

procedure TfrmSQLEditor.actCommitUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ibtrEditor.InTransaction;
end;

procedure TfrmSQLEditor.FormCreate(Sender: TObject);
begin
  FOldDelete := TStringList.Create;
  FOldInsert := TStringList.Create;
  FOldUpdate := TStringList.Create;
  FOldIndRead := TStringList.Create;
  FOldSeqRead := TStringList.Create;
  FTableCount := 0;
  pcMain.ActivePage := tsQuery;
end;

procedure TfrmSQLEditor.FormDestroy(Sender: TObject);
begin
  FOldDelete.Free;
  FOldInsert.Free;
  FOldUpdate.Free;
  FOldIndRead.Free;
  FOldSeqRead.Free;
end;

end.
