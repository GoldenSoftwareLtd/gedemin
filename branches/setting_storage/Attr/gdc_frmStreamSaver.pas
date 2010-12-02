unit gdc_frmStreamSaver;

interface

uses
  Windows,              Messages,              SysUtils,
  Classes,              Graphics,              Controls,
  Forms,                Dialogs,               StdCtrls,
  ExtCtrls,             ComCtrls,              Grids,
  DBGrids,              gsDBGrid,              gsIBGrid,
  Db,                   IBCustomDataSet,       ActnList,
  gdcBase,              dmDatabase_unit,       at_frmIncrDatabaseList,
  gdcStreamSaver,       gd_createable_form,    gsProcessTimeCalculator,
  gsStreamHelper,       gdcSetting;

type
  TgsStreamSaverProcessType =
    (ptUnknown, ptSave, ptLoad, ptSaveSetting, ptLoadSetting,
     ptActivateSetting, ptDeactivateSetting, ptReactivateSetting, ptMakeSetting, ptInstallPackage);

  Tgdc_frmStreamSaver = class(TForm)
    pnlBottom: TPanel;
    pnlMain: TPanel;
    pnlTop: TPanel;
    btnClose: TButton;
    btnNext: TButton;
    btnPrev: TButton;
    PageControl: TPageControl;
    tbsSave: TTabSheet;
    tbsLoad: TTabSheet;
    tbsProcess: TTabSheet;
    lblFirst: TLabel;
    lblSecond: TLabel;
    alMain: TActionList;
    actNext: TAction;
    actPrev: TAction;
    lblResult: TLabel;
    lblWasErrorMsg: TLabel;
    btnShowLog: TButton;
    lblErrorMsg: TLabel;
    lblProgressMain: TLabel;
    pbMain: TProgressBar;
    lblProcessText: TLabel;
    tbsSetting: TTabSheet;
    lblSettingHint01: TLabel;
    lblSettingHint02: TLabel;
    cbMakeSetting: TCheckBox;
    lblSettingQuestion: TLabel;
    cbSettingFormat: TComboBox;
    lblSettingFormat: TLabel;
    imgStatus: TImage;
    pnlDatabases: TPanel;
    lblFileName: TLabel;
    eFileName: TEdit;
    lblLoadingSourceBase: TLabel;
    eLoadingSourceBase: TEdit;
    lblLoadingTargetBase: TLabel;
    eLoadingTargetBase: TEdit;
    lblIncrementedHelp: TLabel;
    lblFileType: TLabel;
    cbStreamFormat: TComboBox;
    lblIncremented: TLabel;
    cbIncremented: TCheckBox;
    lblLoadingFileTypeLabel: TLabel;
    lblLoadingFileType: TLabel;
    lblLoadingIncremented: TLabel;
    lblLoadingIncrementedLabel: TLabel;
    actShowLog: TAction;
    tmrInstallPackage: TTimer;
    procedure btnCloseClick(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbsSaveShow(Sender: TObject);
    procedure tbsLoadShow(Sender: TObject);
    procedure tbsProcessShow(Sender: TObject);
    procedure tbsSettingShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbStreamFormatChange(Sender: TObject);
    procedure cbSettingFormatChange(Sender: TObject);
    procedure cbMakeSettingClick(Sender: TObject);
    procedure cbIncrementedClick(Sender: TObject);
    procedure actShowLogExecute(Sender: TObject);
    procedure actShowLogUpdate(Sender: TObject);
    procedure tmrInstallPackageTimer(Sender: TObject);
  private
    FgdcObject: TgdcBase;
    FgdcDetailObject: TgdcBase;
    FBL: TBookmarkList;
    FWithDetail, FOnlyCurrent: Boolean;
    FProcessType: TgsStreamSaverProcessType;
    FInProcess: Boolean;
    FWasProcessError: Boolean;
    FFileName: String;
    FframeDatabases: TfrmIncrDatabaseList;
    FProcessTimeCalculator: TgsProcessTimeCalculator;
    FRecordMessageCount: Integer;

    FStreamFormat: TgsStreamType;
    FStreamSettingFormat: TgsStreamType;
    FIncrementSaving: Boolean;
    FStreamLogType: TgsStreamLoggingType;
    FReplaceRecordBehaviuor: TReplaceRecordBehaviour;

    procedure SetupDialog;
    procedure LoadDialogSettings;
    procedure SaveDialogSettings;

    procedure Save;
    procedure Load;
    procedure SaveSetting;
    procedure LoadSetting;
    procedure ActivateSetting;
    procedure InstallPackage;
    procedure DeactivateSetting;
    procedure ReactivateSetting;
    procedure MakeSetting;
    procedure DoAfterException(ErrorMsg: String);
  public
    AllGSFList: TGSFList;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm;

    procedure SetParams(gdcObject: TgdcBase; gdcDetail: TgdcBase = nil;
      const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True);

    procedure SetupProgress(const Max: Integer; ALabelString: String = 'Выполнение...');
    procedure Step;
    procedure Done;
    procedure ActivateFinishButtons(const IsActivate: Boolean = True);
    procedure AddMistake(AMistake: String = '');
    procedure AddWarning(AWarningMessage: String = '');
    procedure SetProcessCaptionText(AText: String);
    procedure SetProcessText(AText: String; const Necessary: Boolean = False);

    function ShowSaveForm: Integer;
    function ShowLoadForm: Integer;

    function ShowSaveSettingForm: Integer;
    function ShowLoadSettingForm: Integer;
    function ShowMakeSettingForm: Integer;
    function ShowActivateSettingForm: Integer;
    function ShowInstallPackageForm: Integer;
    function ShowDeactivateSettingForm: Integer;
    function ShowReactivateSettingForm: Integer;

    property gdcObject: TgdcBase read FgdcObject;
    property FileName: String read FFilename write FFilename;
  end;
  
var
  frmStreamSaver: Tgdc_frmStreamSaver;

implementation

uses
  gdcBaseInterface,           Storages,
  at_frmSQLProcess,           IBSQL,                     gs_Exception,
  gd_security,                at_classes,                zlib,
  gd_dlgStreamSaverOptions,   dmImages_unit;

const
  // Через какое кол-во переданных сообщений пропускать, не выводя на экран
  cShowMessageInterval = 5;

{$R *.DFM}

{ Tgdc_frmStreamSaver }

class function Tgdc_frmStreamSaver.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if Assigned(frmStreamSaver) then
    FreeAndNil(frmStreamSaver);

  if not Assigned(frmStreamSaver) then
    frmStreamSaver := Tgdc_frmStreamSaver.Create(Application);

  Result := frmStreamSaver;
end;

constructor Tgdc_frmStreamSaver.Create(AOwner: TComponent);
var
  I: Integer;
begin
  Assert(frmStreamSaver = nil, 'Может быть только одна форма frmStreamSaver');

  inherited;

  frmStreamSaver := Self;
  FgdcObject := nil;
  FgdcDetailObject := nil;
  FBL := nil;
  FInProcess := False;
  FWasProcessError := False;
  FProcessType := ptSave;
  FRecordMessageCount := cShowMessageInterval;     
  PageControl.ActivePage := nil;
  FProcessTimeCalculator := TgsProcessTimeCalculator.Create;
  FStreamLogType := slAll;

  // Заполнение выпадающих списков
  for I := 0 to STREAM_FORMAT_COUNT - 1 do
  begin
    cbStreamFormat.Items.Add(STREAM_FORMATS[I]);
    cbSettingFormat.Items.Add(STREAM_FORMATS[I]);
  end;

  // список заголовков всех файлов настроек
  AllGSFList := TGSFList.Create;
end;

destructor Tgdc_frmStreamSaver.Destroy;
begin
  FreeAndNil(AllGSFList);

  FgdcObject := nil;
  FBL := nil;
  FgdcDetailObject := nil;
  FProcessTimeCalculator.Free;

  if Assigned(FframeDatabases) then
  begin
    if Assigned(GlobalStorage) and (FframeDatabases.ibgrDatabases.SettingsModified) then
      GlobalStorage.SaveComponent(FframeDatabases.ibgrDatabases, FframeDatabases.ibgrDatabases.SaveToStream);
    FframeDatabases.Free;
  end;

  if Assigned(frmSQLProcess) then
    frmSQLProcess.Silent := False;

  if frmStreamSaver = Self then
    frmStreamSaver := nil;

  inherited;
end;

procedure Tgdc_frmStreamSaver.FormShow(Sender: TObject);
begin
  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);
  frmSQLProcess.Silent := True;

  LoadDialogSettings;
  SetupDialog;

  case FProcessType of
    ptSave:
      PageControl.ActivePage := tbsSave;
    ptLoad:
      PageControl.ActivePage := tbsLoad;
    ptSaveSetting, ptLoadSetting, ptActivateSetting, ptDeactivateSetting, ptReactivateSetting, ptMakeSetting:
      PageControl.ActivePage := tbsSetting;
    ptInstallPackage:
    begin
      PageControl.ActivePage := tbsProcess;
      //Self.BringToFront;
      // По таймеру запустится через секунду установка пакетов
      tmrInstallPackage.Enabled := True;
    end;
  end;  
end;

procedure Tgdc_frmStreamSaver.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  PageControl.ActivePage := nil;

  SaveDialogSettings;

  if Assigned(frmSQLProcess) then
  begin
    frmSQLProcess.Close;
    frmSQLProcess.Silent := False;
  end;

  Action := caFree;
end;

procedure Tgdc_frmStreamSaver.tbsSaveShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := true;
  btnNext.Caption := 'Сохранить';

  lblFirst.Caption := '1. Настройки сохранения';
  lblFirst.Font.Style := [fsBold];

  lblSecond.Caption := '2. Сохранение';
  lblSecond.Font.Style := [];
end;

procedure Tgdc_frmStreamSaver.tbsLoadShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := true;
  btnNext.Caption := 'Загрузить';

  lblFirst.Caption := '1. Файл данных';
  lblFirst.Font.Style := [fsBold];

  lblSecond.Caption := '2. Загрузка';
  lblSecond.Font.Style := [];
end;

procedure Tgdc_frmStreamSaver.tbsProcessShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := False;
  ActivateFinishButtons(False);

  lblFirst.Font.Style := [];
  lblSecond.Font.Style := [fsBold];
end;

procedure Tgdc_frmStreamSaver.tbsSettingShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := True;
  lblFirst.Caption := '1. Настройка';
  lblFirst.Font.Style := [fsBold];
  lblSecond.Font.Style := [];

  case FProcessType of

    ptSaveSetting:
    begin
      lblSettingQuestion.Caption := 'Сохранить настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      cbMakeSetting.Visible := (FStreamSettingFormat = sttBinaryOld);
      lblSettingFormat.Visible := True;
      cbSettingFormat.Visible := True;
      btnNext.Caption := 'Сохранить';
      lblSecond.Caption := '2. Сохранение';
    end;

    ptLoadSetting:
    begin
      lblSettingQuestion.Caption := 'Загрузить настройку?';
      lblSettingQuestion.Visible := True;
      lblSettingHint01.Visible := True;
      lblSettingHint02.Visible := True;
      btnNext.Caption := 'Загрузить';
      lblSecond.Caption := '2. Загрузка';
    end;

    ptActivateSetting:
    begin
      lblSettingQuestion.Caption := 'Активировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Активировать';
      lblSecond.Caption := '2. Активация';
    end;

    ptDeactivateSetting:
    begin
      cbMakeSetting.Visible := True;
      cbMakeSetting.Caption := 'Обновить данные настройки перед ее деактивацией?';
      lblSettingFormat.Visible := True;
      cbSettingFormat.Visible := True;
      lblSettingQuestion.Caption := 'Деактивировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Деактивировать';
      lblSecond.Caption := '2. Деактивация';
    end;

    ptReactivateSetting:
    begin
      lblSettingHint01.Caption := 'Переактивация настройки на действующей базе данных может привести к потере данных!'#13#10 +
        'Настоятельно рекомендуется произвести архивное копирование базы данных.';
      lblSettingHint01.Visible := True;
      lblSettingQuestion.Caption := 'Переактивировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Переактивировать';
      lblSecond.Caption := '2. Переактивация';
    end;

    ptMakeSetting:
    begin
      lblSettingQuestion.Caption := 'Сформировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      lblSettingFormat.Visible := True;
      cbSettingFormat.Visible := True;
      btnNext.Caption := 'Сформировать';
      lblSecond.Caption := '2. Формирование';
    end;
  end;
end;

procedure Tgdc_frmStreamSaver.SetParams(gdcObject: TgdcBase; gdcDetail: TgdcBase = nil;
  const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True);
var
  GridOptions: TDBGridOptions;
begin
  if gdcObject <> nil then
  begin
    if gdcObject is TgdcSetting then
      AllGSFList.gdcSetts := TgdcSetting(gdcObject);

    FgdcObject := gdcObject;
    FBL := BL;
    FgdcDetailObject := gdcDetail;
    FWithDetail := Assigned(gdcDetail);
    FOnlyCurrent := OnlyCurrent;

    if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName('RPL_DATABASE'))
       and not Assigned(FframeDatabases) then
    begin
      // фрейм со списком баз данных
      FframeDatabases := TfrmIncrDatabaseList.Create(Self);
      FframeDatabases.Parent := pnlDatabases;
      FframeDatabases.Align := alClient;
      FframeDatabases.gdcDatabases.Database := gdcBaseManager.Database;
      FframeDatabases.gdcDatabases.ReadTransaction := gdcBaseManager.ReadTransaction;
      FframeDatabases.gdcDatabases.ExtraConditions.Add('(isourbase = 0) or (isourbase is null)');
      FframeDatabases.gdcDatabases.Open;
      // запретим редактировать список баз "не-администратору"
      if not IBLogin.IsUserAdmin then
      begin
        FframeDatabases.TBToolbar1.Visible := False;
        GridOptions := FframeDatabases.ibgrDatabases.Options;
        Exclude(GridOptions, dgEditing);
        FframeDatabases.ibgrDatabases.Options := GridOptions;
      end;
      if Assigned(GlobalStorage) then
        GlobalStorage.LoadComponent(FframeDatabases.ibgrDatabases, FframeDatabases.ibgrDatabases.LoadFromStream);
    end;
  end;
end;

procedure Tgdc_frmStreamSaver.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure Tgdc_frmStreamSaver.actNextExecute(Sender: TObject);
begin
  case FProcessType of

    ptSave:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.Save;
      btnPrev.Enabled := true;
      Self.ActivateFinishButtons(True);
    end;

    ptLoad:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.Load;
      Self.ActivateFinishButtons(True);
    end;

    ptSaveSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.SaveSetting;
      btnPrev.Enabled := true;
      Self.ActivateFinishButtons(True);
    end;

    ptLoadSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.LoadSetting;
      Self.ActivateFinishButtons(True);
    end;

    ptActivateSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.ActivateSetting;
    end;

    ptDeactivateSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.DeactivateSetting;
    end;

    ptReactivateSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.ReactivateSetting;
    end;

    ptMakeSetting:
    begin
      PageControl.ActivePage := tbsProcess;
      Self.MakeSetting;
      Self.ActivateFinishButtons(True);
    end;
  end;
end;

procedure Tgdc_frmStreamSaver.actPrevExecute(Sender: TObject);
begin
  case FProcessType of
    ptSave:
      PageControl.ActivePage := tbsSave;

    ptLoad:
      PageControl.ActivePage := tbsLoad;

  else
    if PageControl.ActivePage = tbsProcess then
      PageControl.ActivePage := tbsSetting;
  end;
end;
                                         
procedure Tgdc_frmStreamSaver.Save;
{var
  IncrementDatabaseKey: Integer;}
begin
  try
    // Дадим пользователю выбрать файл для сохранения информации
    if FStreamFormat = sttXML then
      FFileName := gdcObject.QuerySaveFileName('', xmlExtension, xmlDialogFilter)
    else
      FFileName := gdcObject.QuerySaveFileName('', datExtension, datDialogFilter);
    // Если файл выбран
    if FFileName <> '' then
    begin
      {if FIncrementSaving and FframeDatabases.gdcDatabases.Active then
        IncrementDatabaseKey := FframeDatabases.gdcDatabases.FieldByName('ID').AsInteger
      else
        IncrementDatabaseKey := -1;}
      gdcObject.SaveToFile(FFileName, FgdcDetailObject, FBL, FOnlyCurrent, FStreamFormat{, IncrementDatabaseKey});
    end
    else
      // Если файл не выбран, то перейдем на предыдущий шаг
      PageControl.ActivePage := tbsSave;  
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.Load;
begin
  try
    gdcObject.LoadFromFile(FFileName);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.LoadSetting;
begin
  try
    gdcObject.LoadFromFile(Self.Filename);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.SaveSetting;
begin
  try
    if cbMakeSetting.Checked then
      (gdcObject as TgdcSetting).SaveSettingToBlob(FStreamSettingFormat);

    gdcObject.SaveToFile(Self.Filename, FgdcDetailObject, FBL, True, FStreamSettingFormat);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.ActivateSetting;
begin
  try
    (gdcObject as TgdcSetting).ActivateSetting(nil, FBL);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.DeactivateSetting;
begin
  try
    if cbMakeSetting.Checked then
      (gdcObject as TgdcSetting).SaveSettingToBlob(FStreamSettingFormat);

    (gdcObject as TgdcSetting).DeactivateSetting;
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.MakeSetting;
begin
  try
    (gdcObject as TgdcSetting).SaveSettingToBlob(FStreamSettingFormat);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.ReactivateSetting;
begin
  try
    (gdcObject as TgdcSetting).ReactivateSetting(FBL);
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.InstallPackage;
begin
  try
    // устанавливаем пакеты
    AllGSFList.InstallPackages;
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

function Tgdc_frmStreamSaver.ShowLoadForm: Integer;
var
  stRecord: TgsStreamRecord;
  SourceBaseKey, TargetBaseKey: TID;
  I: Integer;
  S: TStream;
  RPLDatabase: TgdRPLDatabase;
  StreamType: TgsStreamType;
begin
  Result := -1;
  // Пользователь должен выбрать файл для загрузки
  FFileName := FgdcObject.QueryLoadFileName(FFileName, datExtension, datxmlDialogFilter);
  // Если пользователь выбрал файл
  if FFileName <> '' then
  begin
    FProcessType := ptLoad;
    eLoadingSourceBase.Visible := false;
    lblLoadingSourceBase.Visible := false;
    eLoadingTargetBase.Visible := false;
    lblLoadingTargetBase.Visible := false;
    lblLoadingIncremented.Caption := 'Нет';

    S := TFileStream.Create(FFileName, fmOpenRead);
    try
      StreamType := GetStreamType(S);
      lblLoadingFileType.Caption := STREAM_FORMATS[Integer(StreamType) - 1];
      if StreamType <> sttBinaryOld then
      begin
        if StreamType = sttXML then
        begin
          TargetBaseKey := -1;
          SourceBaseKey := -1;
        end
        else
        begin
          S.ReadBuffer(I, SizeOf(I));
          if I <> cst_StreamLabel then
            raise Exception.Create(GetGsException(Self, 'ShowLoadForm: Invalid stream format'));
          S.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
          if stRecord.StreamVersion >= 1 then
            S.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));

          // список баз данных из таблицы RPL_DATABASE
          {S.ReadBuffer(I, SizeOf(I));
          if I > 0 then
          begin
            for J := 1 to I do
            begin
              S.ReadBuffer(TempValue, SizeOf(TempValue));
              StreamReadString(S);
            end;
          end;

          // считываем ИД базы пославшей поток
          S.ReadBuffer(I, SizeOf(I));
          SourceBaseKey := I;
          // считываем ИД базы на которую поток был отправлен
          S.ReadBuffer(I, SizeOf(I));
          TargetBaseKey := I;}
          TargetBaseKey := -1;
          SourceBaseKey := -1;
          S.Position := 0;
        end;

        if SourceBaseKey > -1 then
        begin
          if Assigned(atDatabase) and Assigned(atDatabase.Relations.ByRelationName('RPL_DATABASE')) then
          begin
            // вытянем имена баз данных из RPL_DATABASE
            RPLDatabase := TgdRPLDatabase.Create;
            try
              // Исходная база
              RPLDatabase.ID := SourceBaseKey;
              if RPLDatabase.Name <> '' then
                eLoadingSourceBase.Text := RPLDatabase.Name
              else
                eLoadingSourceBase.Text := IntToStr(RPLDatabase.ID);

              // Целевая база
              RPLDatabase.ID := TargetBaseKey;
              if RPLDatabase.Name <> '' then
                eLoadingTargetBase.Text := RPLDatabase.Name
              else
                eLoadingTargetBase.Text := IntToStr(RPLDatabase.ID);
            finally
              RPLDatabase.Free;
            end;
          end
          else
          begin
            eLoadingSourceBase.Text := IntToStr(SourceBaseKey);
            eLoadingTargetBase.Text := IntToStr(TargetBaseKey);
          end;
          lblLoadingIncremented.Caption := 'Да';
        end;
      end;
    finally
      S.Free;
    end;

    Result := Self.ShowModal;
  end;
end;

function Tgdc_frmStreamSaver.ShowSaveForm: Integer;
begin
  FProcessType := ptSave;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowLoadSettingForm: Integer;
begin
  FProcessType := ptLoadSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowSaveSettingForm: Integer;
begin
  FProcessType := ptSaveSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowActivateSettingForm: Integer;
begin
  FProcessType := ptActivateSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowDeactivateSettingForm: Integer;
begin
  FProcessType := ptDeactivateSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowMakeSettingForm: Integer;
begin
  FProcessType := ptMakeSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowReactivateSettingForm: Integer;
begin
  FProcessType := ptReactivateSetting;
  Result := Self.ShowModal;
end;

function Tgdc_frmStreamSaver.ShowInstallPackageForm: Integer;
begin
  FProcessType := ptInstallPackage;
  Result := Self.ShowModal;
end;

procedure Tgdc_frmStreamSaver.SetProcessCaptionText(AText: String);
begin
  lblResult.Caption := AText;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.SetProcessText(AText: String; const Necessary: Boolean = False);
begin
  // Будем выводить только каждое { cShowMessageInterval } сообщение
  if (not Necessary) and (FRecordMessageCount < cShowMessageInterval) then
  begin
    Inc(FRecordMessageCount);
  end
  else
  begin
    FRecordMessageCount := 0;
    lblProcessText.Caption := AText;
    Self.BringToFront;
    UpdateWindow(Self.Handle);
  end;
end;

procedure Tgdc_frmStreamSaver.SetupProgress(const Max: Integer; ALabelString: String = 'Выполнение...');
begin
  // Перейдем на страницу визуализации процесса 
  if PageControl.ActivePage <> tbsProcess then
    PageControl.ActivePage := tbsProcess;

  pbMain.Position := 0;
  if Max > 0 then
    pbMain.Max := Max
  else
    pbMain.Max := 1;
  lblProgressMain.Caption := '0 / ' + IntToStr(pbMain.Max);
  lblResult.Caption := ALabelString;

  FProcessTimeCalculator.StartCalculation(pbMain.Max);

  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.Step;
begin
  if pbMain.Position < pbMain.Max - 1 then
  begin
    pbMain.Position := pbMain.Position + 1;
    FProcessTimeCalculator.Position := pbMain.Position;
    lblProgressMain.Caption := IntToStr(pbMain.Position) + ' / ' + IntToStr(pbMain.Max) +
      ',  ' + FProcessTimeCalculator.GetApproxEndString;
  end;
  if (pbMain.Position mod 10) = 0 then
    Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.Done;
begin
  pbMain.Position := pbMain.Max;
  lblProgressMain.Caption := IntToStr(pbMain.Max) + ' / ' + IntToStr(pbMain.Max);
  lblProcessText.Caption := '';
  lblResult.Caption := lblResult.Caption + ' Завершено ';

  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.AddMistake(AMistake: String);
var
  StatusIcon: TIcon;
begin
  if Assigned(dmImages) then
  begin
    StatusIcon := TIcon.Create;
    try
      dmImages.il16x16.GetIcon(207, StatusIcon);
      imgStatus.Picture.Assign(StatusIcon);
    finally
      StatusIcon.Free;
    end;
  end;

  if AMistake > '' then
  begin
    lblErrorMsg.Caption := AMistake;
    lblErrorMsg.Visible := true;
  end;
  FWasProcessError := True;
end;

procedure Tgdc_frmStreamSaver.AddWarning(AWarningMessage: String);
var
  StatusIcon: TIcon;
begin
  if (not FWasProcessError) and Assigned(dmImages) then
  begin
    StatusIcon := TIcon.Create;
    try
      dmImages.il16x16.GetIcon(224, StatusIcon);
      imgStatus.Picture.Assign(StatusIcon);
    finally
      StatusIcon.Free;
    end;
  end;
end;

procedure Tgdc_frmStreamSaver.DoAfterException(ErrorMsg: String);
begin
  lblProcessText.Caption := '';
  lblResult.Caption := 'Выполнение прервано';
  lblWasErrorMsg.Visible := True;
  lblErrorMsg.Visible := True;
  lblErrorMsg.Caption := ErrorMsg;
  btnClose.Enabled := True;

  at_frmSQLProcess.AddMistake(#13#10'Критическая ошибка! Выполнение прервано!'#13#10 + ErrorMsg, clRed);
end;

procedure Tgdc_frmStreamSaver.LoadDialogSettings;
begin
  if Assigned(GlobalStorage) then
  begin
    FStreamFormat := GetDefaultStreamFormat(False);
    FStreamSettingFormat := GetDefaultStreamFormat(True);
    FIncrementSaving := GlobalStorage.ReadBoolean('Options', 'UseIncrementSaving', False);
    FStreamLogType := TgsStreamLoggingType(GlobalStorage.ReadInteger('Options', 'StreamLogType', 0));
    FReplaceRecordBehaviuor := TReplaceRecordBehaviour(GlobalStorage.ReadInteger('Options', 'StreamReplaceRecordBehaviuor', 0));
  end;
end;

procedure Tgdc_frmStreamSaver.SaveDialogSettings;
begin
  if Assigned(GlobalStorage) then
  begin
    GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_DEFAULT_FORMAT, Integer(FStreamFormat));
    GlobalStorage.WriteInteger('Options', STORAGE_VALUE_STREAM_SETTING_DEFAULT_FORMAT, Integer(FStreamSettingFormat));
    GlobalStorage.WriteBoolean('Options', 'UseIncrementSaving', FIncrementSaving);
    GlobalStorage.WriteInteger('Options', 'StreamLogType', Integer(FStreamLogType));
    GlobalStorage.WriteInteger('Options', 'StreamReplaceRecordBehaviuor', Integer(FReplaceRecordBehaviuor));
  end;
end;

procedure Tgdc_frmStreamSaver.SetupDialog;
begin
  cbStreamFormat.ItemIndex := Integer(FStreamFormat) - 1;
  cbSettingFormat.ItemIndex := Integer(FStreamSettingFormat) - 1;

  if FStreamFormat <> sttBinaryOld then
    cbIncremented.Checked := FIncrementSaving
  else
    cbIncremented.Checked := False;

  lblIncrementedHelp.Visible := cbIncremented.Checked;
  pnlDatabases.Visible := cbIncremented.Checked;

  cbMakeSetting.Visible := False;
  lblSettingFormat.Visible := False;
  cbSettingFormat.Visible := False;
  lblSettingHint01.Visible := False;
  lblSettingHint02.Visible := False;

  btnPrev.Enabled := false;
  btnPrev.Caption := '< Назад';

  eFileName.Text := FFileName;
end;

procedure Tgdc_frmStreamSaver.ActivateFinishButtons(const IsActivate: Boolean = True);
begin
  btnClose.Enabled := IsActivate;
  btnClose.Default := IsActivate;
  btnShowLog.Enabled := IsActivate;
end;

procedure Tgdc_frmStreamSaver.cbStreamFormatChange(Sender: TObject);
begin
  FStreamFormat := TgsStreamType(cbStreamFormat.ItemIndex + 1);
end;

procedure Tgdc_frmStreamSaver.cbSettingFormatChange(Sender: TObject);
begin
  FStreamSettingFormat := TgsStreamType(cbSettingFormat.ItemIndex + 1);
  cbMakeSetting.Visible := (FStreamSettingFormat = sttBinaryOld);
end;

procedure Tgdc_frmStreamSaver.cbMakeSettingClick(Sender: TObject);
begin
  lblSettingFormat.Visible := cbMakeSetting.Checked;
  cbSettingFormat.Visible := cbMakeSetting.Checked; 
end;

procedure Tgdc_frmStreamSaver.cbIncrementedClick(Sender: TObject);
begin
  FIncrementSaving := cbIncremented.Checked;
  lblIncrementedHelp.Visible := cbIncremented.Checked;
  pnlDatabases.Visible := cbIncremented.Checked;
end;

procedure Tgdc_frmStreamSaver.actShowLogExecute(Sender: TObject);
begin
  frmSQLProcess.Show;
end;

procedure Tgdc_frmStreamSaver.actShowLogUpdate(Sender: TObject);
begin
  actShowLog.Enabled := (frmSQLProcess <> nil) and (frmSQLProcess.lv.Items.Count > 0);
end;

procedure Tgdc_frmStreamSaver.tmrInstallPackageTimer(Sender: TObject);
begin
  (Sender AS TTimer).Enabled := False;
  InstallPackage;
end;

end.

