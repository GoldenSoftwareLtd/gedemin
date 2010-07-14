unit gd_dlgAbout_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabaseInfo, ComCtrls, Mask, DBCtrls;

type
  Tgd_dlgAbout = class(TForm)
    IBDatabaseInfo1: TIBDatabaseInfo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    gbGDS32: TGroupBox;
    Label2: TLabel;
    lGDS32FileName: TLabel;
    lGDS32Version: TLabel;
    lGDS32FileDescription: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnOk: TButton;
    GroupBox2: TGroupBox;
    lServerVersion: TLabel;
    lDBSiteName: TLabel;
    lODSVersion: TLabel;
    lPageSize: TLabel;
    lForcedWrites: TLabel;
    lNumBuffers: TLabel;
    lCurrentMemory: TLabel;
    GroupBox3: TGroupBox;
    lGedeminFile: TLabel;
    lGedeminPath: TLabel;
    lGedeminVersion: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Memo1: TMemo;
    TabSheet3: TTabSheet;
    GroupBox4: TGroupBox;
    lISC_USER: TLabel;
    lISC_PASSWORD: TLabel;
    lISC_PATH: TLabel;
    lTemp: TLabel;
    lTmp: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    mPath: TMemo;
    eDBFileName: TEdit;
    tsLogin: TTabSheet;
    GroupBox6: TGroupBox;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    lUser: TLabel;
    lContact: TLabel;
    lIBUser: TLabel;
    lUserKey: TLabel;
    Label33: TLabel;
    lContactKey: TLabel;
    btnHelp: TButton;
    GroupBox7: TGroupBox;
    Label29: TLabel;
    lSession: TLabel;
    Label31: TLabel;
    lDateAndTime: TLabel;
    tsDB: TTabSheet;
    GroupBox5: TGroupBox;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    lDBComment: TLabel;
    lDBRelease: TLabel;
    lDBID: TLabel;
    lDBVersion: TLabel;
    GroupBox8: TGroupBox;
    mDBParams: TMemo;
    btnMSInfo: TButton;
    Label34: TEdit;
    Label30: TLabel;
    gbTrace: TGroupBox;
    mTrace: TMemo;
    GroupBox9: TGroupBox;
    mSQLMonitor: TMemo;
    tsTempFiles: TTabSheet;
    lvTempFiles: TListView;
    lblTempPath: TLabel;
    edTempPath: TEdit;
    mTempFiles: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnMSInfoClick(Sender: TObject);
  private
    procedure FillTempFiles;
  public
    { Public declarations }
  end;

var
  gd_dlgAbout: Tgd_dlgAbout;

implementation

{$R *.DFM}

uses
  IB, IBIntf, jclFileUtils, gd_security, ShellAPI, TypInfo,
  IBSQLMonitor_Gedemin;

procedure Tgd_dlgAbout.FormCreate(Sender: TObject);
var
  Ch: array[0..2048] of Char;
  T: TTraceFlag;
  S: String;
begin
  GetModuleFileName(GetIBLibraryHandle, Ch, SizeOf(Ch));
  gbGDS32.Caption := ' ' + ExtractFileName(Ch) + ' ';
  lGDS32FileName.Caption := Ch;
  if VersionResourceAvailable(Ch) then
    with TjclFileVersionInfo.Create(Ch) do
    try
      lGDS32Version.Caption := BinFileVersion;
      lGDS32FileDescription.Caption := FileDescription;
    finally
      Free;
    end;

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  with TIBDatabaseInfo.Create(nil) do
  try
    Database := IBLogin.Database;
    lServerVersion.Caption := Version;
    eDBFileName.Text := DBFileName;
    if IBLogin.ServerName > '' then
      lDBSiteName.Caption := IBLogin.ServerName + ' (' + DBSiteName + ')'
    else
      lDBSiteName.Caption := '<встроенный сервер>';
    lODSVersion.Caption := IntToStr(ODSMajorVersion) + '.' +
      IntToStr(ODSMinorVersion);
    lPageSize.Caption := IntToStr(PageSize);
    if Boolean(ForcedWrites) then
      lForcedWrites.Caption := 'включена'
    else
      lForcedWrites.Caption := 'отключена';
    lNumBuffers.Caption := IntToStr(NumBuffers);
    lCurrentMemory.Caption := FormatFloat('#,##0', CurrentMemory) + ' байт';
    tsDB.TabVisible := True;
  finally
    Free;
  end else
  begin
    lServerVersion.Caption := '';
    eDBFileName.Text := '';
    lDBSiteName.Caption := '';
    lODSVersion.Caption := '';
    lPageSize.Caption := '';
    lForcedWrites.Caption := '';
    lNumBuffers.Caption := '';
    lCurrentMemory.Caption := '';

    tsDB.TabVisible := False;
  end;

  lGedeminFile.Caption := ExtractFileName(Application.EXEName);
  lGedeminPath.Caption := ExtractFilePath(Application.EXEName);
  if VersionResourceAvailable(Application.EXEName) then
    with TjclFileVersionInfo.Create(Application.EXEName) do
    try
      lGedeminVersion.Caption := BinFileVersion;
    finally
      Free;
    end;

  if GetEnvironmentVariable('ISC_USER', Ch, SizeOf(Ch)) > 0 then
    lISC_USER.Caption := Ch
  else
    lISC_USER.Caption := '<Переменная не определена>';

  if GetEnvironmentVariable('ISC_PASSWORD', Ch, SizeOf(Ch)) > 0 then
    lISC_PASSWORD.Caption := Ch
  else
    lISC_PASSWORD.Caption := '<Переменная не определена>';

  if GetEnvironmentVariable('ISC_PATH', Ch, SizeOf(Ch)) > 0 then
    lISC_PATH.Caption := Ch
  else
    lISC_PATH.Caption := '<Переменная не определена>';

  if GetEnvironmentVariable('TEMP', Ch, SizeOf(Ch)) > 0 then
    lTemp.Caption := Ch
  else
    lTemp.Caption := '<Переменная не определена>';

  if GetEnvironmentVariable('TMP', Ch, SizeOf(Ch)) > 0 then
    lTmp.Caption := Ch
  else
    lTmp.Caption := '<Переменная не определена>';

  if GetEnvironmentVariable('PATH', Ch, SizeOf(Ch)) > 0 then
    mPath.Lines.Text := Ch
  else
    mPath.Lines.Text := '<Переменная не определена>';

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  with IBLogin do
  begin
    tsLogin.TabVisible := True;
    lDBVersion.Caption := DBVersion;
    lDBID.Caption := IntToStr(DBID);
    lDBRelease.Caption := FormatDateTime('dd.mm.yyyy', DBReleaseDate);
    lDBComment.Caption := DBVersionComment;

    lUser.Caption := UserName;
    lContact.Caption := ContactName;
    lIBUser.Caption := IBName;
    lUserKey.Caption := IntToStr(UserKey);
    lContactKey.Caption := IntToStr(ContactKey);
    lSession.Caption := IntToStr(SessionKey);
    lDateAndTime.Caption := DateTimeToStr(StartTime);

    mDBParams.Lines.Text := Database.Params.Text;
    if mDBParams.Lines.IndexOfName('USER_NAME') > -1 then
      mDBParams.Lines.Delete(mDBParams.Lines.IndexOfName('USER_NAME'));
    if mDBParams.Lines.IndexOfName('PASSWORD') > -1 then
      mDBParams.Lines.Delete(mDBParams.Lines.IndexOfName('PASSWORD'));

    for T := tfQPrepare to tfMisc do
    begin
      S := GetEnumName(TypeInfo(TTraceFlag), Integer(T));

      if T in Database.TraceFlags then
        mTrace.Lines.Text := mTrace.Lines.Text + '  ' + S;

      if T in MonitorHook.TraceFlags then
        mSQLMonitor.Lines.Text := mSQLMonitor.Lines.Text + '  ' + S;
    end;
  end else
    tsLogin.TabVisible := False;

  Label34.Text := CmdLine;

  FillTempFiles;
end;

procedure Tgd_dlgAbout.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure Tgd_dlgAbout.btnMSInfoClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'msinfo32.exe', nil, nil, SW_SHOW);
end;

procedure Tgd_dlgAbout.FillTempFiles;

var
  TempPath: array[0..1023] of Char;

  procedure AddFile(const AFileName: String);
  var
    FullName: String;
    F: THandle;
    Sz: DWORD;
  begin
    FullName := String(TempPath) + '\' + AFileName;
    if FileExists(FullName) then
    begin
      with lvTempFiles.Items.Add do
      begin
        Caption := AFileName;

        F := FileOpen(FullName, fmOpenRead);
        if F = INVALID_HANDLE_VALUE then
          SubItems.Add('файл заблокирован')
        else
          try
            Sz := GetFileSize(F, nil);
            if Sz <> INVALID_FILE_SIZE then
              SubItems.Add(FormatFloat('#,##0', Sz));
          finally
            FileClose(F);
          end;
      end;
    end;
  end;

begin
  lvTempFiles.Items.Clear;

  if Assigned(IBLogin) and (IBLogin.DBID > -1) and (IBLogin.UserKey > -1)
    and (GetTempPath(SizeOf(TempPath), TempPath) > 0) then
  begin
    AddFile('g' + IntToStr(IBLogin.DBID) + '.atr');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfh');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfd');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.gsc');
    AddFile('g' + IntToStr(IBLogin.DBID) + '_' + IntToStr(IBLogin.UserKey) + '.usc');
  end;

  edTempPath.Text := TempPath;
end;

end.
