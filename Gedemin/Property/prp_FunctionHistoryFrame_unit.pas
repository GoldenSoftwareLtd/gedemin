// ShlTanya, 26.02.2019

unit prp_FunctionHistoryFrame_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Db, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBCustomDataSet, dmImages_unit, ImgList, TB2Dock, TB2Toolbar, TB2Item,
  ActnList, Menus;

type
  Tprp_FunctionHistoryFrame = class(TFrame)
    pnlLog: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
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
    procedure dsLogDataChange(Sender: TObject; Field: TField);
    procedure ibdsLogAfterOpen(DataSet: TDataSet);
    procedure TBItem1Click(Sender: TObject);
    procedure TBItem2Click(Sender: TObject);
    procedure tbOnlyDiffClick(Sender: TObject);
    procedure actCompareContentsUpdate(Sender: TObject);
    procedure actCompareContentsExecute(Sender: TObject);
    procedure actCheckOutUpdate(Sender: TObject);
    procedure actCheckOutExecute(Sender: TObject);

  private
    FileView: TFrame;
  public
    S: String;

    constructor Create(AnOwner: TComponent); override;
  end;

implementation

{$R *.DFM}

uses
  FileView, gdcBaseInterface, prp_ScriptComparer_unit, prp_FunctionFrame_Unit;

{ Tprp_FunctionHistoryFrame }

constructor Tprp_FunctionHistoryFrame.Create(AnOwner: TComponent);
begin
  inherited;

  FileView := TFilesFrame.Create(Self);
  FileView.Parent := Panel2;
  with TFilesFrame(FileView).FontDialog1.Font do
  begin
    Name := 'Courier New';
    Size := 10;
  end;
  TFilesFrame(FileView).Setup;

  ibdsLog.Transaction := gdcBaseManager.ReadTransaction;
end;

procedure Tprp_FunctionHistoryFrame.dsLogDataChange(Sender: TObject;
  Field: TField);
begin
  TFilesFrame(FileView).pnlCaptionLeft.Caption := 'Текущая ревизия';
  if ibdsLog.FieldByName('revision').AsString <> '999999' then
    TFilesFrame(FileView).pnlCaptionRight.Caption := 'Ревизия ' + ibdsLog.FieldByName('revision').AsString
  else
    TFilesFrame(FileView).pnlCaptionRight.Caption := 'Текущая ревизия';
  TFilesFrame(FileView).Compare(S, ibdsLog.FieldByName('script').AsString);
end;

procedure Tprp_FunctionHistoryFrame.ibdsLogAfterOpen(DataSet: TDataSet);
begin
  ibgrLog.DontLoadSettings := True;
  ibgrLog.ScaleColumns := False;
  DataSet.FieldByName('id').Visible := False;
  DataSet.FieldByName('script').Visible := False;
  DataSet.FieldByName('revision').Visible := False;
  DataSet.FieldByName('editiondate').DisplayLabel := 'Дата изменения';
  DataSet.FieldByName('editiondate').DisplayWidth := 20;
  DataSet.Fields[1].DisplayLabel := 'Ревизия';
  DataSet.Fields[4].DisplayLabel := 'Автор';
  DataSet.Fields[4].DisplayWidth := 100;
  ibgrLog.ScaleColumns := True;
  dsLog.DataSet := ibdsLog;
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
end;

procedure Tprp_FunctionHistoryFrame.actCompareContentsUpdate(
  Sender: TObject);
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
    if ibgrLog.SelectedRows.Count = 1 then
    begin
      ScriptComparer.Compare(S, ibdsLog.FieldByName('script').AsString);
      ScriptComparer.LeftCaption('Текущая ревизия');
      ScriptComparer.RightCaption('Ревизия ' + ibdsLog.FieldByName('revision').AsString);
    end else
    begin
      ibdsLog.Bookmark := ibgrLog.SelectedRows[0];
      S1 := ibdsLog.FieldByName('script').AsString;
      rev1 := 'Ревизия ' + ibdsLog.FieldByName('revision').AsString;

      ibdsLog.Bookmark := ibgrLog.SelectedRows[1];
      S2 := ibdsLog.FieldByName('script').AsString;
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
        gdcFunction.FieldByName('script').AsString := ibdsLog.FieldByName('script').AsString;
        Post;
      except
        raise;
      end;
    end;
  end;
end;

initialization
  RegisterClass(Tprp_FunctionHistoryFrame);
finalization
  UnRegisterClass(Tprp_FunctionHistoryFrame);
end.
