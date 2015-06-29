unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, xReport, DBTables, DB,
  Grids, DBGrids, xMsgBox, xRTF, xRTFView, SplitBar, xWorld,
  xUpgrade, Spin, xBulbBtn, xSpin, xCalc;

type
  TMainForm = class(TForm)
    xReport1: TxReport;
    DataSource1: TDataSource;
    Table1: TTable;
    Panel1: TPanel;
    Panel2: TPanel;
    xWorld1: TxWorld;
    DataSource2: TDataSource;
    Table2: TTable;
    xReport2: TxReport;
    GroupBox1: TGroupBox;
    sw: TRadioButton;
    tw: TRadioButton;
    ExtraPopup: TPopupMenu;
    CreatexRepTst: TMenuItem;
    DataSource3: TDataSource;
    Table3: TTable;
    xRepTst: TxDBUpgrade;
    xReport3: TxReport;
    RunMenu: TPopupMenu;
    Run1: TMenuItem;
    Run2: TMenuItem;
    Run3: TMenuItem;
    Statistics1: TMenuItem;
    PrintDatashowninthiswindow1: TMenuItem;
    Viewer: TxRTFViewer;
    DataSourceAnim: TDataSource;
    Table4: TTable;
    xReport4: TxReport;
    Run4: TMenuItem;
    Label1: TLabel;
    Table3Number: TFloatField;
    Table3AutoNumber: TIntegerField;
    Table3City: TStringField;
    Table3SubCity: TStringField;
    Table3MoreNumber: TFloatField;
    ToFile: TRadioButton;
    RTFOutFile: TEdit;
    xRepTstNum: TxSpinEdit;
    Button1: TButton;
    Button2: TButton;
    procedure xReport1UserField(Sender: TObject; FieldName: String;
      var FieldResult: OpenString);
    procedure CreatexRepTstClick(Sender: TObject);
    procedure Run3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Statistics1Click(Sender: TObject);
    procedure xReport1Reportready(Sender: TObject; var RTFFile: TxRTFFile);
    procedure PrintDatashowninthiswindow1Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.xReport1UserField(Sender: TObject; FieldName: String;
  var FieldResult: OpenString);
begin
  if FieldName = 'TempF' then
    FieldResult := 'Hello. This is a User Field';
end;

const
 CCount = 10;
 Cities: array[0..CCount - 1] of string =
   ('Minsk',
    'Moscow',
    'New-York',
    'Paris',
    'London',
    'S.Petersburg',
    'Kiev',
    'Bonn',
    'Rome',
    'Riga');

procedure TMainForm.CreatexRepTstClick(Sender: TObject);
var
  i: Integer;
begin
  Table3.Close;
  xRepTst.CreateTables(cmCreate);
  Table3.Open;
{  Prg.Min := 0;
  Prg.Max := Round(xRepTstNum.Value);
  Prg.Show;}
  Table3.DisableControls;
  try
    for i := 0 to Round(xRepTstNum.Value) do
     begin
       Table3.Append;
       Table3.FieldByName('AutoNumber').AsInteger := i;
       Table3.FieldByName('City').AsString := Cities[Random(CCount)];
       Table3.FieldByName('SubCity').AsString := Cities[Random(CCount)];
       Table3.FieldByName('Number').AsFloat := Trunc((Random - 1/2)* 1000);
       Table3.FieldByName('More Number').AsFloat := (Random - 1/2)* 1e9;
       Table3.Post;
       if i mod 10 = 0 then
        begin
          {Prg.Value := i;}
          Application.ProcessMessages;
        end;
     end;
  finally
    Table3.EnableControls;
{    Prg.Hide;}
  end;
end;

procedure TMainForm.Run3Click(Sender: TObject);
var
  Report: TxReport;
begin
  if (Sender = Run1) or (Sender = Button1) then
    Report := xReport1
  else if Sender = Run2 then
    Report := xReport2
  else if Sender = Run3 then
    Report := xReport3
  else if Sender = Run4 then
    Report := xReport4
  else
    raise Exception.Create('Unsupposed error...');

  if sw.checked then
    Report.Destination := xReport.dsScreen
  else if tw.checked then
    Report.Destination := xReport.dsUserEvent
  else if ToFile.checked then
   begin
     Report.Destination := xReport.dsFile;
     Report.OutputFile := RTFOutFile.Text;
   end
  else
    raise Exception.Create('New destination');

  Report.Execute;

  if tw.Checked then
    Viewer.SetFocus;

end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
{  Table3.Open;}
end;

procedure TMainForm.Statistics1Click(Sender: TObject);
begin
  Viewer.Data.Statistics;
end;

procedure TMainForm.xReport1Reportready(Sender: TObject;
  var RTFFile: TxRTFFile);
begin
  if tw.Checked then
   begin
     Viewer.ExchangeData(RTFFile);
   end;
end;

procedure TMainForm.PrintDatashowninthiswindow1Click(Sender: TObject);
begin
  Viewer.PrintFile;
end;

end.
