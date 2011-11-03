
unit gd_dlgAbout_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabaseInfo, ComCtrls, Mask, DBCtrls,Registry,WinSock,
  SynEdit, SynEditHighlighter, SynHighlighterIni;

type
  Tgd_dlgAbout = class(TForm)
    pc: TPageControl;
    TabSheet1: TTabSheet;
    btnOk: TButton;
    mCredits: TMemo;
    btnHelp: TButton;
    lblTitle: TLabel;
    TabSheet4: TTabSheet;
    btnCopy: TButton;
    SynIniSyn: TSynIniSyn;
    mSysData: TSynEdit;
    btnMSInfo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnMSInfoClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);

  private
    procedure FillTempFiles;
    procedure AddSection(const S: String);
    procedure AddSpaces(const Name, Value: String);
    procedure AddLibrary(h: HMODULE; const AName: String);
    procedure AddEnv(const AName: String);
    procedure AddBoolean(const AName: String; const AValue: Boolean);
    procedure AddComLibrary(const AClsID: String; const AName: String);

  public
    procedure FillSysData;
  end;

var
  gd_dlgAbout: Tgd_dlgAbout;

implementation

{$R *.DFM}

uses
  IB, IBIntf, jclFileUtils, gd_security, ShellAPI, TypInfo,
  IBSQLMonitor_Gedemin, Clipbrd, MidConst, gdcBaseInterface,
  gd_directories_const,
  {$IFDEF FR4}frxClass,{$ENDIF} FR_Class, ZLIB, jclBase,
  {$IFDEF EXCMAGIC_GEDEMIN}ExcMagic,{$ENDIF} TB2Version;

function GetDiskSizeAvail(TheDrive: PChar; var Total: Integer; var Free: Integer): Boolean;
var
  lpSectorsPerCluster, lpBytesPerSector, lpNumberOfFreeClusters, lpTotalNumberOfClusters: DWORD;
begin
  Result := GetDiskFreeSpace(TheDrive, lpSectorsPerCluster, lpBytesPerSector,
    lpNumberOfFreeClusters, lpTotalNumberOfClusters);

  if Result then
  begin
    Total := MulDiv(lpTotalNumberOfClusters, lpSectorsPerCluster * lpBytesPerSector, 1024 * 1024);
    Free := MulDiv(lpNumberOfFreeClusters, lpSectorsPerCluster * lpBytesPerSector, 1024 * 1024);
  end;
end;

function HostToIP(sHost: String): String;
var
  pcAddr: PChar;
  HostEnt: PHostEnt;
  wsData: TWSAData;
  P: Integer;
begin
  Result := '127.0.0.1';

  P := Pos('/', sHost);
  if P > 0 then
    SetLength(sHost, P - 1);

  if sHost = '' then
    exit;

  WSAStartup($0101, wsData);
  try
    HostEnt := GetHostByName(PChar(sHost));
    if Assigned(HostEnt) and Assigned(HostEnt^.H_Addr_List)
      and Assigned(HostEnt^.H_Addr_List^) then
    begin
      pcAddr := HostEnt^.H_Addr_List^;
      Result := Format('%d.%d.%d.%d', [Byte(pcAddr[0]), Byte(pcAddr[1]),
        Byte(pcAddr[2]), Byte(pcAddr[3])]);
    end;
  finally
    WSACleanup;
  end;
end;

function GetRAM: string;
var
  Info: TMemoryStatus;
begin
  Info.dwLength := SizeOf(TMemoryStatus);
  GlobalMemoryStatus(Info);
  Result := FormatFloat('#,##0', Info.dwTotalPhys div 1024 div 1024) + ' Мб';
end;

function GetOS: String;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
      and Reg.ValueExists('ProductName') then
    begin
      Result := Reg.ReadString('ProductName');
      if Reg.ValueExists('CSDVersion') then
        Result := Result + ', ' + Reg.ReadString('CSDVersion');
    end else
      Result := 'неизвестно';
  finally
    Reg.Free;
  end;
end;

procedure Tgd_dlgAbout.FormCreate(Sender: TObject);
begin
  FillSysData;
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
    FullName, S: String;
    F: THandle;
    Sz: DWORD;
  begin
    FullName := String(TempPath) + '\' + AFileName;
    if FileExists(FullName) then
    begin
      S := 'файл заблокирован';
      F := FileOpen(FullName, fmOpenRead);
      if F <> INVALID_HANDLE_VALUE then
      try
        Sz := GetFileSize(F, nil);
        if Sz <> INVALID_FILE_SIZE then
          S := FormatFloat('#,##0', Sz) + ' байт';
      finally
        FileClose(F);
      end;

      AddSpaces(AFileName, S);
    end;
  end;

begin
  if Assigned(IBLogin) and (IBLogin.DBID > -1) and (IBLogin.UserKey > -1)
    and (GetTempPath(SizeOf(TempPath), TempPath) > 0) then
  begin
    AddSection('Временные файлы');
    AddSpaces('Расположение', TempPath);

    AddFile('g' + IntToStr(IBLogin.DBID) + '.atr');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfh');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.sfd');
    AddFile('g' + IntToStr(IBLogin.DBID) + '.gsc');
    AddFile('g' + IntToStr(IBLogin.DBID) + '_' + IntToStr(IBLogin.UserKey) + '.usc');

    mSysData.Lines.Add('');
    mSysData.Lines.Add('; Временные файлы используются для кэширования информации');
    mSysData.Lines.Add('; из базы данных и ускорения запуска программы.');
    mSysData.Lines.Add('; Для удаления временных файлов вручную: закройте Гедымин,');
    mSysData.Lines.Add('; перейдите в указанную папку, удалите файлы по списку.');
    mSysData.Lines.Add('; Запретить создание временных файлов можно с помощью');
    mSysData.Lines.Add('; параметра командной строки /nc.');
  end;
end;

procedure Tgd_dlgAbout.btnCopyClick(Sender: TObject);
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl: Integer;
  FNext: Boolean;
begin
  FNext := False;

  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN, LANG_RUSSIAN: ;
  else
    ActivateKeyBoardLayout(HKL_NEXT, 0);

    GetKeyboardLayoutName(Ch);
    KL := StrToInt('$' + StrPas(Ch));

    case (KL and $3ff) of
      LANG_BELARUSIAN, LANG_RUSSIAN: FNext := True;
    else
      ActivateKeyBoardLayout(HKL_PREV, 0);
    end;
  end;

  Clipboard.AsText := mSysData.Text;

  if FNext then
    ActivateKeyBoardLayout(HKL_PREV, 0);
end;

procedure Tgd_dlgAbout.FillSysData;
var
  T: TTraceFlag;
  S: String;
  I, TotalB, TotalF: Integer;
  WSAData: TWSAData;
  CompName: array[0..$FF] of Char;
  DriveLetter: Char;
begin
  mSysData.ClearAll;

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  begin
    with TIBDatabaseInfo.Create(nil) do
    try
      Database := IBLogin.Database;

      AddSection('Cервер');
      AddSpaces('Версия сервера',  Version);
      if IBLogin.ServerName > '' then
      begin
        AddSpaces('Имя компьютера/порт',  IBLogin.ServerName);
        AddSpaces('IP сервера',  HostToIP(IBLogin.ServerName));
      end;
      AddBoolean('Встроенный сервер',  IBLogin.ServerName = '');
      AddSpaces('Имя файла БД',  DBFileName);
      AddSpaces('ODS версия',  IntToStr(ODSMajorVersion) + '.' + IntToStr(ODSMinorVersion));
      AddSpaces('Размер страницы',  IntToStr(PageSize));
      AddBoolean('Принудительная зап.', Boolean(ForcedWrites));
      AddSpaces('Размер буфера', IntToStr(NumBuffers));
      AddSpaces('Используемая память', FormatFloat('#,##0', CurrentMemory div 1024) + ' Кб');
    finally
      Free;
    end;
  end;

  WSAStartup($0101, WSAData);
  try
    GetHostName(CompName, SizeOf(CompName));
  finally
    WSACleanup;
  end;

  AddSection('Гедымин');
  AddSpaces('Название компютера', CompName);
  AddSpaces('IP адрес', HostToIP(CompName));
  AddSpaces('ОЗУ', GetRAM);
  AddSpaces('Версия ОС', GetOS);
  AddSpaces('Имя файла', ExtractFileName(Application.EXEName));
  AddSpaces('Расположение', ExtractFilePath(Application.EXEName));
  AddSpaces('Дата файла', FormatDateTime('dd.mm.yyyy', FileDateToDateTime(FileAge(Application.EXEName))));
  if VersionResourceAvailable(Application.EXEName) then
    with TjclFileVersionInfo.Create(Application.EXEName) do
    try
      lblTitle.Caption := 'Платформа Гедымин, v. ' + ProductVersion;

      mCredits.Lines.Insert(0, '');
      mCredits.Lines.Insert(0, LegalCopyright);

      AddSpaces('Версия файла', BinFileVersion);
      AddSpaces('Описание', FileDescription);
    finally
      Free;
    end;

  S := '';
  for I := 1 to ParamCount do
    if Pos(' ', ParamStr(I)) = 0 then
      S := S + ParamStr(I) + ' '
    else
      S := S + '"' + ParamStr(I) + '"' + ' ';
  AddSpaces('Командная строка', S);

  S := '';
  {$IFDEF EXCMAGIC_GEDEMIN}S := S + 'EXCMAGIC_GEDEMIN, ';{$ENDIF}
  {$IFDEF DUNIT_TEST}S := S + 'DUNIT_TEST, ';{$ENDIF}
  {$IFDEF GEDEMIN_LOCK}S := S + 'GEDEMIN_LOCK, ';{$ENDIF}
  {$IFDEF SPLASH}S := S + 'SPLASH, ';{$ENDIF}
  {$IFDEF CATTLE}S := S + 'CATTLE, ';{$ENDIF}
  {$IFDEF SYNEDIT}S := S + 'SYNEDIT, ';{$ENDIF}
  {$IFDEF DEBUG}S := S + 'DEBUG, ';{$ENDIF}
  {$IFDEF FR4}S := S + 'FR4, ';{$ENDIF}
  {$IFDEF IBSQLCACHE}S := S + 'IBSQLCACHE, ';{$ENDIF}
  {$IFDEF TEECHARTPRO}S := S + 'TEECHARTPRO, ';{$ENDIF}
  {$IFDEF QEXPORT}S := S + 'QEXPORT, ';{$ENDIF}
  {$IFDEF CATTLE}S := S + 'CATTLE, ';{$ENDIF}
  {$IFDEF MESSAGE}S := S + 'MESSAGE, ';{$ENDIF}
  {$IFDEF CURRSELLCONTRACT}S := S + 'CURRSELLCONTRACT, ';{$ENDIF}
  {$IFDEF REALIZATION}S := S + 'REALIZATION, ';{$ENDIF}
  {$IFDEF PROTECT}S := S + 'PROTECT, ';{$ENDIF}
  {$IFDEF GEDEMIN}S := S + 'GEDEMIN, ';{$ENDIF}
  {$IFDEF LOADMODULE}S := S + 'LOADMODULE, ';{$ENDIF}
  {$IFDEF MODEM}S := S + 'MODEM, ';{$ENDIF}
  {$IFDEF GED_LOC_RUS}S := S + 'GED_LOC_RUS, ';{$ENDIF}
  {$IFDEF LOCALIZATION}S := S + 'LOCALIZATION, ';{$ENDIF}
  {$IFDEF QBUILDER}S := S + 'QBUILDER, ';{$ENDIF}
  if S > '' then
  begin
    SetLength(S, Length(S) - 2);
    AddSpaces('Символы компиляции', S);
  end;

  AddSection('Версии библиотек');
  AddSpaces('Fast Report 2', Copy(IntToStr(frCurrentVersion), 1, 1) + '.' +
    Copy(IntToStr(frCurrentVersion), 2, 255));
  {$IFDEF FR4}AddSpaces('Fast Report 4', FR_VERSION);{$ENDIF}
  AddSpaces('ZLib', ZLIB_VERSION);
  AddSpaces('JCL', IntToStr(JclVersionMajor) + '.' + IntToStr(JclVersionMinor));
  AddSpaces('Toolbar 2000', Toolbar2000Version);
  {$IFDEF EXCMAGIC_GEDEMIN}AddSpaces('Exceptional Magic', ExceptionHook.Version);{$ENDIF}

  AddLibrary(GetIBLibraryHandle, 'fbclient.dll');
  AddComLibrary(MIDAS_GUID, 'MIDAS.DLL');
  AddComLibrary(GSDBQUERY_GUID, 'GSDBQUERY.DLL');

  AddSection('Жесткие диски');
  for DriveLetter := 'C' to 'Z' do
  begin
    if (GetDriveType(PChar(DriveLetter + ':\')) = DRIVE_FIXED) and
      GetDiskSizeAvail(PChar(DriveLetter + ':\'), TotalB, TotalF) then
        AddSpaces(DriveLetter + ':',
          FormatFloat('#,##0', TotalB) + ' Мб, Свободно: ' + FormatFloat('#,##0', TotalF) + ' Мб');
  end;

  AddSection('Переменные среды');
  AddEnv('ISC_USER');
  AddEnv('ISC_PASSWORD');
  AddEnv('ISC_PATH');
  AddEnv('TEMP');
  AddEnv('TMP');
  AddEnv('PATH');

  if Assigned(IBLogin) and IBLogin.LoggedIn then
  with IBLogin do
  begin
    AddSection('База данных');
    AddSpaces('Версия файла БД', DBVersion);
    AddSpaces('ИД файла БД', IntToStr(DBID));
    AddSpaces('Дата релиза БД', FormatDateTime('dd.mm.yyyy', DBReleaseDate));
    AddSpaces('Комментарий', DBVersionComment);

    AddSpaces('ИД организации', IntToStr(CompanyKey));
    AddSpaces('Организация', CompanyName);
    AddSpaces('Холдинг', HoldingList);
    AddSpaces('Текущий ИД', IntToStr(gdcBaseManager.GetNextID));

    AddSection('Параметры подключения');
    for I := 0 to Database.Params.Count - 1 do
    begin
      if I = Database.Params.IndexOfName('USER_NAME') then
        continue;
      if I = Database.Params.IndexOfName('PASSWORD') then
        continue;
      AddSpaces(Database.Params.Names[I], Database.Params.Values[Database.Params.Names[I]]);
    end;

    AddSection('Пользователь');
    AddSpaces('Учетная запись', UserName);
    AddSpaces('Контакт', ContactName);
    AddSpaces('Пользователь ФБ', IBName);
    AddSpaces('ИД учетной записи', IntToStr(UserKey));
    AddSpaces('ИД контакта', IntToStr(ContactKey));
    AddSpaces('Сессия',  IntToStr(SessionKey));
    AddSpaces('Дата и время подкл.',  DateTimeToStr(StartTime));

    AddSection('Параметры трассировки');
    S := '';
    for T := tfQPrepare to tfMisc do
    begin
      if T in Database.TraceFlags then
        S := S + GetEnumName(TypeInfo(TTraceFlag), Integer(T)) + ', ';
    end;
    if S > '' then
      SetLength(S, Length(S) - 2);
    AddSpaces('Подключение к БД', S);

    S := '';
    for T := tfQPrepare to tfMisc do
    begin
      if T in MonitorHook.TraceFlags then
        S := S + GetEnumName(TypeInfo(TTraceFlag), Integer(T)) + ', ';
    end;
    if S > '' then
      SetLength(S, Length(S) - 2);
    AddSpaces('SQL монитор', S);
  end;

  FillTempFiles;

  mSysData.SelStart := 0;
end;

procedure Tgd_dlgAbout.AddSection(const S: String);
begin
  if mSysData.Lines.Count > 0 then
    mSysData.Lines.Add('');
  mSysData.Lines.Add('[' + S + ']');
end;

procedure Tgd_dlgAbout.AddSpaces(const Name, Value: String);
begin
  mSysData.Lines.Add(Name + StringOfChar(' ', 20 - Length(Name)) + ' = ' + Value);
end;

procedure Tgd_dlgAbout.AddLibrary(h: HMODULE; const AName: String);
var
  HasLoaded: Boolean;
  Ch: array[0..2048] of Char;
begin
  if h = 0 then
  begin
    h := SafeLoadLibrary(AName);
    HasLoaded := True;
  end else
    HasLoaded := False;

  if h > HINSTANCE_ERROR then
    try
      GetModuleFileName(h, Ch, SizeOf(Ch));

      AddSection('Библиотека ' + ExtractFileName(Ch));
      AddSpaces('Имя файла', Ch);

      if VersionResourceAvailable(Ch) then
        with TjclFileVersionInfo.Create(Ch) do
        try
          AddSpaces('Версия', BinFileVersion);
          AddSpaces('Описание', FileDescription);
        finally
          Free;
        end;
    finally
      if HasLoaded then
        FreeLibrary(h);
    end
  else begin
    AddSection('Библиотека ' + AName);
    AddSpaces('Имя файла', '<не обнаружен>');
  end;
end;

procedure Tgd_dlgAbout.AddEnv(const AName: String);
var
  Ch: array[0..2048] of Char;
begin
  if GetEnvironmentVariable(PChar(AName), Ch, SizeOf(Ch)) > 0 then
    AddSpaces(AName, Ch)
  else
    AddSpaces(AName, '<не определена>')
end;

procedure Tgd_dlgAbout.AddBoolean(const AName: String;
  const AValue: Boolean);
begin
  if AValue then
    AddSpaces(AName, 'Да')
  else
    AddSpaces(AName, 'Нет');
end;

procedure Tgd_dlgAbout.AddComLibrary(const AClsID: String; const AName: String);
var
  Reg: TRegistry;
  FN: String;
  Flag: Boolean;
begin
  Flag := False;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;

    if Reg.OpenKeyReadOnly('CLSID\' + AClsID + '\InProcServer32')
      and (Reg.GetDataType('') = rdString) and (Reg.ReadString('') > '') then
    begin
      FN := Reg.ReadString('');

      AddSection('Библиотека ' + AName);
      if FileExists(FN) then
      begin
        AddSpaces('Имя файла', FN);

        if VersionResourceAvailable(FN) then
          with TjclFileVersionInfo.Create(FN) do
          try
            AddSpaces('Версия', BinFileVersion);
            AddSpaces('Описание', FileDescription);
          finally
            Free;
          end;
      end else
        AddSpaces('Файл не найден', FN);

      Flag := True;
    end;
  finally
    Reg.Free;
  end;

  if not Flag then
    AddLibrary(0, AName);
end;

end.

