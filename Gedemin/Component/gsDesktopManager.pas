
{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

  Abstract

  Author

    Andrei Kireev

  Contact address

    a_kireev@yahoo.com
    andreik@gsbelarus.com

  Revisions history

    1.00    15-sep-00    andreik    Initial version.
    1.01    14-mar-01    andreik    Minor changes.
    1.02    14-dec-01    michael    Добавлена возможность сохранения в desktop
                                    окон с базовым классом с под типом  
--}

unit gsDesktopManager;

{ TODO : в будущем надо screenres сделать NOT NULL }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, StdCtrls, Contnrs, gsStorage, gdcBase;

(*
 * Тэрміналёгія:
 *   Дэсктоп -- сукупнасць экранных аб'ектаў (вокнаў).
 *
 *   мэтады счытваньня і запісу дадзеных з/у паток(у) мы будзем называць
 *     ReadFromStream, WriteToStream
 *   мэтады счытваньня і прысвайваньня уласцівасцяў аб'екту мы будзем называць
 *     SaveDesktopItem, LoadDesktopItem
 *
 * Як гэта працуе:
 *   мы счытваем уласцівасці экраннага аб'екту і захоўваем іх у сваей структуры
 *   далей мы можам захаваць гэтую структуру ў базе, альбо ў файле.
 *   таксама мы можам счытаць уласцівасці экраннага аб'екту з базы ў
 *   сваю структуру, каб потым прысвоіць іх экраннаму аб'екту.
 *
 *   такім чынам, калі карыстальнік захоўвае дэсктоп, для кожнага экраннага
 *   аб'екту (зараз мы апрацоўваем вокны) ствараецца адпаведная структура, куды
 *   заносяцца параметры гэтага аб'екта (ягоная пазіцыя, памеры, бачнасць і г.д.).
 *
 *   напрыклад, карыстальнік зачыніў некаторыя вокны, некаторыя перамясціў
 *   і жадае вярнуцца да былой раскладкі. Ён выбірае з выпадальнага сьпісу патрэбны
 *   дэсктоп, дадзеныя дэсктопу загружаюцца з базы, экранныя аб'екты (вокны)
 *   ініцыялізуюцца парамэтрамі, захованымі з дэсктопе.
 *
 *)

(*
 * Базавы клас, ад якога мы будзем наследваць усе класы
 * якія рэпрзентуюць элементы працоўнага стала. Г.зн. і
 * ёсць та структура, ў якой мы захоўваем уласцівасці экраннага
 * аб'екту.
 *)
type
  TDesktopItem = class(TObject)
  private
    FOwnerName: String;
    FItemClassName: String;
    FItemName: String;
    FItem: TComponent;

  protected
    // счытвае з патоку настройкі аб'екту
    procedure ReadFromStream(Reader: TReader); virtual;
    // запісвае ў паток настройкі аб'екту
    procedure WriteToStream(Writer: TWriter); virtual;

    // ініцыялізуе (загружае) экранны аб'ект захаванымі настройкамі
    procedure LoadDesktopItem(I: TComponent); overload; virtual;
    // ініцыялізуе (загружае) экранны аб'ект захаванымі настройкамі
    // аб'ект бярэ са спасылкі FItem
    procedure LoadDesktopItem; overload;
    // счытвае настройкі існуючага экраннага аб'екта
    procedure SaveDesktopItem(I: TComponent); virtual;

  public
    constructor CreateFromStream(S: TReader);

    // робім копію
    procedure Assign(I: TDesktopItem); virtual;

    // функцыя вяртае Ісціну, калі гэты аб'ект захоўвае
    // настройкі для ўказанага аб'екту (аб'ект указваецца
    // праз AnOwnerName, AClassName, AName)
    function IsItem(const AnOwnerName, AClassName, AName: String): Boolean; overload;
    function IsItem(const AClassName, AName: String): Boolean; overload;

    // при сохранении списка настроек экранных объектов
    // в поток нам надо записать тип, чтобы потом мы могли
    // правильно восстановить объект
    class function GetTypeID: Integer; virtual;

    // уласцівасці экраннага аб'екту
    property OwnerName: String read FOwnerName;
    property ItemClassName: String read FItemClassName;
    property ItemName: String read FItemName;

    // спасылка на сам экранны аб'ект
    property Item: TComponent read FItem {write FItem};
  end;

(*
 * Клас, які прызначаны каб захоўваць парамэтры формы.
 *
 *)
type
  TFormData = class(TDesktopItem)
  private
    FHeight: Integer;
    FLeft: Integer;
    FWidth: Integer;
    FTop: Integer;
    FVisible: Boolean;
    FWindowState: TWindowState;

    function GetForm: TForm;
    procedure SetForm(const Value: TForm);

  protected
    procedure ReadFromStream(Reader: TReader); override;
    procedure WriteToStream(Writer: TWriter); override;

    procedure LoadDesktopItem(I: TComponent); override;
    procedure SaveDesktopItem(I: TComponent); override;

  public
    procedure Assign(I: TDesktopItem); override;

    class function GetTypeID: Integer; override;

    property Left: Integer read FLeft;
    property Top: Integer read FTop;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Visible: Boolean read FVisible;
    property WindowState: TWindowState read FWindowState;

    property Form: TForm read GetForm write SetForm;
  end;

  TgdcBaseData = class(TFormData)
  private
    FgdcSubType: String;
    FgdcClassName: String;

  protected
    procedure ReadFromStream(Reader: TReader); override;
    procedure WriteToStream(Writer: TWriter); override;

    procedure SaveDesktopItem(I: TComponent); override;
  public
    procedure Assign(I: TDesktopItem); override;
    
    class function GetTypeID: Integer; override;

    property gdcClassName: String read FgdcClassName;
    property gdcSubType: String read FgdcSubType;
  end;

type
  TgsDesktopManager = class;

  (*

    Клас TDesktopItems прызначаны, каб захоўваць сьпіс аб'ектаў,
    якія захоўваюць экранныя настройкі, экранных аб'ектаў для
    аднаго дэсктопу.

  *)
  TDesktopItems = class(TObject)
  private
    FItems: TObjectList;
    FDesktopManager: TgsDesktopManager;

    function GetItems(Index: Integer): TDesktopItem;
   // procedure SetItems(Index: Integer; const Value: TDesktopItem);
    function GetCount: Integer;

    // найти компонент заданного имени класса и имени в компоненте и всех
    // его подкомпонентах
    function FindComponent(AnOwner: TComponent; const AClassName, AName: String): TComponent; overload;
    // найти компонент заданный ссылкой, если найден -- возвращает эту ссылку
    // если нет -- НИЛ
    function FindComponent(AnOwner: TComponent; AComponent: TComponent): TComponent; overload;

  protected
    // считываем из потока список настроек экранных объектов
    procedure ReadFromStream(S: TStream);
    // записываем в поток список настроек экранных объектов
    procedure WriteToStream(S: TStream);

  public
    constructor Create(ADesktopManager: TgsDesktopManager);
    destructor Destroy; override;

    // добавить в наш список новую структуру для хранения настроек
    // экранного объекта
    procedure Add(const DI: TDesktopItem);
    //
    procedure Remove(const Item: TComponent);
    // найти в нашем списке нашу структуру с настройками экранного объекта
    // по заданным именам владельца, класса и объекта
    function Find(const AnOwnerName, AClassName, AName: String): TDesktopItem; overload;
    function Find(const AClassName, AName: String): TDesktopItem; overload;
    // найти в нашем списке нашу структуру с настройками экранного объекта
    // по заданной ссылке на этот экранный объект
    function Find(const Item: TComponent): TDesktopItem; overload;
    //
    procedure Clear;

    // пройтись по всем окнам и сохранить их настройки
    // в нашей структуре
    procedure SaveDesktopItems(const Mode: Boolean = True);
    // пройтись по списку объектов, для которых у нас есть
    // сохраненные настройки и инициализировать ими соответствующий
    // экранный объект (окно)
    procedure LoadDesktopItems;

    // количество объектов с настройками форм в нашем списке
    property Count: Integer read GetCount;
    // объекты с настройками экранных объектов
    property Items[Index: Integer]: TDesktopItem read GetItems {write SetItems};
      default;
    // ссылка на менеджер десктопов
    property DesktopManager: TgsDesktopManager read FDesktopManager;
  end;

  TOnDesktopItemCreateEvent = function(Sender: TObject;
    const AnItemClass, AnItemName: String): TComponent of object;

  (*

    TgsDesktopManager. Этот компонент отвечает за управление десктопами.
    Он сохраняет и загружает их из базы.
    Он может инициализировать экранные объекты (формы) сохраненными настройками.
    Он может записать настройки экранных объектов в свою структуру.
    Он поддерживает список доступных десктопов.

  *)
  TgsDesktopManager = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FDesktopItems: TDesktopItems;
    FDesktopNames: array of String;
    FDesktopCount: Integer;
    FCurrentDesktopName: String;
    FOnDesktopItemCreate: TOnDesktopItemCreateEvent;
    FStorage: TgsStorage;
    FLoadingDesktop: Boolean;

    procedure SetDatabase(const Value: TIBDatabase);
    function GetDesktopNames(Index: Integer): String;
    function GetCurrentDesktopIndex: Integer;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function DoOnDesktopItemCreate(const AnItemClass, AnItemName: String): TComponent;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // считываем из базы список десктопов для текущего пользователя
    // и разрешения экрана
    procedure ReadDesktopNames;
    // загружаем в кмобо список доступных десктопов
    // делаем в комбо текущим текущий десктоп
    procedure InitComboBox(CB: TComboBox);

    // считываем десктоп, заданный именем из базы данных
    function ReadDesktopData(const ADesktopName: String = ''): Boolean;
    // записываем десктоп, заданный именем в базу данных
    // если Режим=0, то параметры самих форм не сохраняются, но сохраняются
    // настройки компонентов, которые пожелает сохранить программист
    // данный режим используется при сохранении десктопа по выходу
    // из программы. В этом случае положения форм и их видимость не надо сохранять
    // Они (положения форм, их видимость) сохраняются в базе только
    // при принудительном сохранении десктопа или создании нового десктопа.
    procedure WriteDesktopData(ADesktopName: String; const Mode: Boolean);

    // если при загрузке десктопа не указано конкретное имя, то
    // загружается десктоп, сохраненный последним (десктоп по-умолчанию)
    // данный метод, обновляет дату сохранения десктопа, заданного
    // именем, делает его десктопом по-умолчанию
    procedure SetDefaultDesktop(ADesktopName: String);

    // присваивает экранным объектам настройки из текущего десктопа
    procedure LoadDesktop;
    // сохраняет настройки экранных объектов в текущем десктопе
    // Mode: 1 -- захоўваць і стан вокнаў і настройкі контаралаў
    //       0 -- захоўваць толькі настройкі контралаў
    // першы рэжым выкарыстоўваецца, калі карыстальнік захоўвае дэсктоп
    // уруччу. Другі рэжым выкарыстоўваецца, калі карыстальнік
    // выходзіць з дастасаваньня.
    procedure SaveDesktop(const Mode: Boolean);

    // сохраняет настройки для компонента И в десктопе
    procedure SaveDesktopItem(I: TComponent);
    // загружает экранный объект настройками, сохраненными в десктопе
    // если в десктопе нет настроек для данного объекта, то
    // в десктопе создается запись с настройками и инициализируется
    // настройками экранного объекта
    procedure LoadDesktopItem(I: TComponent);

    //
    procedure RemoveDeskTopItem(I: TComponent);

    // удаляет десктоп, заданный именем
    procedure DeleteDesktop(const ADesktopName: String);

    //
    function FindDesktop(const ADesktopName: String): Integer;

    property DesktopNames[Index: Integer]: String read GetDesktopNames;
      default;
    property DesktopCount: Integer read FDesktopCount;
    property CurrentDesktopName: String read FCurrentDesktopName;
    property CurrentDesktopIndex: Integer read GetCurrentDesktopIndex;
    property Storage: TgsStorage read FStorage;
    property DesktopItems: TDesktopItems read FDesktopItems;
    property LoadingDesktop: Boolean read FLoadingDesktop;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;

    // при считывании десктопа из базы данных и создания экранных объектов
    // мы даем программисту возможность создать некоторые объекты вручную
    // для этого он должен перекрыть данный ивент
    // остальные объекты будут создаваться по считанному из потока
    // имени класса. Заметим, что класс должен быть зарегистрирован
    property OnDesktopItemCreate: TOnDesktopItemCreateEvent read FOnDesktopItemCreate
      write FOnDesktopItemCreate;
  end;

  EDesktopError = class(Exception);

procedure Register;

var
  DesktopManager: TgsDesktopManager;

implementation

uses
  DB, IBSQL, gd_security, gd_ClassList, gdcBaseInterface,
  gdc_createable_form, gdc_frmG_unit, gd_createable_form,
  gdc_frmMDH_unit, gsResizerInterface, gd_splash, gdc_dlgG_unit,
  IBBlob;

const
  DesktopValueName = 'Desktop';

function GetScreenRes: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC, HORZRES) * GetDeviceCaps(DC, VERTRES);
  finally
    ReleaseDC(0, DC);
  end;
end;

{ TgsDesktopManager }

constructor TgsDesktopManager.Create;
begin
  // только один менеджер десктопов может быть создан на проект
  Assert(DesktopManager = nil, 'Only one desktop manager per project allowed.');
  inherited Create(AnOwner);
  DesktopManager := Self;
  FDesktopItems := TDesktopItems.Create(Self);
  FDesktopCount := 0;
  FCurrentDesktopName := '';
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10;
  FDatabase := nil;
  FStorage := TgsStorage.Create;
end;

destructor TgsDesktopManager.Destroy;
begin
  DesktopManager := nil;
  if FTransaction.InTransaction then
    FTransaction.Commit;
  FTransaction.Free;
  FDesktopItems.Free;
  FStorage.Free;
  inherited;
end;

function TgsDesktopManager.ReadDesktopData(const ADesktopName: String = ''): Boolean;
var
  IBSQL: TIBSQL;
  S: TStream;
  bs: TIBBlobStream;
begin
  Result := False;
  if DesktopCount = 0 then exit;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    if ADesktopName > '' then
      IBSQL.SQL.Text := Format('SELECT dtdata, name FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
        [IBLogin.UserKey, ADesktopName, GetScreenRes])
    else
      IBSQL.SQL.Text := Format('SELECT dtdata, name FROM gd_desktop WHERE userkey = %d AND ((screenres IS NULL) OR (screenres = %d)) ORDER BY saved DESC',
        [IBLogin.UserKey, GetScreenRes]);
    IBSQL.ExecQuery;

    if IBSQL.EOF then exit;

    if IBSQL.FieldByName('dtdata').IsNull then
      FStorage.Clear
    else begin
      bs := TIBBlobStream.Create;
      try
        bs.Mode := bmRead;
        bs.Database := FDatabase;
        bs.Transaction := FTransaction;
        bs.BlobID := IBSQL.FieldByName('dtdata').AsQUAD;
        FStorage.LoadFromStream(bs);
      finally
        bs.Free;
      end;
    end;

    try
      S := TMemoryStream.Create;
      try
        if FStorage.ReadStream('\', DesktopValueName, S) then
          FDesktopItems.ReadFromStream(S);
      finally
        S.Free;
      end;
      FCurrentDesktopName := IBSQL.FieldByName('name').AsString;
      Result := True;
    except
      if ADesktopName > '' then
        DeleteDesktop(ADesktopName);
      Result := False;
    end;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
    FTransaction.DefaultDatabase := FDatabase;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsNew', [TgsDesktopManager]);
end;

procedure TgsDesktopManager.SaveDesktopItem(I: TComponent);
var
  DI: TDesktopItem;
//  SubType: String;
begin
  DI := FDesktopItems.Find(I.ClassName, I.Name);
  (*
  DI := FDesktopItems.Find(I);
  if (DI = nil) and (I <> nil) and (I.Owner <> nil) then
  *)

  if not Assigned(DI) then
  begin
    if (I is TForm) then
    begin
      if (I is TgdcCreateableForm) and ((I as TgdcCreateableForm).SubType <> '') then
        DI := TgdcBaseData.Create
      else
        DI := TFormData.Create;
    end
    else
      DI := TDesktopItem.Create;

    FDesktopItems.Add(DI);
  end;

  DI.SaveDesktopItem(I)
end;

procedure TgsDesktopManager.LoadDesktopItem(I: TComponent);
var
  DI: TDesktopItem;
//  SubType: String;
begin
  DI := FDesktopItems.Find(I.ClassName, I.Name);
  {
  if Assigned(I.Owner) then
    DI := FDesktopItems.Find(I.Owner.Name, I.ClassName, I.Name)
  else
    DI := FDesktopItems.Find('', I.ClassName, I.Name);
  }

  if Assigned(DI) then
    DI.LoadDesktopItem(I)
  else
  begin
{    if I is TForm then
    begin
      if (I is TgdcCreateableForm) and ((I as TgdcCreateableForm).SubType <> '') then
        DI := TgdcBaseData.Create
      else
        DI := TFormData.Create;
    end
    else
      DI := TDesktopItem.Create;

    FDesktopItems.Add(DI);

    DI.SaveDesktopItem(I); }
  end;
end;

function TgsDesktopManager.GetDesktopNames(Index: Integer): String;
begin
  Assert((Index >= 0) and (Index < FDesktopCount));
  Result := FDesktopNames[Index];
end;

procedure TgsDesktopManager.WriteDesktopData;
var
  IBSQL: TIBSQL;
  I: Integer;
  Found: Boolean;
  S: TStream;
begin
  FStorage.Clear;
  // сначала считаем настройки экранных объектов
  SaveDesktop(Mode);
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    if ADesktopName = '' then
      ADesktopName := 'Стандартный';

    IBSQL.SQL.Text := Format('SELECT * FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if IBSQL.EOF then
    begin
      IBSQL.Close;
      IBSQL.SQL.Text := Format('INSERT INTO gd_desktop (userkey, screenres, name) VALUES (%d,%d,''%s'')',
        [IBLogin.UserKey, GetScreenRes, ADesktopName]);
      IBSQL.ExecQuery;
    end;

    IBSQL.Close;
    IBSQL.SQL.Text := Format('UPDATE gd_desktop SET dtdata = :D, saved=''NOW'' WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.Prepare;

    // создаем переменную типа поток в сторедже
    S := TMemoryStream.Create;
    try
      FDesktopItems.WriteToStream(S);
      FStorage.WriteStream('', DesktopValueName, S);
    finally
      S.Free;
    end;
    FStorage.WriteInteger('', 'DesktopItemsCount', FDesktopItems.Count);
    IBSQL.Params.ByName('D').AsString := FStorage.DataString;
    IBSQL.ExecQuery;
    IBSQL.Close;
    if FTransaction.InTransaction then
      FTransaction.Commit;

    Found := False;
    for I := 0 to FDesktopCount - 1 do
      if FDesktopNames[I] = ADesktopName then
      begin
        Found := True;
        break;
      end;
    if not Found then
    begin
      SetLength(FDesktopNames, FDesktopCount + 1);
      FDesktopNames[FDesktopCount] := ADesktopName;
      Inc(FDesktopCount);
    end;
    FCurrentDesktopName := ADesktopName;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.LoadDesktop;
begin
  FLoadingDesktop := True;
  try
    FDesktopItems.LoadDesktopItems;

    if DesktopManager.DesktopItems.Count > 0 then
    begin
      if (DesktopManager.DesktopItems.Items[0].Item is TForm) and
        (DesktopManager.DesktopItems.Items[0].Item as TForm).Visible
      then
      begin
        (DesktopManager.DesktopItems.Items[0].Item as TForm).SetFocus;
      end;
    end;
  finally
    FLoadingDesktop := False;
  end;
end;

procedure TgsDesktopManager.SaveDesktop;
begin
  FDesktopItems.SaveDesktopItems(Mode);
end;

procedure TgsDesktopManager.DeleteDesktop(const ADesktopName: String);
var
  IBSQL: TIBSQL;
  A: array of String;
  I, K: Integer;
begin
  if (FDesktopCount = 0) or (ADesktopName = '') then
    exit; 

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    IBSQL.SQL.Text := Format('DELETE FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;

  SetLength(A, FDesktopCount);
  for I := 0 to FDesktopCount - 1 do
    A[I] := FDesktopNames[I];
  K := 0;
  for I := 0 to FDesktopCount - 1 do
    if A[I] <> ADesktopName then
    begin
      FDesktopNames[K] := A[I];
      Inc(K);
    end;
  Dec(FDesktopCount);
  SetLength(A, 0);

  if ADesktopName = FCurrentDesktopName then
  begin
    FCurrentDesktopName := '';
  end;
end;

procedure TgsDesktopManager.ReadDesktopNames;
var
  IBSQL: TIBSQL;
begin
  FDesktopCount := 0;
  FCurrentDesktopName := '';
  SetLength(FDesktopNames, 0);

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := gdcBaseManager.ReadTransaction;
    IBSQL.SQL.Text := Format('SELECT name FROM gd_desktop WHERE userkey=%d AND ((screenres IS NULL) OR (screenres=%d))',
      [IBLogin.UserKey, GetScreenRes]);
    IBSQL.ExecQuery;
    while not IBSQL.EOF do
    begin
      SetLength(FDesktopNames, FDesktopCount + 1);
      FDesktopNames[FDesktopCount] := IBSQL.FieldByName('name').AsString;
      Inc(FDesktopCount);
      IBSQL.Next;
    end;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.InitComboBox;
var
  I: Integer;
begin
  CB.Items.Clear;
  for I := 0 to FDesktopCount - 1 do
    CB.Items.Add(FDesktopNames[I]);
  // а сьпісачак жа сартаваны! мусім сінхранізаваць
  // з нашай унутранай структурай
  for I := 0 to FDesktopCount - 1 do
    FDesktopNames[I] := CB.Items[I];
  if CurrentDesktopIndex >= 0 then
    CB.ItemIndex := CurrentDesktopIndex;
end;

function TgsDesktopManager.GetCurrentDesktopIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FDesktopCount - 1 do
    if FDesktopNames[I] = FCurrentDesktopName then
    begin
      Result := I;
      break;
    end;
end;

procedure TgsDesktopManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;
  end;
end;

function TgsDesktopManager.DoOnDesktopItemCreate(const AnItemClass,
  AnItemName: String): TComponent;
begin
  if Assigned(FOnDesktopItemCreate) then
    Result := FOnDesktopItemCreate(Self, AnItemClass, AnItemName)
  else
    Result := nil;  
end;

procedure TgsDesktopManager.SetDefaultDesktop(ADesktopName: String);
var
  IBSQL: TIBSQL;
begin
  Assert(FDesktopCount > 0);

  if ADesktopName = '' then
    ADesktopName := FCurrentDesktopName;

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    IBSQL.SQL.Text := Format('UPDATE gd_desktop SET saved = ''NOW'' WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;
end;

function TgsDesktopManager.FindDesktop(const ADesktopName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DesktopCount - 1 do
    if AnsiCompareText(ADesktopName, DesktopNames[I]) = 0 then
    begin
      Result := I;
      break;
    end;
end;

procedure TgsDesktopManager.RemoveDeskTopItem(I: TComponent);
begin
  FDesktopItems.Remove(I);
end;

{ TDesktopItem }

procedure TDesktopItem.Assign(I: TDesktopItem);
begin
  if Assigned(I) then
  begin
    FItemClassName := I.ItemClassName;
    FItemName := I.ItemName;
    FOwnerName := I.OwnerName;
    FItem := I.Item;
  end;
end;

constructor TDesktopItem.CreateFromStream(S: TReader);
begin
  Create;
  ReadFromStream(S);
end;

class function TDesktopItem.GetTypeID: Integer;
begin
  Result := 0;
end;

function TDesktopItem.IsItem(const AnOwnerName, AClassName, AName: String): Boolean;
begin
  Result := (AnOwnerName = FOwnerName) and
    (AClassName = FItemClassName) and (AName = FItemName);
end;

procedure TDesktopItem.LoadDesktopItem(I: TComponent);
begin
  // калі мы ствараем і ініцыялізуем форму настройкамі з
  // дэсктопу FItem будзе равен НІЛ
  // ініцыялізуем яго пераданай спасылкай
  if FItem = nil then
    FItem := I;
end;

function TDesktopItem.IsItem(const AClassName, AName: String): Boolean;
begin
  Result := (AClassName = FItemClassName) and (AName = FItemName);
end;

procedure TDesktopItem.LoadDesktopItem;
begin
  Assert(FItem <> nil);
  LoadDesktopItem(FItem);
end;

procedure TDesktopItem.ReadFromStream;
begin
  Reader.ReadSignature;
  FOwnerName := Reader.ReadString;
  FItemClassName := Reader.ReadString;
  FItemName := Reader.ReadString;
end;

procedure TDesktopItem.SaveDesktopItem(I: TComponent);
begin
  if Assigned(I) then
  begin
    if Assigned(I.Owner) then
      FOwnerName := I.Owner.Name
    else
      FOwnerName := '';

    FItemClassName := I.ClassName;
    FItemName := I.Name;
    FItem := I;
  end;
end;

procedure TDesktopItem.WriteToStream;
begin
  Writer.WriteSignature;
  Writer.WriteString(OwnerName);
  Writer.WriteString(ItemClassName);
  Writer.WriteString(ItemName);
end;

{ TFormData }

procedure TFormData.Assign(I: TDesktopItem);
begin
  inherited;
  if Assigned(I) then
  with I as TFormData do
  begin
    FLeft := Left;
    FTop := Top;
    FWidth := Width;
    FHeight := Height;
    FVisible := Visible;
    FWindowState := WindowState;
  end;
end;

function TFormData.GetForm: TForm;
begin
  Result := Item as TForm;
end;

class function TFormData.GetTypeID: Integer;
begin
  Result := 1;
end;

procedure TFormData.LoadDesktopItem(I: TComponent);
begin
  inherited LoadDesktopItem(I);
  if Assigned(I) then
    with I as TForm do
    begin
      WindowState := FWindowState;

      // мы не восстанавливаем размеры, координаты окна, если
      // оно максимизировано, минимизировано
      if WindowState = wsNormal then
      begin
        Left := FLeft;
        Top := FTop;
        Width := FWidth;
        Height := FHeight;
      end;

{ TODO :
DAlex. /// 
Для чего здесь Show не понятно.
В Delphi получается, что WM_Activate проходит раньше чем OnCreate, что неправильно.
Если надо откомментаровать, то сообщите мне.
                                                                          DAlex. }
      if FVisible then {Show} else
      begin
        // если главная форма - то вместо скрытия следует ее минимизировать! (denis)
        if Application.MainForm = I then
          //SendMessage(Application.MainForm.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
        else
          Hide;
      end;
    end;
end;

procedure TFormData.ReadFromStream;
begin
  inherited;
  FLeft := Reader.ReadInteger;
  FTop := Reader.ReadInteger;
  FWidth := Reader.ReadInteger;
  FHeight := Reader.ReadInteger;
  FVisible := Reader.ReadBoolean;
  FWindowState := TWindowState(Reader.ReadInteger);
end;

procedure TFormData.SaveDesktopItem(I: TComponent);
begin
  inherited;
  if Assigned(I) then
    with I as TForm do
    begin
      FLeft := Left;
      FTop := Top;
      FWidth := Width;
      FHeight := Height;
      FVisible := IsWindowVisible(Handle);
      FWindowState := WindowState;
    end;
end;

procedure TFormData.SetForm(const Value: TForm);
begin
  FItem := Value;
end;

procedure TFormData.WriteToStream;
begin
  inherited;
  Writer.WriteInteger(FLeft);
  Writer.WriteInteger(FTop);
  Writer.WriteInteger(FWidth);
  Writer.WriteInteger(FHeight);
  Writer.WriteBoolean(FVisible);
  Writer.WriteInteger(Integer(FWindowState));
end;

{ TDesktopItems }

constructor TDesktopItems.Create(ADesktopManager: TgsDesktopManager);
begin
  inherited Create;
  FItems := TObjectList.Create(True);
  FDesktopManager := ADesktopManager;
end;

destructor TDesktopItems.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TDesktopItems.Add;
begin
  Assert(Find(DI.ItemClassName, DI.ItemName) = nil, 'Items with the same classname/name are not allowed');
  FItems.Add(DI);
end;

function TDesktopItems.Find(const AnOwnerName, AClassName, AName: String): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].IsItem(AnOwnerName, AClassName, AName) then
    begin
      Result := Items[I];
      break;
    end;
end;

function TDesktopItems.Find(const Item: TComponent): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if TDesktopItem(FItems[I]).Item = Item then
    begin
      Result := FItems[I] as TDesktopItem;
      break;
    end;
end;

function TDesktopItems.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDesktopItems.GetItems(Index: Integer): TDesktopItem;
begin
  Result := TDesktopItem(FItems[Index]);
end;

procedure TDesktopItems.LoadDesktopItems;
var
  I{, K}: Integer;
  C: TComponent;
  //Cl: TPersistentClass;
  PC: TFormClass;
  F: TForm;
//  GdC: CgdcBase;
  CE: TgdClassEntry;
begin
  // усе вокны, пра якія няма дадзеных у дэсктопе
  // хаваем
  for I := 0 to Screen.FormCount - 1 do
  begin
    if (Find(Screen.Forms[I].ClassName, Screen.Forms[I].Name, '') = nil)
      and (Screen.Forms[I] <> Application.MainForm)
      and (Screen.Forms[I].FormStyle <> fsStayOnTop)
      and (Screen.Forms[I].BorderStyle = bsSizeable)
      and (Screen.Forms[I].ClassName <> 'TfrmSplash') then
    begin
      Screen.Forms[I].Hide;
    end;
  end;

  for I := Count - 1 downto 0 do
  begin
    C := FindComponent(Application, Items[I].ItemClassName, Items[I].ItemName);
    if (C <> nil) and (C is TCreateableForm) then
    begin
       TCreateableForm(C).LoadDesktopSettings;
    end
    else if (C <> nil) and (not (C is TForm)) then
      Items[I].LoadDesktopItem(C)
    else if (Items[I] is TFormData) and TFormData(Items[I]).Visible then
    begin
      if Assigned(FDesktopManager) then
        C := FDesktopManager.DoOnDesktopItemCreate(Items[I].ItemClassName, Items[I].ItemName);

      if not Assigned(C) then
      begin
        PC := TFormClass(GetClass(Items[I].ItemClassName));
        if PC <> nil then
        begin
          if Pos(USERFORM_PREFIX, Items[I].ItemName) = 1 then
          begin
            try
              F := CgdcCreateableForm(PC).CreateUser(Application, Items[I].ItemName);
              if Assigned(F) then
                F.Show;
            except
              { TODO : 
подавление исключения тут потому что Юля
к имени формы вручную прибавляет РУИД какого-то
профиля. естественно что для пользовательской
формы отыскать ресурс с таким именем не удается и возникает
исключение. }
            end;
          end
          else if PC.InheritsFrom(Tgdc_frmG) then
          begin
            if (Items[i] is TgdcBaseData) then
            begin
              CE := gdClassList.Find((Items[i] as TgdcBaseData).gdcClassName);
              if CE is TgdFormEntry {and GdC.Class_TestUserRights([tiAView, tiAChag, tiAFull], (Items[i] as TgdcBaseData).gdcSubType)} then
              begin
                // если был загружен деск-топ с пользовательскими формами
                // подключаемся к другой базе данных, где таких форм нет
                // будет ошибка
                // ее просто игнорируем.
                { TODO : а как быть если это какая другая ошибка?? }
                try
                  F := TgdFormEntry(CE).frmClass.CreateSubType(Application, (Items[i] as TgdcBaseData).gdcSubType);
                except
                  F := nil;
                end;
              end else
                F := nil;
            end else
              F := CgdcCreateableForm(PC).CreateAndAssign(Application);
            if Assigned(F) then
            begin
              if not TgdcCreateableForm(F).CreatedCarefully then
                FreeAndNil(F)
              else
                F.Show;
            end;
          end
          else if PC.InheritsFrom(Tgdc_dlgG) then
          begin
            // NOP
            // мы пропускаем диалоговые окна, даже если они
            // просочились в рабочий стол
          end
          else if PC.InheritsFrom(TgdcCreateableForm) then
            try
              C := CgdcCreateableForm(PC).CreateAndAssign(Application);
            except
            end
          else if PC.InheritsFrom(TCreateableForm) then
            try
              C := CCreateableForm(PC).CreateAndAssign(Application)
            except
            end
          else
            try
              C := PC.Create(Application);
            except
            end;
        end;
      end;

      if Assigned(C) then
        Items[I].LoadDesktopItem(C);
    end;
    if (C <> nil) and C.InheritsFrom(TCustomForm) then
      TCustomForm(C).Show;
  end;

  {$IFNDEF DEBUG}
  if gdSplash <> nil then
    gdSplash.ShowSplash;
  {$ENDIF}  
end;

procedure TDesktopItems.ReadFromStream;
var
  DI: TDesktopItem;
  Reader: TReader;
begin
  FItems.Clear;
  Reader := TReader.Create(S, 1024);
  try
    Reader.ReadSignature;
    Reader.ReadListBegin;
    while not Reader.EndOfList do
    begin
      case Reader.ReadInteger of
        0: DI := TDesktopItem.CreateFromStream(Reader);
        1: DI := TFormData.CreateFromStream(Reader);
        2: DI := TgdcBaseData.CreateFromStream(Reader);
      else
        DI := nil;
      end;

      if Assigned(DI) then
      begin
        if Find({DI.OwnerName, }DI.ItemClassName, DI.ItemName) <> nil then
        begin
          Find({DI.OwnerName, }DI.ItemClassName, DI.ItemName).Assign(DI);
          DI.Free;
        end else
          FItems.Add(DI);
      end else
        raise EDesktopError.Create('Stream error. Invalid desktop item type encountered.');
    end;
    Reader.ReadListEnd;
  finally
    Reader.Free;
  end;
end;

procedure TDesktopItems.SaveDesktopItems;
var
  I: Integer;
begin
  if Mode then
    Clear;

{ TODO : невозможно в десктопе сделать активной форму исследователя }
{ TODO : плохо использовать имя класса }

  for I := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[I] <> Application.MainForm then
    begin
      if (Screen.Forms[I] is TCreateableForm)
        and (not (Screen.Forms[I] is Tgdc_dlgG)) then
      begin
        if Screen.Forms[I].Visible or (Find(Screen.Forms[I]) <> nil) then
          (Screen.Forms[I] as TCreateableForm).SaveDesktopSettings;
      end;
    end;
  end;

  if (Application.MainForm is TCreateableForm) and Application.MainForm.Visible then
    (Application.MainForm as TCreateableForm).SaveDesktopSettings;
end;

{procedure TDesktopItems.SetItems(Index: Integer;
  const Value: TDesktopItem);
begin
  FItems[Index] := Value;
end;}

procedure TDesktopItems.WriteToStream;
var
  I: Integer;
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Writer.WriteSignature;
    Writer.WriteListBegin;
    for I := 0 to Count - 1 do
    begin
      Writer.WriteInteger(Items[I].GetTypeID);
      Items[I].WriteToStream(Writer);
    end;
    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

function TDesktopItems.FindComponent(AnOwner: TComponent; const AClassName,
  AName: String): TComponent;
var
  I: Integer;
begin
  Result := nil;
  if AnOwner <> nil then
    if (AnOwner.ClassName = AClassName) and (AnOwner.Name = AName) then
      Result := AnOwner else
    for I := 0 to AnOwner.ComponentCount - 1 do
    begin
      if (AnOwner.Components[I].ClassName = AClassName) and
        (AnOwner.Components[I].Name = AName) then
      begin
        Result := AnOwner.Components[I];
        break;
      end;

      Result := FindComponent(AnOwner.Components[I], AClassName, AName);

      if Result <> nil then
        break;
    end;
end;

function TDesktopItems.FindComponent(AnOwner, AComponent: TComponent): TComponent;
var
  I: Integer;
begin
  if AnOwner = AComponent then Result := AComponent else
  begin
    Result := nil;
    if AnOwner <> nil then
      for I := 0 to AnOwner.ComponentCount - 1 do
        if AnOwner.Components[I] = AComponent then
        begin
          Result := AnOwner.Components[I];
          break;
        end else if AnOwner.Components[I] is TForm then
        begin
          Result := FindComponent(AnOwner.Components[I], AComponent);
          if Result <> nil then break;
        end;
  end;
end;

procedure TDesktopItems.Clear;
begin
  FItems.Clear;
end;

function TDesktopItems.Find(const AClassName, AName: String): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].IsItem(AClassName, AName) then
    begin
      Result := Items[I];
      break;
    end;
end;

procedure TDesktopItems.Remove(const Item: TComponent);
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if TDesktopItem(FItems[I]).Item = Item then
    begin
      FItems.Delete(I);
      break;
    end;
end;

{ TgdcBaseData }

procedure TgdcBaseData.Assign(I: TDesktopItem);
begin
  inherited;

  if Assigned(I) then
    with I as TgdcBaseData do
    begin
      FgdcClassName := gdcClassName;
      FgdcSubType := gdcSubType;
    end;

end;

class function TgdcBaseData.GetTypeID: Integer;
begin
  Result := 2;
end;

procedure TgdcBaseData.ReadFromStream(Reader: TReader);
begin
  inherited ReadFromStream(Reader);
  FgdcClassName := Reader.ReadString;
  FgdcSubType := Reader.ReadString;
end;

procedure TgdcBaseData.SaveDesktopItem(I: TComponent);
begin
  inherited SaveDesktopItem(I);

  { TODO : 
тут херня. вместо того чтобы записать класс объекта
мы пишем класс окна. }
  FgdcClassName := I.ClassName;
  FgdcSubType := (I as TgdcCreateableForm).SubType;
end;

procedure TgdcBaseData.WriteToStream(Writer: TWriter);
begin
  inherited WriteToStream(Writer);
  Writer.WriteString(FgdcClassName);
  Writer.WriteString(FgdcSubType);
end;

initialization
  DesktopManager := nil;

finalization
  DesktopManager := nil;
end.
