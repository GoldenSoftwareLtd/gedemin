// ShlTanya, 24.02.2019

unit mtd_Inherited;

interface

uses
  Gedemin_TLB, obj_ObjectEvent, ActiveX, Classes, mtd_i_Inherited,
  obj_Inherited, SysUtils, gdcBaseInterface;

type
  PExecuteFunction = ^TExecuteFunction;
  TExecuteFunction = record
    Id: TID;
    Executed: Boolean;
    Sender: TClass;
  end;

type
  TTwoPointer = Record
    ObjectPointer: TObject;
    EventPointer: TMethodInvoker;
    {$IFDEF DEBUG}
    ClassName: array[0..255] of AnsiChar;
    ComponentName: array[0..255] of AnsiChar;
    {$ENDIF}
  end;

  TTwoPointerList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;

    function Add(AnSender: TObject; AnMethodInvoker: TMethodInvoker): Integer;
    procedure Delete(AnSender: TObject); overload;
    procedure Delete(AnIndex: Integer); overload;
    function FindMethodInvoker(AnSender: TObject): TMethodInvoker;
    function FindObjectIndex(AnSender: TObject): Integer;
    procedure Clear; override;

    {$IFDEF DEBUG}
    function GetClassNames: String;
    {$ENDIF}
  end;

type
  TMethodInherited = class(TComponent, IgsInheritedMethodInvoker)
  private
    FInheritedObject: IgsInherited;
    FRegistredEventList: TTwoPointerList;
    FExecuteFunction: TList;

    function InvokeMethod(const AnObject: IgsObject; const AnName: WideString;
      var AnParams: OleVariant): OleVariant;

  protected
    procedure RegisterMethodInvoker(AnSender: TObject; AnMethodInvoker: TMethodInvoker);
    procedure UnRegisterMethodInvoker(AnSender: TObject);
    function Get_Self: TObject;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property InheritedObject: IgsInherited read FInheritedObject;
  end;

implementation

uses
  ComObj, Windows, gdcDelphiObject, IBCustomDataSet,
  IBDataBase, gdcConstants, mtd_i_Base,
  gd_ScrException, DB, gd_DebugLog, obj_GedeminApplication
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

function CompareItems(Item1, Item2: Pointer): Integer;
begin
  Result := Integer(TTwoPointer(Item1^).ObjectPointer) -
    Integer(TTwoPointer(Item2^).ObjectPointer);
end;

{ TMethodInherited }

constructor TMethodInherited.Create(AnOwner: TComponent);
var
  Loc: TgsInherited;
begin
  Assert(InheritedMethodInvoker = nil, '������ InheritedMethodInvoker ����� ���� ������ ����');

  inherited Create(nil);

  Loc := TgsInherited.Create;
  Loc.CustomInvoker := InvokeMethod;
  FInheritedObject := Loc;

  FRegistredEventList := TTwoPointerList.Create;
  FExecuteFunction := TList.Create;

  InheritedMethodInvoker := Self;
end;

destructor TMethodInherited.Destroy;
begin
  if Assigned(FRegistredEventList) then
  begin
    {$IFDEF DEBUG}
    // ��������. ����� �������������� ��������� �� ������
    // ���� ��� ��������� ������ � �����-�� ������ �� ���������� UnRegisterMethodInvoker
    if FRegistredEventList.Count > 0 then
      MessageBox(0, PChar(Format('�� ����������� %d ������������ ������� ��� ������ TMethodInherited. %s',
        [FRegistredEventList.Count, FRegistredEventList.GetClassNames])), '��������', MB_OK or MB_ICONWARNING);
    {$ENDIF}
    FreeAndNil(FRegistredEventList);
  end;

  if (InheritedMethodInvoker <> nil) and (InheritedMethodInvoker.Get_Self = Self) then
    InheritedMethodInvoker := nil;

  FExecuteFunction.Free;

  inherited;
end;

function TMethodInherited.Get_Self: TObject;
begin
  Result := Self;
end;

function TMethodInherited.InvokeMethod(const AnObject: IgsObject;
  const AnName: WideString; var AnParams: OleVariant): OleVariant;
var
  LMethodInvoker: TMethodInvoker;
  LDisp: IDispatch;
  LObj: TObject;
begin
  try
    LDisp := AnObject;
    LObj := TObject((LDisp as IgsObject).Get_Self);
    LMethodInvoker := FRegistredEventList.FindMethodInvoker(LObj);

    if not Assigned(LMethodInvoker) then
      raise Exception.Create(Format('����� %s �� �������� �� ��������� ������� � ������ TInheritedEvent', [LObj.ClassName]));
  except
    on E: Exception do
    begin
      MessageBox(0, PChar(E.Message), '������', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      exit;
    end;
  end;

  try
    if Assigned(gdScrException) then
      FreeAndNil(gdScrException)
    else
      gdScrException := nil;

    Result := LMethodInvoker(AnName, AnParams);
  except
    on E: Exception do
    begin
      // ��� �������� ������ �� �����
      // ��������� ������-���������� gdScrException � ���������� ���������� ������
      if not Assigned(gdScrException) then
        gdScrException := ExceptionCopier(E);
      Abort;
    end
  end;
end;

procedure TMethodInherited.RegisterMethodInvoker(AnSender: TObject;
  AnMethodInvoker: TMethodInvoker);
begin
  FRegistredEventList.Add(AnSender, AnMethodInvoker);
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn(DateTimeToStr(Now) +  Format(': ���������� ������ ��� ������� %s ���������������', [AnSender.ClassName]));
  {$ENDIF}
end;

procedure TMethodInherited.UnRegisterMethodInvoker(AnSender: TObject);
begin
  FRegistredEventList.Delete(AnSender);
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn(DateTimeToStr(Now) +  Format(': ���������� ������ ��� ������� %s ������', [AnSender.ClassName]));
  {$ENDIF}
end;

{ TTwoPointerList }

function TTwoPointerList.Add(AnSender: TObject;
  AnMethodInvoker: TMethodInvoker): Integer;
var
  LRec: ^TTwoPointer;
begin
  GetMem(LRec, SizeOf(TTwoPointer));
  LRec.ObjectPointer := AnSender;
  LRec.EventPointer := AnMethodInvoker;
  {$IFDEF DEBUG}
  StrPCopy(LRec.ClassName, AnSender.ClassName);
  if AnSender.InheritsFrom(TComponent) then
    StrPCopy(LRec.ComponentName, TComponent(AnSender).Name)
  else
    LRec.ComponentName[0] := #0;
  {$ENDIF}

  Result := inherited Add(LRec);

  Sort(CompareItems);
end;

procedure TTwoPointerList.Clear;
begin
  while Count > 0 do
    Delete(0);

  inherited;
end;

constructor TTwoPointerList.Create;
begin
  inherited;

end;

procedure TTwoPointerList.Delete(AnSender: TObject);
var
  I: Integer;
begin
  I := FindObjectIndex(AnSender);
  while I > -1 do
  begin
    Delete(I);
    I := FindObjectIndex(AnSender);
  end;
end;

procedure TTwoPointerList.Delete(AnIndex: Integer);
var
  LRec: ^TTwoPointer;
begin
  Assert((AnIndex >= 0) and (AnIndex < Count), 'Index out of range');

  LRec := Items[AnIndex];
  inherited Delete(AnIndex);
  FreeMem(LRec);
end;

destructor TTwoPointerList.Destroy;
begin
  Clear;

  inherited;
end;

function TTwoPointerList.FindMethodInvoker(AnSender: TObject): TMethodInvoker;
var
  I: Integer;
begin
  I := FindObjectIndex(AnSender);
  if I > -1 then
    Result := TTwoPointer(Items[I]^).EventPointer
  else
    Result := nil;
end;

function TTwoPointerList.FindObjectIndex(AnSender: TObject): Integer;
var
  FI, SI, CurInd, ResVal: Integer;
  LRec: TTwoPointer;
begin
  Result := -1;
  FI := 0;
  SI := Count - 1;
  LRec.ObjectPointer := AnSender;
  while (Result = -1) and (FI <= SI) do
  begin
    CurInd := (FI + SI) div 2;
    ResVal := CompareItems(@LRec, Items[CurInd]);
    if ResVal > 0 then
      FI := CurInd + 1
    else
      if ResVal < 0 then
        SI := CurInd - 1
      else
        Result := CurInd;
  end;
end;

{$IFDEF DEBUG}
function TTwoPointerList.GetClassNames: String;
var
  I: Integer;
  S: String;
begin
  S := '';
  for I := 0 to Count - 1 do
  begin
    S := S + TTwoPointer(Items[I]^).ClassName + '/' + TTwoPointer(Items[I]^).ComponentName + ', ';
  end;
  if Length(S) > 1 then
    SetLength(S, Length(S) - 2);
  Result := S;
end;
{$ENDIF}

end.
