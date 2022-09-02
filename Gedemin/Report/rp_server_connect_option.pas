// ShlTanya, 27.02.2019

unit rp_server_connect_option;

interface

procedure GetReportServerConnectParam(var AnUserName, AnPassword, AnDatabase: String);
procedure SetReportServerConnectParam(const AnUserName, AnPassword, AnDatabase: String);

implementation

uses
  Registry, gd_directories_const, gd_Cipher_unit, gd_SetDatabase, inst_const,
  SysUtils;

procedure GetReportServerConnectParam(var AnUserName, AnPassword, AnDatabase: String);
var
  Reg: TRegistry;
  Size: Integer;
  TempStr: String;
begin
  AnUserName := '';
  AnPassword := '';
  AnDatabase := '';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;
    if Reg.OpenKeyReadOnly(cReportRegPath) then
    begin
      if Reg.ValueExists(cReportServerUser) then
      begin
        Size := Reg.GetDataSize(cReportServerUser);
        SetLength(TempStr, Size);
        Reg.ReadBinaryData(cReportServerUser, TempStr[1], Size);
        UnCipherBuffer(TDnByteArray(TempStr), TDnByteArray(AnUserName));
      end;

      if Reg.ValueExists(cReportServerPass) then
      begin
        Size := Reg.GetDataSize(cReportServerPass);
        SetLength(TempStr, Size);
        Reg.ReadBinaryData(cReportServerPass, TempStr[1], Size);
        UnCipherBuffer(TDnByteArray(TempStr), TDnByteArray(AnPassword));
      end;
      Reg.CloseKey;
    end;
    if Reg.OpenKey(cGedeminRoot, True) then
    begin
      if Reg.ValueExists(ServerNameValue) then
        AnDatabase := Reg.ReadString(ServerNameValue);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SetReportServerConnectParam(const AnUserName, AnPassword, AnDatabase: String);
var
  Reg: TRegistry;
  TempStr: String;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;
    if Reg.OpenKey(cReportRegPath, True) then
    begin
      CipherBuffer(TDnByteArray(AnUserName), TDnByteArray(TempStr));
      Reg.WriteBinaryData(cReportServerUser, TempStr[1], Length(TempStr));
      CipherBuffer(TDnByteArray(AnPassword), TDnByteArray(TempStr));
      Reg.WriteBinaryData(cReportServerPass, TempStr[1], Length(TempStr));
      Reg.CloseKey;
    end;
    if (Trim(AnDatabase) <> '') and Reg.OpenKey(cGedeminRoot, True) then
    begin
      Reg.WriteString(ServerNameValue, AnDatabase);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
