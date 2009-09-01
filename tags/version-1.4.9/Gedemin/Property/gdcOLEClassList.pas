{++

  Copyright (c) 2001 by Golden Software of Belarus

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

uses Classes, ComObj, SysUtils, ActiveX, gd_KeyAssoc;

type
  TWrapperAutoObject = class(TAutoIntfObject)
  private
    FObject: TObject;

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

  // ����� ������������ ��� �������� ������������ ����������� ������
  // � ��� ����������� � OLE �������.
  TgdcCOMClassItem = class
  private
    FDelphiClass: TClass;
    FOLEClass: TWrapperAutoClass;
    FTypeLib: ITypeLib;
    FDispIntf: TGUID;
  public
    // ����������
    procedure Assign(ASource: TgdcCOMClassItem);

    property DelphiClass: TClass read FDelphiClass write FDelphiClass;
    property OLEClass: TWrapperAutoClass read FOLEClass write FOLEClass;
    property TypeLib: ITypeLib read FTypeLib write FTypeLib;
    property DispIntf: TGUID read FDispIntf write FDispIntf;
  end;

  // ������������ ��� �������� ������ ������ ����:
  // TComponentClass <-> TAutoClass
  TgdcOLEClassList = class(TList)
  protected
    function Get(Index: Integer): TgdcCOMClassItem;
    procedure Put(Index: Integer; Item: TgdcCOMClassItem);
  public
    destructor Destroy; override;

    // ���������� ������ TComponentClass <-> TAutoClass.
    // ����������� �������� �� ������������� ���������� ������
    function AddClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
      ATypeLib: ITypeLib; ADispIntf: TGUID): integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
    function Last: TgdcCOMClassItem;
    function IndexOf(AClass: TClass): Integer;
    function FindOLEClass(AClass: TClass): TWrapperAutoClass;
    function FindOLEClassItem(AClass: TClass): TgdcCOMClassItem;
    {function FindClass(AClass: TAutoClass): TComponentClass;}
(*    // ���������� ������ � �����
    procedure SaveToStream(AStream: TStream);
    // ���������� ������ �� ������
    procedure LoadFromStream(AStream: TStream);*)
    // ����������
    procedure Assign(ASource: TgdcOLEClassList);

    property Items[Index: Integer]: TgdcCOMClassItem read Get write Put; default;
  end;

  // ������������ ��� �������� ������ ������ ����:
  // TComponentClass <-> TAutoClass
  TgdcOLEClassListNew = class(TgdKeyIntAssoc)
  private
    FClassNames: TStringList;

  protected
    function Get(Index: Integer): TgdcCOMClassItem;
    procedure Put(Index: Integer; Item: TgdcCOMClassItem);

  public
    constructor Create;
    destructor Destroy; override;

    // ���������� ������ TClass <-> TAutoClass.
    // ����������� �������� �� ������������� ���������� ������
    function AddClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
      ATypeLib: ITypeLib; ADispIntf: TGUID): integer;
    procedure DeleteClass(Index: Integer);
    procedure Clear; override;
    function IndexOfClass(AClass: TClass): Integer;
    function FindOLEClass(AClass: TClass): TWrapperAutoClass;
    function FindOLEClassItem(AClass: TClass): TgdcCOMClassItem;

    function GetClass(const AClassName: String): TClass;
    function GetWrapClass(const AClassName: String; out AClass: TClass): TWrapperAutoClass;

    {function FindClass(AClass: TAutoClass): TComponentClass;}
(*    // ���������� ������ � �����
    procedure SaveToStream(AStream: TStream);
    // ���������� ������ �� ������
    procedure LoadFromStream(AStream: TStream);*)
    // ����������
    procedure Assign(ASource: TgdcOLEClassListNew);

    property Items[Index: Integer]: TgdcCOMClassItem read Get write Put; default;
  end;

  IAuxiliaryDesigner = interface
    procedure RemoveObject(const AnObject: TObject);
  end;

// ����������� ������ ������ � OLE �������.
procedure RegisterGdcOLEClass(AClass: TClass; AOLEClass: TWrapperAutoClass;
  ATypeLib: ITypeLib; ADispIntf: TGUID);
// Un����������� ������ ������ � OLE �������.
procedure UnRegisterGdcOLEClass(AClass: TClass);

// ������� ���������� OLE ����� �� ����������� ������
function FindGdcOLEClass(AClass: TClass): TWrapperAutoClass;
// ������� ���������� ������ �������� ��� ...
function FindGdcOLEClassItem(AClass: TClass): TgdcCOMClassItem;
// ������� ���������� OLE ������ �������� ��� ����������� ������
function GetGdcOLEObject(AObject: TObject): TWrapperAutoObject;

var
  OLEClassList: TgdcOLEClassListNew;
  AuxiliaryDesigner: IAuxiliaryDesigner;

implementation

uses
  gs_Exception;

const
  GDC_OLECLASSLIST = '^OCL';

type
  TLabelStream = array[0..3] of char;

type
  TgdFreeNotificationComponent = class;

  //����� ������, ������ ��� �������� �������� � �������� COM-�������� ��������.
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
    procedure Remove(const AnObject: TObject);
  end;

  TgdFreeNotificationComponent = class(TComponent)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  end;

var
  gdWrapServerList: TgdWrapServerList;


const
  LblSize = SizeOf(TLabelStream);

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

{function TgdcOLEClassList.FindClass(AClass: TAutoClass): TComponentClass;
var
  I: Integer;
begin
  I := 0;
  while (I < Count) and (Items[I].OleClass = AClass) do
    Inc(I);
  if I = Count then
    Result := nil
  else
    Result := Items[I].DelphiClass;
end;}

(*procedure TgdcOLEClassList.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  AStream.Write(GDC_OLECLASSLIST, LblSize);
  AStream.Write(Count, SizeOF(Count));
  for I := 0 to Count - 1 do
  begin
    AStream.Write(Items[I].DelphiClass, SizeOF(TClass));
    AStream.Write(Items[I].OLEClass, SizeOF(TWrapperAutoClass));
  end;
end;

procedure TgdcOLEClassList.LoadFromStream(AStream: TStream);
var
  I, ItemCount: Integer;
  LDelphiClass: TClass;
  LOLEClass: TWrapperAutoClass;
  Lbl:TLabelStream;
begin
  AStream.Read(Lbl, LblSize);
  if Lbl = GDC_OLECLASSLIST then
  begin
    Clear;
    AStream.Read(ItemCount, SizeOF(Count));
    for I := 0 to ItemCount - 1 do
    begin
      AStream.Read(LDelphiClass, SizeOF(LDelphiClass));
      AStream.Read(LOLEClass, SizeOF(LOLEClass));
      Add(LDelphiClass, LOLEClass);
    end;
  end else
    raise Exception.Create(GetGsException(Self, '�������� ������ ������'));
end;
*)

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
  gdWrapServerList.Add(FObject, Self);
//  FObjectKey := FObject;
end;

class function TWrapperAutoObject.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := nil;
end;

destructor TWrapperAutoObject.Destroy;
begin
  if FObject <> nil then
    gdWrapServerList.Remove(FObject);

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
    ObjectKey.Free;
  finally
    try
      gdWrapServerList.Remove(ObjectKey);
    finally
      AuxiliaryDesigner.RemoveObject(ObjectKey);
    end;
  end;
end;

function TWrapperAutoObject.GetObject: TObject;
begin
  if FObject = nil then
    raise Exception.Create('������ ���������.');

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

    // ��������� andreik
    if AClass.InheritsFrom(TPersistent) and not AClass.InheritsFrom(TComponent) then
      RegisterClass(TPersistentClass(AClass));

    FClassNames.AddObject(Copy(UpperCase(AClass.ClassName), 2, 255), Pointer(AClass));
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
  while Count > 0 do
    DeleteClass(0);

  inherited;
end;

constructor TgdcOLEClassListNew.Create;
begin
  inherited;
  FClassNames := TStringList.Create;
  FClassNames.Duplicates := dupError;
  FClassNames.Sorted := True;
end;

procedure TgdcOLEClassListNew.DeleteClass(Index: Integer);
begin
  UnRegisterClass(TPersistentClass(TgdcCOMClassItem(ValuesByIndex[Index]).DelphiClass));
  TgdcCOMClassItem(ValuesByIndex[Index]).Free;
  Delete(Index);
end;

destructor TgdcOLEClassListNew.Destroy;
begin
  Clear;
  FClassNames.Free;

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
var
  I: Integer;
begin
{ TODO :
�������, ��� � �������� ���������� �������� ���������������
��������� ����������, ���� ��� � ���. ����� ��� ������?? }
  I := FClassNames.IndexOf(UpperCase(Copy(AClassName, 2, 255)));
  if I = -1 then
    Result := nil
  else
    Result := TClass(FClassNames.Objects[I]);
end;

function TgdcOLEClassListNew.GetWrapClass(
  const AClassName: String; out AClass: TClass): TWrapperAutoClass;
var
  I: Integer;
begin
  I := FClassNames.IndexOf(UpperCase(Copy(AClassName, 2, 255)));
  if I = -1 then
    AClass := nil
  else
    AClass := TClass(FClassNames.Objects[I]);

  if AClass <> nil then
  begin
    I := Integer(FClassNames.Objects[I]);
    Result := TgdcCOMClassItem(ValuesByKey[I]).OLEClass;
  end else
    Result := nil;
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
  if AnObject.InheritsFrom(TComponent) then
    TComponent(AnObject).FreeNotification(FFreeComponentSpy);
end;

constructor TgdWrapServerList.Create;
begin
  FgdWrapServerList := TgdKeyObjectAssoc.Create;
  FFreeComponentSpy := TgdFreeNotificationComponent.Create(nil);
end;

destructor TgdWrapServerList.Destroy;
begin
  FgdWrapServerList.Free;
  FFreeComponentSpy.Free;

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

procedure TgdWrapServerList.Remove(const AnObject: TObject);
begin
  if Assigned(FgdWrapServerList) then
  begin
    if AnObject.InheritsFrom(TComponent) then
      (AnObject as TComponent).RemoveFreeNotification(FFreeComponentSpy);
    FgdWrapServerList.Remove(Integer(AnObject));
  end;
end;

procedure TgdWrapServerList.NilDelphiObject(const AnObject: TObject);
var
  I: Integer;
begin
  if Assigned(FgdWrapServerList) then
  begin
    I := FgdWrapServerList.IndexOf(Integer(AnObject));
    if I > -1 then
    begin
      (FgdWrapServerList.ObjectByIndex[I] as TWrapperAutoObject).FObject := nil;
      FgdWrapServerList.Delete(I);
    end;
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
//  OLEClassList := nil;
  gdWrapServerList := TgdWrapServerList.Create;

finalization
  if Assigned(OLEClassList) then
    FreeAndNil(OLEClassList);
  FreeAndNil(gdWrapServerList);

end.
