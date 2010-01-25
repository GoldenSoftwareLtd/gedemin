
unit at_dlgLoadPackages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ActnList, XPBevel, Grids, FileCtrl,
  dmImages_unit, gdcSetting, CheckLst, Registry, Menus;

type
  Tat_dlgLoadPackages = class(TForm)
    Panel1: TPanel;
    eSearchPath: TEdit;
    btnBrowse: TButton;
    mGSFInfo: TMemo;
    btnClose: TButton;
    mExistSettInfo: TMemo;
    ActionList1: TActionList;
    actSearchGSF: TAction;
    btnSearch: TButton;
    btnInstallPackage: TButton;
    actInstallPackage: TAction;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    clbPackages: TCheckListBox;
    pEmpty: TPanel;
    lInfo: TLabel;
    actShowFullPackInfo: TAction;
    actHelp: TAction;
    actSetParams: TAction;
    Panel2: TPanel;
    cbLegend: TCheckListBox;
    cbYesToAll: TCheckBox;
    pmSelect: TPopupMenu;
    miNewer: TMenuItem;
    miNotInstalled: TMenuItem;
    miInvert: TMenuItem;
    miClear: TMenuItem;
    N2: TMenuItem;
    miOnlyNewer: TMenuItem;
    miEqual: TMenuItem;
    choose1: TMenuItem;
    chbxFullPackInfo: TCheckBox;
    Label5: TLabel;
    btnHelp: TButton;
    procedure actSearchGSFExecute(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure clbPackagesClick(Sender: TObject);
    procedure actInstallPackageExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actInstallPackageUpdate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure clbPackagesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure clbPackagesClickCheck(Sender: TObject);
    procedure actShowFullPackInfoExecute(Sender: TObject);
    procedure actShowFullPackInfoUpdate(Sender: TObject);
    procedure actSetParamsExecute(Sender: TObject);
    procedure cbLegendDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure miClearClick(Sender: TObject);
    procedure miInvertClick(Sender: TObject);
    procedure miNewerClick(Sender: TObject);
    procedure miNotInstalledClick(Sender: TObject);
    procedure miOnlyNewerClick(Sender: TObject);
    procedure miEqualClick(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);

  private
    SearchPath: String;
    AllGSFList: TGSFList;
    gdcSetting: TgdcSetting;
    PackChecked: Boolean;
    function SetSearchPath(aPath: String): Boolean;
    procedure SearchGSF;
    procedure FillGridList;
    procedure CheckPackage(aVer: TSettingVersion);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  at_dlgLoadPackages: Tat_dlgLoadPackages;

implementation

{$R *.DFM}

uses
  gdcBase, gdcBaseInterface, gd_common_functions, storages, at_frmSQLProcess,
  inst_const, gd_security
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  
//  lToSearch = 'Нажмите ''Искать'' для поиска пакетов настроек';
  lEmptyRes = 'Пакеты настроек не найдены';

// +++++ Tat_dlgLoadSettings +++++

function Tat_dlgLoadPackages.SetSearchPath(aPath: String): Boolean;
begin
  if DirectoryExists(aPath) then
  begin
    SearchPath := aPath;
    Result := True
  end else
  begin
    MessageBox(HANDLE, 'Папка не существует!', 'Ошибка!', MB_OK or MB_ICONEXCLAMATION);
    Result := False;
  end;
end;

// поиск файлов настроек, получение данных о настройках
procedure Tat_dlgLoadPackages.SearchGSF;
begin
// очищаем список
  AllGSFList.Clear;

// заполняем список файлами
  AllGSFList.GetFilesForPath(SearchPath, lInfo);
end;

procedure Tat_dlgLoadPackages.CheckPackage(aVer: TSettingVersion);
var
  i: Integer;
begin 
  for i := 0 to clbPackages.Items.Count-1 do
    if clbPackages.ItemEnabled[i] and                              
       ((clbPackages.Items.Objects[i] as TGSFHeader).MaxVerInfo = aVer) and
       (clbPackages.Items.Objects[i] as TGSFHeader).FullCorrect then
      clbPackages.Checked[i] := not miNotInstalled.Checked;
end;

procedure Tat_dlgLoadPackages.FillGridList;
var
  i, ind: Integer;
begin
  clbPackages.Items.Clear;

  for i := 0 to AllGSFList.Count-1 do
  begin
    with (AllGSFList.Objects[i] as TGSFHeader) do
      if Ending = 1 then
      begin
        ind := clbPackages.Items.AddObject(Name, AllGSFList.Objects[i]);
        if not FullCorrect then
          clbPackages.ItemEnabled[ind] := False;
      end;
  end;

  if clbPackages.Items.Count > 0 then
  begin
    pEmpty.Visible := False;
    clbPackages.ItemIndex := 0;
    clbPackagesClick(clbPackages);
  end else
  begin
    lInfo.Caption := lEmptyRes;
  end;
end;

procedure Tat_dlgLoadPackages.actSearchGSFExecute(Sender: TObject);
var
  Reg: TRegistry;
begin
  if SetSearchPath(eSearchPath.Text) then
  begin
    mGSFInfo.Clear;
    mExistSettInfo.Clear;
    pEmpty.Visible := True;
    PackChecked := False;

    SearchGSF;
    lInfo.Caption := 'Проверка версий и корректности пакетов...';
    lInfo.Refresh;
    AllGSFList.LoadPackageInfo;
    FillGridList;

    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(cSettingRegPath, True) then
      begin
        Reg.WriteString(cPackageSearchPath, eSearchPath.Text);
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

  end;
end;

procedure Tat_dlgLoadPackages.btnBrowseClick(Sender: TObject);
var
  Path: String;
begin
  if SelectDirectory('Укажите папку', '', Path) then
  begin
    eSearchPath.Text := Path;
    actSearchGSFExecute(Sender);    
  end;
end;

procedure Tat_dlgLoadPackages.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
begin
  PackChecked := False;

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(cSettingRegPath) then
    begin
      eSearchPath.Text := Reg.ReadString(cPackageSearchPath);
      Reg.CloseKey;
    end else
      eSearchPath.Text := ExtractFilePath(Application.ExeName);
  finally
    Reg.Free;
  end;

// 'рабочий' gdcОбъект
  gdcSetting := TgdcSetting.Create(Self);
  gdcSetting.SubSet := 'ByID';
                    
// список заголовков всех файлов настроек
  AllGSFList := TGSFList.Create;
  AllGSFList.gdcSetts := gdcSetting;
  
end;


procedure Tat_dlgLoadPackages.clbPackagesClick(Sender: TObject);
var
  Ver: String;
begin
  if (clbPackages.ItemIndex > -1) and Assigned(clbPackages.Items.Objects[clbPackages.ItemIndex]) then
  begin
    mGSFInfo.Clear;
    mExistSettInfo.Clear;

    with clbPackages.Items.Objects[clbPackages.ItemIndex] as TGSFHeader do
    begin
      mGSFInfo.Lines.Add(Comment);
      if not FullCorrect then
      begin                                                            
        mGSFInfo.Lines.Add('------- НЕ ПОДХОДИТ ДЛЯ УСТАНОВКИ -------');
            
        if not CorrectPack then
        begin
          mGSFInfo.Lines.Add('Не найдена промежуточная настройка или пакет, от которого зависит данный.' + 
            ' (RUID = ' + ErrMessage + ')');
        end;

        if avNotApprEXEVersion in ApprVersion then
          mGSFInfo.Lines.Add('Версия EXE-файла не подходит');
        if avNotApprDBVersion in ApprVersion then
          mGSFInfo.Lines.Add('Версия БД не подходит');

        if MaxVerInfo > OwnerList.VerInfoToInstall then
          if (OwnerList.VerInfoToInstall = svNewer) and
             (VerInfo = svEqual) then
            mGSFInfo.Lines.Add('Версии обнаруженного и установленного пакетов совпадают.')
          else
            mGSFInfo.Lines.Add('Версия данного пакета настроек более старая.');

        mGSFInfo.Lines.Add('');
      end;


      case VerInfo of
        svNotInstalled: Ver := ' - пакет не установлен';
        svNewer: Ver := ' - новая версия';
        svEqual: Ver := ' - версии совпадают';
        svOlder: Ver := ' - старая версия';
//        svIncorrect: mGSFInfo.Lines.Add('Некорректна');
        svIndefinite: Ver := ' - INDEFINITE';
      else
        Ver := '';
      end;
      mGSFInfo.Lines.Add('Версия: ' + IntToStr(Version) + Ver);
      mGSFInfo.Lines.Add('Изменен: ' + DateToStr(Date));

// выводим доп. информацию, если надо
      if chbxFullPackInfo.Checked then
      begin
        mGSFInfo.Lines.Add('');
        mGSFInfo.Lines.Add('Требуемые версии: ');
        if Length(MinExeVersion) > 0 then
          mGSFInfo.Lines.Add(' EXE-файла: ' + MinExeVersion)
        else
          mGSFInfo.Lines.Add(' EXE-файла: ограничений нет.');
        if Length(MinDBVersion) > 0 then
          mGSFInfo.Lines.Add(' Базы данных: ' + MinDBVersion)
        else
          mGSFInfo.Lines.Add(' Базы данных: ограничений нет.');
        mGSFInfo.Lines.Add('');
        mGSFInfo.Lines.Add('РУИД: ' + RUIDToStr(RUID));
        mGSFInfo.Lines.Add('');
        mGSFInfo.Lines.Add('Путь: ' + FilePath);
        mGSFInfo.Lines.Add('Файл: ' + FileName);
      end;

      if VerInfo in [svNewer, svEqual, svOlder] then
      begin
        mExistSettInfo.Lines.Add('Версия: ' + IntToStr(RealSetting.Version));
        mExistSettInfo.Lines.Add('Изменен: ' + DateToStr(RealSetting.Date));
      end else     // if Installed
        mExistSettInfo.Lines.Add('Пакет не установлен.');

    end; // with
  end;   // Assigned
end;


procedure Tat_dlgLoadPackages.actInstallPackageExecute(Sender: TObject);
var
  i: Integer;
  isOK: Boolean;
begin
  AllGSFList.isYesToAll := cbYesToAll.Checked;

// формируем список отмеченных пакетов
  AllGSFList.CheckList.Clear;
  for i := 0 to clbPackages.Items.Count-1 do
  begin
    if clbPackages.Checked[i] then
    begin
      AllGSFList.CheckList.Add(IntToStr(AllGSFList.IndexOfObject(clbPackages.Items.Objects[i])));
    end;
  end;

// устанавливаем пакеты
  isOK := AllGSFList.InstallPackages;

// активируем настройки
  AllGSFList.ActivatePackages;
  if isOK then
  begin
    ModalResult := mrOk;
  end;
end;

procedure Tat_dlgLoadPackages.FormDestroy(Sender: TObject);
begin
  gdcSetting.Free;
  AllGSFList.Free;
end;

procedure Tat_dlgLoadPackages.actInstallPackageUpdate(Sender: TObject);
begin
  actInstallPackage.Enabled := PackChecked
    and Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;


procedure Tat_dlgLoadPackages.FormClose(Sender: TObject;
  var Action: TCloseAction);
{var
  ShiftDown: Boolean;} 
begin
{  ShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  if (Action = caHide) and ShiftDown then
    Action := caFree;}
end;

procedure Tat_dlgLoadPackages.clbPackagesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  R: TRect;
begin
  if Assigned(clbPackages.Items.Objects[Index]) then
  begin
    R := Rect;                                               
//    case (clbPackages.Items.Objects[Index] as TGSFHeader).VerInfo of
    case (clbPackages.Items.Objects[Index] as TGSFHeader).MaxVerInfo of
      svNotInstalled:                                          
        begin
          clbPackages.Canvas.Font.Style := clbPackages.Canvas.Font.Style + [fsBold];
        end;
      svNewer:
        begin
          clbPackages.Canvas.Font.Color := clBlue;
          clbPackages.Canvas.Font.Style := clbPackages.Canvas.Font.Style + [fsBold];
        end;
      svOlder:
        begin
          clbPackages.Canvas.Font.Color := clMaroon;
        end;
    end;
    clbPackages.Canvas.FillRect(Rect);
    clbPackages.Canvas.TextOut(R.left, R.top, clbPackages.Items[index]);
  end;
end;

procedure Tat_dlgLoadPackages.clbPackagesClickCheck(Sender: TObject);
var
  curRUID: String;
  i: Integer;
begin
// проверяем на наличие РУИДа в Check-списке
  if clbPackages.State[clbPackages.ItemIndex] = cbChecked then
  begin
    PackChecked := True;
    curRUID := RUIDToStr((clbPackages.Items.Objects[clbPackages.ItemIndex] as TGSFHeader).RUID);
    for i := 0 to clbPackages.Items.Count - 1 do
    begin
      with clbPackages.Items.Objects[i] as TGSFHeader do
      if (curRUID = RUIDToStr(RUID)) and
         (i <> clbPackages.ItemIndex) then
      begin
        clbPackages.Checked[i] := False;
      end;
    end;
  end else
// проверяем, отмечен ли хотя бы один пакет 
  begin
    PackChecked := False;
    for i := 0 to clbPackages.Items.Count-1 do
    begin 
      if clbPackages.Checked[i] then
      begin
        PackChecked := True; 
        Break;
      end;
    end
  end;
end;

procedure Tat_dlgLoadPackages.actShowFullPackInfoExecute(Sender: TObject);
begin
  if chbxFullPackInfo.Checked then
  begin
    //actShowFullPackInfo.Caption := 'Кратко';
    mGSFInfo.Height := 217;
  end else
  begin
    //actShowFullPackInfo.Caption := 'Дополнительно';
    mGSFInfo.Height := 121;
  end;

  clbPackagesClick(clbPackages);
  clbPackages.SetFocus;
end;

procedure Tat_dlgLoadPackages.actShowFullPackInfoUpdate(Sender: TObject);
begin
  actShowFullPackInfo.Enabled := (clbPackages.Items.Count > 0);
end;

procedure Tat_dlgLoadPackages.actSetParamsExecute(Sender: TObject);
begin
  // params
end;

procedure Tat_dlgLoadPackages.cbLegendDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  R: TRect;
begin
  R := Rect; 
  case Index of
    0:
      begin
        cbLegend.Canvas.Font.Style := cbLegend.Canvas.Font.Style + [fsBold];
      end;
    1:
      begin
        cbLegend.Canvas.Font.Color := clBlue;
        cbLegend.Canvas.Font.Style := clbPackages.Canvas.Font.Style + [fsBold];
      end;                                  
    3: 
      begin
        cbLegend.Canvas.Font.Color := clMaroon;
      end;

  end; 
  cbLegend.Canvas.FillRect(Rect);
  cbLegend.Canvas.TextOut(R.left, R.top, cbLegend.Items[index]);
end;       
                        
procedure Tat_dlgLoadPackages.miClearClick(Sender: TObject);
var
  i: Integer;
begin                    
  for i := 0 to clbPackages.Items.Count-1 do
    clbPackages.Checked[i] := False;
    
  PackChecked := False;
end;

procedure Tat_dlgLoadPackages.miInvertClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to clbPackages.Items.Count-1 do
    if clbPackages.ItemEnabled[i] then
      clbPackages.Checked[i] := not clbPackages.Checked[i];

end;

procedure Tat_dlgLoadPackages.miNewerClick(Sender: TObject);
begin
  CheckPackage(svNewer);
end;

procedure Tat_dlgLoadPackages.miNotInstalledClick(Sender: TObject);
begin
  CheckPackage(svNotInstalled);
end;

procedure Tat_dlgLoadPackages.miEqualClick(Sender: TObject);
begin
  CheckPackage(svEqual);
end;

procedure Tat_dlgLoadPackages.miOnlyNewerClick(Sender: TObject);
begin
  if miOnlyNewer.Checked then
    AllGSFList.VerInfoToInstall := svNewer
  else       
    AllGSFList.VerInfoToInstall := svEqual;
  miOnlyNewer.Checked := not miOnlyNewer.Checked;
  miEqual.Enabled := miOnlyNewer.Checked;
  
  PackChecked := False;
  FillGridList;
end;

procedure Tat_dlgLoadPackages.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

constructor Tat_dlgLoadPackages.Create(AnOwner: TComponent);
begin
  inherited;
  at_dlgLoadPackages := Self;
end;

destructor Tat_dlgLoadPackages.Destroy;
begin
  if at_dlgLoadPackages = Self then
    at_dlgLoadPackages := nil;
  inherited;
end;

end.
