unit obj_Designer;

interface

uses
  ComObj, Gedemin_TLB, Comserv, Contnrs, classes, gd_KeyAssoc, gdcOLEClassList;

type
  // ������ ������ ������������ ��� ������� ������ ��������� �
  // ������������ ���������� ��������.
  // ��� ����������� ���������� ������� ������ ������� ��� �� ������.
  TobjDesignerFreeSpy = class(TComponent)
  private
    FObjectList: TObjectList;

    function GetCount: Integer;
    function GetObjectList(Index: Integer): TObject;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor  Destroy; override;

    function  Add(AObject: TObject): Integer;
    function  IndexOf(AObject: TObject): Integer;
    function  Remove(AObject: TObject): Integer;
    procedure Delete(Index: Integer);

    property  ObjectList[Index: Integer]: TObject read GetObjectList; default;
    property  Count: Integer read GetCount;
  end;

  TobjDesigner = class(TAutoObject, IgsDesigner, IAuxiliaryDesigner)
  private
    // ������, ��������� ��������
    FObjectList: TobjDesignerFreeSpy;

    function GetRegisterObject(const AObject: TObject): IgsObject;

    procedure FreeAllObject;
  protected
    function  CreateObject(Owner: OleVariant; const ClassName: WideString; const Name: WideString): IgsObject; safecall;
    // ������ ��� �������� ������������� �������, ������� ��������� � ������������
    function  CreateObjectWithParams(const ClassName: WideString; const Name: WideString;
                                     ParamsArray: OleVariant): IgsObject; safecall;
    function  CreateForm(Owner: OleVariant; const ClassName: WideString;
                         const Name: WideString): IgsObject; safecall;
    procedure DestroyObject(const AObject: IgsObject); safecall;
    function  FindObject(const Name: WideString): IgsObject; safecall;
  public
    destructor Destroy; override;

    procedure Initialize; override;

    procedure RemoveObject(const AnObject: TObject);
  end;

var
  Designer: TObjDesigner;

implementation

uses
  prp_Methods, controls, sysutils,
  gsResizerInterface, Windows, obj_WrapperDelphiClasses,
  gd_createable_form, Storages, gd_directories_const, gdc_createable_form,
  gd_DebugLog, Graphics, obj_WrapperIBXClasses;

var
  IDesigner: IgsDesigner;

{ TwrpDesigner }

function TobjDesigner.CreateForm(
  Owner: OleVariant; const ClassName: WideString;
  const Name: WideString): IgsObject;
begin
  Result := CreateObject(Owner, ClassName, Name);
end;

function  TobjDesigner.CreateObject
  (Owner: OleVariant; const ClassName: WideString; const Name: WideString): IgsObject;
var
  LObjectClass: TClass;
  LObject: TObject;
  LOwner: TComponent;
  LWrapClass: TWrapperAutoClass;
  LClassName: String;
  LUserForm: Boolean;

const
  dsStClassPref = 'T';

begin
  if VariantIsArray(Owner) then
  begin
    Result := CreateObjectWithParams(ClassName, Name, Owner);
    Exit;
  end;

  Result := nil;
  LOwner := nil;
  LObject := nil;
  LObjectClass := nil;
  LUserForm := False;

  LClassName := AnsiUpperCase(Trim(ClassName));

  if LClassName = '' then
    raise Exception.Create('Invalid class name');

  //���� ����� �� ���������� � T, �� ��� ���������������� �����
  { TODO : ����� ��������� �� ������� �������� usrf_?? }
  if (LClassName[1] <> dsStClassPref) then
  begin
    LClassName := AnsiUpperCase(GlobalStorage.ReadString(
      st_ds_NewFormPath + '\' + ClassName, st_ds_FormClass));
    LUserForm  := True;
  end;

  //���� ����� ����������������� � OleClassList
  LWrapClass := OleClassList.GetWrapClass(LClassName, LObjectClass);

  //���� ����� �� ������, �� ���� ����� GetClass
  if LObjectClass = nil then
    LObjectClass := GetClass(LClassName);

  //���� ������ ����-����� � ����-����� � �� �� ����������, �� �������� �������� ������ �� ����-������
  if (LWrapClass <> nil) and (LObjectClass <> nil) and (not LObjectClass.InheritsFrom(TComponent)) then
    LObject := LWrapClass.CreateObject(LObjectClass, Owner);

  if LObjectClass <> nil then
  begin
    try
      //���� ������ �� ������ ����-�������, �� �������� ������� ��� ����������� ��������
      if LObject = nil then
      begin
        //�������� ����������
        if LObjectClass.InheritsFrom(TComponent) then
        begin
          // �������� ����� ����������
          if (VarType(Owner) = varDispatch) and (IDispatch(Owner) <> nil) and
            (InterfaceToObject(Owner) is TComponent) then
          begin
            LOwner := InterfaceToObject(Owner) as TComponent;
          end;

          // ������� ���������. ���� ��� �����, �� ����� ����� ���������
          if LObjectClass.InheritsFrom(TCreateableForm) and LUserForm then
            LObject := CCreateableForm(LObjectClass).CreateUser(LOwner, ClassName)
          else
            LObject := TComponentClass(LObjectClass).Create(LOwner);

          // ����������� ��� ����������
          if Length(Trim(Name)) > 0 then
            TComponent(LObject).Name := Trim(Name);

          // ���� ���� ����������� ������
          if (LObject is TControl) and (not LObjectClass.InheritsFrom(TCreateableForm))
             and (LOwner is TWinControl) then
          begin
            TWinControl(LObject).Parent := LOwner as TWinControl;
          end;
        end else
          LObject := LObjectClass.Create;
      end;
      Result := GetRegisterObject(LObject);
    except
      on E: Exception do
      begin
        // � ������ ������������� ������ ����������� ������
        LObject.Free;
        raise Exception.Create(Format('%s: ������ �������� ������� %s: %s',
         [ClassName, Name, E.Message]));
      end;
    end;
  end else
    raise Exception.Create(Format(
      '���������� ������� ������ ������ %s.'#13#10 +
      '����� "%s" �� ���������������!', [ClassName, ClassName]));
end;

function TobjDesigner.CreateObjectWithParams(const ClassName,
  Name: WideString; ParamsArray: OleVariant): IgsObject;
var
  LObject: TObject;
  LObjectClass: TClass;
  LWrapClass: TWrapperAutoClass;
  LClassName: String;

const
  dsStClassPref = 'T';
begin
  // ������������ ������: TFileStream
  LObject := nil;
  Result := nil;
  LObjectClass := nil;
  LClassName := AnsiUpperCase(Trim(ClassName));
  try
    //���� ����� ����������������� � OleClassList
    LWrapClass := OleClassList.GetWrapClass(LClassName, LObjectClass);
    if LObjectClass <> nil then
    begin
      //���� ����� ������ � �� �� ����������, �� �������� �������� ������ �� ����-������
      if LWrapClass <> nil then
      begin
        LObject := LWrapClass.CreateObject(LObjectClass, ParamsArray);
      end;
    end;

    if LObject <> nil then
    begin
      if LObject.InheritsFrom(TComponent) then
        TComponent(LObject).Name := Name;
      Result := GetRegisterObject(LObject)
    end else
      raise Exception.Create('����� �� ������������ ����� "' + ClassName + '".');
  except
    LObject.Free;
    raise;
  end;
end;

destructor TobjDesigner.Destroy;
begin
  {$IFDEF DEBUG}
  if FObjectList.Count > 0 then
  begin
    Log.LogLn(Format('�� ����������� %d �������� ��������� � Designer', [FObjectList.Count]));
  end;
  {$ENDIF}

  FreeAllObject;
  FreeAndNil(FObjectList);
  inherited;
end;

procedure TobjDesigner.DestroyObject(const AObject: IgsObject);
begin
  if Assigned(AObject) then
    AObject.DestroyObject;
end;

function TobjDesigner.FindObject(const Name: WideString): IgsObject;
var
  I: Integer;
begin
  for I := 0 to FObjectList.Count - 1 do
  begin
    if FObjectList[I] is TComponent and
      (AnsiUpperCase(TComponent(FObjectList[I]).Name) = AnsiUpperCase(Name)) then
    begin
      Result := GetGdcOLEObject(FObjectList[I]) as IgsObject;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TobjDesigner.FreeAllObject;
var
  I: Integer;
  LObject: TObject;
  WrapObject: TWrapperAutoObject;
begin
  for I := FObjectList.Count - 1 downto 0 do
  begin
    LObject := FObjectList[I];
    FObjectList.Delete(I);
    WrapObject := GetGdcOLEObject(LObject);
    if WrapObject <> nil then
      WrapObject.DestroyDelphiObject
    else
      LObject.Free;
  end;
end;

function TobjDesigner.GetRegisterObject(const AObject: TObject): IgsObject;
var
  LWrapper: TWrapperAutoObject;
begin
  LWrapper := GetGdcOLEObject(AObject);
  // ���� �������� ��� ������ �� �������
  if not Assigned(LWrapper) then
    raise Exception.Create(Format('�� ������� ����� �������� ��� ������ %s',
     [ClassName]));
  // ��������� ������ � ������
  FObjectList.Add(AObject);
  // ����������� ���������
  Result := LWrapper as IgsObject;
end;

procedure TobjDesigner.Initialize;
begin
  inherited;

  FObjectList := TobjDesignerFreeSpy.Create(nil);
end;

{ TobjDesignerFreeSpy }

function TobjDesignerFreeSpy.Add(AObject: TObject): Integer;
begin
  Result := FObjectList.Add(AObject);
  if AObject is TComponent then
    FreeNotification(TComponent(AObject));
end;

constructor TobjDesignerFreeSpy.Create(Owner: TComponent);
begin
  inherited;
  FObjectList := TObjectList.Create(False);
end;

procedure TobjDesignerFreeSpy.Delete(Index: Integer);
begin
  FObjectList.Delete(Index);
end;

destructor TobjDesignerFreeSpy.Destroy;
begin
  FObjectList.Free;
  inherited;
end;

function TobjDesignerFreeSpy.GetCount: Integer;
begin
  Result := FObjectList.Count;
end;

function TobjDesignerFreeSpy.GetObjectList(Index: Integer): TObject;
begin
  Result := FObjectList[Index];
end;

function TobjDesignerFreeSpy.IndexOf(AObject: TObject): Integer;
begin
  Result := FObjectList.IndexOf(AObject);
end;

procedure TobjDesignerFreeSpy.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
    Remove(AComponent);

  inherited;
end;

function TobjDesignerFreeSpy.Remove(AObject: TObject): Integer;
begin
  Result := FObjectList.Count - 1;
  while (Result > -1) and (FObjectList[Result] <> AObject) do
    Dec(Result);

  if Result > -1 then FObjectList.Delete(Result);
end;

procedure TobjDesigner.RemoveObject(const AnObject: TObject);
begin
  FObjectList.Remove(AnObject);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TobjDesigner, CLASS_gs_Designer,
    ciMultiInstance, tmApartment);

  Designer := TobjDesigner.Create;
  IDesigner := Designer;
  AuxiliaryDesigner := Designer;

finalization
  IDesigner := nil;
  Designer := nil;
end.

