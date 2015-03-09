unit gdcSetting;

interface                                           

uses
   gdcBase, gd_classlist, Classes, Forms, gd_createable_form, SysUtils, Controls, dialogs,
   db, gd_security, dbgrids, gdcBaseInterface, contnrs, gd_KeyAssoc, IBCustomDataSet,
   StdCtrls, IBSQL, at_SettingWalker, gsStreamHelper, gdcLBRBTreeMetaData;

type
  TgdcSetting = class(TgdcBase)
  private
    FSilent: boolean;
    FActivateErrorDescription: WideString;
    //Список руидов в настройке. Используется при загрузке из потока
    OldRuidList: TStrings;

    FIBSQLDeleteAllPos: TIBSQL;
    FIBSQLSelectPos: TIBSQL;
    FIBSQLSelectAllPos: TIBSQL;
    FIBSQLUpdatePos: TIBSQL;
    FIBSQLUpdatePosOrder: TIBSQL;
    FIBSQLInsertPos: TIBSQL;

    FNewPositionOffset: Integer;
    FManualAddedPositions: TStringList;
    FAddedPositions: TStringList;

    //Проверяет настройку на удаленные из нее объекты
    procedure CheckSetting;
                                                    
    //Загружает в список id главных настроек
    procedure LoadMainSettingsID(KA: TgdKeyArray);
    procedure AddMainSettings(FKeys: TStrings; const MainID: Integer = 0);

    procedure OnStartLoading(Sender: TatSettingWalker; AnObjectSet: TgdcObjectSet);
    procedure OnObjectLoad(Sender: TatSettingWalker; const AClassName, ASubType: String;
      ADataSet: TDataSet; APrSet: TgdcPropertySet;
      const ASR: TgsStreamRecord);
    procedure OnStartLoadingNew(Sender: TatSettingWalker);
    procedure OnObjectLoadNew(Sender: TatSettingWalker; const AClassName, ASubType: String; ADataSet: TDataSet);

  protected
    function CreateDialogForm: TCreateableForm; override;

    procedure CustomModify(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;

    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforePost; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
  // constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    procedure SaveToFile(const AFileName: String = ''; const ADetail: TgdcBase = nil;
      const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True; StreamFormat: TgsStreamType = sttUnknown); override;
    procedure LoadFromFile(const AFileName: String = ''); override;

    {KeyAr - Список идентификаторов настроек. Идентификаторы стоят в порядке создания настроек
     Вместо KeyAr может передаваться nil.
     Если KeyAr <> nil, то натсройка не ищет зависимости и не обращает внимания на BL,
     а сразу вызывает активацию}
    procedure ActivateSetting(KeyAr: TStrings; BL: TBookmarkList;
      const AnModalSQLProcess: Boolean = True; const AnAnswer: Integer = 0);
    //Деактивация текущей настройки
    procedure DeactivateSetting;
    //Сохранение позиций настройки в соответсвующие блоб-поля
    procedure SaveSettingToBlob(SettingFormat: TgsStreamType = sttUnknown);
    //переактивирует текущую настройку без предшедствующей деактивации
    procedure ReActivateSetting(BL: TBookmarkList);
    //Устанавливает сортировку для позиций настройки
    procedure MakeOrder;
    //Выбирает настройки, от которых зависит текущая настройка
    procedure ChooseMainSetting;
    //Очищает зависимость от других настроек
    procedure ClearDependencies;

    procedure UpdateActivateError;
    // Удаляет текущие позиции настройки и заполняет настоящим содержимым настройки
    //  (то есть добавляет в позиции те записи, которые были неявно добавленны в настройку).
    // Перед этим настройка должна быть сформирована (должен быть вызван SaveSetingToBlob,
    //  который обновит данные в шапке).
    procedure AddMissedPositions;

    procedure GoToLastLoadedSetting;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
    class function NeedDeleteTheSame(const SubType: String): Boolean; override;

    property Silent: Boolean read FSilent write FSilent default false;
    //property ActivateError: TSettingError read FActivateError;
    property ActivateErrorDescription: WideString read FActivateErrorDescription;
  end;

  TgdcSettingPos = class(TgdcBase)
  private
    FLastOrderSQL: TIBSQL;


  protected
    function GetOrderClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure DoBeforePost; override;
    procedure DoAfterOpen; override;

    //Последний порядковый номер позиции для текущей настройки
    //Если несколько пользователей будут одновременно формировть настройку, возсожно дублирование
    function GetLastOrder: Integer;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;

    procedure ChooseNewItem;

    procedure AddPos(AnObject: TgdcBase; const WithDetail: Boolean);
    //Процедура для проверки действительности текущей настройки
    procedure Valid(const DoAutoDelete: Boolean = false);

    // Скопировать позицию настройки в указанную настройку, позиция вставляется в конец списка
    function CopyToSetting(const ASettingKey: TID): Boolean;
    // Переместить позицию настройки в указанную настройку
    function MoveToSetting(const ASettingKey: TID): Boolean;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    procedure SetWithDetail(const Value: Boolean; BL: TBookmarkList);
    procedure SetNeedModify(const Value: Boolean; BL: TBookmarkList);
    procedure SetNeedInsert(const Value: Boolean; BL: TBookmarkList);
    procedure SetNeedModifyDefault;
  end;

  TgdcSettingStorage = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    procedure AddPos(ABranchName, AValueName: String);
    //Процедура для проверки действительности текущей настройки
    procedure Valid;

    class function NeedModifyFromStream(const SubType: String): Boolean; override;
  end;

// тип версия_настройки
  TSettingVersion = (svNotInstalled, svNewer, svEqual, svOlder, svIncorrect, svIndefinite);
// тип несоответствие версий
  TApprVersion = (avNotApprEXEVersion, avNotApprDBVersion);

// заголовок настройки
  TSettingHeader = class(TObject)
  public
    ID: TID;                 // id настройки
    RUID: TRUID;             // RUID настройки
    Name: String;            // наименование
    Comment: String;         // описание
    Date: TDateTime;         // дата модификации
    Version: Integer;        // версия
    Ending: Byte;            // конечная/промежуточная
    InterRUID: TStrings;     // список РУИДов настроек, от кот. зависит
    MinExeVersion: String;   // мин версия EXE
    MinDBVersion: String;    // мин версия БД
    Size: Integer;           // размер объекта, байт (для смещения в потоке)

    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetInfo(gdcObject: TgdcBase);
    procedure SaveToStream(Stream: TStream);
    function LoadFromStream(Stream: TStream):Boolean;
  end;

  TGSFList = class;

// информация о файле настройки
  TGSFHeader = class(TSettingHeader)
  private
    GSFVersion: Integer;     // версия формата файла
    function GetFullCorrect: Boolean;

  public
    OwnerList: TGSFList;
    CorrectPack: Boolean;    // корректный пакет
    VerInfo: TSettingVersion;// версия более новая, чем в БД
    MaxVerInfo: TSettingVersion;       // инф. о макс. новизне настроек пакета
    ApprVersion: set of TApprVersion;  // инф. о сравнении версий EXE и БД
    FilePath: String;        // путь к дисковому файлу (исп. при загрузке)
    FileName: String;        // имя дискового файла
    RealSetting: TSettingHeader;
    ErrMessage: String;

    property FullCorrect: Boolean read GetFullCorrect;

    constructor Create; override;
    destructor Destroy; override;

    function GetGSFInfo(const FName: String): Boolean; overload;
    function GetGSFInfo(AStream: TStream): Boolean; overload;
  end;

// список объектов с информацией о файле настройки
  TGSFList = class(TStringList)
  private
    SettIDList: TStringList; // список индексов настроек всех устанавливаемых пакетов
    ProcessedRUIDList: TStringList;    // список RUID настроек, по которым выводился запрос пользователю
    CurDBVersion: String;
    CurEXEVersion: String;

    procedure InstallSettingByID(aID: Integer);

    function LoadInfoFor(aID: Integer; const aRUID, aPath: String; var Err: String; var MaxPackVerInfo: TSettingVersion; out isCorrect: Boolean{; const isForce: Boolean = False}): TSettingVersion;
    function CheckedRUID(aRUID: String): Integer;
  public
    gdcSetts: TgdcSetting;
    isYesToAll: Boolean;
    VerInfoToInstall: TSettingVersion;
    CheckList: TStringList;  // список настроек (пакетов), отмеченных для установки

    constructor Create;
    destructor Destroy; override;
    function AddObject(const S: string; AObject: TObject): Integer; override;
    procedure Clear; override;
    procedure GetFilesForPath(Path: String; const lInfo: TLabel = nil);
    procedure LoadPackageInfo{(const isForce: Boolean = False)};    // можно добавить пар-тр - forEndingOnly
    function InstallPackages: Boolean;
    function InstallPackage(aID: Integer; const NewOnly: Boolean = False): Boolean;
    procedure ActivatePackages;
  end;

  procedure Register;

  function GetCRC32FromText(Text: String): Integer;

  procedure _ActivateSetting(const SettingKey: String; const DontHideForms: Boolean; const AnModalSQLProcess: Boolean; AnAnswer, AnStAnswer: Word);
  procedure _DeactivateSetting(const SettingKey: String; const AnModalSQLProcess: Boolean);

  //Загружает в стринглист в порядке создания руиды объектов,
  //входящих в текущую настройку
  procedure LoadRUIDFromBlob(RuidList: TStrings; RUIDField: TField; const AnID: Integer = -1);
const

  // Идентификатор файла настройки
  gsfID = 608588615;
  // Текущая версия формата файла настройки
  gsfVersion = 1;

  girOK = 0;
  girUserCancel = 1;
  girNotFound = 2;

  cst_StreamValue = 'Value';

var
  glb_ErrMessage: String;
  ErrorMessageForSetting: WideString;

implementation

uses
  gdc_attr_dlgSetting_unit,  gdc_attr_frmSetting_unit, gd_CmdLineParams_unit,
  gdc_attr_dlgSettingPos_unit, gdcMetadata, gdcJournal, gd_FileList_unit,
  gdc_attr_dlgSettingOrder_unit, IBQuery, gdcEvent, Windows, gdcTree,
  gsStorage, Storages, gdcStorage, jclSelected, IBDatabase, at_frmSQLProcess,
  Graphics, at_classes, gd_directories_const, dbclient, gdcFunction,
  evt_i_Base, mtd_i_Base, gd_i_ScriptFactory, gdcFilter, gdcReport,
  gdcMacros, at_sql_metadata, at_sql_setup, dm_i_ClientReport_unit,
  at_ActivateSetting_unit, gsDesktopManager, TypInfo, at_dlgChoosePackage_unit,
  gd_common_functions, zlib, gd_frmBackup_unit, gd_frmRestore_unit, gdcClasses
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdcStreamSaver, gdc_frmStreamSaver, gdcTableMetaData;

const
  cst_strTable = 'Таблица';
  cst_strForm = 'Форма';
  cst_str_WithoutName = 'Без наименования';

  cst_DesktopLast = 'Последний';

type
  TArrByte = array of Byte;
  TCrackIBCustomDataSet = class(TIBCustomDataSet);

var
//Используется при добавлении мета-данных в настройку
  IsSynchTriggersAndIndices: Boolean = False;
  // Будем запоминать ключ загруженной настройки, чтобы после загрузки перейти на нее
  LastLoadedSettingKey: TID = -1;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcSetting, TgdcSettingPos, TgdcSettingStorage]);
end;

// Получаем CRC переданной строки
function GetCRC32FromText(Text: String): Integer;
begin
  Result := Integer(Crc32_P(@Text[1], Length(Text), 0));
end;

{ TgdcSetting }

{constructor TgdcSetting.Create(AnOwner: TComponent);
begin
  inherited;
  FActivateError.Number := 0;
  FActivateError.Description := '';
end;}

procedure TgdcSetting.AddMainSettings(FKeys: TStrings; const MainID: Integer = 0);
var
  I: Integer;
  KA: TgdKeyArray;
  Index: Integer;
  gdcMain: TgdcSetting;
begin
  if FieldByName('Disabled').AsInteger = 0 then
    Exit;

  if FKeys.IndexOf(IntToStr(ID)) > -1 then
    Exit;

  Index := FKeys.IndexOf(IntToStr(MainID));
  if Index = -1 then
    Index := 0;

  FKeys.Insert(Index, IntToStr(ID));

  KA := TgdKeyArray.Create;
  gdcMain := TgdcSetting.CreateSubType(Self, '', 'ByID');
  try
    LoadMainSettingsID(KA);
    gdcMain.Transaction := Transaction;
    gdcMain.Open;
    for I := 0 to KA.Count - 1 do
    begin
      gdcMain.ID := KA[I];
      gdcMain.Open;
      if gdcMain.RecordCount > 0 then
        gdcMain.AddMainSettings(FKeys, ID);
    end;
  finally
    KA.Free;
    gdcMain.Free;
  end;
end;

procedure TgdcSetting.ActivateSetting(KeyAr: TStrings; BL: TBookmarkList;
  const AnModalSQLProcess: Boolean = True; const AnAnswer: Integer = 0);
var
  WasCreate: Boolean;
  J, K: Integer;
  AddKeyAr, FinalKeyAr: TStringList;
  ShowSQL: Boolean;
begin
  Assert(atDatabase <> nil, 'Не загружена база атрибутов atDatabase');

  if (TCreateableForm.FormAssigned(gd_frmBackup) and gd_frmBackup.ServiceActive) or
    (TCreateableForm.FormAssigned(gd_frmRestore) and gd_frmRestore.ServiceActive) then
  begin
    MessageBox(0,
      'Активировать настройку в данный момент времени невозможно,'#13#10 +
      'так как выполняется процесс архивирования или восстановления базы данных.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    exit;
  end;

  WasCreate := not Assigned(KeyAr);
  if WasCreate then
    KeyAr := TStringList.Create;

   //Список для ключей зависимых настроек
  AddKeyAr := TStringList.Create;
  FinalKeyAr := TStringList.Create;
  try
    if WasCreate then
    begin
      if (not Assigned(BL)) or (BL.Count = 0) then
      begin
        //Вытягиваем ключи главных настроек в список
        AddMainSettings(FinalKeyAr);
      end else
      begin
        {Если нам передан букмарклист пробежимся по нему и для каждого
         ид найдем главные настройки}
        for J := 0 to BL.Count - 1 do
        begin
          Bookmark := BL[J];

          if Assigned(IBLogin) then
          begin
            IBLogin.AddEvent(
              'Активизация настройки "' + ObjectName + '"',
              Self.ClassName,
              Self.ID);
          end;

          AddKeyAr.Clear;
          AddMainSettings(AddKeyAr);
          for K := 0 to AddKeyAr.Count - 1 do
          begin
            if FinalKeyAr.IndexOf(AddKeyAr[K]) = -1 then
              FinalKeyAr.Add(AddKeyAr[K]);
          end;
        end;
      end;
    end else
    begin
      Assert(HasSubSet('ByID') or HasSubSet('All'));
      {Если нам передан список ключей пробежимся по нему и найдем главные настройки}
      for J := 0 to KeyAr.Count - 1 do
      begin
        ID := StrToInt(KeyAr[J]);
        AddKeyAr.Clear;
        AddMainSettings(AddKeyAr);
        for K := 0 to AddKeyAr.Count - 1 do
        begin
          if FinalKeyAr.IndexOf(AddKeyAr[K]) = -1 then
            FinalKeyAr.Add(AddKeyAr[K]);
        end;
      end;
    end;

    {запомним значение св-ва Показывать лог формы frmSQLProcess;
    если Self.Silent, то перед активизацией настройки установим его в ложь,
    а потом вернем старое значение}

    if Self.Silent then
    begin
      if not Assigned(frmSQLProcess) then
        frmSQLProcess := TfrmSQLProcess.Create(Owner);

      ShowSQL := frmSQLProcess.Silent;
      try
        frmSQLProcess.Silent := True;
        _ActivateSetting(FinalKeyAr.CommaText, Silent, AnModalSQLProcess and not Silent, Lo(AnAnswer), Hi(AnAnswer));
      finally
        frmSQLProcess.Silent := ShowSQL;
      end;
    end else
    begin
      with TActivateSetting.Create(Application) do
      begin
        SettingKeys := FinalKeyAr.CommaText;
        PostMessage(Handle, WM_ACTIVATESETTING, AnAnswer,
          Integer(AnModalSQLProcess));
      end;
    end;

  finally
    if WasCreate then
      KeyAr.Free;
    AddKeyAr.Free;
    FinalKeyAr.Free;
  end;
end;


function TgdcSetting.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCSETTING', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgSetting.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSetting.CheckSetting;
var
  NewRuidList: TStringList;
  I: Integer;
  HelpList: TStringList;
  stClass, stSubType: String;
  AXID, ADBID, AnID: Integer;
  C: TPersistentClass;
  Obj: TgdcBase;
  AnAnswer: Integer;
begin
  {Если мы в режиме загрузки настройки из потока, то мы должны сравнить
  содержимое загружаемой настройки и содержимое заменяемой настройки.
  Если в заменяемой натсройке присутствуют объекты, которые в новой версии
  настройки нет, то по подтверждению пользователя удалим эти объекты.
  Для функционирования сохраняется список руидов и соответствующих им классов и
  сабтайпов перед редактированием или удалением заменяемой настройки, настройкой из потока}
  if sLoadFromStream in BaseState then
  begin
    //Проверяем создали ли мы список руидов предыдущей настройки
    if Assigned(OldRuidList) and (OldRuidList.Count > 0) then
    begin
      NewRuidList := TStringList.Create;
      HelpList := TStringList.Create;
      try
        //Создаем список руидов загружаемой настройки
        LoadRUIDFromBlob(NewRuidList, FieldByName('data'));
        NewRuidList.Sort;

        for I := OldRuidList.Count - 1 downto 0 do
        begin
          //если руид не найден в новой натсройке
          if NewRuidList.IndexOf(OldRuidList[I]) = -1 then
          begin
            HelpList.CommaText := OldRuidList[I];
            AXID := StrToInt(HelpList[0]);
            ADBID := StrToInt(HelpList[1]);
            stClass := HelpList[2];
            if HelpList.Count = 4 then
              stSubType := HelpList[3]
            else
              stSubType := '';
            C := GetClass(stClass);
            //Удалять будем только объекты, которые мог создать пользователь
            if (C <> nil) and (C.InheritsFrom(TgdcMetaBase) or
              C.InheritsFrom(TgdcEvent) or C.InheritsFrom(TgdcFunction) or
              C.InheritsFrom(TgdcMacros) or C.InheritsFrom(TgdcReport) or
              C.InheritsFrom(TgdcSavedFilter))
            then
            begin
              AnID := gdcBaseManager.GetIDByRUID(AXID, ADBID);
              if AnID = -1 then
                Obj := nil
              else
                try
                  Obj := CgdcBase(C).CreateSingularByID(Self, Database, Transaction,
                    AnID, stSubType);
                except
                  Obj := nil;
                end;

              if Assigned(Obj) then
              begin
                try
                  if Obj.ClassType = TgdcSetting then
                    (Obj as TgdcSetting).DeactivateSetting
                  else
                  begin
                    Obj.Open;
                    if (Obj is TgdcMetaBase) and (Obj as TgdcMetaBase).IsUserDefined
                      or not(Obj is TgdcMetabase)
                    then
                    begin
                      AnAnswer := MessageBox(0, PChar('Объект ' + Obj.GetDisplayName(Obj.SubType) +
                        ' ' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                        ' с идентификатором ' + IntToStr(Obj.ID) + ' не найден в новой версии настройки. Удалить объект?'),
                        'Загрузка настройки', MB_ICONQUESTION or MB_YESNOCANCEL or MB_TASKMODAL);

                      if AnAnswer = IDCANCEL then
                        raise Exception.Create ('Загрузка настройки прервана!');

                      if AnAnswer = IDYES then
                        try
                          Obj.Delete;
                        except
                          on E: Exception do
                          begin
                            MessageBox(0, PChar('При удалении объекта ' + Obj.GetDisplayName(Obj.SubType) +
                              ' ' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                              ' с идентификатором ' + IntToStr(Obj.ID) + ' произошла ошибка: ' +
                              E.Message),
                              'Загрузка настройки', MB_ICONERROR or MB_OK or MB_TASKMODAL);
                          end;
                        end;
                    end;
                  end;
                finally
                  Obj.Free;
                end;
              end;
            end;
          end;
        end;
      finally
        OldRuidList.Clear;
        NewRuidList.Free;
        HelpList.Free;
      end;
    end;
  end;
end;

procedure TgdcSetting.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCSETTING', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  CheckSetting;
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}

end;

procedure TgdcSetting.DeactivateSetting;
begin
  // Если настройка активирована
  if FieldByName('Disabled').AsInteger = 0 then
  begin
    if Assigned(IBLogin) then
    begin
      IBLogin.AddEvent(
        'Деактивация настройки "' + ObjectName + '"',
        Self.ClassName,
        Self.ID);
    end;

    with TActivateSetting.Create(Application) do
    begin
      SettingKeys := IntToStr(ID);
      PostMessage(Handle, WM_DEACTIVATESETTING, 0, Integer(True));
    end;
  end;
end;

procedure TgdcSetting.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSETTING', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if (State in dsEditModes) and (sLoadFromStream in BaseState) then
      FieldByName('disabled').AsInteger := 1
    else if State = dsInsert then
      FieldByName('disabled').AsInteger := 0;

    if Trim(FieldByName('description').AsString) = '' then
      FieldByName('description').Asstring := FieldByName('name').AsString;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcSetting.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcSetting.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_setting';
end;

class function TgdcSetting.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByPosRUID;';
end;

class function TgdcSetting.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmSetting';
end;

procedure TgdcSetting.SaveToFile(const AFileName: String = ''; const ADetail: TgdcBase = nil;
  const BL: TBookmarkList = nil; const OnlyCurrent: Boolean = True; StreamFormat: TgsStreamType = sttUnknown);
var
  FN: String;
  FS: TFileStream;
  BlobStream: TStream;
  PackStream: TZCompressionStream;
  i: Integer;
  StreamSaver: TgdcStreamSaver;
begin
  // Получим формат сохраненных в блобе данных настройки
  BlobStream := CreateBlobStream(FieldByName('Data'), bmRead);
  try
    StreamFormat := GetStreamType(BlobStream);
  finally
    FreeAndNil(BlobStream);
  end;
  // Если по данным не смогли определить формат настройки, попробуем по данным хранилища настройки
  if StreamFormat = sttUnknown then
  begin
    BlobStream := CreateBlobStream(FieldByName('StorageData'), bmRead);
    try
      StreamFormat := GetStreamType(BlobStream);
    finally
      FreeAndNil(BlobStream);
    end;
  end;
  // Если и сейчас не смогли определить формат, значит настройка пуста, сохраним в старом бинарном формате
  if StreamFormat = sttUnknown then
    StreamFormat := sttBinaryOld;

  case StreamFormat of
    sttBinaryOld, sttBinaryNew:
      FN := QuerySaveFileName(AFileName, gsfExtension, gsfSaveDialogFilter);
    sttXML:
      FN := QuerySaveFileName(AFileName, xmlExtension, xmlDialogFilter);
  end;

  if FN > '' then
  begin
    FS := TFileStream.Create(FN, fmCreate);
    try

      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetProcessCaptionText('Сохранение настройки в файл...');

      if StreamFormat <> sttBinaryOld then
      begin
        StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
        try
          StreamSaver.ReadUserFromStream := Self.Silent;
          StreamSaver.Silent := Self.Silent;
          StreamSaver.ReplicationMode := Self.Silent;
          StreamSaver.StreamFormat := StreamFormat;

          StreamSaver.AddObject(Self, True);

          if StreamFormat <> sttBinaryNew then
          begin
            StreamSaver.SaveToStream(FS);
          end
          else
          begin
            // заголовок файла
            i := gsfID;
            FS.Write(i, SizeOf(i));
            i := gsfVersion;
            FS.Write(i, SizeOf(i));

            // сохраняем заголовок настройки в потоке
            with TSettingHeader.Create do
            try
              SetInfo(Self);
              SaveToStream(FS);
            finally
              Free;
            end;

            // сохраняем саму настройку в упакованный поток
            PackStream := TZCompressionStream.Create(FS, zcMax);
            try
              StreamSaver.SaveToStream(PackStream);
            finally
              PackStream.Free;
            end;
          end;
        finally
          StreamSaver.Free;
        end;
      end
      else
      begin
        // заголовок файла
        i := gsfID;
        FS.Write(i, SizeOf(i));
        i := gsfVersion;
        FS.Write(i, SizeOf(i));

        // сохраняем заголовок настройки в потоке
        with TSettingHeader.Create do
        try
          SetInfo(Self);
          SaveToStream(FS);
        finally
          Free;
        end;

        // сохраняем саму настройку в упакованный поток
        PackStream := TZCompressionStream.Create(FS, zcMax);
        try
          SaveToStream(PackStream, ADetail);
        finally
          PackStream.Free;
        end;
      end;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.Done;

    finally
      FS.Free;
    end;
  end;
end;

procedure TgdcSetting.LoadFromFile(const AFileName: String = '');
var
  FN: String;
  FS: TFileStream;
  MS: TMemoryStream;
  PackStream: TZDecompressionStream;
  SizeRead: Integer;
  Buffer: array[0..1023] of Char;
  TempInt: Integer;
  StreamSaver: TgdcStreamSaver;
  StreamType: TgsStreamType;
  ShowLog: Boolean;
begin

  if AFileName = '' then
    FN := QueryLoadFileName(AFileName, gsfExtension, gsfxmlDialogFilter)
  else
    FN := AFileName;

  if FN > '' then
  begin
    FS := TFileStream.Create(FN, fmOpenRead);
    try
      StreamType := GetStreamType(FS);
    finally
      FS.Free;
    end;

    // Если GetStreamType(FS) не смогла определить тип файла настройки, или передан файл нулевого размера
    if StreamType = sttUnknown then
      raise Exception.Create('Неизвестный тип настройки');

    // Если frmSQLProcess не создан, то создадим его здесь
    //  и запретим вылазить на экран
    if not Assigned(frmSQLProcess) then
      frmSQLProcess := TfrmSQLProcess.Create(Owner);

    ShowLog := frmSQLProcess.Silent;
    try
      frmSQLProcess.Silent := True;

      if StreamType = sttXML then
      begin
        // Настройка в XML формате
        FS := TFileStream.Create(FN, fmOpenRead);
        StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
        try
          StreamSaver.Silent := Self.Silent;
          StreamSaver.ReplicationMode := Self.Silent;
          StreamSaver.ReadUserFromStream := Self.Silent;
          StreamSaver.LoadFromStream(FS);
        finally
          StreamSaver.Free;
          FS.Free;
        end;
      end
      else
      begin
        // Обычная настройка в сжатом потоке
        with TGSFHeader.Create do
        try
          if GetGSFInfo(FN) then           // проверяем корректность файла
          begin
            FS := TFileStream.Create(FN, fmOpenRead);
            try
              FS.Position := 2*SizeOf(Integer) + Size + 1;
              PackStream := TZDecompressionStream.Create(FS);
              MS := TMemoryStream.Create;
              try
                repeat
                  SizeRead := PackStream.Read(Buffer, 1024);
                  MS.WriteBuffer(Buffer, SizeRead);
                until (SizeRead < 1024);
                MS.Position := 0;

                // Определим версию потока и способ загрузки
                MS.ReadBuffer(TempInt, SizeOf(TempInt));
                MS.Position := 0;
                if TempInt > 1024 then
                begin
                  StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
                  try
                    StreamSaver.Silent := Self.Silent;
                    StreamSaver.ReplicationMode := Self.Silent;
                    StreamSaver.ReadUserFromStream := Self.Silent;
                    StreamSaver.LoadFromStream(MS);
                  finally
                    StreamSaver.Free;
                  end;
                end
                else
                  Self.LoadFromStream(MS);
              finally
                MS.Free;
                PackStream.Free;
              end;
            finally
              FS.Free;
            end;
          end
          else
            inherited LoadFromFile(FN);
        finally
          Free;
        end;
      end;
    finally
      if Assigned(frmSQLProcess) then
        frmSQLProcess.Silent := ShowLog;
    end;
    Self.CloseOpen;
  end;
end;

procedure TgdcSetting.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByPosRUID') then
    S.Add(Format('EXISTS(SELECT id FROM at_settingpos WHERE settingkey = %s.%s AND ' +
      ' xid = :xid and dbid = :dbid) ', [GetListTableAlias, GetKeyField(GetSubType)]));
end;

procedure TgdcSetting.MakeOrder;
begin
  with Tgdc_dlgSettingOrder.Create(ParentForm) do
    try
      Setup(Self);
      ShowModal;
    finally
      Free;
    end;
end;

class function TgdcSetting.NeedDeleteTheSame(
  const SubType: String): Boolean;
begin
//Если мы при загрузке с потока нашли подобную настройку, то мы попытаемся ее удалить
//Это нужно для того, чтобы корректно перечитывались детальные к настройке объекты
//При удалении шапки настройки все детальные объекты удаляться, а затем нормально загрузяться из потока
//Если их не удалить, то могут остаться детальные объекты прошлой версии настройки
  Result := True;
end;

class function TgdcSetting.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcSetting.ReActivateSetting(BL: TBookmarkList);

  procedure SetDisabled;
  begin
    Edit;
    FieldByName('disabled').AsInteger := 1;
    Post;
  end;

var
  I: Integer;
begin
  if Assigned(BL) and (BL.Count = 1) then
    Bookmark := BL[0];

  if not Assigned(BL) or (BL.Count <= 1) then
  begin
    SetDisabled;
  end
  else
  begin
    for I := 0 to BL.Count - 1 do
    begin
      Bookmark := BL[I];
      SetDisabled;
    end;
  end;
  ActivateSetting(nil, BL);
end;

procedure TgdcSetting.SaveSettingToBlob(SettingFormat: TgsStreamType = sttUnknown);
var
  BlobStream: TStream;
  ibsqlPos: TIBQuery;
  C: TPersistentClass;
  Obj: TgdcBase;
  AnID: Integer;
  OS: TgdcObjectSet;
  MS: TMemoryStream;
  StorageName, Path: String;
  NewFolder: TgsStorageFolder;
  BranchName: String;
  L, I: Integer;
  SaveDetailObjects: Boolean;
  LStorage: TgsStorage;
  stValue: TgsStorageValue;
  PropertyList: TgdcPropertySets;
  Index: Integer;
  MistakeStr, OldSubType, OldClassName: String;
  ObjList: TStringList;
  DL: TgdKeyArray;

  WithDetailID: TID;
  StreamSaver: TgdcStreamSaver;
  StorageStream: TStream;
  PositionsCount: Integer;
begin
  Assert(atDatabase <> nil, 'Не загружена база атрибутов atDatabase');
  Assert(gdcBaseManager <> nil);

  if Assigned(IBLogin) then
  begin
    IBLogin.AddEvent(
      'Формирование настройки "' + ObjectName + '"',
      Self.ClassName,
      Self.ID);
  end;

  AddText('Сохранение данных хранилища в базу данных', clBlack);

  if GlobalStorage <> nil then
    GlobalStorage.SaveToDatabase;

  if UserStorage <> nil then
    UserStorage.SaveToDatabase;

  if CompanyStorage <> nil then
    CompanyStorage.SaveToDatabase;

  if not Self.Silent then
  begin
    AddText('Начата синхронизация триггеров и индексов', clBlack);
    //Т.к. в потоке могут оказаться триггеры и индексы и
    //мы не можем отследить изменение триггеров, а синхронизация
    //индексов проходит достаточно долго, чтобы выполнять ее каждый раз
    //при синхронизации БД, мы будем проводить синхронизацию
    //триггеров и индексов каждый раз при сохранении настройки
    atDatabase.SyncIndicesAndTriggers(Transaction);
    AddText('Закончена синхронизация триггеров и индексов', clBlack);
    AddText('Начато формирование настройки ' +
      FieldByName(GetListField(SubType)).AsString, clBlack);
  end;

  // Если не передан конкретный формат настройки, попробуем прочитать его из хранилища
  if SettingFormat = sttUnknown then
    SettingFormat := GetDefaultStreamFormat(True);

  //////////////////////////////////////////////////////////////
  // Превратим все записи в at_setting_storage в бизнес-объекты
  //
  ConvertStorageRecords(ID, Database);

  // если в опциях установлено "Сохранять настройки в новом формате"
  if SettingFormat <> sttBinaryOld then
  begin

    MS := TMemoryStream.Create;
    StorageStream := TMemoryStream.Create;
    try
      try
        StreamSaver := TgdcStreamSaver.Create(Self.Database, Self.Transaction);
        try
          StreamSaver.Silent := Self.Silent;
          StreamSaver.ReplicationMode := Self.Silent;
          StreamSaver.ReadUserFromStream := Self.Silent;
          StreamSaver.StreamFormat := SettingFormat;
          StreamSaver.SaveSettingDataToStream(MS, FieldByName(GetKeyField(SubType)).AsInteger);
          // 22.03.2010: Мы больше не используем отдельное сохранение хранилища
          //StreamSaver.SaveSettingStorageToStream(StorageStream, FieldByName(GetKeyField(SubType)).AsInteger);
        finally
          StreamSaver.Free;
        end;
      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          raise;
        end;
      end;

      Edit;
      try
        BlobStream := CreateBlobStream(FieldByName('Data'), bmWrite);
        try
          BlobStream.CopyFrom(MS, 0);
        finally
          FreeAndNil(BlobStream);
        end;

        FieldByName('modifydate').AsDateTime := Now;
        FieldByName('version').AsInteger := FieldByName('version').AsInteger + 1;

        Post;
      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          Cancel;
          raise;
        end;
      end;

      if not Self.Silent then
        AddText('Закончено формирование настройки ' +
          FieldByName(GetListField(SubType)).AsString, clBlack);

    finally
      StorageStream.Free;
      MS.Free;
    end;

  end
  else
  begin

    ibsqlPos := TIBQuery.Create(Self);
    try
      ibsqlPos.Transaction := ReadTransaction;

      if Assigned(frmStreamSaver) then
        frmStreamSaver.SetupProgress(1, 'Формирование настройки...');

      Edit;
      try
        BlobStream := CreateBlobStream(FieldByName('Data'), bmWrite);
        MS := TMemoryStream.Create;
        try
          PropertyList := TgdcPropertySets.Create;
          ObjList := TStringList.Create;
          DL := TgdKeyArray.Create;
          OS := TgdcObjectSet.Create(TgdcBase, '');
          PositionsCount := 0;
          try
            // вытянем позиции сохраняемой настройки
            ibsqlPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey ' +
              ' ORDER BY objectorder';
            ibsqlPos.ParamByName('settingkey').AsInteger := FieldByName(GetKeyField(SubType)).AsInteger;
            ibsqlPos.Open;
            while not ibsqlPos.Eof do
            begin
              Index := PropertyList.Add(ibsqlPos.FieldByName('xid').AsString + '_' +
                ibsqlPos.FieldByName('dbid').AsString,
                ibsqlPos.FieldByName('objectclass').AsString,
                ibsqlPos.FieldByName('subtype').AsString);
              PropertyList.Objects[Index].Add('ModifyFromStream',
                ibsqlPos.FieldByName('needmodify').AsVariant);
              //Если мы должны сохранить объект с детальными объектами, то занесем его id в список
              if ibsqlPos.FieldByName('withdetail').AsInteger = 1 then
              begin
                WithDetailID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
                  ibsqlPos.FieldByName('dbid').AsInteger, ReadTransaction);
                if WithDetailID > -1 then
                  DL.Add(WithDetailID)
                else
                begin
                  // Если работает репликатор, то не будем прерывать сохранение настройки
                  if not Self.Silent then
                  begin
                    raise Exception.Create('Не удалось получить идентификатор позиции настройки.'#13#10 +
                      'Проверьте целостность настройки!');
                  end;
                end;
              end;
              Inc(PositionsCount);
              ibsqlPos.Next;
            end;

            if Assigned(frmStreamSaver) then
              frmStreamSaver.SetupProgress(PositionsCount, 'Формирование настройки...');

            ibsqlPos.First;
            while not ibsqlPos.Eof do
            begin
              SaveDetailObjects := ibsqlPos.FieldByName('withdetail').AsInteger = 1;

              {при репликации добавление объекта, его РУИДА и сохр. настройки идет на одной транзакции}
              if Self.Silent and Transaction.InTransaction then
                AnID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
                  ibsqlPos.FieldByName('dbid').AsInteger, Transaction)
              else
                AnID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
                  ibsqlPos.FieldByName('dbid').AsInteger);
              //Сохраняем сами мета-данные в блоб-поле
              C := GetClass(ibsqlPos.FieldByName('objectclass').AsString);
              if C <> nil then
              begin
                if (C.ClassName <> OldClassName) or (ibsqlPos.FieldByName('subtype').AsString <> OldSubType) then
                begin
                  OldClassName := C.ClassName;
                  OldSubType := ibsqlPos.FieldByName('subtype').AsString;

                  Index := ObjList.IndexOf(C.ClassName + '('+ ibsqlPos.FieldByName('subtype').AsString + ')');
                  if Index = -1 then
                  begin
                    Obj := CgdcBase(C).CreateSubType(nil, ibsqlPos.FieldByName('subtype').AsString, 'ByID');
                    Obj.FReadUserFromStream := Self.Silent;
                    ObjList.AddObject(C.ClassName + '('+ ibsqlPos.FieldByName('subtype').AsString + ')', Obj);
                    ObjList.Sort;
                  end else
                    Obj := TgdcBase(ObjList.Objects[Index]);
                end;

                Obj.ID := AnID;
                Obj.Open;

                if Assigned(frmStreamSaver) then
                  frmStreamSaver.SetProcessText(ibsqlPos.FieldByName('category').AsString + ' ' +
                    ibsqlPos.FieldByName('objectname').AsString + #13#10 +
                      ' (XID = ' +  ibsqlPos.FieldByName('xid').AsString +
                      ', DBID = ' + ibsqlPos.FieldByName('dbid').AsString + ')');

                if Obj.RecordCount > 0 then    {!!!!!!!!!!!!!!!!!}
                begin
                  if (Obj is TgdcTableField)
                    and (StrIPos(USERPREFIX, Obj.FieldByName('fieldname').AsString) = 1)
                    and (Obj.FieldByname('crosstable').AsString > '') then
                  begin
                    OS.Add(Obj.FieldByname('crosstablekey').AsInteger, '', '', '');
                    Obj._SaveToStream(MS, OS, PropertyList, nil, DL, SaveDetailObjects);
                    OS.Remove(Obj.FieldByname('crosstablekey').AsInteger);
                  end else
                    Obj._SaveToStream(MS, OS, PropertyList, nil, DL, SaveDetailObjects);
                end
                else
                begin
                  // Если работает репликатор, то не будем прерывать сохранение настройки
                  if not Self.Silent then
                  begin
                    MistakeStr := 'Ошибка при сохранении объекта ' +
                      ibsqlPos.FieldByName('category').AsString + ' ' +
                      ibsqlPos.FieldByName('objectname').AsString + #13#10 +
                      ' (с ' +
                      ' XID = ' +  ibsqlPos.FieldByName('xid').AsString +
                      ' DBID = ' + ibsqlPos.FieldByName('dbid').AsString + ')' + #13#10 +
                      'Объект не найден!';
                    AddMistake(MistakeStr, clRed);
                    raise Exception.Create(MistakeStr);
                  end;
                end;
              end;

              if Assigned(frmStreamSaver) then
                frmStreamSaver.Step;

              ibsqlPos.Next;
            end;

            OS.SaveToStream(BlobStream);

          finally
            OS.Free;
            PropertyList.Free;
            DL.Free;

            for I := 0 to ObjList.Count - 1 do
            begin
              Obj := TgdcBase(ObjList.Objects[I]);
              ObjList.Objects[I] := nil;
              if Assigned(Obj) then
                FreeAndNil(Obj);
            end;
            ObjList.Free;
          end;

          BlobStream.CopyFrom(MS, 0);

        finally
          MS.Free;
          FreeAndNil(BlobStream);
        end;

        Post;

      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          Cancel;
          raise;
        end;
      end;

      // Сохраняем позиции хранилища
      Edit;
      try
        LStorage := nil;
        BlobStream := CreateBlobStream(FieldByName('StorageData'), bmWrite);
        try
          ibsqlPos.Close;
          ibsqlPos.SQL.Text :=
            'SELECT COUNT(*) AS StorPosCount FROM at_setting_storage WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
          ibsqlPos.ParamByName('settingkey').AsInteger := ID;
          ibsqlPos.Open;

          PositionsCount := ibsqlPos.FieldByName('STORPOSCOUNT').AsInteger;

          if PositionsCount > 0 then
          begin
            if Assigned(frmStreamSaver) then
              frmStreamSaver.SetupProgress(PositionsCount, 'Формирование настройки...');

            ibsqlPos.Close;
            ibsqlPos.SQL.Text :=
              'SELECT * FROM at_setting_storage WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
            ibsqlPos.ParamByName('settingkey').AsInteger := ID;
            ibsqlPos.Open;
            while not ibsqlPos.Eof do
            begin
              BranchName := ibsqlPos.FieldByName('branchname').AsString;

              if AnsiPos('\', BranchName) = 0 then
              begin
                Path := '';
                StorageName := BranchName;
              end else
              begin
                Path := System.Copy(BranchName, AnsiPos('\', BranchName), Length(BranchName) -
                  AnsiPos('\', BranchName) + 1);
                StorageName := AnsiUpperCase(System.Copy(BranchName, 1, AnsiPos('\', BranchName) - 1));
              end;
              if AnsiPos(st_root_Global, StorageName) = 1 then
              begin
                if LStorage <> GlobalStorage then
                begin
                  GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
                  LStorage := GlobalStorage;
                end;
              end
              else if AnsiPos(st_root_User, StorageName) = 1 then
              begin
                if LStorage <> UserStorage then
                begin
                  UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
                  LStorage := UserStorage;
                end;
              end
              else
                LStorage := nil;

              if LStorage = nil then
                NewFolder := nil
              else
                NewFolder := LStorage.OpenFolder(Path, False);

              if Assigned(NewFolder) and (ibsqlPos.FieldByName('valuename').AsString > '') then
                stValue := NewFolder.ValueByName(ibsqlPos.FieldByName('valuename').AsString)
              else
                stValue := nil;

              if Assigned(NewFolder) then
              begin
                if ibsqlPos.FieldByName('valuename').AsString > '' then
                begin
                  if Assigned(stValue) then
                  begin
                    BlobStream.WriteBuffer(cst_StreamValue[1], Length(cst_StreamValue));
                    L :=  Length(ibsqlPos.FieldByName('valuename').AsString);
                    BlobStream.WriteBuffer(L, Sizeof(L));
                    BlobStream.WriteBuffer(ibsqlPos.FieldByName('valuename').AsString[1], L);
                    L :=  Length(BranchName);
                    BlobStream.WriteBuffer(L, Sizeof(L));
                    BlobStream.WriteBuffer(BranchName[1], L);
                    stValue.SaveToStream(BlobStream);
                    AddText('Сохранение параметра ' + ibsqlPos.FieldByName('valuename').AsString +
                      ' ветки хранилища ' + BranchName, clBlue);
                  end else
                    raise EgdcIBError.Create(' Параметр ' +
                      ibsqlPos.FieldByName('valuename').AsString +
                      ' ветки хранилища ' + BranchName + ' не найден!');
                end else
                begin
                  L :=  Length(BranchName);
                  BlobStream.WriteBuffer(L, Sizeof(L));
                  BlobStream.WriteBuffer(BranchName[1], L);
                  NewFolder.SaveToStream(BlobStream);
                  AddText('Сохранение ветки хранилища ' + BranchName, clBlue);
                end;
                LStorage.CloseFolder(NewFolder);
              end else
                raise EgdcIBError.Create(
                  'Ветка хранилища "' + BranchName + '" не найдена!'#13#10#13#10 +
                  'В настройку можно добавлять только ветки или параметры'#13#10 +
                  'глобального хранилища или хранилища пользователя Администратор.');

              if Assigned(frmStreamSaver) then
                frmStreamSaver.Step;

              ibsqlPos.Next;
            end;
          end;
        finally
          FreeAndNil(BlobStream);
        end;

        FieldByName('modifydate').AsDateTime := Now;
        FieldByName('version').AsInteger := FieldByName('version').AsInteger + 1;

        Post;

      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          Cancel;
          raise;
        end;
      end;

      if not Self.Silent then
      begin
        if Assigned(frmStreamSaver) then
          frmStreamSaver.Done;

        AddText('Закончено формирование настройки '+
          FieldByName(GetListField(SubType)).AsString, clBlack);
      end;

    finally
      ibsqlPos.Free;
    end;
  end;
end;

procedure TgdcSetting.DoBeforeEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSETTING', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYDOBEFOREEDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREEDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'DOBEFOREEDIT', KEYDOBEFOREEDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if sLoadFromStream in BaseState then
  begin
    if not Assigned(OldRuidList) then
      OldRuidList := TStringList.Create;

    OldRuidList.Clear;
    LoadRUIDFromBlob(OldRuidList, FieldByName('data'), ID);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'DOBEFOREEDIT', KEYDOBEFOREEDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'DOBEFOREEDIT', KEYDOBEFOREEDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSetting.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSETTING', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if sLoadFromStream in BaseState then
  begin
    if not Assigned(OldRuidList) then
      OldRuidList := TStringList.Create
    else
      OldRuidList.Clear;
    LoadRUIDFromBlob(OldRuidList, FieldByName('data'), ID);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSetting.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCSETTING', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTING', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTING') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTING',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTING' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  CheckSetting;
  inherited;

  // Если объект загружается из потока, то запомним ключ загружаемой настройки
  if sLoadFromStream in BaseState then
    LastLoadedSettingKey := Self.ID;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTING', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTING', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSetting.ChooseMainSetting;
var
  KA: TgdKeyArray;
  V: OleVariant;
  I: Integer;
  RuidSl: TStringList;
begin
  Assert(gdcBaseManager <> nil);
  CheckBrowseMode;

  KA := TgdKeyArray.Create;
  RuidSl := TStringList.Create;
  try
    LoadMainSettingsID(KA);

    RuidSl.Clear;
    if ChooseItems(TgdcSetting, KA, V, 'gdcSetting') then
    begin
      for I := 0 to KA.Count - 1 do
      begin
        if (KA[I] <> ID) and (KA[I] <> -1) then
        begin
          RuidSl.Add(gdcBaseManager.GetRUIDStringByID(KA[I]));
        end;
      end;
      Edit;
      FieldByName('settingsruid').AsString := RuidSl.CommaText;
      Post;
    end;
  finally
    KA.Free;
    RuidSl.Free;
  end;
end;

procedure TgdcSetting.LoadMainSettingsID(KA: TgdKeyArray);
var
  RuidList: TStringList;
  RUID: TRUID;
  AnID: Integer;
  I: Integer;
begin
  CheckBrowseMode;
  Assert(gdcBaseManager <> nil);

  KA.Clear;
  RuidList := TStringList.Create;
  try
    RuidList.CommaText := FieldByName('settingsruid').AsString;
    for I := 0 to RuidList.Count - 1 do
    begin
      try
        RUID := StrToRUID(RuidList[I])
      except
        Edit;
        FieldByName('settingsruid').Clear;
        Post;
        Break;
      end;
      AnID := gdcBaseManager.GetIDByRUID(RUID.XID, RUID.DBID);
      if KA.IndexOf(AnID) = -1 then
        KA.Add(AnID);
     end;
  finally
    RuidList.Free;
  end;
end;

destructor TgdcSetting.Destroy;
begin
  if Assigned(OldRuidList) then
    FreeAndNil(OldRuidList);
  inherited;
end;

procedure TgdcSetting.ClearDependencies;
begin
  CheckBrowseMode;
  try
    Edit;
    FieldByName('settingsruid').Clear;
    Post;
  except
    Cancel;
    raise;
  end;
end;

procedure TgdcSetting.UpdateActivateError;
begin
  FActivateErrorDescription := ErrorMessageForSetting;
end;

{ TgdcSettingPos }

procedure TgdcSettingPos.ChooseNewItem;
var
  KeyArray: TgdKeyArray;
  V: OleVariant;
  Cl: TPersistentClass;
  Obj: TgdcBase;
  WithDetail: Boolean;
  AnAnswer: Integer;

begin
  KeyArray := TgdKeyArray.Create;
  with Tgdc_dlgSettingPos.Create(ParentForm) do
  begin
    try
      if ShowModal = mrOk then
      begin
        Cl := FindClass(ObjectClassName);
        if (Cl <> nil) then
        begin
          if (Cl.InheritsFrom(TgdcBase)) then
          begin
            Obj := CgdcBase(Cl).Create(Self);

            try
              if Obj.ChooseItems(V, ChooseObjectName, '') then
              begin
                AnAnswer := MessageBox(HWND(nil), PChar('Сохранять выбранные объекты ' +
                  ' вместе с детальными?'), 'Внимание!',
                  MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL);

                if AnAnswer = IDCANCEL then
                  Exit;

                Obj.SubSet := 'OnlySelected';
                Obj.Open;
                Obj.First;

                WithDetail := (not Obj.Eof) and (AnAnswer = IDYES);

                while not Obj.Eof do
                begin
                  AddPos(Obj, WithDetail);
                  Obj.Next;
                end;

              end;
            finally
              Obj.Free;
            end;
          end;
        end;
       end;
    finally
      Free;
      KeyArray.Free;
    end;
  end;
end;

procedure TgdcSettingPos.DoAfterOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSETTINGPOS', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTINGPOS', KEYDOAFTEROPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEROPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTINGPOS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTINGPOS',
  {M}          'DOAFTEROPEN', KEYDOAFTEROPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTINGPOS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('objectorder').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTINGPOS', 'DOAFTEROPEN', KEYDOAFTEROPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTINGPOS', 'DOAFTEROPEN', KEYDOAFTEROPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSettingPos.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSETTINGPOS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTINGPOS', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTINGPOS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTINGPOS',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTINGPOS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if (State = dsInsert) and (FieldByName('objectorder').IsNull)
    then
      FieldByName('objectorder').AsInteger := GetLastOrder;//FieldByName('id').AsInteger;
  end;

  if (FieldByName('xid').AsInteger = FieldByName('settingkey').AsInteger) and
    (FieldByName('dbid').AsInteger = IBLogin.DBID)
  then
    raise Exception.Create('Попытка зацикливания!');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTINGPOS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTINGPOS', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcSettingPos.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'objectname';
end;

class function TgdcSettingPos.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'at_settingpos';
end;

function TgdcSettingPos.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCSETTINGPOS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTINGPOS', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTINGPOS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTINGPOS',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTINGPOS' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet('BySetting') then
    Result := 'ORDER BY z.objectorder';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTINGPOS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTINGPOS', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcSettingPos.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'BySetting;ByRUID;';
end;

procedure TgdcSettingPos.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('BySetting') then
    S.Add('z.settingkey = :settingkey');
  if HasSubSet('ByRUID') then
    S.Add('z.xid = :xid AND dbid = :dbid');
end;

procedure TgdcSettingPos.AddPos(AnObject: TgdcBase; const WithDetail: Boolean);
var
  AXID, ADBID: TID;
  ibsql, ibsqlID: TIBSQL;
  DL: TObjectList;
  C: TgdcFullClass;
  Obj: TgdcBase;
  Obj2: TgdcTree;
  DidActivate: Boolean;
  I: Integer;
  WasSynch: Boolean;
  gdcIndex: TgdcIndex;
  gdcTrigger: TgdcTrigger;
  gdcFunction: TgdcFunction;
  gdcObject: TgdcBase;
  LBRBTree: TLBRBTreeMetaNames; 
  BaseTableTriggersName: TBaseTableTriggersName;
begin
  Assert(HasSubSet('BySetting'));
  Assert(Active);

  if (AnObject is TgdcView) then
  begin
    ibsql := CreateReadIBSQL;
    ibsqlID := CreateReadIBSQL;
    try
      ibsql.SQL.Text := Format('SELECT * FROM rdb$view_relations WHERE  '+
        ' rdb$view_name = ''%s'' ',
        [AnObject.FieldByName('relationname').AsString]);
      ibsql.ExecQuery;
      while not ibsql.Eof do
      begin
        ibsqlID.Close;
        ibsqlID.SQL.Text := 'SELECT id, relationtype FROM at_relations WHERE relationname = :rn';
        ibsqlID.ParamByName('rn').AsString := ibsql.FieldByName('rdb$relation_name').AsString;

        ibsqlID.ExecQuery;
        if not ibsqlID.EOF then
        begin
          if ibsqlID.FieldByName('relationtype').AsString = 'V' then
            gdcObject := TgdcView.CreateSubType(nil, '', 'ByID')
          else
            gdcObject := CgdcBase(TgdcBaseTable).CreateSubType(nil, '', 'ByID');
          try
            gdcObject.ID := ibsqlID.FieldByName('id').AsInteger;
            gdcObject.Open;
            if (gdcObject.ID <> ID) and (not gdcObject.EOF) then
              AddPos(gdcObject, WithDetail);
          finally
            gdcObject.Free;
          end;
        end;

        ibsqlID.Close;
        ibsqlID.SQL.Text := 'SELECT id, fieldname FROM at_relation_fields WHERE relationname = :rn AND fieldname LIKE ''USR$%''';
        ibsqlID.ParamByName('rn').AsString := ibsql.FieldByName('rdb$relation_name').AsString;

        ibsqlID.ExecQuery;
        if ibsqlID.RecordCount > 0 then
        begin
          gdcObject := CgdcBase(TgdcRelationField).CreateSubType(nil, '', 'ByID');
          try
            while not ibsqlID.Eof do
            begin
              gdcObject.Close;
              gdcObject.ID := ibsqlID.Fields[0].AsInteger;
              gdcObject.Open;
              if (gdcObject.ID <> AnObject.ID) and (gdcObject.RecordCount > 0) then
                AddPos(gdcObject, WithDetail);

              ibsqlID.Next;
            end;
          finally
            gdcObject.Free;
          end;
        end;

        ibsql.Next;
      end;
    finally
      ibsql.Free;
      ibsqlID.Free;
    end;
  end;

  {если на одной транзакции создался и AnObject, и настройка, и РУИД - и такое бывает!}
  gdcBaseManager.GetRUIDByID(AnObject.ID, AXID, ADBID, Transaction);

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;
    DidActivate := False;
    try
      DidActivate := ActivateTransaction;
      ibsql.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey ' +
        ' AND xid = :xid AND dbid = :dbid';
      ibsql.ParamByName('settingkey').AsInteger := ParamByName('settingkey').AsInteger;
      ibsql.ParamByName('xid').AsInteger := AXID;
      ibsql.ParamByName('dbid').AsInteger := ADBID;
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        try
          Insert;
          if FieldByName('settingkey').IsNull or (FieldByName('settingkey').AsInteger = -1) then
            FieldByName('settingkey').AsInteger := ParamByName('settingkey').AsInteger;

          if AnObject.FieldByName(AnObject.GetListField(AnObject.SubType)).AsString > '' then
            FieldByName('objectname').AsString := AnObject.FieldByName(AnObject.GetListField(AnObject.SubType)).AsString
          else
            FieldByName('objectname').AsString := cst_str_WithoutName;
          FieldByName('category').AsString := AnObject.GetDisplayName(AnObject.SubType);
          FieldByName('objectclass').AsString := AnObject.GetCurrRecordClass.gdClass.ClassName;
          FieldByName('subtype').AsString := AnObject.GetCurrRecordClass.SubType;
          FieldByName('xid').AsInteger := AXID;
          FieldByName('dbid').AsInteger := ADBID;
          FieldByName('needmodify').AsInteger := Integer(AnObject.NeedModifyFromStream(AnObject.SubType));
          if (AnObject is TgdcIndex) or (AnObject is TgdcTrigger) or
           (AnObject is TgdcRelationField)
          then
          begin
            FieldByName('mastercategory').AsString := cst_strTable;
            FieldByName('mastername').AsString := AnObject.FieldByName('relationname').AsString;
          end
          else if (AnObject is TgdcEvent) then
          begin
            FieldByName('objectname').AsString := AnObject.FieldByName('objectname').AsString +
              FieldByName('objectname').AsString;
            FieldByName('mastercategory').AsString := cst_strForm;
            FieldByName('mastername').AsString := AnObject.FieldByName('parentname').AsString;
          end;

          if WithDetail then
            FieldByName('withdetail').AsInteger := 1
          else
            FieldByName('withdetail').AsInteger := 0;

          Post;
        except
          Cancel;
          raise;
        end;
      end;

      if AnsiCompareText(AnObject.GetCurrRecordClass.gdClass.ClassName, 'TgdcLBRBTreeTable') = 0 then
        GetLBRBTreeDependentNames(AnObject.FieldByName('relationname').AsString, Transaction, LBRBTree)
      else
        InitLBRBTreeDependentNames(LBRBTree);

      if (AnsiCompareText(AnObject.GetCurrRecordClass.gdClass.ClassName, 'TgdcPrimeTable') = 0)
        or (AnsiCompareText(AnObject.GetCurrRecordClass.gdClass.ClassName, 'TgdcTableToTable') = 0) then
        GetBaseTableTriggersName(AnObject.FieldByName('relationname').AsString, Transaction, BaseTableTriggersName, True)
      else
        if (AnsiCompareText(AnObject.GetCurrRecordClass.gdClass.ClassName, 'TgdcSimpleTable') = 0)
          or (AnsiCompareText(AnObject.GetCurrRecordClass.gdClass.ClassName, 'TgdcTreeTable') = 0) then
          GetBaseTableTriggersName(AnObject.FieldByName('relationname').AsString, Transaction, BaseTableTriggersName)
        else
          InitBaseTableTriggersName(BaseTableTriggersName);

      if DidActivate and Transaction.InTransaction then
        Transaction.Commit;
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    ibsql.Free;
  end;

  if (AnObject is TgdcMetaBase) and WithDetail then
  begin
      // теперь надо сохранить все детальные объекты
  // детальный объект мы создаем следующим образом:
  // 1. строим список фореин ключей, ссылающихся на нашу таблицу
  // !!!!! и на связанные с ней таблицы
  // 2. из списка берем только те ключи, которые состоят из
  //    одного поля и тип домена которых
  //    DMASTERKEY
  // 3. находим базовые классы для таблиц, для которых
  //    созданы эти ключи
  // 4. создаем экземпляры объектов по найденным классам
  // 5. устанавливаем дополнительное условие: ссылка на
  //    мастер запись
  // 6. открываем датасет с примененным условием
  // 7. сохраняем все его записи в настройке
    DL := TObjectList.Create(False);
    ibsql := TIBSQL.Create(nil);
    gdcTrigger := TgdcTrigger.Create(nil);
    gdcIndex := TgdcIndex.Create(nil);
    DidActivate := False;
    WasSynch := IsSynchTriggersAndIndices = False;
    if WasSynch then
      IsSynchTriggersAndIndices := True;
    try
      ibsql.Transaction := Transaction;
      try
        if WasSynch then
        begin
          gdcIndex.SyncIndices((AnObject as TgdcMetaBase).RelationName);
          gdcTrigger.SyncTriggers((AnObject as TgdcMetaBase).RelationName);
        end;
        DidActivate := ActivateTransaction;

        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
          AnObject.GetListTable(AnObject.SubType), DL, True);

        for I := 0 to DL.Count - 1 do
        begin
          if TatForeignKey(DL[I]).IsSimpleKey and
            (TatForeignKey(DL[I]).ConstraintField.Field.FieldName = 'DMASTERKEY') then
          begin
            ibsql.Close;
            //Мы не проверяем наши таблицы на простой
            //первичный ключ, т.к. в список могли попасть
            //только такие таблицы
            ibsql.SQL.Text := Format('SELECT %s FROM %s WHERE %s = %s ',
              [TatForeignKey(DL[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
              TatForeignKey(DL[I]).Relation.RelationName,
              TatForeignKey(DL[I]).ConstraintField.FieldName,
              AnObject.FieldByName(GetKeyField(AnObject.SubType)).AsString]);
            ibsql.ExecQuery;
            if ibsql.RecordCount > 0 then
            begin
              //Находим базовый класс
              C := GetBaseClassForRelation(TatForeignKey(DL[I]).Relation.RelationName);
              if C.gdClass <> nil then
              begin
                //Создаем его экземпляр с одной записью
                Obj := C.gdClass.CreateSingularByID(nil, Database, Transaction,
                  ibsql.Fields[0].AsInteger, C.SubType);
                try
                  Obj.Open;
                  //Находим класс для записи
                  C := Obj.GetCurrRecordClass;
                finally
                  Obj.Free;
                end;
              end;

              //Таким образом мы вытянули класс именно для наших записей
              if C.gdClass <> nil then
              begin
                Obj := C.gdClass.CreateSubType(nil, C.SubType, 'ByID');
                try
                  Obj.Database := Database;
                  Obj.Transaction := Transaction;
                  while not ibsql.Eof do
                  begin
                    Obj.ID := ibsql.Fields[0].AsInteger;
                    Obj.Open;
                    if (not Obj.EOF) and (Obj is TgdcMetaBase) and
                      (TgdcMetaBase(Obj).IsUserDefined) and (not TgdcMetaBase(Obj).IsDerivedObject) then
                    begin
                      //Мы будем сохранять в настройке только пользовательские мета-данные
                      if Obj is TgdcIndex then
                      begin
                        if (AnsiCompareText(Obj.FieldByName('indexname').AsString, LBRBTree.LBIndexName) <> 0)
                          and (AnsiCompareText(Obj.FieldByName('indexname').AsString, LBRBTree.RBIndexName) <> 0) then
                        begin
                          AddPos(Obj, WithDetail);
                        end;
                      end
                      else
                        if Obj is TgdcTrigger then
                        begin
                          if (AnsiCompareText(Obj.FieldByName('triggername').AsString, LBRBTree.BITriggerName) <> 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, LBRBTree.BUTriggerName) <> 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, LBRBTree.BI5TriggerName) <> 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, LBRBTree.BU5TriggerName) <> 0)
                            and (StrIPos(';' + Obj.FieldByName('triggername').AsString + ';', ';' + BaseTableTriggersName.CrossTriggerName) = 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, BaseTableTriggersName.BITriggerName) <> 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, BaseTableTriggersName.BI5TriggerName) <> 0)
                            and (AnsiCompareText(Obj.FieldByName('triggername').AsString, BaseTableTriggersName.BU5TriggerName) <> 0) then
                          begin
                            AddPos(Obj, WithDetail);
                          end;
                        end else
                          AddPos(Obj, WithDetail);
                    end;
                    Obj.Close;
                    ibsql.Next;
                  end;
                finally
                  Obj.Free;
                end;
              end;

            end;
          end;
        end;

        if DidActivate and Transaction.InTransaction then
          Transaction.Commit;
      except
        if DidActivate and Transaction.InTransaction then
          Transaction.Rollback;
        raise;
      end;
    finally
      DL.Free;
      ibsql.Free;
      gdcTrigger.Free;
      gdcIndex.Free;
      if WasSynch then
        IsSynchTriggersAndIndices := False;
    end;
  end else
  //Если переданный объект метод или событие, то вытянем в настройку его скрипт-функцию
  if AnObject is TgdcEvent then
  begin
    gdcFunction := TgdcFunction.CreateSubType(Self, '', 'ByID');
    try
      gdcFunction.ID := AnObject.FieldByName('functionkey').AsInteger;
      gdcFunction.Open;
      if gdcFunction.RecordCount > 0 then
      begin
        AddPos(gdcFunction, WithDetail);
      end;
    finally
      gdcFunction.Free;
    end;
  end;

  //Если переданный объект дерево
  if (AnObject is TgdcTree) and WithDetail then
  begin
    C := AnObject.GetCurrRecordClass;

    if C.gdClass.InheritsFrom(TgdcUserDocument) then
      C.gdClass := TgdcUserDocumentLine;

    if C.gdClass.InheritsFrom(TgdcTree) then
    begin
      Obj2 := C.gdClass.CreateSubType(nil,
        C.SubType, 'ByParent') as TgdcTree;
      try
        Obj2.Parent := AnObject.ID;
        Obj2.Open;
        while not Obj2.EOF do
        begin
          AddPos(Obj2, WithDetail);
          Obj2.Next;
        end;
      finally
        Obj2.Free;
      end;
    end;
  end;
end;

class function TgdcSettingPos.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

function TgdcSettingPos.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCSETTINGPOS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSETTINGPOS', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSETTINGPOS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSETTINGPOS',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSETTINGPOS' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM at_settingpos WHERE settingkey = :settingkey ' +
      ' AND xid = :xid AND dbid = :dbid'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM at_settingpos WHERE settingkey = %d ' +
      ' AND xid = %d AND dbid = %d',
      [FieldByName('settingkey').AsInteger,
       FieldByName('xid').AsInteger,
       FieldByName('dbid').AsInteger]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSETTINGPOS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSETTINGPOS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcSettingPos.SetWithDetail(const Value: Boolean; BL: TBookmarkList);
var
  I: Integer;
  Question: String;
begin
  CheckBrowseMode;
  if Value then
    Question := 'Установить флаг "Сохранять объекты вместе с детальными" %s ?'
  else
    Question := 'Установить флаг "Сохранять объекты без детальных" %s ?';
  if (BL = nil) or (BL.Count <= 1) then
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для записи ' + FieldByName(GetListField(SubType)).AsString])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    Edit;
    FieldByName('withdetail').AsInteger := Integer(Value);
    Post;
  end else
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для ' + IntToStr(BL.Count) + ' записей'])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    for I := 0 to BL.Count - 1 do
    begin
      Bookmark := BL[I];
      Edit;
      FieldByName('withdetail').AsInteger := Integer(Value);
      Post;
    end;
  end;
end;

procedure TgdcSettingPos.Valid(const DoAutoDelete: Boolean = false);
var
  AnID: Integer;
  C: TPersistentClass;
  Obj: TgdcBase;
  WasDelete: Boolean;

  MasterSilentMode: Boolean;
begin
  Assert(Active, 'Объект не активен. Проверка корректности невозможна');
  Assert(gdcBaseManager <> nil);

  if Assigned(Self.MasterSource) then
    MasterSilentMode := TgdcSetting(Self.MasterSource.Dataset).Silent
  else
    MasterSilentMode := False;

  WasDelete := False;
  First;
  while not Eof do
  begin
    AnID := gdcBaseManager.GetIDByRUID(FieldByName('xid').AsInteger,
      FieldByName('dbid').AsInteger);

    C := GetClass(FieldByName('objectclass').AsString);
    if C <> nil then
    begin
      try
        Obj := CgdcBase(C).CreateSingularByID(Self,
          AnID, FieldByName('subtype').AsString);
        try
          Obj.Open;
          if System.Copy(Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString,
            1, Self.FieldByName('objectname').Size) <>
            Self.FieldByName('objectname').AsString
          then
          begin
            Self.Edit;
            Self.FieldByName('objectname').AsString := System.Copy(
              Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString,
              1, Self.FieldByName('objectname').Size);
            if Self.FieldByName('objectname').AsString = '' then
              Self.FieldByName('objectname').AsString := cst_str_WithoutName;
            Self.Post;
          end;
        finally
          Obj.Free;
        end;
      except
        if DoAutoDelete then
        begin
          Delete;
          WasDelete := True;
        end
        else
        begin
          if MasterSilentMode then
          begin
            raise Exception.Create(' Ошибка при считывании объекта ' +
              FieldByName('category').AsString + ' ' +
              FieldByName('objectname').AsString + #13#10 +
              ' (с XID = ' + FieldByName('xid').AsString +
              '   DBID = ' + FieldByName('dbid').AsString + ')');
          end
          else
          begin
            if (MessageBox(0, PChar(' Ошибка при считывании объекта ' +
              FieldByName('category').AsString + ' ' +
              FieldByName('objectname').AsString + #13#10 +
              ' (с XID = ' + FieldByName('xid').AsString +
              '   DBID = ' + FieldByName('dbid').AsString + ')' + #13#10 +
              'Удалить позицию настройки?'), 'Ошибка',
              MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES) then
            begin
              Delete;
              WasDelete := True;
            end;
          end;
        end;
      end;
    end
    else
    begin
      if DoAutoDelete then
      begin
        Delete;
        WasDelete := True;
      end
      else
      begin
        if MasterSilentMode then
        begin
          raise Exception.Create(' Ошибка при считывании объекта ' +
            FieldByName('category').AsString + ' ' +
            FieldByName('objectname').AsString + #13#10 +
            ' (с XID = ' + FieldByName('xid').AsString +
            '   DBID = ' + FieldByName('dbid').AsString + ')');
        end
        else
        begin
          if (MessageBox(0, PChar(' Ошибка при считывании объекта ' +
            FieldByName('category').AsString + ' ' +
            FieldByName('objectname').AsString + #13#10 +
            ' (с XID = ' + FieldByName('xid').AsString +
            '   DBID = ' + FieldByName('dbid').AsString + ')' + #13#10 +
            'Удалить позицию настройки?'), 'Ошибка',
            MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES) then
          begin
            Delete;
            WasDelete := True;
          end;
        end;
      end;
    end;

    if WasDelete then
      WasDelete := False
    else
      Next;
  end;
end;

procedure TgdcSettingPos.SetNeedModify(const Value: Boolean;
  BL: TBookmarkList);
var
  I: Integer;
  Question: String;
begin
  CheckBrowseMode;
  if Value then
    Question := 'Установить флаг "Перезаписывать объект данными из потока" %s ?'
  else
    Question := 'Снять флаг "Перезаписывать объект данными из потока" %s ?';
  if (BL = nil) or (BL.Count <= 1) then
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для записи ' + FieldByName(GetListField(SubType)).AsString])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    Edit;
    FieldByName('needmodify').AsInteger := Integer(Value);
    Post;
  end else
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для ' + IntToStr(BL.Count) + ' записей'])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    for I := 0 to BL.Count - 1 do
    begin
      Bookmark := BL[I];
      Edit;
      FieldByName('needmodify').AsInteger := Integer(Value);
      Post;
    end;
  end;
end;

procedure TgdcSettingPos.SetNeedInsert(const Value: Boolean;
  BL: TBookmarkList);
var
  I: Integer;
  Question: String;
begin
  CheckBrowseMode;
  if Value then
    Question := 'Установить флаг "Добавлять новый объект" %s ?'
  else
    Question := 'Снять флаг "Добавлять новый объект" %s ?';
  if (BL = nil) or (BL.Count <= 1) then
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для записи ' + FieldByName(GetListField(SubType)).AsString])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    Edit;
    FieldByName('needinsert').AsInteger := Integer(Value);
    Post;
  end else
  begin
    if MessageBox(0, PChar(Format(Question,
      ['для ' + IntToStr(BL.Count) + ' записей'])),
      'Внимание!', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
    then
      Exit;

    for I := 0 to BL.Count - 1 do
    begin
      Bookmark := BL[I];
      Edit;
      FieldByName('needinsert').AsInteger := Integer(Value);
      Post;
    end;
  end;
end;

procedure TgdcSettingPos.SetNeedModifyDefault;
var
  ibsql: TIBSQL;
  C: TPersistentClass;
begin
  Assert(Active, 'Объект не активен. Проверка корректности невозможна');
  CheckBrowseMode;
  ibsql := CreateReadIBSQL;
  First;
  try
    while not Eof do
    begin
      C := GetClass(FieldByName('objectclass').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase) then
      begin
        Edit;
        FieldByName('needmodify').AsInteger :=
          Integer(CgdcBase(C).NeedModifyFromStream(FieldByName('subtype').AsString));
        Post;
      end else
      if MessageBox(0, PChar(' Ошибка при считывании объекта ' +
        FieldByName('category').AsString + ' ' +
        FieldByName('objectname').AsString + #13#10 +
        ' (с XID = ' +  FieldByName('xid').AsString +
        '   DBID = ' + FieldByName('dbid').AsString + ')'#13#10 +
        ' Класс ' + FieldByName('objectclass').AsString + ' не найден!' + #13#10 +
        'Удалить позицию настройки?'), 'Ошибка',
        MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES
      then
      begin
        Delete;
      end;

      Next;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcSettingPos.GetLastOrder: Integer;
var
  ibtr: TIBTRansaction;
begin
  Assert(FieldByName('settingkey').AsInteger > 0);
  if not Assigned(FLastOrderSQL) then
  begin
    FLastOrderSQL := TIBSQL.Create(Self);
    FLastOrderSQL.SQL.Text := 'SELECT MAX(objectorder) as objorder FROM at_settingpos WHERE settingkey = :sk';
  end;

  FLastOrderSQL.Close;
  if Transaction.InTransaction then
    ibtr := Transaction
  else
    ibtr := ReadTransaction;

  if FLastOrderSQL.Transaction <> ibtr then
  begin
    FLastOrderSQL.Transaction := ibtr;
  end;

  try
    FLastOrderSQL.ParamByName('sk').AsInteger := FieldByName('settingkey').AsInteger;
    FLastOrderSQL.ExecQuery;

    if FLastOrderSQL.RecordCount > 0 then
    begin
      Result := FLastOrderSQL.FieldByName('objorder').AsInteger + 1;
    end else
      Result := 0;
  finally
    FLastOrderSQL.Close;
  end;
end;

constructor TgdcSettingPos.Create(AnOwner: TComponent);
begin
  inherited;
  FLastOrderSQL := nil;
end;

destructor TgdcSettingPos.Destroy;
begin
  if Assigned(FLastOrderSQL) then
    FLastOrderSQL.Free;
  inherited;
end;

function TgdcSettingPos.CopyToSetting(const ASettingKey: TID): Boolean;
var
  TestSetting: TgdcSetting;
begin
  Result := False;

  // Проверим, существует ли указанная настройка
  TestSetting := TgdcSetting.CreateWithID(nil, Database, Transaction, ASettingKey);
  try
    if Assigned(TestSetting) and (TestSetting.ID = ASettingKey) then
      raise EgdcIDNotFound.Create(Format('Настройка с идентификатором %d не существует.', [ASettingKey]));
  finally
    FreeAndNil(TestSetting);
  end;

  //Скопируемуем данные объекта в новый объект
  if Self.CopyObject then
  begin
    // Изменим ссылку на настройку
    Self.Edit;
    Self.FieldByName('SETTINGKEY').AsInteger := ASettingKey;
    Self.Post;

    Result := True;
  end;
end;

function TgdcSettingPos.MoveToSetting(const ASettingKey: TID): Boolean;
var
  OldSettingPosKey: TID;
begin
  Result := False;

  // Запомним ИД текущей позиции
  OldSettingPosKey := Self.ID;
  // Скопируем позицию
  if Self.CopyToSetting(ASettingKey) then
  begin
    // Пытаемся перейти на оригинальную позицию, и удаляем ее
    Self.ID := OldSettingPosKey;
    if Self.ID = OldSettingPosKey then
      Self.Delete;

    Result := True;  
  end;
end;

{ TgdcSettingStorage }

procedure TgdcSettingStorage.AddPos(ABranchName, AValueName: String);
begin
  Assert(ABranchName > '');
  Assert(HasSubSet('BySetting'));
  Assert(Active);

  Insert;
  FieldByName('settingkey').AsInteger := ParamByName('settingkey').AsInteger;
  FieldByName('branchname').AsString := ABranchName;
  FieldByName('valuename').AsString := AValueName;
  FieldByName('crc').AsInteger := GetCRC32FromText(ABranchName);
  Post;
end;

constructor TgdcSettingStorage.Create(AnOwner: TComponent);
begin
  inherited;
  CustomProcess := [cpInsert, cpDelete, cpModify];
end;

class function TgdcSettingStorage.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcSettingStorage.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'at_setting_storage';
end;

class function TgdcSettingStorage.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'BySetting;ByCRC;';
end;

procedure TgdcSettingStorage.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('BySetting') then
    S.Add('z.settingkey = :settingkey');

  if HasSubSet('ByCRC') then
    S.Add('z.crc = :crc');
end;

class function TgdcSettingStorage.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcSettingStorage.Valid;
var
  BranchName, Path, StorageName: String;
  LStorage: TgsStorage;
  NewFolder: TgsStorageFolder;
  stValue: TgsStorageItem;
  WasDelete: Boolean;
begin
  Assert(Active, 'Объект не активен. Проверка корректности невозможна');
  First;
  WasDelete := False;
  while not Eof do
  begin
    BranchName := FieldByName('branchname').AsString;

    if Pos('#', BranchName) = 1 then
    begin
      Next;
      continue;
    end;

    if AnsiPos('\', BranchName) = 0 then
    begin
      Path := '';
      StorageName := BranchName;
    end else
    begin
      Path := System.Copy(BranchName, AnsiPos('\', BranchName), Length(BranchName) -
        AnsiPos('\', BranchName) + 1);
      StorageName := AnsiUpperCase(System.Copy(BranchName, 1, AnsiPos('\', BranchName) - 1));
    end;
    if AnsiPos(st_root_Global, StorageName) = 1 then
    begin
      LStorage := GlobalStorage;
    end
    else if AnsiPos(st_root_User, StorageName) = 1 then
    begin
      LStorage := UserStorage;
    end
    else
      LStorage := nil;

    if LStorage = nil then
      NewFolder := nil
    else
      NewFolder := LStorage.OpenFolder(Path, False);

    if Assigned(NewFolder) and (FieldByName('valuename').AsString > '') then
      stValue := NewFolder.ValueByName(FieldByName('valuename').AsString)
    else
      stValue := nil;

    if Assigned(NewFolder) then
    begin
      if FieldByName('valuename').AsString > '' then
      begin
        if (not Assigned(stValue)) and (MessageBox(0, PChar(' Параметр ' +
          FieldByName('valuename').AsString +
          ' ветки хранилища ' + BranchName + ' не найден!'
          + #13#10 + 'Удалить позицию настройки?'), 'Ошибка',
          MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES)
        then
        begin
          Delete;
          WasDelete := True;
        end;
      end;
      LStorage.CloseFolder(NewFolder);
    end else
      if MessageBox(0, PChar('Ветка хранилища ' + BranchName + ' не найдена!'
       + #13#10 + 'Удалить позицию настройки?'), 'Ошибка',
        MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES
      then
      begin
        Delete;
        WasDelete := True;
      end;
    if WasDelete then
      WasDelete := False
    else
      Next;
  end;
end;

// ++++++++++++++++++++++++++++++ TSettingHeader ++++++++++++++++++++++++++++++
constructor TSettingHeader.Create;
begin
  inherited;

  InterRUID := TStringList.Create;
  Size := -1;
end;

destructor TSettingHeader.Destroy;
begin
  InterRUID.Free;

  inherited;
end;

// заполняет свойства объекта данными о настройке
procedure TSettingHeader.SetInfo(gdcObject: TgdcBase);
var
  XID, DBID: TID;
begin
  gdcBaseManager.GetRUIDByID(gdcObject.FieldByName('ID').AsInteger, XID, DBID, gdcObject.Transaction);
  RUID.XID  := XID;
  RUID.DBID := DBID;

  Name    := gdcObject.FieldByName('NAME').AsString;
  Comment := gdcObject.FieldByName('DESCRIPTION').AsString;
  Date    := gdcObject.FieldByName('MODIFYDATE').AsDateTime;
  Version := gdcObject.FieldByName('VERSION').AsInteger;   
  Ending  := gdcObject.FieldByName('ENDING').AsInteger;

  InterRUID.CommaText := gdcObject.FieldByName('SETTINGSRUID').AsString;
  MinExeVersion := gdcObject.FieldByName('MINEXEVERSION').AsString;
  MinDBVersion  := gdcObject.FieldByName('MINDBVERSION').AsString;
end;

procedure TSettingHeader.SaveToStream(Stream: TStream);
begin
  Stream.Write(RUID, SizeOf(TRUID));
  SaveStringToStream(Name, Stream);
  SaveStringToStream(Comment, Stream);
  Stream.Write(Date, SizeOf(Date));
  Stream.Write(Version, SizeOf(Version));
  Stream.Write(Ending, SizeOf(Ending));
  SaveStringToStream(InterRUID.Text, Stream);
  SaveStringToStream(MinExeVersion, Stream);
  SaveStringToStream(MinDBVersion, Stream);
end;

function TSettingHeader.LoadFromStream(Stream: TStream): Boolean;
var
  i: Integer;
begin
  Result := True;
  try
    Stream.Read(RUID, SizeOf(TRUID));
    Size := Size + SizeOf(TRUID);
    Name := ReadStringFromStream(Stream);
    Size := Size + Length(Name) + SizeOf(Integer);
    Comment := ReadStringFromStream(Stream);
    Size := Size + Length(Comment) + SizeOf(Integer);
    Stream.Read(Date, SizeOf(Date));
    Stream.Read(Version, SizeOf(Version));
    Stream.Read(Ending, SizeOf(Ending));
    Size := Size + SizeOf(Date) + SizeOf(Version) + SizeOf(Ending);

    InterRUID.Text := ReadStringFromStream(Stream);
    Size := Size + Length(InterRUID.Text) + SizeOf(Integer);

// +++ убираем не RUID'ы
    i := 0;
    while i < InterRUID.Count do
    begin
      if Length(InterRUID[i]) > 0 then
      begin
// удаляем кавычки, если есть
        if (InterRUID[i][1] = '''') and (InterRUID[i][Length(InterRUID[i])] = '''') then
          InterRUID[i] := Copy(InterRUID[i], 2, Length(InterRUID[i])-2);
// проверяем корректность RUID'а           
        try
          StrToRUID(InterRUID[i]);
        except
          InterRUID.Delete(i);
          Dec(i);
        end;
        Inc(i);
      end
      else
        InterRUID.Delete(i);
    end;
// --- убираем не RUID'ы

    MinExeVersion := ReadStringFromStream(Stream);
    Size := Size + Length(MinExeVersion) + SizeOf(Integer);
    MinDBVersion := ReadStringFromStream(Stream);
    Size := Size + Length(MinDBVersion) + SizeOf(Integer);
  except
    Result := False;
  end;
end;

constructor TGSFHeader.Create;
begin
  inherited;

// по умолчанию:
  VerInfo := svIndefinite;   // новизна не определена
  MaxVerInfo := svIndefinite;// (для промежуточных тоже)
  CorrectPack := True;       // пакет корректен
end;

destructor TGSFHeader.Destroy;
begin
  if Assigned(RealSetting) then
    RealSetting.Free;

  inherited;
end;

function TGSFHeader.GetFullCorrect: Boolean;
begin                                         
// пакет считается полностью_корректным, если он:
  Result := CorrectPack and            // корректен физически
            ( {(VerInfo < svEqual) or}   // его версия: более новая или он не установлен
              (MaxVerInfo <= OwnerList.VerInfoToInstall)) and   // или одна из его промеж. настроек является таковой
            (ApprVersion = []);        // подходит по версиям БД и EXE
end;

function TGSFHeader.GetGSFInfo(const FName: String): Boolean;
var
  FS: TFileStream;
begin
  FilePath := ExtractFilePath(FName);
  FileName := ExtractFileName(FName);

  FS := TFileStream.Create(FName, fmOpenRead);
  try
    Result := GetGSFInfo(FS);
  finally
    FS.Free;
  end;
end;

function TGSFHeader.GetGSFInfo(AStream: TStream): Boolean;
var
  i: Integer;
  StreamType: TgsStreamType;
  XMLSettingReader: TgdcStreamXMLWriterReader;
begin
  Result := False;

  StreamType := GetStreamType(AStream);
  // проверим формат настройки: архивная или XML
  if StreamType in [sttBinaryOld, sttBinaryNew] then
  begin
    AStream.Read(i, SizeOf(i));
    if i = gsfID then
    begin
      AStream.Read(i, SizeOf(i));
      GSFVersion := i;
      case i of
        1:
          begin
            Result := LoadFromStream(AStream);
          end;
      end;
    end;
  end
  else
  begin
    GSFVersion := 2;
    XMLSettingReader := TgdcStreamXMLWriterReader.Create;
    try
      Result := XMLSettingReader.GetXMLSettingHeader(AStream, Self);
    finally
      XMLSettingReader.Free;
    end;
  end;
end;

constructor TGSFList.Create;
begin
  inherited;

  Sorted := True;
  Duplicates := dupAccept;

  CurDBVersion := IBLogin.DBVersion;
  CurEXEVersion := GetCurEXEVersion;

  SettIDList := TStringList.Create;
  ProcessedRUIDList := TStringList.Create;
  CheckList := TStringList.Create;

  isYesToAll := False;
  VerInfoToInstall := svNewer;
end;

destructor TGSFList.Destroy;
begin
  Clear; // очищаем список перекрытым методом

  CheckList.Free;
  ProcessedRUIDList.Free;
  SettIDList.Free;

  inherited;
end;
            
function TGSFList.AddObject(const S: string; AObject: TObject): Integer;
begin
  Result := inherited AddObject(S, AObject);

  if Assigned(AObject) then
    (AObject as TGSFHeader).OwnerList := Self;
end;

procedure TGSFList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    if Assigned(Objects[i]) then
      (Objects[i] as TGSFHeader).Free;

  inherited;
end;

// проц. для рекурсивного перебора папок и поиска файлов настроек
procedure TGSFList.GetFilesForPath(Path: String; const lInfo: TLabel = nil);
// lInfo - компонент класса TLabel для отображения пути 
var
  sr: TSearchRec;
  FileAttrs: Integer;

  procedure SearchSettings(const Extension: String);
  var
    Header: TGSFHeader;
  begin
    if FindFirst(Path + '*.' + Extension, FileAttrs, sr) = 0 then
    begin
      Header := TGSFHeader.Create;
      if Header.GetGSFInfo(Path + sr.Name) then
        AddObject(RUIDToStr(Header.RUID), Header)
      else
        Header.Free;

      while FindNext(sr) = 0 do
      begin
        Header := TGSFHeader.Create;
        if Header.GetGSFInfo(Path + sr.Name) then
          AddObject(RUIDToStr(Header.RUID), Header)
        else
          Header.Free;
      end;
      SysUtils.FindClose(sr);
    end;
  end;

begin
  // отображаем путь
  if Assigned(lInfo) then
  begin
    lInfo.Caption := Path;
    lInfo.Refresh;
  end;

  // перебираем файлы
  FileAttrs := 0;
  FileAttrs := FileAttrs + faAnyFile;

  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  // Поищем GSF настройки
  SearchSettings(gsfExtension);
  // Поищем XML настройки
  SearchSettings(xmlExtension);

  // перебираем папки
  if FindFirst(Path + '*.*', FileAttrs, sr) = 0 then
  begin
    if ( (sr.Attr and faDirectory) = faDirectory) and
       (sr.Name <> '.') and (sr.Name <> '..') and (sr.Name <> '.svn') then
      GetFilesForPath(Path + sr.Name, lInfo);
    while FindNext(sr) = 0 do
    begin
      if ( (sr.Attr and faDirectory) = faDirectory) and  // если папка и
         ( (sr.Attr and faHidden) <> faHidden) and       // не HIDDEN и
         (sr.Name <> '.') and (sr.Name <> '..') then     // не ссылка на корень или уровень вверх
        GetFilesForPath(Path + sr.Name, lInfo);
    end;
    SysUtils.FindClose(sr);
  end;
end;

{ TODO : перенести isCorrect в Result }
function TGSFList.LoadInfoFor(aID: Integer; const aRUID, aPath: String; var Err: String;                       
  var MaxPackVerInfo: TSettingVersion; out isCorrect: Boolean{; const isForce: Boolean = False}): TSettingVersion;
var 
  k, ind: Integer;
  tmp_ind, tmp_ver: Integer;
  RealSettID: TID;
  RUID: TRUID;
  isFound: Boolean;

begin
  isCorrect := False;
  Result := svIncorrect;
  isFound := False;

  tmp_ind := -1;
  tmp_ver := 0;
  if (aID = -1) then         // настройка найдена в списке по RUID
  begin

    ind := IndexOf(aRUID);
    if ind > -1 then
    begin 
      while (ind <= Count-1) and                                   
            (RUIDToStr((Objects[ind] as TGSFHeader).RUID) = aRUID) do
      begin
        if (Objects[ind] as TGSFHeader).Ending = 1 then
        begin              // промежуточная конечная %)
          Result := svIndefinite;    // не интересует
          isCorrect := True;
          Exit;
        end else
        begin
          if (Objects[ind] as TGSFHeader).FilePath = aPath then
          begin                                 
            isFound := True; // промежуточная по нужному пути 
            Break;
          end else           // промежуточная по др. пути - ищем последнюю версию
            if (tmp_ind = -1) or
               (tmp_ver < (Objects[ind] as TGSFHeader).Version) then
            begin
              tmp_ind := ind;
              tmp_ver := (Objects[ind] as TGSFHeader).Version;
            end;
        end;
        ind := ind + 1;
      end;
    end;
  end else
  begin
    ind := aID;
    isFound := True;
  end;

  if not isFound and         // промежуточная найдена в другой папке
     (tmp_ind > -1) then
  begin
    isFound := True;
    ind := tmp_ind;
  end;

  if isFound then  // есть настройка с РУИДом aRUID по пути aPath (или передан ID)
  begin 
    isCorrect := True;
    if ((Objects[ind] as TGSFHeader).VerInfo = svIndefinite) or
      ((Objects[ind] as TGSFHeader).MaxVerInfo < (Objects[ind] as TGSFHeader).VerInfo) {or isForce }then      // новизна не определена
    begin

// +++ для конечной настройки определяем соответствие версий
      with (Objects[ind] as TGSFHeader) do
      if Ending = 1 then
      begin                          
        if (MinExeVersion > '') then  
          if TFLItem.CompareVersionStrings(MinExeVersion, CurExeVersion) > 0 then
            Include(ApprVersion, avNotApprEXEVersion);
        if (MinDBVersion > '') then
          if TFLItem.CompareVersionStrings(MinDBVersion, CurDBVersion) > 0 then
            Include(ApprVersion, avNotApprDBVersion);
      end;
// ---

// +++ проверяем новизну 
      RUID := StrToRUID(aRUID);
      RealSettID := gdcBaseManager.GetIDByRUID(RUID.XID, RUID.DBID);
      if RealSettID > -1 then
      begin
        gdcSetts.ID := RealSettID;
        gdcSetts.Open;
        if gdcSetts.RecordCount > 0 then
        begin

// +++ заполняем информацию о настройке в БД
          with (Objects[ind] as TGSFHeader) do
          begin
            if Ending = 1 then
            begin
              RealSetting := TSettingHeader.Create;
              RealSetting.ID := gdcSetts.ID;
              RealSetting.Version := gdcSetts.FieldByName('version').AsInteger;
              RealSetting.Date    := gdcSetts.FieldByName('modifydate').AsDateTime;
              RealSetting.Comment := gdcSetts.FieldByName('description').AsString;
              RealSetting.MinExeVersion := gdcSetts.FieldByName('minexeversion').AsString;
              RealSetting.MinDBVersion  := gdcSetts.FieldByName('mindbversion').AsString;
            end;
// --- информация о настройке в БД         

            // сравниваем версии
            if Version > gdcSetts.FieldByName('version').AsInteger then
              VerInfo := svNewer     // на диске - новая
            else
              if Version < gdcSetts.FieldByName('version').AsInteger then
                VerInfo := svOlder   // на диске - старая
              else
                if Version = gdcSetts.FieldByName('version').AsInteger then
                  VerInfo := svEqual;
          end
        end else   // настройка не установлена
          (Objects[ind] as TGSFHeader).VerInfo := svNotInstalled;
        gdcSetts.Close;
      end else     // в БД нет RUID'а
        (Objects[ind] as TGSFHeader).VerInfo := svNotInstalled;
// --- проверяем новизну


// пробегаем по промежуточным, фактически - проверяем корректность, но
// пока + ищем новые версии промежуточных настроек.
      with (Objects[ind] as TGSFHeader) do
      if VerInfo <= svEqual then      
      begin
        if InterRUID.Count > 0 then
        for k := 0 to InterRUID.Count-1 do
        begin            // получаем версию промежуточной
          LoadInfoFor(-1, InterRUID[k], FilePath, Err, MaxPackVerInfo, isCorrect);

//          if  (MaxPackVerInfo < VerInfo) then
//            MaxVerInfo := MaxPackVerInfo;

          if isCorrect = False then
          begin          // дальше смотреть смысла нет
            if Err = '' then
              Err := InterRUID[k] + Err
            else
              Err := InterRUID[k] + '/' + Err;
            CorrectPack := False;
            Break;
          end;
        end;
      end;

    end;
    Result := (Objects[ind] as TGSFHeader).VerInfo;
  end else
  begin
    RUID := StrToRUID(aRUID);
    RealSettID := gdcBaseManager.GetIDByRUID(RUID.XID, RUID.DBID);
    if RealSettID > -1 then
    begin
      gdcSetts.ID := RealSettID;
      gdcSetts.Open;
      if gdcSetts.RecordCount > 0 then
      begin                  // найдена и конечная => пакет корректен
        if gdcSetts.FieldByName('Ending').AsInteger = 1 then
          isCorrect := True; 
      end
    end
  end;
{  if MaxPackVerInfo > svEqual then
    if Result < svEqual then
      MaxPackVerInfo := Result
    else
  else}
    if MaxPackVerInfo > Result then
      MaxPackVerInfo := Result;
end;

function TGSFList.CheckedRUID(aRUID: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to CheckList.Count-1 do
    if RUIDToStr((Objects[StrToInt(CheckList[i])] as TGSFHeader).RUID) = aRUID then
    begin
      Result := StrToInt(CheckList[i]);
      Break;
    end;
end;

// получение полной информации о конечных настройках
procedure TGSFList.LoadPackageInfo{(const isForce: Boolean = False)};
var
  i: Integer;
  CP: Boolean;
  MaxVer: TSettingVersion;
  ErrMsg: String;
begin
  for i := 0 to Count-1 do
  begin
    with (Objects[i] as TGSFHeader) do
    if (Ending = 1) and                      
       ((VerInfo = svIndefinite) {or isForce}) then
    begin  
//      MaxVer := svEqual;
      ErrMsg := '';
      MaxVer := svOlder;
      LoadInfoFor(i, Strings[i], '', ErrMsg, MaxVer, CP{, isForce});  // Strings[i] хранит RUID
      MaxVerInfo := MaxVer;
      ErrMessage := ErrMsg;
    end;
  end;
end;

function TGSFList.InstallPackages: Boolean;
var
  i: Integer;
begin
  Result := True;

{  ClearIDList;
  ClearProcessedList;}
  SettIDList.Clear;
  ProcessedRUIDList.Clear;

  for i := 0 to CheckList.Count-1 do
    if not InstallPackage(StrToInt(CheckList[i])) then
      Result := False;
end;

// активирует пакет с индексом aID в списке
function TGSFList.InstallPackage(aID: Integer; const NewOnly: Boolean = False): Boolean;
// NewOnly - не спрашивать пользователя, ставить новые версии
var
  IDList: TStringList;                 // список индексов настроек текущего пакета 
  i: Integer;
                                                                                         
  function GetIDList(aID: Integer; const aRUID, aPath: String; NewOnly: Boolean): Integer;
  var
    i, ind, mr: Integer;
    RealSettID: TID;
    RUID: TRUID;
    isFound, isEnding: Boolean;
    EndList: TStringList;
    tmp_ind, tmp_ver: Integer;
  begin
    Result := girNotFound;
    glb_ErrMessage := 'Не найдена настройка с RUID = ' + aRUID + '.';

    isFound := False;
    if aID > -1 then         // передан id
    begin
      ind := aID;
      isFound := True;
    end
    else
      ind := IndexOf(aRUID);

    if ind > -1 then         // настройка найдена в списке по RUID
    begin

      tmp_ind := -1;
      tmp_ver := 0;
      if (aID = -1) then
      begin
        EndList := TStringList.Create;
        i := -1;
        mr{iVers} := -1;
        isEnding := False;
        while (ind <= Count-1) and
              (RUIDToStr((Objects[ind] as TGSFHeader).RUID) = aRUID) do
        begin
          if ((Objects[ind] as TGSFHeader).Ending = 1) then          // конечная
          begin
            isEnding := True;
            if (Objects[ind] as TGSFHeader).VerInfo > svNotInstalled then
              Result := girOK;          // по крайней мере есть в базе
            if ( (Objects[ind] as TGSFHeader).FullCorrect) then
              begin               // промежуточная конечная %)
                if NewOnly then
                begin             // ищем самую последнюю версию
                  if (Objects[ind] as TGSFHeader).Version > mr{iVers} then
                  begin
                    i := ind;
                    mr{iVers} := (Objects[ind] as TGSFHeader).Version;
                  end;
                end else
                  EndList.AddObject((Objects[ind] as TGSFHeader).Name, (Objects[ind] as TGSFHeader));
              end
          end else                     // промежуточная
          begin
            if (Objects[ind] as TGSFHeader).FilePath = aPath then
            begin
              isFound := True;    // промежуточная по нужному пути
              Break;
            end else              // промежуточная по др. пути - ищем последнюю версию
              if (tmp_ind = -1) or
                 (tmp_ver < (Objects[ind] as TGSFHeader).Version) then
              begin
                tmp_ind := ind;
                tmp_ver := (Objects[ind] as TGSFHeader).Version;
              end;
          end;
          ind := ind + 1;
        end;

        if NewOnly then
          if isEnding and (i > -1) then// добавляем в список самую последнюю версию
          begin
            isFound := True;
            ind := i;
          end else
        else
// +++ позволяем пользователю выбрать пакет +++
        if (EndList.Count > 1) or      // есть список конечных
           ( (EndList.Count = 1) and   // одна новая (установленная!)
//           ((EndList.Objects[0] as TGSFHeader).VerInfo = svNewer)
           ((EndList.Objects[0] as TGSFHeader).MaxVerInfo = svNewer)
           ) then
        begin
          i := CheckedRUID(aRUID);
          if i = -1 then
          begin
            with Tat_dlgChoosePackage.Create(Application) do         // выбор пользователя
            try
              lbPackage.Items.Assign(EndList);
              for i := 0 to EndList.Count-1 do
                IDChooseList.Cells[0, i] := IntToStr(IndexOfObject(EndList.Objects[i]));
              btnExist.Enabled := (EndList.Objects[0] as TGSFHeader).VerInfo > svNotInstalled;
              mr := ShowModal;
              if mr = mrOK then
              begin
                ind := SelectedID;
                isFound := True;
              end else
              begin
                if mr = mrAbort then
                begin
                  isFound := False;
                  Result := girUserCancel;
                  glb_ErrMessage := 'Установка прервана пользователем.';
                end
              end;
              ProcessedRUIDList.Add(aRUID);        // фиксируем запрос пользователю
            finally
              Free;
            end;
          end else
          begin
            ind := i;
            isFound := True;
          end;
        end else
          if EndList.Count = 1 then    // одна и не установлена
          begin
            isFound := True;
            ind := ind - 1;
          end;
        EndList.Free;
      end;

      if not isFound and         // промежуточная найдена в другой папке
         (tmp_ind > -1) then
      begin
        isFound := True;
        ind := tmp_ind;
      end;

      if isFound then
      with (Objects[ind] as TGSFHeader) do
      begin
        Result := girOK;
        if (SettIDList.IndexOf(IntToStr(ind)) = -1) then   // нет в списке
        begin
          SettIDList.Add(IntToStr(ind));     // добавляем индекс в список_для_проверки
          if (VerInfo <= svEqual) then     // если версия новая, то смотрим промежуточные
          begin
            if VerInfo <= VerInfoToInstall then
            begin
              IDList.Add(IntToStr(ind));         // добавляем индекс в список_для_установки
//              SettIDList.Add(IntToStr(ind));     // добавляем индекс в список_для_проверки
            end;
            for i := 0 to InterRUID.Count-1 do   // перебираем промежуточные
            begin
// если инф. по установке не запрашивалась у пользователя, то ищем
              if (ProcessedRUIDList.IndexOf(InterRUID.Strings[i]) = -1) then
                Result := GetIDList(-1, InterRUID.Strings[i], FilePath, NewOnly);
              if Result <> girOK then
                Break; 
            end    // for...
          end      // VerInfo <= svEqual
        end        // нет в списке
      end          // isFound
                   
    end else       // настройка _не_ найдена в списке
    begin
      RUID := StrToRUID(aRUID);
      RealSettID := gdcBaseManager.GetIDByRUID(RUID.XID, RUID.DBID);
      if RealSettID > -1 then
      begin
        gdcSetts.ID := RealSettID;
        gdcSetts.Open;
        if gdcSetts.RecordCount > 0 then         // настройка есть в базе
        begin
          Result := girOK;
        end;
        gdcSetts.Close;
      end;
    end;

  end;

begin                                      
  IDList := TStringList.Create;
  try
    if GetIDList(aID, '', '', NewOnly) = girOK then
    begin
      for i := IDList.Count-1 downto 0 do
        InstallSettingByID(StrToInt(IDList.Strings[i]));
      Result := True;
    end        
    else begin                                                                                          
      MessageBox(0, PChar('Пакет не установлен! ' + glb_ErrMessage), 'Gedemin', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      glb_ErrMessage := '';
      Result := False;
    end;
  finally
    IDList.Free;
  end;
end;

procedure TGSFList.InstallSettingByID(aID: Integer);
var
  FS: TFileStream;
  ind: Integer;
  PackStream: TZDecompressionStream;
  MS: TMemoryStream;
  SizeRead: Integer;
  Buffer: array[0..1023] of Char;
  StreamType: TgsStreamType;
  TempInt: Integer;
  StreamSaver: TgdcStreamSaver;
begin
  ind := aID;
  if ind = -1 then
  begin
// по логике, RUID всегда должен быть найден
    raise Exception.Create('Не найден RUID!');
    Exit;
  end;

  FS := TFileStream.Create( (Objects[ind] as TGSFHeader).FilePath +
                            (Objects[ind] as TGSFHeader).FileName, fmOpenRead);
  try
    StreamType := GetStreamType(FS);
    // проверим формат настройки: архивная или XML
    if StreamType <> sttXML then
    begin
      FS.Position := 2*SizeOf(Integer) + (Objects[ind] as TGSFHeader).Size + 1;
      PackStream := TZDecompressionStream.Create(FS);
      MS := TMemoryStream.Create;
      try
        repeat
          SizeRead := PackStream.Read(Buffer, 1024);
          MS.WriteBuffer(Buffer, SizeRead);
        until (SizeRead < 1024) {or PackStream.EOF};
        MS.Position := 0;
        // Проверим формат архивной настройки
        MS.ReadBuffer(TempInt, SizeOf(TempInt));
        MS.Position := 0;
        if TempInt > 1024 then
        begin
          StreamSaver := TgdcStreamSaver.Create(gdcSetts.Database, gdcSetts.Transaction);
          try
            StreamSaver.Silent := gdcSetts.Silent;
            StreamSaver.ReplicationMode := gdcSetts.Silent;
            StreamSaver.ReadUserFromStream := gdcSetts.Silent;
            StreamSaver.LoadFromStream(MS);
          finally
            StreamSaver.Free;
          end;
        end
        else
        begin
          gdcSetts.Open;
          gdcSetts.LoadFromStream(MS);
          gdcSetts.Close;
        end;
      finally
        MS.Free;
        PackStream.Free;
      end;
    end
    else
    begin
      StreamSaver := TgdcStreamSaver.Create(gdcSetts.Database, gdcSetts.Transaction);
      try
        StreamSaver.Silent := gdcSetts.Silent;
        StreamSaver.ReplicationMode := gdcSetts.Silent;
        StreamSaver.ReadUserFromStream := gdcSetts.Silent;
        StreamSaver.LoadFromStream(FS);
      finally
        StreamSaver.Free;
      end;
    end;  
  finally
    FS.Free;
  end;
end;

// активирует настройки из списка SettIDList
procedure TGSFList.ActivatePackages;
var
  RealSettID: TID;
  i: Integer;
  KeyArr: TStringList;
  YesToAll: Integer;
begin
  if isYesToAll then
    YesToAll := mrYesToAll shl 16 or mrYesToAll // = 655370
  else
    YesToAll := 0;

  KeyArr := TStringList.Create;
  try

// формируем список id настроек для активации
// одну не получится, т.к. могли загружаться настройки, непоср. не связанные с конечной;
  for i := 0 to SettIDList.Count-1 do
  begin
    RealSettID := gdcBaseManager.GetIDByRUID((Objects[StrToInt(SettIDList[i])] as TGSFHeader).RUID.XID,
      (Objects[StrToInt(SettIDList[i])] as TGSFHeader).RUID.DBID);
    if RealSettID > -1 then
      KeyArr.Add(IntToStr(RealSettID));
  end;

  gdcSetts.Open;
    gdcSetts.ActivateSetting(KeyArr, nil, True, YesToAll);

  gdcSetts.Close;

  finally
    KeyArr.Free;
  end;
end;


// ------------------------------ TSettingHeader ------------------------------


procedure LoadRUIDFromBlob(RuidList: TStrings; RUIDField: TField; const AnID: Integer = -1);
var
  BlobStream: TStream;
  CDS: TClientDataSet;
  MS: TMemoryStream;
  I: Integer;
  OldPos: LongInt;
  stRecord: TgsStreamRecord;
  stVersion: String;
  OS: TgdcObjectSet;
  stClass, stSubType: String;
  PrSet: TgdcPropertySet;
  StPos: TgdcSettingPos;
  StreamSaver: TgdcStreamSaver;
  StreamType: TgsStreamType;
begin
  Assert(Assigned(RuidList));

  RuidList.Clear;

  //Создаем блоб-поток для обращения к полю, в котором хранится сформированная настройка
  BlobStream := RuidField.DataSet.CreateBlobStream(RUIDField, bmRead);
  try
    StreamType := GetStreamType(BlobStream);
    // загружать новым или старым методом
    if StreamType <> sttBinaryOld then
    begin
      StreamSaver := TgdcStreamSaver.Create(gdcBaseManager.Database, gdcBaseManager.ReadTransaction);
      try
        StreamSaver.FillRUIDListFromStream(BlobStream, RuidList, AnID);
      finally
        StreamSaver.Free;
      end;
    end
    else
    begin
      PrSet := TgdcPropertySet.Create('', nil, '');
      StPos := nil;
      try
        OS := TgdcObjectSet.Create(TgdcBase, '');
        try
          if AnID > 0 then
          begin
            StPos := TgdcSettingPos.Create(nil);
            StPos.AddSubSet('BySetting');
            StPos.AddSubSet('ByRUID');
            StPos.ParamByName('settingkey').AsInteger := AnID;
          end;

          if BlobStream.Size = 0 then
            Exit;

          OS.LoadFromStream(BlobStream);
          while BlobStream.Position < BlobStream.Size do
          begin
            // проверим тот ли поток нам подсунули для считывания из
            BlobStream.ReadBuffer(I, SizeOf(I));
            if I <> cst_StreamLabel then
              raise Exception.Create('Invalid stream format');

            OldPos := BlobStream.Position;
            SetLength(stVersion, Length(cst_WithVersion));
            BlobStream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
            if stVersion = cst_WithVersion then
            begin
              BlobStream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
              if stRecord.StreamVersion >= 1 then
                BlobStream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
            end else
            begin
              BlobStream.Position := OldPos;
            end;
            // загружаем класс и подтип сохраненного объекта
            stClass := StreamReadString(BlobStream);
            stSubType := StreamReadString(BlobStream);

            if stRecord.StreamVersion >= 2 then
            begin
              PrSet.LoadFromStream(BlobStream);
            end;

            CDS := TClientDataSet.Create(nil);
            try
              BlobStream.ReadBuffer(I, SizeOf(I));
              MS := TMemoryStream.Create;
              try
                MS.CopyFrom(BlobStream, I);
                MS.Position := 0;
                try
                  CDS.LoadFromStream(MS);
                except
                  on E: Exception do
                  begin
                    Application.ShowException(E);
                    continue;
                  end;
                end;
              finally
                MS.Free;
              end;

              CDS.Open;
              if Assigned(StPos) then
              begin
              {Если нам передали конкретный id настройки, то будем проверять,
               входит ли руид в позицию настройки
               Необходимо для сохранения списка руидов удаляемой настройки,
               чтобы не удалить случайно объект, который вытягивался ранее по неявным ссылках
               Например, сторед процедура ранее могла использовать поля one, two,
               которые входят явно в другую настройку.
               При новой модификации процедура стала использовать только одно поле two
               Чтобы случайно не удалилось поле One, передаем ид удаляемой настройки =>
               сохраним в список руидов только руид процедуры.}
                StPos.Close;
                StPos.ParamByName('xid').AsString := CDS.FieldByName('_xid').AsString;
                StPos.ParamByName('dbid').AsString := CDS.FieldByName('_dbid').AsString;
                StPos.Open;
                if StPos.RecordCount > 0 then
                begin
                  RuidList.Add(CDS.FieldByName('_xid').AsString + ',' +
                    CDS.FieldByName('_dbid').AsString + ',' + AnsiUpperCase(Trim(stClass)) +
                    ','+ AnsiUpperCase(Trim(stSubType)));
                end;
              end
              else
              begin
                RuidList.Add(CDS.FieldByName('_xid').AsString + ',' +
                  CDS.FieldByName('_dbid').AsString + ',' + AnsiUpperCase(Trim(stClass)) +
                  ','+ AnsiUpperCase(Trim(stSubType)));
              end;
            finally
              CDS.Free;
            end;
          end;
        finally
          OS.Free;
        end;
      finally
        PrSet.Free;
        if Assigned(StPos) then
          FreeAndNil(StPos);
      end;
    end;

  finally
    FreeAndNil(BlobStream);
  end;
end;

procedure _ActivateSetting(const SettingKey: String; const DontHideForms: Boolean; const AnModalSQLProcess: Boolean; AnAnswer, AnStAnswer: Word);
var
  InternalTransaction: TIBTransaction;
  RelName: String;
  WasMetaDataInSetting: Boolean;
  DataStream, StorageStream: TStream;
  ibquery: TIBSQL;
  SettingName: String;
  SettingList: TStringList;
  StNumber: Integer;
  J: DWORD;
  TempPath: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  StreamSaver: TgdcStreamSaver;
  StreamType: TgsStreamType;

  procedure DisconnectDatabase(const WithCommit: Boolean);
  begin
    if gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.Commit;
    if InternalTransaction.InTransaction then
    begin
    if WithCommit then
      begin
        InternalTransaction.Commit;
      end else
      begin
        InternalTransaction.Rollback;
      end;
    end;
    InternalTransaction.DefaultDatabase.Connected := False;
  end;

  procedure ConnectDatabase;
  begin
    InternalTransaction.DefaultDatabase.Connected := True;
    if not InternalTransaction.InTransaction then
      InternalTransaction.StartTransaction;
    if not gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.StartTransaction;
  end;

  procedure ReConnectDatabase(const WithCommit: Boolean = True);
  begin
    try
      DisconnectDatabase(WithCommit);
    except
      on E: Exception do
      begin
        if MessageBox(0,
          PChar('В процессе загрузки настройки произошла ошибка:'#13#10 +
          E.Message + #13#10#13#10 +
          'Продолжать загрузку?'),
          'Ошибка',
          MB_ICONEXCLAMATION or MB_YESNO or MB_TASKMODAL) = IDNO then
        begin
          raise;
        end;  
      end;
    end;
    ConnectDatabase;
  end;

  procedure RunMultiConnection;
  var
    WasConnect: Boolean;
    R: TatRelation;
    ibsql: TIBSQL;
  begin
    Assert(atDatabase <> nil, 'Не загружена база атрибутов');
    if atDatabase.InMultiConnection then
    begin
     {Проверим, действительно ли нам необходимо переподключение.
       Если в таблице at_transaction ничего нет, скинем флаг переподключения}
      ibsql := TIBSQL.Create(nil);
      try
        ibsql.Transaction := InternalTransaction;
        ibsql.SQL.Text := 'SELECT FIRST 1 * FROM at_transaction ';
        ibsql.ExecQuery;

        if ibsql.RecordCount = 0 then
        begin
          atDatabase.CancelMultiConnectionTransaction(True);
        end else
        begin
          with TmetaMultiConnection.Create do
          try
            WasConnect := InternalTransaction.DefaultDatabase.Connected;
            DisconnectDatabase(True);
            RunScripts(False);
            ConnectDatabase;
            R := atDatabase.Relations.ByRelationName(RelName);
            if Assigned(R) then
              R.RefreshConstraints(InternalTransaction.DefaultDatabase, InternalTransaction);
            if not WasConnect then
              DisconnectDatabase(True);
          finally
            Free;
          end;
        end;

      finally
        ibsql.Free;
      end;
    end;
  end;

  procedure _LoadFromStream(Stream: TStream; IDMapping: TgdKeyIntAssoc;
      ObjectSet: TgdcObjectSet; UpdateList: TObjectList; DontHideForms: boolean);
  var
    I: Integer;
    Obj: TgdcBase;
    C, OldClass: TClass;
    IDMappingCreated: Boolean;
    LoadClassName, LoadSubType, OldClassName, OldSubType: String;
    ULCreated: Boolean;
    OldPos: Integer;
    stVersion: String;
    stRecord: TgsStreamRecord;
    WasMetaData: Boolean;
    PrSet: TgdcPropertySet;
    PropInfo: PPropInfo;
    ObjList: TStringList;
    Ind: Integer;
    ObjDataLen: Integer;
    AClassList: TStringList;
    tmpAnAnswer: Word;
  begin
    Assert(IBLogin <> nil);
    Assert(atDatabase <> nil);
    Assert(ObjectSet <> nil);
    tmpAnAnswer := mrNoToAll;

    if Assigned(frmStreamSaver) then
    begin
      frmStreamSaver.SetupProgress(ObjectSet.Count, 'Активация настройки...');
      frmStreamSaver.SetProcessText(SettingName, True);
    end;

    if Assigned(frmSQLProcess) and Assigned(ObjectSet) then
    begin
      with frmSQLProcess.pb do
      begin
        Min := 0;
        Max := ObjectSet.Count;
        Position := 0;
      end;
    end;

    WasMetaData := False;
    Obj := nil;
    OldClassName := '';
    OldSubType := '';
    OldClass := TObject;

    if IDMapping = nil then
    begin
      IDMapping := TLoadedRecordStateList.Create;
      IDMappingCreated := True;
    end else
      IDMappingCreated := False;

    if UpdateList = nil then
    begin
      UpdateList := TObjectList.Create(True);
      ULCreated := True;
    end else
      ULCreated := False;

    PrSet := TgdcPropertySet.Create('', nil, '');
    ObjList := TStringList.Create;
    AClassList := TStringList.Create;
    try
      AClassList.Sorted := True;
      AClassList.Duplicates := dupIgnore;
      try
        while Stream.Position < Stream.Size do
        begin
          // проверим тот ли поток нам подсунули для считывания из
          Stream.ReadBuffer(I, SizeOf(I));
          if I <> cst_StreamLabel then
            raise Exception.Create('Invalid stream format');

          OldPos := Stream.Position;
          SetLength(stVersion, Length(cst_WithVersion));
          Stream.ReadBuffer(stVersion[1], Length(cst_WithVersion));
          if stVersion = cst_WithVersion then
          begin
            Stream.ReadBuffer(stRecord.StreamVersion, SizeOf(stRecord.StreamVersion));
            if stRecord.StreamVersion >= 1 then
              Stream.ReadBuffer(stRecord.StreamDBID, SizeOf(stRecord.StreamDBID));
          end else
          begin
            stRecord.StreamVersion := 0;
            stRecord.StreamDBID := -1;
            Stream.Position := OldPos;
          end;
          // загружаем класс и подтип сохраненного объекта
          LoadClassName := StreamReadString(Stream);
          LoadSubType := StreamReadString(Stream);

          //Считываем свойство ModifyFromStream
          //Для версии потока не ниже 2
          if stRecord.StreamVersion >= 2 then
          begin
            PrSet.LoadFromStream(Stream);
          end;

          if LoadClassName = OldClassName then
          begin
            C := OldClass
          end else
          begin
            C := GetClass(LoadClassName);
          end;

         {Пропускаем класс, если он не найден}
          if C = nil then
          begin
            if (AClassList.IndexOf(LoadClassName) = -1) and (MessageBox(0,
              PChar('При загрузке из потока встречен несуществующий класс: ' + LoadClassName + #13#10#13#10 +
              'Продолжать загрузку?'),
              'Внимание',
              MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDNO) then
            begin
              raise Exception.Create('Invalid class name!');
            end else
            begin
              AClassList.Add(LoadClassName);
              Stream.ReadBuffer(ObjDataLen, SizeOf(ObjDataLen));
              Stream.Seek(ObjDataLen, soFromCurrent);
              continue;
            end;
          end;

          if (CgdcBase(C).InheritsFrom(TgdcMetaBase)) then
          begin
            WasMetaData := True;
            {Помечаем, что в настройке были мета-данные}
            WasMetaDataInSetting := True;
          end
          else
          begin
            if WasMetaData then
            begin
              if not DontHideForms then
                ReconnectDatabase;
            end;

            WasMetaData := False;
          end;

         //При LogOff мы закрыли ReadTransaction. Стартанем ее снова, т.к. она используется при создании gdc-объектов
          ConnectDatabase;

          if (LoadClassName <> OldClassName) or (LoadSubType <> OldSubType) then
          begin
            OldClass := C;
            OldClassName := LoadClassName;
            OldSubType := LoadSubType;

            Ind := ObjList.IndexOf(LoadClassName + '('+ LoadSubType + ')');
            if Ind = -1 then
            begin
              Obj := CgdcBase(C).CreateWithParams(nil,
                InternalTransaction.DefaultDatabase, InternalTransaction, LoadSubType);
              Obj.ReadTransaction := InternalTransaction;
              //Убираем рефреш
              Obj.SetRefreshSQLOn(False);
              Obj.FReadUserFromStream := DontHideForms;
              ObjList.AddObject(LoadClassName + '('+ LoadSubType + ')', Obj);
              ObjList.Sort;
            end else
              Obj := TgdcBase(ObjList.Objects[Ind]);
          end;

          RunMultiConnection;

          try
            //При открытии может возникнуть ошибка, если мета-данные созданы, но еще не прошел комит
            if Obj.SubSet <> 'ByID' then
              Obj.SubSet := 'ByID';
            Obj.Open;
          except
            if not DontHideForms then
              ReconnectDatabase;
            Obj.Open;
          end;

          //Считываем свойство ModifyFromStream
          //Для версии потока не ниже 2
          if stRecord.StreamVersion >= 2 then
          begin
            for I := 0 to PrSet.Count - 1 do
            begin
              PropInfo := GetPropInfo(Obj.ClassInfo, PrSet.Name[I]);
              if (PropInfo <> nil) then
              begin
                SetPropValue(Obj, PrSet.Name[I], PrSet.Value[PrSet.Name[I]]);
              end;
            end;
          end;

          try
            if not DontHideForms or (not (CgdcBase(C).InheritsFrom(TgdcMetaBase)) and not (CgdcBase(C).InheritsFrom(TgdcBaseDocumentType))) then
              Obj.StreamProcessingAnswer := AnAnswer
            else
              Obj.StreamProcessingAnswer := tmpAnAnswer;
            Obj._LoadFromStreamInternal(Stream, IDMapping, ObjectSet, UpdateList, stRecord);
            AnAnswer := Obj.StreamProcessingAnswer;
          except
            on E: Exception do
            begin
              if not DontHideForms then
              begin
                if InternalTransaction.InTransaction then
                  InternalTransaction.Rollback;

                if Assigned(frmStreamSaver) then
                  frmStreamSaver.AddMistake(E.Message);
                AddMistake(E.Message, clRed);
                raise;
              end
              else
              begin
                ErrorMessageForSetting := ErrorMessageForSetting +
                  IntToStr(GetLastError) + ': ' + E.Message + ' ' +
                  Obj.ClassName + '_' + Obj.SubType + #13#10;
                if Obj.State in [dsEdit, dsInsert] then Obj.Cancel;
              end;
            end;
          end;

          if Assigned(frmStreamSaver) then
            frmStreamSaver.Step;
          if Assigned(frmSQLProcess) then
          begin
            frmSQLProcess.pb.Position := frmSQLProcess.pb.Position + 1;
          end;

          //Если объект - поле, то сохраним имя таблицы, чтобы, если понадобится,
          //после переподключения синхронизировать внешние ключи
          if (Obj is TgdcRelationField) then
            RelName := Obj.FieldByName('relationname').AsString
          else
            RelName := '';

        end;
        RunMultiConnection;

        if Assigned(frmStreamSaver) then
          frmStreamSaver.Done;
      except
        on E: Exception do
        begin
          if InternalTransaction.InTransaction then
            InternalTransaction.Rollback;

          if Assigned(frmStreamSaver) then
            frmStreamSaver.AddMistake(E.Message);
          AddMistake(E.Message, clRed);
          raise;
        end;
      end;
    finally
      AClassList.Free;
      PrSet.Free;
      if IDMappingCreated then
        IDMapping.Free;

      if ULCreated then
        UpdateList.Free;

      for I := 0 to ObjList.Count - 1 do
      begin
        Obj := TgdcBase(ObjList.Objects[I]);
        ObjList.Objects[I] := nil;
        if Assigned(Obj) then
          FreeAndNil(Obj);
      end;
      ObjList.Free;
    end;
  end;

  procedure LoadSettingDataFromStream(Stream: TStream; DontHideForms: Boolean);
  var
    OS: TgdcObjectSet;
  begin
    OS := TgdcObjectSet.Create(TgdcBase, '');
    try
      OS.LoadFromStream(Stream);
      _LoadFromStream(Stream, nil, OS, nil, DontHideForms);
    finally
      OS.Free;
    end;
  end;

  procedure LoadSettingStorageFromStream(StorageStream: TStream);
  const
    cst_StreamValue = 'Value';

  var
    StorageName, Path: String;
    NewFolder: TgsStorageFolder;
    BranchName: String;
    L, P: Integer;
    LStorage: TgsStorage;
    OldPos: Integer;
    cstValue: String;
    NeedLoad: Boolean;
  begin
    ConnectDatabase;
    if StorageStream.Size > 0 then
      AddText('Начата загрузка хранилища', clBlack);
    LStorage := nil;
    while StorageStream.Position < StorageStream.Size do
    begin
      OldPos := StorageStream.Position;
      SetLength(cstValue, Length(cst_StreamValue));
      StorageStream.ReadBuffer(cstValue[1], Length(cst_StreamValue));
      if cstValue = cst_StreamValue then
      begin
        StorageStream.ReadBuffer(L, SizeOf(L));
        SetLength(cstValue, L);
        StorageStream.ReadBuffer(cstValue[1], L);
      end else
      begin
        cstValue := '';
        StorageStream.Position := OldPos;
      end;
    //Считываем Хранилище
      StorageStream.ReadBuffer(L, SizeOf(L));
      SetLength(BranchName, L);
      StorageStream.ReadBuffer(BranchName[1], L);
      P := Pos('\', BranchName);
      if P = 0 then
      begin
        Path := '';
        StorageName := BranchName;
      end else
      begin
        Path := System.Copy(BranchName, P, Length(BranchName) - P + 1);
        StorageName := AnsiUpperCase(System.Copy(BranchName, 1, P - 1));
      end;
      { TODO -oJulia : GLOBAL везде заменить на константы }
      if AnsiPos(st_root_Global, StorageName) = 1 then
      begin
        if LStorage <> GlobalStorage then
        begin
          GlobalStorage.CloseFolder(GlobalStorage.OpenFolder('', False, True), False);
          LStorage := GlobalStorage;
        end;
      end else if AnsiPos(st_root_User, StorageName) = 1 then
      begin
        if LStorage <> UserStorage then
        begin
          UserStorage.CloseFolder(UserStorage.OpenFolder('', False, True), False);
          LStorage := UserStorage;
        end;
      end else
        LStorage := nil;

      NeedLoad := True;
      if LStorage = nil then
      begin
        NewFolder := nil;
      end else
      begin
        if ((AnsiCompareText(st_ds_DFMPath, Path) = 0) or
          (AnsiCompareText(st_ds_NewFormPath, Path) = 0)) and
          (cstValue = '') and (LStorage.FolderExists(Path, False)) then
        begin
          MessageBox(0,
            PChar('Ветка хранилища "' + Path + '" уже существует в базе.'#13#10 +
            'Ее замена содержимым настройки может привести к потере данных.'#13#10 +
            'Загрузка ветки отменена!'),
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          NeedLoad := False;
        end
        else if ((AnsiPos(st_ds_DFMPath, Path) = 1) or (AnsiPos(st_ds_NewFormPath, Path) = 1)) and
          ((cstValue > '') and (LStorage.ValueExists(Path, cstValue, False)) or
           (cstValue = '') and (LStorage.FolderExists(Path, False))) then
        begin
          case AnStAnswer of
            mrYesToAll: NeedLoad := True;
            mrNoToAll: NeedLoad := False;
          else
            AnStAnswer := MessageDlg('Форма "' + Path + '\' + cstValue + '" уже настроена.'#13#10 +
              'Заменить настройки формы? ', mtConfirmation,
              [mbYes, mbYesToAll, mbNo, mbNoToAll], 0);
            case AnStAnswer of
              mrYes, mrYesToAll: NeedLoad := True;
            else
              NeedLoad := False;
            end;
          end;
        end else
          NeedLoad := True;

        if NeedLoad then
          NewFolder := LStorage.OpenFolder(Path, True, False)
        else
          NewFolder := nil;
      end;

      if NeedLoad then
      begin
        if Assigned(NewFolder) then
        begin
          if cstValue > '' then
          begin
            NewFolder.AddValueFromStream(cstValue, StorageStream);
            AddText('Загрузка параметра "' + cstValue +
              '" ветки хранилища "' + StorageName + Path + '"', clBlue);
          end else
          begin
            NewFolder.LoadFromStream(StorageStream);
            AddText('Загрузка ветки хранилища "' + StorageName + Path + '"', clBlue);
          end;
          LStorage.CloseFolder(NewFolder, False);
          { TODO :
            при загрузке из потока у хранилища не выставляется внутренний
            флаг. поэтому оно не будет сохраняться  в базу.
            мы выставляем флаг вручную. }
          //LStorage.IsModified := True;
          //LStorage.SaveToDatabase;
        end
        else
        begin
          AddMistake('Ошибка при считывании данных хранилища!', clRed);
          raise Exception.Create('Ошибка при считывании данных хранилища!');
        end;
      end else
      begin
        if cstValue > '' then
        begin
          TgsStorageFolder.SkipValueInStream(StorageStream);
        end else
        begin
          TgsStorageFolder.SkipInStream(StorageStream);
        end;

        if Assigned(NewFolder) then
          LStorage.CloseFolder(NewFolder, False);
      end;
    end;

    //if GlobalStorage.IsModified then
      GlobalStorage.SaveToDatabase;

    //if UserStorage.IsModified then
      UserStorage.SaveToDatabase;

    if StorageStream.Size > 0 then
      AddText('Закончена загрузка хранилища', clBlack);
  end;

begin
  if DontHideForms then AnAnswer := mrYesToAll;
  if SettingKey = '' then Exit;

  ErrorMessageForSetting := '';

  //Перед загрузкой настроек необходимо перегрузить atDatabase
  WasMetaDataInSetting := True;

  //... и сохранить хранилища
  if (GlobalStorage <> nil) and GlobalStorage.IsModified then
    GlobalStorage.SaveToDatabase;

  if (UserStorage <> nil) and UserStorage.IsModified then
    UserStorage.SaveToDatabase;

  if (CompanyStorage <> nil) and CompanyStorage.IsModified then
    CompanyStorage.SaveToDatabase;

  DesktopManager.WriteDesktopData(cst_DesktopLast, True);
  SettingList := TStringList.Create;
  try
    SettingList.CommaText := SettingKey;
    InternalTransaction := TIBTransaction.Create(nil);
    ibquery := TIBSQL.Create(nil);
    try
      InternalTransaction.DefaultDatabase := IBLogin.Database;
      InternalTransaction.Params.Add('nowait');
      InternalTransaction.Params.Add('read_committed');
      InternalTransaction.Params.Add('rec_version');
      ibquery.Transaction := InternalTransaction;

      for StNumber := 0 to SettingList.Count - 1 do
      begin
        ConnectDatabase;

        ibquery.Close;
        ibquery.SQL.Text := 'SELECT * FROM at_setting WHERE id = :ID';
        ibquery.ParamByName('ID').AsString := SettingList[StNumber];
        ibquery.ExecQuery;

        if not ibquery.EOF then
        begin
          SettingName := ibquery.FieldByName('name').AsString;
          //Считываем потоки данных
          DataStream := TMemoryStream.Create;
          StorageStream := TMemoryStream.Create;
          try
            ibquery.FieldByName('data').SaveToStream(DataStream);
            ibquery.FieldByName('storagedata').SaveToStream(StorageStream);

            //если не стоит флажок "не закрывать формы"
            // закроем все формы
            if not DontHideForms then
              FreeAllForms(False);

            if not DontHideForms then
            begin
              AddText('Начата загрузка настройки ' + SettingName, clBlack);

              if Assigned(frmSQLProcess) then
                frmSQLProcess.Caption := 'Загрузка настройки: ' + SettingName;
            end;

            StreamType := GetStreamType(DataStream);
            // Загружать новым или старым методом
            if StreamType <> sttBinaryOld then
            begin
              if not DontHideForms then
              begin
                if Assigned(frmStreamSaver) then
                  frmStreamSaver.SetupProgress(1, 'Синхронизация триггеров и индексов...');

                AddText('Начата синхронизация триггеров и индексов', clBlack);
                if WasMetaDataInSetting then
                begin
                  atDataBase.ProceedLoading(True);
                  WasMetaDataInSetting := False;
                end;
                atDatabase.SyncIndicesAndTriggers(InternalTransaction);

                AddText('Закончена синхронизация триггеров и индексов', clBlack);

                if Assigned(frmStreamSaver) then
                  frmStreamSaver.Done;

                DisconnectDatabase(True);
              end;

              // При LogOff мы закрыли ReadTransaction. Стартанем ее снова, т.к. она используется при создании gdc-объектов
              ConnectDatabase;

              if Assigned(frmStreamSaver) then
                frmStreamSaver.SetProcessText(SettingName, True);

              DataStream.Position := 0;
              StorageStream.Position := 0;

              StreamSaver := TgdcStreamSaver.Create(InternalTransaction.DefaultDatabase, InternalTransaction);
              try
                StreamSaver.Silent := DontHideForms;
                StreamSaver.ReplicationMode := DontHideForms;
                StreamSaver.ReadUserFromStream := DontHideForms;
                StreamSaver.LoadSettingDataFromStream(DataStream, WasMetaDataInSetting, DontHideForms, AnAnswer);
                StreamSaver.LoadSettingStorageFromStream(StorageStream, AnStAnswer);
                // Для логгирования при репликации
                if StreamSaver.ErrorMessageForSetting <> '' then
                  ErrorMessageForSetting := StreamSaver.ErrorMessageForSetting;
              finally
                StreamSaver.Free;
              end;

            end
            else
            begin

              //Загружаем б-о
              if DataStream.Size > 0 then
              begin
                if not DontHideForms then
                begin
                  if Assigned(frmStreamSaver) then
                    frmStreamSaver.SetupProgress(1, 'Синхронизация триггеров и индексов...');
                  AddText('Начата синхронизация триггеров и индексов', clBlack);

                  if WasMetaDataInSetting then
                  begin
                    {Будем перегружать atDatabase. Многие первичные ключи, поля,
                     и другая дребедень могут не занестись в atDatabase,
                     а при загрузке данных из настройки понадобятся.
                     Данные хранить отдельно от структуры!!!!!}
                    atDataBase.ProceedLoading(True);
                    {Сбросим флаг, он установится в True, только если мы будем грузить структуру}
                    WasMetaDataInSetting := False;
                  end;
                  // Т.к. в потоке могут оказаться триггеры и индексы и
                  //  мы не можем отследить изменение триггеров, а синхронизация
                  //  индексов проходит достаточно долго, чтобы выполнять ее каждый раз
                  //  при синхронизации БД, мы будем проводить синхронизацию
                  //  триггеров и индексов каждый раз при активации настройки

                  atDatabase.SyncIndicesAndTriggers(InternalTransaction);

                  if Assigned(frmStreamSaver) then
                    frmStreamSaver.Done;
                  AddText('Закончена синхронизация триггеров и индексов', clBlack);

                  DisconnectDatabase(True);

                end;

                DataStream.Position := 0;
                //Считываем мета-данные и создаем их
                LoadSettingDataFromStream(DataStream, DontHideForms);
              end;

              //Загружаем хранилище
              if StorageStream.Size > 0 then
              begin
                StorageStream.Position := 0;
                LoadSettingStorageFromStream(StorageStream);
              end;
            end;

            ConnectDatabase;
            ibquery.Close;
            ibquery.SQL.Text := 'UPDATE at_setting SET disabled = 0 WHERE id = :ID';
            ibquery.ParamByName('ID').AsString := SettingList[StNumber];
            ibquery.ExecQuery;

            if gd_CmdLineParams.LoadSettingFileName = '' then
            begin
              J := MAX_COMPUTERNAME_LENGTH + 1;
              if GetComputerName(@TempPath, J) then
              begin
                TgdcJournal.AddEvent(
                  'Активирована настройка "' + SettingName + '". С компьютера ' + StrPas(TempPath) + '.',
                  'TgdcSetting',
                  StrToInt(SettingList[StNumber]), nil, True);
              end;
            end;  

            if not DontHideForms then
              DisconnectDatabase(True)
            else
              if InternalTransaction.InTransaction then InternalTransaction.Commit;

            if not DontHideForms then
            begin
              AddText('Закончена загрузка настройки ' + SettingName, clBlack);

              if Assigned(frmSQLProcess) then
                frmSQLProcess.Caption := 'Выполнение SQL команд';
            end;
          finally                                            
            FreeAndNil(DataStream);
            FreeAndNil(StorageStream);
          end;
        end;
      end;
    finally
      try
        ConnectDatabase;

        if not DontHideForms then
        begin
          if IBLogin.LoggedIn then
          begin
            Clear_atSQLSetupCache;
            IBLogin.Relogin;
          end else
            IBLogin.Login;
        end;  

      finally
        ibquery.Free;
        InternalTransaction.Free;
      end;

    end;
  finally
    SettingList.Free;

    if not Assigned(frmStreamSaver) then
    begin
      if not DontHideForms then
        if Assigned(frmSQLProcess) and AnModalSQLProcess and not frmSQLProcess.Silent then
        begin
          frmSQLProcess.BringToFront;
          {$IFNDEF DUNIT_TEST}
          if frmSQLProcess.Visible then
            frmSQLProcess.Hide;
          frmSQLProcess.ShowModal;
          {$ENDIF}
        end;
    end
    else
    begin
      frmStreamSaver.BringToFront;
      frmStreamSaver.ActivateFinishButtons;
    end;
  end;
end;

procedure _DeactivateSetting(const SettingKey: String; const AnModalSQLProcess: Boolean);
var
  InternalTransaction: TIBTransaction;
  RelName: String;
  RUIDList: TStringList;
  HelpList: TStringlist;
  SettingList: TStringList;
  StNumber: Integer;
  Stream: TStream;
  ibquery: TIBQuery;
  SettingName: String;
  J: DWORD;
  TempPath: array[0..MAX_COMPUTERNAME_LENGTH] of Char;

  procedure DisconnectDatabase(const WithCommit: Boolean);
  begin
    if gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.Commit;
    if InternalTransaction.InTransaction then
    begin
    if WithCommit then
      begin
        InternalTransaction.Commit;
      end else
      begin
        InternalTransaction.Rollback;
      end;
    end;
    InternalTransaction.DefaultDatabase.Connected := False;
  end;

  procedure ConnectDatabase;
  begin
    InternalTransaction.DefaultDatabase.Connected := True;
    if not InternalTransaction.InTransaction then
      InternalTransaction.StartTransaction;
    if not gdcBaseManager.ReadTransaction.InTransaction then
      gdcBaseManager.ReadTransaction.StartTransaction;
  end;

  procedure ReConnectDatabase(const WithCommit: Boolean = True);
  begin
    DisconnectDatabase(WithCommit);
    ConnectDatabase;
  end;

  procedure RunMultiConnection;
  var
    WasConnect: Boolean;
    R: TatRelation;
  begin
    Assert(atDatabase <> nil, 'Не загружена база атрибутов');
    if atDatabase.InMultiConnection then
    begin
      with TmetaMultiConnection.Create do
      try
        WasConnect := InternalTransaction.DefaultDatabase.Connected;
        DisconnectDatabase(True);
        RunScripts(False);
        ConnectDatabase;
        R := atDatabase.Relations.ByRelationName(RelName);
        if Assigned(R) then
          R.RefreshConstraints(InternalTransaction.DefaultDatabase, InternalTransaction);
        if not WasConnect then
          DisconnectDatabase(True);
      finally
        Free;
      end;
    end;
  end;

  procedure InternalDeactivate;
  var
    Obj: TgdcBase;
    C: TPersistentClass;
    ibsqlPos: TIBSQL;
    AnID: Integer;
    StorageName, Path: String;
    NewFolder: TgsStorageFolder;
    J: Integer;
    ObjectCount: Integer;
  begin
    ibsqlPos := TIBSQL.Create(nil);
    try
      try
        ibsqlPos.Transaction := InternalTransaction;
        ibsqlPos.SQL.Text :=
          'SELECT count(id) as ObjectCount FROM at_settingpos WHERE settingkey = ' +
          SettingList[stNumber] + ' and autoadded <> 1';
        ibsqlPos.ExecQuery;
        ObjectCount := ibsqlPos.FieldByName('ObjectCount').AsInteger;

        ibsqlPos.Close;
        ibsqlPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey and xid =:xid and dbid = :dbid and autoadded <> 1';

        if Assigned(frmStreamSaver) then
        begin
          frmStreamSaver.SetupProgress(ObjectCount, 'Деактивация настройки...');
          frmStreamSaver.SetProcessText(SettingName, True);
        end;

        for J := RUIDList.Count - 1 downto 0 do
        begin
          HelpList.CommaText := RUIDList[J];
          ConnectDataBase;
          ibsqlPos.Close;
          ibsqlPos.ParamByName('settingkey').AsString := SettingList[stNumber];
          ibsqlPos.ParamByName('xid').AsString := HelpList[0];
          ibsqlPos.ParamByName('dbid').AsString := HelpList[1];
          ibsqlPos.ExecQuery;
          if ibsqlPos.RecordCount > 0 then
          begin

            C := GetClass(ibsqlPos.FieldByName('objectclass').AsString);
            if C <> nil then
            begin
              AnID := gdcBaseManager.GetIDByRUID(ibsqlPos.FieldByName('xid').AsInteger,
                ibsqlPos.FieldByName('dbid').AsInteger);

                Obj := CgdcBase(C).CreateSubType(nil, ibsqlPos.FieldByName('subtype').AsString, 'ByID');
                Obj.Transaction := InternalTransaction;
                Obj.ReadTransaction := InternalTransaction;
                Obj.ID := AnID;
                RunMultiConnection;
                try
                  if Assigned(Obj) then
                  begin
                    Obj.Open;
                    if (Obj.RecordCount > 0) and (not IsGedeminSystemID(Obj.ID)) then
                    try
                      AddText('Удаление объекта ' + Obj.GetDisplayName(Obj.SubType) +
                        ' ' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                        ' с идентификатором ' + IntToStr(AnID), clBlue);
                      if (not (Obj is TgdcMetaBase)) or (Obj as TgdcMetaBase).IsUserDefined then
                        Obj.Delete;
                    except
                      on E: Exception do
                      begin
                        AddMistake(E.Message, clRed);
                        ReconnectDataBase(False);
                      end;
                    end else
                      AddText('Объект ' + Obj.GetDisplayName(Obj.SubType) +
                        ' ' + Obj.FieldByName(Obj.GetListField(Obj.SubType)).AsString +
                        ' с идентификатором ' + IntToStr(AnID) + ' уже удален ', clBlue);

                  end;
                finally
                  Obj.Free;
                end;

            end;
          end;
          if Assigned(frmStreamSaver) then
            frmStreamSaver.Step;
        end;

        RunMultiConnection;

        ibsqlPos.Close;
        ibsqlPos.SQL.Text :=
          'SELECT * FROM at_setting_storage WHERE settingkey = :settingkey AND (NOT branchname LIKE ''#%'')';
        ibsqlPos.ParamByName('settingkey').AsString := SettingList[stNumber];
        ibsqlPos.ExecQuery;
        while not ibsqlPos.Eof do
        begin
          if AnsiPos('\', ibsqlPos.FieldByName('branchname').AsString) = 0 then
          begin
            Path := '';
            StorageName := ibsqlPos.FieldByName('branchname').AsString;
          end else
          begin
            Path := System.Copy(ibsqlPos.FieldByName('branchname').AsString,
              AnsiPos('\', ibsqlPos.FieldByName('branchname').AsString),
              Length(ibsqlPos.FieldByName('branchname').AsString) -
              AnsiPos('\', ibsqlPos.FieldByName('branchname').AsString) + 1);
            StorageName := AnsiUpperCase(System.Copy(ibsqlPos.FieldByName('branchname').AsString,
              1, AnsiPos('\', ibsqlPos.FieldByName('branchname').AsString) - 1));
          end;
          if AnsiPos(st_root_Global, StorageName) = 1 then
          begin
            NewFolder := GlobalStorage.OpenFolder(Path, False);
          end
          else if AnsiPos(st_root_User, StorageName) = 1 then
          begin
            NewFolder := UserStorage.OpenFolder(Path, False);
          end
          else
            NewFolder := nil;

          if Assigned(NewFolder) then
          begin
            if ibsqlPos.FieldByName('valuename').AsString > '' then
            begin
              AddText('Удаление параметра ' + ibsqlPos.FieldByName('valuename').AsString +
                ' ветки хранилища ' + ibsqlPos.FieldByName('branchname').AsString, clBlue);
              NewFolder.DeleteValue(ibsqlPos.FieldByName('valuename').AsString)
            end else
            begin
              AddText('Удаление ветки хранилища ' + ibsqlPos.FieldByName('branchname').AsString, clBlue);
              NewFolder.Drop;
            end;
          end;

          ibsqlPos.Next;
        end;
        if Assigned(frmStreamSaver) then
          frmStreamSaver.Done;
      except
        on E: Exception do
        begin
          AddMistake(E.Message, clRed);
          DisconnectDataBase(False);
          raise;
        end;
      end;
    finally
      ibsqlPos.Free;
    end;
  end;

begin
  Assert(gdcBaseManager <> nil);
  if SettingKey = '' then Exit;

  DesktopManager.WriteDesktopData(cst_DesktopLast, True);
  SettingList := TStringList.Create;
  try
    SettingList.CommaText := SettingKey;
    InternalTransaction := TIBTransaction.Create(nil);
    ibquery := TIBQuery.Create(nil);
    try
      InternalTransaction.DefaultDatabase := IBLogin.Database;
      InternalTransaction.Params.Add('nowait');
      InternalTransaction.Params.Add('read_committed');
      InternalTransaction.Params.Add('rec_version');
      ibquery.Transaction := InternalTransaction;


      if SettingList.Count > 0 then
        FreeAllForms(False);    //закроем все формы

      for StNumber := 0 to SettingList.Count - 1 do
      begin

        ConnectDataBase;
        ibquery.Close;
        ibquery.SQL.Text := 'SELECT * FROM at_setting WHERE id = :ID';
        ibquery.ParamByName('ID').AsString := SettingList[StNumber];
        ibquery.Open;

        if not ibquery.EOF then
        begin
          SettingName := ibquery.FieldByName('name').AsString;

          AddText('Начата синхронизация триггеров и индексов', clBlack);
           //Т.к. в потоке могут оказаться триггеры и индексы и
          //мы не можем отследить изменение триггеров, а синхронизация
          //индексов проходит достаточно долго, чтобы выполнять ее каждый раз
          //при синхронизации БД, мы будем проводить синхронизацию
          //триггеров и индексов каждый раз при активации настройки
          atDatabase.SyncIndicesAndTriggers(InternalTransaction);
          AddText('Закончена синхронизация триггеров и индексов', clBlack);

          AddText(Format('Начата деактивация настройки %s', [SettingName]), clBlack);

          RUIDList := TStringList.Create;
          HelpList := TStringList.Create;

          LoadRUIDFromBlob(RUIDList, ibquery.FieldByName('data'));

          Stream := ibquery.CreateBlobStream(ibquery.FieldByName('StorageData'), bmRead);
          try
            if (RUIDList.Count = 0) and (Stream.Size = 0) then
            begin
              if MessageBox(0, PChar(Format('Настройка %s не была сформирована. Продолжить деактивацию?',
                [SettingName])), 'Внимание!',
                MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDNO
              then
              begin
                AddText(Format('Деактивация настройки %s прервана', [SettingName]), clBlack);
                Continue;
              end;
            end;
          finally
            FreeAndNil(Stream);
          end;
        end;

        InternalDeactivate;

        ConnectDatabase;
        ibquery.SQL.Text := 'UPDATE at_setting SET disabled = 1 WHERE id = ' +
          SettingList[StNumber];
        ibquery.ExecSQL;

        J := MAX_COMPUTERNAME_LENGTH + 1;
        if GetComputerName(@TempPath, J) then
        begin
          TgdcJournal.AddEvent(
            'Деактивирована настройка "' + SettingName + '". С компьютера ' + StrPas(TempPath) + '.',
            'TgdcSetting',
            StrToInt(SettingList[StNumber]), nil, True);
        end;

        DisconnectDatabase(True);

        AddText(Format('Деактивация настройки %s закончена', [SettingName]), clBlack);
      end;
    finally
      try
        ConnectDatabase;

        if IBLogin.LoggedIn then
        begin
          Clear_atSQLSetupCache;
          IBLogin.Relogin;
        end else
          IBLogin.Login;
          
        atDatabase.ForceLoadFromDatabase;
      finally
        ibquery.Free;
        InternalTransaction.Free;
      end;
    end;
  finally
    SettingList.Free;

    if not Assigned(frmStreamSaver) then
    begin
      if Assigned(frmSQLProcess) and AnModalSQLProcess then
      begin
        if frmSQLProcess.Visible then
          frmSQLProcess.Hide;
        frmSQLProcess.ShowModal;
        frmSQLProcess.BringToFront;
      end;
    end
    else
    begin
      frmStreamSaver.BringToFront;
      frmStreamSaver.ActivateFinishButtons;
    end;
  end;
end;

procedure TgdcSetting.OnStartLoading(Sender: TatSettingWalker; AnObjectSet: TgdcObjectSet);
begin
  FNewPositionOffset := 0;
  FIBSQLSelectAllPos.ExecQuery;
end;

procedure TgdcSetting.OnObjectLoad(Sender: TatSettingWalker;
  const AClassName, ASubType: String;
  ADataSet: TDataSet; APrSet: TgdcPropertySet; const ASR: TgsStreamRecord);
var
  C: TPersistentClass;
begin
  while not ADataSet.EOF do
  begin
    if (FIBSQLSelectAllPos.FieldByName('xid').AsInteger = ADataSet.FieldByName('_xid').AsInteger)
      and (FIBSQLSelectAllPos.FieldByName('dbid').AsInteger = ADataSet.FieldByName('_dbid').AsInteger) then
    begin
      FIBSQLSelectAllPos.Next;
      FNewPositionOffset := 0;
    end else
    begin
      C := FindClass(AClassName);

      Assert((C <> nil) and C.InheritsFrom(TgdcBase));

      FIBSQLSelectPos.Close;
      FIBSQLSelectPos.ParamByName('xid').AsInteger := ADataSet.FieldByName('_xid').AsInteger;
      FIBSQLSelectPos.ParamByName('dbid').AsInteger := ADataSet.FieldByName('_dbid').AsInteger;
      FIBSQLSelectPos.ExecQuery;
      if FIBSQLSelectPos.Eof then
      begin
        FIBSQLUpdatePos.ParamByName('OO').AsInteger :=
          FIBSQLSelectAllPos.FieldByName('objectorder').AsInteger + FNewPositionOffset;
        FIBSQLUpdatePos.ExecQuery;

        FIBSQLInsertPos.ParamByName('objectclass').AsString := AClassName;
        FIBSQLInsertPos.ParamByName('subtype').AsString := ASubtype;
        FIBSQLInsertPos.ParamByName('category').AsString := System.Copy(CgdcBase(C).GetDisplayName(ASubType), 1, 20);
        FIBSQLInsertPos.ParamByName('objectname').AsString := System.Copy(CgdcBase(C).GetListNameByID(
          gdcBaseManager.GetIDByRUID(ADataSet.FieldByName('_xid').AsInteger,
          ADataSet.FieldByName('_dbid').AsInteger), ASubType), 1, 60);
        FIBSQLInsertPos.ParamByName('xid').AsInteger := ADataSet.FieldByName('_xid').AsInteger;
        FIBSQLInsertPos.ParamByName('dbid').AsInteger := ADataSet.FieldByName('_dbid').AsInteger;
        FIBSQLInsertPos.ParamByName('objectorder').AsInteger :=
          FIBSQLSelectAllPos.FieldByName('objectorder').AsInteger + FNewPositionOffset;
        FIBSQLInsertPos.ParamByName('withdetail').AsInteger := 0;
        if CgdcBase(C).NeedModifyFromStream(ASubType) then
          FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 1
        else
          FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 0;

        FIBSQLInsertPos.ExecQuery;
        Inc(FNewPositionOffset);
      end;
    end;

    ADataSet.Next;
  end;
end;

procedure TgdcSetting.OnStartLoadingNew(Sender: TatSettingWalker);
begin
  FNewPositionOffset := 0;
  FIBSQLInsertPos.Prepare;
  FIBSQLUpdatePosOrder.Prepare;
  FIBSQLDeleteAllPos.ExecQuery;

  FIBSQLSelectAllPos.ExecQuery;
  while not FIBSQLSelectAllPos.Eof do
  begin
    FManualAddedPositions.Add(FIBSQLSelectAllPos.FieldByName('XID').AsString +
      '_' + FIBSQLSelectAllPos.FieldByName('DBID').AsString);
    FIBSQLSelectAllPos.Next;
  end;
end;

procedure TgdcSetting.OnObjectLoadNew(Sender: TatSettingWalker;
  const AClassName, ASubType: String; ADataSet: TDataSet);
var
  C: TPersistentClass;
  XID, DBID: Integer;
  TempIndex: Integer;
begin
  XID := ADataSet.FieldByName('_xid').AsInteger;
  DBID := ADataSet.FieldByName('_dbid').AsInteger;
  // Если это не обычная позиция настройки
  if not FManualAddedPositions.Find(IntToStr(XID) + '_' + IntToStr(DBID), TempIndex) then
  begin
    // И если мы еще не добавляли объект с таким РУИДом
    if not FAddedPositions.Find(IntToStr(XID) + '_' + IntToStr(DBID), TempIndex) then
    begin
      C := FindClass(AClassName);

      Assert((C <> nil) and C.InheritsFrom(TgdcBase));

      FIBSQLInsertPos.ParamByName('objectclass').AsString := AClassName;
      FIBSQLInsertPos.ParamByName('subtype').AsString := ASubtype;
      FIBSQLInsertPos.ParamByName('category').AsString := System.Copy(CgdcBase(C).GetDisplayName(ASubType), 1, 20);
      FIBSQLInsertPos.ParamByName('objectname').AsString := System.Copy(CgdcBase(C).GetListNameByID(
        gdcBaseManager.GetIDByRUID(ADataSet.FieldByName('_xid').AsInteger,
        ADataSet.FieldByName('_dbid').AsInteger), ASubType), 1, 60);
      FIBSQLInsertPos.ParamByName('xid').AsInteger := ADataSet.FieldByName('_xid').AsInteger;
      FIBSQLInsertPos.ParamByName('dbid').AsInteger := ADataSet.FieldByName('_dbid').AsInteger;
      FIBSQLInsertPos.ParamByName('objectorder').AsInteger := FNewPositionOffset;
      FIBSQLInsertPos.ParamByName('withdetail').AsInteger := 0;
      FIBSQLInsertPos.ParamByName('autoadded').AsInteger := 1;

      if CgdcBase(C).NeedModifyFromStream(ASubType) then
        FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 1
      else
        FIBSQLInsertPos.ParamByName('needmodify').AsInteger := 0;

      FAddedPositions.Add(IntToStr(XID) + '_' + IntToStr(DBID));
      Inc(FNewPositionOffset);
      FIBSQLInsertPos.ExecQuery;
    end;
  end
  else
  begin
    FIBSQLUpdatePosOrder.ParamByName('xid').AsInteger := XID;
    FIBSQLUpdatePosOrder.ParamByName('dbid').AsInteger := DBID;
    FIBSQLUpdatePosOrder.ParamByName('oorder').AsInteger := FNewPositionOffset;
    Inc(FNewPositionOffset);
    FIBSQLUpdatePosOrder.ExecQuery;
  end;
end;

procedure TgdcSetting.AddMissedPositions;
var
  Tr: TIBTransaction;
  SettingWalker: TatSettingWalker;
begin
  FIBSQLSelectAllPos := TIBSQL.Create(nil);
  FIBSQLUpdatePos := TIBSQL.Create(nil);
  FIBSQLUpdatePosOrder := TIBSQL.Create(nil);
  FIBSQLInsertPos := TIBSQL.Create(nil);
  FIBSQLDeleteAllPos := TIBSQL.Create(nil);
  FIBSQLSelectPos := TIBSQL.Create(nil);
  FManualAddedPositions := TStringList.Create;
  FManualAddedPositions.Sorted := True;
  FAddedPositions := TStringList.Create;
  FAddedPositions.Sorted := True;
  SettingWalker := TatSettingWalker.Create;
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    FIBSQLSelectAllPos.Transaction := Tr;
    FIBSQLUpdatePos.Transaction := Tr;
    FIBSQLInsertPos.Transaction := Tr;
    FIBSQLDeleteAllPos.Transaction := Tr;
    FIBSQLSelectPos.Transaction := Tr;
    FIBSQLUpdatePosOrder.Transaction := Tr;

    FIBSQLSelectAllPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :SK ORDER BY objectorder';
    FIBSQLSelectAllPos.ParamByName('SK').AsInteger := Self.FieldByName('id').AsInteger;

    FIBSQLUpdatePos.SQL.Text := 'UPDATE at_settingpos SET objectorder = objectorder + 1 WHERE ' +
      ' settingkey = :SK AND objectorder >= :OO ';
    FIBSQLUpdatePos.ParamByName('SK').AsInteger := Self.FieldByName('id').AsInteger;

    FIBSQLInsertPos.SQL.Text := 'INSERT INTO at_settingpos(settingkey, objectclass, subtype, category, ' +
      'objectname, xid, dbid, objectorder, withdetail, needmodify, autoadded) VALUES( ' +
      ':settingkey, :objectclass, :subtype, :category, ' +
      ':objectname, :xid, :dbid, :objectorder, :withdetail, :needmodify, :autoadded) ';
    FIBSQLInsertPos.ParamByName('settingkey').AsInteger := Self.FieldByName('id').AsInteger;

    FIBSQLSelectPos.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :SK AND xid = :XID AND dbid = :DBID ';
    FIBSQLSelectPos.ParamByName('SK').AsInteger := Self.FieldByName('id').AsInteger;

    FIBSQLDeleteAllPos.SQL.Text := 'DELETE FROM at_settingpos WHERE settingkey = :SK and autoadded = 1';
    FIBSQLDeleteAllPos.ParamByName('SK').AsInteger := Self.FieldByName('id').AsInteger;

    FIBSQLUpdatePosOrder.SQL.Text := 'UPDATE at_settingpos SET objectorder = :oorder ' +
      'WHERE settingkey = :SK AND xid = :xid AND dbid = :dbid';
    FIBSQLUpdatePosOrder.ParamByName('SK').AsInteger := Self.FieldByName('id').AsInteger;

    SettingWalker.StartLoadingNew := OnStartLoadingNew;
    SettingWalker.ObjectLoadNew := OnObjectLoadNew;
    SettingWalker.StartLoading := OnStartLoading;
    SettingWalker.ObjectLoad := OnObjectLoad;

    SettingWalker.Stream := Self.CreateBlobStream(Self.FieldByName('data'), bmRead);
    try
      SettingWalker.ParseStream;
    finally
      SettingWalker.Stream.Free;
    end;

    Tr.Commit;
  finally
    FAddedPositions.Free;
    FManualAddedPositions.Free;
    SettingWalker.Free;
    FIBSQLSelectAllPos.Free;
    FIBSQLUpdatePosOrder.Free;
    FIBSQLUpdatePos.Free;
    FIBSQLInsertPos.Free;
    FIBSQLDeleteAllPos.Free;
    FIBSQLSelectPos.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure TgdcSetting.GoToLastLoadedSetting;
var
  OldObjectKey: TID;
begin
  if LastLoadedSettingKey > -1 then
  begin
    try
      OldObjectKey := Self.ID;
      try
        // Попробуем перейти на загруженную настройку
        Self.ID := LastLoadedSettingKey;
      except
        if OldObjectKey > 0 then
          Self.ID := OldObjectKey
        else
          Self.First;
      end;
    finally
      LastLoadedSettingKey := -1;
    end;
  end;
end;

initialization
  RegisterGDCClass(TgdcSetting,        'Настройка');
  RegisterGDCClass(TgdcSettingPos,     'Позиция настройки');
  RegisterGDCClass(TgdcSettingStorage, 'Позиция настройки хранилища');

finalization
  UnregisterGdcClass(TgdcSetting);
  UnregisterGdcClass(TgdcSettingPos);
  UnregisterGdcClass(TgdcSettingStorage);
end.
