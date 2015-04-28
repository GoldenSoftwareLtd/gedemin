unit rpl_Replicator_unit;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, IBReplicator_TLB, StdVcl, rpl_BaseTypes_unit,
  SysUtils;

type
  TIBReplicator_ = class(TAutoObject, IIBReplicator)
  protected
    procedure Connect(const ServerName, FileName, Protocol, UserName, Password,
      CharSet, Role, Additinal: WideString); safecall;
    procedure ImportData(const Stream: IStream; SaveErrorToManualLog: WordBool); safecall;
    procedure ExportData(const Stream: IStream; CorDBKey: Integer); safecall;
  end;

implementation

uses ComServ, AxCtrls, rpl_ReplicationServer_unit;

procedure TIBReplicator_.Connect(const ServerName, FileName, Protocol,
  UserName, Password, CharSet, Role, Additinal: WideString);
var
  s: string;
begin
  ReplDataBase.LoginPrompt := False;
  ReplDataBase.ServerName := ServerName;
  ReplDataBase.FileName := FileName;
  ReplDataBase.Protocol := Protocol;
  ReplDataBase.Params.Clear;
  S := Trim(username);
  ReplDataBase.Params.Add('user_name=' + S);
  S := Trim(Password);
  ReplDataBase.Params.Add('password=' + S);
  S := Trim(CharSet);
  ReplDataBase.Params.Add('lc_ctype=' + S);

  if Length(Trim(Role)) > 0 then
    ReplDataBase.Params.Add('sql_role_name=' + Trim(Role));
  if Length(Trim(Additinal)) > 0 then
    ReplDataBase.Params.Add(Trim(Additinal));
  RepldataBase.DatabaseName := GetDataBaseName(ServerName, FileName, Protocol);

  ReplDataBase.Connected := True;
end;


procedure TIBReplicator_.ExportData(const Stream: IStream;
  CorDBKey: Integer);
var
  S: TOleStream;
begin
  S := TOleStream.Create(Stream);
  try
    ReplicationServer.ExportData(S, CorDBKey);
  finally
    S.Free;
  end;
end;

procedure TIBReplicator_.ImportData(const Stream: IStream;
  SaveErrorToManualLog: WordBool);
var
  S: TOleStream;
begin
  S := TOleStream.Create(Stream);
  try
    ReplicationServer.ImportData(S, SaveErrorToManualLog);
  finally
    S.Free;
  end;
end;


initialization
  TAutoObjectFactory.Create(ComServer, TIBReplicator_, Class_IBReplicator_,
    ciMultiInstance, tmApartment);
end.
