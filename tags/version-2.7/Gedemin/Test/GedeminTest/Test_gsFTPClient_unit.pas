
unit Test_gsFTPClient_unit;

interface

uses
  Classes, SysUtils, TestFrameWork, gsFTPClient;

type
  TgsFTPClientTest = class(TTestCase)
  private
    FTP: TgsFTPClient;
    FFirstDir, FSecondDir: String;
    FTestData: TMemoryStream;

    procedure TestConnectDisconnect;
    procedure TestCreateDeleteDir;
    procedure TestPutGetFile;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure Test;
  end;

implementation

uses
  Forms;

const
  ServerName = 'meat.by';
  UserName = 'test@meat.by';
  UserPassword = 'test';
  TestDataSize = 1024 * 1024 div 4;  // Size = TestDataSize * SizeOf(Integer)

procedure TgsFTPClientTest.SetUp;
var
  I: Integer;
begin
  inherited;
  FTP := TgsFTPClient.Create;
  FTP.ServerName := ServerName;
  FTP.UserName := UserName;
  FTP.Password := UserPassword;

  FFirstDir := '/Test_' + FormatDateTime('yyyymmddhhnnss', Now);
  FSecondDir := FFirstDir + '/Test_2_' + FormatDateTime('yyyymmddhhnnss', Now);

  FTestData := TMemoryStream.Create;
  for I := 0 to TestDataSize - 1 do
    FTestData.WriteBuffer(I, SizeOf(I));
end;

procedure TgsFTPClientTest.TearDown;
begin
  FTP.Free;
  FTestData.Free;
  inherited;
end;

procedure TgsFTPClientTest.Test;
begin
  TestConnectDisconnect;
  TestCreateDeleteDir;
  TestPutGetFile;
end;

procedure TgsFTPClientTest.TestConnectDisconnect;
begin
  Check(FTP.Connected = False);
  Check(FTP.Connect);
  Check(FTP.Connected);
  FTP.Close;
  Check(FTP.Connected = False);
end;

procedure TgsFTPClientTest.TestCreateDeleteDir;
begin
  Check(FTP.Connect);
  Check(FTP.CreateDir(FFirstDir));
  Check(FTP.CreateDir(FSecondDir));
  Check(FTP.DeleteDir(FSecondDir));
  Check(FTP.DeleteDir(FFirstDir));
  FTP.Close;
end;

procedure TgsFTPClientTest.TestPutGetFile;
var
  LocalFile: String;
begin
  LocalFile := ExtractFilePath(Application.EXEName) + 'test_ftp.dat';
  DeleteFile(LocalFile);

  FTestData.SaveToFile(LocalFile);
  try
    Check(FTP.Connect);
    Check(FTP.CreateDir(FFirstDir));
    Check(FTP.CreateDir(FSecondDir));

    Check(FTP.PutFile(LocalFile, 'file.dat', FSecondDir, True));
    Check(FTP.RenameFile('file.dat', 'file.2', FSecondDir));
    Check(DeleteFile(LocalFile));
    Check(FTP.GetFile('file.2', LocalFile, FSecondDir, True));
    Check(FileExists(LocalFile));
    Check(DeleteFile(LocalFile));
    Check(FTP.DeleteFile('file.2', FSecondDir));
    Check(FTP.DeleteDir(FSecondDir));
    Check(FTP.DeleteDir(FFirstDir));
    FTP.Close;
  finally
    DeleteFile(LocalFile);
  end;
end;

initialization
  RegisterTest('Internals/FTP', TgsFTPClientTest.Suite);
end.

