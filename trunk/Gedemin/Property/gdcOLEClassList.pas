{++

  Copyright (c) 2001 - 2012 by Golden Software of Belarus

  Module

    gdcOLEClassList.pas

  Abstract

    Gedemin project. TgdcCOMClassItem, TgdcOLEClassList.

  Author

    Karpuk Alexander

  Revisions history

    1.00    04.01.01    tiptop        Initial version.
    1.10    13.10.03    DAlex         Overpatching.

--}

unit gdcOLEClassList;

interface

uses Classes, ComObj, SysUtils, ActiveX, gd_KeyAssoc, JclStrHashMap;

type
  TWrapperAutoObject = class(TAutoIntfObject)
  private
    FObject: TObject;
    FIsComponent: Boolean;

  protected
    function GetObject: TObject;

  public
    constructor Create(AObject: TObject; const TypeLib: ITypeLib; const DispIntf: TGUID);
    destructor Destroy; override;

    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; virtual;

    procedure DestroyDelphiObject;

    property DelphiObject: TObject read FObject;
  end;

  TWrapperAutoClass = class of TWrapperAutoObject;

type

  // Класс предназначен для хранения соответствия Делфовского класса
  // и его отображения в OLE области.
  TgdcCOMClassItem = class
  private
    FDelphiClass: TClass;
    FOLEClass: TWrapperAutoClass;
    FTypeLib: ITypeLib;
    FDispIntf: TGUID;
  public
    // Присвоение
    procedure Assign(ASource: TgdcCOMClassItem);

    property DelphiClass: TClass read FDelphiClass write FDelphiClass;
    property OLEClass: TWrapperAutoClass read FOLEClass write FOLEClass;
    property TypeLib: ITypeLib read FTypeLib write FTypeLib;
    property DispIntf: TGUID read FDispIntf write FDispIntf;
  end;

  // Предназначен для хранения списка данных типа:
  // TComponentClass <-> TAutoClass
  TgdcOLEClassList = class(TList)
  protected
    function Get(Index: Integer): TgdcCOMClassItem;
    procedure Put(Index: Integer; Item: TgdcCOMClassItem);
  public
    destructor Destroy; override;

    // Добавление записи TComponentClass <-> TAutoClass.
    // Обязательна проверка на существования идентичной записи
    function AddClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
      ATypeLib: ITypeLib; ADispIntf: TGUID): integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
    function Last: TgdcCOMClassItem;
    function IndexOf(AClass: TClass): Integer;
    function FindOLEClass(AClass: TClass): TWrapperAutoClass;
    function FindOLEClassItem(AClass: TClass): TgdcCOMClassItem;
    // Присвоение
    procedure Assign(ASource: TgdcOLEClassList);

    property Items[Index: Integer]: TgdcCOMClassItem read Get write Put; default;
  end;

  // Предназначен для хранения списка данных типа:
  // TComponentClass <-> TAutoClass
  TgdcOLEClassListNew = class(TgdKeyIntAssoc)
  private
    FHashClassNames: TStringHashMap;

  protected
    function Get(Index: Integer): TgdcCOMClassItem;
    procedure Put(Index: Integer; Item: TgdcCOMClassItem);

  public
    constructor Create;
    destructor Destroy; override;

    // Добавление записи TClass <-> TAutoClass.
    // Обязательна проверка на существования идентичной записи
    function AddClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
      ATypeLib: ITypeLib; ADispIntf: TGUID): integer;
    procedure DeleteClass(Index: Integer);
    procedure Clear; override;
    function IndexOfClass(AClass: TClass): Integer;
    function FindOLEClass(AClass: TClass): TWrapperAutoClass;
    function FindOLEClassItem(AClass: TClass): TgdcCOMClassItem;

    function GetClass(const AClassName: String): TClass;
    function GetWrapClass(const AClassName: String; out AClass: TClass): TWrapperAutoClass;

    // Присвоение
    procedure Assign(ASource: TgdcOLEClassListNew);

    property Items[Index: Integer]: TgdcCOMClassItem read Get write Put; default;
  end;

  IAuxiliaryDesigner = interface
    procedure RemoveObject(const AnObject: TObject);
  end;

// Регистрация класса вместе с OLE классом.
procedure RegisterGdcOLEClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
  ATypeLib: ITypeLib; ADispIntf: TGUID);
// UnРегистрация класса вместе с OLE классом.
procedure UnRegisterGdcOLEClass(AClass: TClass);

// Функция возвращает OLE класс по делфовскому классу
function FindGdcOLEClass(AClass: TClass): TWrapperAutoClass;
// Функция возвращает объект хранящий все ...
function FindGdcOLEClassItem(AClass: TClass): TgdcCOMClassItem;
// Функция возвращает OLE объект оболочку для делфовского класса
function GetGdcOLEObject(AObject: TObject): TWrapperAutoObject;

var
  OLEClassList: TgdcOLEClassListNew;
  AuxiliaryDesigner: IAuxiliaryDesigner;

implementation

uses
  gs_Exception;

type
  TgdFreeNotificationComponent = class;

  //Класс список, служит для контроля создания и удаления COM-серверов оболочек.
  TgdWrapServerList = class(TObject)
  private
    FgdWrapServerList: TgdKeyObjectAssoc;
    FFreeComponentSpy: TgdFreeNotificationComponent;

    procedure NilDelphiObject(const AnObject: TObject);

  public
    constructor Create;
    destructor  Destroy; override;

    function  GetWrapServer(const AnObject: TObject): TWrapperAutoObject;

    procedure Add(const AnObject: TObject; const gdcOLEObject: TWrapperAutoObject);
    procedure Remove(const AnObject: TObject; const AnIsComponent: Boolean);
  end;

  TgdFreeNotificationComponent = class(TComponent)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  end;

var
  gdWrapServerList: TgdWrapServerList;

destructor TgdcOLEClassList.Destroy;
begin
  Clear;

  inherited Destroy;
end;

function TgdcOLEClassList.AddClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
  ATypeLib: ITypeLib; ADispIntf: TGUID): Integer;
var
  COMClassItem: TgdcCOMClassItem;
begin
  if IndexOf(AClass) = -1 then
  begin
    COMClassItem := TgdcCOMClassItem.Create;
    COMClassItem.DelphiClass := AClass;
    COMClassItem.OLEClass := AOLEClass;
    COMClassItem.TypeLib := ATypeLib;
    COMClassItem.DispIntf := ADispIntf;
    Result := inherited Add(COMClassItem);
  end else
    Result := -1;
end;

procedure TgdcOLEClassList.Delete(Index: Integer);
begin
  Items[Index].Free;

  inherited Delete(Index);
end;

procedure TgdcOLEClassList.Clear;
begin
  while Count > 0 do
    Delete(0);
  inherited;
end;

function TgdcOLEClassList.IndexOf(AClass: TClass): Integer;
begin
  Result := 0;
  while  (Result < Count) and (Items[Result].DelphiClass <> AClass) do
    Inc(Result);
  if Result = Count then
    Result := -1;
end;

function TgdcOLEClassList.FindOLEClass(AClass: TClass): TWrapperAutoClass;
begin
  Result := FindOLEClassItem(AClass).OLEClass;
end;

procedure TgdcOLEClassList.Assign(ASource: TgdcOLEClassList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    AddClass(ASource.Items[I].DelphiClass, ASource.Items[I].OLEClass,
     ASource.Items[I].TypeLib, ASource.Items[I].DispIntf);
end;

function TgdcOLEClassList.Get(Index: Integer): TgdcCOMClassItem;
begin
  Result := TgdcCOMClassItem(inherited Items[Index]);
end;

procedure TgdcOLEClassList.Put(Index: integer; Item: TgdcCOMCLassItem);
begin
  Items[Index].Assign(Item);
end;

procedure RegisterGdcOLEClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
  ATypeLib: ITypeLib; ADispIntf: TGUID);
begin
  if not Assigned(OLEClassList) then
    OLEClassList := TgdcOLEClassListNew.Create;

  OLEClassList.AddClass(AClass, AOLEClass, ATypeLib, ADispIntf);
//  OLEClassList.Add(AClass, AOLEClass, ATypeLib, ADispIntf);
end;

procedure UnRegisterGdcOLEClass(AClass: TClass);
var
  I: Integer;
begin
  I := OLEClassList.IndexOfClass(AClass);
  if I > -1 then
    OLEClassList.DeleteClass(I);
end;

function FindGdcOLEClass(AClass: TClass): TWrapperAutoClass;
begin
  if Assigned(OLEClassList) then
    Result := OLEClassList.FindOLEClass(AClass)
  else
    Result := nil;
end;

function GetGdcOLEObject(AObject: TObject): TWrapperAutoObject;
var
  TempVar: TgdcCOMClassItem;
begin
  Result := nil;
  if (OLEClassList <> nil) and (AObject <> nil) then
  begin
    Result := gdWrapServerList.GetWrapServer(AObject);
    if Result = nil then
    begin
      if (AObject is TComponentClass) and
       (TComponent(AObject).VCLCOMObject <> nil) then
        Result := TWrapperAutoObject(TComponent(AObject).ComObject)
      else
      begin
        TempVar := OLEClassList.FindOLEClassItem(AObject.ClassType);
        if Assigned(TempVar) then
          Result := TempVar.OLEClass.Create(AObject, TempVar.TypeLib, TempVar.DispIntf);
      end;
    end;
  end
end;

function FindGdcOLEClassItem(AClass: TClass): TgdcCOMClassItem;
begin
  Result := OLEClassList.FindOLEClassItem(AClass);
end;

procedure TgdcCOMClassItem.Assign(ASource: TgdcCOMClassItem);
begin
  FDelphiClass := ASource.DelphiClass;
  FOLEClass := ASource.OLEClass;
end;

function TgdcOLEClassList.Last: TgdcCOMClassItem;
begin
  Result := TgdcCOMClassItem(Last);
end;

{ TWrapperAutoObject }

constructor TWrapperAutoObject.Create(AObject: TObject;
  const TypeLib: ITypeLib; const DispIntf: TGUID);
begin
  inherited Create(TypeLib, DispIntf);
  FObject := AObject;
  FIsComponent := FObject is TComponent;
  gdWrapServerList.Add(FObject, Self);
end;

class function TWrapperAutoObject.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := nil;
end;

destructor TWrapperAutoObject.Destroy;
begin
  gdWrapServerList.Remove(FObject, FIsComponent);
  FObject := nil;
  inherited Destroy;
end;

function TgdcOLEClassList.FindOLEClassItem(
  AClass: TClass): TgdcCOMClassItem;
var
  I: Integer;
begin
  repeat
    I := 0;
    while (I < Count) and (Items[I].DelphiClass <> AClass) do
      Inc(I);
    AClass := AClass.ClassParent;
  until (I < Count) or (AClass = nil);
  if I = Count then
    Result := nil
  else
    Result := Items[I];
end;

procedure TWrapperAutoObject.DestroyDelphiObject;
var
  ObjectKey: TObject;
begin
  ObjectKey := FObject;
  FObject := nil;
  try
    gdWrapServerList.Remove(ObjectKey, FIsComponent);
    if Assigned(AuxiliaryDesigner) then
      AuxiliaryDesigner.RemoveObject(ObjectKey);
  finally
    ObjectKey.Free;
  end;  
end;

function TWrapperAutoObject.GetObject: TObject;
begin
  if FObject = nil then
    raise Exception.Create('Объект уничтожен.');

  Result := FObject;
end;

{ TgdcOLEClassListNew }

function TgdcOLEClassListNew.AddClass(AClass: TClass;
  AOLEClass: TWrapperAutoClass; ATypeLib: ITypeLib;
  ADispIntf: TGUID): integer;
var
  COMClassItem: TgdcCOMClassItem;
begin
  if IndexOfClass(AClass) = -1 then
  begin
    COMClassItem := TgdcCOMClassItem.Create;
    COMClassItem.DelphiClass := AClass;
    COMClassItem.OLEClass := AOLEClass;
    COMClassItem.TypeLib := ATypeLib;
    COMClassItem.DispIntf := ADispIntf;

    Result := Add(Integer(AClass));
    ValuesByIndex[Result] := Integer(COMClassItem);

    // добавлено andreik
    if AClass.InheritsFrom(TPersistent) and not AClass.InheritsFrom(TComponent) then
      RegisterClass(TPersistentClass(AClass));

    FHashClassNames.Add(AClass.ClassName, AClass);
  end else
    Result := -1;
end;

procedure TgdcOLEClassListNew.Assign(ASource: TgdcOLEClassListNew);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    AddClass(ASource.Items[I].DelphiClass, ASource.Items[I].OLEClass,
     ASource.Items[I].TypeLib, ASource.Items[I].DispIntf);
end;

procedure TgdcOLEClassListNew.Clear;
begin
  while Count > 0 do DeleteClass(0);
  inherited;
end;

constructor TgdcOLEClassListNew.Create;
begin
  inherited;

  FHashClassNames := TStringHashMap.Create(CaseInSensitiveTraits, 1024);
end;

procedure TgdcOLEClassListNew.DeleteClass(Index: Integer);
var
  I: TgdcCOMClassItem;
begin
  I := TgdcCOMClassItem(ValuesByIndex[Index]);
  if I.DelphiClass.InheritsFrom(TPersistent) and not I.DelphiClass.InheritsFrom(TComponent) then
    UnRegisterClass(TPersistentClass(I.DelphiClass));
  FHashClassNames.RemoveData(I.DelphiClass);  
  I.Free;
  Delete(Index);
end;

destructor TgdcOLEClassListNew.Destroy;
begin
  Clear;
  FHashClassNames.Free;

  inherited;
end;

function TgdcOLEClassListNew.FindOLEClass(
  AClass: TClass): TWrapperAutoClass;
begin
  Result := FindOLEClassItem(AClass).OLEClass;
end;

function TgdcOLEClassListNew.FindOLEClassItem(
  AClass: TClass): TgdcCOMClassItem;
var
  I: Integer;
begin
  repeat
    I := IndexOfClass(AClass);
    AClass := AClass.ClassParent;
  until (I > -1) or (AClass = nil);
  if (I = Count) or (I = -1) then
    Result := nil
  else
    Result := Items[I];
end;

function TgdcOLEClassListNew.Get(Index: Integer): TgdcCOMClassItem;
begin
  Result := TgdcCOMClassItem(ValuesByIndex[Index]);
end;

function TgdcOLEClassListNew.GetClass(const AClassName: String): TClass;
begin
  if not FHashClassNames.Find(AClassName, Result) then
    Result := nil;
end;

function TgdcOLEClassListNew.GetWrapClass(
  const AClassName: String; out AClass: TClass): TWrapperAutoClass;
begin
  if FHashClassNames.Find(AClassName, AClass) then
    Result := TgdcCOMClassItem(ValuesByKey[Integer(AClass)]).OLEClass
  else begin
    AClass := nil;
    Result := nil;
  end;
end;

function TgdcOLEClassListNew.IndexOfClass(AClass: TClass): Integer;
begin
  Result := IndexOf(Integer(AClass));
end;

procedure TgdcOLEClassListNew.Put(Index: Integer; Item: TgdcCOMClassItem);
begin
  Items[Index].Assign(Item);
end;

{ TgdWrapServerList }

procedure TgdWrapServerList.Add(const AnObject: TObject;
  const gdcOLEObject: TWrapperAutoObject);
var
  I: Integer;
begin
  I := FgdWrapServerList.Add(Integer(AnObject));
  FgdWrapServerList.ObjectByIndex[I] := gdcOLEObject;
  if AnObject is TComponent then
    TComponent(AnObject).FreeNotification(FFreeComponentSpy);
end;

constructor TgdWrapServerList.Create;
begin
  FgdWrapServerList := TgdKeyObjectAssoc.Create;
  FFreeComponentSpy := TgdFreeNotificationComponent.Create(nil);
end;

destructor TgdWrapServerList.Destroy;
begin
  FFreeComponentSpy.Free;
  FgdWrapServerList.Free;
  inherited;
end;

function TgdWrapServerList.GetWrapServer(
  const AnObject: TObject): TWrapperAutoObject;
var
  I: Integer;
begin
  I := FgdWrapServerList.IndexOf(Integer(AnObject));
  if I > -1 then
  begin
    Result := FgdWrapServerList.ObjectByIndex[I] as TWrapperAutoObject;
    if Result.FObject <> AnObject then
    begin
      FgdWrapServerList.Delete(I);
      Result := nil;
    end;
  end else
    Result := nil;
end;

procedure TgdWrapServerList.Remove(const AnObject: TObject; const AnIsComponent: Boolean);
begin
  if Assigned(AnObject) then
  begin
    if AnIsComponent then
      (AnObject as TComponent).RemoveFreeNotification(FFreeComponentSpy);
    FgdWrapServerList.Remove(Integer(AnObject));
  end;
end;

procedure TgdWrapServerList.NilDelphiObject(const AnObject: TObject);
var
  I: Integer;
begin
  I := FgdWrapServerList.IndexOf(Integer(AnObject));
  if I > -1 then
  begin
    (FgdWrapServerList.ObjectByIndex[I] as TWrapperAutoObject).FObject := nil;
    FgdWrapServerList.Delete(I);
  end;
end;

{ TgdFreeNotificationComponent }

procedure TgdFreeNotificationComponent.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Assigned(gdWrapServerList) and (Operation = opRemove) then
  begin
    gdWrapServerList.NilDelphiObject(AComponent);
  end;  
end;

initialization
  gdWrapServerList := TgdWrapServerList.Create;

finalization
  if Assigned(OLEClassList) then
    FreeAndNil(OLEClassList);
  FreeAndNil(gdWrapServerList);
end.
