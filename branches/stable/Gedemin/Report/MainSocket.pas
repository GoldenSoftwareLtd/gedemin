unit MainSocket;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, StdCtrls, ComCtrls, Db, IBCustomDataSet, IBQuery, IBDatabase,
  rp_BaseReport_unit, DBClient;

type
  TForm1 = class(TForm)
    ClientSocket1: TClientSocket;
    ServerSocket1: TServerSocket;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    IBQuery1: TIBQuery;
    PageControl1: TPageControl;
    Button1: TButton;
    Button4: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormDestroy(Sender: TObject);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocket1ClientWrite(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    FReportResult: TReportResult;
    FTempStream: TMemoryStream;
    Str: TStream;

    procedure CreateDataSetList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClientSocket1.Host := Edit1.Text;
  ClientSocket1.Open;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ClientSocket1.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FReportResult := TReportResult.Create(Self);
  FTempStream := TMemoryStream.Create;
  ServerSocket1.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if ClientSocket1.Active then
    ClientSocket1.Close;
  FTempStream.Clear;
  ClientSocket1.Host := Edit1.Text;
  ClientSocket1.Open;
end;

procedure TForm1.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
  Buf: Pointer;
  RealSize: Integer;
begin
  GetMem(Buf, 9000);
  try
    RealSize := ClientSocket1.Socket.ReceiveLength;
    RealSize := ClientSocket1.Socket.ReceiveBuf(Buf^, RealSize);
    FTempStream.WriteBuffer(Buf^, RealSize);
  finally
    FreeMem(Buf);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FReportResult.Free;
  FTempStream.Free;
end;

procedure TForm1.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  FReportResult.Clear;
  FTempStream.Position := 0;
  FReportResult.LoadFromStream(FTempStream);
  CreateDataSetList;
end;

procedure TForm1.CreateDataSetList;
var
  I: Integer;
begin
  for I := 0 to FReportResult.Count - 1 do
  begin
    with TTabSheet.Create(PageControl1) do
    begin
      Parent := PageControl1;
    end;
  end;
end;

procedure TForm1.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
//
end;

procedure TForm1.ServerSocket1ClientWrite(Sender: TObject;
  Socket: TCustomWinSocket);
const
  BufferSize = 8192;
var
  Buf: Pointer;
  RealSize: Integer;
begin
  if Str.Position >= Str.Size then
  begin
    ServerSocket1.Socket.Connections[0].Close;
    Exit;
  end;

  GetMem(Buf, BufferSize);
  try
    RealSize := Str.Read(Buf^, BufferSize);
    ServerSocket1.Socket.Connections[0].SendBuf(Buf^, RealSize);
  finally
    FreeMem(Buf);
  end;
end;

procedure TForm1.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  IBQuery1.Open;
  Str := IBQuery1.CreateBlobStream(IBQuery1.FieldByName('resultblock'), bmRead);
end;

procedure TForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Str.Free;
  IBQuery1.Close;
end;

end.

