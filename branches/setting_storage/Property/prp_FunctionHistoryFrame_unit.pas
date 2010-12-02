unit prp_FunctionHistoryFrame_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Db, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBCustomDataSet, dmImages_unit, ImgList, TB2Dock, TB2Toolbar, TB2Item,
  ActnList, Menus, StdCtrls, IBSQL;

type
  Tprp_FunctionHistoryFrame = class(TFrame)
    pnlLog: TPanel;
    Splitter1: TSplitter;
    pnlFileView: TPanel;
    ibdsLog: TIBDataSet;
    ibgrLog: TgsIBGrid;
    dsLog: TDataSource;
    Panel1: TPanel;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    tbOnlyDiff: TTBItem;
    alHistoryFrame: TActionList;
    TBSeparatorItem2: TTBSeparatorItem;
    pmHistoryFrame: TPopupMenu;
    actCompareContents: TAction;
    N1: TMenuItem;
    actCheckOut: TAction;
    N2: TMenuItem;
    TBControlItem1: TTBControlItem;
    lblDiffStatus: TLabel;
    procedure dsLogDataChange(Sender: TObject; Field: TField);
    procedure ibdsLogAfterOpen(DataSet: TDataSet);
    procedure TBItem1Click(Sender: TObject);
    procedure TBItem2Click(Sender: TObject);
    procedure tbOnlyDiffClick(Sender: TObject);
    procedure actCompareContentsUpdate(Sender: TObject);
    procedure actCompareContentsExecute(Sender: TObject);
    procedure actCheckOutUpdate(Sender: TObject);
    procedure actCheckOutExecute(Sender: TObject);
    procedure ibgrLogDblClick(Sender: TObject);
  private
    FileView: TFrame;
    FScriptIBSQL: TIBSQL;

    function GetLogFunctionText(const ALogKey: Integer): String;
  public
    S: String;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.DFM}

uses
  FileView, gdcBaseInterface, prp_ScriptComparer_unit, prp_FunctionFrame_Unit;

{ Tprp_FunctionHistoryFrame }

constructor Tprp_FunctionHistoryFrame.Create(AnOwner: TComponent);
begin
  inherited;

  FileView := TFilesFrame.Create(pnlFileView);
  FileView.Parent := Self;
  with TFilesFrame(FileView).FontDialog1.Font do
  begin
    Name := 'Courier New';
    Size := 10;
  end;
  TFilesFrame(FileView).Setup;

  ibdsLog.Transaction := gdcBaseManager.ReadTransaction;
  ibdsLog.SelectSQL.Text :=
    'SELECT' + #13#10 + 
    '  l.id,' + #13#10 +
    '  l.revision,' + #13#10 +
    '  l.editiondate,' + #13#10 +
    '  c.name AS authorname,' + #13#10 +
    '  IIF(l.id = m.id, 1, 0) AS current_revision' + #13#10 +
    'FROM' + #13#10 +
    '  gd_function_log l' + #13#10 +
    '  JOIN gd_contact c ON c.id = l.editorkey' + #13#10 +
    '  LEFT JOIN gd_function_log m ON m.id = (SELECT FIRST (1)' + #13#10 +
    '                                           m.id' + #13#10 +
    '                                         FROM' + #13#10 +
    '                                           gd_function_log m' + #13#10 +
    '                                         WHERE' + #13#10 +
    '                                           m.functionkey = :id' + #13#10 +
    '                                         ORDER BY' + #13#10 +
    '                                           m.revision DESC)' + #13#10 +
    'WHERE' + #13#10 + 
    '  l.functionkey = :id' + #13#10 +
    'ORDER BY' + #13#10 +
    '  l.revision DESC ';

  FScriptIBSQL := TIBSQL.Create(Self);
  FScriptIBSQL.Transaction := gdcBaseManager.ReadTransaction;
  FScriptIBSQL.SQL.Text :=
    'SELECT l.script FROM gd_function_log l WHERE l.id = :id';
end;

procedure Tprp_FunctionHistoryFrame.dsLogDataChange(Sender: TObject; Field: TField);
begin
  TFilesFrame(FileView).pnlCaptionLeft.Caption := 'Текущая ревизия';
  if ibdsLog.FieldByName('current_revision').AsInteger <> 1 then
  begin
    TFilesFrame(FileView).pnlCaptionRight.Caption := 'Ревизия ' + ibdsLog.FieldByName('revision').AsString;
    TFilesFrame(FileView).Compare(S, GetLogFunctionText(ibdsLog.FieldByName('id').AsInteger));
  end
  else
  begin
    TFilesFrame(FileView).pnlCaptionRight.Caption := 'Текущая ревизия';
    TFilesFrame(FileView).Compare(S, S);
  end;

  lblDiffStatus.Caption := Format('     %s', [TFilesFrame(FileView).DiffStatusStr]);
end;

procedure Tprp_FunctionHistoryFrame.ibdsLogAfterOpen(DataSet: TDataSet);
begin
  ibgrLog.DontLoadSettings := True;
  DataSet.FieldByName('id').Visible := False;
  DataSet.FieldByName('editiondate').DisplayLabel := 'Дата изменения';
  DataSet.FieldByName('revision').DisplayLabel := 'Ревизия';
  DataSet.FieldByName('authorname').DisplayLabel := 'Автор';
  DataSet.FieldByName('current_revision').Visible := False;
  dsLog.DataSet := ibdsLog;

  ibgrLog.ColumnByField(DataSet.FieldByName('revision')).Width := 70;
  ibgrLog.ColumnByField(DataSet.FieldByName('editiondate')).Width := 120;
  ibgrLog.StripeEven := DefStripeEven;
  ibgrLog.StripeOdd := DefStripeOdd;
end;

procedure Tprp_FunctionHistoryFrame.TBItem1Click(Sender: TObject);
begin
  TFilesFrame(FileView).NextClick;
end;

procedure Tprp_FunctionHistoryFrame.TBItem2Click(Sender: TObject);
begin
  TFilesFrame(FileView).PrevClick;
end;

procedure Tprp_FunctionHistoryFrame.tbOnlyDiffClick(Sender: TObject);
begin
  TTBItem(Sender).Checked := not TTBItem(Sender).Checked;
  TFilesFrame(FileView).ShowDiffsOnly := TTBItem(Sender).Checked;
  TFilesFrame(FileView).DisplayDiffs;

  lblDiffStatus.Caption := Format('     %s', [TFilesFrame(FileView).DiffStatusStr]);
end;

procedure Tprp_FunctionHistoryFrame.actCompareContentsUpdate(Sender: TObject);
begin
  actCompareContents.Enabled := (ibgrLog.SelectedRows.Count < 3);
end;

procedure Tprp_FunctionHistoryFrame.actCompareContentsExecute(
  Sender: TObject);
var
  ScriptComparer: Tprp_ScriptComparer;
  S1, S2: String;
  rev1, rev2: String;
begin
  ScriptComparer := Tprp_ScriptComparer.Create(nil);
  try
    if ibgrLog.SelectedRows.Count <= 1 then
    begin
      ScriptComparer.Compare(S, GetLogFunctionText(ibdsLog.FieldByName('id').AsInteger));
      ScriptComparer.LeftCaption('Текущая ревизия');
      ScriptComparer.RightCaption('Ревизия ' + ibdsLog.FieldByName('revision').AsString);
    end
    else
    begin
      ibdsLog.Bookmark := ibgrLog.SelectedRows[0];
      S1 := GetLogFunctionText(ibdsLog.FieldByName('id').AsInteger);
      rev1 := 'Ревизия ' + ibdsLog.FieldByName('revision').AsString;

      ibdsLog.Bookmark := ibgrLog.SelectedRows[1];
      S2 := GetLogFunctionText(ibdsLog.FieldByName('id').AsInteger);
      rev2 := 'Ревизия ' + ibdsLog.FieldByName('revision').AsString;

      ScriptComparer.Compare(S1 , S2);
      ScriptComparer.LeftCaption(rev1);
      ScriptComparer.RightCaption(rev2);
    end;
    ScriptComparer.ShowModal;
  finally
    ScriptComparer.Free;
  end;
end;

procedure Tprp_FunctionHistoryFrame.actCheckOutUpdate(Sender: TObject);
begin
  actCheckOut.Enabled := (ibgrLog.SelectedRows.Count = 1) and (Self.Owner is TFunctionFrame);
end;

procedure Tprp_FunctionHistoryFrame.actCheckOutExecute(Sender: TObject);
begin
  ibdsLog.Bookmark := ibgrLog.SelectedRows[0];
  if MessageBox(0, PChar('Заменить скрипт-функцию ревизией ' +
    ibdsLog.FieldByName('revision').AsString + ' от ' +
    ibdsLog.FieldByName('editiondate').AsString), 'Внимание',
    MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES then begin

    with (Self.Owner as TFunctionFrame) do
    begin
      try
        gdcFunction.FieldByName('script').AsString := GetLogFunctionText(ibdsLog.FieldByName('id').AsInteger);
        Post;
      except
        raise;
      end;
    end;
  end;
end;

procedure Tprp_FunctionHistoryFrame.ibgrLogDblClick(Sender: TObject);
begin
  actCompareContents.Execute;
end;

destructor Tprp_FunctionHistoryFrame.Destroy;
begin
  FreeAndNil(FScriptIBSQL);
  inherited;
end;

function Tprp_FunctionHistoryFrame.GetLogFunctionText(const ALogKey: Integer): String;
begin
  Result := '';
  FScriptIBSQL.ParamByName('id').AsInteger := ALogKey;
  FScriptIBSQL.ExecQuery;
  if not FScriptIBSQL.Eof then
    Result := FScriptIBSQL.FieldByName('script').AsString;
  FScriptIBSQL.Close;
end;

initialization
  RegisterClass(Tprp_FunctionHistoryFrame);
finalization
  UnRegisterClass(Tprp_FunctionHistoryFrame);
end.
