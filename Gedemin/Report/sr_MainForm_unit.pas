// ShlTanya, 27.02.2019

unit sr_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Db, IBDatabase, rp_vwReport_unit, StdCtrls,
  OleServer, Word97, axctrls, Provider, DBClient, dmReport_unit,
  IBCustomDataSet, IBTable, Grids, DBGrids, gd_security_body;

type
  TMainReportServer = class(TForm)
    boLogin1: TboLogin;
    gsIBDatabase1: TIBDatabase;
    WordApplication1: TWordApplication;
    Button1: TButton;
    Button2: TButton;
    WordDocument1: TWordDocument;
    Button3: TButton;
    Button4: TButton;
    DataSetProvider1: TDataSetProvider;
    ClientDataSet1: TClientDataSet;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    IBTable1: TIBTable;
    Button10: TButton;
    Edit1: TEdit;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    IBTransaction1: TIBTransaction;
    IBDataSet1: TIBDataSet;
    Button11: TButton;
    Button12: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure WordDocument1Close(Sender: TObject);
    procedure WordDocument1Open(Sender: TObject);
    procedure WordDocument1New(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  private
    FvwReport: TvwReport;
    FdmReport: TdmReport;
  public
    { Public declarations }
  end;

var
  MainReportServer: TMainReportServer;

implementation

uses gd_security_OperationConst, rp_dlgEditFunction_unit, gd_SetDatabase,
     rp_BaseReport_unit;

{$R *.DFM}

procedure TMainReportServer.FormCreate(Sender: TObject);
begin
  FvwReport := TvwReport.Create(Self);
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
  begin
    Application.Terminate;
  end else
  begin
    gsIBDatabase1.Connected := False;
    FdmReport := TdmReport.Create(Self);
    FdmReport.SetDatabase(gsIBDatabase1);
  end;
end;

procedure TMainReportServer.FormDestroy(Sender: TObject);
begin
  if Assigned(FdmReport) then
    FreeAndNil(FdmReport);
  FvwReport.Free;
  WordApplication1.Disconnect;
end;

procedure TMainReportServer.Button1Click(Sender: TObject);
var
  Template, NewTemplate: OleVariant;
begin
  WordApplication1.Connect;
  WordApplication1.Visible := True;
  Template := EmptyParam;
  NewTemplate := False;
  WordDocument1.ConnectTo(WordApplication1.Documents.Add(Template, NewTemplate));
end;

procedure TMainReportServer.WordDocument1Close(Sender: TObject);
var
  Template, NewTemplate: OleVariant;
  Str: TOLEStream;
begin
{  Str := TOLEStream.Create(nil);
  try
    Template := Str;
    WordDocument1.SaveAs(Template);
  finally
    Str.Free;
  end;}
//
end;

procedure TMainReportServer.WordDocument1Open(Sender: TObject);
begin
//
end;

procedure TMainReportServer.WordDocument1New(Sender: TObject);
begin
//                 flt_sqlfilter
end;

procedure TMainReportServer.Button3Click(Sender: TObject);
begin
//  FvwReport.Execute;
  FdmReport.ClientReport1.Execute;
end;

procedure TMainReportServer.Button4Click(Sender: TObject);
var
  F: TdlgEditFunction;
begin
  F := TdlgEditFunction.Create(Self);
  try
    SetDatabase(F, gsIBDatabase1);
    F.AddFunction('REPORTMAIN');
  finally
    F.Free;
  end;
end;

procedure TMainReportServer.Button5Click(Sender: TObject);
var
  FVar, SVar, Temp: Variant;
  VarStr: TVarStream;
  Str: TMemoryStream;
begin
  Str := TMemoryStream.Create;
  try
    VarStr := TVarStream.Create(Str);         
    try
      FVar := VarArrayCreate([0, 2], varVariant);
      FVar[0] := 12;
      Temp := VarArrayCreate([0, 2], varVariant);
      FVar[2] := '123324435';
      Temp[0] := 123;
      Temp[1] := 'www';
      Temp[2] := StrToDate('12.12.00');
      FVar[1] := Temp;
      VarStr.Write(FVar);
      FVar := 0;
      VarStr.Position := 0;
      VarStr.Read(SVar);
    finally
      VarStr.Free;
    end;
  finally
    Str.Free;
  end;
end;

procedure TMainReportServer.Button6Click(Sender: TObject);
var
  FVar, SVar: Variant;
  Bl: Boolean;
begin
//  FVar := 'asdasd';
//  SVar := 'asdasd';
  FVar := VarArrayCreate([0, 2], varVariant);
  SVar := VarArrayCreate([0, 1], varVariant);
  FVar[0] := 12;
  FVar[1] := '123';
  FVar[2] := 'qwrqewr';
  SVar[0] := 12;
  SVar[1] := '123';
//  SVar[2] := 'qwrqewr';
  Bl := CompareParams(FVar, SVar);
//  Bl := FVar = SVar;
end;

procedure TMainReportServer.Button7Click(Sender: TObject);
var
  Param: Variant;
begin
  Param := VarArrayCreate([0, 0], varInteger);
  Param[0] := 10;
  FdmReport.ServerReport1.ExecuteReportAndSaveResult(FdmReport.ClientReport1.ReportList.Reports[0].MainFunction, Param);
end;

procedure TMainReportServer.Button8Click(Sender: TObject);
var
  ReportList: TReportList;
begin
  ReportList := TReportList.Create;
  try
    ReportList.Database := gsIBDatabase1;
    ReportList.Transaction := FdmReport.IBTransaction1;
    FdmReport.ServerReport1.PrepareReportList(ReportList);
  finally
    ReportList.Free;
  end;
end;

procedure TMainReportServer.Button9Click(Sender: TObject);
begin
  FdmReport.ServerReport1.RebuildReports;
end;

procedure TMainReportServer.Button10Click(Sender: TObject);
begin
  IBTable1.Filtered := True;
  IBTable1.Filter := Edit1.Text;
  IBTable1.Open;
end;

procedure TMainReportServer.Button11Click(Sender: TObject);
begin
  FdmReport.ServerReport1.ServerOptions;
end;

procedure TMainReportServer.Button12Click(Sender: TObject);
var
  FStr: TFileStream;
  S: String;
begin
  if OpenDialog1.Execute then
  begin
    ClientDataSet1.LoadFromFile(OpenDialog1.FileName);
    ClientDataSet1.IndexFieldNames := 'REPORTKEY;CRCPARAM;PARAMORDER';
    ClientDataSet1.First;
    FStr := TFileStream.Create('test.txt', fmCreate);
    try
      while not ClientDataSet1.Eof do
      begin
        S := ClientDataSet1.FieldByName('reportkey').AsString + ' ' +
         ClientDataSet1.FieldByName('crcparam').AsString + ' ' + 
         ClientDataSet1.FieldByName('paramorder').AsString + #13#10;
        FStr.Write(S[1], Length(S));
        ClientDataSet1.Next;
      end;
    finally
      FStr.Free;
    end;
  end;
end;

end.
