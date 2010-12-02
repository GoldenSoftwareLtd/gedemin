unit Test2Form;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xReport, gd_security, StdCtrls, Db, IBCustomDataSet, IBQuery, Grids,
  DBGrids, rp_Report, gd_security_OperationConst, DBClient, Provider,
  rp_BaseReport_unit, boScriptControl, rp_ScriptProvider_unit, IBDatabase,
  IBTable;

type
  TForm1 = class(TForm)
    xReport1: TxReport;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    IBQuery1: TIBQuery;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ClientDataSet1: TClientDataSet;
    Button5: TButton;
    dsClient: TDataSource;
    DataSetProvider1: TDataSetProvider;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ClientDataSet1id: TIntegerField;
    ClientDataSet1name: TStringField;
    boScriptControl1: TboScriptControl;
    boUserFunction1: TboUserFunction;
    gsCustomReportBase1: TgsCustomReportBase;
    ibtblTest: TIBTable;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    IBDatabase2: TIBDatabase;
    IBTransaction2: TIBTransaction;
    ibtblReport: TIBTable;
    Button10: TButton;
    IBQuery2: TIBQuery;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure boScriptControl1CreateObject(Sender: TObject;
      Handler: TScriptObjectHandler);
    procedure Button10Click(Sender: TObject);
  private
    procedure CopyData;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses dmDataBase_unit;

{$R *.DFM}

procedure TForm1.CopyData;
var
  I: Integer;
begin
  IBQuery1.Open;
{    ClientDataSet1.Fields.Add(TField.Create(ClientDataSet1));
  while not IBQuery1.Eof do
  begin
    ClientDataSet1.Insert;
    ClientDataSet1.Post;

    IBQuery1.Next;
  end;}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
    Application.Terminate
  else
  begin
    IBQuery1.Open;
    //IBQuery1.Last;
   // CopyData;
//    ClientDataSet1.Assign(IBQuery1);
//    ClientDataSet1.Open;
    IBQuery1.Close;
//  xReport1.
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if gsCustomReportBase1.AddReport then
  begin
    IBQuery1.Close;
    IBQuery1.Open;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if gsCustomReportBase1.EditReport then
  begin
    IBQuery1.Close;
    IBQuery1.Open;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if gsCustomReportBase1.DeleteReport then
  begin
    IBQuery1.Close;
    IBQuery1.Open;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  gsCustomReportBase1.Execute;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    ClientDataSet1.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    ClientDataSet1.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ClientDataSet1.Close;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  ClientDataSet1.Open;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  Temp: TReportResult;
  Str: TMemoryStream;
  Str2: TStream;
  StartTime: TDateTime;
begin
  Temp := TReportResult.Create(Self);
  try
    Temp.AddDataSet('DefaultTable');
    Temp.AddDataSet('FirstTable');
    Temp.AddDataSet('TherdTable');

    DataSetProvider1.DataSet := IBQuery1;

    IBQuery1.Close;
    IBQuery1.SQL.Text := 'SELECT subject FROM msg_message';
    Temp.DataSetByName('FirstTable').ProviderName := DataSetProvider1.Name;
    Temp.DataSetByName('FirstTable').Open;

    IBQuery1.Close;
    IBQuery1.SQL.Text := 'SELECT id, name, (SELECT COUNT(1) FROM RDB$DATABASE) FROM gd_user';
    Temp.DataSet[0].ProviderName := DataSetProvider1.Name;
    Temp.DataSet[0].Open;

    IBQuery1.Close;
    IBQuery1.SQL.Text := 'SELECT id FROM msg_message';
    Temp.DataSet[2].ProviderName := DataSetProvider1.Name;
    Temp.DataSet[2].Open;


{    StartTime := Now;
    ibtblTest.Close;
    ibtblTest.TableName := 'RP_TABLE1';
    ibtblTest.Open;
    Temp.DataSet[1].First;
    while not Temp.DataSet[1].Eof do
    begin
      ibtblTest.AppendRecord([Temp.DataSet[1].Fields[0].AsString]);

      Temp.DataSet[1].Next;
    end;
    ibtblTest.Close;
    //IBTransaction1.Commit;

    ibtblTest.TableName := 'RP_TABLE2';
    ibtblTest.Open;
    Temp.DataSet[2].First;
    while not Temp.DataSet[2].Eof do
    begin
      ibtblTest.AppendRecord([Temp.DataSet[2].Fields[0].AsInteger]);

      Temp.DataSet[2].Next;
    end;
    ibtblTest.Close;
    //IBTransaction1.Commit;

    ibtblTest.TableName := 'RP_TABLE3';
    ibtblTest.Open;
    Temp.DataSet[0].First;
    while not Temp.DataSet[0].Eof do
    begin
      ibtblTest.AppendRecord([Temp.DataSet[0].Fields[0].AsInteger,
       Temp.DataSet[0].Fields[1].AsString, Temp.DataSet[0].Fields[2].AsInteger]);

      Temp.DataSet[0].Next;
    end;
    ibtblTest.Close;
    //IBTransaction1.Commit;
    ShowMessage(DateTimeToStr(Now - StartTime));
    }
    IBDatabase2.Connected := True;
    StartTime := Now;
    ibtblReport.Open;
    ibtblReport.Insert;
    ibtblReport.Fields[0].AsInteger := 1;
    ibtblReport.Fields[1].AsString := '1';
    Str2 := ibtblReport.CreateBlobStream(ibtblReport.Fields[2], bmWrite);
    Temp.SaveToStream(Str2);
    ibtblReport.Post;
    ShowMessage(DateTimeToStr(Now - StartTime));{}

    {DataSetProvider1.DataSet := ClientDataSet1;

    Temp.DataSet[2].Fields.Add(TField.Create(Temp.DataSet[2]));
    Temp.DataSet[2].Fields.Add(TField.Create(Temp.DataSet[2]));
    Temp.DataSet[2].CreateDataSet;
    Temp.DataSet[2].AppendRecord([1, '1']);
    Temp.DataSet[2].AppendRecord([2, '2']);
    Temp.DataSet[2].AppendRecord([3, '3']);
    {ShowMessage('0');
    Temp.DataSet[2].ProviderName := DataSetProvider1.Name;
    Temp.DataSet[2].Open;}

    Str := TMemoryStream.Create;
    try
      Temp.SaveToStream(Str);
      Str.Position := 0;
      Temp.LoadFromStream(Str);
      dsClient.DataSet := Temp.DataSet[0];
      ShowMessage('1');
      dsClient.DataSet := Temp.DataSet[1];
      ShowMessage('2');
      dsClient.DataSet := Temp.DataSet[2];
      ShowMessage('3');
    finally
      Str.Free;
    end;
//    Temp.SaveToFile('555.cds');
  finally
    Temp.Free;
  end;
end;

procedure TForm1.boScriptControl1CreateObject(Sender: TObject;
  Handler: TScriptObjectHandler);
begin
 // Handler.AddObjectProvider(TReportProvider.Create(IBLogin.Database, IBLogin.Database.DefaultTransaction));
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  StartTime: TTime;
  Temp: TReportResult;
  Str: TStream;
begin
  StartTime := Now;
  IBQuery2.Close;
  IBQuery2.SQL.Text := 'SELECT * FROM rp_table1';
  IBQuery2.Open;
  IBQuery2.Last;
  IBQuery2.Close;
  IBQuery2.SQL.Text := 'SELECT * FROM rp_table2';
  IBQuery2.Open;
  IBQuery2.Last;
  IBQuery2.Close;
  IBQuery2.SQL.Text := 'SELECT * FROM rp_table3';
  IBQuery2.Open;
  IBQuery2.Last;
  IBQuery2.Close;
  ShowMessage(TimeToStr(Now - StartTime));
  StartTime := Now;
  ibtblReport.Open;
  Str := ibtblReport.CreateBlobStream(ibtblReport.Fields[2], bmRead);
  Temp := TReportResult.Create(Self);
  try
    Temp.LoadFromStream(Str);
  finally
    Temp.Free;
  end;
  ibtblReport.Close;
  ShowMessage(TimeToStr(Now - StartTime));
end;

end.
