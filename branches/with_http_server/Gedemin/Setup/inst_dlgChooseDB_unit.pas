unit inst_dlgChooseDB_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CheckLst;

type
  TdlgChooseDB = class(TForm)
    clbBases: TCheckListBox;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;                  
  private
    FDBIni: String;

    procedure ReadExistingBases(SL: TStrings);
    procedure ReadNewBases(SL: TStrings);
    function ReadValue(AnSection, AnKeyName, AnDefault: String): String;
  public
    function InstallDatabase(SL: TStrings; AnDatabase, AnDBIni: String): Boolean;
    function UpgradeDatabase(SL: TStrings; AnDatabase, AnDBIni: String): Boolean;
  end;

var
  dlgChooseDB: TdlgChooseDB;

implementation

uses
  Registry, inst_const, gsGedeminInstall, gsSysUtils;

{$R *.DFM}

{ TForm1 }

function TdlgChooseDB.InstallDatabase(SL: TStrings; AnDatabase, AnDBIni: String): Boolean;
var
  I, J: Integer;
  SL2: TStrings;
  Flag: Boolean;
begin
  FDBIni := AnDBIni;

  Caption := 'Выберите дополнительные базы данных для установки';
  Result := True;
  ReadExistingBases(SL);

  SL2 := TStringList.Create;
  try
    ReadNewBases(SL2);

    Flag := False;
    for I := 0 to SL.Count - 1 do
    begin
      Flag := CompareText(AnDatabase, SL[I]) = 0;
      if Flag then
        Break;
    end;

    if not Flag then
      SL.Add(AnsiUpperCase(AnDatabase) + '=Основная база');

    for J := SL2.Count - 1 downto 0 do
      for I := SL.Count - 1 downto 0 do
        if (CompareText(ChangeFileExt(ExtractFileName(SL2.Names[J]), ''), ChangeFileExt(ExtractFileName(SL.Names[I]), '')) = 0) or
           not FileExists(ExtractFilePath(FDBIni) + SL2.Names[J]) then
        begin
          SL2.Delete(J);
          Break;
        end;

    clbBases.Items.Clear;
    for J := 0 to SL2.Count - 1 do
      clbBases.Items.Add(SL2.Values[SL2.Names[J]]);

    if SL2.Count > 0 then
      if MessageBox(Handle, 'Вы хотите установить дополнительные базы данных?',
       'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
        Result := ShowModal = mrOk;

    SL.Clear;
    if Result then
      for I := 0 to clbBases.Items.Count - 1 do
        if clbBases.Checked[I] then
          SL.Add(SL2.Names[I] + '=' + SL2.Values[SL2.Names[I]]);
  finally
    SL2.Free;
  end;
end;

procedure TdlgChooseDB.ReadExistingBases(SL: TStrings);
var
  Reg: TRegistry;
  I: Integer;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cAddDatabaseRegPath, True) then
    begin
      Reg.GetValueNames(SL);
      for I := SL.Count - 1 downto 0 do
      begin
        SL[I] := AnsiUpperCase(GetLocalDatabase(SL[I]));
        if not FileExists(SL[I]) then
          SL.Delete(I);
      end;

      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TdlgChooseDB.ReadNewBases(SL: TStrings);
var
  S: String;
  J: Integer;
  TempSL: TStrings;
begin
  SL.Clear;
  S := ReadValue(cDatabaseSection, '', '');

  // Если ничего не считало, то ничего не меняем.
  if S <> '' then
  begin
    for J := 1 to Length(S) do
      if S[J] = #0 then
        S[J] := #13;
    TempSL := TStringList.Create;
    try
      TempSL.Text := S;

      for J := 0 to TempSL.Count - 1 do
      begin
        S := ReadValue(cDatabaseSection, TempSL[J], '');
        SL.Add(TempSL[J] + '=' + S);
      end;
    finally
      TempSL.Free;
    end;
  end
end;

function TdlgChooseDB.ReadValue(AnSection, AnKeyName,
  AnDefault: String): String;
var
  Size: Integer;
  KName: PChar;
  F: File;
  OldFileMode: Integer;
begin
  Result := AnDefault;

  try
    AssignFile(F, FDBIni);
    OldFileMode := FileMode;
    FileMode := 0;
    Reset(F, 1);
    try
      Size := FileSize(F);
    finally
      CloseFile(F);
      FileMode := OldFileMode;
    end;
  except
    Size := 1000;
  end;

  if Size <= Length(AnDefault) then
    Size := Length(AnDefault) + 1;
  SetLength(Result, Size);
  if Length(AnKeyName) = 0 then
    KName := nil
  else
    KName := @AnKeyName[1];
  if Size = 0 then Exit;
  Size := GetPrivateProfileString(PChar(AnSection), {PChar(AnKeyName), }KName,
    PChar(AnDefault), @Result[1], Size, PChar(FDBIni));
  SetLength(Result, Size);
end;

function TdlgChooseDB.UpgradeDatabase(SL: TStrings; AnDatabase, AnDBIni: String): Boolean;
var
  I: Integer;
  Flag: Boolean;
begin
  FDBIni := AnDBIni;

  Result := True;

  ReadExistingBases(SL);

  Flag := False;
  for I := 0 to SL.Count - 1 do
  begin
    Flag := CompareText(GetLocalDatabase(AnDatabase), SL[I]) = 0;
    if Flag then
      Break;
  end;

  if not Flag then
    SL.Add(AnsiUpperCase(AnDatabase));

  clbBases.Items.Clear;

  for I := SL.Count - 1 downto 0 do
    if (CompareText(GetServerDatabase(SL[I]), GetComputerNameString) = 0) or
     (GetServerDatabase(SL[I]) = '') then
      SL[I] := GetLocalDatabase(SL[I])
    else
      SL.Delete(I);

  clbBases.Items.Assign(SL);

  if SL.Count > 0 then
    Result := ShowModal = mrOk;
  if Result then
  begin
    SL.Clear;
    for I := 0 to clbBases.Items.Count - 1 do
      if clbBases.Checked[I] then
        SL.Add(clbBases.Items[I]);
  end;
end;


end.
