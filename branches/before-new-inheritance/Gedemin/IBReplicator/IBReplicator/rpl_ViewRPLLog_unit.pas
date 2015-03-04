unit rpl_ViewRPLLog_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, xpDBGrid, rplDBGrid, DB, IBCustomDataSet,
  ExtCtrls, ActnList, XPButton, StdCtrls, XPEdit, XPComboBox;

type
  TfrmRPLLog = class(TForm)
    ibdsLog: TIBDataSet;
    dsLog: TDataSource;
    dbgrLog: TrplDBGrid;
    alMain: TActionList;
    actClose: TAction;
    Panel1: TPanel;
    btnClose: TXPButton;
    actFilter: TAction;
    XPButton1: TXPButton;
    cmbWhere: TXPComboBox;
    procedure FormCreate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure dbgrLogDblClick(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    procedure ResizeColumns;
  public
    { Public declarations }
  end;

const
  WHERE_HISTORY_FILE_NAME = 'd:\Bases\IBReplicator\WhereDBHist.txt';

var
  frmRPLLog: TfrmRPLLog;

implementation

uses rpl_dmImages_unit, rpl_BaseTypes_unit;

{$R *.dfm}

procedure TfrmRPLLog.FormCreate(Sender: TObject);
begin
  if FileExists(WHERE_HISTORY_FILE_NAME) then
    cmbWhere.Items.LoadFromFile(WHERE_HISTORY_FILE_NAME)
  else
    cmbWhere.Items.SaveToFile(WHERE_HISTORY_FILE_NAME);
  ibdsLog.Transaction:= ReplDataBase.Transaction;
  ibdsLog.SelectSQL.Text :=
    'SELECT r.relation, l.repltype, l.seqno, l.actiontime, l.oldkey, l.newkey ' +
    'FROM rpl$log l ' +
    '  JOIN rpl$relations r ON r.id = l.relationkey ' +
    'ORDER BY 3 ASC';
//    'ORDER BY 5, 3, 4 ASC';
  ibdsLog.Open;
  WindowState:= wsMaximized;
end;

procedure TfrmRPLLog.FormDestroy(Sender: TObject);
begin
  cmbWhere.Items.SaveToFile(WHERE_HISTORY_FILE_NAME);
end;

procedure TfrmRPLLog.actCloseExecute(Sender: TObject);
begin
  if ibdsLog.Transaction.InTransaction then
    ibdsLog.Transaction.RollBack;
  Close;
end;

procedure TfrmRPLLog.dbgrLogDblClick(Sender: TObject);
var
  sVal: string;
begin
  case dbgrLog.SelectedField.DataType of
    ftString: sVal:= dbgrLog.SelectedField.FullName + ' LIKE ' + QuotedStr('%' + dbgrLog.SelectedField.AsString + '%');
    ftInteger: sVal:= dbgrLog.SelectedField.FullName + '=' + IntToStr(dbgrLog.SelectedField.AsInteger);
  end;
  cmbWhere.Text:= sVal;
end;

procedure TfrmRPLLog.actFilterExecute(Sender: TObject);
var
  sWhere: string;
begin
  if cmbWhere.Text = '' then
    sWhere:= ''
  else
    sWhere:= 'WHERE ' + Trim(cmbWhere.Text);
  ibdsLog.CLose;
  ibdsLog.SelectSQL.Text :=
    'SELECT r.relation, l.repltype, l.seqno, l.actiontime, l.oldkey, l.newkey ' +
    'FROM rpl$log l ' +
    '  JOIN rpl$relations r ON r.id = l.relationkey ' +
    sWhere +
    'ORDER BY 3 ASC';
//    'ORDER BY 5, 3, 4 ASC';
  try
    ibdsLog.Open;
    if (cmbWhere.Items.IndexOf(cmbWhere.Text) = -1) and (Trim(cmbWhere.Text) <> '')  then
      cmbWhere.Items.Add(cmbWhere.Text);
    ResizeColumns;
  except
  end;
end;

procedure TfrmRPLLog.FormResize(Sender: TObject);
begin
  ResizeColumns;
end;

procedure TfrmRPLLog.ResizeColumns;
begin
  if dbgrLog.Columns.Count < 6 then Exit; 
  dbgrLog.Columns[0].Width:= 200;
  dbgrLog.Columns[1].Width:= 20;
  dbgrLog.Columns[2].Width:= 50;
  dbgrLog.Columns[3].Width:= 115;
  dbgrLog.Columns[4].Width:= (dbgrLog.Width - 425) div 2;
  dbgrLog.Columns[5].Width:= (dbgrLog.Width - 420) div 2;
end;

end.
