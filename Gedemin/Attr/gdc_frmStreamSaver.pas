unit gdc_frmStreamSaver;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, gsDBGrid,
  gsIBGrid, Db, IBCustomDataSet, ActnList, gdcBase, dmDatabase_unit, at_frmIncrDatabaseList,
  gdcStreamSaver, gd_createable_form;

type
  TgsStreamSaverProcessType =
    (ptUnknown, ptSave, ptLoad, ptSaveSetting, ptLoadSetting,
     ptActivateSetting, ptDeactivateSetting, ptReactivateSetting, ptMakeSetting);

  Tgdc_frmStreamSaver = class(TForm)
    pnlBottom: TPanel;
    pnlMain: TPanel;
    pnlTop: TPanel;
    btnClose: TButton;
    btnNext: TButton;
    btnPrev: TButton;
    PageControl: TPageControl;
    tbsFirst: TTabSheet;
    tbsSecond: TTabSheet;
    tbsThird: TTabSheet;
    Label1: TLabel;
    lblFirst: TLabel;
    lblSecond: TLabel;
    lblThird: TLabel;
    alMain: TActionList;
    actNext: TAction;
    actPrev: TAction;
    lblResult: TLabel;
    lblWasErrorMsg: TLabel;
    btnShowLog: TButton;
    lblErrorMsg: TLabel;
    pnlDatabases: TPanel;
    lblProgressMain: TLabel;
    pbMain: TProgressBar;
    lblProcessText: TLabel;
    tbsSetting: TTabSheet;
    lblSettingHint01: TLabel;
    lblSettingHint02: TLabel;
    cbMakeSetting: TCheckBox;
    lblSettingQuestion: TLabel;
    actStreamSettings: TAction;
    gbOptions: TGroupBox;
    lblFileName: TLabel;
    lblFileType: TLabel;
    lblLoadingSourceBase: TLabel;
    lblLoadingTargetBase: TLabel;
    eFileName: TEdit;
    eFileType: TEdit;
    eLoadingSourceBase: TEdit;
    eLoadingTargetBase: TEdit;
    lblIncremented: TLabel;
    eIncremented: TEdit;
    btnSettings: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnShowLogClick(Sender: TObject);
    procedure tbsFirstShow(Sender: TObject);
    procedure tbsSecondShow(Sender: TObject);
    procedure tbsThirdShow(Sender: TObject);
    procedure cbIncrementClick(Sender: TObject);
    procedure tbsSettingShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actStreamSettingsExecute(Sender: TObject);
  private
    FgdcObject: TgdcBase;
    FgdcDetailObject: TgdcBase;
    FBL: TBookmarkList;
    FWithDetail, FOnlyCurrent: Boolean;
    FProcessType: TgsStreamSaverProcessType;
    FInProcess: Boolean;
    FFileName: String;
    FframeDatabases: TfrmIncrDatabaseList;
    FProcessDuration: Cardinal;
    FRecordMessageCount: Integer;

    FUseNewStream: Boolean;
    FUseNewStreamSetting: Boolean;
    FStreamType: TStreamFileFormat;
    FStreamSettingType: TStreamFileFormat;
    FIncrementSaving: Boolean;
    FReplaceRecordBehaviuor: TReplaceRecordBehaviour;

    procedure SetInitialSettings;

    procedure Save;
    procedure Load;
    procedure SaveSetting;
    procedure LoadSetting;
    procedure ActivateSetting;
    procedure DeactivateSetting;
    procedure ReactivateSetting;
    procedure MakeSetting;
    procedure DoAfterAbortProcess;
    procedure DoAfterException(ErrorMsg: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetParams(gdcObject: TgdcBase; gdcDetail: TgdcBase = nil;
      const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = false);

    procedure SetupProgress(const Max: Integer; ALabelString: String = 'Выполнение...');
    procedure Step;
    procedure Done;
    procedure ActivateFinishButtons;
    procedure AddMistake(AMistake: String = '');
    procedure SetProcessCaptionText(AText: String);
    procedure SetProcessText(AText: String; const Necessary: Boolean = False);

    function ShowSaveForm: Integer;
    function ShowLoadForm: Integer;

    function ShowSaveSettingForm: Integer;
    function ShowLoadSettingForm: Integer;
    function ShowMakeSettingForm: Integer;
    function ShowActivateSettingForm: Integer;
    function ShowDeactivateSettingForm: Integer;
    function ShowReactivateSettingForm: Integer;

    property gdcObject: TgdcBase read FgdcObject;
    property FileName: String read FFilename write FFilename;
  end;
  
var
  frmStreamSaver: Tgdc_frmStreamSaver;

procedure CreateStreamSaverForm;

implementation

uses
  gdcBaseInterface,           Storages,                  gdcSetting,
  at_frmSQLProcess,           IBSQL,                     gs_Exception,
  gd_security,                at_classes,                zlib,
  gd_dlgStreamSaverOptions;

const
  // Через какое кол-во переданных сообщений пропускать, не выводя на экран
  cShowMessageInterval = 5;

{$R *.DFM}

procedure CreateStreamSaverForm;
begin
  if not Assigned(frmStreamSaver) then
    frmStreamSaver := Tgdc_frmStreamSaver.Create(Application);
end;

{ Tgdc_frmStreamSaver }

constructor Tgdc_frmStreamSaver.Create(AOwner: TComponent);
begin
  Assert(frmStreamSaver = nil, 'Может быть только одна форма frmStreamSaver');

  inherited;

  frmStreamSaver := Self;
  FgdcObject := nil;
  FgdcDetailObject := nil;
  FBL := nil;
  FInProcess := False;
  FProcessType := ptSave;
  FRecordMessageCount := cShowMessageInterval;     
  PageControl.ActivePage := tbsFirst;

  if not Assigned(frmSQLProcess) then
  begin
    frmSQLProcess := TfrmSQLProcess.Create(Application);
    frmSQLProcess.SQLText.Lines.Clear;
  end;  
  frmSQLProcess.Silent := True;
  frmSQLProcess.IsShowLog := True;
end;

destructor Tgdc_frmStreamSaver.Destroy;
begin
  FgdcObject := nil;
  FBL := nil;
  FgdcDetailObject := nil;

  if Assigned(frmSQLProcess) then
    frmSQLProcess.Silent := False;

  frmStreamSaver := nil;
  inherited;
end;

procedure Tgdc_frmStreamSaver.FormShow(Sender: TObject);
begin
  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);
  frmSQLProcess.Silent := True;

  case FProcessType of
    ptSave, ptLoad:
      PageControl.ActivePage := tbsFirst;
    ptSaveSetting, ptLoadSetting, ptActivateSetting, ptDeactivateSetting, ptReactivateSetting, ptMakeSetting:
      PageControl.ActivePage := tbsSetting;
  end;

  SetInitialSettings;
end;

procedure Tgdc_frmStreamSaver.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FframeDatabases) then
  begin
    if Assigned(GlobalStorage) and (FframeDatabases.ibgrDatabases.SettingsModified) then
      GlobalStorage.SaveComponent(FframeDatabases.ibgrDatabases, FframeDatabases.ibgrDatabases.SaveToStream);
    FframeDatabases.Free;
  end;

  if Assigned(frmSQLProcess) then
  begin
    frmSQLProcess.Close;
    frmSQLProcess.Silent := False;
  end;
  
  Action := caFree;
end;

procedure Tgdc_frmStreamSaver.tbsFirstShow(Sender: TObject);
begin
  btnPrev.Enabled := false;
  btnPrev.Caption := '< Назад';
  btnNext.Enabled := true;
  case FProcessType of
    ptSave:
    begin
      lblSecond.Visible := true;
      lblSecond.Caption := '2. Выбор базы';
      lblSecond.Font.Style := [];
      lblThird.Visible := true;
      lblThird.Caption := '3. Сохранение';
      lblThird.Font.Style := [];
      if not FIncrementSaving then
      begin
        lblSecond.Enabled := false;
        btnNext.Caption := 'Сохранить';
      end
      else
      begin
        lblSecond.Enabled := true;
        btnNext.Caption := 'Далее >';
      end;
    end;

    ptLoad:
    begin
      lblSecond.Visible := false;
      lblThird.Visible := true;
      lblThird.Caption := '2. Загрузка';
      lblThird.Font.Style := [];
      btnNext.Caption := 'Загрузить';
    end;
  end;

  lblFirst.Visible := true;
  lblFirst.Caption := '1. Файл';
  lblFirst.Font.Style := [fsBold];
end;

procedure Tgdc_frmStreamSaver.tbsSecondShow(Sender: TObject);
begin
  btnPrev.Enabled := true;
  btnPrev.Caption := '< Назад';
  btnNext.Enabled := true;
  btnNext.Caption := 'Сохранить';

  lblFirst.Font.Style := [];
  lblSecond.Font.Style := [fsBold];
  lblThird.Font.Style := [];
end;

procedure Tgdc_frmStreamSaver.tbsThirdShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := False;
  btnClose.Enabled := False;
  btnShowLog.Enabled := False;
  btnSettings.Enabled := False;

  lblFirst.Font.Style := [];
  lblSecond.Font.Style := [];
  lblThird.Font.Style := [fsBold];
end;

procedure Tgdc_frmStreamSaver.tbsSettingShow(Sender: TObject);
begin
  btnPrev.Enabled := False;
  btnNext.Enabled := True;
  lblSecond.Visible := False;
  lblFirst.Visible := True;
  lblFirst.Caption := '1. Настройка';
  lblFirst.Font.Style := [fsBold];
  lblThird.Visible := True;
  lblThird.Font.Style := [];

  case FProcessType of

    ptSaveSetting:
    begin
      lblSettingQuestion.Caption := 'Сохранить настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      cbMakeSetting.Visible := True;
      btnNext.Caption := 'Сохранить';
      lblThird.Caption := '2. Сохранение';
    end;

    ptLoadSetting:
    begin
      lblSettingQuestion.Caption := 'Загрузить настройку?';
      lblSettingQuestion.Visible := True;
      lblSettingHint01.Visible := True;
      lblSettingHint02.Visible := True;
      btnNext.Caption := 'Загрузить';
      lblThird.Caption := '2. Загрузка';
    end;

    ptActivateSetting:
    begin
      lblSettingQuestion.Caption := 'Активировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Активировать';
      lblThird.Caption := '2. Активация';
    end;

    ptDeactivateSetting:
    begin
      cbMakeSetting.Visible := True;
      cbMakeSetting.Caption := 'Обновить данные настройки перед ее деактивацией?';
      lblSettingQuestion.Caption := 'Деактивировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Деактивировать';
      lblThird.Caption := '2. Деактивация';
    end;

    ptReactivateSetting:
    begin
      lblSettingHint01.Caption := 'Переактивация настройки на действующей базе данных может привести к потере данных!'#13#10 +
        'Настоятельно рекомендуется произвести архивное копирование базы данных.';
      lblSettingHint01.Visible := True;
      lblSettingQuestion.Caption := 'Переактивировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Переактивировать';
      lblThird.Caption := '2. Переактивация';
    end;

    ptMakeSetting:
    begin
      lblSettingQuestion.Caption := 'Сформировать настройку'#13#10 + '  "' + gdcObject.FieldByName('name').AsString + '"?';
      lblSettingQuestion.Visible := True;
      btnNext.Caption := 'Сформировать';
      lblThird.Caption := '2. Формирование';
    end;

  end;
end;

procedure Tgdc_frmStreamSaver.SetParams(gdcObject: TgdcBase; gdcDetail: TgdcBase = nil;
  const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = false);
var
  GridOptions: TDBGridOptions;
begin
  if gdcObject <> nil then
  begin
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
    end
    else
    begin
      lblSecond.Enabled := False;
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
      if PageControl.ActivePage = tbsFirst then
      begin
        if FIncrementSaving then
          PageControl.ActivePage := tbsSecond
        else
        begin
          PageControl.ActivePage := tbsThird;
          Self.Save;
          btnPrev.Enabled := true;
          Self.ActivateFinishButtons;
        end;
      end
      else
        if PageControl.ActivePage = tbsSecond then
        begin
          PageControl.ActivePage := tbsThird;
          Self.Save;
          btnPrev.Enabled := true;
          Self.ActivateFinishButtons;
        end;
    end;

    ptLoad:
    begin
      if PageControl.ActivePage = tbsFirst then
      begin
        PageControl.ActivePage := tbsThird;
        Self.Load;
        Self.ActivateFinishButtons;
      end;
    end;

    ptSaveSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.SaveSetting;
        btnPrev.Enabled := true;
        Self.ActivateFinishButtons;
      end;
    end;

    ptLoadSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.LoadSetting;
        Self.ActivateFinishButtons;
      end;
    end;

    ptActivateSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.ActivateSetting;
      end;
    end;

    ptDeactivateSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.DeactivateSetting;
      end;
    end;

    ptReactivateSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.ReactivateSetting;
      end;
    end;

    ptMakeSetting:
    begin
      if PageControl.ActivePage = tbsSetting then
      begin
        PageControl.ActivePage := tbsThird;
        Self.MakeSetting;
        Self.ActivateFinishButtons;
      end;
    end;

  end;

end;

procedure Tgdc_frmStreamSaver.actPrevExecute(Sender: TObject);
begin
  case FProcessType of
    ptSave:
    begin
      if PageControl.ActivePage = tbsThird then
      begin
        if FIncrementSaving then
          PageControl.ActivePage := tbsSecond
        else
          PageControl.ActivePage := tbsFirst;
        Exit;
      end;

      if PageControl.ActivePage = tbsSecond then
        PageControl.ActivePage := tbsFirst;
    end;

    ptLoad:
    begin
      if PageControl.ActivePage = tbsThird then
        PageControl.ActivePage := tbsFirst;
    end;

  else
    if PageControl.ActivePage = tbsThird then
      PageControl.ActivePage := tbsSetting;
  end;
end;

procedure Tgdc_frmStreamSaver.Save;
var
  startTick: Cardinal;
  StreamSaver: TgdcStreamSaver;
  Bm: TBookmarkStr;
  I: Integer;
  S: TStream;
  StreamType: TgsStreamType;

  procedure SaveDetail;
  var
    DBm: TBookmarkStr;
  begin
    if Assigned(FgdcDetailObject) then
    begin
      FgdcDetailObject.BlockReadSize := 1;
      try
        DBm := FgdcDetailObject.Bookmark;
        FgdcDetailObject.First;
        while not FgdcDetailObject.Eof do
        begin
          StreamSaver.AddObject(FgdcDetailObject{, FWithDetail});
          if StreamSaver.IsAbortingProcess then
          begin
            DoAfterAbortProcess;
            Exit;
          end;
          FgdcDetailObject.Next;
        end;
        FgdcDetailObject.Bookmark := DBm;
      finally
        FgdcDetailObject.BlockReadSize := 0;
      end;
    end;
  end;

begin
  try
    startTick := GetTickCount;

    if FUseNewStream then
    begin

      StreamSaver := TgdcStreamSaver.Create(FgdcObject.Database, FgdcObject.Transaction);
      try
        // если выбрано Инкрементное сохранение, то передадим ИД целевой базы
        if FIncrementSaving and FframeDatabases.gdcDatabases.Active then
          StreamSaver.PrepareForIncrementSaving(FframeDatabases.gdcDatabases.FieldByName('ID').AsInteger);

        // Если сохраняем только одну запись
        if FOnlyCurrent then
        begin
          Self.SetupProgress(1, 'Сохранение данных...');
          StreamSaver.AddObject(FgdcObject{, FWithDetail});
          if StreamSaver.IsAbortingProcess then
          begin
            DoAfterAbortProcess;
            Exit;
          end;
          SaveDetail;
          Self.Step;
        end
        else
        begin
          Bm := FgdcObject.Bookmark;
          FgdcObject.BlockReadSize := 1;

          try
            // Если не передан BookmarkList, то сохраняем весь датасет
            if FBL = nil then
            begin
              Self.SetupProgress(FgdcObject.RecordCount,  'Сохранение данных...');
              FgdcObject.First;
              while not FgdcObject.EOF do
              begin
                StreamSaver.AddObject(FgdcObject{, FWithDetail});
                if StreamSaver.IsAbortingProcess then
                begin
                  DoAfterAbortProcess;
                  Exit;
                end;
                SaveDetail;
                FgdcObject.Next;
                Self.Step;
              end;
            end else
            begin
              Self.SetupProgress(FBL.Count,  'Сохранение данных...');
              FBL.Refresh;
              for I := 0 to FBL.Count - 1 do
              begin
                FgdcObject.Bookmark := FBL[I];
                StreamSaver.AddObject(FgdcObject{, FWithDetail});
                if StreamSaver.IsAbortingProcess then
                begin
                  DoAfterAbortProcess;
                  Exit;
                end;
                SaveDetail;
                Self.Step;
              end;
            end;
          finally
            FgdcObject.Bookmark := Bm;
            FgdcObject.BlockReadSize := 0;
          end;
        end;

        Self.SetProcessCaptionText('Запись в файл...');

        // сохраняем в зависимости от выбранного в настройках типа файла
        StreamType := sttBinaryNew;
        if FStreamType = ffXML then
          StreamType := sttXML;

        S := TFileStream.Create(FFileName, fmCreate);
        try
          StreamSaver.SaveToStream(S, StreamType);
        finally
          S.Free;
        end;
      finally
        StreamSaver.Free;
      end;
    end
    else
    begin
      Self.SetupProgress(1, 'Сохранение данных...');
    
      S := TFileStream.Create(FFileName, fmCreate);
      try
        FgdcObject.SaveToStream(S, FgdcDetailObject, FBL, FOnlyCurrent);
      finally
        S.Free;
      end;
    end;

    FProcessDuration := GetTickCount - startTick;
    Self.Done;
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.Load;
var
  startTick: Cardinal;
  StreamSaver: TgdcStreamSaver;
  S: TStream;
begin
  try
    startTick := GetTickCount;

    StreamSaver := TgdcStreamSaver.Create(FgdcObject.Database, FgdcObject.Transaction);
    S := TFileStream.Create(FFileName, fmOpenRead);
    try
      StreamSaver.Silent := True;
      StreamSaver.ReplaceRecordBehaviour := FReplaceRecordBehaviuor;
      StreamSaver.LoadFromStream(S);
      if StreamSaver.IsAbortingProcess then
      begin
        DoAfterAbortProcess;
        Exit;
      end;
    finally
      S.Free;
      StreamSaver.Free;
    end;

    FProcessDuration := GetTickCount - startTick;
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
      MakeSetting;
      
    gdcObject.SaveToFile(Self.Filename, FgdcDetailObject, FBL);
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
      MakeSetting;

    (gdcObject as TgdcSetting).DeactivateSetting;
  except
    on E: Exception do
      Self.DoAfterException(E.Message);
  end;
end;

procedure Tgdc_frmStreamSaver.MakeSetting;
begin
  (gdcObject as TgdcSetting).SaveSettingToBlob;
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

function Tgdc_frmStreamSaver.ShowLoadForm: Integer;
var
  stRecord: TgsStreamRecord;
  SourceBaseKey, TargetBaseKey: TID;
  I: Integer;
  S: TStream;
  RPLDatabase: TgdRPLDatabase;
begin
  FProcessType := ptLoad;

  S := TFileStream.Create(FFileName, fmOpenRead);
  try

    if GetStreamType(S) = sttXML then
    begin
      TargetBaseKey := -1;
      SourceBaseKey := -1;
      eFileType.Text := 'XML';
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

      eFileType.Text := 'Двоичный';
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
      eIncremented.Text := 'Да';
    end
    else
    begin
      eLoadingSourceBase.Visible := false;
      lblLoadingSourceBase.Visible := false;
      eLoadingTargetBase.Visible := false;
      lblLoadingTargetBase.Visible := false;
      eIncremented.Text := 'Нет';
    end;

  finally
    S.Free;
  end;

  Result := Self.ShowModal;
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
  pbMain.Position := 0;
  if Max > 0 then
    pbMain.Max := Max
  else
    pbMain.Max := 1;
  lblProgressMain.Caption := '0 / ' + IntToStr(pbMain.Max);
  lblResult.Caption := ALabelString;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.Step;
begin
  if pbMain.Position < pbMain.Max - 1 then
  begin
    pbMain.Position := pbMain.Position + 1;
    lblProgressMain.Caption := IntToStr(pbMain.Position) + ' / ' + IntToStr(pbMain.Max);
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
  lblResult.Caption := lblResult.Caption + ' Завершено '{ + FloatToStr(FProcessDuration / 1000) + ' сек'};

  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure Tgdc_frmStreamSaver.btnShowLogClick(Sender: TObject);
begin
  if Assigned(frmSQLProcess) then
    frmSQLProcess.Show;
end;

procedure Tgdc_frmStreamSaver.AddMistake(AMistake: String);
begin
  if AMistake > '' then
  begin
    lblErrorMsg.Caption := AMistake;
    lblErrorMsg.Visible := true;
  end;
  if not lblWasErrorMsg.Visible then
    lblWasErrorMsg.Visible := true;
end;

procedure Tgdc_frmStreamSaver.cbIncrementClick(Sender: TObject);
begin
  {lblSecond.Enabled := cbIncrement.Checked;
  if not cbIncrement.Checked then
    btnNext.Caption := 'Сохранить'
  else
    btnNext.Caption := 'Далее >';}
end;

procedure Tgdc_frmStreamSaver.DoAfterAbortProcess;
begin
  lblProcessText.Caption := '';
  lblResult.Caption := 'Выполнение прервано';
  btnClose.Enabled := True;
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

procedure Tgdc_frmStreamSaver.SetInitialSettings;
begin
  if Assigned(GlobalStorage) then
    with GlobalStorage do
    begin
      FUseNewStream := ReadBoolean('Options', 'UseNewStream', False);
      FUseNewStreamSetting := ReadBoolean('Options', 'UseNewStreamForSetting', False);
      FStreamType := TStreamFileFormat(ReadInteger('Options', 'StreamType', 0));
      FStreamSettingType := TStreamFileFormat(ReadInteger('Options', 'StreamSettingType', 0));
      FIncrementSaving := ReadBoolean('Options', 'UseIncrementSaving', False);
      FReplaceRecordBehaviuor := TReplaceRecordBehaviour(ReadInteger('Options', 'StreamReplaceRecordBehaviuor', 0));
    end;

  if FProcessType = ptSave then
  begin
    if not FIncrementSaving then
      btnNext.Caption := 'Сохранить'
    else
      btnNext.Caption := 'Далее >';

    lblLoadingSourceBase.Visible := False;
    eLoadingSourceBase.Visible := False;
    lblLoadingTargetBase.Visible := False;
    eLoadingTargetBase.Visible := False;
    
    if FUseNewStream then
    begin
      if FStreamType = ffXML then
        eFileType.Text := 'XML'
      else
        eFileType.Text := 'Новый двоичный';

      if FIncrementSaving then
        eIncremented.Text := 'Да'
      else
        eIncremented.Text := 'Нет';
    end
    else
    begin
      eFileType.Text := 'Старый двоичный';
      eIncremented.Text := 'Нет';
    end;
  end;

  eFileName.Text := FFileName;
end;

procedure Tgdc_frmStreamSaver.actStreamSettingsExecute(Sender: TObject);
begin
  with TdlgStreamSaverOptions.Create(Self) do
    try
      if ShowModal = mrOK then
        SetInitialSettings;
    finally
      Free;
    end;
end;

procedure Tgdc_frmStreamSaver.ActivateFinishButtons;
begin
  btnSettings.Enabled := True;
  btnClose.Enabled := True;
  btnClose.Default := True;
  btnShowLog.Enabled := True;
end;

end.

